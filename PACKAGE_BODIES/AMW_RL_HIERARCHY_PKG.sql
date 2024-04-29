--------------------------------------------------------
--  DDL for Package Body AMW_RL_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_RL_HIERARCHY_PKG" AS
/*$Header: amwrlhrb.pls 120.6 2006/03/20 02:52:55 appldev noship $*/

function encode (n1 in number, n2 in number) return varchar2 is
begin
  return to_char(n1) || ':' || to_char(n2);
end encode;

procedure init is
begin

  x_index := 0;
  x_process_tbl := process_tbl();
  x_parent_child_tbl := parent_child_tbl();
  x_up_down_ind_tbl := up_down_ind_tbl();

  x_index_tbl.delete;
  x_t1.delete;
  x_t2.delete;

end init;


function is_ancestor_in_hierarchy(p_process1_id in number,
                                  p_process2_id in number)
                                 return boolean
is
  cursor c_relation_exists (l_ancestor_id number,
                             l_descendant_id number) is
     select 1 from amw_proc_hierarchy_denorm
     where process_id = l_ancestor_id and
           parent_child_id = l_descendant_id and
           hierarchy_type = 'L' and
           up_down_ind = 'D';
  l_dummy number;
begin

  open c_relation_exists(p_process1_id, p_process2_id);
  fetch c_relation_exists into l_dummy;
  if (c_relation_exists%found)
  then
    close c_relation_exists;
    return true;
  else
    close c_relation_exists;
    return false;
  end if;


end is_ancestor_in_hierarchy;

procedure add_rows_to_denorm
(p_ancestor_id in number,
 p_descendant_id in number)

is

begin
    x_index := x_index+2;
    x_process_tbl.extend(2);
    x_parent_child_tbl.extend(2);
    x_up_down_ind_tbl.extend(2);

    --add the new relation
    x_process_tbl(x_index-1) := p_ancestor_id;
    x_parent_child_tbl(x_index-1) := p_descendant_id;
    x_up_down_ind_tbl(x_index-1) := 'D';

    --add the new relation
    x_process_tbl(x_index) := p_descendant_id;
    x_parent_child_tbl(x_index) := p_ancestor_id;
    x_up_down_ind_tbl(x_index) := 'U';
    x_index_tbl(encode(p_ancestor_id,p_descendant_id)) := 1;
end add_rows_to_denorm;


procedure update_denorm_add_child(p_parent_id number,
                                  p_child_id number,
                                  l_sysdate in Date default sysdate)

is

-- CURSOR TO SELECT ALL THE ANCESTORS OF THE GIVEN PROCESS.
   cursor c_ancestors(l_process_id number) is
     select parent_child_id
     from amw_proc_hierarchy_denorm
     where process_id = l_process_id and
           up_down_ind = 'U';

   type ancestor_tbl is table of c_ancestors%rowtype;


-- CURSOR TO SELECT ALL THE DESCENDANTS OF THE GIVEN PROCESS.
   cursor c_descendants (l_process_id number) is
     select parent_child_id
     from amw_proc_hierarchy_denorm
     where process_id = l_process_id and
           up_down_ind = 'D';

   type descendants_tbl is table of c_descendants%rowtype;
   type relations_tbl is table of c_all_latest_relations%rowtype;


-- CURSOR TO FIND WHETHER THE A GIVEN RELATION EXISTS OR NOT..
   cursor c_relation_exists (l_ancestor_id number,
                             l_descendant_id number) is
     select 1 from amw_proc_hierarchy_denorm
     where process_id = l_ancestor_id and
           parent_child_id = l_descendant_id and
           up_down_ind = 'D';

  l_dummy number;
  x_atbl ancestor_tbl;
  x_dtbl descendants_tbl;
  x_rtbl relations_tbl;
  add_flag boolean;
  add_flag1 boolean;
  add_flag2 boolean;
  add_flag3 boolean;



begin
  x_index := 0;
  x_process_tbl := process_tbl();
  x_parent_child_tbl := parent_child_tbl();
  x_up_down_ind_tbl := up_down_ind_tbl();
  x_index_tbl.delete;


-- COLLECT ALL THE ANCESTORS OF THE PARENT INTO A TABLE..
  open c_ancestors(p_parent_id);
  fetch c_ancestors bulk collect into x_atbl;
  close c_ancestors;

-- COLLECT ALL THE DESCENDENTS OF THE CHILD INTO A TABLE.
  open c_descendants(p_child_id);
  fetch c_descendants bulk collect into x_dtbl;
  close c_descendants;


-- COLLECT ALL THE RELATIONS THAT EXISTS IN THE TABLE..
  open c_all_latest_relations;
  fetch c_all_latest_relations bulk collect into x_rtbl;
  close c_all_latest_relations;


-- Store all the relations into an associative array..to transfer into the table later..

-- GET ALL THE RELATIONS THAT ALREADY IN THE HIERARCHY DENORM TABLE IN TO THE 'X_INDEX_TBL'.
  --input all the relations into the associative array
  if(x_rtbl.exists(1))
  then
    for ctr in x_rtbl.first .. x_rtbl.last loop
      if(x_rtbl(ctr).up_down_ind = 'D') then
        x_index_tbl(encode(x_rtbl(ctr).process_id,x_rtbl(ctr).parent_child_id)) := 1;
      end if;
    end loop;
  end if;



-- CHECK IF THE PARENT-CHILD RELATION EXISTS ALREAY IN THE DENORM TABLE.
  add_flag := true;
  if(x_index_tbl.exists(encode(p_parent_id,p_child_id)))
  then
    add_flag := false;
  end if;

-- IF NOT EXISTS ADD IT TO THE DENORM..(I.E. ADD IT TO INTURN ADD X_INDEX_TBL)
  if (add_flag) then
    add_rows_to_denorm(p_parent_id, p_child_id);

-- kosriniv YOU NEED TO DO IT FOR ALL THE ANCESTORS ALSO..
 	if(x_atbl.exists(1)) then
      for ctr1 in x_atbl.first .. x_atbl.last loop
          add_flag3 := true;
          if(x_index_tbl.exists(encode(x_atbl(ctr1).parent_child_id,
                                         p_child_id)))
          then
            add_flag3 := false;
          end if;
          if (add_flag3) then
              add_rows_to_denorm(x_atbl(ctr1).parent_child_id,
                                 p_child_id);
          end if;
       end loop;
            -- ADDED ALL THE ANSCENDENT-DESCENDENTS LINKS..
    end if;
	-- IF ANY DESCENTS EXISTS FOR THE CHILD, YOU NEED TO ADD IT TO THEM TO THE HIERARHY DENORM ALSO..
    if(x_dtbl.exists(1)) then
    -- DO FOR ALL THE DESCNENDENTS..WITH THE PARENT
    for ctr in x_dtbl.first .. x_dtbl.last  loop
      add_flag1 := true;
      if(x_index_tbl.exists(encode(p_parent_id,x_dtbl(ctr).parent_child_id)))
      then
        add_flag1 := false;
      end if;

      if(add_flag1)
      then
        add_rows_to_denorm(p_parent_id,x_dtbl(ctr).parent_child_id);
		-- IF YOU HAVE ANY ASSCENDENTS TO THE PARENT, YOU NEED TO ADD THE DESCENEDENTS TO THEM ALSO IN TO THE HIERARHCY DENORM...
        if(x_atbl.exists(1)) then
        for ctr1 in x_atbl.first .. x_atbl.last loop
          add_flag2 := true;
          if(x_index_tbl.exists(encode(x_atbl(ctr1).parent_child_id,
                                         x_dtbl(ctr).parent_child_id)))
          then
            add_flag2 := false;
          end if;
          if (add_flag2) then
              add_rows_to_denorm(x_atbl(ctr1).parent_child_id,
                                 x_dtbl(ctr).parent_child_id);
           end if;
         end loop;
         -- ADDED ALL THE ANSCENDENT-DESCENDENTS LINKS..
         end if;
        end if;
      end loop;
      end if;
  end if;

  --now insert all the rows found into the amw_proc_hierarchy_denorm table
  if(x_process_tbl.exists(1))

  then
    forall i in x_process_tbl.first .. x_process_tbl.last
      insert into amw_proc_hierarchy_denorm (PROCESS_ID,
                                             PARENT_CHILD_ID,
                                             UP_DOWN_IND,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATED_BY,
                                             CREATION_DATE,
                                             CREATED_BY,
                                             LAST_UPDATE_LOGIN,
                                             OBJECT_VERSION_NUMBER,
                                             HIERARCHY_TYPE)
      values
                                             (x_process_tbl(i),
                                             x_parent_child_tbl(i),
                                             x_up_down_ind_tbl(i),
                                             l_sysdate,
                                             G_USER_ID,
                                             l_sysdate,
                                             G_USER_ID,
                                             G_LOGIN_ID,
                                             1,
                                             'L');
   end if;


  exception
    WHEN OTHERS THEN raise;


end update_denorm_add_child;






--assumes that x_index_tbl has been initialized before first call
procedure recursive_construct_denorm(p_process_id in number)

is

i pls_integer;


add_flag boolean;
add_flag1 boolean;

temp tn;
temp1 tn;

str varchar2(50);
begin

  /* first get the children of p_process_id
   * get it from the x_t1 table which stores these children
   */

  str := to_char(p_process_id);

  if(x_t1.exists(str))
  then
    temp := x_t1(str);
  else
    temp := tn();
  end if;

  /* check to avoid numeric error */
  if(temp.exists(1)) then

  --for each child (of the process on which the procedure is called)
  for i in temp.first .. temp.last loop

      --first construct the denorm hierarchy for that child
     recursive_construct_denorm( p_process_id => temp(i));


      /* if the relationship between the process and the child does
       * not already exist in the denorm table
       * then add the two rows creating the relations
       */
     add_flag := true;

     /* the x_index_tbl just check if we ever added an entry for
      * <p_process_id>:<temp(i)>. If so it would never go process
      * down further because all relations of process_id with the
      * descendants of temp(i) would already have been added
      */
     if (x_index_tbl.exists(encode(p_process_id,temp(i))))
     then
       add_flag := false;
     end if;



      /* if the relation between p_process_id and temp(i)
       * already existed in the relations table we dont need to even look into
       * descendants of child_id .. else we look into them
       * thus only if add_flag = true do any processing.
       */
     if (add_flag)
     then
       add_rows_to_denorm(p_process_id, temp(i));
        --record this new descendant for p_process_id in the descendants array
       x_t2(str).extend;
       x_t2(str)(x_t2(str).last) := temp(i);

       /* check if the child just processed has a single descendant
        * if it doesnt have a single descendant then there is no need
        * to process further in this recursive call
        */
       if(x_t2.exists(to_char(temp(i))))
       then
         --now temp1 points to the descendants of temp(i)
         temp1 := x_t2(to_char(temp(i)));
       else
         temp1 := tn();
       end if;




       --check if necessary to look at descendants of child
       if(temp1.exists(1))
       then
         --for each descendant
         for ctr in temp1.first .. temp1.last loop
           add_flag1 := true;

           --is the p_process_id, temp1(ctr) relation already done?
           if (x_index_tbl.exists(encode(p_process_id,temp1(ctr))))
           then
             add_flag1 := false;
           end if;

           --if fine to add the link between p_process_id and temp1(ctr)
           if(add_flag1)

           then
             add_rows_to_denorm(p_process_id, temp1(ctr));

             --record temp1(ctr) as a descendant of p_process_id
             x_t2(str).extend;
             x_t2(str)(x_t2(str).last) := temp1(ctr);
           end if;
         end loop;
       end if;
      end if;
  end loop;
  end if;



end recursive_construct_denorm;

/* this procedure assumes that the amw_approved_hierarchy
 * table stores current data .. the entire denorm table is
 * refreshed for the approved hierarchy
 * for RL pass -1 as the p_org_id
 */
procedure update_approved_denorm(p_org_id in number,
                                 l_sysdate in Date default sysdate)
is

cursor c_all_approved_links_rl is
       select parent_id, child_id
       from amw_approved_hierarchies
       where (organization_id is null or organization_id = -1)
       and (end_date is null or end_date > l_sysdate);

cursor c_all_approved_links_org(l_org_id in number) is
       select parent_id, child_id
       from amw_approved_hierarchies
       where (organization_id = l_org_id) and
       (end_date is null or end_date > l_sysdate);

str varchar2(50);

begin
  init;

  if(p_org_id is null or p_org_id = -1)
    then
      open c_all_approved_links_rl;
      fetch c_all_approved_links_rl bulk collect into p_links_tbl;
      close c_all_approved_links_rl;
    else
    --ko removing the denorm usage..
      return;
      /*
      open c_all_approved_links_org(p_org_id);
      fetch c_all_approved_links_org bulk collect into p_links_tbl;
      close c_all_approved_links_org;
      */
    end if;

