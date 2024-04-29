--------------------------------------------------------
--  DDL for Package Body AMW_WF_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_WF_HIERARCHY_PKG" as
/*$Header: amwwfhrb.pls 120.1 2005/09/19 15:25:30 appldev noship $*/


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_WF_HIERARCHY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwwfhrb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- have to define these as global because of recursion.
-- make sure to free the memory after use

type t_parent_name    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
v_parent_name	       t_parent_name;
type t_child_name    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
v_child_name	       t_child_name;
type t_transition_parent_list    IS   table of  wf_activity_transitions.from_process_activity%type INDEX BY BINARY_INTEGER;
v_transition_parent_list	       t_transition_parent_list;
type t_org_parent_id    IS   table of  Amw_Process_Org_Relations.parent_process_id%type INDEX BY BINARY_INTEGER;
v_org_parent_id	       t_org_parent_id;
type t_org_child_id    IS   table of  Amw_Process_Org_Relations.child_process_id%type INDEX BY BINARY_INTEGER;
v_org_child_id	       t_org_child_id;

type t_parent_id    IS   table of  amw_process.process_id%type;
v_parent_id	       t_parent_id;
type t_child_id    IS   table of  amw_process.process_id%type;
v_child_id	       t_child_id;

oldCountProc number := 0;
oldCountProcDown number := 0;
oldCount number := 0;
oldCountDown number := 0;

child_num number := 0;
parent_num number := 0;
transition_order number := 0;
input_instance_id number := 0;

org_parent_num  number := 0;
org_child_num  number := 0;

