--------------------------------------------------------
--  DDL for Package Body TASK_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."TASK_MGR" AS
/* $Header: JTFATSKB.pls 120.2 2005/10/31 05:26:24 snellepa ship $ */

  PROCEDURE create_task(API_VERSION             IN  NUMBER,
                        TASK_NAME               IN  VARCHAR2,
                        TASK_TYPE_ID            IN  NUMBER,
                        TASK_STATUS_ID          IN  NUMBER,
                        OWNER_TYPE_CODE         IN  VARCHAR2,
                        OWNER_ID                IN  NUMBER,
                        SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
                        PARTY_ID                IN  NUMBER,
                        X_MSG_DATA              OUT NOCOPY VARCHAR2,
                        X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
                        X_MSG_COUNT             OUT NOCOPY NUMBER)
  IS
    x            NUMBER;
    l_msg_count  NUMBER;
    l_msg_data   VARCHAR2(2000);


    -- NOTE-related variables...
    COMMENTS                 VARCHAR2(2000) := 'Initial Note';
--    l_return_status          VARCHAR2(30);
    l_note_id                NUMBER;
    l_notes                  VARCHAR2(4000) := 'Initial Note';
    l_notes_detail           VARCHAR2(32000) ;
    l_owner_id               NUMBER := 0;
    l_status_fail            EXCEPTION;
    l_msg_index              number;

  BEGIN

--insert into mytemp2 values(API_VERSION, TASK_NAME, TASK_TYPE_ID,
--TASK_STATUS_ID, OWNER_TYPE_CODE, OWNER_ID, SOURCE_OBJECT_TYPE_CODE,
--PARTY_ID);

    SELECT RESOURCE_ID
    INTO   l_owner_id
    FROM   JTF_RS_RESOURCE_EXTNS
    WHERE  CATEGORY = 'EMPLOYEE'
    AND    ROWNUM = 1;

--    DBMS_OUTPUT.PUT_LINE('OWNER_ID = '|| l_owner_id);

    JTF_TASKS_PUB.CREATE_TASK
    (
      P_API_VERSION               =>   1.0,
      P_INIT_MSG_LIST             =>   FND_API.G_TRUE,
      P_COMMIT                    =>   FND_API.G_FALSE,
      P_TASK_NAME                 =>  'Creation Of Approval Request',
      P_TASK_TYPE_NAME            =>   null,
      P_TASK_TYPE_ID              =>   1,
      P_DESCRIPTION               =>   NULL,
      P_TASK_STATUS_NAME          =>   NULL,
      P_TASK_STATUS_ID            =>   10,
      P_TASK_PRIORITY_NAME        =>   NULL,
      P_TASK_PRIORITY_ID          =>   4,
      P_OWNER_TYPE_CODE           =>   'RS_EMPLOYEE',
      P_OWNER_ID                  =>   l_owner_id,
      P_ASSIGNED_BY_NAME          =>   NULL,
      P_ASSIGNED_BY_ID            =>   NULL,
      P_CUSTOMER_NUMBER           =>   NULL,
      P_CUSTOMER_ID               =>   PARTY_ID,
      P_SOURCE_OBJECT_TYPE_CODE   =>  'ISUPPORT',
      P_SOURCE_OBJECT_ID          =>   PARTY_ID,
      P_SOURCE_OBJECT_NAME        =>   PARTY_ID,
      X_RETURN_STATUS             =>   x_return_status,
      X_MSG_COUNT                 =>   x_msg_count,
      X_MSG_DATA                  =>   x_msg_data ,
      X_TASK_ID                   =>   x
    );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_status_fail;
    END IF;

--    l_msg_data := FND_MSG_PUB.GET(1, 'F');

 --DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
 --DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
 --DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);
 --DBMS_OUTPUT.PUT_LINE('TASK_ID = '      ||x);

