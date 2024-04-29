--------------------------------------------------------
--  DDL for Package Body ZPB_EXCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_EXCP_PVT" AS
/* $Header: ZPBVEXCB.pls 120.0.12010.5 2006/08/03 12:05:19 appldev noship $  */


  G_PKG_NAME CONSTANT VARCHAR2(12) := 'zpb_excp_pvt';

-------------------------------------------------------------------------------

PROCEDURE run_exception (
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY varchar2,
  x_msg_count         OUT NOCOPY number,
  x_msg_data          OUT NOCOPY varchar2,
  p_task_id           IN  NUMBER,
  p_user_id           IN  NUMBER )

IS

  l_api_name      CONSTANT VARCHAR2(13) := 'run_exception';
  l_api_version   CONSTANT NUMBER       := 1.0;

  l_exception_limit ZPB_TASK_PARAMETERS.value%type;
  l_query_path      ZPB_TASK_PARAMETERS.value%type;
  l_query_name      ZPB_TASK_PARAMETERS.value%type;
  l_query           VARCHAR2(8000);
  l_user_id         VARCHAR2(64);
  l_task_id         VARCHAR2(64);
  l_dim             ZPB_STATUS_SQL.dimension_name%type;
  l_hier            ZPB_STATUS_SQL.hierarchy_name%type;
  l_count           NUMBER;
  l_excp_ct         VARCHAR2(32766);

  l_instance_id     NUMBER;

  cursor task_dfn is
    select name, value
    from zpb_task_parameters
    where task_id = p_task_id
          and ( name = EXCEPTION_LIMIT
          or name = QUERY_OBJECT_PATH
          or name = QUERY_OBJECT_NAME );

  cursor statSqlMbrs is
    select dimension_name dim, hierarchy_name hier
    from zpb_status_sql
    where (query_path = l_query);

BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_user_id := to_char(p_user_id);
  l_task_id := to_char(p_task_id);

  ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Running Exceptions for user ' || l_user_id || '.');

  for each in task_dfn loop
    if (each.name = EXCEPTION_LIMIT) then
      l_exception_limit := each.value;
    end if;
    if (each.name = QUERY_OBJECT_PATH) then
      l_query_path := each.value;
    end if;
    if (each.name = QUERY_OBJECT_NAME) then
      l_query_name := each.value;
    end if;
  end loop;

  l_query := l_query_path || '/' || l_query_name;



  -- update FRM.CPR formula
  select analysis_cycle_id into l_instance_id
  from   zpb_analysis_cycle_tasks
  where  task_id = p_task_id;

  zpb_aw.execute('call SC.EXCEPCPRMOD(''' || to_char(l_instance_id) || ''')');

  -- Standard Start of API savepoint
  SAVEPOINT zpb_excp_pvt_run_exception;

  --populate zpb_status_sql_members table
  --ZPB_AW_STATUS.RUN_OLAPI_QUERIES( l_query );

  --Test the query entry. The same dimension and hierarchy must exist for all rows.
  l_count := 1;
  for each in statSqlMbrs loop
    if (l_count > 1) then
      if (l_dim <> each.dim or l_hier <> each.hier) then
        ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'The specified query shows inconsistent results.');
        --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --RAISE_APPLICATION_ERROR(-20000, 'The specified query shows inconsistent results.', TRUE);
      end if;
    else
      l_dim := each.dim;
      l_hier := each.hier;
    end if;
    l_count := l_count + 1;
  end loop;

  --call AW exception program
--dbms_output.put_line('call sc.exception.chk(' || '''' || l_task_id || ''' ''' || l_user_id || ''')' );

--Use for debug. Allows for use of show statements in OLAP DML. Be sure to comment out if statement
--below
--ZPB_AW.EXECUTE( 'call sc.exception.chk(' || '''' || l_task_id || ''' ''' || l_user_id || ''')' );
  l_excp_ct := ZPB_AW.INTERP( 'shw sc.exception.chk(' || '''' || l_task_id || ''' ''' || l_user_id || ''')' );

--dbms_output.put_line('Exception count : ' || l_excp_ct);

  -- add in owner and approver names (need to update who columns)
if l_excp_ct<>'NA' and l_excp_ct<>' ' then

  if to_number(l_excp_ct) > 0 then

    update zpb_excp_results z
      set owner = (
      select user_name
      from fnd_user f
      where f.user_id = z.owner_id),
                        LAST_UPDATED_BY =  fnd_global.USER_ID,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where task_id = l_task_id;

    update zpb_excp_results z
      set approver = (
      select user_name
      from fnd_user f
      where f.user_id = z.approver_id),
                        LAST_UPDATED_BY =  fnd_global.USER_ID,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where task_id = l_task_id;
  end if;
