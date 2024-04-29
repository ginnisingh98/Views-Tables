--------------------------------------------------------
--  DDL for Package Body PQH_RBC_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RBC_VALIDATE" AS
/* $Header: pqrbcval.pkb 120.5 2006/03/23 13:28 srajakum noship $ */

function matrix_has_criteria(p_copy_entity_txn_id in number) return varchar2 is
   l_copy_entity_result_id number;

   cursor c1 is select copy_entity_result_id from ben_copy_entity_results
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE';
BEGIN
    open c1;
    fetch c1 into l_copy_entity_result_id;
    if c1%notfound then
       RETURN 'NO';
    else
       RETURN 'YES';
    end if;
    close c1;
END matrix_has_criteria;


function matrix_has_rates(p_copy_entity_txn_id in number) return varchar2 is
   l_copy_entity_result_id number;

   cursor c1 is select copy_entity_result_id from ben_copy_entity_results
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'RMR' and dml_operation <> 'DELETE'
                and Information297 is not null
                and Information297 <> 0;
BEGIN
    open c1;
    fetch c1 into l_copy_entity_result_id;
    if c1%notfound then
       RETURN 'NO';
    else
       RETURN 'YES';
    end if;
    close c1;
END matrix_has_rates;

function matrix_has_criteria_values(p_copy_entity_txn_id in number) return varchar2 is
   l_copy_entity_result_id number;

   cursor c1 is select copy_entity_result_id from ben_copy_entity_results
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'RMV' and dml_operation <> 'DELETE';
BEGIN
    open c1;
    fetch c1 into l_copy_entity_result_id;
    if c1%notfound then
       RETURN 'NO';
    else
       RETURN 'YES';
    end if;
    close c1;
END matrix_has_criteria_values;


function matrix_has_criteria_nodes(p_copy_entity_txn_id in number) return varchar2 is
   l_status varchar2(30);
   l_short_code varchar(30);
   l_name varchar(240);
   l_level_number number;
   l_copy_entity_result_id number;

   cursor c1 is select INFORMATION13,INFORMATION160  from ben_copy_entity_results
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE';

   cursor c2(l_sh_code varchar,l_level_num number)
    is select copy_entity_result_id from ben_copy_entity_results
                where copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'RMN' and dml_operation <> 'DELETE'
                and INFORMATION13 = l_sh_code and INFORMATION160 =  l_level_num;

   cursor c3(l_sh_code varchar)
    is select name from ben_eligy_criteria
                where short_code = l_sh_code;

BEGIN
l_status := 'YES';
    open c1;
    loop
        fetch c1 into l_short_code,l_level_number;
        exit when c1%notfound;

        open c3(l_short_code);
        fetch c3 into l_name;
        if c3%notfound then
           l_status := 'NO';
           hr_utility.set_message(8302,'PQH_RBC_CRIT_DOESNT_EXIST');
           hr_utility.set_message_token('SHORT_CODE',l_short_code);
           hr_multi_message.add;
        end if;
        close c3;

        open c2(l_short_code,l_level_number);
        fetch c2 into l_copy_entity_result_id;
        if c2%notfound then
           l_status := 'NO';
           hr_utility.set_message(8302,'PQH_RBC_NODES_ADD_ONE');
           hr_utility.set_message_token('CRIT_NAME',l_name);
           hr_multi_message.add;
        end if;
        close c2;
    end loop;
    close c1;

return l_status;
END matrix_has_criteria_nodes;



function matrix_has_rate_type(p_copy_entity_txn_id in number) return varchar2 is
   l_crit_rate_defn_id number;

   cursor c1 is Select information1 from ben_copy_entity_results
            Where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RCR';

BEGIN
    open c1;
    fetch c1 into l_crit_rate_defn_id;
    if c1%notfound then
       RETURN 'NO';
    else
       RETURN 'YES';
    end if;
    close c1;
END matrix_has_rate_type;

function matrix_has_criteria_dup(p_copy_entity_txn_id in number) return varchar2 is
   l_crit_rate_defn_id number;
   l_return_val varchar2(3);
   cursor c1 is select count(information13) from ben_copy_entity_results
               where table_alias = 'RBC_CRIT' and dml_operation <> 'DELETE' and copy_entity_txn_id = p_copy_entity_txn_id
               group by information13;