-- Now if the p_links_tbl contains any data then
 if p_links_tbl.exists(1) then
  /* initialize the tables
   * this is needed only for parents
   * i.e only parents can have children and other descendants
   */
  for ctr in p_links_tbl.first .. p_links_tbl.last loop
    str := to_char(p_links_tbl(ctr).parent_id);
    x_t1(str) := tn();
    x_t2(str) := tn();
  end loop;

  --put in all the links
  for ctr in p_links_tbl.first .. p_links_tbl.last loop
    str := to_char(p_links_tbl(ctr).parent_id);
    x_t1(str).extend;
    x_t1(str)(x_t1(str).last) := p_links_tbl(ctr).child_id;
  end loop;


  if(p_org_id is null or p_org_id = -1)
    then
      --make the pl/sql tables contain the up2date data
      recursive_construct_denorm(p_process_id => -1);
      --DML operations
      delete from amw_proc_hierarchy_denorm where hierarchy_type='A';

    else
      recursive_construct_denorm(p_process_id => -2);

      delete from amw_org_hierarchy_denorm
      where organization_id = p_org_id and
      hierarchy_type='A';
  end if;


  if(x_process_tbl.exists(1))

  then
    if(p_org_id is null or p_org_id = -1)

    then
      forall i in x_process_tbl.first .. x_process_tbl.last
        insert into amw_proc_hierarchy_denorm (PROCESS_ID,
                                               PARENT_CHILD_ID,
                                               UP_DOWN_IND,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               OBJECT_VERSION_NUMBER,
                                               HIERARCHY_TYPE)
       values
                                               (x_process_tbl(i),
                                                x_parent_child_tbl(i),
                                                x_up_down_ind_tbl(i),
                                                l_sysdate,
                                                G_USER_ID,
                                                l_sysdate,
                                                G_USER_ID,
                                                G_LOGIN_ID,
                                                1,
                                                'A');
    else --p_org_id is not null
      forall i in x_process_tbl.first .. x_process_tbl.last
        insert into amw_org_hierarchy_denorm (ORGANIZATION_ID,
                                               PROCESS_ID,
                                               PARENT_CHILD_ID,
                                               UP_DOWN_IND,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               OBJECT_VERSION_NUMBER,
                                               HIERARCHY_TYPE)
        values
                                               (p_org_id,
                                                x_process_tbl(i),
                                                x_parent_child_tbl(i),
                                                x_up_down_ind_tbl(i),
                                                l_sysdate,
                                                G_USER_ID,
                                                l_sysdate,
                                                G_USER_ID,
                                                G_LOGIN_ID,
                                                1,
                                                'A');
    end if;
  end if;
 end if;
exception
  WHEN OTHERS then
    raise;


end update_approved_denorm;

procedure update_denorm(p_org_id in number,
                        l_sysdate in Date default sysdate)

is
--l_sysdate DATE := sysdate;
cursor c_top_level_rl is
  (select distinct parent_id
   from amw_latest_hierarchies
   where (organization_id is null or organization_id = -1)
  )
  minus
  (select distinct child_id parent_id
   from amw_latest_hierarchies
   where (organization_id is null or organization_id = -1)
  );

cursor c_top_level_org(l_org_id in number) is
  (select distinct parent_id
   from amw_latest_hierarchies
   where (organization_id = l_org_id)
  )
  minus
  (select distinct child_id parent_id
   from amw_latest_hierarchies
   where (organization_id = l_org_id)
  );


type ttbl is table of c_top_level_rl%rowtype;

p_tbl ttbl;
p_ltbl links_tbl;
l_batch_size pls_integer := 1000;
i pls_integer;
str varchar2(50);


begin




  --initialize all global tables
  init;

  if(p_org_id is null or p_org_id = -1)
  then
    open c_top_level_rl;
    fetch c_top_level_rl bulk collect into p_tbl;
    close c_top_level_rl;
  else
  --ko removing the denorm usage..
  	return;
  	/*
    open c_top_level_org(p_org_id);
    fetch c_top_level_org bulk collect into p_tbl;
    close c_top_level_org;
    */
  end if;


  if(p_org_id is null or p_org_id = -1)
  then
    open c_all_latest_links_rl;
    fetch c_all_latest_links_rl bulk collect into p_links_tbl;
    close c_all_latest_links_rl;
  else
  --ko removing the denorm usage..
  	return;
  	/*
    open c_all_latest_links_org(p_org_id);
    fetch c_all_latest_links_org bulk collect into p_links_tbl;
    close c_all_latest_links_org;
    */
  end if;



-- kosriniv check for p_links_tbl existance..
if p_links_tbl.exists(1) then


  /* initialize the tables
   * this is needed only for parents
   * i.e only parents can have children and other descendants
   */
  for ctr in p_links_tbl.first .. p_links_tbl.last loop
    str := to_char(p_links_tbl(ctr).parent_id);
    x_t1(str) := tn();
    x_t2(str) := tn();
  end loop;

  --put in all the links
  for ctr in p_links_tbl.first .. p_links_tbl.last loop
    str := to_char(p_links_tbl(ctr).parent_id);
    x_t1(str).extend;
    x_t1(str)(x_t1(str).last) := p_links_tbl(ctr).child_id;
  end loop;

end if;
  if(p_tbl.exists(1))

  then

    --call the updating procedure for each top level process
    for i in p_tbl.first .. p_tbl.last loop
      recursive_construct_denorm(p_process_id => p_tbl(i).parent_id);
    end loop;
  end if;


  --delete all rows from the denorm table

  if(p_org_id is null or p_org_id = -1)
  then
    delete from amw_proc_hierarchy_denorm where hierarchy_type='L';
  else
    delete from amw_org_hierarchy_denorm
    where organization_id = p_org_id and
    hierarchy_type='L';
  end if;


  if(x_process_tbl.exists(1))

  then
    if(p_org_id is null or p_org_id = -1)

    then
      forall i in x_process_tbl.first .. x_process_tbl.last
        insert into amw_proc_hierarchy_denorm (PROCESS_ID,
                                               PARENT_CHILD_ID,
                                               UP_DOWN_IND,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               OBJECT_VERSION_NUMBER,
                                               HIERARCHY_TYPE)
       values
                                               (x_process_tbl(i),
                                                x_parent_child_tbl(i),
                                                x_up_down_ind_tbl(i),
                                                l_sysdate,
                                                G_USER_ID,
                                                l_sysdate,
                                                G_USER_ID,
                                                G_LOGIN_ID,
                                                1,
                                                'L');
    else --p_org_id is not null
      forall i in x_process_tbl.first .. x_process_tbl.last
        insert into amw_org_hierarchy_denorm (ORGANIZATION_ID,
                                               PROCESS_ID,
                                               PARENT_CHILD_ID,
                                               UP_DOWN_IND,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               OBJECT_VERSION_NUMBER,
                                               HIERARCHY_TYPE)
        values
                                               (p_org_id,
                                                x_process_tbl(i),
                                                x_parent_child_tbl(i),
                                                x_up_down_ind_tbl(i),
                                                l_sysdate,
                                                G_USER_ID,
                                                l_sysdate,
                                                G_USER_ID,
                                                G_LOGIN_ID,
                                                1,
                                                'L');
    end if;
  end if;

exception
  WHEN OTHERS then
    raise;

end update_denorm;


procedure revise_process_if_necessary
(p_process_id in number,
 l_sysdate in Date default sysdate)
is

  l_process_id amw_process.process_id%type;
  l_process_rev_id amw_process.process_rev_id%type;
  l_item_type amw_process.item_type%type;
  l_name amw_process.name%type;
  l_process_code amw_process.process_code%type;
  l_revision_number amw_process.revision_number%type;
  l_approval_status amw_process.approval_status%type;
  l_control_count amw_process.control_count%type;
  l_risk_count amw_process.risk_count%type;
  l_org_count amw_process.org_count%type;
  l_significant_process_flag amw_process.significant_process_flag%type;
  l_standard_process_flag amw_process.standard_process_flag%type;
  l_certification_status amw_process.certification_status%type;
  l_process_category amw_process.process_category%type;
  l_process_owner_id amw_process.process_owner_id%type;
  l_finance_owner_id amw_process.finance_owner_id%type;
  l_application_owner_id amw_process.application_owner_id%type;
  l_standard_variation amw_process.standard_variation%type;
  l_deletion_date amw_process.deletion_date%type;
  l_process_type amw_process.process_type%type;
  l_control_activity_type amw_process.control_activity_type%type;
  l_object_version_number amw_process.object_version_number%type;
  l_attribute_category amw_process.attribute_category%type;
  l_attribute1 amw_process.attribute1%type;
  l_attribute2 amw_process.attribute2%type;
  l_attribute3 amw_process.attribute3%type;
  l_attribute4 amw_process.attribute4%type;
  l_attribute5 amw_process.attribute5%type;
  l_attribute6 amw_process.attribute6%type;
  l_attribute7 amw_process.attribute7%type;
  l_attribute8 amw_process.attribute8%type;
  l_attribute9 amw_process.attribute9%type;
  l_attribute10 amw_process.attribute10%type;
  l_attribute11 amw_process.attribute11%type;
  l_attribute12 amw_process.attribute12%type;
  l_attribute13 amw_process.attribute13%type;
  l_attribute14 amw_process.attribute14%type;
  l_attribute15 amw_process.attribute15%type;

  l_created_from amw_process.created_from%type;
  l_program_update_date amw_process.program_update_date%type;
  l_program_id amw_process.program_id%type;
  l_program_application_id amw_process.program_application_id%type;
  l_request_id amw_process.request_id%type;
  l_risk_count_latest amw_process.risk_count_latest%type;
  l_control_count_latest amw_process.control_count_latest%type;

  l_new_process_rev_id number;

  l_display_name amw_process_names_tl.display_name%type;
  l_description amw_process_names_tl.description%type;
  l_language amw_process_names_tl.language%type;
  l_source_lang amw_process_names_tl.source_lang%type;

  l_classification amw_process.classification%type;

--  l_sysdate DATE := sysdate;

  l_dummy number;
begin
  if(p_process_id <> -1)
  then

    select process_id, process_rev_id, item_type, name, process_code,
           revision_number, approval_status, control_count,
           risk_count, org_count, significant_process_flag,
           standard_process_flag, certification_status,
           process_category, process_owner_id, finance_owner_id,
           application_owner_id, standard_variation,
           object_version_number, deletion_date,
           process_type, control_activity_type,
           attribute_category, attribute1,
           attribute2, attribute3, attribute4,
           attribute5, attribute6, attribute7,
           attribute8, attribute9, attribute10,
           attribute11, attribute12, attribute13,
           attribute14, attribute15, created_from,
           program_id, program_application_id,
           request_id, program_update_date, risk_count_latest,
           control_count_latest, classification

    into   l_process_id, l_process_rev_id, l_item_type, l_name, l_process_code,
           l_revision_number, l_approval_status, l_control_count,
           l_risk_count, l_org_count, l_significant_process_flag,
           l_standard_process_flag, l_certification_status,
           l_process_category, l_process_owner_id, l_finance_owner_id,
           l_application_owner_id, l_standard_variation,
           l_object_version_number, l_deletion_date,
           l_process_type, l_control_activity_type,
           l_attribute_category, l_attribute1,
           l_attribute2, l_attribute3, l_attribute4,
           l_attribute5, l_attribute6, l_attribute7,
           l_attribute8, l_attribute9, l_attribute10,
           l_attribute11, l_attribute12, l_attribute13,
           l_attribute14, l_attribute15, l_created_from,
           l_program_id, l_program_application_id,
           l_request_id, l_program_update_date,
           l_risk_count_latest, l_control_count_latest,
           l_classification


    from   amw_process

    where  process_id = p_process_id
    and    (end_date is null or end_date > l_sysdate);

    /* any too_many_rows exception will propogate to caller */
    if(sql%notfound)
    then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;



    if (l_approval_status='A')

    --revise the parent process
    then

       insert into amw_process (PROCESS_ID,
                                ITEM_TYPE,
                                NAME,
                                PROCESS_CODE,
                                REVISION_NUMBER,
                                PROCESS_REV_ID,
                                APPROVAL_STATUS,
                                START_DATE,
                                CONTROL_COUNT,
                                RISK_COUNT,
                                ORG_COUNT,
                                SIGNIFICANT_PROCESS_FLAG,
                                STANDARD_PROCESS_FLAG,
                                CERTIFICATION_STATUS,
                                PROCESS_CATEGORY,
                                PROCESS_OWNER_ID,
                                FINANCE_OWNER_ID,
                                APPLICATION_OWNER_ID,
                                STANDARD_VARIATION,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                OBJECT_VERSION_NUMBER,
                                DELETION_DATE,
                                PROCESS_TYPE,
                                CONTROL_ACTIVITY_TYPE,
                                ATTRIBUTE_CATEGORY,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                CREATED_FROM,
                                PROGRAM_ID,
                                PROGRAM_APPLICATION_ID,
                                REQUEST_ID,
                                PROGRAM_UPDATE_DATE,
                                RISK_COUNT_LATEST,
                                CONTROL_COUNT_LATEST,
                                CLASSIFICATION)

                VALUES
                                (l_process_id,
                                 l_item_type,
                                 l_name,
                                 l_process_code,
                                 l_revision_number + 1,
                                 AMW_PROCESS_S.nextval,
                                 'D',
                                 l_sysdate,
                                 l_control_count,
                                 l_risk_count,
                                 l_org_count,
                                 l_significant_process_flag,
                                 l_standard_process_flag,
                                 l_certification_status,
                                 l_process_category,
                                 l_process_owner_id,
                                 l_finance_owner_id,
                                 l_application_owner_id,
                                 l_standard_variation,
                                 l_sysdate,
                                 G_USER_ID,
                                 l_sysdate,
                                 G_USER_ID,
                                 G_LOGIN_ID,
                                 1,
                                 l_deletion_date,
                                 l_process_type,
                                 l_control_activity_type,
                                 l_attribute_category,
                                 l_attribute1,
                                 l_attribute2,
                                 l_attribute3,
                                 l_attribute4,
                                 l_attribute5,
                                 l_attribute6,
                                 l_attribute7,
                                 l_attribute8,
                                 l_attribute9,
                                 l_attribute10,
                                 l_attribute11,
                                 l_attribute12,
                                 l_attribute13,
                                 l_attribute14,
                                 l_attribute15,
                                 l_created_from,
                                 l_program_id,
                                 l_program_application_id,
                                 l_request_id,
                                 l_program_update_date,
                                 l_risk_count_latest,
                                 l_control_count_latest,
                                 l_classification)
                RETURNING
                                 PROCESS_REV_ID
                INTO
                                 l_new_process_rev_id;





       update amw_process set
              last_update_date = l_sysdate,
              last_updated_by = G_USER_ID,
              last_update_login = G_LOGIN_ID,
              end_date = l_sysdate,
              object_version_number = l_object_version_number + 1



       where
             process_id = p_process_id and
             revision_number = l_revision_number and
             object_version_number = l_object_version_number;


       /* The only reason why the above insert could fail is:
        * The object version number had already been incremented
        * By some other process and thus the where clause failed to
        * update any row
        */
       if(sql%notfound)
       then
         raise FND_API.G_EXC_ERROR;
       end if;


      --now update the translatable table
      select display_name, description, language, source_lang

      into   l_display_name, l_description, l_language, l_source_lang

      from   amw_process_names_tl

      where  process_id      = l_process_id and
              revision_number = l_revision_number and
             language = userenv('LANG');

      /* too_many_rows will be propagated */
      if(sql%notfound)
      then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;



      insert into amw_process_names_tl
      (
          process_id
         ,revision_number
         ,process_rev_id
         ,display_name
         ,description
         ,language
         ,source_lang
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,object_version_number
      )
      select
          l_process_id
         ,l_revision_number+1
         ,l_new_process_rev_id
         ,l_display_name
         ,l_description
         ,L.LANGUAGE_CODE
         ,USERENV('LANG')
         ,l_sysdate
         ,g_user_id
         ,l_sysdate
         ,g_user_id
         ,g_login_id
         ,1
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B');

      --write code to copy attachments of the previous rev_id to the new one
      fnd_attached_documents2_pkg.copy_attachments(
                                  X_from_entity_name => 'AMW_PROCESS',
                                  X_from_pk1_value   => l_process_rev_id,
                                  X_to_entity_name   => 'AMW_PROCESS',
                                  X_to_pk1_value   => l_new_process_rev_id,
                                  X_created_by     => g_user_id,
                                  X_last_update_login => g_login_id,
                                  X_program_id      => FND_GLOBAL.CONC_PROGRAM_ID,
                                  X_request_id      => FND_GLOBAL.conc_request_id);







    end if;
  end if;