end if;

  ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Exceptions check completed for user ' || l_user_id || '.');

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

END run_exception;

-------------------------------------------------------------------------------

PROCEDURE test_run_exception

   is

   return_status   varchar2(32766);
   msg_count       number;
   msg_data        varchar2(32766);

  begin

dbms_output.put_line('start run exception test');
  run_exception(1.0, FND_API.G_FALSE, FND_API.G_FALSE, FND_API.G_VALID_LEVEL_FULL, return_status, msg_count, msg_data, 219, 1005156);
dbms_output.put_line(return_status);
dbms_output.put_line(msg_count);
--dbms_output.put_line(msg_data);
dbms_output.put_line('run exception test complete');

EXCEPTION
   WHEN OTHERS THEN
      raise;
   end test_run_exception;

----------------------------------------------------------------------------------

procedure request_child_nodes(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY number,
  x_msg_data          OUT NOCOPY varchar2,
  p_task_id           IN  zpb_excp_explanations.task_id%type,
  p_notification_id   IN  zpb_excp_explanations.notification_id%type)

IS

  l_api_name      CONSTANT VARCHAR2(30) := 'request_child_nodes';
  l_api_version   CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT zpb_excp_request_child_nodes;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- clean up from any previous requests
  delete from zpb_excp_explanations
  where task_id = p_task_id
  and notification_id = p_notification_id;


  insert into zpb_excp_explanations(NOTIFICATION_ID, TASK_ID, MEMBER_ID, MEMBER_DISPLAY,
    OWNER_ID, OWNER, APPROVER_ID, APPROVER, STATUS, VALUE_flag, value_number,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
  (select p_notification_id, e.TASK_ID, e.MEMBER_ID, e.MEMBER_DISPLAY,
    e.OWNER_ID, e.OWNER, e.APPROVER_ID, e.APPROVER, g_req_child_nodes, e.VALUE_flag, e.value_number,
    fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
  from zpb_excp_explanations e
  where e.task_id = p_task_id
  and e.owner_id = nvl(sys_context('ZPB_CONTEXT', 'shadow_id'), fnd_global.user_id));

  insert into zpb_excp_explanations(NOTIFICATION_ID, TASK_ID, MEMBER_ID, MEMBER_DISPLAY,
    OWNER_ID, OWNER, APPROVER_ID, APPROVER, STATUS, VALUE_flag, value_number,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
  (select p_notification_id, e.TASK_ID, e.MEMBER_ID, e.MEMBER_DISPLAY,
    e.OWNER_ID, e.OWNER, e.APPROVER_ID, e.APPROVER, g_req_child_nodes, e.VALUE_flag, e.value_number,
    fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
  from zpb_excp_results e
  where e.task_id = p_task_id
  and e.owner_id = nvl(sys_context('ZPB_CONTEXT', 'shadow_id'), fnd_global.user_id));

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_excp_populate_child_nodes;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_excp_populate_child_nodes;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO zpb_excp_populate_child_nodes;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

END request_child_nodes;

----------------------------------------------------------------------------------

PROCEDURE request_children (
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT nocopy varchar2,
  x_msg_count         OUT nocopy number,
  x_msg_data          OUT nocopy varchar2,
  p_notification_id   IN  zpb_excp_explanations.notification_id%type,
  p_task_id           IN  zpb_excp_explanations.task_id%type )

IS

  l_api_name      CONSTANT VARCHAR2(30) := 'request_children';
  l_api_version   CONSTANT NUMBER       := 1.0;

  l_query_path      ZPB_TASK_PARAMETERS.value%type;
  l_query_name      ZPB_TASK_PARAMETERS.value%type;
  l_query           VARCHAR2(8000);
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_resp_key        FND_RESPONSIBILITY.RESPONSIBILITY_KEY%type;
  l_task_id         VARCHAR2(16);
  l_dim             ZPB_STATUS_SQL.dimension_name%type;
  l_hier            ZPB_STATUS_SQL.hierarchy_name%type;
  l_count           NUMBER;
  l_child_ct        VARCHAR2(2000);

  cursor task_dfn is
    select name, value
    from zpb_task_parameters
    where task_id = p_task_id
          and ( name = QUERY_OBJECT_PATH
          or name = QUERY_OBJECT_NAME );

  cursor statSqlMbrs is
    select dimension_name dim, hierarchy_name hier
    from zpb_status_sql
    where (query_path = l_query);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT zpb_excp_pvt_run_exception;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_user_id := FND_GLOBAL.USER_ID;
  l_resp_id := FND_GLOBAL.RESP_ID;

--l_user_id := 1005262;
--l_resp_id := 57124;
--dbms_output.put_line(l_user_id);
--dbms_output.put_line(l_resp_id);

  select responsibility_key into l_resp_key
    from fnd_responsibility
    where responsibility_id = l_resp_id;

  l_task_id := to_char(p_task_id);
--dbms_output.put_line(l_task_id);

  ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'Finding children for task_id ' || p_task_id || ' and notification_id ' || p_notification_id || '.');

  for each in task_dfn loop
    if (each.name = QUERY_OBJECT_PATH) then
      l_query_path := each.value;
    end if;
    if (each.name = QUERY_OBJECT_NAME) then
      l_query_name := each.value;
    end if;
  end loop;

  l_query := l_query_path || '/' || l_query_name;

--dbms_output.put_line(l_query);

  --
  --Removed the following call, as this should be called on the OLAP connection
  --ZPB_AW.INITIALIZE_WORKSPACE(1.0, FND_API.G_FALSE, p_validation_level, x_return_status, x_msg_count, x_msg_data, l_user_id, l_resp_key);

  --populate zpb_status_sql_members table
  --ZPB_AW_STATUS.RUN_OLAPI_QUERIES( l_query );

  --test the OLAPI query results. The same dimension and hierarchy must exist for all rows.
  l_count := 1;
  for each in statSqlMbrs loop
    if (l_count > 1) then
      if (l_dim <> each.dim or l_hier <> each.hier) then
        ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, 'The specified query shows inconsistent results.');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --RAISE_APPLICATION_ERROR(-20000, 'The specified query shows inconsistent results.', TRUE);
      end if;
    else
      l_dim := each.dim;
      l_hier := each.hier;
    end if;
    l_count := l_count + 1;
  end loop;