BEGIN
    l_return_val := 'NO';
    open c1;
    loop
        fetch c1 into l_crit_rate_defn_id;
        exit when c1%notfound;
        if(l_crit_rate_defn_id > 1) then
           l_return_val := 'YES';
        end if;
    end loop;
    close c1;
    RETURN l_return_val;
END matrix_has_criteria_dup;

function plan_name_exists(l_pl_id in number,p_name in varchar2, p_business_group_id in number) return varchar2 is
   l_name varchar2(240);
   cursor c1 is select name from ben_pl_f
               where name = p_name
               and pl_id <> l_pl_id
               and business_group_id = p_business_group_id;

BEGIN
    open c1;
    fetch c1 into l_name;
    if c1%notfound then
       RETURN 'NO';
    else
       --dbms_output.put_line('name already exists'||l_name);
       hr_utility.set_message(8302,'PQH_RBC_MATRIX_NAME_EXISTS');
       hr_utility.set_message_token('MATRIX_NAME',l_name);
       hr_multi_message.add;
       RETURN 'YES';
    end if;
    close c1;
END plan_name_exists;

--

function plan_short_code_exists(l_pl_id in number,p_short_code in varchar2, p_business_group_id in number) return varchar2 is
   l_short_code varchar2(240);
   cursor c1 is select short_code from ben_pl_f
               where short_code = p_short_code
               and pl_id <> l_pl_id
               and business_group_id = p_business_group_id;

BEGIN
    open c1;
    fetch c1 into l_short_code;
    if c1%notfound then
       RETURN 'NO';
    else
       --dbms_output.put_line('short code already exists'||p_short_code);
       hr_utility.set_message(8302,'PQH_RBC_PLN_SHORT_CODE_EXISTS');
       hr_utility.set_message_token('SHORT_CODE',l_short_code);
       hr_multi_message.add;
       RETURN 'YES';
    end if;
    close c1;
END plan_short_code_exists;
--
function plan_short_name_exists(l_pl_id in number,p_short_name in varchar2, p_business_group_id in number) return varchar2 is
   l_short_name varchar2(240);
   cursor c1 is select short_name from ben_pl_f
               where short_name = p_short_name
               and pl_id <> l_pl_id
               and business_group_id = p_business_group_id;

BEGIN
    open c1;
    fetch c1 into l_short_name;
    if c1%notfound then
       RETURN 'NO';
    else
       --dbms_output.put_line('short name already exists'||p_short_name);
       hr_utility.set_message(8302,'PQH_RBC_PLN_SHORT_NAME_EXISTS');
       hr_utility.set_message_token('SHORT_NAME',l_short_name);
       hr_multi_message.add;
       RETURN 'YES';
    end if;
    close c1;
END plan_short_name_exists;


--
function check_plan_duplicate(p_copy_entity_txn_id in number) return varchar2 is
    l_plan_name varchar2(240);
    l_short_code varchar2(30);
    l_short_name varchar2(30);
    l_pl_id number;
    l_business_group_id number;
    l_status varchar2(10);
    cursor c1 is select information1,information170, information93, information94, information4
        from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'PLN';
begin
    l_status := 'NO';
    open c1;
    fetch c1 into l_pl_id,l_plan_name, l_short_code, l_short_name, l_business_group_id;

    if(c1%notfound) then
       hr_utility.set_message(8302,'PQH_RBC_INVALID_ENTITY_TXN');
       hr_multi_message.add;
       l_status := 'YES';
    else
        if(plan_name_exists(l_pl_id,l_plan_name,l_business_group_id) = 'YES') then
           l_status := 'YES';
        end if;
        if(plan_short_code_exists(l_pl_id,l_short_code,l_business_group_id) = 'YES') then
            l_status := 'YES';
        end if;
        if(plan_short_name_exists(l_pl_id,l_short_name,l_business_group_id) = 'YES') then
           l_status := 'YES';
        end if;
    end if;
   close c1;

   return l_status;
end check_plan_duplicate;
---

function check_critval_dup_in_rmn(p_copy_entity_result_id_node number,p_copy_entity_result_id_val number) return varchar2 is