end revise_process_if_necessary;

/* this procedure updates the instance_id in the
 * amw_approved_hierarchy table if necessary
 * it should be called after a link is inserted in the
 * latest hierarchy (or an instance_id is updated)
 * the reason is that: the child order numbers of any
 * link in the latest and approved hierarchies MUST MATCH
 */
procedure update_appr_ch_ord_num_if_reqd
(p_org_id in number,
 p_parent_id in number,
 p_child_id in number,
 p_instance_id in number)

is

l_dummy pls_integer;

begin

  select 1 into l_dummy from amw_approved_hierarchies
  where parent_id = p_parent_id
  and   child_id   = p_child_id
  and   end_date is null
  and   ((-1 = p_org_id and (organization_id is null or organization_id = -1)) OR
         (p_org_id <> -1 and organization_id = p_org_id));

  update amw_approved_hierarchies set
         last_update_date = sysdate,
         last_updated_by = G_USER_ID,
         last_update_login = G_LOGIN_ID,
         child_order_number = p_instance_id,
         object_version_number = object_version_number + 1
  where  parent_id = p_parent_id
  and    child_id  = p_child_id
  and    end_date is null
  and    ((-1 = p_org_id and (organization_id is null or organization_id = -1)) OR
         (p_org_id <> -1 and organization_id = p_org_id));

exception
  when too_many_rows then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  when others then null;


end update_appr_ch_ord_num_if_reqd;

function get_approval_status(p_process_id in number)
return varchar2
is

l_approval_status amw_process.approval_status%type;
begin
l_approval_status := 'D';

select approval_status into l_approval_status
from amw_process where process_id = p_process_id and
end_date is null;

return l_approval_status;


exception

when others then
  return l_approval_status;

end get_approval_status;

--The parent process and the child process both exist as ICM processes
procedure add_existing_process_as_child(

p_parent_process_id in number,
p_child_process_id in number,
l_sysdate in Date default sysdate,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2)

is


  l_api_name constant varchar2(30) := 'add_existing_process_as_child';

  p_init_msg_list varchar2(10) := FND_API.G_FALSE;

  l_dummy pls_integer;

  l_approval_status amw_process.approval_status%type;

  l_child_order_number amw_latest_hierarchies.child_order_number%type;

  CURSOR c1 is
    (select parent_process_id,
            child_process_id,
            child_order_number from AMW_LATEST_HIERARCHY_RL_V
       start with parent_process_id = -1 and
			    parent_approval_status = 'A'
       connect by prior child_process_id = parent_process_id and
                      child_approval_status = 'A' )
	 MINUS

     (select   parent_process_id,
               child_process_id,
               child_order_number
       from AMW_CURR_APP_HIERARCHY_RL_V);


begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if child_process_id is null
  if p_child_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;




  --check if parent process is locked
  if (is_locked_process(p_parent_process_id))
  then
    raise amw_process_locked_exception;
  end if;


  /* check if the child is an ancestor of parent already
   * so that a circular hierarchy cannot be created
   */
  if(is_ancestor_in_hierarchy(p_child_process_id,p_parent_process_id))
  then
    raise amw_circularity_exception;
  end if;


  --we now check if this link is already existing in the latest hierarchy

  open c_link_exist(p_parent_process_id,p_child_process_id);
  fetch c_link_exist into l_dummy;
  if(c_link_exist%found)
  then
      close c_link_exist;
      return;
  end if;
  close c_link_exist;

  /* else, all is fine, we can proceed with revising the parent process
   * and creating the parent, child link in the latest hierarchy
   */
  revise_process_if_necessary(p_process_id => p_parent_process_id,
                              l_sysdate    => l_sysdate);





  --update the latest hierarchy table
  insert into amw_latest_hierarchies(ORGANIZATION_ID,
                                   PARENT_ID,
                                   CHILD_ID,
                                   CHILD_ORDER_NUMBER,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   LAST_UPDATE_LOGIN,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   OBJECT_VERSION_NUMBER
                                   )
         VALUES                   (-1,
                                   p_parent_process_id,
                                   p_child_process_id,
                                   AMW_CHILD_ORDER_S.nextval,
                                   l_sysdate,
                                   g_user_id,
                                   g_login_id,
                                   l_sysdate,
                                   g_user_id,
                                   1)
         returning                CHILD_ORDER_NUMBER
         into                     l_child_order_number;


  update_appr_ch_ord_num_if_reqd(-1, p_parent_process_id, p_child_process_id,
                                 l_child_order_number);


  /* update the denorm table
   * can throw an amw_processing_exception, so it has been handled.
   */
  update_denorm_add_child(p_parent_id => p_parent_process_id,
                          p_child_id  => p_child_process_id,
                          l_sysdate   => l_sysdate);

  /* if the process was approved to begin with
   * and its parent was -1
   * then the approved hierarchy needs to be modified
   */
  l_approval_status := get_approval_status(p_child_process_id);

  if(l_approval_status = 'A' and p_parent_process_id = -1)

  then
    for a_link in c1 loop
      insert into amw_approved_hierarchies
                  (organization_id,
                   parent_id,
                   child_id,
                   start_date,
                   child_order_number,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATION_DATE,
                   CREATED_BY,
                   OBJECT_VERSION_NUMBER)
      values
                   (-1,
                    a_link.parent_process_id,
                    a_link.child_process_id,
                    l_sysdate,
                    a_link.child_order_number,
                    l_sysdate,
                    g_user_id,
                    g_login_id,
                    l_sysdate,
                    g_user_id,
                    1);
    end loop;

    /* now update the denorm table */
    update_approved_denorm(-1,l_sysdate);

  end if;



  --Call the APIs to adjust the risk and control counts
  update_latest_control_counts(p_parent_process_id);
  update_latest_risk_counts(p_parent_process_id);





exception
  when FND_API.G_EXC_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);


  when FND_API.G_EXC_UNEXPECTED_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  when amw_process_locked_exception then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := x_msg_count + 1;
     fnd_message.set_name('AMW','AMW_PROCESS_LOCKED');
     x_msg_data := fnd_message.get;
     fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                             p_procedure_name =>   'add_existing_process_as_child',
       	                     p_error_text => x_msg_data);
     raise FND_API.G_EXC_ERROR;





  when amw_circularity_exception then
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AMW','AMW_CIRCULARITY_CREATION');
      x_msg_count := x_msg_count + 1;
      x_msg_data := fnd_message.get;
      fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                              p_procedure_name =>   'add_existing_process_as_child',
       	                      p_error_text => x_msg_count);
      raise FND_API.G_EXC_ERROR;


  when amw_processing_exception then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);







end add_existing_process_as_child;




procedure delete_child(

p_parent_process_id in number,
p_child_process_id in number,
l_sysdate in Date default sysdate,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2)

is

  l_api_name constant varchar2(30) := 'delete_child';
  p_init_msg_list varchar2(10) := FND_API.G_FALSE;

  l_approval_status amw_process.approval_status%type;

  l_dummy number;

  CURSOR c3 is
    (select  parent_process_id, child_process_id
       from AMW_CURR_APP_HIERARCHY_RL_V
       where parent_process_id is not null)
    MINUS
    (select parent_process_id, child_process_id
       from AMW_CURR_APP_HIERARCHY_RL_V
       start with parent_process_id = -1
	   connect by prior child_process_id = parent_process_id);
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;


  --check if child_process_id is null
    if p_child_process_id is null then
       raise FND_API.G_EXC_ERROR;
    end if;

  --check if parent process is locked
  if (is_locked_process(p_parent_process_id))
  then
     raise amw_process_locked_exception;
  end if;



  /* check if the link exists: if it doesnt then this is an
   * unexpected error
   */

  open c_link_exist(p_parent_process_id,p_child_process_id);
  fetch c_link_exist into l_dummy;

  if(c_link_exist%notfound)
  then
     close c_link_exist;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  close c_link_exist;


  /* revise the parent */
  revise_process_if_necessary(p_process_id => p_parent_process_id,
                              l_sysdate => l_sysdate);






  /* update the latest hierarchy table
   * first we update the denorm table
   */
  delete from amw_latest_hierarchies

  where
         parent_id = p_parent_process_id and
         child_id  = p_child_process_id  and
         (organization_id is null or organization_id = -1);


  if (sql%notfound)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  update_denorm(p_org_id => -1,
                l_sysdate =>l_sysdate);



  /* under some conditions the approved hierarchy
   * may need to be changed
   * the conditions is
   * The process is present under -1 in the approved hierarchy
   */
   begin
     select 1 into l_dummy from amw_approved_hierarchies
     where (organization_id is null or organization_id = -1)
     and   parent_id = -1
     and   child_id = p_child_process_id
     and   end_date is null;

     delete from amw_approved_hierarchies
     where parent_id = -1
     and   child_id = p_child_process_id
     and   (organization_id is null or organization_id = -1)
     and   end_date is null;

     /* run a cursor to remove defunct links */
     for defunct_link in c3 loop
       update amw_approved_hierarchies
       set end_date = l_sysdate,
           object_version_number = object_version_number + 1
       where (organization_id is null or organization_id = -1)
       and parent_id = defunct_link.parent_process_id
       and child_id = defunct_link.child_process_id
       and end_date is null;
     end loop;

     /* finally update the denorm table */
     update_approved_denorm(-1,l_sysdate);



  exception
     when no_data_found then null;
     when others then null;

   end;

  --Call the procedures to update the risk, control counts
  update_latest_control_counts(p_parent_process_id);
  update_latest_risk_counts(p_parent_process_id);




exception
  when FND_API.G_EXC_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);


  when FND_API.G_EXC_UNEXPECTED_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  when amw_process_locked_exception then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := x_msg_count + 1;
     fnd_message.set_name('AMW','AMW_PROCESS_LOCKED');
     x_msg_data := fnd_message.get;
     fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                             p_procedure_name =>   'delete_child',
            	             p_error_text => x_msg_data);
     raise FND_API.G_EXC_ERROR;


  when amw_processing_exception then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);


  when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);







end delete_child;