--dbms_output.put_line('query line count : ' || to_char(l_count));

--dbms_output.put_line('call sc.exception.exp(' || '''' || p_task_id || ''' ''' || p_notification_id || ''')' );
  l_child_ct := ZPB_AW.INTERP( 'shw sc.exception.exp(' || '''' || to_char(p_task_id) || ''' ''' || to_char(p_notification_id) || ''')' );
--dbms_output.put_line('Child count : ' || l_child_ct);

  ZPB_AW.CLEAN_WORKSPACE(1.0, FND_API.G_FALSE, p_validation_level, x_return_status, x_msg_count, x_msg_data);

  -- add in owner names (need to update who columns)
  if to_number(l_child_ct) > 0 then
    update zpb_excp_explanations z
      set owner = (
      select user_name
      from fnd_user f
      where f.user_id = z.owner_id),
        LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where task_id = p_task_id
      and notification_id = p_notification_id;
  end if;

  ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME || '.' || l_api_name, l_child_ct || ' children found for task_id ' || p_task_id || ' and notification_id ' || p_notification_id || '.');

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO zpb_excp_pvt_run_exception;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );

END request_children;
-------------------------------------------------------------------------------

PROCEDURE test_req_child

   is

   return_status   varchar2(4000);
   msg_count       number;
   msg_data        varchar2(4000);
   msg_out         varchar2(2000);
   i               number;

  begin

  dbms_output.put_line('start request children test');
  request_children(1.0, FND_API.G_TRUE, FND_API.G_TRUE, FND_API.G_VALID_LEVEL_FULL, return_status, msg_count, msg_data, 10000, 9087);
  dbms_output.put_line(return_status);
  dbms_output.put_line(msg_count);
  --dbms_output.put_line(msg_data);
  --i := 1;
  --select fnd_msg_pub.get(-1) into msg_out from dual;
  --dbms_output.put_line(msg_out);
  --while i < msg_count loop
  --  select fnd_msg_pub.get(-2) into msg_out from dual;
  --  dbms_output.put_line(msg_out);
  --  i := i + 1;
  --end loop;
  dbms_output.put_line('request children test complete');

EXCEPTION
   WHEN OTHERS THEN
      raise;
   end test_req_child;
-------------------------------------------------------------------------------


END zpb_excp_pvt;

/