--DBMS_OUTPUT.PUT_LINE('Creating a note...');

    JTF_NOTES_PUB.CREATE_NOTE
    (
      p_parent_note_id         => NULL,
      p_api_version            => 1,
      p_init_msg_list          => NULL,
      p_commit                 => FND_API.G_FALSE,
      p_validation_level       => 0,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      x_jtf_note_id            => l_note_id,
      p_org_id                 => NULL,
      p_source_object_id       => x,
      p_source_object_code     => 'TASK',
      p_notes                  => l_notes,
      --  p_notes_detail           => COMMENTS,
      p_note_status            => 'I',
      p_entered_by             => FND_GLOBAL.USER_ID,
      p_entered_date           => SYSDATE,
      p_last_update_date       => SYSDATE,
      p_last_updated_by        => FND_GLOBAL.USER_ID,
      p_creation_date          => SYSDATE,
      p_created_by             => FND_GLOBAL.USER_ID
    );

--dbms_output.put_line('Api completed '||l_return_status||l_note_id);

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
      RAISE l_status_fail;
    END IF;

    COMMIT;

  EXCEPTION
    when l_status_fail then
      l_msg_index := 1;
      x_msg_data := ' ';
      l_msg_count := x_msg_count;

      while l_msg_count > 0 loop
	l_msg_data := fnd_msg_pub.get(l_msg_index, fnd_api.g_false);
	x_msg_data := concat(x_msg_data, l_msg_data);
	x_msg_data := concat(x_msg_data, '###');
	l_msg_index := l_msg_index + 1;
	l_msg_count := l_msg_count - 1;
      end loop;
  END create_task;


  FUNCTION query_task(API_VERSION    IN NUMBER    DEFAULT 1.0,
                      START_POINTER  IN NUMBER    DEFAULT 1,
                      REC_WANTED     IN NUMBER    DEFAULT 1,
                      TASK_STATUS_ID IN NUMBER    DEFAULT 10,
                      SHOW_ALL       IN VARCHAR2  DEFAULT 'YES',
                      SORT_ORDER     IN VARCHAR2  DEFAULT 'sortByAscendingDate')
  RETURN CLOB IS

     l_task_table              JTF_TASKS_PUB.TASK_TABLE_TYPE;
     l_total_retrieved         NUMBER;
     l_total_returned          NUMBER;
     l_rs                      VARCHAR2(1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);
     l_version_num             NUMBER;

     l_sort_data               JTF_TASKS_PUB.SORT_DATA;

     recurs                    JTF_TASKS_PUB.TASK_RECUR_REC;
     rsc                       JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
     asn                       JTF_TASKS_PUB.TASK_ASSIGN_TBL;
     notes                     JTF_TASKS_PUB.TASK_NOTES_TBL;

     v_first                   INTEGER;
     v_index                   INTEGER;

     row_length INTEGER := 0;
     query_clob CLOB;

     result                    VARCHAR2(4000) := '';
     user0                     VARCHAR2(4000) := '';
     user1                     VARCHAR2(4000) := '';
     user2                     VARCHAR2(4000) := '';
     user3                     VARCHAR2(4000) := '';
     user4                     VARCHAR2(4000) := '';
     user5                     VARCHAR2(4000) := '';
     user6                     VARCHAR2(4000) := '';
     user7                     VARCHAR2(4000) := '';


  BEGIN


     IF( SORT_ORDER = 'sortByAscendingDate' ) THEN
       l_sort_data(1).field_name   := 'task_id';
       l_sort_data(1).asc_dsc_flag := 'A';
       l_sort_data(2).field_name   := 'task_name';
       l_sort_data(2).asc_dsc_flag := 'D';
     ELSIF( SORT_ORDER = 'sortByDescendingDate' ) THEN
       l_sort_data(1).field_name   := 'task_id';
       l_sort_data(1).asc_dsc_flag := 'D';
       l_sort_data(2).field_name   := 'task_name';
       l_sort_data(2).asc_dsc_flag := 'D';
     ELSIF( SORT_ORDER = 'sortByCompany' ) THEN
       l_sort_data(1).field_name   := 'task_id';
       l_sort_data(1).asc_dsc_flag := 'A';
       l_sort_data(2).field_name   := 'task_name';
       l_sort_data(2).asc_dsc_flag := 'D';
     END IF;


     JTF_TASKS_PUB.query_task(
        P_API_VERSION              =>   1.0,
        P_START_POINTER            =>   1,
        P_REC_WANTED               =>   10,
        P_SHOW_ALL                 =>   'Y',
        P_QUERY_OR_NEXT_CODE       =>   'Q',
        P_OBJECT_TYPE_CODE         =>  'ISUPPORT',
        P_TASK_STATUS_ID           =>   TASK_STATUS_ID,
        P_TASK_TYPE_ID             =>   1,
      --P_SOURCE_OBJECT_ID         =>   'ISUPPORT',
      --P_SOURCE_OBJECT_CODE       =>   'ISUPPORT',
--P_SOURCE_OBJECT_TYPE_CODE   =>  'ISUPPORT',
--P_SOURCE_OBJECT_ID          =>   PARTY_ID,
--P_SOURCE_OBJECT_NAME        =>   PARTY_ID,
        P_SORT_DATA                =>   l_sort_data,
        X_TASK_TABLE               =>   l_task_table,
        X_TOTAL_RETRIEVED          =>   l_total_retrieved,
        X_TOTAL_RETURNED           =>   l_total_returned,
        X_RETURN_STATUS            =>   l_rs,
        X_MSG_COUNT                =>   l_msg_count,
        X_MSG_DATA                 =>   l_msg_data,
        X_OBJECT_VERSION_NUMBER    =>   l_version_num);

        l_msg_data := FND_MSG_PUB.GET(1, 'F' );


      --DBMS_OUTPUT.PUT_LINE('RETRIEVED =     '||l_total_retrieved);
      --DBMS_OUTPUT.PUT_LINE('RETURNED  =     '||l_total_returned);
      --DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
      --DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
      --DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);
      --DBMS_OUTPUT.PUT_LINE('TASK_ID = '      ||l_version_num);

    DBMS_LOB.CREATETEMPORARY(query_clob, TRUE, DBMS_LOB.SESSION);

    IF (l_task_table.count > 0) THEN
      v_first := l_task_table.first;
      v_index := v_first;

      LOOP

