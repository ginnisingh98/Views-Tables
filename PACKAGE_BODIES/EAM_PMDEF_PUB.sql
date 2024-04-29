--------------------------------------------------------
--  DDL for Package Body EAM_PMDEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PMDEF_PUB" AS
/* $Header: EAMPPMDB.pls 120.20.12010000.11 2011/01/10 11:06:59 somitra ship $*/
-- Start of comments
--    API name     : package EAM_PMDef_Pub; API's: instantiate_PM_def, create_PM_def, update_PM_def
--    Type        : Public
--    Function    : Copy, create, and update PM definition and associated PM rules.
--    Pre-reqs    : None.
--    Version    :     Current version: 1.0
--            Initial version: 1.0
--
--    Notes
--
-- End of comments

G_PKG_NAME     CONSTANT VARCHAR2(30):='EAM_PMDef_Pub';
g_sysdate       DATE        :=sysdate;
/* for de-bugging */
PROCEDURE print_log(info varchar2) is
PRAGMA  AUTONOMOUS_TRANSACTION;
l_dummy number;
BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG, info);

END;

-- Given an activity association id of an activity association instance,
-- and a pm_schedule_id of a pm template,
-- create a new pm definition from the template, where the new pm definition
-- is associated to the given activity_association_id.

PROCEDURE instantiate_PM_def
(
    p_pm_schedule_id    IN    NUMBER,
    p_activity_assoc_id    IN     NUMBER,
    x_new_pm_schedule_id    OUT NOCOPY     NUMBER,     -- this is the pm_schedule_id of the newly copied pm schedule
    x_return_status        OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER  ,
        x_msg_data              OUT NOCOPY     VARCHAR2
)
IS

l_pm_schedule_id        number;
pm_header_row            pm_scheduling_rec_type;
pm_activity_row            pm_activities_grp_rec_type;
pm_rule_row            pm_rule_rec_type;
l_rule_id            number;
l_validated            boolean;
l_reason_failed            varchar2(30);
l_initial_reading        number;
l_maintenance_object_type    number;
l_maintenance_object_id        number;
l_meter_id            number;
l_return_status varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_update_failed varchar2(1);
l_error_message varchar2(2000);
l_prev_pm_schedule_id        number;
l_last_act               number;
l_count  number;-- for bug 7230256

cursor pm_rules_csr IS
        select
         PM_SCHEDULE_ID,
         RULE_TYPE,
         DAY_INTERVAL,
         METER_ID,
         RUNTIME_INTERVAL,
         EFFECTIVE_READING_FROM,
         EFFECTIVE_READING_TO,
         EFFECTIVE_DATE_FROM,
         EFFECTIVE_DATE_TO,
     LIST_DATE,
     LIST_DATE_DESC
        from eam_pm_scheduling_rules
        where pm_schedule_id = p_pm_schedule_id;

cursor pm_activities_csr IS
    select
    epa.pm_schedule_id,
    meaa.activity_association_id,
    epa.interval_multiple,
        epa.allow_repeat_in_cycle,
    epa.day_tolerance,
    epa.next_service_start_date,
    epa.next_service_end_date
        from eam_pm_activities epa, mtl_eam_asset_activities meaa
    where epa.pm_schedule_id=p_pm_schedule_id
    and epa.activity_association_id =meaa.source_tmpl_id
    and meaa.maintenance_object_id=l_maintenance_object_id;


BEGIN

    x_return_status:=FND_API.G_RET_STS_SUCCESS;

-- Check that enough info is supplied to identify which pm schedule to copy from.
    if (p_pm_schedule_id is null) then
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_MT_SUPPLY_PARAMS');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    end if;

      begin
    select
     PM_SCHEDULE_ID,
     ACTIVITY_ASSOCIATION_ID,
     NON_SCHEDULED_FLAG,
     FROM_EFFECTIVE_DATE,
     TO_EFFECTIVE_DATE,
     RESCHEDULING_POINT,
     LEAD_TIME,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2                               ,
     ATTRIBUTE3                               ,
     ATTRIBUTE4                               ,
     ATTRIBUTE5                               ,
     ATTRIBUTE6                               ,
     ATTRIBUTE7                               ,
     ATTRIBUTE8                               ,
     ATTRIBUTE9                               ,
     ATTRIBUTE10                              ,
     ATTRIBUTE11                              ,
     ATTRIBUTE12                              ,
     ATTRIBUTE13                              ,
     ATTRIBUTE14                              ,
     ATTRIBUTE15                              ,
     DAY_TOLERANCE    ,
     SOURCE_CODE   ,
     SOURCE_LINE   ,
     DEFAULT_IMPLEMENT,
     WHICHEVER_FIRST  ,
     INCLUDE_MANUAL   ,
     SET_NAME_ID     ,
     SCHEDULING_METHOD_CODE,
     TYPE_CODE,
      NEXT_SERVICE_START_DATE,
      NEXT_SERVICE_END_DATE,
     SOURCE_TMPL_ID                           ,
     AUTO_INSTANTIATION_FLAG                  ,
     NAME                                     ,
     TMPL_FLAG                       ,
     GENERATE_WO_STATUS              ,
     INTERVAL_PER_CYCLE                      ,
     CURRENT_CYCLE                           ,
     CURRENT_SEQ                             ,
     CURRENT_WO_SEQ                          ,
     BASE_DATE                               ,
     BASE_READING                            ,
     EAM_LAST_CYCLIC_ACT                     ,
     MAINTENANCE_OBJECT_ID                   ,
     MAINTENANCE_OBJECT_TYPE         ,
/* added for PM Reviewer -- start-- */
     LAST_REVIEWED_DATE             ,
     Last_reviewed_by              ,
/* ---PM reviewer--- end---- */
    generate_next_work_order
    into pm_header_row
    from eam_pm_schedulings
    where pm_schedule_id=p_pm_schedule_id;
     exception
    when no_data_found then
                FND_MESSAGE.SET_NAME ('EAM', 'EAM_MT_SUPPLY_PARAMS');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
     end;

         select eam_pm_schedulings_s.nextval into l_pm_schedule_id from dual;

-- If the source pm is not a template, raise error
        if (not (pm_header_row.tmpl_flag = 'Y')) then
            FND_MESSAGE.SET_NAME('EAM', 'EAM_PM_INST_NOT_TMPL');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        else
        -- When instantiating, tmpl_flag should be 'N'
            pm_header_row.tmpl_flag:='N';
            pm_header_row.source_tmpl_id:=pm_header_row.pm_schedule_id;
            pm_header_row.auto_instantiation_flag:='N';
            pm_header_row.name:=pm_header_row.name || '-' || l_pm_schedule_id;

            begin

            select maintenance_object_id, maintenance_object_type
            into l_maintenance_object_id, l_maintenance_object_type
            from mtl_eam_asset_activities
            where activity_association_id=p_activity_assoc_id;

            pm_header_row.maintenance_object_id := l_maintenance_object_id;
            pm_header_row.maintenance_object_type := 3;
            pm_header_row.current_cycle := 1;
            pm_header_row.current_seq := 0;

            exception
                when no_data_found then
                        FND_MESSAGE.SET_NAME ('EAM', 'EAM_MT_SUPPLY_PARAMS');
                FND_MSG_PUB.Add;
                        RAISE FND_API.G_EXC_ERROR;
            end;
        end if;


    l_validated:=validate_pm_header(pm_header_row, l_reason_failed);


    if (l_validated) then

    insert into eam_pm_schedulings (
         PM_SCHEDULE_ID,
         ACTIVITY_ASSOCIATION_ID,
         NON_SCHEDULED_FLAG,
         FROM_EFFECTIVE_DATE,
         TO_EFFECTIVE_DATE,
         RESCHEDULING_POINT,
         LEAD_TIME,
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
         DAY_TOLERANCE    ,
         SOURCE_CODE   ,
         SOURCE_LINE   ,
         DEFAULT_IMPLEMENT,
         WHICHEVER_FIRST  ,
         INCLUDE_MANUAL   ,
         SET_NAME_ID,
     SCHEDULING_METHOD_CODE,
     TYPE_CODE,
      NEXT_SERVICE_START_DATE,
      NEXT_SERVICE_END_DATE,
     SOURCE_TMPL_ID,
     AUTO_INSTANTIATION_FLAG,
     NAME                 ,
     TMPL_FLAG           ,
     GENERATE_WO_STATUS              ,
     INTERVAL_PER_CYCLE                      ,
     CURRENT_CYCLE                           ,
     CURRENT_SEQ                             ,
     CURRENT_WO_SEQ                          ,
     BASE_DATE                               ,
     BASE_READING                            ,
     EAM_LAST_CYCLIC_ACT                     ,
     MAINTENANCE_OBJECT_ID                   ,
     MAINTENANCE_OBJECT_TYPE                 ,
     /* added for PM Reviewer -- start-- */
      LAST_REVIEWED_DATE             ,
     Last_reviewed_by             ,
     /* ---PM reviewer--- end---- */
     created_by,
     creation_date,
     last_update_login,
     last_updated_by,
     last_update_date ,
     generate_next_work_order   )
    values (
     l_pm_schedule_id,
     pm_header_row.ACTIVITY_ASSOCIATION_ID,
     pm_header_row.NON_SCHEDULED_FLAG,
     pm_header_row.FROM_EFFECTIVE_DATE,
     pm_header_row.TO_EFFECTIVE_DATE,
     pm_header_row.RESCHEDULING_POINT,
     pm_header_row.LEAD_TIME,
     pm_header_row.ATTRIBUTE_CATEGORY,
     pm_header_row.ATTRIBUTE1,
     pm_header_row.ATTRIBUTE2                               ,
     pm_header_row.ATTRIBUTE3                               ,
     pm_header_row.ATTRIBUTE4                               ,
     pm_header_row.ATTRIBUTE5                               ,
     pm_header_row.ATTRIBUTE6                               ,
     pm_header_row.ATTRIBUTE7                               ,
     pm_header_row.ATTRIBUTE8                               ,
     pm_header_row.ATTRIBUTE9                               ,
     pm_header_row.ATTRIBUTE10                              ,
     pm_header_row.ATTRIBUTE11                              ,
     pm_header_row.ATTRIBUTE12                              ,
     pm_header_row.ATTRIBUTE13                              ,
     pm_header_row.ATTRIBUTE14                              ,
     pm_header_row.ATTRIBUTE15                              ,
     pm_header_row.DAY_TOLERANCE    ,
     pm_header_row.SOURCE_CODE   ,
     pm_header_row.SOURCE_LINE   ,
     pm_header_row.DEFAULT_IMPLEMENT,
     pm_header_row.WHICHEVER_FIRST  ,
     pm_header_row.INCLUDE_MANUAL   ,
     pm_header_row.SET_NAME_ID,
     pm_header_row.SCHEDULING_METHOD_CODE ,
    pm_header_row.TYPE_CODE,
    pm_header_row.NEXT_SERVICE_START_DATE,
    pm_header_row.NEXT_SERVICE_END_DATE,
        pm_header_row.SOURCE_TMPL_ID,
        pm_header_row.AUTO_INSTANTIATION_FLAG,
        pm_header_row.NAME                 ,
        pm_header_row.TMPL_FLAG           ,
     pm_header_row.GENERATE_WO_STATUS              ,
     pm_header_row.INTERVAL_PER_CYCLE                      ,
     pm_header_row.CURRENT_CYCLE                           ,
     pm_header_row.CURRENT_SEQ                             ,
     pm_header_row.CURRENT_WO_SEQ                          ,
     pm_header_row.BASE_DATE                               ,
     pm_header_row.BASE_READING                            ,
     pm_header_row.EAM_LAST_CYCLIC_ACT                     ,
     pm_header_row.MAINTENANCE_OBJECT_ID                   ,
     pm_header_row.MAINTENANCE_OBJECT_TYPE                 ,
     /* added for PM Reviewer -- start-- */
      pm_header_row.LAST_REVIEWED_DATE               ,
     pm_header_row.Last_reviewed_by                   ,
     /* ---PM reviewer--- end---- */
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id,
    fnd_global.user_id,
    sysdate ,
    pm_header_row.generate_next_work_order     );

--now start copying the activities.

    for a_pm_activity in pm_activities_csr loop

    --creating an new activity row
    pm_activity_row.pm_schedule_id := a_pm_activity.pm_schedule_id;
    pm_activity_row.activity_association_id := a_pm_activity.activity_association_id;
    pm_activity_row.interval_multiple := a_pm_activity.interval_multiple;
    pm_activity_row.allow_repeat_in_cycle := a_pm_activity.allow_repeat_in_cycle;
    pm_activity_row.day_tolerance := a_pm_activity.day_tolerance;

    --validating the activity row
       l_validated := validate_pm_activity
            ( pm_activity_row,
              pm_header_row,
                      l_reason_failed);

    if (l_validated) then

        insert into eam_pm_activities
        (pm_schedule_id,
         activity_association_id,
         interval_multiple,
         allow_repeat_in_cycle,
         day_tolerance,
         created_by,
         creation_date,
         last_update_login,
         last_updated_by,
         last_update_date   )
         values
         (l_pm_schedule_id,
          a_pm_activity.activity_association_id,
          a_pm_activity.interval_multiple,
          a_pm_activity.allow_repeat_in_cycle,
          a_pm_activity.day_tolerance,
          fnd_global.user_id,
          sysdate,
          fnd_global.login_id,
          fnd_global.user_id,
          sysdate     );

      end if;

    end loop;

    eam_pmdef_pub.update_pm_last_cyclic_act
    (      p_api_version => 1.0 ,
        p_init_msg_list     => 'F' ,
           p_commit            => 'F' ,
           p_validation_level  => 100 ,
        x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
        p_pm_schedule_id => l_pm_schedule_id
     );


     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
         l_update_failed := 'Y';
         RAISE FND_API.G_EXC_ERROR;
     end if;

     -- now start copying over the rules
     for a_pm_rule in pm_rules_csr loop


        -- Get maintenance object id and maintenance type
        select maintenance_object_id, maintenance_object_type
        into l_maintenance_object_id, l_maintenance_object_type
        from mtl_eam_asset_activities
        where activity_association_id=p_activity_assoc_id;

        -- for runtime rule, get the meter id
        if (a_pm_rule.meter_id is not null) then

             --added for performance issues.
                select cca.counter_id into l_meter_id
            from CSI_COUNTER_ASSOCIATIONS cca, CSI_COUNTERS_B ccb
            where  cca.counter_id = ccb.counter_id
                     and   ccb.created_from_counter_tmpl_id=a_pm_rule.meter_id
             and   cca.source_object_id= l_maintenance_object_id ;

        end if;

        insert into eam_pm_scheduling_rules
                ( PM_SCHEDULE_ID,
                 RULE_TYPE,
                DAY_INTERVAL,
                METER_ID  ,
                RUNTIME_INTERVAL,
                CREATED_BY         ,
                CREATION_DATE     ,
                LAST_UPDATE_LOGIN,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                EFFECTIVE_READING_FROM ,
                EFFECTIVE_READING_TO  ,
                EFFECTIVE_DATE_FROM  ,
                EFFECTIVE_DATE_TO   ,
                LIST_DATE          ,
                LIST_DATE_DESC,
                RULE_ID)
            values
                                (l_pm_schedule_id,
                                a_pm_rule.RULE_TYPE,
                                a_pm_rule.DAY_INTERVAL,
                                l_meter_id,
                                a_pm_rule.RUNTIME_INTERVAL,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.login_id,
                    sysdate    ,
                    fnd_global.user_id,
                                a_pm_rule.EFFECTIVE_READING_FROM ,
                                a_pm_rule.EFFECTIVE_READING_TO  ,
                                a_pm_rule.EFFECTIVE_DATE_FROM  ,
                                a_pm_rule.EFFECTIVE_DATE_TO   ,
                                a_pm_rule.LIST_DATE          ,
                                a_pm_rule.LIST_DATE_DESC    ,
                eam_pm_scheduling_rules_s.nextval);