l_copy_entity_result_id number;
l_status varchar(10);
    --get all children of node except the current input val row we have to compare
    cursor c1 is select copy_entity_result_id
        from ben_copy_entity_results
        where gs_parent_entity_result_id = p_copy_entity_result_id_node
        and table_alias = 'RMV' and dml_operation <> 'DELETE'
        and copy_entity_result_id <> p_copy_entity_result_id_val;


begin
    --dbms_output.put_line('Checking check_critval_dup_in_rmn: RMN Node id:'||p_copy_entity_result_id_node||' RMV value to check in RMN:'|| p_copy_entity_result_id_val );
    l_status := 'NO';
    open c1; --get all RMV's and iterate 1 by 1
    loop
    fetch c1 into l_copy_entity_result_id;
        exit when c1%notfound;
    --dbms_output.put_line('Value row got in node to compare:'||l_copy_entity_result_id);
    --check if both are duplicate rows
    if(check_critval_row(l_copy_entity_result_id,p_copy_entity_result_id_val) = 'YES')then
        --dbms_output.put_line('matrix has duplicate criteria values ITER:'||l_copy_entity_result_id || 'AND BASE:' || p_copy_entity_result_id_val );
        l_status := 'YES';
        -- add exception (name value already exists)
    end if;

    end loop;
    close c1;
return l_status;
end check_critval_dup_in_rmn;

---

function check_critval_dup_in_txn(p_copy_entity_txn_id number) return varchar2 is
l_status varchar2(10);
l_copy_entity_result_id1 number;
l_node_id1 number;

l_copy_entity_result_id2 number;
l_copy_entity_result_id3 number;

    --get all values in the transaction
    cursor c1 is select copy_entity_result_id,gs_parent_entity_result_id
        from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'RMV' and dml_operation <> 'DELETE';

    --get parent node id of rmn itself
    cursor c2(node_id number) is select gs_parent_entity_result_id
        from ben_copy_entity_results
        where copy_entity_result_id = node_id
        and table_alias = 'RMN' and dml_operation <> 'DELETE';

    --get all children nodes of a parent node
    cursor c3(parent_node_id number,exclude_node_id number) is select copy_entity_result_id
        from ben_copy_entity_results
        where gs_parent_entity_result_id = parent_node_id
        and table_alias = 'RMN' and dml_operation <> 'DELETE'
        and copy_entity_result_id <> exclude_node_id;

begin
    l_status := 'NO';

    open c1; --get all RMV's in staging and iterate 1 by 1
    loop
    fetch c1 into l_copy_entity_result_id1, l_node_id1;
        exit when c1%notfound;

    --First level: check values with in direct parent
    --dbms_output.put_line('First level is being done at same level for node:'||l_node_id1||' And value:'|| l_copy_entity_result_id1);
    if(check_critval_dup_in_rmn(l_node_id1,l_copy_entity_result_id1) = 'YES') then
        --dbms_output.put_line('duplicate values found at same level Warning !!!!!!!!!!');
        l_status := 'YES';
    end if;

    --dbms_output.put_line('Second level is being done:');
        --Second level: get parent node id of node id and check with its values;
         open c2(l_node_id1); --get parent node of the rmn node
         fetch c2 into l_copy_entity_result_id2;

         if(l_copy_entity_result_id2 is not null) then
            --dbms_output.put_line('Got parent node:'||l_copy_entity_result_id2 ||' For node:'||l_node_id1);
            open c3(l_copy_entity_result_id2,l_node_id1); --get all RMV's in staging and iterate 1 by 1 exclude node itself
            loop
            fetch c3 into l_copy_entity_result_id3;
                exit when c3%notfound;
                --dbms_output.put_line('Comparing children of Main parent row got (After excluding self node_id):'|| l_copy_entity_result_id3 );
                if(check_critval_dup_in_rmn(l_copy_entity_result_id3,l_copy_entity_result_id1) = 'YES') then
                   l_status := 'YES';
                   --dbms_output.put_line('Found duplicate in this comparision Warning !!!!!!!!!!!!');
                end if;
            end loop;
            close c3;

         end if;

        close c2;
   end loop;
   close c1;

return l_status;

end check_critval_dup_in_txn;




function check_critval_row  (p_copy_entity_result_id_row1 number
                            ,p_copy_entity_result_id_row2 number
                            ) return varchar2 is