--DBMS_OUTPUT.PUT_LINE('Task Name: '||l_task_table(v_index).task_name);
--DBMS_OUTPUT.PUT_LINE('Id: '||to_char(l_task_table(v_index).task_id));
--DBMS_OUTPUT.PUT_LINE('Number: '||l_task_table(v_index).task_number);
--DBMS_OUTPUT.PUT_LINE('Acc#: '||l_task_table(v_index).cust_account_number);
--DBMS_OUTPUT.PUT_LINE('Cust Name: '|| l_task_table(v_index).customer_name);
--DBMS_OUTPUT.PUT_LINE('Status:'||l_task_table(v_index).task_status);

--taskID      = queryTaskTokens.nextToken();
--partyID     = queryTaskTokens.nextToken();
--companyID   = queryTaskTokens.nextToken();
--regDate     = queryTaskTokens.nextToken();
--userName    = queryTaskTokens.nextToken();
--userCompany = queryTaskTokens.nextToken();
--accountID   = queryTaskTokens.nextToken();

        IF (result IS NULL ) THEN
           result := NVL(TO_CHAR(l_task_table(v_index).task_id), 'EMPTY');
        ELSE
           result := result||
                     NVL(TO_CHAR(l_task_table(v_index).task_id), 'EMPTY');
        END IF;

        -- ***************************************
        -- NOTE:  customer_ID contains the partyID
        -- ***************************************

        result := result
              ||'^'||NVL(l_task_table(v_index).customer_id,   '-1')
