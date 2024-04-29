--------------------------------------------------------
--  DDL for Package Body MRP_REL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_REL_WF" AS
/*$Header: MRPRLWFB.pls 120.1.12010000.2 2008/12/12 16:22:11 eychen ship $ */

PROCEDURE MSC_INITIALIZE(lv_user_id        IN NUMBER,
                         lv_resp_id        IN NUMBER,
                         lv_application_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
      FND_GLOBAL.APPS_INITIALIZE
                            ( lv_user_id,
                              lv_resp_id,
                              lv_application_id);
COMMIT;
END MSC_INITIALIZE;

PROCEDURE init_source(p_user_name varchar2, p_resp_name varchar2) IS
    l_user_id number;
    l_resp_id number;
    l_application_id number;

    cursor resp_exists(l_resp_name varchar2) IS
    select responsibility_id
    from   fnd_responsibility_vl
    where  application_id = l_application_id
    and    responsibility_name = l_resp_name;

BEGIN
     select user_id
       into l_user_id
       from fnd_user
      where user_name = p_user_name;
  begin

      SELECT APPLICATION_ID
        INTO l_application_id
        FROM FND_APPLICATION_VL
      WHERE APPLICATION_SHORT_NAME = 'MSC'
      and   rownum = 1;

  -- first try to see if current destination responsibility exists in source
  if p_resp_name is not null then

    open resp_exists(p_resp_name);
    fetch resp_exists into l_resp_id;
    close resp_exists;

    /* 6700644, use new resp name */
    if l_resp_id is null then
      open resp_exists('APS Release');
      fetch resp_exists into l_resp_id;
      close resp_exists;
    end if;

  end if;

  -- else get first MSC responsibility available
  if l_resp_id is null then

      SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
          and rownum =1 ;

  end if;

   exception when no_data_found then

     SELECT APPLICATION_ID
     INTO l_application_id
     FROM FND_APPLICATION_VL
     WHERE APPLICATION_SHORT_NAME = 'MRP'
     and rownum = 1;

      SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
          and rownum =1 ;
   end;


      fnd_global.apps_initialize(l_user_id, l_resp_id, l_application_id);
exception when others then
    -- raise; bug7589240
    MSC_INITIALIZE( l_user_id, l_resp_id, l_application_id);
END init_source;

PROCEDURE launch_po_program
(
p_old_need_by_date IN DATE,
p_new_need_by_date IN DATE,
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_user IN VARCHAR2,
p_resp IN VARCHAR2,
p_qty IN NUMBER,
p_out OUT NOCOPY NUMBER
) IS
 p_result boolean;
BEGIN

 mrp_rel_wf.init_source(p_user, p_resp);
 p_result := fnd_request.set_mode(true);
 p_out := fnd_request.submit_request(
                         'MSC',
                         'MRPRSHPO',
                         null,
                         null,
                         false,
                         p_old_need_by_date,
                         p_new_need_by_date,
                         p_po_header_id,
                         p_po_line_id,
                         p_po_number,
                         p_qty);

exception when others then
 p_out :=0;
 raise;
END launch_po_program;

PROCEDURE launch_so_program
(
p_batch_id in number,
p_dblink in varchar2,
p_instance_id in number,
p_user IN VARCHAR2,
p_resp IN VARCHAR2,
p_out OUT NOCOPY NUMBER
) IS
 p_result boolean;
BEGIN

 mrp_rel_wf.init_source(p_user, p_resp);
 p_result := fnd_request.set_mode(true);

 p_out := fnd_request.submit_request(
                         'MSC',
                         'MRPRELSO',
                         null,
                         null,
                         false,
                         p_batch_id,
                         p_dblink,
                         p_instance_id);

exception when others then
 p_out :=0;
 raise;
END launch_so_program;

PROCEDURE validate_pjm_selectAll(p_server_dblink IN varchar2,
                                 p_user_name     IN varchar2,
                                 p_plan_id       IN number,
                                 p_query_id      IN number) IS
sql_stmt varchar2(500);
TYPE type_cursor IS REF CURSOR;
supply_cursor type_cursor;
l_supply_info_data  MRP_REL_WF.supply_project_tbl;
a number;
l_user_id NUMBER;
l_application_id NUMBER;
l_resp_id NUMBER;
l_operating_unit_id NUMBER;
p_org number;
l_valid varchar2(10);
l_error varchar2(1000);
BEGIN

-- get the data into pl/sql table from the source
sql_stmt:=
  ' SELECT  number1, -- trx_id
            number2, -- organization_id,
            date1,   -- new_schedule_date,
            number3, -- project_id,
            number4  -- task_id
     FROM   mrp_form_query '||p_server_dblink||
  '  WHERE query_id = :p_query_id ';

    a :=1;
   OPEN supply_cursor FOR sql_stmt using p_query_id;
   LOOP
      FETCH supply_cursor INTO l_supply_info_data(a).transaction_id,
                               l_supply_info_data(a).organization_id,
                               l_supply_info_data(a).start_date,
                               l_supply_info_data(a).project_id,
                               l_supply_info_data(a).task_id;
      EXIT WHEN supply_cursor%NOTFOUND;
     p_org := l_supply_info_data(a).organization_id;
    a := a+1;
   END LOOP;
   CLOSE supply_cursor;

-- process the data
-- pjm_project.validate_proj_references  requires  correct  org/resp/operating
--unit  setup
-- can not use init_source because pjm requires only Project Manufacturing
--specific resp and application set up.
        select user_id
        INTO  l_user_id
        FROM fnd_user
        where user_name= p_user_name; -- here I can  pass any userid

        SELECT APPLICATION_ID
        INTO l_application_id
        FROM FND_APPLICATION_VL
        WHERE APPLICATION_SHORT_NAME ='PJM'
        and rownum = 1;

        SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
        and rownum = 1;

        select operating_unit
        INTO l_operating_unit_id
        FROM org_organization_definitions
        WHERE organization_id=p_org ; --3983540
       fnd_global.apps_initialize(l_user_id, l_resp_id, l_application_id);

   if nvl(FND_PROFILE.value('MRP_DISABLE_PROJECT_VALIDATION'),'N') = 'Y' then
      return;
   end if;

       FND_CLIENT_INFO.set_org_context(to_char(l_operating_unit_id)); --3983540

-- loop through the supplies to identify which
-- supply has invalid project_id
   for a in 1 .. l_supply_info_data.COUNT  LOOP
       l_valid :=
pjm_project.validate_proj_references(l_supply_info_data(a).organization_id,
                                     l_supply_info_data(a).project_id,
                                     l_supply_info_data(a).task_id,
                                     l_supply_info_data(a).start_date,
                                     null, -- completion_date
                                    ' MSC');
       IF l_valid <> 'S' THEN
       l_error :=  fnd_message.get;
        sql_stmt:= 'update msc_supplies ' ||p_server_dblink ||
             '  SET implement_as = NULL,
                implement_quantity = NULL,
                implement_date = NULL,
                release_status = 2,
                release_errors = :p_error
          where transaction_id = :p_transaction_id
            and plan_id = :plan_id';

       execute immediate sql_stmt
                         using in l_error,
                               in l_supply_info_data(a).transaction_id,
                               in p_plan_id;


       END IF;

     END LOOP;

-- due to bug # 7346704 we should remove this commit,
-- we close dblink in the destination ,
-- we only close dblink from destination to source
-- we do not close this dblink,
/*
       if p_server_dblink is not null and p_server_dblink <> ' ' then
            commit;
            begin
               sql_stmt:= ' alter session close database link '||
                                    ltrim(p_server_dblink,'@');
               execute immediate sql_stmt;
            exception when others then
                 null;
            end;
  end if;
*/

  exception when others then
  null;

END  validate_pjm_selectAll;

PROCEDURE   validate_pjm ( p_org        NUMBER,
                         p_project_id NUMBER,
                         p_task_id    NUMBER,
                         p_start_date DATE,
                         p_completion_date DATE,
                         p_user_name  VARCHAR2,
                         p_valid  OUT NOCOPY VARCHAR2,
                         p_error  OUT NOCOPY VARCHAR2 )   IS



 l_user_id NUMBER;
 l_application_id NUMBER;
 l_resp_id NUMBER;
 l_operating_unit_id NUMBER;
 sql_stmt VARCHAR2(32000);

BEGIN

-- This procedure is called by the procedure in the server.
-- pjm_project.validate_proj_references  requires  correct  org/resp/operating unit  setup
-- can not use init_source because pjm requires only Project Manufacturing specific resp and application set up.

        select user_id
        INTO  l_user_id
        FROM fnd_user
        where user_name= p_user_name; -- here I can  pass any userid

        SELECT APPLICATION_ID
        INTO l_application_id
        FROM FND_APPLICATION_VL
        WHERE APPLICATION_SHORT_NAME ='PJM'
        and rownum = 1;

        SELECT responsibility_id
        INTO l_resp_id
        FROM FND_responsibility_vl
        where application_Id = l_application_id
        and rownum = 1;

        select operating_unit
        INTO l_operating_unit_id
        FROM org_organization_definitions
        WHERE organization_id=p_org ; --3983540

       fnd_global.apps_initialize(l_user_id, l_resp_id, l_application_id);

   if nvl(FND_PROFILE.value('MRP_DISABLE_PROJECT_VALIDATION'),'N') = 'Y' then
      p_valid := 'S';
      return;
   end if;

       FND_CLIENT_INFO.set_org_context(to_char(l_operating_unit_id)); --3983540


  sql_stmt :=
     'BEGIN :p_valid := pjm_project.validate_proj_references(
                                                   :p_org,
                                                   :p_project_id,
                                                   :p_task_id,
                                                   :p_start_date,
                                                   :p_completion_date,
                                                   ''MSC''); END;';

      EXECUTE IMMEDIATE sql_stmt USING
                                 OUT p_valid,
                                 IN  p_org,
                                 IN  p_project_id,
                                 IN  p_task_Id,
                                 IN  p_start_date,
                                 IN  p_completion_date;


       IF p_valid <> 'S' THEN
       p_error :=  fnd_message.get;
       END IF;

END  validate_pjm;

function get_profile_value ( p_prof_name in varchar2
                           , p_user_name in varchar2
                           , p_resp_name in varchar2
                           , p_appl_name in varchar2
                           ) return varchar2 is
  rc varchar2(32000);
  l_user_id number;
  l_appl_id number;
  l_resp_id number;
begin

     begin

        select user_id
        into   l_user_id
        from   fnd_user
        where  user_name = p_user_name;

        select application_id
        into   l_appl_id
        from   fnd_application_vl
        where  application_short_name = p_appl_name;

        select responsibility_id
        into   l_resp_id
        from   fnd_responsibility_vl
        where  responsibility_name = p_resp_name
        and    application_Id = l_appl_id;

     exception

        when others then raise;

     end;

  select fnd_profile.value_specific ( p_prof_name
                                    , l_user_id
                                    , l_resp_id
                                    , l_appl_id
                                    )
         into rc from dual;
  return rc;
exception
  when others then
    return null;
end get_profile_value;

END mrp_rel_wf;

/