p_row1_char1 varchar2(255);
p_row1_char2 varchar2(255);
p_row1_char3 varchar2(255);
p_row1_char4 varchar2(255);
p_row1_num1  number;
p_row1_num2  number;
p_row1_num3  number;
p_row1_num4  number;
p_row1_date1 date;
p_row1_date2 date;
p_row1_date3 date;
p_row1_date4 date;
p_row2_char1 varchar2(255);
p_row2_char2 varchar2(255);
p_row2_char3 varchar2(255);
p_row2_char4 varchar2(255);
p_row2_num1  number;
p_row2_num2  number;
p_row2_num3  number;
p_row2_num4  number;
p_row2_date1 date;
p_row2_date2 date;
p_row2_date3 date;
p_row2_date4 date;

p_row1_org_hier_id number;
p_row1_starting_org_id number;

p_row1_pos_hier_id number;
p_row1_starting_pos_id number;

p_row2_org_hier_id number;
p_row2_starting_org_id number;

p_row2_pos_hier_id number;
p_row2_starting_pos_id number;

  cursor c1(p_copy_entity_result_id number) is select
    information13,information14,information15,information16,
    information169,information174,information221,information222,
    information166,information167,information306,information307,
    information223,information224,information225,information226
    from ben_copy_entity_results
    where copy_entity_result_id = p_copy_entity_result_id
    and table_alias = 'RMV' and dml_operation <> 'DELETE';

begin
--same row not compare
if(p_copy_entity_result_id_row1 = p_copy_entity_result_id_row2) then

return 'NO';

else

    --dbms_output.put_line('compare rows row1:'||p_copy_entity_result_id_row1||' row2:'|| p_copy_entity_result_id_row2);
    open c1(p_copy_entity_result_id_row1);
    fetch c1 into p_row1_char1,p_row1_char2,p_row1_char3,p_row1_char4,
                  p_row1_num1,p_row1_num2,p_row1_num3,p_row1_num4,
                  p_row1_date1,p_row1_date2,p_row1_date3,p_row1_date4,
                  p_row1_org_hier_id,p_row1_starting_org_id,p_row1_pos_hier_id,p_row1_starting_pos_id;


    close c1;

    /*
    dbms_output.put_line('ROW1:'||p_row1_char1||p_row1_char2||p_row1_char3||p_row1_char4||
                  p_row1_num1||p_row1_num2||p_row1_num3||p_row1_num4||
                  p_row1_date1||p_row1_date2||p_row1_date3||p_row1_date4||
                  p_row1_org_hier_id||p_row1_starting_org_id||p_row1_pos_hier_id||p_row1_starting_pos_id);

    */
    open c1(p_copy_entity_result_id_row2);
    fetch c1 into p_row2_char1,p_row1_char2,p_row2_char3,p_row2_char4,
                  p_row2_num1,p_row2_num2,p_row2_num3,p_row2_num4,
                  p_row2_date1,p_row2_date2,p_row2_date3,p_row2_date4,
                  p_row2_org_hier_id,p_row2_starting_org_id,p_row2_pos_hier_id,p_row2_starting_pos_id;

    close c1;
    /*
    dbms_output.put_line('ROW2:'||p_row2_char1||p_row2_char2||p_row2_char3||p_row2_char4||
                  p_row2_num1||p_row2_num2||p_row2_num3||p_row2_num4||
                  p_row2_date1||p_row2_date2||p_row2_date3||p_row2_date4||
                  p_row2_org_hier_id||p_row2_starting_org_id||p_row2_pos_hier_id||p_row2_starting_pos_id);
    */

    if  (   (p_row1_char1 is  NULL or p_row1_char1 = p_row2_char1)
        and (p_row1_char2 is  NULL or p_row1_char2 = p_row2_char2)
        and (p_row1_char3 is  NULL or p_row1_char3 = p_row2_char3)
        and (p_row1_char4 is  NULL or p_row1_char4 = p_row2_char4)

        and (p_row1_num1 is  NULL or p_row1_num1 = p_row2_num1)
        and (p_row1_num2 is  NULL or p_row1_num2 = p_row2_num2)
        and (p_row1_num3 is  NULL or p_row1_num3 = p_row2_num3)
        and (p_row1_num4 is  NULL or p_row1_num4 = p_row2_num4)

        and (p_row1_date1 is NULL or p_row1_date1 = p_row2_date1)
        and (p_row1_date2 is NULL or p_row1_date2 = p_row2_date2)
        and (p_row1_date3 is NULL or p_row1_date3 = p_row2_date3)
        and (p_row1_date4 is NULL or p_row1_date4 = p_row2_date4)

        and (p_row1_org_hier_id is NULL or p_row1_org_hier_id = p_row2_org_hier_id)
        and (p_row1_starting_org_id is NULL or p_row1_starting_org_id = p_row2_starting_org_id)
        and (p_row1_pos_hier_id is NULL or p_row1_pos_hier_id = p_row2_pos_hier_id)
        and (p_row1_starting_pos_id is NULL or p_row1_starting_pos_id = p_row2_starting_pos_id)


    ) then
        --dbms_output.put_line('This two rows are same Warning !!!!!!!!!!!!! ');
        return 'YES';

    end if;