-- if it's a runtime rule, insert meter initial reading into eam_pm_last_services table
        if a_pm_rule.meter_id is not null then

            --added for  performance issues
             select initial_reading into l_initial_reading from
                      (select initial_reading from CSI_COUNTERS_B where counter_id = a_pm_rule.meter_id
                         union
                    select initial_reading from CSI_COUNTER_TEMPLATE_B where counter_id = a_pm_rule.meter_id
                      );
            select EAM_LAST_CYCLIC_ACT into l_last_act    from eam_pm_schedulings
            where pm_schedule_id = l_pm_schedule_id;

            -- for bug 7230256
            l_count := 0;
            select count (*) into l_count
            from eam_pm_last_service
            where meter_id=l_meter_id and ACTIVITY_ASSOCIATION_ID =l_last_act;

            if l_count = 0 then

                insert into eam_pm_last_service
                ( METER_ID ,
                   ACTIVITY_ASSOCIATION_ID        ,
                   LAST_SERVICE_READING         ,
                   PREV_SERVICE_READING        ,
                   WIP_ENTITY_ID              ,
                   LAST_UPDATE_DATE          ,
                   LAST_UPDATED_BY          ,
                   CREATION_DATE           ,
                   CREATED_BY             ,
                   LAST_UPDATE_LOGIN
                )
                values
                (
                l_meter_id,
                l_last_act,
                l_initial_reading,
                null,
                null,
                sysdate,
                    fnd_global.user_id,
                            sysdate,
                    fnd_global.user_id,
                            fnd_global.login_id
                );
            end if;
      end if;

    end loop;

    eam_pmdef_pub.update_pm_last_service_reading
    (      p_api_version => 1.0 ,
        p_init_msg_list     => 'F' ,
           p_commit            => 'F' ,
           p_validation_level  => 100 ,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_pm_schedule_id => l_pm_schedule_id
     );

     if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        l_update_failed := 'Y';
            RAISE FND_API.G_EXC_ERROR;
    end if;

    end if;

    l_prev_pm_schedule_id := p_pm_schedule_id;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         if  l_update_failed = 'Y' then
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_count := 1;
        x_msg_data := l_msg_data;
     else
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
     end if;

     when others then
       l_msg_count := 1;
       x_return_status := fnd_api.g_ret_sts_error;
           l_error_message := substrb(sqlerrm,1,512);
           x_msg_data      := l_error_message;

    -- End of API body.
END instantiate_PM_def;



/* This procedure instantiates a set of PM definitions for all asset_association_id's in the activity_assoc_id_tbl table.
 */

PROCEDURE instantiate_PM_Defs
(
        p_api_version                   IN      NUMBER                          ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL      ,
        x_return_status                 OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER                          ,
        x_msg_data                      OUT NOCOPY     VARCHAR2                        ,
        p_activity_assoc_id_tbl         IN      EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type
)
IS
        l_api_name                      CONSTANT VARCHAR2(30)   := 'instantiate_PM_defs';
        l_api_version                   CONSTANT NUMBER         := 1.0;
    l_activity_assoc_id        number;
    l_return_status            varchar2(1);
    l_msg_count            number;
    l_msg_data            varchar2(2000);

    --record and table type added to identify the instantiated pm templates
    TYPE l_pm_schedule_templ_rec_type is RECORD
    ( PM_SCHEDULE_ID                  NUMBER );

        TYPE l_pm_schedule_templ_tbl_type IS TABLE OF l_pm_schedule_templ_rec_type index by binary_integer;

    l_pm_schedule_templ_tbl l_pm_schedule_templ_tbl_type;

-- This following cursor, given an activity association instance (l_activity_assoc_id), it returns
-- all the pm templates that are associated with the SOURCE activity association TEMPLATES
-- of l_activity_assoc_id, that have auto_instantiation_flag as "Y"

    cursor pm_template_csr_old IS
        select pm_schedule_id
        from eam_pm_schedulings eps, mtl_eam_asset_activities meaa, eam_pm_set_names epsn
        where eps.activity_association_id=meaa.source_tmpl_id
    and meaa.activity_association_id=l_activity_assoc_id
        and eps.tmpl_flag='Y'
    and eps.auto_instantiation_flag='Y'
    and eps.set_name_id=epsn.set_name_id
    and (epsn.end_date is null or (epsn.end_date > sysdate and epsn.end_date > nvl(eps.to_effective_date, sysdate)));

    cursor pm_template_csr IS
        select distinct eps.pm_schedule_id
        from eam_pm_schedulings eps, eam_pm_activities epa,mtl_eam_asset_activities meaa, eam_pm_set_names epsn
        where eps.pm_schedule_id=epa.pm_schedule_id
    and epa.activity_association_id=meaa.source_tmpl_id
    and meaa.activity_association_id=l_activity_assoc_id
        and eps.tmpl_flag='Y'
    and eps.auto_instantiation_flag='Y'
    and eps.set_name_id=epsn.set_name_id
    and (epsn.end_date is null or (epsn.end_date > sysdate and epsn.end_date > nvl(eps.to_effective_date, sysdate)));

    l_new_pm_schedule_id number;
    l_pm_schedule_id number;
    l_pm_template_instantiated varchar2(1);
    k number :=0; -- for bug 7230256

