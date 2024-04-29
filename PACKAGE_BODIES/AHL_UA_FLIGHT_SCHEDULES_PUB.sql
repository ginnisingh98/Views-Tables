--------------------------------------------------------
--  DDL for Package Body AHL_UA_FLIGHT_SCHEDULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UA_FLIGHT_SCHEDULES_PUB" AS
/* $Header: AHLPUFSB.pls 120.4 2006/09/15 23:16:44 sikumar noship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30) :='AHL_UA_FLIGHT_SCHEDULES_PUB';

-- Flag for determining wether to use Actual dates or Estimated dates.
G_USE_ACTUALS   CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;

PROCEDURE Get_Flight_Schedule_Details
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_flight_search_rec     IN      FLIGHT_SEARCH_REC_TYPE,
    x_flight_schedules_tbl      OUT  NOCOPY     AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
)
IS

l_api_name          CONSTANT    VARCHAR2(30)    := 'SEARCH_FLIGHT_SCHEDULES';
l_api_version           CONSTANT    NUMBER      := 1.0;
l_return_status                     VARCHAR2(1);
l_search_Query                  VARCHAR2(5000);
i NUMBER;
l_flight_schedule_csr AHL_OSP_UTIL_PKG.ahl_search_csr;
l_bind_value_tbl AHL_OSP_UTIL_PKG.ahl_conditions_tbl;
l_bind_index NUMBER;
l_super_user VARCHAR2(1);
l_unit_schedule_id NUMBER;
l_flight_schedule_rec AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULE_REC_TYPE;
BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of PLSQL procedure'
        );
    END IF;

    --savepoint is not required for procedures which does only query
    --SAVEPOINT search_flight_schedules_pub;

    -- Initialize return status to success initially
    x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                       p_api_version,
                       l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Validations for dates-based search... If dates criteria applied to arrival / departure, then both start and end need to be passed
    IF (p_flight_search_rec.DATE_APPLY_TO_FLAG IS NOT NULL AND (p_flight_search_rec.START_DATE IS NULL OR p_flight_search_rec.END_DATE IS NULL))
    THEN
        FND_MESSAGE.set_name('AHL', 'AHL_UA_SEARCH_DATE_APP_FLAG');
        FND_MSG_PUB.add;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Search query...
    l_search_Query := 'SELECT
                UNIT_SCHEDULE_ID,
                FLIGHT_NUMBER, SEGMENT,
                DEPARTURE_DEPT_ID,
                DEPARTURE_DEPT_CODE,
                DEPARTURE_ORG_ID,
                DEPARTURE_ORG_CODE,
                ARRIVAL_DEPT_ID,
                ARRIVAL_DEPT_CODE,
                ARRIVAL_ORG_ID,
                ARRIVAL_ORG_CODE,
                EST_DEPARTURE_TIME,
                EST_ARRIVAL_TIME,
                ACTUAL_DEPARTURE_TIME,
                ACTUAL_ARRIVAL_TIME,
                PRECEDING_US_ID,
                CSI_ITEM_INSTANCE_ID,
                UNIT_CONFIG_HEADER_ID,
                UNIT_CONFIG_NAME,
                VISIT_RESCHEDULE_MODE,
                VISIT_RESCHEDULE_MEANING,
                ITEM_NUMBER,
                SERIAL_NUMBER,
                OBJECT_VERSION_NUMBER,
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
                ATTRIBUTE15
            FROM
                 AHL_UNIT_SCHEDULES_V
            WHERE AHL_UTIL_UC_PKG.GET_UC_STATUS_CODE(UNIT_CONFIG_HEADER_ID) NOT IN (''DRAFT'',''EXPIRED'')';

    l_bind_index := 1;

    IF p_flight_search_rec.unit_schedule_id IS NOT NULL THEN
        l_search_Query := l_search_Query || ' AND UNIT_SCHEDULE_ID = :'||l_bind_index;
        l_bind_value_tbl(l_bind_index) := p_flight_search_rec.unit_schedule_id;
        l_bind_index := l_bind_index + 1;
    ELSE
        IF p_flight_search_rec.UNIT_NAME IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(UNIT_CONFIG_NAME) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.UNIT_NAME;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.FLIGHT_NUMBER IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(FLIGHT_NUMBER) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.FLIGHT_NUMBER;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.ITEM_NUMBER IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(ITEM_NUMBER) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.ITEM_NUMBER;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.SERIAL_NUMBER IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(SERIAL_NUMBER) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.SERIAL_NUMBER;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.ARRIVAL_ORG_CODE IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(ARRIVAL_ORG_CODE) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.ARRIVAL_ORG_CODE;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.ARRIVAL_DEPT_CODE IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(ARRIVAL_DEPT_CODE) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.ARRIVAL_DEPT_CODE;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.DEPARTURE_ORG_CODE IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(DEPARTURE_ORG_CODE) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.DEPARTURE_ORG_CODE;
            l_bind_index := l_bind_index + 1;
        END IF;

        IF p_flight_search_rec.DEPARTURE_DEPT_CODE IS NOT NULL THEN
            l_search_Query := l_search_Query || ' AND UPPER(DEPARTURE_DEPT_CODE) LIKE UPPER(RTRIM(:'||l_bind_index||'))';
            l_bind_value_tbl(l_bind_index) := p_flight_search_rec.DEPARTURE_DEPT_CODE;
            l_bind_index := l_bind_index + 1;
        END IF;

        --Triway handling of start_date and End_date
        IF p_flight_search_rec.START_DATE IS NOT NULL AND p_flight_search_rec.END_DATE IS NOT NULL
        THEN
            IF p_flight_search_rec.DATE_APPLY_TO_FLAG IS NULL
            THEN
                IF g_use_actuals = FND_API.G_TRUE
                THEN
                    l_search_Query := l_search_Query ||' AND ( ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time, ''DD-MON-RRRR HH24:MI:SS'') <= nvl(actual_departure_time, est_departure_time) and ';
                    l_search_Query := l_search_Query ||'    nvl(actual_departure_time, est_departure_time) < to_date(:end_time, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;

                    l_search_Query := l_search_Query ||' or ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time, ''DD-MON-RRRR HH24:MI:SS'') < nvl(actual_arrival_time, est_arrival_time) and ';
                    l_search_Query := l_search_Query ||'    nvl(actual_arrival_time, est_arrival_time) <= to_date(:end_time, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;

                    l_search_Query := l_search_Query ||' or ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    nvl(actual_departure_time, est_departure_time) <= to_date(:start_time, ''DD-MON-RRRR HH24:MI:SS'') and ';
                    l_search_Query := l_search_Query ||'    to_date(:end_time, ''DD-MON-RRRR HH24:MI:SS'') <= nvl(actual_arrival_time, est_arrival_time) ';
                    l_search_Query := l_search_Query ||' ) ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                ELSE
                    l_search_Query := l_search_Query ||' AND ( ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time1, ''DD-MON-RRRR HH24:MI:SS'') <= est_departure_time and ';
                    l_search_Query := l_search_Query ||'    est_departure_time < to_date(:end_time1, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;

                    l_search_Query := l_search_Query ||' or ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time2, ''DD-MON-RRRR HH24:MI:SS'') < est_arrival_time and ';
                    l_search_Query := l_search_Query ||'    est_arrival_time <= to_date(:end_time2, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;

                    l_search_Query := l_search_Query ||' or ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    est_departure_time <= to_date(:start_time3, ''DD-MON-RRRR HH24:MI:SS'') and ';
                    l_search_Query := l_search_Query ||'    to_date(:end_time3, ''DD-MON-RRRR HH24:MI:SS'') <= est_arrival_time ';
                    l_search_Query := l_search_Query ||' ) ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                END IF;

            ELSIF p_flight_search_rec.DATE_APPLY_TO_FLAG = G_APPLY_TO_ARRIVAL
            THEN
                IF g_use_actuals = FND_API.G_TRUE
                THEN
                    l_search_Query := l_search_Query ||' AND ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time, ''DD-MON-RRRR HH24:MI:SS'') < nvl(actual_arrival_time, est_arrival_time) and ';
                    l_search_Query := l_search_Query ||'    nvl(actual_arrival_time, est_arrival_time) <= to_date(:end_time, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                ELSE
                    l_search_Query := l_search_Query ||' AND ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time2, ''DD-MON-RRRR HH24:MI:SS'') < est_arrival_time and ';
                    l_search_Query := l_search_Query ||'    est_arrival_time <= to_date(:end_time2, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                END IF;

            ELSIF p_flight_search_rec.DATE_APPLY_TO_FLAG = G_APPLY_TO_DEPARTURE
            THEN
                IF g_use_actuals = FND_API.G_TRUE
                THEN
                    l_search_Query := l_search_Query ||' AND ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time, ''DD-MON-RRRR HH24:MI:SS'') <= nvl(actual_departure_time, est_departure_time) and ';
                    l_search_Query := l_search_Query ||'    nvl(actual_departure_time, est_departure_time) < to_date(:end_time, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                ELSE
                    l_search_Query := l_search_Query ||' AND ';
                    l_search_Query := l_search_Query ||' ( ';
                    l_search_Query := l_search_Query ||'    to_date(:start_time1, ''DD-MON-RRRR HH24:MI:SS'') <= est_departure_time and ';
                    l_search_Query := l_search_Query ||'    est_departure_time < to_date(:end_time1, ''DD-MON-RRRR HH24:MI:SS'') ';
                    l_search_Query := l_search_Query ||' ) ';
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                    l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
                    l_bind_index := l_bind_index + 1;
                END IF;
            END IF;

        ELSIF p_flight_search_rec.START_DATE IS NOT NULL
        THEN
            IF g_use_actuals = FND_API.G_TRUE
            THEN
                l_search_Query := l_search_Query || ' AND NVL(ACTUAL_ARRIVAL_TIME,EST_ARRIVAL_TIME)  >= to_date(:'||l_bind_index||', ''DD-MON-RRRR HH24:MI:SS'')';
            ELSE
                l_search_Query := l_search_Query || ' AND EST_ARRIVAL_TIME  >= to_date(:'||l_bind_index||', ''DD-MON-RRRR HH24:MI:SS'')';
            END IF;
            l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.START_DATE, 'DD-MON-RRRR HH24:MI:SS');
            l_bind_index := l_bind_index + 1;

        ELSIF p_flight_search_rec.END_DATE IS NOT NULL
        THEN
            IF g_use_actuals = FND_API.G_TRUE
            THEN
                l_search_Query := l_search_Query || ' AND NVL(ACTUAL_DEPARTURE_TIME,EST_DEPARTURE_TIME) <= to_date(:'||l_bind_index||', ''DD-MON-RRRR HH24:MI:SS'')';
            ELSE
                l_search_Query := l_search_Query || ' AND EST_DEPARTURE_TIME <= to_date(:'||l_bind_index||', ''DD-MON-RRRR HH24:MI:SS'')';
            END IF;
            l_bind_value_tbl(l_bind_index) := to_char(p_flight_search_rec.END_DATE, 'DD-MON-RRRR HH24:MI:SS');
            l_bind_index := l_bind_index + 1;
        END IF;

        -- add order by. this doesnt have to be done when unit_schedule_id is passed.
        l_search_Query := l_search_Query || ' ORDER BY UNIT_CONFIG_NAME DESC, EST_DEPARTURE_TIME DESC, EST_ARRIVAL_TIME DESC';
    END IF;

    AHL_OSP_UTIL_PKG.OPEN_SEARCH_CURSOR(l_flight_schedule_csr, l_bind_value_tbl, l_search_Query);

    i := 0;
    l_super_user := AHL_UA_FLIGHT_SCHEDULES_PVT.is_super_user;

    --OPEN l_flight_schedule_csr FOR l_search_Query;
    LOOP
        --Get search results
        FETCH l_flight_schedule_csr INTO  l_flight_schedule_rec.UNIT_SCHEDULE_ID,
                     l_flight_schedule_rec.FLIGHT_NUMBER,
                     l_flight_schedule_rec.SEGMENT,
                     l_flight_schedule_rec.DEPARTURE_DEPT_ID,
                     l_flight_schedule_rec.DEPARTURE_DEPT_CODE,
                     l_flight_schedule_rec.DEPARTURE_ORG_ID,
                     l_flight_schedule_rec.DEPARTURE_ORG_CODE,
                     l_flight_schedule_rec.ARRIVAL_DEPT_ID,
                     l_flight_schedule_rec.ARRIVAL_DEPT_CODE,
                     l_flight_schedule_rec.ARRIVAL_ORG_ID,
                     l_flight_schedule_rec.ARRIVAL_ORG_CODE,
                     l_flight_schedule_rec.EST_DEPARTURE_TIME,
                     l_flight_schedule_rec.EST_ARRIVAL_TIME,
                     l_flight_schedule_rec.ACTUAL_DEPARTURE_TIME,
                     l_flight_schedule_rec.ACTUAL_ARRIVAL_TIME,
                     l_flight_schedule_rec.PRECEDING_US_ID,
                     l_flight_schedule_rec.CSI_INSTANCE_ID,
                     l_flight_schedule_rec.UNIT_CONFIG_HEADER_ID,
                     l_flight_schedule_rec.UNIT_CONFIG_NAME,
                     l_flight_schedule_rec.VISIT_RESCHEDULE_MODE,
                     l_flight_schedule_rec.VISIT_RESCHEDULE_MEANING,
                     l_flight_schedule_rec.ITEM_NUMBER,
                     l_flight_schedule_rec.SERIAL_NUMBER,
                     l_flight_schedule_rec.OBJECT_VERSION_NUMBER,
                     l_flight_schedule_rec.ATTRIBUTE_CATEGORY,
                     l_flight_schedule_rec.ATTRIBUTE1,
                     l_flight_schedule_rec.ATTRIBUTE2,
                     l_flight_schedule_rec.ATTRIBUTE3,
                     l_flight_schedule_rec.ATTRIBUTE4,
                     l_flight_schedule_rec.ATTRIBUTE5,
                     l_flight_schedule_rec.ATTRIBUTE6,
                     l_flight_schedule_rec.ATTRIBUTE7,
                     l_flight_schedule_rec.ATTRIBUTE8,
                     l_flight_schedule_rec.ATTRIBUTE9,
                     l_flight_schedule_rec.ATTRIBUTE10,
                     l_flight_schedule_rec.ATTRIBUTE11,
                     l_flight_schedule_rec.ATTRIBUTE12,
                     l_flight_schedule_rec.ATTRIBUTE13,
                     l_flight_schedule_rec.ATTRIBUTE14,
                     l_flight_schedule_rec.ATTRIBUTE15;

        EXIT WHEN l_flight_schedule_csr%NOTFOUND;
        i := i + 1;
        -- Copy values from local record to output table.
        x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID := l_flight_schedule_rec.UNIT_SCHEDULE_ID;
        x_flight_schedules_tbl(i).FLIGHT_NUMBER := l_flight_schedule_rec.FLIGHT_NUMBER;
        x_flight_schedules_tbl(i).SEGMENT := l_flight_schedule_rec.SEGMENT;
        x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID := l_flight_schedule_rec.DEPARTURE_DEPT_ID;
        x_flight_schedules_tbl(i).DEPARTURE_DEPT_CODE := l_flight_schedule_rec.DEPARTURE_DEPT_CODE;
        x_flight_schedules_tbl(i).DEPARTURE_ORG_ID := l_flight_schedule_rec.DEPARTURE_ORG_ID;
        x_flight_schedules_tbl(i).DEPARTURE_ORG_CODE := l_flight_schedule_rec.DEPARTURE_ORG_CODE;
        x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID := l_flight_schedule_rec.ARRIVAL_DEPT_ID;
        x_flight_schedules_tbl(i).ARRIVAL_DEPT_CODE := l_flight_schedule_rec.ARRIVAL_DEPT_CODE;
        x_flight_schedules_tbl(i).ARRIVAL_ORG_ID := l_flight_schedule_rec.ARRIVAL_ORG_ID;
        x_flight_schedules_tbl(i).ARRIVAL_ORG_CODE := l_flight_schedule_rec.ARRIVAL_ORG_CODE;
        x_flight_schedules_tbl(i).EST_DEPARTURE_TIME := l_flight_schedule_rec.EST_DEPARTURE_TIME;
        x_flight_schedules_tbl(i).EST_ARRIVAL_TIME := l_flight_schedule_rec.EST_ARRIVAL_TIME;
        x_flight_schedules_tbl(i).ACTUAL_DEPARTURE_TIME := l_flight_schedule_rec.ACTUAL_DEPARTURE_TIME;
        x_flight_schedules_tbl(i).ACTUAL_ARRIVAL_TIME := l_flight_schedule_rec.ACTUAL_ARRIVAL_TIME;
        x_flight_schedules_tbl(i).PRECEDING_US_ID := l_flight_schedule_rec.PRECEDING_US_ID;
        x_flight_schedules_tbl(i).CSI_INSTANCE_ID := l_flight_schedule_rec.CSI_INSTANCE_ID;
        x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID := l_flight_schedule_rec.UNIT_CONFIG_HEADER_ID;
        x_flight_schedules_tbl(i).UNIT_CONFIG_NAME := l_flight_schedule_rec.UNIT_CONFIG_NAME;
        x_flight_schedules_tbl(i).ITEM_NUMBER := l_flight_schedule_rec.ITEM_NUMBER;
        x_flight_schedules_tbl(i).SERIAL_NUMBER := l_flight_schedule_rec.SERIAL_NUMBER;
        x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE := l_flight_schedule_rec.VISIT_RESCHEDULE_MODE;
        x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MEANING := l_flight_schedule_rec.VISIT_RESCHEDULE_MEANING;
        x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER := l_flight_schedule_rec.OBJECT_VERSION_NUMBER;
        x_flight_schedules_tbl(i).ATTRIBUTE_CATEGORY := l_flight_schedule_rec.ATTRIBUTE_CATEGORY;
        x_flight_schedules_tbl(i).ATTRIBUTE1 := l_flight_schedule_rec.ATTRIBUTE1;
        x_flight_schedules_tbl(i).ATTRIBUTE2 := l_flight_schedule_rec.ATTRIBUTE2;
        x_flight_schedules_tbl(i).ATTRIBUTE3 := l_flight_schedule_rec.ATTRIBUTE3;
        x_flight_schedules_tbl(i).ATTRIBUTE4 := l_flight_schedule_rec.ATTRIBUTE4;
        x_flight_schedules_tbl(i).ATTRIBUTE5 := l_flight_schedule_rec.ATTRIBUTE5;
        x_flight_schedules_tbl(i).ATTRIBUTE6 := l_flight_schedule_rec.ATTRIBUTE6;
        x_flight_schedules_tbl(i).ATTRIBUTE7 := l_flight_schedule_rec.ATTRIBUTE7;
        x_flight_schedules_tbl(i).ATTRIBUTE8 := l_flight_schedule_rec.ATTRIBUTE8;
        x_flight_schedules_tbl(i).ATTRIBUTE9 := l_flight_schedule_rec.ATTRIBUTE9;
        x_flight_schedules_tbl(i).ATTRIBUTE10 := l_flight_schedule_rec.ATTRIBUTE10;
        x_flight_schedules_tbl(i).ATTRIBUTE11 := l_flight_schedule_rec.ATTRIBUTE11;
        x_flight_schedules_tbl(i).ATTRIBUTE12 := l_flight_schedule_rec.ATTRIBUTE12;
        x_flight_schedules_tbl(i).ATTRIBUTE13 := l_flight_schedule_rec.ATTRIBUTE13;
        x_flight_schedules_tbl(i).ATTRIBUTE14 := l_flight_schedule_rec.ATTRIBUTE14;
        x_flight_schedules_tbl(i).ATTRIBUTE15 := l_flight_schedule_rec.ATTRIBUTE15;

        -- Find if record can be updated and deleted.
        x_flight_schedules_tbl(i).is_delete_allowed := AHL_UA_FLIGHT_SCHEDULES_PVT.is_delete_allowed(
                                 p_unit_schedule_id => x_flight_schedules_tbl(i).unit_schedule_id,
                                 p_is_super_user =>  l_super_user
                               );
        x_flight_schedules_tbl(i).is_update_allowed := AHL_UA_FLIGHT_SCHEDULES_PVT.is_update_allowed(
                                 p_unit_schedule_id => x_flight_schedules_tbl(i).unit_schedule_id,
                                 p_is_super_user => l_super_user
                               );
    END LOOP;
    CLOSE l_flight_schedule_csr;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the end of PLSQL procedure'
        );
    END IF;

EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO search_flight_schedules_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                       p_count => x_msg_count,
                       p_data  => x_msg_data);

     WHEN OTHERS THEN
        --ROLLBACK TO search_flight_schedules_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                    p_procedure_name  =>  l_api_name,
                    p_error_text      => SUBSTR(SQLERRM,1,240));

        END IF;
END Get_Flight_Schedule_Details;



--------------------------------------------------------------------------------
-- Public wrapper for AHL_UA_FLIGHT_SCHEDULES_PVT.process_flight_schedules
------------------------------------------------------------------------------------------

PROCEDURE Process_Flight_Schedules
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_x_flight_schedules_tbl        IN OUT  NOCOPY  AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE
)
IS
l_api_name          CONSTANT    VARCHAR2(30)    := 'Process_Flight_Schedules';
l_api_version           CONSTANT    NUMBER      := 1.0;
l_msg_count                     NUMBER;
BEGIN
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of PLSQL procedure'
        );
        END IF;

        --define a savepoint for the procedure
        SAVEPOINT Process_Flight_Schedules_pub;

    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;


        FOR i IN p_x_flight_schedules_tbl.FIRST..p_x_flight_schedules_tbl.LAST
    LOOP
      --Validate DML flag
      IF (p_x_flight_schedules_tbl(i).DML_OPERATION <> 'D' AND p_x_flight_schedules_tbl(i).DML_OPERATION <> 'd' AND
         p_x_flight_schedules_tbl(i).DML_OPERATION <> 'U' AND p_x_flight_schedules_tbl(i).DML_OPERATION <> 'u' AND
         p_x_flight_schedules_tbl(i).DML_OPERATION <> 'C' AND p_x_flight_schedules_tbl(i).DML_OPERATION <> 'c')
      THEN
            FND_MESSAGE.set_name( 'AHL','AHL_COM_INVALID_DML' );
        FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
        FND_MESSAGE.set_token( 'FIELD', p_x_flight_schedules_tbl(i).DML_OPERATION);
        FND_MSG_PUB.add;
      END IF;


      --Obj version number and Unit Schedule id check in case of update or delete.
      IF ( p_x_flight_schedules_tbl(i).DML_OPERATION = 'D' OR p_x_flight_schedules_tbl(i).DML_OPERATION = 'd' OR
           p_x_flight_schedules_tbl(i).DML_OPERATION = 'U' OR p_x_flight_schedules_tbl(i).DML_OPERATION = 'u' )
      THEN
        --Unit Schedule id cannot be null
        IF (p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID IS NULL OR
        p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_US_NOT_FOUND' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
        END IF;

        -- Check for Object Version number.
        IF (p_x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER IS NULL OR
           p_x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM)
        THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_OBJ_VERNO_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
        END IF;
       END IF;

      IF p_x_flight_schedules_tbl(i).DML_OPERATION = 'C' OR
         p_x_flight_schedules_tbl(i).DML_OPERATION = 'c' OR
         p_x_flight_schedules_tbl(i).DML_OPERATION = 'U' OR
         p_x_flight_schedules_tbl(i).DML_OPERATION = 'u'
      THEN
          -- Unit Config Header id is a mandatory input field and cannot be null.
          IF (p_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID IS NULL OR
              p_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID = FND_API.G_MISS_NUM )AND
             (p_x_flight_schedules_tbl(i).UNIT_CONFIG_NAME IS NULL OR
              p_x_flight_schedules_tbl(i).UNIT_CONFIG_NAME = FND_API.G_MISS_CHAR)

          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_INV_UC_NAME' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Flight Number is a mandatory input field and cannot be null.
          IF p_x_flight_schedules_tbl(i).FLIGHT_NUMBER IS NULL OR
             p_x_flight_schedules_tbl(i).FLIGHT_NUMBER = FND_API.G_MISS_CHAR
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_FLG_NUMBER_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Segment is a mandatory input field and cannot be null
          IF p_x_flight_schedules_tbl(i).SEGMENT IS NULL OR
             p_x_flight_schedules_tbl(i).SEGMENT = FND_API.G_MISS_CHAR
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_SEGMENT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Departure_Dept_Id is a mandatory input field and cannot be null
          IF ( p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID IS NULL OR
               p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID = FND_API.G_MISS_NUM ) AND
             ( p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_CODE IS NULL OR
               p_x_flight_schedules_tbl(i).DEPARTURE_DEPT_CODE = FND_API.G_MISS_CHAR )
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_DEPT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Departure_Org_Id is a mandatory input field and cannot be null
          IF ( p_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID IS NULL OR
               p_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID = FND_API.G_MISS_NUM ) AND
             ( p_x_flight_schedules_tbl(i).DEPARTURE_ORG_CODE IS NULL OR
               p_x_flight_schedules_tbl(i).DEPARTURE_ORG_CODE = FND_API.G_MISS_CHAR )
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_ORG_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Arrival_Dept_Id is a mandatory input field and cannot be null
          IF ( p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID IS NULL OR
               p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID = FND_API.G_MISS_NUM ) AND
             ( p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_CODE IS NULL  OR
               p_x_flight_schedules_tbl(i).ARRIVAL_DEPT_CODE = FND_API.G_MISS_CHAR )

          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_DEPT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Arrival_Org_Id is a mandatory input field and cannot be null
          IF ( p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID IS NULL OR
               p_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID = FND_API.G_MISS_NUM ) AND
             ( p_x_flight_schedules_tbl(i).ARRIVAL_ORG_CODE IS NULL OR
               p_x_flight_schedules_tbl(i).ARRIVAL_ORG_CODE = FND_API.G_MISS_CHAR )
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_ORG_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Est_Departure_Time is a mandatory input field and cannot be null
          IF p_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME IS NULL OR
             p_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME = FND_API.G_MISS_DATE
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_DEP_TIME_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Est_Arrival_Time is a mandatory input field and cannot be null
          IF p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME IS NULL OR
             p_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME = FND_API.G_MISS_DATE
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_ARR_TIME_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

          --Visit_Reschedule_Mode is a mandatory input field and cannot be null
          IF ( p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE IS NULL OR
               p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE = FND_API.G_MISS_CHAR ) AND
             ( p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MEANING IS NULL OR
               p_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MEANING = FND_API.G_MISS_CHAR )
          THEN
            FND_MESSAGE.set_name( 'AHL','AHL_UA_VST_RES_MODE_NULL' );
            FND_MESSAGE.set_token( 'RECORD', p_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID);
            FND_MSG_PUB.add;
          END IF;

      END IF;

    END LOOP;

    l_msg_count := FND_MSG_PUB.COUNT_MSG;
    IF (l_msg_count > 0)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
             fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'Before calling the private API.....'
             );
        END IF;

    AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules(
         p_api_version          =>  p_api_version,
         p_init_msg_list        =>  p_init_msg_list,
         p_commit           =>  p_commit,
         p_validation_level     =>  p_validation_level,
         p_default          =>  p_default,
         p_module_type          =>  p_module_type,
         x_return_status        =>  x_return_status,
         x_msg_count            =>  x_msg_count,
         x_msg_data         =>  x_msg_data,
         p_x_flight_schedules_tbl   =>  p_x_flight_schedules_tbl
    );

    -- Check Error Message stack.
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Private API raised expected error....'
         );
            END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Private API raised unexpected error....'
         );
            END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check for p_commit
    IF FND_API.To_Boolean (p_commit)
    THEN
        COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the end of PLSQL procedure'
        );
    END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to Process_Flight_Schedules_pub;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Flight_Schedules_pub;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to Process_Flight_Schedules_pub;
        IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                         p_procedure_name => l_api_name,
                         p_error_text     => SUBSTR(SQLERRM,1,240) );
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

END Process_Flight_Schedules;

-----------------------------------------------------------------------------------------------------
-- Function for constructing record identifier for error messages.
-----------------------------------------------------------------------------------------------------

FUNCTION get_record_identifier(
    p_flght_visit_schedules_rec IN  FLIGHT_VISIT_SCH_REC_TYPE
)
RETURN VARCHAR2
IS
l_record_identifier VARCHAR2(200);
BEGIN
    l_record_identifier := '';

    IF p_flght_visit_schedules_rec.UNIT_CONFIG_NAME IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||p_flght_visit_schedules_rec.UNIT_CONFIG_NAME;
    END IF;

    IF p_flght_visit_schedules_rec.FLIGHT_NUMBER IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||','||p_flght_visit_schedules_rec.FLIGHT_NUMBER;
    END IF;

    IF p_flght_visit_schedules_rec.SEGMENT IS NOT NULL
    THEN
        l_record_identifier := l_record_identifier||','||p_flght_visit_schedules_rec.SEGMENT;
    END IF;

    RETURN l_record_identifier;

END get_record_identifier;
------------------------------------------------------------------------------------------
-- Internal procedure which does the work of populating flight schedule rec,
-- call pvt procedure and repopulate the ids back to flight_visit_rec.
------------------------------------------------------------------------------------------


PROCEDURE handle_flight_schedules(
    p_x_flght_visit_schedules_tbl   IN OUT NOCOPY   FLIGHT_VISIT_SCH_TBL_TYPE,
    x_return_status                 OUT NOCOPY          VARCHAR2,
    x_msg_count                     OUT NOCOPY          NUMBER,
    x_msg_data                      OUT NOCOPY          VARCHAR2
)
IS
i NUMBER;
l_x_flight_schedules_tbl    AHL_UA_FLIGHT_SCHEDULES_PVT.FLIGHT_SCHEDULES_TBL_TYPE;
l_api_name          CONSTANT    VARCHAR2(30)    := 'handle_flight_schedules';
BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of procedure'
        );
        END IF;

    FOR i IN p_x_flght_visit_schedules_tbl.FIRST..p_x_flght_visit_schedules_tbl.LAST
    LOOP
         l_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID       := p_x_flght_visit_schedules_tbl(i).UNIT_SCHEDULE_ID;
         l_x_flight_schedules_tbl(i).FLIGHT_NUMBER      := p_x_flght_visit_schedules_tbl(i).FLIGHT_NUMBER ;
         l_x_flight_schedules_tbl(i).SEGMENT            := p_x_flght_visit_schedules_tbl(i).SEGMENT;
         l_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME     := p_x_flght_visit_schedules_tbl(i).EST_DEPARTURE_TIME;
         l_x_flight_schedules_tbl(i).ACTUAL_DEPARTURE_TIME  := p_x_flght_visit_schedules_tbl(i).ACTUAL_DEPARTURE_TIME;
         l_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID      := p_x_flght_visit_schedules_tbl(i).DEPARTURE_DEPT_ID;
         l_x_flight_schedules_tbl(i).DEPARTURE_DEPT_CODE    := p_x_flght_visit_schedules_tbl(i).DEPARTURE_DEPT_CODE;
         l_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID       := p_x_flght_visit_schedules_tbl(i).DEPARTURE_ORG_ID;
         l_x_flight_schedules_tbl(i).DEPARTURE_ORG_CODE     := p_x_flght_visit_schedules_tbl(i).DEPARTURE_ORG_CODE;
         l_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME       := p_x_flght_visit_schedules_tbl(i).EST_ARRIVAL_TIME;
         l_x_flight_schedules_tbl(i).ACTUAL_ARRIVAL_TIME    := p_x_flght_visit_schedules_tbl(i).ACTUAL_ARRIVAL_TIME;
         l_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID        := p_x_flght_visit_schedules_tbl(i).ARRIVAL_DEPT_ID;
         l_x_flight_schedules_tbl(i).ARRIVAL_DEPT_CODE      := p_x_flght_visit_schedules_tbl(i).ARRIVAL_DEPT_CODE;
         l_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID     := p_x_flght_visit_schedules_tbl(i).ARRIVAL_ORG_ID;
         l_x_flight_schedules_tbl(i).ARRIVAL_ORG_CODE       := p_x_flght_visit_schedules_tbl(i).ARRIVAL_ORG_CODE;
         l_x_flight_schedules_tbl(i).PRECEDING_US_ID        := p_x_flght_visit_schedules_tbl(i).PRECEDING_US_ID;
         l_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID  := p_x_flght_visit_schedules_tbl(i).UNIT_CONFIG_HEADER_ID;
         l_x_flight_schedules_tbl(i).UNIT_CONFIG_NAME       := p_x_flght_visit_schedules_tbl(i).UNIT_CONFIG_NAME;
         l_x_flight_schedules_tbl(i).CSI_INSTANCE_ID        := p_x_flght_visit_schedules_tbl(i).CSI_INSTANCE_ID;
         l_x_flight_schedules_tbl(i).INSTANCE_NUMBER        := p_x_flght_visit_schedules_tbl(i).INSTANCE_NUMBER;
         l_x_flight_schedules_tbl(i).ITEM_NUMBER        := p_x_flght_visit_schedules_tbl(i).ITEM_NUMBER;
         l_x_flight_schedules_tbl(i).SERIAL_NUMBER      := p_x_flght_visit_schedules_tbl(i).SERIAL_NUMBER;
         l_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE  := p_x_flght_visit_schedules_tbl(i).VISIT_RESCHEDULE_MODE;
         l_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MEANING   := p_x_flght_visit_schedules_tbl(i).VISIT_RESCHEDULE_MEANING;
         l_x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER  := p_x_flght_visit_schedules_tbl(i).OBJECT_VERSION_NUMBER;
         --l_x_flight_schedules_tbl(i).IS_UPDATE_ALLOWED        := p_x_flght_visit_schedules_tbl(i).IS_UPDATE_ALLOWED;
         --l_x_flight_schedules_tbl(i).IS_DELETE_ALLOWED        := p_x_flght_visit_schedules_tbl(i).IS_DELETE_ALLOWED;
         l_x_flight_schedules_tbl(i).ATTRIBUTE_CATEGORY     := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE_CATEGORY;
         l_x_flight_schedules_tbl(i).ATTRIBUTE1         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE1;
         l_x_flight_schedules_tbl(i).ATTRIBUTE2         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE2;
         l_x_flight_schedules_tbl(i).ATTRIBUTE3         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE3;
         l_x_flight_schedules_tbl(i).ATTRIBUTE4         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE4;
         l_x_flight_schedules_tbl(i).ATTRIBUTE5         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE5;
         l_x_flight_schedules_tbl(i).ATTRIBUTE6         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE6;
         l_x_flight_schedules_tbl(i).ATTRIBUTE7         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE7;
         l_x_flight_schedules_tbl(i).ATTRIBUTE8         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE8;
         l_x_flight_schedules_tbl(i).ATTRIBUTE9         := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE9;
         l_x_flight_schedules_tbl(i).ATTRIBUTE10        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE10;
         l_x_flight_schedules_tbl(i).ATTRIBUTE11        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE11;
         l_x_flight_schedules_tbl(i).ATTRIBUTE12        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE12;
         l_x_flight_schedules_tbl(i).ATTRIBUTE13        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE13;
         l_x_flight_schedules_tbl(i).ATTRIBUTE14        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE14;
         l_x_flight_schedules_tbl(i).ATTRIBUTE15        := p_x_flght_visit_schedules_tbl(i).ATTRIBUTE15;
         l_x_flight_schedules_tbl(i).DML_OPERATION      := p_x_flght_visit_schedules_tbl(i).DML_OPERATION;
    END LOOP;

    -- Call the private procedure for processing visits
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Calling AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules..'
         );
    END IF;

    AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules(
         p_api_version          =>  1.0,
         p_init_msg_list        =>  FND_API.G_FALSE,
         p_commit           =>  FND_API.G_FALSE,
         p_validation_level     =>  FND_API.G_VALID_LEVEL_FULL,
         p_default          =>  FND_API.G_FALSE,
         p_module_type          =>  null,
         x_return_status        =>  x_return_status,
         x_msg_count            =>  x_msg_count,
         x_msg_data         =>  x_msg_data,
         p_x_flight_schedules_tbl   =>  l_x_flight_schedules_tbl
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'After calling AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules....'
         );
    END IF;

    -- Check Error Message stack.
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised expected error....'
         );
            END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised unexpected error....'
         );
            END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --Populate the ids back to flight_visit_rec
    FOR i IN p_x_flght_visit_schedules_tbl.FIRST..p_x_flght_visit_schedules_tbl.LAST
    LOOP
     p_x_flght_visit_schedules_tbl(i).UNIT_SCHEDULE_ID  := l_x_flight_schedules_tbl(i).UNIT_SCHEDULE_ID;
     p_x_flght_visit_schedules_tbl(i).FLIGHT_NUMBER     := l_x_flight_schedules_tbl(i).FLIGHT_NUMBER;
     p_x_flght_visit_schedules_tbl(i).SEGMENT           := l_x_flight_schedules_tbl(i).SEGMENT;
     p_x_flght_visit_schedules_tbl(i).EST_DEPARTURE_TIME        := l_x_flight_schedules_tbl(i).EST_DEPARTURE_TIME;
     p_x_flght_visit_schedules_tbl(i).ACTUAL_DEPARTURE_TIME := l_x_flight_schedules_tbl(i).ACTUAL_DEPARTURE_TIME;
     p_x_flght_visit_schedules_tbl(i).DEPARTURE_DEPT_ID     := l_x_flight_schedules_tbl(i).DEPARTURE_DEPT_ID;
     p_x_flght_visit_schedules_tbl(i).DEPARTURE_DEPT_CODE   := l_x_flight_schedules_tbl(i).DEPARTURE_DEPT_CODE;
     p_x_flght_visit_schedules_tbl(i).DEPARTURE_ORG_ID      := l_x_flight_schedules_tbl(i).DEPARTURE_ORG_ID;
     p_x_flght_visit_schedules_tbl(i).DEPARTURE_ORG_CODE        := l_x_flight_schedules_tbl(i).DEPARTURE_ORG_CODE;
     p_x_flght_visit_schedules_tbl(i).EST_ARRIVAL_TIME      := l_x_flight_schedules_tbl(i).EST_ARRIVAL_TIME;
     p_x_flght_visit_schedules_tbl(i).ACTUAL_ARRIVAL_TIME   := l_x_flight_schedules_tbl(i).ACTUAL_ARRIVAL_TIME;
     p_x_flght_visit_schedules_tbl(i).ARRIVAL_DEPT_ID       := l_x_flight_schedules_tbl(i).ARRIVAL_DEPT_ID;
     p_x_flght_visit_schedules_tbl(i).ARRIVAL_DEPT_CODE     := l_x_flight_schedules_tbl(i).ARRIVAL_DEPT_CODE;
     p_x_flght_visit_schedules_tbl(i).ARRIVAL_ORG_ID        := l_x_flight_schedules_tbl(i).ARRIVAL_ORG_ID;
     p_x_flght_visit_schedules_tbl(i).ARRIVAL_ORG_CODE      := l_x_flight_schedules_tbl(i).ARRIVAL_ORG_CODE;
     p_x_flght_visit_schedules_tbl(i).PRECEDING_US_ID       := l_x_flight_schedules_tbl(i).PRECEDING_US_ID;
     p_x_flght_visit_schedules_tbl(i).UNIT_CONFIG_HEADER_ID := l_x_flight_schedules_tbl(i).UNIT_CONFIG_HEADER_ID;
     p_x_flght_visit_schedules_tbl(i).UNIT_CONFIG_NAME      := l_x_flight_schedules_tbl(i).UNIT_CONFIG_NAME;
     p_x_flght_visit_schedules_tbl(i).CSI_INSTANCE_ID       := l_x_flight_schedules_tbl(i).CSI_INSTANCE_ID;
     p_x_flght_visit_schedules_tbl(i).INSTANCE_NUMBER       := l_x_flight_schedules_tbl(i).INSTANCE_NUMBER;
     p_x_flght_visit_schedules_tbl(i).ITEM_NUMBER       := l_x_flight_schedules_tbl(i).ITEM_NUMBER;
     p_x_flght_visit_schedules_tbl(i).SERIAL_NUMBER     := l_x_flight_schedules_tbl(i).SERIAL_NUMBER;
     p_x_flght_visit_schedules_tbl(i).VISIT_RESCHEDULE_MODE := l_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MODE;
     p_x_flght_visit_schedules_tbl(i).VISIT_RESCHEDULE_MEANING  := l_x_flight_schedules_tbl(i).VISIT_RESCHEDULE_MEANING;
     p_x_flght_visit_schedules_tbl(i).OBJECT_VERSION_NUMBER := l_x_flight_schedules_tbl(i).OBJECT_VERSION_NUMBER;
     --p_x_flght_visit_schedules_tbl(i).IS_UPDATE_ALLOWED       := p_x_flght_visit_schedules_tbl(i).IS_UPDATE_ALLOWED;
     --p_x_flght_visit_schedules_tbl(i).IS_DELETE_ALLOWED       := p_x_flght_visit_schedules_tbl(i).IS_DELETE_ALLOWED;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE_CATEGORY        := l_x_flight_schedules_tbl(i).ATTRIBUTE_CATEGORY;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE1            := l_x_flight_schedules_tbl(i).ATTRIBUTE1;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE2            := l_x_flight_schedules_tbl(i).ATTRIBUTE2;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE3            := l_x_flight_schedules_tbl(i).ATTRIBUTE3;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE4            := l_x_flight_schedules_tbl(i).ATTRIBUTE4;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE5            := l_x_flight_schedules_tbl(i).ATTRIBUTE5;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE6            := l_x_flight_schedules_tbl(i).ATTRIBUTE6;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE7            := l_x_flight_schedules_tbl(i).ATTRIBUTE7;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE8            := l_x_flight_schedules_tbl(i).ATTRIBUTE8;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE9            := l_x_flight_schedules_tbl(i).ATTRIBUTE9;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE10       := l_x_flight_schedules_tbl(i).ATTRIBUTE10;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE11       := l_x_flight_schedules_tbl(i).ATTRIBUTE11;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE12       := l_x_flight_schedules_tbl(i).ATTRIBUTE12;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE13       := l_x_flight_schedules_tbl(i).ATTRIBUTE13;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE14       := l_x_flight_schedules_tbl(i).ATTRIBUTE14;
     p_x_flght_visit_schedules_tbl(i).ATTRIBUTE15       := l_x_flight_schedules_tbl(i).ATTRIBUTE15;
    END LOOP;
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the end of procedure'
        );
        END IF;


END handle_flight_schedules;



------------------------------------------------------------------------------------------
-- Internal procedure for Auto Creating Visits.
------------------------------------------------------------------------------------------

PROCEDURE auto_create_transit_visit(
    p_x_flight_visit_schedules_tbl  IN OUT NOCOPY   FLIGHT_VISIT_SCH_TBL_TYPE,
    x_return_status                 OUT NOCOPY          VARCHAR2,
    x_msg_count                     OUT NOCOPY          NUMBER,
    x_msg_data                      OUT NOCOPY          VARCHAR2
)
IS
    l_x_visit_rec AHL_VWP_VISITS_PVT.Visit_Rec_Type;
    l_x_visit_tbl AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
    l_is_conflict VARCHAR2(1);
    l_x_succ_flight_schedule AHL_UA_FLIGHT_SCHEDULES_PVT.Flight_Schedule_Rec_Type;
    i NUMBER;
    j NUMBER;
    l_api_name          CONSTANT    VARCHAR2(30)    := 'auto_create_transit_visit';
    l_api_version           CONSTANT    NUMBER  := 1.0;
BEGIN

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of procedure'
        );
        END IF;

        -- populate visit table with required parameters.
    j := 0;

    FOR i IN p_x_flight_visit_schedules_tbl.FIRST..p_x_flight_visit_schedules_tbl.LAST
    LOOP
      IF p_x_flight_visit_schedules_tbl(i).DML_OPERATION = 'C' OR
         p_x_flight_visit_schedules_tbl(i).DML_OPERATION = 'c'
      THEN

        -- check for visit_create_type visit_type_code not null (also the meaning)...
          j := j + 1;

        l_x_visit_tbl(j).VISIT_NAME     :=  p_x_flight_visit_schedules_tbl(i).FLIGHT_NUMBER;
        l_x_visit_tbl(j).ORGANIZATION_ID    :=  p_x_flight_visit_schedules_tbl(i).ARRIVAL_ORG_ID;
        l_x_visit_tbl(j).DEPARTMENT_ID      :=  p_x_flight_visit_schedules_tbl(i).ARRIVAL_DEPT_ID;
        l_x_visit_tbl(j).START_DATE     :=  p_x_flight_visit_schedules_tbl(i).EST_ARRIVAL_TIME;
        --Splitting date into hour and minutes as VWP needs them separately.
        l_x_visit_tbl(j).START_HOUR     :=  TO_NUMBER(TO_CHAR(p_x_flight_visit_schedules_tbl(i).EST_ARRIVAL_TIME,'HH24'));
        l_x_visit_tbl(j).START_MIN      :=  TO_NUMBER(TO_CHAR(p_x_flight_visit_schedules_tbl(i).EST_ARRIVAL_TIME,'MI'));
        l_x_visit_tbl(j).VISIT_TYPE_CODE    :=  p_x_flight_visit_schedules_tbl(i).VISIT_TYPE_CODE;
        l_x_visit_tbl(j).VISIT_TYPE_NAME    :=  p_x_flight_visit_schedules_tbl(i).VISIT_TYPE_MEANING;
        l_x_visit_tbl(j).VISIT_CREATE_TYPE  :=  p_x_flight_visit_schedules_tbl(i).VISIT_CREATE_TYPE;
        --l_x_visit_tbl(j).VISIT_CREATE_MEANING :=  p_x_flight_visit_schedules_tbl(i).VISIT_CREATE_MEANING;
        l_x_visit_tbl(j).UNIT_NAME      :=  p_x_flight_visit_schedules_tbl(i).UNIT_CONFIG_NAME;
        --l_x_visit_tbl(j).UNIT_CONFIG_HEADER_ID    :=  p_x_flight_visit_schedules_tbl(i).UNIT_CONFIG_HEADER_ID;
        l_x_visit_tbl(j).ITEM_INSTANCE_ID   :=  p_x_flight_visit_schedules_tbl(i).CSI_INSTANCE_ID;
        l_x_visit_tbl(j).ITEM_NAME      :=  p_x_flight_visit_schedules_tbl(i).ITEM_NUMBER;
        l_x_visit_tbl(j).SERIAL_NUMBER      :=  p_x_flight_visit_schedules_tbl(i).SERIAL_NUMBER;
        l_x_visit_tbl(j).UNIT_SCHEDULE_ID   :=  p_x_flight_visit_schedules_tbl(i).UNIT_SCHEDULE_ID;
            l_x_visit_tbl(j).TEMPLATE_FLAG      :=  'N';
            l_x_visit_tbl(j).OPERATION_FLAG     :=  'I';

            -- Determine if the succeding event is visit and its details.
            AHL_UA_COMMON_PVT.Get_Succ_Visit_Info
        (
                p_api_version       =>  l_api_version,
            x_return_status     =>  x_return_status,
            x_msg_count     =>  x_msg_count,
            x_msg_data      =>  x_msg_data,
            p_unit_config_id    =>  p_x_flight_visit_schedules_tbl(i).UNIT_CONFIG_HEADER_ID,
            p_end_date_time     =>  p_x_flight_visit_schedules_tbl(i).EST_ARRIVAL_TIME,
            x_succ_visit        =>  l_x_visit_rec,
            x_is_conflict       =>  l_is_conflict
        );

        -- Check Error Message stack.
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised expected error....'
             );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised unexpected error....'
             );
            END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Determine if the succeding event is Flight and its details.
            AHL_UA_COMMON_PVT.Get_Succ_Flight_Info
        (
                p_api_version       =>  l_api_version,
            x_return_status     =>  x_return_status,
            x_msg_count     =>  x_msg_count,
            x_msg_data      =>  x_msg_data,
            p_unit_config_id    =>  p_x_flight_visit_schedules_tbl(i).UNIT_CONFIG_HEADER_ID,
            p_end_date_time     =>  p_x_flight_visit_schedules_tbl(i).EST_ARRIVAL_TIME,
            p_use_actuals       =>  FND_API.G_FALSE,
            x_succ_flight_schedule  =>  l_x_succ_flight_schedule,
            x_is_conflict       =>  l_is_conflict
        );

        -- Check Error Message stack.
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised expected error....'
             );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_UA_FLIGHT_SCHEDULES_PVT.Process_Flight_Schedules API raised unexpected error....'
             );
            END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

            IF l_x_visit_rec.visit_id IS NOT NULL THEN
                l_x_visit_tbl(j).PLAN_END_DATE      :=  l_x_visit_rec.START_DATE;
            ELSIF l_x_succ_flight_schedule.UNIT_SCHEDULE_ID IS NOT NULL THEN
                l_x_visit_tbl(j).PLAN_END_DATE      :=  l_x_succ_flight_schedule.EST_DEPARTURE_TIME;
            END IF;

        IF l_x_visit_tbl(j).PLAN_END_DATE IS NOT NULL THEN
            l_x_visit_tbl(j).PLAN_END_HOUR  :=  TO_NUMBER(TO_CHAR(l_x_visit_tbl(j).PLAN_END_DATE, 'HH24'));
            l_x_visit_tbl(j).PLAN_END_MIN   :=  TO_NUMBER(TO_CHAR(l_x_visit_tbl(j).PLAN_END_DATE, 'MI'));
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).VISIT_NAME->'||l_x_visit_tbl(j).VISIT_NAME
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).ORGANIZATION_ID->'||l_x_visit_tbl(j).ORGANIZATION_ID
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).DEPARTMENT_ID->'||l_x_visit_tbl(j).DEPARTMENT_ID
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).START_DATE->'||l_x_visit_tbl(j).START_DATE
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).VISIT_TYPE_CODE->'||l_x_visit_tbl(j).VISIT_TYPE_CODE
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).VISIT_TYPE_NAME->'||l_x_visit_tbl(j).VISIT_TYPE_NAME
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).VISIT_CREATE_TYPE->'||l_x_visit_tbl(j).VISIT_CREATE_TYPE
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).UNIT_NAME->'||l_x_visit_tbl(j).UNIT_NAME
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).ITEM_INSTANCE_ID->'||l_x_visit_tbl(j).ITEM_INSTANCE_ID
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).ITEM_NAME->'||l_x_visit_tbl(j).ITEM_NAME
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).SERIAL_NUMBER->'||l_x_visit_tbl(j).SERIAL_NUMBER
             );
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).UNIT_SCHEDULE_ID->'||l_x_visit_tbl(j).UNIT_SCHEDULE_ID
             );

             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'l_x_visit_tbl(j).OPERATION_FLAG->'||l_x_visit_tbl(j).OPERATION_FLAG
             );
        END IF;
      END IF;
        END LOOP;

    IF l_x_visit_tbl.COUNT > 0
    THEN

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Calling AHL_VWP_VISITS_PVT.Process_Visit'
             );
        END IF;

        AHL_VWP_VISITS_PVT.Process_Visit (
               p_api_version        =>  1.0,
               p_init_msg_list      =>  FND_API.G_FALSE,
               p_commit         =>  FND_API.G_FALSE,
               p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,
               p_module_type        =>  NULL,
               p_x_Visit_tbl        =>  l_x_visit_tbl,
               x_return_status      =>  x_return_status,
               x_msg_count          =>  x_msg_count,
               x_msg_data           =>  x_msg_data
        );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'After calling AHL_VWP_VISITS_PVT.Process_Visit'
             );
        END IF;

        -- Check Error Message stack.
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_VWP_VISITS_PVT.Process_Visit API raised expected error....'
             );
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'AHL_VWP_VISITS_PVT.Process_Visit API raised unexpected error....'
             );
            END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Re-assign visit id.
        j := l_x_visit_tbl.FIRST;
        FOR i IN p_x_flight_visit_schedules_tbl.FIRST..p_x_flight_visit_schedules_tbl.LAST
        LOOP
              IF p_x_flight_visit_schedules_tbl(i).DML_OPERATION = 'I' OR
                 p_x_flight_visit_schedules_tbl(i).DML_OPERATION = 'i'
              THEN
                p_x_flight_visit_schedules_tbl(i).visit_id := l_x_visit_tbl(j).visit_id;
                j := j + 1;
                IF j >= l_x_visit_tbl.COUNT
                THEN
                   EXIT;
                END IF;
              END IF;
        END LOOP;

    END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the end of procedure'
        );
        END IF;
END auto_create_transit_visit;


PROCEDURE validate_api_inputs(
    p_flight_visit_sch_tbl    IN        FLIGHT_VISIT_SCH_TBL_TYPE,
    x_return_status           OUT NOCOPY    VARCHAR2
)
IS
l_api_name          CONSTANT    VARCHAR2(30)    := 'validate_api_inputs';

BEGIN
    -- Initialize return status to success initially
        x_return_status:= FND_API.G_RET_STS_SUCCESS;

    FOR i IN p_flight_visit_sch_tbl.FIRST..p_flight_visit_sch_tbl.LAST
    LOOP

      --Validate DML flag
      IF (
          p_flight_visit_sch_tbl(i).DML_OPERATION IS NULL
          OR
          (
            p_flight_visit_sch_tbl(i).DML_OPERATION <> 'D' AND p_flight_visit_sch_tbl(i).DML_OPERATION <> 'd' AND
            p_flight_visit_sch_tbl(i).DML_OPERATION <> 'U' AND p_flight_visit_sch_tbl(i).DML_OPERATION <> 'u' AND
            p_flight_visit_sch_tbl(i).DML_OPERATION <> 'C' AND p_flight_visit_sch_tbl(i).DML_OPERATION <> 'c'
          )
         )
      THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'Invalid DML Operation flag for '
            ||p_flight_visit_sch_tbl(i).unit_schedule_id
             );
        END IF;
        FND_MESSAGE.set_name( 'AHL','AHL_COM_INVALID_DML' );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
        FND_MESSAGE.set_token( 'FIELD', p_flight_visit_sch_tbl(i).DML_OPERATION);
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      --Obj version number and Unit Schedule id check in case of update or delete.
      IF ( p_flight_visit_sch_tbl(i).DML_OPERATION = 'D' OR p_flight_visit_sch_tbl(i).DML_OPERATION = 'd' OR
           p_flight_visit_sch_tbl(i).DML_OPERATION = 'U' OR p_flight_visit_sch_tbl(i).DML_OPERATION = 'u' )
      THEN
        --Unit Schedule id cannot be null
        IF (p_flight_visit_sch_tbl(i).UNIT_SCHEDULE_ID IS NULL OR
        p_flight_visit_sch_tbl(i).UNIT_SCHEDULE_ID = FND_API.G_MISS_NUM)
        THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Flight Schedule doesnt id cannot be null '
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_US_NOT_FOUND' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Check for Object Version number.
        IF (p_flight_visit_sch_tbl(i).OBJECT_VERSION_NUMBER IS NULL OR
           p_flight_visit_sch_tbl(i).OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM)
        THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Object version number cannot be null for  '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_OBJ_VERNO_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

      IF p_flight_visit_sch_tbl(i).DML_OPERATION = 'C' OR
         p_flight_visit_sch_tbl(i).DML_OPERATION = 'c' OR
         p_flight_visit_sch_tbl(i).DML_OPERATION = 'U' OR
         p_flight_visit_sch_tbl(i).DML_OPERATION = 'u'
      THEN
          -- Unit Config Header id is a mandatory input field and cannot be null.
          IF (p_flight_visit_sch_tbl(i).UNIT_CONFIG_HEADER_ID IS NULL OR
              p_flight_visit_sch_tbl(i).UNIT_CONFIG_HEADER_ID = FND_API.G_MISS_NUM )AND
             (p_flight_visit_sch_tbl(i).UNIT_CONFIG_NAME IS NULL OR
              p_flight_visit_sch_tbl(i).UNIT_CONFIG_NAME = FND_API.G_MISS_CHAR)

          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Unit config header id and name, both cannot be null for '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_INV_UC_NAME' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Flight Number is a mandatory input field and cannot be null.
          IF p_flight_visit_sch_tbl(i).FLIGHT_NUMBER IS NULL OR
             p_flight_visit_sch_tbl(i).FLIGHT_NUMBER = FND_API.G_MISS_CHAR
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Flight Number cannot be null for '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_FLG_NUMBER_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Segment is a mandatory input field and cannot be null
          IF p_flight_visit_sch_tbl(i).SEGMENT IS NULL OR
             p_flight_visit_sch_tbl(i).SEGMENT = FND_API.G_MISS_CHAR
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Flight Segment cannot be null for '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_SEGMENT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Departure_Dept_Id is a mandatory input field and cannot be null
          IF ( p_flight_visit_sch_tbl(i).DEPARTURE_DEPT_ID IS NULL OR
               p_flight_visit_sch_tbl(i).DEPARTURE_DEPT_ID = FND_API.G_MISS_NUM ) AND
             ( p_flight_visit_sch_tbl(i).DEPARTURE_DEPT_CODE IS NULL OR
               p_flight_visit_sch_tbl(i).DEPARTURE_DEPT_CODE = FND_API.G_MISS_CHAR )
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Departure Department id and code, both cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_DEPT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Departure_Org_Id is a mandatory input field and cannot be null
          IF ( p_flight_visit_sch_tbl(i).DEPARTURE_ORG_ID IS NULL OR
               p_flight_visit_sch_tbl(i).DEPARTURE_ORG_ID = FND_API.G_MISS_NUM ) AND
             ( p_flight_visit_sch_tbl(i).DEPARTURE_ORG_CODE IS NULL OR
               p_flight_visit_sch_tbl(i).DEPARTURE_ORG_CODE = FND_API.G_MISS_CHAR )
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Departure Org id and code, both cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_DEP_ORG_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Arrival_Dept_Id is a mandatory input field and cannot be null
          IF ( p_flight_visit_sch_tbl(i).ARRIVAL_DEPT_ID IS NULL OR
               p_flight_visit_sch_tbl(i).ARRIVAL_DEPT_ID = FND_API.G_MISS_NUM ) AND
             ( p_flight_visit_sch_tbl(i).ARRIVAL_DEPT_CODE IS NULL  OR
               p_flight_visit_sch_tbl(i).ARRIVAL_DEPT_CODE = FND_API.G_MISS_CHAR )

          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Arrival dept id and code, both cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_DEPT_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Arrival_Org_Id is a mandatory input field and cannot be null
          IF ( p_flight_visit_sch_tbl(i).ARRIVAL_ORG_ID IS NULL OR
               p_flight_visit_sch_tbl(i).ARRIVAL_ORG_ID = FND_API.G_MISS_NUM ) AND
             ( p_flight_visit_sch_tbl(i).ARRIVAL_ORG_CODE IS NULL OR
               p_flight_visit_sch_tbl(i).ARRIVAL_ORG_CODE = FND_API.G_MISS_CHAR )
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Arrival org id and code, both cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_ARR_ORG_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Est_Departure_Time is a mandatory input field and cannot be null
          IF p_flight_visit_sch_tbl(i).EST_DEPARTURE_TIME IS NULL OR
             p_flight_visit_sch_tbl(i).EST_DEPARTURE_TIME = FND_API.G_MISS_DATE
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'estimated departure time cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_DEP_TIME_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Est_Arrival_Time is a mandatory input field and cannot be null
          IF p_flight_visit_sch_tbl(i).EST_ARRIVAL_TIME IS NULL OR
             p_flight_visit_sch_tbl(i).EST_ARRIVAL_TIME = FND_API.G_MISS_DATE
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Estimated arrival cannot be null '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_EST_ARR_TIME_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          --Visit_Reschedule_Mode is a mandatory input field and cannot be null
          IF ( p_flight_visit_sch_tbl(i).VISIT_RESCHEDULE_MODE IS NULL OR
               p_flight_visit_sch_tbl(i).VISIT_RESCHEDULE_MODE = FND_API.G_MISS_CHAR ) AND
             ( p_flight_visit_sch_tbl(i).VISIT_RESCHEDULE_MEANING IS NULL OR
               p_flight_visit_sch_tbl(i).VISIT_RESCHEDULE_MEANING = FND_API.G_MISS_CHAR )
          THEN
            IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                 fnd_log.string
                 (
                fnd_log.level_error,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                'Visit Reschedule mode cannot be null for '
                ||p_flight_visit_sch_tbl(i).unit_schedule_id
                 );
            END IF;
            FND_MESSAGE.set_name( 'AHL','AHL_UA_VST_RES_MODE_NULL' );
            FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
            FND_MSG_PUB.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          ----------------- Validate visit paramters here, only when DML_OPERATION is C -------------------
          IF p_flight_visit_sch_tbl(i).DML_OPERATION = 'C' OR
             p_flight_visit_sch_tbl(i).DML_OPERATION = 'c'
          THEN
              -- Check for visit type.
              IF ( p_flight_visit_sch_tbl(i).VISIT_TYPE_CODE IS NULL OR
                   p_flight_visit_sch_tbl(i).VISIT_TYPE_CODE = FND_API.G_MISS_CHAR ) AND
                 ( p_flight_visit_sch_tbl(i).VISIT_TYPE_MEANING IS NULL OR
                   p_flight_visit_sch_tbl(i).VISIT_TYPE_MEANING = FND_API.G_MISS_CHAR )
              THEN
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string
                     (
                    fnd_log.level_error,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'Visit Type Code cannot be null for '
                    ||p_flight_visit_sch_tbl(i).unit_schedule_id
                     );
                END IF;
                FND_MESSAGE.set_name( 'AHL','AHL_UA_VST_TYPE_NULL' );
                FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
                FND_MSG_PUB.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              -- Check for visit create type.
              IF ( p_flight_visit_sch_tbl(i).VISIT_CREATE_TYPE IS NULL OR
                   p_flight_visit_sch_tbl(i).VISIT_CREATE_TYPE = FND_API.G_MISS_CHAR ) AND
                 ( p_flight_visit_sch_tbl(i).VISIT_CREATE_MEANING IS NULL OR
                   p_flight_visit_sch_tbl(i).VISIT_CREATE_MEANING = FND_API.G_MISS_CHAR )
              THEN
                IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
                     fnd_log.string
                     (
                    fnd_log.level_error,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
                    'Visit create type code cannot be null for '
                    ||p_flight_visit_sch_tbl(i).unit_schedule_id
                     );
                END IF;
                FND_MESSAGE.set_name( 'AHL','AHL_UA_VST_CRE_TYPE_NULL' );
                FND_MESSAGE.set_token( 'RECORD', get_record_identifier(p_flight_visit_sch_tbl(i)));
                FND_MSG_PUB.add;
                x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
          END IF;

      END IF;
      END LOOP;
END validate_api_inputs;


------------------------------------------------------------------------------------------
-- Public procedure for Processing(Create/Update/Delete) Flight Schedules
-- and for Auto Creating Visits.
------------------------------------------------------------------------------------------

PROCEDURE Process_FlightVisit_Sch
(
    -- standard IN params
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2    :=FND_API.G_FALSE,
    p_commit            IN      VARCHAR2    :=FND_API.G_FALSE,
    p_validation_level      IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
    p_default           IN      VARCHAR2    :=FND_API.G_FALSE,
    p_module_type           IN      VARCHAR2    :=NULL,
    -- standard OUT params
    x_return_status                 OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                      OUT NOCOPY      VARCHAR2,
    -- procedure params
    p_x_flight_visit_sch_tbl    IN OUT  NOCOPY  FLIGHT_VISIT_SCH_TBL_TYPE
)
IS
l_api_name          CONSTANT    VARCHAR2(30)    := 'Process_FlightVisit_Sch';
l_api_version           CONSTANT    NUMBER      := 1.0;
BEGIN
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the start of PLSQL procedure Process_FlightVisit_Sch'
        );
        END IF;

    --define a savepoint for the procedure
        SAVEPOINT p_x_flght_visit_schedules_pub;

    -- Initialize return status to success initially
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;


        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
             fnd_log.string
             (
             fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
             'Before calling the private API.....'
             );
        END IF;

    -- API call to validate all API input parameters.
    validate_api_inputs(
     p_flight_visit_sch_tbl     =>  p_x_flight_visit_sch_tbl,
     x_return_status        =>  x_return_status
    );

    -- If any severe error occurs, then, abort API.
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'validate_api_inputs API raised expected error....'
         );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
         (
            fnd_log.level_error,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
            'validate_api_inputs API raised unexpected error....'
         );
        END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Procedure to populate Flight Schedule rec from flight_visit_rec

    handle_flight_schedules(
        p_x_flght_visit_schedules_tbl   =>  p_x_flight_visit_sch_tbl,
        x_return_status         =>  x_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data


    );

    --Call procedure to auto create visit
    auto_create_transit_visit(
        p_x_flight_visit_schedules_tbl  => p_x_flight_visit_sch_tbl,
        x_return_status         =>  x_return_status,
        x_msg_count         =>  x_msg_count,
        x_msg_data          =>  x_msg_data
    );

    -- Standard check for p_commit
    IF FND_API.To_Boolean (p_commit)
    THEN
        COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
        (
            fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||'.begin',
            'At the end of PLSQL procedure Process_FlightVisit_Sch'
        );
        END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Rollback to p_x_flght_visit_schedules_pub;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to p_x_flght_visit_schedules_pub;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        Rollback to p_x_flght_visit_schedules_pub;
        IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            fnd_msg_pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                         p_procedure_name => l_api_name,
                         p_error_text     => SUBSTR(SQLERRM,1,240) );
        END IF;
        FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                       p_data  => x_msg_data,
                       p_encoded => fnd_api.g_false );

END Process_FlightVisit_Sch;

END AHL_UA_FLIGHT_SCHEDULES_PUB;

/