--              ||'^'||NVL(TO_CHAR(l_task_table(v_index).task_id), 'EMPTY')
              ||'^'||TO_CHAR(l_task_table(v_index).creation_date,'DD/MM/YYYY')
--              ||'^'||NVL(l_task_table(v_index).customer_name, 'EMPTY')
--              ||'^'||NVL(l_task_table(v_index).customer_name, 'EMPTY')
--              ||'^'||NVL(l_task_table(v_index).cust_account_number, 'EMPTY')
              ||'^';

        row_length := NVL(length(rtrim(result)), 0);
        DBMS_LOB.WRITEAPPEND(query_clob, row_length, result);
        result := '';

        EXIT WHEN v_index = l_task_table.last;
        v_index := l_task_table.next(v_index);

      END LOOP;

    ELSE
      user0 := '12/10/99^John Smith0^Oracle0^Acct 120^';
      user1 := '12/11/99^John Smith1^Oracle1^Acct 121^';
      user2 := '12/12/99^John Smith2^Oracle2^Acct 122^';
      user3 := '12/13/99^John Smith3^Oracle3^Acct 123^';
      user4 := '12/14/99^John Smith4^Oracle4^Acct 124^';
      user5 := '12/15/99^John Smith5^Oracle5^Acct 125^';
      user6 := '12/16/99^John Smith6^Oracle6^Acct 126^';
      user7 := '12/17/99^John Smith7^Oracle7^Acct 127^';

      result := result||user0||user1||user2||user3||
                        user4||user5||user6||user7;

    END IF;

    return( query_clob );

  END query_task;


  PROCEDURE query_test(API_VERSION   IN NUMBER    DEFAULT 1.0,
                       START_POINTER IN NUMBER    DEFAULT 1,
                       REC_WANTED    IN NUMBER    DEFAULT 1,
                       SHOW_ALL      IN VARCHAR2  DEFAULT 'YES',
                       SORT_ORDER    IN VARCHAR2  DEFAULT 'sortByAscendingDate')
  IS
     l_task_table              JTF_TASKS_PUB.TASK_TABLE_TYPE;
     l_total_retrieved         NUMBER;
     l_total_returned          NUMBER;
     l_rs                      VARCHAR2(1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);
     l_version_num             NUMBER;

     l_sort_data               JTF_TASKS_PUB.SORT_DATA;

     recurs                    JTF_TASKS_PUB.TASK_RECUR_REC;
     rsc                       JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
     asn                       JTF_TASKS_PUB.TASK_ASSIGN_TBL;
     notes                     JTF_TASKS_PUB.TASK_NOTES_TBL;

  v_first                    integer;
  v_index                    integer;

     result                    VARCHAR2(4000) := '';
     user0                     VARCHAR2(4000) := '';
     user1                     VARCHAR2(4000) := '';
     user2                     VARCHAR2(4000) := '';
     user3                     VARCHAR2(4000) := '';
     user4                     VARCHAR2(4000) := '';
     user5                     VARCHAR2(4000) := '';
     user6                     VARCHAR2(4000) := '';
     user7                     VARCHAR2(4000) := '';


  BEGIN