BEGIN
        -- Standard Start of API savepoint
    SAVEPOINT   instantiate_PM_Defs_pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (        l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- API body


    if p_activity_assoc_id_tbl.count>0 then

        for i in p_activity_assoc_id_tbl.first..p_activity_assoc_id_tbl.last loop
        l_activity_assoc_id:=p_activity_assoc_id_tbl(i);

        for l_pm_row in pm_template_csr loop
            --defaulting the flag
            l_pm_template_instantiated := 'N';

            --To check whether the template is already instantiated
            if l_pm_schedule_templ_tbl.count >0 then

                   for jj in l_pm_schedule_templ_tbl.first..l_pm_schedule_templ_tbl.last loop

                if l_pm_schedule_templ_tbl(jj).pm_schedule_id = l_pm_row.pm_schedule_id then
                    l_pm_template_instantiated := 'Y';
                end if;

                  end loop;
              end if;

        --instantiate the pm def only if the pm template is not earlier instantiated
           if l_pm_template_instantiated = 'N' then
                    instantiate_PM_def
                    (
            p_activity_assoc_id => l_activity_assoc_id,
                    p_pm_schedule_id => l_pm_row.pm_schedule_id,
                    x_return_status => l_return_status,
                    x_new_pm_schedule_id => l_new_pm_schedule_id,
            x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data
                    );

             if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                 x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;
                 exit;
             end if;

        	l_pm_schedule_templ_tbl(k).pm_schedule_id := l_pm_row.pm_schedule_id; -- replaced i with k for bug 7230256
                k := k + 1; --for bug 7230256

        end if;

        end loop;

    end loop;

    end if;
        -- End of API body.
        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.get
        (       p_msg_index_out                 =>      x_msg_count             ,
                        p_data                  =>      x_msg_data
        );
    x_msg_data := substr(x_msg_data,1,2000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO instantiate_PM_Defs_pvt;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.get
                (       p_msg_index_out                 =>      x_msg_count             ,
                                p_data                  =>      x_msg_data
                );
        x_msg_data := substr(x_msg_data,1,2000);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO instantiate_PM_Defs_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.get
                (       p_msg_index_out                 =>      x_msg_count             ,
                                p_data                  =>      x_msg_data
                );
        x_msg_data := substr(x_msg_data,1,2000);
        WHEN OTHERS THEN
                ROLLBACK TO instantiate_PM_Defs_pvt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.get
                (       p_msg_index_out                 =>      x_msg_count             ,
                                p_data                  =>      x_msg_data
                );
        x_msg_data := substr(x_msg_data,1,2000);
END instantiate_PM_Defs;




PROCEDURE create_PM_def
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE
,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                 OUT NOCOPY     VARCHAR2
,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
        p_pm_schedule_rec                IN      pm_scheduling_rec_type,
    p_pm_activities_tbl        IN       pm_activities_grp_tbl_type,
        p_pm_day_interval_rules_tbl      IN      pm_rule_tbl_type,
        p_pm_runtime_rules_tbl          IN      pm_rule_tbl_type,
        p_pm_list_date_rules_tbl          IN      pm_rule_tbl_type,
        x_new_pm_schedule_id            OUT NOCOPY     NUMBER     -- this is the pm_schedule_id of the newly created pm schedule
) is


l_api_name            CONSTANT VARCHAR2(30)    := 'create_PM_def';
l_api_version               CONSTANT NUMBER         := 1.0;
l_pm_schedule_id        number;
i                number;
l_validated            boolean;
l_reason_failed            varchar2(30);
l_rule_id            number;
x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);
l_act_names             varchar2(500);
l_message        varchar2(30);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    create_PM_def_pub;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (     l_api_version            ,
                                         p_api_version            ,
                                       l_api_name             ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body



-- validate header and all rules
    l_validated:=validate_pm_header_and_rules
    (
            p_pm_schedule_rec,
            p_pm_day_interval_rules_tbl,
            p_pm_runtime_rules_tbl,
            p_pm_list_date_rules_tbl,
            l_reason_failed
    );

    if (not l_validated) then
                FND_MESSAGE.SET_NAME ('EAM', l_reason_failed);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        end if;

    l_validated := validate_pm_activities
    (
        p_pm_activities_tbl,
        p_pm_runtime_rules_tbl,
        p_pm_schedule_rec,
        l_reason_failed,
        l_message,
        l_act_names
    );
    if (not l_validated) then
                FND_MESSAGE.SET_NAME ('EAM', l_reason_failed);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        end if;
     /* Validation generate_next_work_order */
    if ( not (p_pm_schedule_rec.generate_next_work_order  = 'Y'
            OR p_pm_schedule_rec.generate_next_work_order = 'N'
            OR p_pm_schedule_rec.generate_next_work_order is null)) then

     FND_MESSAGE.SET_NAME ('EAM', 'INVALID_GENERATE_NEXT_WORK_ORDER');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;

    end if;

    /* Validating the DFF */

    l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
            p_app_short_name    =>    'EAM',
            p_desc_flex_name    =>    'EAM_PM_SCHEDULE',
            p_ATTRIBUTE_CATEGORY    =>    p_pm_schedule_rec.attribute_category ,
            p_ATTRIBUTE1            =>    p_pm_schedule_rec.attribute1          ,
            p_ATTRIBUTE2            =>    p_pm_schedule_rec.attribute2           ,
            p_ATTRIBUTE3            =>    p_pm_schedule_rec.attribute3            ,
            p_ATTRIBUTE4            =>    p_pm_schedule_rec.attribute4            ,
            p_ATTRIBUTE5            =>    p_pm_schedule_rec.attribute5            ,
            p_ATTRIBUTE6            =>    p_pm_schedule_rec.attribute6            ,
            p_ATTRIBUTE7            =>    p_pm_schedule_rec.attribute7            ,
            p_ATTRIBUTE8            =>    p_pm_schedule_rec.attribute8            ,
            p_ATTRIBUTE9            =>    p_pm_schedule_rec.attribute9            ,
            p_ATTRIBUTE10           =>    p_pm_schedule_rec.attribute10           ,
            p_ATTRIBUTE11           =>    p_pm_schedule_rec.attribute11           ,
            p_ATTRIBUTE12           =>    p_pm_schedule_rec.attribute12           ,
            p_ATTRIBUTE13           =>    p_pm_schedule_rec.attribute13           ,
            p_ATTRIBUTE14           =>    p_pm_schedule_rec.attribute14           ,
            p_ATTRIBUTE15           =>    p_pm_schedule_rec.attribute15 ,
            x_error_segments    =>    x_error_segments ,
            x_error_message        =>    x_error_message);

    IF (not l_validated) THEN
          FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_DESC_FLEX');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG', x_error_message);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

        select eam_pm_schedulings_s.nextval into l_pm_schedule_id from dual;


    insert into eam_pm_schedulings (
         PM_SCHEDULE_ID,
         ACTIVITY_ASSOCIATION_ID,
         NON_SCHEDULED_FLAG,
         FROM_EFFECTIVE_DATE,
         TO_EFFECTIVE_DATE,
         RESCHEDULING_POINT,
         LEAD_TIME,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2                               ,
         ATTRIBUTE3                               ,
         ATTRIBUTE4                               ,
         ATTRIBUTE5                               ,
         ATTRIBUTE6                               ,
         ATTRIBUTE7                               ,
         ATTRIBUTE8                               ,
         ATTRIBUTE9                               ,
         ATTRIBUTE10                              ,
         ATTRIBUTE11                              ,
         ATTRIBUTE12                              ,
         ATTRIBUTE13                              ,
         ATTRIBUTE14                              ,
         ATTRIBUTE15                              ,
         DAY_TOLERANCE    ,
         SOURCE_CODE   ,
         SOURCE_LINE   ,
         DEFAULT_IMPLEMENT,
         WHICHEVER_FIRST  ,
         INCLUDE_MANUAL   ,
         SET_NAME_ID,
     SCHEDULING_METHOD_CODE,
     TYPE_CODE,
      NEXT_SERVICE_START_DATE,
      NEXT_SERVICE_END_DATE,
     SOURCE_TMPL_ID ,
     AUTO_INSTANTIATION_FLAG,
     NAME                  ,
     TMPL_FLAG            ,
     created_by,
     creation_date,
     last_update_login,
     last_updated_by,
     last_update_date,
     GENERATE_WO_STATUS,
     INTERVAL_PER_CYCLE,
     CURRENT_CYCLE,
     CURRENT_SEQ,
     CURRENT_WO_SEQ,
     BASE_DATE,
     BASE_READING,
     EAM_LAST_CYCLIC_ACT,
     MAINTENANCE_OBJECT_ID,
     MAINTENANCE_OBJECT_TYPE,
     /* added for PM Reviewer -- start-- */
     LAST_REVIEWED_DATE,
     Last_reviewed_by
/* ---PM reviewer--- end---- */,
        GENERATE_NEXT_WORK_ORDER )
    values (
     l_pm_schedule_id,
     p_pm_schedule_rec.ACTIVITY_ASSOCIATION_ID,
     p_pm_schedule_rec.NON_SCHEDULED_FLAG,
     p_pm_schedule_rec.FROM_EFFECTIVE_DATE,
     p_pm_schedule_rec.TO_EFFECTIVE_DATE,
     p_pm_schedule_rec.RESCHEDULING_POINT,
     p_pm_schedule_rec.LEAD_TIME,
     p_pm_schedule_rec.ATTRIBUTE_CATEGORY,
     p_pm_schedule_rec.ATTRIBUTE1,
     p_pm_schedule_rec.ATTRIBUTE2                               ,
     p_pm_schedule_rec.ATTRIBUTE3                               ,
     p_pm_schedule_rec.ATTRIBUTE4                               ,
     p_pm_schedule_rec.ATTRIBUTE5                               ,
     p_pm_schedule_rec.ATTRIBUTE6                               ,
     p_pm_schedule_rec.ATTRIBUTE7                               ,
     p_pm_schedule_rec.ATTRIBUTE8                               ,
     p_pm_schedule_rec.ATTRIBUTE9                               ,
     p_pm_schedule_rec.ATTRIBUTE10                              ,
     p_pm_schedule_rec.ATTRIBUTE11                              ,
     p_pm_schedule_rec.ATTRIBUTE12                              ,
     p_pm_schedule_rec.ATTRIBUTE13                              ,
     p_pm_schedule_rec.ATTRIBUTE14                              ,
     p_pm_schedule_rec.ATTRIBUTE15                              ,
     p_pm_schedule_rec.DAY_TOLERANCE    ,
     p_pm_schedule_rec.SOURCE_CODE   ,
     p_pm_schedule_rec.SOURCE_LINE   ,
     p_pm_schedule_rec.DEFAULT_IMPLEMENT,
     p_pm_schedule_rec.WHICHEVER_FIRST  ,
     p_pm_schedule_rec.INCLUDE_MANUAL   ,
     p_pm_schedule_rec.SET_NAME_ID,
     p_pm_schedule_rec.SCHEDULING_METHOD_CODE ,
    p_pm_schedule_rec.TYPE_CODE,
    p_pm_schedule_rec.NEXT_SERVICE_START_DATE,
     p_pm_schedule_rec.NEXT_SERVICE_END_DATE,
        p_pm_schedule_rec.SOURCE_TMPL_ID ,
        p_pm_schedule_rec.AUTO_INSTANTIATION_FLAG,
        p_pm_schedule_rec.NAME                  ,
        p_pm_schedule_rec.TMPL_FLAG            ,
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id,
    fnd_global.user_id,
    sysdate,
    p_pm_schedule_rec.GENERATE_WO_STATUS  ,
    p_pm_schedule_rec.INTERVAL_PER_CYCLE   ,
    p_pm_schedule_rec.CURRENT_CYCLE        ,
    p_pm_schedule_rec.CURRENT_SEQ          ,
    p_pm_schedule_rec.CURRENT_WO_SEQ       ,
    p_pm_schedule_rec.BASE_DATE            ,
    p_pm_schedule_rec.BASE_READING         ,
    p_pm_schedule_rec.EAM_LAST_CYCLIC_ACT  ,
    p_pm_schedule_rec.MAINTENANCE_OBJECT_ID ,
    p_pm_schedule_rec.MAINTENANCE_OBJECT_TYPE,
    /* added for PM Reviewer -- start-- */
     p_pm_schedule_rec.LAST_REVIEWED_DATE,
     p_pm_schedule_rec.Last_reviewed_by,
    /* ---PM reviewer--- end---- */
     p_pm_schedule_rec.generate_next_work_order );

    i:=1;
    while (p_pm_activities_tbl.exists(i))    loop
    insert into eam_pm_activities(
              pm_schedule_id,
              activity_association_id,
              interval_multiple,
              allow_repeat_in_cycle,
              day_tolerance,
              created_by,
              creation_date,
              last_update_login,
              last_update_date,
              last_updated_by
              )
        values(
            l_pm_schedule_id,
            p_pm_activities_tbl(i).activity_association_id,
            p_pm_activities_tbl(i).interval_multiple,
                p_pm_activities_tbl(i).allow_repeat_in_cycle,
            p_pm_activities_tbl(i).day_tolerance,
            fnd_global.user_id,
                    sysdate,
                    fnd_global.login_id,
                    sysdate    ,
                    fnd_global.user_id
           );
        i:=i+1;
    end loop;

    /*FP of R12 bug 9744000 start */
       eam_pmdef_pub.update_pm_last_cyclic_act
       (  p_api_version => 1.0 ,
         p_init_msg_list     => 'F' ,
         p_commit            => 'F' ,
         p_validation_level  => 100 ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data ,
         p_pm_schedule_id => l_pm_schedule_id
        );

      if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
      end if;
     /*bug 9744000 end*/


    i:=1;
    while (p_pm_day_interval_rules_tbl.exists(i))    loop

        insert into eam_pm_scheduling_rules
                (RULE_ID,
                                PM_SCHEDULE_ID,
                                RULE_TYPE,
                                DAY_INTERVAL,
                                METER_ID  ,
                                RUNTIME_INTERVAL,
                                CREATED_BY         ,
                                CREATION_DATE     ,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                EFFECTIVE_READING_FROM ,
                                EFFECTIVE_READING_TO  ,
                                EFFECTIVE_DATE_FROM  ,
                                EFFECTIVE_DATE_TO   ,
                                LIST_DATE          ,
                                LIST_DATE_DESC
                )
                values
                                (eam_pm_scheduling_rules_s.nextval,
                l_pm_schedule_id,
                                p_pm_day_interval_rules_tbl(i).RULE_TYPE,
                                p_pm_day_interval_rules_tbl(i).DAY_INTERVAL,
                                p_pm_day_interval_rules_tbl(i).METER_ID  ,
                                p_pm_day_interval_rules_tbl(i).RUNTIME_INTERVAL,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.login_id,
                                sysdate    ,
                                fnd_global.user_id,
                                p_pm_day_interval_rules_tbl(i).EFFECTIVE_READING_FROM ,
                                p_pm_day_interval_rules_tbl(i).EFFECTIVE_READING_TO  ,
                                p_pm_day_interval_rules_tbl(i).EFFECTIVE_DATE_FROM  ,
                                p_pm_day_interval_rules_tbl(i).EFFECTIVE_DATE_TO   ,
                                p_pm_day_interval_rules_tbl(i).LIST_DATE          ,
                                p_pm_day_interval_rules_tbl(i).LIST_DATE_DESC
                );

        i:=i+1;
    end loop;

    i:=1;
    while (p_pm_runtime_rules_tbl.exists(i))    loop

        insert into eam_pm_scheduling_rules
                                ( RULE_ID,
                PM_SCHEDULE_ID,
                                RULE_TYPE,
                                DAY_INTERVAL,
                                METER_ID  ,
                                RUNTIME_INTERVAL,
                                CREATED_BY         ,
                                CREATION_DATE     ,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                EFFECTIVE_READING_FROM ,
                                EFFECTIVE_READING_TO  ,
                                EFFECTIVE_DATE_FROM  ,
                                EFFECTIVE_DATE_TO   ,
                                LIST_DATE          ,
                                LIST_DATE_DESC
                )
                        values
                                (eam_pm_scheduling_rules_s.nextval,
                l_pm_schedule_id,
                                p_pm_runtime_rules_tbl(i).RULE_TYPE,
                                p_pm_runtime_rules_tbl(i).DAY_INTERVAL,
                                p_pm_runtime_rules_tbl(i).METER_ID  ,
                                p_pm_runtime_rules_tbl(i).RUNTIME_INTERVAL,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.login_id,
                                sysdate    ,
                                fnd_global.user_id,
                                p_pm_runtime_rules_tbl(i).EFFECTIVE_READING_FROM ,
                                p_pm_runtime_rules_tbl(i).EFFECTIVE_READING_TO  ,
                                p_pm_runtime_rules_tbl(i).EFFECTIVE_DATE_FROM  ,
                                p_pm_runtime_rules_tbl(i).EFFECTIVE_DATE_TO   ,
                                p_pm_runtime_rules_tbl(i).LIST_DATE          ,
                                p_pm_runtime_rules_tbl(i).LIST_DATE_DESC
                                );
        i:=i+1;
    end loop;

    /*FP of R12 bug 9744000 start*/
      if(p_pm_runtime_rules_tbl.count <> 0) then
        eam_pmdef_pub.update_pm_last_service_reading
	( p_api_version => 1.0 ,
		p_init_msg_list     => 'F' ,
	  p_commit            => 'F' ,
	  p_validation_level  => 100 ,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_pm_schedule_id => l_pm_schedule_id
	 );

	 if x_return_status <> FND_API.G_RET_STS_SUCCESS then
               RAISE FND_API.G_EXC_ERROR;
	 end if;
       end if;
        /*bug 9744000 end*/

    i:=1;
    while (p_pm_list_date_rules_tbl.exists(i))    loop

        insert into eam_pm_scheduling_rules
                                ( RULE_ID,
                PM_SCHEDULE_ID,
                                RULE_TYPE,
                                DAY_INTERVAL,
                                METER_ID  ,
                                RUNTIME_INTERVAL,
                                CREATED_BY         ,
                                CREATION_DATE     ,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                EFFECTIVE_READING_FROM ,
                                EFFECTIVE_READING_TO  ,
                                EFFECTIVE_DATE_FROM  ,
                                EFFECTIVE_DATE_TO   ,
                                LIST_DATE          ,
                                LIST_DATE_DESC
                )
                        values
                                (eam_pm_scheduling_rules_s.nextval,
                l_pm_schedule_id,
                                p_pm_list_date_rules_tbl(i).RULE_TYPE,
                                p_pm_list_date_rules_tbl(i).DAY_INTERVAL,
                                p_pm_list_date_rules_tbl(i).METER_ID  ,
                                p_pm_list_date_rules_tbl(i).RUNTIME_INTERVAL,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.login_id,
                                sysdate    ,
                                fnd_global.user_id,
                                p_pm_list_date_rules_tbl(i).EFFECTIVE_READING_FROM ,
                                p_pm_list_date_rules_tbl(i).EFFECTIVE_READING_TO  ,
                                p_pm_list_date_rules_tbl(i).EFFECTIVE_DATE_FROM  ,
                                p_pm_list_date_rules_tbl(i).EFFECTIVE_DATE_TO   ,
                                p_pm_list_date_rules_tbl(i).LIST_DATE          ,
                                p_pm_list_date_rules_tbl(i).LIST_DATE_DESC
                                );
        i:=i+1;
    end loop;
    x_new_pm_schedule_id:=l_pm_schedule_id;

    -- End of API body.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.get
        (      p_msg_index_out             =>      x_msg_count         ,
                p_data              =>      x_msg_data
        );
    x_msg_data := substr(x_msg_data,1,2000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_PM_def_pub;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_PM_def_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN OTHERS THEN
        ROLLBACK TO create_PM_def_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
END create_PM_def;



procedure update_pm_def
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status                 OUT NOCOPY     VARCHAR2 ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
        p_pm_schedule_rec               IN      pm_scheduling_rec_type:=null,
    p_pm_activities_tbl        IN      pm_activities_grp_tbl_type,
        p_pm_day_interval_rules_tbl     IN      pm_rule_tbl_type,
        p_pm_runtime_rules_tbl          IN      pm_rule_tbl_type,
        p_pm_list_date_rules_tbl        IN      pm_rule_tbl_type
)
is
l_api_name            CONSTANT VARCHAR2(30)    :='update_pm_def';
l_api_version               CONSTANT NUMBER         := 1.0;
l_pm_header            pm_scheduling_rec_type;
l_day_interval_counter        number;
l_runtime_counter        number;
l_list_date_counter        number;
l_pm_rule            pm_rule_rec_type;
l_selected_day_rules_tbl    pm_rule_tbl_type;
l_selected_runtime_rules_tbl    pm_rule_tbl_type;
l_selected_list_date_rules_tbl  pm_rule_tbl_type;
l_merged_day_rules_tbl         pm_rule_tbl_type;
l_merged_runtime_rules_tbl    pm_rule_tbl_type;
l_merged_list_date_rules_tbl    pm_rule_tbl_type;
l_validated            boolean;
l_validated_act            boolean;
l_reason_failed            varchar2(30);
l_current_rules_tbl        pm_rule_tbl_type;
n                number;
i                number;
l_pm_schedule_id        number;
l_rule_id            number;
l_act_names             varchar2(500);
l_message        varchar2(30);