end if;
 --dbms_output.put_line('This two rows are not same -- success -- ');

return 'NO';

end check_critval_row;


function matrix_has_ratetype_dup(p_copy_entity_txn_id in number) return varchar2 is
   l_crit_rate_defn_id number;
   l_return_val varchar2(3);

 cursor c1 is Select count(information1) from ben_copy_entity_results
            Where copy_entity_txn_id = p_copy_entity_txn_id and table_alias = 'RCR'
            group by information1;

BEGIN
    l_return_val := 'NO';
    open c1;
    loop
        fetch c1 into l_crit_rate_defn_id;
        exit when c1%notfound;
        if(l_crit_rate_defn_id > 1) then
           l_return_val := 'YES';
        end if;
    end loop;
    close c1;
    RETURN l_return_val;
END matrix_has_ratetype_dup;


procedure validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2)is
l_status varchar2(10);
begin
l_status := 'YES';

    hr_multi_message.enable_message_list;

--/*
    --dbms_output.put_line('matrix_has_rates:');
    if( matrix_has_rates(p_copy_entity_txn_id) = 'NO') then
    -- add exception(matrix has no rates added)
        hr_utility.set_message(8302,'PQH_RBC_RATES_ADD_ONE');
        hr_multi_message.add;
    l_status := 'NO';
    end if;
--*/

--/*
    --dbms_output.put_line('check_plan_duplicate:');
    if( check_plan_duplicate(p_copy_entity_txn_id) = 'YES') then
    --dbms_output.put_line('plan already exist');
     -- add exception(matrix plan is duplicated)
    hr_utility.set_message(8302,'PQH_RBC_REENTER_PLAN_INFO');
    hr_multi_message.add;
    l_status := 'NO';
    end if;
--*/

--/*
    --dbms_output.put_line('matrix_has_criteria:');
    if( matrix_has_criteria(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no criteria added and criteria dup not being checked');
        -- add exception(matrix has no criteria added)
        hr_utility.set_message(8302,'PQH_RBC_CRIT_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    else
        if( matrix_has_criteria_dup(p_copy_entity_txn_id) = 'YES') then
            --dbms_output.put_line('matrix has duplicate criteria added');
            -- add exception(matrix has duplicate criteria added)
            hr_utility.set_message(8302,'PQH_RBC_MATRIX_CRITERIA_DUP');
            hr_multi_message.add;
            l_status := 'NO';
        end if;
    end if;

--*/

--/*
    --dbms_output.put_line('matrix_has_rate_type:');
    if( matrix_has_rate_type(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no rate type added and not checking dup for it');
        -- add exception(matrix has no rate type added)
        hr_utility.set_message(8302,'PQH_RBC_RATE_TYPE_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    else
        if( matrix_has_ratetype_dup(p_copy_entity_txn_id) = 'YES') then
            --dbms_output.put_line('matrix has duplicate rate type');
             -- add exception(matrix has duplicate rate type)
            hr_utility.set_message(8302,'PQH_RBC_MATRIX_RATE_TYPE_DUP');
            hr_multi_message.add;
            l_status := 'NO';
        end if;
    end if;
--*/

--/*
    --dbms_output.put_line('matrix_has_criteria_nodes:');
    if( matrix_has_criteria_nodes(p_copy_entity_txn_id) = 'NO') then
    l_status := 'NO';
    end if;
--*/