--DBMS_OUTPUT.PUT_LINE('Testing Task Query sort_order = '||sort_order);

     IF( SORT_ORDER = 'sortByAscendingDate' ) THEN
       l_sort_data(1).field_name   := 'task_name';
       l_sort_data(1).asc_dsc_flag := 'D';
       l_sort_data(2).field_name   := 'task_id';
       l_sort_data(2).asc_dsc_flag := 'A';
     ELSIF( SORT_ORDER = 'sortByDescendingDate' ) THEN
       l_sort_data(1).field_name   := 'task_name';
       l_sort_data(1).asc_dsc_flag := 'D';
       l_sort_data(2).field_name   := 'task_id';
       l_sort_data(2).asc_dsc_flag := 'D';
     ELSIF( SORT_ORDER = 'sortByCompany' ) THEN
       l_sort_data(1).field_name   := 'task_name';
       l_sort_data(1).asc_dsc_flag := 'D';
       l_sort_data(2).field_name   := 'task_id';
       l_sort_data(2).asc_dsc_flag := 'A';
     END IF;


     JTF_TASKS_PUB.query_task(
        P_API_VERSION              =>   1.0,
        P_START_POINTER            =>   1,
        P_REC_WANTED               =>   10,
        P_SHOW_ALL                 =>   'Y',
        P_QUERY_OR_NEXT_CODE       =>   'Q',
      --P_SOURCE_OBJECT_CODE       =>   'ISUPPORT',
        P_SORT_DATA                =>   l_sort_data,
        X_TASK_TABLE               =>   l_task_table,
        X_TOTAL_RETRIEVED          =>   l_total_retrieved,
        X_TOTAL_RETURNED           =>   l_total_returned,
        X_RETURN_STATUS            =>   l_rs,
        X_MSG_COUNT                =>   l_msg_count,
        X_MSG_DATA                 =>   l_msg_data,
        X_OBJECT_VERSION_NUMBER    =>   l_version_num);

        l_msg_data := FND_MSG_PUB.GET(1, 'F' );

--DBMS_OUTPUT.PUT_LINE('X_TSK_TBL.count= '||TO_CHAR(l_task_table.count));

      --DBMS_OUTPUT.PUT_LINE('RETRIEVED =     '||l_total_retrieved);
      --DBMS_OUTPUT.PUT_LINE('RETURNED  =     '||l_total_returned);
      --DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
      --DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
      --DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);
      --DBMS_OUTPUT.PUT_LINE('TASK_ID = '      ||l_version_num);

    IF (l_task_table.count > 0) THEN
      v_first := l_task_table.first;
      v_index := v_first;

      LOOP

--DBMS_OUTPUT.PUT_LINE('Task Name: '||l_task_table(v_index).task_name);
--DBMS_OUTPUT.PUT_LINE('Id: '||to_char(l_task_table(v_index).task_id));
--DBMS_OUTPUT.PUT_LINE('Number: '||l_task_table(v_index).task_number);
--DBMS_OUTPUT.PUT_LINE('Acct#: '||l_task_table(v_index).cust_account_number);

--DBMS_OUTPUT.PUT_LINE('Cust Name: '|| l_task_table(v_index).customer_name);
--DBMS_OUTPUT.PUT_LINE('Status:'||l_task_table(v_index).task_status);
--DBMS_OUTPUT.PUT_LINE('Creation:'||l_task_table(v_index).creation_date);

        EXIT WHEN v_index = l_task_table.last;
        v_index := l_task_table.next(v_index);

      END LOOP;
    result := result||'cccccccccccccccccccccccccccc';

    ELSE
      user0 := '12/10/99^John Smith0^Oracle0^Acct 120^';
      user1 := '12/11/99^John Smith1^Oracle1^Acct 121^';
      user2 := '12/12/99^John Smith2^Oracle2^Acct 122^';
      user3 := '12/13/99^John Smith3^Oracle3^Acct 123^';
      user4 := '12/14/99^John Smith4^Oracle4^Acct 124^';
      user5 := '12/15/99^John Smith5^Oracle5^Acct 125^';
      user6 := '12/16/99^John Smith6^Oracle6^Acct 126^';
      user7 := '12/17/99^John Smith7^Oracle7^Acct 127^';

    result := result||'dddddddddddddddddddddddddddd';
    END IF;

    result := result||user0||user1||user2||user3||
                      user4||user5||user6||user7;

  END query_test;


