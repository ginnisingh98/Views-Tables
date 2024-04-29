--------------------------------------------------------
--  DDL for Package Body AHL_UA_UNIT_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_UNIT_SCHEDULES_PVT" AS
/* $Header: AHLVUUSB.pls 120.6 2008/03/05 00:05:14 adivenka ship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';

---------------------------------
-- Common constants and variables
---------------------------------
l_dummy_varchar     VARCHAR2(1);

/* Variable to indicate whether to use actual flight times */
G_USE_ACTUALS           CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;

/* Constants to define event type */
G_EVENT_TYPE_VISIT      CONSTANT    VARCHAR2(12) := 'VISIT';
G_EVENT_TYPE_FLIGHT     CONSTANT    VARCHAR2(12) := 'FLIGHT';

/* Variable to determine whether to consider department conflcits. Will be initialized from profile */
G_DEPT_CONFLICT_PROF    CONSTANT    VARCHAR2(1) := FND_PROFILE.VALUE('AHL_UA_USE_DEPT_CONFLICT');
G_DEPT_CONFLICT     BOOLEAN;
/* Function to get minimum number of minutes to considered as MO from profiles*/
FUNCTION Get_Min_Time_MO RETURN NUMBER;
/* Variable to determine whether there is a maintenance opportunity
 * Holds value in minutes. This should be equal or more as gap value between two events
 * Will be initialized from profile
 */
G_MIN_TIME_MO       CONSTANT NUMBER := Get_Min_Time_MO;


-----------------------------------
-- Non-spec Procedure Signatures --
-----------------------------------
---------------------------------------------------------------------------------
-- Determines Maintenance Opportunity and Conflcits for the current flight record
-- Prepare it with transient variable calculations
-- Determine whether to add record in appropriate table
---------------------------------------------------------------------------------
PROCEDURE populate_unit_schedule_rec
(
    p_unit_flight_schedule_rec  IN      AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
    p_prev_event_type           IN              VARCHAR2,
    p_window_event              IN              BOOLEAN,
    p_prev_unit_schedule_rec    IN              AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type,
    p_prev_visit_schedule_rec   IN              AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type,
    p_x_MEvent_Header_Rec           IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.MEvent_Header_Rec_Type,
    p_x_Unit_Schedule_tbl           IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_Tbl_Type,
    p_x_Visit_Schedule_tbl          IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_Tbl_Type,
    x_Unit_Schedule_Rec         OUT NOCOPY      AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type
);

---------------------------------------------------------------------------------
-- Determines Maintenance Opportunity and Conflcits for the current visit record
-- Prepare it with transient variable calculations
-- Determine whether to add record in appropriate table
---------------------------------------------------------------------------------
PROCEDURE populate_visit_schedule_rec
(
    p_visit_rec                 IN              AHL_VWP_VISITS_PVT.Visit_Rec_Type,
    p_prev_event_type           IN              VARCHAR2,
    p_window_event              IN              BOOLEAN,
    p_prev_unit_schedule_rec    IN              AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type,
    p_prev_visit_schedule_rec   IN              AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type,
    p_x_MEvent_Header_Rec           IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.MEvent_Header_Rec_Type,
    p_x_Unit_Schedule_tbl           IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_Tbl_Type,
    p_x_Visit_Schedule_tbl          IN OUT NOCOPY   AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_Tbl_Type,
    x_visit_schedule_rec        OUT NOCOPY      AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type
);

------------------------------------------
-- Spec Procedure Search_Unit_Schedules --
------------------------------------------
PROCEDURE Search_Unit_Schedules
(
    p_api_version           IN      NUMBER,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    p_unit_schedules_search     IN      Unit_Schedules_Search_Rec_Type,
    x_unit_schedules_results    OUT NOCOPY      Unit_Schedules_Result_Tbl_Type
)
IS
    -- 1.   Declare local variables
    l_api_name  CONSTANT    VARCHAR2(30)    := 'Search_Unit_Schedules';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    L_DEBUG_MODULE  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_srch_unit_schedule        Unit_Schedules_Result_Rec_Type;

    l_unit_config_id        NUMBER;
    l_unit_config_name      VARCHAR2(80);

    l_time_increment        NUMBER(25,15) := 0;
    l_start_time            DATE;
    l_end_time          DATE;
    l_col_idx           NUMBER := 0;
    l_row_idx           NUMBER := 0;
    l_tbl_dummy_idx         NUMBER;

    l_mevent_header_rec     MEvent_Header_Rec_Type;
    l_unit_schedule_tbl     Unit_Schedule_Tbl_Type;
    l_visit_schedule_tbl        Visit_Schedule_Tbl_Type;

    l_MO_tbl            VARCHAR2(12) := NULL;
    l_MO_tbl_idx            NUMBER := 0;

    l_temp_srch_sched_id        NUMBER;
    l_temp_sched_type       VARCHAR2(2);
    l_temp_unit_sched_id        NUMBER;
    l_temp_visit_id         NUMBER;
    l_temp_visit_status     VARCHAR2(30);
    l_temp_visit_is_org_valid   VARCHAR2(1);
    l_temp_visit_name       VARCHAR2(80);
    l_temp_start_time       DATE;
    l_temp_end_time         DATE;
    l_temp_dept_id          NUMBER;
    l_temp_org_id           NUMBER;

    -- Define a local "constant" to denote the number of time spans that will be returned in the search criteria. Each time span is of size p_time_increment
    L_MAX_TIME_SPANS    CONSTANT    NUMBER := 10;

    -- Define event schedule type constants
    L_EVENT_CONFLICT    CONSTANT    VARCHAR2(2) := 'CO';
    L_EVENT_MULT_EVENT  CONSTANT    VARCHAR2(2) := 'ME';
    L_EVENT_MULT_MAINTOP    CONSTANT    VARCHAR2(2) := 'MM';
    L_EVENT_MAINTOP     CONSTANT    VARCHAR2(2) := 'MO';
    L_EVENT_MAINT_ORG_NOOU  CONSTANT    VARCHAR2(2) := 'MX';
    L_EVENT_VISIT       CONSTANT    VARCHAR2(2) := 'VS';
    L_EVENT_FLIGHT      CONSTANT    VARCHAR2(2) := 'FS';
    L_EVENT_NOTHING     CONSTANT    VARCHAR2(2) := 'XX';

    -- 3.   Define cursor get_unit_details to retrieve details of units satisfying the search criteria
    cursor get_unit_details
    (
        p_unit_name varchar2,
        p_item_number varchar2,
        p_serial_number varchar2
    )
    is
    -- Bug No #4916304: APPSPERF fixes {priyan}
    select
        u.unit_config_header_id uc_header_id,
        u.name uc_name
    from
        ahl_unit_config_headers u,
        mtl_system_items_kfv i,
        csi_item_instances c
    where
	--priyan Bug# 5303188
	--ahl_util_uc_pkg.get_uc_status_code (u.unit_config_header_id) IN ('COMPLETE', 'INCOMPLETE') and
	-- fix for bug number 5528416
	ahl_util_uc_pkg.get_uc_status_code (u.unit_config_header_id) NOT IN ('DRAFT', 'EXPIRED') and
        --u.unit_config_status_code in ('COMPLETE', 'INCOMPLETE') and
        u.csi_item_instance_id = c.instance_id and
        c.inventory_item_id = i.inventory_item_id and
        c.last_vld_organization_id = i.organization_id and
        upper(u.name) like upper(nvl(p_unit_schedules_search.unit_name, '%')) and
        upper(i.concatenated_segments) like upper(nvl(p_unit_schedules_search.item_number, '%')) and
        upper(c.serial_number) like upper(nvl(p_unit_schedules_search.serial_number, '%'))
        order by uc_name desc;
        -- Added sorting on DESC since OAF VO.insertRow inserts a row before the current row, effectively reversing the sort sequence in the UI
    /*
        select uc_header_id, uc_name
        from ahl_unit_config_headers_v
        where upper(uc_name) like nvl(upper(p_unit_schedules_search.unit_name), '%')
        and upper(item_number) like nvl(upper(p_unit_schedules_search.item_number), '%')
        and upper(serial_number) like nvl(upper(p_unit_schedules_search.serial_number), '%')
        and uc_status_code IN ('COMPLETE', 'INCOMPLETE')
    */

