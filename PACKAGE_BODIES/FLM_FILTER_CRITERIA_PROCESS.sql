--------------------------------------------------------
--  DDL for Package Body FLM_FILTER_CRITERIA_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_FILTER_CRITERIA_PROCESS" AS
/* $Header: FLMFLCRB.pls 115.3 2003/05/02 00:31:51 hwenas noship $ */

  /* Function to return the column name for the criteria. */
  FUNCTION get_filter_column (p_criteria_group_type NUMBER, p_criteria_type NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (p_criteria_group_type = FLM_CONSTANTS.CRITERIA_GROUP_SEQ_DEMAND) THEN
      IF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ASSEMBLY) THEN
        return ('ITEM_NUMBER');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_CUST) THEN
        return ('CUSTOMER_NAME');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_CUST_SITE) THEN
        return ('SHIP_TO_ADDRESS');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_DEMAND_CLASS) THEN
        return ('DEMAND_CLASS');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ORDER_DATE) THEN
        return ('ORDER_DATE');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ORDER_LINE) THEN
        return ('SO_LINE_NUMBER');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ORDER_NUM) THEN
        return ('ORDER_NUMBER');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ORDER_PTY) THEN
        return ('ORDER_PRIORITY');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_ORDER_QTY) THEN
        return ('ORIGINAL_ORDER_QUANTITY');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_PLAN_NAME) THEN
        return ('PLAN_NAME');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_PROJECT) THEN
        return ('PROJECT_NAME');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_TASK) THEN
        return ('TASK_NAME');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_SHIP_NUM) THEN
        return ('SHIPMENT_NUMBER');
      ELSIF (p_criteria_type = FLM_CONSTANTS.CRITERIA_UNSCH_QTY) THEN
        return ('ORDER_QUANTITY');
      END IF;
    END IF;
  END get_filter_column;

  /* Procedure to construct the where clause of the FLM filter criteria.
     The data is obtained from FLM_FILTER_CRITERIA table. */
  PROCEDURE get_filter_clause (p_criteria_group_id IN NUMBER,
                               p_table_alias IN VARCHAR2,
                               p_init_msg_list IN VARCHAR2,
                               x_filter OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2)
  IS
    l_debug_line NUMBER;
    l_filter VARCHAR2(5000);
    l_prev_criteria_operation NUMBER := -1;
    l_prev_criteria_num NUMBER := -1;
    l_counter NUMBER := 1;

    CURSOR criteria_list (p_criteria_group_id NUMBER) IS
    SELECT CRITERIA_GROUP_TYPE,CRITERIA_NUM,CRITERIA_TYPE,CRITERIA_OPERATION,CRITERIA_VALUE_TYPE,
           CRITERIA_VALUE_NAME,CRITERIA_VALUE_NUM,CRITERIA_VALUE_DATE
    FROM   flm_filter_criteria
    WHERE  CRITERIA_GROUP_ID = p_criteria_group_id
    ORDER BY CRITERIA_NUM, CRITERIA_OPERATION;

  BEGIN
    SAVEPOINT flm_get_filter_clause;
    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_line := 10;
    FOR criteria_list_rec IN criteria_list(p_criteria_group_id) LOOP

      l_debug_line := 20;
      /* Check if this the new operation to be constructed */
      IF l_prev_criteria_num <> criteria_list_rec.criteria_num THEN
        IF l_prev_criteria_num <> -1 THEN
          /*Connecting with the previous operation*/
          IF l_prev_criteria_operation = FLM_CONSTANTS.OP_LESS_THAN_EQ THEN
            l_filter := l_filter || ' AND ';
          ELSIF l_prev_criteria_operation = FLM_CONSTANTS.OP_EQUALS THEN
            l_filter := l_filter || ' AND ';
          END IF;
        END IF;

        /*Opening of the current operation */
        IF criteria_list_rec.criteria_operation = FLM_CONSTANTS.OP_GREATER_THAN_EQ THEN
          l_filter := l_filter ||  p_table_alias || '.' ||
          get_filter_column(criteria_list_rec.criteria_group_type,criteria_list_rec.criteria_type) || ' BETWEEN ';
        ELSIF criteria_list_rec.criteria_operation = FLM_CONSTANTS.OP_EQUALS THEN
          l_filter := l_filter ||  p_table_alias || '.' ||
          get_filter_column(criteria_list_rec.criteria_group_type,criteria_list_rec.criteria_type);
          IF criteria_list_rec.criteria_value_type = FLM_CONSTANTS.VALUE_STRING THEN
            l_filter := l_filter || ' LIKE ';
          ELSE
            l_filter := l_filter || ' = ';
          END IF;
        ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          return;
        END IF;
      ELSE
        /*Connecting within an operation*/
        IF criteria_list_rec.criteria_operation = FLM_CONSTANTS.OP_LESS_THAN_EQ THEN
          l_filter := l_filter || ' AND ';
        ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          return;
        END IF;
      END IF;

      l_debug_line := 30;
      /*Getting the values for the current operation*/
      IF criteria_list_rec.criteria_value_type = FLM_CONSTANTS.VALUE_STRING THEN
        l_filter := l_filter || ':filter_'|| l_counter;
        FLM_Util.add_bind(':filter_'|| l_counter,
                                        criteria_list_rec.criteria_value_name);

      ELSIF criteria_list_rec.criteria_value_type = FLM_CONSTANTS.VALUE_NUM THEN
        l_filter := l_filter || ':filter_'|| l_counter;
        FLM_Util.add_bind(':filter_'|| l_counter,
                                        criteria_list_rec.criteria_value_num);

      ELSIF criteria_list_rec.criteria_value_type = FLM_CONSTANTS.VALUE_DATE THEN
        l_filter := l_filter || 'TO_DATE(:filter_'|| l_counter ||
                    ',''DD-MON-RR HH24:MI:SS'')';
        FLM_Util.add_bind(':filter_'|| l_counter,
          to_char(criteria_list_rec.criteria_value_date, 'DD-MON-RR HH24:MI:SS'));

      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return;
      END IF;

      l_debug_line := 40;
      l_prev_criteria_operation := criteria_list_rec.criteria_operation;
      l_prev_criteria_num := criteria_list_rec.criteria_num;
      l_counter := l_counter + 1;
    END LOOP;

    x_filter := l_filter;
    l_debug_line := 50;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO flm_get_filter_clause;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('flm_filter_criteria_process' ,'get_filter_clause('||l_debug_line||')');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

  END get_filter_clause;


END flm_filter_criteria_process;

/