x_error_segments        NUMBER;
x_error_message         VARCHAR2(5000);


BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    update_pm_def_pub;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (     l_api_version            ,
                                         p_api_version            ,
                                       l_api_name             ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    if (p_pm_schedule_rec.pm_schedule_id is null) then
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_PM_SCHEDULE_ID_MISSING');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    else
        l_pm_schedule_id:=p_pm_schedule_rec.pm_schedule_id;
    end if;


    /* Validation generate_next_work_order */
       if ( not (p_pm_schedule_rec.generate_next_work_order  = 'Y'
            OR p_pm_schedule_rec.generate_next_work_order = 'N'
            OR p_pm_schedule_rec.generate_next_work_order is null)) then
            FND_MESSAGE.SET_NAME ('EAM', 'INVALID_GENERATE_NEXT_WORK_ORDER');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;

    end if;
    /* Validating the DFF */

    l_validated := EAM_COMMON_UTILITIES_PVT.validate_desc_flex_field (
            p_app_short_name    =>    'EAM',
            p_desc_flex_name    =>    'EAM_PM_SCHEDULE',
            p_ATTRIBUTE_CATEGORY    =>    p_pm_schedule_rec.attribute_category ,
            p_ATTRIBUTE1            =>    p_pm_schedule_rec.attribute1          ,
            p_ATTRIBUTE2            =>    p_pm_schedule_rec.attribute2           ,
            p_ATTRIBUTE3            =>    p_pm_schedule_rec.attribute3            ,
            p_ATTRIBUTE4            =>    p_pm_schedule_rec.attribute4            ,
            p_ATTRIBUTE5            =>    p_pm_schedule_rec.attribute5            ,
            p_ATTRIBUTE6            =>    p_pm_schedule_rec.attribute6            ,
            p_ATTRIBUTE7            =>    p_pm_schedule_rec.attribute7            ,
            p_ATTRIBUTE8            =>    p_pm_schedule_rec.attribute8            ,
            p_ATTRIBUTE9            =>    p_pm_schedule_rec.attribute9            ,
            p_ATTRIBUTE10           =>    p_pm_schedule_rec.attribute10           ,
            p_ATTRIBUTE11           =>    p_pm_schedule_rec.attribute11           ,
            p_ATTRIBUTE12           =>    p_pm_schedule_rec.attribute12           ,
            p_ATTRIBUTE13           =>    p_pm_schedule_rec.attribute13           ,
            p_ATTRIBUTE14           =>    p_pm_schedule_rec.attribute14           ,
            p_ATTRIBUTE15           =>    p_pm_schedule_rec.attribute15 ,
            x_error_segments    =>    x_error_segments ,
            x_error_message        =>    x_error_message);
    IF (not l_validated) THEN
        FND_MESSAGE.SET_NAME ('EAM', x_error_message);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;




    l_validated:=validate_pm_header_and_rules(p_pm_schedule_rec,
                p_pm_day_interval_rules_tbl,
                p_pm_runtime_rules_tbl,
                p_pm_list_date_rules_tbl,
                l_reason_failed);
    l_validated_act := validate_pm_activities
    (
        p_pm_activities_tbl,
        p_pm_runtime_rules_tbl,
        p_pm_schedule_rec,
        l_reason_failed,
        l_message,
        l_act_names
    );
      if (l_validated  and  l_validated_act) then

    update eam_pm_schedulings set
        ACTIVITY_ASSOCIATION_ID=p_pm_schedule_rec.ACTIVITY_ASSOCIATION_ID,
        NON_SCHEDULED_FLAG=p_pm_schedule_rec.NON_SCHEDULED_FLAG,
        FROM_EFFECTIVE_DATE=p_pm_schedule_rec.FROM_EFFECTIVE_DATE,
        TO_EFFECTIVE_DATE=p_pm_schedule_rec.TO_EFFECTIVE_DATE,
        RESCHEDULING_POINT=p_pm_schedule_rec.RESCHEDULING_POINT,
        LEAD_TIME=p_pm_schedule_rec.LEAD_TIME,
        ATTRIBUTE_CATEGORY=p_pm_schedule_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1=p_pm_schedule_rec.ATTRIBUTE1,
        ATTRIBUTE2=p_pm_schedule_rec.ATTRIBUTE2                    ,
        ATTRIBUTE3=p_pm_schedule_rec.ATTRIBUTE3                               ,
        ATTRIBUTE4=p_pm_schedule_rec.ATTRIBUTE4                               ,
        ATTRIBUTE5=p_pm_schedule_rec.ATTRIBUTE5                               ,
        ATTRIBUTE6=p_pm_schedule_rec.ATTRIBUTE6                               ,
        ATTRIBUTE7=p_pm_schedule_rec.ATTRIBUTE7                               ,
        ATTRIBUTE8=p_pm_schedule_rec.ATTRIBUTE8                               ,
        ATTRIBUTE9=p_pm_schedule_rec.ATTRIBUTE9                               ,
        ATTRIBUTE10=p_pm_schedule_rec.ATTRIBUTE10                              ,
        ATTRIBUTE11=p_pm_schedule_rec.ATTRIBUTE11                              ,
        ATTRIBUTE12=p_pm_schedule_rec.ATTRIBUTE12                              ,
        ATTRIBUTE13=p_pm_schedule_rec.ATTRIBUTE13                              ,
        ATTRIBUTE14=p_pm_schedule_rec.ATTRIBUTE14                              ,
        ATTRIBUTE15=p_pm_schedule_rec.ATTRIBUTE15                              ,
        DAY_TOLERANCE    =p_pm_schedule_rec.DAY_TOLERANCE   ,
        SOURCE_CODE=p_pm_schedule_rec.SOURCE_CODE   ,
        SOURCE_LINE=  p_pm_schedule_rec.SOURCE_LINE   ,
        DEFAULT_IMPLEMENT=p_pm_schedule_rec.DEFAULT_IMPLEMENT,
        WHICHEVER_FIRST = p_pm_schedule_rec.WHICHEVER_FIRST  ,
        INCLUDE_MANUAL  = p_pm_schedule_rec.INCLUDE_MANUAL   ,
        SET_NAME_ID=p_pm_schedule_rec.SET_NAME_ID,
        SCHEDULING_METHOD_CODE= p_pm_schedule_rec.SCHEDULING_METHOD_CODE ,
        TYPE_CODE=p_pm_schedule_rec.TYPE_CODE,
    NEXT_SERVICE_START_DATE=p_pm_schedule_rec.NEXT_SERVICE_START_DATE,
    NEXT_SERVICE_END_DATE=p_pm_schedule_rec.NEXT_SERVICE_END_DATE,
    SOURCE_TMPL_ID = p_pm_schedule_rec.SOURCE_TMPL_ID,
     AUTO_INSTANTIATION_FLAG          =p_pm_schedule_rec.AUTO_INSTANTIATION_FLAG,
     NAME  =p_pm_schedule_rec.NAME,
     TMPL_FLAG   =p_pm_schedule_rec.TMPL_FLAG,
     GENERATE_WO_STATUS = p_pm_schedule_rec.GENERATE_WO_STATUS, -- bug 9823755
    LAST_REVIEWED_BY = p_pm_schedule_rec.LAST_REVIEWED_BY,
    LAST_REVIEWED_DATE = p_pm_schedule_rec.LAST_REVIEWED_DATE ,
        --CREATED_BY=fnd_global.user_id,
        --CREATION_DATE=sysdate,
        LAST_UPDATE_LOGIN=fnd_global.login_id,
        LAST_UPDATED_BY=fnd_global.user_id,
        LAST_UPDATE_DATE=sysdate    ,
        generate_next_work_order =p_pm_schedule_rec.generate_next_work_order
        where PM_SCHEDULE_ID=l_pm_schedule_id;

    delete from eam_pm_activities
    where pm_schedule_id=l_pm_schedule_id;

    n:=1;
    while (p_pm_activities_tbl.exists(n)) loop /*FP of 7030271*/

        insert into eam_pm_activities(
              pm_schedule_id,
              activity_association_id,
              interval_multiple,
              allow_repeat_in_cycle,
              day_tolerance,
              created_by,
              creation_date,
              last_update_login,
              last_update_date,
              last_updated_by
              )
        values(
            l_pm_schedule_id,
            p_pm_activities_tbl(n).activity_association_id,
            p_pm_activities_tbl(n).interval_multiple,
                p_pm_activities_tbl(n).allow_repeat_in_cycle,
            p_pm_activities_tbl(n).day_tolerance,
            fnd_global.user_id,
                    sysdate,
                    fnd_global.login_id,
                    sysdate    ,
                    fnd_global.user_id
           );
    n:=n+1;

    end loop;

     /*bug 9744000 start */
       eam_pmdef_pub.update_pm_last_cyclic_act
       (  p_api_version => 1.0 ,
         p_init_msg_list     => 'F' ,
         p_commit            => 'F' ,
         p_validation_level  => 100 ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data ,
         p_pm_schedule_id => l_pm_schedule_id
        );

      if x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
      end if;
     /*bug 9744000 end*/

    delete from eam_pm_scheduling_rules
    where pm_schedule_id=l_pm_schedule_id;

      for i in 1..3 loop
    if (i=1) then
        l_current_rules_tbl:=p_pm_day_interval_rules_tbl;
    elsif (i=2) then
        l_current_rules_tbl:=p_pm_runtime_rules_tbl;
    elsif (i=3) then
        l_current_rules_tbl:=p_pm_list_date_rules_tbl;
    end if;
    n:=1;
    while (l_current_rules_tbl.exists(n)) loop

                    select eam_pm_scheduling_rules_s.nextval into l_rule_id from dual; --Bug#5453536

            insert into eam_pm_scheduling_rules
                                ( rule_id,
                PM_SCHEDULE_ID,
                                RULE_TYPE,
                                DAY_INTERVAL,
                                METER_ID  ,
                                RUNTIME_INTERVAL,
                                CREATED_BY         ,
                                CREATION_DATE     ,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                EFFECTIVE_READING_FROM ,
                                EFFECTIVE_READING_TO  ,
                                EFFECTIVE_DATE_FROM  ,
                                EFFECTIVE_DATE_TO   ,
                                LIST_DATE          ,
                                LIST_DATE_DESC
                )
                        values
                                (l_rule_id,
                l_pm_schedule_id,
                                l_current_rules_tbl(n).RULE_TYPE,
                                l_current_rules_tbl(n).DAY_INTERVAL,
                                l_current_rules_tbl(n).METER_ID  ,
                                l_current_rules_tbl(n).RUNTIME_INTERVAL,
                                fnd_global.user_id,
                                sysdate,
                                fnd_global.login_id,
                                sysdate    ,
                                fnd_global.user_id,
                                l_current_rules_tbl(n).EFFECTIVE_READING_FROM ,
                                l_current_rules_tbl(n).EFFECTIVE_READING_TO  ,
                                l_current_rules_tbl(n).EFFECTIVE_DATE_FROM  ,
                                l_current_rules_tbl(n).EFFECTIVE_DATE_TO   ,
                                l_current_rules_tbl(n).LIST_DATE          ,
                                l_current_rules_tbl(n).LIST_DATE_DESC
                                );
        n:=n+1;
    end loop;    -- end while loop that loops through each record
      end loop;         -- end for loop that loop through 3 tables

    /*FP of R12 bug 9744000 start*/
      if(p_pm_runtime_rules_tbl.count <> 0) then
        eam_pmdef_pub.update_pm_last_service_reading
	( p_api_version => 1.0 ,
 	  p_init_msg_list     => 'F' ,
	  p_commit            => 'F' ,
	  p_validation_level  => 100 ,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
 	  x_msg_data => x_msg_data,
	  p_pm_schedule_id => l_pm_schedule_id
	 );

	 if x_return_status <> FND_API.G_RET_STS_SUCCESS then
               RAISE FND_API.G_EXC_ERROR;
	 end if;
       end if;
        /*bug 9744000 end*/

    else   -- rules did not validate
                FND_MESSAGE.SET_NAME ('EAM', l_reason_failed);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    end if;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.get
        (      p_msg_index_out             =>      x_msg_count         ,
                p_data              =>      x_msg_data
        );
    x_msg_data := substr(x_msg_data,1,2000);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_pm_def_pub;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_pm_def_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN OTHERS THEN
        ROLLBACK TO update_pm_def_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
END update_PM_def;



function validate_pm_header
(
  p_pm_schedule_rec               IN      pm_scheduling_rec_type,
  x_reason_failed                 OUT NOCOPY     varchar2
) return BOOLEAN
is

l_count                number;
l_asset_activity_id        number;
l_last_service_start_date     date;
l_last_service_end_date         date;
l_pm_schedule_id        number;
l_lookup_type                   mfg_lookups.lookup_type%type;
l_status_id number;


begin
-- Check all the "not null" fields
    if (p_pm_schedule_rec.rescheduling_point is null
        or p_pm_schedule_rec.set_name_id is null
        or p_pm_schedule_rec.type_code is null
        or p_pm_schedule_rec.scheduling_method_code is null
        or p_pm_schedule_rec.whichever_first is null
        or p_pm_schedule_rec.name is null
        or p_pm_schedule_rec.generate_wo_status is null
        or p_pm_schedule_rec.interval_per_cycle is null
        or p_pm_schedule_rec.maintenance_object_id is null
        or p_pm_schedule_rec.maintenance_object_type is null)
    then
        x_reason_failed:='EAM_PM_HD_NOT_ENOUGH_PARAM';
        return false;
    end if;


-- default_implement(Y/N), whichever_first(Y/N), include_manual(Y/N),  type_code(list_dates, rule_based ) scheduling_method_code(forward, backward)

    if (p_pm_schedule_rec.default_implement is not null
        and p_pm_schedule_rec.default_implement <> 'Y'
        and p_pm_schedule_rec.default_implement <> 'N') then
        x_reason_failed:='EAM_PM_HD_INVALID_DEFAULT_IMPL';
        return false;
    end if;

     /* added for PM Reviewer -- start-- */

     if( (p_pm_schedule_rec.Last_reviewed_by is null and p_pm_schedule_rec.Last_reviewed_date is not null)
        or (p_pm_schedule_rec.Last_reviewed_by is not null and p_pm_schedule_rec.Last_reviewed_date is null)) then
        x_reason_failed:='EAM_PM_REVIEW_BY_DATE';
        return false;
     else
        if (p_pm_schedule_rec.Last_reviewed_by is not null and p_pm_schedule_rec.Last_reviewed_date is null) then
                if(p_pm_schedule_rec.Last_reviewed_date<>trunc(sysdate)) then
                    x_reason_failed:='EAM_PM_REVIEW_DATE_BY';
                    return false;
                end if ;
        end if;
     end if;


     /* ---PM reviewer--- end---- */

    if (p_pm_schedule_rec.whichever_first is not null
        and p_pm_schedule_rec.whichever_first <> 'Y'
        and p_pm_schedule_rec.whichever_first <> 'N') then
        x_reason_failed:='EAM_PM_HD_INVALID_WHICHEVER';
        return false;
    end if;

        if (p_pm_schedule_rec.include_manual is not null
        and p_pm_schedule_rec.include_manual <> 'Y'
            and p_pm_schedule_rec.include_manual <> 'N') then
                x_reason_failed:='EAM_PM_HD_INVALID_INC_MANUAL';
                return false;
        end if;


        /* Bug # 3840702 : Need to replace literals by bind variable */
    l_lookup_type := 'EAM_PM_TYPE';
    select count(*) into l_count
    from mfg_lookups
    where lookup_type = l_lookup_type
    and lookup_code=p_pm_schedule_rec.type_code;

    if (l_count=0) then
        x_reason_failed:='EAM_PM_HD_INVALID_PM_TYPE';
        return false;
    end if;

    l_lookup_type := 'EAM_PM_SCHEDULING_METHOD';
    select count(*) into l_count
    from mfg_lookups
    where lookup_type = l_lookup_type
    and lookup_code=p_pm_schedule_rec.scheduling_method_code;

    if (l_count=0) then
        x_reason_failed:='EAM_PM_HD_INVALID_SCH_METHOD';
        return false;
    end if;

-- header validation: when it's not a template, auto_instantiation flag must be 'N' or null
    if (p_pm_schedule_rec.tmpl_flag='N' and p_pm_schedule_rec.auto_instantiation_flag='Y') then
        x_reason_failed:='EAM_PM_HD_NOT_TMPL_INST';
        return false;
    end if;

-- header validation: effective to > effective from
    if (p_pm_schedule_rec.from_effective_date is not null
        and p_pm_schedule_rec.to_effective_date is not null
        and p_pm_schedule_rec.from_effective_date > p_pm_schedule_rec.to_effective_date)
    then
        x_reason_failed:='EAM_PM_HD_INVALID_DATES';
        return false;
    end if;

-- header validation: activity association id is valid
-- header validation: header effective from / to within asset activity effective from / to

-- header validation: Check that the asset activity has last service reading start/end date.
-- header validation : Check that the set name is valid
-- header validation : set name effective end date > sysdate
-- header validation: pm start and end date is within effective dates of set name

        select count(*) into l_count
        from eam_pm_set_names
        where set_name_id = p_pm_schedule_rec.set_name_id;

    if (l_count=0) then
        x_reason_failed:='EAM_PM_HD_INVALID_SET_NAME';
        return false;
    end if;



-- set name is unique for this asset activity association and for this type of tmpl_flag
-- (at most one template and one definition for each asset activity association)

    /* Bug # 3890075 : Modified the logic so that the query is executed only once. */

-- header validation: there can be only one default
       /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
-- header validation: PM Name must be unique
        /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
        BEGIN
           SELECT pm_schedule_id into l_pm_schedule_id
           FROM eam_pm_schedulings
           WHERE name=p_pm_schedule_rec.name
       AND tmpl_flag=p_pm_schedule_rec.tmpl_flag;

           if (p_pm_schedule_rec.pm_schedule_id is null) then
        x_reason_failed:='EAM_PM_HD_NAME_NOT_UNIQUE';
        return false;
           else
                if (l_pm_schedule_id <> p_pm_schedule_rec.pm_schedule_id) then
                    x_reason_failed:='EAM_PM_HD_NAME_NOT_UNIQUE';
                    return false;
                end if;
           end if;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
              null;
       WHEN TOO_MANY_ROWS THEN
          x_reason_failed:='EAM_PM_HD_NAME_NOT_UNIQUE';
          return false;
    END;

    --For list dates pm schedule cyclic attributes should have default values
	-- Bug 10334825 . Commented validation for Current Interval Count as per PM comment .
	if p_pm_schedule_rec.TYPE_CODE = 20  and
	   ( -- p_pm_schedule_rec.current_seq > 0 or
	     p_pm_schedule_rec.interval_per_cycle >1
	     or p_pm_schedule_rec.current_cycle > 1
		) then

	    x_reason_failed := 'EAM_PM_HD_LIST_DATES_VLD';
	    return false;

	end if;


    --New options of Base Date and meter are not applicable for list dates schedule type

       if p_pm_schedule_rec.type_code = 20 and p_pm_schedule_rec.rescheduling_point in (5,6) then
        x_reason_failed:='EAM_PM_HD_SCHED_TYPE_NA';
        return false;
       end if;

       --validation for current interval count cannot be greater than interval per cycle

       if p_pm_schedule_rec.current_seq > p_pm_schedule_rec.interval_per_cycle then
             x_reason_failed := 'EAM_PM_HD_CURRENT_SEQ';
         return false;
       end if;

       --validation for generate wo status

       begin

       SELECT status_id into l_status_id
       FROM EAM_WO_STATUSES_V
       WHERE ENABLED_FLAG='Y' AND SYSTEM_STATUS IN (1,3,6,17)
       and status_id=p_pm_schedule_rec.generate_wo_status;

       exception when no_data_found then
             x_reason_failed := 'EAM_PM_HD_INVALID_WO_STATUS';
         return false;
           when too_many_rows then
            null;
       end;

       return true;

end;


function validate_pm_day_interval_rule
(
        p_pm_rule_rec                   IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN
is
begin

-- rule type is day interval rule
    if (p_pm_rule_rec.rule_type is null or p_pm_rule_rec.rule_type<>1) then
        x_reason_failed:='EAM_PM_DAY_WRONG_RULE_TYPE';
        return false;
    end if;

-- day interval is not null
    if (p_pm_rule_rec.day_interval is null) then
        x_reason_failed:='EAM_PM_DAY_NO_DAY_INTERVAL';
        return false;
    end if;

-- meter id,  runtime_interval, effective_reading_from, and effective_reading_to, list_date, and list_date_desc must be null

    if (p_pm_rule_rec.meter_id is not null
        or p_pm_rule_rec.runtime_interval is not null
        or p_pm_rule_rec.effective_reading_from is not null
        or p_pm_rule_rec.effective_reading_to is not null
        or p_pm_rule_rec.list_date is not null
        or p_pm_rule_rec.list_date_desc is not null)
    then
        x_reason_failed:='EAM_PM_DAY_TOO_MANY_PARAMS';
        return false;
    end if;

-- effective to > effective from

    if (p_pm_rule_rec.effective_date_from is not null
        and p_pm_rule_rec.effective_date_to is not null
        and p_pm_rule_rec.effective_date_from > p_pm_rule_rec.effective_date_to) then
            x_reason_failed:='EAM_PM_DAY_INVALID_DATE';
            return false;
    end if;

    return true;


end;



function validate_pm_runtime_rule
(
        p_pm_rule_rec                   IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY      varchar2
) return BOOLEAN
is
    l_meter_id            number;
    l_value_change_dir        varchar2(1);
    l_count                number;
begin

-- rule type must be run time rule
    if (p_pm_rule_rec.rule_type is null or p_pm_rule_rec.rule_type<>2) then
        x_reason_failed:='EAM_PM_RUN_WRONG_RULE_TYPE';
        return false;
    end if;

-- not null: meter_id, runtime_interval not null
    if (p_pm_rule_rec.meter_id is null
        or p_pm_rule_rec.runtime_interval is null) then
        x_reason_failed:='EAM_PM_RUN_MISSING_PARAMS';
        return false;
    end if;

-- must be null: day_interval, effective_date_from, effective_date_to, list_date, list_date_desc
    if (p_pm_rule_rec.day_interval is not null
        or p_pm_rule_rec.effective_date_from is not null
        or p_pm_rule_rec.effective_date_to is not null
        or p_pm_rule_rec.list_date is not null
        or p_pm_rule_rec.list_date_desc is not null)
    then
        x_reason_failed:='EAM_PM_RUN_TOO_MANY_PARAMS';
        return false;
    end if;


-- validate that the meter id is valid
         --added for perofrmance issues
    select 1 into l_count from dual where exists
        (select COUNTER_ID from CSI_COUNTERS_B where counter_id =  p_pm_rule_rec.meter_id
         union
         select COUNTER_ID from CSI_COUNTER_TEMPLATE_B where counter_id =  p_pm_rule_rec.meter_id) ;


    if (l_count=0) then
        x_reason_failed:='EAM_PM_RUN_INVALID_METER_ID';
        return false;
    end if;

-- ascending: effective to > effective from, and vice versa

     --added for perofrmance issues
     select direction into l_value_change_dir from
           (select direction from CSI_COUNTERS_B where counter_id = p_pm_rule_rec.meter_id
                   union
                select direction from CSI_COUNTER_TEMPLATE_B where counter_id = p_pm_rule_rec.meter_id);

    if ((l_value_change_dir='A' -- ascending
         and p_pm_rule_rec.effective_reading_from > p_pm_rule_rec.effective_reading_to)
        or
        (l_value_change_dir='D' --descending
         and p_pm_rule_rec.effective_reading_to > p_pm_rule_rec.effective_reading_from))
    then
        x_reason_failed:='EAM_PM_RUN_INVALID_FROM_TO';
        return false;
    end if;

       /* Check for whether meter has last service reading has been moved
          to validate_pm_header_and_rules */

    return true;
end;



function validate_pm_list_date
(
        p_pm_rule_rec                   IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN
is
begin

-- rule_type must be list date
    if (p_pm_rule_rec.rule_type is null or p_pm_rule_rec.rule_type<>3) then
        x_reason_failed:='EAM_PM_LIST_WRONG_RULE_TYPE';
        return false;
    end if;

-- not null: list_date, (list_date_desc is not required)
    if (p_pm_rule_rec.list_date is null) then
        x_reason_failed:='EAM_PM_LIST_NO_DATE';
        return false;
    end if;

-- null: day_interval, meter_id, runtime_interval, effective_reading_from, effective_reading_to, effective_date_from, effective_date_to???
    if (p_pm_rule_rec.day_interval is not null
            or p_pm_rule_rec.meter_id is not null
            or p_pm_rule_rec.runtime_interval is not null
            or p_pm_rule_rec.effective_reading_from is not null
            or p_pm_rule_rec.effective_reading_to is not null
            or p_pm_rule_rec.effective_date_from is not null
            or p_pm_rule_rec.effective_date_to is not null) then
        x_reason_failed:='EAM_PM_LIST_TOO_MANY_PARAMS';
        return false;
    end if;


-- list date greater than sysdate
    if (trunc(p_pm_rule_rec.list_date) < trunc(sysdate)) then
        x_reason_failed:='EAM_PM_LIST_INVALID_DATE_PAST';
        return false;
    end if;

    return true;

end;



function validate_pm_day_interval_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY    varchar2
) return BOOLEAN
is
    i            number;
    j            number;
    k            number;
    l_temp_date_tbl     pm_date_tbl_type;
    l_sorted_date_tbl     pm_date_tbl_type;
    l_reason_failed     varchar2(30);
    l_validated         boolean;
    l_min_index         number;
    l_max_index         number;
    l_num_rules        number;
    l_num_sortable_rules     number;
    l_pm_rule_rec        pm_rule_rec_type;
begin
-- validate each day interval rule

    -- Go through the table one by one,
    -- validate each rule individually
    -- pick out the one(s) without effective_from or effective_date_to
    -- make sure that there can be at most one w/o effective_from_date and at most one w/o effective_date_to,
    --and copy the rest to another table.

        i:=1;   -- counter for all rules
    j:=1;   -- counter for sortable rules
        while (p_pm_rules_tbl.exists(i))        loop
        l_pm_rule_rec:=p_pm_rules_tbl(i);
        l_validated:=validate_pm_day_interval_rule(l_pm_rule_rec, l_reason_failed);
        if (not l_validated) then
            x_reason_failed:=l_reason_failed;
            return false;
        end if;

        -- At most one day interval rule can exist such that effective_date_from is null
        -- this rule is the first rule after sorting.
        if l_pm_rule_rec.effective_date_from is null then
            if (l_min_index is not null) then
                x_reason_failed:='EAM_PM_DAY_MANY_NO_FROM';
                return false;
            else
                l_min_index:=i;
            end if;
        end if;

                -- At most one day interval rule can exist such that effective_date_to is null
                -- this rule is the last rule after sorting.
        if l_pm_rule_rec.effective_date_to is null then
            if (l_max_index is not null) then
                x_reason_failed:='EAM_PM_DAY_MANY_NO_TO';
                return false;
            else
                l_max_index:=i;
            end if;
        end if;

        -- If both effective from and effective to are null, then only one day interval rule can exist
        if (l_min_index=l_max_index and i>1) then
            x_reason_failed:='EAM_PM_DAY_OVERLAP';
            return false;
        end if;

        -- If the both effective from and effective to are present,
        -- then put the index and start date of this record into
        -- another temp table for sorting.
        if ((l_max_index is null or l_max_index<>i)
                 and (l_min_index is null or l_min_index<>i)) then
            l_temp_date_tbl(j).index1:=i;
            l_temp_date_tbl(j).date1:=p_pm_rules_tbl(i).effective_date_from;
            j:=j+1;
        end if;

        i:=i+1;
    end loop;
    l_num_rules:=i-1;
    l_num_sortable_rules:=j-1;


-- validate: no overlap; at most one rule with no effective from, and at most one rule with no effective to.
    sort_table_by_date(l_temp_date_tbl, l_num_sortable_rules, l_sorted_date_tbl);

    -- If there is a rule w/o effective_to date, then put this rule's index and effective_from date
    -- as the last record in the sorted table
    if (l_max_index is not null) then
        l_sorted_date_tbl(l_num_sortable_rules+1).index1:=l_max_index;
        l_sorted_date_tbl(l_num_sortable_rules+1).date1:=p_pm_rules_tbl(l_max_index).effective_date_from;
    end if;

    -- First, check whether the first record (with no effective_date_from) overlaps with the next record
    if (l_min_index is not null and l_num_rules > 1
        and p_pm_rules_tbl(l_min_index).effective_date_to > p_pm_rules_tbl(l_sorted_date_tbl(1).index1).effective_date_from)
    then
        x_reason_failed:='EAM_PM_DAY_OVERLAP';
        return false;
    end if;


    k:=1;
    while (l_sorted_date_tbl.exists(k+1)) loop
        if (p_pm_rules_tbl(l_sorted_date_tbl(k).index1).effective_date_to > p_pm_rules_tbl(l_sorted_date_tbl(k+1).index1).effective_date_from)
        then
            x_reason_failed:='EAM_PM_DAY_OVERLAP';
            return false;
        end if;
        k:=k+1;

    end loop;
    return true;

end;



function validate_pm_runtime_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY    varchar2
) return BOOLEAN
is
    i            number;
    j            number;
    k            number;
    l_temp_num_tbl         pm_num_tbl_type;
    l_sorted_num_tbl     pm_num_tbl_type;
    l_reason_failed     varchar2(30);
    l_validated         boolean;
    l_min_index         number;
    l_max_index         number;
    l_num_rules        number;
    l_num_sortable_rules     number;
    l_pm_rule_rec        pm_rule_rec_type;
    l_meter_id_tbl        pm_num_tbl_type;
    l_num_rules_for_meter   pm_num_tbl_type;
    l_sorted_meter_id_tbl   pm_num_tbl_type;
    l_meter_from_tbl         pm_num_tbl_type;
    l_current_meter_index    number;
    l_start_rule_index    number;
    l_end_rule_index    number;
    l_current_rule_index    number;
    l_temp_reading_from_tbl        pm_num_tbl_type;
    l_sorted_meter_from_tbl        pm_num_tbl_type;
    l_num_meters        number;
    l_num_rules_counter    number;
    l_cur_p_tbl_rule_index    number;


begin


        i:=1;  -- counter for all rules

    -- First, validate each rule, and put meter id's into a meter id table
    while (p_pm_rules_tbl.exists(i)) loop

        l_pm_rule_rec:=p_pm_rules_tbl(i);
        l_validated:=validate_pm_runtime_rule(l_pm_rule_rec, l_reason_failed);
        if (not l_validated) then
            x_reason_failed:=l_reason_failed;
            return false;
        end if;

        l_meter_id_tbl(i).index1:=i;
        l_meter_id_tbl(i).num1:=p_pm_rules_tbl(i).meter_id;
        i:=i+1;
    end loop;

    l_num_rules:=i-1;

    -- Now, l_meter_id_tbl.index is the index of p_pm_rules_tbl, and l_meter_id_tbl.num1
    -- is p_pm_rules_tbl.meter_id

    -- sort the meter id table by meter id

    sort_table_by_number(l_meter_id_tbl, l_num_rules, l_sorted_meter_id_tbl);

    -- Go through sorted meter id to determine the number of meters involved
    -- and how many rules there are for each meter
    -- put different meter rules effective reading from into different sections of
    -- l_meter_from_tbl


    i:=1;
    l_num_meters:=0;

    while (l_sorted_meter_id_tbl.exists(i)) loop
        if (i=1) then
            l_num_meters:=1;
            l_num_rules_for_meter(l_num_meters).num1:=1;
        elsif (l_sorted_meter_id_tbl(i).num1<> l_sorted_meter_id_tbl(i-1).num1) then
            l_num_meters:=l_num_meters+1;
                        l_num_rules_for_meter(l_num_meters).num1:=1;
        else
            l_num_rules_for_meter(l_num_meters).num1:=l_num_rules_for_meter(l_num_meters).num1+1;
        end if;

        -- following two lines put index and reading_from into l_meter_from_tbl
        l_meter_from_tbl(i).index1:=l_sorted_meter_id_tbl(i).index1;
        l_meter_from_tbl(i).num1:=p_pm_rules_tbl(l_sorted_meter_id_tbl(i).index1).effective_reading_from;
        i:=i+1;
    end loop;


    -- loop through each meter and do cross validation for all rules of each meter

    l_num_rules_counter:=0;
    for l_current_meter_index in 1..l_num_meters loop
        l_start_rule_index:=l_num_rules_counter+1;
        l_end_rule_index:=l_num_rules_counter+l_num_rules_for_meter(l_current_meter_index).num1;

        l_min_index:=null;
        l_max_index:=null;

        -- loop through each rule, validate that there is at most one rule w/o effective from,
        -- at most one rule w/o effective to, and if one rule has no effective from and no
        -- effective to, then there cannot be more than one rules.
        -- At the end of the loop, put all the rules with both effective from and effective to
        -- into a table for sorting.

        l_num_sortable_rules:=0;

        -- Following for loop:
        -- Go through the section of rule table for the current meter one by one,
        -- pick out the one(s) without effective_from or effective_date_to
        -- make sure that there can be at most one w/o effective_from_reading and at
        -- most one w/o effective_reading_to

        for l_current_rule_index in l_start_rule_index .. l_end_rule_index loop
            l_cur_p_tbl_rule_index:=l_meter_from_tbl(l_current_rule_index).index1;
            l_pm_rule_rec:=p_pm_rules_tbl(l_cur_p_tbl_rule_index);

            -- For each meter, at most one runtime rule can exist such that
            -- effective_reading_from is null
            -- this rule is the first rule after sorting.
            if l_pm_rule_rec.effective_reading_from is null then
                if (l_min_index is not null) then
                    x_reason_failed:='EAM_PM_RUN_MANY_NO_FROM';
                    return false;
                else
                    l_min_index:=l_cur_p_tbl_rule_index;
                end if;
            end if;

                    -- for each meter, At most one runtime rule can exist such that
            -- effective_reading_to is null
                    -- this rule is the last rule after sorting.

            if l_pm_rule_rec.effective_reading_to is null then
                if (l_max_index is not null) then
                    x_reason_failed:='EAM_PM_RUN_MANY_NO_TO';
                    return false;
                else
                    l_max_index:=l_cur_p_tbl_rule_index;
                end if;
            end if;

            -- If both effective from and effective to are null, then only one day interval rule can exist
            if (l_min_index=l_max_index and l_num_rules_for_meter(l_current_meter_index).num1>1) then
                x_reason_failed:='EAM_PM_RUN_OVERLAP';
                return false;
            end if;

            -- If both effective from and effective to are present,
            -- then put the index and start reading of this record into
            -- another temp table for sorting.


            if ((l_max_index is null or l_max_index<>l_cur_p_tbl_rule_index)
                      and (l_min_index is null or l_min_index<>l_cur_p_tbl_rule_index))
            then
                l_num_sortable_rules:=l_num_sortable_rules+1;
                l_temp_reading_from_tbl(l_num_sortable_rules).index1:=l_meter_from_tbl(l_current_rule_index).index1;
                l_temp_reading_from_tbl(l_num_sortable_rules).num1:=p_pm_rules_tbl(l_cur_p_tbl_rule_index).effective_reading_from;
            end if;
        end loop;  -- end for loop that loops through each rule within a meter



        -- validate: no overlap; at most one rule with no effective from, and at most one rule with no effective to.

        -- following loop for debugging
        i:=l_num_rules_counter;

        sort_table_by_number(l_temp_reading_from_tbl,
                    l_num_sortable_rules,
                    l_sorted_meter_from_tbl);

        -- Now, l_sorted_meter_from_tbl is a table of rules for ONE meter.
        -- The index of this table starts at 1.

        -- If there is a rule w/o effective_to reading,
        -- then put this rule's index and effective_from reading
        -- as the last record in the sorted table
        if (l_max_index is not null) then
            l_sorted_meter_from_tbl(l_num_sortable_rules+1).index1:=l_max_index;
            l_sorted_meter_from_tbl(l_num_sortable_rules+1).num1:=p_pm_rules_tbl(l_max_index).effective_reading_from;
            l_num_sortable_rules:=l_num_sortable_rules+1;
        end if;

        -- First, check whether the first record (with no effective_reading_from) overlaps with the next record
        if (l_min_index is not null
        and l_num_sortable_rules >0
        and l_min_index <> l_max_index
            and p_pm_rules_tbl(l_min_index).effective_reading_to > p_pm_rules_tbl(l_sorted_meter_from_tbl(l_num_rules_counter+1).index1).effective_reading_from)
        then
            x_reason_failed:='EAM_PM_RUN_OVERLAP';
            return false;
        end if;




        -- This loop goes through each pair of adjacent rules and checks for overlap
        for k in 1 .. l_num_sortable_rules-1 loop
            if (p_pm_rules_tbl(l_sorted_meter_from_tbl(k).index1).effective_reading_to > p_pm_rules_tbl(l_sorted_meter_from_tbl(k+1).index1).effective_reading_from)
            then
                x_reason_failed:='EAM_PM_RUN_OVERLAP';
                return false;
            end if;
        end loop;    -- end while loop that checks overlap
        l_num_rules_counter:=l_num_rules_counter+l_num_rules_for_meter(l_current_meter_index).num1;
    end loop;      -- end for loop that loops through each meter
    return true;

end;





function validate_pm_list_date_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY    varchar2
) return BOOLEAN
is
    l_reason_failed        varchar2(30);
    l_validated        boolean;
    l_temp_date_tbl        pm_date_tbl_type;
    l_sorted_date_tbl    pm_date_tbl_type;
    l_num_rules        number;
    i            number;