BEGIN
    -- Standard start of API savepoint
    SAVEPOINT Search_Unit_Schedules_SP;

    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list by default
    FND_MSG_PUB.Initialize;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log API entry point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    -- 4.   Delete all records from global temporary table ahl_srch_unit_schedules
    -- DELETE FROM AHL_SRCH_UNIT_SCHEDULES;
    -- If global temp table is deleted, then multiple navigations to and fro from Search Unit Schedules UI cannot be
    -- supported, hence retaining all data in the table till session is killed. Not sure whether it will be a
    -- performance hit or not, will repeal both frontend and backend code in that case.

    -- 5.   If (p_unit_schedules_search is NULL or p_unit_schedules_search.start_date_time is null), then display error "Start date and time are mandatory parameters to perform a search on Unit Schedules"
    IF (p_unit_schedules_search.start_date_time IS NULL OR p_unit_schedules_search.start_date_time = FND_API.G_MISS_DATE)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_SUS_START_DATE_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 6.   If (p_unit_schedules_search is NULL or p_unit_schedules_search.time_increment is null or p_unit_schedules_search.time_uom is null), then display error "Display increment is mandatory parameter to perform a search on Unit Schedules"
    IF (
        p_unit_schedules_search.time_increment IS NULL OR p_unit_schedules_search.time_increment = FND_API.G_MISS_NUM OR
        p_unit_schedules_search.time_uom IS NULL OR p_unit_schedules_search.time_uom = FND_API.G_MISS_CHAR
    )
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_SUS_TIME_UOM_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 7.   If (p_unit_schedules_search.time_increment is not a positive integer), then display error "Display increment should be a positive integer"
    IF (p_unit_schedules_search.time_increment <= 0 OR p_unit_schedules_search.time_increment <> TRUNC(p_unit_schedules_search.time_increment))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_SUS_TIME_INTEGER');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 8.   Validate p_unit_schedules_search.time_uom using cursor check_time_uom_exists. If cursor does not return 1 record (and only 1), the display error "Invalid UOM for display increment"
    IF  NOT (AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_UA_TIME_UOM', p_unit_schedules_search.time_uom))
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_SUS_TIME_UOM_INVALID');
        FND_MESSAGE.SET_TOKEN('UOM', p_unit_schedules_search.time_uom);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            L_DEBUG_MODULE,
            'Basic validations done'
        );
    END IF;

    -- Calculat the time increment, based on the UOMs
    IF (p_unit_schedules_search.time_uom = 'MIN')
    THEN
        l_time_increment := 1/1440;
    ELSIF (p_unit_schedules_search.time_uom = 'HOUR')
    THEN
        l_time_increment := 1/24;
    ELSIF (p_unit_schedules_search.time_uom = 'DAY')
    THEN
        l_time_increment := 1;
    END IF;

    l_time_increment := l_time_increment * p_unit_schedules_search.time_increment;

    -- 10.  Open cursor get_unit_details and loop through the records

    OPEN get_unit_details
    (
        p_unit_schedules_search.unit_name,
        p_unit_schedules_search.item_number,
        p_unit_schedules_search.serial_number
    );
    LOOP
        FETCH get_unit_details INTO l_unit_config_id, l_unit_config_name;
        EXIT WHEN get_unit_details%NOTFOUND;

        -- Initialize outer loop counter (for the particular unit_config_id)
        l_row_idx := l_row_idx + 1;

        -- Initialize start date time to user-entered start date time (this will be the current start date time for the first time span)
        l_start_time := p_unit_schedules_search.start_date_time;

        -- Start inner loop (for each time span)
        FOR l_col_idx IN 1..L_MAX_TIME_SPANS
        LOOP
            -- Initialize end date time of the time span to current start date time + time increment/span
            l_end_time := l_start_time + l_time_increment;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    L_DEBUG_MODULE,
                    '[l_unit_config_id='||TO_CHAR(l_unit_config_id)||'][l_unit_config_name='||l_unit_config_name||'][l_row_idx='||TO_CHAR(l_row_idx)||'][l_col_idx='||TO_CHAR(l_col_idx)||']'||
                    '[l_start_time='||TO_CHAR(l_start_time, 'DD-MM-YYYY HH24:MI:SS')||'][l_end_time='||TO_CHAR(l_end_time, 'DD-MM-YYYY HH24:MI:SS')||'][l_time_increment='||TO_CHAR(l_time_increment)||']'
                );
            END IF;

            -- Actual code logic for each time span starts here

            -- ii.  Call AHL_UA_UNIT_SCHEDULES_PVT.Get_MEvent_Details to retrieve details of unit schedule event for this l_unit_config_id and within the time period l_start_time to l_end_time.
            -- Populate l_mevent_header_rec with these 3 parameters and pass to the API. Also pass p_module_type = 'US' to prevent unnecessary populating of parameters in this API.
            l_mevent_header_rec.unit_config_header_id   := l_unit_config_id;
            l_mevent_header_rec.start_time          := l_start_time;
            l_mevent_header_rec.end_time            := l_end_time;

            Get_MEvent_Details
            (
                p_api_version       => 1.0,
                p_module_type       => 'US',
                x_return_status     => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_x_MEvent_Header_Rec   => l_mevent_header_rec,
                x_Unit_Schedule_tbl => l_unit_schedule_tbl,
                    x_Visit_Schedule_tbl    => l_visit_schedule_tbl
            );

            -- Verify the Get_MEvent_Details does not throw unexpected errors, etc
            IF (l_return_status = FND_API.G_RET_STS_ERROR)
            THEN
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_error,
                        L_DEBUG_MODULE,
                        'Call to Get_MEvent_Details API returned EXPECTED error'
                    );
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
            THEN
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
                THEN
                    fnd_log.string
                    (
                        fnd_log.level_error,
                        L_DEBUG_MODULE,
                        'Call to Get_MEvent_Details API returned UNEXPECTED error'
                    );
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Check Error Message stack.
            x_msg_count := FND_MSG_PUB.count_msg;
            IF x_msg_count > 0
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    L_DEBUG_MODULE,
                    'l_mevent_header_rec = [EVENT_COUNT='||TO_CHAR(l_mevent_header_rec.EVENT_COUNT)||'][HAS_CONFLICT='||l_mevent_header_rec.HAS_CONFLICT||'][HAS_MOPPORTUNITY='||l_mevent_header_rec.HAS_MOPPORTUNITY||']'||
                    'l_unit_schedule_tbl = [COUNT='||TO_CHAR(l_unit_schedule_tbl.COUNT)||']'||'l_visit_schedule_tbl = [COUNT='||TO_CHAR(l_visit_schedule_tbl.COUNT)||']'
                );
            END IF;

            -- iii. Based on the following logic for the type of event, populate relevant details in the global temporary table ahl_srch_unit_schedules and also in the output record

            -- 1.   Initialize all temporary table values to null
            l_temp_unit_sched_id    := null;
            l_temp_visit_id     := null;
            l_temp_visit_name   := null;
            l_temp_visit_status := null;
            l_temp_visit_is_org_valid:= null;
            l_temp_start_time   := null;
            l_temp_end_time     := null;
            l_temp_dept_id      := null;
            l_temp_org_id       := null;

            -- 2.   If (l_mevent_header_rec.event_count > 1), implies that there are multiple events
            IF (l_mevent_header_rec.event_count > 1)
            THEN
                -- a.   If (l_mevent_header_rec.has_conflict = FND_API.G_TRUE), implies that there is a conflict
                IF (l_mevent_header_rec.has_conflict = FND_API.G_TRUE)
                THEN
                    l_temp_sched_type   := L_EVENT_CONFLICT;

                -- b.   Else, if (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE), implies that there are a multiple events with maintenance opportunity
                ELSIF (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE)
                THEN
                    l_temp_sched_type   := L_EVENT_MULT_MAINTOP;
                -- c.   Else, implies that there are multiple events
                ELSE
                    l_temp_sched_type   := L_EVENT_MULT_EVENT;
                END IF;

                l_temp_start_time   := l_start_time;
                l_temp_end_time     := l_end_time;

            -- 3.   If (l_mevent_header_rec.event_count = 0), implies that there are no events
            ELSIF (l_mevent_header_rec.event_count = 0)
            THEN
                -- a.   If (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE), implies that there is a maintenance opportunity
                IF (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE)
                THEN
                    l_temp_sched_type := L_EVENT_MAINTOP;

                    -- The MO record can either be in l_visit_schedule_tbl or l_unit_schedule_tbl is one of its records, need to know
                    -- where and then retrieve the correct information from that record
                    l_MO_tbl := null;
                    l_MO_tbl_idx := 0;

                    -- First check l_unit_schedule_tbl
                    IF (l_unit_schedule_tbl.count > 0)
                    THEN
                        FOR l_tbl_dummy_idx IN l_unit_schedule_tbl.FIRST..l_unit_schedule_tbl.LAST
                        LOOP
                            IF (l_unit_schedule_tbl(l_tbl_dummy_idx).HAS_MOPPORTUNITY = FND_API.G_TRUE)
                            THEN
                                l_MO_tbl_idx := l_tbl_dummy_idx;
                                l_MO_tbl := G_EVENT_TYPE_FLIGHT;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;

                    -- If not found in l_unit_schedule_tbl, then check l_visit_schedule_tbl
                    IF (l_visit_schedule_tbl.count > 0 AND l_MO_tbl IS NULL)
                    THEN
                        FOR l_tbl_dummy_idx IN l_visit_schedule_tbl.FIRST..l_visit_schedule_tbl.LAST
                        LOOP
                            IF (l_visit_schedule_tbl(l_tbl_dummy_idx).HAS_MOPPORTUNITY = FND_API.G_TRUE)
                            THEN
                                l_MO_tbl_idx := l_tbl_dummy_idx;
                                l_MO_tbl := G_EVENT_TYPE_VISIT;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;

                    -- ii.  If (l_MO_tbl = G_EVENT_TYPE_FLIGHT), implies that the preceding event to this time block is a flight schedule
                    IF (l_MO_tbl = G_EVENT_TYPE_FLIGHT)
                    THEN
                        -- 1.   If (l_unit_schedule_tbl(l_MO_tbl).is_prev_org_valid = FND_API.G_FALSE), implies that the the org is not in the user's OU
                        IF (l_unit_schedule_tbl(l_MO_tbl_idx).is_prev_org_valid = FND_API.G_FALSE)
                        THEN
                            l_temp_sched_type := L_EVENT_MAINT_ORG_NOOU;
                        ELSE
                            l_temp_visit_name := l_unit_schedule_tbl(l_MO_tbl_idx).prev_flight_number;
                            l_temp_unit_sched_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_unit_schedule_id;
                            l_temp_start_time := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_end_time;
                            l_temp_end_time := l_unit_schedule_tbl(l_MO_tbl_idx).departure_time;
                            l_temp_dept_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_dep_id;
                            l_temp_org_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_org_id;
                        END IF;

                    -- iii. Else, if (l_MO_tbl = G_EVENT_TYPE_VISIT), implies that the preceding event to this time block is a visit schedule
                    ELSIF (l_MO_tbl = G_EVENT_TYPE_VISIT)
                    THEN
                        -- 1.   If (l_visit_schedule_tbl(l_MO_tbl).is_prev_org_valid = FND_API.G_FALSE), implies that the the org is not in the user's OU
                        IF (l_visit_schedule_tbl(l_MO_tbl_idx).is_prev_org_valid = FND_API.G_FALSE)
                        THEN
                            l_temp_sched_type := L_EVENT_MAINT_ORG_NOOU;
                        ELSE
                            l_temp_visit_name := l_visit_schedule_tbl(l_MO_tbl_idx).prev_flight_number;
                            l_temp_unit_sched_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_unit_schedule_id;
                            l_temp_start_time := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_end_time;
                            l_temp_end_time := l_visit_schedule_tbl(l_MO_tbl_idx).start_time;
                            l_temp_dept_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_dep_id;
                            l_temp_org_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_org_id;
                        END IF;

                    -- iv.  Else, there is something wrong (since atleast one l_unit_schedule_tbl or one l_visit_schedule_tbl is expected)
                    ELSE
                        l_temp_sched_type := L_EVENT_NOTHING;
                    END IF;

                -- b.   Else, implies that there is no event (based on the minimum window for a maintenance opportunity or no flight schedules are created for the unit)
                ELSE
                    l_temp_sched_type := L_EVENT_NOTHING;
                END IF;

            -- 4.   If (l_mevent_header_rec.event_count = 1)
            ELSIF (l_mevent_header_rec.event_count = 1)
            THEN
                -- a.   If (l_mevent_header_rec.has_conflict = FND_API.G_TRUE), implies that there is a conflict
                IF (l_mevent_header_rec.has_conflict = FND_API.G_TRUE)
                THEN
                    l_temp_sched_type := L_EVENT_CONFLICT;
                    l_temp_start_time := l_start_time;
                    l_temp_end_time := l_end_time;

                -- b.   Else, if (l_mevent_header_rec.has_mopportunity = FND_API.G_FALSE), implies either a visit or flight is scheduled
                ELSIF (l_mevent_header_rec.has_mopportunity = FND_API.G_FALSE)
                THEN
                    -- i.   If (l_unit_schedule_tbl.count > 0), implies that a flight is scheduled
                    IF (l_unit_schedule_tbl.count > 0)
                    THEN
                        l_temp_sched_type := L_EVENT_FLIGHT;
                        l_temp_unit_sched_id := l_unit_schedule_tbl(0).unit_schedule_id;
                    -- ii.  Else, if (l_unit_schedule_tbl.count > 0), implies that a visit is scheduled
                    ELSIF (l_visit_schedule_tbl.count > 0)
                    THEN
                        l_temp_sched_type := L_EVENT_VISIT;
                        l_temp_visit_id := l_visit_schedule_tbl(0).visit_id;
                        l_temp_visit_status := l_visit_schedule_tbl(0).visit_status_code;
                        l_temp_visit_is_org_valid := l_visit_schedule_tbl(0).is_org_valid;
                    -- iii. Else, there is something wrong
                    ELSE
                        l_temp_sched_type := L_EVENT_NOTHING;
                    END IF;

                -- c.   Else, if (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE), implies there is a maintenance opportunity
                ELSIF (l_mevent_header_rec.has_mopportunity = FND_API.G_TRUE)
                THEN
                    /*
                    -- The earlier logic was 1 event (flight / visit) with MO(s) will be displayed as MO according to the
                    -- priorities of displaying event icons
                    --
                    -- This was confusing to the User, also presented an incorrect picture, so after discussions with PM the logic
                    -- has now been modified to 1 event (flight / visit) with MO(s) is equivalent to Multiple Events with MO
                    --
                    -- NOTE: Please do not remove this code-block, the modifications are after this

                    l_temp_sched_type := L_EVENT_MAINTOP;

                    -- The MO record can either be in l_visit_schedule_tbl or l_unit_schedule_tbl is one of its records, need to know
                    -- where and then retrieve the correct information from that record
                    l_MO_tbl := null;
                    l_MO_tbl_idx := 0;

                    -- First check l_unit_schedule_tbl
                    IF (l_unit_schedule_tbl.count > 0)
                    THEN
                        FOR l_tbl_dummy_idx IN l_unit_schedule_tbl.FIRST..l_unit_schedule_tbl.LAST
                        LOOP
                            IF (l_unit_schedule_tbl(l_tbl_dummy_idx).HAS_MOPPORTUNITY = FND_API.G_TRUE)
                            THEN
                                l_MO_tbl_idx := l_tbl_dummy_idx;
                                l_MO_tbl := G_EVENT_TYPE_FLIGHT;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;

                    -- If not found in l_unit_schedule_tbl, then check l_visit_schedule_tbl
                    IF (l_visit_schedule_tbl.count > 0 AND l_MO_tbl IS NULL)
                    THEN
                        FOR l_tbl_dummy_idx IN l_visit_schedule_tbl.FIRST..l_visit_schedule_tbl.LAST
                        LOOP
                            IF (l_visit_schedule_tbl(l_tbl_dummy_idx).HAS_MOPPORTUNITY = FND_API.G_TRUE)
                            THEN
                                l_MO_tbl_idx := l_tbl_dummy_idx;
                                l_MO_tbl := G_EVENT_TYPE_VISIT;
                                EXIT;
                            END IF;
                        END LOOP;
                    END IF;

                    -- ii.  If (l_MO_tbl = G_EVENT_TYPE_FLIGHT), implies that the preceding event to this time block is a flight schedule
                    IF (l_MO_tbl = G_EVENT_TYPE_FLIGHT)
                    THEN
                        -- 1.   If (l_unit_schedule_tbl(l_MO_tbl).is_prev_org_valid = FND_API.G_FALSE), implies that the the org is not in the user's OU
                        IF (l_unit_schedule_tbl(l_MO_tbl_idx).is_prev_org_valid = FND_API.G_FALSE)
                        THEN
                            l_temp_sched_type := L_EVENT_MAINT_ORG_NOOU;
                        ELSE
                            l_temp_visit_name := l_unit_schedule_tbl(l_MO_tbl_idx).prev_flight_number;
                            l_temp_unit_sched_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_unit_schedule_id;
                            l_temp_start_time := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_end_time;
                            l_temp_end_time := l_unit_schedule_tbl(l_MO_tbl_idx).departure_time;
                            l_temp_dept_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_dep_id;
                            l_temp_org_id := l_unit_schedule_tbl(l_MO_tbl_idx).prev_event_org_id;
                        END IF;

                    -- iii. Else, if (l_MO_tbl = G_EVENT_TYPE_VISIT), implies that the preceding event to this time block is a visit schedule
                    ELSIF (l_MO_tbl = G_EVENT_TYPE_VISIT)
                    THEN
                        -- 1.   If (l_visit_schedule_tbl(l_MO_tbl).is_prev_org_valid = FND_API.G_FALSE), implies that the the org is not in the user's OU
                        IF (l_visit_schedule_tbl(l_MO_tbl_idx).is_prev_org_valid = FND_API.G_FALSE)
                        THEN
                            l_temp_sched_type := L_EVENT_MAINT_ORG_NOOU;
                        ELSE
                            l_temp_visit_name := l_visit_schedule_tbl(l_MO_tbl_idx).prev_flight_number;
                            l_temp_unit_sched_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_unit_schedule_id;
                            l_temp_start_time := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_end_time;
                            l_temp_end_time := l_visit_schedule_tbl(l_MO_tbl_idx).start_time;
                            l_temp_dept_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_dep_id;
                            l_temp_org_id := l_visit_schedule_tbl(l_MO_tbl_idx).prev_event_org_id;
                        END IF;

                    -- iv.  Else, there is something wrong (since atleast one l_unit_schedule_tbl or one l_visit_schedule_tbl is expected)
                    ELSE
                        l_temp_sched_type := L_EVENT_NOTHING;
                    END IF;
                    */

                    l_temp_sched_type := L_EVENT_MULT_MAINTOP;
                    l_temp_start_time := l_start_time;
                    l_temp_end_time := l_end_time;
                END IF;

            -- Else, there is something wrong
            ELSE
                l_temp_sched_type := L_EVENT_NOTHING;
            END IF;

            -- 5.   Insert record into global temporary table ahl_srch_unit_schedules

            SELECT NVL(MAX(SRCH_UNIT_SCHEDULE_ID), 0) + 1 INTO l_temp_srch_sched_id FROM AHL_SRCH_UNIT_SCHEDULES;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
                fnd_log.string
                (
                    fnd_log.level_statement,
                    L_DEBUG_MODULE,
                    '[l_temp_srch_sched_id='||TO_CHAR(l_temp_srch_sched_id)||'][l_temp_sched_type='||l_temp_sched_type||'][l_unit_config_id='||TO_CHAR(l_unit_config_id)||'][l_temp_unit_sched_id='||TO_CHAR(l_temp_unit_sched_id)||']'||
                    '[l_temp_visit_id='||TO_CHAR(l_temp_visit_id)||'][l_temp_visit_name='||l_temp_visit_name||'][l_temp_dept_id='||TO_CHAR(l_temp_dept_id)||'][l_temp_org_id='||TO_CHAR(l_temp_org_id)||']'||
                    '[l_temp_start_time='||TO_CHAR(l_temp_start_time, 'DD-MM-YYYY HH24:MI:SS')||'][l_temp_end_time='||TO_CHAR(l_temp_end_time, 'DD-MM-YYYY HH24:MI:SS')||']'||
                    '[l_temp_visit_status='||l_temp_visit_status||'][l_temp_visit_is_org_valid='||l_temp_visit_is_org_valid||']'
                );
            END IF;

            INSERT INTO AHL_SRCH_UNIT_SCHEDULES
            (
                SRCH_UNIT_SCHEDULE_ID,
                UNIT_CONFIG_HEADER_ID,
                UNIT_SCHEDULE_TYPE,
                UNIT_SCHEDULE_ID,
                VISIT_ID,
                VISIT_STATUS_CODE,
                VISIT_IS_ORG_VALID,
                VISIT_NAME,
                START_TIME,
                END_TIME,
                DEPARTMENT_ID,
                ORGANIZATION_ID
            )
            VALUES
            (
                l_temp_srch_sched_id,
                l_unit_config_id,
                l_temp_sched_type,
                l_temp_unit_sched_id,
                l_temp_visit_id,
                l_temp_visit_status,
                l_temp_visit_is_org_valid,
                l_temp_visit_name,
                l_temp_start_time,
                l_temp_end_time,
                l_temp_dept_id,
                l_temp_org_id
            );

            -- iv.  Populate the return parameters for this record in l_srch_unit_schedule
            l_srch_unit_schedule.result_row_num         := l_row_idx;
            l_srch_unit_schedule.result_col_num         := l_col_idx;
            l_srch_unit_schedule.unit_name          := l_unit_config_name;
            l_srch_unit_schedule.unit_config_header_id  := l_unit_config_id;
            l_srch_unit_schedule.schedule_id        := l_temp_srch_sched_id;
            l_srch_unit_schedule.schedule_type      := l_temp_sched_type;

            -- v.   Add l_srch_unit_schedule record to x_unit_schedules_results output table
            x_unit_schedules_results(l_row_idx * L_MAX_TIME_SPANS + l_col_idx) := l_srch_unit_schedule;

            -- Actual code logic for each time span ends here

            -- Initialize start date time for the next time span = end date time of current time span
            l_start_time := l_end_time;
        END LOOP;
        -- End of L_MAX_TIME_SPAN time blocks loops
    END LOOP;
    -- End of l_unit_config_id

    -- API body ends here

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Commit by default
    COMMIT WORK;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Search_Unit_Schedules_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Search_Unit_Schedules_SP;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Search_Unit_Schedules_SP;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Search_Unit_Schedules',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Search_Unit_Schedules;
