--------------------------------------------------------
--  DDL for Package Body FLM_LINEARITY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_LINEARITY_REPORT" AS
/* $Header: FLMFLINB.pls 115.3 2002/11/27 11:19:25 nrajpal ship $ */

PROCEDURE populate_flow_summary (
        x_return_status         OUT     NOCOPY	VARCHAR2,
        p_line_from             IN      VARCHAR2,
        p_line_to               IN      VARCHAR2,
        p_sch_group             IN      VARCHAR2,
        p_org_id                IN      NUMBER,
        p_begin_date            IN      DATE,
        p_last_date             IN      DATE,
        p_query_id              IN      NUMBER
) IS

CURSOR flow_schedule_cursor(l_week_start_date DATE) IS
SELECT  wl.line_code,
        wsg.schedule_group_name schedule_group,
        NVL(wfs.schedule_group_id,-1),
        wfs.primary_item_id,
        trunc(wfs.scheduled_completion_date),
        sum(nvl(wfs.planned_quantity,0)),
        sum(nvl(wfs.quantity_completed,0))
FROM wip_flow_schedules wfs, wip_lines wl, wip_schedule_groups wsg
WHERE wfs.organization_id = p_org_id
AND trunc(wfs.scheduled_completion_date) between trunc(l_week_start_date) and trunc(l_week_start_date+6)
AND wl.line_id = wfs.line_id
AND wl.organization_id = wfs.organization_id
AND (p_line_from IS NULL or (wl.line_code >= p_line_from AND wl.line_code <= p_line_to))
AND wsg.schedule_group_id(+) = wfs.schedule_group_id
AND wsg.organization_id(+) = wfs.organization_id
AND (p_sch_group IS NULL or p_sch_group = wsg.schedule_group_name)
GROUP BY wl.line_code, wsg.schedule_group_name, wfs.schedule_group_id, wfs.primary_item_id,
         trunc(wfs.scheduled_completion_date);

TYPE flow_schedule_type IS RECORD
        ( line_code             VARCHAR2(10),
          schedule_group        VARCHAR2(150),
          schedule_group_id     NUMBER,
          item_id               NUMBER,
          completion_date       DATE,
          planned_qty           NUMBER,
          actual_qty            NUMBER );

TYPE daily_qty_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE daily_date_table IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE weekly_flow_schedule_type IS RECORD
        ( week_start_date       DATE,
          line_code             VARCHAR2(10),
          schedule_group        VARCHAR2(150),
          item_id               NUMBER,
          planned_qty           daily_qty_table,
          actual_qty            daily_qty_table );

flow_schedule           flow_schedule_type;
weekly_flow_schedule    weekly_flow_schedule_type;
l_week_start_date       DATE;
l_last_line_code        VARCHAR2(10);
l_last_schedule_group_id        NUMBER;
l_last_item_id          NUMBER;

PROCEDURE clean_record IS
BEGIN
    weekly_flow_schedule.item_id := NULL;
    weekly_flow_schedule.week_start_date := NULL;
    weekly_flow_schedule.line_code := NULL;
    weekly_flow_schedule.schedule_group := NULL;
    weekly_flow_schedule.planned_qty(1) := NULL;
    weekly_flow_schedule.planned_qty(2) := NULL;
    weekly_flow_schedule.planned_qty(3) := NULL;
    weekly_flow_schedule.planned_qty(4) := NULL;
    weekly_flow_schedule.planned_qty(5) := NULL;
    weekly_flow_schedule.planned_qty(6) := NULL;
    weekly_flow_schedule.planned_qty(7) := NULL;
    weekly_flow_schedule.actual_qty(1) := NULL;
    weekly_flow_schedule.actual_qty(2) := NULL;
    weekly_flow_schedule.actual_qty(3) := NULL;
    weekly_flow_schedule.actual_qty(4) := NULL;
    weekly_flow_schedule.actual_qty(5) := NULL;
    weekly_flow_schedule.actual_qty(6) := NULL;
    weekly_flow_schedule.actual_qty(7) := NULL;
END;

PROCEDURE flush_record IS
BEGIN

    INSERT INTO mrp_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number15,
        date1,
        char1,
        char2,
        number1,
        number2,
        number3,
        number4,
        number5,
        number6,
        number7,
        number8,
        number9,
        number10,
        number11,
        number12,
        number13,
        number14 )
    VALUES (
        p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        weekly_flow_schedule.item_id,
        weekly_flow_schedule.week_start_date,
        weekly_flow_schedule.line_code,
        weekly_flow_schedule.schedule_group,
        weekly_flow_schedule.planned_qty(1),
        weekly_flow_schedule.planned_qty(2),
        weekly_flow_schedule.planned_qty(3),
        weekly_flow_schedule.planned_qty(4),
        weekly_flow_schedule.planned_qty(5),
        weekly_flow_schedule.planned_qty(6),
        weekly_flow_schedule.planned_qty(7),
        weekly_flow_schedule.actual_qty(1),
        weekly_flow_schedule.actual_qty(2),
        weekly_flow_schedule.actual_qty(3),
        weekly_flow_schedule.actual_qty(4),
        weekly_flow_schedule.actual_qty(5),
        weekly_flow_schedule.actual_qty(6),
        weekly_flow_schedule.actual_qty(7)
    );

END flush_record;

BEGIN
  clean_record;
  l_week_start_date := p_begin_date;

  WHILE (l_week_start_date < p_last_date) LOOP

    OPEN flow_schedule_cursor(l_week_start_date);
    FETCH flow_schedule_cursor INTO flow_schedule;

    IF (flow_schedule_cursor%FOUND) THEN

      l_last_schedule_group_id := flow_schedule.schedule_group_id;
      l_last_line_code := flow_schedule.line_code;
      l_last_item_id := flow_schedule.item_id;
      LOOP

        IF ((l_last_schedule_group_id<>flow_schedule.schedule_group_id) OR
        (l_last_line_code<>flow_schedule.line_code) OR (l_last_item_id<>flow_schedule.item_id)) THEN
            flush_record;
            clean_record;
        END IF;

        weekly_flow_schedule.week_start_date := l_week_start_date;
        weekly_flow_schedule.line_code := flow_schedule.line_code;
        weekly_flow_schedule.schedule_group := flow_schedule.schedule_group;
        weekly_flow_schedule.item_id := flow_schedule.item_id;
        weekly_flow_schedule.planned_qty(flow_schedule.completion_date-l_week_start_date+1)
                                         := flow_schedule.planned_qty;
        weekly_flow_schedule.actual_qty(flow_schedule.completion_date-l_week_start_date+1)
                                         := flow_schedule.actual_qty;

        l_last_schedule_group_id := flow_schedule.schedule_group_id;
        l_last_line_code := flow_schedule.line_code;
        l_last_item_id := flow_schedule.item_id;

        FETCH flow_schedule_cursor INTO flow_schedule;
        IF (flow_schedule_cursor%NOTFOUND) THEN
          flush_record;
          clean_record;
          EXIT;
        END IF;

      END LOOP;

    END IF;
    l_week_start_date := l_week_start_date + 7;
    CLOSE flow_schedule_cursor;
  END LOOP;

END Populate_Flow_Summary;

END flm_linearity_report;

/