--SQL> select task_status_id, name
--  2  from jtf_task_statuses_vl;
--
--TASK_STATUS_ID NAME
---------------- ------------------------------
--             2 PLANNED
--             3 ACCEPTED
--             4 REJECTED
--             5 WORKING
--             6 INTERRUPTED
--             7 CANCELLED
--             8 COMPLETED
--             9 CLOSED
--            10 OPEN
--            11 CLOSE
--            12 NOT STARTED
--            14 ASSIGNED
--             1 IN PLANNING
--            13 UNASSIGNED


PROCEDURE update_task(API_VERSION           IN NUMBER DEFAULT 1.0,
                      OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                      P_TASK_ID             IN NUMBER,
                      COMMENTS              IN VARCHAR2 DEFAULT NULL,
                      COMPLETION_STATUS     IN VARCHAR2 DEFAULT 'COMPLETED',
                      X_MSG_DATA            OUT NOCOPY VARCHAR2,
                      X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
                      X_MSG_COUNT           OUT NOCOPY NUMBER)
IS
    l_task_table              JTF_TASKS_PUB.TASK_TABLE_TYPE;
    l_total_retrieved         NUMBER;
    l_total_returned          NUMBER;
--    l_rs                      VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_version_num             NUMBER;
    l_status_id               NUMBER := 9;
    x                         NUMBER;

    l_status_fail             EXCEPTION;
    l_msg_index              number;
    l_sort_data               JTF_TASKS_PUB.SORT_DATA;

-- note-related variables...

    l_object_version_number  NUMBER := 0;
    l_jtf_note_id            NUMBER := 0;
--    l_return_status          VARCHAR2(30);
    l_note_id                NUMBER;
    l_notes                  VARCHAR2(4000) := '';
    l_notes_detail           VARCHAR2(32000);
    l_owner_id               NUMBER := 0;
--  context_tab              JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE;

  BEGIN

    l_status_id := 8;

    SELECT OBJECT_VERSION_NUMBER
    INTO   l_object_version_number
    FROM   JTF_TASKS_B
    WHERE  TASK_ID = P_TASK_ID;

    SELECT JTF_NOTE_ID
    INTO   l_note_id
    FROM   JTF_NOTES_B
    WHERE  SOURCE_OBJECT_ID = p_task_id
    AND    SOURCE_OBJECT_CODE = 'TASK'
    AND    ROWNUM = 1;

    SELECT RESOURCE_ID
    INTO   l_owner_id
    FROM   JTF_RS_RESOURCE_EXTNS
    WHERE  CATEGORY = 'EMPLOYEE'
    AND    ROWNUM = 1;

--    DBMS_OUTPUT.PUT_LINE('Task '||p_task_id||' status = '||l_status_id||
--      ' with completion_status = '||completion_status );
--    DBMS_OUTPUT.PUT_LINE('l_note_id=' || l_note_id);


     JTF_TASKS_PUB.update_task(
        P_API_VERSION              =>   1.0,
        P_OBJECT_VERSION_NUMBER    =>   l_object_version_number,
        P_TASK_STATUS_ID           =>   l_status_id,
        P_TASK_ID                  =>   P_TASK_ID,
        P_COMMIT                   =>   FND_API.G_FALSE,
        X_RETURN_STATUS            =>   x_return_status,
        X_MSG_COUNT                =>   x_msg_count,
        X_MSG_DATA                 =>   x_msg_data);

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_status_fail;
    END IF;

--        l_msg_data := FND_MSG_PUB.GET(1, 'F' );

      --DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
      --DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
      --DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);


   l_notes   := COMMENTS;

   JTF_NOTES_PUB.UPDATE_NOTE
     ( p_api_version           => 1,
       p_init_msg_list         => FND_API.G_FALSE,
       p_commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_jtf_note_id           => l_note_id,
       p_entered_by            => NULL,
       p_last_updated_by       => l_owner_id,
       p_last_update_date      => SYSDATE,
       p_last_update_login     => NULL,
       p_notes                 => COMMENTS
     );

--    DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||x_return_status);
--     DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||x_msg_count);
--     DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||x_msg_data);


  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE l_status_fail;
    END IF;

    COMMIT;

