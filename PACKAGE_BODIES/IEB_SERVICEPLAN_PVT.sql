--------------------------------------------------------
--  DDL for Package Body IEB_SERVICEPLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEB_SERVICEPLAN_PVT" AS
/* $Header: IEBSVPB.pls 115.10 2004/02/13 21:51:58 gpagadal noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEB_ServicePlan_PVT
-- Purpose
--    To provide easy to use apis for Blending admin.
-- History
--    02-July-2003     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
PROCEDURE Create_ServicePlan(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id OUT NOCOPY NUMBER,
                       p_name IN VARCHAR2,
                       p_desc IN VARCHAR2,
                       p_direction IN VARCHAR2,
                       p_media_type_id IN NUMBER
                       )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_svc_plan_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;
    l_temp_str varchar2(80);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;


    select IEB_SVC_PLAN_S1.nextval into l_svc_plan_id from dual;

    EXECUTE immediate 'INSERT INTO  IEB_SERVICE_PLANS '||
    '(   SVCPLN_ID, ' ||
    '    CREATED_BY, ' ||
    '    CREATION_DATE, ' ||
    '    LAST_UPDATED_BY,' ||
    '    LAST_UPDATE_DATE, ' ||
    '    LAST_UPDATE_LOGIN, ' ||
    '    SERVICE_PLAN_NAME, ' ||
    '    DIRECTION, ' ||
    '    TREATMENT, ' ||
    '    DESCRIPTION, ' ||
    '    MEDIA_TYPE_ID, ' ||
    '  OBJECT_VERSION_NUMBER,' ||
    '  SECURITY_GROUP_ID ' ||
    ' )VALUES ' ||
    '(:1 ,' ||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9, '||
    ' :10, '||
    ' :11, '||
    ' :12, '||
    ' :13 '||
    ') '
     USING  l_svc_plan_id,
       FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        LTRIM(RTRIM(p_name)),
        p_direction,
        l_temp_str,
        LTRIM(RTRIM(p_desc)),
        p_media_type_id,
        0,
        0;



    insert into IEB_SERVICE_PLANS_TL (
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        SERVICE_PLAN_ID,
        OBJECT_VERSION_NUMBER,
        DESCRIPTION,
        LAST_UPDATE_LOGIN,
        PLAN_NAME,
        LANGUAGE,
        SOURCE_LANG
    ) select
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        l_svc_plan_id,
        0,
        LTRIM(RTRIM(p_desc)),
        FND_GLOBAL.LOGIN_ID,
        LTRIM(RTRIM(p_name)),
        L.LANGUAGE_CODE,
        userenv('LANG')
        FROM FND_LANGUAGES L
        where L.INSTALLED_FLAG in ('I', 'B')
        and not exists
        (select NULL
        from IEB_SERVICE_PLANS_TL T
        where T.SERVICE_PLAN_ID = l_svc_plan_id
        and T.LANGUAGE = L.LANGUAGE_CODE);




p_plan_id := l_svc_plan_id;
COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_ServicePlan;
--===================================================================
-- NAME
--   Create_IOCoverages
--
-- PURPOSE
--    Private api to create coverages.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create coverages
--
--
-- HISTORY
--   30-July-2003     GPAGADAL   Created

--===================================================================

PROCEDURE Create_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEB_SERVICE_COVERAGES_OBJ
                                ) as


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_svc_plan_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_isvccov_id IEB_INB_SVC_COVERAGES.ISVCCOV_ID%type;

    l_osvccov_id IEB_OUTB_SVC_COVERAGES.OSVCCOV_ID%type;

    l_begin_time IEB_OUTB_SVC_COVERAGES.BEGIN_TIME_HHMM%type;

    l_end_time IEB_OUTB_SVC_COVERAGES.END_TIME_HHMM%type;

    l_minagent IEB_SERVICE_LEVELS_B.MIN_AGENTS%type;

    l_quota IEB_SERVICE_LEVELS_B.HOURLY_QUOTA%type;

    l_level_id IEB_SERVICE_LEVELS_B.SERVICE_LEVEL_ID%type;

    l_max_wait_time IEB_SERVICE_LEVELS_B.MAX_WAIT_TIME%type;

    l_percentage IEB_SERVICE_LEVELS_B.GOAL_PERCENT%type;

    l_time_threshold IEB_SERVICE_LEVELS_B.GOAL_TIME%type;

    l_reroute_time IEB_SERVICE_LEVELS_B.REROUTE_TIME%type;

    l_reroute_war_time IEB_SERVICE_LEVELS_B.REROUTE_WARNING_TIME%type;
    l_temp_str varchar2(80);


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;

    if ( rec_obj.direction = 'O') then

                select b.HOURLY_QUOTA, b.MIN_AGENTS
             into l_quota, l_minagent from IEB_SERVICE_LEVELS_B b, IEB_SERVICE_LEVELS_tl tl
             where b.SERVICE_LEVEL_ID = tl.SERVICE_LEVEL_ID
             and tl.LANGUAGE = l_language
             and b.SERVICE_LEVEL_ID = rec_obj.slevel_id;

        select IEB_SVC_COV_S2.nextval into l_osvccov_id from dual;

        if l_quota IS NULL  then
            l_quota :=0;
        end if;
        if l_minagent IS NULL  then
            l_minagent := 0;
        end if;

        l_quota := ((rec_obj.end_time - rec_obj.start_time)/100)*l_quota;

        EXECUTE immediate 'INSERT into IEB_OUTB_SVC_COVERAGES '||
        ' ( OSVCCOV_ID, '||
        ' CREATED_BY,  '||
        ' CREATION_DATE, '||
        ' LAST_UPDATED_BY, '||
        ' LAST_UPDATE_DATE, '||
        ' LAST_UPDATE_LOGIN,'||
        ' SCHEDULE_TYPE, '||
        ' REGULAR_SCHD_DAY, '||
        ' SPEC_SCHD_DATE, '||
        ' BEGIN_TIME_HHMM, '||
        ' END_TIME_HHMM, '||
        ' MIN_AGENT, '||
        ' QUOTA, '||
        ' SVCPLN_SVCPLN_ID,'||
        ' OBJECT_VERSION_NUMBER, '||
        ' SECURITY_GROUP_ID, '||
        ' SERVICE_LEVEL_ID'||
        ' ) values ( '||
        ' :1, '||
        ' :2, '||
        ' :3, '||
        ' :4, '||
        ' :5, '||
        ' :6, '||
        ' :7, '||
        ' :8, '||
        ' :9, '||
        ' :10, '||
        ' :11, '||
        ' :12, '||
        ' :13, '||
        ' :14, '||
        ' :15, '||
        ' :16, '||
        ' :17 '||
        ' ) '
        USING   l_osvccov_id,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID,
                rec_obj.schedule_type,
                rec_obj.regular_schd_day,
                rec_obj.spec_schd_date,
                rec_obj.start_time,
                rec_obj.end_time,
                l_minagent,
                l_quota,
                rec_obj.splan_id,
                0,
                0,
                rec_obj.slevel_id;

elsif (rec_obj.direction = 'I') then

    select  b.MIN_AGENTS,b.GOAL_PERCENT, b.GOAL_TIME,
            b.MAX_WAIT_TIME,b.REROUTE_TIME, b.REROUTE_WARNING_TIME
             into l_minagent, l_percentage,
            l_time_threshold, l_max_wait_time, l_reroute_time,
            l_reroute_war_time
    from IEB_SERVICE_LEVELS_B b, IEB_SERVICE_LEVELS_tl tl
    where b.SERVICE_LEVEL_ID = tl.SERVICE_LEVEL_ID
        and tl.LANGUAGE = l_language
        and b.SERVICE_LEVEL_ID = rec_obj.slevel_id;


    select IEB_SVC_COV_S1.nextval into l_isvccov_id from dual;

    if l_minagent IS NULL  then
        l_minagent := 0;
    end if;
    if l_percentage IS NULL then
        l_percentage :=0;
    end if;
    if l_time_threshold IS NULL then
        l_time_threshold := 0;
    end if;

    if l_max_wait_time IS NULL then
        l_max_wait_time := 0;
    end if;
    if l_reroute_time IS NULL  then
        l_reroute_time :=1;
    end if;
    if l_reroute_war_time IS NULL  then
        l_reroute_war_time := 1;
    end if;


    EXECUTE immediate ' INSERT INTO IEB_INB_SVC_COVERAGES '||
    ' ( ISVCCOV_ID, '||
    '    CREATED_BY, '||
    '    CREATION_DATE, '||
    '    LAST_UPDATED_BY, '||
    '    LAST_UPDATE_DATE, '||
    '    LAST_UPDATE_LOGIN, '||
    '    SCHEDULE_TYPE, '||
    '    REGULAR_SCHD_DAY, '||
    '    SPEC_SCHD_DATE, '||
    '    BEGIN_TIME_HHMM, '||
    '    END_TIME_HHMM, '||
    '    MIN_AGENT, '||
    '    PERCENTAGE, '||
    '    TIME_THRESHOLD, '||
    '    MAX_WAIT_TIME, '||
    '    REROUTE_TIME, '||
    '    REROUTE_WARNING_TIME, '||
    '    SVCPLN_SVCPLN_ID, '||
    '    OBJECT_VERSION_NUMBER, '||
    '    SECURITY_GROUP_ID, '||
    '    SERVICE_LEVEL_ID '||
    '    ) values ( '||
    ' :1, '||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9, '||
    ' :10, '||
    ' :11, '||
    ' :12, '||
    ' :13, '||
    ' :14, '||
    ' :15, '||
    ' :16, '||
    ' :17, '||
    ' :18, '||
    ' :19, '||
    ' :20, '||
    ' :21 '||
    ' ) '
    USING   l_isvccov_id,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
            rec_obj.schedule_type,
            rec_obj.regular_schd_day,
            rec_obj.spec_schd_date,
            rec_obj.start_time,
            rec_obj.end_time,
            l_minagent,
            l_percentage,
            l_time_threshold,
            l_max_wait_time,
            l_reroute_time,
            l_reroute_war_time,
            rec_obj.splan_id,
            0,
            0,
            rec_obj.slevel_id;
    end if;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_IOCoverages;
--===================================================================
-- NAME
--   Update_IOCoverages
--
-- PURPOSE
--    Private api to create regional plan.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create regional plan
--
--
-- HISTORY
--   30-July-2003     GPAGADAL   Created

--===================================================================

PROCEDURE Update_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEB_SERVICE_COVERAGES_OBJ
                                )as


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_svc_plan_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_isvccov_id IEB_INB_SVC_COVERAGES.ISVCCOV_ID%type;

    l_osvccov_id IEB_OUTB_SVC_COVERAGES.OSVCCOV_ID%type;

    l_begin_time IEB_OUTB_SVC_COVERAGES.BEGIN_TIME_HHMM%type;

    l_end_time IEB_OUTB_SVC_COVERAGES.END_TIME_HHMM%type;

    l_minagent IEB_SERVICE_LEVELS_B.MIN_AGENTS%type;

    l_quota IEB_SERVICE_LEVELS_B.HOURLY_QUOTA%type;

    l_level_id IEB_SERVICE_LEVELS_B.SERVICE_LEVEL_ID%type;

    l_max_wait_time IEB_SERVICE_LEVELS_B.MAX_WAIT_TIME%type;

    l_percentage IEB_SERVICE_LEVELS_B.GOAL_PERCENT%type;

    l_time_threshold IEB_SERVICE_LEVELS_B.GOAL_TIME%type;

    l_reroute_time IEB_SERVICE_LEVELS_B.REROUTE_TIME%type;

    l_reroute_war_time IEB_SERVICE_LEVELS_B.REROUTE_WARNING_TIME%type;
    l_temp_str varchar2(80);


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;
    if ( rec_obj.direction = 'O') then

        select b.HOURLY_QUOTA, b.MIN_AGENTS
        into l_quota, l_minagent from IEB_SERVICE_LEVELS_B b, IEB_SERVICE_LEVELS_tl tl
        where b.SERVICE_LEVEL_ID = tl.SERVICE_LEVEL_ID
        and tl.LANGUAGE = l_language
        and b.SERVICE_LEVEL_ID = rec_obj.slevel_id;

        l_quota := ((rec_obj.end_time - rec_obj.start_time)/100)*l_quota;


        if(rec_obj.schedule_type = 'R') then

            update IEB_OUTB_SVC_COVERAGES
            set BEGIN_TIME_HHMM = rec_obj.start_time,
                END_TIME_HHMM = rec_obj.end_time,
                MIN_AGENT = l_minagent,
                QUOTA = l_quota,
                SERVICE_LEVEL_ID = rec_obj.slevel_id,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            where SVCPLN_SVCPLN_ID = rec_obj.splan_id
                and SCHEDULE_TYPE = rec_obj.schedule_type
                and REGULAR_SCHD_DAY = rec_obj.regular_schd_day;

        elsif(rec_obj.schedule_type ='S') then

            update IEB_OUTB_SVC_COVERAGES
            set BEGIN_TIME_HHMM = rec_obj.start_time,
                END_TIME_HHMM = rec_obj.end_time,
                MIN_AGENT = l_minagent,
                QUOTA = l_quota,
                SERVICE_LEVEL_ID = rec_obj.slevel_id,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            where SVCPLN_SVCPLN_ID = rec_obj.splan_id
                and SCHEDULE_TYPE = rec_obj.schedule_type
                and SPEC_SCHD_DATE = rec_obj.spec_schd_date;
        end if;

    elsif (rec_obj.direction = 'I') then

        select  b.MIN_AGENTS,b.GOAL_PERCENT, b.GOAL_TIME,
                b.MAX_WAIT_TIME,b.REROUTE_TIME, b.REROUTE_WARNING_TIME
                 into l_minagent, l_percentage,
                l_time_threshold, l_max_wait_time, l_reroute_time,
                l_reroute_war_time
        from IEB_SERVICE_LEVELS_B b, IEB_SERVICE_LEVELS_tl tl
        where b.SERVICE_LEVEL_ID = tl.SERVICE_LEVEL_ID
            and tl.LANGUAGE = l_language
            and b.SERVICE_LEVEL_ID = rec_obj.slevel_id;

        if( l_reroute_time = null) then
            l_reroute_time :=1;
        end if;
        if( l_reroute_war_time = null) then
            l_reroute_war_time := 1;
        end if;

        if(rec_obj.schedule_type = 'R') then

            update IEB_INB_SVC_COVERAGES
            set BEGIN_TIME_HHMM = rec_obj.start_time,
                END_TIME_HHMM = rec_obj.end_time,
                MIN_AGENT = l_minagent,
                PERCENTAGE = l_percentage,
                TIME_THRESHOLD = l_time_threshold,
                MAX_WAIT_TIME = l_max_wait_time,
                REROUTE_TIME = l_reroute_time,
                REROUTE_WARNING_TIME = l_reroute_war_time,
                SERVICE_LEVEL_ID = rec_obj.slevel_id,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            where SVCPLN_SVCPLN_ID = rec_obj.splan_id
                and SCHEDULE_TYPE = rec_obj.schedule_type
                and REGULAR_SCHD_DAY = rec_obj.regular_schd_day;

        elsif(rec_obj.schedule_type ='S') then

            update IEB_INB_SVC_COVERAGES
            set BEGIN_TIME_HHMM = rec_obj.start_time,
                END_TIME_HHMM = rec_obj.end_time,
                MIN_AGENT = l_minagent,
                PERCENTAGE = l_percentage,
                TIME_THRESHOLD = l_time_threshold,
                MAX_WAIT_TIME = l_max_wait_time,
                REROUTE_TIME = l_reroute_time,
                REROUTE_WARNING_TIME = l_reroute_war_time,
                SERVICE_LEVEL_ID = rec_obj.slevel_id,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
            where SVCPLN_SVCPLN_ID = rec_obj.splan_id
                and SCHEDULE_TYPE = rec_obj.schedule_type
                and SPEC_SCHD_DATE = rec_obj.spec_schd_date;
        end if;
   end if;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Update_IOCoverages;
--===================================================================
-- NAME
--   Create_Classification
--
-- PURPOSE
--    Private api to create classification.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create classification
--
--
-- HISTORY
--   31-July-2003     GPAGADAL   Created

--===================================================================



PROCEDURE Create_Classification(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_cat_id in  NUMBER,
                       p_classfn_name in VARCHAR2
                       )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_wbscrule_id  IEB_WB_SVC_CAT_RULES.WBSCRULE_ID%type;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;

    select IEB_SVC_CAT_RULES_S1.nextval into l_wbscrule_id from dual;

    EXECUTE immediate 'INSERT into IEB_WB_SVC_CAT_RULES '||
        '(WBSCRULE_ID, '||
        ' RULE_TYPE, '||
        ' CREATED_BY, '||
        ' CREATION_DATE, '||
        ' LAST_UPDATED_BY, '||
        ' LAST_UPDATE_DATE, '||
        ' LAST_UPDATE_LOGIN, '||
        ' CLASSIFICATION, '||
        ' SKILL_INCLUDED_Y_N, '||
        ' DESCRIPTION, '||
        ' WBSC_WBSC_ID, '||
        ' OBJECT_VERSION_NUMBER, '||
        ' SECURITY_GROUP_ID '||
        ' ) VALUES '||
        ' ( :1,' ||
        ' :2, '||
        ' :3, '||
        ' :4, '||
        ' :5, '||
        ' :6, '||
        ' :7, '||
        ' :8, '||
        ' :9, '||
        ' :10, '||
        ' :11, '||
        ' :12, '||
        ' :13 '||
        ' ) '
        USING   l_wbscrule_id,
                'C',
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID,
                p_classfn_name,
                'N',
                p_classfn_name,
                p_svc_cat_id,
                0,
                0;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


END   Create_Classification;

--===================================================================
-- NAME
--   Create_CampCategory
--
-- PURPOSE
--    Private api to create category
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create category
--
-- HISTORY
--   1-August-2003     GPAGADAL   Created

--===================================================================


PROCEDURE Create_CampCategory(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_name in VARCHAR2,
                       p_media_type_id in NUMBER
                        )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_wbsc_id  IEB_WB_SVC_CATS.WBSC_ID%type;

    l_media_type IEB_SVC_CAT_TEMPS_B.media_type%type;

    l_parent_id IEB_WB_SVC_CATS.parent_id%type;

    l_cpn_svr_name IEB_WB_SVC_CATS.campaign_server_name%type;

    l_svr_cat_name IEB_WB_SVC_CATS.service_category_name%type;

    l_time_stamp NUMBER(15);

    --create cursor to get the all servers
    cursor c_cur is
          select s.WBSVR_ID, s.WB_SERVER_NAME, s.IEO_SERVER_ID  from IEB_WB_SERVERS s;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;

    select  media_type into l_media_type
     from IEB_SVC_CAT_TEMPS_B where media_type_id = p_media_type_id;

    for c_rec in c_cur LOOP

        select parent_id into l_parent_id
        from IEB_WB_SVC_CATS where media_type_id= p_media_type_id
        and wbsvr_wbsvr_id= c_rec.WBSVR_ID
        and default_flag= 'Y';

        SELECT DBMS_UTILITY.GET_TIME INTO l_time_stamp FROM dual;

        l_svr_cat_name := p_svc_plan_id||p_name||to_char(l_time_stamp);


        select IEB_SVC_CATS_S1.nextval into l_wbsc_id from dual;

        EXECUTE immediate 'INSERT into IEB_WB_SVC_CATS '||
        ' (WBSC_ID,  '||
        ' CREATED_BY,  '||
        ' CREATION_DATE, '||
        ' LAST_UPDATED_BY,  '||
        ' LAST_UPDATE_DATE, '||
        ' LAST_UPDATE_LOGIN, '||
        ' SERVICE_CATEGORY_NAME, '||
        ' CAMPAIGN_SERVER_NAME, '||
        ' ACTIVE_Y_N, '||
        ' MEDIA_TYPE, '||
        ' PRIORITY, '||
        ' DEPTH, '||
        ' WBSVR_WBSVR_ID, '||
        ' PARENT_ID, '||
        ' SVCPLN_SVCPLN_ID, '||
        ' OBJECT_VERSION_NUMBER, '||
        ' SECURITY_GROUP_ID, '||
        ' MEDIA_TYPE_ID'||
        ' ) values ('||
        ' :1, '||
        ' :2, '||
        ' :3, '||
        ' :4, '||
        ' :5, '||
        ' :6, '||
        ' :7, '||
        ' :8, '||
        ' :9, '||
        ' :10, '||
        ' :11, '||
        ' :12, '||
        ' :13, '||
        ' :14, '||
        ' :15, '||
        ' :16, '||
        ' :17, '||
        ' :18 '||
        ' ) '
        USING   l_wbsc_id,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID,
                l_svr_cat_name,
                p_name,
                'Y',
                l_media_type,
                0,
                3,
                c_rec.WBSVR_ID,
                l_parent_id,
                p_svc_plan_id,
                0,
                0,
                p_media_type_id;


    end loop;



COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


END   Create_CampCategory;

--===================================================================
-- NAME
--   Create_ClassfnCategory
--
-- PURPOSE
--    Private api to create category
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create category
--
-- HISTORY
--   5-August-2003     GPAGADAL   Created

--===================================================================


PROCEDURE Create_ClassfnCategory(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_cat_id OUT NOCOPY NUMBER,
                       p_svc_plan_id in  NUMBER,
                       p_name in VARCHAR2,
                       p_media_type_id in NUMBER,
                       p_server_id IN NUMBER
                        )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_wbsc_id  IEB_WB_SVC_CATS.WBSC_ID%type;

    l_media_type IEB_SVC_CAT_TEMPS_B.media_type%type;

    l_parent_id IEB_WB_SVC_CATS.parent_id%type;

    l_cpn_svr_name IEB_WB_SVC_CATS.campaign_server_name%type;

    l_svr_cat_name IEB_WB_SVC_CATS.service_category_name%type;

    l_time_stamp NUMBER(15);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;


        select parent_id into l_parent_id
        from IEB_WB_SVC_CATS where media_type_id= p_media_type_id
        and wbsvr_wbsvr_id= p_server_id
        and default_flag= 'Y';

        select  media_type into l_media_type
        from IEB_SVC_CAT_TEMPS_B where media_type_id = p_media_type_id;


        SELECT DBMS_UTILITY.GET_TIME INTO l_time_stamp FROM dual;

        l_svr_cat_name := p_svc_plan_id||p_name||to_char(l_time_stamp);

        select IEB_SVC_CATS_S1.nextval into l_wbsc_id from dual;

        EXECUTE immediate 'INSERT into IEB_WB_SVC_CATS '||
        ' (WBSC_ID,  '||
        ' CREATED_BY,  '||
        ' CREATION_DATE, '||
        ' LAST_UPDATED_BY,  '||
        ' LAST_UPDATE_DATE, '||
        ' LAST_UPDATE_LOGIN, '||
        ' SERVICE_CATEGORY_NAME, '||
        ' ACTIVE_Y_N, '||
        ' MEDIA_TYPE, '||
        ' PRIORITY, '||
        ' DEPTH, '||
        ' WBSVR_WBSVR_ID, '||
        ' PARENT_ID, '||
        ' SVCPLN_SVCPLN_ID, '||
        ' OBJECT_VERSION_NUMBER, '||
        ' SECURITY_GROUP_ID, '||
        ' MEDIA_TYPE_ID'||
        ' ) values ('||
        ' :1, '||
        ' :2, '||
        ' :3, '||
        ' :4, '||
        ' :5, '||
        ' :6, '||
        ' :7, '||
        ' :8, '||
        ' :9, '||
        ' :10, '||
        ' :11, '||
        ' :12, '||
        ' :13, '||
        ' :14, '||
        ' :15, '||
        ' :16, '||
        ' :17 '||
        ' ) '
        USING   l_wbsc_id,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID,
                l_svr_cat_name,
                'Y',
                l_media_type,
                0,
                3,
                p_server_id,
                l_parent_id,
                p_svc_plan_id,
                0,
                0,
                p_media_type_id;


p_cat_id := l_wbsc_id;


COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END   Create_ClassfnCategory;

--===================================================================
-- NAME
--   Create_RegionalPlan
--
-- PURPOSE
--    Private api to create regional plan.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create regional plan
--
--
-- HISTORY
--   24-July-2003     GPAGADAL   Created

--===================================================================

PROCEDURE Create_RegionalPlan(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id OUT NOCOPY NUMBER,
                       p_base_plan_id in NUMBER,
                       p_name IN VARCHAR2,
                       p_desc IN VARCHAR2,
                       p_direction IN VARCHAR2,
                       p_media_type_id IN NUMBER
                       )as


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_svc_plan_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;


    IEB_ServicePlan_PVT.Create_ServicePlan(x_return_status,
                             x_msg_count,
                             x_msg_data,
                             l_svc_plan_id,
                             p_name,
                             p_desc,
                             p_direction,
                             p_media_type_id);


    EXECUTE immediate 'INSERT into IEB_REGIONAL_PLANS '||
    '(SERVICE_PLAN_ID, '||
    ' CREATED_BY, '||
    ' CREATION_DATE, '||
    ' LAST_UPDATED_BY, '||
    ' LAST_UPDATE_DATE, '||
    ' LAST_UPDATE_LOGIN, '||
    ' BASE_PLAN_ID, '||
    ' OBJECT_VERSION_NUMBER, '||
    ' SECURITY_GROUP_ID '||
    ' ) VALUES '||
    ' (:1, '||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9'||
    ') '
    USING l_svc_plan_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        p_base_plan_id,
        0,
        0;

p_plan_id := l_svc_plan_id;

COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


END   Create_RegionalPlan;

--===================================================================
-- NAME
--   Create_GroupPlanMap
--
-- PURPOSE
--    Private api to create group map.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create group map
--
--
-- HISTORY
--   24-July-2003     GPAGADAL   Created

--===================================================================
PROCEDURE Create_GroupPlanMap(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id in  NUMBER,
                       p_server_group_id IN NUMBER
                       )as


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_svc_plan_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_map_id IEB_GROUP_PLAN_MAPS.MAP_ID%type;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;


    select IEB_GROUP_PLAN_MAPS_S1.nextval into l_map_id from dual;
    EXECUTE immediate 'INSERT INTO IEB_GROUP_PLAN_MAPS '||
    '(MAP_ID, '||
    ' SERVICE_PLAN_ID, '||
    ' CREATED_BY, '||
    ' CREATION_DATE, '||
    ' LAST_UPDATED_BY, '||
    ' LAST_UPDATE_DATE, '||
    ' LAST_UPDATE_LOGIN, '||
    ' SERVER_GROUP_ID, '||
    ' OBJECT_VERSION_NUMBER, '||
    ' SECURITY_GROUP_ID '||
    ' ) VALUES '||
    ' ( :1, '||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9, '||
    ' :10  '||
    ') '
    USING l_map_id,
        p_plan_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        p_server_group_id,
        0,
        0 ;




COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Create_GroupPlanMap;

--===================================================================
-- NAME
--   Update_Category
--
-- PURPOSE
--    Private api to update  category.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  update category
--
--
-- HISTORY
--   3-Sep-2003     GPAGADAL   Created

--===================================================================


PROCEDURE Update_Category (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_base_plan_id in  NUMBER,
                                p_media_type_id in NUMBER,
                                p_reg_plan_id in  NUMBER
                                )
as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


    update IEB_WB_SVC_CATS set
        svcpln_svcpln_id =  p_reg_plan_id,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    where MEDIA_TYPE_ID  = p_media_type_id
        and svcpln_svcpln_id =  p_base_plan_id;


COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Update_Category;



--===================================================================
-- NAME
--   Create_ServiceLevel
--
-- PURPOSE
--    Private api to create service level.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  create service level
--
--
-- HISTORY
--   11-July-2003     GPAGADAL   Created

--===================================================================
PROCEDURE Create_ServiceLevel ( x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count OUT  NOCOPY NUMBER,
                                x_msg_data  OUT  NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEB_SERVICE_LEVELS_OBJ
                               )as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_service_lvl_id  IEB_SERVICE_LEVELS_B.SERVICE_LEVEL_ID%type;
    l_temp_str varchar2(80);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    x_msg_count := 0;
    l_temp_str := null;


    select IEB_SVC_LEVEL_S1.nextval into l_service_lvl_id from dual;

    EXECUTE immediate  'insert into IEB_SERVICE_LEVELS_B '||
    '(SERVICE_LEVEL_ID, '||
    ' CREATED_BY, '||
    ' CREATION_DATE, '||
    ' LAST_UPDATED_BY, '||
    ' LAST_UPDATE_DATE, '||
    ' LAST_UPDATE_LOGIN, '||
    ' DIRECTION, '||
    ' MANDATORY_FLAG, '||
    ' HOURLY_QUOTA, '||
    ' MIN_AGENTS, '||
    ' GOAL_PERCENT, '||
    ' GOAL_TIME, '||
    ' MAX_WAIT_TIME, '||
    ' REROUTE_TIME, '||
    ' REROUTE_WARNING_TIME, '||
    ' OBJECT_VERSION_NUMBER, '||
    ' SECURITY_GROUP_ID '||
    ' ) values '||
    ' (:1, '||
    ' :2, '||
    ' :3, '||
    ' :4, '||
    ' :5, '||
    ' :6, '||
    ' :7, '||
    ' :8, '||
    ' :9, '||
    ' :10, '||
    ' :11, '||
    ' :12, '||
    ' :13, '||
    ' :14, '||
    ' :15, '||
    ' :16, '||
    ' :17 '||
    ') '
    USING l_service_lvl_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        rec_obj.direction,
        l_temp_str,
        rec_obj.hourly_quota,
        rec_obj.min_agents,
        rec_obj.goal_percent,
        rec_obj.goal_time,
        rec_obj.max_wait_time,
        rec_obj.reroute_time,
        rec_obj.reroute_warning_time,
        0,
        0;





 insert into IEB_SERVICE_LEVELS_TL (
    SERVICE_LEVEL_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEVEL_NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_service_lvl_id,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.LOGIN_ID,
    LTRIM(RTRIM(rec_obj.level_name)),
    LTRIM(RTRIM(rec_obj.level_description)),
    0,
    0,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEB_SERVICE_LEVELS_TL T
    where T.SERVICE_LEVEL_ID = l_service_lvl_id
    and T.LANGUAGE = L.LANGUAGE_CODE);


  COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_ServiceLevel;


--===================================================================
-- NAME
--   Update_ServiceLevel
--
-- PURPOSE
--    Private api to update service level.
--
-- NOTES
--    1. Work blending Admin will use this procedure to  update service level
--
--
-- HISTORY
--   11-July-2003     GPAGADAL   Created

--===================================================================
PROCEDURE Update_ServiceLevel (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       rec_obj IN SYSTEM.IEB_SERVICE_LEVELS_OBJ
                       )

as
    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_service_lvl_id  IEB_SERVICE_LEVELS_B.SERVICE_LEVEL_ID%type;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';

    if (rec_obj.direction = 'I') then
   -- dbms_output.put_line('inbound');
        update IEB_SERVICE_LEVELS_B set
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
            GOAL_PERCENT = rec_obj.goal_percent,
            GOAL_TIME = rec_obj.goal_time,
            MAX_WAIT_TIME = rec_obj.max_wait_time,
            MIN_AGENTS= rec_obj.min_agents
         where
          SERVICE_LEVEL_ID = rec_obj.service_level_id;

    elsif (rec_obj.direction = 'O') then
   -- dbms_output.put_line('outbound');
        update IEB_SERVICE_LEVELS_B set
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
            HOURLY_QUOTA = rec_obj.hourly_quota,
            MIN_AGENTS= rec_obj.min_agents
         where
          SERVICE_LEVEL_ID = rec_obj.service_level_id;



    end if;

 COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Update_ServiceLevel;




--===================================================================
-- NAME
--   Delete_Service_Level
--
-- PURPOSE
--    Private api to delete service level
--
-- NOTES
--    1. Work blending Admin will use this procedure to delete service level
--
--
-- HISTORY
--   09-July-2003     GPAGADAL   Created
--===================================================================


PROCEDURE Delete_Service_Level(   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
    x_service_level_id IN NUMBER
    )
    is

    l_language  VARCHAR2(4);

    l_service_level_id  IEB_SERVICE_LEVELS_B.SERVICE_LEVEL_ID%type;

BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := '';


    EXECUTE immediate
    'delete from IEB_SERVICE_LEVELS_TL '||
    ' where  SERVICE_LEVEL_ID = :1  and language= :2'
    USING x_service_level_id, l_language;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from IEB_SERVICE_LEVELS_B '||
    ' where  SERVICE_LEVEL_ID =  :1'
    USING x_service_level_id;

    if (sql%notfound) then
        null;
    end if;

COMMIT;
     EXCEPTION
         WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
         x_return_status := fnd_api.g_ret_sts_unexp_error;




END Delete_Service_Level;


--===================================================================
-- NAME
--   Delete_Service_Plan
--
-- PURPOSE
--    Private api to delete service plan
--
-- NOTES
--    1. Work blending Admin will use this procedure to delete service plan
--
--
-- HISTORY
--   24-July-2003     GPAGADAL   Created
--===================================================================

PROCEDURE Delete_Service_Plan (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
    x_service_plan_id IN NUMBER
)
 as


    l_service_plan_b_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := '';

    EXECUTE immediate
   ' delete from IEB_SERVICE_PLANS where  SVCPLN_ID = :1 or SVCPLN_ID in ( select SERVICE_PLAN_ID  from ieb_regional_plans where base_plan_id = :2)'
    USING x_service_plan_id, x_service_plan_id;
    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from IEB_SERVICE_PLANS_TL where  SERVICE_PLAN_ID = :1 or SERVICE_PLAN_ID in ( select SERVICE_PLAN_ID  from ieb_regional_plans where base_plan_id =:2)'
    USING x_service_plan_id, x_service_plan_id;

    if (sql%notfound) then
        null;
    end if;



    EXECUTE immediate
    ' delete from ieb_group_plan_maps where service_plan_id = :1 or  service_plan_id in (select SERVICE_PLAN_ID  from ieb_regional_plans where base_plan_id =:2)'
    USING x_service_plan_id, x_service_plan_id ;

    if (sql%notfound) then
        null;
    end if;


    EXECUTE immediate
    ' delete from IEB_INB_SVC_COVERAGES where  SVCPLN_SVCPLN_ID = :1 or SVCPLN_SVCPLN_ID in (select SERVICE_PLAN_ID  from ieb_regional_plans where base_plan_id =:2)'
    USING x_service_plan_id, x_service_plan_id;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from IEB_OUTB_SVC_COVERAGES where  SVCPLN_SVCPLN_ID = :1 or SVCPLN_SVCPLN_ID in (select SERVICE_PLAN_ID  from ieb_regional_plans where base_plan_id =:2)'
    USING x_service_plan_id, x_service_plan_id;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from ieb_regional_plans where base_plan_id = :1'
    USING x_service_plan_id;

    if (sql%notfound) then
        null;
    end if;



COMMIT;
     EXCEPTION
         WHEN others THEN
        --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_Service_Plan;

--===================================================================
-- NAME
--   Delete_Classification
--
-- PURPOSE
--    Private api to delete classifications
--
-- NOTES
--    1. Work blending Admin will use this procedure to delete classifications
--
--
-- HISTORY
--   1-August-2003     GPAGADAL   Created
--===================================================================

PROCEDURE Delete_Classification(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_media_type_id in NUMBER
                       )
 as


    l_service_plan_b_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := '';

    EXECUTE immediate
    ' delete from   IEB_WB_SVC_CAT_RULES '||
    ' where WBSC_WBSC_ID in (select distinct c.WBSC_ID from '||
    ' IEB_WB_SVC_CATS c,IEB_WB_SVC_CAT_RULES r , IEB_REGIONAL_PLANS p '||
    ' where c.WBSC_ID = r.WBSC_WBSC_ID '||
    ' and (c.SVCPLN_SVCPLN_ID = :1 or p.BASE_PLAN_ID = :2) '||
    ' and c.MEDIA_TYPE_ID = :3  '||
    ' and p.SERVICE_PLAN_ID (+)= c.SVCPLN_SVCPLN_ID  ) '
    USING  p_svc_plan_id,p_svc_plan_id, p_media_type_id;

    if (sql%notfound) then
        null;
    end if;

   EXECUTE immediate
    ' delete from IEB_WB_SVC_CATS s '||
    ' where s.WBSC_ID in ( select c.WBSC_ID from '||
    ' IEB_WB_SVC_CATS c,  IEB_REGIONAL_PLANS p '||
    ' where  c.MEDIA_TYPE_ID  = :1'||
    ' and (c.svcpln_svcpln_id =  :2 or p.BASE_PLAN_ID = :3) '||
    ' and p.SERVICE_PLAN_ID (+)= c.SVCPLN_SVCPLN_ID )  '
    USING p_media_type_id, p_svc_plan_id, p_svc_plan_id;

    if (sql%notfound) then
        null;
    end if;

COMMIT;
     EXCEPTION
         WHEN others THEN
        --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_Classification;

--===================================================================
-- NAME
--   Delete_Category
--
-- PURPOSE
--    Private api to delete service categories
--
-- NOTES
--    1. Work blending Admin will use this procedure to delete  service categories
--
--
-- HISTORY
--   1-August-2003     GPAGADAL   Created
--===================================================================

PROCEDURE Delete_Category(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_media_type_id in NUMBER
                       ) as


    l_service_plan_b_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := '';

    EXECUTE immediate
    ' delete from IEB_WB_SVC_CATS s '||
    ' where s.WBSC_ID in ( select c.WBSC_ID from '||
    ' IEB_WB_SVC_CATS c,  IEB_REGIONAL_PLANS p '||
    ' where  c.MEDIA_TYPE_ID  = :1'||
    ' and (c.svcpln_svcpln_id =  :2 or p.BASE_PLAN_ID = :3) '||
    ' and p.SERVICE_PLAN_ID (+)= c.SVCPLN_SVCPLN_ID )  '
    USING p_media_type_id, p_svc_plan_id, p_svc_plan_id;

    if (sql%notfound) then
        null;
    end if;


COMMIT;
     EXCEPTION
        WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_Category;
--===================================================================
-- NAME
--   Delete_IOCoverages
--
-- PURPOSE
--    Private api to delete service plan coverages
--
-- NOTES
--    1. Work blending Admin will use this procedure to delete  service plan coverages
--
--
-- HISTORY
--   4-August-2003     GPAGADAL   Created
--===================================================================

PROCEDURE Delete_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_direction IN VARCHAR2,
                                p_plan_id IN VARCHAR2
                                )as


    l_service_plan_b_id  IEB_SERVICE_PLANS.SVCPLN_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    x_msg_data := '';

    if( p_direction = 'I') then

        EXECUTE immediate
        ' delete from IEB_INB_SVC_COVERAGES where svcpln_svcpln_id =:1 '
        USING p_plan_id;

        if (sql%notfound) then
            null;
        end if;
    elsif (p_direction = 'O') then

        EXECUTE immediate
        ' delete from IEB_OUTB_SVC_COVERAGES where svcpln_svcpln_id =:1 '
        USING p_plan_id;

        if (sql%notfound) then
            null;
        end if;
    end if;

COMMIT;
     EXCEPTION
        WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_IOCoverages;


PROCEDURE Delete_Regional_Plan (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_base_plan_id IN NUMBER,
                       p_reg_plan_id IN NUMBER )as


    l_media_type_id  IEB_SERVICE_PLANS.MEDIA_TYPE_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';

    select MEDIA_TYPE_ID into l_media_type_id from IEB_SERVICE_PLANS where SVCPLN_ID = p_base_plan_id;

    update IEB_WB_SVC_CATS set
        svcpln_svcpln_id =  p_base_plan_id,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    where MEDIA_TYPE_ID  = l_media_type_id
        and svcpln_svcpln_id =  p_reg_plan_id;



    EXECUTE immediate
    ' delete from ieb_regional_plans where base_plan_id = :1 and SERVICE_PLAN_ID = :2'
    USING p_base_plan_id, p_reg_plan_id ;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from ieb_group_plan_maps where service_plan_id = :1 '
    USING p_reg_plan_id;

    if (sql%notfound) then
      null;
    end if;

    EXECUTE immediate
    ' delete from IEB_INB_SVC_COVERAGES where  SVCPLN_SVCPLN_ID = :1 '
    USING p_reg_plan_id;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from IEB_OUTB_SVC_COVERAGES where  SVCPLN_SVCPLN_ID = :1'
    USING p_reg_plan_id;

    if (sql%notfound) then
        null;
    end if;
     EXECUTE immediate
    ' delete from IEB_SERVICE_PLANS where  SVCPLN_ID = :1'
    USING p_reg_plan_id;

    if (sql%notfound) then
        null;
    end if;

    EXECUTE immediate
    ' delete from IEB_SERVICE_PLANS_TL where  SERVICE_PLAN_ID = :1'
    USING p_reg_plan_id;

    if (sql%notfound) then
        null;
    end if;


COMMIT;
     EXCEPTION
        WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_Regional_Plan;


PROCEDURE Delete_Regional_PlanMaps (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_reg_plan_id IN NUMBER ,
                       p_base_plan_id IN NUMBER,
                       p_media_type_id IN NUMBER)as

    l_language  VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


    EXECUTE immediate
    ' delete from ieb_group_plan_maps where service_plan_id = :1 '
    USING p_reg_plan_id;

    if (sql%notfound) then
      null;
    end if;


    update IEB_WB_SVC_CATS set
        svcpln_svcpln_id =  p_base_plan_id,
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    where MEDIA_TYPE_ID  = p_media_type_id
        and svcpln_svcpln_id =  p_reg_plan_id;



COMMIT;
     EXCEPTION
        WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;


END Delete_Regional_PlanMaps;


PROCEDURE Delete_SpecDateCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_direction IN VARCHAR2,
                                p_plan_id IN VARCHAR2,
                                p_spec_date IN VARCHAR2
                                )as


    l_media_type_id  IEB_SERVICE_PLANS.MEDIA_TYPE_ID%type;

    l_service_plan_tl_id  IEB_SERVICE_PLANS_TL.SERVICE_PLAN_ID%type;
    l_language  VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


BEGIN

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_count := 0;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';




    if( p_direction = 'I') then

        EXECUTE immediate
        ' delete from IEB_INB_SVC_COVERAGES where svcpln_svcpln_id =:1 and SPEC_SCHD_DATE =:2 and SCHEDULE_TYPE = :3'
        USING p_plan_id, p_spec_date, 'S';

        if (sql%notfound) then
            null;
        end if;
    elsif (p_direction = 'O') then

        EXECUTE immediate
        ' delete from IEB_OUTB_SVC_COVERAGES where svcpln_svcpln_id =:1 and SPEC_SCHD_DATE=:2 and SCHEDULE_TYPE = :3'
        USING p_plan_id, p_spec_date, 'S';

        if (sql%notfound) then
            null;
        end if;
    end if;

COMMIT;
     EXCEPTION
        WHEN others THEN
       -- dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
        ROLLBACK;
        x_return_status := fnd_api.g_ret_sts_unexp_error;



END Delete_SpecDateCoverages;


END IEB_ServicePlan_PVT;

/