oldCount1 number := 0;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure write_amw_process (
 p_process_name			   IN VARCHAR2,
 p_SIGNIFICANT_PROCESS_FLAG        IN VARCHAR2,
 p_STANDARD_PROCESS_FLAG           IN VARCHAR2,
 p_APPROVAL_STATUS                 IN VARCHAR2,
 p_CERTIFICATION_STATUS            IN VARCHAR2,
 p_PROCESS_OWNER_ID                IN NUMBER,
 p_PROCESS_CATEGORY                IN VARCHAR2,
 p_APPLICATION_OWNER_ID            IN NUMBER,
 p_FINANCE_OWNER_ID                IN NUMBER,
 p_commit		           in varchar2 := FND_API.G_FALSE,
 p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
 p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
 x_return_status		   out nocopy varchar2,
 x_msg_count			   out nocopy number,
 x_msg_data			   out nocopy varchar2
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'write_amw_process';

-- 8.1.7 compatibility issue
 /*
type t_name    IS   table of  amw_process.name%type INDEX BY varchar2(30);
v_name		       t_name;

type t_amwp_name       is table of amw_process.name%type;
v_amwp_name 	       t_amwp_name;
*/
-- 8.1.7 compatibility issue
/*
type t_final_list    IS   table of  amw_process.name%type INDEX BY varchar2(30);
v_final_list		       t_final_list;
*/
type t_forall_list    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
v_forall_list		       t_forall_list;

type t_forall_final_list    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
v_forall_final_list		       t_forall_final_list;

 -- 8.1.7 compatibility issue
/*
cursor	c_amwp_name is
select	name
from 	amw_process;
*/

hash_value NUMBER;
v_index NUMBER;
xst BOOLEAN;
insert_row_cnt NUMBER;
l_std_process_flag varchar2(30);

l_return_status	varchar2(10);
l_msg_count	number;
l_msg_data	varchar2(4000);
l_dummy number;
exists_in_final boolean;
final_row_cnt number;


begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

select fnd_profile.value('AMW_SET_STD_PROCESS') into l_std_process_flag from dual;

 -- 8.1.7 compatibility issue
/*
open c_amwp_name;
loop
	fetch c_amwp_name bulk collect into v_amwp_name;
	exit when c_amwp_name%notfound;
end loop;
close c_amwp_name;


v_index := v_amwp_name.first;
while v_index <= v_amwp_name.last
loop
--	hash_value := dbms_utility.get_hash_value(v_amwp_name(v_index), 1000, 5625);
	v_name(v_amwp_name(v_index)) := v_amwp_name(v_index);
v_index := v_amwp_name.next(v_index);
end loop;
*/
find_hierarchy_children(p_process_name);
find_hierarchy_parent(p_process_name);

insert_row_cnt := 0;

-- v_final_list is being used to weed out duplicates
FOR i IN 1..v_child_name.count LOOP
 -- 8.1.7 compatibility issue
/*
--kosriniv	xst := v_name.exists(dbms_utility.get_hash_value(v_child_name(i), 1000, 5625));
	xst := v_name.exists(v_child_name(i));
	if xst = false then
--kosriniv		v_final_list(dbms_utility.get_hash_value(v_child_name(i), 1000, 5625)) := v_child_name(i);
		v_final_list(v_child_name(i)) := v_child_name(i);
	end if;
*/
    begin
        xst := false;
        select 1
        into l_dummy
        from amw_process
        where name = v_child_name(i);
        xst := true;
    exception
        when no_data_found then
             xst := false;
        when too_many_rows then -- this is of course improbabable, still...
             xst := true;
    end;
	if xst = false then
       	insert_row_cnt := insert_row_cnt + 1;
        v_forall_list(insert_row_cnt) := v_child_name(i);
	end if;

END LOOP;

FOR j IN 1..v_parent_name.count LOOP
 -- 8.1.7 compatibility issue
/*
--kosriniv		xst := v_name.exists(dbms_utility.get_hash_value(v_parent_name(j), 1000, 5625));
	xst := v_name.exists(v_parent_name(j));
	if (xst = false) AND (v_parent_name(j) <> 'ROOT') then
--kosriniv		v_final_list(dbms_utility.get_hash_value(v_parent_name(j), 1000, 5625)) := v_parent_name(j);
		v_final_list(v_parent_name(j)) := v_parent_name(j);
	end if;
*/
    begin
        xst := false;
        select 1
        into l_dummy
        from amw_process
        where name = v_parent_name(j);
        xst := true;
    exception
        when no_data_found then
             xst := false;
        when too_many_rows then -- this is of course improbabable, still...
             xst := true;
    end;
	if (xst = false) AND (v_parent_name(j) <> 'ROOT') then
       	insert_row_cnt := insert_row_cnt + 1;
        v_forall_list(insert_row_cnt) := v_parent_name(j);
	end if;

END LOOP;


-- added by abedajna
-- but now forall list may contain duplicate values. Let's weed those duplicates out.
-- just to keep things simple, I'll use a double loop
final_row_cnt := 0;
FOR i IN 1..v_forall_list.count LOOP
        exists_in_final := false;
        FOR j IN 1..v_forall_final_list.count LOOP
            if v_forall_final_list(j) = v_forall_list(i) then
                  exists_in_final := true;
                  exit;
            end if;
        end loop;
        if exists_in_final = false then
            final_row_cnt := final_row_cnt + 1;
            v_forall_final_list(final_row_cnt) := v_forall_list(i);
        end if;
END LOOP;



 -- 8.1.7 compatibility issue
/*
v_index := v_final_list.first;
insert_row_cnt := 0;
while v_index <= v_final_list.last
loop
	insert_row_cnt := insert_row_cnt + 1;
	v_forall_list(insert_row_cnt) := v_final_list(v_index);
	v_index := v_final_list.next(v_index);
end loop;
*/

/* v_index := v_forall_list.first;
dbms_output.put_line('PRINTING FORALL LIST');
while v_index <= v_forall_list.last
loop
	dbms_output.put_line('index: '||v_index||' value: '||v_forall_list(v_index));
	v_index := v_forall_list.next(v_index);
end loop; */


--FORALL v_ind IN v_forall_list.FIRST..v_forall_list.LAST
FORALL v_ind IN 1..final_row_cnt
      INSERT INTO amw_process(   PROCESS_REV_ID,
				 PROCESS_ID,
				 SIGNIFICANT_PROCESS_FLAG,
				 STANDARD_PROCESS_FLAG,
				 APPROVAL_STATUS,
				 CERTIFICATION_STATUS,
				 PROCESS_OWNER_ID,
				 PROCESS_CATEGORY,
				 APPLICATION_OWNER_ID,
				 FINANCE_OWNER_ID,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_VERSION_NUMBER,
				 ITEM_TYPE,
				 NAME )
				VALUES
				(AMW_PROCESS_S.nextval,
         			AMW_PROCESS_S.nextval,
				p_SIGNIFICANT_PROCESS_FLAG,
				l_std_process_flag,
				p_APPROVAL_STATUS,
				p_CERTIFICATION_STATUS,
				decode(p_PROCESS_OWNER_ID, -1, to_number(null), p_PROCESS_OWNER_ID),
				p_PROCESS_CATEGORY,
				decode(p_APPLICATION_OWNER_ID, -1, to_number(null), p_APPLICATION_OWNER_ID),
				decode(p_FINANCE_OWNER_ID, -1, to_number(null), p_FINANCE_OWNER_ID),
				sysdate,
				G_USER_ID,
				sysdate,
				G_USER_ID,
				G_LOGIN_ID,
				1,
				'AUDITMGR',
				v_forall_final_list(v_ind));


v_parent_name.delete;
parent_num := 0;
v_child_name.delete;
child_num := 0;
--v_name.delete;
--v_amwp_name.trim;

synch_hierarchy_amw_process( l_return_status, l_msg_count, l_msg_data);

exception

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end write_amw_process;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure find_hierarchy_children(p_process_name in varchar2)
is
  cursor c1 (l_name varchar2) is
    select CHILD_PROCESS_NAME
	from amw_wf_hierarchy_v
    where PARENT_PROCESS_NAME=l_name;

  c1_rec c1%rowtype;

begin
  for c1_rec in c1(p_process_name) loop
	  exit when c1%notfound;
	  child_num := child_num + 1;
	  v_child_name(child_num) := c1_rec.CHILD_PROCESS_NAME;
          find_hierarchy_children(p_process_name =>c1_rec.CHILD_PROCESS_NAME);
  end loop;
end find_hierarchy_children;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure find_hierarchy_parent(p_process_name in varchar2)
is
  cursor c1 (l_name varchar2) is
    select PARENT_PROCESS_NAME
	from amw_wf_hierarchy_v
    where CHILD_PROCESS_NAME=l_name;

  c1_rec c1%rowtype;

begin
  for c1_rec in c1(p_process_name) loop
	  exit when c1%notfound;
	  parent_num := parent_num + 1;
	  v_parent_name(parent_num) := c1_rec.PARENT_PROCESS_NAME;
          find_hierarchy_parent(p_process_name =>c1_rec.PARENT_PROCESS_NAME);
  end loop;

end find_hierarchy_parent;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure synch_hierarchy_amw_process( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2)
is
begin
x_return_status	:= 'S';
x_msg_count := 0;
x_msg_data := null;
null;
end synch_hierarchy_amw_process;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


/*
** procedure synch_hierarchy_amw_process(errbuf       OUT NOCOPY      VARCHAR2,
** 				         retcode      OUT NOCOPY      NUMBER)
** is
**
** type t_amwp_name       is table of amw_process.name%type;
** v_amwp_name 	       t_amwp_name;
** type t_delete_list    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
** v_delete_list		       t_delete_list;
** type t_child_list    IS   table of  amw_process.name%type INDEX BY BINARY_INTEGER;
** v_child_list		       t_child_list;
**
** root_process_name amw_process.name%type;
** v_index NUMBER;
** xst BOOLEAN;
** delete_row_cnt NUMBER;
** conc_status        BOOLEAN;
**
** cursor	c_amwp_name is
** select	name
** from 	amw_process;
**
** begin
**
** retcode := 0;
** errbuf := null;
**
** open c_amwp_name;
** loop
** 	fetch c_amwp_name bulk collect into v_amwp_name;
** 	exit when c_amwp_name%notfound;
** end loop;
** close c_amwp_name;
**
**
** select name
** into root_process_name
** from amw_process
** where process_id = -1;
**
** find_hierarchy_children(root_process_name);
**
** FOR i IN 1..v_child_name.count LOOP
** 	v_child_list(dbms_utility.get_hash_value(v_child_name(i), 1000, 5625)) := v_child_name(i);
** END LOOP;
**
** delete_row_cnt := 0;
** v_index := v_amwp_name.first;
** while v_index <= v_amwp_name.last
** loop
** 	xst := v_child_list.exists(dbms_utility.get_hash_value(v_amwp_name(v_index), 1000, 5625));
** 	if ( (xst = false) AND (root_process_name <> v_amwp_name(v_index)) ) then
** 		delete_row_cnt := delete_row_cnt + 1;
** 		v_delete_list(delete_row_cnt) := v_amwp_name(v_index);
** 	end if;
** 	v_index := v_amwp_name.next(v_index);
** end loop;
**
**
** v_index := v_delete_list.first;
** fnd_file.put_line(fnd_file.log, 'PRINTING DELETE LIST');
** while v_index <= v_delete_list.last
** loop
** 	fnd_file.put_line(fnd_file.log, 'index: '||v_index||' value: '||v_delete_list(v_index));
** 	v_index := v_delete_list.next(v_index);
** end loop;
**
**
** FORALL v_ind IN 1..delete_row_cnt
** 	DELETE from amw_process
** 	where name = v_delete_list(v_ind);
**
**
** v_child_name.delete;
** child_num := 0;
** v_child_list.delete;
** v_delete_list.delete;
** v_amwp_name.trim;
**
** commit;
**
** exception
**     when others then
** 	retcode := 1;
** 	errbuf := SUBSTR(SQLERRM, 1,240);
**	fnd_file.put_line(fnd_file.log,errbuf);
**	conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);
**
** end synch_hierarchy_amw_process;
*/

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


function find_transition_order(p_instance_id in number) return number
is
begin
  transition_order := 0;
  input_instance_id := p_instance_id;
  if p_instance_id is null then return 0; end if;
  find_transition_children(p_instance_id => p_instance_id);
  v_transition_parent_list.delete;
  return transition_order;
end find_transition_order;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure find_transition_children(p_instance_id in number)
is
  cursor ct (l_instance_id number) is
    select to_process_activity
	from wf_activity_transitions
    where from_process_activity = l_instance_id;

  ct_rec ct%rowtype;

begin
  for ct_rec in ct(p_instance_id) loop
          -- check for loops. If loops exist, IGNORE the last arrow that leads back to the parent.
	  -- A loop means that P is a child of P, but P as a child of P does not contribute to
	  -- increase the transition children count.
	  exit when ct%notfound or v_transition_parent_list.exists( ct_rec.to_process_activity );
	  if ct_rec.to_process_activity <> input_instance_id then
		  transition_order := transition_order + 1;
	  end if;
 	  v_transition_parent_list( ct_rec.to_process_activity ) := ct_rec.to_process_activity;
	  -- dbms_output.put_line('transition_order: '||transition_order||' to_process_activity: '||ct_rec.to_process_activity);
          find_transition_children(p_instance_id =>ct_rec.to_process_activity);
  end loop;

end find_transition_children;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

procedure find_org_hierarchy_parent(p_org_id in number, p_process_id in number)
is
  cursor c10 (l_org_id number, l_process_id number) is
    select PARENT_PROCESS_ID
	from Amw_Process_Org_Relations
    where CHILD_PROCESS_ID=l_process_id
    and organization_id = l_org_id;

  c10_rec c10%rowtype;

begin
  for c10_rec in c10(p_org_id, p_process_id) loop
	  exit when c10%notfound;
	  org_parent_num := org_parent_num + 1;
	  v_org_parent_id(org_parent_num) := c10_rec.PARENT_PROCESS_ID;
          find_org_hierarchy_parent(p_org_id => p_org_id, p_process_id => c10_rec.PARENT_PROCESS_ID);
  end loop;
end find_org_hierarchy_parent;



------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure find_org_hierarchy_children(p_org_id in number, p_process_id in number)
is
  cursor c11 (l_org_id number, l_process_id number) is
    select CHILD_PROCESS_ID
	from Amw_Process_Org_Relations
    where PARENT_PROCESS_ID=l_process_id
    and organization_id = l_org_id;

  c11_rec c11%rowtype;

begin
  for c11_rec in c11(p_org_id, p_process_id) loop
	  exit when c11%notfound;
	  org_child_num := org_child_num + 1;
	  v_org_child_id(org_child_num) := c11_rec.CHILD_PROCESS_ID;
          find_org_hierarchy_children(p_org_id => p_org_id, p_process_id => c11_rec.CHILD_PROCESS_ID);
  end loop;
end find_org_hierarchy_children;



------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------



procedure reset_process_risk_ctrl_count is

type rec_amw_counts IS record
        (process_id                amw_process.process_id%type,
	no_assoc_risks		   amw_process.risk_count%type,
	no_assoc_controls	   amw_process.control_count%type,
	risk_count		   amw_process.risk_count%type,
	control_count		   amw_process.control_count%type);


 v_rec_amw_counts	rec_amw_counts;
 type t_amw_counts    IS   table of rec_amw_counts index by binary_integer;
 v_amw_counts t_amw_counts;

 cursor  c_populate_amw_counts is
 select process_id, risk_count, control_count, 0, 0 from amw_process;

 v_index         NUMBER;
 l_risk_count    number;
 l_control_count number;
 insert_row_cnt  number;

begin

-- updating every process in amw_process with its risk/ctrl count

	update amw_process ap
	set risk_count =
	(select count(ara.risk_id)
	from amw_risk_associations ara
	where pk1 = ap.process_id
	and object_type = 'PROCESS'),
	control_count =
	(select count(distinct aca.control_id)
	from amw_control_associations aca, amw_risk_associations ara
	where ara.pk1 = ap.process_id
	and ara.object_type = 'PROCESS'
	and aca.pk1 = ara.risk_id
	and aca.object_type = 'RISK');


   open c_populate_amw_counts;
   loop
       fetch c_populate_amw_counts into v_rec_amw_counts;
       exit when c_populate_amw_counts%notfound;
       v_amw_counts(v_rec_amw_counts.process_id) := v_rec_amw_counts;
   end loop;
   close c_populate_amw_counts;


    v_index := v_amw_counts.first;
    while v_index <= v_amw_counts.last
    loop

	select nvl(sum(risk_count), 0), nvl(sum(control_count), 0)
	into l_risk_count, l_control_count
	from amw_process amwp, Amw_Proc_Hierarchy_Denorm apdenorm
	where apdenorm.process_id = v_index
	and apdenorm.up_down_ind = 'D'
	and amwp.process_id = apdenorm.parent_child_id;

	v_amw_counts(v_index).risk_count :=  l_risk_count + v_amw_counts(v_index).no_assoc_risks;
	v_amw_counts(v_index).control_count :=  l_control_count + v_amw_counts(v_index).no_assoc_controls;

        v_index := v_amw_counts.next(v_index);
    end loop;


    v_index := v_amw_counts.first;
    while v_index <= v_amw_counts.last
    loop
	update amw_process
	set risk_count = v_amw_counts(v_index).risk_count,
	control_count = v_amw_counts(v_index).control_count
	where process_id = v_index;

        v_index := v_amw_counts.next(v_index);
    end loop;

exception
when deadlock_detected then
    AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_DEADLOCK_DETECTED');
    raise amw_deadlock_detected;

end reset_process_risk_ctrl_count;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure reset_proc_org_risk_ctrl_count( p_org_id   IN NUMBER) is

type rec_amw_porg_counts IS record
        (process_id                amw_process_organization.process_id%type,
	no_assoc_risks		   amw_process_organization.risk_count%type,
	no_assoc_controls	   amw_process_organization.control_count%type,
	risk_count		   amw_process_organization.risk_count%type,
	control_count		   amw_process_organization.control_count%type);


v_rec_amw_porg_counts	rec_amw_porg_counts;
type t_amw_porg_counts    IS   table of rec_amw_porg_counts index by binary_integer;
v_amw_porg_counts t_amw_porg_counts;

cursor  c_populate_amw_org_counts(l_org_id number) is
select process_id, risk_count, control_count, 0, 0
from amw_process_organization
where organization_id = l_org_id
and end_date is null;

cursor c_org(p_org_id number) is
select distinct organization_id from amw_process_organization where organization_id = nvl(p_org_id, organization_id) and end_date is null;

l_org		number;
v_index         NUMBER;
l_risk_count    number;
l_control_count number;
insert_row_cnt  number;

begin
	update amw_process_organization apo
	set risk_count =
	(select count(ara.risk_id)
	from amw_risk_associations ara
	where pk1 = apo.process_organization_id
	and object_type = 'PROCESS_ORG'),
	control_count =
	(select count(distinct aca.control_id)
	from amw_control_associations aca, amw_risk_associations ara
	where ara.pk1 = apo.process_organization_id
	and ara.object_type = 'PROCESS_ORG'
	and aca.pk1 = ara.risk_association_id
	and aca.object_type = 'RISK_ORG')
	where organization_id = nvl(p_org_id, organization_id)
	and   end_date is null;

open c_org(p_org_id);
loop
    fetch c_org into l_org;
    exit when c_org%notfound;
--dbms_output.put_line('new org: '||l_org);
    open c_populate_amw_org_counts(l_org);
    loop
        fetch c_populate_amw_org_counts into v_rec_amw_porg_counts;
        exit when c_populate_amw_org_counts%notfound;
        v_amw_porg_counts(v_rec_amw_porg_counts.process_id) := v_rec_amw_porg_counts;
    end loop;
    close c_populate_amw_org_counts;

    v_index := v_amw_porg_counts.first;
    while v_index <= v_amw_porg_counts.last
    loop

	select nvl(sum(risk_count), 0), nvl(sum(control_count), 0)
	into l_risk_count, l_control_count
	from amw_process_organization amwp, Amw_Org_Hierarchy_Denorm aodenorm
	where  aodenorm.organization_id = l_org
	and aodenorm.process_id = v_index
	and aodenorm.up_down_ind = 'D'
	and amwp.process_id = aodenorm.parent_child_id
	and amwp.organization_id = l_org
	and amwp.end_date is null;

	v_amw_porg_counts(v_index).risk_count :=  l_risk_count + v_amw_porg_counts(v_index).no_assoc_risks;
	v_amw_porg_counts(v_index).control_count :=  l_control_count + v_amw_porg_counts(v_index).no_assoc_controls;

        v_index := v_amw_porg_counts.next(v_index);
    end loop;


    v_index := v_amw_porg_counts.first;
    while v_index <= v_amw_porg_counts.last
    loop

	update amw_process_organization
	set risk_count = v_amw_porg_counts(v_index).risk_count,
	control_count = v_amw_porg_counts(v_index).control_count
	where process_id = v_index
	and organization_id = l_org
	and end_date is null;

        v_index := v_amw_porg_counts.next(v_index);
    end loop;

    v_amw_porg_counts.delete;

end loop;
close c_org;

exception
when deadlock_detected then
    AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_DEADLOCK_DETECTED');
    raise amw_deadlock_detected;

end reset_proc_org_risk_ctrl_count;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

procedure reset_proc_org_risk_ctrl_count is
begin
	reset_proc_org_risk_ctrl_count(p_org_id => null);
end reset_proc_org_risk_ctrl_count;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------



procedure populate_flatlist(p_org_id in number) is

cursor c11(l_org_id number) is
	select process_id from amw_process_organization where organization_id = l_org_id and end_date is null;

type t_apo_id          is table of amw_process_organization.process_id%type;
v_apo_id 	       t_apo_id;

v_index number;
v_indexDown number;
j number := 0;
jDown number := 0;
oldParentCount number := 0;
oldChildCount number := 0;
l_dummy number;


begin
delete from Amw_Org_Hierarchy_Denorm where organization_id = p_org_id;
open c11(p_org_id);
loop
    fetch c11 bulk collect into v_apo_id;
    exit when c11%notfound;
end loop;
close c11;

-- if the tables have been deleted ...
oldParentCount := v_org_parent_id.count;
if (oldParentCount = 0) then
    oldCount := 0;
end if;
oldChildCount := v_org_child_id.count;
if (oldChildCount = 0) then
    oldCountDown := 0;
end if;


v_index := v_apo_id.first;
while v_index <= v_apo_id.last
loop

-- insert upward hierarchy

	find_org_hierarchy_parent(p_org_id, v_apo_id(v_index));
	j := oldCount + 1;
	-- opportunity exists for performance improvement here
	FOR i IN j..v_org_parent_id.count LOOP

		begin
			select 1 into l_dummy
			from Amw_Org_Hierarchy_Denorm
			where Organization_Id = p_org_id
			and Process_Id = v_apo_id(v_index)
			and Parent_Child_Id = v_org_parent_id(i)
			and Up_Down_Ind = 'U';

		exception
			when no_data_found then
				insert into Amw_Org_Hierarchy_Denorm
				(Organization_Id,
				Process_Id,
				Parent_Child_Id,
				Up_Down_Ind,
				Last_Update_Date,
				Last_Updated_By,
				Creation_Date,
				Created_By,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER
				)
				values
				(p_org_id,
				v_apo_id(v_index),
				v_org_parent_id(i),
				'U',
				sysdate,
				G_USER_ID,
				sysdate,
				G_USER_ID,
				G_LOGIN_ID,
				1);
		end;
	END LOOP;
	oldCount := v_org_parent_id.count;


-- insert downward hierarchy

	find_org_hierarchy_children(p_org_id, v_apo_id(v_index));
	jDown := oldCountDown + 1;
	-- opportunity exists for performance improvement here
	FOR i IN jDown..v_org_child_id.count LOOP

		begin
			select 1 into l_dummy
			from Amw_Org_Hierarchy_Denorm
			where Organization_Id = p_org_id
			and Process_Id = v_apo_id(v_index)
			and Parent_Child_Id = v_org_child_id(i)
			and Up_Down_Ind = 'D';

		exception
			when no_data_found then
				insert into Amw_Org_Hierarchy_Denorm
				(Organization_Id,
				Process_Id,
				Parent_Child_Id,
				Up_Down_Ind,
				Last_Update_Date,
				Last_Updated_By,
				Creation_Date,
				Created_By,
				Last_Update_Login,
				OBJECT_VERSION_NUMBER
				)
				values
				(p_org_id,
				v_apo_id(v_index),
				v_org_child_id(i),
				'D',
				sysdate,
				G_USER_ID,
				sysdate,
				G_USER_ID,
				G_LOGIN_ID,
				1);
		end;
	END LOOP;
	oldCountDown := v_org_child_id.count;

v_index := v_apo_id.next(v_index);
end loop;
-- if i delete this table, it cribs when I try to execute this procedure multiple
-- times in the same session.
-- v_org_parent_id.delete;
exception
when deadlock_detected then
    AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_DEADLOCK_DETECTED');
    raise amw_deadlock_detected;
end populate_flatlist;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- get the process hierarchy IN AMW (i.e. the process should exist in amw_process) and
-- populate Amw_Process_Org_Relations
procedure create_org_relations( p_process_name		in varchar2,
			        p_org_id		in number,
		       		x_return_status		out nocopy varchar2,
				x_msg_count		out nocopy number,
				x_msg_data		out nocopy varchar2)
is
  cursor c1 (l_name varchar2) is
    select child_nondisp_name
	from amw_process_hierarchy_v
    where parent_nondisp_name=l_name;

  c1_rec c1%rowtype;
  parent_id number;
  child_id number;
  instance_id number;
  l_dummy number;

begin
-- much scope for performance improvement lies here. Too many sql's being fired.
  for c1_rec in c1(p_process_name) loop
	  exit when c1%notfound;

	  select process_id into parent_id from amw_process where name = p_process_name;
	  select process_id into child_id from amw_process where name = c1_rec.child_nondisp_name;

          select  wpa.instance_id
          into instance_id
	  from wf_process_activities wpa,
	  wf_activities wa
	  where wpa.process_item_type = 'AUDITMGR'
	  and wpa.process_name = p_process_name
	  and wpa.process_name =  wa.name
	  and wa.end_date is null
	  and wa.item_type = 'AUDITMGR'
	  and wpa.process_version = wa.version
	  and wpa.activity_name = c1_rec.child_nondisp_name;

	  assoc_process_org_hier(child_id, p_org_id, parent_id,  x_return_status, x_msg_count, x_msg_data);

		begin

		select 1
		into l_dummy
		from Amw_Process_Org_Relations
		where ORGANIZATION_ID = p_org_id
		and PARENT_PROCESS_ID = parent_id
		and CHILD_PROCESS_ID = child_id;

		exception
		when no_data_found then

			  insert into Amw_Process_Org_Relations
				 (ORGANIZATION_ID,
				 PARENT_PROCESS_ID,
				 CHILD_PROCESS_ID,
				 INSTANCE_ID,
				 EXCEPTION_PRESENT_FLAG,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_VERSION_NUMBER)
				 values
				 (p_org_id,
				 parent_id,
				 child_id,
				 instance_id,
				 'N',
				 sysdate,
				 G_USER_ID,
				 sysdate,
				 G_USER_ID,
				 G_LOGIN_ID,
				 1);
		end;

	  create_org_relations(c1_rec.child_nondisp_name, p_org_id, x_return_status, x_msg_count, x_msg_data);
  end loop;
end create_org_relations;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure assoc_process_org_hier(
		p_process_id		in Number,
		p_org_id		in Number,
		p_parent_process_id	in Number,
		x_return_status		out nocopy varchar2,
		x_msg_count		out nocopy number,
		x_msg_data		out nocopy varchar2)
is
  l_apo_type AMW_PROC_ORG_HIERARCHY_PVT.apo_type;

begin
	l_apo_type.process_id := p_process_id;
	l_apo_type.organization_id := p_org_id;

	AMW_PROC_ORG_HIERARCHY_PVT.associate_process_org(
		          p_apo_type => l_apo_type,
		          p_process_id => p_process_id,
			  p_top_process_id => null,
			  p_organization_id => p_org_id,
			  p_parent_process_id => p_parent_process_id,
			  p_mode => 'ASSOCIATE',
		          x_return_status => x_return_status,
			  x_msg_count => x_msg_count,
		          x_msg_data => x_msg_data );

end assoc_process_org_hier;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure assoc_process_rcm_org_hier(
		p_process_id		in Number,
		p_org_id		in Number,
		p_rcm_assoc     in varchar2 := 'N',
		p_batch_id      in number := null,
		p_rcm_org_intf_id in number := null,
		p_risk_id       in number := null,
		p_control_id    in number := null,
		p_parent_process_id	in Number,
		x_return_status		out nocopy varchar2,
		x_msg_count		out nocopy number,
		x_msg_data		out nocopy varchar2)
is
  l_apo_type AMW_PROC_ORG_HIERARCHY_PVT.apo_type;

begin
	l_apo_type.process_id := p_process_id;
	l_apo_type.organization_id := p_org_id;

    fnd_file.put_line(fnd_file.LOG, 'INSIDE ASSOC_PROCESS_RCM_ORG_HIER');
    fnd_file.put_line(fnd_file.LOG, 'l_apo_type.process_id: '||l_apo_type.process_id);
    fnd_file.put_line(fnd_file.LOG, 'l_apo_type.organization_id: '||l_apo_type.organization_id);
    fnd_file.put_line(fnd_file.LOG, 'p_process_id: '||p_process_id);
    fnd_file.put_line(fnd_file.LOG, 'p_organization_id: '||p_org_id);
    fnd_file.put_line(fnd_file.LOG, 'p_parent_process_id: '||p_parent_process_id);
    fnd_file.put_line(fnd_file.LOG, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

    AMW_PROC_ORG_HIERARCHY_PVT.associate_process_org(
       p_apo_type             => l_apo_type,
	   p_process_id 		  => p_process_id,
	   p_top_process_id 	  => null,
	   p_organization_id 	  => p_org_id,
	   p_parent_process_id 	  => p_parent_process_id,
	   p_rcm_assoc 			  => p_rcm_assoc,
	   p_batch_id 			  => p_batch_id,
	   p_rcm_org_intf_id   	  => p_rcm_org_intf_id,
	   p_risk_id 			  => p_risk_id,
	   p_control_id 		  => p_control_id,
	   p_mode 				  => 'ASSOCIATE',
	   x_return_status 		  => x_return_status,
	   x_msg_count 			  => x_msg_count,
	   x_msg_data 			  => x_msg_data );

   ---npanandi added 10/18/2004:
   ---bugfix for bug 3841334
   ---added below 2 lines to sync up code between main and branch lines
   reset_proc_org_risk_ctrl_count(p_org_id);
   reset_org_count;
   ---npanandi ended fix: 10/18/2004 for bug 3841334
end assoc_process_rcm_org_hier;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- note that "associate" function (as opposed to add function) will always add the process
-- directly under the root node.
procedure associate_org_process(
	p_process_id		in number,
	p_org_id		in number,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2) is

 L_API_NAME CONSTANT VARCHAR2(30) := 'associate_org_process';

p_name varchar2(100);
l_dummy number;
l_return_status  varchar2(100);
l_msg_count  number;
l_msg_data  varchar2(4000);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

		begin

	        assoc_process_org_hier(p_process_id, p_org_id, -1, l_return_status, l_msg_count, l_msg_data);

		select 1
		into l_dummy
		from Amw_Process_Org_Relations
		where ORGANIZATION_ID = p_org_id
		and PARENT_PROCESS_ID = -1
		and CHILD_PROCESS_ID = p_process_id;

		exception
		when no_data_found then


			  insert into Amw_Process_Org_Relations
				 (ORGANIZATION_ID,
				 PARENT_PROCESS_ID,
				 CHILD_PROCESS_ID,
				 INSTANCE_ID,
				 EXCEPTION_PRESENT_FLAG,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_VERSION_NUMBER)
				 values
				 (p_org_id,
				 -1,
				 p_process_id,
				 0,
				 'N',
				 sysdate,
				 G_USER_ID,
				 sysdate,
				 G_USER_ID,
				 G_LOGIN_ID,
				 1);
		end;

	 select name
	 into p_name
	 from amw_process
	 where process_id = p_process_id;

	 create_org_relations(p_name, p_org_id, l_return_status, l_msg_count, l_msg_data);

	 populate_flatlist(p_org_id);
	 reset_proc_org_risk_ctrl_count(p_org_id);
	 reset_org_count;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end associate_org_process;

--npanandi commented this on 10/18/2004, for syncing between the version
--of this API in branch and main
--changed signature of associate_org_process as given below screws up the association
--hence, commented below, and resorted to earlier signature as above
/**
procedure associate_org_process(
	p_process_id		in number,
	p_org_id		in number,
	p_rcm_assoc     in varchar2 := 'N',
    p_batch_id      in number := null,
	p_rcm_org_intf_id in number := null,
    p_risk_id       in number := null,
    p_control_id    in number := null,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2) is

 L_API_NAME CONSTANT VARCHAR2(30) := 'associate_org_process';

p_name varchar2(100);
l_dummy number;
l_return_status  varchar2(100);
l_msg_count  number;
l_msg_data  varchar2(4000);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

        fnd_file.put_line(fnd_file.LOG, 'INSIDE ASSOCIATE_ORG_PROCESS');
		fnd_file.put_line(fnd_file.LOG, 'p_process_id: '||p_process_id);
		fnd_file.put_line(fnd_file.LOG, 'p_org_id: '||p_org_id);
		fnd_file.put_line(fnd_file.LOG, 'p_rcm_assoc: '||p_rcm_assoc);
		fnd_file.put_line(fnd_file.LOG, 'p_batch_id: '||p_batch_id);
		fnd_file.put_line(fnd_file.LOG, 'p_risk_id: '||p_risk_id);
		fnd_file.put_line(fnd_file.LOG, 'p_control_id: '||p_control_id);
		fnd_file.put_line(fnd_file.LOG, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
	    assoc_process_rcm_org_hier(
               p_process_id           => p_process_id,
		       p_org_id		          => p_org_id,
		       p_rcm_assoc            => p_rcm_assoc,
		       p_batch_id             => p_batch_id,
			   p_rcm_org_intf_id      => p_rcm_org_intf_id,
               p_risk_id              => p_risk_id,
               p_control_id           => p_control_id,
			   p_parent_process_id	  => -1,
		       x_return_status		  => l_return_status,
		       x_msg_count		      => l_msg_count,
		       x_msg_data		      => l_msg_data);

		begin

		select 1
		into l_dummy
		from Amw_Process_Org_Relations
		where ORGANIZATION_ID = p_org_id
		and PARENT_PROCESS_ID = -1
		and CHILD_PROCESS_ID = p_process_id;

		exception
		when no_data_found then


			  insert into Amw_Process_Org_Relations
				 (ORGANIZATION_ID,
				 PARENT_PROCESS_ID,
				 CHILD_PROCESS_ID,
				 INSTANCE_ID,
				 EXCEPTION_PRESENT_FLAG,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_VERSION_NUMBER)
				 values
				 (p_org_id,
				 -1,
				 p_process_id,
				 0,
				 'N',
				 sysdate,
				 G_USER_ID,
				 sysdate,
				 G_USER_ID,
				 G_LOGIN_ID,
				 1);
		end;

	 select name
	 into p_name
	 from amw_process
	 where process_id = p_process_id;

	 create_org_relations(p_name, p_org_id, l_return_status, l_msg_count, l_msg_data);

	 populate_flatlist(p_org_id);
	 reset_proc_org_risk_ctrl_count(p_org_id);
	 reset_org_count;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end associate_org_process;
**/
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- p_child_process_id is the process being deleted.
procedure delete_org_relation(
		p_parent_process_id	in number,
		p_child_process_id	in number,
		p_org_id		in number) is

l_exist number := 0;
l_next_level number;
x_return_status varchar2(10);
x_msg_count number;
x_msg_data varchar2(2000);
l_apo_type AMW_PROC_ORG_HIERARCHY_PVT.apo_type;

cursor c1 (l_pid number, p_oid number) is
select CHILD_PROCESS_ID
from Amw_Process_Org_Relations
where PARENT_PROCESS_ID = l_pid
and organization_id = p_oid;


begin
	delete from Amw_Process_Org_Relations
	where ORGANIZATION_ID = p_org_id
	and PARENT_PROCESS_ID = p_parent_process_id
	and CHILD_PROCESS_ID = p_child_process_id;

		select count(ORGANIZATION_ID)
		into l_exist
		from Amw_Process_Org_Relations
		where ORGANIZATION_ID = p_org_id
		and CHILD_PROCESS_ID = p_child_process_id;

		IF l_exist = 0 THEN
/*			disassociate_process_org(p_process_id	=> p_child_process_id,
						p_org_id	=> p_org_id,
						x_return_status	=> x_return_status,
						x_msg_count	=> x_msg_count,
						x_msg_data	=> x_msg_data); */


		l_apo_type.process_id := p_child_process_id;
		l_apo_type.organization_id := p_org_id;


        	AMW_PROC_ORG_HIERARCHY_PVT.associate_process_org(
        		          p_apo_type => l_apo_type,
        		          p_process_id => p_child_process_id,
            			  p_top_process_id => null,
        	    		  p_organization_id => p_org_id,
        		    	  p_parent_process_id => null,
        			      p_mode => 'DISASSOCIATE',
        		          x_return_status => x_return_status,
            			  x_msg_count => x_msg_count,
        		          x_msg_data => x_msg_data );


               	for c1_rec in c1(p_child_process_id, p_org_id) loop
            	  exit when c1%notfound;
                   delete_org_relation(
            		    p_parent_process_id	=> p_child_process_id,
            	    	p_child_process_id	=> c1_rec.CHILD_PROCESS_ID,
                		p_org_id		    => p_org_id);
               	end loop;
		END IF;

  	populate_flatlist(p_org_id);
	reset_proc_org_risk_ctrl_count(p_org_id);
	reset_org_count;


end delete_org_relation;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- get the process hierarchy IN Amw_Process_Org_Relations and fire atomic
-- disassociate api for each.
procedure disassociate_process_org(
	p_process_id		in number,
	p_org_id		in number,
	p_commit		in varchar2 := FND_API.G_FALSE,
	p_validation_level	IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'disassociate_process_org';

  l_apo_type AMW_PROC_ORG_HIERARCHY_PVT.apo_type;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

	-- first disassociate the process itself, then loop through the org hierarchy
	l_apo_type.process_id := p_process_id;
	l_apo_type.organization_id := p_org_id;

	delete from Amw_Process_Org_Relations
	where ORGANIZATION_ID = p_org_id
	and CHILD_PROCESS_ID = p_process_id;


	AMW_PROC_ORG_HIERARCHY_PVT.associate_process_org(
		          p_apo_type => l_apo_type,
		          p_process_id => p_process_id,
			  p_top_process_id => null,
			  p_organization_id => p_org_id,
			  p_parent_process_id => null,
			  p_mode => 'DISASSOCIATE',
		          x_return_status => x_return_status,
			  x_msg_count => x_msg_count,
		          x_msg_data => x_msg_data );

	disassoc_proc_org_hier(p_process_id =>p_process_id, p_org_id => p_org_id);

	delete from amw_process_organization
	where organization_id = p_org_id
	and end_date is not null;

	populate_flatlist(p_org_id);
	reset_proc_org_risk_ctrl_count(p_org_id);
	reset_org_count;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);


  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);


end disassociate_process_org;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure disassoc_proc_org_hier(p_process_id in number, p_org_id in number) is

  cursor c1 (l_id number, l_oid number) is
    select CHILD_PROCESS_ID
	from Amw_Process_Org_Relations
    where PARENT_PROCESS_ID=l_id
    and organization_id = l_oid;

  c1_rec c1%rowtype;

l_return_status  varchar2(30);
l_msg_count  number;
l_msg_data varchar2(4000);

l_apo_type AMW_PROC_ORG_HIERARCHY_PVT.apo_type;

begin
	-- loop through the org hierarchy and disassociate the children
	for c1_rec in c1(p_process_id, p_org_id) loop
	  exit when c1%notfound;

			delete from Amw_Process_Org_Relations
			where ORGANIZATION_ID = p_org_id
			and PARENT_PROCESS_ID = p_process_id
			and CHILD_PROCESS_ID = c1_rec.CHILD_PROCESS_ID;

			l_apo_type.process_id := c1_rec.CHILD_PROCESS_ID;
			l_apo_type.organization_id := p_org_id;

			AMW_PROC_ORG_HIERARCHY_PVT.associate_process_org(
				          p_apo_type => l_apo_type,
				          p_process_id => c1_rec.CHILD_PROCESS_ID,
					  p_top_process_id => null,
					  p_organization_id => p_org_id,
					  p_parent_process_id => null,
					  p_mode => 'DISASSOCIATE',
				          x_return_status => l_return_status,
					  x_msg_count => l_msg_count,
				          x_msg_data => l_msg_data );

			disassoc_proc_org_hier(p_process_id =>c1_rec.CHILD_PROCESS_ID, p_org_id => p_org_id);
	end loop;
exception
when deadlock_detected then
    AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_DEADLOCK_DETECTED');
    raise amw_deadlock_detected;

end disassoc_proc_org_hier;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- associate: everytime a process is associated (or added), the risks/ctrl/ap/acct associated with that
-- process in the library get associated too. Say a process P is associatd to org O. If I
-- associate the same process P again to org O, the existing association records will be
-- overwritten with the most current information.

-- disassociate: If I "delete" a process, it is not necessarily disassociated.
-- A process will be "disasociated" from an org ONLY if there's no more existance of that
-- process in the hierarchy for that particular org. (Note that a process can exist at
-- multiple leaves).

procedure modify_org_relation (
p_mode				in varchar2,
p_parent_process_id		in number,
p_child_process_id		in number,
p_org_id			in number,
p_exception_yes			in varchar2,
p_process_owner_party_id	in number,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

  L_API_NAME CONSTANT VARCHAR2(30) := 'modify_org_relation';
  p_name varchar2(100);
  l_dummy number;
  l_return_status  varchar2(100);
  l_msg_count  number;
  l_msg_data  varchar2(4000);
  l_person_id number;
  l_header varchar2(4000);
  l_body varchar2(4000);
  l_notif_id number;
  l_ret_status  varchar2(30);
  l_parent_disp_name  varchar2(100);
  l_child_disp_name  varchar2(100);
  l_org_name  varchar2(100);

  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_process_owner_party_id <> 0 then

	select employee_id
	into l_person_id
	from AMW_EMPLOYEES_CURRENT_V
	where party_id = p_process_owner_party_id;

	select watl.display_name
	into  l_parent_disp_name
	from wf_activities_tl watl, wf_activities wa, amw_process ap
	where ap.process_id = p_parent_process_id
	and ap.name = wa.name
	and wa.item_type = 'AUDITMGR'
	and wa.end_date is null
	and watl.item_type = 'AUDITMGR'
	and watl.name = wa.name
	and watl.version = wa.version
	and watl.language = userenv('LANG');

	select watl.display_name
	into  l_child_disp_name
	from wf_activities_tl watl, wf_activities wa, amw_process ap
	where ap.process_id = p_child_process_id
	and ap.name = wa.name
	and wa.item_type = 'AUDITMGR'
	and wa.end_date is null
	and watl.item_type = 'AUDITMGR'
	and watl.name = wa.name
	and watl.version = wa.version
	and watl.language = userenv('LANG');

	select name
	into l_org_name
	from amw_audit_units_v
	where organization_id = p_org_id;

  else
	l_person_id := 0;
  end if;


  if (p_mode = 'ADD') then

        assoc_process_org_hier(p_child_process_id, p_org_id, p_parent_process_id, l_return_status, l_msg_count, l_msg_data);

  	begin

	select 1
	into l_dummy
	from Amw_Process_Org_Relations
	where ORGANIZATION_ID = p_org_id
	and PARENT_PROCESS_ID = p_parent_process_id
	and CHILD_PROCESS_ID = p_child_process_id;

	exception
        	when no_data_found then

		  insert into Amw_Process_Org_Relations
			 (ORGANIZATION_ID,
			 PARENT_PROCESS_ID,
			 CHILD_PROCESS_ID,
			 INSTANCE_ID,
			 EXCEPTION_PRESENT_FLAG,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 CREATION_DATE,
			 CREATED_BY,
			 LAST_UPDATE_LOGIN,
			 OBJECT_VERSION_NUMBER)
			 values
			 (p_org_id,
			 p_parent_process_id,
			 p_child_process_id,
			 0,
			 p_exception_yes,
			 sysdate,
			 G_USER_ID,
			 sysdate,
			 G_USER_ID,
			 G_LOGIN_ID,
			 1);
	end;

	 select name
	 into p_name
	 from amw_process
	 where process_id = p_child_process_id;

	 create_org_relations(p_name, p_org_id, l_return_status, l_msg_count, l_msg_data);

	 if l_person_id <> 0 then
		 fnd_message.set_name('AMW', 'AMW_PROC_ADD_HEAD');
		 l_header := fnd_message.get;

		 fnd_message.set_name('AMW', 'AMW_PROC_ADD_BODY');
	         fnd_message.set_token('CHILD', l_child_disp_name);
	         fnd_message.set_token('PARENT', l_parent_disp_name);
	         fnd_message.set_token('ORG', l_org_name);
		 l_body := fnd_message.get;

		 AMW_Utility_PVT.send_wf_standalone_message(      p_subject		=> l_header,
								  p_body		=> l_body,
								  p_send_to_person_id	=> l_person_id,
								  x_notif_id		=> l_notif_id,
								  x_return_status	=> l_ret_status);
	 end if;

  elsif (p_mode = 'DEL') then
	delete_org_relation(p_parent_process_id, p_child_process_id, p_org_id);

	 if l_person_id <> 0 then
		 fnd_message.set_name('AMW', 'AMW_PROC_DEL_HEAD');
		 l_header := fnd_message.get;

		 fnd_message.set_name('AMW', 'AMW_PROC_DEL_BODY');
	         fnd_message.set_token('CHILD', l_child_disp_name);
	         fnd_message.set_token('PARENT', l_parent_disp_name);
	         fnd_message.set_token('ORG', l_org_name);
		 l_body := fnd_message.get;

		 AMW_Utility_PVT.send_wf_standalone_message(      p_subject		=> l_header,
								  p_body		=> l_body,
								  p_send_to_person_id	=> l_person_id,
								  x_notif_id		=> l_notif_id,
								  x_return_status	=> l_ret_status);
	 end if;

  end if;

populate_flatlist(p_org_id);
reset_proc_org_risk_ctrl_count(p_org_id);
reset_org_count;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end modify_org_relation;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure reset_org_count is
begin

update amw_process amwp
set amwp.org_count =   (select count(process_organization_id)
                        from amw_process_organization amwpo
                        where amwpo.process_id = amwp.process_id
                        and amwpo.end_date is null);
exception
when deadlock_detected then
    AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_DEADLOCK_DETECTED');
    raise amw_deadlock_detected;
end reset_org_count;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------



/*==============================================================+
 | This procedure is a wrapper for synch_hierarchy_amw_process				       |
 | To use as a concurrent program.											       |
 +==============================================================*/


PROCEDURE sync_hier_amw_process_wrap (
			 errbuf     out nocopy  varchar2,
			 retcode    out nocopy  varchar2 ) IS

x_return_status	varchar2(10);
x_msg_count     	number;
x_msg_data		varchar2(4000);
conc_status 		boolean;
l_msg_index_out     number;
BEGIN

	retcode :=0;
	errbuf :='';
	synch_hierarchy_amw_process( x_return_status => x_return_status ,
                             x_msg_count     => x_msg_count ,
                             x_msg_data      => x_msg_data);

	FND_FILE.PUT_LINE(FND_FILE.LOG,'Return Status :' || x_return_status || ':'||x_msg_count||':'||x_msg_data);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		ROLLBACK;
		retcode := 2;
		IF x_msg_count <> 1 THEN
			FND_MSG_PUB.GET(p_encoded => FND_API.G_FALSE, p_data => x_msg_data,  p_msg_index_out => l_msg_index_out);
		END IF;
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| x_msg_data);
		errbuf := SUBSTR(x_msg_data,1,1000);
	ELSE
		COMMIT;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RETCODE :=2;
		errbuf := SUBSTR(SQLERRM,1,1000);
		conc_status :=FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
END sync_hier_amw_process_wrap;



/*==============================================================+
 | This procedure is a wrapper for reset_process_risk_ctrl_count					       |
 | To use as a concurrent program.											       |
 +==============================================================*/



PROCEDURE reset_process_risk_ctrl_wrap(
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2
			) IS

conc_status 		boolean;

BEGIN
	retcode :=0;
	errbuf :='';
	reset_process_risk_ctrl_count;
	commit;

EXCEPTION

	WHEN OTHERS THEN
		rollback;
		retcode :=2;
		errbuf := SUBSTR(SQLERRM,1,1000);
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

END   reset_process_risk_ctrl_wrap;

/*==============================================================+
 | This procedure is a wrapper for reset_proc_org_risk_ctrl_count				       |
 | To use as a concurrent program.											       |
 +==============================================================*/


procedure reset_proc_org_risk_ctrl_wrap(
			 errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2,
			p_org_id in number
			) is
conc_status boolean;

begin

	retcode :=0;
	errbuf :='';
	if p_org_id is null then
		reset_proc_org_risk_ctrl_count(p_org_id => null);
	else
		reset_proc_org_risk_ctrl_count(p_org_id => p_org_id);
	end if;
	commit;
exception
	when others then
		rollback;
		retcode :=2;
		errbuf :=SUBSTR(SQLERRM,1,1000);
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

end reset_proc_org_risk_ctrl_wrap;



------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

/* Refresh Api:
** Refresh unfortunately is NOT the same as a combination of disassociate and associate.
** Library:
** All
** |---P1
**     |---P2
**          |---P3
**               |---P4
**
** Org:
** All
** |---OP1
**     |---OP2
**          |---OP3
**               |---OP4
**
** Now if I add P41 to P3 and disassociate and associate, this is how the hierarchy in org will look like:
**
** Library:
** All
** |---P1
**     |---P2
**          |---P3
** 	      |---P4
** 	      |---P41
**
** Org:
** All
** |---OP1
**     |---OP2
** |---OP3
**      |---OP4
**      |---OP41
**
** instead of
**
** Org:
** All
** |---OP1
**     |---OP2
**          |---OP3
**               |---OP4
** 	         |---Op41
**
** Thus I need to write a special refresh api.
** Note that if P1 is added to P in the library, P needs to be refreshed in any org for P1 to get reflected there.
** Refreshing P1 will not produce any result as P1 is not there. In short, synchronize the parent.
** Synchronizing is equivalent to disassociating + re-associating, albeit at the old parent node, rather than under the root.
**
**
** To refresh in all orgs, pass -1 for org_id
** To refresh in all orgs without exception, pass -2 for org_id
** To refresh in a particular org, pass org_id
*/

procedure refresh_process_org (
p_process_id			in number,
p_org_id			in number,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'refresh_process_org';

l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
amw_exception    exception;
l_org_id number;

cursor c_all_orgs(l_pid number) is
 select distinct organization_id
 from amw_process_organization
 where process_id = l_pid
 and end_date is null;

cursor c_all_exorgs(l_pid number) is
 select distinct organization_id
 from amw_process_organization
 where process_id = l_pid
 and end_date is null
 and organization_id not in
(select distinct old_pk1 from amw_exceptions_b where ((old_pk2 = l_pid and object_type in ('PROCESS','RISK','CONTROL'))or (object_type = 'PROCESS' and old_pk3 = l_pid)) and old_pk1 is not null)
 and organization_id not in
(select distinct new_pk1 from amw_exceptions_b where ((new_pk2 = l_pid and object_type in ('PROCESS','RISK','CONTROL'))or (object_type = 'PROCESS' and new_pk3 = l_pid)) and new_pk1 is not null);


  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if p_org_id = -1 then

	open c_all_orgs(p_process_id);
	loop
	    fetch c_all_orgs into l_org_id;
	    exit when c_all_orgs%notfound;

		refresh_process_per_org (
		p_process_id	  => p_process_id,
		p_org_id	  => l_org_id,
		x_return_status	  => l_return_status,
		x_msg_count	  => l_msg_count,
		x_msg_data	  => l_msg_data	);

		if l_return_status <> 'S' then
			raise amw_exception;
		end if;

	end loop;
	close c_all_orgs;

  elsif p_org_id = -2 then

	open c_all_exorgs(p_process_id);
	loop
	    fetch c_all_exorgs into l_org_id;
	    exit when c_all_exorgs%notfound;

		refresh_process_per_org (
		p_process_id	  => p_process_id,
		p_org_id	  => l_org_id,
		x_return_status	  => l_return_status,
		x_msg_count	  => l_msg_count,
		x_msg_data	  => l_msg_data	);

		if l_return_status <> 'S' then
			raise amw_exception;
		end if;

	end loop;
	close c_all_exorgs;

  else -- p_org_id has an org value then

	refresh_process_per_org (
	p_process_id	  => p_process_id,
	p_org_id	  => p_org_id,
	x_return_status	  => l_return_status,
	x_msg_count	  => l_msg_count,
	x_msg_data	  => l_msg_data	);

	if l_return_status <> 'S' then
		raise amw_exception;
	end if;

  end if;

  reset_org_count;


exception
  WHEN amw_exception THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end refresh_process_org;


------------------------------------------------------------------------------------------------------------


procedure refresh_process_org (
p_process_id			in number,
p_org_string			in varchar,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'refresh_process_org';
l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
amw_exception    exception;
str              varchar2(4000);
diff		 number;
orgstr		 varchar2(100);
l_org_string     varchar2(4000);
orgid		 number;

  begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

l_org_string := p_org_string;
while LENGTH(l_org_string) <> 0 loop
select LTRIM(l_org_string, '1234567890') into str from dual;
diff := LENGTH(l_org_string) - LENGTH(str);
if  LENGTH(str) is null then  diff := LENGTH(l_org_string); end if;
select SUBSTR(l_org_string, 1, diff) into orgstr from dual;
orgid := to_number(orgstr);

	refresh_process_per_org (
	p_process_id	  => p_process_id,
	p_org_id	  => orgid,
	x_return_status	  => l_return_status,
	x_msg_count	  => l_msg_count,
	x_msg_data	  => l_msg_data	);

	if l_return_status <> 'S' then
		raise amw_exception;
	end if;

select LTRIM(str, 'x') into l_org_string from dual;
end loop;

  reset_org_count;

exception
  WHEN amw_exception THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end refresh_process_org;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure refresh_process_per_org(
p_process_id			in number,
p_org_id			in number,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
) is

l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
l_parent_pid	 number;
l_name		 varchar2(100);
v_index		 number;
amw_exception    exception;

cursor c_parents(l_org number, l_proc number) is
	select parent_process_id
	from Amw_Process_Org_Relations
	where organization_id = p_org_id
	and child_process_id = p_process_id;

type t_parent_pid      is table of amw_process.process_id%type;
v_parent_pid 	       t_parent_pid;

begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

open c_parents(p_org_id, p_process_id);
loop
    fetch c_parents bulk collect into v_parent_pid;
    exit when c_parents%notfound;
end loop;
close c_parents;

if v_parent_pid.count = 0 then
	return;
end if;

disassociate_process_org(
	p_process_id	=> p_process_id,
	p_org_id	=> p_org_id,
	x_return_status	=> l_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);

if l_return_status <> 'S' then
	raise amw_exception;
end if;

v_index := v_parent_pid.first;
while v_index <= v_parent_pid.last
loop

	assoc_process_org_hier(p_process_id, p_org_id, v_parent_pid(v_index),l_return_status, l_msg_count, l_msg_data);

	if l_return_status <> 'S' then
		raise amw_exception;
	end if;

	insert into Amw_Process_Org_Relations
		 (ORGANIZATION_ID,
		 PARENT_PROCESS_ID,
		 CHILD_PROCESS_ID,
		 INSTANCE_ID,
		 EXCEPTION_PRESENT_FLAG,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 OBJECT_VERSION_NUMBER)
		 values
		 (p_org_id,
		 v_parent_pid(v_index),
		 p_process_id,
		 0,
		 'N',
		 sysdate,
		 G_USER_ID,
		 sysdate,
		 G_USER_ID,
		 G_LOGIN_ID,
		 1);

v_index := v_parent_pid.next(v_index);
end loop;


 select name
 into l_name
 from amw_process
 where process_id = p_process_id;

 create_org_relations(l_name, p_org_id, l_return_status, l_msg_count, l_msg_data);

if l_return_status <> 'S' then
	raise amw_exception;
end if;

 populate_flatlist(p_org_id);
 reset_proc_org_risk_ctrl_count(p_org_id);
 v_parent_pid.trim;

exception

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN amw_exception THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end refresh_process_per_org;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function check_org_children_exist(p_process_id in number) return number
is
l_pname varchar2(30);
l_dummy number;
j number;
begin
	select name into l_pname from amw_process where process_id = p_process_id;
	find_hierarchy_children(l_pname);
	j := oldCount1 + 1;
        FOR i IN j..v_child_name.count LOOP
		begin
			select 1 into l_dummy
			from amw_process_organization
			where end_date is null
			and process_id = (select process_id from amw_process where name = v_child_name(i));
			oldCount1 := v_child_name.count;
			return 1;
		exception
			when too_many_rows then
				oldCount1 := v_child_name.count;
				return 1;
			when no_data_found then
				null;
		end;
	END LOOP;
	oldCount1 := v_child_name.count;
	return 0;
end check_org_children_exist;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- Check if current process or any of its children exists in any org. If yes, return 1, else 0
procedure check_org_exist( p_process_id		 in number,
			   p_out		 out nocopy number,
		           x_return_status       out nocopy varchar2,
                           x_msg_count           out nocopy number,
                           x_msg_data            out nocopy varchar2)
is
l_dummy number;
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	select 1 into l_dummy
	from amw_process_organization
	where process_id = p_process_id
	and end_date is null;

	p_out := 1;
exception
	when too_many_rows then
		p_out := 1;

	when no_data_found then
		p_out := check_org_children_exist(p_process_id);

	WHEN OTHERS THEN
	     ROLLBACK;
	     p_out := 0;
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end check_org_exist;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- Check if active certification is going on for this process or any of its children in any org
-- If yes, return 1, else 0

procedure check_cert_exist( p_process_id	       in number,
			    p_out		       out nocopy number,
			   x_return_status             out nocopy varchar2,
                           x_msg_count                 out nocopy number,
                           x_msg_data                  out nocopy varchar2)
is
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	p_out := 0;
end check_cert_exist;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- Check if active certification is going on for this process or any of its children in a particular org
-- If yes, return 1, else 0

procedure check_cert_exist( p_process_id	       in number,
			    p_out		       out nocopy number,
			   p_org_id		       in number,
			   x_return_status             out nocopy varchar2,
                           x_msg_count                 out nocopy number,
                           x_msg_data                  out nocopy varchar2)
is
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	p_out := 0;
end check_cert_exist;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


-- Check if current process or any of its children exists in any org. (1)
-- OR
-- Check if active certification is going on for this process or any of its children in any org (2)
-- p_check return values:
-- (1) and (2): 2
-- (1) only: 1
-- (2) only: 2
-- none: 0

procedure check_org_cert_exist( p_process_id		in number,
		           p_check			out nocopy number,
		           x_return_status		out nocopy varchar2,
                           x_msg_count			out nocopy number,
                           x_msg_data			out nocopy varchar2)
is

l_return_status	 varchar2(10);
l_msg_count	 number;
l_msg_data	 varchar2(4000);
p_org_out	 number := 0;
p_cert_out	 number := 0;
amw_exception    exception;

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	check_org_exist( p_process_id	 =>  p_process_id,
			 p_out		 =>  p_org_out,
		         x_return_status =>  l_return_status,
                         x_msg_count     =>  l_msg_count,
                         x_msg_data      =>  l_msg_data );

	if l_return_status <> 'S' then
		raise amw_exception;
	end if;

	check_cert_exist( p_process_id	     =>  p_process_id,
			  p_out		     =>  p_cert_out,
			  x_return_status    =>  l_return_status,
                          x_msg_count        =>  l_msg_count,
                          x_msg_data         =>  l_msg_data );

	if l_return_status <> 'S' then
		raise amw_exception;
	end if;

	if p_org_out = 0 AND p_cert_out = 0 then
		p_check := 0;
	elsif p_org_out = 0 AND p_cert_out = 1 then
		p_check := 2;
	elsif p_org_out = 1 AND p_cert_out = 0 then
		p_check := 1;
	elsif p_org_out = 1 AND p_cert_out = 1 then
		p_check := 2;
	end if;

exception
  WHEN amw_exception THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end check_org_cert_exist;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


function check_org_user_permission(org_id in number) return number is
userId number := FND_GLOBAL.User_Id;
l_dummy number;
begin
	if (fnd_profile.value('AMW_ORG_SECURITY_SWITCH') = 'N') OR (fnd_profile.value('AMW_ORG_SECURITY_SWITCH') is null) then
		return 1;
	end if;

	if fnd_profile.value('AMW_ACCESS_ALL_ORGS') = 'Y' then
		return 1;
	else
		l_dummy := isProcessOwner(userId, org_id) + hasOrgAccess(userId, org_id);
		if (l_dummy = 1) OR (l_dummy = 2) then
			return 1;
		else
			return 0;
		end if;
	end if;
end check_org_user_permission;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


function isProcessOwner(p_user_id in number, p_org_id in number) return number is
l_empid  number;
l_dummy  number;
l_party_id  number;
begin
	select nvl(employee_id, 0) into l_empid from fnd_user where user_id = p_user_id;

	if l_empid = 0 then return 0; end if;

    begin
	select party_id into l_party_id from amw_employees_current_v where employee_id = l_empid;
    exception
        when no_data_found then
            return 0;
    end;

	begin
		select 1 into l_dummy
		from amw_process_organization
		where end_date is null
		and organization_id = p_org_id
		and process_owner_id = l_party_id;
		return 1;
	exception
		when too_many_rows then
			return 1;
		when no_data_found then
			return 0;
	end;
end isProcessOwner;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


function hasOrgAccess(p_user_id in number, p_org_id in number) return number is
l_empid  number;
l_dummy  number;
begin
--	check if the person is a manager of any audit unit. If no, return 0;
--	If yes, check if he's the manager of the given org. If yes, return 1.
--	if no, check if the current org is in the downward hierarchy of any of the orgs the person is a manager of; If yes, return 1, else return 0;

	select nvl(employee_id, 0) into l_empid from fnd_user where user_id = p_user_id;

	if l_empid = 0 then return 0; end if;

	begin
		select org_information2
		into l_dummy
		from hr_organization_information
		where organization_id in (select distinct organization_id from amw_audit_units_v)
		and org_information_context = 'Organization Name Alias'
		and org_information2 = l_empid;
	exception
		when no_data_found then
			return 0;

		when too_many_rows then
			null;
	end;

	begin
		select 1
		into l_dummy
		from hr_organization_information
		where organization_id = p_org_id
		and org_information_context = 'Organization Name Alias'
		and org_information2 = l_empid;

		return 1;
	exception
		when no_data_found then
			return checkOrgHier(l_empid, p_org_id);
	end;

end hasOrgAccess;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function checkOrgHier(p_emp_id in number, p_org_id in number) return number is
l_dummy  number;
l_org number;
hier_name varchar2(30);

cursor c_orgs(l_emp number) is
		select hoi.organization_id
		from hr_organization_information hoi, amw_audit_units_v aauv
		where hoi.organization_id = aauv.organization_id
		and hoi.org_information_context = 'Organization Name Alias'
		and hoi.org_information2 = l_emp;

begin

	hier_name := fnd_profile.value('AMW_ORG_SECURITY_HIERARCHY');

	if hier_name is null then return 0; end if;

	open c_orgs(p_emp_id);
	loop
	    fetch c_orgs into l_org;
            exit when c_orgs%notfound;

	    begin
                    select 1 into l_dummy
                    from dual where p_org_id in
                    (select organization_id_child
                     from
                        (select organization_id_parent, organization_id_child from per_org_structure_elements
                        where org_structure_version_id =
                            (select org_structure_version_id from per_org_structure_versions
                            where date_to is null and organization_structure_id =
                            (select organization_structure_id from per_organization_structures where name = hier_name)))
                    start with organization_id_parent = l_org
                    connect by organization_id_parent = prior organization_id_child);

		    return 1;

	    exception
			when no_data_found then
				null;

			when too_many_rows then
				return 1;
      	   end;
	end loop;
	close c_orgs;
	return 0;
end checkOrgHier;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- abb added
procedure find_amwp_hierarchy_children(p_process_id in number)
is
  cursor c1 (l_id number) is
        select b2.process_id
        from amw_wf_hierarchy_v a, amw_process b1, amw_process b2
        where b1.name = a.parent_process_name
        and b1.item_type = a.parent_item_type
        and b2.name = a.child_process_name
        and b2.item_type = a.child_item_type
        and b1.process_id = l_id;

  c1_rec c1%rowtype;

begin
  for c1_rec in c1(p_process_id) loop
	  exit when c1%notfound;
      v_child_id.extend(1);
      v_child_id(v_child_id.count) := c1_rec.process_id;
          find_amwp_hierarchy_children(p_process_id =>c1_rec.process_id);
  end loop;
end find_amwp_hierarchy_children;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- abb added
procedure find_amwp_hierarchy_parent(p_process_id in number)
is
  cursor c1 (l_id number) is
        select b1.process_id
        from amw_wf_hierarchy_v a, amw_process b1, amw_process b2
        where b1.name = a.parent_process_name
        and b1.item_type = a.parent_item_type
        and b2.name = a.child_process_name
        and b2.item_type = a.child_item_type
        and b2.process_id = l_id;

  c1_rec c1%rowtype;

begin
  for c1_rec in c1(p_process_id) loop
	  exit when c1%notfound;
      v_parent_id.extend(1);
      v_parent_id(v_parent_id.count) := c1_rec.process_id;
          find_amwp_hierarchy_parent(p_process_id =>c1_rec.process_id);
  end loop;
end find_amwp_hierarchy_parent;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- abb changed
procedure populate_proc_flatlist is

cursor c12 is
	select process_id from amw_process;

type t_ap_id        is table of amw_process.process_id%type;
v_ap_id 	      t_ap_id;

v_index number;
v_indexDown number;
j number;
jDown number;
l_process_id number;
l_child_id number;
l_parent_id number;
l_dummy number;
-- there is still some scope of performance improvement. E.g. the denorm data
-- could be stored in a temporary table of records and then bulk inserted into the database.
-- But pre 9i doesn't support table-in-table or index by varchar tables, so
-- the check for duplicates would involve looping through the whole table.
-- for tables of large size, that itself is expensive, and would counter the gains
-- obtained by bulk insert. If further performance problem is reported, we'll
-- try out these tricks.
begin
delete from Amw_Proc_Hierarchy_Denorm;
open c12;
loop
    fetch c12 bulk collect into v_ap_id;
    exit when c12%notfound;
end loop;
close c12;
v_index := v_ap_id.first;
while v_index <= v_ap_id.last
loop
-- insert upward hierarchy

    v_parent_id := t_parent_id();
	find_amwp_hierarchy_parent(v_ap_id(v_index));
    l_process_id := v_ap_id(v_index);
	FOR i IN 1..v_parent_id.count LOOP
        l_parent_id := v_parent_id(i);
			begin
				select 1 into l_dummy
				from Amw_Proc_Hierarchy_Denorm
				where Process_Id = l_process_id
				and Parent_Child_Id = l_parent_id
				and Up_Down_Ind = 'U';
			exception
				when no_data_found then
					insert into Amw_Proc_Hierarchy_Denorm
					(Process_Id,
					Parent_Child_Id,
					Up_Down_Ind,
					Last_Update_Date,
					Last_Updated_By,
					Creation_Date,
					Created_By,
					Last_Update_Login,
					OBJECT_VERSION_NUMBER
					)
					values
					(l_process_id,
					l_parent_id,
					'U',
					sysdate,
					G_USER_ID,
					sysdate,
					G_USER_ID,
					G_LOGIN_ID,
					1);
			end;
	END LOOP;

-- insert downward hierarchy

    v_child_id := t_child_id();
	find_amwp_hierarchy_children(v_ap_id(v_index));
	FOR i IN 1..v_child_id.count LOOP
        l_child_id := v_child_id(i);
			begin
				select 1 into l_dummy
				from Amw_Proc_Hierarchy_Denorm
				where Process_Id = l_process_id
				and Parent_Child_Id = l_child_id
				and Up_Down_Ind = 'D';
			exception
				when no_data_found then
					insert into Amw_Proc_Hierarchy_Denorm
					(Process_Id,
					Parent_Child_Id,
					Up_Down_Ind,
					Last_Update_Date,
					Last_Updated_By,
					Creation_Date,
					Created_By,
					Last_Update_Login,
					OBJECT_VERSION_NUMBER
					)
					values
					(l_process_id,
					l_child_id,
					'D',
					sysdate,
					G_USER_ID,
					sysdate,
					G_USER_ID,
					G_LOGIN_ID,
					1);
			end;
	END LOOP;

v_index := v_ap_id.next(v_index);
end loop;
end populate_proc_flatlist;


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


procedure adhoc_synch_hier_amw_proc  ( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2)
is

L_API_NAME CONSTANT VARCHAR2(30) := 'synch_hierarchy_amw_process';
p_init_msg_list	       VARCHAR2(10) := FND_API.G_FALSE;

type t_amwp_name       is table of amw_process.name%type;
v_amwp_name 	       t_amwp_name;
type t_amwp_pid        is table of amw_process.process_id%type;
v_amwp_pid 	       t_amwp_pid;

type t_org             is table of amw_process_organization.organization_id%type;
v_org 		       t_org;

--type rec_amw IS record
--        (name 		amw_process.name%type,
--        process_id 	amw_process.process_id%type);
--v_rec_amw rec_amw;
--type t_amw    IS   table of rec_amw index by binary_integer;
--v_amw t_amw;

-- 8.1.7 compatibility issue
/*
type t_amwp_name_pid        is table of amw_process.process_id%type index by VARCHAR2(30);
v_amwp_name_pid 	    t_amwp_name_pid;
*/
-- added by abedajna
/*
type t_wf_name         is table of wf_activities.name%type;
v_wf_name  t_wf_name;
type t_wf_name_table    IS   table of t_wf_name index by binary_integer;
v_wf_name_table     t_wf_name_table;
*/

type t_delete_list    IS   table of amw_process.name%type index by binary_integer;
v_delete_list		   t_delete_list;

type t_delete_pid_list    IS   table of amw_process.process_id%type index by binary_integer;
v_delete_pid_list	       t_delete_pid_list;

-- 8.1.7 compatibility issue
/*
type t_child_list    IS   table of  amw_process.name%type index by VARCHAR2(30);
v_child_list		            t_child_list;
*/

root_process_name amw_process.name%type;
v_index NUMBER;
v_index1 NUMBER;
xst BOOLEAN;
delete_row_cnt NUMBER;
x_return_status1 varchar2(10);
x_msg_count1 number;
x_msg_data1 varchar2(4000);

cursor	c_amwp_name is
select	name, process_id
from 	amw_process;

cursor c_org (p_pid number) is
select organization_id
from amw_process_organization
where process_id = p_pid;

cursor exceptions_to_be_del is
select exception_id
from amw_exceptions_b
where object_type = 'PROCESS_VARIANT_ADD'
and new_pk1 not in
(select process_id from amw_process where standard_process_flag = 'Y');

l_ex_id  number;
hvalue number;
v_inner_index number;

amw_processing_exception exception;


begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- go through amw_process, see if the process does NOT exist as a child of ALL Process
-- in wf, in that case, delete the row from amw_process. This is to take care of
-- dangling rows in amw_process.
open c_amwp_name;
loop
	fetch c_amwp_name bulk collect into v_amwp_name, v_amwp_pid;
	exit when c_amwp_name%notfound;
end loop;
close c_amwp_name;

-- 8.1.7 compatibility issue
/*
v_index := v_amwp_name.first;
while v_index <= v_amwp_name.last
loop
--kosriniv	v_amwp_name_pid( dbms_utility.get_hash_value(v_amwp_name(v_index), 1000, 5625) ) := v_amwp_pid(v_index);
	v_amwp_name_pid( v_amwp_name(v_index) ) := v_amwp_pid(v_index);
	v_index := v_amwp_name.next(v_index);
end loop;
*/

select name
into root_process_name
from amw_process
where process_id = -1;

find_hierarchy_children(root_process_name);

-- 8.1.7 compatibility issue
/*
FOR i IN 1..v_child_name.count LOOP
--kosriniv	v_child_list(dbms_utility.get_hash_value(v_child_name(i), 1000, 5625)) := v_child_name(i);
	v_child_list(v_child_name(i)) := v_child_name(i);
END LOOP;
*/
-- added by abedajna
/*
    FOR i IN 1..v_child_name.count LOOP
       hvalue := dbms_utility.get_hash_value(v_child_name(i), 3, POWER(2,15));
       if v_wf_name_table.exists(hvalue) then -- entry exists
            v_wf_name := v_wf_name_table(hvalue);
            v_wf_name.extend(1);
            v_wf_name(v_wf_name.count) := v_child_name(i);
            v_wf_name_table(hvalue) := v_wf_name;
       else
            v_wf_name := t_wf_name();
            v_wf_name.extend(1);
            v_wf_name(1) := v_child_name(i);
            v_wf_name_table(hvalue) := v_wf_name;
       end if;
    end loop;
*/

delete_row_cnt := 0;
v_index := v_amwp_name.first;
while v_index <= v_amwp_name.last
loop
/*
-- abedajna: check if the child amwp name exists in v_wf_name_table
    hvalue := dbms_utility.get_hash_value(v_amwp_name(v_index), 3, POWER(2,15));
    begin
      v_wf_name := v_wf_name_table(hvalue);

      v_inner_index := v_wf_name.first;
         while v_inner_index <= v_wf_name.last
         loop
            if v_amwp_name(v_index) = v_wf_name(v_inner_index) then
                xst := true;
                exit;
            end if;
        	v_inner_index := v_wf_name.next(v_inner_index);
         end loop;
    exception
        when no_data_found then
            xst := false;
    end;
*/
      xst := false;
      v_inner_index := v_child_name.first;
         while v_inner_index <= v_child_name.last
         loop
            if v_amwp_name(v_index) = v_child_name(v_inner_index) then
                xst := true;
                exit;
            end if;
        	v_inner_index := v_child_name.next(v_inner_index);
         end loop;

	if ( (xst = false) AND (root_process_name <> v_amwp_name(v_index)) ) then
		delete_row_cnt := delete_row_cnt + 1;
		v_delete_list(delete_row_cnt) := v_amwp_name(v_index);
	end if;
	v_index := v_amwp_name.next(v_index);
end loop;

-- this produces PLS-00801: internal error [74301] during compilation!
-- delete risk associations in the risk library.
-- FORALL v_ind IN 1..delete_row_cnt
--	DELETE from amw_risk_associations
--	where pk1 = v_amwp_name_pid( v_delete_list(v_ind) )
--	and object_type = 'PROCESS';

-- delete risk associations in the risk library.
 v_index := v_delete_list.first;
 while v_index <= v_delete_list.last
 loop
    -- opportunity for performance improvement exist
        select process_id
        into  v_delete_pid_list(v_index)
        from amw_process
        where item_type = 'AUDITMGR'
        and name = v_delete_list(v_index);
-- 	v_delete_pid_list(v_index) := v_amwp_name_pid( v_delete_list(v_index) );
	v_index := v_delete_list.next(v_index);
 end loop;




-- UNIT TESTING BEGIN --
-- v_index := v_delete_list.first;
-- dbms_output.put_line('PRINTING DELETE LIST, NAME');
-- while v_index <= v_delete_list.last
-- loop
-- 	dbms_output.put_line('index: '||v_index||' value: '||v_delete_list(v_index));
--	v_index := v_delete_list.next(v_index);
-- end loop;

-- v_index := v_delete_pid_list.first;
-- line_number := 11;
-- dbms_output.put_line('PRINTING DELETE LIST, PID');
-- while v_index <= v_delete_pid_list.last
-- loop
-- 	dbms_output.put_line('index: '||v_index||' value: '||v_delete_pid_list(v_index) );
--	v_index := v_delete_pid_list.next(v_index);
-- end loop;
-- UNIT TESTING END --


-- disassociate these processes from all the orgs they are associated with
 v_index := v_delete_pid_list.first;
 while v_index <= v_delete_pid_list.last
 loop
	open c_org( v_delete_pid_list(v_index) );
	loop
		fetch c_org bulk collect into v_org;
		exit when c_org%notfound;
	end loop;
	close c_org;

	v_index1 := v_org.first;
	while v_index1 <= v_org.last
	loop
			disassociate_process_org(p_process_id	=> v_delete_pid_list(v_index),
						p_org_id	=> v_org(v_index1),
						x_return_status	=> x_return_status1,
						x_msg_count	=> x_msg_count1,
						x_msg_data	=> x_msg_data1);

-- kosriniv begin :- Check the return status, and if error then raise the amw_processing_exception to handle it.
		IF x_return_status1 <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE amw_processing_exception;
		END IF;
-- kosriniv end
                  v_index1 := v_org.next(v_index1);
	end loop;
	v_index := v_delete_pid_list.next(v_index);
 end loop;


 FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_risk_associations
	where pk1 = v_delete_pid_list(v_ind)
	and object_type = 'PROCESS';

 FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_objective_associations
	where pk1 = v_delete_pid_list(v_ind)
	and object_type = 'PROCESS';

-- delete from amw_process
FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_process
	where name = v_delete_list(v_ind);

-- endate these processes in wf_activities and call wf purge api's to delete them
FORALL v_ind IN 1..delete_row_cnt
	update wf_activities
	set end_date = sysdate
	where name = v_delete_list(v_ind)
	and item_type = 'AUDITMGR'
	and end_date is null;

--wf_purge.Items(
--  itemtype => 'AUDITMGR',
--  docommit => false);
--wf_purge.Activities(
--  itemtype => 'AUDITMGR');

v_child_name.delete;
child_num := 0;
--v_child_list.delete;
v_delete_list.delete;
v_delete_pid_list.delete;
--v_amwp_name_pid.delete;
v_amwp_name.trim;
v_amwp_pid.trim;

-- nullify the standard variations that have been deleted
update amw_process ap1
set ap1.standard_variation =
(select ap2.process_id from amw_process ap2 where ap2.process_id = ap1.standard_variation);

-- delete the corresponding variation exceptions created for them.
open exceptions_to_be_del;
 loop
    fetch exceptions_to_be_del into l_ex_id;
    exit when exceptions_to_be_del%notfound;
    delete from amw_exceptions_b where exception_id = l_ex_id;
    delete from amw_exceptions_reasons where exception_id = l_ex_id;
    delete from amw_exceptions_tl where exception_id = l_ex_id;
 end loop;
close exceptions_to_be_del;

-- delete those process rows from amw_process which have been deleted from wf
delete from amw_process a where not exists
(select name from wf_activities w where w.name = a.name and w.item_type = 'AUDITMGR' and w.end_date is null);

--populate_proc_flatlist;
--reset_org_count;
--reset_process_risk_ctrl_count;
-- reset_proc_org_risk_ctrl_count;

exception

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);


-- kosriniv begin :- Handle amw_processing_exception
  WHEN amw_processing_exception THEN
  	ROLLBACK;
	x_return_status := x_return_status1;
	x_msg_count := x_msg_count1;
	IF x_msg_count = 1 THEN
		x_msg_data := x_msg_data1;
	END IF;
-- kosriniv end.

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end adhoc_synch_hier_amw_proc;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- DO NOT CALL THIS PROCEDURE FROM ANYWHERE IN AMW.D CODE. THIS IS BEING PROVIDED TO FIX BUG 4306756
-- THIS IS CALLED ONLY FROM AMWDTFIX.SQL

procedure old_synch_hier_amw_process( x_return_status		   out nocopy varchar2,
				       x_msg_count	           out nocopy number,
				       x_msg_data		   out nocopy varchar2)
is

L_API_NAME CONSTANT VARCHAR2(30) := 'old_synch_hier_amw_process';
p_init_msg_list	       VARCHAR2(10) := FND_API.G_FALSE;

type t_amwp_name       is table of amw_process.name%type;
v_amwp_name 	       t_amwp_name;
type t_amwp_pid        is table of amw_process.process_id%type;
v_amwp_pid 	       t_amwp_pid;

type t_org             is table of amw_process_organization.organization_id%type;
v_org 		       t_org;

type t_delete_list    IS   table of amw_process.name%type index by binary_integer;
v_delete_list		   t_delete_list;

type t_delete_pid_list    IS   table of amw_process.process_id%type index by binary_integer;
v_delete_pid_list	       t_delete_pid_list;

root_process_name amw_process.name%type;
v_index NUMBER;
v_index1 NUMBER;
xst BOOLEAN;
delete_row_cnt NUMBER;
x_return_status1 varchar2(10);
x_msg_count1 number;
x_msg_data1 varchar2(4000);

cursor	c_amwp_name is
select	name, process_id
from 	amw_process;

cursor c_org (p_pid number) is
select organization_id
from amw_process_organization
where process_id = p_pid;

cursor exceptions_to_be_del is
select exception_id
from amw_exceptions_b
where object_type = 'PROCESS_VARIANT_ADD'
and new_pk1 not in
(select process_id from amw_process where standard_process_flag = 'Y');

l_ex_id  number;
hvalue number;
v_inner_index number;

amw_processing_exception exception;


begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- go through amw_process, see if the process does NOT exist as a child of ALL Process
-- in wf, in that case, delete the row from amw_process. This is to take care of
-- dangling rows in amw_process.
open c_amwp_name;
loop
	fetch c_amwp_name bulk collect into v_amwp_name, v_amwp_pid;
	exit when c_amwp_name%notfound;
end loop;
close c_amwp_name;

select name
into root_process_name
from amw_process
where process_id = -1;

find_hierarchy_children(root_process_name);

delete_row_cnt := 0;
v_index := v_amwp_name.first;
while v_index <= v_amwp_name.last
loop
      xst := false;
      v_inner_index := v_child_name.first;
         while v_inner_index <= v_child_name.last
         loop
            if v_amwp_name(v_index) = v_child_name(v_inner_index) then
                xst := true;
                exit;
            end if;
        	v_inner_index := v_child_name.next(v_inner_index);
         end loop;

	if ( (xst = false) AND (root_process_name <> v_amwp_name(v_index)) ) then
		delete_row_cnt := delete_row_cnt + 1;
		v_delete_list(delete_row_cnt) := v_amwp_name(v_index);
	end if;
	v_index := v_amwp_name.next(v_index);
end loop;

 v_index := v_delete_list.first;
 while v_index <= v_delete_list.last
 loop
        select process_id
        into  v_delete_pid_list(v_index)
        from amw_process
        where item_type = 'AUDITMGR'
        and name = v_delete_list(v_index);
	v_index := v_delete_list.next(v_index);
 end loop;


-- disassociate these processes from all the orgs they are associated with
 v_index := v_delete_pid_list.first;
 while v_index <= v_delete_pid_list.last
 loop
	open c_org( v_delete_pid_list(v_index) );
	loop
		fetch c_org bulk collect into v_org;
		exit when c_org%notfound;
	end loop;
	close c_org;

	v_index1 := v_org.first;
	while v_index1 <= v_org.last
	loop
			disassociate_process_org(p_process_id	=> v_delete_pid_list(v_index),
						p_org_id	=> v_org(v_index1),
						x_return_status	=> x_return_status1,
						x_msg_count	=> x_msg_count1,
						x_msg_data	=> x_msg_data1);

-- kosriniv begin :- Check the return status, and if error then raise the amw_processing_exception to handle it.
		IF x_return_status1 <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE amw_processing_exception;
		END IF;
-- kosriniv end
                  v_index1 := v_org.next(v_index1);
	end loop;
	v_index := v_delete_pid_list.next(v_index);
 end loop;


 FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_risk_associations
	where pk1 = v_delete_pid_list(v_ind)
	and object_type = 'PROCESS';

 FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_objective_associations
	where pk1 = v_delete_pid_list(v_ind)
	and object_type = 'PROCESS';

-- delete from amw_process
FORALL v_ind IN 1..delete_row_cnt
	DELETE from amw_process
	where name = v_delete_list(v_ind);

-- endate these processes in wf_activities and call wf purge api's to delete them
FORALL v_ind IN 1..delete_row_cnt
	update wf_activities
	set end_date = sysdate
	where name = v_delete_list(v_ind)
	and item_type = 'AUDITMGR'
	and end_date is null;

wf_purge.Items(
  itemtype => 'AUDITMGR',
  docommit => false);
wf_purge.Activities(
  itemtype => 'AUDITMGR');

v_child_name.delete;
child_num := 0;
--v_child_list.delete;
v_delete_list.delete;
v_delete_pid_list.delete;
--v_amwp_name_pid.delete;
v_amwp_name.trim;
v_amwp_pid.trim;

-- nullify the standard variations that have been deleted
update amw_process ap1
set ap1.standard_variation =
(select ap2.process_id from amw_process ap2 where ap2.process_id = ap1.standard_variation);

-- delete the corresponding variation exceptions created for them.
open exceptions_to_be_del;
 loop
    fetch exceptions_to_be_del into l_ex_id;
    exit when exceptions_to_be_del%notfound;
    delete from amw_exceptions_b where exception_id = l_ex_id;
    delete from amw_exceptions_reasons where exception_id = l_ex_id;
    delete from amw_exceptions_tl where exception_id = l_ex_id;
 end loop;
close exceptions_to_be_del;

-- delete those process rows from amw_process which have been deleted from wf
delete from amw_process a where not exists
(select name from wf_activities w where w.name = a.name and w.item_type = 'AUDITMGR' and w.end_date is null);

populate_proc_flatlist;
reset_org_count;
reset_process_risk_ctrl_count;
-- reset_proc_org_risk_ctrl_count;

exception

  WHEN amw_deadlock_detected THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);


-- kosriniv begin :- Handle amw_processing_exception
  WHEN amw_processing_exception THEN
  	ROLLBACK;
	x_return_status := x_return_status1;
	x_msg_count := x_msg_count1;
	IF x_msg_count = 1 THEN
		x_msg_data := x_msg_data1;
	END IF;
-- kosriniv end.

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end old_synch_hier_amw_process;



end AMW_WF_HIERARCHY_PKG;

/
