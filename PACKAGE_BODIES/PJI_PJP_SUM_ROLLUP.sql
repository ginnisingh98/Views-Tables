--------------------------------------------------------
--  DDL for Package Body PJI_PJP_SUM_ROLLUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_SUM_ROLLUP" as
  /* $Header: PJISP02B.pls 120.75.12010000.18 2010/05/24 09:17:40 arbandyo ship $ */

  g_event_id              number(15);
  g_project_id            number(15);
  g_plan_type_id          number(15);
  g_old_baselined_version number(15);
  g_new_baselined_version number(15);
  g_old_original_version  number(15);
  g_new_original_version  number(15);
  g_old_struct_version    number(15);
  g_new_struct_version    number(15);
  g_rbs_version           number(15);
  g_cb_plans constant NUMBER := 2;
  g_co_plans constant NUMBER := 4;
  g_lp_plans constant NUMBER := 8;
  g_wk_plans constant NUMBER := 16;
  g_latest_plans constant NUMBER := 30;
  g_all_plans constant NUMBER := 62;

  -- -----------------------------------------------------
  -- procedure POPULATE_TIME_DIMENSION
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure POPULATE_TIME_DIMENSION (p_worker_id in number) is

    l_process varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_TIME_DIMENSION(p_worker_id);')) then
      return;
    end if;

    PJI_TIME_C.LOAD(null, null, l_return_status, l_msg_count, l_msg_data);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_TIME_DIMENSION(p_worker_id);');

    commit;

  end POPULATE_TIME_DIMENSION;


  -- -----------------------------------------------------
  -- procedure CREATE_EVENTS_SNAPSHOT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure CREATE_EVENTS_SNAPSHOT (p_worker_id in number) is

    cursor events (p_worker_id in number) is
    select /*+ ordered index(log PA_PJI_PROJ_EVENTS_LOG_N1) use_hash(log) */     /* Modified for Bug 7669026 */
      distinct
      log.ROWID LOG_ROWID,
      log.EVENT_TYPE,
      log.EVENT_ID,
      log.EVENT_OBJECT,
      log.OPERATION_TYPE,
      log.STATUS,
      log.ATTRIBUTE_CATEGORY,
      log.ATTRIBUTE1,
      to_char(decode(log.EVENT_TYPE,
                     'RBS_PRG',   ver.RBS_HEADER_ID,
                     'RBS_ASSOC', ver.RBS_HEADER_ID,
                                  log.ATTRIBUTE2)) ATTRIBUTE2,
      log.ATTRIBUTE3,
      log.ATTRIBUTE4,
      log.ATTRIBUTE5,
      log.ATTRIBUTE6,
      log.ATTRIBUTE7,
      log.ATTRIBUTE8,
      log.ATTRIBUTE9,
      log.ATTRIBUTE10,
      log.ATTRIBUTE11,
      log.ATTRIBUTE12,
      log.ATTRIBUTE13,
      log.ATTRIBUTE14,
      log.ATTRIBUTE15,
      log.ATTRIBUTE16,
      log.ATTRIBUTE17,
      log.ATTRIBUTE18,
      log.ATTRIBUTE19,
      log.ATTRIBUTE20
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_PJI_PROJ_EVENTS_LOG log,
      PA_RBS_VERSIONS_B      ver
    where
      map.WORKER_ID    =  p_worker_id and
      log.EVENT_TYPE   in (-- 'WBS_CHANGE',          -- disable bulk processing
                           -- 'WBS_PUBLISH',         -- of WBS events
                           'RBS_ASSOC',
                           'RBS_PRG') and
      log.ATTRIBUTE1   = map.PROJECT_ID and
      log.EVENT_OBJECT = ver.RBS_VERSION_ID (+)
    union all
    select /*+ ordered index(log PA_PJI_PROJ_EVENTS_LOG_N1) use_hash(log) */             /* Modified for Bug 7669026 */
      distinct
      log.ROWID LOG_ROWID,
      log.EVENT_TYPE,
      log.EVENT_ID,
      log.EVENT_OBJECT,
      log.OPERATION_TYPE,
      log.STATUS,
      log.ATTRIBUTE_CATEGORY,
      log.ATTRIBUTE1,
      log.ATTRIBUTE2,
      log.ATTRIBUTE3,
      log.ATTRIBUTE4,
      log.ATTRIBUTE5,
      log.ATTRIBUTE6,
      log.ATTRIBUTE7,
      log.ATTRIBUTE8,
      log.ATTRIBUTE9,
      log.ATTRIBUTE10,
      log.ATTRIBUTE11,
      log.ATTRIBUTE12,
      log.ATTRIBUTE13,
      log.ATTRIBUTE14,
      log.ATTRIBUTE15,
      log.ATTRIBUTE16,
      log.ATTRIBUTE17,
      log.ATTRIBUTE18,
      log.ATTRIBUTE19,
      log.ATTRIBUTE20
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_PJI_PROJ_EVENTS_LOG log
    where
      map.WORKER_ID    = p_worker_id  and
      log.EVENT_TYPE   = 'PRG_CHANGE' and
      log.EVENT_OBJECT = -1           and
      log.ATTRIBUTE1   = map.PROJECT_ID;

    cursor prg_change_events (p_worker_id in number) is
    select /*+ index(log PA_PJI_PROJ_EVENTS_LOG_N1) */
      log.ROWID LOG_ROWID,
      log.EVENT_TYPE,
      log.EVENT_ID,
      log.EVENT_OBJECT,
      log.OPERATION_TYPE,
      log.STATUS,
      log.ATTRIBUTE_CATEGORY,
      log.ATTRIBUTE1,
      log.ATTRIBUTE2,
      log.ATTRIBUTE3,
      log.ATTRIBUTE4,
      log.ATTRIBUTE5,
      log.ATTRIBUTE6,
      log.ATTRIBUTE7,
      log.ATTRIBUTE8,
      log.ATTRIBUTE9,
      log.ATTRIBUTE10,
      log.ATTRIBUTE11,
      log.ATTRIBUTE12,
      log.ATTRIBUTE13,
      log.ATTRIBUTE14,
      log.ATTRIBUTE15,
      log.ATTRIBUTE16,
      log.ATTRIBUTE17,
      log.ATTRIBUTE18,
      log.ATTRIBUTE19,
      log.ATTRIBUTE20
    from
      PA_PJI_PROJ_EVENTS_LOG log,
      (
        select /*+ ordered index(ver PA_PROJ_ELEMENT_VERSIONS_N3) */
          distinct
          ver.PRG_GROUP
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PA_PROJ_ELEMENT_VERSIONS ver
        where
          map.WORKER_ID = p_worker_id and
          map.PROJECT_ID = ver.PROJECT_ID and
          ver.PRG_GROUP is not null
      ) map
    where
      log.EVENT_TYPE   =  'PRG_CHANGE' and
      log.EVENT_OBJECT <> -1           and
      map.PRG_GROUP    in (log.EVENT_OBJECT, log.ATTRIBUTE1);

    cursor rbs_push_events (p_worker_id in number,
                            p_rbs_header_id in number) is
    select /*+ index(log PA_PJI_PROJ_EVENTS_LOG_N1) */
      distinct
      log.ROWID                             LOG_ROWID,
      log.EVENT_TYPE,
      log.EVENT_ID,
      log.EVENT_OBJECT,
      log.OPERATION_TYPE,
      log.STATUS,
      log.ATTRIBUTE_CATEGORY,
      log.ATTRIBUTE1,
      nvl(log.ATTRIBUTE2, log.EVENT_OBJECT) ATTRIBUTE2,
      log.ATTRIBUTE3,
      log.ATTRIBUTE4,
      log.ATTRIBUTE5,
      log.ATTRIBUTE6,
      log.ATTRIBUTE7,
      log.ATTRIBUTE8,
      log.ATTRIBUTE9,
      log.ATTRIBUTE10,
      log.ATTRIBUTE11,
      log.ATTRIBUTE12,
      log.ATTRIBUTE13,
      log.ATTRIBUTE14,
      log.ATTRIBUTE15,
      'N'                                   ATTRIBUTE16, -- project event flag
      log.ATTRIBUTE17,                                   -- chain identifier
      log.ATTRIBUTE18,                                   -- push chain flag
      log.ATTRIBUTE19,                                   -- project id
      ver.RBS_HEADER_ID                     ATTRIBUTE20  -- rbs header
    from
      PA_PJI_PROJ_EVENTS_LOG log,
      (
      select
        distinct
        asg.RBS_HEADER_ID,
        asg.RBS_VERSION_ID
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PA_RBS_PRJ_ASSIGNMENTS asg
      where
        map.WORKER_ID     = p_worker_id and
        asg.PROJECT_ID    = map.PROJECT_ID and
        asg.RBS_HEADER_ID = nvl(p_rbs_header_id,
                                asg.RBS_HEADER_ID)
      ) ver
    where
      log.EVENT_TYPE = 'RBS_PUSH' and
      ver.RBS_VERSION_ID in (log.EVENT_OBJECT, log.ATTRIBUTE2);

    cursor rbs_delete_events (p_worker_id in number,
                              p_rbs_header_id in number) is
    select /*+ index(log PA_PJI_PROJ_EVENTS_LOG_N1) */
      distinct
      log.ROWID LOG_ROWID,
      log.EVENT_TYPE,
      log.EVENT_ID,
      log.EVENT_OBJECT,
      log.OPERATION_TYPE,
      log.STATUS,
      log.ATTRIBUTE_CATEGORY,
      log.ATTRIBUTE1,
      log.ATTRIBUTE2,
      log.ATTRIBUTE3,
      log.ATTRIBUTE4,
      log.ATTRIBUTE5,
      log.ATTRIBUTE6,
      log.ATTRIBUTE7,
      log.ATTRIBUTE8,
      log.ATTRIBUTE9,
      log.ATTRIBUTE10,
      log.ATTRIBUTE11,
      log.ATTRIBUTE12,
      log.ATTRIBUTE13,
      log.ATTRIBUTE14,
      log.ATTRIBUTE15,
      log.ATTRIBUTE16,
      log.ATTRIBUTE17,
      log.ATTRIBUTE18,
      log.ATTRIBUTE19,
      log.ATTRIBUTE20
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_RBS_PRJ_ASSIGNMENTS asg,
      PA_PJI_PROJ_EVENTS_LOG log
    where
      map.WORKER_ID     = p_worker_id            and
      asg.PROJECT_ID    = map.PROJECT_ID         and
      asg.RBS_HEADER_ID = nvl(p_rbs_header_id,
                              asg.RBS_HEADER_ID) and
      log.EVENT_TYPE    = 'RBS_DELETE'           and
      log.EVENT_OBJECT  = asg.RBS_VERSION_ID;

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);
    l_rbs_header_id     number;
    l_chain_flag        varchar2(150);
    l_last_rbs_link     number;

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_EVENTS_SNAPSHOT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      insert into PJI_PA_PROJ_EVENTS_LOG
      (
        WORKER_ID,
        LOG_ROWID,
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20
      )
      select /*+ ordered index(log PA_PJI_PROJ_EVENTS_LOG_N1)
                         use_hash(log)
                         use_hash(map) */
        p_worker_id,
        log.ROWID,
        log.EVENT_TYPE,
        log.EVENT_ID,
        log.EVENT_OBJECT,
        log.OPERATION_TYPE,
        log.STATUS,
        log.ATTRIBUTE_CATEGORY,
        log.ATTRIBUTE1,
        log.ATTRIBUTE2,
        log.ATTRIBUTE3,
        log.ATTRIBUTE4,
        log.ATTRIBUTE5,
        log.ATTRIBUTE6,
        log.ATTRIBUTE7,
        log.ATTRIBUTE8,
        log.ATTRIBUTE9,
        log.ATTRIBUTE10,
        log.ATTRIBUTE11,
        log.ATTRIBUTE12,
        log.ATTRIBUTE13,
        log.ATTRIBUTE14,
        log.ATTRIBUTE15,
        log.ATTRIBUTE16,
        log.ATTRIBUTE17,
        log.ATTRIBUTE18,
        log.ATTRIBUTE19,
        log.ATTRIBUTE20
      from
        PA_PJI_PROJ_EVENTS_LOG log,
        PJI_PJP_PROJ_BATCH_MAP map
      where
        map.WORKER_ID    = p_worker_id    and
        log.EVENT_TYPE   = 'PRG_CHANGE'   and
        log.EVENT_OBJECT = -1             and
        log.ATTRIBUTE1   = map.PROJECT_ID;

      delete
      from   PA_PJI_PROJ_EVENTS_LOG
      where  ROWID in (select LOG_ROWID
                       from   PJI_PA_PROJ_EVENTS_LOG
                       where  WORKER_ID = p_worker_id);

    elsif (l_extraction_type = 'INCREMENTAL') then

      for c in events(p_worker_id) loop

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          LOG_ROWID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE16,
          ATTRIBUTE17,
          ATTRIBUTE18,
          ATTRIBUTE19,
          ATTRIBUTE20
        )
        values
        (
          p_worker_id,
          c.LOG_ROWID,
          c.EVENT_TYPE,
          c.EVENT_ID,
          c.EVENT_OBJECT,
          c.OPERATION_TYPE,
          c.STATUS,
          c.ATTRIBUTE_CATEGORY,
          c.ATTRIBUTE1,
          c.ATTRIBUTE2,
          c.ATTRIBUTE3,
          c.ATTRIBUTE4,
          c.ATTRIBUTE5,
          c.ATTRIBUTE6,
          c.ATTRIBUTE7,
          c.ATTRIBUTE8,
          c.ATTRIBUTE9,
          c.ATTRIBUTE10,
          c.ATTRIBUTE11,
          c.ATTRIBUTE12,
          c.ATTRIBUTE13,
          c.ATTRIBUTE14,
          c.ATTRIBUTE15,
          c.ATTRIBUTE16,
          c.ATTRIBUTE17,
          c.ATTRIBUTE18,
          c.ATTRIBUTE19,
          c.ATTRIBUTE20
        );

        delete
        from   PA_PJI_PROJ_EVENTS_LOG
        where  ROWID = c.LOG_ROWID;

      end loop;

      for c in prg_change_events(p_worker_id) loop

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          LOG_ROWID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE16,
          ATTRIBUTE17,
          ATTRIBUTE18,
          ATTRIBUTE19,
          ATTRIBUTE20
        )
        values
        (
          p_worker_id,
          c.LOG_ROWID,
          c.EVENT_TYPE,
          c.EVENT_ID,
          c.EVENT_OBJECT,
          c.OPERATION_TYPE,
          c.STATUS,
          c.ATTRIBUTE_CATEGORY,
          c.ATTRIBUTE1,
          c.ATTRIBUTE2,
          c.ATTRIBUTE3,
          c.ATTRIBUTE4,
          c.ATTRIBUTE5,
          c.ATTRIBUTE6,
          c.ATTRIBUTE7,
          c.ATTRIBUTE8,
          c.ATTRIBUTE9,
          c.ATTRIBUTE10,
          c.ATTRIBUTE11,
          c.ATTRIBUTE12,
          c.ATTRIBUTE13,
          c.ATTRIBUTE14,
          c.ATTRIBUTE15,
          c.ATTRIBUTE16,
          c.ATTRIBUTE17,
          c.ATTRIBUTE18,
          c.ATTRIBUTE19,
          c.ATTRIBUTE20
        );

        delete
        from   PA_PJI_PROJ_EVENTS_LOG
        where  ROWID = c.LOG_ROWID;

      end loop;

      -- RBS_PRG events override RBS_ASSOC events

      delete
      from   PJI_PA_PROJ_EVENTS_LOG log1
      where  log1.WORKER_ID = p_worker_id and
             log1.EVENT_TYPE = 'RBS_ASSOC' and
             exists (select 1
                     from   PJI_PA_PROJ_EVENTS_LOG log2
                     where  log2.WORKER_ID    = p_worker_id       and
                            log2.EVENT_TYPE   = 'RBS_PRG'         and
                            log2.EVENT_OBJECT = log1.EVENT_OBJECT and
                            log2.ATTRIBUTE1   = log1.ATTRIBUTE1);

      -- convert RBS_PRG events into RBS_ASSOC events

      for c in (select distinct
                       EVENT_OBJECT RBS_VERSION_ID,
                       ATTRIBUTE1   PROJECT_ID,
                       ATTRIBUTE2   RBS_HEADER_ID
                from   PJI_PA_PROJ_EVENTS_LOG
                where  WORKER_ID = p_worker_id and
                       EVENT_TYPE = 'RBS_PRG') loop

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          LOG_ROWID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE16,
          ATTRIBUTE17,
          ATTRIBUTE18,
          ATTRIBUTE19,
          ATTRIBUTE20
        )
        select
          distinct
          p_worker_id                      WORKER_ID,
          null                             LOG_ROWID,
          'RBS_ASSOC'                      EVENT_TYPE,
          -1                               EVENT_ID,
          c.RBS_VERSION_ID                 EVENT_OBJECT,
          'I'                              OPERATION_TYPE,
          'X'                              STATUS,
          null                             ATTRIBUTE_CATEGORY,
          emt.PROJECT_ID                   ATTRIBUTE1,
          c.RBS_HEADER_ID                  ATTRIBUTE2,
          null                             ATTRIBUTE3,
          null                             ATTRIBUTE4,
          null                             ATTRIBUTE5,
          null                             ATTRIBUTE6,
          null                             ATTRIBUTE7,
          null                             ATTRIBUTE8,
          null                             ATTRIBUTE9,
          null                             ATTRIBUTE10,
          null                             ATTRIBUTE11,
          null                             ATTRIBUTE12,
          null                             ATTRIBUTE13,
          null                             ATTRIBUTE14,
          null                             ATTRIBUTE15,
          null                             ATTRIBUTE16,
          c.PROJECT_ID                     ATTRIBUTE17, -- program's PROJECT_ID
          decode(prg.SUB_EMT_ID,
                 prg.SUB_ROLLUP_ID, 'Y',
                                    'N')   ATTRIBUTE18, -- PROG_REP_USAGE_FLAG
          decode(rbs_hdr.PROJECT_ID,
                 null, null,
                       'MARK_AS_PROG_REP') ATTRIBUTE19, -- update header only
          'CONVERTED_RBS_PRG_EVENT'        ATTRIBUTE20  -- flg converted events
        from
          PA_XBS_DENORM          prg,
          PA_PROJ_ELEMENTS       emt,
          PJI_PJP_RBS_HEADER     rbs_hdr,
          PJI_PA_PROJ_EVENTS_LOG log
        where
          prg.SUP_PROJECT_ID  = c.PROJECT_ID                and
          (prg.SUB_EMT_ID = prg.SUB_ROLLUP_ID or
           prg.SUP_EMT_ID <> prg.SUB_EMT_ID)                and
          emt.PROJ_ELEMENT_ID = prg.SUB_EMT_ID              and
          emt.PROJECT_ID      = rbs_hdr.PROJECT_ID      (+) and
          -1                  = rbs_hdr.PLAN_VERSION_ID (+) and
          c.RBS_VERSION_ID    = rbs_hdr.RBS_VERSION_ID  (+) and
          (rbs_hdr.PROJECT_ID is null or
           prg.SUB_EMT_ID = prg.SUB_ROLLUP_ID)              and
          p_worker_id         = log.WORKER_ID           (+) and
          'RBS_ASSOC'         = log.EVENT_TYPE          (+) and
          c.RBS_VERSION_ID    = log.EVENT_OBJECT        (+) and
          emt.PROJECT_ID      = log.ATTRIBUTE1          (+) and
          log.WORKER_ID       is null;

      end loop;

      delete
      from   PJI_PA_PROJ_EVENTS_LOG
      where  WORKER_ID = p_worker_id and
             EVENT_TYPE = 'RBS_PRG';

    elsif (l_extraction_type = 'PARTIAL') then

      null; -- do not process any events during partial refresh

    elsif (l_extraction_type = 'RBS') then

      l_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'RBS_HEADER_ID');

      if (l_rbs_header_id = -1) then
        l_rbs_header_id := null;
      end if;

      --ensure all RBS_ASSOC and RBS_PRG events point to the latest version

      update PA_PJI_PROJ_EVENTS_LOG log
      set    log.EVENT_OBJECT =
             (
             select
               ver1.RBS_VERSION_ID
             from
               (
               select
                 ver.RBS_VERSION_ID
               from
                 PA_RBS_VERSIONS_B ver
               where
                 ver.RBS_HEADER_ID = nvl(l_rbs_header_id,
                                         ver.RBS_HEADER_ID) and
                 ver.STATUS_CODE = 'FROZEN'
               order by
                 ver.VERSION_NUMBER desc
               ) ver1
             where
               ROWNUM = 1
             )
      where  log.EVENT_TYPE in ('RBS_ASSOC', 'RBS_PRG') and
             log.EVENT_OBJECT in
             (
             select
               ver.RBS_VERSION_ID
             from
               PA_RBS_VERSIONS_B ver
             where
               ver.RBS_HEADER_ID = nvl(l_rbs_header_id,
                                       ver.RBS_HEADER_ID)
             ) and
             log.EVENT_OBJECT not in
             (
             select
               ver1.RBS_VERSION_ID
             from
               (
               select
                 ver.RBS_VERSION_ID
               from
                 PA_RBS_VERSIONS_B ver
               where
                 ver.RBS_HEADER_ID = nvl(l_rbs_header_id,
                                         ver.RBS_HEADER_ID) and
                 ver.STATUS_CODE = 'FROZEN'
               order by
                 ver.VERSION_NUMBER desc
               ) ver1
             where
               ROWNUM = 1
             );

      -- get RBS_PUSH events

      for c in rbs_push_events(p_worker_id, l_rbs_header_id) loop

        if (c.ATTRIBUTE2 is not null) then

          insert into PJI_PA_PROJ_EVENTS_LOG
          (
            WORKER_ID,
            LOG_ROWID,
            EVENT_TYPE,
            EVENT_ID,
            EVENT_OBJECT,
            OPERATION_TYPE,
            STATUS,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ATTRIBUTE16,
            ATTRIBUTE17,
            ATTRIBUTE18,
            ATTRIBUTE19,
            ATTRIBUTE20
          )
          values
          (
            p_worker_id,
            c.LOG_ROWID,
            c.EVENT_TYPE,
            c.EVENT_ID,
            c.EVENT_OBJECT,
            c.OPERATION_TYPE,
            c.STATUS,
            c.ATTRIBUTE_CATEGORY,
            c.ATTRIBUTE1,
            c.ATTRIBUTE2,
            c.ATTRIBUTE3,
            c.ATTRIBUTE4,
            c.ATTRIBUTE5,
            c.ATTRIBUTE6,
            c.ATTRIBUTE7,
            c.ATTRIBUTE8,
            c.ATTRIBUTE9,
            c.ATTRIBUTE10,
            c.ATTRIBUTE11,
            c.ATTRIBUTE12,
            c.ATTRIBUTE13,
            c.ATTRIBUTE14,
            c.ATTRIBUTE15,
            c.ATTRIBUTE16,
            c.ATTRIBUTE17,
            c.ATTRIBUTE18,
            c.ATTRIBUTE19,
            c.ATTRIBUTE20
          );

        end if;

        delete
        from   PA_PJI_PROJ_EVENTS_LOG
        where  ROWID = c.LOG_ROWID;

      end loop;

      -- get RBS_DELETE events

      for c in rbs_delete_events(p_worker_id, l_rbs_header_id) loop

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          LOG_ROWID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE16,
          ATTRIBUTE17,
          ATTRIBUTE18,
          ATTRIBUTE19,
          ATTRIBUTE20
        )
        values
        (
          p_worker_id,
          c.LOG_ROWID,
          c.EVENT_TYPE,
          c.EVENT_ID,
          c.EVENT_OBJECT,
          c.OPERATION_TYPE,
          c.STATUS,
          c.ATTRIBUTE_CATEGORY,
          c.ATTRIBUTE1,
          c.ATTRIBUTE2,
          c.ATTRIBUTE3,
          c.ATTRIBUTE4,
          c.ATTRIBUTE5,
          c.ATTRIBUTE6,
          c.ATTRIBUTE7,
          c.ATTRIBUTE8,
          c.ATTRIBUTE9,
          c.ATTRIBUTE10,
          c.ATTRIBUTE11,
          c.ATTRIBUTE12,
          c.ATTRIBUTE13,
          c.ATTRIBUTE14,
          c.ATTRIBUTE15,
          c.ATTRIBUTE16,
          c.ATTRIBUTE17,
          c.ATTRIBUTE18,
          c.ATTRIBUTE19,
          c.ATTRIBUTE20
        );

        delete
        from   PA_PJI_PROJ_EVENTS_LOG
        where  ROWID = c.LOG_ROWID;

      end loop;

      -- normalize chains of 'RBS_PUSH' events

      for c in (select   EVENT_ID
                from     PJI_PA_PROJ_EVENTS_LOG
                where    WORKER_ID = p_worker_id and
                         EVENT_TYPE = 'RBS_PUSH'
                order by EVENT_ID) loop

        select ATTRIBUTE18
        into   l_chain_flag
        from   PJI_PA_PROJ_EVENTS_LOG
        where  WORKER_ID = p_worker_id and
               EVENT_TYPE = 'RBS_PUSH' and
               EVENT_ID = c.EVENT_ID;

        if (l_chain_flag is null) then

          update PJI_PA_PROJ_EVENTS_LOG log1
          set    log1.ATTRIBUTE18 = 'PJI$LIST',
                 log1.ATTRIBUTE17 = c.EVENT_ID
          where  log1.WORKER_ID   = p_worker_id and
                 log1.EVENT_TYPE  = 'RBS_PUSH' and
                 log1.EVENT_ID    in
                   (select
                      log1.EVENT_ID
                    from
                      PJI_PA_PROJ_EVENTS_LOG log1
                    start with
                      log1.WORKER_ID   = p_worker_id and
                      log1.EVENT_TYPE  = 'RBS_PUSH'  and
                      log1.EVENT_ID    = c.EVENT_ID  and
                      log1.ATTRIBUTE18 is null
                    connect by
                      log1.ATTRIBUTE2 = prior log1.EVENT_OBJECT);

          select log1.EVENT_OBJECT
          into   l_last_rbs_link
          from   PJI_PA_PROJ_EVENTS_LOG log1
          where  log1.WORKER_ID   = p_worker_id and
                 log1.EVENT_TYPE  = 'RBS_PUSH'  and
                 log1.ATTRIBUTE17 = c.EVENT_ID  and
                 log1.ATTRIBUTE18 = 'PJI$LIST'  and
                 log1.EVENT_ID    in (select max(log2.EVENT_ID)
                                      from   PJI_PA_PROJ_EVENTS_LOG log2
                                      where  log2.WORKER_ID = p_worker_id  and
                                             log2.EVENT_TYPE = 'RBS_PUSH'  and
                                             log2.ATTRIBUTE17 = c.EVENT_ID and
                                             log2.ATTRIBUTE18 = 'PJI$LIST');

          update PJI_PA_PROJ_EVENTS_LOG
          set    EVENT_OBJECT = l_last_rbs_link
          where  WORKER_ID    = p_worker_id and
                 EVENT_TYPE   = 'RBS_PUSH'  and
                 ATTRIBUTE17  = c.EVENT_ID  and
                 ATTRIBUTE18  = 'PJI$LIST';

        end if;

      end loop;

      -- 'RBS_DELETE' event overrides 'RBS_PUSH' event

      insert into PJI_PA_PROJ_EVENTS_LOG
      (
        WORKER_ID,
        LOG_ROWID,
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20
      )
      select
        distinct
        log_del.WORKER_ID,
        log_del.LOG_ROWID,
        log_del.EVENT_TYPE,
        log_del.EVENT_ID,
        log_push.ATTRIBUTE2              EVENT_OBJECT,
        log_del.OPERATION_TYPE,
        log_del.STATUS,
        log_del.ATTRIBUTE_CATEGORY,
        log_del.ATTRIBUTE1,
        log_del.ATTRIBUTE2,
        log_del.ATTRIBUTE3,
        log_del.ATTRIBUTE4,
        log_del.ATTRIBUTE5,
        log_del.ATTRIBUTE6,
        log_del.ATTRIBUTE7,
        log_del.ATTRIBUTE8,
        log_del.ATTRIBUTE9,
        log_del.ATTRIBUTE10,
        log_del.ATTRIBUTE11,
        log_del.ATTRIBUTE12,
        log_del.ATTRIBUTE13,
        log_del.ATTRIBUTE14,
        log_del.ATTRIBUTE15,
        log_del.ATTRIBUTE16,
        log_del.ATTRIBUTE17,
        log_del.ATTRIBUTE18,
        log_del.ATTRIBUTE19,
        log_del.ATTRIBUTE20
      from
        PJI_PA_PROJ_EVENTS_LOG log_del,
        PJI_PA_PROJ_EVENTS_LOG log_push
      where
        log_del.WORKER_ID     = p_worker_id  and
        log_del.EVENT_TYPE    = 'RBS_DELETE' and
        log_push.WORKER_ID    = p_worker_id  and
        log_push.EVENT_TYPE   = 'RBS_PUSH'   and
        log_push.EVENT_OBJECT = log_del.EVENT_OBJECT;

      delete
      from   PJI_PA_PROJ_EVENTS_LOG log1
      where  log1.WORKER_ID    =  p_worker_id and
             log1.EVENT_TYPE   =  'RBS_PUSH' and
             log1.EVENT_OBJECT in (select log2.EVENT_OBJECT
                                   from   PJI_PA_PROJ_EVENTS_LOG log2
                                   where  log2.WORKER_ID = p_worker_id and
                                          log2.EVENT_TYPE = 'RBS_DELETE');

      -- add PROJECT_ID to RBS_PUSH events
/* Midified this insert for bug#6450097 */
      insert into PJI_PA_PROJ_EVENTS_LOG
      (
        WORKER_ID,
        LOG_ROWID,
        EVENT_TYPE,
        EVENT_ID,
        EVENT_OBJECT,
        OPERATION_TYPE,
        STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ATTRIBUTE16,
        ATTRIBUTE17,
        ATTRIBUTE18,
        ATTRIBUTE19,
        ATTRIBUTE20
      )
      select
        distinct
        log.WORKER_ID,
        log.LOG_ROWID,
        log.EVENT_TYPE,
        log.EVENT_ID,
        log.EVENT_OBJECT,
        log.OPERATION_TYPE,
        log.STATUS,
        log.ATTRIBUTE_CATEGORY,
        log.ATTRIBUTE1,
        log.ATTRIBUTE2,
        log.ATTRIBUTE3,
        log.ATTRIBUTE4,
        log.ATTRIBUTE5,
        log.ATTRIBUTE6,
        log.ATTRIBUTE7,
        log.ATTRIBUTE8,
        log.ATTRIBUTE9,
        log.ATTRIBUTE10,
        log.ATTRIBUTE11,
        log.ATTRIBUTE12,
        log.ATTRIBUTE13,
        log.ATTRIBUTE14,
        log.ATTRIBUTE15,
        'Y'                              ATTRIBUTE16,
        log.ATTRIBUTE17,
        log.ATTRIBUTE18,
        rbs_prj.PROJECT_ID               ATTRIBUTE19,
        log.ATTRIBUTE20
      from
        PJI_PA_PROJ_EVENTS_LOG log,
        PA_RBS_PRJ_ASSIGNMENTS rbs_prj,
	PA_RBS_VERSIONS_B rbs
      where
        log.WORKER_ID           = p_worker_id and
        log.EVENT_TYPE          = 'RBS_PUSH'  and
        rbs.RBS_VERSION_ID  = log.ATTRIBUTE2 and
	rbs.rbs_header_id = rbs_prj.rbs_header_id;

      delete
      from   PJI_PA_PROJ_EVENTS_LOG
      where  WORKER_ID   = p_worker_id and
             EVENT_TYPE  = 'RBS_PUSH' and
             ATTRIBUTE16 = 'N';

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_EVENTS_SNAPSHOT(p_worker_id);');

    commit;

  end CREATE_EVENTS_SNAPSHOT;


  -- -----------------------------------------------------
  -- procedure PROCESS_RBS_CHANGES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure PROCESS_RBS_CHANGES (p_worker_id in number) is

    cursor rbs_events (p_worker_id in number) is
    select
      distinct
      ATTRIBUTE20  RBS_HEADER_ID,
      ATTRIBUTE2   OLD_RBS_VERSION_ID,
      EVENT_OBJECT NEW_RBS_VERSION_ID
    from
      PJI_PA_PROJ_EVENTS_LOG
    where
      WORKER_ID = p_worker_id and
      EVENT_TYPE = 'RBS_PUSH';

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_RBS_CHANGES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'RBS') then

      for c in rbs_events(p_worker_id) loop

        PA_RBS_UTILS.PROCESS_RBS_CHANGES(c.RBS_HEADER_ID,
                                         c.NEW_RBS_VERSION_ID,
                                         c.OLD_RBS_VERSION_ID,
                                         l_return_status,
                                         l_msg_count,
                                         l_msg_data);

      end loop;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_RBS_CHANGES(p_worker_id);');

    commit;

  end PROCESS_RBS_CHANGES;


  -- -----------------------------------------------------
  -- procedure CREATE_MAPPING_RULES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure CREATE_MAPPING_RULES (p_worker_id in number) is

    cursor required_rbs (p_worker_id in number) is
    select
      distinct asg.RBS_VERSION_ID  -- bug 6892644
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_RBS_PRJ_ASSIGNMENTS asg
    where
      map.WORKER_ID            = p_worker_id    and
      asg.PROJECT_ID           = map.PROJECT_ID and
      asg.REPORTING_USAGE_FLAG = 'Y';

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_MAPPING_RULES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    for c in required_rbs(p_worker_id) loop

      begin
      PA_RBS_MAPPING.CREATE_MAPPING_RULES(c.RBS_VERSION_ID,
                                          l_return_status,
                                          l_msg_count,
                                          l_msg_data);
      exception when others then
        PJI_UTILS.WRITE2LOG('CREATE_MAPPING_RULES:' ||
                            c.RBS_VERSION_ID || ' : ' || SQLERRM);
      end;

    end loop;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_MAPPING_RULES(p_worker_id);');

    commit;

  end CREATE_MAPPING_RULES;


  -- -----------------------------------------------------
  -- procedure MAP_RBS_HEADERS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure MAP_RBS_HEADERS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.MAP_RBS_HEADERS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    begin
    PA_RBS_MAPPING.MAP_RBS_ACTUALS(p_worker_id,
                                   l_return_status,
                                   l_msg_count,
                                   l_msg_data);
    exception when others then
      PJI_UTILS.WRITE2LOG('MAP_RBS_HEADERS:' || SQLERRM);
    end;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.MAP_RBS_HEADERS(p_worker_id);');

    commit;

  end MAP_RBS_HEADERS;


  -- -----------------------------------------------------
  -- procedure UPDATE_XBS_DENORM_FULL
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure UPDATE_XBS_DENORM_FULL (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

    l_count             number;

  begin

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM_FULL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_count := 0;

    if (l_extraction_type = 'FULL') then

      insert into PJI_XBS_DENORM den_i
      (
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        pa.STRUCT_TYPE,
        pa.PRG_GROUP,
        pa.STRUCT_VERSION_ID,
        pa.SUP_PROJECT_ID,
        pa.SUP_ID,
        pa.SUP_EMT_ID,
        pa.SUBRO_ID,
        pa.SUB_ID,
        pa.SUB_EMT_ID,
        pa.SUP_LEVEL,
        pa.SUB_LEVEL,
        pa.SUB_ROLLUP_ID,
        pa.SUB_LEAF_FLAG,
        pa.RELATIONSHIP_TYPE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PA_XBS_DENORM pa
      where
        map.WORKER_ID = p_worker_id and
        pa.SUP_PROJECT_ID = map.PROJECT_ID and
        not exists (select /*+ index(pji, PJI_XBS_DENORM_N3) */
                           1
                    from   PJI_XBS_DENORM pji
                    where  pji.STRUCT_TYPE    = 'PRG' and
                           pji.SUB_EMT_ID     = pji.SUB_ROLLUP_ID and
                           pji.SUP_PROJECT_ID = pa.SUP_PROJECT_ID);

        l_count := l_count + sql%rowcount;

    elsif (l_extraction_type = 'INCREMENTAL') then

      insert into PJI_XBS_DENORM den_i
      (
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ ordered index(pa PA_XBS_DENORM_N3) use_hash(PA) */                  /* Modified for Bug 7669026 */
        pa.STRUCT_TYPE,
        pa.PRG_GROUP,
        pa.STRUCT_VERSION_ID,
        pa.SUP_PROJECT_ID,
        pa.SUP_ID,
        pa.SUP_EMT_ID,
        pa.SUBRO_ID,
        pa.SUB_ID,
        pa.SUB_EMT_ID,
        pa.SUP_LEVEL,
        pa.SUB_LEVEL,
        pa.SUB_ROLLUP_ID,
        pa.SUB_LEAF_FLAG,
        pa.RELATIONSHIP_TYPE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PA_XBS_DENORM pa
      where
        map.WORKER_ID     = p_worker_id      and
        pa.SUP_PROJECT_ID = map.PROJECT_ID   and
        pa.STRUCT_TYPE    = 'PRG'            and
        pa.SUB_EMT_ID     = pa.SUB_ROLLUP_ID and
        not exists (select /*+ index(pji, PJI_XBS_DENORM_N3) use_hash(PJI) */                    /* Modified for Bug 7669026 */
                           1
                    from   PJI_XBS_DENORM pji
                    where  pji.STRUCT_TYPE    = 'PRG' and
                           pji.SUB_EMT_ID     = pji.SUB_ROLLUP_ID and
                           pji.SUP_PROJECT_ID = pa.SUP_PROJECT_ID);

    end if;

    if (l_count > 0) then

      delete
      from   PJI_REP_XBS_DENORM;
      -- where  PROJECT_ID in (select map.PROJECT_ID
      --                       from   PJI_PJP_PROJ_BATCH_MAP map
      --                       where  map.WORKER_ID = p_worker_id);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM_FULL(p_worker_id);');

    commit;

  end UPDATE_XBS_DENORM_FULL;


  -- -----------------------------------------------------
  -- procedure LOCK_HEADERS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure LOCK_HEADERS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_lock_mode       varchar2(255);
    l_return_status   varchar2(255);
    l_msg_code        varchar2(255);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.LOCK_HEADERS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- PJI_FM_XBS_ACCUM_MAINT.WBS_LOCK_PVT(p_online_flag   => 'N',
    --                                     x_lock_mode     => l_lock_mode,
    --                                     x_return_status => l_return_status);

    -- SELECT DECODE(l_extraction_type, 'PARTIAL', 'PLANTYPE', l_extraction_type)
    -- INTO   l_extraction_type
    -- FROM   DUAL ;

    Pji_Fm_Plan_Maint_Pvt.OBTAIN_RELEASE_LOCKS (
      p_context        => l_extraction_type
    , p_lock_mode      => 'P'
    , x_return_status  => l_return_status
    , x_msg_code       => l_msg_code
    );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.LOCK_HEADERS(p_worker_id);');

    commit;

  end LOCK_HEADERS;


  -- -----------------------------------------------------
  -- procedure UPDATE_PROGRAM_WBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure UPDATE_PROGRAM_WBS (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_WBS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      insert into PJI_PJP_WBS_HEADER
      (
        PROJECT_ID,
        PLAN_VERSION_ID,
        WBS_VERSION_ID,
        WP_FLAG,
        CB_FLAG,
        CO_FLAG,
        LOCK_FLAG,
        PLAN_TYPE_ID,
        MIN_TXN_DATE,
        MAX_TXN_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PLAN_TYPE_CODE
      )
      select
        PROJECT_ID,
        -1,
        PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(PROJECT_ID),
        'N',
        null,
        null,
        'P',
        null,
        to_date('3000/01/01', 'YYYY/MM/DD') MIN_TXN_DATE,
        to_date('0001/01/01', 'YYYY/MM/DD') MAX_TXN_DATE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login,
        'A'
      from
        (
        select
          distinct
          prj_emt.PROJECT_ID
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PA_PROJ_ELEMENTS prj_emt
        where
          map.WORKER_ID       = p_worker_id and
          prj_emt.OBJECT_TYPE = 'PA_STRUCTURES' and
          prj_emt.PROJECT_ID  = map.PROJECT_ID
        )
      order by
        PROJECT_ID;

      while (SQL%ROWCOUNT > 0) loop

        update PJI_PJP_WBS_HEADER wbs_hdr
        set    wbs_hdr.WBS_VERSION_ID =
               (select /*+ index(log PA_PJI_PROJ_EVENTS_LOG_N1) */
                       distinct log.ATTRIBUTE2
                from   PA_PJI_PROJ_EVENTS_LOG log
                where  log.EVENT_TYPE = 'WBS_PUBLISH' and
                       log.EVENT_OBJECT = wbs_hdr.WBS_VERSION_ID),
               wbs_hdr.LAST_UPDATE_DATE  = l_last_update_date,
               wbs_hdr.LAST_UPDATED_BY   = l_last_updated_by,
               wbs_hdr.LAST_UPDATE_LOGIN = l_last_update_login
        where  wbs_hdr.PROJECT_ID in
               (select map.PROJECT_ID
                from   PJI_PJP_PROJ_BATCH_MAP map
                where  map.WORKER_ID = p_worker_id) and
               wbs_hdr.PLAN_VERSION_ID = -1 and
               wbs_hdr.WBS_VERSION_ID in
               (select log.EVENT_OBJECT
                from   PA_PJI_PROJ_EVENTS_LOG log
                where  log.EVENT_TYPE = 'WBS_PUBLISH');

      end loop;

    else

      update PJI_PJP_WBS_HEADER
      set    WBS_VERSION_ID =
                         PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID
                         (PROJECT_ID),
             LOCK_FLAG         = 'P',
             LAST_UPDATE_DATE  = l_last_update_date,
             LAST_UPDATED_BY   = l_last_updated_by,
             LAST_UPDATE_LOGIN = l_last_update_login
      where  PLAN_VERSION_ID = -1 and
             PROJECT_ID in (select EVENT_OBJECT
                            from   PJI_PA_PROJ_EVENTS_LOG
                            where  WORKER_ID = p_worker_id and
                                   EVENT_TYPE in ('WBS_CHANGE',
                                                  'WBS_PUBLISH'));

      insert into PJI_PJP_WBS_HEADER
      (
        PROJECT_ID,
        PLAN_VERSION_ID,
        WBS_VERSION_ID,
        WP_FLAG,
        CB_FLAG,
        CO_FLAG,
        LOCK_FLAG,
        PLAN_TYPE_ID,
        MIN_TXN_DATE,
        MAX_TXN_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PLAN_TYPE_CODE
      )
      select
        PROJECT_ID,
        -1,
        PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(PROJECT_ID),
        'N',
        null,
        null,
        'P',
        null,
        to_date('3000/01/01', 'YYYY/MM/DD') MIN_TXN_DATE,
        to_date('0001/01/01', 'YYYY/MM/DD') MAX_TXN_DATE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login,
        'A'
      from
        (
        select
          distinct
          prj_emt.PROJECT_ID
        from
          PJI_PA_PROJ_EVENTS_LOG log,
          PA_PROJ_ELEMENTS       prj_emt,
          PJI_PJP_WBS_HEADER     hdr
        where
          log.WORKER_ID       =  p_worker_id                   and
          log.EVENT_TYPE      in ('WBS_CHANGE', 'WBS_PUBLISH') and
          prj_emt.OBJECT_TYPE =  'PA_STRUCTURES'               and
          prj_emt.PROJECT_ID  =  log.EVENT_OBJECT              and
          -1                  =  hdr.PLAN_VERSION_ID (+)       and
          prj_emt.PROJECT_ID  =  hdr.PROJECT_ID      (+)       and
          hdr.PROJECT_ID      is null
        )
      order by
        PROJECT_ID;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_WBS(p_worker_id);');

    commit;

  end UPDATE_PROGRAM_WBS;


  -- -----------------------------------------------------
  -- procedure PURGE_EVENT_DATA
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure PURGE_EVENT_DATA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PURGE_EVENT_DATA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL') then

      delete
      from   PJI_FP_XBS_ACCUM_F
      where  (RBS_AGGR_LEVEL,
              WBS_ROLLUP_FLAG,
              PRG_ROLLUP_FLAG) in (('L', 'Y', 'N'),
                                   ('R', 'N', 'N'),
                                   ('R', 'Y', 'N')) and
             (PROJECT_ID,
              PLAN_VERSION_ID,
              decode(PLAN_VERSION_ID,
                     -3, PLAN_TYPE_ID,
                     -4, PLAN_TYPE_ID,
                         -1)) in (select
                                    log.ATTRIBUTE1,
                                    decode(log.EVENT_TYPE,
                                           'WBS_CHANGE',    log.ATTRIBUTE3,
                                           'WBS_PUBLISH',   log.ATTRIBUTE3,
                                           'PLAN_BASELINE', -3,
                                           'PLAN_ORIGINAL', -4),
                                    decode(log.EVENT_TYPE,
                                           'WBS_CHANGE',    -1,
                                           'WBS_PUBLISH',   -1,
                                           'PLAN_BASELINE', log.ATTRIBUTE2,
                                           'PLAN_ORIGINAL', log.ATTRIBUTE2)
                                   from
                                     PJI_PA_PROJ_EVENTS_LOG log
                                   where
                                     log.WORKER_ID = p_worker_id and
                                     log.EVENT_TYPE in ('WBS_CHANGE',
                                                        'WBS_PUBLISH',
                                                        'PLAN_BASELINE',
                                                        'PLAN_ORIGINAL'));

    elsif (l_extraction_type = 'RBS') then

      delete
      from   PJI_PJP_RBS_HEADER
      where  RBS_VERSION_ID in (select distinct
                                       log.EVENT_OBJECT
                                from   PJI_PA_PROJ_EVENTS_LOG log
                                where  log.WORKER_ID = p_worker_id and
                                       log.EVENT_TYPE = 'RBS_DELETE');

      delete
      from   PJI_ROLLUP_LEVEL_STATUS
      where  RBS_VERSION_ID in (select distinct
                                       decode(log.EVENT_TYPE,
                                              'RBS_PUSH', log.ATTRIBUTE2,
                                              'RBS_DELETE', log.EVENT_OBJECT)
                                from   PJI_PA_PROJ_EVENTS_LOG log
                                where  log.WORKER_ID = p_worker_id and
                                       log.EVENT_TYPE in ('RBS_PUSH',
                                                          'RBS_DELETE'));

      delete
      from   PJI_FP_XBS_ACCUM_F
      where  RBS_AGGR_LEVEL in ('L', 'R') and
             (PROJECT_ID,
              PLAN_VERSION_ID,
              RBS_VERSION_ID) in (select distinct
                                         rbs_hdr.PROJECT_ID,
                                         rbs_hdr.PLAN_VERSION_ID,
                                         rbs_hdr.RBS_VERSION_ID
                                  from   PJI_PA_PROJ_EVENTS_LOG log,
                                         PJI_PJP_RBS_HEADER rbs_hdr
                                  where  log.WORKER_ID = p_worker_id and
                                         log.EVENT_TYPE = 'RBS_PUSH' and
                                         rbs_hdr.RBS_VERSION_ID =
                                           log.ATTRIBUTE2
                                  union
                                  select distinct
                                         rbs_hdr.PROJECT_ID,
                                         rbs_hdr.PLAN_VERSION_ID,
                                         rbs_hdr.RBS_VERSION_ID
                                  from   PJI_PA_PROJ_EVENTS_LOG log,
                                         PJI_PJP_RBS_HEADER rbs_hdr
                                  where  log.WORKER_ID = p_worker_id and
                                         log.EVENT_TYPE = 'RBS_DELETE' and
                                         rbs_hdr.RBS_VERSION_ID =
                                           log.EVENT_OBJECT);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PURGE_EVENT_DATA(p_worker_id);');

    commit;

  end PURGE_EVENT_DATA;


  -- -----------------------------------------------------
  -- procedure UPDATE_PROGRAM_RBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure UPDATE_PROGRAM_RBS (p_worker_id in number) is

    cursor rbs_prg_full (p_worker_id in number) is
    select
      distinct
      asg.RBS_HEADER_ID,
      asg.RBS_VERSION_ID,
      den2.SUP_PROJECT_ID             PROJECT_ID,
      decode(den1.SUB_EMT_ID,
             den1.SUB_ROLLUP_ID, 'Y',
                                 'N') PROG_REP_USAGE_FLAG,
      'Y'                             REPORTING_USAGE_FLAG,
      'N'                             FP_USAGE_FLAG
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_RBS_PRJ_ASSIGNMENTS asg,
      PA_XBS_DENORM          den1,
      PA_XBS_DENORM          den2
    where
      map.WORKER_ID            =  p_worker_id     and
      asg.PROJECT_ID           =  map.PROJECT_ID  and
      asg.PROG_REP_USAGE_FLAG  =  'Y'             and
      asg.REPORTING_USAGE_FLAG =  'Y'             and
      den1.STRUCT_TYPE         =  'PRG'           and
      den1.STRUCT_VERSION_ID   is null            and
      den1.SUP_PROJECT_ID      =  asg.PROJECT_ID  and
      (den1.SUB_EMT_ID = den1.SUB_ROLLUP_ID or
       den1.SUP_EMT_ID <> den1.SUB_EMT_ID)        and
      den2.STRUCT_TYPE         =  'PRG'           and
      den2.STRUCT_VERSION_ID   is null            and
      den2.SUP_EMT_ID          =  den2.SUB_EMT_ID and
      den2.SUP_EMT_ID          =  den1.SUB_EMT_ID
    order by
      asg.RBS_HEADER_ID,
      asg.RBS_VERSION_ID;

    cursor rbs_prg (p_worker_id in number) is
    select
      distinct
      log.ATTRIBUTE2   RBS_HEADER_ID,
      log.EVENT_OBJECT RBS_VERSION_ID,
      log.ATTRIBUTE1   PROJECT_ID,
      log.ATTRIBUTE17  PROGRAM_ID,
      log.ATTRIBUTE18  PROG_REP_USAGE_FLAG,
      'Y'              REPORTING_USAGE_FLAG,
      'N'              FP_USAGE_FLAG,
      log.ATTRIBUTE19  UPDATE_HEADER_ONLY_FLAG
    from
      PJI_PA_PROJ_EVENTS_LOG log
    where
      log.WORKER_ID   = p_worker_id               and
      log.EVENT_TYPE  = 'RBS_ASSOC'               and
      log.ATTRIBUTE20 = 'CONVERTED_RBS_PRG_EVENT'
    order by
      log.ATTRIBUTE17,
      log.ATTRIBUTE2,
      log.EVENT_OBJECT;

    cursor rbs_assoc (p_worker_id in number) is
    select
      distinct
      log.ATTRIBUTE2   RBS_HEADER_ID,
      log.EVENT_OBJECT RBS_VERSION_ID,
      log.ATTRIBUTE1   PROJECT_ID,
      'N'              PROG_REP_USAGE_FLAG,
      'Y'              REPORTING_USAGE_FLAG,
      'N'              FP_USAGE_FLAG
    from
      PJI_PA_PROJ_EVENTS_LOG log
    where
      log.WORKER_ID   = p_worker_id and
      log.EVENT_TYPE  = 'RBS_ASSOC' and
      log.ATTRIBUTE20 is null
    order by
      log.ATTRIBUTE2,
      log.EVENT_OBJECT;

    cursor rbs_push (p_worker_id in number) is
    select
      distinct
      log.ATTRIBUTE20  RBS_HEADER_ID,
      log.EVENT_OBJECT RBS_VERSION_ID,
      log.ATTRIBUTE2   OLD_RBS_VERSION_ID,
      log.ATTRIBUTE19  PROJECT_ID,
      'N'              PROG_REP_USAGE_FLAG,
      'Y'              REPORTING_USAGE_FLAG,
      'N'              FP_USAGE_FLAG
    from
      PJI_PA_PROJ_EVENTS_LOG log
    where
      log.WORKER_ID = p_worker_id and
      log.EVENT_TYPE = 'RBS_PUSH'
    order by
      log.ATTRIBUTE20,
      log.EVENT_OBJECT;

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_program_id        number;
    l_rbs_header_id     number;
    l_rbs_version_id    number;
    l_prj_index         number;
    l_project_id_tbl    system.pa_num_tbl_type;
    l_count             number;
    l_rowid             rowid;
    l_return_status     varchar2(255);
    l_error_code        varchar2(255);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_RBS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (l_extraction_type = 'FULL') then

      l_rbs_header_id := -1;
      l_rbs_version_id := -1;
      l_prj_index := 1;
      l_project_id_tbl := system.pa_num_tbl_type();
      l_project_id_tbl.delete;

      for c in rbs_prg_full(p_worker_id) loop

        l_project_id_tbl.extend(1);
        l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
        l_prj_index := l_prj_index + 1;

        if (l_rbs_header_id = -1 and l_rbs_version_id = -1) then

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;

        elsif (c.RBS_HEADER_ID <> l_rbs_header_id or
               c.RBS_VERSION_ID <> l_rbs_version_id) then

          PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                    l_rbs_version_id,
                                                    l_project_id_tbl,
                                                    l_return_status);

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;
          l_prj_index := 1;
          l_project_id_tbl.delete;

        end if;

        insert into PJI_PJP_RBS_HEADER
        (
          PROJECT_ID,
          PLAN_VERSION_ID,
          RBS_VERSION_ID,
          REPORTING_USAGE_FLAG,
          PROG_REP_USAGE_FLAG,
          PLAN_USAGE_FLAG,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          PLAN_TYPE_CODE
        )
        select
          c.PROJECT_ID,
          -1,
          c.RBS_VERSION_ID,
          c.REPORTING_USAGE_FLAG,
          c.PROG_REP_USAGE_FLAG,
          c.FP_USAGE_FLAG,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login,
          'A'
        from
          dual
        where
          not exists
          (
          select
            1
          from
            PJI_PJP_RBS_HEADER rbs_hdr
          where
            rbs_hdr.PROJECT_ID      = c.PROJECT_ID and
            rbs_hdr.PLAN_VERSION_ID = -1 and
            rbs_hdr.RBS_VERSION_ID  = c.RBS_VERSION_ID
          );

      end loop;

      if (l_rbs_header_id <> -1 and l_rbs_version_id <> -1) then

        PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                  l_rbs_version_id,
                                                  l_project_id_tbl,
                                                  l_return_status);

      end if;

      insert into PJI_PJP_RBS_HEADER
      (
        PROJECT_ID,
        PLAN_VERSION_ID,
        RBS_VERSION_ID,
        REPORTING_USAGE_FLAG,
        PROG_REP_USAGE_FLAG,
        PLAN_USAGE_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PLAN_TYPE_CODE
      )
      select
        distinct
        asg.PROJECT_ID,
        -1,
        asg.RBS_VERSION_ID,
        asg.REPORTING_USAGE_FLAG,
        asg.PROG_REP_USAGE_FLAG,
        asg.FP_USAGE_FLAG,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login,
        'A'
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PA_RBS_PRJ_ASSIGNMENTS asg,
        PJI_PJP_RBS_HEADER     rbs_hdr
      where
        map.WORKER_ID            = p_worker_id                 and
        asg.PROJECT_ID           = map.PROJECT_ID              and
        asg.REPORTING_USAGE_FLAG =  'Y'                        and
        asg.PROJECT_ID           = rbs_hdr.PROJECT_ID      (+) and
        -1                       = rbs_hdr.PLAN_VERSION_ID (+) and
        asg.RBS_VERSION_ID       = rbs_hdr.RBS_VERSION_ID  (+) and
        rbs_hdr.PROJECT_ID is null;

      insert into PJI_PJP_RBS_HEADER
      (
        PROJECT_ID,
        PLAN_VERSION_ID,
        RBS_VERSION_ID,
        REPORTING_USAGE_FLAG,
        PROG_REP_USAGE_FLAG,
        PLAN_USAGE_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PLAN_TYPE_CODE
      )
      select
        map.PROJECT_ID,
        -1,
        -1,
        'N',
        'N',
        'N',
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login,
        'A'
      from
        PJI_PJP_PROJ_BATCH_MAP map
      where
        map.WORKER_ID = p_worker_id;

    elsif (l_extraction_type = 'INCREMENTAL' or
           l_extraction_type = 'PARTIAL') then

      -- RBS_PRG

      l_program_id     := -1;
      l_rbs_header_id  := -1;
      l_rbs_version_id := -1;
      l_prj_index      :=  1;
      l_project_id_tbl :=  system.pa_num_tbl_type();
      l_project_id_tbl.delete;

      for c in rbs_prg(p_worker_id) loop

        if (c.UPDATE_HEADER_ONLY_FLAG is null) then

          l_project_id_tbl.extend(1);
          l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
          l_prj_index := l_prj_index + 1;

          if (l_rbs_header_id = -1 and l_rbs_version_id = -1) then

            l_program_id     := c.PROGRAM_ID;
            l_rbs_header_id  := c.RBS_HEADER_ID;
            l_rbs_version_id := c.RBS_VERSION_ID;

          elsif (c.PROGRAM_ID     <> l_program_id or
                 c.RBS_HEADER_ID  <> l_rbs_header_id or
                 c.RBS_VERSION_ID <> l_rbs_version_id) then

            PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                      l_rbs_version_id,
                                                      l_project_id_tbl,
                                                      l_return_status);

            l_program_id     := c.PROGRAM_ID;
            l_rbs_header_id  := c.RBS_HEADER_ID;
            l_rbs_version_id := c.RBS_VERSION_ID;
            l_prj_index      := 1;
            l_project_id_tbl.delete;

          end if;

        end if;

        update PJI_PJP_RBS_HEADER
        set    RBS_VERSION_ID       = c.RBS_VERSION_ID,
               REPORTING_USAGE_FLAG = c.REPORTING_USAGE_FLAG,
               PROG_REP_USAGE_FLAG  = c.PROG_REP_USAGE_FLAG,
               LAST_UPDATE_DATE     = l_last_update_date,
               LAST_UPDATED_BY      = l_last_updated_by,
               LAST_UPDATE_LOGIN    = l_last_update_login
        where  PROJECT_ID                = c.PROJECT_ID     and
               RBS_VERSION_ID            = c.RBS_VERSION_ID and
               PLAN_VERSION_ID           = -1               and
               c.UPDATE_HEADER_ONLY_FLAG = 'MARK_AS_PROG_REP';

        if (sql%rowcount = 0) then

          insert into PJI_PJP_RBS_HEADER
          (
            PROJECT_ID,
            PLAN_VERSION_ID,
            RBS_VERSION_ID,
            REPORTING_USAGE_FLAG,
            PROG_REP_USAGE_FLAG,
            PLAN_USAGE_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            PLAN_TYPE_CODE
          )
          values
          (
            c.PROJECT_ID,
            -1,
            c.RBS_VERSION_ID,
            c.REPORTING_USAGE_FLAG,
            c.PROG_REP_USAGE_FLAG,
            c.FP_USAGE_FLAG,
            l_last_update_date,
            l_last_updated_by,
            l_creation_date,
            l_created_by,
            l_last_update_login,
            'A'
          );

          insert into PJI_PA_PROJ_EVENTS_LOG
          (
            WORKER_ID,
            EVENT_TYPE,
            EVENT_ID,
            EVENT_OBJECT,
            OPERATION_TYPE,
            STATUS
          )
          select
            p_worker_id,
            'PJI_RBS_CHANGE',
            PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
            c.RBS_VERSION_ID,
            'I',
            'X'
          from
            DUAL
          where
            not exists (select 1
                        from   PA_RBS_DENORM rbs
                        where  rbs.STRUCT_VERSION_ID = c.RBS_VERSION_ID);

        end if;

      end loop;

      if (l_rbs_header_id <> -1 and l_rbs_version_id <> -1) then

        PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                  l_rbs_version_id,
                                                  l_project_id_tbl,
                                                  l_return_status);

      end if;

      delete
      from   PJI_PA_PROJ_EVENTS_LOG
      where  WORKER_ID   = p_worker_id and
             EVENT_TYPE  = 'RBS_ASSOC' and
             ATTRIBUTE19 = 'MARK_AS_PROG_REP';

      -- RBS_ASSOC

      l_rbs_header_id := -1;
      l_rbs_version_id := -1;
      l_prj_index := 1;
      l_project_id_tbl := system.pa_num_tbl_type();
      l_project_id_tbl.delete;

      for c in rbs_assoc(p_worker_id) loop

        l_project_id_tbl.extend(1);
        l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
        l_prj_index := l_prj_index + 1;

        if (l_rbs_header_id = -1 and l_rbs_version_id = -1) then

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;

        elsif (c.RBS_HEADER_ID <> l_rbs_header_id or
               c.RBS_VERSION_ID <> l_rbs_version_id) then

          PA_RBS_ASGMT_PVT.ASSIGN_NEW_VERSION(l_rbs_version_id,
                                              l_project_id_tbl,
                                              l_return_status);

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;
          l_prj_index := 1;
          l_project_id_tbl.delete;

        end if;

        update PJI_PJP_RBS_HEADER
        set    RBS_VERSION_ID    = c.RBS_VERSION_ID,
               LAST_UPDATE_DATE  = l_last_update_date,
               LAST_UPDATED_BY   = l_last_updated_by,
               LAST_UPDATE_LOGIN = l_last_update_login
        where  PROJECT_ID      = c.PROJECT_ID and
               RBS_VERSION_ID  = c.RBS_VERSION_ID and
               PLAN_VERSION_ID = -1;

        if (sql%rowcount = 0) then

          insert into PJI_PJP_RBS_HEADER
          (
            PROJECT_ID,
            PLAN_VERSION_ID,
            RBS_VERSION_ID,
            REPORTING_USAGE_FLAG,
            PROG_REP_USAGE_FLAG,
            PLAN_USAGE_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            PLAN_TYPE_CODE
          )
          values
          (
            c.PROJECT_ID,
            -1,
            c.RBS_VERSION_ID,
            c.REPORTING_USAGE_FLAG,
            c.PROG_REP_USAGE_FLAG,
            c.FP_USAGE_FLAG,
            l_last_update_date,
            l_last_updated_by,
            l_creation_date,
            l_created_by,
            l_last_update_login,
            'A'
          );

          insert into PJI_PA_PROJ_EVENTS_LOG
          (
            WORKER_ID,
            EVENT_TYPE,
            EVENT_ID,
            EVENT_OBJECT,
            OPERATION_TYPE,
            STATUS
          )
          select
            p_worker_id,
            'PJI_RBS_CHANGE',
            PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
            c.RBS_VERSION_ID,
            'I',
            'X'
          from
            DUAL
          where
            not exists (select 1
                        from   PA_RBS_DENORM rbs
                        where  rbs.STRUCT_VERSION_ID = c.RBS_VERSION_ID);

        end if;

      end loop;

      if (l_rbs_header_id <> -1 and l_rbs_version_id <> -1) then

        PA_RBS_ASGMT_PVT.ASSIGN_NEW_VERSION(l_rbs_version_id,
                                            l_project_id_tbl,
                                            l_return_status);

      end if;

    elsif (l_extraction_type = 'RBS') then

      l_rbs_header_id := -1;
      l_rbs_version_id := -1;
      l_prj_index := 1;
      l_project_id_tbl := system.pa_num_tbl_type();
      l_project_id_tbl.delete;

      for c in rbs_push(p_worker_id) loop

        l_project_id_tbl.extend(1);
        l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
        l_prj_index := l_prj_index + 1;

        if (l_rbs_header_id = -1 and l_rbs_version_id = -1) then

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;

        elsif (c.RBS_HEADER_ID <> l_rbs_header_id or
               c.RBS_VERSION_ID <> l_rbs_version_id) then

          PA_RBS_ASGMT_PVT.ASSIGN_NEW_VERSION(l_rbs_version_id,
                                              l_project_id_tbl,
                                              l_return_status);

          l_rbs_header_id := c.RBS_HEADER_ID;
          l_rbs_version_id := c.RBS_VERSION_ID;
          l_prj_index := 1;
          l_project_id_tbl.delete;

        end if;

        update PJI_PJP_RBS_HEADER
        set    RBS_VERSION_ID    = c.RBS_VERSION_ID,
               LAST_UPDATE_DATE  = l_last_update_date,
               LAST_UPDATED_BY   = l_last_updated_by,
               LAST_UPDATE_LOGIN = l_last_update_login
        where  PROJECT_ID      = c.PROJECT_ID and
               RBS_VERSION_ID  = c.OLD_RBS_VERSION_ID and
               PLAN_VERSION_ID = -1;

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS
        )
        select
          p_worker_id,
          'PJI_RBS_CHANGE',
          PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
          c.RBS_VERSION_ID,
          'I',
          'X'
        from
          DUAL
        where
          not exists (select 1
                      from   PA_RBS_DENORM rbs
                      where  rbs.STRUCT_VERSION_ID = c.RBS_VERSION_ID);

      end loop;

      if (l_rbs_header_id <> -1 and l_rbs_version_id <> -1) then

        PA_RBS_ASGMT_PVT.ASSIGN_NEW_VERSION(l_rbs_version_id,
                                            l_project_id_tbl,
                                            l_return_status);

      end if;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_RBS(p_worker_id);');

    commit;

  end UPDATE_PROGRAM_RBS;


  -- -----------------------------------------------------
  -- procedure SET_ONLINE_CONTEXT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called during online processing.
  --
  -- -----------------------------------------------------
  procedure SET_ONLINE_CONTEXT (p_event_id              in number,
                                p_project_id            in number,
                                p_plan_type_id          in number,
                                p_old_baselined_version in number,
                                p_new_baselined_version in number,
                                p_old_original_version  in number,
                                p_new_original_version  in number,
                                p_old_struct_version    in number,
                                p_new_struct_version    in number,
                                p_rbs_version in number default null) is

  begin

    g_event_id              := p_event_id;
    g_project_id            := p_project_id;
    g_plan_type_id          := p_plan_type_id;
    g_old_baselined_version := p_old_baselined_version;
    g_new_baselined_version := p_new_baselined_version;
    g_old_original_version  := p_old_original_version;
    g_new_original_version  := p_new_original_version;
    g_old_struct_version    := p_old_struct_version;
    g_new_struct_version    := p_new_struct_version;
    g_rbs_version           := p_rbs_version;

  end SET_ONLINE_CONTEXT;


  -- -----------------------------------------------------
  -- procedure POPULATE_XBS_DENORM_DELTA
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure POPULATE_XBS_DENORM_DELTA (p_worker_id in number default null) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_program_id        number;
    l_rbs_header_id     number;
    l_rbs_version_id    number;
    l_prj_index         number;
    l_project_id_tbl    system.pa_num_tbl_type;
    l_count             number;
    l_rowid             rowid;
    l_return_status     varchar2(255);
    l_error_code        varchar2(255);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

  begin

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_XBS_DENORM_DELTA(p_worker_id);')) then
        return;
      end if;

      l_last_update_date  := sysdate;
      l_last_updated_by   := FND_GLOBAL.USER_ID;
      l_creation_date     := sysdate;
      l_created_by        := FND_GLOBAL.USER_ID;
      l_last_update_login := FND_GLOBAL.LOGIN_ID;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      if (l_extraction_type = 'INCREMENTAL') then

        insert into PJI_XBS_DENORM_DELTA delta_i
        (
          WORKER_ID,
          EVENT_ID,
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          SIGN
        )
        select
          p_worker_id,
          EVENT_ID,
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          decode(sum(SUP_LEVEL_NEW), 0, sum(SUP_LEVEL_OLD),
                                        sum(SUP_LEVEL_NEW)) SUP_LEVEL,
          decode(sum(SUB_LEVEL_NEW), 0, sum(SUB_LEVEL_OLD),
                                        sum(SUB_LEVEL_NEW)) SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          sum(SIGN) SIGN
        from
          (
          select
            distinct
            log.EVENT_ID,
            wbs.STRUCT_TYPE,
            -1                               PRG_GROUP,
            wbs.STRUCT_VERSION_ID,
            wbs.SUP_PROJECT_ID,
            -1                               SUP_ID,
            wbs.SUP_EMT_ID,
            -1                               SUBRO_ID,
            -1                               SUB_ID,
            wbs.SUB_EMT_ID,
            wbs.SUP_LEVEL                    SUP_LEVEL_NEW,
            wbs.SUB_LEVEL                    SUB_LEVEL_NEW,
            0                                SUP_LEVEL_OLD,
            0                                SUB_LEVEL_OLD,
            wbs.SUB_ROLLUP_ID,
            'X'                              SUB_LEAF_FLAG,
            'X'                              RELATIONSHIP_TYPE,
            +1                               SIGN
          from
            PA_XBS_DENORM wbs,
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID         =  p_worker_id                   and
            log.EVENT_TYPE        in ('WBS_CHANGE', 'WBS_PUBLISH') and
            wbs.STRUCT_TYPE       =  'WBS'                         and
            wbs.SUP_PROJECT_ID    =  log.ATTRIBUTE1                and
            wbs.STRUCT_VERSION_ID =  log.EVENT_OBJECT
          union all
          select
            distinct
            log.EVENT_ID,
            wbs.STRUCT_TYPE,
            -1                               PRG_GROUP,
            wbs.STRUCT_VERSION_ID,
            wbs.SUP_PROJECT_ID,
            -1                               SUP_ID,
            wbs.SUP_EMT_ID,
            -1                               SUBRO_ID,
            -1                               SUB_ID,
            wbs.SUB_EMT_ID,
            0                                SUP_LEVEL_NEW,
            0                                SUB_LEVEL_NEW,
            wbs.SUP_LEVEL                    SUP_LEVEL_OLD,
            wbs.SUB_LEVEL                    SUB_LEVEL_OLD,
            wbs.SUB_ROLLUP_ID,
            'X'                              SUB_LEAF_FLAG,
            'X'                              RELATIONSHIP_TYPE,
            -1                               SIGN
          from
            PJI_XBS_DENORM wbs,
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID         =  p_worker_id                   and
            log.EVENT_TYPE        in ('WBS_CHANGE', 'WBS_PUBLISH') and
            wbs.STRUCT_TYPE       =  'WBS'                         and
            wbs.SUP_PROJECT_ID    =  log.ATTRIBUTE1                and
            wbs.STRUCT_VERSION_ID =  log.ATTRIBUTE2
          union all
          select
            distinct
            -1                               EVENT_ID,
            prg.STRUCT_TYPE,
            -1                               PRG_GROUP,
            -1                               STRUCT_VERSION_ID,
            prg.SUP_PROJECT_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            -1                               SUBRO_ID,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUP_LEVEL                    SUP_LEVEL_NEW,
            prg.SUB_LEVEL                    SUB_LEVEL_NEW,
            0                                SUP_LEVEL_OLD,
            0                                SUB_LEVEL_OLD,
            prg.SUB_ROLLUP_ID,
            'X'                              SUB_LEAF_FLAG,
            prg.RELATIONSHIP_TYPE,
            +1                               SIGN
          from
            PA_XBS_DENORM prg,
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID     =  p_worker_id                        and
            log.EVENT_TYPE    =  'PRG_CHANGE'                       and
            log.EVENT_OBJECT  <> -1                                 and
            prg.STRUCT_TYPE   =  'PRG'                              and
            prg.PRG_GROUP     in (log.EVENT_OBJECT, log.ATTRIBUTE1)
          union all
          select
            distinct
            -1                               EVENT_ID,
            prg.STRUCT_TYPE,
            -1                               PRG_GROUP,
            -1                               STRUCT_VERSION_ID,
            prg.SUP_PROJECT_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            -1                               SUBRO_ID,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            0                                SUP_LEVEL_NEW,
            0                                SUB_LEVEL_NEW,
            prg.SUP_LEVEL                    SUP_LEVEL_OLD,
            prg.SUB_LEVEL                    SUB_LEVEL_OLD,
            prg.SUB_ROLLUP_ID,
            'X'                              SUB_LEAF_FLAG,
            prg.RELATIONSHIP_TYPE,
            -1 SIGN
          from
            PJI_XBS_DENORM prg,
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID    =  p_worker_id  and
            log.EVENT_TYPE   =  'PRG_CHANGE' and
            log.EVENT_OBJECT <> -1           and
            prg.STRUCT_TYPE  =  'PRG'        and
            prg.PRG_GROUP    in (log.EVENT_OBJECT, log.ATTRIBUTE1)
          )
        group by
          EVENT_ID,
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE
        having
          sum(SIGN) <> 0;

        -- push down program RBSs across new links

        insert into PJI_PA_PROJ_EVENTS_LOG
        (
          WORKER_ID,
          LOG_ROWID,
          EVENT_TYPE,
          EVENT_ID,
          EVENT_OBJECT,
          OPERATION_TYPE,
          STATUS,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE16,
          ATTRIBUTE17,
          ATTRIBUTE18,
          ATTRIBUTE19,
          ATTRIBUTE20
        )
        select
          distinct
          evt.WORKER_ID,
          evt.LOG_ROWID,
          evt.EVENT_TYPE,
          evt.EVENT_ID,
          evt.EVENT_OBJECT,
          evt.OPERATION_TYPE,
          evt.STATUS,
          evt.ATTRIBUTE_CATEGORY,
          evt.ATTRIBUTE1,
          evt.ATTRIBUTE2,
          evt.ATTRIBUTE3,
          evt.ATTRIBUTE4,
          evt.ATTRIBUTE5,
          evt.ATTRIBUTE6,
          evt.ATTRIBUTE7,
          evt.ATTRIBUTE8,
          evt.ATTRIBUTE9,
          evt.ATTRIBUTE10,
          evt.ATTRIBUTE11,
          evt.ATTRIBUTE12,
          evt.ATTRIBUTE13,
          evt.ATTRIBUTE14,
          evt.ATTRIBUTE15,
          evt.ATTRIBUTE16,
          evt.ATTRIBUTE17,
          evt.ATTRIBUTE18,
          evt.ATTRIBUTE19,
          evt.ATTRIBUTE20
        from
          (
          select
            distinct
            p_worker_id                   WORKER_ID,
            null                          LOG_ROWID,
            'RBS_ASSOC'                   EVENT_TYPE,
            -1                            EVENT_ID,
            sup_rbs_hdr.RBS_VERSION_ID    EVENT_OBJECT,
            'I'                           OPERATION_TYPE,
            'X'                           STATUS,
            null                          ATTRIBUTE_CATEGORY,
            sub_ver.PROJECT_ID            ATTRIBUTE1,
            hdr.RBS_HEADER_ID             ATTRIBUTE2,
            null                          ATTRIBUTE3,
            null                          ATTRIBUTE4,
            null                          ATTRIBUTE5,
            null                          ATTRIBUTE6,
            null                          ATTRIBUTE7,
            null                          ATTRIBUTE8,
            null                          ATTRIBUTE9,
            null                          ATTRIBUTE10,
            null                          ATTRIBUTE11,
            null                          ATTRIBUTE12,
            null                          ATTRIBUTE13,
            null                          ATTRIBUTE14,
            null                          ATTRIBUTE15,
            null                          ATTRIBUTE16,
            prg.SUP_PROJECT_ID            ATTRIBUTE17, -- program's PROJECT_ID
            'N'                           ATTRIBUTE18, -- PROG_REP_USAGE_FLAG
            null                          ATTRIBUTE19, -- update header only
            'NEW_CONVERTED_RBS_PRG_EVENT' ATTRIBUTE20  -- flg converted events
          from
            PJI_XBS_DENORM_DELTA     prg,
            PJI_PJP_RBS_HEADER       sup_rbs_hdr,
            PA_PROJ_ELEMENT_VERSIONS sub_ver,
            PA_RBS_VERSIONS_B        hdr
          where
            prg.STRUCT_TYPE                 =  'PRG'                      and
            prg.SUP_ID                      <> prg.SUB_ID                 and
            prg.SIGN                        =  1                          and
            sup_rbs_hdr.PROJECT_ID          =  prg.SUP_PROJECT_ID         and
            sup_rbs_hdr.PLAN_VERSION_ID     =  -1                         and
            sup_rbs_hdr.PROG_REP_USAGE_FLAG =  'Y'                        and
            sub_ver.ELEMENT_VERSION_ID      =  prg.SUB_ID                 and
            hdr.RBS_VERSION_ID              =  sup_rbs_hdr.RBS_VERSION_ID
          )                      evt,
          PJI_PJP_RBS_HEADER     sub_rbs_hdr,
          PJI_PA_PROJ_EVENTS_LOG log
        where
          evt.ATTRIBUTE1         = sub_rbs_hdr.PROJECT_ID      (+) and
          -1                     = sub_rbs_hdr.PLAN_VERSION_ID (+) and
          evt.EVENT_OBJECT       = sub_rbs_hdr.RBS_VERSION_ID  (+) and
          sub_rbs_hdr.PROJECT_ID is null                           and
          'RBS_ASSOC'            = log.EVENT_TYPE              (+) and
          evt.ATTRIBUTE1         = log.ATTRIBUTE1              (+) and
          evt.EVENT_OBJECT       = log.EVENT_OBJECT            (+) and
          log.EVENT_TYPE         is null;

        l_program_id     := -1;
        l_rbs_header_id  := -1;
        l_rbs_version_id := -1;
        l_prj_index      :=  1;
        l_project_id_tbl :=  system.pa_num_tbl_type();
        l_project_id_tbl.delete;

        for c in (select
                    distinct
                    log.ATTRIBUTE2   RBS_HEADER_ID,
                    log.EVENT_OBJECT RBS_VERSION_ID,
                    log.ATTRIBUTE1   PROJECT_ID,
                    log.ATTRIBUTE17  PROGRAM_ID,
                    log.ATTRIBUTE18  PROG_REP_USAGE_FLAG,
                    'Y'              REPORTING_USAGE_FLAG,
                    'N'              FP_USAGE_FLAG,
                    log.ATTRIBUTE19  UPDATE_HEADER_ONLY_FLAG
                  from
                    PJI_PA_PROJ_EVENTS_LOG log
                  where
                    log.WORKER_ID   = p_worker_id                   and
                    log.EVENT_TYPE  = 'RBS_ASSOC'                   and
                    log.ATTRIBUTE20 = 'NEW_CONVERTED_RBS_PRG_EVENT'
                  order by
                    log.ATTRIBUTE17,
                    log.ATTRIBUTE2,
                    log.EVENT_OBJECT) loop

          l_project_id_tbl.extend(1);
          l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
          l_prj_index := l_prj_index + 1;

          if (l_rbs_header_id = -1 and l_rbs_version_id = -1) then

            l_program_id     := c.PROGRAM_ID;
            l_rbs_header_id  := c.RBS_HEADER_ID;
            l_rbs_version_id := c.RBS_VERSION_ID;

          elsif (c.PROGRAM_ID     <> l_program_id or
                 c.RBS_HEADER_ID  <> l_rbs_header_id or
                 c.RBS_VERSION_ID <> l_rbs_version_id) then

            PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                      l_rbs_version_id,
                                                      l_project_id_tbl,
                                                      l_return_status);

            l_program_id     := c.PROGRAM_ID;
            l_rbs_header_id  := c.RBS_HEADER_ID;
            l_rbs_version_id := c.RBS_VERSION_ID;
            l_prj_index      := 1;
            l_project_id_tbl.delete;

          end if;

          insert into PJI_PJP_RBS_HEADER
          (
            PROJECT_ID,
            PLAN_VERSION_ID,
            RBS_VERSION_ID,
            REPORTING_USAGE_FLAG,
            PROG_REP_USAGE_FLAG,
            PLAN_USAGE_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            PLAN_TYPE_CODE
          )
          values
          (
            c.PROJECT_ID,
            -1,
            c.RBS_VERSION_ID,
            c.REPORTING_USAGE_FLAG,
            c.PROG_REP_USAGE_FLAG,
            c.FP_USAGE_FLAG,
            l_last_update_date,
            l_last_updated_by,
            l_creation_date,
            l_created_by,
            l_last_update_login,
            'A'
          );

          insert into PJI_PA_PROJ_EVENTS_LOG
          (
            WORKER_ID,
            EVENT_TYPE,
            EVENT_ID,
            EVENT_OBJECT,
            OPERATION_TYPE,
            STATUS
          )
          select
            p_worker_id,
            'PJI_RBS_CHANGE',
            PA_PJI_PROJ_EVENTS_LOG_S.NEXTVAL,
            c.RBS_VERSION_ID,
            'I',
            'X'
          from
            DUAL
          where
            not exists (select 1
                        from   PA_RBS_DENORM rbs
                        where  rbs.STRUCT_VERSION_ID = c.RBS_VERSION_ID);

        end loop;

        if (l_rbs_header_id <> -1 and l_rbs_version_id <> -1) then

          PA_RBS_ASGMT_PVT.ASSOCIATE_RBS_TO_PROGRAM(l_rbs_header_id,
                                                    l_rbs_version_id,
                                                    l_project_id_tbl,
                                                    l_return_status);

        end if;

      end if;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_XBS_DENORM_DELTA(p_worker_id);');

      commit;

    else -- online mode

      -- get WBS delta for online processing

      insert into PJI_XBS_DENORM_DELTA_T
      (
        WORKER_ID,
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE,
        SIGN
      )
      select
        1 WORKER_ID,
        -- p_worker_id WORKER_ID,
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        decode(sum(SUP_LEVEL_NEW), 0, sum(SUP_LEVEL_OLD),
                                      sum(SUP_LEVEL_NEW)) SUP_LEVEL,
        decode(sum(SUB_LEVEL_NEW), 0, sum(SUB_LEVEL_OLD),
                                      sum(SUB_LEVEL_NEW)) SUB_LEVEL,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE,
        sum(SIGN) SIGN
      from
        (
        select
          wbs.STRUCT_TYPE,
          -1                               PRG_GROUP,
          wbs.STRUCT_VERSION_ID,
          wbs.SUP_PROJECT_ID,
          -1                               SUP_ID,
          wbs.SUP_EMT_ID,
          -1                               SUBRO_ID,
          -1                               SUB_ID,
          wbs.SUB_EMT_ID,
          wbs.SUP_LEVEL                    SUP_LEVEL_NEW,
          wbs.SUB_LEVEL                    SUB_LEVEL_NEW,
          0                                SUP_LEVEL_OLD,
          0                                SUB_LEVEL_OLD,
          wbs.SUB_ROLLUP_ID,
          'X'                              SUB_LEAF_FLAG,
          'X'                              RELATIONSHIP_TYPE,
          +1                               SIGN
        from
          PA_XBS_DENORM wbs
        where
          wbs.STRUCT_TYPE       = 'WBS' and
          wbs.SUP_PROJECT_ID    = g_project_id and
          wbs.STRUCT_VERSION_ID in (g_new_struct_version)
        union all
        select
          wbs.STRUCT_TYPE,
          -1                               PRG_GROUP,
          wbs.STRUCT_VERSION_ID,
          wbs.SUP_PROJECT_ID,
          -1                               SUP_ID,
          wbs.SUP_EMT_ID,
          -1                               SUBRO_ID,
          -1                               SUB_ID,
          wbs.SUB_EMT_ID,
          0                                SUP_LEVEL_NEW,
          0                                SUB_LEVEL_NEW,
          wbs.SUP_LEVEL                    SUP_LEVEL_OLD,
          wbs.SUB_LEVEL                    SUB_LEVEL_OLD,
          wbs.SUB_ROLLUP_ID,
          'X'                              SUB_LEAF_FLAG,
          'X'                              RELATIONSHIP_TYPE,
          -1                               SIGN
        from
          PJI_XBS_DENORM wbs
        where
          wbs.STRUCT_TYPE       =  'WBS' and
          wbs.SUP_PROJECT_ID    =  g_project_id and
          wbs.STRUCT_VERSION_ID in (g_old_struct_version)
        )
      group by
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE
      having
        sum(SIGN) <> 0;

    end if;

  end POPULATE_XBS_DENORM_DELTA;


  -- -----------------------------------------------------
  -- procedure POPULATE_RBS_DENORM_DELTA
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure POPULATE_RBS_DENORM_DELTA (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_RBS_DENORM_DELTA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'RBS') then

      insert into PJI_RBS_DENORM_DELTA delta_i
      (
        WORKER_ID,
        STRUCT_VERSION_ID,
        SUP_ID,
        SUBRO_ID,
        SUB_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_LEAF_FLAG,
        SIGN
      )
      select
        p_worker_id,
        STRUCT_VERSION_ID,
        SUP_ID,
        SUBRO_ID,
        SUB_ID,
        decode(sum(SUP_LEVEL_NEW), 0, sum(SUP_LEVEL_OLD),
                                      sum(SUP_LEVEL_NEW)) SUP_LEVEL,
        decode(sum(SUB_LEVEL_NEW), 0, sum(SUB_LEVEL_OLD),
                                      sum(SUB_LEVEL_NEW)) SUB_LEVEL,
        SUB_LEAF_FLAG,
        sum(SIGN) SIGN
      from
        (
        select
          distinct
          rbs.STRUCT_VERSION_ID,
          rbs.SUP_ID,
          -1                               SUBRO_ID,
          rbs.SUB_ID,
          rbs.SUP_LEVEL                    SUP_LEVEL_NEW,
          rbs.SUB_LEVEL                    SUB_LEVEL_NEW,
          0                                SUP_LEVEL_OLD,
          0                                SUB_LEVEL_OLD,
          'X'                              SUB_LEAF_FLAG,
          +1                               SIGN
        from
          PA_RBS_DENORM rbs,
          PJI_PA_PROJ_EVENTS_LOG log
        where
          log.WORKER_ID         = p_worker_id and
          log.EVENT_TYPE        = 'RBS_PUSH'  and
          rbs.STRUCT_VERSION_ID = log.EVENT_OBJECT
        union all
        select
          distinct
          rbs.STRUCT_VERSION_ID,
          rbs.SUP_ID,
          -1                               SUBRO_ID,
          rbs.SUB_ID,
          0                                SUP_LEVEL_NEW,
          0                                SUB_LEVEL_NEW,
          rbs.SUP_LEVEL                    SUP_LEVEL_OLD,
          rbs.SUB_LEVEL                    SUB_LEVEL_OLD,
          'X'                              SUB_LEAF_FLAG,
          -1                               SIGN
        from
          PJI_RBS_DENORM rbs,
          PJI_PA_PROJ_EVENTS_LOG log
        where
          log.WORKER_ID         = p_worker_id and
          log.EVENT_TYPE        = 'RBS_PUSH'  and
          rbs.STRUCT_VERSION_ID = log.ATTRIBUTE2
        )
      group by
        STRUCT_VERSION_ID,
        SUP_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_LEAF_FLAG
      having
        sum(SIGN) <> 0;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_RBS_DENORM_DELTA(p_worker_id);');

    commit;

  end POPULATE_RBS_DENORM_DELTA;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FP_SLICES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_FP_SLICES (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_flag  varchar2(1); /* Added for Bug 8708651 */

    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

    l_plan_type_id      number;    -- Bug#5099574
    l_refresh_code      number;


  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_SLICES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

   --  Bug#5099574  - Start

      l_plan_type_id     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'PLAN_TYPE_ID');
      l_refresh_code     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'REFRESH_CODE');

      if (l_plan_type_id = -1) then
        l_plan_type_id := null;
      end if;

    -- If  condtion is true then mark the process as completed and return
      if ( l_extraction_type='PARTIAL' and ( bitand(l_refresh_code,1) <> 1) ) then
       PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_SLICES(p_worker_id);');
       commit;
       return;
      end if;

  --  Bug#5099574 - End


    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG,
      nvl(GLOBAL_CURR1_FLAG,'Y')   /* Added for Bug 8708651, NULL check added for 9062837 */
    into
      l_txn_currency_flag,
      l_g2_currency_flag,
      l_g1_currency_flag    /* Added for Bug 8708651 */
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert into PJI_FP_AGGR_PJP0 pjp0_i
    (
      WORKER_ID,
      TXN_ACCUM_HEADER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      RAW_COST,
      BRDN_COST,
      REVENUE,
      BILL_RAW_COST,
      BILL_BRDN_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BRDN_COST,
      BILL_LABOR_HRS,
      EQUIPMENT_RAW_COST,
      EQUIPMENT_BRDN_COST,
      CAPITALIZABLE_RAW_COST,
      CAPITALIZABLE_BRDN_COST,
      LABOR_RAW_COST,
      LABOR_BRDN_COST,
      LABOR_HRS,
      LABOR_REVENUE,
      EQUIPMENT_HOURS,
      BILLABLE_EQUIPMENT_HOURS,
      SUP_INV_COMMITTED_COST,
      PO_COMMITTED_COST,
      PR_COMMITTED_COST,
      OTH_COMMITTED_COST
    )
    select
      src.WORKER_ID,
      src.TXN_ACCUM_HEADER_ID,
      src.PROJECT_ID,
      src.PROJECT_ORG_ID,
      src.PROJECT_ORGANIZATION_ID,
      src.PROJECT_ELEMENT_ID,
      src.TIME_ID,
      src.PERIOD_TYPE_ID,
      src.CALENDAR_TYPE,
      src.RBS_AGGR_LEVEL,
      src.WBS_ROLLUP_FLAG,
      src.PRG_ROLLUP_FLAG,
      src.CURR_RECORD_TYPE_ID,
      src.CURRENCY_CODE,
      src.RBS_ELEMENT_ID,
      src.RBS_VERSION_ID,
      src.PLAN_VERSION_ID,
      src.PLAN_TYPE_ID,
      sum(src.RAW_COST)                               RAW_COST,
      sum(src.BRDN_COST)                              BRDN_COST,
      sum(src.REVENUE)                                REVENUE,
      sum(decode(src.PROJECT_TYPE_CLASS, 'B',
                 src.BILL_RAW_COST, to_number(null))) BILL_RAW_COST,
      sum(decode(src.PROJECT_TYPE_CLASS, 'B',
                 src.BILL_BRDN_COST, to_number(null)))BILL_BRDN_COST,
      sum(decode(src.PROJECT_TYPE_CLASS || '_' ||
                 cls.RESOURCE_CLASS_CODE, 'B_PEOPLE',
                 src.BILL_RAW_COST, to_number(null))) BILL_LABOR_RAW_COST,
      sum(decode(src.PROJECT_TYPE_CLASS || '_' ||
                 cls.RESOURCE_CLASS_CODE, 'B_PEOPLE',
                 src.BILL_BRDN_COST, to_number(null)))BILL_LABOR_BRDN_COST,
      sum(decode(src.PROJECT_TYPE_CLASS || '_' ||
                 cls.RESOURCE_CLASS_CODE, 'B_PEOPLE',
                 src.BILL_QUANTITY, to_number(null))) BILL_LABOR_HRS,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'EQUIPMENT',
                 src.RAW_COST, to_number(null)))      EQUIPMENT_RAW_COST,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'EQUIPMENT',
                 src.BRDN_COST, to_number(null)))     EQUIPMENT_BRDN_COST,
      sum(decode(src.PROJECT_TYPE_CLASS, 'C',
                 src.BILL_RAW_COST, to_number(null))) CAPITALIZABLE_RAW_COST,
      sum(decode(src.PROJECT_TYPE_CLASS, 'C',
                 src.BILL_BRDN_COST, to_number(null)))CAPITALIZABLE_BRDN_COST,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'PEOPLE',
                 src.RAW_COST, to_number(null)))      LABOR_RAW_COST,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'PEOPLE',
                 src.BRDN_COST, to_number(null)))     LABOR_BRDN_COST,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'PEOPLE',
                 src.QUANTITY, to_number(null)))      LABOR_HRS,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'PEOPLE',
                 src.REVENUE, to_number(null)))       LABOR_REVENUE,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'EQUIPMENT',
                 src.QUANTITY, to_number(null)))      EQUIPMENT_HOURS,
      sum(decode(cls.RESOURCE_CLASS_CODE, 'EQUIPMENT',
                 src.BILL_QUANTITY, to_number(null))) BILLABLE_EQUIPMENT_HOURS,
      sum(src.SUP_INV_COMMITTED_COST)                 SUP_INV_COMMITTED_COST,
      sum(src.PO_COMMITTED_COST)                      PO_COMMITTED_COST,
      sum(src.PR_COMMITTED_COST)                      PR_COMMITTED_COST,
      sum(src.OTH_COMMITTED_COST)                     OTH_COMMITTED_COST
    from
      (
      select
        src3.WORKER_ID,
        src3.TXN_ACCUM_HEADER_ID,
        src3.RESOURCE_CLASS_ID,
        src3.PROJECT_ID,
        src3.PROJECT_ORG_ID,
        src3.PROJECT_ORGANIZATION_ID,
        src3.PROJECT_TYPE_CLASS,
        src3.PROJECT_ELEMENT_ID,
        src3.TIME_ID,
        src3.PERIOD_TYPE_ID,
        src3.CALENDAR_TYPE,
        src3.RBS_AGGR_LEVEL,
        src3.WBS_ROLLUP_FLAG,
        src3.PRG_ROLLUP_FLAG,
        sum(src3.CURR_RECORD_TYPE_ID)                 CURR_RECORD_TYPE_ID,
        nvl(src3.CURRENCY_CODE, 'PJI$NULL')           CURRENCY_CODE,
        src3.RBS_ELEMENT_ID,
        src3.RBS_VERSION_ID,
        src3.PLAN_VERSION_ID,
        src3.PLAN_TYPE_ID,
        max(src3.RAW_COST)                            RAW_COST,
        max(src3.BRDN_COST)                           BRDN_COST,
        max(src3.REVENUE)                             REVENUE,
        max(src3.BILL_RAW_COST)                       BILL_RAW_COST,
        max(src3.BILL_BRDN_COST)                      BILL_BRDN_COST,
        max(src3.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        max(src3.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        max(src3.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        max(src3.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        max(src3.QUANTITY)                            QUANTITY,
        max(src3.BILL_QUANTITY)                       BILL_QUANTITY
      from
        (
        select /*+ ordered */
          p_worker_id                                 WORKER_ID,
          src.TXN_ACCUM_HEADER_ID,
          src.RESOURCE_CLASS_ID,
          src.PROJECT_ID,
          src.PROJECT_ORG_ID,
          map.PROJECT_ORGANIZATION_ID,
          src.PROJECT_TYPE_CLASS,
          decode(src.TASK_ID,
                 -1, ver.PROJ_ELEMENT_ID,
                 src.TASK_ID)                         PROJECT_ELEMENT_ID,
          src.RECVR_PERIOD_ID                         TIME_ID,
          32                                          PERIOD_TYPE_ID,
          decode(src.RECVR_PERIOD_TYPE,
                 'ENT', 'E',
                 'GL',  'G',
                 'PA',  'P')                          CALENDAR_TYPE,
          'L'                                         RBS_AGGR_LEVEL,
          'N'                                         WBS_ROLLUP_FLAG,
          'N'                                         PRG_ROLLUP_FLAG,
          invert.INVERT_ID                            CURR_RECORD_TYPE_ID,
          decode(invert.INVERT_ID,
                 1,   l_g1_currency_code,
                 2,   l_g2_currency_code,
                 4,   info.PF_CURRENCY_CODE,
                 8,   map.PRJ_CURRENCY_CODE,
                 16,  src.TXN_CURRENCY_CODE,
                 32,  l_g1_currency_code,
                 64,  l_g2_currency_code,
                 128, info.PF_CURRENCY_CODE,
                 256, map.PRJ_CURRENCY_CODE)          DIFF_CURRENCY_CODE,
          DIFF_ROWNUM                                 DIFF_ROWNUM,
          decode(invert.INVERT_ID,
                 1,   l_g1_currency_code,
                 2,   l_g2_currency_code,
                 4,   info.PF_CURRENCY_CODE,
                 8,   map.PRJ_CURRENCY_CODE,
                 16,  src.TXN_CURRENCY_CODE,
                 32,  src.TXN_CURRENCY_CODE,
                 64,  src.TXN_CURRENCY_CODE,
                 128, src.TXN_CURRENCY_CODE,
                 256, src.TXN_CURRENCY_CODE)          CURRENCY_CODE,
          nvl(rbs.ELEMENT_ID, -1)                     RBS_ELEMENT_ID,
          src.RBS_VERSION_ID,
          -1                                          PLAN_VERSION_ID,
          -1                                          PLAN_TYPE_ID,
          decode(invert.INVERT_ID,
                 1,   src.G1_RAW_COST,
                 2,   src.G2_RAW_COST,
                 4,   src.POU_RAW_COST,
                 8,   src.PRJ_RAW_COST,
                 16,  src.TXN_RAW_COST,
                 32,  src.G1_RAW_COST,
                 64,  src.G2_RAW_COST,
                 128, src.POU_RAW_COST,
                 256, src.PRJ_RAW_COST)               RAW_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_BRDN_COST,
                 2,   src.G2_BRDN_COST,
                 4,   src.POU_BRDN_COST,
                 8,   src.PRJ_BRDN_COST,
                 16,  src.TXN_BRDN_COST,
                 32,  src.G1_BRDN_COST,
                 64,  src.G2_BRDN_COST,
                 128, src.POU_BRDN_COST,
                 256, src.PRJ_BRDN_COST)              BRDN_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_REVENUE,
                 2,   src.G2_REVENUE,
                 4,   src.POU_REVENUE,
                 8,   src.PRJ_REVENUE,
                 16,  src.TXN_REVENUE,
                 32,  src.G1_REVENUE,
                 64,  src.G2_REVENUE,
                 128, src.POU_REVENUE,
                 256, src.PRJ_REVENUE)                REVENUE,
          decode(invert.INVERT_ID,
                 1,   src.G1_BILL_RAW_COST,
                 2,   src.G2_BILL_RAW_COST,
                 4,   src.POU_BILL_RAW_COST,
                 8,   src.PRJ_BILL_RAW_COST,
                 16,  src.TXN_BILL_RAW_COST,
                 32,  src.G1_BILL_RAW_COST,
                 64,  src.G2_BILL_RAW_COST,
                 128, src.POU_BILL_RAW_COST,
                 256, src.PRJ_BILL_RAW_COST)          BILL_RAW_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_BILL_BRDN_COST,
                 2,   src.G2_BILL_BRDN_COST,
                 4,   src.POU_BILL_BRDN_COST,
                 8,   src.PRJ_BILL_BRDN_COST,
                 16,  src.TXN_BILL_BRDN_COST,
                 32,  src.G1_BILL_BRDN_COST,
                 64,  src.G2_BILL_BRDN_COST,
                 128, src.POU_BILL_BRDN_COST,
                 256, src.PRJ_BILL_BRDN_COST)         BILL_BRDN_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_SUP_INV_COMMITTED_COST,
                 2,   src.G2_SUP_INV_COMMITTED_COST,
                 4,   src.POU_SUP_INV_COMMITTED_COST,
                 8,   src.PRJ_SUP_INV_COMMITTED_COST,
                 16,  src.TXN_SUP_INV_COMMITTED_COST,
                 32,  src.G1_SUP_INV_COMMITTED_COST,
                 64,  src.G2_SUP_INV_COMMITTED_COST,
                 128, src.POU_SUP_INV_COMMITTED_COST,
                 256, src.PRJ_SUP_INV_COMMITTED_COST) SUP_INV_COMMITTED_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_PO_COMMITTED_COST,
                 2,   src.G2_PO_COMMITTED_COST,
                 4,   src.POU_PO_COMMITTED_COST,
                 8,   src.PRJ_PO_COMMITTED_COST,
                 16,  src.TXN_PO_COMMITTED_COST,
                 32,  src.G1_PO_COMMITTED_COST,
                 64,  src.G2_PO_COMMITTED_COST,
                 128, src.POU_PO_COMMITTED_COST,
                 256, src.PRJ_PO_COMMITTED_COST)      PO_COMMITTED_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_PR_COMMITTED_COST,
                 2,   src.G2_PR_COMMITTED_COST,
                 4,   src.POU_PR_COMMITTED_COST,
                 8,   src.PRJ_PR_COMMITTED_COST,
                 16,  src.TXN_PR_COMMITTED_COST,
                 32,  src.G1_PR_COMMITTED_COST,
                 64,  src.G2_PR_COMMITTED_COST,
                 128, src.POU_PR_COMMITTED_COST,
                 256, src.PRJ_PR_COMMITTED_COST)      PR_COMMITTED_COST,
          decode(invert.INVERT_ID,
                 1,   src.G1_OTH_COMMITTED_COST,
                 2,   src.G2_OTH_COMMITTED_COST,
                 4,   src.POU_OTH_COMMITTED_COST,
                 8,   src.PRJ_OTH_COMMITTED_COST,
                 16,  src.TXN_OTH_COMMITTED_COST,
                 32,  src.G1_OTH_COMMITTED_COST,
                 64,  src.G2_OTH_COMMITTED_COST,
                 128, src.POU_OTH_COMMITTED_COST,
                 256, src.PRJ_OTH_COMMITTED_COST)     OTH_COMMITTED_COST,
          src.QUANTITY,
          src.BILL_QUANTITY
        from
          (
          select
            ROWNUM                                       DIFF_ROWNUM,
            src2.TXN_ACCUM_HEADER_ID,
            src2.RESOURCE_CLASS_ID,
            src2.PROJECT_ID,
            src2.PROJECT_ORG_ID,
            src2.PROJECT_ORGANIZATION_ID,
            src2.PROJECT_TYPE_CLASS,
            src2.TASK_ID,
            src2.RECVR_PERIOD_TYPE,
            src2.RECVR_PERIOD_ID,
            src2.RBS_VERSION_ID,
            src2.TXN_CURRENCY_CODE,
            src2.TXN_RAW_COST,
            src2.TXN_BILL_RAW_COST,
            src2.TXN_BRDN_COST,
            src2.TXN_BILL_BRDN_COST,
            src2.TXN_REVENUE,
            src2.TXN_SUP_INV_COMMITTED_COST,
            src2.TXN_PO_COMMITTED_COST,
            src2.TXN_PR_COMMITTED_COST,
            src2.TXN_OTH_COMMITTED_COST,
            src2.PRJ_RAW_COST,
            src2.PRJ_BILL_RAW_COST,
            src2.PRJ_BRDN_COST,
            src2.PRJ_BILL_BRDN_COST,
            src2.PRJ_REVENUE,
            src2.PRJ_SUP_INV_COMMITTED_COST,
            src2.PRJ_PO_COMMITTED_COST,
            src2.PRJ_PR_COMMITTED_COST,
            src2.PRJ_OTH_COMMITTED_COST,
            src2.POU_RAW_COST,
            src2.POU_BILL_RAW_COST,
            src2.POU_BRDN_COST,
            src2.POU_BILL_BRDN_COST,
            src2.POU_REVENUE,
            src2.POU_SUP_INV_COMMITTED_COST,
            src2.POU_PO_COMMITTED_COST,
            src2.POU_PR_COMMITTED_COST,
            src2.POU_OTH_COMMITTED_COST,
            src2.EOU_RAW_COST,
            src2.EOU_BILL_RAW_COST,
            src2.EOU_BRDN_COST,
            src2.EOU_BILL_BRDN_COST,
            src2.EOU_SUP_INV_COMMITTED_COST,
            src2.EOU_PO_COMMITTED_COST,
            src2.EOU_PR_COMMITTED_COST,
            src2.EOU_OTH_COMMITTED_COST,
            src2.G1_RAW_COST,
            src2.G1_BILL_RAW_COST,
            src2.G1_BRDN_COST,
            src2.G1_BILL_BRDN_COST,
            src2.G1_REVENUE,
            src2.G1_SUP_INV_COMMITTED_COST,
            src2.G1_PO_COMMITTED_COST,
            src2.G1_PR_COMMITTED_COST,
            src2.G1_OTH_COMMITTED_COST,
            src2.G2_RAW_COST,
            src2.G2_BILL_RAW_COST,
            src2.G2_BRDN_COST,
            src2.G2_BILL_BRDN_COST,
            src2.G2_REVENUE,
            src2.G2_SUP_INV_COMMITTED_COST,
            src2.G2_PO_COMMITTED_COST,
            src2.G2_PR_COMMITTED_COST,
            src2.G2_OTH_COMMITTED_COST,
            src2.QUANTITY,
            src2.BILL_QUANTITY
          from
            (
          select
            src1.TXN_ACCUM_HEADER_ID,
            src1.RESOURCE_CLASS_ID,
            src1.PROJECT_ID,
            src1.PROJECT_ORG_ID,
            src1.PROJECT_ORGANIZATION_ID,
            src1.PROJECT_TYPE_CLASS,
            src1.TASK_ID,
            src1.RECVR_PERIOD_TYPE,
            src1.RECVR_PERIOD_ID,
            src1.RBS_VERSION_ID,
            src1.TXN_CURRENCY_CODE,
            sum(src1.TXN_RAW_COST)                  TXN_RAW_COST,
            sum(src1.TXN_BILL_RAW_COST)             TXN_BILL_RAW_COST,
            sum(src1.TXN_BRDN_COST)                 TXN_BRDN_COST,
            sum(src1.TXN_BILL_BRDN_COST)            TXN_BILL_BRDN_COST,
            sum(src1.TXN_REVENUE)                   TXN_REVENUE,
            sum(src1.TXN_SUP_INV_COMMITTED_COST)    TXN_SUP_INV_COMMITTED_COST,
            sum(src1.TXN_PO_COMMITTED_COST)         TXN_PO_COMMITTED_COST,
            sum(src1.TXN_PR_COMMITTED_COST)         TXN_PR_COMMITTED_COST,
            sum(src1.TXN_OTH_COMMITTED_COST)        TXN_OTH_COMMITTED_COST,
            sum(src1.PRJ_RAW_COST)                  PRJ_RAW_COST,
            sum(src1.PRJ_BILL_RAW_COST)             PRJ_BILL_RAW_COST,
            sum(src1.PRJ_BRDN_COST)                 PRJ_BRDN_COST,
            sum(src1.PRJ_BILL_BRDN_COST)            PRJ_BILL_BRDN_COST,
            sum(src1.PRJ_REVENUE)                   PRJ_REVENUE,
            sum(src1.PRJ_SUP_INV_COMMITTED_COST)    PRJ_SUP_INV_COMMITTED_COST,
            sum(src1.PRJ_PO_COMMITTED_COST)         PRJ_PO_COMMITTED_COST,
            sum(src1.PRJ_PR_COMMITTED_COST)         PRJ_PR_COMMITTED_COST,
            sum(src1.PRJ_OTH_COMMITTED_COST)        PRJ_OTH_COMMITTED_COST,
            sum(src1.POU_RAW_COST)                  POU_RAW_COST,
            sum(src1.POU_BILL_RAW_COST)             POU_BILL_RAW_COST,
            sum(src1.POU_BRDN_COST)                 POU_BRDN_COST,
            sum(src1.POU_BILL_BRDN_COST)            POU_BILL_BRDN_COST,
            sum(src1.POU_REVENUE)                   POU_REVENUE,
            sum(src1.POU_SUP_INV_COMMITTED_COST)    POU_SUP_INV_COMMITTED_COST,
            sum(src1.POU_PO_COMMITTED_COST)         POU_PO_COMMITTED_COST,
            sum(src1.POU_PR_COMMITTED_COST)         POU_PR_COMMITTED_COST,
            sum(src1.POU_OTH_COMMITTED_COST)        POU_OTH_COMMITTED_COST,
            sum(src1.EOU_RAW_COST)                  EOU_RAW_COST,
            sum(src1.EOU_BILL_RAW_COST)             EOU_BILL_RAW_COST,
            sum(src1.EOU_BRDN_COST)                 EOU_BRDN_COST,
            sum(src1.EOU_BILL_BRDN_COST)            EOU_BILL_BRDN_COST,
            sum(src1.EOU_SUP_INV_COMMITTED_COST)    EOU_SUP_INV_COMMITTED_COST,
            sum(src1.EOU_PO_COMMITTED_COST)         EOU_PO_COMMITTED_COST,
            sum(src1.EOU_PR_COMMITTED_COST)         EOU_PR_COMMITTED_COST,
            sum(src1.EOU_OTH_COMMITTED_COST)        EOU_OTH_COMMITTED_COST,
            sum(src1.G1_RAW_COST)                   G1_RAW_COST,
            sum(src1.G1_BILL_RAW_COST)              G1_BILL_RAW_COST,
            sum(src1.G1_BRDN_COST)                  G1_BRDN_COST,
            sum(src1.G1_BILL_BRDN_COST)             G1_BILL_BRDN_COST,
            sum(src1.G1_REVENUE)                    G1_REVENUE,
            sum(src1.G1_SUP_INV_COMMITTED_COST)     G1_SUP_INV_COMMITTED_COST,
            sum(src1.G1_PO_COMMITTED_COST)          G1_PO_COMMITTED_COST,
            sum(src1.G1_PR_COMMITTED_COST)          G1_PR_COMMITTED_COST,
            sum(src1.G1_OTH_COMMITTED_COST)         G1_OTH_COMMITTED_COST,
            sum(src1.G2_RAW_COST)                   G2_RAW_COST,
            sum(src1.G2_BILL_RAW_COST)              G2_BILL_RAW_COST,
            sum(src1.G2_BRDN_COST)                  G2_BRDN_COST,
            sum(src1.G2_BILL_BRDN_COST)             G2_BILL_BRDN_COST,
            sum(src1.G2_REVENUE)                    G2_REVENUE,
            sum(src1.G2_SUP_INV_COMMITTED_COST)     G2_SUP_INV_COMMITTED_COST,
            sum(src1.G2_PO_COMMITTED_COST)          G2_PO_COMMITTED_COST,
            sum(src1.G2_PR_COMMITTED_COST)          G2_PR_COMMITTED_COST,
            sum(src1.G2_OTH_COMMITTED_COST)         G2_OTH_COMMITTED_COST,
            sum(src1.QUANTITY)                      QUANTITY,
            sum(src1.BILL_QUANTITY)                 BILL_QUANTITY
          from
            (
          select                           -- initial actuals data
            bal.TXN_ACCUM_HEADER_ID,
            bal.RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            bal.PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            nvl(rbs_hdr.RBS_VERSION_ID, -1)         RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            bal.TXN_RAW_COST,
            bal.TXN_BILL_RAW_COST,
            bal.TXN_BRDN_COST,
            bal.TXN_BILL_BRDN_COST,
            bal.TXN_REVENUE,
            to_number(null)                         TXN_SUP_INV_COMMITTED_COST,
            to_number(null)                         TXN_PO_COMMITTED_COST,
            to_number(null)                         TXN_PR_COMMITTED_COST,
            to_number(null)                         TXN_OTH_COMMITTED_COST,
            bal.PRJ_RAW_COST,
            bal.PRJ_BILL_RAW_COST,
            bal.PRJ_BRDN_COST,
            bal.PRJ_BILL_BRDN_COST,
            bal.PRJ_REVENUE,
            to_number(null)                         PRJ_SUP_INV_COMMITTED_COST,
            to_number(null)                         PRJ_PO_COMMITTED_COST,
            to_number(null)                         PRJ_PR_COMMITTED_COST,
            to_number(null)                         PRJ_OTH_COMMITTED_COST,
            bal.POU_RAW_COST,
            bal.POU_BILL_RAW_COST,
            bal.POU_BRDN_COST,
            bal.POU_BILL_BRDN_COST,
            bal.POU_REVENUE,
            to_number(null)                         POU_SUP_INV_COMMITTED_COST,
            to_number(null)                         POU_PO_COMMITTED_COST,
            to_number(null)                         POU_PR_COMMITTED_COST,
            to_number(null)                         POU_OTH_COMMITTED_COST,
            bal.EOU_RAW_COST,
            bal.EOU_BILL_RAW_COST,
            bal.EOU_BRDN_COST,
            bal.EOU_BILL_BRDN_COST,
            to_number(null)                         EOU_SUP_INV_COMMITTED_COST,
            to_number(null)                         EOU_PO_COMMITTED_COST,
            to_number(null)                         EOU_PR_COMMITTED_COST,
            to_number(null)                         EOU_OTH_COMMITTED_COST,
            bal.G1_RAW_COST,
            bal.G1_BILL_RAW_COST,
            bal.G1_BRDN_COST,
            bal.G1_BILL_BRDN_COST,
            bal.G1_REVENUE,
            to_number(null)                         G1_SUP_INV_COMMITTED_COST,
            to_number(null)                         G1_PO_COMMITTED_COST,
            to_number(null)                         G1_PR_COMMITTED_COST,
            to_number(null)                         G1_OTH_COMMITTED_COST,
            bal.G2_RAW_COST,
            bal.G2_BILL_RAW_COST,
            bal.G2_BRDN_COST,
            bal.G2_BILL_BRDN_COST,
            bal.G2_REVENUE,
            to_number(null)                         G2_SUP_INV_COMMITTED_COST,
            to_number(null)                         G2_PO_COMMITTED_COST,
            to_number(null)                         G2_PR_COMMITTED_COST,
            to_number(null)                         G2_OTH_COMMITTED_COST,
            bal.QUANTITY,
            bal.BILL_QUANTITY
          from
            PJI_PJP_PROJ_BATCH_MAP map,
            PJI_FP_TXN_ACCUM       bal,
            PJI_PJP_RBS_HEADER     rbs_hdr
          where
            l_extraction_type in ('FULL', 'PARTIAL')    and
--     decode(l_extraction_type,'FULL','Y','PARTIAL',decode(bitand(l_refresh_code,1),1,'Y','N'),'N') ='Y'  and --  Bug#5099574
--      l_plan_type_id IS NULL        and                                 --  Bug#5099574
            map.WORKER_ID     = p_worker_id             and
            bal.PROJECT_ID    = map.PROJECT_ID          and
            bal.PROJECT_ID    = rbs_hdr.PROJECT_ID      and
            -1                = rbs_hdr.PLAN_VERSION_ID
          union all                     -- initial commitments data
          select
            bal.TXN_ACCUM_HEADER_ID,
            to_number(null)                         RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            to_char(null)                           PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            nvl(rbs_hdr.RBS_VERSION_ID, -1)         RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            to_number(null)                         TXN_RAW_COST,
            to_number(null)                         TXN_BILL_RAW_COST,
            to_number(null)                         TXN_BRDN_COST,
            to_number(null)                         TXN_BILL_BRDN_COST,
            to_number(null)                         TXN_REVENUE,
            bal.TXN_SUP_INV_COMMITTED_COST,
            bal.TXN_PO_COMMITTED_COST,
            bal.TXN_PR_COMMITTED_COST,
            bal.TXN_OTH_COMMITTED_COST,
            to_number(null)                         PRJ_RAW_COST,
            to_number(null)                         PRJ_BILL_RAW_COST,
            to_number(null)                         PRJ_BRDN_COST,
            to_number(null)                         PRJ_BILL_BRDN_COST,
            to_number(null)                         PRJ_REVENUE,
            bal.PRJ_SUP_INV_COMMITTED_COST,
            bal.PRJ_PO_COMMITTED_COST,
            bal.PRJ_PR_COMMITTED_COST,
            bal.PRJ_OTH_COMMITTED_COST,
            to_number(null)                         POU_RAW_COST,
            to_number(null)                         POU_BILL_RAW_COST,
            to_number(null)                         POU_BRDN_COST,
            to_number(null)                         POU_BILL_BRDN_COST,
            to_number(null)                         POU_REVENUE,
            bal.POU_SUP_INV_COMMITTED_COST,
            bal.POU_PO_COMMITTED_COST,
            bal.POU_PR_COMMITTED_COST,
            bal.POU_OTH_COMMITTED_COST,
            to_number(null)                         EOU_RAW_COST,
            to_number(null)                         EOU_BILL_RAW_COST,
            to_number(null)                         EOU_BRDN_COST,
            to_number(null)                         EOU_BILL_BRDN_COST,
            bal.EOU_SUP_INV_COMMITTED_COST,
            bal.EOU_PO_COMMITTED_COST,
            bal.EOU_PR_COMMITTED_COST,
            bal.EOU_OTH_COMMITTED_COST,
            to_number(null)                         G1_RAW_COST,
            to_number(null)                         G1_BILL_RAW_COST,
            to_number(null)                         G1_BRDN_COST,
            to_number(null)                         G1_BILL_BRDN_COST,
            to_number(null)                         G1_REVENUE,
            bal.G1_SUP_INV_COMMITTED_COST,
            bal.G1_PO_COMMITTED_COST,
            bal.G1_PR_COMMITTED_COST,
            bal.G1_OTH_COMMITTED_COST,
            to_number(null)                         G2_RAW_COST,
            to_number(null)                         G2_BILL_RAW_COST,
            to_number(null)                         G2_BRDN_COST,
            to_number(null)                         G2_BILL_BRDN_COST,
            to_number(null)                         G2_REVENUE,
            bal.G2_SUP_INV_COMMITTED_COST,
            bal.G2_PO_COMMITTED_COST,
            bal.G2_PR_COMMITTED_COST,
            bal.G2_OTH_COMMITTED_COST,
            to_number(null)                         QUANTITY,
            to_number(null)                         BILL_QUANTITY
          from
            PJI_PJP_PROJ_BATCH_MAP map,
            PJI_FP_TXN_ACCUM1      bal,
            PJI_PJP_RBS_HEADER     rbs_hdr
          where
            l_extraction_type in ('FULL', 'PARTIAL')    and
--            decode(l_extraction_type,'FULL','Y','PARTIAL',decode(bitand(l_refresh_code,1),1,'Y','N'),'N') ='Y'  and  --  Bug#5099574
  --          l_plan_type_id IS NULL        and                             --  Bug#5099574
            map.WORKER_ID     = p_worker_id             and
            bal.PROJECT_ID    = map.PROJECT_ID          and
            bal.PROJECT_ID    = rbs_hdr.PROJECT_ID      and
            -1                = rbs_hdr.PLAN_VERSION_ID
          union all                       -- incremental data
          select
            tmp7.TXN_ACCUM_HEADER_ID,
            tmp7.RESOURCE_CLASS_ID,
            tmp7.PROJECT_ID,
            tmp7.PROJECT_ORG_ID,
            tmp7.PROJECT_ORGANIZATION_ID,
            tmp7.PROJECT_TYPE_CLASS,
            nvl(tmp7.TASK_ID, -1)                   TASK_ID,
            tmp7.RECVR_PERIOD_TYPE,
            tmp7.RECVR_PERIOD_ID,
            nvl(rbs_hdr.RBS_VERSION_ID, -1)         RBS_VERSION_ID,
            tmp7.TXN_CURRENCY_CODE,
            tmp7.TXN_RAW_COST,
            tmp7.TXN_BILL_RAW_COST,
            tmp7.TXN_BRDN_COST,
            tmp7.TXN_BILL_BRDN_COST,
            tmp7.TXN_REVENUE,
            tmp7.TXN_SUP_INV_COMMITTED_COST,
            tmp7.TXN_PO_COMMITTED_COST,
            tmp7.TXN_PR_COMMITTED_COST,
            tmp7.TXN_OTH_COMMITTED_COST,
            tmp7.PRJ_RAW_COST,
            tmp7.PRJ_BILL_RAW_COST,
            tmp7.PRJ_BRDN_COST,
            tmp7.PRJ_BILL_BRDN_COST,
            tmp7.PRJ_REVENUE,
            tmp7.PRJ_SUP_INV_COMMITTED_COST,
            tmp7.PRJ_PO_COMMITTED_COST,
            tmp7.PRJ_PR_COMMITTED_COST,
            tmp7.PRJ_OTH_COMMITTED_COST,
            tmp7.POU_RAW_COST,
            tmp7.POU_BILL_RAW_COST,
            tmp7.POU_BRDN_COST,
            tmp7.POU_BILL_BRDN_COST,
            tmp7.POU_REVENUE,
            tmp7.POU_SUP_INV_COMMITTED_COST,
            tmp7.POU_PO_COMMITTED_COST,
            tmp7.POU_PR_COMMITTED_COST,
            tmp7.POU_OTH_COMMITTED_COST,
            tmp7.EOU_RAW_COST,
            tmp7.EOU_BILL_RAW_COST,
            tmp7.EOU_BRDN_COST,
            tmp7.EOU_BILL_BRDN_COST,
            tmp7.EOU_SUP_INV_COMMITTED_COST,
            tmp7.EOU_PO_COMMITTED_COST,
            tmp7.EOU_PR_COMMITTED_COST,
            tmp7.EOU_OTH_COMMITTED_COST,
            tmp7.G1_RAW_COST,
            tmp7.G1_BILL_RAW_COST,
            tmp7.G1_BRDN_COST,
            tmp7.G1_BILL_BRDN_COST,
            tmp7.G1_REVENUE,
            tmp7.G1_SUP_INV_COMMITTED_COST,
            tmp7.G1_PO_COMMITTED_COST,
            tmp7.G1_PR_COMMITTED_COST,
            tmp7.G1_OTH_COMMITTED_COST,
            tmp7.G2_RAW_COST,
            tmp7.G2_BILL_RAW_COST,
            tmp7.G2_BRDN_COST,
            tmp7.G2_BILL_BRDN_COST,
            tmp7.G2_REVENUE,
            tmp7.G2_SUP_INV_COMMITTED_COST,
            tmp7.G2_PO_COMMITTED_COST,
            tmp7.G2_PR_COMMITTED_COST,
            tmp7.G2_OTH_COMMITTED_COST,
            tmp7.QUANTITY,
            tmp7.BILL_QUANTITY
          from
            PJI_PJP_RMAP_FPR   tmp7_r,
            PJI_FM_AGGR_FIN7   tmp7,
            PJI_PJP_RBS_HEADER rbs_hdr
          where
            l_extraction_type = 'INCREMENTAL'           and
            tmp7_r.WORKER_ID  = p_worker_id             and
            tmp7_r.STG_ROWID  = tmp7.ROWID              and
            tmp7.PROJECT_ID   = rbs_hdr.PROJECT_ID      and
            -1                = rbs_hdr.PLAN_VERSION_ID
          union all                  -- newly associated RBSs for actuals
          select
            bal.TXN_ACCUM_HEADER_ID,
            bal.RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            bal.PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            log.RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            bal.TXN_RAW_COST,
            bal.TXN_BILL_RAW_COST,
            bal.TXN_BRDN_COST,
            bal.TXN_BILL_BRDN_COST,
            bal.TXN_REVENUE,
            to_number(null)                         TXN_SUP_INV_COMMITTED_COST,
            to_number(null)                         TXN_PO_COMMITTED_COST,
            to_number(null)                         TXN_PR_COMMITTED_COST,
            to_number(null)                         TXN_OTH_COMMITTED_COST,
            bal.PRJ_RAW_COST,
            bal.PRJ_BILL_RAW_COST,
            bal.PRJ_BRDN_COST,
            bal.PRJ_BILL_BRDN_COST,
            bal.PRJ_REVENUE,
            to_number(null)                         PRJ_SUP_INV_COMMITTED_COST,
            to_number(null)                         PRJ_PO_COMMITTED_COST,
            to_number(null)                         PRJ_PR_COMMITTED_COST,
            to_number(null)                         PRJ_OTH_COMMITTED_COST,
            bal.POU_RAW_COST,
            bal.POU_BILL_RAW_COST,
            bal.POU_BRDN_COST,
            bal.POU_BILL_BRDN_COST,
            bal.POU_REVENUE,
            to_number(null)                         POU_SUP_INV_COMMITTED_COST,
            to_number(null)                         POU_PO_COMMITTED_COST,
            to_number(null)                         POU_PR_COMMITTED_COST,
            to_number(null)                         POU_OTH_COMMITTED_COST,
            bal.EOU_RAW_COST,
            bal.EOU_BILL_RAW_COST,
            bal.EOU_BRDN_COST,
            bal.EOU_BILL_BRDN_COST,
            to_number(null)                         EOU_SUP_INV_COMMITTED_COST,
            to_number(null)                         EOU_PO_COMMITTED_COST,
            to_number(null)                         EOU_PR_COMMITTED_COST,
            to_number(null)                         EOU_OTH_COMMITTED_COST,
            bal.G1_RAW_COST,
            bal.G1_BILL_RAW_COST,
            bal.G1_BRDN_COST,
            bal.G1_BILL_BRDN_COST,
            bal.G1_REVENUE,
            to_number(null)                         G1_SUP_INV_COMMITTED_COST,
            to_number(null)                         G1_PO_COMMITTED_COST,
            to_number(null)                         G1_PR_COMMITTED_COST,
            to_number(null)                         G1_OTH_COMMITTED_COST,
            bal.G2_RAW_COST,
            bal.G2_BILL_RAW_COST,
            bal.G2_BRDN_COST,
            bal.G2_BILL_BRDN_COST,
            bal.G2_REVENUE,
            to_number(null)                         G2_SUP_INV_COMMITTED_COST,
            to_number(null)                         G2_PO_COMMITTED_COST,
            to_number(null)                         G2_PR_COMMITTED_COST,
            to_number(null)                         G2_OTH_COMMITTED_COST,
            bal.QUANTITY,
            bal.BILL_QUANTITY
          from
            PJI_FP_TXN_ACCUM bal,
            (
            select
              distinct
              to_number(log.EVENT_OBJECT)          RBS_VERSION_ID,
              to_number(log.ATTRIBUTE1)            PROJECT_ID
            from
              PJI_PA_PROJ_EVENTS_LOG log
            where
              log.WORKER_ID = p_worker_id and
              log.EVENT_TYPE = 'RBS_ASSOC'
            ) log
          where
            l_extraction_type = 'INCREMENTAL' and
            bal.PROJECT_ID = log.PROJECT_ID
          union all                    -- newly associated RBSs for commitments
          select
            bal.TXN_ACCUM_HEADER_ID,
            to_number(null)                         RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            to_char(null)                           PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            log.RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            to_number(null)                         TXN_RAW_COST,
            to_number(null)                         TXN_BILL_RAW_COST,
            to_number(null)                         TXN_BRDN_COST,
            to_number(null)                         TXN_BILL_BRDN_COST,
            to_number(null)                         TXN_REVENUE,
            bal.TXN_SUP_INV_COMMITTED_COST,
            bal.TXN_PO_COMMITTED_COST,
            bal.TXN_PR_COMMITTED_COST,
            bal.TXN_OTH_COMMITTED_COST,
            to_number(null)                         PRJ_RAW_COST,
            to_number(null)                         PRJ_BILL_RAW_COST,
            to_number(null)                         PRJ_BRDN_COST,
            to_number(null)                         PRJ_BILL_BRDN_COST,
            to_number(null)                         PRJ_REVENUE,
            bal.PRJ_SUP_INV_COMMITTED_COST,
            bal.PRJ_PO_COMMITTED_COST,
            bal.PRJ_PR_COMMITTED_COST,
            bal.PRJ_OTH_COMMITTED_COST,
            to_number(null)                         POU_RAW_COST,
            to_number(null)                         POU_BILL_RAW_COST,
            to_number(null)                         POU_BRDN_COST,
            to_number(null)                         POU_BILL_BRDN_COST,
            to_number(null)                         POU_REVENUE,
            bal.POU_SUP_INV_COMMITTED_COST,
            bal.POU_PO_COMMITTED_COST,
            bal.POU_PR_COMMITTED_COST,
            bal.POU_OTH_COMMITTED_COST,
            to_number(null)                         EOU_RAW_COST,
            to_number(null)                         EOU_BILL_RAW_COST,
            to_number(null)                         EOU_BRDN_COST,
            to_number(null)                         EOU_BILL_BRDN_COST,
            bal.EOU_SUP_INV_COMMITTED_COST,
            bal.EOU_PO_COMMITTED_COST,
            bal.EOU_PR_COMMITTED_COST,
            bal.EOU_OTH_COMMITTED_COST,
            to_number(null)                         G1_RAW_COST,
            to_number(null)                         G1_BILL_RAW_COST,
            to_number(null)                         G1_BRDN_COST,
            to_number(null)                         G1_BILL_BRDN_COST,
            to_number(null)                         G1_REVENUE,
            bal.G1_SUP_INV_COMMITTED_COST,
            bal.G1_PO_COMMITTED_COST,
            bal.G1_PR_COMMITTED_COST,
            bal.G1_OTH_COMMITTED_COST,
            to_number(null)                         G2_RAW_COST,
            to_number(null)                         G2_BILL_RAW_COST,
            to_number(null)                         G2_BRDN_COST,
            to_number(null)                         G2_BILL_BRDN_COST,
            to_number(null)                         G2_REVENUE,
            bal.G2_SUP_INV_COMMITTED_COST,
            bal.G2_PO_COMMITTED_COST,
            bal.G2_PR_COMMITTED_COST,
            bal.G2_OTH_COMMITTED_COST,
            to_number(null)                         QUANTITY,
            to_number(null)                         BILL_QUANTITY
          from
            PJI_FP_TXN_ACCUM1 bal,
            (
            select
              distinct
              to_number(log.EVENT_OBJECT)          RBS_VERSION_ID,
              to_numbeR(log.ATTRIBUTE1)            PROJECT_ID
            from
              PJI_PA_PROJ_EVENTS_LOG log
            where
              log.WORKER_ID = p_worker_id and
              log.EVENT_TYPE = 'RBS_ASSOC'
            ) log
          where
            l_extraction_type = 'INCREMENTAL' and
            bal.PROJECT_ID = log.PROJECT_ID
          union all
          select /*+ ordered */            -- RBS change processing actuals
            bal.TXN_ACCUM_HEADER_ID,
            bal.RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            bal.PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            nvl(to_number(log.EVENT_OBJECT), -1)    RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            bal.TXN_RAW_COST,
            bal.TXN_BILL_RAW_COST,
            bal.TXN_BRDN_COST,
            bal.TXN_BILL_BRDN_COST,
            bal.TXN_REVENUE,
            to_number(null)                         TXN_SUP_INV_COMMITTED_COST,
            to_number(null)                         TXN_PO_COMMITTED_COST,
            to_number(null)                         TXN_PR_COMMITTED_COST,
            to_number(null)                         TXN_OTH_COMMITTED_COST,
            bal.PRJ_RAW_COST,
            bal.PRJ_BILL_RAW_COST,
            bal.PRJ_BRDN_COST,
            bal.PRJ_BILL_BRDN_COST,
            bal.PRJ_REVENUE,
            to_number(null)                         PRJ_SUP_INV_COMMITTED_COST,
            to_number(null)                         PRJ_PO_COMMITTED_COST,
            to_number(null)                         PRJ_PR_COMMITTED_COST,
            to_number(null)                         PRJ_OTH_COMMITTED_COST,
            bal.POU_RAW_COST,
            bal.POU_BILL_RAW_COST,
            bal.POU_BRDN_COST,
            bal.POU_BILL_BRDN_COST,
            bal.POU_REVENUE,
            to_number(null)                         POU_SUP_INV_COMMITTED_COST,
            to_number(null)                         POU_PO_COMMITTED_COST,
            to_number(null)                         POU_PR_COMMITTED_COST,
            to_number(null)                         POU_OTH_COMMITTED_COST,
            bal.EOU_RAW_COST,
            bal.EOU_BILL_RAW_COST,
            bal.EOU_BRDN_COST,
            bal.EOU_BILL_BRDN_COST,
            to_number(null)                         EOU_SUP_INV_COMMITTED_COST,
            to_number(null)                         EOU_PO_COMMITTED_COST,
            to_number(null)                         EOU_PR_COMMITTED_COST,
            to_number(null)                         EOU_OTH_COMMITTED_COST,
            bal.G1_RAW_COST,
            bal.G1_BILL_RAW_COST,
            bal.G1_BRDN_COST,
            bal.G1_BILL_BRDN_COST,
            bal.G1_REVENUE,
            to_number(null)                         G1_SUP_INV_COMMITTED_COST,
            to_number(null)                         G1_PO_COMMITTED_COST,
            to_number(null)                         G1_PR_COMMITTED_COST,
            to_number(null)                         G1_OTH_COMMITTED_COST,
            bal.G2_RAW_COST,
            bal.G2_BILL_RAW_COST,
            bal.G2_BRDN_COST,
            bal.G2_BILL_BRDN_COST,
            bal.G2_REVENUE,
            to_number(null)                         G2_SUP_INV_COMMITTED_COST,
            to_number(null)                         G2_PO_COMMITTED_COST,
            to_number(null)                         G2_PR_COMMITTED_COST,
            to_number(null)                         G2_OTH_COMMITTED_COST,
            bal.QUANTITY,
            bal.BILL_QUANTITY
          from
            PJI_PA_PROJ_EVENTS_LOG   log,
            PJI_PJP_PROJ_EXTR_STATUS stat,
            PJI_FP_TXN_ACCUM         bal
          where
            l_extraction_type      = 'RBS'           and
            log.WORKER_ID          = p_worker_id     and
            log.EVENT_TYPE         = 'RBS_PUSH'      and
            stat.PROJECT_ID        = log.ATTRIBUTE19 and
            stat.EXTRACTION_STATUS = 'I'             and
            bal.PROJECT_ID         = log.ATTRIBUTE19
          union all                        -- RBS change processing commitments
          select
            bal.TXN_ACCUM_HEADER_ID,
            to_number(null)                         RESOURCE_CLASS_ID,
            bal.PROJECT_ID,
            bal.PROJECT_ORG_ID,
            bal.PROJECT_ORGANIZATION_ID,
            to_char(null)                           PROJECT_TYPE_CLASS,
            nvl(bal.TASK_ID, -1)                    TASK_ID,
            bal.RECVR_PERIOD_TYPE,
            bal.RECVR_PERIOD_ID,
            nvl(to_number(log.EVENT_OBJECT), -1)    RBS_VERSION_ID,
            bal.TXN_CURRENCY_CODE,
            to_number(null)                         TXN_RAW_COST,
            to_number(null)                         TXN_BILL_RAW_COST,
            to_number(null)                         TXN_BRDN_COST,
            to_number(null)                         TXN_BILL_BRDN_COST,
            to_number(null)                         TXN_REVENUE,
            bal.TXN_SUP_INV_COMMITTED_COST,
            bal.TXN_PO_COMMITTED_COST,
            bal.TXN_PR_COMMITTED_COST,
            bal.TXN_OTH_COMMITTED_COST,
            to_number(null)                         PRJ_RAW_COST,
            to_number(null)                         PRJ_BILL_RAW_COST,
            to_number(null)                         PRJ_BRDN_COST,
            to_number(null)                         PRJ_BILL_BRDN_COST,
            to_number(null)                         PRJ_REVENUE,
            bal.PRJ_SUP_INV_COMMITTED_COST,
            bal.PRJ_PO_COMMITTED_COST,
            bal.PRJ_PR_COMMITTED_COST,
            bal.PRJ_OTH_COMMITTED_COST,
            to_number(null)                         POU_RAW_COST,
            to_number(null)                         POU_BILL_RAW_COST,
            to_number(null)                         POU_BRDN_COST,
            to_number(null)                         POU_BILL_BRDN_COST,
            to_number(null)                         POU_REVENUE,
            bal.POU_SUP_INV_COMMITTED_COST,
            bal.POU_PO_COMMITTED_COST,
            bal.POU_PR_COMMITTED_COST,
            bal.POU_OTH_COMMITTED_COST,
            to_number(null)                         EOU_RAW_COST,
            to_number(null)                         EOU_BILL_RAW_COST,
            to_number(null)                         EOU_BRDN_COST,
            to_number(null)                         EOU_BILL_BRDN_COST,
            bal.EOU_SUP_INV_COMMITTED_COST,
            bal.EOU_PO_COMMITTED_COST,
            bal.EOU_PR_COMMITTED_COST,
            bal.EOU_OTH_COMMITTED_COST,
            to_number(null)                         G1_RAW_COST,
            to_number(null)                         G1_BILL_RAW_COST,
            to_number(null)                         G1_BRDN_COST,
            to_number(null)                         G1_BILL_BRDN_COST,
            to_number(null)                         G1_REVENUE,
            bal.G1_SUP_INV_COMMITTED_COST,
            bal.G1_PO_COMMITTED_COST,
            bal.G1_PR_COMMITTED_COST,
            bal.G1_OTH_COMMITTED_COST,
            to_number(null)                         G2_RAW_COST,
            to_number(null)                         G2_BILL_RAW_COST,
            to_number(null)                         G2_BRDN_COST,
            to_number(null)                         G2_BILL_BRDN_COST,
            to_number(null)                         G2_REVENUE,
            bal.G2_SUP_INV_COMMITTED_COST,
            bal.G2_PO_COMMITTED_COST,
            bal.G2_PR_COMMITTED_COST,
            bal.G2_OTH_COMMITTED_COST,
            to_number(null)                         QUANTITY,
            to_number(null)                         BILL_QUANTITY
          from
            PJI_PA_PROJ_EVENTS_LOG   log,
            PJI_PJP_PROJ_EXTR_STATUS stat,
            PJI_FP_TXN_ACCUM1        bal
          where
            l_extraction_type      = 'RBS'           and
            log.WORKER_ID          = p_worker_id     and
            log.EVENT_TYPE         = 'RBS_PUSH'      and
            stat.PROJECT_ID        = log.ATTRIBUTE19 and
            stat.EXTRACTION_STATUS = 'I'             and
            bal.PROJECT_ID         = log.ATTRIBUTE19
            ) src1
          group by
            src1.TXN_ACCUM_HEADER_ID,
            src1.RESOURCE_CLASS_ID,
            src1.PROJECT_ID,
            src1.PROJECT_ORG_ID,
            src1.PROJECT_ORGANIZATION_ID,
            src1.PROJECT_TYPE_CLASS,
            src1.TASK_ID,
            src1.RECVR_PERIOD_TYPE,
            src1.RECVR_PERIOD_ID,
            src1.RBS_VERSION_ID,
            src1.TXN_CURRENCY_CODE
            ) src2
          ) src,
          PA_RBS_TXN_ACCUM_MAP     rbs,
          PJI_PJP_PROJ_BATCH_MAP   map,
          PJI_ORG_EXTR_INFO        info,
          PJI_PJP_WBS_HEADER       wbs_hdr,
          PA_PROJ_ELEMENT_VERSIONS ver,
          (
            select 1   INVERT_ID from dual
                                 where l_g1_currency_flag = 'Y' and    /* Added for Bug 8708651 */
                                       l_g1_currency_code is not null union all
            select 2   INVERT_ID from dual
                                 where l_g2_currency_flag = 'Y' and
                                       l_g2_currency_code is not null union all
            select 4   INVERT_ID from dual union all
            select 8   INVERT_ID from dual union all
            select 16  INVERT_ID from dual
                                 where l_txn_currency_flag = 'Y'
         -- select 32  INVERT_ID from dual  OMIT DETAIL SLICES FOR NOW
         --                      where l_g1_currency_code is not null union all
         -- select 64  INVERT_ID from dual
         --                      where l_g2_currency_flag = 'Y' and
         --                            l_g2_currency_code is not null union all
         -- select 128 INVERT_ID from dual union all
         -- select 256 INVERT_ID from dual
          ) invert
        where
          src.TXN_ACCUM_HEADER_ID     = rbs.TXN_ACCUM_HEADER_ID (+) and
          src.RBS_VERSION_ID          = rbs.STRUCT_VERSION_ID   (+) and
          map.WORKER_ID               = p_worker_id                 and
          src.PROJECT_ID              = map.PROJECT_ID              and
          src.PROJECT_ORG_ID          = info.ORG_ID                 and  /*5377133 */
          wbs_hdr.PLAN_VERSION_ID     = -1                          and
          src.PROJECT_ID              = wbs_hdr.PROJECT_ID          and
          ver.ELEMENT_VERSION_ID      = wbs_hdr.WBS_VERSION_ID
        ) src3
      group by
        src3.WORKER_ID,
        src3.TXN_ACCUM_HEADER_ID,
        src3.RESOURCE_CLASS_ID,
        src3.PROJECT_ID,
        src3.PROJECT_ORG_ID,
        src3.PROJECT_ORGANIZATION_ID,
        src3.PROJECT_TYPE_CLASS,
        src3.PROJECT_ELEMENT_ID,
        src3.TIME_ID,
        src3.PERIOD_TYPE_ID,
        src3.CALENDAR_TYPE,
        src3.RBS_AGGR_LEVEL,
        src3.WBS_ROLLUP_FLAG,
        src3.PRG_ROLLUP_FLAG,
        src3.DIFF_CURRENCY_CODE,
        src3.DIFF_ROWNUM,
        nvl(src3.CURRENCY_CODE, 'PJI$NULL'),
        src3.RBS_ELEMENT_ID,
        src3.RBS_VERSION_ID,
        src3.PLAN_VERSION_ID,
        src3.PLAN_TYPE_ID
      ) src,
      PA_RESOURCE_CLASSES_B cls
    where
      src.RESOURCE_CLASS_ID = cls.RESOURCE_CLASS_ID (+)
    group by
      src.WORKER_ID,
      src.TXN_ACCUM_HEADER_ID,
      src.PROJECT_ID,
      src.PROJECT_ORG_ID,
      src.PROJECT_ORGANIZATION_ID,
      src.PROJECT_ELEMENT_ID,
      src.TIME_ID,
      src.PERIOD_TYPE_ID,
      src.CALENDAR_TYPE,
      src.RBS_AGGR_LEVEL,
      src.WBS_ROLLUP_FLAG,
      src.PRG_ROLLUP_FLAG,
      src.CURR_RECORD_TYPE_ID,
      src.CURRENCY_CODE,
      src.RBS_ELEMENT_ID,
      src.RBS_VERSION_ID,
      src.PLAN_VERSION_ID,
      src.PLAN_TYPE_ID;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FP_SLICES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_AC_SLICES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_AC_SLICES (p_worker_id in number) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);


    l_txn_currency_flag varchar2(1);
    l_g2_currency_flag  varchar2(1);
    l_g1_currency_flag  varchar2(1);   /* Added for Bug 8708651 */

    l_g1_currency_code  varchar2(30);
    l_g2_currency_code  varchar2(30);

    l_plan_type_id      number;    -- Bug#5099574
    l_refresh_code      number;


  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_SLICES(p_worker_id);')) then
      return;
    end if;

   --  Bug#5099574  - Start

      l_plan_type_id     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'PLAN_TYPE_ID');
      l_refresh_code     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'REFRESH_CODE');

      if (l_plan_type_id = -1) then
        l_plan_type_id := null;
      end if;

    -- If the condtion is true then mark the process as completed and return
      if ( l_extraction_type='PARTIAL' and ( l_plan_type_id is not null  or bitand(l_refresh_code,1) <> 1) ) then
       PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_SLICES(p_worker_id);');
       commit;
       return;
      end if;

  --  Bug#5099574 - End

    if (l_extraction_type <> 'RBS') then

    select
      TXN_CURR_FLAG,
      GLOBAL_CURR2_FLAG,
      nvl(GLOBAL_CURR1_FLAG,'Y')   /* Added for Bug 8708651, NULL check added for 9062837 */
    into
      l_txn_currency_flag,
      l_g2_currency_flag,
      l_g1_currency_flag      /* Added for Bug 8708651 */
    from
      PJI_SYSTEM_SETTINGS;

    l_g1_currency_code := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
    l_g2_currency_code := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;

    insert into PJI_AC_AGGR_PJP0 pjp0_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_INVOICE_WRITE_OFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE
    )
    select
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      sum(CURR_RECORD_TYPE_ID)                     CURR_RECORD_TYPE_ID,
      nvl(CURRENCY_CODE, 'PJI$NULL')               CURRENCY_CODE,
      max(REVENUE)                                 REVENUE,
      max(INITIAL_FUNDING_AMOUNT)                  INITIAL_FUNDING_AMOUNT,
      max(INITIAL_FUNDING_COUNT)                   INITIAL_FUNDING_COUNT,
      max(ADDITIONAL_FUNDING_AMOUNT)               ADDITIONAL_FUNDING_AMOUNT,
      max(ADDITIONAL_FUNDING_COUNT)                ADDITIONAL_FUNDING_COUNT,
      max(CANCELLED_FUNDING_AMOUNT)                CANCELLED_FUNDING_AMOUNT,
      max(CANCELLED_FUNDING_COUNT)                 CANCELLED_FUNDING_COUNT,
      max(FUNDING_ADJUSTMENT_AMOUNT)               FUNDING_ADJUSTMENT_AMOUNT,
      max(FUNDING_ADJUSTMENT_COUNT)                FUNDING_ADJUSTMENT_COUNT,
      max(REVENUE_WRITEOFF)                        REVENUE_WRITEOFF,
      max(AR_INVOICE_AMOUNT)                       AR_INVOICE_AMOUNT,
      max(AR_INVOICE_COUNT)                        AR_INVOICE_COUNT,
      max(AR_CASH_APPLIED_AMOUNT)                  AR_CASH_APPLIED_AMOUNT,
      max(AR_INVOICE_WRITE_OFF_AMOUNT)             AR_INVOICE_WRITE_OFF_AMOUNT,
      max(AR_INVOICE_WRITEOFF_COUNT)               AR_INVOICE_WRITEOFF_COUNT,
      max(AR_CREDIT_MEMO_AMOUNT)                   AR_CREDIT_MEMO_AMOUNT,
      max(AR_CREDIT_MEMO_COUNT)                    AR_CREDIT_MEMO_COUNT,
      max(UNBILLED_RECEIVABLES)                    UNBILLED_RECEIVABLES,
      max(UNEARNED_REVENUE)                        UNEARNED_REVENUE,
      max(AR_UNAPPR_INVOICE_AMOUNT)                AR_UNAPPR_INVOICE_AMOUNT,
      max(AR_UNAPPR_INVOICE_COUNT)                 AR_UNAPPR_INVOICE_COUNT,
      max(AR_APPR_INVOICE_AMOUNT)                  AR_APPR_INVOICE_AMOUNT,
      max(AR_APPR_INVOICE_COUNT)                   AR_APPR_INVOICE_COUNT,
      max(AR_AMOUNT_DUE)                           AR_AMOUNT_DUE,
      max(AR_COUNT_DUE)                            AR_COUNT_DUE,
      max(AR_AMOUNT_OVERDUE)                       AR_AMOUNT_OVERDUE,
      max(AR_COUNT_OVERDUE)                        AR_COUNT_OVERDUE
    from
      (
      select /*+ ordered */
        p_worker_id                                WORKER_ID,
        src.PROJECT_ID,
        src.PROJECT_ORG_ID,
        map.PROJECT_ORGANIZATION_ID,
        decode(src.TASK_ID,
               -1, ver.PROJ_ELEMENT_ID,
               src.TASK_ID)                        PROJECT_ELEMENT_ID,
        src.PERIOD_ID                              TIME_ID,
        32                                         PERIOD_TYPE_ID,
        decode(src.PERIOD_TYPE,
               'ENT', 'E',
               'GL',  'G',
               'PA',  'P')                         CALENDAR_TYPE,
        'N'                                        WBS_ROLLUP_FLAG,
        'N'                                        PRG_ROLLUP_FLAG,
        invert.INVERT_ID                           CURR_RECORD_TYPE_ID,
        decode(invert.INVERT_ID,
               1,   l_g1_currency_code,
               2,   l_g2_currency_code,
               4,   src.PF_CURRENCY_CODE,
               8,   src.PRJ_CURRENCY_CODE,
               16,  src.TXN_CURRENCY_CODE,
               32,  l_g1_currency_code,
               64,  l_g2_currency_code,
               128, src.PF_CURRENCY_CODE,
               256, src.PRJ_CURRENCY_CODE)         DIFF_CURRENCY_CODE,
        DIFF_ROWNUM                                DIFF_ROWNUM,
        decode(invert.INVERT_ID,
               1,   l_g1_currency_code,
               2,   l_g2_currency_code,
               4,   src.PF_CURRENCY_CODE,
               8,   src.PRJ_CURRENCY_CODE,
               16,  src.TXN_CURRENCY_CODE,
               32,  src.TXN_CURRENCY_CODE,
               64,  src.TXN_CURRENCY_CODE,
               128, src.TXN_CURRENCY_CODE,
               256, src.TXN_CURRENCY_CODE)         CURRENCY_CODE,
        decode(invert.INVERT_ID,
               1,   src.G1_REVENUE,
               2,   src.G2_REVENUE,
               4,   src.POU_REVENUE,
               8,   src.PRJ_REVENUE,
               16,  src.TXN_REVENUE,
               32,  src.G1_REVENUE,
               64,  src.G2_REVENUE,
               128, src.POU_REVENUE,
               256, src.PRJ_REVENUE)               REVENUE,
        decode(invert.INVERT_ID,
               1,   src.G1_INITIAL_FUNDING_AMOUNT,
               2,   src.G2_INITIAL_FUNDING_AMOUNT,
               4,   src.POU_INITIAL_FUNDING_AMOUNT,
               8,   src.PRJ_INITIAL_FUNDING_AMOUNT,
               16,  src.TXN_INITIAL_FUNDING_AMOUNT,
               32,  src.G1_INITIAL_FUNDING_AMOUNT,
               64,  src.G2_INITIAL_FUNDING_AMOUNT,
               128, src.POU_INITIAL_FUNDING_AMOUNT,
               256, src.PRJ_INITIAL_FUNDING_AMOUNT)
                                                   INITIAL_FUNDING_AMOUNT,
        src.INITIAL_FUNDING_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_ADDITIONAL_FUNDING_AMOUNT,
               2,   src.G2_ADDITIONAL_FUNDING_AMOUNT,
               4,   src.POU_ADDITIONAL_FUNDING_AMOUNT,
               8,   src.PRJ_ADDITIONAL_FUNDING_AMOUNT,
               16,  src.TXN_ADDITIONAL_FUNDING_AMOUNT,
               32,  src.G1_ADDITIONAL_FUNDING_AMOUNT,
               64,  src.G2_ADDITIONAL_FUNDING_AMOUNT,
               128, src.POU_ADDITIONAL_FUNDING_AMOUNT,
               256, src.PRJ_ADDITIONAL_FUNDING_AMOUNT)
                                                   ADDITIONAL_FUNDING_AMOUNT,
        src.ADDITIONAL_FUNDING_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_CANCELLED_FUNDING_AMOUNT,
               2,   src.G2_CANCELLED_FUNDING_AMOUNT,
               4,   src.POU_CANCELLED_FUNDING_AMOUNT,
               8,   src.PRJ_CANCELLED_FUNDING_AMOUNT,
               16,  src.TXN_CANCELLED_FUNDING_AMOUNT,
               32,  src.G1_CANCELLED_FUNDING_AMOUNT,
               64,  src.G2_CANCELLED_FUNDING_AMOUNT,
               128, src.POU_CANCELLED_FUNDING_AMOUNT,
               256, src.PRJ_CANCELLED_FUNDING_AMOUNT)
                                                   CANCELLED_FUNDING_AMOUNT,
        src.CANCELLED_FUNDING_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_FUNDING_ADJUSTMENT_AMOUNT,
               2,   src.G2_FUNDING_ADJUSTMENT_AMOUNT,
               4,   src.POU_FUNDING_ADJUSTMENT_AMOUNT,
               8,   src.PRJ_FUNDING_ADJUSTMENT_AMOUNT,
               16,  src.TXN_FUNDING_ADJUSTMENT_AMOUNT,
               32,  src.G1_FUNDING_ADJUSTMENT_AMOUNT,
               64,  src.G2_FUNDING_ADJUSTMENT_AMOUNT,
               128, src.POU_FUNDING_ADJUSTMENT_AMOUNT,
               256, src.PRJ_FUNDING_ADJUSTMENT_AMOUNT)
                                                   FUNDING_ADJUSTMENT_AMOUNT,
        src.FUNDING_ADJUSTMENT_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_REVENUE_WRITEOFF,
               2,   src.G2_REVENUE_WRITEOFF,
               4,   src.POU_REVENUE_WRITEOFF,
               8,   src.PRJ_REVENUE_WRITEOFF,
               16,  src.TXN_REVENUE_WRITEOFF,
               32,  src.G1_REVENUE_WRITEOFF,
               64,  src.G2_REVENUE_WRITEOFF,
               128, src.POU_REVENUE_WRITEOFF,
               256, src.PRJ_REVENUE_WRITEOFF)      REVENUE_WRITEOFF,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_INVOICE_AMOUNT,
               2,   src.G2_AR_INVOICE_AMOUNT,
               4,   src.POU_AR_INVOICE_AMOUNT,
               8,   src.PRJ_AR_INVOICE_AMOUNT,
               16,  src.TXN_AR_INVOICE_AMOUNT,
               32,  src.G1_AR_INVOICE_AMOUNT,
               64,  src.G2_AR_INVOICE_AMOUNT,
               128, src.POU_AR_INVOICE_AMOUNT,
               256, src.PRJ_AR_INVOICE_AMOUNT)     AR_INVOICE_AMOUNT,
        src.AR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_CASH_APPLIED_AMOUNT,
               2,   src.G2_AR_CASH_APPLIED_AMOUNT,
               4,   src.POU_AR_CASH_APPLIED_AMOUNT,
               8,   src.PRJ_AR_CASH_APPLIED_AMOUNT,
               16,  src.TXN_AR_CASH_APPLIED_AMOUNT,
               32,  src.G1_AR_CASH_APPLIED_AMOUNT,
               64,  src.G2_AR_CASH_APPLIED_AMOUNT,
               128, src.POU_AR_CASH_APPLIED_AMOUNT,
               256, src.PRJ_AR_CASH_APPLIED_AMOUNT)
                                                   AR_CASH_APPLIED_AMOUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_INVOICE_WRITEOFF_AMOUNT,
               2,   src.G2_AR_INVOICE_WRITEOFF_AMOUNT,
               4,   src.POU_AR_INVOICE_WRITEOFF_AMOUNT,
               8,   src.PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
               16,  src.TXN_AR_INVOICE_WRITEOFF_AMOUNT,
               32,  src.G1_AR_INVOICE_WRITEOFF_AMOUNT,
               64,  src.G2_AR_INVOICE_WRITEOFF_AMOUNT,
               128, src.POU_AR_INVOICE_WRITEOFF_AMOUNT,
               256, src.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)
                                                   AR_INVOICE_WRITE_OFF_AMOUNT,
        src.AR_INVOICE_WRITEOFF_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_CREDIT_MEMO_AMOUNT,
               2,   src.G2_AR_CREDIT_MEMO_AMOUNT,
               4,   src.POU_AR_CREDIT_MEMO_AMOUNT,
               8,   src.PRJ_AR_CREDIT_MEMO_AMOUNT,
               16,  src.TXN_AR_CREDIT_MEMO_AMOUNT,
               32,  src.G1_AR_CREDIT_MEMO_AMOUNT,
               64,  src.G2_AR_CREDIT_MEMO_AMOUNT,
               128, src.POU_AR_CREDIT_MEMO_AMOUNT,
               256, src.PRJ_AR_CREDIT_MEMO_AMOUNT) AR_CREDIT_MEMO_AMOUNT,
        src.AR_CREDIT_MEMO_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_UNBILLED_RECEIVABLES,
               2,   src.G2_UNBILLED_RECEIVABLES,
               4,   src.POU_UNBILLED_RECEIVABLES,
               8,   src.PRJ_UNBILLED_RECEIVABLES,
               16,  src.TXN_UNBILLED_RECEIVABLES,
               32,  src.G1_UNBILLED_RECEIVABLES,
               64,  src.G2_UNBILLED_RECEIVABLES,
               128, src.POU_UNBILLED_RECEIVABLES,
               256, src.PRJ_UNBILLED_RECEIVABLES)  UNBILLED_RECEIVABLES,
        decode(invert.INVERT_ID,
               1,   src.G1_UNEARNED_REVENUE,
               2,   src.G2_UNEARNED_REVENUE,
               4,   src.POU_UNEARNED_REVENUE,
               8,   src.PRJ_UNEARNED_REVENUE,
               16,  src.TXN_UNEARNED_REVENUE,
               32,  src.G1_UNEARNED_REVENUE,
               64,  src.G2_UNEARNED_REVENUE,
               128, src.POU_UNEARNED_REVENUE,
               256, src.PRJ_UNEARNED_REVENUE)      UNEARNED_REVENUE,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_UNAPPR_INVOICE_AMOUNT,
               2,   src.G2_AR_UNAPPR_INVOICE_AMOUNT,
               4,   src.POU_AR_UNAPPR_INVOICE_AMOUNT,
               8,   src.PRJ_AR_UNAPPR_INVOICE_AMOUNT,
               16,  src.TXN_AR_UNAPPR_INVOICE_AMOUNT,
               32,  src.G1_AR_UNAPPR_INVOICE_AMOUNT,
               64,  src.G2_AR_UNAPPR_INVOICE_AMOUNT,
               128, src.POU_AR_UNAPPR_INVOICE_AMOUNT,
               256, src.PRJ_AR_UNAPPR_INVOICE_AMOUNT)
                                                   AR_UNAPPR_INVOICE_AMOUNT,
        src.AR_UNAPPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_APPR_INVOICE_AMOUNT,
               2,   src.G2_AR_APPR_INVOICE_AMOUNT,
               4,   src.POU_AR_APPR_INVOICE_AMOUNT,
               8,   src.PRJ_AR_APPR_INVOICE_AMOUNT,
               16,  src.TXN_AR_APPR_INVOICE_AMOUNT,
               32,  src.G1_AR_APPR_INVOICE_AMOUNT,
               64,  src.G2_AR_APPR_INVOICE_AMOUNT,
               128, src.POU_AR_APPR_INVOICE_AMOUNT,
               256, src.PRJ_AR_APPR_INVOICE_AMOUNT)
                                                   AR_APPR_INVOICE_AMOUNT,
        src.AR_APPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_AMOUNT_DUE,
               2,   src.G2_AR_AMOUNT_DUE,
               4,   src.POU_AR_AMOUNT_DUE,
               8,   src.PRJ_AR_AMOUNT_DUE,
               16,  src.TXN_AR_AMOUNT_DUE,
               32,  src.G1_AR_AMOUNT_DUE,
               64,  src.G2_AR_AMOUNT_DUE,
               128, src.POU_AR_AMOUNT_DUE,
               256, src.PRJ_AR_AMOUNT_DUE)         AR_AMOUNT_DUE,
        src.AR_COUNT_DUE,
        decode(invert.INVERT_ID,
               1,   src.G1_AR_AMOUNT_OVERDUE,
               2,   src.G2_AR_AMOUNT_OVERDUE,
               4,   src.POU_AR_AMOUNT_OVERDUE,
               8,   src.PRJ_AR_AMOUNT_OVERDUE,
               16,  src.TXN_AR_AMOUNT_OVERDUE,
               32,  src.G1_AR_AMOUNT_OVERDUE,
               64,  src.G2_AR_AMOUNT_OVERDUE,
               128, src.POU_AR_AMOUNT_OVERDUE,
               256, src.PRJ_AR_AMOUNT_OVERDUE)     AR_AMOUNT_OVERDUE,
        src.AR_COUNT_OVERDUE
      from
        (
        select
          ROWNUM                                DIFF_ROWNUM,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          TASK_ID,
          PERIOD_TYPE,
          PERIOD_ID,
          PF_CURRENCY_CODE,
          PRJ_CURRENCY_CODE,
          TXN_CURRENCY_CODE,
          TXN_REVENUE,
          TXN_FUNDING,
          TXN_INITIAL_FUNDING_AMOUNT,
          TXN_ADDITIONAL_FUNDING_AMOUNT,
          TXN_CANCELLED_FUNDING_AMOUNT,
          TXN_FUNDING_ADJUSTMENT_AMOUNT,
          TXN_REVENUE_WRITEOFF,
          TXN_AR_INVOICE_AMOUNT,
          TXN_AR_CASH_APPLIED_AMOUNT,
          TXN_AR_INVOICE_WRITEOFF_AMOUNT,
          TXN_AR_CREDIT_MEMO_AMOUNT,
          TXN_UNBILLED_RECEIVABLES,
          TXN_UNEARNED_REVENUE,
          TXN_AR_UNAPPR_INVOICE_AMOUNT,
          TXN_AR_APPR_INVOICE_AMOUNT,
          TXN_AR_AMOUNT_DUE,
          TXN_AR_AMOUNT_OVERDUE,
          PRJ_REVENUE,
          PRJ_FUNDING,
          PRJ_INITIAL_FUNDING_AMOUNT,
          PRJ_ADDITIONAL_FUNDING_AMOUNT,
          PRJ_CANCELLED_FUNDING_AMOUNT,
          PRJ_FUNDING_ADJUSTMENT_AMOUNT,
          PRJ_REVENUE_WRITEOFF,
          PRJ_AR_INVOICE_AMOUNT,
          PRJ_AR_CASH_APPLIED_AMOUNT,
          PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
          PRJ_AR_CREDIT_MEMO_AMOUNT,
          PRJ_UNBILLED_RECEIVABLES,
          PRJ_UNEARNED_REVENUE,
          PRJ_AR_UNAPPR_INVOICE_AMOUNT,
          PRJ_AR_APPR_INVOICE_AMOUNT,
          PRJ_AR_AMOUNT_DUE,
          PRJ_AR_AMOUNT_OVERDUE,
          POU_REVENUE,
          POU_FUNDING,
          POU_INITIAL_FUNDING_AMOUNT,
          POU_ADDITIONAL_FUNDING_AMOUNT,
          POU_CANCELLED_FUNDING_AMOUNT,
          POU_FUNDING_ADJUSTMENT_AMOUNT,
          POU_REVENUE_WRITEOFF,
          POU_AR_INVOICE_AMOUNT,
          POU_AR_CASH_APPLIED_AMOUNT,
          POU_AR_INVOICE_WRITEOFF_AMOUNT,
          POU_AR_CREDIT_MEMO_AMOUNT,
          POU_UNBILLED_RECEIVABLES,
          POU_UNEARNED_REVENUE,
          POU_AR_UNAPPR_INVOICE_AMOUNT,
          POU_AR_APPR_INVOICE_AMOUNT,
          POU_AR_AMOUNT_DUE,
          POU_AR_AMOUNT_OVERDUE,
          INITIAL_FUNDING_COUNT,
          ADDITIONAL_FUNDING_COUNT,
          CANCELLED_FUNDING_COUNT,
          FUNDING_ADJUSTMENT_COUNT,
          AR_INVOICE_COUNT,
          AR_CASH_APPLIED_COUNT,
          AR_INVOICE_WRITEOFF_COUNT,
          AR_CREDIT_MEMO_COUNT,
          AR_UNAPPR_INVOICE_COUNT,
          AR_APPR_INVOICE_COUNT,
          AR_COUNT_DUE,
          AR_COUNT_OVERDUE,
          G1_REVENUE,
          G1_FUNDING,
          G1_INITIAL_FUNDING_AMOUNT,
          G1_ADDITIONAL_FUNDING_AMOUNT,
          G1_CANCELLED_FUNDING_AMOUNT,
          G1_FUNDING_ADJUSTMENT_AMOUNT,
          G1_REVENUE_WRITEOFF,
          G1_AR_INVOICE_AMOUNT,
          G1_AR_CASH_APPLIED_AMOUNT,
          G1_AR_INVOICE_WRITEOFF_AMOUNT,
          G1_AR_CREDIT_MEMO_AMOUNT,
          G1_UNBILLED_RECEIVABLES,
          G1_UNEARNED_REVENUE,
          G1_AR_UNAPPR_INVOICE_AMOUNT,
          G1_AR_APPR_INVOICE_AMOUNT,
          G1_AR_AMOUNT_DUE,
          G1_AR_AMOUNT_OVERDUE,
          G2_REVENUE,
          G2_FUNDING,
          G2_INITIAL_FUNDING_AMOUNT,
          G2_ADDITIONAL_FUNDING_AMOUNT,
          G2_CANCELLED_FUNDING_AMOUNT,
          G2_FUNDING_ADJUSTMENT_AMOUNT,
          G2_REVENUE_WRITEOFF,
          G2_AR_INVOICE_AMOUNT,
          G2_AR_CASH_APPLIED_AMOUNT,
          G2_AR_INVOICE_WRITEOFF_AMOUNT,
          G2_AR_CREDIT_MEMO_AMOUNT,
          G2_UNBILLED_RECEIVABLES,
          G2_UNEARNED_REVENUE,
          G2_AR_UNAPPR_INVOICE_AMOUNT,
          G2_AR_APPR_INVOICE_AMOUNT,
          G2_AR_AMOUNT_DUE,
          G2_AR_AMOUNT_OVERDUE
        from
          (
        select /*+ ordered */
          src.PROJECT_ID,
          src.PROJECT_ORG_ID,
          src.PROJECT_ORGANIZATION_ID,
          nvl(src.TASK_ID, -1)                  TASK_ID,
          src.PERIOD_TYPE,
          src.PERIOD_ID,
          info.PF_CURRENCY_CODE,
          prj.PROJECT_CURRENCY_CODE             PRJ_CURRENCY_CODE,
          src.TXN_CURRENCY_CODE,
          sum(src.TXN_REVENUE)                  TXN_REVENUE,
          sum(src.TXN_FUNDING)                  TXN_FUNDING,
          sum(src.TXN_INITIAL_FUNDING_AMOUNT)   TXN_INITIAL_FUNDING_AMOUNT,
          sum(src.TXN_ADDITIONAL_FUNDING_AMOUNT)TXN_ADDITIONAL_FUNDING_AMOUNT,
          sum(src.TXN_CANCELLED_FUNDING_AMOUNT) TXN_CANCELLED_FUNDING_AMOUNT,
          sum(src.TXN_FUNDING_ADJUSTMENT_AMOUNT)TXN_FUNDING_ADJUSTMENT_AMOUNT,
          sum(src.TXN_REVENUE_WRITEOFF)         TXN_REVENUE_WRITEOFF,
          sum(src.TXN_AR_INVOICE_AMOUNT)        TXN_AR_INVOICE_AMOUNT,
          sum(src.TXN_AR_CASH_APPLIED_AMOUNT)   TXN_AR_CASH_APPLIED_AMOUNT,
          sum(src.TXN_AR_INVOICE_WRITEOFF_AMOUNT)
                                                TXN_AR_INVOICE_WRITEOFF_AMOUNT,
          sum(src.TXN_AR_CREDIT_MEMO_AMOUNT)    TXN_AR_CREDIT_MEMO_AMOUNT,
          sum(src.TXN_UNBILLED_RECEIVABLES)     TXN_UNBILLED_RECEIVABLES,
          sum(src.TXN_UNEARNED_REVENUE)         TXN_UNEARNED_REVENUE,
          sum(src.TXN_AR_UNAPPR_INVOICE_AMOUNT) TXN_AR_UNAPPR_INVOICE_AMOUNT,
          sum(src.TXN_AR_APPR_INVOICE_AMOUNT)   TXN_AR_APPR_INVOICE_AMOUNT,
          sum(src.TXN_AR_AMOUNT_DUE)            TXN_AR_AMOUNT_DUE,
          sum(src.TXN_AR_AMOUNT_OVERDUE)        TXN_AR_AMOUNT_OVERDUE,
          sum(src.PRJ_REVENUE)                  PRJ_REVENUE,
          sum(src.PRJ_FUNDING)                  PRJ_FUNDING,
          sum(src.PRJ_INITIAL_FUNDING_AMOUNT)   PRJ_INITIAL_FUNDING_AMOUNT,
          sum(src.PRJ_ADDITIONAL_FUNDING_AMOUNT)PRJ_ADDITIONAL_FUNDING_AMOUNT,
          sum(src.PRJ_CANCELLED_FUNDING_AMOUNT) PRJ_CANCELLED_FUNDING_AMOUNT,
          sum(src.PRJ_FUNDING_ADJUSTMENT_AMOUNT)PRJ_FUNDING_ADJUSTMENT_AMOUNT,
          sum(src.PRJ_REVENUE_WRITEOFF)         PRJ_REVENUE_WRITEOFF,
          sum(src.PRJ_AR_INVOICE_AMOUNT)        PRJ_AR_INVOICE_AMOUNT,
          sum(src.PRJ_AR_CASH_APPLIED_AMOUNT)   PRJ_AR_CASH_APPLIED_AMOUNT,
          sum(src.PRJ_AR_INVOICE_WRITEOFF_AMOUNT)
                                                PRJ_AR_INVOICE_WRITEOFF_AMOUNT,
          sum(src.PRJ_AR_CREDIT_MEMO_AMOUNT)    PRJ_AR_CREDIT_MEMO_AMOUNT,
          sum(src.PRJ_UNBILLED_RECEIVABLES)     PRJ_UNBILLED_RECEIVABLES,
          sum(src.PRJ_UNEARNED_REVENUE)         PRJ_UNEARNED_REVENUE,
          sum(src.PRJ_AR_UNAPPR_INVOICE_AMOUNT) PRJ_AR_UNAPPR_INVOICE_AMOUNT,
          sum(src.PRJ_AR_APPR_INVOICE_AMOUNT)   PRJ_AR_APPR_INVOICE_AMOUNT,
          sum(src.PRJ_AR_AMOUNT_DUE)            PRJ_AR_AMOUNT_DUE,
          sum(src.PRJ_AR_AMOUNT_OVERDUE)        PRJ_AR_AMOUNT_OVERDUE,
          sum(src.POU_REVENUE)                  POU_REVENUE,
          sum(src.POU_FUNDING)                  POU_FUNDING,
          sum(src.POU_INITIAL_FUNDING_AMOUNT)   POU_INITIAL_FUNDING_AMOUNT,
          sum(src.POU_ADDITIONAL_FUNDING_AMOUNT)POU_ADDITIONAL_FUNDING_AMOUNT,
          sum(src.POU_CANCELLED_FUNDING_AMOUNT) POU_CANCELLED_FUNDING_AMOUNT,
          sum(src.POU_FUNDING_ADJUSTMENT_AMOUNT)POU_FUNDING_ADJUSTMENT_AMOUNT,
          sum(src.POU_REVENUE_WRITEOFF)         POU_REVENUE_WRITEOFF,
          sum(src.POU_AR_INVOICE_AMOUNT)        POU_AR_INVOICE_AMOUNT,
          sum(src.POU_AR_CASH_APPLIED_AMOUNT)   POU_AR_CASH_APPLIED_AMOUNT,
          sum(src.POU_AR_INVOICE_WRITEOFF_AMOUNT)
                                                POU_AR_INVOICE_WRITEOFF_AMOUNT,
          sum(src.POU_AR_CREDIT_MEMO_AMOUNT)    POU_AR_CREDIT_MEMO_AMOUNT,
          sum(src.POU_UNBILLED_RECEIVABLES)     POU_UNBILLED_RECEIVABLES,
          sum(src.POU_UNEARNED_REVENUE)         POU_UNEARNED_REVENUE,
          sum(src.POU_AR_UNAPPR_INVOICE_AMOUNT) POU_AR_UNAPPR_INVOICE_AMOUNT,
          sum(src.POU_AR_APPR_INVOICE_AMOUNT)   POU_AR_APPR_INVOICE_AMOUNT,
          sum(src.POU_AR_AMOUNT_DUE)            POU_AR_AMOUNT_DUE,
          sum(src.POU_AR_AMOUNT_OVERDUE)        POU_AR_AMOUNT_OVERDUE,
          sum(src.INITIAL_FUNDING_COUNT)        INITIAL_FUNDING_COUNT,
          sum(src.ADDITIONAL_FUNDING_COUNT)     ADDITIONAL_FUNDING_COUNT,
          sum(src.CANCELLED_FUNDING_COUNT)      CANCELLED_FUNDING_COUNT,
          sum(src.FUNDING_ADJUSTMENT_COUNT)     FUNDING_ADJUSTMENT_COUNT,
          sum(src.AR_INVOICE_COUNT)             AR_INVOICE_COUNT,
          sum(src.AR_CASH_APPLIED_COUNT)        AR_CASH_APPLIED_COUNT,
          sum(src.AR_INVOICE_WRITEOFF_COUNT)    AR_INVOICE_WRITEOFF_COUNT,
          sum(src.AR_CREDIT_MEMO_COUNT)         AR_CREDIT_MEMO_COUNT,
          sum(src.AR_UNAPPR_INVOICE_COUNT)      AR_UNAPPR_INVOICE_COUNT,
          sum(src.AR_APPR_INVOICE_COUNT)        AR_APPR_INVOICE_COUNT,
          sum(src.AR_COUNT_DUE)                 AR_COUNT_DUE,
          sum(src.AR_COUNT_OVERDUE)             AR_COUNT_OVERDUE,
          sum(src.G1_REVENUE)                   G1_REVENUE,
          sum(src.G1_FUNDING)                   G1_FUNDING,
          sum(src.G1_INITIAL_FUNDING_AMOUNT)    G1_INITIAL_FUNDING_AMOUNT,
          sum(src.G1_ADDITIONAL_FUNDING_AMOUNT) G1_ADDITIONAL_FUNDING_AMOUNT,
          sum(src.G1_CANCELLED_FUNDING_AMOUNT)  G1_CANCELLED_FUNDING_AMOUNT,
          sum(src.G1_FUNDING_ADJUSTMENT_AMOUNT) G1_FUNDING_ADJUSTMENT_AMOUNT,
          sum(src.G1_REVENUE_WRITEOFF)          G1_REVENUE_WRITEOFF,
          sum(src.G1_AR_INVOICE_AMOUNT)         G1_AR_INVOICE_AMOUNT,
          sum(src.G1_AR_CASH_APPLIED_AMOUNT)    G1_AR_CASH_APPLIED_AMOUNT,
          sum(src.G1_AR_INVOICE_WRITEOFF_AMOUNT)G1_AR_INVOICE_WRITEOFF_AMOUNT,
          sum(src.G1_AR_CREDIT_MEMO_AMOUNT)     G1_AR_CREDIT_MEMO_AMOUNT,
          sum(src.G1_UNBILLED_RECEIVABLES)      G1_UNBILLED_RECEIVABLES,
          sum(src.G1_UNEARNED_REVENUE)          G1_UNEARNED_REVENUE,
          sum(src.G1_AR_UNAPPR_INVOICE_AMOUNT)  G1_AR_UNAPPR_INVOICE_AMOUNT,
          sum(src.G1_AR_APPR_INVOICE_AMOUNT)    G1_AR_APPR_INVOICE_AMOUNT,
          sum(src.G1_AR_AMOUNT_DUE)             G1_AR_AMOUNT_DUE,
          sum(src.G1_AR_AMOUNT_OVERDUE)         G1_AR_AMOUNT_OVERDUE,
          sum(src.G2_REVENUE)                   G2_REVENUE,
          sum(src.G2_FUNDING)                   G2_FUNDING,
          sum(src.G2_INITIAL_FUNDING_AMOUNT)    G2_INITIAL_FUNDING_AMOUNT,
          sum(src.G2_ADDITIONAL_FUNDING_AMOUNT) G2_ADDITIONAL_FUNDING_AMOUNT,
          sum(src.G2_CANCELLED_FUNDING_AMOUNT)  G2_CANCELLED_FUNDING_AMOUNT,
          sum(src.G2_FUNDING_ADJUSTMENT_AMOUNT) G2_FUNDING_ADJUSTMENT_AMOUNT,
          sum(src.G2_REVENUE_WRITEOFF)          G2_REVENUE_WRITEOFF,
          sum(src.G2_AR_INVOICE_AMOUNT)         G2_AR_INVOICE_AMOUNT,
          sum(src.G2_AR_CASH_APPLIED_AMOUNT)    G2_AR_CASH_APPLIED_AMOUNT,
          sum(src.G2_AR_INVOICE_WRITEOFF_AMOUNT)G2_AR_INVOICE_WRITEOFF_AMOUNT,
          sum(src.G2_AR_CREDIT_MEMO_AMOUNT)     G2_AR_CREDIT_MEMO_AMOUNT,
          sum(src.G2_UNBILLED_RECEIVABLES)      G2_UNBILLED_RECEIVABLES,
          sum(src.G2_UNEARNED_REVENUE)          G2_UNEARNED_REVENUE,
          sum(src.G2_AR_UNAPPR_INVOICE_AMOUNT)  G2_AR_UNAPPR_INVOICE_AMOUNT,
          sum(src.G2_AR_APPR_INVOICE_AMOUNT)    G2_AR_APPR_INVOICE_AMOUNT,
          sum(src.G2_AR_AMOUNT_DUE)             G2_AR_AMOUNT_DUE,
          sum(src.G2_AR_AMOUNT_OVERDUE)         G2_AR_AMOUNT_OVERDUE
        from
          PJI_PJP_RMAP_ACR  src_r,
          PJI_FM_AGGR_ACT4  src,
          PA_PROJECTS_ALL   prj,
          PJI_ORG_EXTR_INFO info
        where
          src_r.WORKER_ID     = p_worker_id          and
          src.ROWID           = src_r.STG_ROWID      and
          src.PROJECT_ID      = prj.PROJECT_ID       and
          prj.ORG_ID          = info.ORG_ID          /*5377133 */
        group by
          src.PROJECT_ID,
          src.PROJECT_ORG_ID,
          src.PROJECT_ORGANIZATION_ID,
          nvl(src.TASK_ID, -1),
          src.PERIOD_TYPE,
          src.PERIOD_ID,
          info.PF_CURRENCY_CODE,
          prj.PROJECT_CURRENCY_CODE,
          src.TXN_CURRENCY_CODE
          )
        )                        src,
        PJI_PJP_PROJ_BATCH_MAP   map,
        PJI_PJP_WBS_HEADER       wbs_hdr,
        PA_PROJ_ELEMENT_VERSIONS ver,
        (
          select 1   INVERT_ID from dual
                               where l_g1_currency_flag = 'Y' and    /* Added for Bug 8708651 */
                                     l_g1_currency_code is not null union all
          select 2   INVERT_ID from dual
                               where l_g2_currency_flag = 'Y' and
                                     l_g2_currency_code is not null union all
          select 4   INVERT_ID from dual union all
          select 8   INVERT_ID from dual union all
          select 16  INVERT_ID from dual
                               where l_txn_currency_flag = 'Y'
       -- select 32  INVERT_ID from dual  OMIT DETAIL SLICES FOR NOW
       --                      where l_g1_currency_code is not null union all
       -- select 64  INVERT_ID from dual
       --                      where l_g2_currency_flag = 'Y' and
       --                            l_g2_currency_code is not null union all
       -- select 128 INVERT_ID from dual union all
       -- select 256 INVERT_ID from dual
        ) invert
      where
        map.WORKER_ID           = p_worker_id            and
        src.PROJECT_ID          = map.PROJECT_ID         and
        wbs_hdr.PLAN_VERSION_ID = -1                     and
        src.PROJECT_ID          = wbs_hdr.PROJECT_ID     and
        ver.ELEMENT_VERSION_ID  = wbs_hdr.WBS_VERSION_ID
      )
    group by
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      DIFF_CURRENCY_CODE,
      DIFF_ROWNUM,
      nvl(CURRENCY_CODE, 'PJI$NULL');

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_AC_SLICES;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_PROJECTS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_PROJECTS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_last_update_login number;

    l_return_status   varchar2(255) := FND_API.G_RET_STS_SUCCESS;
    l_msg_data        varchar2(2000);
    l_err_msg         VARCHAR2(100):= 'Error in PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PROJECTS -> PJI_FM_PLAN_MAINT.POPULATE_FIN8';

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PROJECTS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    update PA_PROJECTS_ALL
    set    PJI_SOURCE_FLAG   = 'Y',
           LAST_UPDATE_DATE  = l_last_update_date,
           LAST_UPDATED_BY   = l_last_updated_by,
           LAST_UPDATE_LOGIN = l_last_update_login
    where  nvl(PJI_SOURCE_FLAG, 'X') <> 'Y' and
           PROJECT_ID in (select distinct
                                 PROJECT_ID
                          from   PJI_FP_AGGR_PJP0
                          where  WORKER_ID = p_worker_id
                          union
                          select distinct
                                 PROJECT_ID
                          from   PJI_AC_AGGR_PJP0
                          where  WORKER_ID = p_worker_id);

    if (l_extraction_type = 'PARTIAL' or
        l_extraction_type = 'RBS') then

      update PJI_PJP_PROJ_BATCH_MAP
      set    PJI_PROJECT_STATUS = 'Y'
      where  WORKER_ID = p_worker_id and
             PJI_PROJECT_STATUS is null;

    elsif (l_extraction_type = 'FULL' or
           l_extraction_type = 'INCREMENTAL') then

/*bug#5349102 added the check for FIN8 */
      update PJI_PJP_PROJ_BATCH_MAP
      set    PJI_PROJECT_STATUS = 'Y'
      where  WORKER_ID = p_worker_id and
             PJI_PROJECT_STATUS is null and
             PROJECT_ID in (select distinct
                                   PROJECT_ID
                            from   PJI_FP_AGGR_PJP0
                            where  WORKER_ID = p_worker_id
                            union
                            select distinct
                                   PROJECT_ID
                            from   PJI_AC_AGGR_PJP0
                            where  WORKER_ID = p_worker_id
                            union
                            select distinct
                                   PROJECT_ID
                            from pji_fm_aggr_fin8
                            ) and
             PROJECT_ID in (select PROJECT_ID
                            from   PA_PROJECTS_ALL
                            where  STRUCTURE_SHARING_CODE = 'SHARE_FULL');

    end if;

    if (l_extraction_type = 'INCREMENTAL') then

      update PJI_PJP_PROJ_BATCH_MAP map
      set    map.EXTRACTION_TYPE = 'M'
      where  map.WORKER_ID = p_worker_id and
             map.PROJECT_ID in (select fin7.PROJECT_ID
                                from   PJI_PJP_RMAP_FPR fin7_r,
                                       PJI_FM_AGGR_FIN7 fin7
                                where  fin7_r.WORKER_ID = p_worker_id and
                                       fin7_r.RECORD_TYPE = 'M' and
                                       fin7.ROWID = fin7_r.STG_ROWID);

      update PJI_PJP_PROJ_BATCH_MAP map
      set    map.EXTRACTION_TYPE = 'M'
      where  map.WORKER_ID = p_worker_id and
             map.PROJECT_ID not in (select cmt.PROJECT_ID
                                    from   PA_COMMITMENT_TXNS cmt);

    end if;


    --
    -- Dev notes: Sadiq 21-Oct-2005
    --
    -- Populate fin8 was moved from get_planres_actuals to mark_extracted_projects
    --   to avoid populating it multiple times in case of a failure in
    --   proj perf/progress integration apis that can cause the step to run
    --   again. Also, use of savepoint to populate fin8 on a project-by-project basis
    --   was considered but not chosen as this solution will not scale. Further this
    --   step (mark extr proj) has relatively less processing compared to other steps
    --   and is a good place to perform this transaction.
    --
    -- This change needs to be kept in mind when performing changes to sumz (adding
    --   new steps or changing sequences) programs in future.
    --

    PJI_FM_PLAN_MAINT.POPULATE_FIN8 (p_worker_id       => p_worker_id,
                                     p_extraction_type => l_extraction_type,
                                     x_return_status   => l_return_status,
                                     x_msg_data        => l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      dbms_standard.raise_application_error(-20105, l_err_msg);
    END IF;


    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PROJECTS(p_worker_id);');

    commit;

  end MARK_EXTRACTED_PROJECTS;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_FP_CUST_SLICES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
procedure AGGREGATE_FP_CUST_SLICES (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_plan_type_id    number;   --  Bug#5099574
    l_refresh_code    number;
    l_workplan_type_id number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');
    l_refresh_code     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'REFRESH_CODE');  -- Bug#5099574

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_CUST_SLICES(p_worker_id);')) then
      return;
    end if;

    l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                      (l_process, 'PLAN_TYPE_ID');

    if (l_plan_type_id = -1) then
      l_plan_type_id := null;
    end if;

      if  (l_extraction_type ='PARTIAL') then  -- Partial Refresh Performance Improvement

      --  Bug#  5208322  :  the workplan plan_type_id is stored in  l_workplan_type_id
      begin
      SELECT fin_plan_type_id into l_workplan_type_id
      FROM pa_fin_plan_types_b
      WHERE use_for_workplan_flag = 'Y';
      exception
      when no_data_found then
      l_workplan_type_id := NULL;
      end;


      INSERT INTO pji_fm_extr_plnver3_t
      (worker_id,project_id,plan_version_id,time_phased_type_code)
      select
      map.worker_id,bv.project_id,bv.budget_version_id,
      nvl(fpo.all_time_phased_code,nvl(fpo.cost_time_phased_code,fpo.revenue_time_phased_code)) time_phased_code
      from
      PJI_PJP_PROJ_BATCH_MAP map,
      PA_PROJ_FP_OPTIONS     fpo,
      PA_BUDGET_VERSIONS     bv
      where
      map.WORKER_ID    = p_worker_id               and
      fpo.FIN_PLAN_TYPE_ID  = nvl(l_plan_type_id,fpo.FIN_PLAN_TYPE_ID) and
      fpo.PROJECT_ID      = map.PROJECT_ID            and
      bv.PROJECT_ID      = map.PROJECT_ID            and
      bv.BUDGET_VERSION_ID  = fpo.FIN_PLAN_VERSION_ID   and
      (
          'Y' IN    -- Bug#5099574  Pull Reversals for CB / CO if refresh_code < 62 . Else pull for all plans ids >0 if refresh_code>=62
        (
            Select decode(
              bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
                decode(  bitand(l_refresh_code,g_cb_plans),g_cb_plans,
                decode(decode(bv.baselined_date, NULL, 'N', 'Y')||bv.current_flag,'YY', 'Y', 'N'),'X')) from dual
           UNION  ALL
            Select decode(
              bitand(l_refresh_code,g_all_plans),g_all_plans,'Y',
              decode( bitand(l_refresh_code,g_co_plans),g_co_plans,bv.current_original_flag,'X')) from dual
        )
      OR    -- Bug#5099574  Pull Reversals for Fin plan Working Versions when l_refresh_code=16,30. ignore if  l_refresh_code>=62
        (
         bv.BUDGET_STATUS_CODE in ('W','S')      and
         fpo.FIN_PLAN_TYPE_ID <> l_workplan_type_id    and                -- Bug#  5208322
         DECODE(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',DECODE(BITAND(l_refresh_code,g_wk_plans),g_wk_plans,'Y','N'))='Y'
         )
      OR    --Pull Reversals for Work plan Working Versions / LPub Vers / Baselined Versions when l_refresh_code=2,8,16,30. ignore if  l_refresh_code>=62
      EXISTS   ( select 1 from PA_PROJ_ELEM_VER_STRUCTURE  ppevs where
         bv.FIN_PLAN_TYPE_ID          = l_workplan_type_id        and    -- Bug#  5208322
         bv.PROJECT_STRUCTURE_VERSION_ID  = ppevs.ELEMENT_VERSION_ID  and
          (
          decode(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',
                        decode(BITAND(l_refresh_code,g_lp_plans),g_lp_plans,LATEST_EFF_PUBLISHED_FLAG,'N'))='Y'
          or
          decode(BITAND(l_refresh_code,g_all_plans),g_all_plans,'N',
                        decode(BITAND(l_refresh_code,g_wk_plans),g_wk_plans,STATUS_CODE,'N'))='STRUCTURE_WORKING'
                                    or
              decode(BITAND(l_refresh_code,g_all_plans ),g_all_plans ,'N',
                         decode(BITAND(l_refresh_code,g_cb_plans),g_cb_plans,NVL2(CURRENT_BASELINE_DATE,'Y','N'),'N')) ='Y'

          )
        )
      )
    UNION ALL --Pull Reversals for Actuals , CB,CO  when l_refresh_code=-1,-3,-4
      select
      map.worker_id,map.project_id,  plan_version_id,  'G'  time_phased_code
      from
      PJI_PJP_PROJ_BATCH_MAP map,
          (
      select decode (bitand (l_refresh_code,1),1,-1,-999) plan_version_id from dual  where l_plan_type_id is null
      union all
      select decode (bitand (l_refresh_code,g_cb_plans),g_cb_plans,-3,-999) plan_version_id  from dual
      union all
      select decode (bitand (l_refresh_code,g_co_plans),g_co_plans,-4,-999) plan_version_id  from dual
          )
      where map.worker_id=p_worker_id;


      end if;    -- Partial Refresh Performance Improvement


    insert into PJI_FP_AGGR_PJP1 pjp1_i
    (
      WORKER_ID,
      RECORD_TYPE,
      PRG_LEVEL,
      LINE_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      PLAN_TYPE_CODE,
      RAW_COST,
      BRDN_COST,
      REVENUE,
      BILL_RAW_COST,
      BILL_BRDN_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BRDN_COST,
      BILL_LABOR_HRS,
      EQUIPMENT_RAW_COST,
      EQUIPMENT_BRDN_COST,
      CAPITALIZABLE_RAW_COST,
      CAPITALIZABLE_BRDN_COST,
      LABOR_RAW_COST,
      LABOR_BRDN_COST,
      LABOR_HRS,
      LABOR_REVENUE,
      EQUIPMENT_HOURS,
      BILLABLE_EQUIPMENT_HOURS,
      SUP_INV_COMMITTED_COST,
      PO_COMMITTED_COST,
      PR_COMMITTED_COST,
      OTH_COMMITTED_COST,
      ACT_LABOR_HRS,
      ACT_EQUIP_HRS,
      ACT_LABOR_BRDN_COST,
      ACT_EQUIP_BRDN_COST,
      ACT_BRDN_COST,
      ACT_RAW_COST,
      ACT_REVENUE,
      ACT_LABOR_RAW_COST,
      ACT_EQUIP_RAW_COST,
      ETC_LABOR_HRS,
      ETC_EQUIP_HRS,
      ETC_LABOR_BRDN_COST,
      ETC_EQUIP_BRDN_COST,
      ETC_BRDN_COST,
      ETC_RAW_COST,
      ETC_LABOR_RAW_COST,
      ETC_EQUIP_RAW_COST,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    select
      WORKER_ID,
      null                                            RECORD_TYPE,
      0                                               PRG_LEVEL,
      null                                            LINE_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      PLAN_TYPE_CODE,
      sum(RAW_COST)                                   RAW_COST,
      sum(BRDN_COST)                                  BRDN_COST,
      sum(REVENUE)                                    REVENUE,
      sum(BILL_RAW_COST)                              BILL_RAW_COST,
      sum(BILL_BRDN_COST)                             BILL_BRDN_COST,
      sum(BILL_LABOR_RAW_COST)                        BILL_LABOR_RAW_COST,
      sum(BILL_LABOR_BRDN_COST)                       BILL_LABOR_BRDN_COST,
      sum(BILL_LABOR_HRS)                             BILL_LABOR_HRS,
      sum(EQUIPMENT_RAW_COST)                         EQUIPMENT_RAW_COST,
      sum(EQUIPMENT_BRDN_COST)                        EQUIPMENT_BRDN_COST,
      sum(CAPITALIZABLE_RAW_COST)                     CAPITALIZABLE_RAW_COST,
      sum(CAPITALIZABLE_BRDN_COST)                    CAPITALIZABLE_BRDN_COST,
      sum(LABOR_RAW_COST)                             LABOR_RAW_COST,
      sum(LABOR_BRDN_COST)                            LABOR_BRDN_COST,
      sum(LABOR_HRS)                                  LABOR_HRS,
      sum(LABOR_REVENUE)                              LABOR_REVENUE,
      sum(EQUIPMENT_HOURS)                            EQUIPMENT_HOURS,
      sum(BILLABLE_EQUIPMENT_HOURS)                   BILLABLE_EQUIPMENT_HOURS,
      sum(SUP_INV_COMMITTED_COST)                     SUP_INV_COMMITTED_COST,
      sum(PO_COMMITTED_COST)                          PO_COMMITTED_COST,
      sum(PR_COMMITTED_COST)                          PR_COMMITTED_COST,
      sum(OTH_COMMITTED_COST)                         OTH_COMMITTED_COST,
      sum(ACT_LABOR_HRS)                              ACT_LABOR_HRS,
      sum(ACT_EQUIP_HRS)                              ACT_EQUIP_HRS,
      sum(ACT_LABOR_BRDN_COST)                        ACT_LABOR_BRDN_COST,
      sum(ACT_EQUIP_BRDN_COST)                        ACT_EQUIP_BRDN_COST,
      sum(ACT_BRDN_COST)                              ACT_BRDN_COST,
      sum(ACT_RAW_COST)                               ACT_RAW_COST,
      sum(ACT_REVENUE)                                ACT_REVENUE,
      sum(ACT_LABOR_RAW_COST)                         ACT_LABOR_RAW_COST,
      sum(ACT_EQUIP_RAW_COST)                         ACT_EQUIP_RAW_COST,
      sum(ETC_LABOR_HRS)                              ETC_LABOR_HRS,
      sum(ETC_EQUIP_HRS)                              ETC_EQUIP_HRS,
      sum(ETC_LABOR_BRDN_COST)                        ETC_LABOR_BRDN_COST,
      sum(ETC_EQUIP_BRDN_COST)                        ETC_EQUIP_BRDN_COST,
      sum(ETC_BRDN_COST)                              ETC_BRDN_COST,
      sum(ETC_RAW_COST)                               ETC_RAW_COST,
      sum(ETC_LABOR_RAW_COST)                         ETC_LABOR_RAW_COST,
      sum(ETC_EQUIP_RAW_COST)                         ETC_EQUIP_RAW_COST,
      sum(CUSTOM1)                                    CUSTOM1,
      sum(CUSTOM2)                                    CUSTOM2,
      sum(CUSTOM3)                                    CUSTOM3,
      sum(CUSTOM4)                                    CUSTOM4,
      sum(CUSTOM5)                                    CUSTOM5,
      sum(CUSTOM6)                                    CUSTOM6,
      sum(CUSTOM7)                                    CUSTOM7,
      sum(CUSTOM8)                                    CUSTOM8,
      sum(CUSTOM9)                                    CUSTOM9,
      sum(CUSTOM10)                                   CUSTOM10,
      sum(CUSTOM11)                                   CUSTOM11,
      sum(CUSTOM12)                                   CUSTOM12,
      sum(CUSTOM13)                                   CUSTOM13,
      sum(CUSTOM14)                                   CUSTOM14,
      sum(CUSTOM15)                                   CUSTOM15
    from
      (
      select
        WORKER_ID,
        to_char(null)                                 LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        'A'                                           PLAN_TYPE_CODE,
        RAW_COST,
        BRDN_COST,
        REVENUE,
        BILL_RAW_COST,
        BILL_BRDN_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BRDN_COST,
        BILL_LABOR_HRS,
        EQUIPMENT_RAW_COST,
        EQUIPMENT_BRDN_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BRDN_COST,
        LABOR_HRS,
        LABOR_REVENUE,
        EQUIPMENT_HOURS,
        BILLABLE_EQUIPMENT_HOURS,
        SUP_INV_COMMITTED_COST,
        PO_COMMITTED_COST,
        PR_COMMITTED_COST,
        OTH_COMMITTED_COST,
        to_number(null)                               ACT_LABOR_HRS,
        to_number(null)                               ACT_EQUIP_HRS,
        to_number(null)                               ACT_LABOR_BRDN_COST,
        to_number(null)                               ACT_EQUIP_BRDN_COST,
        to_number(null)                               ACT_BRDN_COST,
        to_number(null)                               ACT_RAW_COST,
        to_number(null)                               ACT_REVENUE,
        to_number(null)                               ACT_LABOR_RAW_COST,
        to_number(null)                               ACT_EQUIP_RAW_COST,
        to_number(null)                               ETC_LABOR_HRS,
        to_number(null)                               ETC_EQUIP_HRS,
        to_number(null)                               ETC_LABOR_BRDN_COST,
        to_number(null)                               ETC_EQUIP_BRDN_COST,
        to_number(null)                               ETC_BRDN_COST,
        to_number(null)                               ETC_RAW_COST,
        to_number(null)                               ETC_LABOR_RAW_COST,
        to_number(null)                               ETC_EQUIP_RAW_COST,
        to_number(null)                               CUSTOM1,
        to_number(null)                               CUSTOM2,
        to_number(null)                               CUSTOM3,
        to_number(null)                               CUSTOM4,
        to_number(null)                               CUSTOM5,
        to_number(null)                               CUSTOM6,
        to_number(null)                               CUSTOM7,
        to_number(null)                               CUSTOM8,
        to_number(null)                               CUSTOM9,
        to_number(null)                               CUSTOM10,
        to_number(null)                               CUSTOM11,
        to_number(null)                               CUSTOM12,
        to_number(null)                               CUSTOM13,
        to_number(null)                               CUSTOM14,
        to_number(null)                               CUSTOM15
      from
        PJI_FP_AGGR_PJP0
      where
        WORKER_ID = p_worker_id
      union all
      select
        WORKER_ID,
        to_char(null)                                 LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        'A'                                           PLAN_TYPE_CODE,
        to_number(null)                               RAW_COST,
        to_number(null)                               BRDN_COST,
        to_number(null)                               REVENUE,
        to_number(null)                               BILL_RAW_COST,
        to_number(null)                               BILL_BRDN_COST,
        to_number(null)                               BILL_LABOR_RAW_COST,
        to_number(null)                               BILL_LABOR_BRDN_COST,
        to_number(null)                               BILL_LABOR_HRS,
        to_number(null)                               EQUIPMENT_RAW_COST,
        to_number(null)                               EQUIPMENT_BRDN_COST,
        to_number(null)                               CAPITALIZABLE_RAW_COST,
        to_number(null)                               CAPITALIZABLE_BRDN_COST,
        to_number(null)                               LABOR_RAW_COST,
        to_number(null)                               LABOR_BRDN_COST,
        to_number(null)                               LABOR_HRS,
        to_number(null)                               LABOR_REVENUE,
        to_number(null)                               EQUIPMENT_HOURS,
        to_number(null)                               BILLABLE_EQUIPMENT_HOURS,
        to_number(null)                               SUP_INV_COMMITTED_COST,
        to_number(null)                               PO_COMMITTED_COST,
        to_number(null)                               PR_COMMITTED_COST,
        to_number(null)                               OTH_COMMITTED_COST,
        to_number(null)                               ACT_LABOR_HRS,
        to_number(null)                               ACT_EQUIP_HRS,
        to_number(null)                               ACT_LABOR_BRDN_COST,
        to_number(null)                               ACT_EQUIP_BRDN_COST,
        to_number(null)                               ACT_BRDN_COST,
        to_number(null)                               ACT_RAW_COST,
        to_number(null)                               ACT_REVENUE,
        to_number(null)                               ACT_LABOR_RAW_COST,
        to_number(null)                               ACT_EQUIP_RAW_COST,
        to_number(null)                               ETC_LABOR_HRS,
        to_number(null)                               ETC_EQUIP_HRS,
        to_number(null)                               ETC_LABOR_BRDN_COST,
        to_number(null)                               ETC_EQUIP_BRDN_COST,
        to_number(null)                               ETC_BRDN_COST,
        to_number(null)                               ETC_RAW_COST,
        to_number(null)                               ETC_LABOR_RAW_COST,
        to_number(null)                               ETC_EQUIP_RAW_COST,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      from
        PJI_FP_CUST_PJP0
      where
        WORKER_ID = p_worker_id
      union all                      -- commitments reversals
      select
        p_worker_id                                   WORKER_ID,
        to_char(null)                                 LINE_TYPE,
        fpr.PROJECT_ID,
        fpr.PROJECT_ORG_ID,
        fpr.PROJECT_ORGANIZATION_ID,
        fpr.PROJECT_ELEMENT_ID,
        fpr.TIME_ID,
        fpr.PERIOD_TYPE_ID,
        fpr.CALENDAR_TYPE,
        fpr.RBS_AGGR_LEVEL,
        fpr.WBS_ROLLUP_FLAG,
        fpr.PRG_ROLLUP_FLAG,
        fpr.CURR_RECORD_TYPE_ID,
        fpr.CURRENCY_CODE,
        fpr.RBS_ELEMENT_ID,
        fpr.RBS_VERSION_ID,
        fpr.PLAN_VERSION_ID,
        fpr.PLAN_TYPE_ID,
        fpr.PLAN_TYPE_CODE,
        to_number(null)                               RAW_COST,
        to_number(null)                               BRDN_COST,
        to_number(null)                               REVENUE,
        to_number(null)                               BILL_RAW_COST,
        to_number(null)                               BILL_BRDN_COST,
        to_number(null)                               BILL_LABOR_RAW_COST,
        to_number(null)                               BILL_LABOR_BRDN_COST,
        to_number(null)                               BILL_LABOR_HRS,
        to_number(null)                               EQUIPMENT_RAW_COST,
        to_number(null)                               EQUIPMENT_BRDN_COST,
        to_number(null)                               CAPITALIZABLE_RAW_COST,
        to_number(null)                               CAPITALIZABLE_BRDN_COST,
        to_number(null)                               LABOR_RAW_COST,
        to_number(null)                               LABOR_BRDN_COST,
        to_number(null)                               LABOR_HRS,
        to_number(null)                               LABOR_REVENUE,
        to_number(null)                               EQUIPMENT_HOURS,
        to_number(null)                               BILLABLE_EQUIPMENT_HOURS,
        - fpr.SUP_INV_COMMITTED_COST,
        - fpr.PO_COMMITTED_COST,
        - fpr.PR_COMMITTED_COST,
        - fpr.OTH_COMMITTED_COST,
        to_number(null)                               ACT_LABOR_HRS,
        to_number(null)                               ACT_EQUIP_HRS,
        to_number(null)                               ACT_LABOR_BRDN_COST,
        to_number(null)                               ACT_EQUIP_BRDN_COST,
        to_number(null)                               ACT_BRDN_COST,
        to_number(null)                               ACT_RAW_COST,
        to_number(null)                               ACT_REVENUE,
        to_number(null)                               ACT_LABOR_RAW_COST,
        to_number(null)                               ACT_EQUIP_RAW_COST,
        to_number(null)                               ETC_LABOR_HRS,
        to_number(null)                               ETC_EQUIP_HRS,
        to_number(null)                               ETC_LABOR_BRDN_COST,
        to_number(null)                               ETC_EQUIP_BRDN_COST,
        to_number(null)                               ETC_BRDN_COST,
        to_number(null)                               ETC_RAW_COST,
        to_number(null)                               ETC_LABOR_RAW_COST,
        to_number(null)                               ETC_EQUIP_RAW_COST,
        to_number(null)                               CUSTOM1,
        to_number(null)                               CUSTOM2,
        to_number(null)                               CUSTOM3,
        to_number(null)                               CUSTOM4,
        to_number(null)                               CUSTOM5,
        to_number(null)                               CUSTOM6,
        to_number(null)                               CUSTOM7,
        to_number(null)                               CUSTOM8,
        to_number(null)                               CUSTOM9,
        to_number(null)                               CUSTOM10,
        - fpr.custom11                                CUSTOM11,         /* Modified for Bug 8271578 Start */
        - fpr.custom12                                CUSTOM12,
        - fpr.custom13                                CUSTOM13,
        - fpr.custom14                                CUSTOM14,
        - fpr.custom15                                CUSTOM15          /* Modified for Bug 8271578 End */
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_FP_XBS_ACCUM_F fpr
      where
        l_extraction_type   = 'INCREMENTAL'  and
        map.WORKER_ID       = p_worker_id    and
        map.EXTRACTION_TYPE = 'M'            and
        fpr.PROJECT_ID      = map.PROJECT_ID and
        fpr.PERIOD_TYPE_ID  = 32             and
        fpr.RBS_AGGR_LEVEL  = 'L'            and
        fpr.WBS_ROLLUP_FLAG = 'N'            and
        fpr.PRG_ROLLUP_FLAG = 'N'            and
        abs(nvl(fpr.SUP_INV_COMMITTED_COST, 0)) +
          abs(nvl(fpr.PO_COMMITTED_COST, 0)) +
          abs(nvl(fpr.PR_COMMITTED_COST, 0)) +
          abs(nvl(fpr.OTH_COMMITTED_COST, 0)) > 0
      union all
      select /*+ ordered */
        p_worker_id                                   WORKER_ID,
        to_char(null)                                 LINE_TYPE,
        fpr.PROJECT_ID,
        fpr.PROJECT_ORG_ID,
        fpr.PROJECT_ORGANIZATION_ID,
        fpr.PROJECT_ELEMENT_ID,
        fpr.TIME_ID,
        fpr.PERIOD_TYPE_ID,
        fpr.CALENDAR_TYPE,
        fpr.RBS_AGGR_LEVEL,
        fpr.WBS_ROLLUP_FLAG,
        fpr.PRG_ROLLUP_FLAG,
        fpr.CURR_RECORD_TYPE_ID,
        fpr.CURRENCY_CODE,
        fpr.RBS_ELEMENT_ID,
        fpr.RBS_VERSION_ID,
        fpr.PLAN_VERSION_ID,
        fpr.PLAN_TYPE_ID,
        fpr.PLAN_TYPE_CODE,
        - fpr.RAW_COST                                RAW_COST,
        - fpr.BRDN_COST                               BRDN_COST,
        - fpr.REVENUE                                 REVENUE,
        - fpr.BILL_RAW_COST                           BILL_RAW_COST,
        - fpr.BILL_BRDN_COST                          BILL_BRDN_COST,
        - fpr.BILL_LABOR_RAW_COST                     BILL_LABOR_RAW_COST,
        - fpr.BILL_LABOR_BRDN_COST                    BILL_LABOR_BRDN_COST,
        - fpr.BILL_LABOR_HRS                          BILL_LABOR_HRS,
        - fpr.EQUIPMENT_RAW_COST                      EQUIPMENT_RAW_COST,
        - fpr.EQUIPMENT_BRDN_COST                     EQUIPMENT_BRDN_COST,
        - fpr.CAPITALIZABLE_RAW_COST                  CAPITALIZABLE_RAW_COST,
        - fpr.CAPITALIZABLE_BRDN_COST                 CAPITALIZABLE_BRDN_COST,
        - fpr.LABOR_RAW_COST                          LABOR_RAW_COST,
        - fpr.LABOR_BRDN_COST                         LABOR_BRDN_COST,
        - fpr.LABOR_HRS                               LABOR_HRS,
        - fpr.LABOR_REVENUE                           LABOR_REVENUE,
        - fpr.EQUIPMENT_HOURS                         EQUIPMENT_HOURS,
        - fpr.BILLABLE_EQUIPMENT_HOURS                BILLABLE_EQUIPMENT_HOURS,
        - fpr.SUP_INV_COMMITTED_COST                  SUP_INV_COMMITTED_COST,
        - fpr.PO_COMMITTED_COST                       PO_COMMITTED_COST,
        - fpr.PR_COMMITTED_COST                       PR_COMMITTED_COST,
        - fpr.OTH_COMMITTED_COST                      OTH_COMMITTED_COST,
        - fpr.ACT_LABOR_HRS                           ACT_LABOR_HRS,
        - fpr.ACT_EQUIP_HRS                           ACT_EQUIP_HRS,
        - fpr.ACT_LABOR_BRDN_COST                     ACT_LABOR_BRDN_COST,
        - fpr.ACT_EQUIP_BRDN_COST                     ACT_EQUIP_BRDN_COST,
        - fpr.ACT_BRDN_COST                           ACT_BRDN_COST,
        - fpr.ACT_RAW_COST                            ACT_RAW_COST,
        - fpr.ACT_REVENUE                             ACT_REVENUE,
        - fpr.ACT_LABOR_RAW_COST                      ACT_LABOR_RAW_COST,
        - fpr.ACT_EQUIP_RAW_COST                      ACT_EQUIP_RAW_COST,
        - fpr.ETC_LABOR_HRS                           ETC_LABOR_HRS,
        - fpr.ETC_EQUIP_HRS                           ETC_EQUIP_HRS,
        - fpr.ETC_LABOR_BRDN_COST                     ETC_LABOR_BRDN_COST,
        - fpr.ETC_EQUIP_BRDN_COST                     ETC_EQUIP_BRDN_COST,
        - fpr.ETC_BRDN_COST                           ETC_BRDN_COST,
        - fpr.ETC_RAW_COST                            ETC_RAW_COST,
        - fpr.ETC_LABOR_RAW_COST                      ETC_LABOR_RAW_COST,
        - fpr.ETC_EQUIP_RAW_COST                      ETC_EQUIP_RAW_COST,
        - fpr.CUSTOM1                                 CUSTOM1,
        - fpr.CUSTOM2                                 CUSTOM2,
        - fpr.CUSTOM3                                 CUSTOM3,
        - fpr.CUSTOM4                                 CUSTOM4,
        - fpr.CUSTOM5                                 CUSTOM5,
        - fpr.CUSTOM6                                 CUSTOM6,
        - fpr.CUSTOM7                                 CUSTOM7,
        - fpr.CUSTOM8                                 CUSTOM8,
        - fpr.CUSTOM9                                 CUSTOM9,
        - fpr.CUSTOM10                                CUSTOM10,
        - fpr.CUSTOM11                                CUSTOM11,
        - fpr.CUSTOM12                                CUSTOM12,
        - fpr.CUSTOM13                                CUSTOM13,
        - fpr.CUSTOM14                                CUSTOM14,
        - fpr.CUSTOM15                                CUSTOM15
      from
        PJI_FM_EXTR_PLNVER3_T map,
        PJI_FP_XBS_ACCUM_F fpr
      where
        l_extraction_type   = 'PARTIAL'           and
        map.WORKER_ID       = p_worker_id         and
        fpr.PROJECT_ID      = map.PROJECT_ID      and
        fpr.PLAN_VERSION_ID = map.PLAN_VERSION_ID and
        fpr.PERIOD_TYPE_ID  = decode(map.time_phased_type_code,
                                     'N', decode(fpr.PERIOD_TYPE_ID,
                                                 32, 32,
                                                     2048),
                                          32)     and
        fpr.RBS_AGGR_LEVEL  = 'L'                 and
        fpr.WBS_ROLLUP_FLAG = 'N'                 and
        fpr.PRG_ROLLUP_FLAG = 'N'
      )
      group by
      WORKER_ID,
      LINE_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      PLAN_TYPE_CODE
    having not
      (nvl(sum(RAW_COST), 0)                 = 0 and
       nvl(sum(BRDN_COST), 0)                = 0 and
       nvl(sum(REVENUE), 0)                  = 0 and
       nvl(sum(BILL_RAW_COST), 0)            = 0 and
       nvl(sum(BILL_BRDN_COST), 0)           = 0 and
       nvl(sum(BILL_LABOR_RAW_COST), 0)      = 0 and
       nvl(sum(BILL_LABOR_BRDN_COST), 0)     = 0 and
       nvl(sum(BILL_LABOR_HRS), 0)           = 0 and
       nvl(sum(EQUIPMENT_RAW_COST), 0)       = 0 and
       nvl(sum(EQUIPMENT_BRDN_COST), 0)      = 0 and
       nvl(sum(CAPITALIZABLE_RAW_COST), 0)   = 0 and
       nvl(sum(CAPITALIZABLE_BRDN_COST), 0)  = 0 and
       nvl(sum(LABOR_RAW_COST), 0)           = 0 and
       nvl(sum(LABOR_BRDN_COST), 0)          = 0 and
       nvl(sum(LABOR_HRS), 0)                = 0 and
       nvl(sum(LABOR_REVENUE), 0)            = 0 and
       nvl(sum(EQUIPMENT_HOURS), 0)          = 0 and
       nvl(sum(BILLABLE_EQUIPMENT_HOURS), 0) = 0 and
       nvl(sum(SUP_INV_COMMITTED_COST), 0)   = 0 and
       nvl(sum(PO_COMMITTED_COST), 0)        = 0 and
       nvl(sum(PR_COMMITTED_COST), 0)        = 0 and
       nvl(sum(OTH_COMMITTED_COST), 0)       = 0 and
       nvl(sum(ACT_LABOR_HRS), 0)            = 0 and
       nvl(sum(ACT_EQUIP_HRS), 0)            = 0 and
       nvl(sum(ACT_LABOR_BRDN_COST), 0)      = 0 and
       nvl(sum(ACT_EQUIP_BRDN_COST), 0)      = 0 and
       nvl(sum(ACT_BRDN_COST), 0)            = 0 and
       nvl(sum(ACT_RAW_COST), 0)             = 0 and
       nvl(sum(ACT_REVENUE), 0)              = 0 and
       nvl(sum(ACT_LABOR_RAW_COST), 0)       = 0 and
       nvl(sum(ACT_EQUIP_RAW_COST), 0)       = 0 and
       nvl(sum(ETC_LABOR_HRS), 0)            = 0 and
       nvl(sum(ETC_EQUIP_HRS), 0)            = 0 and
       nvl(sum(ETC_LABOR_BRDN_COST), 0)      = 0 and
       nvl(sum(ETC_EQUIP_BRDN_COST), 0)      = 0 and
       nvl(sum(ETC_BRDN_COST), 0)            = 0 and
       nvl(sum(ETC_RAW_COST), 0)             = 0 and
       nvl(sum(ETC_LABOR_RAW_COST), 0)       = 0 and
       nvl(sum(ETC_EQUIP_RAW_COST), 0)       = 0 and
       nvl(sum(CUSTOM1), 0)                  = 0 and
       nvl(sum(CUSTOM2), 0)                  = 0 and
       nvl(sum(CUSTOM3), 0)                  = 0 and
       nvl(sum(CUSTOM4), 0)                  = 0 and
       nvl(sum(CUSTOM5), 0)                  = 0 and
       nvl(sum(CUSTOM6), 0)                  = 0 and
       nvl(sum(CUSTOM7), 0)                  = 0 and
       nvl(sum(CUSTOM8), 0)                  = 0 and
       nvl(sum(CUSTOM9), 0)                  = 0 and
       nvl(sum(CUSTOM10), 0)                 = 0 and
       nvl(sum(CUSTOM11), 0)                 = 0 and
       nvl(sum(CUSTOM12), 0)                 = 0 and
       nvl(sum(CUSTOM13), 0)                 = 0 and
       nvl(sum(CUSTOM14), 0)                 = 0 and
       nvl(sum(CUSTOM15), 0)                 = 0);

       if  (  l_extraction_type    =  'PARTIAL' ) then    -- Partial Refresh Performance Improvement
    delete from PJI_FM_EXTR_PLNVER3_T where worker_id=p_worker_id;
  end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_CUST_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_FP_CUST_SLICES;


  -- -----------------------------------------------------
  -- procedure AGGREGATE_AC_CUST_SLICES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_AC_CUST_SLICES (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);
    l_refresh_code number;   --  Bug#5099574
    l_plan_type_id number;
  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_CUST_SLICES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

     --  Bug#5099574
     l_refresh_code     :=  PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'REFRESH_CODE');
    l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_process, 'PLAN_TYPE_ID');

    if (l_plan_type_id = -1) then
      l_plan_type_id := null;
    end if;
/* spliited the SQL to remove unnecessasry hits based on extraction type */
IF l_extraction_type='PARTIAL' THEN      -- Bug#5453009 Performance Fix  .
                      -- Sql was split into 2 for Partial  and Non Partial Flows

    insert into PJI_AC_AGGR_PJP1 pjp1_i
    (
      WORKER_ID,
      RECORD_TYPE,
      PRG_LEVEL,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_INVOICE_WRITE_OFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    select
      WORKER_ID,
      null                                         RECORD_TYPE,
      0                                            PRG_LEVEL,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      sum(REVENUE)                                 REVENUE,
      sum(INITIAL_FUNDING_AMOUNT)                  INITIAL_FUNDING_AMOUNT,
      sum(INITIAL_FUNDING_COUNT)                   INITIAL_FUNDING_COUNT,
      sum(ADDITIONAL_FUNDING_AMOUNT)               ADDITIONAL_FUNDING_AMOUNT,
      sum(ADDITIONAL_FUNDING_COUNT)                ADDITIONAL_FUNDING_COUNT,
      sum(CANCELLED_FUNDING_AMOUNT)                CANCELLED_FUNDING_AMOUNT,
      sum(CANCELLED_FUNDING_COUNT)                 CANCELLED_FUNDING_COUNT,
      sum(FUNDING_ADJUSTMENT_AMOUNT)               FUNDING_ADJUSTMENT_AMOUNT,
      sum(FUNDING_ADJUSTMENT_COUNT)                FUNDING_ADJUSTMENT_COUNT,
      sum(REVENUE_WRITEOFF)                        REVENUE_WRITEOFF,
      sum(AR_INVOICE_AMOUNT)                       AR_INVOICE_AMOUNT,
      sum(AR_INVOICE_COUNT)                        AR_INVOICE_COUNT,
      sum(AR_CASH_APPLIED_AMOUNT)                  AR_CASH_APPLIED_AMOUNT,
      sum(AR_INVOICE_WRITE_OFF_AMOUNT)             AR_INVOICE_WRITE_OFF_AMOUNT,
      sum(AR_INVOICE_WRITEOFF_COUNT)               AR_INVOICE_WRITEOFF_COUNT,
      sum(AR_CREDIT_MEMO_AMOUNT)                   AR_CREDIT_MEMO_AMOUNT,
      sum(AR_CREDIT_MEMO_COUNT)                    AR_CREDIT_MEMO_COUNT,
      sum(UNBILLED_RECEIVABLES)                    UNBILLED_RECEIVABLES,
      sum(UNEARNED_REVENUE)                        UNEARNED_REVENUE,
      sum(AR_UNAPPR_INVOICE_AMOUNT)                AR_UNAPPR_INVOICE_AMOUNT,
      sum(AR_UNAPPR_INVOICE_COUNT)                 AR_UNAPPR_INVOICE_COUNT,
      sum(AR_APPR_INVOICE_AMOUNT)                  AR_APPR_INVOICE_AMOUNT,
      sum(AR_APPR_INVOICE_COUNT)                   AR_APPR_INVOICE_COUNT,
      sum(AR_AMOUNT_DUE)                           AR_AMOUNT_DUE,
      sum(AR_COUNT_DUE)                            AR_COUNT_DUE,
      sum(AR_AMOUNT_OVERDUE)                       AR_AMOUNT_OVERDUE,
      sum(AR_COUNT_OVERDUE)                        AR_COUNT_OVERDUE,
      sum(CUSTOM1)                                 CUSTOM1,
      sum(CUSTOM2)                                 CUSTOM2,
      sum(CUSTOM3)                                 CUSTOM3,
      sum(CUSTOM4)                                 CUSTOM4,
      sum(CUSTOM5)                                 CUSTOM5,
      sum(CUSTOM6)                                 CUSTOM6,
      sum(CUSTOM7)                                 CUSTOM7,
      sum(CUSTOM8)                                 CUSTOM8,
      sum(CUSTOM9)                                 CUSTOM9,
      sum(CUSTOM10)                                CUSTOM10,
      sum(CUSTOM11)                                CUSTOM11,
      sum(CUSTOM12)                                CUSTOM12,
      sum(CUSTOM13)                                CUSTOM13,
      sum(CUSTOM14)                                CUSTOM14,
      sum(CUSTOM15)                                CUSTOM15
    from
      (
      select
        WORKER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITE_OFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        to_number(null)                            CUSTOM1,
        to_number(null)                            CUSTOM2,
        to_number(null)                            CUSTOM3,
        to_number(null)                            CUSTOM4,
        to_number(null)                            CUSTOM5,
        to_number(null)                            CUSTOM6,
        to_number(null)                            CUSTOM7,
        to_number(null)                            CUSTOM8,
        to_number(null)                            CUSTOM9,
        to_number(null)                            CUSTOM10,
        to_number(null)                            CUSTOM11,
        to_number(null)                            CUSTOM12,
        to_number(null)                            CUSTOM13,
        to_number(null)                            CUSTOM14,
        to_number(null)                            CUSTOM15
      from
        PJI_AC_AGGR_PJP0
      where
        WORKER_ID = p_worker_id
      union all
      select
        WORKER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        to_number(null)                            REVENUE,
        to_number(null)                            INITIAL_FUNDING_AMOUNT,
        to_number(null)                            INITIAL_FUNDING_COUNT,
        to_number(null)                            ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                            ADDITIONAL_FUNDING_COUNT,
        to_number(null)                            CANCELLED_FUNDING_AMOUNT,
        to_number(null)                            CANCELLED_FUNDING_COUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                            REVENUE_WRITEOFF,
        to_number(null)                            AR_INVOICE_AMOUNT,
        to_number(null)                            AR_INVOICE_COUNT,
        to_number(null)                            AR_CASH_APPLIED_AMOUNT,
        to_number(null)                            AR_INVOICE_WRITE_OFF_AMOUNT,
        to_number(null)                            AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                            AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                            AR_CREDIT_MEMO_COUNT,
        to_number(null)                            UNBILLED_RECEIVABLES,
        to_number(null)                            UNEARNED_REVENUE,
        to_number(null)                            AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                            AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                            AR_APPR_INVOICE_AMOUNT,
        to_number(null)                            AR_APPR_INVOICE_COUNT,
        to_number(null)                            AR_AMOUNT_DUE,
        to_number(null)                            AR_COUNT_DUE,
        to_number(null)                            AR_AMOUNT_OVERDUE,
        to_number(null)                            AR_COUNT_OVERDUE,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      from
        PJI_AC_CUST_PJP0
      where
        WORKER_ID = p_worker_id
      union all                        -- partial refresh reversals
      select /*+  full(map) use_nl(acr) */
        p_worker_id                                WORKER_ID,
        acr.PROJECT_ID,
        acr.PROJECT_ORG_ID,
        acr.PROJECT_ORGANIZATION_ID,
        acr.PROJECT_ELEMENT_ID,
        acr.TIME_ID,
        acr.PERIOD_TYPE_ID,
        acr.CALENDAR_TYPE,
        acr.WBS_ROLLUP_FLAG,
        acr.PRG_ROLLUP_FLAG,
        acr.CURR_RECORD_TYPE_ID,
        acr.CURRENCY_CODE,
        - acr.REVENUE                              REVENUE,
        - acr.INITIAL_FUNDING_AMOUNT               INITIAL_FUNDING_AMOUNT,
        - acr.INITIAL_FUNDING_COUNT                INITIAL_FUNDING_COUNT,
        - acr.ADDITIONAL_FUNDING_AMOUNT            ADDITIONAL_FUNDING_AMOUNT,
        - acr.ADDITIONAL_FUNDING_COUNT             ADDITIONAL_FUNDING_COUNT,
        - acr.CANCELLED_FUNDING_AMOUNT             CANCELLED_FUNDING_AMOUNT,
        - acr.CANCELLED_FUNDING_COUNT              CANCELLED_FUNDING_COUNT,
        - acr.FUNDING_ADJUSTMENT_AMOUNT            FUNDING_ADJUSTMENT_AMOUNT,
        - acr.FUNDING_ADJUSTMENT_COUNT             FUNDING_ADJUSTMENT_COUNT,
        - acr.REVENUE_WRITEOFF                     REVENUE_WRITEOFF,
        - acr.AR_INVOICE_AMOUNT                    AR_INVOICE_AMOUNT,
        - acr.AR_INVOICE_COUNT                     AR_INVOICE_COUNT,
        - acr.AR_CASH_APPLIED_AMOUNT               AR_CASH_APPLIED_AMOUNT,
        - acr.AR_INVOICE_WRITE_OFF_AMOUNT          AR_INVOICE_WRITE_OFF_AMOUNT,
        - acr.AR_INVOICE_WRITEOFF_COUNT            AR_INVOICE_WRITEOFF_COUNT,
        - acr.AR_CREDIT_MEMO_AMOUNT                AR_CREDIT_MEMO_AMOUNT,
        - acr.AR_CREDIT_MEMO_COUNT                 AR_CREDIT_MEMO_COUNT,
        - acr.UNBILLED_RECEIVABLES                 UNBILLED_RECEIVABLES,
        - acr.UNEARNED_REVENUE                     UNEARNED_REVENUE,
        - acr.AR_UNAPPR_INVOICE_AMOUNT             AR_UNAPPR_INVOICE_AMOUNT,
        - acr.AR_UNAPPR_INVOICE_COUNT              AR_UNAPPR_INVOICE_COUNT,
        - acr.AR_APPR_INVOICE_AMOUNT               AR_APPR_INVOICE_AMOUNT,
        - acr.AR_APPR_INVOICE_COUNT                AR_APPR_INVOICE_COUNT,
        - acr.AR_AMOUNT_DUE                        AR_AMOUNT_DUE,
        - acr.AR_COUNT_DUE                         AR_COUNT_DUE,
        - acr.AR_AMOUNT_OVERDUE                    AR_AMOUNT_OVERDUE,
        - acr.AR_COUNT_OVERDUE                     AR_COUNT_OVERDUE,
        - acr.CUSTOM1                              CUSTOM1,
        - acr.CUSTOM2                              CUSTOM2,
        - acr.CUSTOM3                              CUSTOM3,
        - acr.CUSTOM4                              CUSTOM4,
        - acr.CUSTOM5                              CUSTOM5,
        - acr.CUSTOM6                              CUSTOM6,
        - acr.CUSTOM7                              CUSTOM7,
        - acr.CUSTOM8                              CUSTOM8,
        - acr.CUSTOM9                              CUSTOM9,
        - acr.CUSTOM10                             CUSTOM10,
        - acr.CUSTOM11                             CUSTOM11,
        - acr.CUSTOM12                             CUSTOM12,
        - acr.CUSTOM13                             CUSTOM13,
        - acr.CUSTOM14                             CUSTOM14,
        - acr.CUSTOM15                             CUSTOM15
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_AC_XBS_ACCUM_F acr
      where
        l_extraction_type   = 'PARTIAL'      and
        map.WORKER_ID       = p_worker_id    and
        acr.PROJECT_ID      = map.PROJECT_ID and
        acr.PERIOD_TYPE_ID  = 32             and
        acr.WBS_ROLLUP_FLAG = 'N'            and
        acr.PRG_ROLLUP_FLAG = 'N'         and
  decode(bitand(l_refresh_code,1),1,'Y','N') ='Y'   and   --  Bug#5099574
  l_plan_type_id is null
      )
    group by
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE
    having not
      (nvl(sum(REVENUE), 0)                     = 0 and
       nvl(sum(INITIAL_FUNDING_AMOUNT), 0)      = 0 and
       nvl(sum(INITIAL_FUNDING_COUNT), 0)       = 0 and
       nvl(sum(ADDITIONAL_FUNDING_AMOUNT), 0)   = 0 and
       nvl(sum(ADDITIONAL_FUNDING_COUNT), 0)    = 0 and
       nvl(sum(CANCELLED_FUNDING_AMOUNT), 0)    = 0 and
       nvl(sum(CANCELLED_FUNDING_COUNT), 0)     = 0 and
       nvl(sum(FUNDING_ADJUSTMENT_AMOUNT), 0)   = 0 and
       nvl(sum(FUNDING_ADJUSTMENT_COUNT), 0)    = 0 and
       nvl(sum(REVENUE_WRITEOFF), 0)            = 0 and
       nvl(sum(AR_INVOICE_AMOUNT), 0)           = 0 and
       nvl(sum(AR_INVOICE_COUNT), 0)            = 0 and
       nvl(sum(AR_CASH_APPLIED_AMOUNT), 0)      = 0 and
       nvl(sum(AR_INVOICE_WRITE_OFF_AMOUNT), 0) = 0 and
       nvl(sum(AR_INVOICE_WRITEOFF_COUNT), 0)   = 0 and
       nvl(sum(AR_CREDIT_MEMO_AMOUNT), 0)       = 0 and
       nvl(sum(AR_CREDIT_MEMO_COUNT), 0)        = 0 and
       nvl(sum(UNBILLED_RECEIVABLES), 0)        = 0 and
       nvl(sum(UNEARNED_REVENUE), 0)            = 0 and
       nvl(sum(AR_UNAPPR_INVOICE_AMOUNT), 0)    = 0 and
       nvl(sum(AR_UNAPPR_INVOICE_COUNT), 0)     = 0 and
       nvl(sum(AR_APPR_INVOICE_AMOUNT), 0)      = 0 and
       nvl(sum(AR_APPR_INVOICE_COUNT), 0)       = 0 and
       nvl(sum(AR_AMOUNT_DUE), 0)               = 0 and
       nvl(sum(AR_COUNT_DUE), 0)                = 0 and
       nvl(sum(AR_AMOUNT_OVERDUE), 0)           = 0 and
       nvl(sum(AR_COUNT_OVERDUE), 0)            = 0 and
       nvl(sum(CUSTOM1), 0)                     = 0 and
       nvl(sum(CUSTOM2), 0)                     = 0 and
       nvl(sum(CUSTOM3), 0)                     = 0 and
       nvl(sum(CUSTOM4), 0)                     = 0 and
       nvl(sum(CUSTOM5), 0)                     = 0 and
       nvl(sum(CUSTOM6), 0)                     = 0 and
       nvl(sum(CUSTOM7), 0)                     = 0 and
       nvl(sum(CUSTOM8), 0)                     = 0 and
       nvl(sum(CUSTOM9), 0)                     = 0 and
       nvl(sum(CUSTOM10), 0)                    = 0 and
       nvl(sum(CUSTOM11), 0)                    = 0 and
       nvl(sum(CUSTOM12), 0)                    = 0 and
       nvl(sum(CUSTOM13), 0)                    = 0 and
       nvl(sum(CUSTOM14), 0)                    = 0 and
       nvl(sum(CUSTOM15), 0)                    = 0);

else
 insert into PJI_AC_AGGR_PJP1 pjp1_i
    (
      WORKER_ID,
      RECORD_TYPE,
      PRG_LEVEL,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      REVENUE,
      INITIAL_FUNDING_AMOUNT,
      INITIAL_FUNDING_COUNT,
      ADDITIONAL_FUNDING_AMOUNT,
      ADDITIONAL_FUNDING_COUNT,
      CANCELLED_FUNDING_AMOUNT,
      CANCELLED_FUNDING_COUNT,
      FUNDING_ADJUSTMENT_AMOUNT,
      FUNDING_ADJUSTMENT_COUNT,
      REVENUE_WRITEOFF,
      AR_INVOICE_AMOUNT,
      AR_INVOICE_COUNT,
      AR_CASH_APPLIED_AMOUNT,
      AR_INVOICE_WRITE_OFF_AMOUNT,
      AR_INVOICE_WRITEOFF_COUNT,
      AR_CREDIT_MEMO_AMOUNT,
      AR_CREDIT_MEMO_COUNT,
      UNBILLED_RECEIVABLES,
      UNEARNED_REVENUE,
      AR_UNAPPR_INVOICE_AMOUNT,
      AR_UNAPPR_INVOICE_COUNT,
      AR_APPR_INVOICE_AMOUNT,
      AR_APPR_INVOICE_COUNT,
      AR_AMOUNT_DUE,
      AR_COUNT_DUE,
      AR_AMOUNT_OVERDUE,
      AR_COUNT_OVERDUE,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    select
      WORKER_ID,
      null                                         RECORD_TYPE,
      0                                            PRG_LEVEL,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      sum(REVENUE)                                 REVENUE,
      sum(INITIAL_FUNDING_AMOUNT)                  INITIAL_FUNDING_AMOUNT,
      sum(INITIAL_FUNDING_COUNT)                   INITIAL_FUNDING_COUNT,
      sum(ADDITIONAL_FUNDING_AMOUNT)               ADDITIONAL_FUNDING_AMOUNT,
      sum(ADDITIONAL_FUNDING_COUNT)                ADDITIONAL_FUNDING_COUNT,
      sum(CANCELLED_FUNDING_AMOUNT)                CANCELLED_FUNDING_AMOUNT,
      sum(CANCELLED_FUNDING_COUNT)                 CANCELLED_FUNDING_COUNT,
      sum(FUNDING_ADJUSTMENT_AMOUNT)               FUNDING_ADJUSTMENT_AMOUNT,
      sum(FUNDING_ADJUSTMENT_COUNT)                FUNDING_ADJUSTMENT_COUNT,
      sum(REVENUE_WRITEOFF)                        REVENUE_WRITEOFF,
      sum(AR_INVOICE_AMOUNT)                       AR_INVOICE_AMOUNT,
      sum(AR_INVOICE_COUNT)                        AR_INVOICE_COUNT,
      sum(AR_CASH_APPLIED_AMOUNT)                  AR_CASH_APPLIED_AMOUNT,
      sum(AR_INVOICE_WRITE_OFF_AMOUNT)             AR_INVOICE_WRITE_OFF_AMOUNT,
      sum(AR_INVOICE_WRITEOFF_COUNT)               AR_INVOICE_WRITEOFF_COUNT,
      sum(AR_CREDIT_MEMO_AMOUNT)                   AR_CREDIT_MEMO_AMOUNT,
      sum(AR_CREDIT_MEMO_COUNT)                    AR_CREDIT_MEMO_COUNT,
      sum(UNBILLED_RECEIVABLES)                    UNBILLED_RECEIVABLES,
      sum(UNEARNED_REVENUE)                        UNEARNED_REVENUE,
      sum(AR_UNAPPR_INVOICE_AMOUNT)                AR_UNAPPR_INVOICE_AMOUNT,
      sum(AR_UNAPPR_INVOICE_COUNT)                 AR_UNAPPR_INVOICE_COUNT,
      sum(AR_APPR_INVOICE_AMOUNT)                  AR_APPR_INVOICE_AMOUNT,
      sum(AR_APPR_INVOICE_COUNT)                   AR_APPR_INVOICE_COUNT,
      sum(AR_AMOUNT_DUE)                           AR_AMOUNT_DUE,
      sum(AR_COUNT_DUE)                            AR_COUNT_DUE,
      sum(AR_AMOUNT_OVERDUE)                       AR_AMOUNT_OVERDUE,
      sum(AR_COUNT_OVERDUE)                        AR_COUNT_OVERDUE,
      sum(CUSTOM1)                                 CUSTOM1,
      sum(CUSTOM2)                                 CUSTOM2,
      sum(CUSTOM3)                                 CUSTOM3,
      sum(CUSTOM4)                                 CUSTOM4,
      sum(CUSTOM5)                                 CUSTOM5,
      sum(CUSTOM6)                                 CUSTOM6,
      sum(CUSTOM7)                                 CUSTOM7,
      sum(CUSTOM8)                                 CUSTOM8,
      sum(CUSTOM9)                                 CUSTOM9,
      sum(CUSTOM10)                                CUSTOM10,
      sum(CUSTOM11)                                CUSTOM11,
      sum(CUSTOM12)                                CUSTOM12,
      sum(CUSTOM13)                                CUSTOM13,
      sum(CUSTOM14)                                CUSTOM14,
      sum(CUSTOM15)                                CUSTOM15
    from
      (
      select
        WORKER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITE_OFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        to_number(null)                            CUSTOM1,
        to_number(null)                            CUSTOM2,
        to_number(null)                            CUSTOM3,
        to_number(null)                            CUSTOM4,
        to_number(null)                            CUSTOM5,
        to_number(null)                            CUSTOM6,
        to_number(null)                            CUSTOM7,
        to_number(null)                            CUSTOM8,
        to_number(null)                            CUSTOM9,
        to_number(null)                            CUSTOM10,
        to_number(null)                            CUSTOM11,
        to_number(null)                            CUSTOM12,
        to_number(null)                            CUSTOM13,
        to_number(null)                            CUSTOM14,
        to_number(null)                            CUSTOM15
      from
        PJI_AC_AGGR_PJP0
      where
        WORKER_ID = p_worker_id
      union all
      select
        WORKER_ID,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        to_number(null)                            REVENUE,
        to_number(null)                            INITIAL_FUNDING_AMOUNT,
        to_number(null)                            INITIAL_FUNDING_COUNT,
        to_number(null)                            ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                            ADDITIONAL_FUNDING_COUNT,
        to_number(null)                            CANCELLED_FUNDING_AMOUNT,
        to_number(null)                            CANCELLED_FUNDING_COUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                            REVENUE_WRITEOFF,
        to_number(null)                            AR_INVOICE_AMOUNT,
        to_number(null)                            AR_INVOICE_COUNT,
        to_number(null)                            AR_CASH_APPLIED_AMOUNT,
        to_number(null)                            AR_INVOICE_WRITE_OFF_AMOUNT,
        to_number(null)                            AR_INVOICE_WRITEOFF_COUNT,
        to_number(null)                            AR_CREDIT_MEMO_AMOUNT,
        to_number(null)                            AR_CREDIT_MEMO_COUNT,
        to_number(null)                            UNBILLED_RECEIVABLES,
        to_number(null)                            UNEARNED_REVENUE,
        to_number(null)                            AR_UNAPPR_INVOICE_AMOUNT,
        to_number(null)                            AR_UNAPPR_INVOICE_COUNT,
        to_number(null)                            AR_APPR_INVOICE_AMOUNT,
        to_number(null)                            AR_APPR_INVOICE_COUNT,
        to_number(null)                            AR_AMOUNT_DUE,
        to_number(null)                            AR_COUNT_DUE,
        to_number(null)                            AR_AMOUNT_OVERDUE,
        to_number(null)                            AR_COUNT_OVERDUE,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      from
        PJI_AC_CUST_PJP0
      where
        WORKER_ID = p_worker_id
      union all    -- activity and snapshot reversals  -  PART 1  -  ENT dates
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+  leading(INVERT,ENT,ACR) full(map) use_nl(acr map) */    /* Modified for Bug 7669026 */
            distinct                                   -- Bug 6689297
        p_worker_id                                WORKER_ID,
        acr.PROJECT_ID,
        acr.PROJECT_ORG_ID,
        acr.PROJECT_ORGANIZATION_ID,
        acr.PROJECT_ELEMENT_ID,
        decode(invert.INVERT_ID,
               'ACTIVITY', acr.TIME_ID,
               'SNAPSHOT', ent.ENT_PERIOD_ID)      TIME_ID,
        32                                         PERIOD_TYPE_ID,
        'E'                                        CALENDAR_TYPE,
        acr.WBS_ROLLUP_FLAG,
        acr.PRG_ROLLUP_FLAG,
        acr.CURR_RECORD_TYPE_ID,
        acr.CURRENCY_CODE,
        to_number(null)                            REVENUE,
        to_number(null)                            INITIAL_FUNDING_AMOUNT,
        to_number(null)                            INITIAL_FUNDING_COUNT,
        to_number(null)                            ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                            ADDITIONAL_FUNDING_COUNT,
        to_number(null)                            CANCELLED_FUNDING_AMOUNT,
        to_number(null)                            CANCELLED_FUNDING_COUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                            REVENUE_WRITEOFF,
        to_number(null)                            AR_INVOICE_AMOUNT,    -- Bug 6689297
        to_number(null)                            AR_INVOICE_COUNT,     -- Bug 6689297
/*        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(ent.ENT_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_COUNT) AR_INVOICE_COUNT, */
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_CASH_APPLIED_AMOUNT)
                                                   AR_CASH_APPLIED_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_WRITE_OFF_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_WRITE_OFF_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(ent.ENT_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               -acr.AR_INVOICE_WRITEOFF_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_WRITEOFF_COUNT)
                                                   AR_INVOICE_WRITEOFF_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_CREDIT_MEMO_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_CREDIT_MEMO_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(ent.ENT_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_CREDIT_MEMO_COUNT),
               'SNAPSHOT', - acr.AR_CREDIT_MEMO_COUNT)
                                                   AR_CREDIT_MEMO_COUNT,
        to_number(null)                            UNBILLED_RECEIVABLES,
        to_number(null)                            UNEARNED_REVENUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_AMOUNT)
                                                   AR_UNAPPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(ent.ENT_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_UNAPPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_COUNT)
                                                   AR_UNAPPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_AMOUNT)
                                                   AR_APPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(ent.ENT_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_APPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_COUNT)
                                                   AR_APPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_DUE)    AR_AMOUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_DUE)     AR_COUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_OVERDUE)AR_AMOUNT_OVERDUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_OVERDUE) AR_COUNT_OVERDUE,
        to_number(null)                            CUSTOM1,
        to_number(null)                            CUSTOM2,
        to_number(null)                            CUSTOM3,
        to_number(null)                            CUSTOM4,
        to_number(null)                            CUSTOM5,
        to_number(null)                            CUSTOM6,
        to_number(null)                            CUSTOM7,
        to_number(null)                            CUSTOM8,
        to_number(null)                            CUSTOM9,
        to_number(null)                            CUSTOM10,
        to_number(null)                            CUSTOM11,
        to_number(null)                            CUSTOM12,
        to_number(null)                            CUSTOM13,
        to_number(null)                            CUSTOM14,
        to_number(null)                            CUSTOM15
      from
        PJI_PJP_PROJ_BATCH_MAP map,
        PJI_AC_XBS_ACCUM_F     acr,
        PJI_AC_AGGR_PJP0       pjp0,    -- Bug 6689297
        PJI_TIME_RPT_STRUCT    cal,
        PJI_TIME_ENT_PERIOD_V  ent,
        (
          select 'ACTIVITY' INVERT_ID from DUAL union all
          select 'SNAPSHOT' INVERT_ID from DUAL
        ) invert
      where
        l_extraction_type                <> 'PARTIAL'                   and
        map.WORKER_ID                    =  p_worker_id                 and
        acr.PROJECT_ID                   =  map.PROJECT_ID              and
        pjp0.WORKER_ID                   =  p_worker_id                 and    -- Bug 6689297
        acr.PROJECT_ID                   =  pjp0.PROJECT_ID             and    -- Bug 6689297
        acr.WBS_ROLLUP_FLAG              =  'N'                         and
        acr.PRG_ROLLUP_FLAG              =  'N'                         and
        cal.REPORT_DATE                  =  trunc(ent.START_DATE, 'J')  and
        cal.CALENDAR_TYPE                =  acr.CALENDAR_TYPE           and
        cal.PERIOD_TYPE_ID               =  acr.PERIOD_TYPE_ID          and
        cal.TIME_ID                      =  acr.TIME_ID                 and
        bitand(cal.RECORD_TYPE_ID, 1376) =  cal.RECORD_TYPE_ID          and
        sysdate between ent.START_DATE and ent.END_DATE                 and
        abs(nvl(acr.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_AMOUNT_DUE,0)) +
          abs(nvl(acr.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_COUNT_DUE,0)) +
          abs(nvl(acr.AR_COUNT_OVERDUE,0)) > 0
      union all    -- activity and snapshot reversals  -  PART 2  -  GL dates
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+ leading(INVERT,ACR) full(map) use_nl(acr map) full(info) */             /* Modified for Bug 7669026 */
            distinct                                   -- Bug 6689297
        p_worker_id                                WORKER_ID,
        acr.PROJECT_ID,
        acr.PROJECT_ORG_ID,
        acr.PROJECT_ORGANIZATION_ID,
        acr.PROJECT_ELEMENT_ID,
        decode(invert.INVERT_ID,
               'ACTIVITY', acr.TIME_ID,
               'SNAPSHOT', gl_cal.CAL_PERIOD_ID)   TIME_ID,
        32                                         PERIOD_TYPE_ID,
        'G'                                        CALENDAR_TYPE,
        acr.WBS_ROLLUP_FLAG,
        acr.PRG_ROLLUP_FLAG,
        acr.CURR_RECORD_TYPE_ID,
        acr.CURRENCY_CODE,
        to_number(null)                            REVENUE,
        to_number(null)                            INITIAL_FUNDING_AMOUNT,
        to_number(null)                            INITIAL_FUNDING_COUNT,
        to_number(null)                            ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                            ADDITIONAL_FUNDING_COUNT,
        to_number(null)                            CANCELLED_FUNDING_AMOUNT,
        to_number(null)                            CANCELLED_FUNDING_COUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                            REVENUE_WRITEOFF,
        to_number(null)                            AR_INVOICE_AMOUNT,    -- Bug 6689297
        to_number(null)                            AR_INVOICE_COUNT,     -- Bug 6689297
/*        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(gl_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_COUNT) AR_INVOICE_COUNT,   */
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_CASH_APPLIED_AMOUNT)
                                                   AR_CASH_APPLIED_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_WRITE_OFF_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_WRITE_OFF_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(gl_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               -acr.AR_INVOICE_WRITEOFF_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_WRITEOFF_COUNT)
                                                   AR_INVOICE_WRITEOFF_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_CREDIT_MEMO_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_CREDIT_MEMO_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(gl_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_CREDIT_MEMO_COUNT),
               'SNAPSHOT', - acr.AR_CREDIT_MEMO_COUNT)
                                                   AR_CREDIT_MEMO_COUNT,
        to_number(null)                            UNBILLED_RECEIVABLES,
        to_number(null)                            UNEARNED_REVENUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_AMOUNT)
                                                   AR_UNAPPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(gl_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_UNAPPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_COUNT)
                                                   AR_UNAPPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_AMOUNT)
                                                   AR_APPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(gl_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_APPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_COUNT)
                                                   AR_APPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_DUE)    AR_AMOUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_DUE)     AR_COUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_OVERDUE)AR_AMOUNT_OVERDUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_OVERDUE) AR_COUNT_OVERDUE,
        to_number(null)                            CUSTOM1,
        to_number(null)                            CUSTOM2,
        to_number(null)                            CUSTOM3,
        to_number(null)                            CUSTOM4,
        to_number(null)                            CUSTOM5,
        to_number(null)                            CUSTOM6,
        to_number(null)                            CUSTOM7,
        to_number(null)                            CUSTOM8,
        to_number(null)                            CUSTOM9,
        to_number(null)                            CUSTOM10,
        to_number(null)                            CUSTOM11,
        to_number(null)                            CUSTOM12,
        to_number(null)                            CUSTOM13,
        to_number(null)                            CUSTOM14,
        to_number(null)                            CUSTOM15
      from
        PJI_PJP_PROJ_BATCH_MAP  map,
        PJI_AC_XBS_ACCUM_F      acr,
        PJI_AC_AGGR_PJP0        pjp0,    -- Bug 6689297
        PJI_TIME_CAL_RPT_STRUCT cal,
        PJI_ORG_EXTR_INFO       info,
        PJI_TIME_CAL_PERIOD_V   gl_cal,
        (
          select 'ACTIVITY' INVERT_ID from DUAL union all
          select 'SNAPSHOT' INVERT_ID from DUAL
        ) invert
      where
        l_extraction_type                <> 'PARTIAL'                     and
        map.WORKER_ID                    =  p_worker_id                   and
        acr.PROJECT_ID                   =  map.PROJECT_ID                and
        pjp0.WORKER_ID                   =  p_worker_id                   and    -- Bug 6689297
        acr.PROJECT_ID                   =  pjp0.PROJECT_ID               and    -- Bug 6689297
        acr.WBS_ROLLUP_FLAG              =  'N'                           and
        acr.PRG_ROLLUP_FLAG              =  'N'                           and
        acr.PROJECT_ORG_ID               =  info.ORG_ID                   and  /*5377133 */
        acr.CALENDAR_TYPE                =  'G'                           and
        cal.REPORT_DATE                  =  trunc(gl_cal.START_DATE, 'J') and
        cal.CALENDAR_ID                  =  info.GL_CALENDAR_ID           and
        cal.PERIOD_TYPE_ID               =  acr.PERIOD_TYPE_ID            and
        cal.TIME_ID                      =  acr.TIME_ID                   and
        bitand(cal.RECORD_TYPE_ID, 1376) =  cal.RECORD_TYPE_ID            and
        gl_cal.CALENDAR_ID               =  info.GL_CALENDAR_ID           and
        sysdate between gl_cal.START_DATE and gl_cal.END_DATE             and
        abs(nvl(acr.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_AMOUNT_DUE,0)) +
          abs(nvl(acr.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_COUNT_DUE,0)) +
          abs(nvl(acr.AR_COUNT_OVERDUE,0)) > 0
      union all    -- activity and snapshot reversals  -  PART 3  -  PA dates
                   -- Select old ITD amounts for snapshots with
                   -- reverse sign from base level fact
      select /*+ leading(INVERT,ACR) full(map) use_nl(acr map) full(info) */          /* Modified for Bug 7669026 */
            distinct                                   -- Bug 6689297
        p_worker_id                                WORKER_ID,
        acr.PROJECT_ID,
        acr.PROJECT_ORG_ID,
        acr.PROJECT_ORGANIZATION_ID,
        acr.PROJECT_ELEMENT_ID,
        decode(invert.INVERT_ID,
               'ACTIVITY', acr.TIME_ID,
               'SNAPSHOT', pa_cal.CAL_PERIOD_ID)   TIME_ID,
        32                                         PERIOD_TYPE_ID,
        'P'                                        CALENDAR_TYPE,
        acr.WBS_ROLLUP_FLAG,
        acr.PRG_ROLLUP_FLAG,
        acr.CURR_RECORD_TYPE_ID,
        acr.CURRENCY_CODE,
        to_number(null)                            REVENUE,
        to_number(null)                            INITIAL_FUNDING_AMOUNT,
        to_number(null)                            INITIAL_FUNDING_COUNT,
        to_number(null)                            ADDITIONAL_FUNDING_AMOUNT,
        to_number(null)                            ADDITIONAL_FUNDING_COUNT,
        to_number(null)                            CANCELLED_FUNDING_AMOUNT,
        to_number(null)                            CANCELLED_FUNDING_COUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_AMOUNT,
        to_number(null)                            FUNDING_ADJUSTMENT_COUNT,
        to_number(null)                            REVENUE_WRITEOFF,
        to_number(null)                            AR_INVOICE_AMOUNT,    -- Bug 6689297
        to_number(null)                            AR_INVOICE_COUNT,     -- Bug 6689297
/*        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(pa_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_COUNT) AR_INVOICE_COUNT,  */
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_CASH_APPLIED_AMOUNT)
                                                   AR_CASH_APPLIED_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_INVOICE_WRITE_OFF_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_INVOICE_WRITE_OFF_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(pa_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               -acr.AR_INVOICE_WRITEOFF_COUNT),
               'SNAPSHOT', - acr.AR_INVOICE_WRITEOFF_COUNT)
                                                   AR_INVOICE_WRITEOFF_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', - acr.AR_CREDIT_MEMO_AMOUNT,
               'SNAPSHOT', to_number(null))        AR_CREDIT_MEMO_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(pa_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_CREDIT_MEMO_COUNT),
               'SNAPSHOT', - acr.AR_CREDIT_MEMO_COUNT)
                                                   AR_CREDIT_MEMO_COUNT,
        to_number(null)                            UNBILLED_RECEIVABLES,
        to_number(null)                            UNEARNED_REVENUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_AMOUNT)
                                                   AR_UNAPPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(pa_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_UNAPPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_UNAPPR_INVOICE_COUNT)
                                                   AR_UNAPPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_AMOUNT)
                                                   AR_APPR_INVOICE_AMOUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', decode(pa_cal.CAL_PERIOD_ID,
                                  acr.TIME_ID, to_number(null),
                                               - acr.AR_APPR_INVOICE_COUNT),
               'SNAPSHOT', - acr.AR_APPR_INVOICE_COUNT)
                                                   AR_APPR_INVOICE_COUNT,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_DUE)    AR_AMOUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_DUE)     AR_COUNT_DUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_AMOUNT_OVERDUE)AR_AMOUNT_OVERDUE,
        decode(invert.INVERT_ID,
               'ACTIVITY', to_number(null),
               'SNAPSHOT', - acr.AR_COUNT_OVERDUE) AR_COUNT_OVERDUE,
        to_number(null)                            CUSTOM1,
        to_number(null)                            CUSTOM2,
        to_number(null)                            CUSTOM3,
        to_number(null)                            CUSTOM4,
        to_number(null)                            CUSTOM5,
        to_number(null)                            CUSTOM6,
        to_number(null)                            CUSTOM7,
        to_number(null)                            CUSTOM8,
        to_number(null)                            CUSTOM9,
        to_number(null)                            CUSTOM10,
        to_number(null)                            CUSTOM11,
        to_number(null)                            CUSTOM12,
        to_number(null)                            CUSTOM13,
        to_number(null)                            CUSTOM14,
        to_number(null)                            CUSTOM15
      from
        PJI_PJP_PROJ_BATCH_MAP  map,
        PJI_AC_XBS_ACCUM_F      acr,
        PJI_AC_AGGR_PJP0        pjp0,    -- Bug 6689297
        PJI_TIME_CAL_RPT_STRUCT cal,
        PJI_ORG_EXTR_INFO       info,
        PJI_TIME_CAL_PERIOD_V   pa_cal,
        (
          select 'ACTIVITY' INVERT_ID from DUAL union all
          select 'SNAPSHOT' INVERT_ID from DUAL
        ) invert
      where
        l_extraction_type                <> 'PARTIAL'                     and
        map.WORKER_ID                    =  p_worker_id                   and
        acr.PROJECT_ID                   =  map.PROJECT_ID                and
        pjp0.WORKER_ID                   =  p_worker_id                   and    -- Bug 6689297
        acr.PROJECT_ID                   =  pjp0.PROJECT_ID               and    -- Bug 6689297
        acr.WBS_ROLLUP_FLAG              =  'N'                           and
        acr.PRG_ROLLUP_FLAG              =  'N'                           and
        acr.PROJECT_ORG_ID               =  info.ORG_ID                   and /*5377133 */
        acr.CALENDAR_TYPE                =  'P'                           and
        cal.REPORT_DATE                  =  trunc(pa_cal.START_DATE, 'J') and
        cal.CALENDAR_ID                  =  info.PA_CALENDAR_ID           and
        cal.PERIOD_TYPE_ID               =  acr.PERIOD_TYPE_ID            and
        cal.TIME_ID                      =  acr.TIME_ID                   and
        bitand(cal.RECORD_TYPE_ID, 1376) =  cal.RECORD_TYPE_ID            and
        pa_cal.CALENDAR_ID               =  info.PA_CALENDAR_ID           and
        sysdate between pa_cal.START_DATE and pa_cal.END_DATE             and
        abs(nvl(acr.AR_CASH_APPLIED_AMOUNT,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_AMOUNT,0)) +
          abs(nvl(acr.AR_AMOUNT_DUE,0)) +
          abs(nvl(acr.AR_AMOUNT_OVERDUE,0)) +
          abs(nvl(acr.AR_UNAPPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_APPR_INVOICE_COUNT,0)) +
          abs(nvl(acr.AR_COUNT_DUE,0)) +
          abs(nvl(acr.AR_COUNT_OVERDUE,0)) > 0
      )
    group by
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE
    having not
      (nvl(sum(REVENUE), 0)                     = 0 and
       nvl(sum(INITIAL_FUNDING_AMOUNT), 0)      = 0 and
       nvl(sum(INITIAL_FUNDING_COUNT), 0)       = 0 and
       nvl(sum(ADDITIONAL_FUNDING_AMOUNT), 0)   = 0 and
       nvl(sum(ADDITIONAL_FUNDING_COUNT), 0)    = 0 and
       nvl(sum(CANCELLED_FUNDING_AMOUNT), 0)    = 0 and
       nvl(sum(CANCELLED_FUNDING_COUNT), 0)     = 0 and
       nvl(sum(FUNDING_ADJUSTMENT_AMOUNT), 0)   = 0 and
       nvl(sum(FUNDING_ADJUSTMENT_COUNT), 0)    = 0 and
       nvl(sum(REVENUE_WRITEOFF), 0)            = 0 and
       nvl(sum(AR_INVOICE_AMOUNT), 0)           = 0 and
       nvl(sum(AR_INVOICE_COUNT), 0)            = 0 and
       nvl(sum(AR_CASH_APPLIED_AMOUNT), 0)      = 0 and
       nvl(sum(AR_INVOICE_WRITE_OFF_AMOUNT), 0) = 0 and
       nvl(sum(AR_INVOICE_WRITEOFF_COUNT), 0)   = 0 and
       nvl(sum(AR_CREDIT_MEMO_AMOUNT), 0)       = 0 and
       nvl(sum(AR_CREDIT_MEMO_COUNT), 0)        = 0 and
       nvl(sum(UNBILLED_RECEIVABLES), 0)        = 0 and
       nvl(sum(UNEARNED_REVENUE), 0)            = 0 and
       nvl(sum(AR_UNAPPR_INVOICE_AMOUNT), 0)    = 0 and
       nvl(sum(AR_UNAPPR_INVOICE_COUNT), 0)     = 0 and
       nvl(sum(AR_APPR_INVOICE_AMOUNT), 0)      = 0 and
       nvl(sum(AR_APPR_INVOICE_COUNT), 0)       = 0 and
       nvl(sum(AR_AMOUNT_DUE), 0)               = 0 and
       nvl(sum(AR_COUNT_DUE), 0)                = 0 and
       nvl(sum(AR_AMOUNT_OVERDUE), 0)           = 0 and
       nvl(sum(AR_COUNT_OVERDUE), 0)            = 0 and
       nvl(sum(CUSTOM1), 0)                     = 0 and
       nvl(sum(CUSTOM2), 0)                     = 0 and
       nvl(sum(CUSTOM3), 0)                     = 0 and
       nvl(sum(CUSTOM4), 0)                     = 0 and
       nvl(sum(CUSTOM5), 0)                     = 0 and
       nvl(sum(CUSTOM6), 0)                     = 0 and
       nvl(sum(CUSTOM7), 0)                     = 0 and
       nvl(sum(CUSTOM8), 0)                     = 0 and
       nvl(sum(CUSTOM9), 0)                     = 0 and
       nvl(sum(CUSTOM10), 0)                    = 0 and
       nvl(sum(CUSTOM11), 0)                    = 0 and
       nvl(sum(CUSTOM12), 0)                    = 0 and
       nvl(sum(CUSTOM13), 0)                    = 0 and
       nvl(sum(CUSTOM14), 0)                    = 0 and
       nvl(sum(CUSTOM15), 0)                    = 0);
end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_CUST_SLICES(p_worker_id);');

    commit;

  end AGGREGATE_AC_CUST_SLICES;


  -- -----------------------------------------------------
  -- procedure PULL_DANGLING_PLANS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PULL_DANGLING_PLANS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_DANGLING_PLANS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    IF (l_extraction_type = 'INCREMENTAL') THEN
      Pji_Fm_Plan_Maint.CREATE_SECONDARY_PVT;
      -- PJI_FM_PLAN_MAINT_PVT.PULL_DANGLING_PLANS; -- Removing redundant api nesting.
    END IF;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_DANGLING_PLANS(p_worker_id);');

    commit;

  end PULL_DANGLING_PLANS;


  -- -----------------------------------------------------
  -- procedure PULL_PLANS_FOR_PR
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PULL_PLANS_FOR_PR (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_code        varchar2(255);
    l_msg_data        varchar2(2000);

    l_plan_type_id    number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_PR(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'PARTIAL') then

      l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (l_process, 'PLAN_TYPE_ID');

      if (l_plan_type_id = -1) then
        l_plan_type_id := null;
      end if;

      PJI_FM_PLAN_MAINT.PULL_PLANS_FOR_PR(null,
                                          l_plan_type_id,
                                          'PLANTYPE',
                                          l_return_status,
                                          l_msg_code);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_PR(p_worker_id);');

    commit;

  end PULL_PLANS_FOR_PR;


  -- -----------------------------------------------------
  -- procedure PULL_PLANS_FOR_RBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure PULL_PLANS_FOR_RBS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_code        varchar2(255);
    l_msg_data        varchar2(2000);

    l_rbs_version_id  number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_RBS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'RBS') then

      l_rbs_version_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (l_process, 'RBS_VERSION_ID');

      PJI_FM_PLAN_MAINT.PULL_PLANS_FOR_PR(l_rbs_version_id,
                                          null,
                                          'RBS',
                                          l_return_status,
                                          l_msg_code);

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_RBS(p_worker_id);');

    commit;

  end PULL_PLANS_FOR_RBS;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_RBS_TOP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_RBS_TOP (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_TOP(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    insert into PJI_FP_AGGR_PJP1 pjp1_i
    (
      WORKER_ID,
      RECORD_TYPE,
      PRG_LEVEL,
      LINE_TYPE,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      PLAN_TYPE_CODE,
      RAW_COST,
      BRDN_COST,
      REVENUE,
      BILL_RAW_COST,
      BILL_BRDN_COST,
      BILL_LABOR_RAW_COST,
      BILL_LABOR_BRDN_COST,
      BILL_LABOR_HRS,
      EQUIPMENT_RAW_COST,
      EQUIPMENT_BRDN_COST,
      CAPITALIZABLE_RAW_COST,
      CAPITALIZABLE_BRDN_COST,
      LABOR_RAW_COST,
      LABOR_BRDN_COST,
      LABOR_HRS,
      LABOR_REVENUE,
      EQUIPMENT_HOURS,
      BILLABLE_EQUIPMENT_HOURS,
      SUP_INV_COMMITTED_COST,
      PO_COMMITTED_COST,
      PR_COMMITTED_COST,
      OTH_COMMITTED_COST,
      ACT_LABOR_HRS,
      ACT_EQUIP_HRS,
      ACT_LABOR_BRDN_COST,
      ACT_EQUIP_BRDN_COST,
      ACT_BRDN_COST,
      ACT_RAW_COST,
      ACT_REVENUE,
      ACT_LABOR_RAW_COST,
      ACT_EQUIP_RAW_COST,
      ETC_LABOR_HRS,
      ETC_EQUIP_HRS,
      ETC_LABOR_BRDN_COST,
      ETC_EQUIP_BRDN_COST,
      ETC_BRDN_COST,
      ETC_RAW_COST,
      ETC_LABOR_RAW_COST,
      ETC_EQUIP_RAW_COST,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    select
      p_worker_id                                     WORKER_ID,
      null                                            RECORD_TYPE,
      pjp1.PRG_LEVEL,
      pjp1.LINE_TYPE,
      pjp1.PROJECT_ID,
      pjp1.PROJECT_ORG_ID,
      pjp1.PROJECT_ORGANIZATION_ID,
      pjp1.PROJECT_ELEMENT_ID,
      pjp1.TIME_ID,
      pjp1.PERIOD_TYPE_ID,
      pjp1.CALENDAR_TYPE,
      pjp1.RBS_AGGR_LEVEL,
      pjp1.WBS_ROLLUP_FLAG,
      pjp1.PRG_ROLLUP_FLAG,
      pjp1.CURR_RECORD_TYPE_ID,
      pjp1.CURRENCY_CODE,
      pjp1.RBS_ELEMENT_ID,
      pjp1.RBS_VERSION_ID,
      pjp1.PLAN_VERSION_ID,
      pjp1.PLAN_TYPE_ID,
      pjp1.PLAN_TYPE_CODE,
      sum(pjp1.RAW_COST)                              RAW_COST,
      sum(pjp1.BRDN_COST)                             BRDN_COST,
      sum(pjp1.REVENUE)                               REVENUE,
      sum(pjp1.BILL_RAW_COST)                         BILL_RAW_COST,
      sum(pjp1.BILL_BRDN_COST)                        BILL_BRDN_COST,
      sum(pjp1.BILL_LABOR_RAW_COST)                   BILL_LABOR_RAW_COST,
      sum(pjp1.BILL_LABOR_BRDN_COST)                  BILL_LABOR_BRDN_COST,
      sum(pjp1.BILL_LABOR_HRS)                        BILL_LABOR_HRS,
      sum(pjp1.EQUIPMENT_RAW_COST)                    EQUIPMENT_RAW_COST,
      sum(pjp1.EQUIPMENT_BRDN_COST)                   EQUIPMENT_BRDN_COST,
      sum(pjp1.CAPITALIZABLE_RAW_COST)                CAPITALIZABLE_RAW_COST,
      sum(pjp1.CAPITALIZABLE_BRDN_COST)               CAPITALIZABLE_BRDN_COST,
      sum(pjp1.LABOR_RAW_COST)                        LABOR_RAW_COST,
      sum(pjp1.LABOR_BRDN_COST)                       LABOR_BRDN_COST,
      sum(pjp1.LABOR_HRS)                             LABOR_HRS,
      sum(pjp1.LABOR_REVENUE)                         LABOR_REVENUE,
      sum(pjp1.EQUIPMENT_HOURS)                       EQUIPMENT_HOURS,
      sum(pjp1.BILLABLE_EQUIPMENT_HOURS)              BILLABLE_EQUIPMENT_HOURS,
      sum(pjp1.SUP_INV_COMMITTED_COST)                SUP_INV_COMMITTED_COST,
      sum(pjp1.PO_COMMITTED_COST)                     PO_COMMITTED_COST,
      sum(pjp1.PR_COMMITTED_COST)                     PR_COMMITTED_COST,
      sum(pjp1.OTH_COMMITTED_COST)                    OTH_COMMITTED_COST,
      sum(pjp1.ACT_LABOR_HRS)                         ACT_LABOR_HRS,
      sum(pjp1.ACT_EQUIP_HRS)                         ACT_EQUIP_HRS,
      sum(pjp1.ACT_LABOR_BRDN_COST)                   ACT_LABOR_BRDN_COST,
      sum(pjp1.ACT_EQUIP_BRDN_COST)                   ACT_EQUIP_BRDN_COST,
      sum(pjp1.ACT_BRDN_COST)                         ACT_BRDN_COST,
      sum(pjp1.ACT_RAW_COST)                          ACT_RAW_COST,
      sum(pjp1.ACT_REVENUE)                           ACT_REVENUE,
      sum(pjp1.ACT_LABOR_RAW_COST)                    ACT_LABOR_RAW_COST,
      sum(pjp1.ACT_EQUIP_RAW_COST)                    ACT_EQUIP_RAW_COST,
      sum(pjp1.ETC_LABOR_HRS)                         ETC_LABOR_HRS,
      sum(pjp1.ETC_EQUIP_HRS)                         ETC_EQUIP_HRS,
      sum(pjp1.ETC_LABOR_BRDN_COST)                   ETC_LABOR_BRDN_COST,
      sum(pjp1.ETC_EQUIP_BRDN_COST)                   ETC_EQUIP_BRDN_COST,
      sum(pjp1.ETC_BRDN_COST)                         ETC_BRDN_COST,
      sum(pjp1.ETC_RAW_COST)                          ETC_RAW_COST,
      sum(pjp1.ETC_LABOR_RAW_COST)                    ETC_LABOR_RAW_COST,
      sum(pjp1.ETC_EQUIP_RAW_COST)                    ETC_EQUIP_RAW_COST,
      sum(pjp1.CUSTOM1)                               CUSTOM1,
      sum(pjp1.CUSTOM2)                               CUSTOM2,
      sum(pjp1.CUSTOM3)                               CUSTOM3,
      sum(pjp1.CUSTOM4)                               CUSTOM4,
      sum(pjp1.CUSTOM5)                               CUSTOM5,
      sum(pjp1.CUSTOM6)                               CUSTOM6,
      sum(pjp1.CUSTOM7)                               CUSTOM7,
      sum(pjp1.CUSTOM8)                               CUSTOM8,
      sum(pjp1.CUSTOM9)                               CUSTOM9,
      sum(pjp1.CUSTOM10)                              CUSTOM10,
      sum(pjp1.CUSTOM11)                              CUSTOM11,
      sum(pjp1.CUSTOM12)                              CUSTOM12,
      sum(pjp1.CUSTOM13)                              CUSTOM13,
      sum(pjp1.CUSTOM14)                              CUSTOM14,
      sum(pjp1.CUSTOM15)                              CUSTOM15
    from
      (
      select
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        'T'                                           RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        -1                                            RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        max(pjp1.RAW_COST)                            RAW_COST,
        max(pjp1.BRDN_COST)                           BRDN_COST,
        max(pjp1.REVENUE)                             REVENUE,
        max(pjp1.BILL_RAW_COST)                       BILL_RAW_COST,
        max(pjp1.BILL_BRDN_COST)                      BILL_BRDN_COST,
        max(pjp1.BILL_LABOR_RAW_COST)                 BILL_LABOR_RAW_COST,
        max(pjp1.BILL_LABOR_BRDN_COST)                BILL_LABOR_BRDN_COST,
        max(pjp1.BILL_LABOR_HRS)                      BILL_LABOR_HRS,
        max(pjp1.EQUIPMENT_RAW_COST)                  EQUIPMENT_RAW_COST,
        max(pjp1.EQUIPMENT_BRDN_COST)                 EQUIPMENT_BRDN_COST,
        max(pjp1.CAPITALIZABLE_RAW_COST)              CAPITALIZABLE_RAW_COST,
        max(pjp1.CAPITALIZABLE_BRDN_COST)             CAPITALIZABLE_BRDN_COST,
        max(pjp1.LABOR_RAW_COST)                      LABOR_RAW_COST,
        max(pjp1.LABOR_BRDN_COST)                     LABOR_BRDN_COST,
        max(pjp1.LABOR_HRS)                           LABOR_HRS,
        max(pjp1.LABOR_REVENUE)                       LABOR_REVENUE,
        max(pjp1.EQUIPMENT_HOURS)                     EQUIPMENT_HOURS,
        max(pjp1.BILLABLE_EQUIPMENT_HOURS)            BILLABLE_EQUIPMENT_HOURS,
        max(pjp1.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        max(pjp1.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        max(pjp1.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        max(pjp1.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        max(pjp1.ACT_LABOR_HRS)                       ACT_LABOR_HRS,
        max(pjp1.ACT_EQUIP_HRS)                       ACT_EQUIP_HRS,
        max(pjp1.ACT_LABOR_BRDN_COST)                 ACT_LABOR_BRDN_COST,
        max(pjp1.ACT_EQUIP_BRDN_COST)                 ACT_EQUIP_BRDN_COST,
        max(pjp1.ACT_BRDN_COST)                       ACT_BRDN_COST,
        max(pjp1.ACT_RAW_COST)                        ACT_RAW_COST,
        max(pjp1.ACT_REVENUE)                         ACT_REVENUE,
        max(pjp1.ACT_LABOR_RAW_COST)                  ACT_LABOR_RAW_COST,
        max(pjp1.ACT_EQUIP_RAW_COST)                  ACT_EQUIP_RAW_COST,
        max(pjp1.ETC_LABOR_HRS)                       ETC_LABOR_HRS,
        max(pjp1.ETC_EQUIP_HRS)                       ETC_EQUIP_HRS,
        max(pjp1.ETC_LABOR_BRDN_COST)                 ETC_LABOR_BRDN_COST,
        max(pjp1.ETC_EQUIP_BRDN_COST)                 ETC_EQUIP_BRDN_COST,
        max(pjp1.ETC_BRDN_COST)                       ETC_BRDN_COST,
        max(pjp1.ETC_RAW_COST)                        ETC_RAW_COST,
        max(pjp1.ETC_LABOR_RAW_COST)                  ETC_LABOR_RAW_COST,
        max(pjp1.ETC_EQUIP_RAW_COST)                  ETC_EQUIP_RAW_COST,
        max(pjp1.CUSTOM1)                             CUSTOM1,
        max(pjp1.CUSTOM2)                             CUSTOM2,
        max(pjp1.CUSTOM3)                             CUSTOM3,
        max(pjp1.CUSTOM4)                             CUSTOM4,
        max(pjp1.CUSTOM5)                             CUSTOM5,
        max(pjp1.CUSTOM6)                             CUSTOM6,
        max(pjp1.CUSTOM7)                             CUSTOM7,
        max(pjp1.CUSTOM8)                             CUSTOM8,
        max(pjp1.CUSTOM9)                             CUSTOM9,
        max(pjp1.CUSTOM10)                            CUSTOM10,
        max(pjp1.CUSTOM11)                            CUSTOM11,
        max(pjp1.CUSTOM12)                            CUSTOM12,
        max(pjp1.CUSTOM13)                            CUSTOM13,
        max(pjp1.CUSTOM14)                            CUSTOM14,
        max(pjp1.CUSTOM15)                            CUSTOM15
      from
        (
        select
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          -1                                          RBS_ELEMENT_ID,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE,
          sum(pjp1.RAW_COST)                          RAW_COST,
          sum(pjp1.BRDN_COST)                         BRDN_COST,
          sum(pjp1.REVENUE)                           REVENUE,
          sum(pjp1.BILL_RAW_COST)                     BILL_RAW_COST,
          sum(pjp1.BILL_BRDN_COST)                    BILL_BRDN_COST,
          sum(pjp1.BILL_LABOR_RAW_COST)               BILL_LABOR_RAW_COST,
          sum(pjp1.BILL_LABOR_BRDN_COST)              BILL_LABOR_BRDN_COST,
          sum(pjp1.BILL_LABOR_HRS)                    BILL_LABOR_HRS,
          sum(pjp1.EQUIPMENT_RAW_COST)                EQUIPMENT_RAW_COST,
          sum(pjp1.EQUIPMENT_BRDN_COST)               EQUIPMENT_BRDN_COST,
          sum(pjp1.CAPITALIZABLE_RAW_COST)            CAPITALIZABLE_RAW_COST,
          sum(pjp1.CAPITALIZABLE_BRDN_COST)           CAPITALIZABLE_BRDN_COST,
          sum(pjp1.LABOR_RAW_COST)                    LABOR_RAW_COST,
          sum(pjp1.LABOR_BRDN_COST)                   LABOR_BRDN_COST,
          sum(pjp1.LABOR_HRS)                         LABOR_HRS,
          sum(pjp1.LABOR_REVENUE)                     LABOR_REVENUE,
          sum(pjp1.EQUIPMENT_HOURS)                   EQUIPMENT_HOURS,
          sum(pjp1.BILLABLE_EQUIPMENT_HOURS)          BILLABLE_EQUIPMENT_HOURS,
          sum(pjp1.SUP_INV_COMMITTED_COST)            SUP_INV_COMMITTED_COST,
          sum(pjp1.PO_COMMITTED_COST)                 PO_COMMITTED_COST,
          sum(pjp1.PR_COMMITTED_COST)                 PR_COMMITTED_COST,
          sum(pjp1.OTH_COMMITTED_COST)                OTH_COMMITTED_COST,
          sum(pjp1.ACT_LABOR_HRS)                     ACT_LABOR_HRS,
          sum(pjp1.ACT_EQUIP_HRS)                     ACT_EQUIP_HRS,
          sum(pjp1.ACT_LABOR_BRDN_COST)               ACT_LABOR_BRDN_COST,
          sum(pjp1.ACT_EQUIP_BRDN_COST)               ACT_EQUIP_BRDN_COST,
          sum(pjp1.ACT_BRDN_COST)                     ACT_BRDN_COST,
          sum(pjp1.ACT_RAW_COST)                      ACT_RAW_COST,
          sum(pjp1.ACT_REVENUE)                       ACT_REVENUE,
          sum(pjp1.ACT_LABOR_RAW_COST)                ACT_LABOR_RAW_COST,
          sum(pjp1.ACT_EQUIP_RAW_COST)                ACT_EQUIP_RAW_COST,
          sum(pjp1.ETC_LABOR_HRS)                     ETC_LABOR_HRS,
          sum(pjp1.ETC_EQUIP_HRS)                     ETC_EQUIP_HRS,
          sum(pjp1.ETC_LABOR_BRDN_COST)               ETC_LABOR_BRDN_COST,
          sum(pjp1.ETC_EQUIP_BRDN_COST)               ETC_EQUIP_BRDN_COST,
          sum(pjp1.ETC_BRDN_COST)                     ETC_BRDN_COST,
          sum(pjp1.ETC_RAW_COST)                      ETC_RAW_COST,
          sum(pjp1.ETC_LABOR_RAW_COST)                ETC_LABOR_RAW_COST,
          sum(pjp1.ETC_EQUIP_RAW_COST)                ETC_EQUIP_RAW_COST,
          sum(pjp1.CUSTOM1)                           CUSTOM1,
          sum(pjp1.CUSTOM2)                           CUSTOM2,
          sum(pjp1.CUSTOM3)                           CUSTOM3,
          sum(pjp1.CUSTOM4)                           CUSTOM4,
          sum(pjp1.CUSTOM5)                           CUSTOM5,
          sum(pjp1.CUSTOM6)                           CUSTOM6,
          sum(pjp1.CUSTOM7)                           CUSTOM7,
          sum(pjp1.CUSTOM8)                           CUSTOM8,
          sum(pjp1.CUSTOM9)                           CUSTOM9,
          sum(pjp1.CUSTOM10)                          CUSTOM10,
          sum(pjp1.CUSTOM11)                          CUSTOM11,
          sum(pjp1.CUSTOM12)                          CUSTOM12,
          sum(pjp1.CUSTOM13)                          CUSTOM13,
          sum(pjp1.CUSTOM14)                          CUSTOM14,
          sum(pjp1.CUSTOM15)                          CUSTOM15
        from
          PJI_FP_AGGR_PJP1 pjp1,
          (
          select
            distinct
            to_number(log.EVENT_OBJECT)          RBS_VERSION_ID,
            to_number(log.ATTRIBUTE1)            PROJECT_ID
          from
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID = p_worker_id and
            log.EVENT_TYPE = 'RBS_ASSOC'
          ) log
        where
          pjp1.WORKER_ID      = p_worker_id            and
          pjp1.PROJECT_ID     = log.PROJECT_ID     (+) and
          pjp1.RBS_VERSION_ID = log.RBS_VERSION_ID (+) and
          log.PROJECT_ID      is null
        group by
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE
      ) pjp1
      group by
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE
      ) pjp1
    group by
      pjp1.PRG_LEVEL,
      pjp1.LINE_TYPE,
      pjp1.PROJECT_ID,
      pjp1.PROJECT_ORG_ID,
      pjp1.PROJECT_ORGANIZATION_ID,
      pjp1.PROJECT_ELEMENT_ID,
      pjp1.TIME_ID,
      pjp1.PERIOD_TYPE_ID,
      pjp1.CALENDAR_TYPE,
      pjp1.RBS_AGGR_LEVEL,
      pjp1.WBS_ROLLUP_FLAG,
      pjp1.PRG_ROLLUP_FLAG,
      pjp1.CURR_RECORD_TYPE_ID,
      pjp1.CURRENCY_CODE,
      pjp1.RBS_ELEMENT_ID,
      pjp1.RBS_VERSION_ID,
      pjp1.PLAN_VERSION_ID,
      pjp1.PLAN_TYPE_ID,
      pjp1.PLAN_TYPE_CODE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_TOP(p_worker_id);');

    commit;

  end ROLLUP_FPR_RBS_TOP;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_WBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_WBS (p_worker_id in number default null) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_fpm_upgrade     varchar2(30);
    l_max_level       number;
    l_level           number;
    l_step_seq        number;
    l_level_seq       number;
    l_count           number;
    l_partial_mode    varchar2(30);

  begin

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(p_worker_id);')) then
        return;
      end if;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      l_fpm_upgrade := nvl(PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE'), 'C');

      select decode(l_extraction_type,'PARTIAL','PARTIAL',NULL)
      into l_partial_mode
      from dual;

      -- allow recovery after each level is processed

      select
        STEP_SEQ
      into
        l_step_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME = 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(p_worker_id);';

      select
        count(*)
      into
        l_count
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_FPR_WBS%';

      if (l_count = 0) then

        select /*+ ordered index(den PJI_XBS_DENORM_N3) use_hash(den) */    /* Modified for Bug 7669026 */
          nvl(max(den.SUP_LEVEL), 0)
        into
          l_level
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PJI_XBS_DENORM den
        where
          map.WORKER_ID      = p_worker_id    and
          den.STRUCT_TYPE    = 'PRG'          and
          den.SUB_LEVEL      = den.SUP_LEVEL  and
          den.SUP_PROJECT_ID = map.PROJECT_ID;

        PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                               'MAX_PROGRAM_LEVEL',
                                               l_level);

        for x in 1 .. l_level loop

          insert into PJI_SYSTEM_PRC_STATUS
          (
            PROCESS_NAME,
            STEP_SEQ,
            STEP_STATUS,
            STEP_NAME,
            START_DATE,
            END_DATE
          )
          select
            l_process                                             PROCESS_NAME,
            to_char(l_step_seq + x / 1000)                        STEP_SEQ,
            null                                                  STEP_STATUS,
            'ROLLUP_FPR_WBS - level ' || to_char(l_level - x + 1) STEP_NAME,
            null                                                  START_DATE,
            null                                                  END_DATE
          from
            DUAL;

        end loop;

      end if;

      l_max_level := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                     (l_process, 'MAX_PROGRAM_LEVEL');

      select
        nvl(to_number(min(STEP_SEQ)), 0)
      into
        l_level_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_FPR_WBS%' and
        STEP_STATUS is null;

      if (l_level_seq = 0) then
        l_level := 0;
      else
        l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
      end if;

      while (l_level > 0) loop

        update PJI_SYSTEM_PRC_STATUS
        set    START_DATE = sysdate
        where  PROCESS_NAME = l_process and
               STEP_SEQ = l_level_seq;

        -- rollup project hiearchy

/* Call to Paritioned procedure for bug 7551819 */
        PJI_PROCESS_UTIL.EXECUTE_ROLLUP_FPR_WBS(p_worker_id,
                                                l_level,
                                                l_partial_mode,
                                                l_fpm_upgrade);
/* Commented for bug 7551819 */
--        insert /*+ parallel(pjp1_in)
  --                 noappend(pjp1_in) */ into PJI_FP_AGGR_PJP1 pjp1_in    -- changed for bug 5927368
	/*(
          WORKER_ID,
          RECORD_TYPE,
          PRG_LEVEL,
          LINE_TYPE,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          PROJECT_ELEMENT_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          RBS_AGGR_LEVEL,
          WBS_ROLLUP_FLAG,
          PRG_ROLLUP_FLAG,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          RBS_ELEMENT_ID,
          RBS_VERSION_ID,
          PLAN_VERSION_ID,
          PLAN_TYPE_ID,
          PLAN_TYPE_CODE,
          RAW_COST,
          BRDN_COST,
          REVENUE,
          BILL_RAW_COST,
          BILL_BRDN_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BRDN_COST,
          BILL_LABOR_HRS,
          EQUIPMENT_RAW_COST,
          EQUIPMENT_BRDN_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BRDN_COST,
          LABOR_HRS,
          LABOR_REVENUE,
          EQUIPMENT_HOURS,
          BILLABLE_EQUIPMENT_HOURS,
          SUP_INV_COMMITTED_COST,
          PO_COMMITTED_COST,
          PR_COMMITTED_COST,
          OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
          ACT_EQUIP_HRS,
          ACT_LABOR_BRDN_COST,
          ACT_EQUIP_BRDN_COST,
          ACT_BRDN_COST,
          ACT_RAW_COST,
          ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
          ETC_LABOR_HRS,
          ETC_EQUIP_HRS,
          ETC_LABOR_BRDN_COST,
          ETC_EQUIP_BRDN_COST,
          ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15
        )
        select
          pjp1_i.WORKER_ID,
          pjp1_i.RECORD_TYPE,
          pjp1_i.PRG_LEVEL,
          pjp1_i.LINE_TYPE,
          pjp1_i.PROJECT_ID,
          pjp1_i.PROJECT_ORG_ID,
          pjp1_i.PROJECT_ORGANIZATION_ID,
          pjp1_i.PROJECT_ELEMENT_ID,
          pjp1_i.TIME_ID,
          pjp1_i.PERIOD_TYPE_ID,
          pjp1_i.CALENDAR_TYPE,
          pjp1_i.RBS_AGGR_LEVEL,
          pjp1_i.WBS_ROLLUP_FLAG,
          pjp1_i.PRG_ROLLUP_FLAG,
          pjp1_i.CURR_RECORD_TYPE_ID,
          pjp1_i.CURRENCY_CODE,
          pjp1_i.RBS_ELEMENT_ID,
          pjp1_i.RBS_VERSION_ID,
          pjp1_i.PLAN_VERSION_ID,
          pjp1_i.PLAN_TYPE_ID,
          pjp1_i.PLAN_TYPE_CODE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.RAW_COST))                    RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BRDN_COST))                   BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.REVENUE))                     REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILL_RAW_COST))               BILL_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILL_BRDN_COST))              BILL_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILL_LABOR_RAW_COST))         BILL_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILL_LABOR_BRDN_COST))        BILL_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILL_LABOR_HRS))              BILL_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.EQUIPMENT_RAW_COST))          EQUIPMENT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.EQUIPMENT_BRDN_COST))         EQUIPMENT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.CAPITALIZABLE_RAW_COST))      CAPITALIZABLE_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.CAPITALIZABLE_BRDN_COST))     CAPITALIZABLE_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.LABOR_RAW_COST))              LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.LABOR_BRDN_COST))             LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.LABOR_HRS))                   LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.LABOR_REVENUE))               LABOR_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.EQUIPMENT_HOURS))             EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.BILLABLE_EQUIPMENT_HOURS))    BILLABLE_EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.SUP_INV_COMMITTED_COST))      SUP_INV_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.PO_COMMITTED_COST))           PO_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.PR_COMMITTED_COST))           PR_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED
                          || '_' || l_fpm_upgrade
                          || '_' || l_partial_mode,
                        'LW_N_Y_Y_C_', to_number(null),
                 pjp1_i.OTH_COMMITTED_COST))          OTH_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_LABOR_HRS)       ACT_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_EQUIP_HRS)       ACT_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_LABOR_BRDN_COST) ACT_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_EQUIP_BRDN_COST) ACT_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_BRDN_COST)       ACT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_RAW_COST)        ACT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_REVENUE)         ACT_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_LABOR_RAW_COST)  ACT_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ACT_EQUIP_RAW_COST)  ACT_EQUIP_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_LABOR_HRS)       ETC_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_EQUIP_HRS)       ETC_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_LABOR_BRDN_COST) ETC_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_EQUIP_BRDN_COST) ETC_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_BRDN_COST)       ETC_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_RAW_COST)        ETC_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_LABOR_RAW_COST)  ETC_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE
                   || '_' || l_partial_mode,
                 'LW_N_Y__', to_number(null),
                          pjp1_i.ETC_EQUIP_RAW_COST)  ETC_EQUIP_RAW_COST,
          pjp1_i.CUSTOM1,
          pjp1_i.CUSTOM2,
          pjp1_i.CUSTOM3,
          pjp1_i.CUSTOM4,
          pjp1_i.CUSTOM5,
          pjp1_i.CUSTOM6,
          pjp1_i.CUSTOM7,
          pjp1_i.CUSTOM8,
          pjp1_i.CUSTOM9,
          pjp1_i.CUSTOM10,
          pjp1_i.CUSTOM11,
          pjp1_i.CUSTOM12,
          pjp1_i.CUSTOM13,
          pjp1_i.CUSTOM14,
          pjp1_i.CUSTOM15
        from
          (
        select
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y')                INSERT_FLAG,
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE)           SUB_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE)           SUP_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG)SUP_VER_ENABLED,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null))              SUP_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null))              SUP_EMT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null))              SUP_WP_FLAG,
          p_worker_id                                 WORKER_ID,
          'W'                                         RECORD_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL)              PRG_LEVEL,
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID)  PROJECT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID)              PROJECT_ORG_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID)     PROJECT_ORGANIZATION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID)                   PROJECT_ELEMENT_ID,
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N')            WBS_ROLLUP_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y')            PRG_ROLLUP_FLAG,
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)) PLAN_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID))    PLAN_TYPE_ID,
          pjp.PLAN_TYPE_CODE,
          sum(pjp.RAW_COST)                           RAW_COST,
          sum(pjp.BRDN_COST)                          BRDN_COST,
          sum(pjp.REVENUE)                            REVENUE,
          sum(pjp.BILL_RAW_COST)                      BILL_RAW_COST,
          sum(pjp.BILL_BRDN_COST)                     BILL_BRDN_COST,
          sum(pjp.BILL_LABOR_RAW_COST)                BILL_LABOR_RAW_COST,
          sum(pjp.BILL_LABOR_BRDN_COST)               BILL_LABOR_BRDN_COST,
          sum(pjp.BILL_LABOR_HRS)                     BILL_LABOR_HRS,
          sum(pjp.EQUIPMENT_RAW_COST)                 EQUIPMENT_RAW_COST,
          sum(pjp.EQUIPMENT_BRDN_COST)                EQUIPMENT_BRDN_COST,
          sum(pjp.CAPITALIZABLE_RAW_COST)             CAPITALIZABLE_RAW_COST,
          sum(pjp.CAPITALIZABLE_BRDN_COST)            CAPITALIZABLE_BRDN_COST,
          sum(pjp.LABOR_RAW_COST)                     LABOR_RAW_COST,
          sum(pjp.LABOR_BRDN_COST)                    LABOR_BRDN_COST,
          sum(pjp.LABOR_HRS)                          LABOR_HRS,
          sum(pjp.LABOR_REVENUE)                      LABOR_REVENUE,
          sum(pjp.EQUIPMENT_HOURS)                    EQUIPMENT_HOURS,
          sum(pjp.BILLABLE_EQUIPMENT_HOURS)           BILLABLE_EQUIPMENT_HOURS,
          sum(pjp.SUP_INV_COMMITTED_COST)             SUP_INV_COMMITTED_COST,
          sum(pjp.PO_COMMITTED_COST)                  PO_COMMITTED_COST,
          sum(pjp.PR_COMMITTED_COST)                  PR_COMMITTED_COST,
          sum(pjp.OTH_COMMITTED_COST)                 OTH_COMMITTED_COST,
          sum(pjp.ACT_LABOR_HRS)                      ACT_LABOR_HRS,
          sum(pjp.ACT_EQUIP_HRS)                      ACT_EQUIP_HRS,
          sum(pjp.ACT_LABOR_BRDN_COST)                ACT_LABOR_BRDN_COST,
          sum(pjp.ACT_EQUIP_BRDN_COST)                ACT_EQUIP_BRDN_COST,
          sum(pjp.ACT_BRDN_COST)                      ACT_BRDN_COST,
          sum(pjp.ACT_RAW_COST)                       ACT_RAW_COST,
          sum(pjp.ACT_REVENUE)                        ACT_REVENUE,
          sum(pjp.ACT_LABOR_RAW_COST)                 ACT_LABOR_RAW_COST,
          sum(pjp.ACT_EQUIP_RAW_COST)                 ACT_EQUIP_RAW_COST,
          sum(pjp.ETC_LABOR_HRS)                      ETC_LABOR_HRS,
          sum(pjp.ETC_EQUIP_HRS)                      ETC_EQUIP_HRS,
          sum(pjp.ETC_LABOR_BRDN_COST)                ETC_LABOR_BRDN_COST,
          sum(pjp.ETC_EQUIP_BRDN_COST)                ETC_EQUIP_BRDN_COST,
          sum(pjp.ETC_BRDN_COST)                      ETC_BRDN_COST,
          sum(pjp.ETC_RAW_COST)                       ETC_RAW_COST,
          sum(pjp.ETC_LABOR_RAW_COST)                 ETC_LABOR_RAW_COST,
          sum(pjp.ETC_EQUIP_RAW_COST)                 ETC_EQUIP_RAW_COST,
          sum(pjp.CUSTOM1)                            CUSTOM1,
          sum(pjp.CUSTOM2)                            CUSTOM2,
          sum(pjp.CUSTOM3)                            CUSTOM3,
          sum(pjp.CUSTOM4)                            CUSTOM4,
          sum(pjp.CUSTOM5)                            CUSTOM5,
          sum(pjp.CUSTOM6)                            CUSTOM6,
          sum(pjp.CUSTOM7)                            CUSTOM7,
          sum(pjp.CUSTOM8)                            CUSTOM8,
          sum(pjp.CUSTOM9)                            CUSTOM9,
          sum(pjp.CUSTOM10)                           CUSTOM10,
          sum(pjp.CUSTOM11)                           CUSTOM11,
          sum(pjp.CUSTOM12)                           CUSTOM12,
          sum(pjp.CUSTOM13)                           CUSTOM13,
          sum(pjp.CUSTOM14)                           CUSTOM14,
          sum(pjp.CUSTOM15)                           CUSTOM15
        from
          (
          select /*+ ordered index(wbs PA_XBS_DENORM_N2) */
                 -- get incremental task level amounts from source and
                 -- program rollup amounts from interim
            /*to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            decode(wbs_hdr.WP_FLAG
                     || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                     || '_' || nvl(fin_plan.INVERT_ID, 'PRJ'),
                   'N_1_PRJ', 'N',
                   'N_-1_PRG', 'N',
                   decode(top_slice.INVERT_ID,
                          'PRJ', 'Y',
                          decode(wbs.SUB_LEVEL,
                                 1, 'Y', 'N')))       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(wbs_hdr.WP_FLAG
                                 || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                                 || '_' || fin_plan.INVERT_ID,
                               'N_1_PRG', decode(top_slice.INVERT_ID,
                                                 'PRJ', 'Y',
                                                 decode(wbs.SUB_LEVEL,
                                                        1, 'Y', 'N')),
                               'N_-1_PRG', 'N',
                               decode(wbs_hdr.WP_FLAG
                                        || '_' || fin_plan.INVERT_ID
                                        || '_' || fin_plan.CB
                                        || '_' || fin_plan.CO
                                        || '_'
                                        || to_char(fin_plan.PLAN_VERSION_ID),
                                      'N_PRJ_Y_Y_-4', 'N',
                                                      'Y'))
                  )                                   INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', fin_plan.PLAN_VERSION_ID,
                            pjp1.PLAN_VERSION_ID)     PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1   pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PA_XBS_DENORM      wbs,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL
            ) fin_plan,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            ((wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1) or
             (wbs.SUP_LEVEL <> wbs.SUB_LEVEL))                     and
            wbs.STRUCT_VERSION_ID   =  prg.SUP_ID                  and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            pjp1.WORKER_ID          =  p_worker_id                 and
            pjp1.PRG_LEVEL          in (0, l_level)                and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')                  and
            pjp1.WBS_ROLLUP_FLAG    =  'N'                         and
            pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                  and
            pjp1.PROJECT_ID         =  wbs_hdr.PROJECT_ID          and
            pjp1.PLAN_VERSION_ID    =  wbs_hdr.PLAN_VERSION_ID     and
            pjp1.PLAN_TYPE_CODE     =  wbs_hdr.PLAN_TYPE_CODE      and
            decode(pjp1.PLAN_VERSION_ID,
                   -3, pjp1.PLAN_TYPE_ID,
                   -4, pjp1.PLAN_TYPE_ID,
                       -1)          =  decode(pjp1.PLAN_VERSION_ID,
                                              -3, wbs_hdr.PLAN_TYPE_ID,
                                              -4, wbs_hdr.PLAN_TYPE_ID,
                                                  -1)              and
            wbs.STRUCT_VERSION_ID   =  wbs_hdr.WBS_VERSION_ID      and
            pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID              and
            wbs_hdr.CB_FLAG         =  fin_plan.CB             (+) and
            wbs_hdr.CO_FLAG         =  fin_plan.CO             (+) and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+)
          union all
          select /*+ ordered */
                 -- get incremental project level amounts from source
            /*to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            'Y'                                       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(fin_plan.PLAN_VERSION_ID,
                               null, 'N', 'Y'))       INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            pjp1.PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, pjp1.PLAN_VERSION_ID,
                               -2, pjp1.PLAN_VERSION_ID,
                               -3, pjp1.PLAN_VERSION_ID, -- won't exist
                               -4, pjp1.PLAN_VERSION_ID, -- won't exist
                                   fin_plan.PLAN_VERSION_ID),
                        pjp1.PLAN_VERSION_ID)         PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1   pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB_FLAG,
                     'N' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'N' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL
            ) fin_plan
          where
            prg.STRUCT_TYPE         = 'PRG'                    and
            prg.SUP_LEVEL           = l_level                  and
            prg.SUB_LEVEL           = l_level                  and
            pjp1.WORKER_ID          = p_worker_id              and
            pjp1.PROJECT_ID         = prg.SUP_PROJECT_ID       and
            pjp1.PROJECT_ELEMENT_ID = prg.SUP_EMT_ID           and
            pjp1.PRG_LEVEL          = 0                        and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')              and
            pjp1.WBS_ROLLUP_FLAG    = 'N'                      and
            pjp1.PRG_ROLLUP_FLAG    = 'N'                      and
            wbs_hdr.PROJECT_ID      = pjp1.PROJECT_ID          and
            wbs_hdr.PLAN_VERSION_ID = pjp1.PLAN_VERSION_ID     and
            wbs_hdr.PLAN_TYPE_CODE  = pjp1.PLAN_TYPE_CODE      and
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, 'Y',
                               -2, 'Y',
                               -3, 'Y', -- won't exist
                               -4, 'Y', -- won't exist
                                   decode(wbs_hdr.CB_FLAG || '_' ||
                                          wbs_hdr.CO_FLAG,
                                          'Y_Y', 'Y',
                                          'N_Y', 'Y',
                                          'Y_N', 'Y',
                                                 'N')),
                        'Y')        =  'Y'                     and
            wbs_hdr.WBS_VERSION_ID  = prg.SUP_ID               and
            wbs_hdr.CB_FLAG         = fin_plan.CB_FLAG     (+) and
            wbs_hdr.CO_FLAG         = fin_plan.CO_FLAG     (+)
          union all
          select /*+ ordered
                     index(fpr PJI_FP_XBS_ACCUM_F_N1) */
                 -- get delta task level amounts from Reporting Lines
            /*to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            decode(log.EVENT_TYPE,
                   'WBS_CHANGE', 'Y',
                   'WBS_PUBLISH', 'N')                PUSHUP_FLAG,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', decode(top_slice.INVERT_ID,
                                   'PRJ', 'Y',
                                   decode(wbs.SUB_LEVEL,
                                          1, 'Y', 'N')),
                   decode(wbs_hdr.WP_FLAG
                            || '_' || fin_plan.INVERT_ID
                            || '_' || fin_plan.CB
                            || '_' || fin_plan.CO
                            || '_' || to_char(fin_plan.PLAN_VERSION_ID),
                          'N_PRJ_Y_Y_-4', 'N',
                                          'Y'))       INSERT_FLAG,
            fpr.PROJECT_ID,
            fpr.PROJECT_ORG_ID,
            fpr.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            fpr.TIME_ID,
            fpr.PERIOD_TYPE_ID,
            fpr.CALENDAR_TYPE,
            fpr.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            fpr.PRG_ROLLUP_FLAG,
            fpr.CURR_RECORD_TYPE_ID,
            fpr.CURRENCY_CODE,
            fpr.RBS_ELEMENT_ID,
            fpr.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', fin_plan.PLAN_VERSION_ID,
                            fpr.PLAN_VERSION_ID)      PLAN_VERSION_ID,
            fpr.PLAN_TYPE_ID,
            fpr.PLAN_TYPE_CODE,
            wbs.SIGN * fpr.RAW_COST                   RAW_COST,
            wbs.SIGN * fpr.BRDN_COST                  BRDN_COST,
            wbs.SIGN * fpr.REVENUE                    REVENUE,
            wbs.SIGN * fpr.BILL_RAW_COST              BILL_RAW_COST,
            wbs.SIGN * fpr.BILL_BRDN_COST             BILL_BRDN_COST,
            wbs.SIGN * fpr.BILL_LABOR_RAW_COST        BILL_LABOR_RAW_COST,
            wbs.SIGN * fpr.BILL_LABOR_BRDN_COST       BILL_LABOR_BRDN_COST,
            wbs.SIGN * fpr.BILL_LABOR_HRS             BILL_LABOR_HRS,
            wbs.SIGN * fpr.EQUIPMENT_RAW_COST         EQUIPMENT_RAW_COST,
            wbs.SIGN * fpr.EQUIPMENT_BRDN_COST        EQUIPMENT_BRDN_COST,
            wbs.SIGN * fpr.CAPITALIZABLE_RAW_COST     CAPITALIZABLE_RAW_COST,
            wbs.SIGN * fpr.CAPITALIZABLE_BRDN_COST    CAPITALIZABLE_BRDN_COST,
            wbs.SIGN * fpr.LABOR_RAW_COST             LABOR_RAW_COST,
            wbs.SIGN * fpr.LABOR_BRDN_COST            LABOR_BRDN_COST,
            wbs.SIGN * fpr.LABOR_HRS                  LABOR_HRS,
            wbs.SIGN * fpr.LABOR_REVENUE              LABOR_REVENUE,
            wbs.SIGN * fpr.EQUIPMENT_HOURS            EQUIPMENT_HOURS,
            wbs.SIGN * fpr.BILLABLE_EQUIPMENT_HOURS   BILLABLE_EQUIPMENT_HOURS,
            wbs.SIGN * fpr.SUP_INV_COMMITTED_COST     SUP_INV_COMMITTED_COST,
            wbs.SIGN * fpr.PO_COMMITTED_COST          PO_COMMITTED_COST,
            wbs.SIGN * fpr.PR_COMMITTED_COST          PR_COMMITTED_COST,
            wbs.SIGN * fpr.OTH_COMMITTED_COST         OTH_COMMITTED_COST,
            wbs.SIGN * fpr.ACT_LABOR_HRS              ACT_LABOR_HRS,
            wbs.SIGN * fpr.ACT_EQUIP_HRS              ACT_EQUIP_HRS,
            wbs.SIGN * fpr.ACT_LABOR_BRDN_COST        ACT_LABOR_BRDN_COST,
            wbs.SIGN * fpr.ACT_EQUIP_BRDN_COST        ACT_EQUIP_BRDN_COST,
            wbs.SIGN * fpr.ACT_BRDN_COST              ACT_BRDN_COST,
            wbs.SIGN * fpr.ACT_RAW_COST               ACT_RAW_COST,
            wbs.SIGN * fpr.ACT_REVENUE                ACT_REVENUE,
            wbs.SIGN * fpr.ACT_LABOR_RAW_COST         ACT_LABOR_RAW_COST,
            wbs.SIGN * fpr.ACT_EQUIP_RAW_COST         ACT_EQUIP_RAW_COST,
            wbs.SIGN * fpr.ETC_LABOR_HRS              ETC_LABOR_HRS,
            wbs.SIGN * fpr.ETC_EQUIP_HRS              ETC_EQUIP_HRS,
            wbs.SIGN * fpr.ETC_LABOR_BRDN_COST        ETC_LABOR_BRDN_COST,
            wbs.SIGN * fpr.ETC_EQUIP_BRDN_COST        ETC_EQUIP_BRDN_COST,
            wbs.SIGN * fpr.ETC_BRDN_COST              ETC_BRDN_COST,
            wbs.SIGN * fpr.ETC_RAW_COST               ETC_RAW_COST,
            wbs.SIGN * fpr.ETC_LABOR_RAW_COST         ETC_LABOR_RAW_COST,
            wbs.SIGN * fpr.ETC_EQUIP_RAW_COST         ETC_EQUIP_RAW_COST,
            wbs.SIGN * fpr.CUSTOM1                    CUSTOM1,
            wbs.SIGN * fpr.CUSTOM2                    CUSTOM2,
            wbs.SIGN * fpr.CUSTOM3                    CUSTOM3,
            wbs.SIGN * fpr.CUSTOM4                    CUSTOM4,
            wbs.SIGN * fpr.CUSTOM5                    CUSTOM5,
            wbs.SIGN * fpr.CUSTOM6                    CUSTOM6,
            wbs.SIGN * fpr.CUSTOM7                    CUSTOM7,
            wbs.SIGN * fpr.CUSTOM8                    CUSTOM8,
            wbs.SIGN * fpr.CUSTOM9                    CUSTOM9,
            wbs.SIGN * fpr.CUSTOM10                   CUSTOM10,
            wbs.SIGN * fpr.CUSTOM11                   CUSTOM11,
            wbs.SIGN * fpr.CUSTOM12                   CUSTOM12,
            wbs.SIGN * fpr.CUSTOM13                   CUSTOM13,
            wbs.SIGN * fpr.CUSTOM14                   CUSTOM14,
            wbs.SIGN * fpr.CUSTOM15                   CUSTOM15
          from
            PJI_PA_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            PJI_XBS_DENORM_DELTA   wbs,
            PJI_XBS_DENORM         prg,
            PJI_FP_XBS_ACCUM_F     fpr,
            (
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL
            ) fin_plan,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.WORKER_ID           =  p_worker_id                 and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            log.WORKER_ID           =  p_worker_id                 and
            log.EVENT_ID            =  wbs.EVENT_ID                and
            log.EVENT_TYPE          in ('WBS_CHANGE',
                                        'WBS_PUBLISH')             and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1              and
            wbs_hdr.PLAN_VERSION_ID =  log.ATTRIBUTE3              and
            wbs_hdr.WBS_VERSION_ID  =  wbs.STRUCT_VERSION_ID       and
            wbs_hdr.PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                  and
            fpr.RBS_AGGR_LEVEL      =  'T'                         and
            fpr.WBS_ROLLUP_FLAG     =  'N'                         and
            fpr.PRG_ROLLUP_FLAG     in ('Y', 'N')                  and
            fpr.PROJECT_ID          =  wbs.SUP_PROJECT_ID          and
            fpr.PROJECT_ELEMENT_ID  =  wbs.SUB_EMT_ID              and
            fpr.PROJECT_ID          =  wbs_hdr.PROJECT_ID          and
            fpr.PLAN_VERSION_ID     =  wbs_hdr.PLAN_VERSION_ID     and
            fpr.PLAN_TYPE_CODE      =  wbs_hdr.PLAN_TYPE_CODE      and
            decode(fpr.PLAN_VERSION_ID,
                   -3, fpr.PLAN_TYPE_ID,
                   -4, fpr.PLAN_TYPE_ID,
                       -1)          =  decode(fpr.PLAN_VERSION_ID,
                                              -3, wbs_hdr.PLAN_TYPE_ID,
                                              -4, wbs_hdr.PLAN_TYPE_ID,
                                                  -1)              and
            wbs_hdr.CB_FLAG         =  fin_plan.CB             (+) and
            wbs_hdr.CO_FLAG         =  fin_plan.CO             (+) and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+) and
            (wbs.SUP_LEVEL <> wbs.SUB_LEVEL or
             (wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1))
          ) pjp,
          (
          select /*+ ordered */
            /*prg.SUP_PROJECT_ID,
            map.PROJECT_ORG_ID               SUP_PROJECT_ORG_ID,
            map.PROJECT_ORGANIZATION_ID      SUP_PROJECT_ORGANIZATION_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            prg.SUP_LEVEL,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUB_ROLLUP_ID,
            invert.INVERT_VALUE              RELATIONSHIP_TYPE,
            decode(prg.RELATIONSHIP_TYPE,
                   'LW', 'Y',
                   'LF', 'N')                WP_FLAG,
            'Y'                              PUSHUP_FLAG
          from
            PJI_PJP_PROJ_BATCH_MAP map,
            PJI_XBS_DENORM prg,
            (
              select 'LF' INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'LW' INVERT_ID, 'LW' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LW' INVERT_VALUE from dual
            ) invert,
            PJI_XBS_DENORM_DELTA prg_delta
          where
            prg.STRUCT_TYPE               = 'PRG'                           and
            prg.SUB_ROLLUP_ID             is not null                       and
            prg.SUB_LEVEL                 = l_level                         and
            map.WORKER_ID                 = p_worker_id                     and
            map.PROJECT_ID                = prg.SUP_PROJECT_ID              and
            decode(prg.SUB_LEVEL,
                   prg.SUP_LEVEL, 'A',
                   prg.RELATIONSHIP_TYPE) = invert.INVERT_ID                and
            p_worker_id                   = prg_delta.WORKER_ID         (+) and
            prg.STRUCT_TYPE               = prg_delta.STRUCT_TYPE       (+) and
            prg.SUP_PROJECT_ID            = prg_delta.SUP_PROJECT_ID    (+) and
            prg.SUP_LEVEL                 = prg_delta.SUP_LEVEL         (+) and
            prg.SUP_ID                    = prg_delta.SUP_ID            (+) and
            prg.SUB_LEVEL                 = prg_delta.SUB_LEVEL         (+) and
            prg.SUB_ID                    = prg_delta.SUB_ID            (+) and
            prg.RELATIONSHIP_TYPE         = prg_delta.RELATIONSHIP_TYPE (+) and
            -1                            = prg_delta.SIGN              (+) and
            prg_delta.SUP_PROJECT_ID      is null
          )                          prg,
          PJI_PJP_WBS_HEADER         wbs_hdr,
          PA_PROJ_ELEM_VER_STRUCTURE sub_ver,
          PA_PROJ_ELEM_VER_STRUCTURE sup_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp.PROJECT_ID         = sub_ver.PROJECT_ID                (+) and
          pjp.WBS_VERSION_ID     = sub_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sub_ver.STATUS_CODE               (+) and
          pjp.WBS_VERSION_ID     = prg.SUB_ID                        (+) and
          pjp.RELATIONSHIP_TYPE  = prg.RELATIONSHIP_TYPE             (+) and
          pjp.PUSHUP_FLAG        = prg.PUSHUP_FLAG                   (+) and
          prg.SUP_PROJECT_ID     = wbs_hdr.PROJECT_ID                (+) and
          prg.SUP_ID             = wbs_hdr.WBS_VERSION_ID            (+) and
          prg.WP_FLAG            = wbs_hdr.WP_FLAG                   (+) and
          'Y'                    = wbs_hdr.WP_FLAG                   (+) and
          wbs_hdr.PROJECT_ID     = sup_ver.PROJECT_ID                (+) and
          wbs_hdr.WBS_VERSION_ID = sup_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sup_ver.STATUS_CODE               (+) and
          'Y'                    = sup_ver.LATEST_EFF_PUBLISHED_FLAG (+) and
          prg.SUP_EMT_ID         = sup_wpa.PROJ_ELEMENT_ID           (+)
        group by
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y'),
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL),
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID),
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y'),
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID)),
          pjp.PLAN_TYPE_CODE
          )                          pjp1_i,
          PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp1_i.INSERT_FLAG  = 'Y'                                and
          pjp1_i.PROJECT_ID   = sup_fin_ver.PROJECT_ID         (+) and
          pjp1_i.SUP_ID       = sup_fin_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_WORKING' = sup_fin_ver.STATUS_CODE        (+) and
          pjp1_i.SUP_EMT_ID   = sup_wpa.PROJ_ELEMENT_ID        (+) and
          'N'                 = sup_wpa.WP_ENABLE_VERSION_FLAG (+) and
          (pjp1_i.SUP_ID is null or
           (pjp1_i.SUP_ID is not null and
            (sup_fin_ver.PROJECT_ID is not null or
             sup_wpa.PROJ_ELEMENT_ID is not null)));*/

        update PJI_SYSTEM_PRC_STATUS
        set    STEP_STATUS = 'C',
               END_DATE = sysdate
        where  PROCESS_NAME = l_process and
               STEP_SEQ = l_level_seq;

        commit;

        select
          nvl(to_number(min(STEP_SEQ)), 0)
        into
          l_level_seq
        from
          PJI_SYSTEM_PRC_STATUS
        where
          PROCESS_NAME = l_process and
          STEP_NAME like 'ROLLUP_FPR_WBS%' and
          STEP_STATUS is null;

        if (l_level_seq = 0) then
          l_level := 0;
        else
          l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
        end if;

      end loop;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(p_worker_id);');

      commit;

    else -- online mode

      -- rollup just WBS for online processing

      select /*+ ordered use_nl(den) */ -- bug 7607077 asahoo - removed index hint
        nvl(max(den.SUP_LEVEL), 0)
      into
        l_level
      from
        PJI_FM_EXTR_PLNVER3_T ver3,
        PJI_XBS_DENORM den
      where
        den.STRUCT_TYPE    = 'PRG'          and
        den.SUB_LEVEL      = den.SUP_LEVEL  and
        den.SUP_PROJECT_ID = ver3.PROJECT_ID;

      while (l_level > 0) loop

        -- rollup project hiearchy

        insert into PJI_FP_AGGR_PJP1_T
        (
          WORKER_ID,
          RECORD_TYPE,
          PRG_LEVEL,
          LINE_TYPE,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          PROJECT_ELEMENT_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          RBS_AGGR_LEVEL,
          WBS_ROLLUP_FLAG,
          PRG_ROLLUP_FLAG,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          RBS_ELEMENT_ID,
          RBS_VERSION_ID,
          PLAN_VERSION_ID,
          PLAN_TYPE_ID,
          PLAN_TYPE_CODE,
          RAW_COST,
          BRDN_COST,
          REVENUE,
          BILL_RAW_COST,
          BILL_BRDN_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BRDN_COST,
          BILL_LABOR_HRS,
          EQUIPMENT_RAW_COST,
          EQUIPMENT_BRDN_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BRDN_COST,
          LABOR_HRS,
          LABOR_REVENUE,
          EQUIPMENT_HOURS,
          BILLABLE_EQUIPMENT_HOURS,
          SUP_INV_COMMITTED_COST,
          PO_COMMITTED_COST,
          PR_COMMITTED_COST,
          OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
          ACT_EQUIP_HRS,
          ACT_LABOR_BRDN_COST,
          ACT_EQUIP_BRDN_COST,
          ACT_BRDN_COST,
          ACT_RAW_COST,
          ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
          ETC_LABOR_HRS,
          ETC_EQUIP_HRS,
          ETC_LABOR_BRDN_COST,
          ETC_EQUIP_BRDN_COST,
          ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15
        )
        select
          pjp1_i.WORKER_ID,
          pjp1_i.RECORD_TYPE,
          pjp1_i.PRG_LEVEL,
          pjp1_i.LINE_TYPE,
          pjp1_i.PROJECT_ID,
          pjp1_i.PROJECT_ORG_ID,
          pjp1_i.PROJECT_ORGANIZATION_ID,
          pjp1_i.PROJECT_ELEMENT_ID,
          pjp1_i.TIME_ID,
          pjp1_i.PERIOD_TYPE_ID,
          pjp1_i.CALENDAR_TYPE,
          pjp1_i.RBS_AGGR_LEVEL,
          pjp1_i.WBS_ROLLUP_FLAG,
          pjp1_i.PRG_ROLLUP_FLAG,
          pjp1_i.CURR_RECORD_TYPE_ID,
          pjp1_i.CURRENCY_CODE,
          pjp1_i.RBS_ELEMENT_ID,
          pjp1_i.RBS_VERSION_ID,
          pjp1_i.PLAN_VERSION_ID,
          pjp1_i.PLAN_TYPE_ID,
          pjp1_i.PLAN_TYPE_CODE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.RAW_COST))                    RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BRDN_COST))                   BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.REVENUE))                     REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_RAW_COST))               BILL_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_BRDN_COST))              BILL_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_RAW_COST))         BILL_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_BRDN_COST))        BILL_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_HRS))              BILL_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_RAW_COST))          EQUIPMENT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_BRDN_COST))         EQUIPMENT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.CAPITALIZABLE_RAW_COST))      CAPITALIZABLE_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.CAPITALIZABLE_BRDN_COST))     CAPITALIZABLE_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_RAW_COST))              LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_BRDN_COST))             LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_HRS))                   LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_REVENUE))               LABOR_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_HOURS))             EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILLABLE_EQUIPMENT_HOURS))    BILLABLE_EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.SUP_INV_COMMITTED_COST))      SUP_INV_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.PO_COMMITTED_COST))           PO_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.PR_COMMITTED_COST))           PR_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.OTH_COMMITTED_COST))          OTH_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_HRS)       ACT_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_HRS)       ACT_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_BRDN_COST) ACT_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_BRDN_COST) ACT_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_BRDN_COST)       ACT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_RAW_COST)        ACT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_REVENUE)         ACT_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_RAW_COST)  ACT_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_RAW_COST)  ACT_EQUIP_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_HRS)       ETC_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_HRS)       ETC_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_BRDN_COST) ETC_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_BRDN_COST) ETC_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_BRDN_COST)       ETC_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_RAW_COST)        ETC_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_RAW_COST)  ETC_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_RAW_COST)  ETC_EQUIP_RAW_COST,
          pjp1_i.CUSTOM1,
          pjp1_i.CUSTOM2,
          pjp1_i.CUSTOM3,
          pjp1_i.CUSTOM4,
          pjp1_i.CUSTOM5,
          pjp1_i.CUSTOM6,
          pjp1_i.CUSTOM7,
          pjp1_i.CUSTOM8,
          pjp1_i.CUSTOM9,
          pjp1_i.CUSTOM10,
          pjp1_i.CUSTOM11,
          pjp1_i.CUSTOM12,
          pjp1_i.CUSTOM13,
          pjp1_i.CUSTOM14,
          pjp1_i.CUSTOM15
        from
          (
        select
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y')                INSERT_FLAG,
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE)           SUB_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE)           SUP_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG)SUP_VER_ENABLED,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null))              SUP_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null))              SUP_EMT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null))              SUP_WP_FLAG,
          1                                           WORKER_ID,
          -- p_worker_id                              WORKER_ID,
          'W'                                         RECORD_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL)              PRG_LEVEL,
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID)  PROJECT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID)              PROJECT_ORG_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID)     PROJECT_ORGANIZATION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID)                   PROJECT_ELEMENT_ID,
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N')            WBS_ROLLUP_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y')            PRG_ROLLUP_FLAG,
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)) PLAN_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID))    PLAN_TYPE_ID,
          pjp.PLAN_TYPE_CODE,
          sum(pjp.RAW_COST)                           RAW_COST,
          sum(pjp.BRDN_COST)                          BRDN_COST,
          sum(pjp.REVENUE)                            REVENUE,
          sum(pjp.BILL_RAW_COST)                      BILL_RAW_COST,
          sum(pjp.BILL_BRDN_COST)                     BILL_BRDN_COST,
          sum(pjp.BILL_LABOR_RAW_COST)                BILL_LABOR_RAW_COST,
          sum(pjp.BILL_LABOR_BRDN_COST)               BILL_LABOR_BRDN_COST,
          sum(pjp.BILL_LABOR_HRS)                     BILL_LABOR_HRS,
          sum(pjp.EQUIPMENT_RAW_COST)                 EQUIPMENT_RAW_COST,
          sum(pjp.EQUIPMENT_BRDN_COST)                EQUIPMENT_BRDN_COST,
          sum(pjp.CAPITALIZABLE_RAW_COST)             CAPITALIZABLE_RAW_COST,
          sum(pjp.CAPITALIZABLE_BRDN_COST)            CAPITALIZABLE_BRDN_COST,
          sum(pjp.LABOR_RAW_COST)                     LABOR_RAW_COST,
          sum(pjp.LABOR_BRDN_COST)                    LABOR_BRDN_COST,
          sum(pjp.LABOR_HRS)                          LABOR_HRS,
          sum(pjp.LABOR_REVENUE)                      LABOR_REVENUE,
          sum(pjp.EQUIPMENT_HOURS)                    EQUIPMENT_HOURS,
          sum(pjp.BILLABLE_EQUIPMENT_HOURS)           BILLABLE_EQUIPMENT_HOURS,
          sum(pjp.SUP_INV_COMMITTED_COST)             SUP_INV_COMMITTED_COST,
          sum(pjp.PO_COMMITTED_COST)                  PO_COMMITTED_COST,
          sum(pjp.PR_COMMITTED_COST)                  PR_COMMITTED_COST,
          sum(pjp.OTH_COMMITTED_COST)                 OTH_COMMITTED_COST,
          sum(pjp.ACT_LABOR_HRS)                      ACT_LABOR_HRS,
          sum(pjp.ACT_EQUIP_HRS)                      ACT_EQUIP_HRS,
          sum(pjp.ACT_LABOR_BRDN_COST)                ACT_LABOR_BRDN_COST,
          sum(pjp.ACT_EQUIP_BRDN_COST)                ACT_EQUIP_BRDN_COST,
          sum(pjp.ACT_BRDN_COST)                      ACT_BRDN_COST,
          sum(pjp.ACT_RAW_COST)                       ACT_RAW_COST,
          sum(pjp.ACT_REVENUE)                        ACT_REVENUE,
          sum(pjp.ACT_LABOR_RAW_COST)                 ACT_LABOR_RAW_COST,
          sum(pjp.ACT_EQUIP_RAW_COST)                 ACT_EQUIP_RAW_COST,
          sum(pjp.ETC_LABOR_HRS)                      ETC_LABOR_HRS,
          sum(pjp.ETC_EQUIP_HRS)                      ETC_EQUIP_HRS,
          sum(pjp.ETC_LABOR_BRDN_COST)                ETC_LABOR_BRDN_COST,
          sum(pjp.ETC_EQUIP_BRDN_COST)                ETC_EQUIP_BRDN_COST,
          sum(pjp.ETC_BRDN_COST)                      ETC_BRDN_COST,
          sum(pjp.ETC_RAW_COST)                       ETC_RAW_COST,
          sum(pjp.ETC_LABOR_RAW_COST)                 ETC_LABOR_RAW_COST,
          sum(pjp.ETC_EQUIP_RAW_COST)                 ETC_EQUIP_RAW_COST,
          sum(pjp.CUSTOM1)                            CUSTOM1,
          sum(pjp.CUSTOM2)                            CUSTOM2,
          sum(pjp.CUSTOM3)                            CUSTOM3,
          sum(pjp.CUSTOM4)                            CUSTOM4,
          sum(pjp.CUSTOM5)                            CUSTOM5,
          sum(pjp.CUSTOM6)                            CUSTOM6,
          sum(pjp.CUSTOM7)                            CUSTOM7,
          sum(pjp.CUSTOM8)                            CUSTOM8,
          sum(pjp.CUSTOM9)                            CUSTOM9,
          sum(pjp.CUSTOM10)                           CUSTOM10,
          sum(pjp.CUSTOM11)                           CUSTOM11,
          sum(pjp.CUSTOM12)                           CUSTOM12,
          sum(pjp.CUSTOM13)                           CUSTOM13,
          sum(pjp.CUSTOM14)                           CUSTOM14,
          sum(pjp.CUSTOM15)                           CUSTOM15
        from
          (
          select /*+ ordered index(wbs PA_XBS_DENORM_N2) */
                 -- get incremental task level amounts from source and
                 -- program rollup amounts from interim
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            decode(wbs_hdr.WP_FLAG
                     || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                     || '_' || nvl(fin_plan.INVERT_ID, 'PRJ'),
                   'N_1_PRJ', 'N',
                   'N_-1_PRG', 'N',
                   decode(top_slice.INVERT_ID,
                          'PRJ', 'Y',
                          decode(wbs.SUB_LEVEL,
                                 1, 'Y', 'N')))       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(wbs_hdr.WP_FLAG
                                 || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                                 || '_' || fin_plan.INVERT_ID,
                               'N_1_PRG', decode(top_slice.INVERT_ID,
                                                 'PRJ', 'Y',
                                                 decode(wbs.SUB_LEVEL,
                                                        1, 'Y', 'N')),
                               'N_-1_PRG', 'N',
                               decode(wbs_hdr.WP_FLAG
                                        || '_' || fin_plan.INVERT_ID
                                        || '_' || fin_plan.CB
                                        || '_' || fin_plan.CO
                                        || '_'
                                        || to_char(fin_plan.PLAN_VERSION_ID),
                                      'N_PRJ_Y_Y_-4', 'N',
                                                      'Y'))
                  )                                   INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', fin_plan.PLAN_VERSION_ID,
                            pjp1.PLAN_VERSION_ID)     PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1_T pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PA_XBS_DENORM      wbs,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL
            ) fin_plan,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            ((wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1) or
             (wbs.SUP_LEVEL <> wbs.SUB_LEVEL))                     and
            wbs.STRUCT_VERSION_ID   =  prg.SUP_ID                  and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            -- pjp1.WORKER_ID       =  p_worker_id                 and
            pjp1.PRG_LEVEL          in (0, l_level)                and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')                  and
            pjp1.WBS_ROLLUP_FLAG    =  'N'                         and
            pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                  and
            pjp1.PROJECT_ID         =  wbs_hdr.PROJECT_ID          and
            pjp1.PLAN_VERSION_ID    =  wbs_hdr.PLAN_VERSION_ID     and
            pjp1.PLAN_TYPE_CODE     =  wbs_hdr.PLAN_TYPE_CODE      and
            decode(pjp1.PLAN_VERSION_ID,
                   -3, pjp1.PLAN_TYPE_ID,
                   -4, pjp1.PLAN_TYPE_ID,
                       -1)          =  decode(pjp1.PLAN_VERSION_ID,
                                              -3, wbs_hdr.PLAN_TYPE_ID,
                                              -4, wbs_hdr.PLAN_TYPE_ID,
                                                  -1)              and
            wbs.STRUCT_VERSION_ID   =  wbs_hdr.WBS_VERSION_ID      and
            pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID              and
            wbs_hdr.CB_FLAG         =  fin_plan.CB             (+) and
            wbs_hdr.CO_FLAG         =  fin_plan.CO             (+) and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+)
          union all
          select /*+ ordered */
                 -- get incremental project level amounts from source
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            'Y'                                       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(fin_plan.PLAN_VERSION_ID,
                               null, 'N', 'Y'))       INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            pjp1.PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, pjp1.PLAN_VERSION_ID,
                               -2, pjp1.PLAN_VERSION_ID,
                               -3, pjp1.PLAN_VERSION_ID, -- won't exist
                               -4, pjp1.PLAN_VERSION_ID, -- won't exist
                                   fin_plan.PLAN_VERSION_ID),
                        pjp1.PLAN_VERSION_ID)         PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1_T pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB_FLAG,
                     'N' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'N' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL
            ) fin_plan
          where
            prg.STRUCT_TYPE         = 'PRG'                    and
            prg.SUP_LEVEL           = l_level                  and
            prg.SUB_LEVEL           = l_level                  and
            -- pjp1.WORKER_ID       = p_worker_id              and
            pjp1.PROJECT_ID         = prg.SUP_PROJECT_ID       and
            pjp1.PROJECT_ELEMENT_ID = prg.SUP_EMT_ID           and
            pjp1.PRG_LEVEL          = 0                        and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')              and
            pjp1.WBS_ROLLUP_FLAG    = 'N'                      and
            pjp1.PRG_ROLLUP_FLAG    = 'N'                      and
            wbs_hdr.PROJECT_ID      = pjp1.PROJECT_ID          and
            wbs_hdr.PLAN_VERSION_ID = pjp1.PLAN_VERSION_ID     and
            wbs_hdr.PLAN_TYPE_CODE  = pjp1.PLAN_TYPE_CODE      and
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, 'Y',
                               -2, 'Y',
                               -3, 'Y', -- won't exist
                               -4, 'Y', -- won't exist
                                   decode(wbs_hdr.CB_FLAG || '_' ||
                                          wbs_hdr.CO_FLAG,
                                          'Y_Y', 'Y',
                                          'N_Y', 'Y',
                                          'Y_N', 'Y',
                                                 'N')),
                        'Y')        =  'Y'                     and
            wbs_hdr.WBS_VERSION_ID  = prg.SUP_ID               and
            wbs_hdr.CB_FLAG         = fin_plan.CB_FLAG     (+) and
            wbs_hdr.CO_FLAG         = fin_plan.CO_FLAG     (+)
          union all
          select /*+ ordered
                     index(log PA_PJI_PROJ_EVENTS_LOG_N2)
                     index(fpr PJI_FP_XBS_ACCUM_F_N1) */
                 -- get delta task level amounts from Reporting Lines
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            decode(log.EVENT_TYPE,
                   'WBS_CHANGE', 'Y',
                   'WBS_PUBLISH', 'N')                PUSHUP_FLAG,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', decode(top_slice.INVERT_ID,
                                   'PRJ', 'Y',
                                   decode(wbs.SUB_LEVEL,
                                          1, 'Y', 'N')),
                   decode(wbs_hdr.WP_FLAG
                            || '_' || fin_plan.INVERT_ID
                            || '_' || fin_plan.CB
                            || '_' || fin_plan.CO
                            || '_' || to_char(fin_plan.PLAN_VERSION_ID),
                          'N_PRJ_Y_Y_-4', 'N',
                                          'Y'))       INSERT_FLAG,
            fpr.PROJECT_ID,
            fpr.PROJECT_ORG_ID,
            fpr.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            fpr.TIME_ID,
            fpr.PERIOD_TYPE_ID,
            fpr.CALENDAR_TYPE,
            fpr.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            fpr.PRG_ROLLUP_FLAG,
            fpr.CURR_RECORD_TYPE_ID,
            fpr.CURRENCY_CODE,
            fpr.RBS_ELEMENT_ID,
            fpr.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', fin_plan.PLAN_VERSION_ID,
                            fpr.PLAN_VERSION_ID)      PLAN_VERSION_ID,
            fpr.PLAN_TYPE_ID,
            fpr.PLAN_TYPE_CODE,
            wbs.SIGN * fpr.RAW_COST                   RAW_COST,
            wbs.SIGN * fpr.BRDN_COST                  BRDN_COST,
            wbs.SIGN * fpr.REVENUE                    REVENUE,
            wbs.SIGN * fpr.BILL_RAW_COST              BILL_RAW_COST,
            wbs.SIGN * fpr.BILL_BRDN_COST             BILL_BRDN_COST,
            wbs.SIGN * fpr.BILL_LABOR_RAW_COST        BILL_LABOR_RAW_COST,
            wbs.SIGN * fpr.BILL_LABOR_BRDN_COST       BILL_LABOR_BRDN_COST,
            wbs.SIGN * fpr.BILL_LABOR_HRS             BILL_LABOR_HRS,
            wbs.SIGN * fpr.EQUIPMENT_RAW_COST         EQUIPMENT_RAW_COST,
            wbs.SIGN * fpr.EQUIPMENT_BRDN_COST        EQUIPMENT_BRDN_COST,
            wbs.SIGN * fpr.CAPITALIZABLE_RAW_COST     CAPITALIZABLE_RAW_COST,
            wbs.SIGN * fpr.CAPITALIZABLE_BRDN_COST    CAPITALIZABLE_BRDN_COST,
            wbs.SIGN * fpr.LABOR_RAW_COST             LABOR_RAW_COST,
            wbs.SIGN * fpr.LABOR_BRDN_COST            LABOR_BRDN_COST,
            wbs.SIGN * fpr.LABOR_HRS                  LABOR_HRS,
            wbs.SIGN * fpr.LABOR_REVENUE              LABOR_REVENUE,
            wbs.SIGN * fpr.EQUIPMENT_HOURS            EQUIPMENT_HOURS,
            wbs.SIGN * fpr.BILLABLE_EQUIPMENT_HOURS   BILLABLE_EQUIPMENT_HOURS,
            wbs.SIGN * fpr.SUP_INV_COMMITTED_COST     SUP_INV_COMMITTED_COST,
            wbs.SIGN * fpr.PO_COMMITTED_COST          PO_COMMITTED_COST,
            wbs.SIGN * fpr.PR_COMMITTED_COST          PR_COMMITTED_COST,
            wbs.SIGN * fpr.OTH_COMMITTED_COST         OTH_COMMITTED_COST,
            wbs.SIGN * fpr.ACT_LABOR_HRS              ACT_LABOR_HRS,
            wbs.SIGN * fpr.ACT_EQUIP_HRS              ACT_EQUIP_HRS,
            wbs.SIGN * fpr.ACT_LABOR_BRDN_COST        ACT_LABOR_BRDN_COST,
            wbs.SIGN * fpr.ACT_EQUIP_BRDN_COST        ACT_EQUIP_BRDN_COST,
            wbs.SIGN * fpr.ACT_BRDN_COST              ACT_BRDN_COST,
            wbs.SIGN * fpr.ACT_RAW_COST               ACT_RAW_COST,
            wbs.SIGN * fpr.ACT_REVENUE                ACT_REVENUE,
            wbs.SIGN * fpr.ACT_LABOR_RAW_COST         ACT_LABOR_RAW_COST,
            wbs.SIGN * fpr.ACT_EQUIP_RAW_COST         ACT_EQUIP_RAW_COST,
            wbs.SIGN * fpr.ETC_LABOR_HRS              ETC_LABOR_HRS,
            wbs.SIGN * fpr.ETC_EQUIP_HRS              ETC_EQUIP_HRS,
            wbs.SIGN * fpr.ETC_LABOR_BRDN_COST        ETC_LABOR_BRDN_COST,
            wbs.SIGN * fpr.ETC_EQUIP_BRDN_COST        ETC_EQUIP_BRDN_COST,
            wbs.SIGN * fpr.ETC_BRDN_COST              ETC_BRDN_COST,
            wbs.SIGN * fpr.ETC_RAW_COST               ETC_RAW_COST,
            wbs.SIGN * fpr.ETC_LABOR_RAW_COST         ETC_LABOR_RAW_COST,
            wbs.SIGN * fpr.ETC_EQUIP_RAW_COST         ETC_EQUIP_RAW_COST,
            wbs.SIGN * fpr.CUSTOM1                    CUSTOM1,
            wbs.SIGN * fpr.CUSTOM2                    CUSTOM2,
            wbs.SIGN * fpr.CUSTOM3                    CUSTOM3,
            wbs.SIGN * fpr.CUSTOM4                    CUSTOM4,
            wbs.SIGN * fpr.CUSTOM5                    CUSTOM5,
            wbs.SIGN * fpr.CUSTOM6                    CUSTOM6,
            wbs.SIGN * fpr.CUSTOM7                    CUSTOM7,
            wbs.SIGN * fpr.CUSTOM8                    CUSTOM8,
            wbs.SIGN * fpr.CUSTOM9                    CUSTOM9,
            wbs.SIGN * fpr.CUSTOM10                   CUSTOM10,
            wbs.SIGN * fpr.CUSTOM11                   CUSTOM11,
            wbs.SIGN * fpr.CUSTOM12                   CUSTOM12,
            wbs.SIGN * fpr.CUSTOM13                   CUSTOM13,
            wbs.SIGN * fpr.CUSTOM14                   CUSTOM14,
            wbs.SIGN * fpr.CUSTOM15                   CUSTOM15
          from
            PA_PJI_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            PJI_XBS_DENORM_DELTA_T wbs,
            PJI_XBS_DENORM         prg,
            PJI_FP_XBS_ACCUM_F     fpr,
            (
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL
            ) fin_plan,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            -- wbs.WORKER_ID        =  p_worker_id                 and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            -- log.WORKER_ID        =  p_worker_id                 and
            log.EVENT_ID            =  g_event_id                  and
            log.EVENT_TYPE          in ('WBS_CHANGE',
                                        'WBS_PUBLISH')             and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1              and
            wbs_hdr.PLAN_VERSION_ID =  log.ATTRIBUTE3              and
            wbs_hdr.WBS_VERSION_ID  =  wbs.STRUCT_VERSION_ID       and
            wbs_hdr.PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                  and
            fpr.RBS_AGGR_LEVEL      =  'T'                         and
            fpr.WBS_ROLLUP_FLAG     =  'N'                         and
            fpr.PRG_ROLLUP_FLAG     in ('Y', 'N')                  and
            fpr.PROJECT_ID          =  wbs.SUP_PROJECT_ID          and
            fpr.PROJECT_ELEMENT_ID  =  wbs.SUB_EMT_ID              and
            fpr.PROJECT_ID          =  wbs_hdr.PROJECT_ID          and
            fpr.PLAN_VERSION_ID     =  wbs_hdr.PLAN_VERSION_ID     and
            fpr.PLAN_TYPE_CODE      =  wbs_hdr.PLAN_TYPE_CODE      and
            decode(fpr.PLAN_VERSION_ID,
                   -3, fpr.PLAN_TYPE_ID,
                   -4, fpr.PLAN_TYPE_ID,
                       -1)          =  decode(fpr.PLAN_VERSION_ID,
                                              -3, wbs_hdr.PLAN_TYPE_ID,
                                              -4, wbs_hdr.PLAN_TYPE_ID,
                                                  -1)              and
            wbs_hdr.CB_FLAG         =  fin_plan.CB             (+) and
            wbs_hdr.CO_FLAG         =  fin_plan.CO             (+) and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+) and
            (wbs.SUP_LEVEL <> wbs.SUB_LEVEL or
             (wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1))
          union all
          select /*+ ordered
                     index(log PA_PJI_PROJ_EVENTS_LOG_N2)
                     index(fpr PJI_FP_XBS_ACCUM_F_N1) */
                 -- Baseline reversals and fact amounts  (-3 slice)
                 -- Current Original reversals and fact amounts  (-4 slice)
                 -- Part 1
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            'LF'                                      RELATIONSHIP_TYPE,
            'Y'                                       PUSHUP_FLAG,
            decode(fpr.RBS_AGGR_LEVEL,
                   'L', 'N', 'Y')                     INSERT_FLAG,
            fpr.PROJECT_ID,
            fpr.PROJECT_ORG_ID,
            fpr.PROJECT_ORGANIZATION_ID,
            prg.SUP_EMT_ID                            PROJECT_ELEMENT_ID,
            fpr.TIME_ID,
            fpr.PERIOD_TYPE_ID,
            fpr.CALENDAR_TYPE,
            fpr.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            fpr.PRG_ROLLUP_FLAG,
            fpr.CURR_RECORD_TYPE_ID,
            fpr.CURRENCY_CODE,
            fpr.RBS_ELEMENT_ID,
            fpr.RBS_VERSION_ID,
            decode(log.EVENT_TYPE,
                   'PLAN_BASELINE', -3,
                   'PLAN_ORIGINAL', -4)               PLAN_VERSION_ID,
            fpr.PLAN_TYPE_ID,
            fpr.PLAN_TYPE_CODE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.RAW_COST                          RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BRDN_COST                         BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.REVENUE                           REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_RAW_COST                     BILL_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_BRDN_COST                    BILL_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_RAW_COST               BILL_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_BRDN_COST              BILL_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_HRS                    BILL_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_RAW_COST                EQUIPMENT_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_BRDN_COST               EQUIPMENT_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CAPITALIZABLE_RAW_COST            CAPITALIZABLE_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CAPITALIZABLE_BRDN_COST           CAPITALIZABLE_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_RAW_COST                    LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_BRDN_COST                   LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_HRS                         LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_REVENUE                     LABOR_REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_HOURS                   EQUIPMENT_HOURS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILLABLE_EQUIPMENT_HOURS          BILLABLE_EQUIPMENT_HOURS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.SUP_INV_COMMITTED_COST            SUP_INV_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.PO_COMMITTED_COST                 PO_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.PR_COMMITTED_COST                 PR_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.OTH_COMMITTED_COST                OTH_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_HRS                     ACT_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_HRS                     ACT_EQUIP_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_BRDN_COST               ACT_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_BRDN_COST               ACT_EQUIP_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_BRDN_COST                     ACT_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_RAW_COST                      ACT_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_REVENUE                       ACT_REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_RAW_COST                ACT_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_RAW_COST                ACT_EQUIP_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_HRS                     ETC_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_HRS                     ETC_EQUIP_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_BRDN_COST               ETC_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_BRDN_COST               ETC_EQUIP_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_BRDN_COST                     ETC_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_RAW_COST                      ETC_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_RAW_COST                ETC_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_RAW_COST                ETC_EQUIP_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM1                           CUSTOM1,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM2                           CUSTOM2,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM3                           CUSTOM3,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM4                           CUSTOM4,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM5                           CUSTOM5,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM6                           CUSTOM6,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM7                           CUSTOM7,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM8                           CUSTOM8,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM9                           CUSTOM9,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM10                          CUSTOM10,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM11                          CUSTOM11,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM12                          CUSTOM12,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM13                          CUSTOM13,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM14                          CUSTOM14,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM15                          CUSTOM15
          from
            PA_PJI_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            -- Changes done for bug 7354982.
            --PJI_XBS_DENORM         prg,
            PJI_FP_XBS_ACCUM_F     fpr,
            PJI_XBS_DENORM         prg
          where
            prg.STRUCT_TYPE         =  'PRG'                        and
            prg.SUP_LEVEL           =  l_level                      and
            prg.SUB_LEVEL           =  l_level                      and
            log.EVENT_ID            =  g_event_id                   and
            log.EVENT_TYPE          in ('PLAN_BASELINE',
                                        'PLAN_ORIGINAL')            and
            fpr.PROJECT_ID          =  log.ATTRIBUTE1               and
            fpr.PROJECT_ID          =  prg.SUP_PROJECT_ID           and
            fpr.PLAN_TYPE_ID        =  log.ATTRIBUTE2               and
            fpr.PLAN_VERSION_ID     in (decode(log.EVENT_TYPE,
                                               'PLAN_BASELINE', -3,
                                               'PLAN_ORIGINAL', -4),
                                        log.EVENT_OBJECT)           and
            (fpr.RBS_AGGR_LEVEL,
             fpr.WBS_ROLLUP_FLAG,
             fpr.PRG_ROLLUP_FLAG)   in (('T', 'Y', 'N'),
                                        ('T', 'N', 'N'),
                                        ('L', 'N', 'N'))            and
            fpr.PROJECT_ELEMENT_ID  =  prg.SUB_EMT_ID               and
            wbs_hdr.PROJECT_ID      =  fpr.PROJECT_ID               and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1               and
            wbs_hdr.PLAN_VERSION_ID in (log.ATTRIBUTE3,
                                        log.EVENT_OBJECT)           and
            wbs_hdr.PLAN_VERSION_ID =  decode(sign(fpr.PLAN_VERSION_ID),
                                              -1, log.ATTRIBUTE3,
                                                  log.EVENT_OBJECT) and
            wbs_hdr.PLAN_TYPE_ID    =  log.ATTRIBUTE2               and
            wbs_hdr.PLAN_TYPE_CODE  =  fpr.PLAN_TYPE_CODE           and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                   and
             prg.struct_version_id is NULL                               -- added for bug 5882260
          union all
          select /*+ ordered
                     index(log PA_PJI_PROJ_EVENTS_LOG_N2)
                     index(fpr PJI_FP_XBS_ACCUM_F_N1) */
                 -- Baseline reversals and fact amounts  (-3 slice)
                 -- Current Original reversals and fact amounts  (-4 slice)
                 -- Part 2
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            'LF'                                      RELATIONSHIP_TYPE,
            'Y'                                       PUSHUP_FLAG,
            decode(fpr.RBS_AGGR_LEVEL,
                   'L', 'N', 'Y')                     INSERT_FLAG,
            fpr.PROJECT_ID,
            fpr.PROJECT_ORG_ID,
            fpr.PROJECT_ORGANIZATION_ID,
            prg.SUP_EMT_ID                            PROJECT_ELEMENT_ID,
            fpr.TIME_ID,
            fpr.PERIOD_TYPE_ID,
            fpr.CALENDAR_TYPE,
            fpr.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            fpr.PRG_ROLLUP_FLAG,
            fpr.CURR_RECORD_TYPE_ID,
            fpr.CURRENCY_CODE,
            fpr.RBS_ELEMENT_ID,
            fpr.RBS_VERSION_ID,
            decode(log.EVENT_TYPE,
                   'PLAN_BASELINE', -3,
                   'PLAN_ORIGINAL', -4)               PLAN_VERSION_ID,
            fpr.PLAN_TYPE_ID,
            fpr.PLAN_TYPE_CODE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.RAW_COST                          RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BRDN_COST                         BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.REVENUE                           REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_RAW_COST                     BILL_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_BRDN_COST                    BILL_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_RAW_COST               BILL_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_BRDN_COST              BILL_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILL_LABOR_HRS                    BILL_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_RAW_COST                EQUIPMENT_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_BRDN_COST               EQUIPMENT_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CAPITALIZABLE_RAW_COST            CAPITALIZABLE_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CAPITALIZABLE_BRDN_COST           CAPITALIZABLE_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_RAW_COST                    LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_BRDN_COST                   LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_HRS                         LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.LABOR_REVENUE                     LABOR_REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.EQUIPMENT_HOURS                   EQUIPMENT_HOURS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.BILLABLE_EQUIPMENT_HOURS          BILLABLE_EQUIPMENT_HOURS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.SUP_INV_COMMITTED_COST            SUP_INV_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.PO_COMMITTED_COST                 PO_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.PR_COMMITTED_COST                 PR_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.OTH_COMMITTED_COST                OTH_COMMITTED_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_HRS                     ACT_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_HRS                     ACT_EQUIP_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_BRDN_COST               ACT_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_BRDN_COST               ACT_EQUIP_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_BRDN_COST                     ACT_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_RAW_COST                      ACT_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_REVENUE                       ACT_REVENUE,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_LABOR_RAW_COST                ACT_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ACT_EQUIP_RAW_COST                ACT_EQUIP_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_HRS                     ETC_LABOR_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_HRS                     ETC_EQUIP_HRS,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_BRDN_COST               ETC_LABOR_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_BRDN_COST               ETC_EQUIP_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_BRDN_COST                     ETC_BRDN_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_RAW_COST                      ETC_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_LABOR_RAW_COST                ETC_LABOR_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.ETC_EQUIP_RAW_COST                ETC_EQUIP_RAW_COST,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM1                           CUSTOM1,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM2                           CUSTOM2,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM3                           CUSTOM3,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM4                           CUSTOM4,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM5                           CUSTOM5,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM6                           CUSTOM6,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM7                           CUSTOM7,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM8                           CUSTOM8,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM9                           CUSTOM9,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM10                          CUSTOM10,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM11                          CUSTOM11,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM12                          CUSTOM12,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM13                          CUSTOM13,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM14                          CUSTOM14,
            decode(fpr.PLAN_VERSION_ID,
                   log.ATTRIBUTE3,   -1,
                   log.EVENT_OBJECT,  1,
                   -3,               -1,
                   -4,               -1)
              * fpr.CUSTOM15                          CUSTOM15
          from
            PA_PJI_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            -- Changes done for bug 7354982.
            --PJI_XBS_DENORM         prg,
            PJI_FP_XBS_ACCUM_F     fpr,
            PJI_XBS_DENORM         prg
          where
            prg.STRUCT_TYPE         =  'PRG'                        and
            prg.SUP_LEVEL           =  l_level                      and
            prg.SUB_LEVEL           =  l_level                      and
            log.EVENT_ID            =  g_event_id                   and
            log.EVENT_TYPE          in ('PLAN_BASELINE',
                                        'PLAN_ORIGINAL')            and
            fpr.PROJECT_ID          =  log.ATTRIBUTE1               and
            fpr.PROJECT_ID          =  prg.SUP_PROJECT_ID           and
            fpr.PLAN_TYPE_ID        =  log.ATTRIBUTE2               and
            fpr.PLAN_VERSION_ID     in (log.ATTRIBUTE3,
                                        log.EVENT_OBJECT)           and
            (fpr.RBS_AGGR_LEVEL,
             fpr.WBS_ROLLUP_FLAG,
             fpr.PRG_ROLLUP_FLAG)   in (('L', 'N', 'N'))            and
            fpr.PROJECT_ELEMENT_ID  <> prg.SUB_EMT_ID               and
            wbs_hdr.PROJECT_ID      =  fpr.PROJECT_ID               and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1               and
            wbs_hdr.PLAN_VERSION_ID in (log.ATTRIBUTE3,
                                        log.EVENT_OBJECT)           and
            wbs_hdr.PLAN_VERSION_ID =  decode(sign(fpr.PLAN_VERSION_ID),
                                              -1, log.ATTRIBUTE3,
                                                  log.EVENT_OBJECT) and
            wbs_hdr.PLAN_TYPE_ID    =  log.ATTRIBUTE2               and
            wbs_hdr.PLAN_TYPE_CODE  =  fpr.PLAN_TYPE_CODE           and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                   and
             prg.struct_version_id is NULL                               -- added for bug 5882260
          ) pjp,
          (
          select /*+ ordered
                     index(prg PJI_XBS_DENORM_N3)
                     index(prj PA_PROJECTS_U1) */
            prg.SUP_PROJECT_ID,
            prj.ORG_ID                       SUP_PROJECT_ORG_ID,
            prj.CARRYING_OUT_ORGANIZATION_ID SUP_PROJECT_ORGANIZATION_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            prg.SUP_LEVEL,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUB_ROLLUP_ID,
            invert.INVERT_VALUE              RELATIONSHIP_TYPE,
            decode(prg.RELATIONSHIP_TYPE,
                   'LW', 'Y',
                   'LF', 'N')                WP_FLAG,
            'Y'                              PUSHUP_FLAG
          from
            PJI_XBS_DENORM        prg,
            PA_PROJECTS_ALL       prj,
            (
              select 'LF' INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'LW' INVERT_ID, 'LW' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LW' INVERT_VALUE from dual
            ) invert
          where
            l_level                       > 1                  and
            prg.STRUCT_TYPE               = 'PRG'              and
            prg.SUB_ROLLUP_ID             is not null          and
            prg.SUB_LEVEL                 = l_level            and
            -- map.WORKER_ID              = p_worker_id        and
            prj.PROJECT_ID                = prg.SUP_PROJECT_ID and
            decode(prg.SUB_LEVEL,
                   prg.SUP_LEVEL, 'A',
                   prg.RELATIONSHIP_TYPE) = invert.INVERT_ID
          )                          prg,
          PJI_PJP_WBS_HEADER         wbs_hdr,
          PA_PROJ_ELEM_VER_STRUCTURE sub_ver,
          PA_PROJ_ELEM_VER_STRUCTURE sup_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp.PROJECT_ID         = sub_ver.PROJECT_ID                (+) and
          pjp.WBS_VERSION_ID     = sub_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sub_ver.STATUS_CODE               (+) and
          pjp.WBS_VERSION_ID     = prg.SUB_ID                        (+) and
          pjp.RELATIONSHIP_TYPE  = prg.RELATIONSHIP_TYPE             (+) and
          pjp.PUSHUP_FLAG        = prg.PUSHUP_FLAG                   (+) and
          prg.SUP_PROJECT_ID     = wbs_hdr.PROJECT_ID                (+) and
          prg.SUP_ID             = wbs_hdr.WBS_VERSION_ID            (+) and
          prg.WP_FLAG            = wbs_hdr.WP_FLAG                   (+) and
          'Y'                    = wbs_hdr.WP_FLAG                   (+) and
          wbs_hdr.PROJECT_ID     = sup_ver.PROJECT_ID                (+) and
          wbs_hdr.WBS_VERSION_ID = sup_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sup_ver.STATUS_CODE               (+) and
          'Y'                    = sup_ver.LATEST_EFF_PUBLISHED_FLAG (+) and
          prg.SUP_EMT_ID         = sup_wpa.PROJ_ELEMENT_ID           (+)
        group by
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y'),
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL),
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID),
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y'),
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID)),
          pjp.PLAN_TYPE_CODE
          )                          pjp1_i,
          PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp1_i.INSERT_FLAG  = 'Y'                                and
          pjp1_i.PROJECT_ID   = sup_fin_ver.PROJECT_ID         (+) and
          pjp1_i.SUP_ID       = sup_fin_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_WORKING' = sup_fin_ver.STATUS_CODE        (+) and
          pjp1_i.SUP_EMT_ID   = sup_wpa.PROJ_ELEMENT_ID        (+) and
          'N'                 = sup_wpa.WP_ENABLE_VERSION_FLAG (+) and
          (pjp1_i.SUP_ID is null or
           (pjp1_i.SUP_ID is not null and
            (sup_fin_ver.PROJECT_ID is not null or
             sup_wpa.PROJ_ELEMENT_ID is not null)));

        l_level := l_level - 1;

      end loop;

    end if;

  end ROLLUP_FPR_WBS;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_RBS_SMART_SLICES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_RBS_SMART_SLICES (p_worker_id in number default null) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);

  begin

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES(p_worker_id);')) then
        return;
      end if;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      insert into PJI_FP_AGGR_PJP1 pjp1_i
      (
        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        PLAN_TYPE_CODE,
        RAW_COST,
        BRDN_COST,
        REVENUE,
        BILL_RAW_COST,
        BILL_BRDN_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BRDN_COST,
        BILL_LABOR_HRS,
        EQUIPMENT_RAW_COST,
        EQUIPMENT_BRDN_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BRDN_COST,
        LABOR_HRS,
        LABOR_REVENUE,
        EQUIPMENT_HOURS,
        BILLABLE_EQUIPMENT_HOURS,
        SUP_INV_COMMITTED_COST,
        PO_COMMITTED_COST,
        PR_COMMITTED_COST,
        OTH_COMMITTED_COST,
        ACT_LABOR_HRS,
        ACT_EQUIP_HRS,
        ACT_LABOR_BRDN_COST,
        ACT_EQUIP_BRDN_COST,
        ACT_BRDN_COST,
        ACT_RAW_COST,
        ACT_REVENUE,
        ACT_LABOR_RAW_COST,
        ACT_EQUIP_RAW_COST,
        ETC_LABOR_HRS,
        ETC_EQUIP_HRS,
        ETC_LABOR_BRDN_COST,
        ETC_EQUIP_BRDN_COST,
        ETC_BRDN_COST,
        ETC_RAW_COST,
        ETC_LABOR_RAW_COST,
        ETC_EQUIP_RAW_COST,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select
        p_worker_id                                   WORKER_ID,
        'R'                                           RECORD_TYPE,
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        sum(pjp1.RAW_COST)                            RAW_COST,
        sum(pjp1.BRDN_COST)                           BRDN_COST,
        sum(pjp1.REVENUE)                             REVENUE,
        sum(pjp1.BILL_RAW_COST)                       BILL_RAW_COST,
        sum(pjp1.BILL_BRDN_COST)                      BILL_BRDN_COST,
        sum(pjp1.BILL_LABOR_RAW_COST)                 BILL_LABOR_RAW_COST,
        sum(pjp1.BILL_LABOR_BRDN_COST)                BILL_LABOR_BRDN_COST,
        sum(pjp1.BILL_LABOR_HRS)                      BILL_LABOR_HRS,
        sum(pjp1.EQUIPMENT_RAW_COST)                  EQUIPMENT_RAW_COST,
        sum(pjp1.EQUIPMENT_BRDN_COST)                 EQUIPMENT_BRDN_COST,
        sum(pjp1.CAPITALIZABLE_RAW_COST)              CAPITALIZABLE_RAW_COST,
        sum(pjp1.CAPITALIZABLE_BRDN_COST)             CAPITALIZABLE_BRDN_COST,
        sum(pjp1.LABOR_RAW_COST)                      LABOR_RAW_COST,
        sum(pjp1.LABOR_BRDN_COST)                     LABOR_BRDN_COST,
        sum(pjp1.LABOR_HRS)                           LABOR_HRS,
        sum(pjp1.LABOR_REVENUE)                       LABOR_REVENUE,
        sum(pjp1.EQUIPMENT_HOURS)                     EQUIPMENT_HOURS,
        sum(pjp1.BILLABLE_EQUIPMENT_HOURS)            BILLABLE_EQUIPMENT_HOURS,
        sum(pjp1.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        sum(pjp1.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        sum(pjp1.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        sum(pjp1.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        sum(pjp1.ACT_LABOR_HRS)                       ACT_LABOR_HRS,
        sum(pjp1.ACT_EQUIP_HRS)                       ACT_EQUIP_HRS,
        sum(pjp1.ACT_LABOR_BRDN_COST)                 ACT_LABOR_BRDN_COST,
        sum(pjp1.ACT_EQUIP_BRDN_COST)                 ACT_EQUIP_BRDN_COST,
        sum(pjp1.ACT_BRDN_COST)                       ACT_BRDN_COST,
        sum(pjp1.ACT_RAW_COST)                        ACT_RAW_COST,
        sum(pjp1.ACT_REVENUE)                         ACT_REVENUE,
        sum(pjp1.ACT_LABOR_RAW_COST)                  ACT_LABOR_RAW_COST,
        sum(pjp1.ACT_EQUIP_RAW_COST)                  ACT_EQUIP_RAW_COST,
        sum(pjp1.ETC_LABOR_HRS)                       ETC_LABOR_HRS,
        sum(pjp1.ETC_EQUIP_HRS)                       ETC_EQUIP_HRS,
        sum(pjp1.ETC_LABOR_BRDN_COST)                 ETC_LABOR_BRDN_COST,
        sum(pjp1.ETC_EQUIP_BRDN_COST)                 ETC_EQUIP_BRDN_COST,
        sum(pjp1.ETC_BRDN_COST)                       ETC_BRDN_COST,
        sum(pjp1.ETC_RAW_COST)                        ETC_RAW_COST,
        sum(pjp1.ETC_LABOR_RAW_COST)                  ETC_LABOR_RAW_COST,
        sum(pjp1.ETC_EQUIP_RAW_COST)                  ETC_EQUIP_RAW_COST,
        sum(pjp1.CUSTOM1)                             CUSTOM1,
        sum(pjp1.CUSTOM2)                             CUSTOM2,
        sum(pjp1.CUSTOM3)                             CUSTOM3,
        sum(pjp1.CUSTOM4)                             CUSTOM4,
        sum(pjp1.CUSTOM5)                             CUSTOM5,
        sum(pjp1.CUSTOM6)                             CUSTOM6,
        sum(pjp1.CUSTOM7)                             CUSTOM7,
        sum(pjp1.CUSTOM8)                             CUSTOM8,
        sum(pjp1.CUSTOM9)                             CUSTOM9,
        sum(pjp1.CUSTOM10)                            CUSTOM10,
        sum(pjp1.CUSTOM11)                            CUSTOM11,
        sum(pjp1.CUSTOM12)                            CUSTOM12,
        sum(pjp1.CUSTOM13)                            CUSTOM13,
        sum(pjp1.CUSTOM14)                            CUSTOM14,
        sum(pjp1.CUSTOM15)                            CUSTOM15
      from
        (
      select /*+ ordered index(wbs PA_XBS_DENORM_N2) */ -- smart slices
        decode(pjp1.RBS_AGGR_LEVEL ||
               decode(top_slice.INVERT_ID,
                      'PRJ', 'Y',
                             decode(wbs.SUP_EMT_ID,
                                    wbs.SUB_EMT_ID, 'N', 'Y')),
               'LN', 'X', null)                       RECORD_TYPE,
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', wbs.STRUCT_EMT_ID,
                      nvl(wbs.SUP_EMT_ID,
                          pjp1.PROJECT_ELEMENT_ID))   PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y',
                      decode(wbs.SUP_EMT_ID,
                             wbs.SUB_EMT_ID, 'N', 'Y')) WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        sum(pjp1.RAW_COST)                            RAW_COST,
        sum(pjp1.BRDN_COST)                           BRDN_COST,
        sum(pjp1.REVENUE)                             REVENUE,
        sum(pjp1.BILL_RAW_COST)                       BILL_RAW_COST,
        sum(pjp1.BILL_BRDN_COST)                      BILL_BRDN_COST,
        sum(pjp1.BILL_LABOR_RAW_COST)                 BILL_LABOR_RAW_COST,
        sum(pjp1.BILL_LABOR_BRDN_COST)                BILL_LABOR_BRDN_COST,
        sum(pjp1.BILL_LABOR_HRS)                      BILL_LABOR_HRS,
        sum(pjp1.EQUIPMENT_RAW_COST)                  EQUIPMENT_RAW_COST,
        sum(pjp1.EQUIPMENT_BRDN_COST)                 EQUIPMENT_BRDN_COST,
        sum(pjp1.CAPITALIZABLE_RAW_COST)              CAPITALIZABLE_RAW_COST,
        sum(pjp1.CAPITALIZABLE_BRDN_COST)             CAPITALIZABLE_BRDN_COST,
        sum(pjp1.LABOR_RAW_COST)                      LABOR_RAW_COST,
        sum(pjp1.LABOR_BRDN_COST)                     LABOR_BRDN_COST,
        sum(pjp1.LABOR_HRS)                           LABOR_HRS,
        sum(pjp1.LABOR_REVENUE)                       LABOR_REVENUE,
        sum(pjp1.EQUIPMENT_HOURS)                     EQUIPMENT_HOURS,
        sum(pjp1.BILLABLE_EQUIPMENT_HOURS)            BILLABLE_EQUIPMENT_HOURS,
        sum(pjp1.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        sum(pjp1.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        sum(pjp1.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        sum(pjp1.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        sum(pjp1.ACT_LABOR_HRS)                       ACT_LABOR_HRS,
        sum(pjp1.ACT_EQUIP_HRS)                       ACT_EQUIP_HRS,
        sum(pjp1.ACT_LABOR_BRDN_COST)                 ACT_LABOR_BRDN_COST,
        sum(pjp1.ACT_EQUIP_BRDN_COST)                 ACT_EQUIP_BRDN_COST,
        sum(pjp1.ACT_BRDN_COST)                       ACT_BRDN_COST,
        sum(pjp1.ACT_RAW_COST)                        ACT_RAW_COST,
        sum(pjp1.ACT_REVENUE)                         ACT_REVENUE,
        sum(pjp1.ACT_LABOR_RAW_COST)                  ACT_LABOR_RAW_COST,
        sum(pjp1.ACT_EQUIP_RAW_COST)                  ACT_EQUIP_RAW_COST,
        sum(pjp1.ETC_LABOR_HRS)                       ETC_LABOR_HRS,
        sum(pjp1.ETC_EQUIP_HRS)                       ETC_EQUIP_HRS,
        sum(pjp1.ETC_LABOR_BRDN_COST)                 ETC_LABOR_BRDN_COST,
        sum(pjp1.ETC_EQUIP_BRDN_COST)                 ETC_EQUIP_BRDN_COST,
        sum(pjp1.ETC_BRDN_COST)                       ETC_BRDN_COST,
        sum(pjp1.ETC_RAW_COST)                        ETC_RAW_COST,
        sum(pjp1.ETC_LABOR_RAW_COST)                  ETC_LABOR_RAW_COST,
        sum(pjp1.ETC_EQUIP_RAW_COST)                  ETC_EQUIP_RAW_COST,
        sum(pjp1.CUSTOM1)                             CUSTOM1,
        sum(pjp1.CUSTOM2)                             CUSTOM2,
        sum(pjp1.CUSTOM3)                             CUSTOM3,
        sum(pjp1.CUSTOM4)                             CUSTOM4,
        sum(pjp1.CUSTOM5)                             CUSTOM5,
        sum(pjp1.CUSTOM6)                             CUSTOM6,
        sum(pjp1.CUSTOM7)                             CUSTOM7,
        sum(pjp1.CUSTOM8)                             CUSTOM8,
        sum(pjp1.CUSTOM9)                             CUSTOM9,
        sum(pjp1.CUSTOM10)                            CUSTOM10,
        sum(pjp1.CUSTOM11)                            CUSTOM11,
        sum(pjp1.CUSTOM12)                            CUSTOM12,
        sum(pjp1.CUSTOM13)                            CUSTOM13,
        sum(pjp1.CUSTOM14)                            CUSTOM14,
        sum(pjp1.CUSTOM15)                            CUSTOM15
      from
        (
        select /*+ ordered */
          wbs_hdr.WBS_VERSION_ID,
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          decode(rbs.SUP_LEVEL,
                 rbs.SUB_LEVEL, 'L', 'R')             RBS_AGGR_LEVEL,
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          rbs.SUP_ID                                  RBS_ELEMENT_ID,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE,
          sum(pjp1.RAW_COST)                          RAW_COST,
          sum(pjp1.BRDN_COST)                         BRDN_COST,
          sum(pjp1.REVENUE)                           REVENUE,
          sum(pjp1.BILL_RAW_COST)                     BILL_RAW_COST,
          sum(pjp1.BILL_BRDN_COST)                    BILL_BRDN_COST,
          sum(pjp1.BILL_LABOR_RAW_COST)               BILL_LABOR_RAW_COST,
          sum(pjp1.BILL_LABOR_BRDN_COST)              BILL_LABOR_BRDN_COST,
          sum(pjp1.BILL_LABOR_HRS)                    BILL_LABOR_HRS,
          sum(pjp1.EQUIPMENT_RAW_COST)                EQUIPMENT_RAW_COST,
          sum(pjp1.EQUIPMENT_BRDN_COST)               EQUIPMENT_BRDN_COST,
          sum(pjp1.CAPITALIZABLE_RAW_COST)            CAPITALIZABLE_RAW_COST,
          sum(pjp1.CAPITALIZABLE_BRDN_COST)           CAPITALIZABLE_BRDN_COST,
          sum(pjp1.LABOR_RAW_COST)                    LABOR_RAW_COST,
          sum(pjp1.LABOR_BRDN_COST)                   LABOR_BRDN_COST,
          sum(pjp1.LABOR_HRS)                         LABOR_HRS,
          sum(pjp1.LABOR_REVENUE)                     LABOR_REVENUE,
          sum(pjp1.EQUIPMENT_HOURS)                   EQUIPMENT_HOURS,
          sum(pjp1.BILLABLE_EQUIPMENT_HOURS)          BILLABLE_EQUIPMENT_HOURS,
          sum(pjp1.SUP_INV_COMMITTED_COST)            SUP_INV_COMMITTED_COST,
          sum(pjp1.PO_COMMITTED_COST)                 PO_COMMITTED_COST,
          sum(pjp1.PR_COMMITTED_COST)                 PR_COMMITTED_COST,
          sum(pjp1.OTH_COMMITTED_COST)                OTH_COMMITTED_COST,
          sum(pjp1.ACT_LABOR_HRS)                     ACT_LABOR_HRS,
          sum(pjp1.ACT_EQUIP_HRS)                     ACT_EQUIP_HRS,
          sum(pjp1.ACT_LABOR_BRDN_COST)               ACT_LABOR_BRDN_COST,
          sum(pjp1.ACT_EQUIP_BRDN_COST)               ACT_EQUIP_BRDN_COST,
          sum(pjp1.ACT_BRDN_COST)                     ACT_BRDN_COST,
          sum(pjp1.ACT_RAW_COST)                      ACT_RAW_COST,
          sum(pjp1.ACT_REVENUE)                       ACT_REVENUE,
          sum(pjp1.ACT_LABOR_RAW_COST)                ACT_LABOR_RAW_COST,
          sum(pjp1.ACT_EQUIP_RAW_COST)                ACT_EQUIP_RAW_COST,
          sum(pjp1.ETC_LABOR_HRS)                     ETC_LABOR_HRS,
          sum(pjp1.ETC_EQUIP_HRS)                     ETC_EQUIP_HRS,
          sum(pjp1.ETC_LABOR_BRDN_COST)               ETC_LABOR_BRDN_COST,
          sum(pjp1.ETC_EQUIP_BRDN_COST)               ETC_EQUIP_BRDN_COST,
          sum(pjp1.ETC_BRDN_COST)                     ETC_BRDN_COST,
          sum(pjp1.ETC_RAW_COST)                      ETC_RAW_COST,
          sum(pjp1.ETC_LABOR_RAW_COST)                ETC_LABOR_RAW_COST,
          sum(pjp1.ETC_EQUIP_RAW_COST)                ETC_EQUIP_RAW_COST,
          sum(pjp1.CUSTOM1)                           CUSTOM1,
          sum(pjp1.CUSTOM2)                           CUSTOM2,
          sum(pjp1.CUSTOM3)                           CUSTOM3,
          sum(pjp1.CUSTOM4)                           CUSTOM4,
          sum(pjp1.CUSTOM5)                           CUSTOM5,
          sum(pjp1.CUSTOM6)                           CUSTOM6,
          sum(pjp1.CUSTOM7)                           CUSTOM7,
          sum(pjp1.CUSTOM8)                           CUSTOM8,
          sum(pjp1.CUSTOM9)                           CUSTOM9,
          sum(pjp1.CUSTOM10)                          CUSTOM10,
          sum(pjp1.CUSTOM11)                          CUSTOM11,
          sum(pjp1.CUSTOM12)                          CUSTOM12,
          sum(pjp1.CUSTOM13)                          CUSTOM13,
          sum(pjp1.CUSTOM14)                          CUSTOM14,
          sum(pjp1.CUSTOM15)                          CUSTOM15
        from
          PJI_FP_AGGR_PJP1        pjp1,
          PJI_ROLLUP_LEVEL_STATUS ss,
          PJI_PJP_RBS_HEADER      rbs_hdr,
          PJI_PJP_WBS_HEADER      wbs_hdr,
          PA_RBS_DENORM           rbs
        where
          l_extraction_type     <> 'RBS'                   and
          rbs.STRUCT_VERSION_ID =  ss.RBS_VERSION_ID       and
          pjp1.WORKER_ID        =  p_worker_id             and
          pjp1.RBS_AGGR_LEVEL   =  'L'                     and
          pjp1.WBS_ROLLUP_FLAG  =  'N'                     and
          pjp1.PRG_ROLLUP_FLAG  in ('Y', 'N')              and
          pjp1.PROJECT_ID       =  ss.PROJECT_ID           and
          pjp1.RBS_VERSION_ID   =  ss.RBS_VERSION_ID       and
          pjp1.RBS_ELEMENT_ID   =  rbs.SUB_ID              and
          pjp1.PLAN_VERSION_ID  =  ss.PLAN_VERSION_ID      and
          pjp1.PLAN_TYPE_CODE   =  ss.PLAN_TYPE_CODE       and
          pjp1.PROJECT_ID       =  rbs_hdr.PROJECT_ID      and
          pjp1.PLAN_VERSION_ID  =  rbs_hdr.PLAN_VERSION_ID and
          pjp1.PLAN_TYPE_CODE   =  rbs_hdr.PLAN_TYPE_CODE  and
          pjp1.RBS_VERSION_ID   =  rbs_hdr.RBS_VERSION_ID  and
          pjp1.PROJECT_ID       =  wbs_hdr.PROJECT_ID      and
          pjp1.PLAN_VERSION_ID  =  wbs_hdr.PLAN_VERSION_ID and
          pjp1.PLAN_TYPE_CODE   =  wbs_hdr.PLAN_TYPE_CODE  and
          decode(pjp1.PLAN_VERSION_ID,
                 -3, pjp1.PLAN_TYPE_ID,
                 -4, pjp1.PLAN_TYPE_ID,
                     -1)        =  decode(pjp1.PLAN_VERSION_ID,
                                          -3, wbs_hdr.PLAN_TYPE_ID,
                                          -4, wbs_hdr.PLAN_TYPE_ID,
                                              -1)
        group by
          wbs_hdr.WBS_VERSION_ID,
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          decode(rbs.SUP_LEVEL,
                 rbs.SUB_LEVEL, 'L', 'R'),
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          rbs.SUP_ID,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE
        )                  pjp1,
        PA_XBS_DENORM      wbs,
        (
          select 1     WBS_SUP_LEVEL,
                 'PRJ' INVERT_ID
          from   DUAL
          union all
          select 1     WBS_SUP_LEVEL,
                 'WBS' INVERT_ID
          from   DUAL
        ) top_slice
      where
        l_extraction_type       <> 'RBS'                       and
        'WBS'                   =  wbs.STRUCT_TYPE         (+) and
        pjp1.PROJECT_ID         =  wbs.SUP_PROJECT_ID      (+) and
        pjp1.WBS_VERSION_ID     =  wbs.STRUCT_VERSION_ID   (+) and
        pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID          (+) and
        wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+)
      group by
        decode(pjp1.RBS_AGGR_LEVEL ||
               decode(top_slice.INVERT_ID,
                      'PRJ', 'Y',
                             decode(wbs.SUP_EMT_ID,
                                    wbs.SUB_EMT_ID, 'N', 'Y')),
               'LN', 'X', null),
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', wbs.STRUCT_EMT_ID,
                      nvl(wbs.SUP_EMT_ID,
                          pjp1.PROJECT_ELEMENT_ID)),
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y',
                      decode(wbs.SUP_EMT_ID,
                             wbs.SUB_EMT_ID, 'N', 'Y')),
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE
        ) pjp1
      where
        nvl(pjp1.RECORD_TYPE, 'Y') = 'Y'
      group by
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES(p_worker_id);');

      commit;

    else -- online mode

      insert into PJI_FP_AGGR_PJP1_T pjp1_i
      (
        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        PLAN_TYPE_CODE,
        RAW_COST,
        BRDN_COST,
        REVENUE,
        BILL_RAW_COST,
        BILL_BRDN_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BRDN_COST,
        BILL_LABOR_HRS,
        EQUIPMENT_RAW_COST,
        EQUIPMENT_BRDN_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BRDN_COST,
        LABOR_HRS,
        LABOR_REVENUE,
        EQUIPMENT_HOURS,
        BILLABLE_EQUIPMENT_HOURS,
        SUP_INV_COMMITTED_COST,
        PO_COMMITTED_COST,
        PR_COMMITTED_COST,
        OTH_COMMITTED_COST,
        ACT_LABOR_HRS,
        ACT_EQUIP_HRS,
        ACT_LABOR_BRDN_COST,
        ACT_EQUIP_BRDN_COST,
        ACT_BRDN_COST,
        ACT_RAW_COST,
        ACT_REVENUE,
        ACT_LABOR_RAW_COST,
        ACT_EQUIP_RAW_COST,
        ETC_LABOR_HRS,
        ETC_EQUIP_HRS,
        ETC_LABOR_BRDN_COST,
        ETC_EQUIP_BRDN_COST,
        ETC_BRDN_COST,
        ETC_RAW_COST,
        ETC_LABOR_RAW_COST,
        ETC_EQUIP_RAW_COST,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select
        1                                             WORKER_ID,
        -- p_worker_id                                WORKER_ID,
        'R'                                           RECORD_TYPE,
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        sum(pjp1.RAW_COST)                            RAW_COST,
        sum(pjp1.BRDN_COST)                           BRDN_COST,
        sum(pjp1.REVENUE)                             REVENUE,
        sum(pjp1.BILL_RAW_COST)                       BILL_RAW_COST,
        sum(pjp1.BILL_BRDN_COST)                      BILL_BRDN_COST,
        sum(pjp1.BILL_LABOR_RAW_COST)                 BILL_LABOR_RAW_COST,
        sum(pjp1.BILL_LABOR_BRDN_COST)                BILL_LABOR_BRDN_COST,
        sum(pjp1.BILL_LABOR_HRS)                      BILL_LABOR_HRS,
        sum(pjp1.EQUIPMENT_RAW_COST)                  EQUIPMENT_RAW_COST,
        sum(pjp1.EQUIPMENT_BRDN_COST)                 EQUIPMENT_BRDN_COST,
        sum(pjp1.CAPITALIZABLE_RAW_COST)              CAPITALIZABLE_RAW_COST,
        sum(pjp1.CAPITALIZABLE_BRDN_COST)             CAPITALIZABLE_BRDN_COST,
        sum(pjp1.LABOR_RAW_COST)                      LABOR_RAW_COST,
        sum(pjp1.LABOR_BRDN_COST)                     LABOR_BRDN_COST,
        sum(pjp1.LABOR_HRS)                           LABOR_HRS,
        sum(pjp1.LABOR_REVENUE)                       LABOR_REVENUE,
        sum(pjp1.EQUIPMENT_HOURS)                     EQUIPMENT_HOURS,
        sum(pjp1.BILLABLE_EQUIPMENT_HOURS)            BILLABLE_EQUIPMENT_HOURS,
        sum(pjp1.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        sum(pjp1.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        sum(pjp1.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        sum(pjp1.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        sum(pjp1.ACT_LABOR_HRS)                       ACT_LABOR_HRS,
        sum(pjp1.ACT_EQUIP_HRS)                       ACT_EQUIP_HRS,
        sum(pjp1.ACT_LABOR_BRDN_COST)                 ACT_LABOR_BRDN_COST,
        sum(pjp1.ACT_EQUIP_BRDN_COST)                 ACT_EQUIP_BRDN_COST,
        sum(pjp1.ACT_BRDN_COST)                       ACT_BRDN_COST,
        sum(pjp1.ACT_RAW_COST)                        ACT_RAW_COST,
        sum(pjp1.ACT_REVENUE)                         ACT_REVENUE,
        sum(pjp1.ACT_LABOR_RAW_COST)                  ACT_LABOR_RAW_COST,
        sum(pjp1.ACT_EQUIP_RAW_COST)                  ACT_EQUIP_RAW_COST,
        sum(pjp1.ETC_LABOR_HRS)                       ETC_LABOR_HRS,
        sum(pjp1.ETC_EQUIP_HRS)                       ETC_EQUIP_HRS,
        sum(pjp1.ETC_LABOR_BRDN_COST)                 ETC_LABOR_BRDN_COST,
        sum(pjp1.ETC_EQUIP_BRDN_COST)                 ETC_EQUIP_BRDN_COST,
        sum(pjp1.ETC_BRDN_COST)                       ETC_BRDN_COST,
        sum(pjp1.ETC_RAW_COST)                        ETC_RAW_COST,
        sum(pjp1.ETC_LABOR_RAW_COST)                  ETC_LABOR_RAW_COST,
        sum(pjp1.ETC_EQUIP_RAW_COST)                  ETC_EQUIP_RAW_COST,
        sum(pjp1.CUSTOM1)                             CUSTOM1,
        sum(pjp1.CUSTOM2)                             CUSTOM2,
        sum(pjp1.CUSTOM3)                             CUSTOM3,
        sum(pjp1.CUSTOM4)                             CUSTOM4,
        sum(pjp1.CUSTOM5)                             CUSTOM5,
        sum(pjp1.CUSTOM6)                             CUSTOM6,
        sum(pjp1.CUSTOM7)                             CUSTOM7,
        sum(pjp1.CUSTOM8)                             CUSTOM8,
        sum(pjp1.CUSTOM9)                             CUSTOM9,
        sum(pjp1.CUSTOM10)                            CUSTOM10,
        sum(pjp1.CUSTOM11)                            CUSTOM11,
        sum(pjp1.CUSTOM12)                            CUSTOM12,
        sum(pjp1.CUSTOM13)                            CUSTOM13,
        sum(pjp1.CUSTOM14)                            CUSTOM14,
        sum(pjp1.CUSTOM15)                            CUSTOM15
      from
        (
      select /*+ ordered index(wbs PA_XBS_DENORM_N2) */ -- smart slices
        decode(pjp1.RBS_AGGR_LEVEL ||
               decode(top_slice.INVERT_ID,
                      'PRJ', 'Y',
                             decode(wbs.SUP_EMT_ID,
                                    wbs.SUB_EMT_ID, 'N', 'Y')),
               'LN', 'X', null)                       RECORD_TYPE,
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', wbs.STRUCT_EMT_ID,
                      nvl(wbs.SUP_EMT_ID,
                          pjp1.PROJECT_ELEMENT_ID))   PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y',
                      decode(wbs.SUP_EMT_ID,
                             wbs.SUB_EMT_ID, 'N', 'Y')) WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        sum(pjp1.RAW_COST)                            RAW_COST,
        sum(pjp1.BRDN_COST)                           BRDN_COST,
        sum(pjp1.REVENUE)                             REVENUE,
        sum(pjp1.BILL_RAW_COST)                       BILL_RAW_COST,
        sum(pjp1.BILL_BRDN_COST)                      BILL_BRDN_COST,
        sum(pjp1.BILL_LABOR_RAW_COST)                 BILL_LABOR_RAW_COST,
        sum(pjp1.BILL_LABOR_BRDN_COST)                BILL_LABOR_BRDN_COST,
        sum(pjp1.BILL_LABOR_HRS)                      BILL_LABOR_HRS,
        sum(pjp1.EQUIPMENT_RAW_COST)                  EQUIPMENT_RAW_COST,
        sum(pjp1.EQUIPMENT_BRDN_COST)                 EQUIPMENT_BRDN_COST,
        sum(pjp1.CAPITALIZABLE_RAW_COST)              CAPITALIZABLE_RAW_COST,
        sum(pjp1.CAPITALIZABLE_BRDN_COST)             CAPITALIZABLE_BRDN_COST,
        sum(pjp1.LABOR_RAW_COST)                      LABOR_RAW_COST,
        sum(pjp1.LABOR_BRDN_COST)                     LABOR_BRDN_COST,
        sum(pjp1.LABOR_HRS)                           LABOR_HRS,
        sum(pjp1.LABOR_REVENUE)                       LABOR_REVENUE,
        sum(pjp1.EQUIPMENT_HOURS)                     EQUIPMENT_HOURS,
        sum(pjp1.BILLABLE_EQUIPMENT_HOURS)            BILLABLE_EQUIPMENT_HOURS,
        sum(pjp1.SUP_INV_COMMITTED_COST)              SUP_INV_COMMITTED_COST,
        sum(pjp1.PO_COMMITTED_COST)                   PO_COMMITTED_COST,
        sum(pjp1.PR_COMMITTED_COST)                   PR_COMMITTED_COST,
        sum(pjp1.OTH_COMMITTED_COST)                  OTH_COMMITTED_COST,
        sum(pjp1.ACT_LABOR_HRS)                       ACT_LABOR_HRS,
        sum(pjp1.ACT_EQUIP_HRS)                       ACT_EQUIP_HRS,
        sum(pjp1.ACT_LABOR_BRDN_COST)                 ACT_LABOR_BRDN_COST,
        sum(pjp1.ACT_EQUIP_BRDN_COST)                 ACT_EQUIP_BRDN_COST,
        sum(pjp1.ACT_BRDN_COST)                       ACT_BRDN_COST,
        sum(pjp1.ACT_RAW_COST)                        ACT_RAW_COST,
        sum(pjp1.ACT_REVENUE)                         ACT_REVENUE,
        sum(pjp1.ACT_LABOR_RAW_COST)                  ACT_LABOR_RAW_COST,
        sum(pjp1.ACT_EQUIP_RAW_COST)                  ACT_EQUIP_RAW_COST,
        sum(pjp1.ETC_LABOR_HRS)                       ETC_LABOR_HRS,
        sum(pjp1.ETC_EQUIP_HRS)                       ETC_EQUIP_HRS,
        sum(pjp1.ETC_LABOR_BRDN_COST)                 ETC_LABOR_BRDN_COST,
        sum(pjp1.ETC_EQUIP_BRDN_COST)                 ETC_EQUIP_BRDN_COST,
        sum(pjp1.ETC_BRDN_COST)                       ETC_BRDN_COST,
        sum(pjp1.ETC_RAW_COST)                        ETC_RAW_COST,
        sum(pjp1.ETC_LABOR_RAW_COST)                  ETC_LABOR_RAW_COST,
        sum(pjp1.ETC_EQUIP_RAW_COST)                  ETC_EQUIP_RAW_COST,
        sum(pjp1.CUSTOM1)                             CUSTOM1,
        sum(pjp1.CUSTOM2)                             CUSTOM2,
        sum(pjp1.CUSTOM3)                             CUSTOM3,
        sum(pjp1.CUSTOM4)                             CUSTOM4,
        sum(pjp1.CUSTOM5)                             CUSTOM5,
        sum(pjp1.CUSTOM6)                             CUSTOM6,
        sum(pjp1.CUSTOM7)                             CUSTOM7,
        sum(pjp1.CUSTOM8)                             CUSTOM8,
        sum(pjp1.CUSTOM9)                             CUSTOM9,
        sum(pjp1.CUSTOM10)                            CUSTOM10,
        sum(pjp1.CUSTOM11)                            CUSTOM11,
        sum(pjp1.CUSTOM12)                            CUSTOM12,
        sum(pjp1.CUSTOM13)                            CUSTOM13,
        sum(pjp1.CUSTOM14)                            CUSTOM14,
        sum(pjp1.CUSTOM15)                            CUSTOM15
      from
        (
        select /*+ ordered */
          wbs_hdr.WBS_VERSION_ID,
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          decode(rbs.SUP_LEVEL,
                 rbs.SUB_LEVEL, 'L', 'R')             RBS_AGGR_LEVEL,
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          rbs.SUP_ID                                  RBS_ELEMENT_ID,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE,
          sum(pjp1.RAW_COST)                          RAW_COST,
          sum(pjp1.BRDN_COST)                         BRDN_COST,
          sum(pjp1.REVENUE)                           REVENUE,
          sum(pjp1.BILL_RAW_COST)                     BILL_RAW_COST,
          sum(pjp1.BILL_BRDN_COST)                    BILL_BRDN_COST,
          sum(pjp1.BILL_LABOR_RAW_COST)               BILL_LABOR_RAW_COST,
          sum(pjp1.BILL_LABOR_BRDN_COST)              BILL_LABOR_BRDN_COST,
          sum(pjp1.BILL_LABOR_HRS)                    BILL_LABOR_HRS,
          sum(pjp1.EQUIPMENT_RAW_COST)                EQUIPMENT_RAW_COST,
          sum(pjp1.EQUIPMENT_BRDN_COST)               EQUIPMENT_BRDN_COST,
          sum(pjp1.CAPITALIZABLE_RAW_COST)            CAPITALIZABLE_RAW_COST,
          sum(pjp1.CAPITALIZABLE_BRDN_COST)           CAPITALIZABLE_BRDN_COST,
          sum(pjp1.LABOR_RAW_COST)                    LABOR_RAW_COST,
          sum(pjp1.LABOR_BRDN_COST)                   LABOR_BRDN_COST,
          sum(pjp1.LABOR_HRS)                         LABOR_HRS,
          sum(pjp1.LABOR_REVENUE)                     LABOR_REVENUE,
          sum(pjp1.EQUIPMENT_HOURS)                   EQUIPMENT_HOURS,
          sum(pjp1.BILLABLE_EQUIPMENT_HOURS)          BILLABLE_EQUIPMENT_HOURS,
          sum(pjp1.SUP_INV_COMMITTED_COST)            SUP_INV_COMMITTED_COST,
          sum(pjp1.PO_COMMITTED_COST)                 PO_COMMITTED_COST,
          sum(pjp1.PR_COMMITTED_COST)                 PR_COMMITTED_COST,
          sum(pjp1.OTH_COMMITTED_COST)                OTH_COMMITTED_COST,
          sum(pjp1.ACT_LABOR_HRS)                     ACT_LABOR_HRS,
          sum(pjp1.ACT_EQUIP_HRS)                     ACT_EQUIP_HRS,
          sum(pjp1.ACT_LABOR_BRDN_COST)               ACT_LABOR_BRDN_COST,
          sum(pjp1.ACT_EQUIP_BRDN_COST)               ACT_EQUIP_BRDN_COST,
          sum(pjp1.ACT_BRDN_COST)                     ACT_BRDN_COST,
          sum(pjp1.ACT_RAW_COST)                      ACT_RAW_COST,
          sum(pjp1.ACT_REVENUE)                       ACT_REVENUE,
          sum(pjp1.ACT_LABOR_RAW_COST)                ACT_LABOR_RAW_COST,
          sum(pjp1.ACT_EQUIP_RAW_COST)                ACT_EQUIP_RAW_COST,
          sum(pjp1.ETC_LABOR_HRS)                     ETC_LABOR_HRS,
          sum(pjp1.ETC_EQUIP_HRS)                     ETC_EQUIP_HRS,
          sum(pjp1.ETC_LABOR_BRDN_COST)               ETC_LABOR_BRDN_COST,
          sum(pjp1.ETC_EQUIP_BRDN_COST)               ETC_EQUIP_BRDN_COST,
          sum(pjp1.ETC_BRDN_COST)                     ETC_BRDN_COST,
          sum(pjp1.ETC_RAW_COST)                      ETC_RAW_COST,
          sum(pjp1.ETC_LABOR_RAW_COST)                ETC_LABOR_RAW_COST,
          sum(pjp1.ETC_EQUIP_RAW_COST)                ETC_EQUIP_RAW_COST,
          sum(pjp1.CUSTOM1)                           CUSTOM1,
          sum(pjp1.CUSTOM2)                           CUSTOM2,
          sum(pjp1.CUSTOM3)                           CUSTOM3,
          sum(pjp1.CUSTOM4)                           CUSTOM4,
          sum(pjp1.CUSTOM5)                           CUSTOM5,
          sum(pjp1.CUSTOM6)                           CUSTOM6,
          sum(pjp1.CUSTOM7)                           CUSTOM7,
          sum(pjp1.CUSTOM8)                           CUSTOM8,
          sum(pjp1.CUSTOM9)                           CUSTOM9,
          sum(pjp1.CUSTOM10)                          CUSTOM10,
          sum(pjp1.CUSTOM11)                          CUSTOM11,
          sum(pjp1.CUSTOM12)                          CUSTOM12,
          sum(pjp1.CUSTOM13)                          CUSTOM13,
          sum(pjp1.CUSTOM14)                          CUSTOM14,
          sum(pjp1.CUSTOM15)                          CUSTOM15
        from
          PJI_FP_AGGR_PJP1_T      pjp1,
          PJI_ROLLUP_LEVEL_STATUS ss,
          PJI_PJP_RBS_HEADER      rbs_hdr,
          PJI_PJP_WBS_HEADER      wbs_hdr,
          PA_RBS_DENORM           rbs
        where
          -- l_extraction_type  <> 'RBS'                   and
          rbs.STRUCT_VERSION_ID =  ss.RBS_VERSION_ID       and
          -- pjp1.WORKER_ID     =  p_worker_id             and
          pjp1.RBS_AGGR_LEVEL   =  'L'                     and
          pjp1.WBS_ROLLUP_FLAG  =  'N'                     and
          pjp1.PRG_ROLLUP_FLAG  in ('Y', 'N')              and
          pjp1.PROJECT_ID       =  ss.PROJECT_ID           and
          pjp1.RBS_VERSION_ID   =  ss.RBS_VERSION_ID       and
          pjp1.RBS_ELEMENT_ID   =  rbs.SUB_ID              and
          pjp1.PLAN_VERSION_ID  =  ss.PLAN_VERSION_ID      and
          pjp1.PLAN_TYPE_CODE   =  ss.PLAN_TYPE_CODE       and
          pjp1.PROJECT_ID       =  rbs_hdr.PROJECT_ID      and
          pjp1.PLAN_VERSION_ID  =  rbs_hdr.PLAN_VERSION_ID and
          pjp1.PLAN_TYPE_CODE   =  rbs_hdr.PLAN_TYPE_CODE  and
          pjp1.RBS_VERSION_ID   =  rbs_hdr.RBS_VERSION_ID  and
          pjp1.PROJECT_ID       =  wbs_hdr.PROJECT_ID      and
          pjp1.PLAN_VERSION_ID  =  wbs_hdr.PLAN_VERSION_ID and
          pjp1.PLAN_TYPE_CODE   =  wbs_hdr.PLAN_TYPE_CODE  and
          decode(pjp1.PLAN_VERSION_ID,
                 -3, pjp1.PLAN_TYPE_ID,
                 -4, pjp1.PLAN_TYPE_ID,
                     -1)        =  decode(pjp1.PLAN_VERSION_ID,
                                          -3, wbs_hdr.PLAN_TYPE_ID,
                                          -4, wbs_hdr.PLAN_TYPE_ID,
                                              -1)
        group by
          wbs_hdr.WBS_VERSION_ID,
          pjp1.PRG_LEVEL,
          pjp1.LINE_TYPE,
          pjp1.PROJECT_ID,
          pjp1.PROJECT_ORG_ID,
          pjp1.PROJECT_ORGANIZATION_ID,
          pjp1.PROJECT_ELEMENT_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          decode(rbs.SUP_LEVEL,
                 rbs.SUB_LEVEL, 'L', 'R'),
          pjp1.WBS_ROLLUP_FLAG,
          pjp1.PRG_ROLLUP_FLAG,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          rbs.SUP_ID,
          pjp1.RBS_VERSION_ID,
          pjp1.PLAN_VERSION_ID,
          pjp1.PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE
        )                  pjp1,
        PA_XBS_DENORM      wbs,
        (
          select 1     WBS_SUP_LEVEL,
                 'PRJ' INVERT_ID
          from   DUAL
          union all
          select 1     WBS_SUP_LEVEL,
                 'WBS' INVERT_ID
          from   DUAL
        ) top_slice
      where
        -- l_extraction_type    <> 'RBS'                       and
        'WBS'                   =  wbs.STRUCT_TYPE         (+) and
        pjp1.PROJECT_ID         =  wbs.SUP_PROJECT_ID      (+) and
        pjp1.WBS_VERSION_ID     =  wbs.STRUCT_VERSION_ID   (+) and
        pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID          (+) and
        wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+)
      group by
        decode(pjp1.RBS_AGGR_LEVEL ||
               decode(top_slice.INVERT_ID,
                      'PRJ', 'Y',
                             decode(wbs.SUP_EMT_ID,
                                    wbs.SUB_EMT_ID, 'N', 'Y')),
               'LN', 'X', null),
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', wbs.STRUCT_EMT_ID,
                      nvl(wbs.SUP_EMT_ID,
                          pjp1.PROJECT_ELEMENT_ID)),
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y',
                      decode(wbs.SUP_EMT_ID,
                             wbs.SUB_EMT_ID, 'N', 'Y')),
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE
        ) pjp1
      where
        nvl(pjp1.RECORD_TYPE, 'Y') = 'Y'
      group by
        pjp1.PRG_LEVEL,
        pjp1.LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE;

    end if;

  end ROLLUP_FPR_RBS_SMART_SLICES;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_WBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_WBS (p_worker_id in number default null) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_level           number;
    l_max_level       number;
    l_step_seq        number;
    l_level_seq       number;
    l_count           number;

  begin

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_WBS(p_worker_id);')) then
        return;
      end if;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      -- allow recovery after each level is processed

      select
        STEP_SEQ
      into
        l_step_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME = 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_WBS(p_worker_id);';

      select
        count(*)
      into
        l_count
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_ACR_WBS%';

      if (l_count = 0) then

        select /*+ ordered index(den PJI_XBS_DENORM_N3) use_hash(den) */             /* Modified for Bug 7669026 */
          nvl(max(den.SUP_LEVEL), 0)
        into
          l_level
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PJI_XBS_DENORM den
        where
          map.WORKER_ID      = p_worker_id    and
          den.STRUCT_TYPE    = 'PRG'          and
          den.SUB_LEVEL      = den.SUP_LEVEL  and
          den.SUP_PROJECT_ID = map.PROJECT_ID;

        PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                               'MAX_PROGRAM_LEVEL',
                                               l_level);

        for x in 1 .. l_level loop

          insert into PJI_SYSTEM_PRC_STATUS
          (
            PROCESS_NAME,
            STEP_SEQ,
            STEP_STATUS,
            STEP_NAME,
            START_DATE,
            END_DATE
          )
          select
            l_process                                             PROCESS_NAME,
            to_char(l_step_seq + x / 1000)                        STEP_SEQ,
            null                                                  STEP_STATUS,
            'ROLLUP_ACR_WBS - level ' || to_char(l_level - x + 1) STEP_NAME,
            null                                                  START_DATE,
            null                                                  END_DATE
          from
            DUAL;

        end loop;

      end if;

      l_max_level := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                     (l_process, 'MAX_PROGRAM_LEVEL');

      select
        nvl(to_number(min(STEP_SEQ)), 0)
      into
        l_level_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_ACR_WBS%' and
        STEP_STATUS is null;

      if (l_level_seq = 0) then
        l_level := 0;
      else
        l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
      end if;

      while (l_level > 0) loop

        update PJI_SYSTEM_PRC_STATUS
        set    START_DATE = sysdate
        where  PROCESS_NAME = l_process and
               STEP_SEQ = l_level_seq;

        -- rollup project hiearchy
/* Call to Paritioned procedure for bug 7551819 */
        PJI_PROCESS_UTIL.EXECUTE_ROLLUP_ACR_WBS(p_worker_id,
                                                l_level);

/* Commented for bug 7551819 */
--         insert /*+ parallel(pjp1_in)
  --                 noappend(pjp1_in) */ into PJI_AC_AGGR_PJP1 pjp1_in       -- changed for bug 5927368
    /*    (          WORKER_ID,
          RECORD_TYPE,
          PRG_LEVEL,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          PROJECT_ELEMENT_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          WBS_ROLLUP_FLAG,
          PRG_ROLLUP_FLAG,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          REVENUE,
          INITIAL_FUNDING_AMOUNT,
          INITIAL_FUNDING_COUNT,
          ADDITIONAL_FUNDING_AMOUNT,
          ADDITIONAL_FUNDING_COUNT,
          CANCELLED_FUNDING_AMOUNT,
          CANCELLED_FUNDING_COUNT,
          FUNDING_ADJUSTMENT_AMOUNT,
          FUNDING_ADJUSTMENT_COUNT,
          REVENUE_WRITEOFF,
          AR_INVOICE_AMOUNT,
          AR_INVOICE_COUNT,
          AR_CASH_APPLIED_AMOUNT,
          AR_INVOICE_WRITE_OFF_AMOUNT,
          AR_INVOICE_WRITEOFF_COUNT,
          AR_CREDIT_MEMO_AMOUNT,
          AR_CREDIT_MEMO_COUNT,
          UNBILLED_RECEIVABLES,
          UNEARNED_REVENUE,
          AR_UNAPPR_INVOICE_AMOUNT,
          AR_UNAPPR_INVOICE_COUNT,
          AR_APPR_INVOICE_AMOUNT,
          AR_APPR_INVOICE_COUNT,
          AR_AMOUNT_DUE,
          AR_COUNT_DUE,
          AR_AMOUNT_OVERDUE,
          AR_COUNT_OVERDUE,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15
        )
        select
          pjp1_i.WORKER_ID,
          pjp1_i.RECORD_TYPE,
          pjp1_i.PRG_LEVEL,
          pjp1_i.PROJECT_ID,
          pjp1_i.PROJECT_ORG_ID,
          pjp1_i.PROJECT_ORGANIZATION_ID,
          pjp1_i.PROJECT_ELEMENT_ID,
          pjp1_i.TIME_ID,
          pjp1_i.PERIOD_TYPE_ID,
          pjp1_i.CALENDAR_TYPE,
          pjp1_i.WBS_ROLLUP_FLAG,
          pjp1_i.PRG_ROLLUP_FLAG,
          pjp1_i.CURR_RECORD_TYPE_ID,
          pjp1_i.CURRENCY_CODE,
          pjp1_i.REVENUE,
          pjp1_i.INITIAL_FUNDING_AMOUNT,
          pjp1_i.INITIAL_FUNDING_COUNT,
          pjp1_i.ADDITIONAL_FUNDING_AMOUNT,
          pjp1_i.ADDITIONAL_FUNDING_COUNT,
          pjp1_i.CANCELLED_FUNDING_AMOUNT,
          pjp1_i.CANCELLED_FUNDING_COUNT,
          pjp1_i.FUNDING_ADJUSTMENT_AMOUNT,
          pjp1_i.FUNDING_ADJUSTMENT_COUNT,
          pjp1_i.REVENUE_WRITEOFF,
          pjp1_i.AR_INVOICE_AMOUNT,
          pjp1_i.AR_INVOICE_COUNT,
          pjp1_i.AR_CASH_APPLIED_AMOUNT,
          pjp1_i.AR_INVOICE_WRITE_OFF_AMOUNT,
          pjp1_i.AR_INVOICE_WRITEOFF_COUNT,
          pjp1_i.AR_CREDIT_MEMO_AMOUNT,
          pjp1_i.AR_CREDIT_MEMO_COUNT,
          pjp1_i.UNBILLED_RECEIVABLES,
          pjp1_i.UNEARNED_REVENUE,
          pjp1_i.AR_UNAPPR_INVOICE_AMOUNT,
          pjp1_i.AR_UNAPPR_INVOICE_COUNT,
          pjp1_i.AR_APPR_INVOICE_AMOUNT,
          pjp1_i.AR_APPR_INVOICE_COUNT,
          pjp1_i.AR_AMOUNT_DUE,
          pjp1_i.AR_COUNT_DUE,
          pjp1_i.AR_AMOUNT_OVERDUE,
          pjp1_i.AR_COUNT_OVERDUE,
          pjp1_i.CUSTOM1,
          pjp1_i.CUSTOM2,
          pjp1_i.CUSTOM3,
          pjp1_i.CUSTOM4,
          pjp1_i.CUSTOM5,
          pjp1_i.CUSTOM6,
          pjp1_i.CUSTOM7,
          pjp1_i.CUSTOM8,
          pjp1_i.CUSTOM9,
          pjp1_i.CUSTOM10,
          pjp1_i.CUSTOM11,
          pjp1_i.CUSTOM12,
          pjp1_i.CUSTOM13,
          pjp1_i.CUSTOM14,
          pjp1_i.CUSTOM15
        from
          (
        select
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y')             INSERT_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_ID)                 SUP_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_EMT_ID)             SUP_EMT_ID,
          p_worker_id                              WORKER_ID,
          'W'                                      RECORD_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL)           PRG_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID,
                 prg.SUP_PROJECT_ID)               PROJECT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID)           PROJECT_ORG_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID)  PROJECT_ORGANIZATION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID)                PROJECT_ELEMENT_ID,
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N')         WBS_ROLLUP_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y')         PRG_ROLLUP_FLAG,
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          sum(pjp.REVENUE)                         REVENUE,
          sum(pjp.INITIAL_FUNDING_AMOUNT)          INITIAL_FUNDING_AMOUNT,
          sum(pjp.INITIAL_FUNDING_COUNT)           INITIAL_FUNDING_COUNT,
          sum(pjp.ADDITIONAL_FUNDING_AMOUNT)       ADDITIONAL_FUNDING_AMOUNT,
          sum(pjp.ADDITIONAL_FUNDING_COUNT)        ADDITIONAL_FUNDING_COUNT,
          sum(pjp.CANCELLED_FUNDING_AMOUNT)        CANCELLED_FUNDING_AMOUNT,
          sum(pjp.CANCELLED_FUNDING_COUNT)         CANCELLED_FUNDING_COUNT,
          sum(pjp.FUNDING_ADJUSTMENT_AMOUNT)       FUNDING_ADJUSTMENT_AMOUNT,
          sum(pjp.FUNDING_ADJUSTMENT_COUNT)        FUNDING_ADJUSTMENT_COUNT,
          sum(pjp.REVENUE_WRITEOFF)                REVENUE_WRITEOFF,
          sum(pjp.AR_INVOICE_AMOUNT)               AR_INVOICE_AMOUNT,
          sum(pjp.AR_INVOICE_COUNT)                AR_INVOICE_COUNT,
          sum(pjp.AR_CASH_APPLIED_AMOUNT)          AR_CASH_APPLIED_AMOUNT,
          sum(pjp.AR_INVOICE_WRITE_OFF_AMOUNT)     AR_INVOICE_WRITE_OFF_AMOUNT,
          sum(pjp.AR_INVOICE_WRITEOFF_COUNT)       AR_INVOICE_WRITEOFF_COUNT,
          sum(pjp.AR_CREDIT_MEMO_AMOUNT)           AR_CREDIT_MEMO_AMOUNT,
          sum(pjp.AR_CREDIT_MEMO_COUNT)            AR_CREDIT_MEMO_COUNT,
          sum(pjp.UNBILLED_RECEIVABLES)            UNBILLED_RECEIVABLES,
          sum(pjp.UNEARNED_REVENUE)                UNEARNED_REVENUE,
          sum(pjp.AR_UNAPPR_INVOICE_AMOUNT)        AR_UNAPPR_INVOICE_AMOUNT,
          sum(pjp.AR_UNAPPR_INVOICE_COUNT)         AR_UNAPPR_INVOICE_COUNT,
          sum(pjp.AR_APPR_INVOICE_AMOUNT)          AR_APPR_INVOICE_AMOUNT,
          sum(pjp.AR_APPR_INVOICE_COUNT)           AR_APPR_INVOICE_COUNT,
          sum(pjp.AR_AMOUNT_DUE)                   AR_AMOUNT_DUE,
          sum(pjp.AR_COUNT_DUE)                    AR_COUNT_DUE,
          sum(pjp.AR_AMOUNT_OVERDUE)               AR_AMOUNT_OVERDUE,
          sum(pjp.AR_COUNT_OVERDUE)                AR_COUNT_OVERDUE,
          sum(pjp.CUSTOM1)                         CUSTOM1,
          sum(pjp.CUSTOM2)                         CUSTOM2,
          sum(pjp.CUSTOM3)                         CUSTOM3,
          sum(pjp.CUSTOM4)                         CUSTOM4,
          sum(pjp.CUSTOM5)                         CUSTOM5,
          sum(pjp.CUSTOM6)                         CUSTOM6,
          sum(pjp.CUSTOM7)                         CUSTOM7,
          sum(pjp.CUSTOM8)                         CUSTOM8,
          sum(pjp.CUSTOM9)                         CUSTOM9,
          sum(pjp.CUSTOM10)                        CUSTOM10,
          sum(pjp.CUSTOM11)                        CUSTOM11,
          sum(pjp.CUSTOM12)                        CUSTOM12,
          sum(pjp.CUSTOM13)                        CUSTOM13,
          sum(pjp.CUSTOM14)                        CUSTOM14,
          sum(pjp.CUSTOM15)                        CUSTOM15
        from
          (
          select /*+ ordered index(wbs PA_XBS_DENORM_N2) */
                 -- get incremental task level amounts from source and
                 -- program rollup amounts from interim
            /*wbs_hdr.WBS_VERSION_ID,
            'LF'                                      RELATIONSHIP_TYPE,
            decode(top_slice.INVERT_ID,
                   'PRJ', 'Y',
                          decode(wbs.SUB_LEVEL,
                                 1, 'Y', 'N'))        PUSHUP_FLAG,
            'Y'                                       INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.REVENUE,
            pjp1.INITIAL_FUNDING_AMOUNT,
            pjp1.INITIAL_FUNDING_COUNT,
            pjp1.ADDITIONAL_FUNDING_AMOUNT,
            pjp1.ADDITIONAL_FUNDING_COUNT,
            pjp1.CANCELLED_FUNDING_AMOUNT,
            pjp1.CANCELLED_FUNDING_COUNT,
            pjp1.FUNDING_ADJUSTMENT_AMOUNT,
            pjp1.FUNDING_ADJUSTMENT_COUNT,
            pjp1.REVENUE_WRITEOFF,
            pjp1.AR_INVOICE_AMOUNT,
            pjp1.AR_INVOICE_COUNT,
            pjp1.AR_CASH_APPLIED_AMOUNT,
            pjp1.AR_INVOICE_WRITE_OFF_AMOUNT,
            pjp1.AR_INVOICE_WRITEOFF_COUNT,
            pjp1.AR_CREDIT_MEMO_AMOUNT,
            pjp1.AR_CREDIT_MEMO_COUNT,
            pjp1.UNBILLED_RECEIVABLES,
            pjp1.UNEARNED_REVENUE,
            pjp1.AR_UNAPPR_INVOICE_AMOUNT,
            pjp1.AR_UNAPPR_INVOICE_COUNT,
            pjp1.AR_APPR_INVOICE_AMOUNT,
            pjp1.AR_APPR_INVOICE_COUNT,
            pjp1.AR_AMOUNT_DUE,
            pjp1.AR_COUNT_DUE,
            pjp1.AR_AMOUNT_OVERDUE,
            pjp1.AR_COUNT_OVERDUE,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_AC_AGGR_PJP1   pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PA_XBS_DENORM      wbs,
            PJI_XBS_DENORM     prg,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            ((wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1) or
             (wbs.SUP_LEVEL <> wbs.SUB_LEVEL))                     and
            wbs.STRUCT_VERSION_ID   =  prg.SUP_ID                  and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            pjp1.WORKER_ID          =  p_worker_id                 and
            pjp1.PRG_LEVEL          in (0, l_level)                and
            pjp1.WBS_ROLLUP_FLAG    =  'N'                         and
            pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                  and
            wbs_hdr.PLAN_VERSION_ID =  -1                          and
            pjp1.PROJECT_ID         =  wbs_hdr.PROJECT_ID          and
            wbs.STRUCT_VERSION_ID   =  wbs_hdr.WBS_VERSION_ID      and
            pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID              and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+)
          union all
          select /*+ ordered */
                 -- get incremental project level amounts from source
           /* wbs_hdr.WBS_VERSION_ID,
            'LF'                                   RELATIONSHIP_TYPE,
            'Y'                                    PUSHUP_FLAG,
            'N'                                    INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            pjp1.PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            'Y'                                    WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.REVENUE,
            pjp1.INITIAL_FUNDING_AMOUNT,
            pjp1.INITIAL_FUNDING_COUNT,
            pjp1.ADDITIONAL_FUNDING_AMOUNT,
            pjp1.ADDITIONAL_FUNDING_COUNT,
            pjp1.CANCELLED_FUNDING_AMOUNT,
            pjp1.CANCELLED_FUNDING_COUNT,
            pjp1.FUNDING_ADJUSTMENT_AMOUNT,
            pjp1.FUNDING_ADJUSTMENT_COUNT,
            pjp1.REVENUE_WRITEOFF,
            pjp1.AR_INVOICE_AMOUNT,
            pjp1.AR_INVOICE_COUNT,
            pjp1.AR_CASH_APPLIED_AMOUNT,
            pjp1.AR_INVOICE_WRITE_OFF_AMOUNT,
            pjp1.AR_INVOICE_WRITEOFF_COUNT,
            pjp1.AR_CREDIT_MEMO_AMOUNT,
            pjp1.AR_CREDIT_MEMO_COUNT,
            pjp1.UNBILLED_RECEIVABLES,
            pjp1.UNEARNED_REVENUE,
            pjp1.AR_UNAPPR_INVOICE_AMOUNT,
            pjp1.AR_UNAPPR_INVOICE_COUNT,
            pjp1.AR_APPR_INVOICE_AMOUNT,
            pjp1.AR_APPR_INVOICE_COUNT,
            pjp1.AR_AMOUNT_DUE,
            pjp1.AR_COUNT_DUE,
            pjp1.AR_AMOUNT_OVERDUE,
            pjp1.AR_COUNT_OVERDUE,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_AC_AGGR_PJP1   pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PJI_XBS_DENORM     prg
          where
            prg.STRUCT_TYPE         = 'PRG'                              and
            prg.SUP_LEVEL           = l_level                            and
            prg.SUB_LEVEL           = l_level                            and
            pjp1.WORKER_ID          = p_worker_id                        and
            pjp1.PROJECT_ID         = prg.SUP_PROJECT_ID                 and
            pjp1.PROJECT_ELEMENT_ID = prg.SUP_EMT_ID                     and
            pjp1.PRG_LEVEL          = 0                                  and
            pjp1.WBS_ROLLUP_FLAG    = 'N'                                and
            pjp1.PRG_ROLLUP_FLAG    = 'N'                                and
            wbs_hdr.PROJECT_ID      = pjp1.PROJECT_ID                    and
            wbs_hdr.PLAN_VERSION_ID = -1                                 and
            wbs_hdr.WBS_VERSION_ID  = prg.SUP_ID
          union all
          select /*+ ordered
                     index(fpr PJI_AC_XBR_ACCUM_F_N1) */
                 -- get delta task level amounts from Reporting Lines
            /*wbs_hdr.WBS_VERSION_ID,
            'LF'                                   RELATIONSHIP_TYPE,
            decode(log.EVENT_TYPE,
                   'WBS_CHANGE', 'Y',
                   'WBS_PUBLISH', 'N')             PUSHUP_FLAG,
            'Y'                                    INSERT_FLAG,
            acr.PROJECT_ID,
            acr.PROJECT_ORG_ID,
            acr.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))
                                                   PROJECT_ELEMENT_ID,
            acr.TIME_ID,
            acr.PERIOD_TYPE_ID,
            acr.CALENDAR_TYPE,
            'Y'                                    WBS_ROLLUP_FLAG,
            acr.PRG_ROLLUP_FLAG,
            acr.CURR_RECORD_TYPE_ID,
            acr.CURRENCY_CODE,
            wbs.SIGN * acr.REVENUE                 REVENUE,
            wbs.SIGN * acr.INITIAL_FUNDING_AMOUNT  INITIAL_FUNDING_AMOUNT,
            wbs.SIGN * acr.INITIAL_FUNDING_COUNT   INITIAL_FUNDING_COUNT,
            wbs.SIGN * acr.ADDITIONAL_FUNDING_AMOUNT
                                                   ADDITIONAL_FUNDING_AMOUNT,
            wbs.SIGN * acr.ADDITIONAL_FUNDING_COUNT
                                                   ADDITIONAL_FUNDING_COUNT,
            wbs.SIGN * acr.CANCELLED_FUNDING_AMOUNT
                                                   CANCELLED_FUNDING_AMOUNT,
            wbs.SIGN * acr.CANCELLED_FUNDING_COUNT CANCELLED_FUNDING_COUNT,
            wbs.SIGN * acr.FUNDING_ADJUSTMENT_AMOUNT
                                                   FUNDING_ADJUSTMENT_AMOUNT,
            wbs.SIGN * acr.FUNDING_ADJUSTMENT_COUNT
                                                   FUNDING_ADJUSTMENT_COUNT,
            wbs.SIGN * acr.REVENUE_WRITEOFF        REVENUE_WRITEOFF,
            wbs.SIGN * acr.AR_INVOICE_AMOUNT       AR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_COUNT        AR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_CASH_APPLIED_AMOUNT  AR_CASH_APPLIED_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_WRITE_OFF_AMOUNT
                                                   AR_INVOICE_WRITE_OFF_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_WRITEOFF_COUNT
                                                   AR_INVOICE_WRITEOFF_COUNT,
            wbs.SIGN * acr.AR_CREDIT_MEMO_AMOUNT   AR_CREDIT_MEMO_AMOUNT,
            wbs.SIGN * acr.AR_CREDIT_MEMO_COUNT    AR_CREDIT_MEMO_COUNT,
            wbs.SIGN * acr.UNBILLED_RECEIVABLES    UNBILLED_RECEIVABLES,
            wbs.SIGN * acr.UNEARNED_REVENUE        UNEARNED_REVENUE,
            wbs.SIGN * acr.AR_UNAPPR_INVOICE_AMOUNT
                                                   AR_UNAPPR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_UNAPPR_INVOICE_COUNT AR_UNAPPR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_APPR_INVOICE_AMOUNT  AR_APPR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_APPR_INVOICE_COUNT   AR_APPR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_AMOUNT_DUE           AR_AMOUNT_DUE,
            wbs.SIGN * acr.AR_COUNT_DUE            AR_COUNT_DUE,
            wbs.SIGN * acr.AR_AMOUNT_OVERDUE       AR_AMOUNT_OVERDUE,
            wbs.SIGN * acr.AR_COUNT_OVERDUE        AR_COUNT_OVERDUE,
            wbs.SIGN * acr.CUSTOM1                 CUSTOM1,
            wbs.SIGN * acr.CUSTOM2                 CUSTOM2,
            wbs.SIGN * acr.CUSTOM3                 CUSTOM3,
            wbs.SIGN * acr.CUSTOM4                 CUSTOM4,
            wbs.SIGN * acr.CUSTOM5                 CUSTOM5,
            wbs.SIGN * acr.CUSTOM6                 CUSTOM6,
            wbs.SIGN * acr.CUSTOM7                 CUSTOM7,
            wbs.SIGN * acr.CUSTOM8                 CUSTOM8,
            wbs.SIGN * acr.CUSTOM9                 CUSTOM9,
            wbs.SIGN * acr.CUSTOM10                CUSTOM10,
            wbs.SIGN * acr.CUSTOM11                CUSTOM11,
            wbs.SIGN * acr.CUSTOM12                CUSTOM12,
            wbs.SIGN * acr.CUSTOM13                CUSTOM13,
            wbs.SIGN * acr.CUSTOM14                CUSTOM14,
            wbs.SIGN * acr.CUSTOM15                CUSTOM15
          from
            PJI_PA_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            PJI_XBS_DENORM_DELTA   wbs,
            PJI_XBS_DENORM         prg,
            PJI_AC_XBS_ACCUM_F     acr,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.WORKER_ID           =  p_worker_id                 and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            log.WORKER_ID           =  p_worker_id                 and
            log.EVENT_ID            =  wbs.EVENT_ID                and
            log.EVENT_TYPE          in ('WBS_CHANGE',
                                        'WBS_PUBLISH')             and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1              and
            wbs_hdr.PLAN_VERSION_ID =  log.ATTRIBUTE3              and
            wbs_hdr.PLAN_VERSION_ID =  -1                          and
            wbs_hdr.WBS_VERSION_ID  =  wbs.STRUCT_VERSION_ID       and
            wbs_hdr.PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                  and
            acr.WBS_ROLLUP_FLAG     =  'N'                         and
            acr.PRG_ROLLUP_FLAG     =  'N'                         and
            acr.PROJECT_ID          =  wbs.SUP_PROJECT_ID          and
            acr.PROJECT_ELEMENT_ID  =  wbs.SUB_EMT_ID              and
            acr.PROJECT_ID          =  wbs_hdr.PROJECT_ID          and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+) and
            (wbs.SUP_LEVEL <> wbs.SUB_LEVEL or
             (wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1))
          ) pjp,
          (
          select /*+ ordered */
            /*prg.SUP_PROJECT_ID,
            map.PROJECT_ORG_ID               SUP_PROJECT_ORG_ID,
            map.PROJECT_ORGANIZATION_ID      SUP_PROJECT_ORGANIZATION_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            prg.SUP_LEVEL,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUB_ROLLUP_ID,
            prg.RELATIONSHIP_TYPE            RELATIONSHIP_TYPE,
            'Y'                              PUSHUP_FLAG
          from
            PJI_PJP_PROJ_BATCH_MAP map,
            PJI_XBS_DENORM         prg,
            PJI_XBS_DENORM_DELTA   prg_delta
          where
            prg.STRUCT_TYPE          = 'PRG'                           and
            prg.RELATIONSHIP_TYPE    = 'LF'                            and
            prg.SUB_ROLLUP_ID        is not null                       and
            prg.SUB_LEVEL            = l_level                         and
            map.WORKER_ID            = p_worker_id                     and
            map.PROJECT_ID           = prg.SUP_PROJECT_ID              and
            p_worker_id              = prg_delta.WORKER_ID         (+) and
            prg.STRUCT_TYPE          = prg_delta.STRUCT_TYPE       (+) and
            prg.SUP_PROJECT_ID       = prg_delta.SUP_PROJECT_ID    (+) and
            prg.SUP_LEVEL            = prg_delta.SUP_LEVEL         (+) and
            prg.SUP_ID               = prg_delta.SUP_ID            (+) and
            prg.SUB_LEVEL            = prg_delta.SUB_LEVEL         (+) and
            prg.SUB_ID               = prg_delta.SUB_ID            (+) and
            prg.RELATIONSHIP_TYPE    = prg_delta.RELATIONSHIP_TYPE (+) and
            -1                       = prg_delta.SIGN              (+) and
            prg_delta.SUP_PROJECT_ID is null
          ) prg
        where
          pjp.WBS_VERSION_ID    = prg.SUB_ID            (+) and
          pjp.RELATIONSHIP_TYPE = prg.RELATIONSHIP_TYPE (+) and
          pjp.PUSHUP_FLAG       = prg.PUSHUP_FLAG       (+)
        group by
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_EMT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID,
                 prg.SUP_PROJECT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID),
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y'),
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE
          )                          pjp1_i,
          PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp1_i.INSERT_FLAG  = 'Y'                                and
          pjp1_i.PROJECT_ID   = sup_fin_ver.PROJECT_ID         (+) and
          pjp1_i.SUP_ID       = sup_fin_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_WORKING' = sup_fin_ver.STATUS_CODE        (+) and
          pjp1_i.SUP_EMT_ID   = sup_wpa.PROJ_ELEMENT_ID        (+) and
          'N'                 = sup_wpa.WP_ENABLE_VERSION_FLAG (+) and
          (pjp1_i.SUP_ID is null or
           (pjp1_i.SUP_ID is not null and
            (sup_fin_ver.PROJECT_ID is not null or
             sup_wpa.PROJ_ELEMENT_ID is not null)));*/

        update PJI_SYSTEM_PRC_STATUS
        set    STEP_STATUS = 'C',
               END_DATE = sysdate
        where  PROCESS_NAME = l_process and
               STEP_SEQ = l_level_seq;

        commit;

        select
          nvl(to_number(min(STEP_SEQ)), 0)
        into
          l_level_seq
        from
          PJI_SYSTEM_PRC_STATUS
        where
          PROCESS_NAME = l_process and
          STEP_NAME like 'ROLLUP_ACR_WBS%' and
          STEP_STATUS is null;

        if (l_level_seq = 0) then
          l_level := 0;
        else
          l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
        end if;

      end loop;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_WBS(p_worker_id);');

      commit;

    else -- online mode

      -- rollup just WBS for online processing

      select /*+ ordered use_nl(den) */ -- bug 7607077 asahoo - removed index hint
        nvl(max(den.SUP_LEVEL), 0)
      into
        l_level
      from
        PJI_FM_EXTR_PLNVER3_T ver3,
        PJI_XBS_DENORM den
      where
        den.STRUCT_TYPE    = 'PRG'          and
        den.SUB_LEVEL      = den.SUP_LEVEL  and
        den.SUP_PROJECT_ID = ver3.PROJECT_ID;

      while (l_level > 0) loop

        -- rollup project hiearchy

        insert into PJI_AC_AGGR_PJP1_T
        (
          WORKER_ID,
          RECORD_TYPE,
          PRG_LEVEL,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          PROJECT_ELEMENT_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          WBS_ROLLUP_FLAG,
          PRG_ROLLUP_FLAG,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          REVENUE,
          INITIAL_FUNDING_AMOUNT,
          INITIAL_FUNDING_COUNT,
          ADDITIONAL_FUNDING_AMOUNT,
          ADDITIONAL_FUNDING_COUNT,
          CANCELLED_FUNDING_AMOUNT,
          CANCELLED_FUNDING_COUNT,
          FUNDING_ADJUSTMENT_AMOUNT,
          FUNDING_ADJUSTMENT_COUNT,
          REVENUE_WRITEOFF,
          AR_INVOICE_AMOUNT,
          AR_INVOICE_COUNT,
          AR_CASH_APPLIED_AMOUNT,
          AR_INVOICE_WRITE_OFF_AMOUNT,
          AR_INVOICE_WRITEOFF_COUNT,
          AR_CREDIT_MEMO_AMOUNT,
          AR_CREDIT_MEMO_COUNT,
          UNBILLED_RECEIVABLES,
          UNEARNED_REVENUE,
          AR_UNAPPR_INVOICE_AMOUNT,
          AR_UNAPPR_INVOICE_COUNT,
          AR_APPR_INVOICE_AMOUNT,
          AR_APPR_INVOICE_COUNT,
          AR_AMOUNT_DUE,
          AR_COUNT_DUE,
          AR_AMOUNT_OVERDUE,
          AR_COUNT_OVERDUE,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15
        )
        select
          pjp1_i.WORKER_ID,
          pjp1_i.RECORD_TYPE,
          pjp1_i.PRG_LEVEL,
          pjp1_i.PROJECT_ID,
          pjp1_i.PROJECT_ORG_ID,
          pjp1_i.PROJECT_ORGANIZATION_ID,
          pjp1_i.PROJECT_ELEMENT_ID,
          pjp1_i.TIME_ID,
          pjp1_i.PERIOD_TYPE_ID,
          pjp1_i.CALENDAR_TYPE,
          pjp1_i.WBS_ROLLUP_FLAG,
          pjp1_i.PRG_ROLLUP_FLAG,
          pjp1_i.CURR_RECORD_TYPE_ID,
          pjp1_i.CURRENCY_CODE,
          pjp1_i.REVENUE,
          pjp1_i.INITIAL_FUNDING_AMOUNT,
          pjp1_i.INITIAL_FUNDING_COUNT,
          pjp1_i.ADDITIONAL_FUNDING_AMOUNT,
          pjp1_i.ADDITIONAL_FUNDING_COUNT,
          pjp1_i.CANCELLED_FUNDING_AMOUNT,
          pjp1_i.CANCELLED_FUNDING_COUNT,
          pjp1_i.FUNDING_ADJUSTMENT_AMOUNT,
          pjp1_i.FUNDING_ADJUSTMENT_COUNT,
          pjp1_i.REVENUE_WRITEOFF,
          pjp1_i.AR_INVOICE_AMOUNT,
          pjp1_i.AR_INVOICE_COUNT,
          pjp1_i.AR_CASH_APPLIED_AMOUNT,
          pjp1_i.AR_INVOICE_WRITE_OFF_AMOUNT,
          pjp1_i.AR_INVOICE_WRITEOFF_COUNT,
          pjp1_i.AR_CREDIT_MEMO_AMOUNT,
          pjp1_i.AR_CREDIT_MEMO_COUNT,
          pjp1_i.UNBILLED_RECEIVABLES,
          pjp1_i.UNEARNED_REVENUE,
          pjp1_i.AR_UNAPPR_INVOICE_AMOUNT,
          pjp1_i.AR_UNAPPR_INVOICE_COUNT,
          pjp1_i.AR_APPR_INVOICE_AMOUNT,
          pjp1_i.AR_APPR_INVOICE_COUNT,
          pjp1_i.AR_AMOUNT_DUE,
          pjp1_i.AR_COUNT_DUE,
          pjp1_i.AR_AMOUNT_OVERDUE,
          pjp1_i.AR_COUNT_OVERDUE,
          pjp1_i.CUSTOM1,
          pjp1_i.CUSTOM2,
          pjp1_i.CUSTOM3,
          pjp1_i.CUSTOM4,
          pjp1_i.CUSTOM5,
          pjp1_i.CUSTOM6,
          pjp1_i.CUSTOM7,
          pjp1_i.CUSTOM8,
          pjp1_i.CUSTOM9,
          pjp1_i.CUSTOM10,
          pjp1_i.CUSTOM11,
          pjp1_i.CUSTOM12,
          pjp1_i.CUSTOM13,
          pjp1_i.CUSTOM14,
          pjp1_i.CUSTOM15
        from
          (
        select
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y')             INSERT_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_ID)                 SUP_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_EMT_ID)             SUP_EMT_ID,
          1                                        WORKER_ID,
          -- p_worker_id                           WORKER_ID,
          'W'                                      RECORD_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL)           PRG_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID,
                 prg.SUP_PROJECT_ID)               PROJECT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID)           PROJECT_ORG_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID)  PROJECT_ORGANIZATION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID)                PROJECT_ELEMENT_ID,
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N')         WBS_ROLLUP_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y')         PRG_ROLLUP_FLAG,
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          sum(pjp.REVENUE)                         REVENUE,
          sum(pjp.INITIAL_FUNDING_AMOUNT)          INITIAL_FUNDING_AMOUNT,
          sum(pjp.INITIAL_FUNDING_COUNT)           INITIAL_FUNDING_COUNT,
          sum(pjp.ADDITIONAL_FUNDING_AMOUNT)       ADDITIONAL_FUNDING_AMOUNT,
          sum(pjp.ADDITIONAL_FUNDING_COUNT)        ADDITIONAL_FUNDING_COUNT,
          sum(pjp.CANCELLED_FUNDING_AMOUNT)        CANCELLED_FUNDING_AMOUNT,
          sum(pjp.CANCELLED_FUNDING_COUNT)         CANCELLED_FUNDING_COUNT,
          sum(pjp.FUNDING_ADJUSTMENT_AMOUNT)       FUNDING_ADJUSTMENT_AMOUNT,
          sum(pjp.FUNDING_ADJUSTMENT_COUNT)        FUNDING_ADJUSTMENT_COUNT,
          sum(pjp.REVENUE_WRITEOFF)                REVENUE_WRITEOFF,
          sum(pjp.AR_INVOICE_AMOUNT)               AR_INVOICE_AMOUNT,
          sum(pjp.AR_INVOICE_COUNT)                AR_INVOICE_COUNT,
          sum(pjp.AR_CASH_APPLIED_AMOUNT)          AR_CASH_APPLIED_AMOUNT,
          sum(pjp.AR_INVOICE_WRITE_OFF_AMOUNT)     AR_INVOICE_WRITE_OFF_AMOUNT,
          sum(pjp.AR_INVOICE_WRITEOFF_COUNT)       AR_INVOICE_WRITEOFF_COUNT,
          sum(pjp.AR_CREDIT_MEMO_AMOUNT)           AR_CREDIT_MEMO_AMOUNT,
          sum(pjp.AR_CREDIT_MEMO_COUNT)            AR_CREDIT_MEMO_COUNT,
          sum(pjp.UNBILLED_RECEIVABLES)            UNBILLED_RECEIVABLES,
          sum(pjp.UNEARNED_REVENUE)                UNEARNED_REVENUE,
          sum(pjp.AR_UNAPPR_INVOICE_AMOUNT)        AR_UNAPPR_INVOICE_AMOUNT,
          sum(pjp.AR_UNAPPR_INVOICE_COUNT)         AR_UNAPPR_INVOICE_COUNT,
          sum(pjp.AR_APPR_INVOICE_AMOUNT)          AR_APPR_INVOICE_AMOUNT,
          sum(pjp.AR_APPR_INVOICE_COUNT)           AR_APPR_INVOICE_COUNT,
          sum(pjp.AR_AMOUNT_DUE)                   AR_AMOUNT_DUE,
          sum(pjp.AR_COUNT_DUE)                    AR_COUNT_DUE,
          sum(pjp.AR_AMOUNT_OVERDUE)               AR_AMOUNT_OVERDUE,
          sum(pjp.AR_COUNT_OVERDUE)                AR_COUNT_OVERDUE,
          sum(pjp.CUSTOM1)                         CUSTOM1,
          sum(pjp.CUSTOM2)                         CUSTOM2,
          sum(pjp.CUSTOM3)                         CUSTOM3,
          sum(pjp.CUSTOM4)                         CUSTOM4,
          sum(pjp.CUSTOM5)                         CUSTOM5,
          sum(pjp.CUSTOM6)                         CUSTOM6,
          sum(pjp.CUSTOM7)                         CUSTOM7,
          sum(pjp.CUSTOM8)                         CUSTOM8,
          sum(pjp.CUSTOM9)                         CUSTOM9,
          sum(pjp.CUSTOM10)                        CUSTOM10,
          sum(pjp.CUSTOM11)                        CUSTOM11,
          sum(pjp.CUSTOM12)                        CUSTOM12,
          sum(pjp.CUSTOM13)                        CUSTOM13,
          sum(pjp.CUSTOM14)                        CUSTOM14,
          sum(pjp.CUSTOM15)                        CUSTOM15
        from
          (
          select /*+ ordered index(wbs PA_XBS_DENORM_N2) */
                 -- get incremental task level amounts from source and
                 -- program rollup amounts from interim
            wbs_hdr.WBS_VERSION_ID,
            'LF'                                      RELATIONSHIP_TYPE,
            decode(top_slice.INVERT_ID,
                   'PRJ', 'Y',
                          decode(wbs.SUB_LEVEL,
                                 1, 'Y', 'N'))        PUSHUP_FLAG,
            'Y'                                       INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.REVENUE,
            pjp1.INITIAL_FUNDING_AMOUNT,
            pjp1.INITIAL_FUNDING_COUNT,
            pjp1.ADDITIONAL_FUNDING_AMOUNT,
            pjp1.ADDITIONAL_FUNDING_COUNT,
            pjp1.CANCELLED_FUNDING_AMOUNT,
            pjp1.CANCELLED_FUNDING_COUNT,
            pjp1.FUNDING_ADJUSTMENT_AMOUNT,
            pjp1.FUNDING_ADJUSTMENT_COUNT,
            pjp1.REVENUE_WRITEOFF,
            pjp1.AR_INVOICE_AMOUNT,
            pjp1.AR_INVOICE_COUNT,
            pjp1.AR_CASH_APPLIED_AMOUNT,
            pjp1.AR_INVOICE_WRITE_OFF_AMOUNT,
            pjp1.AR_INVOICE_WRITEOFF_COUNT,
            pjp1.AR_CREDIT_MEMO_AMOUNT,
            pjp1.AR_CREDIT_MEMO_COUNT,
            pjp1.UNBILLED_RECEIVABLES,
            pjp1.UNEARNED_REVENUE,
            pjp1.AR_UNAPPR_INVOICE_AMOUNT,
            pjp1.AR_UNAPPR_INVOICE_COUNT,
            pjp1.AR_APPR_INVOICE_AMOUNT,
            pjp1.AR_APPR_INVOICE_COUNT,
            pjp1.AR_AMOUNT_DUE,
            pjp1.AR_COUNT_DUE,
            pjp1.AR_AMOUNT_OVERDUE,
            pjp1.AR_COUNT_OVERDUE,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_AC_AGGR_PJP1_T pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PA_XBS_DENORM      wbs,
            PJI_XBS_DENORM     prg,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            ((wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1) or
             (wbs.SUP_LEVEL <> wbs.SUB_LEVEL))                     and
            wbs.STRUCT_VERSION_ID   =  prg.SUP_ID                  and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            -- pjp1.WORKER_ID       =  p_worker_id                 and
            pjp1.PRG_LEVEL          in (0, l_level)                and
            pjp1.WBS_ROLLUP_FLAG    =  'N'                         and
            pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                  and
            wbs_hdr.PLAN_VERSION_ID =  -1                          and
            pjp1.PROJECT_ID         =  wbs_hdr.PROJECT_ID          and
            wbs.STRUCT_VERSION_ID   =  wbs_hdr.WBS_VERSION_ID      and
            pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID              and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+)
          union all
          select /*+ ordered */
                 -- get incremental project level amounts from source
            wbs_hdr.WBS_VERSION_ID,
            'LF'                                   RELATIONSHIP_TYPE,
            'Y'                                    PUSHUP_FLAG,
            'N'                                    INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            pjp1.PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            'Y'                                    WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.REVENUE,
            pjp1.INITIAL_FUNDING_AMOUNT,
            pjp1.INITIAL_FUNDING_COUNT,
            pjp1.ADDITIONAL_FUNDING_AMOUNT,
            pjp1.ADDITIONAL_FUNDING_COUNT,
            pjp1.CANCELLED_FUNDING_AMOUNT,
            pjp1.CANCELLED_FUNDING_COUNT,
            pjp1.FUNDING_ADJUSTMENT_AMOUNT,
            pjp1.FUNDING_ADJUSTMENT_COUNT,
            pjp1.REVENUE_WRITEOFF,
            pjp1.AR_INVOICE_AMOUNT,
            pjp1.AR_INVOICE_COUNT,
            pjp1.AR_CASH_APPLIED_AMOUNT,
            pjp1.AR_INVOICE_WRITE_OFF_AMOUNT,
            pjp1.AR_INVOICE_WRITEOFF_COUNT,
            pjp1.AR_CREDIT_MEMO_AMOUNT,
            pjp1.AR_CREDIT_MEMO_COUNT,
            pjp1.UNBILLED_RECEIVABLES,
            pjp1.UNEARNED_REVENUE,
            pjp1.AR_UNAPPR_INVOICE_AMOUNT,
            pjp1.AR_UNAPPR_INVOICE_COUNT,
            pjp1.AR_APPR_INVOICE_AMOUNT,
            pjp1.AR_APPR_INVOICE_COUNT,
            pjp1.AR_AMOUNT_DUE,
            pjp1.AR_COUNT_DUE,
            pjp1.AR_AMOUNT_OVERDUE,
            pjp1.AR_COUNT_OVERDUE,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_AC_AGGR_PJP1_T pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PJI_XBS_DENORM     prg
          where
            prg.STRUCT_TYPE         = 'PRG'                              and
            prg.SUP_LEVEL           = l_level                            and
            prg.SUB_LEVEL           = l_level                            and
            -- pjp1.WORKER_ID       = p_worker_id                        and
            pjp1.PROJECT_ID         = prg.SUP_PROJECT_ID                 and
            pjp1.PROJECT_ELEMENT_ID = prg.SUP_EMT_ID                     and
            pjp1.PRG_LEVEL          = 0                                  and
            pjp1.WBS_ROLLUP_FLAG    = 'N'                                and
            pjp1.PRG_ROLLUP_FLAG    = 'N'                                and
            wbs_hdr.PROJECT_ID      = pjp1.PROJECT_ID                    and
            wbs_hdr.PLAN_VERSION_ID = -1                                 and
            wbs_hdr.WBS_VERSION_ID  = prg.SUP_ID
          union all
          select /*+ ordered
                     index(log PA_PJI_PROJ_EVENTS_LOG_N2)
                     index(fpr PJI_AC_XBR_ACCUM_F_N1) */
                 -- get delta task level amounts from Reporting Lines
            wbs_hdr.WBS_VERSION_ID,
            'LF'                                   RELATIONSHIP_TYPE,
            decode(log.EVENT_TYPE,
                   'WBS_CHANGE', 'Y',
                   'WBS_PUBLISH', 'N')             PUSHUP_FLAG,
            'Y'                                    INSERT_FLAG,
            acr.PROJECT_ID,
            acr.PROJECT_ORG_ID,
            acr.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))
                                                   PROJECT_ELEMENT_ID,
            acr.TIME_ID,
            acr.PERIOD_TYPE_ID,
            acr.CALENDAR_TYPE,
            'Y'                                    WBS_ROLLUP_FLAG,
            acr.PRG_ROLLUP_FLAG,
            acr.CURR_RECORD_TYPE_ID,
            acr.CURRENCY_CODE,
            wbs.SIGN * acr.REVENUE                 REVENUE,
            wbs.SIGN * acr.INITIAL_FUNDING_AMOUNT  INITIAL_FUNDING_AMOUNT,
            wbs.SIGN * acr.INITIAL_FUNDING_COUNT   INITIAL_FUNDING_COUNT,
            wbs.SIGN * acr.ADDITIONAL_FUNDING_AMOUNT
                                                   ADDITIONAL_FUNDING_AMOUNT,
            wbs.SIGN * acr.ADDITIONAL_FUNDING_COUNT
                                                   ADDITIONAL_FUNDING_COUNT,
            wbs.SIGN * acr.CANCELLED_FUNDING_AMOUNT
                                                   CANCELLED_FUNDING_AMOUNT,
            wbs.SIGN * acr.CANCELLED_FUNDING_COUNT CANCELLED_FUNDING_COUNT,
            wbs.SIGN * acr.FUNDING_ADJUSTMENT_AMOUNT
                                                   FUNDING_ADJUSTMENT_AMOUNT,
            wbs.SIGN * acr.FUNDING_ADJUSTMENT_COUNT
                                                   FUNDING_ADJUSTMENT_COUNT,
            wbs.SIGN * acr.REVENUE_WRITEOFF        REVENUE_WRITEOFF,
            wbs.SIGN * acr.AR_INVOICE_AMOUNT       AR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_COUNT        AR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_CASH_APPLIED_AMOUNT  AR_CASH_APPLIED_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_WRITE_OFF_AMOUNT
                                                   AR_INVOICE_WRITE_OFF_AMOUNT,
            wbs.SIGN * acr.AR_INVOICE_WRITEOFF_COUNT
                                                   AR_INVOICE_WRITEOFF_COUNT,
            wbs.SIGN * acr.AR_CREDIT_MEMO_AMOUNT   AR_CREDIT_MEMO_AMOUNT,
            wbs.SIGN * acr.AR_CREDIT_MEMO_COUNT    AR_CREDIT_MEMO_COUNT,
            wbs.SIGN * acr.UNBILLED_RECEIVABLES    UNBILLED_RECEIVABLES,
            wbs.SIGN * acr.UNEARNED_REVENUE        UNEARNED_REVENUE,
            wbs.SIGN * acr.AR_UNAPPR_INVOICE_AMOUNT
                                                   AR_UNAPPR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_UNAPPR_INVOICE_COUNT AR_UNAPPR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_APPR_INVOICE_AMOUNT  AR_APPR_INVOICE_AMOUNT,
            wbs.SIGN * acr.AR_APPR_INVOICE_COUNT   AR_APPR_INVOICE_COUNT,
            wbs.SIGN * acr.AR_AMOUNT_DUE           AR_AMOUNT_DUE,
            wbs.SIGN * acr.AR_COUNT_DUE            AR_COUNT_DUE,
            wbs.SIGN * acr.AR_AMOUNT_OVERDUE       AR_AMOUNT_OVERDUE,
            wbs.SIGN * acr.AR_COUNT_OVERDUE        AR_COUNT_OVERDUE,
            wbs.SIGN * acr.CUSTOM1                 CUSTOM1,
            wbs.SIGN * acr.CUSTOM2                 CUSTOM2,
            wbs.SIGN * acr.CUSTOM3                 CUSTOM3,
            wbs.SIGN * acr.CUSTOM4                 CUSTOM4,
            wbs.SIGN * acr.CUSTOM5                 CUSTOM5,
            wbs.SIGN * acr.CUSTOM6                 CUSTOM6,
            wbs.SIGN * acr.CUSTOM7                 CUSTOM7,
            wbs.SIGN * acr.CUSTOM8                 CUSTOM8,
            wbs.SIGN * acr.CUSTOM9                 CUSTOM9,
            wbs.SIGN * acr.CUSTOM10                CUSTOM10,
            wbs.SIGN * acr.CUSTOM11                CUSTOM11,
            wbs.SIGN * acr.CUSTOM12                CUSTOM12,
            wbs.SIGN * acr.CUSTOM13                CUSTOM13,
            wbs.SIGN * acr.CUSTOM14                CUSTOM14,
            wbs.SIGN * acr.CUSTOM15                CUSTOM15
          from
            PA_PJI_PROJ_EVENTS_LOG log,
            PJI_PJP_WBS_HEADER     wbs_hdr,
            PJI_XBS_DENORM_DELTA_T wbs,
            PJI_XBS_DENORM         prg,
            PJI_AC_XBS_ACCUM_F     acr,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.WORKER_ID           =  p_worker_id                 and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            -- log.WORKER_ID        =  p_worker_id                 and
            log.EVENT_ID            =  g_event_id                  and
            log.EVENT_TYPE          in ('WBS_CHANGE',
                                        'WBS_PUBLISH')             and
            wbs_hdr.PROJECT_ID      =  log.ATTRIBUTE1              and
            wbs_hdr.PLAN_VERSION_ID =  log.ATTRIBUTE3              and
            wbs_hdr.PLAN_VERSION_ID =  -1                          and
            wbs_hdr.WBS_VERSION_ID  =  wbs.STRUCT_VERSION_ID       and
            wbs_hdr.PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            wbs_hdr.WBS_VERSION_ID  =  prg.SUP_ID                  and
            acr.WBS_ROLLUP_FLAG     =  'N'                         and
            acr.PRG_ROLLUP_FLAG     =  'N'                         and
            acr.PROJECT_ID          =  wbs.SUP_PROJECT_ID          and
            acr.PROJECT_ELEMENT_ID  =  wbs.SUB_EMT_ID              and
            acr.PROJECT_ID          =  wbs_hdr.PROJECT_ID          and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+) and
            (wbs.SUP_LEVEL <> wbs.SUB_LEVEL or
             (wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1))
          ) pjp,
          (
          select
            prg.SUP_PROJECT_ID,
            map.ORG_ID                       SUP_PROJECT_ORG_ID,
            map.CARRYING_OUT_ORGANIZATION_ID SUP_PROJECT_ORGANIZATION_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            prg.SUP_LEVEL,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUB_ROLLUP_ID,
            prg.RELATIONSHIP_TYPE            RELATIONSHIP_TYPE,
            'Y'                              PUSHUP_FLAG
          from
            PJI_XBS_DENORM prg,
            PA_PROJECTS_ALL map
          where
            l_level               >  1                  and
            prg.STRUCT_TYPE       =  'PRG'              and
            prg.RELATIONSHIP_TYPE =  'LF'               and
            prg.SUB_ROLLUP_ID     is not null           and
            prg.SUB_LEVEL         =  l_level            and
            -- map.WORKER_ID      =  p_worker_id        and
            map.PROJECT_ID        =  prg.SUP_PROJECT_ID
          ) prg
        where
          pjp.WBS_VERSION_ID    = prg.SUB_ID            (+) and
          pjp.RELATIONSHIP_TYPE = prg.RELATIONSHIP_TYPE (+) and
          pjp.PUSHUP_FLAG       = prg.PUSHUP_FLAG       (+)
        group by
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, prg.SUP_EMT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID,
                 prg.SUP_PROJECT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID),
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y'),
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE
          )                          pjp1_i,
          PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp1_i.INSERT_FLAG  = 'Y'                                and
          pjp1_i.PROJECT_ID   = sup_fin_ver.PROJECT_ID         (+) and
          pjp1_i.SUP_ID       = sup_fin_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_WORKING' = sup_fin_ver.STATUS_CODE        (+) and
          pjp1_i.SUP_EMT_ID   = sup_wpa.PROJ_ELEMENT_ID        (+) and
          'N'                 = sup_wpa.WP_ENABLE_VERSION_FLAG (+) and
          (pjp1_i.SUP_ID is null or
           (pjp1_i.SUP_ID is not null and
            (sup_fin_ver.PROJECT_ID is not null or
             sup_wpa.PROJ_ELEMENT_ID is not null)));

        l_level := l_level - 1;

      end loop;

    end if;

  end ROLLUP_ACR_WBS;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_PRG
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_PRG (p_worker_id in number) is

    l_process         varchar2(30);
    l_prg_exists      varchar2(25);
    l_extraction_type varchar2(30);
    l_level           number;
    l_max_level       number;
    l_step_seq        number;
    l_level_seq       number;
    l_count           number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_PRG(p_worker_id);')) then
      return;
    end if;

    l_prg_exists := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                    (l_process, 'PROGRAM_EXISTS');

    if (l_prg_exists = 'N') then
      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_PRG(p_worker_id);');
      commit;
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- allow recovery after each level is processed

    select
      STEP_SEQ
    into
      l_step_seq
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME = 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_PRG(p_worker_id);';

    select
      count(*)
    into
      l_count
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME like 'ROLLUP_FPR_PRG%';

    if (l_count = 0) then

      select
        nvl(max(den.SUP_LEVEL), 0)
      into
        l_level
      from
        PJI_XBS_DENORM_DELTA den
      where
        den.WORKER_ID = p_worker_id and
        den.STRUCT_TYPE = 'PRG';

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'MAX_PROGRAM_LEVEL',
                                             l_level);

      insert into PJI_SYSTEM_PRC_STATUS
      (
        PROCESS_NAME,
        STEP_SEQ,
        STEP_STATUS,
        STEP_NAME,
        START_DATE,
        END_DATE
      )
      select
        l_process                              PROCESS_NAME,
        to_char(l_step_seq + SUP_LEVEL / 1000) STEP_SEQ,
        null                                   STEP_STATUS,
        'ROLLUP_FPR_PRG - level ' ||
          to_char(l_level - SUP_LEVEL + 1)     STEP_NAME,
        null                                   START_DATE,
        null                                   END_DATE
      from
      (
        select
          SUP_LEVEL
        from
          PJI_XBS_DENORM_DELTA
        where
          worker_id = p_worker_id and
          STRUCT_TYPE = 'PRG'
        union all
        select
          SUP_LEVEL
        from
          PA_XBS_DENORM den,
          PJI_PJP_PROJ_BATCH_MAP map
        where
          map.WORKER_ID      = p_worker_id    and
          den.STRUCT_TYPE    = 'PRG'          and
          den.SUP_PROJECT_ID = map.PROJECT_ID
      )
      where
        exists
        (
        select
          1
        from
          PJI_XBS_DENORM_DELTA
        where
          WORKER_ID = p_worker_id and
          ROWNUM = 1
        )
      group by
        SUP_LEVEL
      order by
        SUP_LEVEL desc;

    end if;

    l_max_level := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                   (l_process, 'MAX_PROGRAM_LEVEL');

    select
      nvl(to_number(min(STEP_SEQ)), 0)
    into
      l_level_seq
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME like 'ROLLUP_FPR_PRG%' and
      STEP_STATUS is null;

    if (l_level_seq = 0) then
      l_level := 0;
    else
      l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
    end if;

    while (l_level > 0) loop

      update PJI_SYSTEM_PRC_STATUS
      set    START_DATE = sysdate
      where  PROCESS_NAME = l_process and
             STEP_SEQ = l_level_seq;

      -- rollup project hiearchy
/* Call to Paritioned procedure for bug 7551819 */
        PJI_PROCESS_UTIL.EXECUTE_ROLLUP_FPR_PRG(p_worker_id,
                                                l_level);

/* Commented for bug 7551819 */
--      insert /*+ parallel(pjp1_in)
  --               noappend(pjp1_in) */ into PJI_FP_AGGR_PJP1 pjp1_in  -- changed for bug 5927368
    /*  (        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        PLAN_TYPE_CODE,
        RAW_COST,
        BRDN_COST,
        REVENUE,
        BILL_RAW_COST,
        BILL_BRDN_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BRDN_COST,
        BILL_LABOR_HRS,
        EQUIPMENT_RAW_COST,
        EQUIPMENT_BRDN_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BRDN_COST,
        LABOR_HRS,
        LABOR_REVENUE,
        EQUIPMENT_HOURS,
        BILLABLE_EQUIPMENT_HOURS,
        SUP_INV_COMMITTED_COST,
        PO_COMMITTED_COST,
        PR_COMMITTED_COST,
        OTH_COMMITTED_COST,
        ACT_LABOR_HRS,
        ACT_EQUIP_HRS,
        ACT_LABOR_BRDN_COST,
        ACT_EQUIP_BRDN_COST,
        ACT_BRDN_COST,
        ACT_RAW_COST,
        ACT_REVENUE,
        ACT_LABOR_RAW_COST,
        ACT_EQUIP_RAW_COST,
        ETC_LABOR_HRS,
        ETC_EQUIP_HRS,
        ETC_LABOR_BRDN_COST,
        ETC_EQUIP_BRDN_COST,
        ETC_BRDN_COST,
        ETC_RAW_COST,
        ETC_LABOR_RAW_COST,
        ETC_EQUIP_RAW_COST,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select /*+ no_merge(pjp) */
        /*p_worker_id                                   WORKER_ID,
        'P'                                           RECORD_TYPE,
        l_level                                       PRG_LEVEL,
        pjp.LINE_TYPE,
        pjp.SUP_PROJECT_ID                            PROJECT_ID,
        map.PROJECT_ORG_ID,
        map.PROJECT_ORGANIZATION_ID,
        decode(pjp.STRUCT_TYPE,
               'DO_NOT_ROLLUP', pjp.SUB_ROLLUP_ID,
                                decode(top_slice.INVERT_ID,
                                       'PRJ', pjp.SUP_EMT_ID, wbs.SUP_EMT_ID)
              )                                       PROJECT_ELEMENT_ID,
        pjp.TIME_ID,
        pjp.PERIOD_TYPE_ID,
        pjp.CALENDAR_TYPE,
        pjp.RBS_AGGR_LEVEL,
        decode(pjp.STRUCT_TYPE,
               'DO_NOT_ROLLUP', 'N',
                                decode(top_slice.INVERT_ID,
                                       'PRJ', 'Y', decode(pjp.SUB_ROLLUP_ID,
                                                          wbs.SUP_EMT_ID,
                                                          'N', 'Y'))
              )                                       WBS_ROLLUP_FLAG,
        'Y'                                           PRG_ROLLUP_FLAG,
        pjp.CURR_RECORD_TYPE_ID,
        pjp.CURRENCY_CODE,
        pjp.RBS_ELEMENT_ID,
        pjp.RBS_VERSION_ID,
        pjp.PLAN_VERSION_ID,
        pjp.PLAN_TYPE_ID,
        pjp.PLAN_TYPE_CODE,
        sum(pjp.RAW_COST)                             RAW_COST,
        sum(pjp.BRDN_COST)                            BRDN_COST,
        sum(pjp.REVENUE)                              REVENUE,
        sum(pjp.BILL_RAW_COST)                        BILL_RAW_COST,
        sum(pjp.BILL_BRDN_COST)                       BILL_BRDN_COST,
        sum(pjp.BILL_LABOR_RAW_COST)                  BILL_LABOR_RAW_COST,
        sum(pjp.BILL_LABOR_BRDN_COST)                 BILL_LABOR_BRDN_COST,
        sum(pjp.BILL_LABOR_HRS)                       BILL_LABOR_HRS,
        sum(pjp.EQUIPMENT_RAW_COST)                   EQUIPMENT_RAW_COST,
        sum(pjp.EQUIPMENT_BRDN_COST)                  EQUIPMENT_BRDN_COST,
        sum(pjp.CAPITALIZABLE_RAW_COST)               CAPITALIZABLE_RAW_COST,
        sum(pjp.CAPITALIZABLE_BRDN_COST)              CAPITALIZABLE_BRDN_COST,
        sum(pjp.LABOR_RAW_COST)                       LABOR_RAW_COST,
        sum(pjp.LABOR_BRDN_COST)                      LABOR_BRDN_COST,
        sum(pjp.LABOR_HRS)                            LABOR_HRS,
        sum(pjp.LABOR_REVENUE)                        LABOR_REVENUE,
        sum(pjp.EQUIPMENT_HOURS)                      EQUIPMENT_HOURS,
        sum(pjp.BILLABLE_EQUIPMENT_HOURS)             BILLABLE_EQUIPMENT_HOURS,
        sum(pjp.SUP_INV_COMMITTED_COST)               SUP_INV_COMMITTED_COST,
        sum(pjp.PO_COMMITTED_COST)                    PO_COMMITTED_COST,
        sum(pjp.PR_COMMITTED_COST)                    PR_COMMITTED_COST,
        sum(pjp.OTH_COMMITTED_COST)                   OTH_COMMITTED_COST,
        sum(pjp.ACT_LABOR_HRS)                        ACT_LABOR_HRS,
        sum(pjp.ACT_EQUIP_HRS)                        ACT_EQUIP_HRS,
        sum(pjp.ACT_LABOR_BRDN_COST)                  ACT_LABOR_BRDN_COST,
        sum(pjp.ACT_EQUIP_BRDN_COST)                  ACT_EQUIP_BRDN_COST,
        sum(pjp.ACT_BRDN_COST)                        ACT_BRDN_COST,
        sum(pjp.ACT_RAW_COST)                         ACT_RAW_COST,
        sum(pjp.ACT_REVENUE)                          ACT_REVENUE,
        sum(pjp.ACT_LABOR_RAW_COST)                   ACT_LABOR_RAW_COST,
        sum(pjp.ACT_EQUIP_RAW_COST)                   ACT_EQUIP_RAW_COST,
        sum(pjp.ETC_LABOR_HRS)                        ETC_LABOR_HRS,
        sum(pjp.ETC_EQUIP_HRS)                        ETC_EQUIP_HRS,
        sum(pjp.ETC_LABOR_BRDN_COST)                  ETC_LABOR_BRDN_COST,
        sum(pjp.ETC_EQUIP_BRDN_COST)                  ETC_EQUIP_BRDN_COST,
        sum(pjp.ETC_BRDN_COST)                        ETC_BRDN_COST,
        sum(pjp.ETC_RAW_COST)                         ETC_RAW_COST,
        sum(pjp.ETC_LABOR_RAW_COST)                   ETC_LABOR_RAW_COST,
        sum(pjp.ETC_EQUIP_RAW_COST)                   ETC_EQUIP_RAW_COST,
        sum(pjp.CUSTOM1)                              CUSTOM1,
        sum(pjp.CUSTOM2)                              CUSTOM2,
        sum(pjp.CUSTOM3)                              CUSTOM3,
        sum(pjp.CUSTOM4)                              CUSTOM4,
        sum(pjp.CUSTOM5)                              CUSTOM5,
        sum(pjp.CUSTOM6)                              CUSTOM6,
        sum(pjp.CUSTOM7)                              CUSTOM7,
        sum(pjp.CUSTOM8)                              CUSTOM8,
        sum(pjp.CUSTOM9)                              CUSTOM9,
        sum(pjp.CUSTOM10)                             CUSTOM10,
        sum(pjp.CUSTOM11)                             CUSTOM11,
        sum(pjp.CUSTOM12)                             CUSTOM12,
        sum(pjp.CUSTOM13)                             CUSTOM13,
        sum(pjp.CUSTOM14)                             CUSTOM14,
        sum(pjp.CUSTOM15)                             CUSTOM15
      from
        (
        select /*+ ordered index(fpr PJI_FP_XBS_ACCUM_F_N1) */
               -- get structure level amounts from Reporting Lines
         /* decode(fpr.RBS_AGGR_LEVEL,
                 'L', 'DO_NOT_ROLLUP',
                      'WBS')                          STRUCT_TYPE,
          to_char(null)                               LINE_TYPE,
          prg.SUP_PROJECT_ID,
          prg.SUP_ID,
          prg.SUP_EMT_ID,
          prg.SUB_EMT_ID,
          prg.SUB_ROLLUP_ID,
          'FPR'                                       LINE_SOURCE,
          decode(fpr.PLAN_VERSION_ID,
                 -1, prg.SUB_ID,
                 -3, prg.SUB_ID,
                 -4, prg.SUB_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  prg.SUB_ID))        SUB_ID,
          decode(fpr.PLAN_VERSION_ID,
                 -1, 'N',
                 -3, 'N',
                 -4, 'N',
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  'N'))               SUP_WP_FLAG,
          decode(fpr.PLAN_VERSION_ID,
                 -1, fpr.PLAN_VERSION_ID,
                 -3, fpr.PLAN_VERSION_ID,
                 -4, fpr.PLAN_VERSION_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  fin_plan.PLAN_VERSION_ID)
                )                                     SUB_PLAN_VERSION_ID,
          decode(fpr.PLAN_VERSION_ID,
                 -1, fpr.PLAN_TYPE_ID,
                 -3, fpr.PLAN_TYPE_ID,
                 -4, fpr.PLAN_TYPE_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  fpr.PLAN_TYPE_ID))  SUB_PLAN_TYPE_ID,
          fpr.TIME_ID,
          fpr.PERIOD_TYPE_ID,
          fpr.CALENDAR_TYPE,
          fpr.RBS_AGGR_LEVEL,
          fpr.CURR_RECORD_TYPE_ID,
          fpr.CURRENCY_CODE,
          fpr.RBS_ELEMENT_ID,
          fpr.RBS_VERSION_ID,
          decode(wbs_hdr.WP_FLAG,
                 'N', decode(wbs_hdr.PLAN_VERSION_ID,
                             -1, fpr.PLAN_VERSION_ID,
                                 fin_plan.PLAN_VERSION_ID),
                      sup_wbs_hdr.PLAN_VERSION_ID)    PLAN_VERSION_ID,
          decode(wbs_hdr.WP_FLAG,
                 'N', fpr.PLAN_TYPE_ID,
                      sup_wbs_hdr.PLAN_TYPE_ID)       PLAN_TYPE_ID,
          fpr.PLAN_TYPE_CODE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.RAW_COST)             RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BRDN_COST)            BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.REVENUE)              REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILL_RAW_COST)        BILL_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILL_BRDN_COST)       BILL_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILL_LABOR_RAW_COST)  BILL_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILL_LABOR_BRDN_COST) BILL_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILL_LABOR_HRS)       BILL_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.EQUIPMENT_RAW_COST)   EQUIPMENT_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.EQUIPMENT_BRDN_COST)  EQUIPMENT_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.CAPITALIZABLE_RAW_COST)
                                                      CAPITALIZABLE_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.CAPITALIZABLE_BRDN_COST)
                                                      CAPITALIZABLE_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.LABOR_RAW_COST)       LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.LABOR_BRDN_COST)      LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.LABOR_HRS)            LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.LABOR_REVENUE)        LABOR_REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.EQUIPMENT_HOURS)      EQUIPMENT_HOURS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.BILLABLE_EQUIPMENT_HOURS)
                                                      BILLABLE_EQUIPMENT_HOURS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.SUP_INV_COMMITTED_COST)
                                                      SUP_INV_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.PO_COMMITTED_COST)    PO_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.PR_COMMITTED_COST)    PR_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 prg.SIGN * fpr.OTH_COMMITTED_COST)   OTH_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_LABOR_HRS)        ACT_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_EQUIP_HRS)        ACT_EQUIP_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_LABOR_BRDN_COST)  ACT_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_EQUIP_BRDN_COST)  ACT_EQUIP_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_BRDN_COST)        ACT_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_RAW_COST)         ACT_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_REVENUE)          ACT_REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_LABOR_RAW_COST)   ACT_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ACT_EQUIP_RAW_COST)   ACT_EQUIP_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_LABOR_HRS)        ETC_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_EQUIP_HRS)        ETC_EQUIP_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_LABOR_BRDN_COST)  ETC_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_EQUIP_BRDN_COST)  ETC_EQUIP_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_BRDN_COST)        ETC_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_RAW_COST)         ETC_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_LABOR_RAW_COST)   ETC_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 prg.SIGN * fpr.ETC_EQUIP_RAW_COST)   ETC_EQUIP_RAW_COST,
          prg.SIGN * fpr.CUSTOM1                      CUSTOM1,
          prg.SIGN * fpr.CUSTOM2                      CUSTOM2,
          prg.SIGN * fpr.CUSTOM3                      CUSTOM3,
          prg.SIGN * fpr.CUSTOM4                      CUSTOM4,
          prg.SIGN * fpr.CUSTOM5                      CUSTOM5,
          prg.SIGN * fpr.CUSTOM6                      CUSTOM6,
          prg.SIGN * fpr.CUSTOM7                      CUSTOM7,
          prg.SIGN * fpr.CUSTOM8                      CUSTOM8,
          prg.SIGN * fpr.CUSTOM9                      CUSTOM9,
          prg.SIGN * fpr.CUSTOM10                     CUSTOM10,
          prg.SIGN * fpr.CUSTOM11                     CUSTOM11,
          prg.SIGN * fpr.CUSTOM12                     CUSTOM12,
          prg.SIGN * fpr.CUSTOM13                     CUSTOM13,
          prg.SIGN * fpr.CUSTOM14                     CUSTOM14,
          prg.SIGN * fpr.CUSTOM15                     CUSTOM15
        from
          PJI_XBS_DENORM_DELTA       prg,
          PA_PROJ_ELEMENTS           prj_emt,
          PJI_PJP_WBS_HEADER         wbs_hdr,
          PJI_FP_XBS_ACCUM_F         fpr,
          PJI_PJP_WBS_HEADER         sup_wbs_hdr,
          PA_PROJ_ELEM_VER_STRUCTURE sub_ver,
          PA_PROJ_ELEM_VER_STRUCTURE sup_ver,
          (
            select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID
            from DUAL union all
            select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID
            from DUAL union all
            select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID
            from DUAL union all
            select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID
            from DUAL
          ) fin_plan
        where
          prg.WORKER_ID              =  p_worker_id                    and
          prg.STRUCT_TYPE            =  'PRG'                          and
          prg.SUP_LEVEL              =  l_level                        and
          nvl(prg.SUB_ROLLUP_ID,
              prg.SUP_EMT_ID)        <> prg.SUP_EMT_ID                 and
          fpr.PROJECT_ID             =  prj_emt.PROJECT_ID             and
          (((fpr.RBS_AGGR_LEVEL,
             fpr.WBS_ROLLUP_FLAG,
             fpr.PRG_ROLLUP_FLAG) in (('T', 'Y', 'Y'),
                                      ('T', 'Y', 'N'),
                                      ('T', 'N', 'Y'),
                                      ('T', 'N', 'N'),
                                      ('L', 'N', 'N')) and
             fpr.PROJECT_ELEMENT_ID = prg.SUB_EMT_ID) or
           ((fpr.RBS_AGGR_LEVEL,
             fpr.WBS_ROLLUP_FLAG,
             fpr.PRG_ROLLUP_FLAG) in (('L', 'N', 'Y'),
                                      ('L', 'N', 'N')) and
             fpr.PROJECT_ELEMENT_ID <> prg.SUB_EMT_ID))                and
          decode(fpr.PLAN_VERSION_ID,
                 -1, 'LF',
                 -2, 'LF',
                 -3, 'LF',
                 -4, 'LF',
                     decode(wbs_hdr.WP_FLAG,
                            'N', 'LF',
                              'LW')) =  prg.RELATIONSHIP_TYPE          and
          prj_emt.PROJ_ELEMENT_ID    =  prg.SUB_EMT_ID                 and
          wbs_hdr.PROJECT_ID         =  prj_emt.PROJECT_ID             and
          decode(wbs_hdr.WP_FLAG,
                 'Y', wbs_hdr.WBS_VERSION_ID,
                      -1)            = decode(wbs_hdr.WP_FLAG,
                                              'Y', prg.SUB_ID,
                                                   -1)                 and
          wbs_hdr.PLAN_VERSION_ID    =  fpr.PLAN_VERSION_ID            and
          wbs_hdr.PLAN_TYPE_CODE     =  fpr.PLAN_TYPE_CODE             and
          decode(fpr.PLAN_VERSION_ID,
                 -3, fpr.PLAN_TYPE_ID,
                 -4, fpr.PLAN_TYPE_ID,
                     -1)             =  decode(fpr.PLAN_VERSION_ID,
                                               -3, wbs_hdr.PLAN_TYPE_ID,
                                               -4, wbs_hdr.PLAN_TYPE_ID,
                                                   -1)                 and
          decode(wbs_hdr.WP_FLAG,
                 'N', decode(fpr.PLAN_VERSION_ID,
                             -1, 'Y',
                             -2, 'Y',
                             -3, 'Y',
                             -4, 'Y',
                                 decode(fpr.RBS_AGGR_LEVEL
                                          || '_' || wbs_hdr.CB_FLAG
                                          || '_' || wbs_hdr.CO_FLAG,
                                        'L_Y_Y', 'Y',
                                        'L_N_Y', 'Y',
                                        'L_Y_N', 'Y',
                                                 'N')),
                      'Y')           =  'Y'                            and
          prg.SUP_PROJECT_ID         =  sup_wbs_hdr.PROJECT_ID     (+) and
          prg.SUP_ID                 =  sup_wbs_hdr.WBS_VERSION_ID (+) and
          'Y'                        =  sup_wbs_hdr.WP_FLAG        (+) and
          wbs_hdr.PROJECT_ID         =  sub_ver.PROJECT_ID         (+) and
          wbs_hdr.WBS_VERSION_ID     =  sub_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_PUBLISHED'      =  sub_ver.STATUS_CODE        (+) and
          sup_wbs_hdr.PROJECT_ID     =  sup_ver.PROJECT_ID         (+) and
          sup_wbs_hdr.WBS_VERSION_ID =  sup_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_PUBLISHED'      =  sup_ver.STATUS_CODE        (+) and
          wbs_hdr.CB_FLAG            =  fin_plan.CB                (+) and
          wbs_hdr.CO_FLAG            =  fin_plan.CO                (+)
        union all
        select /*+ ordered */
               -- get structure level amounts from interim
         /* decode(pjp1.RBS_AGGR_LEVEL,
                 'L', 'DO_NOT_ROLLUP',
                      'WBS')                          STRUCT_TYPE,
          to_char(null)                               LINE_TYPE,
          prg.SUP_PROJECT_ID,
          prg.SUP_ID,
          prg.SUP_EMT_ID,
          prg.SUB_EMT_ID,
          prg.SUB_ROLLUP_ID,
          'PJP1'                                      LINE_SOURCE,
          decode(pjp1.PLAN_VERSION_ID,
                 -1, prg.SUB_ID,
                 -3, prg.SUB_ID,
                 -4, prg.SUB_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  prg.SUB_ID))        SUB_ID,
          decode(pjp1.PLAN_VERSION_ID,
                 -1, 'N',
                 -3, 'N',
                 -4, 'N',
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  'N'))               SUP_WP_FLAG,
          decode(pjp1.PLAN_VERSION_ID,
                 -1, pjp1.PLAN_VERSION_ID,
                 -3, pjp1.PLAN_VERSION_ID,
                 -4, pjp1.PLAN_VERSION_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  fin_plan.PLAN_VERSION_ID)
                )                                     SUB_PLAN_VERSION_ID,
          decode(pjp1.PLAN_VERSION_ID,
                 -1, pjp1.PLAN_TYPE_ID,
                 -3, pjp1.PLAN_TYPE_ID,
                 -4, pjp1.PLAN_TYPE_ID,
                     decode(fin_plan.PLAN_VERSION_ID,
                            null, null,
                                  pjp1.PLAN_TYPE_ID)) SUB_PLAN_TYPE_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          pjp1.RBS_AGGR_LEVEL,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          pjp1.RBS_ELEMENT_ID,
          pjp1.RBS_VERSION_ID,
          decode(wbs_hdr.WP_FLAG,
                 'N', decode(wbs_hdr.PLAN_VERSION_ID,
                             -1, pjp1.PLAN_VERSION_ID,
                                 fin_plan.PLAN_VERSION_ID),
                      sup_wbs_hdr.PLAN_VERSION_ID)    PLAN_VERSION_ID,
          decode(wbs_hdr.WP_FLAG,
                 'N', pjp1.PLAN_TYPE_ID,
                      sup_wbs_hdr.PLAN_TYPE_ID)       PLAN_TYPE_ID,
          pjp1.PLAN_TYPE_CODE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.RAW_COST)                       RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BRDN_COST)                      BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.REVENUE)                        REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILL_RAW_COST)                  BILL_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILL_BRDN_COST)                 BILL_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILL_LABOR_RAW_COST)            BILL_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILL_LABOR_BRDN_COST)           BILL_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILL_LABOR_HRS)                 BILL_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.EQUIPMENT_RAW_COST)             EQUIPMENT_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.EQUIPMENT_BRDN_COST)            EQUIPMENT_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.CAPITALIZABLE_RAW_COST)         CAPITALIZABLE_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.CAPITALIZABLE_BRDN_COST)        CAPITALIZABLE_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.LABOR_RAW_COST)                 LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.LABOR_BRDN_COST)                LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.LABOR_HRS)                      LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.LABOR_REVENUE)                  LABOR_REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.EQUIPMENT_HOURS)                EQUIPMENT_HOURS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.BILLABLE_EQUIPMENT_HOURS)       BILLABLE_EQUIPMENT_HOURS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.SUP_INV_COMMITTED_COST)         SUP_INV_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.PO_COMMITTED_COST)              PO_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.PR_COMMITTED_COST)              PR_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sub_ver.STATUS_CODE
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y__', to_number(null),
                 'Y_Y__STRUCTURE_PUBLISHED', to_number(null),
                 pjp1.OTH_COMMITTED_COST)             OTH_COMMITTED_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_LABOR_HRS)                  ACT_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_EQUIP_HRS)                  ACT_EQUIP_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_LABOR_BRDN_COST)            ACT_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_EQUIP_BRDN_COST)            ACT_EQUIP_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_BRDN_COST)                  ACT_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_RAW_COST)                   ACT_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_REVENUE)                    ACT_REVENUE,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_LABOR_RAW_COST)             ACT_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ACT_EQUIP_RAW_COST)             ACT_EQUIP_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_LABOR_HRS)                  ETC_LABOR_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_EQUIP_HRS)                  ETC_EQUIP_HRS,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_LABOR_BRDN_COST)            ETC_LABOR_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_EQUIP_BRDN_COST)            ETC_EQUIP_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_BRDN_COST)                  ETC_BRDN_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_RAW_COST)                   ETC_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_LABOR_RAW_COST)             ETC_LABOR_RAW_COST,
          decode(wbs_hdr.WP_FLAG
                   || '_' || sup_wbs_hdr.WP_FLAG
                   || '_' || sup_ver.STATUS_CODE,
                 'Y_Y_', to_number(null),
                 pjp1.ETC_EQUIP_RAW_COST)             ETC_EQUIP_RAW_COST,
          pjp1.CUSTOM1,
          pjp1.CUSTOM2,
          pjp1.CUSTOM3,
          pjp1.CUSTOM4,
          pjp1.CUSTOM5,
          pjp1.CUSTOM6,
          pjp1.CUSTOM7,
          pjp1.CUSTOM8,
          pjp1.CUSTOM9,
          pjp1.CUSTOM10,
          pjp1.CUSTOM11,
          pjp1.CUSTOM12,
          pjp1.CUSTOM13,
          pjp1.CUSTOM14,
          pjp1.CUSTOM15
        from
          PJI_FP_AGGR_PJP1           pjp1,
          PJI_PJP_WBS_HEADER         wbs_hdr,
          PA_PROJ_ELEMENTS           prj_emt,
          PA_XBS_DENORM              prg,
          PJI_XBS_DENORM_DELTA       prg_delta,
          PJI_PJP_WBS_HEADER         sup_wbs_hdr,
          PA_PROJ_ELEM_VER_STRUCTURE sub_ver,
          PA_PROJ_ELEM_VER_STRUCTURE sup_ver,
          (
            select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID
            from DUAL union all
            select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID
            from DUAL union all
            select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID
            from DUAL union all
            select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID
            from DUAL
          ) fin_plan
        where
          prg.STRUCT_TYPE            =  'PRG'                           and
          prg.SUP_LEVEL              =  l_level                         and
          nvl(prg.SUB_ROLLUP_ID,
              prg.SUP_EMT_ID)        <> prg.SUP_EMT_ID                  and
          p_worker_id                =  prg_delta.WORKER_ID         (+) and
          prg.STRUCT_TYPE            =  prg_delta.STRUCT_TYPE       (+) and
          prg.SUP_PROJECT_ID         =  prg_delta.SUP_PROJECT_ID    (+) and
          prg.SUP_LEVEL              =  prg_delta.SUP_LEVEL         (+) and
          prg.SUP_ID                 =  prg_delta.SUP_ID            (+) and
          prg.SUB_LEVEL              =  prg_delta.SUB_LEVEL         (+) and
          prg.SUB_ID                 =  prg_delta.SUB_ID            (+) and
          prg.RELATIONSHIP_TYPE      =  prg_delta.RELATIONSHIP_TYPE (+) and
          1                          =  prg_delta.SIGN              (+) and
          (prg_delta.SUP_PROJECT_ID is not null or
           (prg_delta.SUP_PROJECT_ID is null and
            pjp1.RECORD_TYPE = 'P'))                                    and
          pjp1.WORKER_ID             =  p_worker_id                     and
          pjp1.PRG_LEVEL             in (0, prg.SUB_LEVEL)              and
          pjp1.PROJECT_ID            =  prj_emt.PROJECT_ID              and
          (((pjp1.RBS_AGGR_LEVEL,
             pjp1.WBS_ROLLUP_FLAG,
             pjp1.PRG_ROLLUP_FLAG) in (('T', 'Y', 'Y'),
                                       ('T', 'Y', 'N'),
                                       ('T', 'N', 'Y'),
                                       ('T', 'N', 'N'),
                                       ('L', 'N', 'N')) and
             pjp1.PROJECT_ELEMENT_ID = prg.SUB_EMT_ID) or
           ((pjp1.RBS_AGGR_LEVEL,
             pjp1.WBS_ROLLUP_FLAG,
             pjp1.PRG_ROLLUP_FLAG) in (('L', 'N', 'Y'),
                                       ('L', 'N', 'N')) and
             pjp1.PROJECT_ELEMENT_ID <> prg.SUB_EMT_ID))                and
          decode(pjp1.PLAN_VERSION_ID,
                 -1, 'LF',
                 -2, 'LF',
                 -3, 'LF',
                 -4, 'LF',
                     decode(wbs_hdr.WP_FLAG,
                            'N', 'LF',
                              'LW')) =  prg.RELATIONSHIP_TYPE           and
          prg.STRUCT_VERSION_ID      is null                            and
          prj_emt.OBJECT_TYPE        =  'PA_STRUCTURES'                 and
          prj_emt.PROJ_ELEMENT_ID    =  prg.SUB_EMT_ID                  and
          wbs_hdr.PROJECT_ID         =  prj_emt.PROJECT_ID              and
          wbs_hdr.WBS_VERSION_ID     =  prg.SUB_ID                      and
          wbs_hdr.PROJECT_ID         =  pjp1.PROJECT_ID                 and
          wbs_hdr.PLAN_VERSION_ID    =  pjp1.PLAN_VERSION_ID            and
          wbs_hdr.PLAN_TYPE_CODE     =  pjp1.PLAN_TYPE_CODE             and
          decode(pjp1.PLAN_VERSION_ID,
                 -3, pjp1.PLAN_TYPE_ID,
                 -4, pjp1.PLAN_TYPE_ID,
                     -1)             =  decode(pjp1.PLAN_VERSION_ID,
                                               -3, wbs_hdr.PLAN_TYPE_ID,
                                               -4, wbs_hdr.PLAN_TYPE_ID,
                                                   -1)                  and
          decode(wbs_hdr.WP_FLAG,
                 'N', decode(pjp1.PLAN_VERSION_ID,
                             -1, 'Y',
                             -2, 'Y',
                             -3, 'Y',
                             -4, 'Y',
                                 decode(pjp1.RBS_AGGR_LEVEL
                                          || '_' || wbs_hdr.CB_FLAG
                                          || '_' || wbs_hdr.CO_FLAG,
                                        'L_Y_Y', 'Y',
                                        'L_N_Y', 'Y',
                                        'L_Y_N', 'Y',
                                                 'N')),
                      'Y')           =  'Y'                             and
          prg.SUP_PROJECT_ID         =  sup_wbs_hdr.PROJECT_ID      (+) and
          prg.SUP_ID                 =  sup_wbs_hdr.WBS_VERSION_ID  (+) and
          'Y'                        =  sup_wbs_hdr.WP_FLAG         (+) and
          wbs_hdr.PROJECT_ID         =  sub_ver.PROJECT_ID          (+) and
          wbs_hdr.WBS_VERSION_ID     =  sub_ver.ELEMENT_VERSION_ID  (+) and
          'STRUCTURE_PUBLISHED'      =  sub_ver.STATUS_CODE         (+) and
          sup_wbs_hdr.PROJECT_ID     =  sup_ver.PROJECT_ID          (+) and
          sup_wbs_hdr.WBS_VERSION_ID =  sup_ver.ELEMENT_VERSION_ID  (+) and
          'STRUCTURE_PUBLISHED'      =  sup_ver.STATUS_CODE         (+) and
          wbs_hdr.CB_FLAG            =  fin_plan.CB                 (+) and
          wbs_hdr.CO_FLAG            =  fin_plan.CO                 (+)
        )                          pjp,
        PJI_PJP_PROJ_BATCH_MAP     map,
        PA_PROJ_WORKPLAN_ATTR      sup_wpa,
        PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
        PA_XBS_DENORM              wbs,
        (
          select 1     WBS_SUP_LEVEL,
                 'PRJ' INVERT_ID
          from   DUAL
          union all
          select 1     WBS_SUP_LEVEL,
                 'WBS' INVERT_ID
          from   DUAL
        ) top_slice
      where
        map.WORKER_ID           = p_worker_id                         and
        map.PROJECT_ID          = pjp.SUP_PROJECT_ID                  and
        pjp.SUP_EMT_ID          = sup_wpa.PROJ_ELEMENT_ID             and
        pjp.SUP_PROJECT_ID      = sup_fin_ver.PROJECT_ID          (+) and
        pjp.SUP_ID              = sup_fin_ver.ELEMENT_VERSION_ID  (+) and
        'STRUCTURE_WORKING'     = sup_fin_ver.STATUS_CODE         (+) and
        (pjp.SUP_WP_FLAG is null or
         (pjp.SUP_WP_FLAG is not null and
          (sup_fin_ver.PROJECT_ID is not null or
           sup_wpa.WP_ENABLE_VERSION_FLAG = 'N')))                    and
        'WBS'                   = wbs.STRUCT_TYPE                 (+) and
        pjp.STRUCT_TYPE         = wbs.STRUCT_TYPE                 (+) and
        pjp.SUP_PROJECT_ID      = wbs.SUP_PROJECT_ID              (+) and
        pjp.SUP_ID              = wbs.STRUCT_VERSION_ID           (+) and
        pjp.SUB_ROLLUP_ID       = wbs.SUB_EMT_ID                  (+) and
        wbs.SUP_LEVEL           = top_slice.WBS_SUP_LEVEL         (+)
      group by
        pjp.LINE_TYPE,
        pjp.SUP_PROJECT_ID,
        map.PROJECT_ORG_ID,
        map.PROJECT_ORGANIZATION_ID,
        decode(pjp.STRUCT_TYPE,
               'DO_NOT_ROLLUP', pjp.SUB_ROLLUP_ID,
                                decode(top_slice.INVERT_ID,
                                       'PRJ', pjp.SUP_EMT_ID, wbs.SUP_EMT_ID)
              ),
        pjp.TIME_ID,
        pjp.PERIOD_TYPE_ID,
        pjp.CALENDAR_TYPE,
        pjp.RBS_AGGR_LEVEL,
        decode(pjp.STRUCT_TYPE,
               'DO_NOT_ROLLUP', 'N',
                                decode(top_slice.INVERT_ID,
                                       'PRJ', 'Y', decode(pjp.SUB_ROLLUP_ID,
                                                          wbs.SUP_EMT_ID,
                                                          'N', 'Y'))
              ),
        pjp.CURR_RECORD_TYPE_ID,
        pjp.CURRENCY_CODE,
        pjp.RBS_ELEMENT_ID,
        pjp.RBS_VERSION_ID,
        pjp.PLAN_VERSION_ID,
        pjp.PLAN_TYPE_ID,
        pjp.PLAN_TYPE_CODE;*/

      update PJI_SYSTEM_PRC_STATUS
      set    STEP_STATUS = 'C',
             END_DATE = sysdate
      where  PROCESS_NAME = l_process and
             STEP_SEQ = l_level_seq;

      commit;

      select
        nvl(to_number(min(STEP_SEQ)), 0)
      into
        l_level_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_FPR_PRG%' and
        STEP_STATUS is null;

      if (l_level_seq = 0) then
        l_level := 0;
      else
        l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
      end if;

    end loop;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_PRG(p_worker_id);');

    commit;

  end ROLLUP_FPR_PRG;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_PRG
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_PRG (p_worker_id in number) is

    l_process         varchar2(30);
    l_prg_exists      varchar2(25);
    l_extraction_type varchar2(30);
    l_level           number;
    l_max_level       number;
    l_step_seq        number;
    l_level_seq       number;
    l_count           number;

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_PRG(p_worker_id);')) then
      return;
    end if;

    l_prg_exists := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                    (l_process, 'PROGRAM_EXISTS');

    if (l_prg_exists = 'N') then
      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process,
        'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_PRG(p_worker_id);');
      commit;
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- allow recovery after each level is processed

    select
      STEP_SEQ
    into
      l_step_seq
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME = 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_PRG(p_worker_id);';

    select
      count(*)
    into
      l_count
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME like 'ROLLUP_ACR_PRG%';

    if (l_count = 0) then

      select
         nvl(max(den.SUP_LEVEL), 0)
      into
        l_level
      from
        PJI_XBS_DENORM_DELTA den
      where
        den.WORKER_ID = p_worker_id and
        den.STRUCT_TYPE = 'PRG';

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'MAX_PROGRAM_LEVEL',
                                             l_level);

      insert into PJI_SYSTEM_PRC_STATUS
      (
        PROCESS_NAME,
        STEP_SEQ,
        STEP_STATUS,
        STEP_NAME,
        START_DATE,
        END_DATE
      )
      select
        l_process                              PROCESS_NAME,
        to_char(l_step_seq + SUP_LEVEL / 1000) STEP_SEQ,
        null                                   STEP_STATUS,
        'ROLLUP_ACR_PRG - level ' ||
          to_char(l_level - SUP_LEVEL + 1)     STEP_NAME,
        null                                   START_DATE,
        null                                   END_DATE
      from
      (
        select
          SUP_LEVEL
        from
          PJI_XBS_DENORM_DELTA
        where
          worker_id = p_worker_id and
          STRUCT_TYPE = 'PRG'
        union all
        select
          SUP_LEVEL
        from
          PA_XBS_DENORM den,
          PJI_PJP_PROJ_BATCH_MAP map
        where
          map.WORKER_ID      = p_worker_id    and
          den.STRUCT_TYPE    = 'PRG'          and
          den.SUP_PROJECT_ID = map.PROJECT_ID
      )
      where
        exists
        (
        select
          1
        from
          PJI_XBS_DENORM_DELTA
        where
          WORKER_ID = p_worker_id and
          ROWNUM = 1
        )
      group by
        SUP_LEVEL
      order by
        SUP_LEVEL desc;

    end if;

    l_max_level := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                   (l_process, 'MAX_PROGRAM_LEVEL');

    select
      nvl(to_number(min(STEP_SEQ)), 0)
    into
      l_level_seq
    from
      PJI_SYSTEM_PRC_STATUS
    where
      PROCESS_NAME = l_process and
      STEP_NAME like 'ROLLUP_ACR_PRG%' and
      STEP_STATUS is null;

    if (l_level_seq = 0) then
      l_level := 0;
    else
      l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
    end if;

    while (l_level > 0) loop

      update PJI_SYSTEM_PRC_STATUS
      set    START_DATE = sysdate
      where  PROCESS_NAME = l_process and
             STEP_SEQ = l_level_seq;

      -- rollup project hiearchy
/* Call to Paritioned procedure for bug 7551819 */
      PJI_PROCESS_UTIL.EXECUTE_ROLLUP_ACR_PRG(p_worker_id,
                                              l_level);

/* Commented for bug 7551819 */
  --    insert /*+ parallel(pjp1_in)
    --             noappend(pjp1_in) */ into PJI_AC_AGGR_PJP1 pjp1_in      -- changed for bug 5927368
     /* (
        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITE_OFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select /*+ no_merge(pjp) */
        /*p_worker_id                                WORKER_ID,
        'P'                                        RECORD_TYPE,
        l_level                                    PRG_LEVEL,
        pjp.SUP_PROJECT_ID                         PROJECT_ID,
        map.PROJECT_ORG_ID,
        map.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', pjp.SUP_EMT_ID,
               wbs.SUP_EMT_ID)                     PROJECT_ELEMENT_ID,
        pjp.TIME_ID,
        pjp.PERIOD_TYPE_ID,
        pjp.CALENDAR_TYPE,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y', decode(pjp.SUB_ROLLUP_ID,
                                  wbs.SUP_EMT_ID,
                                  'N', 'Y'))       WBS_ROLLUP_FLAG,
        'Y'                                        PRG_ROLLUP_FLAG,
        pjp.CURR_RECORD_TYPE_ID,
        pjp.CURRENCY_CODE,
        sum(pjp.REVENUE)                           REVENUE,
        sum(pjp.INITIAL_FUNDING_AMOUNT)            INITIAL_FUNDING_AMOUNT,
        sum(pjp.INITIAL_FUNDING_COUNT)             INITIAL_FUNDING_COUNT,
        sum(pjp.ADDITIONAL_FUNDING_AMOUNT)         ADDITIONAL_FUNDING_AMOUNT,
        sum(pjp.ADDITIONAL_FUNDING_COUNT)          ADDITIONAL_FUNDING_COUNT,
        sum(pjp.CANCELLED_FUNDING_AMOUNT)          CANCELLED_FUNDING_AMOUNT,
        sum(pjp.CANCELLED_FUNDING_COUNT)           CANCELLED_FUNDING_COUNT,
        sum(pjp.FUNDING_ADJUSTMENT_AMOUNT)         FUNDING_ADJUSTMENT_AMOUNT,
        sum(pjp.FUNDING_ADJUSTMENT_COUNT)          FUNDING_ADJUSTMENT_COUNT,
        sum(pjp.REVENUE_WRITEOFF)                  REVENUE_WRITEOFF,
        sum(pjp.AR_INVOICE_AMOUNT)                 AR_INVOICE_AMOUNT,
        sum(pjp.AR_INVOICE_COUNT)                  AR_INVOICE_COUNT,
        sum(pjp.AR_CASH_APPLIED_AMOUNT)            AR_CASH_APPLIED_AMOUNT,
        sum(pjp.AR_INVOICE_WRITE_OFF_AMOUNT)       AR_INVOICE_WRITE_OFF_AMOUNT,
        sum(pjp.AR_INVOICE_WRITEOFF_COUNT)         AR_INVOICE_WRITEOFF_COUNT,
        sum(pjp.AR_CREDIT_MEMO_AMOUNT)             AR_CREDIT_MEMO_AMOUNT,
        sum(pjp.AR_CREDIT_MEMO_COUNT)              AR_CREDIT_MEMO_COUNT,
        sum(pjp.UNBILLED_RECEIVABLES)              UNBILLED_RECEIVABLES,
        sum(pjp.UNEARNED_REVENUE)                  UNEARNED_REVENUE,
        sum(pjp.AR_UNAPPR_INVOICE_AMOUNT)          AR_UNAPPR_INVOICE_AMOUNT,
        sum(pjp.AR_UNAPPR_INVOICE_COUNT)           AR_UNAPPR_INVOICE_COUNT,
        sum(pjp.AR_APPR_INVOICE_AMOUNT)            AR_APPR_INVOICE_AMOUNT,
        sum(pjp.AR_APPR_INVOICE_COUNT)             AR_APPR_INVOICE_COUNT,
        sum(pjp.AR_AMOUNT_DUE)                     AR_AMOUNT_DUE,
        sum(pjp.AR_COUNT_DUE)                      AR_COUNT_DUE,
        sum(pjp.AR_AMOUNT_OVERDUE)                 AR_AMOUNT_OVERDUE,
        sum(pjp.AR_COUNT_OVERDUE)                  AR_COUNT_OVERDUE,
        sum(pjp.CUSTOM1)                           CUSTOM1,
        sum(pjp.CUSTOM2)                           CUSTOM2,
        sum(pjp.CUSTOM3)                           CUSTOM3,
        sum(pjp.CUSTOM4)                           CUSTOM4,
        sum(pjp.CUSTOM5)                           CUSTOM5,
        sum(pjp.CUSTOM6)                           CUSTOM6,
        sum(pjp.CUSTOM7)                           CUSTOM7,
        sum(pjp.CUSTOM8)                           CUSTOM8,
        sum(pjp.CUSTOM9)                           CUSTOM9,
        sum(pjp.CUSTOM10)                          CUSTOM10,
        sum(pjp.CUSTOM11)                          CUSTOM11,
        sum(pjp.CUSTOM12)                          CUSTOM12,
        sum(pjp.CUSTOM13)                          CUSTOM13,
        sum(pjp.CUSTOM14)                          CUSTOM14,
        sum(pjp.CUSTOM15)                          CUSTOM15
      from
        (
        select /*+ ordered index(acr PJI_AC_XBS_ACCUM_F_N1) */
               -- get structure level amounts from Reporting Lines
          /*prg.SUP_PROJECT_ID,
          prg.SUP_ID,
          prg.SUP_EMT_ID,
          prg.SUB_EMT_ID,
          prg.SUB_ROLLUP_ID,
          'ACR'                                    LINE_SOURCE,
          prg.SUB_ID,
          acr.TIME_ID,
          acr.PERIOD_TYPE_ID,
          acr.CALENDAR_TYPE,
          acr.CURR_RECORD_TYPE_ID,
          acr.CURRENCY_CODE,
          prg.SIGN * acr.REVENUE                   REVENUE,
          prg.SIGN * acr.INITIAL_FUNDING_AMOUNT    INITIAL_FUNDING_AMOUNT,
          prg.SIGN * acr.INITIAL_FUNDING_COUNT     INITIAL_FUNDING_COUNT,
          prg.SIGN * acr.ADDITIONAL_FUNDING_AMOUNT ADDITIONAL_FUNDING_AMOUNT,
          prg.SIGN * acr.ADDITIONAL_FUNDING_COUNT  ADDITIONAL_FUNDING_COUNT,
          prg.SIGN * acr.CANCELLED_FUNDING_AMOUNT  CANCELLED_FUNDING_AMOUNT,
          prg.SIGN * acr.CANCELLED_FUNDING_COUNT   CANCELLED_FUNDING_COUNT,
          prg.SIGN * acr.FUNDING_ADJUSTMENT_AMOUNT FUNDING_ADJUSTMENT_AMOUNT,
          prg.SIGN * acr.FUNDING_ADJUSTMENT_COUNT  FUNDING_ADJUSTMENT_COUNT,
          prg.SIGN * acr.REVENUE_WRITEOFF          REVENUE_WRITEOFF,
          prg.SIGN * acr.AR_INVOICE_AMOUNT         AR_INVOICE_AMOUNT,
          prg.SIGN * acr.AR_INVOICE_COUNT          AR_INVOICE_COUNT,
          prg.SIGN * acr.AR_CASH_APPLIED_AMOUNT    AR_CASH_APPLIED_AMOUNT,
          prg.SIGN *
            acr.AR_INVOICE_WRITE_OFF_AMOUNT        AR_INVOICE_WRITE_OFF_AMOUNT,
          prg.SIGN * acr.AR_INVOICE_WRITEOFF_COUNT AR_INVOICE_WRITEOFF_COUNT,
          prg.SIGN * acr.AR_CREDIT_MEMO_AMOUNT     AR_CREDIT_MEMO_AMOUNT,
          prg.SIGN * acr.AR_CREDIT_MEMO_COUNT      AR_CREDIT_MEMO_COUNT,
          prg.SIGN * acr.UNBILLED_RECEIVABLES      UNBILLED_RECEIVABLES,
          prg.SIGN * acr.UNEARNED_REVENUE          UNEARNED_REVENUE,
          prg.SIGN * acr.AR_UNAPPR_INVOICE_AMOUNT  AR_UNAPPR_INVOICE_AMOUNT,
          prg.SIGN * acr.AR_UNAPPR_INVOICE_COUNT   AR_UNAPPR_INVOICE_COUNT,
          prg.SIGN * acr.AR_APPR_INVOICE_AMOUNT    AR_APPR_INVOICE_AMOUNT,
          prg.SIGN * acr.AR_APPR_INVOICE_COUNT     AR_APPR_INVOICE_COUNT,
          prg.SIGN * acr.AR_AMOUNT_DUE             AR_AMOUNT_DUE,
          prg.SIGN * acr.AR_COUNT_DUE              AR_COUNT_DUE,
          prg.SIGN * acr.AR_AMOUNT_OVERDUE         AR_AMOUNT_OVERDUE,
          prg.SIGN * acr.AR_COUNT_OVERDUE          AR_COUNT_OVERDUE,
          prg.SIGN * acr.CUSTOM1                   CUSTOM1,
          prg.SIGN * acr.CUSTOM2                   CUSTOM2,
          prg.SIGN * acr.CUSTOM3                   CUSTOM3,
          prg.SIGN * acr.CUSTOM4                   CUSTOM4,
          prg.SIGN * acr.CUSTOM5                   CUSTOM5,
          prg.SIGN * acr.CUSTOM6                   CUSTOM6,
          prg.SIGN * acr.CUSTOM7                   CUSTOM7,
          prg.SIGN * acr.CUSTOM8                   CUSTOM8,
          prg.SIGN * acr.CUSTOM9                   CUSTOM9,
          prg.SIGN * acr.CUSTOM10                  CUSTOM10,
          prg.SIGN * acr.CUSTOM11                  CUSTOM11,
          prg.SIGN * acr.CUSTOM12                  CUSTOM12,
          prg.SIGN * acr.CUSTOM13                  CUSTOM13,
          prg.SIGN * acr.CUSTOM14                  CUSTOM14,
          prg.SIGN * acr.CUSTOM15                  CUSTOM15
        from
          PJI_XBS_DENORM_DELTA prg,
          PA_PROJ_ELEMENTS     prj_emt,
          PJI_PJP_WBS_HEADER   wbs_hdr,
          PJI_AC_XBS_ACCUM_F   acr
        where
          prg.WORKER_ID           =  p_worker_id        and
          prg.STRUCT_TYPE         =  'PRG'              and
          prg.RELATIONSHIP_TYPE   =  'LF'               and
          prg.SUP_LEVEL           =  l_level            and
          nvl(prg.SUB_ROLLUP_ID,
              prg.SUP_EMT_ID)     <> prg.SUP_EMT_ID     and
          acr.WBS_ROLLUP_FLAG     in ('Y', 'N')         and
          acr.PRG_ROLLUP_FLAG     in ('Y', 'N')         and
          acr.PROJECT_ID          =  prj_emt.PROJECT_ID and
          acr.PROJECT_ELEMENT_ID  =  prg.SUB_EMT_ID     and
          prj_emt.PROJ_ELEMENT_ID =  prg.SUB_EMT_ID     and
          wbs_hdr.PROJECT_ID      =  prj_emt.PROJECT_ID and
          wbs_hdr.PLAN_VERSION_ID =  -1
        union all
        select /*+ ordered */
               -- get program rollup amounts
          /*prg.SUP_PROJECT_ID,
          prg.SUP_ID,
          prg.SUP_EMT_ID,
          prg.SUB_EMT_ID,
          prg.SUB_ROLLUP_ID,
          'PJP1'                                   LINE_SOURCE,
          prg.SUB_ID,
          pjp1.TIME_ID,
          pjp1.PERIOD_TYPE_ID,
          pjp1.CALENDAR_TYPE,
          pjp1.CURR_RECORD_TYPE_ID,
          pjp1.CURRENCY_CODE,
          pjp1.REVENUE,
          pjp1.INITIAL_FUNDING_AMOUNT,
          pjp1.INITIAL_FUNDING_COUNT,
          pjp1.ADDITIONAL_FUNDING_AMOUNT,
          pjp1.ADDITIONAL_FUNDING_COUNT,
          pjp1.CANCELLED_FUNDING_AMOUNT,
          pjp1.CANCELLED_FUNDING_COUNT,
          pjp1.FUNDING_ADJUSTMENT_AMOUNT,
          pjp1.FUNDING_ADJUSTMENT_COUNT,
          pjp1.REVENUE_WRITEOFF,
          pjp1.AR_INVOICE_AMOUNT,
          pjp1.AR_INVOICE_COUNT,
          pjp1.AR_CASH_APPLIED_AMOUNT,
          pjp1.AR_INVOICE_WRITE_OFF_AMOUNT,
          pjp1.AR_INVOICE_WRITEOFF_COUNT,
          pjp1.AR_CREDIT_MEMO_AMOUNT,
          pjp1.AR_CREDIT_MEMO_COUNT,
          pjp1.UNBILLED_RECEIVABLES,
          pjp1.UNEARNED_REVENUE,
          pjp1.AR_UNAPPR_INVOICE_AMOUNT,
          pjp1.AR_UNAPPR_INVOICE_COUNT,
          pjp1.AR_APPR_INVOICE_AMOUNT,
          pjp1.AR_APPR_INVOICE_COUNT,
          pjp1.AR_AMOUNT_DUE,
          pjp1.AR_COUNT_DUE,
          pjp1.AR_AMOUNT_OVERDUE,
          pjp1.AR_COUNT_OVERDUE,
          pjp1.CUSTOM1,
          pjp1.CUSTOM2,
          pjp1.CUSTOM3,
          pjp1.CUSTOM4,
          pjp1.CUSTOM5,
          pjp1.CUSTOM6,
          pjp1.CUSTOM7,
          pjp1.CUSTOM8,
          pjp1.CUSTOM9,
          pjp1.CUSTOM10,
          pjp1.CUSTOM11,
          pjp1.CUSTOM12,
          pjp1.CUSTOM13,
          pjp1.CUSTOM14,
          pjp1.CUSTOM15
        from
          PJI_AC_AGGR_PJP1     pjp1,
          PJI_PJP_WBS_HEADER   wbs_hdr,
          PA_PROJ_ELEMENTS     prj_emt,
          PA_XBS_DENORM        prg,
          PJI_XBS_DENORM_DELTA prg_delta
        where
          prg.STRUCT_TYPE         =  'PRG'                           and
          prg.SUP_LEVEL           =  l_level                         and
          nvl(prg.SUB_ROLLUP_ID,
              prg.SUP_EMT_ID)     <> prg.SUP_EMT_ID                  and
          prg.RELATIONSHIP_TYPE   =  'LF'                            and
          p_worker_id             =  prg_delta.WORKER_ID         (+) and
          prg.STRUCT_TYPE         =  prg_delta.STRUCT_TYPE       (+) and
          prg.SUP_PROJECT_ID      =  prg_delta.SUP_PROJECT_ID    (+) and
          prg.SUP_LEVEL           =  prg_delta.SUP_LEVEL         (+) and
          prg.SUP_ID              =  prg_delta.SUP_ID            (+) and
          prg.SUB_LEVEL           =  prg_delta.SUB_LEVEL         (+) and
          prg.SUB_ID              =  prg_delta.SUB_ID            (+) and
          prg.RELATIONSHIP_TYPE   =  prg_delta.RELATIONSHIP_TYPE (+) and
          1                       =  prg_delta.SIGN              (+) and
          (prg_delta.SUP_PROJECT_ID is not null or
           (prg_delta.SUP_PROJECT_ID is null and
            pjp1.RECORD_TYPE = 'P'))                                 and
          pjp1.WORKER_ID          =  p_worker_id                     and
          pjp1.PRG_LEVEL          in (0, prg.SUB_LEVEL)              and
          pjp1.WBS_ROLLUP_FLAG    in ('Y', 'N')                      and
          pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                      and
          pjp1.PROJECT_ID         =  prj_emt.PROJECT_ID              and
          pjp1.PROJECT_ELEMENT_ID =  prg.SUB_EMT_ID                  and
          prg.STRUCT_VERSION_ID   is null                            and
          prj_emt.OBJECT_TYPE     =  'PA_STRUCTURES'                 and
          prj_emt.PROJ_ELEMENT_ID =  prg.SUB_EMT_ID                  and
          wbs_hdr.PROJECT_ID      =  prj_emt.PROJECT_ID              and
          wbs_hdr.WBS_VERSION_ID  =  prg.SUB_ID                      and
          wbs_hdr.PROJECT_ID      =  pjp1.PROJECT_ID                 and
          wbs_hdr.PLAN_VERSION_ID =  -1
        )                          pjp,
        PJI_PJP_PROJ_BATCH_MAP     map,
        PA_PROJ_WORKPLAN_ATTR      sup_wpa,
        PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
        PA_XBS_DENORM              wbs,
        (
          select 1     WBS_SUP_LEVEL,
                 'PRJ' INVERT_ID
          from   DUAL
          union all
          select 1     WBS_SUP_LEVEL,
                 'WBS' INVERT_ID
          from   DUAL
        ) top_slice
      where
        map.WORKER_ID         =  p_worker_id                        and
        map.PROJECT_ID        = pjp.SUP_PROJECT_ID                  and
        pjp.SUP_EMT_ID        = sup_wpa.PROJ_ELEMENT_ID             and
        pjp.SUP_PROJECT_ID    = sup_fin_ver.PROJECT_ID          (+) and
        pjp.SUP_ID            = sup_fin_ver.ELEMENT_VERSION_ID  (+) and
        'STRUCTURE_WORKING'   = sup_fin_ver.STATUS_CODE         (+) and
        (sup_fin_ver.PROJECT_ID is not null or
         sup_wpa.WP_ENABLE_VERSION_FLAG = 'N')                      and
        wbs.STRUCT_TYPE       =  'WBS'                              and
        wbs.SUP_PROJECT_ID    =  map.PROJECT_ID                     and
        wbs.SUP_PROJECT_ID    =  pjp.SUP_PROJECT_ID                 and
        wbs.STRUCT_VERSION_ID =  pjp.SUP_ID                         and
        wbs.SUB_EMT_ID        =  pjp.SUB_ROLLUP_ID                  and
        wbs.SUP_LEVEL         =  top_slice.WBS_SUP_LEVEL        (+)
      group by
        pjp.SUP_PROJECT_ID,
        map.PROJECT_ORG_ID,
        map.PROJECT_ORGANIZATION_ID,
        decode(top_slice.INVERT_ID,
               'PRJ', pjp.SUP_EMT_ID,
               wbs.SUP_EMT_ID),
        pjp.TIME_ID,
        pjp.PERIOD_TYPE_ID,
        pjp.CALENDAR_TYPE,
        decode(top_slice.INVERT_ID,
               'PRJ', 'Y', decode(pjp.SUB_ROLLUP_ID,
                                  wbs.SUP_EMT_ID,
                                  'N', 'Y')),
        pjp.CURR_RECORD_TYPE_ID,
        pjp.CURRENCY_CODE;*/

      update PJI_SYSTEM_PRC_STATUS
      set    STEP_STATUS = 'C',
             END_DATE = sysdate
      where  PROCESS_NAME = l_process and
             STEP_SEQ = l_level_seq;

      commit;

      select
        nvl(to_number(min(STEP_SEQ)), 0)
      into
        l_level_seq
      from
        PJI_SYSTEM_PRC_STATUS
      where
        PROCESS_NAME = l_process and
        STEP_NAME like 'ROLLUP_ACR_PRG%' and
        STEP_STATUS is null;

      if (l_level_seq = 0) then
        l_level := 0;
      else
        l_level := l_max_level - ((l_level_seq - l_step_seq) * 1000) + 1;
      end if;

    end loop;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_PRG(p_worker_id);');

    commit;

  end ROLLUP_ACR_PRG;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_CAL_NONTP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_CAL_NONTP (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_NONTP(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_NONTP_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_NONTP(p_worker_id);');

    commit;

  end ROLLUP_FPR_CAL_NONTP;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_CAL_PA
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_CAL_PA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_PA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_PA_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_PA(p_worker_id);');

    commit;

  end ROLLUP_FPR_CAL_PA;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_CAL_GL
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_CAL_GL (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_GL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_GL_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_GL(p_worker_id);');

    commit;

  end ROLLUP_FPR_CAL_GL;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_CAL_EN
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_CAL_EN (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_EN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_ENT_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_EN(p_worker_id);');

    commit;

  end ROLLUP_FPR_CAL_EN;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_CAL_ALL
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_CAL_ALL (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_ALL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- Changes done for bug 6381284
    --PJI_FM_PLAN_CAL_RLPS.CREATE_FP_ALL_T_PRI_ROLLUP('G');
    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_ALL_T_PRI_ROLLUP('C');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_ALL(p_worker_id);');

    commit;

  end ROLLUP_FPR_CAL_ALL;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_CAL_PA
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_CAL_PA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_PA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_AC_PA_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_PA(p_worker_id);');

    commit;

  end ROLLUP_ACR_CAL_PA;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_CAL_GL
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_CAL_GL (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_GL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

   PJI_FM_PLAN_CAL_RLPS.CREATE_AC_GL_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_GL(p_worker_id);');

    commit;

  end ROLLUP_ACR_CAL_GL;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_CAL_EN
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_CAL_EN (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_EN(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_AC_ENT_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_EN(p_worker_id);');

    commit;

  end ROLLUP_ACR_CAL_EN;


  -- -----------------------------------------------------
  -- procedure ROLLUP_ACR_CAL_ALL
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure ROLLUP_ACR_CAL_ALL (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_ALL(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_AC_ALL_T_PRI_ROLLUP('G');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_ALL(p_worker_id);');

    commit;

  end ROLLUP_ACR_CAL_ALL;



  -- -----------------------------------------------------
  -- procedure AGGREGATE_PLAN_DATA
  --
  --   History
  --   21-OCT-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure AGGREGATE_PLAN_DATA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_PLAN_DATA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    IF (l_extraction_type IN ('PARTIAL', 'RBS', 'INCREMENTAL', 'FULL')) THEN
/* Call to Paritioned procedure for bug 7551819 */
      PJI_PROCESS_UTIL.EXECUTE_AGGREGATE_PLAN_DATA(p_worker_id);

/* Commented for bug 7551819 */
--      insert /*+ parallel(pjp1_in)
  --               noappend(pjp1_in) */ into PJI_FP_AGGR_PJP1 pjp1_in   -- changed for bug 5927368
    /*  (
        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        LINE_TYPE,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        RBS_AGGR_LEVEL,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        RBS_ELEMENT_ID,
        RBS_VERSION_ID,
        PLAN_VERSION_ID,
        PLAN_TYPE_ID,
        PLAN_TYPE_CODE,
        RAW_COST,
        BRDN_COST,
        REVENUE,
        BILL_RAW_COST,
        BILL_BRDN_COST,
        BILL_LABOR_RAW_COST,
        BILL_LABOR_BRDN_COST,
        BILL_LABOR_HRS,
        EQUIPMENT_RAW_COST,
        EQUIPMENT_BRDN_COST,
        CAPITALIZABLE_RAW_COST,
        CAPITALIZABLE_BRDN_COST,
        LABOR_RAW_COST,
        LABOR_BRDN_COST,
        LABOR_HRS,
        LABOR_REVENUE,
        EQUIPMENT_HOURS,
        BILLABLE_EQUIPMENT_HOURS,
        SUP_INV_COMMITTED_COST,
        PO_COMMITTED_COST,
        PR_COMMITTED_COST,
        OTH_COMMITTED_COST,
        ACT_LABOR_HRS,
        ACT_EQUIP_HRS,
        ACT_LABOR_BRDN_COST,
        ACT_EQUIP_BRDN_COST,
        ACT_BRDN_COST,
        ACT_RAW_COST,
        ACT_REVENUE,
        ACT_LABOR_RAW_COST,
        ACT_EQUIP_RAW_COST,
        ETC_LABOR_HRS,
        ETC_EQUIP_HRS,
        ETC_LABOR_BRDN_COST,
        ETC_EQUIP_BRDN_COST,
        ETC_BRDN_COST,
        ETC_RAW_COST,
        ETC_LABOR_RAW_COST,
        ETC_EQUIP_RAW_COST,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select
        pjp1.WORKER_ID,
        'A'                                 RECORD_TYPE,
        pjp1.PRG_LEVEL,
        'AGGR_PLAN'                         LINE_TYPE,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE,
        sum(pjp1.RAW_COST)                  RAW_COST,
        sum(pjp1.BRDN_COST)                 BRDN_COST,
        sum(pjp1.REVENUE)                   REVENUE,
        sum(pjp1.BILL_RAW_COST)             BILL_RAW_COST,
        sum(pjp1.BILL_BRDN_COST)            BILL_BRDN_COST,
        sum(pjp1.BILL_LABOR_RAW_COST)       BILL_LABOR_RAW_COST,
        sum(pjp1.BILL_LABOR_BRDN_COST)      BILL_LABOR_BRDN_COST,
        sum(pjp1.BILL_LABOR_HRS)            BILL_LABOR_HRS,
        sum(pjp1.EQUIPMENT_RAW_COST)        EQUIPMENT_RAW_COST,
        sum(pjp1.EQUIPMENT_BRDN_COST)       EQUIPMENT_BRDN_COST,
        sum(pjp1.CAPITALIZABLE_RAW_COST)    CAPITALIZABLE_RAW_COST,
        sum(pjp1.CAPITALIZABLE_BRDN_COST)   CAPITALIZABLE_BRDN_COST,
        sum(pjp1.LABOR_RAW_COST)            LABOR_RAW_COST,
        sum(pjp1.LABOR_BRDN_COST)           LABOR_BRDN_COST,
        sum(pjp1.LABOR_HRS)                 LABOR_HRS,
        sum(pjp1.LABOR_REVENUE)             LABOR_REVENUE,
        sum(pjp1.EQUIPMENT_HOURS)           EQUIPMENT_HOURS,
        sum(pjp1.BILLABLE_EQUIPMENT_HOURS)  BILLABLE_EQUIPMENT_HOURS,
        sum(pjp1.SUP_INV_COMMITTED_COST)    SUP_INV_COMMITTED_COST,
        sum(pjp1.PO_COMMITTED_COST)         PO_COMMITTED_COST,
        sum(pjp1.PR_COMMITTED_COST)         PR_COMMITTED_COST,
        sum(pjp1.OTH_COMMITTED_COST)        OTH_COMMITTED_COST,
        sum(pjp1.ACT_LABOR_HRS)             ACT_LABOR_HRS,
        sum(pjp1.ACT_EQUIP_HRS)             ACT_EQUIP_HRS,
        sum(pjp1.ACT_LABOR_BRDN_COST)       ACT_LABOR_BRDN_COST,
        sum(pjp1.ACT_EQUIP_BRDN_COST)       ACT_EQUIP_BRDN_COST,
        sum(pjp1.ACT_BRDN_COST)             ACT_BRDN_COST,
        sum(pjp1.ACT_RAW_COST)              ACT_RAW_COST,
        sum(pjp1.ACT_REVENUE)               ACT_REVENUE,
        sum(pjp1.ACT_LABOR_RAW_COST)        ACT_LABOR_RAW_COST,
        sum(pjp1.ACT_EQUIP_RAW_COST)        ACT_EQUIP_RAW_COST,
        sum(pjp1.ETC_LABOR_HRS)             ETC_LABOR_HRS,
        sum(pjp1.ETC_EQUIP_HRS)             ETC_EQUIP_HRS,
        sum(pjp1.ETC_LABOR_BRDN_COST)       ETC_LABOR_BRDN_COST,
        sum(pjp1.ETC_EQUIP_BRDN_COST)       ETC_EQUIP_BRDN_COST,
        sum(pjp1.ETC_BRDN_COST)             ETC_BRDN_COST,
        sum(pjp1.ETC_RAW_COST)              ETC_RAW_COST,
        sum(pjp1.ETC_LABOR_RAW_COST)        ETC_LABOR_RAW_COST,
        sum(pjp1.ETC_EQUIP_RAW_COST)        ETC_EQUIP_RAW_COST,
        sum(pjp1.CUSTOM1)                   CUSTOM1,
        sum(pjp1.CUSTOM2)                   CUSTOM2,
        sum(pjp1.CUSTOM3)                   CUSTOM3,
        sum(pjp1.CUSTOM4)                   CUSTOM4,
        sum(pjp1.CUSTOM5)                   CUSTOM5,
        sum(pjp1.CUSTOM6)                   CUSTOM6,
        sum(pjp1.CUSTOM7)                   CUSTOM7,
        sum(pjp1.CUSTOM8)                   CUSTOM8,
        sum(pjp1.CUSTOM9)                   CUSTOM9,
        sum(pjp1.CUSTOM10)                  CUSTOM10,
        sum(pjp1.CUSTOM11)                  CUSTOM11,
        sum(pjp1.CUSTOM12)                  CUSTOM12,
        sum(pjp1.CUSTOM13)                  CUSTOM13,
        sum(pjp1.CUSTOM14)                  CUSTOM14,
        sum(pjp1.CUSTOM15)                  CUSTOM15
      from
        PJI_FP_AGGR_PJP1 pjp1
      where
        pjp1.WORKER_ID = p_worker_id
      group by
        pjp1.WORKER_ID,
        pjp1.PRG_LEVEL,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.RBS_AGGR_LEVEL,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        pjp1.RBS_ELEMENT_ID,
        pjp1.RBS_VERSION_ID,
        pjp1.PLAN_VERSION_ID,
        pjp1.PLAN_TYPE_ID,
        pjp1.PLAN_TYPE_CODE
      having not
        (nvl(sum(pjp1.RAW_COST), 0)                 = 0 and
         nvl(sum(pjp1.BRDN_COST), 0)                = 0 and
         nvl(sum(pjp1.REVENUE), 0)                  = 0 and
         nvl(sum(pjp1.BILL_RAW_COST), 0)            = 0 and
         nvl(sum(pjp1.BILL_BRDN_COST), 0)           = 0 and
         nvl(sum(pjp1.BILL_LABOR_RAW_COST), 0)      = 0 and
         nvl(sum(pjp1.BILL_LABOR_BRDN_COST), 0)     = 0 and
         nvl(sum(pjp1.BILL_LABOR_HRS), 0)           = 0 and
         nvl(sum(pjp1.EQUIPMENT_RAW_COST), 0)       = 0 and
         nvl(sum(pjp1.EQUIPMENT_BRDN_COST), 0)      = 0 and
         nvl(sum(pjp1.CAPITALIZABLE_RAW_COST), 0)   = 0 and
         nvl(sum(pjp1.CAPITALIZABLE_BRDN_COST), 0)  = 0 and
         nvl(sum(pjp1.LABOR_RAW_COST), 0)           = 0 and
         nvl(sum(pjp1.LABOR_BRDN_COST), 0)          = 0 and
         nvl(sum(pjp1.LABOR_HRS), 0)                = 0 and
         nvl(sum(pjp1.LABOR_REVENUE), 0)            = 0 and
         nvl(sum(pjp1.EQUIPMENT_HOURS), 0)          = 0 and
         nvl(sum(pjp1.BILLABLE_EQUIPMENT_HOURS), 0) = 0 and
         nvl(sum(pjp1.SUP_INV_COMMITTED_COST), 0)   = 0 and
         nvl(sum(pjp1.PO_COMMITTED_COST), 0)        = 0 and
         nvl(sum(pjp1.PR_COMMITTED_COST), 0)        = 0 and
         nvl(sum(pjp1.OTH_COMMITTED_COST), 0)       = 0 and
         nvl(sum(pjp1.ACT_LABOR_HRS), 0)            = 0 and
         nvl(sum(pjp1.ACT_EQUIP_HRS), 0)            = 0 and
         nvl(sum(pjp1.ACT_LABOR_BRDN_COST), 0)      = 0 and
         nvl(sum(pjp1.ACT_EQUIP_BRDN_COST), 0)      = 0 and
         nvl(sum(pjp1.ACT_BRDN_COST), 0)            = 0 and
         nvl(sum(pjp1.ACT_RAW_COST), 0)             = 0 and
         nvl(sum(pjp1.ACT_REVENUE), 0)              = 0 and
         nvl(sum(pjp1.ACT_LABOR_RAW_COST), 0)       = 0 and
         nvl(sum(pjp1.ACT_EQUIP_RAW_COST), 0)       = 0 and
         nvl(sum(pjp1.ETC_LABOR_HRS), 0)            = 0 and
         nvl(sum(pjp1.ETC_EQUIP_HRS), 0)            = 0 and
         nvl(sum(pjp1.ETC_LABOR_BRDN_COST), 0)      = 0 and
         nvl(sum(pjp1.ETC_EQUIP_BRDN_COST), 0)      = 0 and
         nvl(sum(pjp1.ETC_BRDN_COST), 0)            = 0 and
         nvl(sum(pjp1.ETC_RAW_COST), 0)             = 0 and
         nvl(sum(pjp1.ETC_LABOR_RAW_COST), 0)       = 0 and
         nvl(sum(pjp1.ETC_EQUIP_RAW_COST), 0)       = 0 and
         nvl(sum(pjp1.CUSTOM1), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM2), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM3), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM4), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM5), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM6), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM7), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM8), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM9), 0)                  = 0 and
         nvl(sum(pjp1.CUSTOM10), 0)                 = 0 and
         nvl(sum(pjp1.CUSTOM11), 0)                 = 0 and
         nvl(sum(pjp1.CUSTOM12), 0)                 = 0 and
         nvl(sum(pjp1.CUSTOM13), 0)                 = 0 and
         nvl(sum(pjp1.CUSTOM14), 0)                 = 0 and
         nvl(sum(pjp1.CUSTOM15), 0)                 = 0);

      insert into PJI_AC_AGGR_PJP1 pjp1_i
      (
        WORKER_ID,
        RECORD_TYPE,
        PRG_LEVEL,
        PROJECT_ID,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_ELEMENT_ID,
        TIME_ID,
        PERIOD_TYPE_ID,
        CALENDAR_TYPE,
        WBS_ROLLUP_FLAG,
        PRG_ROLLUP_FLAG,
        CURR_RECORD_TYPE_ID,
        CURRENCY_CODE,
        REVENUE,
        INITIAL_FUNDING_AMOUNT,
        INITIAL_FUNDING_COUNT,
        ADDITIONAL_FUNDING_AMOUNT,
        ADDITIONAL_FUNDING_COUNT,
        CANCELLED_FUNDING_AMOUNT,
        CANCELLED_FUNDING_COUNT,
        FUNDING_ADJUSTMENT_AMOUNT,
        FUNDING_ADJUSTMENT_COUNT,
        REVENUE_WRITEOFF,
        AR_INVOICE_AMOUNT,
        AR_INVOICE_COUNT,
        AR_CASH_APPLIED_AMOUNT,
        AR_INVOICE_WRITE_OFF_AMOUNT,
        AR_INVOICE_WRITEOFF_COUNT,
        AR_CREDIT_MEMO_AMOUNT,
        AR_CREDIT_MEMO_COUNT,
        UNBILLED_RECEIVABLES,
        UNEARNED_REVENUE,
        AR_UNAPPR_INVOICE_AMOUNT,
        AR_UNAPPR_INVOICE_COUNT,
        AR_APPR_INVOICE_AMOUNT,
        AR_APPR_INVOICE_COUNT,
        AR_AMOUNT_DUE,
        AR_COUNT_DUE,
        AR_AMOUNT_OVERDUE,
        AR_COUNT_OVERDUE,
        CUSTOM1,
        CUSTOM2,
        CUSTOM3,
        CUSTOM4,
        CUSTOM5,
        CUSTOM6,
        CUSTOM7,
        CUSTOM8,
        CUSTOM9,
        CUSTOM10,
        CUSTOM11,
        CUSTOM12,
        CUSTOM13,
        CUSTOM14,
        CUSTOM15
      )
      select
        pjp1.WORKER_ID,
        'A'                                        RECORD_TYPE,
        pjp1.PRG_LEVEL,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE,
        sum(pjp1.REVENUE)                          REVENUE,
        sum(pjp1.INITIAL_FUNDING_AMOUNT)           INITIAL_FUNDING_AMOUNT,
        sum(pjp1.INITIAL_FUNDING_COUNT)            INITIAL_FUNDING_COUNT,
        sum(pjp1.ADDITIONAL_FUNDING_AMOUNT)        ADDITIONAL_FUNDING_AMOUNT,
        sum(pjp1.ADDITIONAL_FUNDING_COUNT)         ADDITIONAL_FUNDING_COUNT,
        sum(pjp1.CANCELLED_FUNDING_AMOUNT)         CANCELLED_FUNDING_AMOUNT,
        sum(pjp1.CANCELLED_FUNDING_COUNT)          CANCELLED_FUNDING_COUNT,
        sum(pjp1.FUNDING_ADJUSTMENT_AMOUNT)        FUNDING_ADJUSTMENT_AMOUNT,
        sum(pjp1.FUNDING_ADJUSTMENT_COUNT)         FUNDING_ADJUSTMENT_COUNT,
        sum(pjp1.REVENUE_WRITEOFF)                 REVENUE_WRITEOFF,
        sum(pjp1.AR_INVOICE_AMOUNT)                AR_INVOICE_AMOUNT,
        sum(pjp1.AR_INVOICE_COUNT)                 AR_INVOICE_COUNT,
        sum(pjp1.AR_CASH_APPLIED_AMOUNT)           AR_CASH_APPLIED_AMOUNT,
        sum(pjp1.AR_INVOICE_WRITE_OFF_AMOUNT)      AR_INVOICE_WRITE_OFF_AMOUNT,
        sum(pjp1.AR_INVOICE_WRITEOFF_COUNT)        AR_INVOICE_WRITEOFF_COUNT,
        sum(pjp1.AR_CREDIT_MEMO_AMOUNT)            AR_CREDIT_MEMO_AMOUNT,
        sum(pjp1.AR_CREDIT_MEMO_COUNT)             AR_CREDIT_MEMO_COUNT,
        sum(pjp1.UNBILLED_RECEIVABLES)             UNBILLED_RECEIVABLES,
        sum(pjp1.UNEARNED_REVENUE)                 UNEARNED_REVENUE,
        sum(pjp1.AR_UNAPPR_INVOICE_AMOUNT)         AR_UNAPPR_INVOICE_AMOUNT,
        sum(pjp1.AR_UNAPPR_INVOICE_COUNT)          AR_UNAPPR_INVOICE_COUNT,
        sum(pjp1.AR_APPR_INVOICE_AMOUNT)           AR_APPR_INVOICE_AMOUNT,
        sum(pjp1.AR_APPR_INVOICE_COUNT)            AR_APPR_INVOICE_COUNT,
        sum(pjp1.AR_AMOUNT_DUE)                    AR_AMOUNT_DUE,
        sum(pjp1.AR_COUNT_DUE)                     AR_COUNT_DUE,
        sum(pjp1.AR_AMOUNT_OVERDUE)                AR_AMOUNT_OVERDUE,
        sum(pjp1.AR_COUNT_OVERDUE)                 AR_COUNT_OVERDUE,
        sum(pjp1.CUSTOM1)                          CUSTOM1,
        sum(pjp1.CUSTOM2)                          CUSTOM2,
        sum(pjp1.CUSTOM3)                          CUSTOM3,
        sum(pjp1.CUSTOM4)                          CUSTOM4,
        sum(pjp1.CUSTOM5)                          CUSTOM5,
        sum(pjp1.CUSTOM6)                          CUSTOM6,
        sum(pjp1.CUSTOM7)                          CUSTOM7,
        sum(pjp1.CUSTOM8)                          CUSTOM8,
        sum(pjp1.CUSTOM9)                          CUSTOM9,
        sum(pjp1.CUSTOM10)                         CUSTOM10,
        sum(pjp1.CUSTOM11)                         CUSTOM11,
        sum(pjp1.CUSTOM12)                         CUSTOM12,
        sum(pjp1.CUSTOM13)                         CUSTOM13,
        sum(pjp1.CUSTOM14)                         CUSTOM14,
        sum(pjp1.CUSTOM15)                         CUSTOM15
      from
        PJI_AC_AGGR_PJP1 pjp1
      where
        pjp1.WORKER_ID = p_worker_id
      group by
        pjp1.WORKER_ID,
        pjp1.PRG_LEVEL,
        pjp1.PROJECT_ID,
        pjp1.PROJECT_ORG_ID,
        pjp1.PROJECT_ORGANIZATION_ID,
        pjp1.PROJECT_ELEMENT_ID,
        pjp1.TIME_ID,
        pjp1.PERIOD_TYPE_ID,
        pjp1.CALENDAR_TYPE,
        pjp1.WBS_ROLLUP_FLAG,
        pjp1.PRG_ROLLUP_FLAG,
        pjp1.CURR_RECORD_TYPE_ID,
        pjp1.CURRENCY_CODE
      having not
        (nvl(sum(REVENUE), 0)                     = 0 and
         nvl(sum(INITIAL_FUNDING_AMOUNT), 0)      = 0 and
         nvl(sum(INITIAL_FUNDING_COUNT), 0)       = 0 and
         nvl(sum(ADDITIONAL_FUNDING_AMOUNT), 0)   = 0 and
         nvl(sum(ADDITIONAL_FUNDING_COUNT), 0)    = 0 and
         nvl(sum(CANCELLED_FUNDING_AMOUNT), 0)    = 0 and
         nvl(sum(CANCELLED_FUNDING_COUNT), 0)     = 0 and
         nvl(sum(FUNDING_ADJUSTMENT_AMOUNT), 0)   = 0 and
         nvl(sum(FUNDING_ADJUSTMENT_COUNT), 0)    = 0 and
         nvl(sum(REVENUE_WRITEOFF), 0)            = 0 and
         nvl(sum(AR_INVOICE_AMOUNT), 0)           = 0 and
         nvl(sum(AR_INVOICE_COUNT), 0)            = 0 and
         nvl(sum(AR_CASH_APPLIED_AMOUNT), 0)      = 0 and
         nvl(sum(AR_INVOICE_WRITE_OFF_AMOUNT), 0) = 0 and
         nvl(sum(AR_INVOICE_WRITEOFF_COUNT), 0)   = 0 and
         nvl(sum(AR_CREDIT_MEMO_AMOUNT), 0)       = 0 and
         nvl(sum(AR_CREDIT_MEMO_COUNT), 0)        = 0 and
         nvl(sum(UNBILLED_RECEIVABLES), 0)        = 0 and
         nvl(sum(UNEARNED_REVENUE), 0)            = 0 and
         nvl(sum(AR_UNAPPR_INVOICE_AMOUNT), 0)    = 0 and
         nvl(sum(AR_UNAPPR_INVOICE_COUNT), 0)     = 0 and
         nvl(sum(AR_APPR_INVOICE_AMOUNT), 0)      = 0 and
         nvl(sum(AR_APPR_INVOICE_COUNT), 0)       = 0 and
         nvl(sum(AR_AMOUNT_DUE), 0)               = 0 and
         nvl(sum(AR_COUNT_DUE), 0)                = 0 and
         nvl(sum(AR_AMOUNT_OVERDUE), 0)           = 0 and
         nvl(sum(AR_COUNT_OVERDUE), 0)            = 0 and
         nvl(sum(CUSTOM1), 0)                     = 0 and
         nvl(sum(CUSTOM2), 0)                     = 0 and
         nvl(sum(CUSTOM3), 0)                     = 0 and
         nvl(sum(CUSTOM4), 0)                     = 0 and
         nvl(sum(CUSTOM5), 0)                     = 0 and
         nvl(sum(CUSTOM6), 0)                     = 0 and
         nvl(sum(CUSTOM7), 0)                     = 0 and
         nvl(sum(CUSTOM8), 0)                     = 0 and
         nvl(sum(CUSTOM9), 0)                     = 0 and
         nvl(sum(CUSTOM10), 0)                    = 0 and
         nvl(sum(CUSTOM11), 0)                    = 0 and
         nvl(sum(CUSTOM12), 0)                    = 0 and
         nvl(sum(CUSTOM13), 0)                    = 0 and
         nvl(sum(CUSTOM14), 0)                    = 0 and
         nvl(sum(CUSTOM15), 0)                    = 0); */

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.AGGREGATE_PLAN_DATA(p_worker_id);');

    commit;

  end AGGREGATE_PLAN_DATA;


  -- -----------------------------------------------------
  -- procedure PURGE_PLAN_DATA
  --
  --   History
  --   21-OCT-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure PURGE_PLAN_DATA (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

  -- begin: bug 7146014
  TYPE row_id_tab_type   IS TABLE OF rowid index by binary_integer;
  x_row_id               row_id_tab_type;

  cursor c1 is
    select rowid from pji_fp_aggr_pjp1
     where worker_id = p_worker_id
       and nvl(LINE_TYPE, 'X') <> 'AGGR_PLAN';
  -- end: bug 7146014
  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PURGE_PLAN_DATA(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    IF (l_extraction_type IN ('PARTIAL', 'RBS', 'INCREMENTAL', 'FULL')) THEN

	-- begin: bug 7146014

        open c1;
        loop
         fetch c1 bulk collect into x_row_id limit 500000;

          If x_row_id.count > 0  then
             Forall j in x_row_id.first..x_row_id.last
               delete from pji_fp_aggr_pjp1
          	    where worker_id = p_worker_id
          	      and rowid = x_row_id(j);

          	 commit;
          	 x_row_id.delete;
             exit when c1%notfound;

        	 Else
        	   Exit;
        	 End if;

        	 end loop;

          close c1;
        -- End: bug 7146014

	/* Commented for bug 7146014
      delete
      from   PJI_FP_AGGR_PJP1 pjp1
      where  pjp1.WORKER_ID = p_worker_id and
             nvl(pjp1.LINE_TYPE, 'X') <> 'AGGR_PLAN';
*/
      delete
      from   PJI_AC_AGGR_PJP1 pjp1
      where  pjp1.WORKER_ID = p_worker_id and
             nvl(pjp1.RECORD_TYPE, 'X') <> 'A';

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PURGE_PLAN_DATA(p_worker_id);');

    commit;

  end PURGE_PLAN_DATA;


  -- -----------------------------------------------------
  -- procedure GET_FPR_ROWIDS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure GET_FPR_ROWIDS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.GET_FPR_ROWIDS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.GET_FP_ROW_IDS;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.GET_FPR_ROWIDS(p_worker_id);');

    commit;

  end GET_FPR_ROWIDS;


  -- -----------------------------------------------------
  -- procedure UPDATE_FPR_ROWS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure UPDATE_FPR_ROWS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_FPR_ROWS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.UPDATE_FP_ROWS;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_FPR_ROWS(p_worker_id);');

    commit;

  end UPDATE_FPR_ROWS;


  -- -----------------------------------------------------
  -- procedure INSERT_FPR_ROWS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure INSERT_FPR_ROWS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_FPR_ROWS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.INSERT_FP_ROWS;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_FPR_ROWS(p_worker_id);');

    commit;

  end INSERT_FPR_ROWS;


  -- -----------------------------------------------------
  -- procedure CLEANUP_FPR_ROWID_TABLE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- -----------------------------------------------------
  procedure CLEANUP_FPR_ROWID_TABLE (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP_FPR_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- PJI_FM_PLAN_MAINT_PVT.CLEANUP_FP_RMAP_FPR;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP_FPR_ROWID_TABLE(p_worker_id);');

    commit;

  end CLEANUP_FPR_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure GET_ACR_ROWIDS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure GET_ACR_ROWIDS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.GET_ACR_ROWIDS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL' or
        l_extraction_type = 'PARTIAL' or
        l_extraction_type = 'RBS') then

      PJI_FM_PLAN_MAINT_PVT.GET_AC_ROW_IDS;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.GET_ACR_ROWIDS(p_worker_id);');

    commit;

  end GET_ACR_ROWIDS;


  -- -----------------------------------------------------
  -- procedure UPDATE_ACR_ROWS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure UPDATE_ACR_ROWS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_ACR_ROWS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'INCREMENTAL' or
        l_extraction_type = 'PARTIAL' or
        l_extraction_type = 'RBS') then

      PJI_FM_PLAN_MAINT_PVT.UPDATE_AC_ROWS;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_ACR_ROWS(p_worker_id);');

    commit;

  end UPDATE_ACR_ROWS;


  -- -----------------------------------------------------
  -- procedure INSERT_ACR_ROWS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure INSERT_ACR_ROWS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_ACR_ROWS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'FULL') then

      PJI_FM_PLAN_MAINT_PVT.INSERT_INTO_AC_FACT;

    elsif (l_extraction_type = 'INCREMENTAL' or
           l_extraction_type = 'PARTIAL' or
           l_extraction_type = 'RBS') then

      PJI_FM_PLAN_MAINT_PVT.INSERT_AC_ROWS;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_ACR_ROWS(p_worker_id);');

    commit;

  end INSERT_ACR_ROWS;


  -- -----------------------------------------------------
  -- procedure CLEANUP_ACR_ROWID_TABLE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure CLEANUP_ACR_ROWID_TABLE (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP_ACR_ROWID_TABLE(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- if (l_extraction_type = 'INCREMENTAL' or
    --     l_extraction_type = 'PARTIAL' or
    --     l_extraction_type = 'RBS') then
    --
    --   PJI_FM_PLAN_MAINT_PVT.CLEANUP_AC_RMAP_FPR;
    --
    -- end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP_ACR_ROWID_TABLE(p_worker_id);');

    commit;

  end CLEANUP_ACR_ROWID_TABLE;


  -- -----------------------------------------------------
  -- procedure UPDATE_XBS_DENORM
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure UPDATE_XBS_DENORM (p_worker_id in number default null) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

    l_count             number;
    l_wbs_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  begin

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM(p_worker_id);')) then
        return;
      end if;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      l_count := 0;

      if (l_extraction_type = 'INCREMENTAL') then


        BEGIN
            select distinct struct_version_id bulk collect
            into  l_wbs_version_id_tbl
            from (
                 select  ver.element_version_id struct_version_id
                 from    PA_PROJ_ELEMENT_VERSIONS ver
                 where   ver.OBJECT_TYPE = 'PA_STRUCTURES' and
                         ver.PRG_GROUP in
             (select
                decode(invert.INVERT_ID,
                       1, log.EVENT_OBJECT,
                       2, log.ATTRIBUTE1) PRG_GROUP
              from
                PJI_PA_PROJ_EVENTS_LOG log,
                (
                  select 1 INVERT_ID from DUAL union all
                  select 2 INVERT_ID from DUAL
                ) invert
              where
                log.WORKER_ID    =  p_worker_id  and
                log.EVENT_TYPE   =  'PRG_CHANGE' and
                log.EVENT_OBJECT <> -1)
             union all
                 select ver.wbs_version_id
                 from   PJI_PA_PROJ_EVENTS_LOG log,Pji_pjp_wbs_header ver
                 where  ver.project_id=to_number(log.ATTRIBUTE1) and
                        log.WORKER_ID    = p_worker_id  and
                        log.EVENT_TYPE   = 'PRG_CHANGE' and
                        log.EVENT_OBJECT = -1
             union all
                 select   to_number(decode(invert.INVERT_ID,
                                           1, log.EVENT_OBJECT,
                                           2, log.ATTRIBUTE2)) struct_version_id
                 from    PJI_PA_PROJ_EVENTS_LOG log,
                         (
                          select 1 INVERT_ID from DUAL union all
                          select 2 INVERT_ID from DUAL
                         ) invert
                 where
                         log.WORKER_ID  = p_worker_id and
                         log.EVENT_TYPE in ('WBS_CHANGE',  'WBS_PUBLISH'));
              EXCEPTION
                  WHEN NO_DATA_FOUND then null;
              END;



        delete from PJI_XBS_DENORM
        where SUP_PROJECT_ID in
              (select
                 ver.PROJECT_ID
               from
                 PA_PROJ_ELEMENT_VERSIONS ver
               where
                 ver.OBJECT_TYPE = 'PA_STRUCTURES' and
                 ver.PRG_GROUP in
                 (select
                    decode(invert.INVERT_ID,
                           1, log.EVENT_OBJECT,
                           2, log.ATTRIBUTE1) PRG_GROUP
                  from
                    PJI_PA_PROJ_EVENTS_LOG log,
                    (
                      select 1 INVERT_ID from DUAL union all
                      select 2 INVERT_ID from DUAL
                    ) invert
                  where
                    log.WORKER_ID    =  p_worker_id  and
                    log.EVENT_TYPE   =  'PRG_CHANGE' and
                    log.EVENT_OBJECT <> -1));

        l_count := l_count + sql%rowcount;

        delete from PJI_XBS_DENORM
        where SUP_PROJECT_ID in (select log.ATTRIBUTE1
                                 from   PJI_PA_PROJ_EVENTS_LOG log
                                 where  log.WORKER_ID    = p_worker_id  and
                                        log.EVENT_TYPE   = 'PRG_CHANGE' and
                                        log.EVENT_OBJECT = -1);

        l_count := l_count + sql%rowcount;

        delete from PJI_XBS_DENORM
        where STRUCT_TYPE in ('WBS', 'XBS') and
              STRUCT_VERSION_ID in (select
                                      decode(invert.INVERT_ID,
                                             1, log.EVENT_OBJECT,
                                             2, log.ATTRIBUTE2)
                                    from
                                      PJI_PA_PROJ_EVENTS_LOG log,
                                      (
                                        select 1 INVERT_ID from DUAL union all
                                        select 2 INVERT_ID from DUAL
                                      ) invert
                                    where
                                      log.WORKER_ID  = p_worker_id and
                                      log.EVENT_TYPE in ('WBS_CHANGE',
                                                         'WBS_PUBLISH'));

        l_count := l_count + sql%rowcount;

        insert into PJI_XBS_DENORM
        (
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_TYPE,
          den.PRG_GROUP,
          den.STRUCT_VERSION_ID,
          den.SUP_PROJECT_ID,
          den.SUP_ID,
          den.SUP_EMT_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUB_EMT_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_ROLLUP_ID,
          den.SUB_LEAF_FLAG,
          den.RELATIONSHIP_TYPE,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_XBS_DENORM den
        where
          den.SUP_PROJECT_ID in
          (select
             ver.PROJECT_ID
           from
             PA_PROJ_ELEMENT_VERSIONS ver
           where
             ver.OBJECT_TYPE = 'PA_STRUCTURES' and
             ver.PRG_GROUP in
             (select
                decode(invert.INVERT_ID,
                       1, log.EVENT_OBJECT,
                       2, log.ATTRIBUTE1) PRG_GROUP
              from
                PJI_PA_PROJ_EVENTS_LOG log,
                (
                  select 1 INVERT_ID from DUAL union all
                  select 2 INVERT_ID from DUAL
                ) invert
              where
                log.WORKER_ID    =  p_worker_id  and
                log.EVENT_TYPE   =  'PRG_CHANGE' and
                log.EVENT_OBJECT <> -1)
           union
           select to_number(log.ATTRIBUTE1) PROJECT_ID
           from   PJI_PA_PROJ_EVENTS_LOG log
           where  log.WORKER_ID    = p_worker_id  and
                  log.EVENT_TYPE   = 'PRG_CHANGE' and
                  log.EVENT_OBJECT = -1)
        union all
        select
          den.STRUCT_TYPE,
          den.PRG_GROUP,
          den.STRUCT_VERSION_ID,
          den.SUP_PROJECT_ID,
          den.SUP_ID,
          den.SUP_EMT_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUB_EMT_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_ROLLUP_ID,
          den.SUB_LEAF_FLAG,
          den.RELATIONSHIP_TYPE,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_XBS_DENORM den,
          (
          select
            distinct
            EVENT_OBJECT,
            ATTRIBUTE2
          from
            PJI_PA_PROJ_EVENTS_LOG
          where
            WORKER_ID = p_worker_id and
            EVENT_TYPE in ('WBS_CHANGE', 'WBS_PUBLISH')
          ) log
        where
          den.STRUCT_TYPE in ('WBS', 'XBS') and
          (log.EVENT_OBJECT = den.STRUCT_VERSION_ID or
           log.ATTRIBUTE2 = den.STRUCT_VERSION_ID);

        l_count := l_count + sql%rowcount;

      elsif (l_extraction_type = 'PARTIAL') then

           BEGIN
            select distinct ver.wbs_version_id bulk collect
            into  l_wbs_version_id_tbl
            from  PJI_PJP_PROJ_BATCH_MAP map,Pji_pjp_wbs_header ver
            where map.PROJECT_ID=ver.project_id
            and   map.WORKER_ID = p_worker_id;
         EXCEPTION
            WHEN NO_DATA_FOUND then null;
         END;

        delete
        from   PJI_XBS_DENORM
        where  SUP_PROJECT_ID in (select map.PROJECT_ID
                                  from   PJI_PJP_PROJ_BATCH_MAP map
                                  where  WORKER_ID = p_worker_id);

        l_count := l_count + sql%rowcount;

        insert into PJI_XBS_DENORM
        (
          STRUCT_TYPE,
          PRG_GROUP,
          STRUCT_VERSION_ID,
          SUP_PROJECT_ID,
          SUP_ID,
          SUP_EMT_ID,
          SUBRO_ID,
          SUB_ID,
          SUB_EMT_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_ROLLUP_ID,
          SUB_LEAF_FLAG,
          RELATIONSHIP_TYPE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_TYPE,
          den.PRG_GROUP,
          den.STRUCT_VERSION_ID,
          den.SUP_PROJECT_ID,
          den.SUP_ID,
          den.SUP_EMT_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUB_EMT_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_ROLLUP_ID,
          den.SUB_LEAF_FLAG,
          den.RELATIONSHIP_TYPE,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PA_XBS_DENORM den
        where
          map.WORKER_ID = p_worker_id and
          den.SUP_PROJECT_ID = map.PROJECT_ID;

        l_count := l_count + sql%rowcount;

      end if;

      if (l_count > 0) then

        --  delete        from   PJI_REP_XBS_DENORM;
        pji_rep_util.Log_Struct_Change_Event(l_wbs_version_id_tbl);
        -- where  PROJECT_ID in (select map.PROJECT_ID
        --                       from   PJI_PJP_PROJ_BATCH_MAP map
        --                       where  map.WORKER_ID = p_worker_id);

      end if;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM(p_worker_id);');

      commit;

    else -- online mode

       IF g_old_struct_version IS NOT NULL THEN
          l_wbs_version_id_tbl.EXTEND;
          l_wbs_version_id_tbl(1) :=g_old_struct_version ;
          IF g_new_struct_version IS NOT NULL  and  g_old_struct_version<>g_new_struct_version THEN
             l_wbs_version_id_tbl.EXTEND;
             l_wbs_version_id_tbl(2) :=g_new_struct_version ;
          END IF;
       else
            IF g_new_struct_version IS NOT NULL THEN
              l_wbs_version_id_tbl.EXTEND;
              l_wbs_version_id_tbl(1) :=g_new_struct_version ;
            END IF;
       END IF;

      -- online mode, refresh denorm table for a single WBS version ID

      l_count := 0;

      delete /*+ index(den PJI_XBS_DENORM_N2) */
      from  PJI_XBS_DENORM den
      where den.STRUCT_TYPE       in ('WBS', 'XBS') and
            den.SUP_PROJECT_ID    =  g_project_id and
            den.STRUCT_VERSION_ID in (g_old_struct_version,
                                      g_new_struct_version);

      l_count := l_count + sql%rowcount;

      delete /*+ index(den PJI_XBS_DENORM_N3) */
      from  PJI_XBS_DENORM den
      where den.STRUCT_TYPE    =  'PRG' and
            den.SUP_PROJECT_ID in (select prg.SUP_PROJECT_ID
                                   from   PJI_FP_AGGR_XBS_T prg
                                   where  prg.STRUCT_TYPE = 'PRG');

      l_count := l_count + sql%rowcount;

      insert into PJI_XBS_DENORM
      (
        STRUCT_TYPE,
        PRG_GROUP,
        STRUCT_VERSION_ID,
        SUP_PROJECT_ID,
        SUP_ID,
        SUP_EMT_ID,
        SUBRO_ID,
        SUB_ID,
        SUB_EMT_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_ROLLUP_ID,
        SUB_LEAF_FLAG,
        RELATIONSHIP_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select /*+ index(den PA_XBS_DENORM_N2) */
        den.STRUCT_TYPE,
        den.PRG_GROUP,
        den.STRUCT_VERSION_ID,
        den.SUP_PROJECT_ID,
        den.SUP_ID,
        den.SUP_EMT_ID,
        den.SUBRO_ID,
        den.SUB_ID,
        den.SUB_EMT_ID,
        den.SUP_LEVEL,
        den.SUB_LEVEL,
        den.SUB_ROLLUP_ID,
        den.SUB_LEAF_FLAG,
        den.RELATIONSHIP_TYPE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_XBS_DENORM den
      where
        den.STRUCT_TYPE       in ('WBS', 'XBS') and
        den.SUP_PROJECT_ID    =  g_project_id and
        den.STRUCT_VERSION_ID in (g_old_struct_version,
                                  g_new_struct_version)
      union all
      select /*+ index(den PA_XBS_DENORM_N3) */
        den.STRUCT_TYPE,
        den.PRG_GROUP,
        den.STRUCT_VERSION_ID,
        den.SUP_PROJECT_ID,
        den.SUP_ID,
        den.SUP_EMT_ID,
        den.SUBRO_ID,
        den.SUB_ID,
        den.SUB_EMT_ID,
        den.SUP_LEVEL,
        den.SUB_LEVEL,
        den.SUB_ROLLUP_ID,
        den.SUB_LEAF_FLAG,
        den.RELATIONSHIP_TYPE,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_XBS_DENORM den
      where
        den.STRUCT_TYPE    =  'PRG' and
        den.SUP_PROJECT_ID in (select prg.SUP_PROJECT_ID
                               from   PJI_FP_AGGR_XBS_T prg
                               where  prg.STRUCT_TYPE = 'PRG');

      if (l_count > 0) then

       --delete        from   PJI_REP_XBS_DENORM;
         pji_rep_util.Log_Struct_Change_Event(l_wbs_version_id_tbl);
        -- where  PROJECT_ID = g_project_id and
        --        OWNER_WBS_VERSION_ID in (g_old_struct_version,
        --                                 g_new_struct_version);

      end if;

      delete from PJI_XBS_DENORM_DELTA_T;

    end if;

  end UPDATE_XBS_DENORM;


  -- -----------------------------------------------------
  -- procedure UPDATE_RBS_DENORM
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- Called by RBS program
  --
  -- This API will be called for both online and bulk processing.
  --
  -- -----------------------------------------------------
  procedure UPDATE_RBS_DENORM (p_worker_id in number default null) is

    l_process           varchar2(30);
    l_extraction_type   varchar2(30);

    l_last_update_date  date;
    l_last_updated_by   number;
    l_creation_date     date;
    l_created_by        number;
    l_last_update_login number;

    l_fpm_upgrade       varchar2(30);

  begin

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    l_fpm_upgrade := PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE');

    if (p_worker_id is not null) then

      l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

      if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_RBS_DENORM(p_worker_id);')) then
        return;
      end if;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

      if (nvl(l_fpm_upgrade, 'P') <> 'C' and
          l_extraction_type = 'FULL') then

        insert into PJI_RBS_DENORM den_i
        (
          STRUCT_VERSION_ID,
          SUP_ID,
          SUBRO_ID,
          SUB_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_LEAF_FLAG,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          pa.STRUCT_VERSION_ID,
          pa.SUP_ID,
          pa.SUBRO_ID,
          pa.SUB_ID,
          pa.SUP_LEVEL,
          pa.SUB_LEVEL,
          pa.SUB_LEAF_FLAG,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_RBS_DENORM pa,
          PJI_RBS_DENORM pji
        where
          nvl(pa.STRUCT_VERSION_ID, -1)
                                   = nvl(pji.STRUCT_VERSION_ID (+), -1)     and
          nvl(pa.SUP_ID, -1)       = nvl(pji.SUP_ID (+), -1)                and
          nvl(pa.SUBRO_ID, -1)     = nvl(pji.SUBRO_ID (+), -1)              and
          nvl(pa.SUB_ID, -1)       = nvl(pji.SUB_ID (+), -1)                and
          nvl(pa.SUP_LEVEL, -1)    = nvl(pji.SUP_LEVEL (+), -1)             and
          nvl(pa.SUB_LEVEL, -1)    = nvl(pji.SUB_LEVEL (+), -1)             and
          nvl(pa.SUB_LEAF_FLAG, 'PJI$NULL')
                                   = nvl(pji.SUB_LEAF_FLAG (+), 'PJI$NULL') and
          pji.STRUCT_VERSION_ID    is null;

      elsif (l_extraction_type = 'INCREMENTAL' or
             (nvl(l_fpm_upgrade, 'P') = 'C' and
              l_extraction_type = 'FULL')) then

        /* Added for Bug 9099240 Start */
        if PA_RBS_MAPPING.g_max_rbs_id1 is not null or
           PA_RBS_MAPPING.g_max_rbs_id2 is not null then

          insert into PJI_RBS_DENORM
          (
            STRUCT_VERSION_ID,
            SUP_ID,
            SUBRO_ID,
            SUB_ID,
            SUP_LEVEL,
            SUB_LEVEL,
            SUB_LEAF_FLAG,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN
          )
        	select
        		interim.struct_version_id,
        		interim.sup_id,
        		interim.subro_id,
        		interim.sub_id,
        		interim.sup_level,
        		interim.sub_level,
        		interim.sub_leaf_flag,
        		l_last_update_date,
        		l_last_updated_by,
        		l_creation_date,
        		l_created_by,
        		l_last_update_login
        	from 	PJI_FP_AGGR_RBS	interim
        	where 	interim.worker_id = p_worker_id;

        else
        /* Added for Bug 9099240 End */

        delete from PJI_RBS_DENORM
        where STRUCT_VERSION_ID in (select log.EVENT_OBJECT
                                    from   PJI_PA_PROJ_EVENTS_LOG log
                                    where  log.WORKER_ID = p_worker_id and
                                           log.EVENT_TYPE = 'PJI_RBS_CHANGE');

        insert into PJI_RBS_DENORM
        (
          STRUCT_VERSION_ID,
          SUP_ID,
          SUBRO_ID,
          SUB_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_LEAF_FLAG,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_VERSION_ID,
          den.SUP_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_LEAF_FLAG,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_RBS_DENORM den,
          (
          select
            distinct
            log.EVENT_OBJECT
          from
            PJI_PA_PROJ_EVENTS_LOG log
          where
            log.WORKER_ID = p_worker_id and
            log.EVENT_TYPE in ('PJI_RBS_CHANGE')
          ) log
        where
          den.STRUCT_VERSION_ID = log.EVENT_OBJECT;

        end if; /* Added for Bug 9099240 */

      elsif (l_extraction_type = 'RBS') then

        delete from PJI_RBS_DENORM
        where STRUCT_VERSION_ID in (select
                                      decode(log.EVENT_TYPE,
                                             'RBS_PUSH',
                                               decode(invert.INVERT_ID,
                                                      1, log.EVENT_OBJECT,
                                                      2, log.ATTRIBUTE2),
                                             'RBS_DELETE', log.EVENT_OBJECT)
                                    from
                                      PJI_PA_PROJ_EVENTS_LOG log,
                                      (
                                        select 1 INVERT_ID from DUAL union all
                                        select 2 INVERT_ID from DUAL
                                      ) invert
                                    where
                                      log.WORKER_ID = p_worker_id and
                                      log.EVENT_TYPE in ('RBS_PUSH',
                                                         'RBS_DELETE'));

        insert into PJI_RBS_DENORM
        (
          STRUCT_VERSION_ID,
          SUP_ID,
          SUBRO_ID,
          SUB_ID,
          SUP_LEVEL,
          SUB_LEVEL,
          SUB_LEAF_FLAG,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
        )
        select
          den.STRUCT_VERSION_ID,
          den.SUP_ID,
          den.SUBRO_ID,
          den.SUB_ID,
          den.SUP_LEVEL,
          den.SUB_LEVEL,
          den.SUB_LEAF_FLAG,
          l_last_update_date,
          l_last_updated_by,
          l_creation_date,
          l_created_by,
          l_last_update_login
        from
          PA_RBS_DENORM den,
          (
          select
            distinct
            EVENT_OBJECT,
            ATTRIBUTE2
          from
            PJI_PA_PROJ_EVENTS_LOG
          where
            WORKER_ID = p_worker_id and
            EVENT_TYPE = 'RBS_PUSH'
          ) log
        where
          den.STRUCT_VERSION_ID = log.EVENT_OBJECT;

      end if;

      PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_RBS_DENORM(p_worker_id);');

      commit;

    else -- online mode

      /* Added for Bug 9099240 Start */
    if PA_RBS_MAPPING.g_max_rbs_id1 is not null or
       PA_RBS_MAPPING.g_max_rbs_id2 is not null then

      insert into PJI_RBS_DENORM
      (
        STRUCT_VERSION_ID,
        SUP_ID,
        SUBRO_ID,
        SUB_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_LEAF_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
    	select
    		interim.struct_version_id,
    		interim.sup_id,
    		interim.subro_id,
    		interim.sub_id,
    		interim.sup_level,
    		interim.sub_level,
    		interim.sub_leaf_flag,
    		l_last_update_date,
    		l_last_updated_by,
    		l_creation_date,
    		l_created_by,
    		l_last_update_login
    	from 	PJI_FP_AGGR_RBS_T	interim
    	where 	interim.worker_id = 1;        /* Modified for bug 9709502 */

    else
     /* Added for Bug 9099240 End */

      delete from PJI_RBS_DENORM
      where STRUCT_VERSION_ID = g_rbs_version;

      insert into PJI_RBS_DENORM
      (
        STRUCT_VERSION_ID,
        SUP_ID,
        SUBRO_ID,
        SUB_ID,
        SUP_LEVEL,
        SUB_LEVEL,
        SUB_LEAF_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      select
        den.STRUCT_VERSION_ID,
        den.SUP_ID,
        den.SUBRO_ID,
        den.SUB_ID,
        den.SUP_LEVEL,
        den.SUB_LEVEL,
        den.SUB_LEAF_FLAG,
        l_last_update_date,
        l_last_updated_by,
        l_creation_date,
        l_created_by,
        l_last_update_login
      from
        PA_RBS_DENORM den
      where
        den.STRUCT_VERSION_ID = g_rbs_version;

      -- delete from PJI_RBS_DENORM_DELTA_T;

      end if; /* Added for Bug 9099240 */

    end if;

    /* Added for Bug 9099240 Start */
    if l_extraction_type is null then
    	  PJI_PJP_SUM_DENORM.cleanup_rbs_denorm(p_worker_id,'ONLINE');
    else
    	  PJI_PJP_SUM_DENORM.cleanup_rbs_denorm(p_worker_id,l_extraction_type);
    end if;
    /* Added for Bug 9099240 End */

  end UPDATE_RBS_DENORM;


  -- -----------------------------------------------------
  -- procedure PROCESS_PENDING_EVENTS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PROCESS_PENDING_EVENTS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_EVENTS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    begin
    PJI_FM_XBS_ACCUM_MAINT.PROCESS_PENDING_EVENTS(l_return_status,
                                                  l_msg_data);
    exception when others then
      PJI_UTILS.WRITE2LOG('PROCESS_PENDING_EVENTS:' || SQLERRM);
    end;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_EVENTS(p_worker_id);');

    commit;

  end PROCESS_PENDING_EVENTS;


  -- -----------------------------------------------------
  -- procedure PROCESS_PENDING_PLAN_UPDATES
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure PROCESS_PENDING_PLAN_UPDATES (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_PLAN_UPDATES(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.PROCESS_PENDING_PLAN_UPDATES(l_extraction_type,
                                                       l_return_status,
                                                       l_msg_data);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_PLAN_UPDATES(p_worker_id);');

    commit;

  end PROCESS_PENDING_PLAN_UPDATES;


  -- -----------------------------------------------------
  -- procedure GET_PLANRES_ACTUALS
  --
  --   History
  --   26-JAN-2004  SASHAIK  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure GET_PLANRES_ACTUALS (p_worker_id in number) is

    cursor project_list (p_worker_id in number) is
    select
      ROWNUM,
      PROJECT_ID
    from
      PJI_PJP_PROJ_BATCH_MAP
    where
      WORKER_ID = p_worker_id             and
      PJI_PROJECT_STATUS = 'Y'            and
      rownum <= G_PROGRESS_COMMIT_SIZE;

    l_process         varchar2(30);
    l_extraction_type varchar2(30);
    l_extraction_type_wp varchar2(30);

    l_project_id_tbl  system.pa_num_tbl_type;
    l_prj_index       number;
    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_ret_msg_data        varchar2(2000);
    l_ret_status      varchar2(255);
    l_success         varchar2(1) := 'Y';
    l_err_msg1         VARCHAR2(100):= 'Error in PJI_PJP_SUM_ROLLUP.GET_PLANRES_ACTUALS -> PA_PROGRESS_PUB.GET_SUMMARIZED_ACTUALS';
    l_err_msg2         VARCHAR2(100):= 'Error in PJI_PJP_SUM_ROLLUP.GET_PLANRES_ACTUALS -> PJI_FM_PLAN_MAINT.GET_ACTUALS_SUMM';

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);
    l_ret_status := FND_API.G_RET_STS_SUCCESS;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.GET_PLANRES_ACTUALS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- Incr-Incr, Full-Initial, rbs-full, pr-full.
    SELECT DECODE(l_extraction_type, 'INCREMENTAL', 'INCREMENTAL', 'FULL', 'INITIAL', 'FULL')
    INTO   l_extraction_type_wp
    FROM   DUAL;

  LOOP

    l_project_id_tbl := system.pa_num_tbl_type();
    l_project_id_tbl.delete;
    l_prj_index := 1;

    for c in project_list(p_worker_id) loop
      l_project_id_tbl.extend(1);
      l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
      l_prj_index := l_prj_index + 1;
    end loop;

    EXIT WHEN l_project_id_tbl.COUNT = 0;

    if (l_prj_index > 1) then

      Pa_Task_Pub1.G_CALL_PJI_ROLLUP := 'N';

      savepoint S_PROGRESS_ROLLUP;

      PA_PROGRESS_PUB.GET_SUMMARIZED_ACTUALS(p_project_id_list => l_project_id_tbl,
                                             p_extraction_type => l_extraction_type_wp,
                                             p_plan_res_level  => 'Y',
                                             x_return_status   => l_return_status,
                                             x_msg_count       => l_msg_count,
                                             x_msg_data        => l_msg_data);


      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      FND_MESSAGE.SET_NAME('PA', l_msg_data);
      l_ret_msg_data := FND_MESSAGE.GET;
        rollback to S_PROGRESS_ROLLUP;
        l_success := 'Y';
      end if;

      -- l_success := 'N'; -- NOTE!!! This condition is present only to simulate failure
                        --   condition. It is to be commented at all times in checked
                        --   in code.

      forall j in 1..l_project_id_tbl.COUNT
        update PJI_PJP_PROJ_BATCH_MAP
        set pji_project_status =
                     decode(l_return_status
                          , FND_API.G_RET_STS_SUCCESS
                          , 'S' -- Success
                          , 'S' -- keeping this for future requirement Pending processing as actuals did not get returned for this project.
                          ),
        act_err_msg=  decode(l_return_status
                          , FND_API.G_RET_STS_SUCCESS
                          , act_err_msg
                          , l_ret_msg_data
                          )
        where WORKER_ID  = p_worker_id and
              project_id = l_project_id_tbl(j);

      COMMIT;

    end if;

  END LOOP;

  if l_success <> 'Y' then

      update pji_pjp_proj_batch_map -- Process the pending projects in the next sumz run.
        set pji_project_status = 'Y'
      where
        WORKER_ID  = p_worker_id and
        pji_project_status = 'P';

      commit;
      dbms_standard.raise_application_error(-20110, l_err_msg1);

  end if;

  -- Reset flags. 'N' means actuals don't exist for this project.
  -- Reset flags for only those projects for which actuals exist.
  update pji_pjp_proj_batch_map
     set pji_project_status = 'Y'
  where
     WORKER_ID  = p_worker_id and
     pji_project_status <> 'N';


  PJI_FM_PLAN_MAINT.GET_ACTUALS_SUMM (
      p_extr_type       => l_extraction_type
    , x_return_status   => l_return_status
    , x_msg_code        => l_msg_data ) ;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    dbms_standard.raise_application_error(-20120, l_err_msg2);
  END IF;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.GET_PLANRES_ACTUALS(p_worker_id);');

    commit;

  end GET_PLANRES_ACTUALS;


  -- -----------------------------------------------------
  -- procedure GET_TASK_ROLLUP_ACTUALS
  --
  --   History
  --   26-JAN-2004  SASHAIK  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure GET_TASK_ROLLUP_ACTUALS (p_worker_id in number) is

    cursor project_list (p_worker_id in number) is
    SELECT nvl(ver.PRG_LEVEL,1) PRG_LEVEL,
           ver.PROJECT_ID
    FROM
           pji_pjp_proj_batch_map   map,
           pa_proj_element_versions ver,
           pa_proj_structure_types typ,
           pa_proj_elem_ver_structure str
    WHERE
           typ.STRUCTURE_TYPE_ID         = 1
       AND typ.PROJ_ELEMENT_ID           = str.PROJ_ELEMENT_ID
       AND str.LATEST_EFF_PUBLISHED_FLAG = 'Y'
       AND str.ELEMENT_VERSION_ID        = ver.ELEMENT_VERSION_ID
       AND str.PROJ_ELEMENT_ID           = ver.PROJ_ELEMENT_ID
       AND str.PROJECT_ID                = ver.PROJECT_ID
       AND ver.OBJECT_TYPE               = 'PA_STRUCTURES'
       AND ver.PROJECT_ID                = map.PROJECT_ID
       AND map.WORKER_ID                 = p_worker_id
       AND map.PJI_PROJECT_STATUS        = 'Y'
       ORDER BY ver.PRG_LEVEL DESC NULLS FIRST;

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_project_id_tbl  system.pa_num_tbl_type;
    l_prg_level_tbl   system.pa_num_tbl_type;
    l_prj_index       number;
    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin


    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.GET_TASK_ROLLUP_ACTUALS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    if (l_extraction_type = 'FULL' or
        l_extraction_type = 'INCREMENTAL') then

      update PJI_PJP_PROJ_BATCH_MAP
      set    PJI_PROJECT_STATUS = 'Y'
      where  WORKER_ID = p_worker_id and
             PJI_PROJECT_STATUS is null and
             PROJECT_ID in (select distinct
                                   PROJECT_ID
                            from   PJI_FP_AGGR_PJP1
                            where  WORKER_ID = p_worker_id
                            and    PLAN_VERSION_ID = -1);

    end if;

    l_project_id_tbl := system.pa_num_tbl_type();
    l_project_id_tbl.delete;
    l_prg_level_tbl  := system.pa_num_tbl_type();
    l_prg_level_tbl.delete;
    l_prj_index := 1;

    for c in project_list(p_worker_id) loop
      l_project_id_tbl.extend(1);
      l_project_id_tbl(l_prj_index) := c.PROJECT_ID;
      l_prg_level_tbl.extend(1);
      l_prg_level_tbl(l_prj_index) := c.PRG_LEVEL;
      l_prj_index := l_prj_index + 1;
    end loop;



    if (l_prj_index > 1) then

      PA_PROGRESS_PUB.GET_SUMMARIZED_ACTUALS(p_project_id_list => l_project_id_tbl,
                                             p_extraction_type => l_extraction_type,
                                             p_plan_res_level  => 'N',
                                             p_proj_pgm_level  => l_prg_level_tbl,
                                             x_return_status   => l_return_status,
                                             x_msg_count       => l_msg_count,
                                             x_msg_data        => l_msg_data);


      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        dbms_standard.raise_application_error(-20130, 'Error in PJI_PJP_SUM_ROLLUP.GET_TASK_ROLLUP_ACTUALS -> PA_PROGRESS_PUB.GET_SUMMARIZED_ACTUALS');
      end if;

    end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.GET_TASK_ROLLUP_ACTUALS(p_worker_id);');

    commit;

  end GET_TASK_ROLLUP_ACTUALS;


  -- -----------------------------------------------------
  -- procedure UNLOCK_ALL_HEADERS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure UNLOCK_ALL_HEADERS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_msg_code        varchar2(255);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UNLOCK_ALL_HEADERS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    update PJI_PJP_WBS_HEADER
    set    LOCK_FLAG = null
    where  LOCK_FLAG is not null
      and  project_id IN
           ( SELECT project_id
             FROM   pji_pjp_proj_batch_map
             WHERE  worker_id = p_worker_id );

    -- SELECT DECODE(l_extraction_type, 'PARTIAL', 'PLANTYPE', l_extraction_type)
    -- INTO   l_extraction_type
    -- FROM   DUAL ;

    Pji_Fm_Plan_Maint_Pvt.OBTAIN_RELEASE_LOCKS (
      p_context        => l_extraction_type
    , p_lock_mode      => NULL
    , x_return_status  => l_return_status
    , x_msg_code       => l_msg_code
    );

    PJI_FM_PLAN_MAINT_PVT.DELETE_PLAN_LINES ( x_return_status => l_return_status );

   -- Pji_Fm_Plan_Maint_Pvt.MARK_EXTRACTED_PLANS('SEC');
 --   Back to CREATE_SECONDARY_PVT due to issue 5155692

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UNLOCK_ALL_HEADERS(p_worker_id);');

    commit;

  end UNLOCK_ALL_HEADERS;


  -- -----------------------------------------------------
  -- procedure EXTRACT_FIN_PLAN_VERS_BULK
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure EXTRACT_FIN_PLAN_VERS_BULK (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_FIN_PLAN_VERS_BULK(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.EXTRACT_FIN_PLAN_VERS_BULK(p_slice_type => 'PRI');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_FIN_PLAN_VERS_BULK(p_worker_id);');

    commit;

  end EXTRACT_FIN_PLAN_VERS_BULK;


  -- -----------------------------------------------------
  -- procedure POPULATE_WBS_HDR
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure POPULATE_WBS_HDR (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_WBS_HDR(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.POPULATE_WBS_HDR;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_WBS_HDR(p_worker_id);');

    commit;

  end POPULATE_WBS_HDR;


  -- -----------------------------------------------------
  -- procedure UPDATE_WBS_HDR
  --
  --   History
  --   19-MAR-2004  SASHAIK Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure UPDATE_WBS_HDR (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_WBS_HDR(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    -- PJI_FM_PLAN_MAINT_PVT.UPDATE_WBS_HDR;
    PJI_FM_PLAN_MAINT_PVT.UPDATE_WBS_HDR(p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.UPDATE_WBS_HDR(p_worker_id);');

    commit;

  end UPDATE_WBS_HDR;


  -- -----------------------------------------------------
  -- procedure POPULATE_RBS_HDR
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure POPULATE_RBS_HDR (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_RBS_HDR(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.POPULATE_RBS_HDR;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.POPULATE_RBS_HDR(p_worker_id);');

    commit;

  end POPULATE_RBS_HDR;


  -- -----------------------------------------------------
  -- procedure EXTRACT_PLAN_AMOUNTS_PRIRBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure EXTRACT_PLAN_AMOUNTS_PRIRBS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_AMOUNTS_PRIRBS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.EXTRACT_PLAN_AMOUNTS_PRIRBS;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_AMOUNTS_PRIRBS(p_worker_id);');

    commit;

  end EXTRACT_PLAN_AMOUNTS_PRIRBS;


  -- -----------------------------------------------------
  -- procedure ROLLUP_FPR_RBS_T_SLICE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure ROLLUP_FPR_RBS_T_SLICE (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_T_SLICE(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.ROLLUP_FPR_RBS_T_SLICE;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_T_SLICE(p_worker_id);');

    commit;

  end ROLLUP_FPR_RBS_T_SLICE;


  -- -----------------------------------------------------
  -- procedure CREATE_FP_PA_PRI_ROLLUP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure CREATE_FP_PA_PRI_ROLLUP (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_PA_PRI_ROLLUP(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_PA_PRI_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_PA_PRI_ROLLUP(p_worker_id);');

    commit;

  end CREATE_FP_PA_PRI_ROLLUP;


  -- -----------------------------------------------------
  -- procedure CREATE_FP_GL_PRI_ROLLUP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure CREATE_FP_GL_PRI_ROLLUP (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_GL_PRI_ROLLUP(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_GL_PRI_ROLLUP;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_GL_PRI_ROLLUP(p_worker_id);');

    commit;

  end CREATE_FP_GL_PRI_ROLLUP;


  -- -----------------------------------------------------
  -- procedure CREATE_FP_ALL_PRI_ROLLUP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure CREATE_FP_ALL_PRI_ROLLUP (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_ALL_PRI_ROLLUP(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_ALL_T_PRI_ROLLUP('G');

    PJI_FM_PLAN_CAL_RLPS.CREATE_FP_ALL_T_PRI_ROLLUP('P');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CREATE_FP_ALL_PRI_ROLLUP(p_worker_id);');

    commit;

  end CREATE_FP_ALL_PRI_ROLLUP;


  -- -----------------------------------------------------
  -- procedure INSERT_INTO_FP_FACT
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure INSERT_INTO_FP_FACT (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_INTO_FP_FACT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.INSERT_INTO_FP_FACT;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.INSERT_INTO_FP_FACT(p_worker_id);');

    commit;

  end INSERT_INTO_FP_FACT;


  -- -----------------------------------------------------
  -- procedure MARK_EXTRACTED_PLANS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Used solely for FP.M Upgrade
  --
  -- -----------------------------------------------------
  procedure MARK_EXTRACTED_PLANS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PLANS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.MARK_EXTRACTED_PLANS('PRI');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PLANS(p_worker_id);');

    commit;

  end MARK_EXTRACTED_PLANS;


  procedure REMAP_RBS_TXN_ACCUM_HDRS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.REMAP_RBS_TXN_ACCUM_HDRS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');
    -- Extraction type is not needed for this step.
    -- Retaining it to maintain coding style as well as for potential future use.

    PJI_FM_XBS_ACCUM_UTILS.REMAP_RBS_TXN_ACCUM_HDRS (
          x_return_status => l_return_status
         ,x_msg_data      => l_msg_data
         ,x_msg_count     => l_msg_count );

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.REMAP_RBS_TXN_ACCUM_HDRS(p_worker_id);');

    commit;

  end REMAP_RBS_TXN_ACCUM_HDRS ;


  procedure RETRIEVE_OVERRIDDEN_WP_ETC (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.RETRIEVE_OVERRIDDEN_WP_ETC(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');
    -- Extraction type is not needed for this step.
    -- Retaining it to maintain coding style as well as for potential future use.

    PJI_FM_PLAN_MAINT_PVT.RETRIEVE_OVERRIDDEN_WP_ETC;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.RETRIEVE_OVERRIDDEN_WP_ETC(p_worker_id);');

    commit;

  end RETRIEVE_OVERRIDDEN_WP_ETC ;


  procedure EXTRACT_PLAN_ETC_PRIRBS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status varchar2(255);
    l_msg_count     number;
    l_msg_data      varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_ETC_PRIRBS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');
    -- Extraction type is not needed for this step.
    -- Retaining it to maintain coding style as well as for potential future use.

    PJI_FM_PLAN_MAINT_PVT.EXTRACT_PLAN_ETC_PRIRBS(p_slice_type => 'SEC');

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.EXTRACT_PLAN_ETC_PRIRBS(p_worker_id);');

    commit;

  end EXTRACT_PLAN_ETC_PRIRBS ;


  -- -----------------------------------------------------
  -- procedure CLEANUP
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure CLEANUP (p_worker_id in number default null) is

    l_process varchar2(30);
    l_schema  varchar2(30);

  begin

    if (p_worker_id is not null) then

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

/* 5755229 Because No step entry in the delete process FPM Upgrade
    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP(p_worker_id);')) then -- Bug#5171542
    return;
    end if;
5755229  */

    l_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJP_RMAP_FPR',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PJP_RMAP_ACR',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_AGGR_PJP0',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_AC_AGGR_PJP0',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_CUST_PJP0',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_AC_CUST_PJP0',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FM_EXTR_PLNVER4',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_AGGR_PJP1',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_AC_AGGR_PJP1',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_AGGR_XBS',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_AGGR_RBS',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_XBS_DENORM_DELTA',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_RBS_DENORM_DELTA',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_FP_RMAP_FPR',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_AC_RMAP_ACR',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.TRUNC_INT_TABLE(l_schema,
                                     'PJI_PA_PROJ_EVENTS_LOG',
                                     'PARTITION',
                                     'P' || p_worker_id);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.CLEANUP(p_worker_id);'); -- Bug#5171542
    commit;

    else -- online mode

      delete from PJI_XBS_DENORM_DELTA_T;

      delete from PJI_FP_AGGR_PJP1_T;

      delete from PJI_AC_AGGR_PJP1_T;

    end if;

  end CLEANUP;
-- bug 6520936
Procedure MERGE_INTO_FP_FACTS (p_worker_id in number) is

    l_process         varchar2(30);
    l_extraction_type varchar2(30);

    l_return_status   varchar2(255);
    l_msg_count       number;
    l_msg_data        varchar2(2000);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_ROLLUP.MERGE_INTO_FP_FACT(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');

    PJI_FM_PLAN_MAINT_PVT.MERGE_INTO_FP_FACTS;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_ROLLUP.MERGE_INTO_FP_FACT(p_worker_id);');

    commit;

  end MERGE_INTO_FP_FACTS;
-- bug 6520936


end PJI_PJP_SUM_ROLLUP;

/