/* return TRUE is process is locked in RL: either because it is itself
 * submitted for approval or because some higher process is submitted
 * for approval and the approval profile option dictates locking of
 * all downward processes in the hierarchy.
 */
function is_locked_process(p_process_id in number) return boolean is

   cursor c_locks(l_process_id number) is
       select locked_process_id from amw_process_locks
       where (organization_id is null or organization_id=-1) and
             locked_process_id=l_process_id;
   l_dummy number;
   begin
       open c_locks(p_process_id);
       fetch c_locks into l_dummy;
       if(c_locks%notfound)
       then
          close c_locks;
          return false;
       end if;

       close c_locks;
       return true;

end is_locked_process;

















/* this is called to get the process_id from the name and item
 * type. This function will RAISE AN EXCEPTION (not return null)
 * if it does not find such a process in amw_process table
 */
function get_process_id_from_wf_params(p_name in varchar2,
                                       p_item_type in varchar2)
return number is

l_process_id amw_process.process_id%type;

begin

  select process_id into l_process_id from amw_process
  where name = p_name
  and   item_type = p_item_type
  and   end_date is null;


return l_process_id;
exception
  when others
    then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end get_process_id_from_wf_params;

function does_wf_proc_exist_in_icm(p_name in varchar2,
                                   p_item_type in varchar2)
return boolean is

l_dummy pls_integer;

begin

  select 1 into l_dummy from amw_process
  where name = p_name
  and  item_type = p_item_type
  and  end_date is null;

  return true;

exception
  when no_data_found then
    return false;
  when others then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

end does_wf_proc_exist_in_icm;

function get_process_code return varchar2

is


l_code varchar2(100);
l_dummy pls_integer;

l_prefix amw_parameters.parameter_value%type;

begin


l_prefix := AMW_UTILITY_PVT.get_parameter(p_org_id => -1,
                                          p_param_name => 'PROCESS_CODE_PREFIX');


while (true) loop
  select l_prefix || to_char(AMW_PROCESS_CODE_S.nextval) into l_code from dual;

  select 1 into l_dummy from amw_process
  where  process_code = l_code
  and    end_date is null;

end loop;

exception
  when no_data_found then
    return l_code;
  when others then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;


end;
/* create a new icm process and return the process_id */
function create_new_icm_process(
p_name in varchar2,
p_item_type in varchar2,
p_display_name in varchar2,
p_description in varchar2)

return number

is

l_process_id amw_process.process_id%type;
l_process_rev_id amw_process.process_rev_id%type;
l_new_code amw_process.process_code%type;
begin
  l_new_code := get_process_code;

  insert into amw_process       (PROCESS_ID,
                                ITEM_TYPE,
                                NAME,
                                PROCESS_CODE,
                                REVISION_NUMBER,
                                PROCESS_REV_ID,
                                APPROVAL_STATUS,
                                START_DATE,
                                CONTROL_COUNT,
                                RISK_COUNT,
                                ORG_COUNT,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                OBJECT_VERSION_NUMBER,
                                PROCESS_TYPE,
                                PROGRAM_ID,
                                REQUEST_ID,
                                PROGRAM_UPDATE_DATE,
                                RISK_COUNT_LATEST,
                                CONTROL_COUNT_LATEST,
                                SIGNIFICANT_PROCESS_FLAG,
                                STANDARD_PROCESS_FLAG,
                                PROCESS_CATEGORY)

                VALUES
                                (AMW_PROCESS_S.nextval,
                                 p_item_type,
                                 p_name,
                                 l_new_code,
                                 1,
                                 AMW_PROCESS_S.nextval,
                                 'D',
                                 g_sysdate,
                                 0,
                                 0,
                                 0,
                                 g_sysdate,
                                 G_USER_ID,
                                 g_sysdate,
                                 G_USER_ID,
                                 G_LOGIN_ID,
                                 1,
                                 'P',
                                 FND_GLOBAL.CONC_PROGRAM_ID,
                                 FND_GLOBAL.CONC_REQUEST_ID,
                                 DECODE(FND_GLOBAL.CONC_PROGRAM_ID,null,null,g_sysdate),
                                 0,
                                 0,
                                 'Y',
                                 'Y',
                                 'R')
                RETURNING
                                 PROCESS_ID, PROCESS_REV_ID
                INTO
                                 l_process_id, l_process_rev_id;


  insert into amw_process_names_tl
      (
          process_id
         ,revision_number
         ,process_rev_id
         ,display_name
         ,description
         ,language
         ,source_lang
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,object_version_number
      )
      select
          l_process_id
         ,1
         ,l_process_rev_id
         ,p_display_name
         ,p_description
         ,L.LANGUAGE_CODE
         ,USERENV('LANG')
         ,g_sysdate
         ,g_user_id
         ,g_sysdate
         ,g_user_id
         ,g_login_id
         ,1
      from FND_LANGUAGES L
      where L.INSTALLED_FLAG in ('I', 'B');


  return l_process_id;

end create_new_icm_process;

function is_deleted_process(p_process_id in number)
return boolean is
l_dummy pls_integer;
begin
  select 1 into l_dummy from amw_process
  where process_id = p_process_id
  and   end_date is null
  and   deletion_date is not null;

  return true;

exception
  when no_data_found then
    return false;
  when others then
    raise;

end is_deleted_process;

/* @p_parent_process_id : the process_id of the parent process under which to add
 * @p_name : the name (from wf)
 * @p_item_type : the item_type(from wf)
 * @p_instance_id : the instance_id from WF
 * @p_overwrite_ex : 'Y' or 'N' telling whether or not to overwrite ICM defn.
   with WF definition
 */

procedure recursive_wf_import (p_parent_process_id in number,
                               p_name in varchar2,
                               p_item_type in varchar2,
                               p_display_name in varchar2,
                               p_description in varchar2,
                               p_instance_id in number,
                               p_overwrite_ex in varchar2)


is
cursor c_wf_children (l_name in varchar2, l_item_type in varchar2) is
    select activity_item_type, activity_name,
           activity_display_name, activity_description,
           instance_id
    from   amw_wf_process_hierarchy_vl
    where  process_name = l_name and
           process_item_type = l_item_type;
type wf_children_tbl is table of c_wf_children%rowtype;

wfc_tbl wf_children_tbl;


cursor c_wf_minus_icm(l_name in varchar2, l_item_type in varchar2) is
    (select activity_name, activity_item_type
     from amw_wf_process_hierarchy_vl
     where process_name = l_name
     and   process_item_type = l_item_type
    )
    MINUS
    (select child_name activity_name, child_item_type activity_item_type
     from   amw_latest_hierarchy_rl_v
     where  parent_name = l_name
     and    parent_item_type = l_item_type
    );

type wf_minus_icm_tbl is table of c_wf_minus_icm%rowtype;
wf_diff_icm wf_minus_icm_tbl;

cursor c_icm_minus_wf(l_name in varchar2, l_item_type in varchar2) is
    (select child_name, child_item_type
     from   amw_latest_hierarchy_rl_v
     where  parent_name = l_name
     and    parent_item_type = l_item_type
    )
    MINUS
    (select activity_name child_name, activity_item_type child_item_type
     from amw_wf_process_hierarchy_vl
     where process_name = l_name
     and   process_item_type = l_item_type
    );

type icm_minus_wf_tbl is table of c_icm_minus_wf%rowtype;
icm_diff_wf icm_minus_wf_tbl;


CURSOR c1 is
    (select parent_process_id,
            child_process_id,
            child_order_number from AMW_LATEST_HIERARCHY_RL_V
       start with parent_process_id = -1 and
			    parent_approval_status = 'A'
       connect by prior child_process_id = parent_process_id and
                      child_approval_status = 'A' )
	 MINUS

     (select   parent_process_id,
               child_process_id,
               child_order_number
       from AMW_CURR_APP_HIERARCHY_RL_V);




indexing_str varchar2(40);
-- whether am currently processing some recursive invocation on
-- this name and item_type : then value is : 'VISITING'
-- if for first time : value is 'ARRIVED'
-- if already visited : value is 'VISITED'

visiting_status varchar2(8);
l_process_id amw_process.process_id%type;
l_dummy pls_integer;
exist_in_icm boolean;
cur_child_id amw_process.process_id%type;
l_approval_status amw_process.approval_status%type;
security_check varchar2(1);