begin
-- validate each list date; copy each list date and index into l_temp_date_tbl
    i:=1;
    while p_pm_rules_tbl.exists(i) loop
        l_validated:=validate_pm_list_date(p_pm_rules_tbl(i), l_reason_failed);
        if (not l_validated) then
            x_reason_failed:=l_reason_failed;
            return false;
        end if;
        l_temp_date_tbl(i).index1:=i;
        l_temp_date_tbl(i).date1:=p_pm_rules_tbl(i).list_date;
        i:=i+1;
    end loop;
    l_num_rules:=i-1;

-- no list dates can be the same
    sort_table_by_date (l_temp_date_tbl, l_num_rules, l_sorted_date_tbl);
    i:=1;
    while p_pm_rules_tbl.exists(i+1) loop
        if (p_pm_rules_tbl(l_sorted_date_tbl(i).index1).list_date=p_pm_rules_tbl(l_sorted_date_tbl(i+1).index1).list_date) then
            x_reason_failed:='EAM_PM_LIST_SAME_DATES';
            return false;
        end if;
        i:=i+1;
    end loop;
    return true;
end;



function validate_pm_header_and_rules
(
        p_pm_schedule_rec               IN      pm_scheduling_rec_type,
        p_pm_day_interval_rules_tbl     IN      pm_rule_tbl_type,
        p_pm_runtime_rules_tbl         IN      pm_rule_tbl_type,
        p_pm_list_date_rules_tbl         IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY    varchar2
) return BOOLEAN
is
    l_validated            boolean;
    l_reason_failed            varchar2(30);
    i                number;
    l_count                number;
    l_meter_id            number;

