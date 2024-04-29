--------------------------------------------------------
--  DDL for Package Body FLM_SEQ_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SEQ_UI" AS
/* $Header: FLMSQUIB.pls 120.2.12010000.2 2008/09/04 15:21:34 adasa ship $  */


  /******************************************************************
   * To delete a task and its details in FLM_SEQ_* tables           *
   ******************************************************************/
  PROCEDURE delete_tasks(p_seq_task_id IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_delete_tasks;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_line := 10;
    DELETE FROM FLM_SEQ_TASK_EXCEPTIONS
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 20;
    DELETE FROM FLM_SEQ_TASK_CONSTRAINTS
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 30;
    DELETE FROM FLM_SEQ_TASK_DEMANDS
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 40;
    DELETE FROM FLM_SEQ_TASK_LINES
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 50;
    DELETE FROM FLM_FILTER_CRITERIA
    WHERE CRITERIA_GROUP_ID = (SELECT DEMAND_CRITERIA_GROUP_ID FROM FLM_SEQ_TASKS WHERE SEQ_TASK_ID = p_seq_task_id);

    l_debug_line := 60;
    DELETE FROM FLM_SEQ_TASKS
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 70;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO flm_delete_tasks;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'delete_tasks('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END delete_tasks;

  /*****************************************************************************************
   * To delete a task and its details in FLM_SEQ_* tables. After that it commits           *
   *****************************************************************************************/
  PROCEDURE delete_tasks_commit(p_seq_task_id IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_delete_tasks_commit;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_line := 10;
    delete_tasks(p_seq_task_id,'F', x_return_status, x_msg_count, x_msg_data);
    l_debug_line := 20;

    commit;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO flm_delete_tasks_commit;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'delete_tasks_commit('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END delete_tasks_commit;







  /******************************************************************
   * To calculate available capacity of a given line for a given    *
   * period of time (p_start_date, p_end_date) inclusively;         *
   * the line is represented by (start, stop, hourly_rate)          *
   ******************************************************************/
  /*fix bug#3827600
    For counting the number of days in between, CALENDAR timezone is used
    while for couting the exclude hours, CLIENT timezone is used.
    The justification of the use of CLIENT timezone is that
    the existing code has a lot of logic based on time range between 0 and 24.
  */
  PROCEDURE line_available_capacity(p_organization_id IN NUMBER,
                                   p_start_time IN NUMBER,
  				   p_stop_time IN NUMBER,
  				   p_hourly_rate IN NUMBER,
                                   p_start_date IN DATE,
                                   p_end_date IN DATE,
                                   p_init_msg_list IN VARCHAR2,
				   x_capacity OUT NOCOPY NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2
                                   )
  IS
    l_capacity NUMBER := 0;
    l_days NUMBER;
    l_start_date DATE;
    l_end_date DATE;

    l_start_day DATE;
    l_end_day DATE;

    l_start_time NUMBER;
    l_end_time NUMBER;

    l_start_exclude NUMBER;
    l_end_exclude NUMBER;
    l_working_hours NUMBER;

    l_debug_line NUMBER;

    l_temp_date DATE;  --fix bug#3170105

    --fix bug#3827600
    --Added new additional variables.
    l_in_start_time NUMBER;
    l_in_stop_time NUMBER;
    --end of fix bug#3827600

    FUNCTION get_excluded_hours(p_line_start IN NUMBER,
 			        p_line_stop IN NUMBER,
			        p_start IN NUMBER,
			        p_end IN NUMBER) RETURN NUMBER
    IS
      l_start NUMBER;
      l_end NUMBER;
      l_return NUMBER;
    BEGIN

      if (p_line_start < p_start) then
        l_start := p_start;
      else
 	l_start := p_line_start;
      end if;

      if (p_line_stop < p_end) then
	l_end := p_line_stop;
      else
	l_end := p_end;
      end if;

      l_return := l_end - l_start;

      if (l_return < 0) then
	l_return := 0;
      end if;

      return l_return;

    END get_excluded_hours;

  BEGIN
    SAVEPOINT flm_line_available_capacity;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --fix bug#3170105
    flm_timezone.init_timezone(p_organization_id);

    l_start_date := p_start_date;
    l_end_date := p_end_date;

    l_debug_line := 20;
    l_start_day := MRP_CALENDAR.NEXT_WORK_DAY(p_organization_id,
                   1,
                   flm_timezone.server_to_calendar(l_start_date));

    l_debug_line := 30;
    l_end_day := MRP_CALENDAR.PREV_WORK_DAY(p_organization_id,
                   1,
                   flm_timezone.server_to_calendar(l_end_date));

    if (l_start_day = flm_timezone.server_to_calendar(l_start_date)) then
      --fix bug#3872600: Modified to get time component in client timezone
      l_temp_date := flm_timezone.server_to_client(l_start_date);
      l_start_time := to_char(l_temp_date, 'SSSSS');
    else
      l_start_time := -1;
    end if;

    if (l_end_day = flm_timezone.server_to_calendar(l_end_date)) then
      --fix bug#3872600: Modified to get time component in client timezone
      l_temp_date := flm_timezone.server_to_client(l_end_date);
      l_end_time := to_char(l_temp_date, 'SSSSS');
     else
      l_end_time := -1;
    end if;

    l_debug_line := 40;
    if (l_end_day < l_start_day) then
      l_capacity := 0;
    else
      l_days := MRP_CALENDAR.DAYS_BETWEEN(p_organization_id,
					  1,
					  l_start_day,
					  l_end_day);
      l_days := l_days + 1;

      l_debug_line := 50;

      --fix bug#3872600: Modified to get client version of the passed start and end time
      l_temp_date := trunc(sysdate) + (p_start_time/86400);
      l_temp_date := flm_timezone.server_to_client(l_temp_date);
      l_in_start_time := to_char(l_temp_date, 'SSSSS');

      l_temp_date := trunc(sysdate) + (p_stop_time/86400);
      l_temp_date := flm_timezone.server_to_client(l_temp_date);
      l_in_stop_time := to_char(l_temp_date, 'SSSSS');

      l_debug_line := 60;
      l_working_hours := (l_in_stop_time - l_in_start_time)/3600;

      if l_working_hours <= 0 then
         l_working_hours := l_working_hours + 24;
      end if;

      if (l_start_time = -1) then
        l_start_exclude := 0;
      elsif (l_start_time = 0) then
        l_start_exclude := 0;
      else
	if (l_in_start_time < l_in_stop_time) then
	   l_start_exclude := get_excluded_hours(l_in_start_time/3600,
						 l_in_stop_time/3600,
						 0, l_start_time/3600);
	else
        /*fix bug#3838351
          In the case of line start > line stop,
          call the get_excluded_hours twice:
          1. for working hours: 0 to line_stop
          2. for working hours: line_start to 24
         */
	   l_start_exclude := get_excluded_hours(0,
						 l_in_stop_time/3600,
						 0, l_start_time/3600);

           l_start_exclude := l_start_exclude +
                              get_excluded_hours(l_in_start_time/3600,
						 24,
						 0, l_start_time/3600);
	end if;
      end if;

      if (l_end_time = -1) then
        l_end_exclude := 0;
      elsif (l_end_time = 0) then
        l_end_exclude := l_working_hours;
      else
      --fix bug#3838351: Same explanation as above.
	if (l_in_start_time < l_in_stop_time) then
	   l_end_exclude := get_excluded_hours(l_in_start_time/3600,
					       l_in_stop_time/3600,
					       l_end_time/3600, 24);
        else
	   l_end_exclude := get_excluded_hours(0,
					       l_in_stop_time/3600,
					       l_end_time/3600, 24);

           l_end_exclude := l_end_exclude +
                            get_excluded_hours(l_in_start_time/3600,
					       24,
					       l_end_time/3600, 24);
	end if;
      end if;
      --end of fix bug#3170105

      l_debug_line := 70;
      l_capacity := p_hourly_rate* (l_days * l_working_hours - l_start_exclude - l_end_exclude);

    end if;

    x_capacity := l_capacity;
    l_debug_line := 80;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_capacity := -1;
      ROLLBACK TO flm_line_available_capacity;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'flm_line_available_capacity('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

END line_available_capacity;


  /**********************************************************************************
   * To insert demand from MRP_UNSCHEDULED_ORDERS_V to FLM_SEQ_TASK_DEMANDS table.  *
   **********************************************************************************/
  PROCEDURE insert_demands(p_seq_task_id IN NUMBER,
                         p_max_rows IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_criteria_group_id NUMBER;
    l_alternate_routing_flag VARCHAR2(1);
    l_seq_task_type NUMBER;
    l_line_id NUMBER;
    l_org_id NUMBER;
    l_demand_start_date VARCHAR2(100);
    l_demand_end_date VARCHAR2(100);
    l_planning_flag VARCHAR2(1); --Added for bugfix:7305721

    l_where VARCHAR2(5000);
    l_filter VARCHAR2(4000);
    l_return_status VARCHAR2(30);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_cursor INTEGER;
    l_dummy INTEGER;
    l_cursor_insert VARCHAR2(5000);
    l_debug_line NUMBER;

    l_cursor_cnt VARCHAR2(1000);
    l_quantity NUMBER;
    l_count_rows NUMBER;

    CURSOR line_list IS
    SELECT LINE_ID
    FROM FLM_SEQ_TASK_LINES
    WHERE SEQ_TASK_ID = p_seq_task_id;
  BEGIN
    SAVEPOINT flm_insert_demands;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Added Planning Recomendation flag for bug fix:7305721
    SELECT NVL(DEMAND_CRITERIA_GROUP_ID,-1),NVL(ALTERNATE_ROUTING_FLAG,'N'),SEQ_TASK_TYPE, ORGANIZATION_ID,
           TO_CHAR(DEMAND_START_DATE,'DD-MON-RR HH24:MI:SS'), TO_CHAR(DEMAND_END_DATE,'DD-MON-RR HH24:MI:SS'),
           NVL(HONOR_PLANNING_FLAG,'N')
    INTO l_criteria_group_id,l_alternate_routing_flag,l_seq_task_type,l_org_id,
         l_demand_start_date,l_demand_end_date,l_planning_flag
    FROM FLM_SEQ_TASKS
    WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 20;
    IF l_seq_task_type = FLM_CONSTANTS.SEQ_TASK_RESEQ THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      return;
    END IF;

    l_debug_line := 30;
    FOR line_list_rec IN line_list LOOP
      l_line_id := line_list_rec.line_id;
      l_where := NULL;
      l_filter := NULL;
      l_cursor_insert := NULL;
      l_cursor_cnt := NULL;

      FLM_Util.init_bind;

      IF (l_seq_task_type = FLM_CONSTANTS.SEQ_TASK_SO AND l_alternate_routing_flag = 'N') THEN
        l_where := 'FROM FLM_SEQ_DEMAND_SALES_ORDERS_V MUOV WHERE '||
                   'MUOV.ALTERNATE_ROUTING_DESIGNATOR IS NULL AND ';
      ELSIF (l_seq_task_type = FLM_CONSTANTS.SEQ_TASK_SO AND l_alternate_routing_flag = 'Y') THEN
        l_where := 'FROM FLM_SEQ_DEMAND_SALES_ORDERS_V MUOV WHERE ';
      ELSE
        l_where := 'FROM FLM_SEQ_DEMAND_PLAN_ORDERS_V MUOV WHERE ';
         --Added for bugfix:7305721
         IF(l_alternate_routing_flag = 'N') THEN
          l_where := l_where || 'MUOV.ALTERNATE_ROUTING_DESIGNATOR IS NULL AND ';
         END IF;
         IF(l_planning_flag = 'Y') THEN
          l_where := l_where || 'MUOV.RECO_LINE_ID = MUOV.LINE_ID AND ';
         END IF;

      END IF;


      l_where := l_where || 'MUOV.LINE_ID = :l_line_id AND MUOV.ORGANIZATION_ID = :l_org_id AND ';
      l_where := l_where || 'MUOV.ORDER_DATE BETWEEN TO_DATE(:l_demand_start_date,' ||
                 '''DD-MON-RR HH24:MI:SS'') AND TO_DATE(:l_demand_end_date,' ||
                 '''DD-MON-RR HH24:MI:SS'')';
      l_where := l_where || ' AND MUOV.ORDER_QUANTITY > 0';

      l_debug_line := 40;
      flm_filter_criteria_process.get_filter_clause(l_criteria_group_id,'MUOV',NULL,l_filter,
                                                    l_return_status,l_msg_count,l_msg_data);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        return;
      END IF;
      IF l_filter IS NOT NULL THEN
        l_where := l_where || ' AND ' || l_filter;
      END IF;

      l_debug_line := 50;
      -- Count the rows and quantity
      l_cursor_cnt := 'SELECT COUNT(*), SUM(ORDER_QUANTITY) '||l_where;
      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, l_cursor_cnt, dbms_sql.v7);

      FLM_Util.add_bind(':l_line_id', l_line_id);
      FLM_Util.add_bind(':l_org_id', l_org_id);
      FLM_Util.add_bind(':l_demand_start_date', l_demand_start_date);
      FLM_Util.add_bind(':l_demand_end_date', l_demand_end_date);
      FLM_Util.do_binds(l_cursor);

      dbms_sql.define_column(l_cursor, 1, l_count_rows);
      dbms_sql.define_column(l_cursor, 2, l_quantity);
      l_debug_line := 55;
      l_dummy := dbms_sql.execute(l_cursor);
      IF (dbms_sql.fetch_rows(l_cursor) > 0) THEN
        dbms_sql.column_value(l_cursor,1, l_count_rows);
        dbms_sql.column_value(l_cursor,2, l_quantity);
      END IF;
      dbms_sql.close_cursor(l_cursor);

      IF (p_max_rows IS NOT NULL AND p_max_rows <> -1 AND l_count_rows > p_max_rows) THEN
        ROLLBACK TO flm_insert_demands;
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('FLM','FLM_SEQ_DEMAND_EXCEEDED');
          FND_MSG_PUB.Add;
        END IF;

        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);
        return;
      END IF;

      IF (p_max_rows IS NULL OR p_max_rows <> -1) THEN
        l_cursor_insert := 'INSERT INTO FLM_SEQ_TASK_DEMANDS (SEQ_TASK_ID,ALTERNATE_ROUTING_DESIGNATOR,LINE_ID,'||
                           'DEMAND_ID,SPLIT_NUMBER,OBJECT_VERSION_NUMBER,ORGANIZATION_ID,PRIMARY_ITEM_ID,'||
                           'OPEN_QTY,REQUESTED_QTY,FULFILLED_QTY,'||
                           'CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,'||
                           'LAST_UPDATE_DATE,LAST_UPDATED_BY,REQUEST_ID,PROGRAM_ID,PROGRAM_APPLICATION_ID,'||
                           'PROGRAM_UPDATE_DATE) ';

        l_cursor_insert := l_cursor_insert || 'SELECT :p_seq_task_id,MUOV.ALTERNATE_ROUTING_DESIGNATOR,'||
                           'MUOV.LINE_ID,MUOV.DEMAND_SOURCE_LINE,1,1,MUOV.ORGANIZATION_ID,'||
                           'MUOV.INVENTORY_ITEM_ID,MUOV.ORDER_QUANTITY,MUOV.ORDER_QUANTITY,0,'||
                           'fnd_global.user_id,sysdate,'||
                           'fnd_global.login_id,sysdate,fnd_global.user_id,fnd_global.conc_request_id,'||
                           'fnd_global.conc_program_id,fnd_global.prog_appl_id,sysdate ';

        l_cursor_insert := l_cursor_insert || l_where;

        l_debug_line := 60;
        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor, l_cursor_insert, dbms_sql.v7);

        FLM_Util.add_bind(':p_seq_task_id', p_seq_task_id);
        FLM_Util.do_binds(l_cursor);

        l_dummy := dbms_sql.execute(l_cursor);
        dbms_sql.close_cursor(l_cursor);
        l_debug_line := 70;

      END IF;

      G_DEMAND_QTY(l_line_id) := l_quantity;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_insert_demands;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'insert_demands('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END insert_demands;

  /*****************************************************
   * To get demand qty from G_DEMAND_QTY PL/SQL table. *
   *****************************************************/
  PROCEDURE get_demand_qty(p_line_id IN NUMBER,
                         p_init_msg_list IN VARCHAR2,
                         x_demand_qty OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_get_demand_qty;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_demand_qty := G_DEMAND_QTY(p_line_id);

    l_debug_line := 20;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_get_demand_qty;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'get_demand_qty('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END get_demand_qty;


  /*******************************************************
   * To delete demands from FLM_SEQ_TASK_DEMANDS table.  *
   *******************************************************/
  PROCEDURE delete_demands(p_seq_task_id IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_delete_demands;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM FLM_SEQ_TASK_DEMANDS WHERE SEQ_TASK_ID = p_seq_task_id;
    l_debug_line := 20;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_delete_demands;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'delete_demands('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END delete_demands;

  /*******************************************************
   * To delete criteria from FLM_FILTER_CRITERIA table.  *
   *******************************************************/
  PROCEDURE delete_criteria(p_seq_task_id IN NUMBER,
                           p_init_msg_list IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
    l_criteria_group_id NUMBER;
  BEGIN
    SAVEPOINT flm_delete_criteria;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_line := 20;
    SELECT NVL(DEMAND_CRITERIA_GROUP_ID,-1)
      INTO l_criteria_group_id
      FROM FLM_SEQ_TASKS
     WHERE SEQ_TASK_ID = p_seq_task_id;

    l_debug_line := 30;
    DELETE FROM FLM_FILTER_CRITERIA WHERE CRITERIA_GROUP_ID = l_criteria_group_id;

    l_debug_line := 40;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_delete_criteria;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'delete_criteria('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END delete_criteria;

  /***************************************************************************************
   * To insert lines from WIP_LINES into FLM_SEQ_TASK_LINES and all constraints on the   *
   * line default rule from FLM_SEQ_TASK_CONSTRAINTS into FLM_SEQ_TASK_CONSTRAINTS.      *
   ***************************************************************************************/
  PROCEDURE insert_line_constraints(p_seq_task_id IN NUMBER,
                                    p_line_id IN NUMBER,
                                    p_org_id IN NUMBER,
                                    p_init_msg_list IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_insert_line_constraints;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO FLM_SEQ_TASK_LINES (
      SEQ_TASK_ID,
      LINE_ID,
      OBJECT_VERSION_NUMBER,
      ORGANIZATION_ID,
      SEQ_DIRECTION,
      START_TIME,
      STOP_TIME,
      HOURLY_RATE,
      CONNECT_FLAG,
      FIX_SEQUENCE_TYPE,
      FIX_SEQUENCE_AMOUNT,
      COMBINE_SCHEDULE_FLAG,
      AVAILABLE_CAPACITY,
      RESEQUENCED_QTY,
      RULE_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE )
    SELECT
      p_seq_task_id,
      p_line_id,
      1,
      ORGANIZATION_ID,
      NVL(SEQ_DIRECTION,1),
      START_TIME,
      STOP_TIME,
      MAXIMUM_RATE,
      NVL(SEQ_CONNECT_FLAG,'N'),
      NVL(SEQ_FIX_SEQUENCE_TYPE,1),
      SEQ_FIX_SEQUENCE_AMOUNT,
      NVL(SEQ_COMBINE_SCHEDULE_FLAG,'N'),
      0,
      0,
      SEQ_DEFAULT_RULE_ID,
      fnd_global.user_id,
      sysdate,
      fnd_global.login_id,
      sysdate,
      fnd_global.user_id,
      NULL,
      NULL,
      NULL,
      NULL
    FROM WIP_LINES
    WHERE LINE_ID = p_line_id AND ORGANIZATION_ID = p_org_id;

    INSERT INTO FLM_SEQ_TASK_CONSTRAINTS (
      SEQ_TASK_ID,
      LINE_ID,
      PARENT_CONSTRAINT_NUMBER,
      CONSTRAINT_NUMBER,
      OBJECT_VERSION_NUMBER,
      ORGANIZATION_ID,
      PRIORITY,
      CONSTRAINT_TYPE,
      CONSTRAINT_TYPE_VALUE1,
      CONSTRAINT_TYPE_VALUE2,
      CONSTRAINT_TYPE_VALUE3,
      ATTRIBUTE_ID,
      ATTRIBUTE_VALUE1_NAME,
      ATTRIBUTE_VALUE2_NAME,
      ATTRIBUTE_VALUE1_NUM,
      ATTRIBUTE_VALUE2_NUM,
      ATTRIBUTE_VALUE1_DATE,
      ATTRIBUTE_VALUE2_DATE,
      FULFILLED_TO_QTY,
      VIOLATION_COUNT,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      REQUEST_ID,
      PROGRAM_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE )
    SELECT
      p_seq_task_id,
      p_line_id,
      C.PARENT_CONSTRAINT_NUMBER,
      C.CONSTRAINT_NUMBER,
      1,
      C.ORGANIZATION_ID,
      C.PRIORITY,
      C.CONSTRAINT_TYPE,
      C.CONSTRAINT_TYPE_VALUE1,
      C.CONSTRAINT_TYPE_VALUE2,
      C.CONSTRAINT_TYPE_VALUE3,
      C.ATTRIBUTE_ID,
      C.ATTRIBUTE_VALUE1_NAME,
      C.ATTRIBUTE_VALUE2_NAME,
      C.ATTRIBUTE_VALUE1_NUM,
      C.ATTRIBUTE_VALUE2_NUM,
      C.ATTRIBUTE_VALUE1_DATE,
      C.ATTRIBUTE_VALUE2_DATE,
      0,
      0,
      fnd_global.user_id,
      sysdate,
      fnd_global.login_id,
      sysdate,
      fnd_global.user_id,
      NULL,
      NULL,
      NULL,
      NULL
    FROM FLM_SEQ_RULE_CONSTRAINTS C, WIP_LINES L
    WHERE C.RULE_ID = L.SEQ_DEFAULT_RULE_ID
      AND L.LINE_ID = p_line_id
      AND L.ORGANIZATION_ID = p_org_id;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_insert_line_constraints;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'insert_line_constraints('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END insert_line_constraints;

  /*****************************************************************************************************
   * To delete lines from FLM_SEQ_TASK_LINES and line contraints from FLM_SEQ_TASK_CONSTRAINTS table.  *
   *****************************************************************************************************/
  PROCEDURE delete_line_constraints(p_seq_task_id IN NUMBER,
                                    p_init_msg_list IN VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_delete_line_constraints;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM FLM_SEQ_TASK_LINES WHERE SEQ_TASK_ID = p_seq_task_id;
    l_debug_line := 20;

    DELETE FROM FLM_SEQ_TASK_CONSTRAINTS WHERE SEQ_TASK_ID = p_seq_task_id;
    l_debug_line := 30;

  EXCEPTION

    WHEN OTHERS THEN
      ROLLBACK TO flm_delete_line_constraints;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'delete_line_constraints('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END delete_line_constraints;

  /******************************************************************
   * To get min wip_entity_id from WIP_FLOW_SCHEDULES PL/SQL table. *
   ******************************************************************/
  PROCEDURE get_min_wip_entity_id(p_start_date IN DATE,
                                  p_org_id IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  x_wip_entity_id OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
  BEGIN
    SAVEPOINT flm_get_min_wip_entity_id;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT min(wip_entity_id)
    INTO x_wip_entity_id
    FROM WIP_FLOW_SCHEDULES
    WHERE scheduled_completion_date >= flm_timezone.client00_in_server(p_start_date) --fix bug#3170105
      AND organization_id = p_org_id;

    l_debug_line := 20;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_get_min_wip_entity_id;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'get_min_wip_entity_id('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END get_min_wip_entity_id;

  /*********************************************************************
   * To clean up the raw UI data  			               *
   *********************************************************************/
  PROCEDURE data_cleanup( p_init_msg_list IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2)
  IS
    CURSOR l_task_cursor IS
    SELECT seq_task_id
    FROM FLM_SEQ_TASKS
    WHERE seq_request_id = -1
      AND creation_date < sysdate-2;

    l_debug_line NUMBER;
    l_return_status VARCHAR2(1000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
  BEGIN

    SAVEPOINT flm_data_cleanup;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_debug_line := 10;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR l_task_rec IN l_task_cursor LOOP
      delete_tasks(l_task_rec.seq_task_id, 'F', l_return_status, l_msg_count, l_msg_data);
    END LOOP;
    l_debug_line := 20;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO flm_data_cleanup;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_seq_ui' ,'data_cleanup('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END data_cleanup;

  /*****
   * Get the flag that indicates whether Flow Sequencing
   * is enabled, which is defined by the 'FLM_ENABLE_FLMSEQ'
   * profile.
   *****/
  FUNCTION Get_FlmSeq_Enabled_Flag RETURN VARCHAR2
  IS
    flmseq_enabled_prf_value VARCHAR2(1) := 'N';
  BEGIN
    flmseq_enabled_prf_value := fnd_profile.value('FLM_ENABLE_FLMSEQ');
    IF flmseq_enabled_prf_value = 'Y' THEN
      RETURN flmseq_enabled_prf_value;
    END IF;
    RETURN 'N';
  END Get_FlmSeq_Enabled_Flag;

  /*****
   * Determines whether Flow Sequencing is licensed. Flow Sequencing
   * is 'licensed' if:
   * (1) Flow Manufacturing installed; and
   * (2) Flow Sequencing is enabled.
   *****/
  FUNCTION Get_FlmSeq_Licensed RETURN VARCHAR2
  IS
    flm_licensed VARCHAR2(1) := 'N';
    flmseq_enabled_prf_value VARCHAR2(1) := 'N';
  BEGIN
    flm_licensed := flm_util.Get_Install_Status();
    flmseq_enabled_prf_value := flm_seq_ui.Get_FlmSeq_Enabled_Flag();

    IF flm_licensed = 'I' and flmseq_enabled_prf_value = 'Y'
    THEN
      RETURN 'Y';
    END IF;

    RETURN 'N';
  END Get_FlmSeq_Licensed;


END flm_seq_ui;

/