begin

  indexing_str := p_name || 'w' || p_item_type;

  if(not visited_tbl.exists(indexing_str))
  then
    visiting_status := 'ARRIVED';
  elsif (visited_tbl(indexing_str) = 1)
  then
    visiting_status := 'VISITING';
  else
    visiting_status := 'VISITED';
  end if;



  if(visiting_status = 'VISITING')
  then
    raise wf_cycle_present_exception;
  end if;

  -- so visiting_status = 'ARRIVED' or 'VISITED'
  if(visiting_status = 'VISITED')
  then
    -- 1. Must add link in latest hierarchy unless present
    -- 2. Must add link in approved hierarchy if necessary
    -- 3. Must update instance_id of approved hierarchy if necessary
    -- 4. Must update the denorm table of approved hierarchy if a link was
    --    indeed added

    -- FIRST: Get the process_id : it must be there since this node
    -- has already been visited.
    l_process_id := get_process_id_from_wf_params(p_name, p_item_type);

    -- CHECK IF CIRCULARITY BEING CREATED ...
    -- Notice : circularity can be created only if
    -- this process and its parent were both in ICM before the
    -- recursive_wf_import began ... if circularity is through the
    -- wf hierarchy it will be detected as a cycle in wf ...
    -- hence the point is : we can rely on the non-updated
    -- denorm tables....
    if(is_ancestor_in_hierarchy(l_process_id, p_parent_process_id))
    then
      raise amw_circularity_exception;
    end if;


    -- If this link is not in latest hierachy we add it
    -- If it was present we do not do anything
    -- In particular we DO NOT UPDATE the child_order_number ..
    -- even though p_overwrite_ex may be 'Y'
    begin
      select 1 into l_dummy from amw_latest_hierarchies
      where parent_id = p_parent_process_id
      and   child_id = l_process_id
      and   (organization_id is null or organization_id = -1);
    exception
      when no_data_found
        then
          insert into amw_latest_hierarchies (ORGANIZATION_ID,
                                            PARENT_ID,
                                            CHILD_ID,
                                            CHILD_ORDER_NUMBER,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            OBJECT_VERSION_NUMBER
                                            )
                 values                     (-1,
                                              p_parent_process_id,
                                              l_process_id,
                                              p_instance_id,
                                              g_sysdate,
                                              g_user_id,
                                              g_login_id,
                                              g_sysdate,
                                              g_user_id,
                                              1);
          update_appr_ch_ord_num_if_reqd(-1, p_parent_process_id,
                                         l_process_id,
                                         p_instance_id);

      when others
        then raise;
    end;

    -- In this block we would have added a link to approved_hierarchy if necessary
    -- The only case when this can be necessary is the following
    -- 1. p_parent_process_id = -1 and
    -- 2. the process with l_process_id is approved ...
    -- 3. However this is not possible because : since this process has been
    --    completely visited the calling parent process cannot be -1
    --    -1 can call this recursive procedure on only 1 child ....
    --    thus if that child was already completed ... this procedure
    --    cannot be called with -1 as the parent_process_id .. hence we do
    --    not need to check for addition to the approved hierarchy

    return;

  end if;

  /* so here assume : visiting_status = 'ARRIVED' */
  --first change the visiting status to reflect visiting
  visited_tbl(indexing_str) := 1;

  --check if process exist in ICM
  exist_in_icm := does_wf_proc_exist_in_icm(p_name,p_item_type);


  if(exist_in_icm)
  then
      --just need to add the links in the latest hierarchy if so needed ...
      l_process_id := get_process_id_from_wf_params(p_name, p_item_type);

      if(is_deleted_process(l_process_id))
      then
        raise amw_process_deleted_exception;
      end if;

      if(is_ancestor_in_hierarchy(l_process_id, p_parent_process_id))
      then
        raise amw_circularity_exception;
      end if;

      --security check : the user needs to have appropriate privilege on this
      --process to be able to add it under a process on which the user has the
      --privilege!

      security_check := amw_security_utils_pvt.check_function(p_function => 'AMW_UPD_RL_PROC'
      							     ,p_object_name  => 'AMW_PROCESS_APPR_ETTY'
   							     ,p_instance_pk1_value => to_char(l_process_id)
   							     ,p_instance_pk2_value => '*NULL*'
   							     ,p_instance_pk3_value => '*NULL*'
   							     ,p_instance_pk4_value => '*NULL*'
   							     ,p_instance_pk5_value => '*NULL*');
      --it can be 'T', 'F', 'U' (unsupported API version)
      if (security_check <> 'T') then
        raise amw_insfcnt_prvlg_exception;
      end if;




      begin
        select 1 into l_dummy from amw_latest_hierarchies
        where parent_id = p_parent_process_id
        and   child_id = l_process_id
        and   (organization_id is null or organization_id = -1);
      exception
        when no_data_found then
          insert into amw_latest_hierarchies (ORGANIZATION_ID,
                                            PARENT_ID,
                                            CHILD_ID,
                                            CHILD_ORDER_NUMBER,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_LOGIN,
                                            CREATION_DATE,
                                            CREATED_BY,
                                            OBJECT_VERSION_NUMBER)
          values                            (-1,
                                              p_parent_process_id,
                                              l_process_id,
                                              p_instance_id,
                                              g_sysdate,
                                              g_user_id,
                                              g_login_id,
                                              g_sysdate,
                                              g_user_id,
                                              1);
          update_appr_ch_ord_num_if_reqd(-1, p_parent_process_id,
                                         l_process_id,
                                         p_instance_id);

        when others then
          raise;
      end;



    if(p_overwrite_ex = 'N')
    then
      --dont have to follow the wf_hierarchy any further ...

      --indicate that this node has been visited
      visited_tbl(indexing_str) := 2;
      return;
    else

      --1. get process_id
      --2. Get icm_minus_wf and wf_minus_icm
      --3. if there is a difference ... then revise if necessary
      --4. update info abt links
      --5. for each check if appr_hierarchy needs to be updated
      --6. call recursive on each child
      --7. before returning indicate that you are done

      open c_wf_minus_icm(p_name, p_item_type);
      open c_icm_minus_wf(p_name, p_item_type);
      fetch c_wf_minus_icm bulk collect into wf_diff_icm;
      fetch c_icm_minus_wf bulk collect into icm_diff_wf;



      if(wf_diff_icm.exists(1) or icm_diff_wf.exists(1))
      then
        if(is_locked_process(l_process_id))
        then
          raise amw_process_locked_exception;
        end if;
        revise_process_if_necessary(p_process_id => l_process_id,
                                    l_sysdate => g_sysdate);
      end if;

      --end_date all the links in icm_minus_wf
      if(icm_diff_wf.exists(1))
      then
        for ctr in icm_diff_wf.first .. icm_diff_wf.last loop
          cur_child_id := get_process_id_from_wf_params
                          (icm_diff_wf(ctr).child_name,
                           icm_diff_wf(ctr).child_item_type);

          delete from amw_latest_hierarchies
          where (organization_id is null or organization_id = -1)
          and parent_id = l_process_id
          and child_id  = cur_child_id;
        end loop;
      end if;
      close c_wf_minus_icm;
      close c_icm_minus_wf;

      open c_wf_children(p_name, p_item_type);
      fetch c_wf_children bulk collect into wfc_tbl;
      if(wfc_tbl.exists(1))
      then
        for ctr in wfc_tbl.first .. wfc_tbl.last loop
          recursive_wf_import(p_parent_process_id => l_process_id,
                          p_name   => wfc_tbl(ctr).activity_name,
                          p_item_type => wfc_tbl(ctr).activity_item_type,
                          p_display_name => wfc_tbl(ctr).activity_display_name,
                          p_description => wfc_tbl(ctr).activity_description,
                          p_instance_id => wfc_tbl(ctr).instance_id,
                          p_overwrite_ex => p_overwrite_ex);
        end loop;
      end if;
      close c_wf_children;
    end if;
    --there can be a case where the approved hierarchy needs to be changed
    --if the parent_process_id = -1 and the current procedure is approved ..
    --and will remain approved ...
    --however in this case this recursive invocation must be the first one itself
    --since parent_id = -1


    if(p_parent_process_id = -1)
    then
      select approval_status into l_approval_status
      from   amw_process
      where  process_id = l_process_id
      and    end_date is null;

      if(l_approval_status = 'A')
      then
        /* add link to approved hierarchy if not already there ... */
        for a_link in c1 loop
          insert into amw_approved_hierarchies
                      (organization_id,
                      parent_id,
                      child_id,
                      start_date,
                      child_order_number,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      CREATION_DATE,
                      CREATED_BY,
                      OBJECT_VERSION_NUMBER)
          values
                      (-1,
                       a_link.parent_process_id,
                       a_link.child_process_id,
                       g_sysdate,
                       a_link.child_order_number,
                       g_sysdate,
                       g_user_id,
                       g_login_id,
                       g_sysdate,
                       g_user_id,
                       1);
        end loop;

       /* now update the denorm table */
       update_approved_denorm(-1,g_sysdate);
       update_appr_control_counts;
       update_appr_risk_counts;
      end if;

    end if;

    visited_tbl(indexing_str) := 2;
    return;

  end if;
  /* so process was not in ICM */
  --create a new process and add links ...
  --1. get the process_id of the newly created process
  ---  and make the link from parent to child.
  --2. call recursively on each child
  --3. make links in latest hierarchy
  --4. before returning indicate that you are done ...

  l_process_id := create_new_icm_process(p_name,p_item_type,p_display_name,
                                         p_description);


  insert into amw_latest_hierarchies (organization_id,
                                    parent_id,
                                    child_id,
                                    child_order_number,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    OBJECT_VERSION_NUMBER)
  values
                                   (-1,
                                    p_parent_process_id,
                                    l_process_id,
                                    p_instance_id,
                                    g_sysdate,
                                    g_user_id,
                                    g_login_id,
                                    g_sysdate,
                                    g_user_id,
                                    1);





  /* loop and call recursively on each child in WF */
  open c_wf_children(p_name,p_item_type);
  fetch c_wf_children bulk collect into wfc_tbl;



  if(wfc_tbl.exists(1))
  then
    for ctr in wfc_tbl.first .. wfc_tbl.last loop
      recursive_wf_import(p_parent_process_id => l_process_id,
                          p_name   => wfc_tbl(ctr).activity_name,
                          p_item_type => wfc_tbl(ctr).activity_item_type,
                          p_display_name => wfc_tbl(ctr).activity_display_name,
                          p_description => wfc_tbl(ctr).activity_description,
                          p_instance_id => wfc_tbl(ctr).instance_id,
                          p_overwrite_ex => p_overwrite_ex);
    end loop;
  end if;
  close c_wf_children;

  visited_tbl(indexing_str) := 2;
  return;

end recursive_wf_import;


procedure import_wf_process(
	p_parent_process_id	in number,
	p_comb_string		in varchar2,
	p_overwrite_ex		in varchar2,
	l_sysdate in Date default sysdate,
	p_update_denorm_count IN VARCHAR2 := 'Y',
	x_return_status		out nocopy varchar2,
	x_msg_count		out nocopy number,
	x_msg_data		out nocopy varchar2)
is
  iStart pls_integer := 1;
  iEnd   pls_integer;
  cur_name wf_activities_vl.name%type;
  cur_item_type wf_activities_vl.item_type%type;
  cur_display_name wf_activities_vl.display_name%type;
  cur_description  wf_activities_vl.description%type;
  cur_instance_id  number;


begin
  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  /* initializations for this procedure */
  g_sysdate := l_sysdate;

  while (true) loop
    /* loop level initialization */
    visited_tbl.delete;

    /* returns the position of first occurence of 'w' */
    iEnd := INSTR(p_comb_string, 'x', iStart);
    if(iEnd = 0)
    then
      exit;
    end if;

    cur_name := substr(p_comb_string, iStart, iEnd-iStart);
    iStart := iEnd+1;
    iEnd := INSTR(p_comb_string, 'w', iStart);
    if(iEnd = 0)
    then
      iEnd := length(p_comb_string) + 1;
    end if;
    cur_item_type := substr(p_comb_string, iStart,iEnd-iStart);
    iStart := iEnd + 1;


    /* do your processing */
    select display_name, description, AMW_CHILD_ORDER_S.nextval
    into   cur_display_name, cur_description, cur_instance_id
    from   wf_activities_vl
    where  name = cur_name
    and    item_type = cur_item_type
    and    end_date is null;




    recursive_wf_import(p_parent_process_id  => p_parent_process_id,
                        p_name               => cur_name,
                        p_item_type          => cur_item_type,
                        p_display_name       => cur_display_name,
                        p_description        => cur_description,
                        p_instance_id        => cur_instance_id,
                        p_overwrite_ex       => p_overwrite_ex);




  end loop;
  IF p_update_denorm_count = 'Y' THEN
  /* update the denorm tables .. */
  update_denorm(p_org_id => -1,
                l_sysdate    => g_sysdate);


  /* then update the risk_control_counts */
  update_all_latest_rc_counts(p_mode => 'RC');
 END IF;

exception
    when amw_process_locked_exception then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := x_msg_count + 1;
      fnd_message.set_name('AMW','AMW_PROCESS_LOCKED');
      x_msg_data := fnd_message.get;
      fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                              p_procedure_name =>   'import_wf_process',
           	              p_error_text => x_msg_data);
      raise FND_API.G_EXC_ERROR;

    when amw_circularity_exception then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := x_msg_count + 1;
      fnd_message.set_name('AMW','AMW_WF_CIRCULARITY_CREATION');
      x_msg_data := fnd_message.get;
      fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                              p_procedure_name =>   'import_wf_process',
           	              p_error_text => x_msg_data);
      raise FND_API.G_EXC_ERROR;


    when amw_process_deleted_exception then
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         fnd_message.set_name('AMW','AMW_DELETED_PROC_MODIF');
	 x_msg_data := fnd_message.get;
	 fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
	                         p_procedure_name =>   'import_wf_process',
	            	         p_error_text => x_msg_data);
         raise FND_API.G_EXC_ERROR;

    when amw_insfcnt_prvlg_exception then
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         fnd_message.set_name('AMW','AMW_INSFCNT_OPRN_PRVLG');
	 x_msg_data := fnd_message.get;
	 fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
	                         p_procedure_name =>   'import_wf_process',
	            	         p_error_text => x_msg_data);
         raise FND_API.G_EXC_ERROR;

    when wf_cycle_present_exception then
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := x_msg_count + 1;
         fnd_message.set_name('AMW','AMW_CYCLE_IN_WF_HIERARCHY');
    	 x_msg_data := fnd_message.get;
    	 fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
    	                         p_procedure_name =>   'import_wf_process',
    	            	         p_error_text => x_msg_count);
         raise FND_API.G_EXC_ERROR;

    when OTHERS then
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                p_data => x_msg_data);
end import_wf_process;

















--THIS IS REALLY A MIRROR IMAGE OF add_exisiting_process_as_child PROCEDURE
--WITH SOME CHANGES ....
--The parent process and the child process both exist as ICM processes
procedure add_WEBADI_HIERARCHY_LINKS(
p_child_order_number in number,
p_parent_process_id in number,
p_child_process_id in number,
l_sysdate in Date default sysdate,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2)

is

  l_api_name constant varchar2(30) := 'add_WEBADI_HIERARCHY_LINKS';
  p_init_msg_list varchar2(10) := FND_API.G_FALSE;
  l_dummy pls_integer;
  L_CHILD_ORDER NUMBER;
  l_approval_status amw_process.approval_status%type;
  l_child_order_number amw_latest_hierarchies.child_order_number%type;

  CURSOR c1 is
    (select parent_process_id,
            child_process_id,
            child_order_number from AMW_LATEST_HIERARCHY_RL_V
       start with parent_process_id = -1 and
			    parent_approval_status = 'A'
       connect by prior child_process_id = parent_process_id and
                      child_approval_status = 'A' )
	 MINUS

     (select   parent_process_id,
               child_process_id,
               child_order_number
       from AMW_CURR_APP_HIERARCHY_RL_V);


begin
  ---05.23.2005 npanandi: commenting below log message
  ---FND_FILE.PUT_LINE(FND_FILE.LOG,'add_WEBADI_HIERARCHY_LINKS START');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if child_process_id is null
  if p_child_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;




  --check if parent process is locked
  if (is_locked_process(p_parent_process_id))
  then
    raise amw_process_locked_exception;
  end if;


  /* check if the child is an ancestor of parent already
   * so that a circular hierarchy cannot be created
   */
  if(is_ancestor_in_hierarchy(p_child_process_id,p_parent_process_id))
  then
    raise amw_circularity_exception;
  end if;


  --we now check if this link is already existing in the latest hierarchy

  open c_link_exist(p_parent_process_id,p_child_process_id);
  fetch c_link_exist into l_dummy;


  if(c_link_exist%found)
  then
      close c_link_exist;
      return;
  end if;
  close c_link_exist;

  /* else, all is fine, we can proceed with revising the parent process
   * and creating the parent, child link in the latest hierarchy
   */
  revise_process_if_necessary(p_process_id => p_parent_process_id,
                              l_sysdate    => l_sysdate);





  --update the latest hierarchy table
  ---IF p_child_order_number IS -100, THIS MEANS THAT NO SEQ NUM WAS DEFINED BY USER
  --SO GENERATED VIA SEQUENCE
  IF(P_CHILD_ORDER_NUMBER = -100) THEN
     SELECT AMW_CHILD_ORDER_S.nextval INTO L_CHILD_ORDER FROM DUAL;
  ELSE
     L_CHILD_ORDER := P_CHILD_ORDER_NUMBER;
  END IF;

  insert into amw_latest_hierarchies(ORGANIZATION_ID,
                                   PARENT_ID,
                                   CHILD_ID,
                                   CHILD_ORDER_NUMBER,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   LAST_UPDATE_LOGIN,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   OBJECT_VERSION_NUMBER)
         VALUES                   (-1,
		                   p_parent_process_id,
                                   p_child_process_id,
                                   L_CHILD_ORDER,
                                   l_sysdate,
                                   g_user_id,
                                   g_login_id,
                                   l_sysdate,
                                   g_user_id,
                                   1)
         returning                CHILD_ORDER_NUMBER
         into                     l_child_order_number;


  update_appr_ch_ord_num_if_reqd(-1, p_parent_process_id, p_child_process_id,
                                 l_child_order_number);


  /* update the denorm table
   * can throw an amw_processing_exception, so it has been handled.
   */
   ---COMMENTING THE BELOW ... DON'T NEED THIS FROM WEBADI
   /*
   update_denorm_add_child(p_parent_id => p_parent_process_id,
                          p_child_id  => p_child_process_id,
                          l_sysdate   => l_sysdate);
   */

  /* if the process was approved to begin with
   * and its parent was -1
   * then the approved hierarchy needs to be modified
   */
  select approval_status into l_approval_status
  from amw_process where process_id = p_child_process_id and
  end_date is null;

  if(l_approval_status = 'A' and p_parent_process_id = -1)

  then
    for a_link in c1 loop
      insert into amw_approved_hierarchies
                  (organization_id,
                   parent_id,
                   child_id,
                   start_date,
                   child_order_number,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   CREATION_DATE,
                   CREATED_BY,
                   OBJECT_VERSION_NUMBER)
      values
                   (-1,
                    a_link.parent_process_id,
                    a_link.child_process_id,
                    l_sysdate,
                    a_link.child_order_number,
                    l_sysdate,
                    g_user_id,
                    g_login_id,
                    l_sysdate,
                    g_user_id,
                    1);
    end loop;

    /* now update the denorm table */
    update_approved_denorm(-1,l_sysdate);

  end if;

  ---05.23.2005 npanandi: commenting below log message
  ---FND_FILE.PUT_LINE(FND_FILE.LOG,'add_WEBADI_HIERARCHY_LINKS END');

  --Call the APIs to adjust the risk and control counts
  --COMMENTING THE BELOW .... DON'T NEED THIS WHEN CALLING FROM WEBADI
  ---update_latest_control_counts(p_parent_process_id);
  ---update_latest_risk_counts(p_parent_process_id);