begin

-- validate header
    l_validated:=validate_pm_header(p_pm_schedule_rec, l_reason_failed);
    if (not l_validated) then
        x_reason_failed:=l_reason_failed;
        return false;
    end if;

-- rules tables cannot be all empty
    if (p_pm_day_interval_rules_tbl.count=0 and p_pm_runtime_rules_tbl.count=0 and p_pm_list_date_rules_tbl.count=0) then
        x_reason_failed:='EAM_PM_EMPTY_HEADER';
        return false;
    end if;

-- If header is of type rule_based, then list_date rule table should be empty
    if (p_pm_schedule_rec.type_code=10       --'Rule Based, meter and day time'
        and p_pm_list_date_rules_tbl.count>0) then
        x_reason_failed:='EAM_PM_RULE_NOT_MATCH_PM_TYPE';
        return false;
    end if;

-- If header is of type rule_based, then list_date rule table should be empty
        if (p_pm_schedule_rec.type_code=17       --'day time only'
            and (p_pm_list_date_rules_tbl.count>0 or p_pm_runtime_rules_tbl.count>0)) then
                x_reason_failed:='EAM_PM_RULE_NOT_MATCH_PM_TYPE';
                return false;
        end if;


-- If header is of type list date, then day interval rules and runtime rules table should be empty
    if (p_pm_schedule_rec.type_code=20     -- 'List Dates'
        and (p_pm_day_interval_rules_tbl.count>0 or p_pm_runtime_rules_tbl.count>0))
    then
        x_reason_failed:='EAM_PM_RULE_NOT_MATCH_PM_TYPE';
        return false;
    end if;


-- validate each type of rules
    l_validated:=validate_pm_day_interval_rules(p_pm_day_interval_rules_tbl, l_reason_failed);
        if (not l_validated) then
                x_reason_failed:=l_reason_failed;
                return false;
        end if;

    l_validated:=validate_pm_runtime_rules(p_pm_runtime_rules_tbl, l_reason_failed);
        if (not l_validated) then
                x_reason_failed:=l_reason_failed;
                return false;
        end if;

    l_validated:=validate_pm_list_date_rules(p_pm_list_date_rules_tbl, l_reason_failed);
        if (not l_validated) then
                x_reason_failed:=l_reason_failed;
                return false;
        end if;


-- Check that effective date from and effective date to in the day interval rules are within the effective dates of the header
    i:=1;
    while (p_pm_day_interval_rules_tbl.exists(i)) loop
        if (p_pm_day_interval_rules_tbl(i).effective_date_from < p_pm_schedule_rec.from_effective_date
            or p_pm_day_interval_rules_tbl(i).effective_date_to > p_pm_schedule_rec.to_effective_date)
        then
            x_reason_failed:='EAM_PM_HD_DAY_INVALID_DATE';
            return false;
        end if;
        i:=i+1;
    end loop;

