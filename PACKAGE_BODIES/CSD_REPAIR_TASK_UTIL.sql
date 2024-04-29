--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_TASK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_TASK_UTIL" as
/* $Header: csdvrtub.pls 120.1 2005/08/09 16:27:03 sangigup noship $ csdtactb.pls */

    G_PKG_NAME CONSTANT  VARCHAR2(30)  := 'CSD_REPAIR_TASK_UTIL';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvrtub.pls';
    l_debug              NUMBER       := csd_gen_utility_pvt.g_debug_level;

    -- Global variable for storing the debug level
    G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


procedure string_to_array( p_x_string IN OUT NOCOPY VARCHAR2, x_result_ids OUT NOCOPY  NUMBER_ARRAY_TYPE) IS

pos NUMBER;
total_length NUMBER := length(p_x_string);
i NUMBER := 1;
 --p_x_string = '123,456,789'

BEGIN
--i := l_result.FIRST;
while length(p_x_string)  >0 LOOP
--dbms_output.put_line('inside ');
pos := INSTR(p_x_string, ',', 1, 1); -- first appearance of , in the string
if pos =0 then
    x_result_ids (i) := p_x_string ;
    exit;
    else
--dbms_output.put_line('pos:= '|| pos);
x_result_ids(i) := to_number(substr(p_x_string, 1, pos-1)); -- will put 123 in the array- extracts pos-1 characters
--dbms_output.put_line('i '|| x_plan_ids(i));
p_x_string := substr(p_x_string,pos +1, length(p_x_string)-pos);
--dbms_output.put_line('p_x_string := '|| p_x_string);
i := i + 1;
--i := l_result.NEXT(i);
end if;

ENd LOOP;

END; --procedure string_to_array

--function to get the plan name from the plan id
function get_plan_name (p_plan_id IN NUMBER ) return VARCHAR2 IS
l_dummy varchar2(30);
cursor c_get_plan_name ( p_plan_id NUMBER) IS
select name
from qa_plans
where plan_id = p_plan_id;
BEGIN
OPEN c_get_plan_name(p_plan_id);
FETCH c_get_plan_name into l_dummy;
CLOSE c_get_plan_name;

return l_dummy;

END get_plan_name;

--procedure to return plan ids for the collection ids. This will return all the plan ids
 -- for which data was collected for a given collection id.
PROCEDURE get_planIds_for_CIds(p_local_cids_array IN NUMBER_ARRAY_TYPE,
                       x_local_plan_ids_array out NOCOPY NUMBER_ARRAY_TYPE) IS

l_cid_list varchar2(10000);
i NUMBER;

CURSOR c_plan_ids (p_local_cids VARCHAR2) IS
 SELECT distinct plan_id
 FROM qa_results
 WHERE collection_id in (p_local_cids);


BEGIN

-- convert array to comma delimited string
 for i in 1.. p_local_cids_array.count LOOP
 l_cid_list := l_cid_list ||',' || p_local_cids_array(i);
 END LOOP;

  IF l_cid_list IS NOT NULL THEN
    l_cid_list := substr(l_cid_list, 2);
  END IF;

 FOR c1 in c_plan_ids (l_cid_list)
   LOOP
   i:= i+1;
   x_local_plan_ids_array(i) := c1.plan_id;
  END LOOP;



 END get_planIds_for_CIds;



End CSD_REPAIR_TASK_UTIL;

/