exception
  when FND_API.G_EXC_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);


  when FND_API.G_EXC_UNEXPECTED_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  when amw_process_locked_exception then
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := x_msg_count + 1;
       fnd_message.set_name('AMW','AMW_PROCESS_LOCKED');
       x_msg_data := fnd_message.get;
       fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                               p_procedure_name =>   'add_WEBADI_HIERARCHY_LINKS',
         	               p_error_text => x_msg_data);
       raise FND_API.G_EXC_ERROR;





  when amw_circularity_exception then
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := x_msg_count + 1;
       fnd_message.set_name('AMW','AMW_CIRCULARITY_CREATION');
       x_msg_data := fnd_message.get;
       fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                               p_procedure_name =>   'add_WEBADI_HIERARCHY_LINKS',
         	               p_error_text => x_msg_data);
       raise FND_API.G_EXC_ERROR;


  when amw_processing_exception then
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data);


  when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

end add_WEBADI_HIERARCHY_LINKS;



----------------------------COUNT UPDATE API's---------------------------------------------
/* update the approved risk counts for all processes above
 * p_process_id in RL Approved Hierarchy
 * Call this ONLY AFTER making the denorm tables reflect
 * the current denormed approved hierarchy
 * This can be called for post approval processing
 *** BE CAREFUL WITH THE USE OF THIS PROCEDURE ***
 * This process only affects procedures in the approved_hierarchy
 * The approved_hierarchy is always connected to the root
 * It is possible that a process was approved and yet not present
 * in the approved hierarchy. Thus after some process P was approved
 * and its child Q (approved earlier) was added to the approved
 * hierarchy WHEN P was approved: IF THIS PROCEDURE WAS CALLED ONLY FOR
 * P it will not affect Q and the final result would be INCORRECT.
 */
procedure update_approved_risk_counts(p_process_id in number)
is


cursor c is
(select process_id from amw_process where process_id in
                 ((select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = p_process_id
                   and up_down_ind = 'U'
                   and hierarchy_type = 'A'
                   )
                   union all
                   (select p_process_id from dual)));
type t_n is table of number;
x t_n;
begin
open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
  update amw_process
  set    risk_count      = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 in ( ( select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A') union all (select x(ctr) from dual) )
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'PROCESS'
                            ) ),
         object_version_number = object_version_number + 1,
         last_update_date = sysdate,
         last_updated_by = G_USER_ID,
         last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and approval_date is not null
and approval_end_date is null
and process_id <> -1;
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_approved_risk_counts;


/* update the approved control counts for all processes above
 * p_process_id in RL Approved Hierarchy
 * Call this ONLY AFTER making the denorm tables reflect
 * the current denormed approved hierarchy
 * This can be called for post approval processing
 *** BE CAREFUL WITH THE USE OF THIS PROCEDURE ***
 * This process only affects procedures in the approved_hierarchy
 * The approved_hierarchy is always connected to the root
 * It is possible that a process was approved and yet not present
 * in the approved hierarchy. Thus after some process P was approved
 * and its child Q (approved earlier) was added to the approved
 * hierarchy WHEN P was approved: IF THIS PROCEDURE WAS CALLED ONLY FOR
 * P it will not affect Q and the final result would be INCORRECT.
 */
procedure update_approved_control_counts(p_process_id in number)
is
cursor c is
(select process_id from amw_process where process_id in
                 ((select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = p_process_id
                   and up_down_ind = 'U'
                   and hierarchy_type = 'A'
                   )
                   union all
                   (select p_process_id from dual)));