--/*
    --dbms_output.put_line('matrix_has_criteria_values:');
    if( matrix_has_criteria_values(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no criteria values and not checking dup for it');
        -- add exception(matrix has no criteria values)
        hr_utility.set_message(8302,'PQH_RBC_CRIT_VAL_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    else
        -- matrix has criteria values so proceed to check duplicates
        --dbms_output.put_line('matrix_has_criteria_values and checking duplicates:');
        if( check_critval_dup_in_txn(p_copy_entity_txn_id) = 'YES') then
            --dbms_output.put_line('matrix has duplicate criteria values');
            -- add exception(matrix has duplicate criteria values)
            hr_utility.set_message(8302,'PQH_RBC_CRIT_VAL_DUP_IN_PAGE');
            hr_multi_message.add;
            l_status := 'NO';
        end if;
    end if;
--*/

 p_status := l_status ;

end validate_matrix;




procedure pre_validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2)is
l_status varchar2(10);
begin
l_status := 'YES';
FND_MSG_PUB.initialize;
hr_multi_message.enable_message_list;


--/*
    --dbms_output.put_line('matrix_has_criteria:');
    if( matrix_has_criteria(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no criteria added and criteria dup not being checked');
        -- add exception(matrix has no criteria added)
        hr_utility.set_message(8302,'PQH_RBC_CRIT_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    end if;

--*/

--/*
    --dbms_output.put_line('matrix_has_rate_type:');
    if( matrix_has_rate_type(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no rate type added and not checking dup for it');
        -- add exception(matrix has no rate type added)
        hr_utility.set_message(8302,'PQH_RBC_RATE_TYPE_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    end if;
--*/

--/*
    --dbms_output.put_line('matrix_has_criteria_nodes:');
    if( matrix_has_criteria_nodes(p_copy_entity_txn_id) = 'NO') then
        l_status := 'NO';
    end if;
--*/

--/*
    --dbms_output.put_line('matrix_has_criteria_values:');
    if( matrix_has_criteria_values(p_copy_entity_txn_id) = 'NO') then
        --dbms_output.put_line('matrix has no criteria values and not checking dup for it');
        -- add exception(matrix has no criteria values)
        hr_utility.set_message(8302,'PQH_RBC_CRIT_VAL_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    end if;

--/*
    --dbms_output.put_line('matrix_has_rates:');
    if( matrix_has_rates(p_copy_entity_txn_id) = 'NO') then
        -- add exception(matrix has no rates added)
        hr_utility.set_message(8302,'PQH_RBC_RATES_ADD_ONE');
        hr_multi_message.add;
        l_status := 'NO';
    end if;
--*/


 p_status := l_status ;

end pre_validate_matrix;

procedure check_warnings(p_copy_entity_txn_id in number,p_status out nocopy varchar2,p_warning_message out nocopy varchar2)is
l_status varchar2(10);
l_count number;
l_criteria_rate_defn number;
l_crit_rate_defn_name varchar2(240);
l_crit_rate_defn_names varchar2(2400);
l_num number;
cursor c1 is select Information1
        from ben_copy_entity_results
        where
        table_alias = 'RCR' and dml_operation <> 'DELETE'
        and copy_entity_txn_id = p_copy_entity_txn_id;

begin
    l_status := 'YES';
    l_crit_rate_defn_names := '';
    l_num := 0;
    FND_MSG_PUB.initialize;

    -- for each criteria rate defn added we have one RCR row created
    -- check for each rcr row created if you have atleast one rmr row created
    open c1; --get all RCR's and iterate 1 by 1
    loop
        fetch c1 into l_criteria_rate_defn;
            exit when c1%notfound;

        select name into l_crit_rate_defn_name from pqh_criteria_rate_defn_vl where criteria_rate_defn_id = l_criteria_rate_defn;
        l_count := 0;
        select count(*) into l_count from ben_copy_entity_results
            where
            table_alias = 'RMR' and dml_operation <> 'DELETE'
            and copy_entity_txn_id = p_copy_entity_txn_id
            and Information162 = l_criteria_rate_defn;

        if l_count = 0 then
            l_status := 'NO';
            if l_num <> 0 then
                l_crit_rate_defn_names := concat(l_crit_rate_defn_names,', ');
                l_num := l_num+1;
           end if;
            l_crit_rate_defn_names := concat(l_crit_rate_defn_names,l_crit_rate_defn_name);
        end if;

    end loop;
    close c1;

    if l_status = 'NO' then
        hr_utility.set_message(8302,'PQH_RBC_RATE_DEFN_RATES_WARN');
        hr_utility.set_message_token('NAME',l_crit_rate_defn_names);
        p_warning_message := hr_utility.get_message;
    else
        p_warning_message := '';
    end if;

 p_status := l_status ;

