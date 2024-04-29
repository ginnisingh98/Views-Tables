--------------------------------------------------------
--  DDL for Package Body MST_CP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_CP_WRAPPER" AS
/*$Header: MSTCPWPB.pls 115.4 2004/04/22 01:06:59 jnhuang noship $ */
   -- set to trigger mode to bypass the 'SAVEPOINT' and 'ROLLBACK' command.

PROCEDURE COPY_PLAN(p_plan_id IN NUMBER,
                    p_dest_plan_name IN VARCHAR2,
                    p_dest_plan_desc IN VARCHAR2,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTCPPCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id,  -- source plan id
                      p_dest_plan_name,  -- dest plan name
                      p_dest_plan_desc); -- dest plan desc
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END COPY_PLAN;

PROCEDURE LAUNCH_PLAN(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTLPLAN',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id);  -- source plan id
                     -- 2,    -- reuse setup data
                     -- 1,    -- run audit exceptions
                     -- 1);   -- lanuch planner
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END LAUNCH_PLAN;

PROCEDURE REOPTIMIZE_PLAN(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTOPTCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id,  -- source plan id
                      2,
                      1,
                      0,
                      0,
                      0,
                      0);   -- run kpi flag
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END REOPTIMIZE_PLAN;

PROCEDURE CALCULATE_KPI(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTKPICP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id,  -- source plan id
                      1,  -- optimized_flag: do not optimize
                      1,  -- maintain user edits: none
                      1,  -- allow removal from firm trips
                      2,  -- run audit report
                      2,    -- run exception flag
                      1);   -- run kpi flag
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END CALCULATE_KPI;

PROCEDURE CALCULATE_EXCEPTIONS(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTEXPCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id,  -- source plan id
                      1,  -- optimized_flag: do not optimize
                      1,  -- maintain user edits: none
                      1,  -- allow removal from firm trips
                      2,  -- run audit report
                      1,    -- run exception flag
                      2);   -- run kpi flag
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END CALCULATE_EXCEPTIONS;

PROCEDURE CALCULATE_AUDIT_EXCEPTIONS(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN

   --FND_GLOBAL.APPS_INITIALIZE(FND_GLOBAL.user_id, FND_GLOBAL.resp_id, 390);
   --l_result := FND_REQUEST.SET_MODE(TRUE);

   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST( application => 'MST',    --application
                      program => 'MSTEARCP',-- program
                      argument1 => p_plan_id);

   /*FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTEARCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id); -- plan id*/
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     commit;
   end if;
END CALCULATE_AUDIT_EXCEPTIONS;

PROCEDURE start_online_planner(p_plan_id IN NUMBER,
                    p_request_id OUT NOCOPY NUMBER) IS
l_result boolean;
l_request_id number;
BEGIN
   l_request_id := NULL;
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                      'MST',       -- application
                      'MSTOPNCP',-- program
                      NULL,       -- description
                      NULL,       -- start_time
                      FALSE,      -- sub_request
                      p_plan_id,  -- source plan id
                      4,  -- optimized_flag: start online planner
                      1,  -- maintain user edits: none
                      2,  -- allow removal from firm trips:  No
                      2,  -- run audit report
                      1,    -- run exception flag
                      1);   -- run kpi flag
   p_request_id := l_request_id;
   if l_request_id <> 0 then
     --update mst_plans set engine_active_flag = 1, request_id = l_request_id where plan_id = p_plan_id;
     update mst_plans set state = 4, program = 4, request_id = l_request_id where plan_id = p_plan_id;
     commit;
   end if;
END start_online_planner;

END MST_CP_WRAPPER;


/