type t_n is table of number;
x t_n;
begin
open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
  update amw_process
  set    control_count      = (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 in ( ( select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A') union all (select x(ctr) from dual) )
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'RISK'
                            ) ),
         object_version_number = object_version_number + 1,
         last_update_date = sysdate,
         last_updated_by = G_USER_ID,
         last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and approval_date is not null
and approval_end_date is null
and process_id <> -1;
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_approved_control_counts;



/* updates risk counts for every process in
 * the approved hierarchy
 */
procedure update_appr_risk_counts is

cursor c is
(select process_id from amw_process where process_id in
                  (select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = -1
                   and up_down_ind = 'D'
                   and hierarchy_type = 'A'
                   ));
type t_n is table of number;
x t_n;
begin
open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
  update amw_process
  set    risk_count      = (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 in ( ( select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A') union all (select x(ctr) from dual) )
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'PROCESS'
                            ) ),
         object_version_number = object_version_number + 1,
         last_update_date = sysdate,
         last_updated_by = G_USER_ID,
         last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and approval_date is not null
and approval_end_date is null
and process_id <> -1;
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_appr_risk_counts;

procedure update_appr_control_counts is
cursor c is
(select process_id from amw_process where process_id in
                  (select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = -1
                   and up_down_ind = 'D'
                   and hierarchy_type = 'A'
                   ));
type t_n is table of number;
x t_n;

begin

open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process
set control_count = (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 in (  (select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'A') union all (select x(ctr) from dual) )
                            and approval_date is not null
                            and deletion_approval_date is null
                            and object_type = 'RISK'
                            ) )
    ,object_version_number = object_version_number + 1,
         last_update_date = sysdate,
         last_updated_by = G_USER_ID,
         last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and approval_date is not null
and approval_end_date is null
and process_id <> -1;
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;


end update_appr_control_counts;




/* update the latest control counts for all processes above
 * p_process_id in RL
 * Call this ONLY AFTER making the denorm tables reflect
 * the current denormed hierarchy
 */
procedure update_latest_control_counts(p_process_id in number)
is

cursor c is
(select process_id from amw_process where process_id in
                  (select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = p_process_id
                   and up_down_ind = 'U'
                   and hierarchy_type = 'L'
                   ) union all
                   (select p_process_id from dual));
type t_n is table of number;
x t_n;
begin
open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
  update amw_process
  set    control_count_latest      = (select count(*) from (
                            select distinct control_id from amw_control_associations
                            where pk1 in ( ( select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L') union all (select x(ctr) from dual) )
                            and deletion_date is null
                            and object_type = 'RISK'
                            ) )
         --unsure whether FWK validation may throw error if ovn is incremented here
         --so am removing it here.
         --.object_version_number = object_version_number + 1,
         ,last_update_date = sysdate
         ,last_updated_by = G_USER_ID
         ,last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and end_date is null
and process_id <> -1;
end if;



exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_latest_control_counts;


procedure update_latest_risk_counts(p_process_id in number)
is
cursor c is
(select process_id from amw_process where process_id in
                  (select parent_child_id
                   from amw_proc_hierarchy_denorm
                   where process_id = p_process_id
                   and up_down_ind = 'U'
                   and hierarchy_type = 'L'
                   ) union all
                   (select p_process_id from dual));
type t_n is table of number;
x t_n;

begin

open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process
set risk_count_latest =    (select count(*) from (
                            select distinct risk_id from amw_risk_associations
                            where pk1 in (  (select parent_child_id
                            from amw_proc_hierarchy_denorm
                            where process_id = x(ctr)
                            and up_down_ind = 'D'
                            and hierarchy_type = 'L') union all (select x(ctr) from dual) )
                            and deletion_date is null
                            and object_type = 'PROCESS'
                            ) )
     --,object_version_number = object_version_number + 1
     	      ,last_update_date = sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and end_date is null
and process_id <> -1;
end if;

exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_latest_risk_counts;


/* This is only being used by my Java API
 * assumes that a rollback on error will be done from the caller
 * please keep this in mind when using
 */
procedure update_rc_latest_counts(p_process_id in number,
                                  x_return_status out nocopy varchar2,
                                  x_msg_count out nocopy number,
                                  x_msg_data out nocopy varchar2)

is




  l_api_name constant varchar2(30) := 'update_rc_latest_counts';

  p_init_msg_list varchar2(10) := FND_API.G_FALSE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;


  update_latest_risk_counts(p_process_id => p_process_id);
  update_latest_control_counts(p_process_id => p_process_id);

exception
  when others then
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
end update_rc_latest_counts;



/* update the latest risk-control counts for ALL processes in RL */
procedure update_all_latest_rc_counts(p_mode in varchar2)

is
cursor c is
(select process_id from amw_process where end_date is null and process_id <> -1);
type t_n is table of number;
x t_n;

begin
  open c;
  fetch c bulk collect into x;
  close c;

  if x.exists(1) then
  if(p_mode = 'R')
  then
    forall ctr in x.first .. x.last
      update amw_process
      set risk_count_latest = (select count(*) from (
                             select distinct risk_id
                             from amw_risk_associations
                             where pk1 in ((select parent_child_id
                                           from amw_proc_hierarchy_denorm
                                           where process_id = x(ctr)
                                           and up_down_ind = 'D'
                                           and hierarchy_type = 'L') union all (select x(ctr) from dual) )
                                           and deletion_date is null
                                           and object_type = 'PROCESS'
                                          )),
        object_version_number = object_version_number + 1
        ,last_update_date = sysdate
	,last_updated_by = G_USER_ID
        ,last_update_login = G_LOGIN_ID
    where process_id = x(ctr)
    and end_date is null;

  elsif (p_mode = 'C')
  then
    forall ctr in x.first .. x.last
      update amw_process
      set control_count_latest = (select count(*) from

                               (select distinct control_id from amw_control_associations
                                where pk1 in ((select parent_child_id
                                              from amw_proc_hierarchy_denorm
                                              where process_id = x(ctr)
                                              and up_down_ind = 'D'
                                              and hierarchy_type = 'L') union all (select x(ctr) from dual) )
                                and deletion_date is null
                                and object_type = 'RISK'
                                )),
        object_version_number = object_version_number + 1
        ,last_update_date = sysdate
	,last_updated_by = G_USER_ID
        ,last_update_login = G_LOGIN_ID
    where process_id = x(ctr)
    and end_date is null;
  elsif (p_mode = 'RC')
  then
    forall ctr in x.first .. x.last
      update amw_process
            set risk_count_latest = (select count(*) from (
                                   select distinct risk_id
                                   from amw_risk_associations
                                   where pk1 in ((select parent_child_id
                                                 from amw_proc_hierarchy_denorm
                                                 where process_id = x(ctr)
                                                 and up_down_ind = 'D'
                                                 and hierarchy_type = 'L') union all (select x(ctr) from dual) )
                                                 and deletion_date is null
                                                 and object_type = 'PROCESS'
                                                )),

               control_count_latest = (select count(*) from

			                (select distinct control_id from amw_control_associations
			                 where pk1 in ((select parent_child_id
			                               from amw_proc_hierarchy_denorm
			                               where process_id = x(ctr)
			                               and up_down_ind = 'D'
			                               and hierarchy_type = 'L') union all (select x(ctr) from dual) )
			                 and deletion_date is null
			                 and object_type = 'RISK')),
              object_version_number = object_version_number + 1
              ,last_update_date = sysdate
	      ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID
          where process_id = x(ctr)
          and end_date is null;




  end if;
  end if;


exception

when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_all_latest_rc_counts;











/* Update the org_counts for all approved processes in RL
 * Amit, in my opinion we need something that does it per process
 * rather than for everything -- pls, give this a thought
 */
procedure update_all_org_counts

is
cursor c is (select process_id from amw_process where
             approval_date is not null
	     and approval_end_date is null
             and process_id <> -1);
type t_n is table of number;
x t_n;
begin
open c;
fetch c bulk collect into x;
close c;

if x.exists(1) then
forall ctr in x.first .. x.last
update amw_process
set org_count = (select count(*) from
                (select distinct organization_id
                from amw_process_organization
                where process_id = x(ctr)
                and end_date is null
                and (deletion_date is null or (deletion_date is not null and approval_date is null)))),
    object_version_number = object_version_number + 1
    ,last_update_date = sysdate
    ,last_updated_by = G_USER_ID
    ,last_update_login = G_LOGIN_ID
where process_id = x(ctr)
and approval_date is not null
and approval_end_date is null;
end if;

end update_all_org_counts;


/* update the org count for p_process_id */
procedure update_org_count(p_process_id in number)

is

begin
update amw_process
set org_count = (select count(*) from
                (select distinct organization_id
                from amw_process_organization
                where process_id = p_process_id
                and end_date is null
                and (deletion_date is null or (deletion_date is not null and approval_date is null)))),
    object_version_number = object_version_number + 1
    ,last_update_date = sysdate
    ,last_updated_by = G_USER_ID
    ,last_update_login = G_LOGIN_ID
where approval_date is not null
and approval_end_date is null
and process_id <> -1  --retained for safety
and process_id = p_process_id;


exception


when others
  then raise FND_API.G_EXC_UNEXPECTED_ERROR;

end update_org_count;

-------------------------------------------------------------------------------------------


/* the following is needed for ProcessRevisionAMImpl.java
 */

 procedure update_attachments(p_old_prev_id in varchar2,
                              p_new_prev_id in varchar2,
                              x_return_status out nocopy varchar2,
			      x_msg_count out nocopy number,
			      x_msg_data out nocopy varchar2)

 is
  l_api_name constant varchar2(30) := 'update_attachments';

  p_init_msg_list varchar2(10) := FND_API.G_FALSE;

 begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if FND_API.to_Boolean(p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

   --First remove all the old attachments
   FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => 'AMW_PROCESS',
                                                  X_pk1_value   => p_old_prev_id);

   --copy over all attachments of the temporary rev id
   fnd_attached_documents2_pkg.copy_attachments(
                              X_from_entity_name  => 'AMW_PROCESS',
                              X_from_pk1_value    => p_new_prev_id,
                              X_to_entity_name    => 'AMW_PROCESS',
                              X_to_pk1_value      => p_old_prev_id,
                              X_created_by        => g_user_id,
                              X_last_update_login => g_login_id,
                              X_program_id        => FND_GLOBAL.CONC_PROGRAM_ID,
                              X_request_id        => FND_GLOBAL.conc_request_id);


   --remove all the attachments of the temporary id

   FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => 'AMW_PROCESS',
                                                  X_pk1_value   => p_new_prev_id);


 exception
   when OTHERS then

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);

 end update_attachments;

procedure create_new_process_as_child(
p_parent_process_id in number,
p_item_type in varchar2,
p_display_name in varchar2,
p_description in varchar2,
p_control_type in varchar2,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2) is

l_pid number;
l_name number;

begin

select amw_process_name_s.nextval into l_name from dual;

l_pid := create_new_icm_process(
	p_name		=> to_char(l_name),
	p_item_type	=> p_item_type,
	p_display_name	=> p_display_name,
	p_description	=> p_description);

update amw_process
set PROCESS_TYPE = decode(p_control_type, 'A', 'C', 'M', 'C', 'B', 'C', PROCESS_TYPE),
CONTROL_ACTIVITY_TYPE = decode(p_control_type, '-1', CONTROL_ACTIVITY_TYPE, p_control_type)
where process_id = l_pid
and end_date is null;

add_existing_process_as_child(
p_parent_process_id	=> p_parent_process_id,
p_child_process_id	=> l_pid,
x_return_status		=> x_return_status,
x_msg_count		=> x_msg_count,
x_msg_data		=> x_msg_data);

conv_tutor_grants(l_pid);

end create_new_process_as_child;



procedure conv_tutor_add_child(
p_parent_process_id in number,
p_display_name in varchar2,
p_control_type in varchar2,
x_return_status out nocopy varchar2,
x_msg_count out nocopy number,
x_msg_data out nocopy varchar2) is

l_pid number;

begin

select process_id
into l_pid
from AMW_LATEST_REVISIONS_V
where display_name = p_display_name;

add_existing_process_as_child(
p_parent_process_id => p_parent_process_id,
p_child_process_id  => l_pid,
x_return_status => x_return_status,
x_msg_count => x_msg_count,
x_msg_data => x_msg_data);

conv_tutor_grants(l_pid);

exception
    when too_many_rows then
         fnd_message.set_name('AMW','AMW_COV_TUTOR_NONUNQ');
         fnd_message.set_token('AMW_COV_TUTOR_NONUNQ', p_display_name);
         x_msg_data := fnd_message.get;
         x_return_status := FND_API.G_RET_STS_ERROR;


    when no_data_found then
        create_new_process_as_child(
            p_parent_process_id => p_parent_process_id,
            p_item_type => 'AUDITMGR',
            p_display_name => p_display_name,
            p_description => p_display_name,
	    p_control_type => p_control_type,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

end conv_tutor_add_child;


procedure conv_tutor_grants(l_process_id in number) is

l_return_status  varchar2(10);
l_msg_count number;
l_msg_data varchar2(4000);
l_party_id number;

begin

    select person_party_id
    into l_party_id
    from fnd_user
    where user_id = G_USER_ID;

	AMW_SECURITY_PUB.grant_role_guid
	(
	 p_api_version           => 1,
	 p_role_name             => 'AMW_RL_PROC_OWNER_ROLE',
	 p_object_name           => 'AMW_PROCESS_APPR_ETTY',
	 p_instance_type         => 'INSTANCE',
	 p_instance_set_id       => null,
	 p_instance_pk1_value    => l_process_id,
	 p_instance_pk2_value    => null,
	 p_instance_pk3_value    => null,
	 p_instance_pk4_value    => null,
	 p_instance_pk5_value    => null,
	 p_party_id              => l_party_id,
	 p_start_date            => g_sysdate,
	 p_end_date              => null,
	 x_return_status         => l_return_status,
	 x_errorcode             => l_msg_count,
	 x_grant_guid            => l_msg_data);

/*	AMW_SECURITY_PUB.grant_role_guid
	(
	 p_api_version           => 1,
	 p_role_name             => 'AMW_RL_PROC_FINANCE_OWNER_ROLE',
	 p_object_name           => 'AMW_PROCESS_APPR_ETTY',
	 p_instance_type         => 'INSTANCE',
	 p_instance_set_id       => null,
	 p_instance_pk1_value    => l_process_id,
	 p_instance_pk2_value    => null,
	 p_instance_pk3_value    => null,
	 p_instance_pk4_value    => null,
	 p_instance_pk5_value    => null,
	 p_party_id              => l_party_id,
	 p_start_date            => g_sysdate,
	 p_end_date              => null,
	 x_return_status         => l_return_status,
	 x_errorcode             => l_msg_count,
	 x_grant_guid            => l_msg_data);

	AMW_SECURITY_PUB.grant_role_guid
	(
	 p_api_version           => 1,
	 p_role_name             => 'AMW_RL_PROC_APPL_OWNER_ROLE',
	 p_object_name           => 'AMW_PROCESS_APPR_ETTY',
	 p_instance_type         => 'INSTANCE',
	 p_instance_set_id       => null,
	 p_instance_pk1_value    => l_process_id,
	 p_instance_pk2_value    => null,
	 p_instance_pk3_value    => null,
	 p_instance_pk4_value    => null,
	 p_instance_pk5_value    => null,
	 p_party_id              => l_party_id,
	 p_start_date            => g_sysdate,
	 p_end_date              => null,
	 x_return_status         => l_return_status,
	 x_errorcode             => l_msg_count,
	 x_grant_guid            => l_msg_data);
*/

end conv_tutor_grants;



procedure Check_Root_Access(p_predicate    in varchar2,
                            p_hasAccess    out NOCOPY varchar2) is

l_hasaccess varchar2(1) := 'N';
cursor_select   INTEGER;
cursor_execute  INTEGER;
query_to_exec   VARCHAR2(32767);

begin

query_to_exec := 'select process_id from AMW_CURRENT_APPRVD_REV_V where process_id = -1 and '||p_predicate;
cursor_select := DBMS_SQL.OPEN_CURSOR;
DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
cursor_execute := DBMS_SQL.EXECUTE(cursor_select);
IF DBMS_SQL.FETCH_ROWS(cursor_select) > 0 THEN
	l_hasaccess := 'Y';
ELSE
	l_hasaccess := 'N';
END IF;
DBMS_SQL.CLOSE_CURSOR(cursor_select);

p_hasAccess := l_hasAccess;

end Check_Root_Access;



PROCEDURE reset_count(
			errbuf     out nocopy  varchar2,
			retcode    out nocopy  varchar2
			) IS

conc_status 		boolean;

BEGIN
	retcode :=0;
	errbuf :='';

	--updates latest hier denorm
	amw_rl_hierarchy_pkg.update_denorm (-1, sysdate);
	--updates approved hier denorm
	amw_rl_hierarchy_pkg.update_approved_denorm (-1, sysdate);

	update amw_process
	set risk_count = null,
	control_count = null,
	risk_count_latest = null,
	control_count_latest = null;

	--updates latest risk/control counts
	amw_rl_hierarchy_pkg.update_all_latest_rc_counts('RC');
	--updates approved risk counts
	amw_rl_hierarchy_pkg.update_appr_risk_counts;
	--updates approved control counts
	amw_rl_hierarchy_pkg.update_appr_control_counts;
	-- update approved org counts
        amw_rl_hierarchy_pkg.update_all_org_counts;

	commit;

EXCEPTION

	WHEN OTHERS THEN
		rollback;
		retcode :=2;
		errbuf := SUBSTR(SQLERRM,1,1000);
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);

END   reset_count;


-- returns 1 if process is present in the latest hiearchy
-- 0 otherwise
function is_proc_in_ltst_hier(p_process_id in number) return number is
ret_val number := 1;
begin
if p_process_id = -1 then
    return 1;
else
        select 1 into ret_val
        from dual
        where (exists
                (select parent_id from amw_latest_hierarchies
                where parent_id = p_process_id
                and (organization_id = -1 or organization_id is null)))
        or (exists
                (select child_id from amw_latest_hierarchies
                where child_id = p_process_id
                and (organization_id = -1 or organization_id is null)));

        return ret_val;
end if;
exception
        when no_data_found then
            ret_val := 0;
            return ret_val;

        when too_many_rows then -- shouldn't happen... still
            ret_val := 1;
            return ret_val;

end is_proc_in_ltst_hier;

function areChildListSame(p_process_id in number) return varchar is
retvalue varchar2(1);
l_dummy number;
begin

retvalue := 'N';

        begin
           select child_id
           into l_dummy
           from amw_approved_hierarchies
           where parent_id = p_process_id
           and (organization_id is null or organization_id = -1)
           and (end_date is null or end_date > sysdate)
           and child_id not in
              (select child_id
              from amw_latest_hierarchies
              where parent_id = p_process_id
              and   (organization_id is null or organization_id = -1));
       exception
            when no_data_found then
                begin
                   select child_id
                   into l_dummy
                   from amw_latest_hierarchies
                   where parent_id = p_process_id
                   and   (organization_id is null or organization_id = -1)
                   and child_id not in
                       (select child_id
                       from amw_approved_hierarchies
                       where parent_id = p_process_id
                       and (organization_id is null or organization_id = -1)
                       and (end_date is null or end_date > sysdate));
                exception
                    when too_many_rows then
                        return retvalue;
                    when no_data_found then
                        retvalue := 'Y';
                        return retvalue;
                end;
            when too_many_rows then
                return retvalue;
        end;
return retvalue;
end;

function does_apprvd_ver_exst(p_process_id in number) return varchar is
l_dummy number;
begin
    select 1
    into l_dummy
    from amw_process
    where process_id = p_process_id
    and approval_status = 'A';

    return 'Y';

exception
    when no_data_found then
        return 'N';
    when too_many_rows then
        return 'Y';
end;

-- this api is to be called from java to figure out if the process
-- is undoable or not. Based on this, the Undo buutton should
-- be rendered
procedure isProcessUndoAble (	p_process_id in number,
                				ret_value out nocopy varchar2,
	                            x_return_status out nocopy varchar2,
	                            x_msg_count out nocopy number,
	                            x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'isProcessUndoAble';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);
l_dummy number;
appstatus varchar2(10);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

ret_value := 'N';

-- check if the process is draft

select approval_status into appstatus from amw_process
where process_id = p_process_id and end_date is null;

if appstatus <> 'D' then
	return;
end if;

-- check if the draft has been created due to addition/deletion of children

if areChildListSame(p_process_id) = 'Y' then
	ret_value := 'Y';
	return;
else
	return;
end if;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;

--========================================================================================================
-- call this only after calling isProcessUndoAble.
-- This api performs the delete (purging of draft row) action
-- if conditions are satisfied
procedure delete_draft (p_process_id in number,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'delete_draft';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);
appexst varchar2(1);
l_risk_exists boolean :=false;
l_control_exists boolean :=false;
cursor parents(pid number) is
             select parent_id
             from amw_latest_hierarchies
             where child_id = pid
             and   (organization_id is null or organization_id = -1);
parent_rec parents%rowtype;
l_flag varchar2(10);
previd number;
l_dummy number;
ret_val varchar2(10);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;



--ko we need this to be outside of IF block to delete the attachments.
    select process_rev_id
    into previd from amw_process
    where process_id = p_process_id
    and end_date is null;

appexst := does_apprvd_ver_exst(p_process_id);
if appexst = 'Y' then

--ko moved this undoable check from outside of ifblock to inside..As a new draft can be deleted even if it is having children.
 -- do another check for undoablity

         isProcessUndoAble (	p_process_id => p_process_id,
                				ret_value => ret_val,
	                            x_return_status => x_return_status,
	                            x_msg_count => x_msg_count,
	                            x_msg_data => x_msg_data);

	     if ret_val <> 'Y' then
            fnd_message.set_name('AMW','AMW_CANT_UNDO_DRAFT');
            err_msg := fnd_message.get;
            fnd_msg_pub.add_exc_msg(p_pkg_name  => 'amw_rl_hierarchy_pkg',
                       	            p_procedure_name => 'delete_draft',
                                    p_error_text => err_msg);
            raise FND_API.G_EXC_ERROR;
	     end if;
         if  x_return_status <> FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;


    delete from amw_process
    where process_id = p_process_id
    and end_date is null;

    delete from amw_process_names_tl
    where process_rev_id = previd;

    update amw_process
    set end_date = null
    where process_id = p_process_id
    and approval_date is not null
    and approval_end_date is null;

else -- appexst = 'N'

    select standard_process_flag, process_rev_id
    into l_flag, previd from amw_process
    where process_id = p_process_id;

    if l_flag = 'Y' then
        begin
            select 1 into l_dummy from dual
            where exists
            (select 1 from amw_process
            where standard_variation = previd
            and end_date is null);

            fnd_message.set_name('AMW','AMW_CANT_DEL_DRAFT_NS');
            err_msg := fnd_message.get;
            fnd_msg_pub.add_exc_msg(p_pkg_name  => 'amw_rl_hierarchy_pkg',
                       	            p_procedure_name => 'delete_draft',
                                    p_error_text => err_msg);
            raise FND_API.G_EXC_ERROR;

        exception
                when no_data_found then
                    null;
        end;
    end if;

    for parent_rec in parents(p_process_id) loop
    	  exit when parents%notfound;
    	  revise_process_if_necessary(parent_rec.parent_id);
    	  delete from amw_latest_hierarchies
    	  where parent_id = parent_rec.parent_id
    	  and child_id = p_process_id
    	  and (organization_id is null or organization_id = -1);
 	end loop;

--kosriniv need to de link the children this process has..
    delete from amw_latest_hierarchies
    where parent_id = p_process_id
    and (organization_id is null or organization_id = -1);
    delete from amw_process where process_id = p_process_id;
    delete from amw_process_names_tl where process_rev_id = previd;

end if;

-- perform other common delete operations

delete from amw_risk_associations
where pk1 = p_process_id
and approval_date is null
and object_type = 'PROCESS';
--ko we need to update the latest risk & controls counts..
IF SQL%FOUND THEN
l_risk_exists := TRUE;
END IF;

update amw_risk_associations
set deletion_date = null
where pk1 = p_process_id
and object_type = 'PROCESS'
and deletion_date is not null
and deletion_approval_date is null;

IF SQL%FOUND THEN
l_risk_exists := TRUE;
END IF;

delete from amw_control_associations
where pk1 = p_process_id
and approval_date is null
and object_type = 'RISK';

IF SQL%FOUND THEN
l_control_exists := TRUE;
END IF;

update amw_control_associations
set deletion_date = null
where pk1 = p_process_id
and object_type = 'RISK'
and deletion_date is not null
and deletion_approval_date is null;

IF SQL%FOUND THEN
l_control_exists := TRUE;
END IF;

delete from amw_acct_associations
where pk1 = p_process_id
and approval_date is null
and object_type = 'PROCESS';

update amw_acct_associations
set deletion_date = null
where pk1 = p_process_id
and object_type = 'PROCESS'
and deletion_date is not null
and deletion_approval_date is null;


delete from amw_objective_associations
where pk1 = p_process_id
and approval_date is null
and object_type in ('PROCESS', 'CONTROL');

update amw_objective_associations
set deletion_date = null
where pk1 = p_process_id
and object_type in ('PROCESS', 'CONTROL')
and deletion_date is not null
and deletion_approval_date is null;


delete from amw_significant_elements
where pk1 = p_process_id
and approval_date is null
and object_type = 'PROCESS';

update amw_significant_elements
set deletion_date = null
where pk1 = p_process_id
and object_type = 'PROCESS'
and deletion_date is not null
and deletion_approval_date is null;


FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(X_entity_name => 'AMW_PROCESS',
                                               X_pk1_value   => previd);

-- cancel existing change requests

-- update latest hierarchy denorm
amw_rl_hierarchy_pkg.update_denorm (-1, sysdate);

--ko update the risk control counts..

if appexst = 'Y' AND l_risk_exists then

-- Update the latest risk control counts..
  update_latest_risk_counts(p_process_id);
end if;

if appexst = 'Y' AND l_control_exists then

  update_latest_control_counts(p_process_id);

end if;

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end;


--========================================================================================================
-- call this in the create process from UI page..
-- This api gives the user process owner grant..
-- if conditions are satisfied
procedure create_process_owner_grant (p_process_id in varchar2,
                        x_return_status out nocopy varchar2,
                        x_msg_count out nocopy number,
                        x_msg_data out nocopy varchar2) is

l_api_name constant varchar2(30) := 'create_process_owner_grant';
p_init_msg_list varchar2(10) := FND_API.G_FALSE;
err_msg varchar2(4000);
l_party_id number;

begin

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  select person_party_id
    into l_party_id
    from fnd_user
    where user_id = G_USER_ID;

	AMW_SECURITY_PUB.grant_role_guid
	(
	 p_api_version           => 1,
	 p_role_name             => 'AMW_RL_PROC_OWNER_ROLE',
	 p_object_name           => 'AMW_PROCESS_APPR_ETTY',
	 p_instance_type         => 'INSTANCE',
	 p_instance_set_id       => null,
	 p_instance_pk1_value    => p_process_id,
	 p_instance_pk2_value    => null,
	 p_instance_pk3_value    => null,
	 p_instance_pk4_value    => null,
	 p_instance_pk5_value    => null,
	 p_party_id              => l_party_id,
	 p_start_date            => g_sysdate,
	 p_end_date              => null,
	 x_return_status         =>x_return_status,
	 x_errorcode             => x_msg_count,
	 x_grant_guid            => x_msg_data);



exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end create_process_owner_grant;

-- *******************************************************--

procedure delete_activities(p_parent_process_id in number,
			   			   p_child_id_string in varchar2,
	                       x_return_status out nocopy varchar2,
                           x_msg_count out nocopy number,
                           x_msg_data out nocopy varchar2)
is
l_api_name constant varchar2(30) := 'delete_activities';
p_init_msg_list varchar2(10) := FND_API.G_TRUE;
str              varchar2(4000);
diff		 	 number;
childstr		 varchar2(100);
l_child_string   varchar2(4000);
l_child_id		 number;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_child_string :=  p_child_id_string;
  while LENGTH(l_child_string) <> 0 loop
    select LTRIM(l_child_string, '1234567890') into str from dual;
    diff := LENGTH(l_child_string) - LENGTH(str);
    if  LENGTH(str) is null then
      diff := LENGTH(l_child_string);
    end if;
    select SUBSTR(l_child_string, 1, diff) into childstr from dual;
    l_child_id := to_number(childstr);
    delete from amw_latest_hierarchies where parent_id = p_parent_process_id
    and child_id = l_child_id and organization_id = -1;
    select LTRIM(str, 'x') into l_child_string from dual;
  end loop;
exception
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
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count, p_data => x_msg_data);

