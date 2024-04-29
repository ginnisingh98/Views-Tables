--------------------------------------------------------
--  DDL for Package Body WPS_CAPACITY_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WPS_CAPACITY_CHANGES_PKG" AS
/* $Header: WPSCAPCB.pls 115.4 2002/12/20 23:36:44 sjchen ship $ */


  /**
   * This procedure is used to delete a resource exception
   * This has a cascading effect, any attached instances will also be deleted
   */
  PROCEDURE Delete_Resource_Exception(X_Rowid VARCHAR2) is

  l_department_id  NUMBER;
  l_resource_id    NUMBER;
  l_shift_num      NUMBER;
  l_action_type    NUMBER;
  l_simulation_set VARCHAR2(10);
  l_from_date      DATE;
  l_instance_count NUMBER;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    SELECT DEPARTMENT_ID,RESOURCE_ID,SHIFT_NUM,FROM_DATE,
           SIMULATION_SET,ACTION_TYPE
    INTO l_department_id,l_resource_id,l_shift_num,l_from_date,
         l_simulation_set,l_action_type
    FROM BOM_RESOURCE_CHANGES
    WHERE ROWID = X_Rowid;

    SELECT COUNT(*) INTO l_instance_count
    FROM BOM_RES_INSTANCE_CHANGES
    WHERE DEPARTMENT_ID  = l_department_id AND
          RESOURCE_ID    = l_resource_id AND
          SHIFT_NUM      = l_shift_num AND
          FROM_DATE      = l_from_date AND
          SIMULATION_SET = l_simulation_set AND
          ACTION_TYPE    = l_action_type;

    if( l_instance_count <> 0 ) then
      DELETE FROM BOM_RES_INSTANCE_CHANGES
      WHERE  DEPARTMENT_ID  = l_department_id AND
             RESOURCE_ID    = l_resource_id AND
             SHIFT_NUM      = l_shift_num AND
             FROM_DATE      = l_from_date AND
             SIMULATION_SET = l_simulation_set AND
             ACTION_TYPE    = l_action_type;

    end if;

    DELETE FROM BOM_RESOURCE_CHANGES
    WHERE  rowid = X_Rowid;

    COMMIT;

  END Delete_Resource_Exception;


  /**
   * This procedure is used to delete a resource instance exception
   * deleting instance exception will decrease the
   * resource exception capacity units by 1
   * If capacity change reaches 0, the resource exception will also be deleted
   */

  PROCEDURE Delete_Resinst_Exception(X_Rowid VARCHAR2) is

  l_department_id  NUMBER;
  l_resource_id    NUMBER;
  l_shift_num      NUMBER;
  l_action_type    NUMBER;
  l_simulation_set VARCHAR2(10);
  l_from_date      DATE;
  l_to_date        DATE;
  l_capacity_units NUMBER;
  l_from_time      NUMBER;
  l_to_time        NUMBER;
  l_sch_instance   NUMBER;
  l_record_exists  NUMBER;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    SELECT DEPARTMENT_ID,RESOURCE_ID,SHIFT_NUM,FROM_DATE,TO_DATE,
           SIMULATION_SET,ACTION_TYPE,FROM_TIME,TO_TIME
    INTO   l_department_id,l_resource_id,l_shift_num,l_from_date,
           l_to_date,l_simulation_set,l_action_type,l_from_time,
           l_to_time
    FROM   BOM_RES_INSTANCE_CHANGES
    WHERE  ROWID = X_Rowid;

    --Get the schedule to instance flag for the department resource
    SELECT SCHEDULE_TO_INSTANCE
    INTO   l_sch_instance
    FROM   BOM_DEPARTMENT_RESOURCES
    WHERE  DEPARTMENT_ID = l_department_id AND
           RESOURCE_ID   = l_resource_id;

    --Schedule_to_instance: 1 means resource is scheduled to instance
    --Schedule_to_instance: 2 means resource is not scheduled to instance
    l_record_exists := 0;

    --Make the deletion at resource instance level consistent no matter
    --the resource is scheduled to instance or not

    --if(l_sch_instance = 1) then
      SELECT COUNT(*) INTO l_record_exists
      FROM   BOM_RESOURCE_CHANGES
      WHERE  DEPARTMENT_ID        = l_department_id AND
             RESOURCE_ID          = l_resource_id AND
             SHIFT_NUM            = l_shift_num AND
             FROM_DATE            = l_from_date AND
             NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
             NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
             NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
             SIMULATION_SET       = l_simulation_set AND
             ACTION_TYPE          = l_action_type;
    --end if;

    if (l_record_exists <> 0) then
        SELECT CAPACITY_CHANGE INTO l_capacity_units
        FROM   BOM_RESOURCE_CHANGES
        WHERE  DEPARTMENT_ID        = l_department_id AND
               RESOURCE_ID          = l_resource_id AND
               SHIFT_NUM            = l_shift_num AND
               FROM_DATE            = l_from_date AND
               NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
               NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
               NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
               SIMULATION_SET       = l_simulation_set AND
               ACTION_TYPE          = l_action_type;

        if( (l_capacity_units > 1) OR (l_capacity_units < -1) ) then
          if(l_capacity_units > 1 ) then
            l_capacity_units := l_capacity_units -1;
          elsif (l_capacity_units < 1) then
            l_capacity_units := l_capacity_units - (-1);
          end if;

          UPDATE BOM_RESOURCE_CHANGES
          SET    CAPACITY_CHANGE = l_capacity_units
          WHERE  DEPARTMENT_ID        = l_department_id AND
                 RESOURCE_ID          = l_resource_id AND
                 SHIFT_NUM            = l_shift_num AND
                 FROM_DATE            = l_from_date AND
                 NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
                 NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
                 NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
                 SIMULATION_SET       = l_simulation_set AND
                 ACTION_TYPE          = l_action_type;

        elsif( (l_capacity_units = 1) OR (l_capacity_units = -1)) then
          DELETE FROM BOM_RESOURCE_CHANGES
          WHERE  DEPARTMENT_ID        = l_department_id AND
                 RESOURCE_ID          = l_resource_id AND
                 SHIFT_NUM            = l_shift_num AND
                 FROM_DATE            = l_from_date AND
                 NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
                 NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
                 NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
                 SIMULATION_SET       = l_simulation_set AND
                 ACTION_TYPE          = l_action_type;
        end if;
    end if;

    DELETE FROM BOM_RES_INSTANCE_CHANGES
    WHERE  rowid = X_Rowid;

    COMMIT;

  END Delete_Resinst_Exception;


  /**
   * This procedure is used to update a resource exception
   * updating a resource exception would update all the attached
   * instances too
   */

  PROCEDURE Update_Resource_Exception(X_Rowid     VARCHAR2,
                                      X_Shift     NUMBER,
                                      X_Action    NUMBER,
                                      X_Units     NUMBER,
                                      X_From_Date DATE,
                                      X_To_Date   DATE,
                                      X_From_Time NUMBER,
                                      X_To_Time   NUMBER,
                                      X_User_Id   NUMBER,
				      X_REASON_CODE VARCHAR2 DEFAULT NULL) is


  l_rowid       VARCHAR2(30);
  l_shift_num   NUMBER;
  l_action_type NUMBER;
  l_units       NUMBER;
  l_from_date   DATE;
  l_to_date     DATE;
  l_from_time   NUMBER;
  l_to_time     NUMBER;
  l_user_id     NUMBER;

  t_resource_id    NUMBER;
  t_department_id  NUMBER;
  t_simulation_set VARCHAR2(10);
  t_shift_num      NUMBER;
  t_action_type    NUMBER;
  t_units          NUMBER;
  t_from_date      DATE;
  t_to_date        DATE;
  t_from_time      NUMBER;
  t_to_time        NUMBER;


  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    l_rowid       := X_Rowid;
    l_shift_num   := X_Shift;
    l_action_type := X_Action;
    l_units       := X_Units;
    l_from_date   := X_From_Date;
    l_to_date     := X_To_Date;
    l_from_time   := X_From_Time;
    l_to_time     := X_To_Time;
    l_user_id     := X_User_Id;

    if (l_action_type = 0) then
     l_action_type := 2;
    end if;

    SELECT
      RESOURCE_ID, DEPARTMENT_ID, SIMULATION_SET, SHIFT_NUM,
      ACTION_TYPE, CAPACITY_CHANGE, FROM_DATE,
      TO_DATE, FROM_TIME, TO_TIME
    INTO
      t_resource_id, t_department_id, t_simulation_set, t_shift_num,
      t_action_type, t_units, t_from_date,
      t_to_date, t_from_time, t_to_time
    FROM BOM_RESOURCE_CHANGES
    WHERE ROWID = l_rowid;


    UPDATE BOM_RESOURCE_CHANGES
    SET
      SHIFT_NUM        = l_shift_num,
      ACTION_TYPE      = l_action_type,
      CAPACITY_CHANGE  = l_units,
      FROM_DATE        = l_from_date,
      TO_DATE          = l_to_date,
      FROM_TIME        = l_from_time,
      TO_TIME          = l_to_time,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY  = l_user_id,
      reason_code      = x_reason_code
    WHERE ROWID = l_rowid;


    UPDATE BOM_RES_INSTANCE_CHANGES
    SET
      FROM_DATE        = l_from_date,
      TO_DATE          = l_to_date,
      FROM_TIME        = l_from_time,
      TO_TIME          = l_to_time,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY  = l_user_id
    WHERE
      RESOURCE_ID          = t_resource_id AND
      DEPARTMENT_ID        = t_department_id AND
      SIMULATION_SET       = t_simulation_set AND
      SHIFT_NUM            = t_shift_num AND
      ACTION_TYPE          = t_action_type AND
      FROM_DATE            = t_from_date AND
      NVL(TO_DATE,SYSDATE) = NVL(t_to_date,SYSDATE) AND
      NVL(FROM_TIME,0)     = NVL(t_from_time,0) AND
      NVL(TO_TIME,0)       = NVL(t_to_time,0);

    COMMIT;

  END Update_Resource_Exception;

  /**
   * This procedure is used to insert a resource exception
   */
  PROCEDURE Insert_Resource_Exception(X_Resource_Id   NUMBER,
                                      X_Department_Id NUMBER,
                                      X_Shift         NUMBER,
                                      X_Action        NUMBER,
                                      X_Units         NUMBER,
                                      X_From_Date     DATE,
                                      X_To_Date       DATE,
                                      X_From_Time     NUMBER,
                                      X_To_Time       NUMBER,
                                      X_Sim_Set       VARCHAR2,
                                      X_User_Id       NUMBER,
				      X_REASON_CODE   VARCHAR2 DEFAULT NULL) is
  l_resource_id   NUMBER;
  l_department_id NUMBER;
  l_shift_num     NUMBER;
  l_action_type   NUMBER;
  l_units         NUMBER;
  l_from_date     DATE;
  l_to_date       DATE;
  l_from_time     NUMBER;
  l_to_time       NUMBER;
  l_sim_set       VARCHAR2(10);
  l_record_count  NUMBER;
  l_user_id       NUMBER;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    l_resource_id   := X_Resource_Id;
    l_department_id := X_Department_Id;
    l_shift_num     := X_Shift;
    l_action_type   := X_Action;
    l_units         := X_Units;
    l_from_date     := X_From_Date;
    l_to_date       := X_To_Date;
    l_from_time     := X_From_Time;
    l_to_time       := X_To_Time;
    l_sim_set       := X_Sim_Set;
    l_user_id       := X_User_Id;
    l_record_count  := 0;

    if(l_action_type = 0) then
      l_action_type := 2;
    end if;

    SELECT COUNT(*) INTO l_record_count
    FROM   BOM_RESOURCE_CHANGES
    WHERE  DEPARTMENT_ID        = l_department_id AND
           RESOURCE_ID          = l_resource_id AND
           SHIFT_NUM            = l_shift_num AND
           FROM_DATE            = l_from_date AND
           NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
           NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
           NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
           SIMULATION_SET       = l_sim_set AND
           ACTION_TYPE          = l_action_type;

    if (l_record_count = 0) then

      INSERT INTO BOM_RESOURCE_CHANGES (
        DEPARTMENT_ID, RESOURCE_ID, SHIFT_NUM, ACTION_TYPE,
        CAPACITY_CHANGE, FROM_DATE, TO_DATE, FROM_TIME,
        TO_TIME, SIMULATION_SET, LAST_UPDATE_DATE,
        LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, REASON_CODE)
      VALUES
        (l_department_id, l_resource_id, l_shift_num, l_action_type,
         l_units, l_from_date, l_to_date, l_from_time,
         l_to_time,l_sim_set, sysdate,
         l_user_id, sysdate, l_user_id, X_REASON_CODE);
    else
      UPDATE BOM_RESOURCE_CHANGES
      SET    CAPACITY_CHANGE = CAPACITY_CHANGE + l_units,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = l_user_id
      WHERE  DEPARTMENT_ID        = l_department_id AND
             RESOURCE_ID          = l_resource_id AND
             SHIFT_NUM            = l_shift_num AND
             FROM_DATE            = l_from_date AND
             NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
             NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
             NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
             SIMULATION_SET       = l_sim_set AND
             ACTION_TYPE          = l_action_type;
    end if;

    COMMIT;


  END Insert_Resource_Exception;

  /**
   * This procedure is used to insert a resource instance exception
   * Units will always be entered as 1 or -1 in the table
   */

  PROCEDURE Insert_ResInst_Exception(X_Resource_Id    NUMBER,
                                      X_Department_Id NUMBER,
                                      X_Shift         NUMBER,
                                      X_Action        NUMBER,
                                      X_Units         NUMBER,
                                      X_From_Date     DATE,
                                      X_To_Date       DATE,
                                      X_From_Time     NUMBER,
                                      X_To_Time       NUMBER,
                                      X_Instance_Id   NUMBER,
                                      X_Serial_Num    VARCHAR2,
                                      X_Sim_Set       VARCHAR2,
				      X_User_Id       NUMBER,
				      X_REASON_CODE   VARCHAR2 DEFAULT NULL) is


  l_resource_id   NUMBER;
  l_department_id NUMBER;
  l_shift_num     NUMBER;
  l_action_type   NUMBER;
  l_units         NUMBER;
  l_from_date     DATE;
  l_to_date       DATE;
  l_from_time     NUMBER;
  l_to_time       NUMBER;
  l_instance_id   NUMBER;
  l_serial_num    VARCHAR2(30);
  l_sim_set       VARCHAR2(10);
  l_user_id       NUMBER;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    l_resource_id   := X_Resource_Id;
    l_department_id := X_Department_Id;
    l_shift_num     := X_Shift;
    l_action_type   := X_Action;
    l_units         := X_Units;
    l_from_date     := X_From_Date;
    l_to_date       := X_To_Date;
    l_from_time     := X_From_Time;
    l_to_time       := X_To_Time;
    l_instance_id   := X_instance_Id;
    l_serial_num    := X_Serial_Num;
    l_sim_set       := X_Sim_Set;
    l_user_id       := X_User_Id;

    if(l_action_type = 0) then
      l_action_type := 2;
    end if;

    INSERT INTO BOM_RES_INSTANCE_CHANGES (
      DEPARTMENT_ID, RESOURCE_ID, SHIFT_NUM, ACTION_TYPE,
      CAPACITY_CHANGE, FROM_DATE, TO_DATE, FROM_TIME,
      TO_TIME, SIMULATION_SET, INSTANCE_ID, SERIAL_NUMBER,
      LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
      CREATED_BY, REASON_CODE)
    VALUES
      (l_department_id, l_resource_id, l_shift_num, l_action_type,
       l_units, l_from_date, l_to_date, l_from_time,
       l_to_time, l_sim_set, l_instance_id, l_serial_num,
       sysdate, l_user_id, sysdate, l_user_id, x_reason_code);

    COMMIT;


  END Insert_ResInst_Exception;


  /**
   * This procedure is used to update a resource instance exception
   */

  PROCEDURE Update_ResInst_Exception (X_Rowid       VARCHAR2,
                                      X_Shift       NUMBER,
                                      X_Action      NUMBER,
                                      X_Units       NUMBER,
                                      X_From_Date   DATE,
                                      X_To_Date     DATE,
                                      X_From_Time   NUMBER,
                                      X_To_Time     NUMBER,
                                      X_Instance_Id NUMBER,
                                      X_Serial_Num  VARCHAR2,
                                      X_User_Id     NUMBER,
				      X_REASON_CODE VARCHAR2 DEFAULT NULL) is

  l_rowid       VARCHAR2(30);
  l_shift_num   NUMBER;
  l_action_type NUMBER;
  l_units       NUMBER;
  l_from_date   DATE;
  l_to_date     DATE;
  l_from_time   NUMBER;
  l_to_time     NUMBER;
  l_instance_id NUMBER;
  l_serial_num  VARCHAR2(30);
  l_user_id     NUMBER;

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    l_rowid       := X_Rowid;
    l_shift_num   := X_Shift;
    l_action_type := X_Action;
    l_units       := X_Units;
    l_from_date   := X_From_Date;
    l_to_date     := X_To_Date;
    l_from_time   := X_From_Time;
    l_to_time     := X_To_Time;
    l_instance_id := X_Instance_Id;
    l_serial_num  := X_Serial_Num;
    l_user_id     := X_User_Id;

    if (l_action_type = 0) then
     l_action_type := 2;
    end if;

    UPDATE BOM_RES_INSTANCE_CHANGES
    SET
      SHIFT_NUM        = l_shift_num,
      ACTION_TYPE      = l_action_type,
      CAPACITY_CHANGE  = l_units,
      FROM_DATE        = l_from_date,
      TO_DATE          = l_to_date,
      FROM_TIME        = l_from_time,
      TO_TIME          = l_to_time,
      LAST_UPDATED_BY  = l_user_id,
      LAST_UPDATE_DATE = sysdate,
      REASON_CODE      = x_reason_code
    WHERE ROWID = l_rowid;
    COMMIT;

  END Update_ResInst_Exception;


  /**
   * This procedure is used to check whether insertion of
   * instance exception will max out the assigned units of
   * resource exception. This only make sense for
   * for the case of resource which is scheduled to instance
   */

  PROCEDURE CheckResInstForInsert(X_Resource_Id   NUMBER,
                                  X_Department_Id NUMBER,
                                  X_Sim_Set       VARCHAR2,
                                  X_Shift         NUMBER,
                                  X_Action        NUMBER,
                                  X_Units         NUMBER,
                                  X_From_Date     DATE,
                                  X_To_Date       DATE,
                                  X_From_Time     NUMBER,
                                  X_To_Time       NUMBER,
                                  X_Return_Id OUT NOCOPY NUMBER) is


  l_resource_id   NUMBER;
  l_department_id NUMBER;
  l_sim_set       VARCHAR2(10);
  l_shift_num     NUMBER;
  l_action_type   NUMBER;
  l_units         NUMBER;
  l_from_date     DATE;
  l_to_date       DATE;
  l_from_time     NUMBER;
  l_to_time       NUMBER;
  l_max_units     NUMBER;
  l_current_units NUMBER;
  l_return_id     NUMBER;
  l_record_count  NUMBER;

  BEGIN

    l_resource_id   := X_Resource_Id;
    l_department_id := X_Department_Id;
    l_sim_set       := X_Sim_Set;
    l_shift_num     := X_Shift;
    l_action_type   := X_Action;
    l_units         := X_Units;
    l_from_date     := X_From_Date;
    l_to_date       := X_To_Date;
    l_from_time     := X_From_Time;
    l_to_time       := X_To_Time;
    l_current_units := 999999;
    l_return_id     := 0;
    l_record_count  := 0;

    if (l_action_type = 0) then
     l_action_type := 2;
    end if;

    SELECT CAPACITY_UNITS INTO l_max_units
    FROM   BOM_DEPARTMENT_RESOURCES
    WHERE  RESOURCE_ID   = l_resource_id and
           DEPARTMENT_ID = l_department_id;

    SELECT COUNT(*) INTO l_record_count
    FROM   BOM_RESOURCE_CHANGES
    WHERE  DEPARTMENT_ID        = l_department_id AND
           RESOURCE_ID          = l_resource_id AND
           SHIFT_NUM            = l_shift_num AND
           FROM_DATE            = l_from_date AND
           NVL(TO_DATE,SYSDATE) = NVL(l_to_date,SYSDATE) AND
           NVL(FROM_TIME,0)     = NVL(l_from_time,0) AND
           NVL(TO_TIME,0)       = NVL(l_to_time,0) AND
           SIMULATION_SET       = l_sim_set AND
           ACTION_TYPE          = l_action_type;


    if(l_record_count <> 0) then
      SELECT nvl(CAPACITY_CHANGE,999999) into l_current_units
      FROM   BOM_RESOURCE_CHANGES
      WHERE  DEPARTMENT_ID        = l_department_id AND
             RESOURCE_ID          = l_resource_id AND
             SHIFT_NUM            = l_shift_num AND
             SIMULATION_SET       = l_sim_set AND
             ACTION_TYPE          = l_action_type AND
             FROM_DATE            = l_from_date AND
             nvl(TO_DATE,sysdate) = nvl(l_to_date,sysdate) AND
             nvl(FROM_TIME,0)     = nvl(l_from_time,0) AND
             nvl(TO_TIME,0)       = nvl(l_to_time,0);

    end if;

    if(l_current_units <> 999999) then
      if (l_current_units + 1 > l_max_units) then
        l_return_id := 1;
      end if;
    end if;

    X_Return_Id := l_return_id;

  END CheckResInstForInsert;



END WPS_CAPACITY_CHANGES_PKG;

/