end check_warnings;



procedure on_validate_matrix(p_copy_entity_txn_id in number,p_status out nocopy varchar2)is
l_status varchar2(10);
begin
   l_status := 'YES';
   FND_MSG_PUB.initialize;
   hr_multi_message.enable_message_list;
--/*
    --dbms_output.put_line('check_plan_duplicate:');
    if( check_plan_duplicate(p_copy_entity_txn_id) = 'YES') then
    --dbms_output.put_line('plan already exist');
     -- add exception(matrix plan is duplicated)
    hr_utility.set_message(8302,'PQH_RBC_REENTER_PLAN_INFO');
    hr_multi_message.add;
    l_status := 'NO';
    end if;
--*/

--/*
--    --dbms_output.put_line('matrix_has_criteria:');
--    if( matrix_has_criteria(p_copy_entity_txn_id) = 'NO') then
--        --dbms_output.put_line('matrix has no criteria added and criteria dup not being checked');
--        -- add exception(matrix has no criteria added)
--        hr_utility.set_message(8302,'PQH_RBC_CRIT_ADD_ONE');
--        hr_multi_message.add;
--        l_status := 'NO';
--    else
        if( matrix_has_criteria_dup(p_copy_entity_txn_id) = 'YES') then
            --dbms_output.put_line('matrix has duplicate criteria added');
            -- add exception(matrix has duplicate criteria added)
            hr_utility.set_message(8302,'PQH_RBC_MATRIX_CRITERIA_DUP');
            hr_multi_message.add;
            l_status := 'NO';
        end if;
--    end if;

--*/

--/*
--    --dbms_output.put_line('matrix_has_rate_type:');
--    if( matrix_has_rate_type(p_copy_entity_txn_id) = 'NO') then
--        --dbms_output.put_line('matrix has no rate type added and not checking dup for it');
--        -- add exception(matrix has no rate type added)
--        hr_utility.set_message(8302,'PQH_RBC_RATE_TYPE_ADD_ONE');
--        hr_multi_message.add;
--        l_status := 'NO';
--    else
        if( matrix_has_ratetype_dup(p_copy_entity_txn_id) = 'YES') then
            --dbms_output.put_line('matrix has duplicate rate type');
             -- add exception(matrix has duplicate rate type)
            hr_utility.set_message(8302,'PQH_RBC_MATRIX_RATE_TYPE_DUP');
            hr_multi_message.add;
            l_status := 'NO';
        end if;
--    end if;
--*/


--/* We may not need to check duplicate criteria values because we do in pages
--    --dbms_output.put_line('matrix_has_criteria_values:');
--    if( matrix_has_criteria_values(p_copy_entity_txn_id) = 'NO') then
--        --dbms_output.put_line('matrix has no criteria values and not checking dup for it');
--        -- add exception(matrix has no criteria values)
--        hr_utility.set_message(8302,'PQH_RBC_CRIT_VAL_ADD_ONE');
--        hr_multi_message.add;
--        l_status := 'NO';
--    else
--         We may not need to check duplicate criteria values because we do in pages
--        dbms_output.put_line('matrix_has_criteria_values and checking duplicates:');
--        if( check_critval_dup_in_txn(p_copy_entity_txn_id) = 'YES') then
--           dbms_output.put_line('matrix has duplicate criteria values');
--           add exception(matrix has duplicate criteria values)
--           hr_utility.set_message(8302,'PQH_RBC_CRIT_VAL_DUP_IN_PAGE');
--           hr_multi_message.add;
--           l_status := 'NO';
--        end if;
--    end if;
--*/

 p_status := l_status ;

end on_validate_matrix;




end PQH_RBC_VALIDATE;

/