EXCEPTION
  when l_status_fail then
      l_msg_index := 1;
      x_msg_data := ' ';
      l_msg_count := x_msg_count;

      while l_msg_count > 0 loop
	l_msg_data := fnd_msg_pub.get(l_msg_index, fnd_api.g_false);
	x_msg_data := concat(x_msg_data, l_msg_data);
	x_msg_data := concat(x_msg_data, '###');
	l_msg_index := l_msg_index + 1;
	l_msg_count := l_msg_count - 1;
      end loop;

--  dbms_output.put_line('NOTE API COMPLETED: '|| l_return_status || l_note_id);

  END update_task;


  PROCEDURE update_task_without_note(API_VERSION           IN NUMBER DEFAULT 1.0,
                                     OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                                     P_TASK_ID             IN NUMBER,
                                     COMMENTS              IN VARCHAR2 DEFAULT NULL,
                                     COMPLETION_STATUS     IN VARCHAR2 DEFAULT 'COMPLETED') IS

     l_task_table              JTF_TASKS_PUB.TASK_TABLE_TYPE;
     l_total_retrieved         NUMBER;
     l_total_returned          NUMBER;
     l_rs                      VARCHAR2(1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);
     l_version_num             NUMBER;
     l_status_id               NUMBER := 9;
     x                         NUMBER;

     recurs                    JTF_TASKS_PUB.TASK_RECUR_REC;
     rsc                       JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;
     asn                       JTF_TASKS_PUB.TASK_ASSIGN_TBL;
     ass                       JTF_TASKS_PUB.TASK_ASSIGN_TBL;
     notes                     JTF_TASKS_PUB.TASK_NOTES_TBL;

     l_sort_data               JTF_TASKS_PUB.SORT_DATA;

     -- note-related variables...
     x_return_status          VARCHAR2(2000);
     x_msg_count              NUMBER;
     x_msg_data               VARCHAR2(2000);
     x_cust_account_id        NUMBER;
     x_cust_account_number    VARCHAR2(2000);
     x_party_id               NUMBER;
     x_party_number           VARCHAR2(2000);
     x_profile_id             NUMBER;


     l_object_version_number  NUMBER := 0;
     l_return_status          VARCHAR2(30);
     l_note_id                NUMBER;
     l_notes                  VARCHAR2(4000) := '';
     l_notes_detail           VARCHAR2(32000);
     context_tab              JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE;

  BEGIN

     IF( COMPLETION_STATUS    = 'ACCEPTED' )   THEN
       l_status_id := 3;
     ELSIF( COMPLETION_STATUS = 'REJECTED' )   THEN
       l_status_id := 4;
     ELSIF( COMPLETION_STATUS = 'COMPLETED' )  THEN
       l_status_id := 8;
     ELSIF( COMPLETION_STATUS = 'CLOSED' )     THEN
       l_status_id := 9;
     ELSIF( COMPLETION_STATUS = 'UNASSIGNED' ) THEN
       l_status_id := 13;
     END IF;

     SELECT JTF_TASKS_B.OBJECT_VERSION_NUMBER
     INTO l_object_version_number
     FROM JTF_TASKS_B
     WHERE TASK_ID = P_TASK_ID;


   --DBMS_OUTPUT.PUT_LINE('Task '||task_id||' status = '||l_status_id||
   --   ' with completion_status = '||completion_status );

     JTF_TASKS_PUB.update_task(
        P_API_VERSION              =>   1.0,
        P_OBJECT_VERSION_NUMBER    =>   l_object_version_number,
        P_TASK_STATUS_ID           =>   l_status_id,
        P_TASK_ID                  =>   P_TASK_ID,
      --P_SOURCE_OBJECT_TYPE_CODE  =>   NULL,
      --P_SOURCE_OBJECT_TYPE_CODE  =>  'ISUPPORT',
        X_RETURN_STATUS            =>   l_rs,
        X_MSG_COUNT                =>   l_msg_count,
        X_MSG_DATA                 =>   l_msg_data);

        l_msg_data := FND_MSG_PUB.GET(1, 'F' );

      --DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
      --DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
      --DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);

  END update_task_without_note;


  PROCEDURE update_party_note(API_VERSION           IN NUMBER DEFAULT 1.0,
                              OBJECT_VERSION_NUMBER IN NUMBER DEFAULT 1,
                              PARTY_ID              IN NUMBER,
                              COMMENTS              IN VARCHAR2) IS

     CURSOR jtf_note_id_cursor IS
        SELECT JTF_NOTE_ID
        FROM   JTF_NOTES_B
        WHERE  SOURCE_OBJECT_CODE = 'PARTY'
        AND    SOURCE_OBJECT_ID   = PARTY_ID
        ORDER BY 1;

     l_msg_count              NUMBER;
     l_msg_data               VARCHAR2(2000);

     x_return_status          VARCHAR2(2000);
     x_msg_count              NUMBER;
     x_msg_data               VARCHAR2(2000);
     x_cust_account_id        NUMBER;
     x_cust_account_number    VARCHAR2(2000);
     x_party_id               NUMBER;
     x_party_number           VARCHAR2(2000);
     x_profile_id             NUMBER;


     l_jtf_note_id   NUMBER := 0;
     l_return_status VARCHAR2(30);
     p_note_id       NUMBER;
     l_notes         VARCHAR2(4000) := '';
     l_notes_detail  VARCHAR2(32000);
     context_tab     JTF_NOTES_PUB.JTF_NOTE_CONTEXTS_TBL_TYPE;

  BEGIN

     OPEN  jtf_note_id_cursor;
     FETCH jtf_note_id_cursor INTO p_note_id;