---------------------------------------
-- Spec Procedure Get_MEvent_Details --
---------------------------------------
PROCEDURE Get_MEvent_Details
(
    p_api_version       IN      NUMBER,
    p_module_type       IN      VARCHAR2,
    x_return_status     OUT NOCOPY      VARCHAR2,
    x_msg_count     OUT NOCOPY      NUMBER,
    x_msg_data      OUT NOCOPY      VARCHAR2,
    p_x_MEvent_Header_Rec   IN OUT NOCOPY   MEvent_Header_Rec_Type,
    x_Unit_Schedule_tbl OUT NOCOPY  Unit_Schedule_Tbl_Type,
    x_Visit_Schedule_tbl    OUT NOCOPY  Visit_Schedule_Tbl_Type
)
IS
    -- 1.   Declare local variables
    l_api_name  CONSTANT    VARCHAR2(30)    := 'Get_MEvent_Details';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    L_DEBUG_MODULE  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    -- Variable to hold all the events in the time slot
    l_event_schedule_tbl        AHL_UA_COMMON_PVT.Event_schedule_Tbl_type;
    -- to store the flight record
    l_flight_schedule_rec       AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type;
    -- to store fetched visit record
    l_visit_rec                 AHL_VWP_VISITS_PVT.Visit_Rec_Type;
    -- to store previous and current record information
    l_prev_event_type       VARCHAR2(12);
    l_prev_unit_schedule_rec    AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type;
    l_prev_visit_schedule_rec   AHL_UA_UNIT_SCHEDULES_PVT. Visit_Schedule_rec_type;
    l_curr_event_type       VARCHAR2(12);
    l_curr_unit_schedule_rec    AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type;
    l_curr_visit_schedule_rec   AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type;

    -- to fetcch information related to unit.. to be shown on UI as context information
    CURSOR context_info_csr (p_unit_config_header_id IN NUMBER)
    IS
    -- Bug No #4916304: APPSPERF fixes {priyan}
    SELECT
         U.NAME,
         I.CONCATENATED_SEGMENTS ITEM_NUMBER,
         C.SERIAL_NUMBER
    FROM
        AHL_UNIT_CONFIG_HEADERS U,
        CSI_ITEM_INSTANCES C,
        MTL_SYSTEM_ITEMS_KFV I
    WHERE
        U.CSI_ITEM_INSTANCE_ID = C.INSTANCE_ID
        AND C.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND C.LAST_VLD_ORGANIZATION_ID = I.ORGANIZATION_ID
        AND UNIT_CONFIG_HEADER_ID = P_UNIT_CONFIG_HEADER_ID;
    /*
    SELECT name, item_number, serial_number
    FROM ahl_unit_header_details_v
    WHERE unit_config_header_id = p_unit_config_header_id;
    */

    -- to get a visit record information
    CURSOR visit_schedule_info_csr (p_visit_id IN NUMBER)
    IS
    -- Bug No #4916304: APPSPERF fixes {priyan}
    SELECT
        AVTB.VISIT_NUMBER,
        AVTT.VISIT_NAME,
        AVTB.ORGANIZATION_ID ORG_ID,
        MP.ORGANIZATION_CODE ORG_CODE,
        AVTB.DEPARTMENT_ID DEPT_ID,
        BDPT.DEPARTMENT_CODE DEPT_CODE,
        FLVT.MEANING VISIT_TYPE_MEAN,
        AVTB.STATUS_CODE,
        FNVS.MEANING STATUS_MEAN
    FROM
        AHL_VISITS_B AVTB,
        AHL_VISITS_TL AVTT,
        MTL_PARAMETERS MP,
        BOM_DEPARTMENTS BDPT,
        FND_LOOKUP_VALUES_VL FLVT,
        FND_LOOKUP_VALUES_VL FNVS
    WHERE
        AVTB.VISIT_ID = P_VISIT_ID
        AND AVTB.VISIT_ID = AVTT.VISIT_ID
        AND AVTT.LANGUAGE = USERENV('LANG')
        AND AVTB.ORGANIZATION_ID = MP.ORGANIZATION_ID(+)
        AND AVTB.DEPARTMENT_ID = BDPT.DEPARTMENT_ID(+)
        AND FLVT.LOOKUP_TYPE(+) = 'AHL_PLANNING_VISIT_TYPE'
        AND FLVT.LOOKUP_CODE(+) = AVTB.VISIT_TYPE_CODE
        AND FNVS.LOOKUP_TYPE(+) = 'AHL_VWP_VISIT_STATUS'
        AND FNVS.LOOKUP_CODE(+) = AVTB.STATUS_CODE;
    /*
    SELECT visit_number, visit_name, org_id, org_code, dept_id, dept_code,
    visit_type_mean, status_code, status_mean --,unit_schedule_id
    FROM ahl_visit_details_v
    WHERE visit_id = p_visit_id;
    */

    -- temporary variable to call other APIs
    l_is_conflict           VARCHAR2(1);
    l_is_org_in_user_ou         VARCHAR2(1);


    -- To search a flight record and hold search results
    l_flight_search_rec         AHL_UA_FLIGHT_SCHEDULES_PUB.FLIGHT_SEARCH_REC_TYPE;
    l_flight_schedules_tbl      AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE;

    -- early exit flag for module type 'US' processing
    l_early_exit_flag       BOOLEAN;