-- Check that list dates in the list date rules are within effective dates of the header
    i:=1;
    while (p_pm_list_date_rules_tbl.exists(i)) loop
        if (p_pm_list_date_rules_tbl(i).list_date < p_pm_schedule_rec.from_effective_date
            or p_pm_list_date_rules_tbl(i).list_date > p_pm_schedule_rec.to_effective_date)
        then
            x_reason_failed:='EAM_PM_HD_LIST_INVALID_DATE';
            return false;
        end if;
        i:=i+1;
    end loop;

  return true;
end;

--this is an overloaded method to include logic of meter last service reading

function validate_pm_activity
(
    p_pm_activity_grp_rec                   IN      pm_activities_grp_rec_type,
    p_pm_runtime_rules_tbl             IN      pm_rule_tbl_type,
    p_pm_schedule_rec            IN    PM_Scheduling_Rec_Type,
    x_reason_failed            OUT NOCOPY     varchar2,
    x_message            OUT NOCOPY     varchar2,
    x_activities                    OUT NOCOPY     varchar2
) return BOOLEAN

is
l_pm_schedule_id        number;
l_last_service_start_date     date;
l_last_service_end_date         date;
i number;
l_count number;
l_lsi_updated varchar2(1);
l_maintenance_object_id number;
l_asset_activity_id number;
l_last_scheduled_start_date date;
l_last_scheduled_end_date date;
l_actual_end_date date;
l_wip_entity_id number;
l_act_name      varchar2(50);
l_transaction_id number;
begin

-- activity validation: Check that the asset activity has last service reading start/end date.

    if (p_pm_schedule_rec.tmpl_flag is null or p_pm_schedule_rec.tmpl_flag='N') then /* FP of R12 bug 9744000, added null condition*/

        select last_service_start_date, last_service_end_date,last_scheduled_start_date,last_scheduled_end_date,
        maintenance_object_id,asset_activity_id
        into l_last_service_start_date, l_last_service_end_date,l_last_scheduled_start_date,l_last_scheduled_end_date,
        l_maintenance_object_id,l_asset_activity_id
           from mtl_eam_asset_activities
           where activity_association_id=p_pm_activity_grp_rec.activity_association_id;

        select distinct msi.concatenated_segments  into l_act_name
        from mtl_system_items_b_kfv msi
    where msi.inventory_item_id=l_asset_activity_id
        and msi.eam_item_type=2;


        if (l_last_service_start_date is null or l_last_service_end_date is null) then

          select max(ejct.actual_start_date),
                  max(ejct.actual_end_date) into
          l_last_service_start_date,
          l_last_service_end_date

          from eam_job_completion_txns ejct, wip_discrete_jobs wdj
                  where wdj.wip_entity_id = ejct.wip_entity_id
          and wdj.maintenance_object_id=l_maintenance_object_id
                  and wdj.primary_item_id=l_asset_activity_id
          and ejct.transaction_type=1;

          if (l_last_service_start_date is null or l_last_service_end_date is null) then

            l_last_service_start_date := g_sysdate;
            l_last_service_end_date := g_sysdate;
                        l_lsi_updated := 'Y';
            x_activities :=l_act_name;
          end if;

                     UPDATE mtl_eam_asset_activities
                  SET last_service_start_date = l_last_service_start_date,
          last_service_end_date = l_last_service_end_date,
          last_update_date=sysdate, last_updated_by=fnd_global.user_id,
                last_update_login=fnd_global.login_id
                  WHERE activity_association_id = p_pm_activity_grp_rec.activity_association_id;


        end if;

        if (l_last_scheduled_start_date is null or l_last_scheduled_end_date is null) then


                          begin

              select transaction_id into l_transaction_id from
              ( select max(actual_end_date),transaction_id  from eam_job_completion_txns ejct,
                  wip_discrete_jobs wdj
                  where ejct.transaction_type=1 and
                  wdj.wip_entity_id = ejct.wip_entity_id and
                  wdj.maintenance_object_id = l_maintenance_object_id and
                  wdj.primary_item_id =  l_asset_activity_id group by ejct.transaction_id order by ejct.transaction_id desc) where rownum = 1;

              exception when no_data_found then
                l_last_scheduled_start_date := g_sysdate;
                l_last_scheduled_end_date := g_sysdate;
                l_lsi_updated := 'Y';
                x_activities :=l_act_name;
                  end;

               if l_transaction_id is not null then
                begin

                SELECT wdj.scheduled_start_date,
                wdj.scheduled_completion_date,wdj.wip_entity_id
                into l_last_scheduled_start_date,l_last_scheduled_end_date,l_wip_entity_id
                FROM eam_job_completion_txns ejct, wip_discrete_jobs wdj WHERE wdj.primary_item_id=l_asset_activity_id
                and
                wdj.maintenance_object_id=l_maintenance_object_id and
                ejct.transaction_id=l_transaction_id and ejct.transaction_type=1 and
                ejct.wip_entity_id=wdj.wip_entity_id;

                exception when no_data_found then
                l_last_scheduled_start_date := g_sysdate;
                l_last_scheduled_end_date := g_sysdate;
                l_lsi_updated := 'Y';
                x_activities :=l_act_name;
                end;
            end if;

                   UPDATE mtl_eam_asset_activities meaa
                   SET meaa.last_scheduled_start_date = l_last_scheduled_start_date,
                   meaa.last_scheduled_end_date    = l_last_scheduled_end_date,
           meaa.wip_entity_id=l_wip_entity_id,
           last_update_date=sysdate, last_updated_by=fnd_global.user_id,
                 last_update_login=fnd_global.login_id
                   WHERE (meaa.last_scheduled_start_date is null OR
                        meaa.last_scheduled_end_date is null) AND
                        meaa.activity_association_id = p_pm_activity_grp_rec.activity_association_id;

        end if;

    end if;

--in case of runtime rules check for last service reading.if not insert the same with default values
    i:=1;
    if (p_pm_schedule_rec.tmpl_flag is null or p_pm_schedule_rec.tmpl_flag='N') then -- FP: bug 9744000, added null condition
            while (p_pm_runtime_rules_tbl.exists(i)) loop

                select count(*) into l_count
                from eam_pm_last_service
                where meter_id=p_pm_runtime_rules_tbl(i).meter_id
                and activity_association_id=p_pm_activity_grp_rec.activity_association_id;

                if (l_count = 0) then

            INSERT INTO eam_pm_last_service (activity_association_id, meter_id,
                        last_service_reading, last_update_date, last_updated_by, creation_date,
                    last_update_login, created_by)
            VALUES (p_pm_activity_grp_rec.activity_association_id,
                    p_pm_runtime_rules_tbl(i).meter_id,
                nvl(p_pm_runtime_rules_tbl(i).last_service_reading, 0),
                        sysdate,
                fnd_global.user_id,
                sysdate,
                    fnd_global.login_id,
                fnd_global.user_id);

                l_lsi_updated := 'Y';
                x_activities :=l_act_name;
                    end if;
            i:=i+1;
        end loop;
      end if;

-- set name is unique for this asset activity association and for this type of tmpl_flag
-- (at most one template and one definition for each asset activity association)

    /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
        BEGIN

       select eps.pm_schedule_id into l_pm_schedule_id from
           eam_pm_schedulings eps,eam_pm_activities epa
       where eps.pm_schedule_id=epa.pm_schedule_id
       and epa.activity_association_id=p_pm_activity_grp_rec.activity_association_id
       and eps.set_name_id=p_pm_schedule_rec.set_name_id
       and eps.tmpl_flag=p_pm_schedule_rec.tmpl_flag;

           if (p_pm_schedule_rec.pm_schedule_id is null) then
           -- If it's not an update action
        x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
        return false;
       else
        -- it's an update action
        if (l_pm_schedule_id <> p_pm_schedule_rec.pm_schedule_id) then
           x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
           return false;
        end if;

           end if;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
              null;
           WHEN TOO_MANY_ROWS THEN
          x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
              return false;
    END;

-- activity validation: there can be only one default

    if (p_pm_schedule_rec.default_implement is not null and p_pm_schedule_rec.default_implement='Y') then

       /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
           BEGIN

          select eps.pm_schedule_id into l_pm_schedule_id from
                 eam_pm_schedulings eps,eam_pm_activities epa
          where eps.pm_schedule_id=epa.pm_schedule_id
          and epa.activity_association_id=p_pm_activity_grp_rec.activity_association_id
          and eps.default_implement = 'Y'
          and eps.tmpl_flag=p_pm_schedule_rec.tmpl_flag;

        -- If there is one default, check if it is the same one
        -- as the one that's being validated.
                   if (p_pm_schedule_rec.pm_schedule_id is null) then
                      x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
                      return false;
                   else
                   if (l_pm_schedule_id <> p_pm_schedule_rec.pm_schedule_id) then
                         x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
                         return false;
                   end if;
        end if;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                   null;
        WHEN TOO_MANY_ROWS THEN
           x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
           return false;
       END;
    end if;

    --For list dates pm schedule activity cyclic attributes should have default values

    if p_pm_schedule_rec.TYPE_CODE = 20 and
       (p_pm_activity_grp_rec.interval_multiple > 1 or p_pm_activity_grp_rec.allow_repeat_in_cycle <> 'N') then

        x_reason_failed := 'EAM_PM_HD_LIST_DATES_VLD';
        return false;

    end if;

        if l_lsi_updated = 'Y' then
         x_message := 'EAM_PM_LAST_SERVICE_DEFAULT';
    end if;

    return true;

end validate_pm_activity;

--this will be called from instantiation api