end delete_activities;


--The parent process and the child process both exist as ICM processes
procedure add_activities(  p_parent_process_id in number,
			   			   p_child_id_string in varchar2,
			   			   p_sysdate in Date default sysdate,
	                       x_return_status out nocopy varchar2,
                           x_msg_count out nocopy number,
                           x_msg_data out nocopy varchar2)
is
  l_api_name constant varchar2(30) := 'add_activities';
  l_dummy pls_integer;
  l_approval_status amw_process.approval_status%type;
  l_child_order_number amw_latest_hierarchies.child_order_number%type;
  p_init_msg_list varchar2(10) := FND_API.G_TRUE;
  str              varchar2(4000);
  diff		 	 number;
  childstr		 varchar2(100);
  l_child_string   varchar2(4000);
  l_child_id		 number;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  if FND_GLOBAL.user_id is null then
     AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent_process_id is null
  if p_parent_process_id is null then
     raise FND_API.G_EXC_ERROR;
  end if;

  --check if parent process is locked
  if (is_locked_process(p_parent_process_id))
  then
    raise amw_process_locked_exception;
  end if;

  l_child_string :=  p_child_id_string;
  while LENGTH(l_child_string) <> 0 loop
    select LTRIM(l_child_string, '1234567890') into str from dual;
    diff := LENGTH(l_child_string) - LENGTH(str);
    if  LENGTH(str) is null then
      diff := LENGTH(l_child_string);
    end if;
    select SUBSTR(l_child_string, 1, diff) into childstr from dual;
    l_child_id := to_number(childstr);
    /* check if the child is an ancestor of parent already
   	* so that a circular hierarchy cannot be created
   	*/
  	if(is_ancestor_in_hierarchy(l_child_id,p_parent_process_id))
  	then
    	raise amw_circularity_exception;
  	end if;

  	--we now check if this link is already existing in the latest hierarchy

  	open c_link_exist(p_parent_process_id,l_child_id);
  	fetch c_link_exist into l_dummy;
  	if(c_link_exist%found)
  	then
      close c_link_exist;
      return;
  	end if;
  	close c_link_exist;


	--update the latest hierarchy table
    insert into amw_latest_hierarchies(ORGANIZATION_ID,
                                   PARENT_ID,
                                   CHILD_ID,
                                   CHILD_ORDER_NUMBER,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   LAST_UPDATE_LOGIN,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   OBJECT_VERSION_NUMBER
                                   )
         VALUES                   (-1,
                                   p_parent_process_id,
                                   l_child_id,
                                   AMW_CHILD_ORDER_S.nextval,
                                   p_sysdate,
                                   g_user_id,
                                   g_login_id,
                                   p_sysdate,
                                   g_user_id,
                                   1)
         returning                CHILD_ORDER_NUMBER
         into                     l_child_order_number;


  	update_appr_ch_ord_num_if_reqd(-1, p_parent_process_id, l_child_id,
                                 l_child_order_number);


    select LTRIM(str, 'x') into l_child_string from dual;
  end loop;

exception
  when FND_API.G_EXC_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
  when amw_process_locked_exception then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := x_msg_count + 1;
     fnd_message.set_name('AMW','AMW_PROCESS_LOCKED');
     x_msg_data := fnd_message.get;
     fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                             p_procedure_name =>  l_api_name,
       	                     p_error_text => x_msg_data);
     raise FND_API.G_EXC_ERROR;
  when amw_circularity_exception then
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AMW','AMW_CIRCULARITY_CREATION');
      x_msg_count := x_msg_count + 1;
      x_msg_data := fnd_message.get;
      fnd_msg_pub.add_exc_msg(p_pkg_name  =>    G_PKG_NAME,
                              p_procedure_name =>   l_api_name,
       	                      p_error_text => x_msg_count);
      raise FND_API.G_EXC_ERROR;
  when amw_processing_exception then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
  when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

end add_activities;

procedure revise_process(p_process_id in number,
  						 p_init_msg_list	IN VARCHAR2 := FND_API.G_FALSE,
						 x_return_status out nocopy varchar2,
						 x_msg_count out nocopy number,
						 x_msg_data out nocopy varchar2)
is
begin
  G_USER_ID := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  revise_process_if_necessary(p_process_id => p_process_id);

exception
	when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
end revise_process;

PROCEDURE update_latest_denorm_counts
( p_process_id		    IN NUMBER,
  p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status		   OUT NOCOPY VARCHAR2,
  x_msg_count			   OUT NOCOPY VARCHAR2,
  x_msg_data			   OUT NOCOPY VARCHAR2)
IS

  L_API_NAME CONSTANT VARCHAR2(30) := 'update_latest_denorm_counts';


BEGIN

--always initialize global variables in th api's used from SelfSerivice Fwk..
   G_USER_ID := FND_GLOBAL.USER_ID;
   G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- update the latest denorm hierarchy..
	AMW_RL_HIERARCHY_PKG.update_denorm(p_org_id => -1);
-- Update the Risk Counts..
    update_latest_risk_counts(p_process_id => p_process_id);
-- Update the Control Counts..
    update_latest_control_counts( p_process_id => p_process_id);


exception
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
END update_latest_denorm_counts;

end AMW_RL_HIERARCHY_PKG;

/