--      notes(1).org_id                 :=  173 ;
--      notes(1).notes                  := COMMENTS;
--      notes(1).notes_detail           := null;
--      notes(1).note_status            := null ;
--      notes(1).entered_by             :=  -1 ;
--      notes(1).entered_date           := sysdate ;
--      notes(1).note_type              := null ;
--
--      l_notes   := COMMENTS;

     WHILE jtf_note_id_cursor%FOUND
     LOOP
      --context_tab(1).note_context_id      := 8715;
        context_tab(1).note_context_type_id := PARTY_ID;
        context_tab(1).note_context_type    := 'PARTY';
        context_tab(1).last_update_date     := SYSDATE;
        context_tab(1).last_updated_by      := FND_GLOBAL.USER_ID;
        context_tab(1).created_by           := FND_GLOBAL.USER_ID;


        JTF_NOTES_PUB.Update_note
          ( p_api_version           => 1,
            p_init_msg_list         => FND_API.G_FALSE,
          --p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_jtf_note_id           => p_note_id,
            p_entered_by            => NULL,
            p_last_updated_by       => 1000,
            p_last_update_date      => SYSDATE,
            p_last_update_login     => NULL,
            p_notes                 => 'Updated thru API',
            p_notes_detail          => COMMENTS,
            p_append_flag           => FND_API.G_MISS_CHAR,
            p_note_status           => FND_API.G_MISS_CHAR,
            p_note_type             => FND_API.G_MISS_CHAR,
            p_jtf_note_contexts_tab => context_tab
          );

--dbms_output.put_line('Api completed '||l_return_status||p_note_id);

          FETCH jtf_note_id_cursor INTO p_note_id;

    END LOOP;

--l_msg_data := FND_MSG_PUB.GET(1, 'F' );
--DBMS_OUTPUT.PUT_LINE('RETURN_STATUS = '||l_rs);
--DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT   = '||l_msg_count);
--DBMS_OUTPUT.PUT_LINE('MSG_DATA = '     ||l_msg_data);

  END UPDATE_PARTY_NOTE;


END TASK_MGR;

/