function validate_pm_activity
(
        p_pm_activity_grp_rec                   IN      pm_activities_grp_rec_type,
    p_pm_schedule_rec            IN    PM_Scheduling_Rec_Type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN

is
l_pm_schedule_id        number;
l_last_service_start_date     date;
l_last_service_end_date         date;
i number;
begin

-- activity validation: Check that the asset activity has last service reading start/end date.

    if (p_pm_schedule_rec.tmpl_flag='N') then

            select last_service_start_date, last_service_end_date
        into l_last_service_start_date, l_last_service_end_date
            from mtl_eam_asset_activities
            where activity_association_id=p_pm_activity_grp_rec.activity_association_id;

        if (l_last_service_start_date is null or l_last_service_end_date is null) then
            x_reason_failed:='EAM_PM_HD_ACT_NO_SERVICE_DATE';
            return false;
        end if;

    end if;

    --For list dates pm schedule activity cyclic attributes should have default values

    if p_pm_schedule_rec.TYPE_CODE = 20 and
       (p_pm_activity_grp_rec.interval_multiple > 1 or p_pm_activity_grp_rec.allow_repeat_in_cycle <> 'N') then

        x_reason_failed := 'EAM_PM_HD_LIST_DATES_VLD';
        return false;

    end if;

-- set name is unique for this asset activity association and for this type of tmpl_flag
-- (at most one template and one definition for each asset activity association)

    /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
        BEGIN

       select eps.pm_schedule_id into l_pm_schedule_id from
           eam_pm_schedulings eps,eam_pm_activities epa
       where eps.pm_schedule_id=epa.pm_schedule_id
       and epa.activity_association_id=p_pm_activity_grp_rec.activity_association_id
       and eps.set_name_id=p_pm_schedule_rec.set_name_id
       and eps.tmpl_flag=p_pm_schedule_rec.tmpl_flag;

           if (p_pm_schedule_rec.pm_schedule_id is null) then
           -- If it's not an update action
        x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
        return false;
       else
        -- it's an update action
        if (l_pm_schedule_id <> p_pm_schedule_rec.pm_schedule_id) then
           x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
           return false;
        end if;

           end if;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
              null;
           WHEN TOO_MANY_ROWS THEN
          x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_SET_NAME';
              return false;
    END;

-- activity validation: there can be only one default

    if (p_pm_schedule_rec.default_implement is not null and p_pm_schedule_rec.default_implement='Y') then

       /* Bug # 3890075 : Modified the logic so that the query is executed only once. */
           BEGIN

          select eps.pm_schedule_id into l_pm_schedule_id from
                 eam_pm_schedulings eps,eam_pm_activities epa
          where eps.pm_schedule_id=epa.pm_schedule_id
          and epa.activity_association_id=p_pm_activity_grp_rec.activity_association_id
          and eps.default_implement = 'Y'
          and eps.tmpl_flag=p_pm_schedule_rec.tmpl_flag;

        -- If there is one default, check if it is the same one
        -- as the one that's being validated.
                   if (p_pm_schedule_rec.pm_schedule_id is null) then
                      x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
                      return false;
                   else
                   if (l_pm_schedule_id <> p_pm_schedule_rec.pm_schedule_id) then
                         x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
                         return false;
                   end if;
        end if;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                   null;
        WHEN TOO_MANY_ROWS THEN
           x_reason_failed:='EAM_PM_HD_NOT_UNIQUE_DEFAULT';
           return false;
       END;
    end if;

    return true;

end validate_pm_activity;

function validate_pm_activities
(      p_pm_activities_grp_tbl           IN      pm_activities_grp_tbl_type,
       p_pm_runtime_rules_tbl         IN      pm_rule_tbl_type,
       p_pm_schedule_rec               IN      pm_scheduling_rec_type,
       x_reason_failed               OUT NOCOPY varchar2,
       x_message                   OUT NOCOPY varchar2,
       x_activities                OUT NOCOPY varchar2
 ) return boolean
 is
  i                number;
  l_validated            boolean;
  l_reason_failed        varchar2(30);
  l_pm_activities_grp_rec       pm_activities_grp_rec_type;
  l_message varchar2(30);
  l_activity     varchar2(50);
begin
        --added so that the LSI defaulting happens consistenly for all the activities consitently bug:4768304
    g_sysdate := sysdate;
    i:=1;   -- counter for all activities

    if ( p_pm_activities_grp_tbl.count = 0 ) then
       x_reason_failed:='EAM_PM_NO_ACT';
       return false;
    end if;

        while (p_pm_activities_grp_tbl.exists(i))        loop

        -- check for reschedule manual work order option applicable only
        --in case of single activity PM

        if i > 1 and p_pm_schedule_rec.include_manual='Y' then
        x_reason_failed := 'EAM_PM_HD_RESCHED_MAN_NA';
        return false;
        end if;

            l_pm_activities_grp_rec:=p_pm_activities_grp_tbl(i);

        l_validated:=validate_pm_activity(l_pm_activities_grp_rec, p_pm_runtime_rules_tbl,p_pm_schedule_rec,l_reason_failed,l_message,l_activity);

        if (not l_validated) then
        x_reason_failed := l_reason_failed;
        return false;
        end if;

        if (l_validated) and l_message is not null then
            x_message := l_message;
        if(x_activities is null ) then
           x_activities := l_activity;
        else
           x_activities := x_activities ||' , ' || l_activity;
        end if;
            end if;

        i:= i+1;

    end loop;
    return true;
end;


procedure sort_table_by_date
(
    p_date_table             IN    pm_date_tbl_type,
    p_num_rows            IN     number,
    x_sorted_date_table        OUT NOCOPY     pm_date_tbl_type
)
is

    i         number;
    j        number;
    l_min_index    number;
    l_temp_date_rec    pm_date_rec_type;

begin
    x_sorted_date_table:=p_date_table;
    for i in 1..p_num_rows loop
        l_min_index:=i;
        for j in i+1..p_num_rows loop
            if x_sorted_date_table(j).date1 < x_sorted_date_table(l_min_index).date1 then
                l_min_index:=j;
            end if;
        end loop;
        l_temp_date_rec:=x_sorted_date_table(i);
        x_sorted_date_table(i):=x_sorted_date_table(l_min_index);
        x_sorted_date_table(l_min_index):=l_temp_date_rec;
    end loop;
end;


procedure sort_table_by_number
(
        p_num_table                    IN      pm_num_tbl_type,
        p_num_rows                      IN      number,
        x_sorted_num_table             OUT NOCOPY     pm_num_tbl_type
)
is

        i               number;
        j               number;
        l_min_index     number;
        l_temp_num_rec     pm_num_rec_type;

begin
        x_sorted_num_table:=p_num_table;
        for i in 1..p_num_rows loop
                l_min_index:=i;
                for j in i+1..p_num_rows loop
                        if x_sorted_num_table(j).num1 < x_sorted_num_table(l_min_index).num1 then
                                l_min_index:=j;
                        end if;
                end loop;
                l_temp_num_rec:=x_sorted_num_table(i);
                x_sorted_num_table(i):=x_sorted_num_table(l_min_index);
                x_sorted_num_table(l_min_index):=l_temp_num_rec;
        end loop;
end;


-- merge two rule tables; p_rules_tbl1 overrides p_rules_tbl2
procedure merge_rules
(p_rules_tbl1           IN      pm_rule_tbl_type,
p_rules_tbl2            IN      pm_rule_tbl_type,
x_merged_rules_tbl      OUT NOCOPY     pm_rule_tbl_type)
is
    i        number;
    j        number;
    l_num_tbl1    pm_num_tbl_type;
    l_sorted_num_tbl1    pm_num_tbl_type;
begin
    i:=1;
    while (p_rules_tbl1.exists(i)) loop
        if (p_rules_tbl1(i).rule_id is not null) then
            l_num_tbl1(i).index1:=i;
            l_num_tbl1(i).num1:=p_rules_tbl1(i).rule_id;
            l_num_tbl1(i).other:=1;
        end if;
        i:=i+1;
    end loop;

    while (p_rules_tbl2.exists(i)) loop
        if (p_rules_tbl2(i).rule_id is not null) then
            l_num_tbl1(i).index1:=i;
            l_num_tbl1(i).num1:=p_rules_tbl2(i).rule_id;
            l_num_tbl1(i).other:=2;
        end if;
        i:=i+1;
    end loop;

    sort_table_by_number(l_num_tbl1, i-1, l_sorted_num_tbl1);

    i:=1;     -- counter for the sorted number table
    j:=1;     -- counter for the merged rules table; j<=i at any time
    while (l_num_tbl1.exists(i)) loop
        if (i>1 and l_num_tbl1(i).index1=l_num_tbl1(i-1).index1
               and l_num_tbl1(i).other=1) then
            x_merged_rules_tbl(j):=p_rules_tbl1(l_num_tbl1(i).index1);
        else
            j:=j+1;
        end if;

        if (l_num_tbl1(i).other=1) then
            x_merged_rules_tbl(j):=p_rules_tbl1(l_num_tbl1(i).index1);
        else   -- if l_num_tbl1(i).other=2
            x_merged_rules_tbl(j):=p_rules_tbl2(l_num_tbl1(i).index1);
        end if;
        i:=i+1;
    end loop;

end;

--this will be called by pm form and also called from the new api update_pm_last_cyclic_act

procedure get_pm_last_activity
(    p_pm_schedule_id        IN     NUMBER,
     p_activity_association_id  OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count                     OUT NOCOPY     NUMBER ,
     x_msg_data                      OUT NOCOPY     VARCHAR2
 )
is

l_rescheduling_point number;
l_last_service_date date;
l_act_assoc_id number;
l_current_seq number;
l_msg_data varchar2(2000);
l_error_message varchar2(2000);


BEGIN
x_return_status:='S';
-- Check that enough info is supplied to identify which pm schedule to copy from.
    if (p_pm_schedule_id is null) then
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_MT_SUPPLY_PARAMS');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    end if;

--getting the scheduling option for the pm schedule

select rescheduling_point,current_seq into l_rescheduling_point,l_current_seq
from eam_pm_schedulings
where pm_schedule_id = p_pm_schedule_id;

--mandatory checking for rescheduling and current interval values
    if (l_rescheduling_point is null) then
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_PM_NO_RESCHED');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    end if;

    if (l_current_seq is null) then
        FND_MESSAGE.SET_NAME ('EAM', 'EAM_PM_NO_CURRENTSEQ');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
    end if;

--based on current sequence retrieve

if l_current_seq > 0 then

--based on scheduling option retrieve the last service date

    if (l_rescheduling_point in (1,5,6)) then

        select max(meaa.last_service_start_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id and
        ((epa.ALLOW_REPEAT_IN_CYCLE='N' and epa.interval_multiple=eps.current_seq) or
        (epa.ALLOW_REPEAT_IN_CYCLE='Y' and mod(eps.current_seq, epa.interval_multiple)=0));

        elsif (l_rescheduling_point = 2) then

        select max(meaa.last_service_end_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id and
        ((epa.ALLOW_REPEAT_IN_CYCLE='N' and epa.interval_multiple=eps.current_seq) or
        (epa.ALLOW_REPEAT_IN_CYCLE='Y' and mod(eps.current_seq, epa.interval_multiple)=0));

         elsif (l_rescheduling_point = 3) then

        select max(meaa.last_scheduled_start_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id and
        ((epa.ALLOW_REPEAT_IN_CYCLE='N' and epa.interval_multiple=eps.current_seq) or
        (epa.ALLOW_REPEAT_IN_CYCLE='Y' and mod(eps.current_seq, epa.interval_multiple)=0));

         elsif (l_rescheduling_point = 4) then

        select max(meaa.last_scheduled_end_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id and
        ((epa.ALLOW_REPEAT_IN_CYCLE='N' and epa.interval_multiple=eps.current_seq) or
        (epa.ALLOW_REPEAT_IN_CYCLE='Y' and mod(eps.current_seq, epa.interval_multiple)=0));

    end if;


elsif l_current_seq = 0 then

    if (l_rescheduling_point in (1,5,6)) then

        select max(meaa.last_service_start_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id;

        elsif (l_rescheduling_point = 2) then

        select max(meaa.last_service_end_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id;

         elsif (l_rescheduling_point = 3) then

        select max(meaa.last_scheduled_start_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id;

         elsif (l_rescheduling_point = 4) then

        select max(meaa.last_scheduled_end_date) into l_last_service_date
        from mtl_eam_asset_activities meaa, eam_pm_activities epa, eam_pm_schedulings eps
        where epa.activity_association_id=meaa.activity_association_id and
        epa.pm_schedule_id=eps.pm_schedule_id and eps.pm_schedule_id=p_pm_schedule_id;

    end if;

end if;

--based on last service date get the last activity association id of the
--lowest interval multiple activity in case of a tie
-- modified for 9754424, handled no_data_found exception incase of l_last_service_date is null.
Begin
	select * into l_act_assoc_id from (
	SELECT  meaa.activity_association_id  FROM mtl_eam_asset_activities meaa, eam_pm_activities epa
	WHERE decode(l_rescheduling_point,2,last_service_end_date ,3,last_scheduled_start_date, 4,last_scheduled_end_date ,last_service_start_date)
	= l_last_service_date
	AND meaa.activity_association_id = epa.activity_association_id AND epa.pm_schedule_id = p_pm_schedule_id
	order by interval_multiple
	)
	where rownum=1 ;
 EXCEPTION
		WHEN no_data_found THEN
        NULL;
End;
--assigning the last activity
p_activity_association_id :=nvl(l_act_assoc_id,p_activity_association_id);

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.get
                (       p_msg_index_out                 =>      x_msg_count             ,
                                p_data                  =>      x_msg_data
                );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN OTHERS THEN
       x_msg_count := 1;
       x_return_status := fnd_api.g_ret_sts_error;
           l_error_message := substrb(sqlerrm,1,512);
           x_msg_data      := l_error_message;
END get_pm_last_activity;

--this will be called by work order completion


procedure update_pm_last_cyclic_act
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
    p_pm_schedule_id        IN     NUMBER
 )

is
l_api_name            CONSTANT VARCHAR2(30)    :='update_pm_last_cyclic_act';
l_api_version               CONSTANT NUMBER         := 1.0;
x_error_message         VARCHAR2(2000);

l_rescheduling_point number;
l_last_service_date date;
l_act_assoc_id number;
l_pm_schedule_id number;
l_return_status            varchar2(1);
l_msg_count number;
l_msg_data varchar2(2000);
l_get_failed varchar2(1);

BEGIN

l_pm_schedule_id := p_pm_schedule_id;
-- Standard Start of API savepoint
SAVEPOINT update_pm_last_cyclic_act;

x_return_status := FND_API.G_RET_STS_SUCCESS;

--mandatory checking
if (p_pm_schedule_id is null) then
    FND_MESSAGE.SET_NAME ('EAM', 'EAM_PM_SCHEDULE_ID_MISSING');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
end if;

--call to get the last activity of the pm schedule

eam_pmdef_pub.get_pm_last_activity(p_pm_schedule_id => l_pm_schedule_id,
                     p_activity_association_id =>l_act_assoc_id,
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
                     x_msg_data  => l_msg_data);

if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            l_get_failed := 'Y';
            RAISE FND_API.G_EXC_ERROR;
end if;

-- updating the eam_last_cyclic_act field
-- modified for 9754424.
if (l_act_assoc_id is not null) or (l_act_assoc_id <>FND_API.G_MISS_NUM) THEN
update eam_pm_schedulings set EAM_LAST_CYCLIC_ACT = l_act_assoc_id,
                             last_update_date=sysdate,
                 last_updated_by=fnd_global.user_id,
                           last_update_login=fnd_global.login_id
                 where pm_schedule_id = p_pm_schedule_id;
end if;
--standard commit to be checked

IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_pm_last_cyclic_act;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_get_failed = 'Y' then
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        else
            FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                p_data              =>      x_msg_data
            );
            x_msg_data := substr(x_msg_data,1,2000);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_pm_last_cyclic_act;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN OTHERS THEN
        ROLLBACK TO update_pm_last_cyclic_act;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
END update_pm_last_cyclic_act;

procedure update_pm_last_service_reading
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
    p_pm_schedule_id        IN     NUMBER
 )
is
l_api_name            CONSTANT VARCHAR2(30)    :='update_pm_last_service_reading';
l_api_version               CONSTANT NUMBER         := 1.0;
x_error_message         VARCHAR2(2000);

l_rescheduling_point number;
l_last_service_date date;
l_act_assoc_id number;
l_pm_schedule_id number;
l_return_status            varchar2(1);
lsr number;
l_msg_count number;
l_msg_data varchar2(2000);
l_get_failed varchar2(1);

cursor c_pm_runtime_rule is
    select pm_schedule_id,
        meter_id,
        rule_id
    from eam_pm_scheduling_rules
    where pm_schedule_id = l_pm_schedule_id
    and rule_type = 2;

BEGIN

l_pm_schedule_id := p_pm_schedule_id;

-- Standard Start of API savepoint
SAVEPOINT update_pm_last_service_reading;

x_return_status := FND_API.G_RET_STS_SUCCESS;

--mandatory checking

if (p_pm_schedule_id is null) then
    FND_MESSAGE.SET_NAME ('EAM', 'EAM_PM_SCHEDULE_ID_MISSING');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
end if;

--call to get the last activity of the pm schedule

eam_pmdef_pub.get_pm_last_activity(p_pm_schedule_id => l_pm_schedule_id,
                     p_activity_association_id =>l_act_assoc_id,
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
                     x_msg_data  => l_msg_data);

if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            l_get_failed := 'Y';
            RAISE FND_API.G_EXC_ERROR;
end if;

--get the last service reading and update the same in epsr

for runtime_rec in c_pm_runtime_rule loop

    select last_service_reading into lsr
    from eam_pm_last_service
    where meter_id = runtime_rec.meter_id and activity_association_id = l_act_assoc_id;

    update eam_pm_scheduling_rules set last_service_reading = lsr,
                 last_update_date=sysdate,
                 last_updated_by=fnd_global.user_id,
                 last_update_login=fnd_global.login_id
    where pm_schedule_id=runtime_rec.pm_schedule_id and
    meter_id = runtime_rec.meter_id and
    rule_id = runtime_rec.rule_id;

 end loop;

--standard commit to be checked
IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_pm_last_service_reading;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        if l_get_failed = 'Y' then
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        else
            FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
            x_msg_data := substr(x_msg_data,1,2000);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_pm_last_service_reading;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
    WHEN OTHERS THEN
        ROLLBACK TO update_pm_last_service_reading;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (    G_PKG_NAME          ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.get
            (      p_msg_index_out             =>      x_msg_count         ,
                    p_data              =>      x_msg_data
            );
        x_msg_data := substr(x_msg_data,1,2000);
END update_pm_last_service_reading;




END;


/