BEGIN

    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list by default
    FND_MSG_PUB.Initialize;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log API entry point
    ----dbms_output.put_line('At the start of PLSQL procedure');
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;
    -- API body starts here
    -- log input values
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            L_DEBUG_MODULE,
            'p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID : ' || p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID || ' ' ||
            'p_x_MEvent_Header_Rec.START_TIME : ' || p_x_MEvent_Header_Rec.START_TIME || ' ' ||
            'p_x_MEvent_Header_Rec.END_TIME : ' || p_x_MEvent_Header_Rec.END_TIME
        );
    END IF;
    -- validate mandatory input values
    IF(p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID IS NULL OR
       p_x_MEvent_Header_Rec.START_TIME IS NULL OR
       p_x_MEvent_Header_Rec.END_TIME IS NULL OR
       p_x_MEvent_Header_Rec.END_TIME <= p_x_MEvent_Header_Rec.START_TIME)THEN
       ----dbms_output.put_line('Unexpected error : Invalid Input');
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string
                (
                    fnd_log.level_error,
                    L_DEBUG_MODULE,
                    'Unexpected error : Invalid Input'
                );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --initialize profile values
    IF(G_DEPT_CONFLICT_PROF = 'Y')THEN
      G_DEPT_CONFLICT := TRUE;
    ELSE
      G_DEPT_CONFLICT := FALSE;
    END IF;



    -- populate header record with unit information
    -- needs to be executed when module type is OAF and not US
    IF(p_module_type <> 'US') THEN
        OPEN context_info_csr (p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID);
        FETCH context_info_csr INTO p_x_MEvent_Header_Rec.UNIT_NAME, p_x_MEvent_Header_Rec.ITEM_NUMBER,
                               p_x_MEvent_Header_Rec.SERIAL_NUMBER;
        IF(context_info_csr%NOTFOUND)THEN
            ----dbms_output.put_line('Unexpected error : Unit not found');
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string
                (
                    fnd_log.level_error,
                    L_DEBUG_MODULE,
                    'Unexpected error : unit not found'
                );
            END IF;
            CLOSE context_info_csr;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE context_info_csr;
    END IF;
    -- initialize header level conflict and Maintenance Opportunity related flags with default values
    p_x_MEvent_Header_Rec.HAS_CONFLICT := FND_API.G_FALSE;
    p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY := FND_API.G_FALSE;
    ----dbms_output.put_line('Calling AHL_UA_COMMON_PVT.get_all_events');
    -- Get all the events in the time slot
    AHL_UA_COMMON_PVT.get_all_events(
          p_api_version       => 1.0 ,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_unit_config_id    => p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID,
          p_start_date_time   => p_x_MEvent_Header_Rec.START_TIME,
          p_end_date_time     => p_x_MEvent_Header_Rec.END_TIME,
          p_use_actuals       => G_USE_ACTUALS,
          x_event_schedules   => l_event_schedule_tbl);
    -- Check for API errors
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      ----dbms_output.put_line('Unexpected error : AHL_UA_COMMON_PVT.get_all_events returned errors');
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string
          (
              fnd_log.level_error,
              L_DEBUG_MODULE,
              'Unexpected error : AHL_UA_COMMON_PVT.get_all_events returned errors'
          );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Set the event count
    IF(l_event_schedule_tbl IS NULL)THEN
        p_x_MEvent_Header_Rec.EVENT_COUNT := 0;
    ELSE
        p_x_MEvent_Header_Rec.EVENT_COUNT := l_event_schedule_tbl.COUNT;
    END IF;

    -- Get previous flight information in all cases
    AHL_UA_COMMON_PVT.Get_Prec_Flight_Info
    (
            p_api_version          =>  1.0,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_unit_config_id       => p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID,
            p_start_date_time      => p_x_MEvent_Header_Rec.START_TIME,
            p_use_actuals          => G_USE_ACTUALS,
            x_prec_flight_schedule => l_flight_schedule_rec,
            x_is_conflict          => l_is_conflict

     );
     -- Check for API errors
     IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
        ----dbms_output.put_line('Unexpected error : AHL_UA_COMMON_PVT.Get_Prec_Flight_Info returned errors');
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string
             (
                fnd_log.level_error,
                L_DEBUG_MODULE,
                'Unexpected error : AHL_UA_COMMON_PVT.Get_Prec_Flight_Info returned errors'
             );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- assign previous flight info if available
    IF(l_flight_schedule_rec.UNIT_SCHEDULE_ID IS NOT NULL)THEN
      l_prev_event_type := NULL;
      l_prev_unit_schedule_rec.UNIT_SCHEDULE_ID := l_flight_schedule_rec.UNIT_SCHEDULE_ID;
      l_prev_unit_schedule_rec.FLIGHT_NUMBER := l_flight_schedule_rec.FLIGHT_NUMBER;
    END IF;

    -- For first event(if it starts on or after start time of window) or if the event count is zero
    IF(
    p_x_MEvent_Header_Rec.EVENT_COUNT = 0 OR
    (p_module_type <> 'US' and l_event_schedule_tbl(l_event_schedule_tbl.FIRST).EVENT_START_TIME >= p_x_MEvent_Header_Rec.START_TIME) OR
    (p_module_type = 'US' and l_event_schedule_tbl(l_event_schedule_tbl.FIRST).EVENT_START_TIME > p_x_MEvent_Header_Rec.START_TIME)
      ) THEN
        AHL_UA_COMMON_PVT.Get_Prec_Event_Info
        (
            p_api_version          =>  1.0,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_unit_config_id       => p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID,
            p_start_date_time      => p_x_MEvent_Header_Rec.START_TIME,
            p_use_actuals          => G_USE_ACTUALS,
            x_prec_flight_schedule => l_flight_schedule_rec,
            x_prec_visit           => l_visit_rec,
            x_is_conflict          => l_is_conflict,
            x_is_org_in_user_ou    => l_is_org_in_user_ou

        );
       -- Check for API errors
       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         ----dbms_output.put_line('Unexpected error : AHL_UA_COMMON_PVT.Get_Prec_Visit_Info returned errors');
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string
             (
                fnd_log.level_error,
                L_DEBUG_MODULE,
                'Unexpected error : AHL_UA_COMMON_PVT.Get_Prec_Event_Info returned errors'
             );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       -- determine type of previous event
       IF(l_flight_schedule_rec.unit_schedule_id IS NOT NULL)THEN
          l_prev_event_type := G_EVENT_TYPE_FLIGHT;
       ELSIF(l_visit_rec.visit_id IS NOT NULL)THEN
          l_prev_event_type := G_EVENT_TYPE_VISIT;
       END IF;
       -- populate prior event info into local variable for previous event
       IF(l_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
         ----dbms_output.put_line('calling populate_unit_schedule_rec for  pre window event');
         populate_unit_schedule_rec(
            p_unit_flight_schedule_rec => l_flight_schedule_rec,
            p_prev_event_type          => NULL,
            p_window_event             => FALSE,
            p_prev_unit_schedule_rec   => NULL,
            p_prev_visit_schedule_rec  => NULL,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_unit_schedule_rec        => l_prev_unit_schedule_rec
         );

       ELSIF(l_prev_event_type = G_EVENT_TYPE_VISIT)THEN
         ----dbms_output.put_line('calling populate_visit_schedule_rec for  pre window event');
         OPEN visit_schedule_info_csr(l_visit_rec.visit_id);
         FETCH visit_schedule_info_csr INTO l_visit_rec.visit_number,
                                             l_visit_rec.visit_name,
                                             l_visit_rec.organization_id,
                                             l_visit_rec.org_name,
                                             l_visit_rec.department_id,
                                             l_visit_rec.dept_name,
                                             l_visit_rec.visit_type_name,
                                             l_visit_rec.status_code,
                                             l_visit_rec.status_name;--,unit_schedule_id
         CLOSE visit_schedule_info_csr;
         populate_visit_schedule_rec(
            p_visit_rec                => l_visit_rec,
            p_prev_event_type          => NULL,
            p_window_event             => FALSE,
            p_prev_unit_schedule_rec   => NULL,
            p_prev_visit_schedule_rec  => NULL,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_Visit_Schedule_Rec       => l_prev_visit_schedule_rec
         );
         l_prev_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID := l_prev_unit_schedule_rec.UNIT_SCHEDULE_ID ;
         l_prev_visit_schedule_rec.PREV_FLIGHT_NUMBER := l_prev_unit_schedule_rec.FLIGHT_NUMBER;
       END IF;
    END IF;
    -- For all events in the window
    ----dbms_output.put_line('processing window events');
    IF(p_x_MEvent_Header_Rec.EVENT_COUNT > 0)THEN
      ----dbms_output.put_line('p_x_MEvent_Header_Rec.EVENT_COUNT : ' || p_x_MEvent_Header_Rec.EVENT_COUNT);
      FOR i IN l_event_schedule_tbl.FIRST..l_event_schedule_tbl.LAST  LOOP
        IF(l_event_schedule_tbl(i).EVENT_TYPE = G_EVENT_TYPE_FLIGHT)THEN
          l_curr_event_type := G_EVENT_TYPE_FLIGHT;
          l_flight_search_rec.UNIT_SCHEDULE_ID := l_event_schedule_tbl(i).EVENT_ID;
          ----dbms_output.put_line('calling AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details for UNIT_SCHEDULE_ID : ' || l_flight_search_rec.UNIT_SCHEDULE_ID);
          AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details(
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_TRUE,
                p_commit                        => FND_API.G_FALSE,
                p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
                p_default                       => FND_API.G_FALSE,
                p_module_type                   => 'US',
                x_return_status                 => x_return_status,
                x_msg_count                     => x_msg_count,
                x_msg_data                      => x_msg_data,
                p_flight_search_rec             => l_flight_search_rec,
                x_flight_schedules_tbl          => l_flight_schedules_tbl
          );
          -- Check for API errors
          IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            ----dbms_output.put_line('Unexpected error : AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details returned error');
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string
                (
                    fnd_log.level_error,
                    L_DEBUG_MODULE,
                    'Unexpected error : AHL_UA_FLIGHT_SCHEDULES_PUB.Get_Flight_Schedule_Details returned error'
                );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          l_flight_schedule_rec := l_flight_schedules_tbl(l_flight_schedules_tbl.FIRST);
          ----dbms_output.put_line('calling populate_unit_schedule_rec for window event');
          populate_unit_schedule_rec(
            p_unit_flight_schedule_rec => l_flight_schedule_rec,
            p_prev_event_type          => l_prev_event_type,
            p_window_event             => TRUE,
            p_prev_unit_schedule_rec   => l_prev_unit_schedule_rec,
            p_prev_visit_schedule_rec  => l_prev_visit_schedule_rec,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_Unit_Schedule_Rec        => l_curr_unit_schedule_rec
          );
          l_prev_event_type := l_curr_event_type;
          l_prev_unit_schedule_rec := l_curr_unit_schedule_rec;
        ELSIF(l_event_schedule_tbl(i).EVENT_TYPE = G_EVENT_TYPE_VISIT)THEN
          l_curr_event_type := G_EVENT_TYPE_VISIT;
          ----dbms_output.put_line('Getting visit information for visit_id : ' || l_event_schedule_tbl(i).EVENT_ID);
          OPEN visit_schedule_info_csr(l_event_schedule_tbl(i).EVENT_ID);
          FETCH visit_schedule_info_csr INTO l_visit_rec.visit_number,
                                             l_visit_rec.visit_name,
                                             l_visit_rec.organization_id,
                                             l_visit_rec.org_name,
                                             l_visit_rec.department_id,
                                             l_visit_rec.dept_name,
                                             l_visit_rec.visit_type_name,
                                             l_visit_rec.status_code,
                                             l_visit_rec.status_name;--,unit_schedule_id
          l_visit_rec.visit_id := l_event_schedule_tbl(i).EVENT_ID;
          l_visit_rec.start_date := l_event_schedule_tbl(i).EVENT_START_TIME;
          l_visit_rec.end_date := l_event_schedule_tbl(i).EVENT_END_TIME;
          ----dbms_output.put_line('calling populate_visit_schedule_rec for window event');
          populate_visit_schedule_rec(
            p_visit_rec                => l_visit_rec,
            p_prev_event_type          => l_prev_event_type,
            p_window_event             => TRUE,
            p_prev_unit_schedule_rec   => l_prev_unit_schedule_rec,
            p_prev_visit_schedule_rec  => l_prev_visit_schedule_rec,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_Visit_Schedule_Rec       => l_curr_visit_schedule_rec
          );
          CLOSE visit_schedule_info_csr;
          l_prev_event_type := l_curr_event_type;
          l_prev_visit_schedule_rec := l_curr_visit_schedule_rec;
        END IF;
        -- if module type is US then if there is MO and Conflcit.. return without further processing to save resources.
        IF(p_module_type = 'US' AND p_x_MEvent_Header_Rec.HAS_CONFLICT = FND_API.G_TRUE AND p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE)THEN
           l_early_exit_flag := TRUE;
           EXIT;
        END IF;
      END LOOP;
    END IF;
    -- For search unit schedule when already determined that there are conflcits and maintenance opportunities
    IF(l_early_exit_flag)THEN
      ----dbms_output.put_line('exiting early');
      RETURN;
    END IF;

    -- For last event(if it ends before end time of window) or if the event count is zero
    IF(p_x_MEvent_Header_Rec.EVENT_COUNT = 0 OR
       NVL(l_event_schedule_tbl(l_event_schedule_tbl.LAST).EVENT_END_TIME,
           l_event_schedule_tbl(l_event_schedule_tbl.LAST).EVENT_START_TIME + 1/1440 )< p_x_MEvent_Header_Rec.END_TIME) THEN
       -- populate previous event information
       -- get previous flight information
       AHL_UA_COMMON_PVT.Get_Succ_Event_Info
       (
            p_api_version          =>  1.0,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_unit_config_id       => p_x_MEvent_Header_Rec.UNIT_CONFIG_HEADER_ID,
            p_end_date_time        => p_x_MEvent_Header_Rec.END_TIME,
            p_use_actuals          => G_USE_ACTUALS,
            x_succ_flight_schedule => l_flight_schedule_rec,
            x_succ_visit           => l_visit_rec,
            x_is_conflict          => l_is_conflict,
            x_is_org_in_user_ou    => l_is_org_in_user_ou

        );
       -- Check for API errors
       IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
          ----dbms_output.put_line('Unexpected error : AHL_UA_COMMON_PVT.Get_Succ_Event_Info returned errors');
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string
             (
                fnd_log.level_error,
                L_DEBUG_MODULE,
                'Unexpected error : AHL_UA_COMMON_PVT.Get_Succ_Event_Info returned errors'
             );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       -- determine type of last event
       IF(l_flight_schedule_rec.unit_schedule_id IS NOT NULL)THEN
          l_curr_event_type := G_EVENT_TYPE_FLIGHT;
       ELSIF(l_visit_rec.visit_id IS NOT NULL)THEN
          l_curr_event_type := G_EVENT_TYPE_VISIT;
       ELSE
          l_curr_event_type := NULL;--no last event found
       END IF;
       -- populate prior event info into local variable for previous event
       IF(l_curr_event_type = G_EVENT_TYPE_FLIGHT)THEN
         ----dbms_output.put_line('calling populate_unit_schedule_rec for  post window event');
         populate_unit_schedule_rec(
            p_unit_flight_schedule_rec => l_flight_schedule_rec,
            p_prev_event_type          => l_prev_event_type,
            p_window_event             => FALSE,
            p_prev_unit_schedule_rec   => l_prev_unit_schedule_rec,
            p_prev_visit_schedule_rec  => l_prev_visit_schedule_rec,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_Unit_Schedule_Rec        => l_curr_unit_schedule_rec
         );
       ELSIF(l_curr_event_type = G_EVENT_TYPE_VISIT)THEN
         ----dbms_output.put_line('calling populate_visit_schedule_rec for  post window event');
         OPEN visit_schedule_info_csr(l_visit_rec.visit_id);
         FETCH visit_schedule_info_csr INTO l_visit_rec.visit_number,
                                             l_visit_rec.visit_name,
                                             l_visit_rec.organization_id,
                                             l_visit_rec.org_name,
                                             l_visit_rec.department_id,
                                             l_visit_rec.dept_name,
                                             l_visit_rec.visit_type_name,
                                             l_visit_rec.status_code,
                                             l_visit_rec.status_name;--,unit_schedule_id
         CLOSE visit_schedule_info_csr;
         populate_visit_schedule_rec(
            p_visit_rec                => l_visit_rec,
            p_prev_event_type          => l_prev_event_type,
            p_window_event             => FALSE,
            p_prev_unit_schedule_rec   => l_prev_unit_schedule_rec,
            p_prev_visit_schedule_rec  => l_prev_visit_schedule_rec,
            p_x_MEvent_Header_Rec      => p_x_MEvent_Header_Rec,
            p_x_Unit_Schedule_tbl      => x_Unit_Schedule_tbl,
            p_x_Visit_Schedule_tbl     => x_Visit_Schedule_tbl,
            x_Visit_Schedule_Rec       => l_curr_visit_schedule_rec
         );
       ELSE -- when no post window event is found
       -- a dummy record needs to be added with MO flag as FND_API.G_TRUE if there is flight for unit
       -- either can add it to flight or visit, lets add where perious event lies
       --Adithya added the end_date > sysdate condition for FP bug# 6447447.
           IF(l_prev_event_type IS NOT NULL AND p_x_MEvent_Header_Rec.END_TIME > SYSDATE)THEN
             IF(l_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
               l_curr_unit_schedule_rec := NULL;--initilaize it
               l_curr_unit_schedule_rec.PREV_EVENT_ID       := l_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
               l_curr_unit_schedule_rec.PREV_EVENT_TYPE     := l_prev_event_type;
               l_curr_unit_schedule_rec.PREV_EVENT_ORG_ID   := l_prev_unit_schedule_rec.ARRIVAL_ORG_ID;
               l_curr_Unit_Schedule_Rec.IS_PREV_ORG_VALID   := l_prev_unit_schedule_rec.IS_ORG_VALID;
               l_curr_unit_schedule_rec.PREV_EVENT_ORG_NAME := l_prev_unit_schedule_rec.ARRIVAL_ORG_NAME;
               l_curr_unit_schedule_rec.PREV_EVENT_DEP_ID   := l_prev_unit_schedule_rec.ARRIVAL_DEP_ID;
               l_curr_unit_schedule_rec.PRVE_EVENT_DEP_NAME := l_prev_unit_schedule_rec.ARRIVAL_DEP_NAME;
               l_curr_unit_schedule_rec.PREV_EVENT_END_TIME := l_prev_unit_schedule_rec.ARRIVAL_TIME;
               l_curr_unit_schedule_rec.PREV_UNIT_SCHEDULE_ID   := l_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
               l_curr_unit_schedule_rec.PREV_FLIGHT_NUMBER  := l_prev_unit_schedule_rec.FLIGHT_NUMBER;
               l_curr_unit_schedule_rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;
               l_curr_unit_schedule_rec.HAS_CONFLICT        := FND_API.G_FALSE;
               l_prev_unit_schedule_rec.EVENT_SEQ           := NVL(l_prev_unit_schedule_rec.EVENT_SEQ,1);
               l_curr_unit_schedule_rec.EVENT_SEQ           := l_prev_unit_schedule_rec.EVENT_SEQ + 1;
               -- add pre-window event if event count = 0
               IF(p_x_MEvent_Header_Rec.EVENT_COUNT = 0)THEN
                  x_Unit_Schedule_tbl(l_prev_unit_schedule_rec.EVENT_SEQ -1 ) := l_prev_unit_schedule_rec;
               END IF;
               -- add current dummy event
               x_Unit_Schedule_tbl(l_curr_unit_schedule_rec.EVENT_SEQ -1) := l_curr_unit_schedule_rec;
               -- update header to tell that there is a MO
               p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;

	     --Adithya modified the condition below as part of fix for FP bug# 6447447
 	     -- Even if there are no flights but visits exist in the past, MO should be flagged
             ELSIF(l_prev_event_type = G_EVENT_TYPE_VISIT) --AND l_prev_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID IS NOT NULL)
	     THEN
               l_curr_visit_schedule_rec := NULL;--initilaize it
               l_curr_visit_schedule_rec.PREV_EVENT_ID        := l_prev_visit_schedule_rec.VISIT_ID;
               l_curr_visit_schedule_rec.PREV_EVENT_TYPE          := l_prev_event_type;
               l_curr_visit_schedule_rec.PREV_EVENT_ORG_ID    := l_prev_visit_schedule_rec.VISIT_ORG_ID;
               l_curr_visit_Schedule_Rec.IS_PREV_ORG_VALID    := l_prev_visit_schedule_rec.IS_ORG_VALID;
               l_curr_visit_schedule_rec.PREV_EVENT_ORG_NAME  := l_prev_visit_schedule_rec.VISIT_ORG_NAME;
               l_curr_visit_schedule_rec.PREV_EVENT_DEP_ID    := l_prev_visit_schedule_rec.VISIT_DEP_ID;
               l_curr_visit_schedule_rec.PRVE_EVENT_DEP_NAME  := l_prev_visit_schedule_rec.VISIT_DEP_NAME;
               l_curr_visit_schedule_rec.PREV_EVENT_END_TIME  :=
                                          NVL(l_prev_visit_schedule_rec.END_TIME, l_prev_visit_schedule_rec.START_TIME + 1/1440);
               l_curr_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID := l_prev_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID;
               l_curr_visit_schedule_rec.PREV_FLIGHT_NUMBER   := l_prev_visit_schedule_rec.PREV_FLIGHT_NUMBER;
               l_curr_visit_schedule_rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;
               l_curr_visit_schedule_rec.HAS_CONFLICT        := FND_API.G_FALSE;
               l_prev_visit_schedule_rec.EVENT_SEQ           := NVL(l_prev_visit_schedule_rec.EVENT_SEQ,1);
               l_curr_visit_schedule_rec.EVENT_SEQ           := l_prev_visit_schedule_rec.EVENT_SEQ + 1;
               -- add pre-window event if event count = 0
               IF(p_x_MEvent_Header_Rec.EVENT_COUNT = 0)THEN
                  x_Visit_Schedule_tbl(l_prev_visit_schedule_rec.EVENT_SEQ - 1) := l_prev_visit_schedule_rec;
               END IF;
               -- add current event
               x_Visit_Schedule_tbl(l_curr_visit_schedule_rec.EVENT_SEQ -1) := l_curr_visit_schedule_rec;
               -- update header to tell that there is a MO
               p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;
             END IF;

	     --Adithya modified code for fixing FP bug# 6447447  -- Start --
	     ELSIF ( p_x_MEvent_Header_Rec.END_TIME > SYSDATE )
	     --if no events are found ( i.e. previous event id is null)
		  THEN
		    l_curr_visit_schedule_rec := NULL;--initilaize it
		    l_curr_visit_schedule_rec.EVENT_SEQ           := 1;
			l_curr_visit_schedule_rec.PREV_EVENT_END_TIME        := sysdate;
		    l_curr_visit_schedule_rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;
		    l_curr_visit_schedule_rec.HAS_CONFLICT        := FND_API.G_FALSE;
		    -- add current dummy event
		    x_Visit_Schedule_tbl(0) := l_curr_visit_schedule_rec;
		    -- update header to tell that there is a MO
		    p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY    := FND_API.G_TRUE;
	      --Adithya modified code for fixing FP bug# 6447447  -- END --

           END IF;
       END IF;
    END IF;

    ----dbms_output.put_line('returning after success');
    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Get_MEvent_Details',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Get_MEvent_Details;
-------------------------------------------------------------------------------------------
-- Non-spec Procedure populate_unit_schedule_rec --
-- Determines Maintenance Opportunity and Conflcits for the current flight record
-- Prepare it with transient variable calculations
-------------------------------------------------------------------------------------------
PROCEDURE populate_unit_schedule_rec(
         p_unit_flight_schedule_rec IN            AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
         p_prev_event_type          IN            VARCHAR2,
         p_window_event             IN            BOOLEAN,
         p_prev_unit_schedule_rec   IN            AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type,
         p_prev_visit_schedule_rec  IN            AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type,
         p_x_MEvent_Header_Rec      IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.MEvent_Header_Rec_Type,
         p_x_Unit_Schedule_tbl      IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_Tbl_Type,
         p_x_Visit_Schedule_tbl     IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_Tbl_Type,
         x_Unit_Schedule_Rec        OUT NOCOPY     AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type
      ) IS

      --    Declare local variables
      l_api_name    CONSTANT    VARCHAR2(30)    := 'populate_unit_schedule_rec';
      L_DEBUG_MODULE    CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

      add_pre_window_event BOOLEAN;
      l_previous_event_seq NUMBER;
      l_index NUMBER;

      org_conflict BOOLEAN;
      dept_conflict BOOLEAN;
      time_conflict BOOLEAN;

      l_org_valid VARCHAR2(1);
      l_return_status VARCHAR2(1);
      l_msg_data VARCHAR2(2000);

      -- added this variable because visit_end_date might be null and we have to add 1 min to the start time to
      -- compare for conflcits.
      l_prev_event_end_time DATE;

BEGIN
     -- Log API entry point
     ----dbms_output.put_line('adding flight record for unit_schedule_id : ' || p_unit_flight_schedule_rec.UNIT_SCHEDULE_ID);
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
     THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.begin',
            'At the start of PLSQL procedure'
        );
     END IF;


     x_Unit_Schedule_Rec.UNIT_SCHEDULE_ID      := p_unit_flight_schedule_rec.UNIT_SCHEDULE_ID;
     x_Unit_Schedule_Rec.FLIGHT_NUMBER         := p_unit_flight_schedule_rec.FLIGHT_NUMBER;
     x_Unit_Schedule_Rec.SEGMENT               := p_unit_flight_schedule_rec.SEGMENT;
     x_Unit_Schedule_Rec.DEPARTURE_ORG_ID      := p_unit_flight_schedule_rec.DEPARTURE_ORG_ID;
     x_Unit_Schedule_Rec.DEPARTURE_ORG_NAME    := p_unit_flight_schedule_rec.DEPARTURE_ORG_CODE;
     x_Unit_Schedule_Rec.DEPARTURE_DEP_ID      := p_unit_flight_schedule_rec.DEPARTURE_DEPT_ID;
     x_Unit_Schedule_Rec.DEPARTURE_DEP_NAME    := p_unit_flight_schedule_rec.DEPARTURE_DEPT_CODE;
     x_Unit_Schedule_Rec.ARRIVAL_ORG_ID        := p_unit_flight_schedule_rec.ARRIVAL_ORG_ID;
     x_Unit_Schedule_Rec.ARRIVAL_ORG_NAME      := p_unit_flight_schedule_rec.ARRIVAL_ORG_CODE;
     x_Unit_Schedule_Rec.ARRIVAL_DEP_ID        := p_unit_flight_schedule_rec.ARRIVAL_DEPT_ID;
     x_Unit_Schedule_Rec.ARRIVAL_DEP_NAME      := p_unit_flight_schedule_rec.ARRIVAL_DEPT_CODE;



     -- whether the org is valid for the user
     x_Unit_Schedule_Rec.IS_ORG_VALID := FND_API.G_TRUE;
     IF(p_unit_flight_schedule_rec.ARRIVAL_ORG_ID IS NOT NULL)THEN
        x_Unit_Schedule_Rec.IS_ORG_VALID := AHL_UTILITY_PVT.IS_ORG_IN_USER_OU(
                                                     p_org_id   => p_unit_flight_schedule_rec.ARRIVAL_ORG_ID,
                                                     p_org_name => NULL,
                                                     x_return_status => l_return_status,
                                                     x_msg_data => l_msg_data
                                                     );
        -- Check for API errors
        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
           ----dbms_output.put_line('Unexpected error : AHL_UTILITY_PVT.IS_ORG_IN_USER_OU returned errors');
           IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string
             (
                fnd_log.level_error,
                L_DEBUG_MODULE,
                'Unexpected error : AHL_UTILITY_PVT.IS_ORG_IN_USER_OU returned errors'
             );
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     IF(G_USE_ACTUALS = FND_API.G_FALSE)THEN
        x_Unit_Schedule_Rec.DEPARTURE_TIME := p_unit_flight_schedule_rec.EST_DEPARTURE_TIME;
        x_Unit_Schedule_Rec.ARRIVAL_TIME   := p_unit_flight_schedule_rec.EST_ARRIVAL_TIME;
     ELSE
        x_Unit_Schedule_Rec.DEPARTURE_TIME := NVL(p_unit_flight_schedule_rec.ACTUAL_DEPARTURE_TIME,
                                              p_unit_flight_schedule_rec.EST_DEPARTURE_TIME);
        x_Unit_Schedule_Rec.ARRIVAL_TIME   := NVL(p_unit_flight_schedule_rec.ACTUAL_ARRIVAL_TIME,
                                              p_unit_flight_schedule_rec.EST_ARRIVAL_TIME);
     END IF;

     x_Unit_Schedule_Rec.PREV_EVENT_TYPE := p_prev_event_type;
     x_Unit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_FALSE;
     x_Unit_Schedule_Rec.HAS_CONFLICT     := FND_API.G_FALSE;

     IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
        ----dbms_output.put_line('prev event type  : ' || G_EVENT_TYPE_FLIGHT);
        x_Unit_Schedule_Rec.PREV_EVENT_ID       := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Unit_Schedule_Rec.PREV_EVENT_ORG_ID   := p_prev_unit_schedule_rec.ARRIVAL_ORG_ID;
        x_Unit_Schedule_Rec.IS_PREV_ORG_VALID   := p_prev_unit_schedule_rec.IS_ORG_VALID;
        x_Unit_Schedule_Rec.PREV_EVENT_ORG_NAME := p_prev_unit_schedule_rec.ARRIVAL_ORG_NAME;
        x_Unit_Schedule_Rec.PREV_EVENT_DEP_ID   := p_prev_unit_schedule_rec.ARRIVAL_DEP_ID;
        x_Unit_Schedule_Rec.PRVE_EVENT_DEP_NAME := p_prev_unit_schedule_rec.ARRIVAL_DEP_NAME;
        l_prev_event_end_time                   := p_prev_unit_schedule_rec.ARRIVAL_TIME;
        x_Unit_Schedule_Rec.PREV_EVENT_END_TIME := l_prev_event_end_time;
        x_Unit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID   := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Unit_Schedule_Rec.PREV_FLIGHT_NUMBER  := p_prev_unit_schedule_rec.FLIGHT_NUMBER;
        l_previous_event_seq                    := NVL(p_prev_unit_schedule_rec.EVENT_SEQ,0);
     ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
        ----dbms_output.put_line('prev event type  : ' || G_EVENT_TYPE_VISIT);
        x_Unit_Schedule_Rec.PREV_EVENT_ID       := p_prev_visit_schedule_rec.VISIT_ID;
        x_Unit_Schedule_Rec.PREV_EVENT_ORG_ID   := p_prev_visit_schedule_rec.VISIT_ORG_ID;
        x_Unit_Schedule_Rec.IS_PREV_ORG_VALID   := p_prev_visit_schedule_rec.IS_ORG_VALID;
        x_Unit_Schedule_Rec.PREV_EVENT_ORG_NAME := p_prev_visit_schedule_rec.VISIT_ORG_NAME;
        x_Unit_Schedule_Rec.PREV_EVENT_DEP_ID   := p_prev_visit_schedule_rec.VISIT_DEP_ID;
        x_Unit_Schedule_Rec.PRVE_EVENT_DEP_NAME := p_prev_visit_schedule_rec.VISIT_DEP_NAME;
        l_prev_event_end_time                   := NVL(p_prev_visit_schedule_rec.END_TIME,
                      p_prev_visit_schedule_rec.START_TIME + 1/1440) ;
        x_Unit_Schedule_Rec.PREV_EVENT_END_TIME := l_prev_event_end_time;
        x_Unit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID   := p_prev_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID;
        x_Unit_Schedule_Rec.PREV_FLIGHT_NUMBER  := p_prev_visit_schedule_rec.PREV_FLIGHT_NUMBER;
        l_previous_event_seq                    := NVL(p_prev_visit_schedule_rec.EVENT_SEQ,0);
     ELSE
        x_Unit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID   := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Unit_Schedule_Rec.PREV_FLIGHT_NUMBER  := p_prev_unit_schedule_rec.FLIGHT_NUMBER;
     END IF;

     -- Determine Conflcits
     IF(x_Unit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL)THEN
        IF(x_Unit_Schedule_Rec.DEPARTURE_ORG_ID <> x_Unit_Schedule_Rec.PREV_EVENT_ORG_ID)THEN
           x_Unit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
           org_conflict := TRUE;
        END IF;
        IF(G_DEPT_CONFLICT AND x_Unit_Schedule_Rec.DEPARTURE_DEP_ID <> x_Unit_Schedule_Rec.PREV_EVENT_DEP_ID)THEN
           x_Unit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
           dept_conflict := TRUE;
        END IF;
        IF(x_Unit_Schedule_Rec.DEPARTURE_TIME < l_prev_event_end_time)THEN
           x_Unit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
           time_conflict := TRUE;
        END IF;
     END IF;

     -- Determine Maintenance Opportunity
     -- MO should be in future
     /*
      * Commenting out the following lines of code - bug #4071097 has been converted to ER...
      * Retaining code since this will later be needed anyway, when the ER is worked upon...
      */
       -- Uncommented the following lines of code as part of fix for bug# 6447447
     IF(x_Unit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL AND
        --x_Unit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID IS NOT NULL AND
        x_Unit_Schedule_Rec.DEPARTURE_TIME > l_prev_event_end_time AND
        x_Unit_Schedule_Rec.DEPARTURE_TIME > SYSDATE) THEN
        IF(l_prev_event_end_time >= SYSDATE AND
          (x_Unit_Schedule_Rec.DEPARTURE_TIME - l_prev_event_end_time)*24*60 >= G_MIN_TIME_MO)THEN
           x_Unit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        ELSIF(l_prev_event_end_time < SYSDATE AND
          (x_Unit_Schedule_Rec.DEPARTURE_TIME - SYSDATE)*24*60 >= G_MIN_TIME_MO)THEN
           x_Unit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        END IF;
     END IF;
     --Commented the following lines of code as part of fix for bug# 6447447
     /*
     IF(x_Unit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL AND
        x_Unit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID IS NOT NULL AND
        x_Unit_Schedule_Rec.DEPARTURE_TIME > l_prev_event_end_time) THEN
        IF ((x_Unit_Schedule_Rec.DEPARTURE_TIME - l_prev_event_end_time)*24*60 >= G_MIN_TIME_MO)THEN
           x_Unit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        END IF;
     END IF;
     */

     add_pre_window_event := FALSE;
     -- Determine event sequence based on window and non window event
     -- decide whether to add "out of window" records.
     -- out of window events will be added when there is MO or conflcit
     IF(p_window_event)THEN
       IF(x_Unit_Schedule_Rec.PREV_EVENT_ID IS NULL)THEN
         x_Unit_Schedule_Rec.EVENT_SEQ := 1;
       ELSE
         IF(l_previous_event_seq > 0)THEN
            x_Unit_Schedule_Rec.EVENT_SEQ := l_previous_event_seq + 1;
         ELSE
            IF(x_Unit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE OR x_Unit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
               add_pre_window_event := TRUE;
               x_Unit_Schedule_Rec.EVENT_SEQ := 2;
            ELSE
               x_Unit_Schedule_Rec.EVENT_SEQ := 1;
            END IF;
         END IF;
       END IF;
     ELSIF( NOT p_window_event AND x_Unit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL)THEN
       IF(x_Unit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE OR x_Unit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
         IF(l_previous_event_seq > 0)THEN
            x_Unit_Schedule_Rec.EVENT_SEQ := l_previous_event_seq + 1;
         ELSE
            add_pre_window_event := TRUE;
            x_Unit_Schedule_Rec.EVENT_SEQ := 2;
         END IF;
       END IF;
     END IF;
     -- add pre window event if applicable
     IF(add_pre_window_event)THEN
       IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
         p_x_Unit_Schedule_tbl(0) := p_prev_unit_schedule_rec;
         p_x_Unit_Schedule_tbl(0).EVENT_SEQ := 1;
       ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
         p_x_Visit_Schedule_tbl(0) := p_prev_visit_schedule_rec;
         p_x_Visit_Schedule_tbl(0).EVENT_SEQ := 1;
       END IF;
     END IF;

     -- Add Conflcit Message
     IF(x_Unit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
       -- Event with sequence () and previous Event() has conflcits.
       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FLIGHT_CONFLICT_MSG');
       FND_MESSAGE.SET_TOKEN('EVENT_SEQ1',x_Unit_Schedule_Rec.EVENT_SEQ,false);
       FND_MESSAGE.SET_TOKEN('EVENT_SEQ2',x_Unit_Schedule_Rec.EVENT_SEQ -1,false);
       x_Unit_Schedule_Rec.CONFLICT_MESSAGE := FND_MESSAGE.get;
       IF(org_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Departure Org() and previous flight Arrival Org() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FFO_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('DEP_ORG',x_Unit_Schedule_Rec.DEPARTURE_ORG_NAME,false);
           FND_MESSAGE.SET_TOKEN('ARR_ORG',p_prev_unit_schedule_rec.ARRIVAL_ORG_NAME,false);
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE || FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Daparture Org() and previous visit Org() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FVO_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('DEP_ORG',x_Unit_Schedule_Rec.DEPARTURE_ORG_NAME,false);
           FND_MESSAGE.SET_TOKEN('VST_ORG',p_prev_visit_schedule_rec.VISIT_ORG_NAME,false);
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE || FND_MESSAGE.get;
         END IF;
       END IF;
       IF(dept_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Departure Dept() and previous flight Arrival Dept() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FFD_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('DEP_DEPT',x_Unit_Schedule_Rec.DEPARTURE_DEP_NAME,false);
           FND_MESSAGE.SET_TOKEN('ARR_DEPT',p_prev_unit_schedule_rec.ARRIVAL_DEP_NAME,false);
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Departure Dept() and previous visit Dept() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FVD_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('DEP_DEPT',x_Unit_Schedule_Rec.DEPARTURE_DEP_NAME,false);
           FND_MESSAGE.SET_TOKEN('VST_DEPT',p_prev_visit_schedule_rec.VISIT_DEP_NAME,false);
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         END IF;
       END IF;
       IF(time_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Departure Time and previous flight Arrival Time has overlap.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FFT_CONFLICT_MSG');
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Departure Time and previous Visit End Time has overlap.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FVT_CONFLICT_MSG');
           x_Unit_Schedule_Rec.CONFLICT_MESSAGE := x_Unit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         END IF;
       END IF;
     END IF;
     -- add current event to table of events.
     IF(NVL(x_Unit_Schedule_Rec.EVENT_SEQ,0) > 0)THEN
        IF(p_x_Unit_Schedule_tbl IS NULL)THEN
          l_index := 0;
        ELSE
          l_index := p_x_Unit_Schedule_tbl.COUNT;
        END IF;
        p_x_Unit_Schedule_tbl(l_index) := x_Unit_Schedule_Rec;
     END IF;

     -- Update conflict or MO at the header level
     IF(x_Unit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
        p_x_MEvent_Header_Rec.HAS_CONFLICT := FND_API.G_TRUE;
     END IF;
     IF(x_Unit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE)THEN
        p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
     END IF;

     -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;
    ----dbms_output.put_line('added flight record for unit_schedule_id : ' || p_unit_flight_schedule_rec.UNIT_SCHEDULE_ID);


END populate_unit_schedule_rec;

-------------------------------------------------------------------------------------------
-- Non-spec Procedure populate_visit_schedule_rec --
-- Determines Maintenance Opportunity and Conflcits for the current visit record
-- Prepare it with transient variable calculations
-------------------------------------------------------------------------------------------
PROCEDURE populate_visit_schedule_rec(
         p_visit_rec                IN            AHL_VWP_VISITS_PVT.Visit_Rec_Type,
         p_prev_event_type          IN            VARCHAR2,
         p_window_event             IN            BOOLEAN,
         p_prev_unit_schedule_rec   IN            AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_rec_type,
         p_prev_visit_schedule_rec  IN            AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type,
         p_x_MEvent_Header_Rec      IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.MEvent_Header_Rec_Type,
         p_x_Unit_Schedule_tbl      IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.Unit_Schedule_Tbl_Type,
         p_x_Visit_Schedule_tbl     IN OUT NOCOPY AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_Tbl_Type,
         x_visit_schedule_rec       OUT NOCOPY    AHL_UA_UNIT_SCHEDULES_PVT.Visit_Schedule_rec_type
      )IS

      --    Declare local variables
      l_api_name    CONSTANT    VARCHAR2(30)    := 'populate_visit_schedule_rec';
      L_DEBUG_MODULE    CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

      add_pre_window_event BOOLEAN;
      l_previous_event_seq NUMBER;
      l_index NUMBER;

      org_conflict BOOLEAN;
      dept_conflict BOOLEAN;
      time_conflict BOOLEAN;

      l_org_valid VARCHAR2(1);
      l_return_status VARCHAR2(1);
      l_msg_data VARCHAR2(2000);

      -- added this variable because visit_end_date might be null and we have to add 1 min to the start time to
      -- compare for conflcits.
      l_prev_event_end_time DATE;

BEGIN
     -- Log API entry point
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
     THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.begin',
            'At the start of PLSQL procedure'
        );
     END IF;
     ----dbms_output.put_line('adding visit record for VISIT_ID : ' || p_Visit_Rec.VISIT_ID);

     x_visit_Schedule_rec.VISIT_ID          := p_Visit_Rec.VISIT_ID;
     x_visit_Schedule_rec.VISIT_NUMBER      := p_Visit_Rec.VISIT_NUMBER;
     x_visit_Schedule_rec.VISIT_NAME        := p_Visit_Rec.VISIT_NAME;
     x_visit_Schedule_rec.VISIT_TYPE        := p_Visit_Rec.VISIT_TYPE_NAME;
     x_visit_Schedule_rec.VISIT_STATUS_CODE := p_Visit_Rec.STATUS_CODE;
     x_visit_Schedule_rec.VISIT_STATUS      := p_Visit_Rec.STATUS_NAME;
     ----dbms_output.put_line('adding org and dept info: ');

     x_Visit_Schedule_Rec.VISIT_ORG_ID      := p_Visit_Rec.ORGANIZATION_ID;
     x_Visit_Schedule_Rec.VISIT_ORG_NAME    := p_Visit_Rec.ORG_NAME;
     x_Visit_Schedule_Rec.VISIT_DEP_ID      := p_Visit_Rec.DEPARTMENT_ID;
     x_Visit_Schedule_Rec.VISIT_DEP_NAME    := p_Visit_Rec.DEPT_NAME;
     x_Visit_Schedule_Rec.START_TIME        := p_Visit_Rec.START_DATE;
     x_Visit_Schedule_Rec.END_TIME          := p_Visit_Rec.END_DATE;
     ----dbms_output.put_line('added org and dept info: ');



     x_Visit_Schedule_Rec.IS_ORG_VALID := FND_API.G_TRUE;
     IF(p_Visit_Rec.ORGANIZATION_ID IS NOT NULL)THEN

       -- whether the org is valid for the user
       x_Visit_Schedule_Rec.IS_ORG_VALID := AHL_UTILITY_PVT.IS_ORG_IN_USER_OU(
                                                     p_org_id   => p_Visit_Rec.ORGANIZATION_ID,
                                                     p_org_name => NULL,
                                                     x_return_status => l_return_status,
                                                     x_msg_data => l_msg_data
                                                     );
       -- Check for API errors
       IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
         ----dbms_output.put_line('Unexpected error : AHL_UTILITY_PVT.IS_ORG_IN_USER_OU returned errors');
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string
             (
                fnd_log.level_error,
                L_DEBUG_MODULE,
                'Unexpected error : AHL_UTILITY_PVT.IS_ORG_IN_USER_OU returned errors'
             );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     IF(NVL(x_visit_Schedule_rec.VISIT_STATUS_CODE,'x') NOT IN( 'CLOSED','CANCELLED'))THEN
       x_Visit_Schedule_Rec.CAN_CANCEL := FND_API.G_TRUE;
     ELSE
       x_Visit_Schedule_Rec.CAN_CANCEL := FND_API.G_FALSE;
     END IF;


     x_Visit_Schedule_Rec.PREV_EVENT_TYPE := p_prev_event_type;
     x_Visit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_FALSE;
     x_Visit_Schedule_Rec.HAS_CONFLICT     := FND_API.G_FALSE;

     IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
        ----dbms_output.put_line('Previous event type  : ' || G_EVENT_TYPE_FLIGHT);

        x_Visit_Schedule_Rec.PREV_EVENT_ID      := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Visit_Schedule_Rec.PREV_EVENT_ORG_ID  := p_prev_unit_schedule_rec.ARRIVAL_ORG_ID;
        x_Visit_Schedule_Rec.IS_PREV_ORG_VALID  := p_prev_unit_schedule_rec.IS_ORG_VALID;
        x_Visit_Schedule_Rec.PREV_EVENT_ORG_NAME    := p_prev_unit_schedule_rec.ARRIVAL_ORG_NAME;
        x_Visit_Schedule_Rec.PREV_EVENT_DEP_ID  := p_prev_unit_schedule_rec.ARRIVAL_DEP_ID;
        x_Visit_Schedule_Rec.PRVE_EVENT_DEP_NAME    := p_prev_unit_schedule_rec.ARRIVAL_DEP_NAME;
        l_prev_event_end_time                   := p_prev_unit_schedule_rec.ARRIVAL_TIME;
        x_Visit_Schedule_Rec.PREV_EVENT_END_TIME    := l_prev_event_end_time;
        x_Visit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID  := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Visit_Schedule_Rec.PREV_FLIGHT_NUMBER := p_prev_unit_schedule_rec.FLIGHT_NUMBER;
        l_previous_event_seq                    := NVL(p_prev_unit_schedule_rec.EVENT_SEQ,0);
     ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
        ----dbms_output.put_line('Previous event type  : ' || G_EVENT_TYPE_VISIT);
        x_Visit_Schedule_Rec.PREV_EVENT_ID      := p_prev_visit_schedule_rec.VISIT_ID;
        x_Visit_Schedule_Rec.PREV_EVENT_ORG_ID  := p_prev_visit_schedule_rec.VISIT_ORG_ID;
        x_Visit_Schedule_Rec.IS_PREV_ORG_VALID  := p_prev_visit_schedule_rec.IS_ORG_VALID;
        x_Visit_Schedule_Rec.PREV_EVENT_ORG_NAME    := p_prev_visit_schedule_rec.VISIT_ORG_NAME;
        x_Visit_Schedule_Rec.PREV_EVENT_DEP_ID  := p_prev_visit_schedule_rec.VISIT_DEP_ID;
        x_Visit_Schedule_Rec.PRVE_EVENT_DEP_NAME    := p_prev_visit_schedule_rec.VISIT_DEP_NAME;
        l_prev_event_end_time                   := NVL(p_prev_visit_schedule_rec.END_TIME,
                      p_prev_visit_schedule_rec.START_TIME+ 1/1440) ;
        x_Visit_Schedule_Rec.PREV_EVENT_END_TIME    := l_prev_event_end_time;
        x_Visit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID  := p_prev_visit_schedule_rec.PREV_UNIT_SCHEDULE_ID;
        x_Visit_Schedule_Rec.PREV_FLIGHT_NUMBER := p_prev_visit_schedule_rec.PREV_FLIGHT_NUMBER;
        l_previous_event_seq                    := NVL(p_prev_visit_schedule_rec.EVENT_SEQ,0);
     ELSE
        x_Visit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID  := p_prev_unit_schedule_rec.UNIT_SCHEDULE_ID;
        x_Visit_Schedule_Rec.PREV_FLIGHT_NUMBER := p_prev_unit_schedule_rec.FLIGHT_NUMBER;
     END IF;
     ----dbms_output.put_line('deciding on conflicts ');

     -- Determine Conflcits
     IF(x_Visit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL)THEN
        IF(x_Visit_Schedule_Rec.VISIT_ORG_ID <> x_Visit_Schedule_Rec.PREV_EVENT_ORG_ID)THEN
           org_conflict := TRUE;
           x_Visit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
        END IF;
        IF(G_DEPT_CONFLICT AND x_Visit_Schedule_Rec.VISIT_DEP_ID <> x_Visit_Schedule_Rec.PREV_EVENT_DEP_ID)THEN
           dept_conflict := TRUE;
           x_Visit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
        END IF;
        IF(x_Visit_Schedule_Rec.START_TIME < l_prev_event_end_time)THEN
           time_conflict := TRUE;
           x_Visit_Schedule_Rec.HAS_CONFLICT := FND_API.G_TRUE;
        END IF;
     END IF;

     -- Determine Maintenance Opportunity
     -- MO should be in future
     /*
      * Commenting out the following lines of code - bug #4071097 has been converted to ER...
      * Retaining code since this will later be needed anyway, when the ER is worked upon...
      */
     -- Uncommented the following lines of code as part of fix for bug# 6447447
     IF(x_Visit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL AND
        --x_Visit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID IS NOT NULL AND
        x_Visit_Schedule_Rec.START_TIME > l_prev_event_end_time AND
        x_Visit_Schedule_Rec.START_TIME > SYSDATE) THEN
        IF(l_prev_event_end_time >= SYSDATE AND
          (x_Visit_Schedule_Rec.START_TIME - l_prev_event_end_time)*24*60 >= G_MIN_TIME_MO)THEN
           x_Visit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        ELSIF(l_prev_event_end_time < SYSDATE AND
          (x_Visit_Schedule_Rec.START_TIME - SYSDATE)*24*60 >= G_MIN_TIME_MO)THEN
           x_Visit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        END IF;
     END IF;

     -- Commented the following lines of code as part of fix for bug# 6447447
     /*
     IF(x_Visit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL AND
        x_Visit_Schedule_Rec.PREV_UNIT_SCHEDULE_ID IS NOT NULL AND
        x_Visit_Schedule_Rec.START_TIME > l_prev_event_end_time) THEN
        IF ((x_Visit_Schedule_Rec.START_TIME - l_prev_event_end_time)*24*60 >= G_MIN_TIME_MO)THEN
           x_Visit_Schedule_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
        END IF;
     END IF;
     */

     add_pre_window_event := FALSE;
     -- Determine event sequence based on window and non window event
     -- decide whether to add "out of window" records.
     IF(p_window_event)THEN
       IF(x_Visit_Schedule_Rec.PREV_EVENT_ID IS NULL)THEN
         x_Visit_Schedule_Rec.EVENT_SEQ := 1;
       ELSE
         IF(l_previous_event_seq > 0)THEN
            x_Visit_Schedule_Rec.EVENT_SEQ := l_previous_event_seq + 1;
         ELSE
            IF(x_Visit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE OR x_Visit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
               add_pre_window_event := TRUE;
               x_Visit_Schedule_Rec.EVENT_SEQ := 2;
            ELSE
               x_Visit_Schedule_Rec.EVENT_SEQ := 1;
            END IF;
         END IF;
       END IF;
     ELSIF( NOT p_window_event AND x_Visit_Schedule_Rec.PREV_EVENT_ID IS NOT NULL)THEN
       IF(x_Visit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE OR x_Visit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
         IF(l_previous_event_seq > 0)THEN
            x_Visit_Schedule_Rec.EVENT_SEQ := l_previous_event_seq + 1;
         ELSE
            add_pre_window_event := TRUE;
            x_Visit_Schedule_Rec.EVENT_SEQ := 2;
         END IF;
       END IF;
     END IF;
     -- add pre window event if applicable
     IF(add_pre_window_event)THEN
       IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
         p_x_Unit_Schedule_tbl(0) := p_prev_unit_schedule_rec;
         p_x_Unit_Schedule_tbl(0).EVENT_SEQ := 1;
       ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
         p_x_Visit_Schedule_tbl(0) := p_prev_visit_schedule_rec;
         p_x_Visit_Schedule_tbl(0).EVENT_SEQ := 1;
       END IF;
     END IF;

     -- Add Conflcit Message
     IF(x_Visit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
       -- Event with sequence () and previous Event() has conflcits.
       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_FLIGHT_CONFLICT_MSG');
       FND_MESSAGE.SET_TOKEN('EVENT_SEQ1',x_Visit_Schedule_Rec.EVENT_SEQ,false);
       FND_MESSAGE.SET_TOKEN('EVENT_SEQ2',x_Visit_Schedule_Rec.EVENT_SEQ -1,false);
       x_Visit_Schedule_Rec.CONFLICT_MESSAGE := FND_MESSAGE.get;
       IF(org_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Visit Org() and previous flight Arrival Org() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VFO_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('VST_ORG',x_Visit_Schedule_Rec.VISIT_ORG_NAME,false);
           FND_MESSAGE.SET_TOKEN('ARR_ORG',p_prev_unit_schedule_rec.ARRIVAL_ORG_NAME,false);
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE || FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Visit Org() and previous visit Org() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VVO_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('VST_ORG',x_Visit_Schedule_Rec.VISIT_ORG_NAME,false);
           FND_MESSAGE.SET_TOKEN('VST_PORG',p_prev_visit_schedule_rec.VISIT_ORG_NAME,false);
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE || FND_MESSAGE.get;
         END IF;
       END IF;
       IF(dept_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Visit Dept() and previous flight Arrival Dept() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VFD_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('VST_DEPT',x_Visit_Schedule_Rec.VISIT_DEP_NAME,false);
           FND_MESSAGE.SET_TOKEN('ARR_DEPT',p_prev_unit_schedule_rec.ARRIVAL_DEP_NAME,false);
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Visit Dept() and previous visit Dept() do not match.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VVD_CONFLICT_MSG');
           FND_MESSAGE.SET_TOKEN('VST_DEPT',x_Visit_Schedule_Rec.VISIT_DEP_NAME,false);
           FND_MESSAGE.SET_TOKEN('VST_PDEPT',p_prev_visit_schedule_rec.VISIT_DEP_NAME,false);
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         END IF;
       END IF;
       IF(time_conflict)THEN
         IF(p_prev_event_type = G_EVENT_TYPE_FLIGHT)THEN
           -- Visit start Time and previous flight Arrival Time has overlap.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VFT_CONFLICT_MSG');
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         ELSIF(p_prev_event_type = G_EVENT_TYPE_VISIT)THEN
           -- Visit Start Time and previous Visit End Time has overlap.
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_VVT_CONFLICT_MSG');
           x_Visit_Schedule_Rec.CONFLICT_MESSAGE := x_Visit_Schedule_Rec.CONFLICT_MESSAGE ||FND_MESSAGE.get;
         END IF;
       END IF;
     END IF;
     -- add current event to table of events.
     IF(NVL(x_Visit_Schedule_Rec.EVENT_SEQ,0) > 0)THEN
        IF(p_x_Visit_Schedule_tbl IS NULL)THEN
          l_index := 0;
        ELSE
          l_index := p_x_Visit_Schedule_tbl.COUNT;
        END IF;
        p_x_Visit_Schedule_tbl(l_index) := x_Visit_Schedule_Rec;
     END IF;

     -- Update conflict or MO at the header level
     IF(x_Visit_Schedule_Rec.HAS_CONFLICT = FND_API.G_TRUE)THEN
        p_x_MEvent_Header_Rec.HAS_CONFLICT := FND_API.G_TRUE;
     END IF;
     IF(x_Visit_Schedule_Rec.HAS_MOPPORTUNITY = FND_API.G_TRUE)THEN
        p_x_MEvent_Header_Rec.HAS_MOPPORTUNITY := FND_API.G_TRUE;
     END IF;

     -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;
    ----dbms_output.put_line('added visit record for VISIT_ID : ' || p_Visit_Rec.VISIT_ID);

END populate_visit_schedule_rec;
---------------------------------------------
-- Spec Procedure Get_Prec_Succ_Event_Info --
---------------------------------------------
PROCEDURE Get_Prec_Succ_Event_Info
(
    p_api_version       IN      NUMBER,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT     NOCOPY  NUMBER,
    x_msg_data      OUT     NOCOPY  VARCHAR2,
    p_unit_config_id        IN          NUMBER,
    p_start_date_time   IN          DATE,
    p_end_date_time     IN          DATE,
    x_prec_visit        OUT     NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
    x_prec_flight_schedule  OUT     NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
    x_is_prec_conflict      OUT     NOCOPY  VARCHAR2,
    x_is_prec_org_in_ou OUT NOCOPY  VARCHAR2,
    x_succ_visit        OUT     NOCOPY  AHL_VWP_VISITS_PVT.Visit_Rec_Type,
    x_succ_flight_schedule  OUT     NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type,
    x_is_succ_conflict  OUT     NOCOPY  VARCHAR2,
        x_is_succ_org_in_ou OUT NOCOPY  VARCHAR2
)
IS
    -- 1.   Declare local variables
    l_api_name  CONSTANT    VARCHAR2(30)    := 'Get_Prec_Succ_Event_Info';
    l_api_version   CONSTANT    NUMBER      := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    L_DEBUG_MODULE  CONSTANT    VARCHAR2(100)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    cursor check_unit_exists
    (
        p_unit_config_id number
    )
    is
    select 'x'
    from ahl_unit_config_headers
    where unit_config_header_id = p_unit_config_id
    --priyan Bug # 5303188
    --and ahl_util_uc_pkg.get_uc_status_code (p_unit_config_id) IN ('COMPLETE', 'INCOMPLETE');
    --and unit_config_status_code IN ('COMPLETE', 'INCOMPLETE');
    -- fix for bug #5528416 - must include quarantined units
    and ahl_util_uc_pkg.get_uc_status_code (p_unit_config_id) NOT IN ('DRAFT', 'EXPIRED');

BEGIN
    -- Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list by default
    FND_MSG_PUB.Initialize;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Log API entry point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    -- API body starts here
    -- 5.   If (p_unit_config_id is null or p_start_date_time is null or p_end_date_time is null), then display error "Unit Configuration Id and Start Time are mandatory parameters"
    IF (
        p_unit_config_id IS NULL OR p_unit_config_id = FND_API.G_MISS_NUM OR
        p_start_date_time IS NULL OR p_start_date_time = FND_API.G_MISS_DATE
        -- There could be cases where there are no succeeding events, hence np p_end_date_time
        --p_end_date_time IS NULL OR p_end_date_time = FND_API.G_MISS_DATE OR
        --p_start_date_time >= nvl(p_end_date_time, p_start_date_time + 1)
    )
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_COM_INVALID_PROCEDURE_CALL');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', l_api_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 6.   Validate unit configuration with unit_config_id = p_unit_config_id exists and is complete and active, using cursor check_unit_exists. If no record found, throw error "Unit Configuration does not exist or is not complete"
    OPEN check_unit_exists (p_unit_config_id);
    FETCH check_unit_exists INTO l_dummy_varchar;
    IF (check_unit_exists%NOTFOUND)
    THEN
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_UA_UNIT_ID_NOT_FOUND');
        FND_MSG_PUB.ADD;
        CLOSE check_unit_exists;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_unit_exists;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            L_DEBUG_MODULE,
            'Basic validations done'
        );
    END IF;

    -- Call AHL_UA_COMMON_PVT.Get_Prec_Event_Info to retrieve details of the previous event (visit / flight) and conflicts, if any
    AHL_UA_COMMON_PVT.Get_Prec_Event_Info
    (
        p_api_version       => 1.0,
        x_return_status     => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_unit_config_id    => p_unit_config_id,
        p_start_date_time   => p_start_date_time,
        p_use_actuals       => G_USE_ACTUALS,
        x_prec_visit        => x_prec_visit,
        x_prec_flight_schedule  => x_prec_flight_schedule,
        x_is_conflict       => x_is_prec_conflict,
        x_is_org_in_user_ou => x_is_prec_org_in_ou
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            L_DEBUG_MODULE,
            'After calling AHL_UA_COMMON_PVT.Get_Prec_Event_Info [x_is_prec_conflict='||x_is_prec_conflict||']'
        );
    END IF;

    -- Call AHL_UA_COMMON_PVT.Get_Succ_Event_Info to retrieve details of the next event (visit / flight) and conflicts, if any
    AHL_UA_COMMON_PVT.Get_Succ_Event_Info
    (
        p_api_version       => 1.0,
        x_return_status     => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_unit_config_id    => p_unit_config_id,
        -- Pass p_end_date_time = p_start_date_time as sequence of all events will be based on start times
        -- The same logic is used in Get_All_Events too...
        p_end_date_time     => p_start_date_time,
        p_use_actuals       => G_USE_ACTUALS,
        x_succ_visit        => x_succ_visit,
        x_succ_flight_schedule  => x_succ_flight_schedule,
        x_is_conflict       => x_is_succ_conflict,
        x_is_org_in_user_ou => x_is_succ_org_in_ou
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_statement,
            L_DEBUG_MODULE,
            'After calling AHL_UA_COMMON_PVT.Get_Succ_Event_Info [x_is_succ_conflict='||x_is_succ_conflict||']'
        );
    END IF;
    -- API body ends here

    -- Log API exit point
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
    THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            L_DEBUG_MODULE||'.end',
            'At the end of PLSQL procedure'
        );
    END IF;

    -- Check Error Message stack.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get
    (
        p_count     => x_msg_count,
        p_data      => x_msg_data,
        p_encoded   => FND_API.G_FALSE
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
            (
                p_pkg_name      => G_PKG_NAME,
                p_procedure_name    => 'Get_Prec_Succ_Event_Info',
                p_error_text        => SUBSTR(SQLERRM,1,240)
            );
        END IF;
        FND_MSG_PUB.count_and_get
        (
            p_count     => x_msg_count,
            p_data      => x_msg_data,
            p_encoded   => FND_API.G_FALSE
        );
END Get_Prec_Succ_Event_Info;

-- Function to get the profile value for minimum number of minutes to considered as a
-- Maintenance Opportunity

FUNCTION Get_Min_Time_MO RETURN NUMBER  IS

  l_min_time_mo    NUMBER;
  l_min_time_mo_str VARCHAR2(30);

BEGIN

   BEGIN
     l_min_time_mo_str := FND_PROFILE.VALUE('AHL_UA_MIN_MO_SIZE');

     IF (l_min_time_mo_str IS NULL) THEN
        l_min_time_mo := 1;
     ELSIF (to_number(l_min_time_mo_str) <= 1 ) THEN
        l_min_time_mo := 1;
     ELSE
        l_min_time_mo := to_number(l_min_time_mo_str);
     END IF;

   EXCEPTION
     WHEN VALUE_ERROR THEN
        l_min_time_mo := 1;

     WHEN INVALID_NUMBER THEN
        l_min_time_mo := 1;
   END;

   -- return date.
   RETURN l_min_time_mo;

END Get_Min_Time_MO;

END AHL_UA_UNIT_SCHEDULES_PVT;

/
