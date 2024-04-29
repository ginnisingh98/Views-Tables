--------------------------------------------------------
--  DDL for Package Body PQH_GSP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_UTILITY" as
/* $Header: pqgsputl.pkb 120.10.12010000.2 2008/08/05 13:35:44 ubhat ship $ */

g_package  Varchar2(30) := 'pqh_gsp_utility.';
g_debug boolean := hr_utility.debug_enabled;

--
---------------------------get_gsp_plntyp_str_date-----------------------------
--
function get_gsp_plntyp_str_date (p_business_group_id  in number
                                 ,p_copy_entity_txn_id  in number default  null )
return date is
   l_proc varchar2(72) := g_package||'get_gsp_plntyp_str_date';
   l_plan_type_date DATE ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
   select min(effective_start_date)
     into l_plan_type_date
     from ben_pl_typ_f
    where business_group_id = p_business_group_id
      and opt_typ_cd ='GSP'
      and pl_typ_stat_cd ='A';
   hr_utility.set_location('Plan Type date is :'|| l_plan_type_date, 20);
   if l_plan_type_date is null and p_copy_entity_txn_id is not null
   then
      begin
         select information308
           into l_plan_type_date
           from ben_copy_entity_results
          where copy_entity_txn_id = p_copy_entity_txn_id
            and table_alias = 'PGM';
      hr_utility.set_location('Plan Type date is :'|| l_plan_type_date, 30);
      exception
         when no_data_found then
            l_plan_type_date := null ;
      end;
   end if ;
   return l_plan_type_date ;
exception
   when others then
      hr_utility.set_location('Problem in determining Plan Type date ',40);
      raise;
end get_gsp_plntyp_str_date ;
--
---------------------------gsp_plan_type_exists-----------------------------
--
function gsp_plan_type_exists (p_business_group_id  in number)
return varchar2 is
   l_proc varchar2(72) := g_package||'gsp_plan_type_exists';
   l_status varchar2(1) ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
   begin
      select 'Y'
        into l_status
        from ben_pl_typ_f
       where business_group_id = p_business_group_id
         and opt_typ_cd ='GSP'
         and pl_typ_stat_cd ='A'
         and rownum<2 ;
   exception
         when no_data_found then
            l_status := 'N';
            hr_utility.set_location('GSP Plan Type does not exist ',40);
   end ;
   return l_status;
end gsp_plan_type_exists ;
--
---------------------------chk_grade_exist_in_gl-----------------------------
--

FUNCTION chk_grade_exist_in_gl
(
 p_copy_entity_txn_id     IN    ben_copy_entity_results.copy_entity_result_id%TYPE
)
RETURN  VARCHAR2 IS
/*
  Author  : mvankada
  Purpose : This function checks whether any Grade(s) attached to Grade Later or not.
  If atleast one Grade has attached to Grade Ladder then this funtion returns 'Y' else 'N'

  Used in : This function call is used in Grade HGrid page to enable/disable or
            To throw error Message if No grades are attached to Grade Ladder
  1) Progression Order Icon
  2) Continue to Next Task button

*/

CURSOR csr_grade_in_gl
IS
Select copy_entity_result_id
From   ben_copy_entity_results
Where  Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND    Table_Alias = 'CPP'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    nvl(Information104,'PPP') <> 'UNLINK';

l_cer number;
l_proc   varchar2(72) := g_package||'chk_grade_exist_in_gl';

BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_copy_entity_txn_id '||l_proc,20);
end if;

Open csr_grade_in_gl;
Fetch csr_grade_in_gl into l_cer;
if csr_grade_in_gl%found then
   return 'Y';
Else
   return 'N';
End If;
Close csr_grade_in_gl;
EXCEPTION
  WHEN OTHERS THEN
     return 'N';
End chk_grade_exist_in_gl;

--
---------------------------remove_grade_from_grdldr-----------------------------
--

Procedure remove_grade_from_grdldr
(
 p_Grade_Result_Id     IN    ben_copy_entity_results.copy_entity_result_id%TYPE,
 p_Copy_Entity_Txn_Id     IN    ben_copy_entity_results.copy_entity_txn_id%TYPE,
 p_Business_Group_Id      IN    Number,
 p_Effective_Date         IN    Date,
 p_Rec_Exists             OUT NOCOPY   Varchar2
) IS

/*
   Author : mvankada
   Purpose :
    I) This procedure checks whether rec to be removed is in Staging Area Only or in Main Tables
          p_rec_exists has values :
          =======================
           MAIN    Main Table
           STAGE   Staging Area
    II) If the record to be removed is in Main Tables then this procedure also checks whether
        the grade is attached  to the employee or not. If attached then raise the error.
*/

l_pgm_id     Number;
l_grade_id   Number;
l_assg_id    Number;
l_dummy      Char(1);
l_grade_name            Ben_Copy_Entity_Results.Information5%Type;
l_proc   varchar2(72) := g_package||'remove_grade_from_grdldr';
l_message_type     varchar2(10) := 'W';
l_warnings_rec     pqh_utility.warnings_rec;
l_business_area varchar2(50) := 'PQH_GSP_TASK_LIST';
l_crpth_hier_ver number;
l_corps_id number;
l_grade_crpath_node number;

-- To Get Pgm_Id of PGM based on Txn_id
Cursor csr_pgm_id
IS
Select grdldr.Information1
From   Ben_Copy_Entity_Results grdldr
Where  grdldr.Table_Alias = 'PGM'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grdldr.Copy_Entity_Txn_Id = p_Copy_Entity_Txn_Id
And    Information4 = p_Business_Group_Id;

-- To Get Corps_definition_Id of CPD based on Txn_id

Cursor csr_corps_id
IS
Select grdldr.Information1
From   Ben_Copy_Entity_Results grdldr
Where  grdldr.Table_Alias = 'CPD'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grdldr.Copy_Entity_Txn_Id = p_Copy_Entity_Txn_Id
And    Information4 = p_Business_Group_Id;



-- To Get Grade_Id (information253) of CPP based on Result_id  of CPP
Cursor csr_grade_id
IS
Select grd.Information253,
       grd.Information5
From   Ben_Copy_Entity_Results grd
Where  grd.Table_Alias = 'CPP'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grd.Copy_Entity_Result_Id = p_Grade_Result_Id;



-- Check Grade and Grade Ladder is attached to an employee
Cursor csr_gl_grade_assg_emp (l_pgm_id Number, l_grade_id Number)
IS
Select assignment_id
From   per_all_assignments_f assgt
Where  grade_id = l_grade_id
AND    Grade_Ladder_Pgm_Id     = l_pgm_id
AND    p_Effective_Date BETWEEN assgt.effective_start_date
AND    nvl(assgt.effective_end_date,hr_general.end_of_time)
AND    assgt.business_group_id = p_Business_Group_Id;


-- Check Grade is attached to an employee
Cursor csr_grd_assg_emp (l_grade_id Number)
IS
Select Null
From   per_all_assignments_f assgt
Where  grade_id = l_grade_id
AND    p_Effective_Date BETWEEN assgt.effective_start_date
AND    nvl(assgt.effective_end_date,hr_general.end_of_time)
AND    assgt.business_group_id = p_Business_Group_Id;


Cursor csr_default_grdldr
IS
Select   Null
From     ben_pgm_f
Where    pgm_id = l_pgm_id
And      pgm_typ_cd = 'GSP'
And      Dflt_Pgm_Flag = 'Y'
And      business_group_id = p_business_group_id
And      p_Effective_Date Between Effective_Start_date
And      nvl(Effective_End_Date,hr_general.end_of_time);

Cursor csr_grade_crpath_node
IS
select null
      from per_gen_hierarchy_nodes
      where hierarchy_version_id = l_crpth_hier_ver
      and information9 = l_corps_id
      and information23 = l_grade_id;


BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_Grade_Result_Id '||p_Grade_Result_Id,20);
hr_utility.set_location('p_Copy_Entity_Txn_Id '||p_Copy_Entity_Txn_Id,30);
hr_utility.set_location('p_Effective_Date '||p_Effective_Date,40);
hr_utility.set_location('p_Business_Group_Id '||p_business_group_id,50);
end if;

hr_multi_message.enable_message_list;

-- Get Pgm_Id
Open csr_pgm_id;
Fetch csr_pgm_id into l_pgm_id;
Close csr_pgm_id;

if g_debug then
hr_utility.set_location('Pgm_Id '||l_pgm_id,70);
end if;

-- Get Grade Id
Open csr_grade_id;
Fetch csr_grade_id into l_grade_id,l_grade_name;
Close csr_grade_id;

if g_debug then
hr_utility.set_location('Grade Id '||l_grade_id,80);
hr_utility.set_location('Grade Name '||l_grade_name,81);
end if;

IF (l_grade_id is NOT  NULL AND l_pgm_id IS NOT NULL ) THEN

  -- If the Grade Ladder is Default Grade Ladder, if the employee placements exists
  -- on grade then raise warning message.
  Open csr_default_grdldr;
  Fetch csr_default_grdldr into l_dummy;
  If csr_default_grdldr%Found Then
if g_debug then
      hr_utility.set_location('Grade Ladder is Default Grade Ladder',85);
end if;
      Close csr_default_grdldr;

      Open csr_grd_assg_emp(l_grade_id);
      Fetch csr_grd_assg_emp into l_dummy;
      IF csr_grd_assg_emp%Found Then
            Close csr_grd_assg_emp;
if g_debug then
            hr_utility.set_location('Employe placements exist on the Default Grade Ladder Grades',87);
end if;
if g_debug then
            hr_utility.set_location('Grade Name '||l_grade_name,88);
end if;
            p_rec_exists := l_grade_name;
      Else
         p_rec_exists := 'MAIN';
         Close csr_grd_assg_emp;
      End if;
  Else
      p_rec_exists := 'MAIN';
      Close csr_default_grdldr;


      Open csr_gl_grade_assg_emp(l_pgm_id, l_grade_id);
      Fetch csr_gl_grade_assg_emp into l_assg_id;
      if csr_gl_grade_assg_emp%found then
         if g_debug then
               hr_utility.set_location(' Employe placements exist on the Grades',90);
         end if;
         hr_utility.set_message(8302,'PQH_GSP_CANNOT_UNLINK_GRD');
         hr_utility.raise_error;
      end if;
      Close csr_gl_grade_assg_emp;

      l_business_area := pqh_corps_utility.get_cet_business_area(p_copy_entity_txn_id);
      if l_business_area = 'PQH_CORPS_TASK_LIST' then
        -- Get Corps_Id
        Open csr_corps_id;
        Fetch csr_corps_id into l_corps_id;
        Close csr_corps_id;

        if l_corps_id is not null then

        l_crpth_hier_ver := pqh_cpd_hr_to_stage.get_crpth_hier_ver;

        OPEN csr_grade_crpath_node;
         FETCH csr_grade_crpath_node into l_grade_crpath_node;
      if csr_grade_crpath_node%found then
         if g_debug then
               hr_utility.set_location(' Corps and Grade are part of a Career Path',90);
         end if;
         hr_utility.set_message(8302,'PQH_GSP_GRD_PART_OF_CRPATH');
         hr_utility.raise_error;
      end if;
         CLOSE csr_grade_crpath_node;
        end if;
      end if;


 END IF;

ELSE
  p_rec_exists := 'STAGE';
END IF;
if g_debug then
  hr_utility.set_location('p_rec_exists :'||p_rec_exists,99);
  hr_utility.set_location('Leaving '||l_proc,100);
end if;
EXCEPTION
  WHEN others THEN
     p_rec_exists := 'STAGE';
     fnd_msg_pub.add;
End remove_grade_from_grdldr;

--
---------------------------GET_PGM_TYP-----------------------------
--
FUNCTION GET_PGM_TYP (p_cpy_enty_txn_id       in  number)
RETURN varchar2 is
BEGIN
    RETURN 'GSP' ;
EXCEPTION
   WHEN others THEN

return 'GSP' ;
END;

--
---------------------------ENABLE_DISABLE_START_ICON-----------------------------
--
FUNCTION ENABLE_DISABLE_START_ICON(p_gsp_node in varchar2,
                                   p_copy_enty_txn_id in number,
                                   p_table_alias in varchar2)
RETURN varchar2 is
st_icon varchar2(10) := 'N';
prev_task varchar2(10);
l_table_alias varchar2(50) := 'PQH_GSP_TASK_LIST';
--
l_proc 	varchar2(72) := g_package||'enable_disable_start_icon';
--
BEGIN
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
  hr_utility.set_location('p_gsp_node is '||p_gsp_node,5);
  hr_utility.set_location('p_copy_entity_txn_id is '||p_copy_enty_txn_id,10);
  hr_utility.set_location('p_table_alias is '||p_table_alias,15);
end if;

if (p_table_alias is not null) then
	l_table_alias := p_table_alias;
end if;

if p_gsp_node = '1' then
	st_icon := 'Y';
else
	select nvl(pa.decode_function_name, '99') into prev_task from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;

st_icon := get_status(prev_task, p_copy_enty_txn_id, l_table_alias);
end if;

if g_debug then
  hr_utility.set_location('Leaving Successfully'||l_proc,5);
end if;

    RETURN st_icon;
EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
return 'N';
END;
--
--
---------------------------GET_STATUS-----------------------------
--
FUNCTION GET_STATUS(p_gsp_node in varchar2,
                    p_copy_enty_txn_id in number,
                    p_table_alias in varchar2)
RETURN varchar2 is
st_icon varchar2(10) := 'Y';
l_table_alias varchar2(50) := 'PQH_GSP_TASK_LIST';
--
l_proc 	varchar2(72) := g_package||'get_status';
--
BEGIN
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
  hr_utility.set_location('p_gsp_node is '||p_gsp_node,5);
  hr_utility.set_location('p_copy_entity_txn_id is '||p_copy_enty_txn_id,10);
  hr_utility.set_location('p_table_alias is '||p_table_alias,15);
end if;

if (p_table_alias is not null) then
	l_table_alias := p_table_alias;
end if;

if l_table_alias = 'PQH_CORPS_TASK_LIST' Then

   st_icon := pqh_corps_utility.get_cpd_status(p_node_number        => p_gsp_node,
                                               p_copy_entity_txn_id => p_copy_enty_txn_id);
Return st_icon;

End If;
if p_gsp_node = '1' then
	select bcer.information100 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '2' then
	select bcer.information101 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '3' then
	select bcer.information102 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '4'then
	select bcer.information103 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '5' then
	select bcer.information104 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '6' then
	select bcer.information105 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
elsif p_gsp_node = '7' then
	select bcer.information106 into st_icon from
	ben_copy_entity_results bcer, pqh_table_route ptr, pqh_attributes pa
		where
	bcer.table_route_id = ptr.table_route_id
	and ptr.table_route_id = pa.master_table_route_id
	and ptr.table_alias = l_table_alias
	and pa.attribute_name = p_gsp_node
	and bcer.copy_entity_txn_id = p_copy_enty_txn_id;
else
st_icon := 'N';
end if;
if g_debug then
  hr_utility.set_location('Leaving Successfully'||l_proc,5);
end if;
    RETURN st_icon;
EXCEPTION
   WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
return 'N';
END;

--
---------------------------USE_POINT_OR_STEP-----------------------------
--
FUNCTION USE_POINT_OR_STEP(p_copy_entity_txn_id       in  number)
RETURN varchar2 IS
/*
  Author  : mvankada
  Purpose : This Function checks whether Grade Ladder is using Steps or Points
            and returns the values STEP/POINT
*/
l_result Varchar2(20);
l_proc   varchar2(72) := g_package||'USE_POINT_OR_STEP';

Cursor csr_use_points
IS
Select  Decode(nvl(grdldr.INFORMATION18,'N'),'Y','POINT','STEP')   /* INFORMATION18 -> Use Progression Points */
FROM    Ben_Copy_Entity_Results grdldr
WHERE   grdldr.Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND     grdldr.Table_Alias        = 'PGM';


BEGIN

if g_debug then
hr_utility.set_location('Leaving '||l_proc,10);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,20);
end if;

Open csr_use_points;
Fetch csr_use_points into l_result;
Close csr_use_points;

if g_debug then
hr_utility.set_location('l_result  '||l_result,25);
end if;
return l_result;

if g_debug then
hr_utility.set_location('Leaving '||l_proc,30);
end if;

EXCEPTION
When others THEN
    l_result := 'STEP';
    return l_result;

END USE_POINT_OR_STEP;

--
---------------------------remove_step_from_grade-----------------------------
--
Procedure remove_step_from_grade
(
 p_step_result_id         IN    ben_copy_entity_results.copy_entity_result_id%TYPE,
 p_copy_entity_txn_id     IN    number,
 p_effective_date         IN    Date,
 p_use_points             IN    varchar2,
 p_step_id                IN    ben_copy_entity_results.information1%TYPE,
 p_celing_step_flag       IN    varchar2,
 p_rec_exists             OUT NOCOPY   Varchar2
 ) IS


 /*
   Author  : mvankada
   Purpose :
      1) This procedure is used to  Check whether Record to be removed is in Staging Area Only
             or in Main Tables
                  p_rec_exists has values :
                  =======================
                   MAIN    Main Table
                   STAGE   Staging Area

     II) If the Record to be removed is the HR/BEN Tables  and if the Step is
         1)  Ceiling Step
         2)  Special Ceiling Step
         3)  Employee Placements on this Step
        then raise the error.

*/


l_business_area varchar2(50) := 'PQH_GSP_TASK_LIST';
l_crpth_hier_ver number;
l_corps_id number;
l_grade_crpath_node number;
l_pgm_id       Number;
l_grade_id        Number;
l_proc            varchar2(72) := g_package||'remove_step_from_grade';

-- To Get information1 (Pgm_ID) of PGM, based on TXN_ID
 Cursor csr_pgm_id
 IS
 Select  grdldr.information1    -- PGM_ID
 From    Ben_Copy_Entity_Results  grdldr
 Where   grdldr.Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
 AND     grdldr.Table_Alias =  'PGM';

-- To Get Corps_definition_Id of CPD based on Txn_id

Cursor csr_corps_id
IS
Select grdldr.Information1
From   Ben_Copy_Entity_Results grdldr
Where  grdldr.Table_Alias = 'CPD'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grdldr.Copy_Entity_Txn_Id = p_Copy_Entity_Txn_Id;

-- To Get information253 (Grade_id) of CPP, based on Step Result Id
Cursor csr_grade_id
IS
Select  grd.information253
From    Ben_Copy_Entity_Results  grd
Where   grd.Table_Alias = 'CPP'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND     grd.copy_entity_result_id = (Select step.gs_parent_entity_result_id
                                     From   Ben_Copy_Entity_Results  step
                                     Where  step.Copy_Entity_Result_Id= p_step_result_id
                                     AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
                                   AND    step.Table_Alias = 'COP');

Cursor csr_grade_crpath_node
IS
select null
      from per_gen_hierarchy_nodes
      where hierarchy_version_id = l_crpth_hier_ver
      and information9 = l_corps_id
      and information23 = l_grade_id
      and information3 = p_step_id;

BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_step_result_id '||p_step_result_id,20);
hr_utility.set_location('p_use_points '||p_use_points,30);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,40);
hr_utility.set_location('p_effective_date '||p_effective_date,70);
end if;

hr_multi_message.enable_message_list;

-- Get Pgm_ID
       Open  csr_pgm_id;
       Fetch csr_pgm_id into l_pgm_id;
       Close csr_pgm_id;

-- Get Grade_ID
        Open csr_grade_id;
        Fetch csr_grade_id into l_grade_id;
        Close csr_grade_id;

if g_debug then
 hr_utility.set_location('Grade Ladder Id :'||l_pgm_id,100);
 hr_utility.set_location('Grade Id :'||l_grade_id,110);
 hr_utility.set_location('Step Id:'||p_step_id ,120);
end if;

 IF (l_pgm_id IS NOT NULL AND   -- Grade Ladder Id
     l_grade_id IS NOT NULL AND    -- Grade Id
     p_step_id IS NOT NULL )       -- Step Id
 THEN
if g_debug then
    hr_utility.set_location('Rec is in HR/BEN Tables ',150);
end if;
    p_rec_exists := 'MAIN';

       /* This call raise error if step is
         1) Special Ceiling Step
         2) Employee Placements on this step
        */

         PER_SPINAL_POINT_STEPS_PKG.del_chks_del(p_step_id => p_step_id,
                                                 p_sess    => p_effective_date);

       -- If the Step is Ceiling Step Then raise Error
if g_debug then
         hr_utility.set_location('Ceiling Step Y/N '||p_celing_step_flag ,180);
end if;

         If (p_celing_step_flag = 'Y') Then  -- Ceiling_Step_Flag Values Y/N
                   hr_utility.set_message(801, 'PER_7937_DEL_CEIL_STEP');
                   hr_utility.raise_error;
         END IF;

      l_business_area := pqh_corps_utility.get_cet_business_area(p_copy_entity_txn_id);
      if l_business_area = 'PQH_CORPS_TASK_LIST' then
        -- Get Corps_Id
        Open csr_corps_id;
        Fetch csr_corps_id into l_corps_id;
        Close csr_corps_id;

        if l_corps_id is not null then

        l_crpth_hier_ver := pqh_cpd_hr_to_stage.get_crpth_hier_ver;

        OPEN csr_grade_crpath_node;
         FETCH csr_grade_crpath_node into l_grade_crpath_node;
      if csr_grade_crpath_node%found then
         if g_debug then
               hr_utility.set_location(' Corps and Grade are part of a Career Path',90);
         end if;
         hr_utility.set_message(8302,'PQH_GSP_STEP_PART_OF_CRPATH');
         hr_utility.raise_error;
      end if;
         CLOSE csr_grade_crpath_node;
        end if;
      end if;


  ELSE
if g_debug then
       hr_utility.set_location('Data only in Staging Area',350);
end if;
       p_rec_exists := 'STAGE';

 End IF;


EXCEPTION
  WHEN others THEN
    p_rec_exists := 'STAGE';
    fnd_msg_pub.add;

END remove_step_from_grade;
--
---------------------------CHK_PROFILE_EXISTS-----------------------------
--

FUNCTION CHK_PROFILE_EXISTS
( p_copy_entity_result_id IN Ben_Copy_Entity_Results.Copy_Entity_Result_Id%Type,
  p_copy_entity_txn_id    IN Ben_Copy_Entity_Results.Copy_Entity_Txn_Id%Type
)
RETURN varchar2 IS

/* Author  : mvankada
   Purpose : This function returns whether GSP Entity have eligibility profiles are not
             If Yes, returns Y otherwise N
*/

Cursor csr_profile_count
IS
Select  '1'
From    Ben_Copy_Entity_Results
Where   Table_Alias = 'ELP'
And     Gs_Parent_Entity_Result_Id = p_Copy_Entity_Result_Id
And     Copy_Entity_Txn_Id  = p_copy_entity_txn_id
And     Result_type_Cd = 'DISPLAY'
And     Nvl(Information104,'PPP') <> 'UNLINK' ;

l_cer  Varchar2(10);
l_proc   varchar2(72) := g_package||'chk_profile_exists';
l_exists Varchar2(10);

BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id,20);
end if;

Open csr_profile_count;
Fetch csr_profile_count into l_cer;
if csr_profile_count%FOUND then
     l_exists := 'Y';
else
     l_exists := 'N';
end if;
Close csr_profile_count;
return l_exists;

if g_debug then
hr_utility.set_location('Leaving'||l_proc,60);
end if;

EXCEPTION
  WHEN others THEN
    return 'N';
END CHK_PROFILE_EXISTS;



--
---------------------------DISPLAY_ICON-----------------------------
--

FUNCTION DISPLAY_ICON
(p_page                    IN   Varchar2,
 p_Table_Alias             IN   Ben_Copy_Entity_Results.Table_Alias%Type,
 p_action                  IN   Varchar2,
 p_copy_entity_txn_id      IN   Ben_Copy_Entity_Results.Copy_Entity_Txn_Id%Type,
 p_copy_entity_result_id   IN   Ben_Copy_Entity_Results.Copy_Entity_Result_Id%Type
 ) RETURN varchar2
IS

/*
  Author  : mvankada
  Purpose : This Function is Used in all HGrid Pages to Disply Icons -
            Add, Update, Remove, Progression Order, Score Icons at Different Levels.

  Return Values :
  =================
   E  Enable
   D  Disable
   N  NoIcon

  p_page has values
  =================
  GRADE_HGRID    -- Grades Page
  STEP_HGRID     -- Steps Page
  PRG_RULE_HGRID -- Progression Rules/ Review And Submit Pages

  p_action has values
  ===================
  ADD
  UPDATE
  REMOVE
  PRGORDER
  SCORE
  GRDQUOTA
  CARRERPATH
*/

Cursor Csr_steps_exists
IS
Select Null
From   Ben_COpy_Entity_Results
Where  Gs_Parent_Entity_Result_Id = p_copy_entity_result_id
And    table_alias ='COP'
And    Copy_Entity_Txn_Id = p_copy_entity_txn_id
And    result_type_cd = 'DISPLAY'
And    Nvl(Information104,'PPP') <> 'UNLINK';


l_grade_attached Varchar2(40);
l_exists         Varchar2(40);
l_dummy          Char(1);
l_proc        	 varchar2(72) := g_package||'display_icon';
BEGIN
if g_debug then
hr_utility.set_location('Entering'||l_proc,10);
hr_utility.set_location('p_page'||p_page,20);
hr_utility.set_location('p_Table_Alias'||p_Table_Alias,30);
hr_utility.set_location('p_copy_entity_txn_id'||p_copy_entity_txn_id,40);
hr_utility.set_location('p_copy_entity_result_id'||p_copy_entity_result_id,50);
end if;

-- For Grade HGrid Page
If  p_page = 'GRADE_HGRID' Then
   If p_Table_Alias = 'PGM' Then

        If   p_action = 'ADD' Then
             return 'E';
        Elsif p_action = 'PRGORDER' then
              -- Check The Grade Ladder has Grades or not
              -- If No Grades are attached to Grade Ladder then
              -- Disable Progression Order Icon otherwise Enable it.
              l_grade_attached := pqh_gsp_utility.chk_grade_exist_in_gl( p_copy_entity_txn_id => p_copy_entity_txn_id );

              If l_grade_attached = 'N' Then
                     return 'D';
              Else
                     return 'E';
              End If;
          Else -- # other actions
              return 'N';
        End If; -- # end of other actions

    Elsif p_Table_Alias = 'CPP' Then
      -- mvankada
      -- Added cotion GRDQUOTA for FRPS Cors Functionality.
       If   (  p_action = 'UPDATE'  OR p_action = 'REMOVE' OR p_action = 'GRDQUOTA') Then
           return 'E';
       Else
           return 'N';
       End If;
    Else
         return 'N';
    End If; -- # Table Name

End If; -- #   Grade HGrid Page


-- For Step HGrid Page
If  p_page = 'STEP_HGRID'
Then
      If p_Table_Alias = 'CPP' Then

         If ( p_action = 'ADD') Then
                return 'E';
         Elsif (p_action = 'UPDATE') Then

	   -- If Steps Exists for the Grade then Enable Update Button
	   -- Else Disable It
	      Open Csr_steps_exists  ;
	      Fetch Csr_steps_exists into l_dummy;
	      If Csr_steps_exists%Found Then
	           return 'E';
	      Else
	           return 'D';
	      End If;
	     Close Csr_steps_exists;
	 Else
	     return 'N';
	 End If;

      Elsif p_Table_Alias  = 'COP' Then

           If p_action = 'REMOVE' Then
                 return 'E';
           Else
                 return 'N';
           End If;


      Else  -- # 'PGM'
         return 'N';
      End If;

End If; -- # Step HGrid Page.

If  p_page = 'PRG_RULE_HGRID'
Then
if g_debug then
    hr_utility.set_location('Prg Rule Hgrid page' ,40);
end if;

    If  p_Table_Alias  = 'PGM'
    Then
            If p_action = 'ADD' Then
                 return 'E';
            Elsif p_action = 'UPDATE' Then
                l_exists := pqh_gsp_utility.CHK_PROFILE_EXISTS(p_copy_entity_result_id => p_copy_entity_result_id,
                                                               p_copy_entity_txn_id    => p_copy_entity_txn_id);
                     if g_debug then
                              hr_utility.set_location('ELP recs Exists (Y/N) :'|| l_exists,41);
                     end if;
                if  l_exists = 'Y'  then
		      return 'E';
		else
		     return 'D';
                end if;
            Else
                return 'N';

            End If; -- Action
    Elsif  p_Table_Alias = 'ELP' Then
          if p_action = 'REMOVE' Then
              return 'E';
          elsif  p_action = 'SCORE' Then
              return 'D';
          else
              return 'N';
          end if;

    ElsIf  p_Table_Alias = 'CPP' then
               if p_action = 'ADD' Then
                   return 'E';
               elsif p_action = 'UPDATE' Then
          if g_debug then
                    hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id ,50);
          end if;
                    l_exists := pqh_gsp_utility.CHK_PROFILE_EXISTS(p_copy_entity_result_id => p_copy_entity_result_id,
                                                                   p_copy_entity_txn_id    => p_copy_entity_txn_id);
	 if g_debug then
                    hr_utility.set_location('l_exists :: '||l_exists,60);
         end if;

                    if  l_exists = 'Y'  then
                           return 'E';
                    else
                           return 'D';
                    end if;
               else
                    return 'N';
               end if;  -- Action
        ElsIf  p_Table_Alias = 'COP'   then
               if p_action = 'ADD' Then
                   return 'E';
               elsif p_action = 'UPDATE'Then

	            if g_debug then
                       hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id ,80);
                    end if;

                    l_exists := pqh_gsp_utility.CHK_PROFILE_EXISTS(p_copy_entity_result_id => p_copy_entity_result_id,
                                                                   p_copy_entity_txn_id    => p_copy_entity_txn_id);
	            if g_debug then
                       hr_utility.set_location('l_exists :: '||l_exists,90);
                    end if;

                    if  l_exists = 'Y'  then
                           return 'E';
                    else
                           return 'D';
                    end if;
               -- Added CARRERPATH for FR PS Corsp Functionality.
               elsif p_action = 'CARRERPATH' then
                    return 'E';
               else
                    return 'N';
               end if;  -- Action

      Else
        return 'N';
      End if;
if g_debug then
    hr_utility.set_location('Update is through' ,50);
end if;

End If; -- # Progression Rules HGgrid

if g_debug then
hr_utility.set_location('Leaving'||l_proc,300);
end if;
END DISPLAY_ICON;


--
---------------------------GET_STEP_NAME-----------------------------
--


FUNCTION GET_STEP_NAME( p_copy_entity_result_id  in  Number,
                        p_copy_entity_txn_id     in  Number)
RETURN Number IS

l_proc        		varchar2(72) := g_package||'GET_STEP_NAME';
l_step_or_point         Varchar2(40);
l_opt_cer_id            Number;
l_pay_scale_cer_id      Number;
l_grd_cer_id            Number;
l_step_no               Number;
l_starting_step         Number;

Cursor  Csr_Cer_Ids
IS
Select  oipl.Information262,  -- Point Cer Id
        oipl.Information259,  -- Pay Scale Cer Id
        oipl.Gs_Parent_Entity_Result_id -- Grade Cer_id
From    Ben_Copy_Entity_Results oipl
Where   oipl.Copy_Entity_Result_Id = p_copy_entity_result_id
And     oipl.Copy_Entity_Txn_Id  = p_copy_entity_Txn_id
AND    nvl(oipl.result_type_cd,'DISPLAY') = 'DISPLAY'
And     oipl.Table_Alias = 'COP';


Cursor Csr_Step_No (l_opt_cer_id IN Number,l_pay_scale_cer_id IN Number,l_grd_cer_id IN Number,l_cet_id in number)
IS
Select count(*)
From   Ben_Copy_Entity_Results opt1,
       Ben_Copy_Entity_Results opt2,
       Ben_Copy_Entity_Results oipl
Where  oipl.Information262 = opt2.copy_entity_result_id
And    opt1.Information253 >= opt2.Information253
And    opt1.copy_entity_result_id = l_opt_cer_id
And    oipl.Information259 = l_pay_scale_cer_id  -- Information259 is Pay Scale Cer Id
And    oipl.Gs_Parent_Entity_Result_Id = l_grd_cer_id
AND    nvl(oipl.result_type_cd,'DISPLAY') = 'DISPLAY'
And    Nvl(oipl.Information104,'PPP') <> 'UNLINK'
and    oipl.copy_entity_txn_id = l_cet_id
group by opt1.Information263,oipl.Gs_Parent_Entity_Result_Id,opt1.Information98;

Cursor csr_starting_step
IS
select information228
from ben_copy_entity_results
where copy_entity_result_id = l_grd_cer_id;

BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id,20);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,30);
end if;

Open Csr_Cer_Ids;
Fetch Csr_Cer_Ids into l_opt_cer_id,l_pay_scale_cer_id,l_grd_cer_id;
Close Csr_Cer_Ids;

if g_debug then
hr_utility.set_location('Option Entity Result Id  '||l_opt_cer_id,40);
hr_utility.set_location('Pay Scale Entity Result Id '||l_pay_scale_cer_id,50);
end if;

Open Csr_Step_No(l_opt_cer_id,l_pay_scale_cer_id,l_grd_cer_id,p_copy_entity_txn_id);
Fetch Csr_Step_No into l_step_no;
Close Csr_Step_No;

if l_step_no = 0 then
   l_step_no := null;
end if;

Open csr_starting_step;
Fetch csr_starting_step into l_starting_step;
Close csr_starting_step;

return l_step_no+nvl(l_starting_step,1)-1;


Exception
   When others then
     l_step_no := null;
     return l_step_no;
End;



--

---------------------------GET_STEP_PRG_RULE_HGRID_NAME-----------------------------
--

FUNCTION GET_STEP_PRG_RULE_HGRID_NAME( p_copy_entity_result_id  in  Number,
                                       p_copy_entity_txn_id     in  Number,
                                       p_Table_Alias in ben_copy_entity_results.Table_Alias%Type,
                                       p_hgrid                   in Varchar Default NULL)
RETURN varchar2 IS
/*
  Author  : mvankada
  Purpose : This function is used in Step, Progrogression Rules, Review and Submit HGrid Page to display
            Name of Gsp Entity.

p_hgrid Values    Meaning
===========================
RATES_HGRID      Rates HGrid

*/

-- Grade Ladder : PGM    information5 -- Name

Cursor csr_grdldr_name  IS
Select grdldr.information5
From   Ben_Copy_Entity_Results grdldr
Where  grdldr.Copy_Entity_Result_Id = p_copy_entity_result_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    grdldr.Table_Alias= p_Table_Alias;

-- Grade : CPP    information5 -- Grade Name,    information98 -- PayScale Name
Cursor csr_grd_name IS
Select grd.information5,information98
From   Ben_Copy_Entity_Results grd
Where  grd.Copy_Entity_Result_Id = p_copy_entity_result_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    grd.Table_Alias = p_Table_Alias;

-- Step : COP    information5 -- Step Name,    information99 -- Point Name
Cursor csr_step_name IS
Select step.information5 , information99
From   Ben_Copy_Entity_Results step
Where  step.Copy_Entity_Result_Id = p_copy_entity_result_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    step.Table_Alias = p_Table_Alias;

-- Eligibility Profile : ELP   information5 -- Profile Name
Cursor csr_elig_name IS
Select elig.information5
From   Ben_Copy_Entity_Results elig
Where  elig.Copy_Entity_Result_Id = p_copy_entity_result_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    elig.Table_Alias = p_Table_Alias;

Cursor csr_corps_gross_index IS
Select to_number(opt.information173)
From   Ben_Copy_Entity_Results Opt
Where  opt.Table_Alias           = 'OPT'
AND    opt.Copy_Entity_Txn_id    = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    opt.Copy_Entity_Result_Id = ( Select oipl.Information262 -- Point Cer Id
                                     From   Ben_Copy_Entity_Results oipl
                                     Where  Copy_Entity_Result_Id = p_copy_entity_result_id
                                     AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
                                     And    Copy_Entity_Txn_id    = p_copy_entity_txn_id
                                     And    Table_Alias = 'COP');

Cursor csr_table_name IS
Select Substr(Display_name,1,50)
From Pqh_table_Route
Where Table_Alias = p_Table_Alias;

l_proc        		varchar2(72) := g_package||'GET_STEP_PRG_RULE_HGRID_NAME';
l_step_or_point         Varchar2(40);
l_name                  Varchar2(4000);
l_name1                 Varchar2(4000);
l_step_name             Varchar2(4000);


l_gross_index           Number;
l_increased_index       Number;
l_bus_area              Varchar2(240);
l_corps_step_name       Varchar2(4000);
l_table_name            Varchar2(4000);



BEGIN
if g_debug then
hr_utility.set_location('Entering '||l_proc,10);
hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id,20);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,30);
hr_utility.set_location('p_Table_Alias '||p_Table_Alias,40);
end if;

l_step_or_point := pqh_gsp_utility.USE_POINT_OR_STEP(p_copy_entity_txn_id => p_copy_entity_txn_id);
if g_debug then
hr_utility.set_location('Point/Step : '||l_step_or_point,40);
end if;

if (p_Table_Alias = 'PGM') then
     Open csr_grdldr_name;
     Fetch csr_grdldr_name into  l_name;
     Close csr_grdldr_name;
if g_debug then
     hr_utility.set_location('Grade Ladder Name '||l_name,60);
end if;
     return l_name;
elsif  (p_Table_Alias = 'CPP') then
      Open csr_grd_name;
      Fetch csr_grd_name into  l_name,l_name1;
      Close csr_grd_name;
if g_debug then
       hr_utility.set_location('Grade Name '||substr(l_name,1,50),80);
       hr_utility.set_location('Pay Scale Name '||substr(l_name1,1,50),90);
end if;
    if ( (l_step_or_point ='POINT') AND (l_name1 IS NOT NULL )) then
       return l_name || ' (' ||l_name1|| ')';
    else
       return l_name;
    end if;

elsif  (p_Table_Alias = 'COP') then
      Open csr_step_name;
      Fetch csr_step_name into  l_name,l_name1;
      Close csr_step_name;
      if g_debug then
           hr_utility.set_location('Step Name '||l_name,100);
           hr_utility.set_location('Point Name '||l_name1,120);
      end if;
      l_step_name := GET_STEP_NAME( p_copy_entity_result_id => p_copy_entity_result_id,
                                       p_copy_entity_txn_id => p_copy_entity_txn_id);

       if g_debug then
         hr_utility.set_location('Generated Step Name  : '||l_step_name,125);
      end if;


      l_bus_area := pqh_corps_utility.get_cet_business_area( p_copy_entity_txn_id => p_copy_entity_txn_id);
      if g_debug then
         hr_utility.set_location('Business Area : '||l_bus_area,130);
      end if;
      -- For Corps Rates HGrid Page need to Display Step Name like Step (Point Name | Gross Index | Increased Gross Index)
      If (nvl(l_bus_area,'PQH_GSP_TASK_LIST') = 'PQH_CORPS_TASK_LIST' And p_hgrid = 'RATES_HGRID' ) Then

          Open csr_corps_gross_index;
          Fetch csr_corps_gross_index into  l_gross_index;
          Close csr_corps_gross_index;

          if g_debug then
               hr_utility.set_location('Gross Index  '||l_gross_index,140);
          end if;
          If l_gross_index IS NOT NULL Then
               l_increased_index := pqh_corps_utility.get_increased_index(p_gross_index        => l_gross_index,
                                                                          p_copy_entity_txn_id => p_copy_entity_txn_id);
          End If;

          if g_debug then
               hr_utility.set_location('Increased  Index  '||l_increased_index,150);
          end if;

          if ( (l_step_or_point ='POINT') AND (l_name1 IS NOT NULL)) then
                   l_corps_step_name := l_step_name || ' (' ||l_name1;

                  if l_gross_index IS NOT NULL Then
                      l_corps_step_name := l_corps_step_name || '  | IB '  || l_gross_index;
                  end if;

                  if l_increased_index IS NOT NULL Then
                      l_corps_step_name := l_corps_step_name || ' | INM '  || l_increased_index;
                  end if;
                   l_corps_step_name :=l_corps_step_name || ' ) ';
                  return l_corps_step_name;
          end if;

     Else

       -- For GSP

    if ( (l_step_or_point ='POINT') AND (l_name1 IS NOT NULL)) then
         return l_step_name || ' (' ||l_name1|| ')';
    else
         return l_name1;
    end if;
   End if;


elsif (p_Table_Alias = 'ELP') then
     Open csr_elig_name;
     Fetch csr_elig_name into  l_name;
     Close csr_elig_name;
if g_debug then
     hr_utility.set_location('Eligibility Profile Name '||l_name,60);
end if;
     return l_name;
else
    open csr_table_name;
    fetch csr_table_name into l_table_name;
    close csr_table_name;
    if l_table_name IS NOT NULL then
       return l_table_name;
    else
      return null;
    end if;
end if; -- table_name
if g_debug then
hr_utility.set_location('Leaving '||l_proc,100);
end if;
END GET_STEP_PRG_RULE_HGRID_NAME;

--
---------------------------CHK_GRD_DETAILS-----------------------------
--

PROCEDURE CHK_GRD_DETAILS
(
 p_name                  IN per_grades.name%TYPE,
 p_short_name            IN per_grades.short_name%TYPE,
 p_business_group_id     IN per_grades.business_group_id%TYPE,
 p_grade_id              IN per_grades.grade_id%TYPE default NULL,
 p_copy_entity_result_id IN ben_copy_entity_results.copy_entity_result_id%TYPE default NULL,
 p_copy_entity_txn_id    IN ben_copy_entity_results.copy_entity_txn_id%TYPE,
 p_status                OUT NOCOPY VARCHAR
)
IS

CURSOR csr_grade_name
IS
Select null
From   Per_Grades
Where  name = p_name
And    business_group_id = p_business_group_id
And    grade_id <>  nvl(p_grade_id,-1)
Union ALL
Select null
From  ben_copy_entity_results
Where
information5 = p_name
And   information4   = p_business_group_id
And   table_alias    = 'PLN'
And   result_type_cd = 'DISPLAY'
And   copy_entity_result_id <>  nvl(p_copy_entity_result_id,-1)
And   copy_entity_txn_id = p_copy_entity_txn_id;

CURSOR csr_grade_short_name
IS
Select null
From  per_grades
Where short_name      = p_short_name
And business_group_id = p_business_group_id
And grade_id <>  nvl(p_grade_id,-1)
Union ALL
Select null
From ben_copy_entity_results
Where information102 = p_short_name
And  information4    = p_business_group_id
And  table_alias='PLN'
And  result_type_cd = 'DISPLAY'
And  copy_entity_result_id <>  nvl(p_copy_entity_result_id,-1)
And  copy_entity_txn_id=p_copy_entity_txn_id;

l_grade_name per_grades.name%TYPE;
l_short_name per_grades.short_name%TYPE;
l_proc        		varchar2(72) := g_package||'CHK_GRD_DETAILS';

BEGIN
if g_debug then
 hr_utility.set_location('Entering '||l_proc,10);
 hr_utility.set_location('p_name '||p_name,20);
 hr_utility.set_location('p_short_name '||p_short_name,30);
 hr_utility.set_location('p_business_group_id '||p_business_group_id,40);
 hr_utility.set_location('p_grade_id '||p_grade_id,50);
 hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id,60);
 hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,70);
end if;

 hr_multi_message.enable_message_list;
 Open csr_grade_name;
 Fetch csr_grade_name into l_grade_name;
 If(csr_grade_name%FOUND) THEN
         p_status := 'E';
         hr_utility.set_message(8302,'PER_7830_DEF_GRADE_EXISTS');
         hr_utility.raise_error;
 Else
        p_status := 'Y';
 End if;

 Open csr_grade_short_name;
 Fetch csr_grade_short_name into l_short_name;
 If(csr_grade_short_name%FOUND) THEN
          p_status := 'E';
          hr_utility.set_message(800,'HR_289555_NON_UNIQ_SHORT_NAME');
          hr_utility.raise_error;
 Else
           p_status := 'Y';
 End if;
if g_debug then
hr_utility.set_location('Leaving '||l_proc,100);
end if;
Exception
  when others then
      p_status := 'E';
      fnd_msg_pub.add;
END CHK_GRD_DETAILS;


--
---------------------------get_standard_rate-----------------------------
--

Function get_standard_rate(p_copy_entity_result_id   in number,
                           p_effective_date          in date)
RETURN number is
--
Cursor csr_std_rate is
Select information98
From ben_copy_entity_results std
Where std.gs_parent_entity_result_id = p_copy_entity_result_id
And  std.table_alias = 'ABR'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND  p_effective_date between information2 and nvl(information3,to_date('31/12/4712','dd/mm/RRRR'));
--
l_std_rate     number(38,15) := 0;
--
Begin
  --
  Open csr_std_rate;
  Fetch csr_std_rate into l_std_rate;
  Close csr_std_rate;
  --
  Return l_std_rate;
--
End get_standard_rate;

--
---------------------------delete_transaction-----------------------------
--
procedure delete_transaction
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE) IS


begin
del_gl_details_from_stage(p_pqh_copy_entity_txn_id);
delete from pqh_copy_entity_txns where copy_entity_txn_id = p_pqh_copy_entity_txn_id;
end delete_transaction;

--
---------------------------del_gl_details_from_stage-----------------------------
--
procedure del_gl_details_from_stage
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE) IS

begin
delete from pqh_copy_entity_attribs where copy_entity_txn_id = p_pqh_copy_entity_txn_id;
delete from ben_copy_entity_results where copy_entity_txn_id = p_pqh_copy_entity_txn_id;
end del_gl_details_from_stage;

--
---------------------------enddate_grade_ladder-----------------------------
--
procedure enddate_grade_ladder
(p_ben_pgm_id IN ben_pgm_f.pgm_id%TYPE,
 p_effective_date_in IN ben_pgm_f.effective_start_date%TYPE) IS

Cursor pgm is
select pgm_id, object_version_number from ben_pgm_f where pgm_id = p_ben_pgm_id and effective_end_date = hr_general.end_of_time;

Cursor c2 is
select copy_entity_txn_id from pqh_copy_entity_txns where copy_entity_txn_id in
(select copy_entity_txn_id from ben_copy_entity_results
where information1 = p_ben_pgm_id and table_alias = 'PGM' and information_category = 'GRADE_LADDER'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY')
and status = 'SFL';

l_effective_start_date date;
l_effective_end_date date;

l_proc        		varchar2(72) := g_package||'enddate_grade_ladder';

begin
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
  hr_utility.set_location('p_ben_pgm_id is '||p_ben_pgm_id, 10);
  hr_utility.set_location('p_effective_date_in is '||p_effective_date_in, 15);
end if;

for each_rec in pgm loop
ben_program_api.delete_Program
  (p_pgm_id                         => p_ben_pgm_id
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  ,p_object_version_number          => each_rec.object_version_number
  ,p_effective_date                 => p_effective_date_in
  ,p_datetrack_mode                 => 'DELETE'
  );
end loop;

for sfl_txn in c2 loop
delete_transaction(sfl_txn.copy_entity_txn_id);
end loop;
if g_debug then
hr_utility.set_location('Successfull completion for '||l_proc,5);
end if;
exception when others then
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in'||l_proc,5);
end if;
raise;
end enddate_grade_ladder;

--
---------------------------Get_Step_Dtls-----------------------------
--
/* This function is used to return the Current Step Id and Step Name */
/* pass P_Id_name as I if Step Id is required. Pass 'N' if Stap_name is required */

Function Get_Step_Dtls
(P_Entity_id       In Number,
 P_Effective_Date  In Date,
 P_Id_name         In Varchar2,
 P_Curr_Prop	   In Varchar2)

RETURN Number Is

 Cursor Step is
 Select Steps.Step_Id, Steps.Spinal_point_id, Steps.Grade_spine_id
   From Per_Spinal_Point_Placements_F Plcmt,
        Per_Spinal_Point_Steps_F Steps
  Where Plcmt.ASSIGNMENT_ID = P_Entity_id
    and P_Effective_Date
Between Plcmt.Effective_Start_Date and Plcmt.Effective_End_Date
    and Plcmt.Step_id       = Steps.Step_Id
    and P_Effective_Date
Between Steps.Effective_Start_Date and Steps.Effective_End_Date;

 Cursor PropStep Is
 Select Step.Step_id, Step.Spinal_point_id, Step.Grade_spine_id
   From Ben_Oipl_F Oipl,
        Ben_pl_F Pl,
        Ben_Opt_F Opt,
        Per_Spinal_points point,
        Per_Grade_Spines_f GSpine,
        Per_Spinal_point_Steps_F Step
  Where Oipl.Oipl_id  = P_Entity_Id
    and P_Effective_Date
Between OiPl.Effective_Start_Date and OiPl.Effective_End_Date
    and Pl.Pl_id = Oipl.Pl_Id
    and P_Effective_Date
Between Pl.Effective_Start_Date and Pl.Effective_End_Date
    and Oipl.Opt_id = Opt.Opt_id
    and P_Effective_Date
Between Opt.Effective_Start_Date and Opt.Effective_End_Date
    and Point.Spinal_Point_id  = Opt.Mapping_Table_Pk_Id
    and Pl.Mapping_Table_Pk_Id = Gspine.Grade_Id
    and P_Effective_Date
Between Gspine.Effective_Start_Date and Gspine.Effective_End_Date
    and Step.Grade_Spine_Id    = Gspine.Grade_Spine_Id
    and P_Effective_Date
Between Step.Effective_Start_Date and Step.Effective_End_Date
    and Step.SPINAL_POINT_ID   = Point.SPINAL_POINT_ID;

l_Point_id        Per_Spinal_POint_Steps_f.Spinal_Point_Id%TYPE;
l_Parent_Spine_id Per_Spinal_Point_Placements_F.Parent_Spine_Id%TYPE;
l_Step_Id         Per_Spinal_POint_Steps_F.Step_Id%TYPE := NULL;
l_Step_name       Number(10)  := NULL;
begin

If P_Curr_Prop = 'CURR' then
   Open Step;
   Fetch Step into l_Step_Id , L_Point_Id, l_Parent_Spine_id;
   Close step;
ElsIf P_Curr_Prop = 'PROP' and P_Entity_Id is NOT NULL then
   Open PropStep;
   Fetch PropStep into l_Step_Id , L_Point_Id, l_Parent_Spine_id;
   Close PropStep;
End If;

If P_Id_Name = 'I' Then
   Return l_Step_Id;
Else
If l_point_id is Not NULL and l_Parent_Spine_Id is not NULL Then
   per_spinal_point_steps_pkg.pop_flds(l_Step_name,
                                       P_Effective_Date,
                                       l_point_id,
                                       l_Parent_Spine_Id);

End If;
   Return l_Step_Name;
End If;

End Get_Step_Dtls;

--
--
---------------------------Get_Cur_Sal-----------------------------
--

Function Get_Cur_Sal
(P_Assignment_id   In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date)

Return Number Is

 L_Cur_Sal                Per_pay_Proposals.PROPOSED_SALARY_N%TYPE;
 l_input_value_id         pay_input_values_f.Input_Value_id%TYPE;
 L_FREQUENCY              per_time_period_types.period_type%TYPE;
 L_ANNUAL_SALARY          Per_pay_Proposals.PROPOSED_SALARY_N%TYPE;
 L_PAY_BASIS              Varchar2(5);
 L_REASON_CD              Per_pay_Proposals.proposal_reason%TYPE;
 l_pay_basis_frequency    Per_pay_bases.pay_basis%TYPE;
 L_CURRENCY               Ben_Pgm_F.Pgm_Uom%TYPE;
 L_STATUS                 Number(10);

  Cursor Sal is
  Select pev.screen_entry_value
    From pay_element_entries_f pee,
         pay_input_values_f piv,
         pay_element_entry_values_f pev
   Where pee.Assignment_id = P_Assignment_id
     and P_Effective_Date
 between pee.Effective_Start_Date and pee.Effective_End_Date
     and Piv.Input_Value_id   = l_Input_Value_id
     and P_Effective_Date
 Between Piv.Effective_Start_Date and Piv.Effective_End_Date
     and pev.ELEMENT_ENTRY_ID = Pee.ELEMENT_ENTRY_ID
     and Piv.INPUT_VALUE_ID = Pev.INPUT_VALUE_ID
     and P_Effective_Date
 Between Pev.Effective_Start_Date and Pev.Effective_End_Date;

  Cursor Pay_Bases_Element is
  Select input_value_id
    From Per_Pay_Bases         ppb,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.pay_basis_id  = ppb.pay_basis_id;

  Cursor GrdLdr_Element is
  Select DFLT_INPUT_VALUE_ID
    from Ben_Pgm_f             pgm,
         Per_All_Assignments_f paf
   Where paf.Assignment_Id = p_Assignment_Id
     and p_Effective_Date
 Between Paf.Effective_Start_Date and Paf.Effective_End_Date
     and paf.GRADE_LADDER_PGM_ID = pgm.pgm_id
     and p_Effective_Date
 Between pgm.Effective_Start_date and pgm.Effective_End_Date;

Begin

/* Commenting the following Cursor Calls as the Procedure below will return the required amount */

/*  Open  Pay_Bases_Element;
  Fetch Pay_Bases_Element into l_input_Value_id;
  Close Pay_Bases_Element;

  If l_input_Value_id is NULL Then
     Open  GrdLdr_Element;
     Fetch GrdLdr_Element into l_input_Value_id;
     Close GrdLdr_Element;
  End If;

  if l_Input_Value_id is Not NULL Then
     Open Sal;
     Fetch Sal into L_Cur_Sal;
    Close Sal;
  Else
    l_Cur_Sal := 0;
  End If;

  Return L_Cur_Sal; */

   /* the following Procedure will return The Annual Salary */
  pqh_employee_salary.GET_EMPLOYEE_SALARY
  (P_ASSIGNMENT_ID        =>  p_Assignment_Id
  ,P_EFFECTIVE_DATE       =>  p_Effective_Date
  ,P_SALARY               =>  L_Cur_Sal
  ,P_FREQUENCY            =>  L_FREQUENCY
  ,P_ANNUAL_SALARY        =>  L_ANNUAL_SALARY
  ,P_PAY_BASIS            =>  L_PAY_BASIS
  ,P_REASON_CD            =>  L_REASON_CD
  ,P_CURRENCY             =>  L_CURRENCY
  ,P_STATUS               =>  L_STATUS
  ,p_pay_basis_frequency  => l_pay_basis_frequency);


   Return L_ANNUAL_SALARY;

End Get_Cur_Sal;

--
---------------------------Get_CAGR_Name-----------------------------
--

Function Get_CAGR_Name
(P_CAGR_Id IN Per_Collective_Agreements.Collective_Agreement_ID%TYPE)

Return Varchar2 Is
L_Cagr_name Per_Collective_Agreements.Name%TYPE;

Cursor CAGR is
Select Name
  from Per_Collective_Agreements
 Where Collective_Agreement_Id = P_CAGR_Id;

Begin

Open CAGR;
Fetch CAGR into l_Cagr_name;
Close Cagr;

Return l_Cagr_Name;

End Get_CAGR_Name;
--
---------------------------gen_txn_display_name-----------------------------
--

Function gen_txn_display_name
(p_program_name IN pqh_copy_entity_txns.display_name%TYPE,
p_mode IN varchar2)
Return Varchar2 is
l_timestamp varchar2(30) := fnd_date.date_to_canonical(sysdate);
l_display_name varchar2(300);
l_mode varchar2(10) := p_mode;
l_proc varchar2(72) := 'gen_txn_display_name';
begin
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
  hr_utility.set_location('p_program_name is '||p_program_name, 10);
  hr_utility.set_location('p_mode is '||p_mode, 15);
end if;

--
--If Mode is null then consider it to be a create transaction
--
if p_mode is null then
l_mode := 'C';
end if;

--
-- No need for extra space at the end of generated name if p_display_name is null.
--
if p_program_name is not null then
l_display_name := l_mode||':'||l_timestamp||':'||substr(p_program_name, 1, 78);
else
l_display_name := l_mode||':'||l_timestamp;
end if;

if g_debug then
hr_utility.set_location('Leaving '||l_proc,5);
end if;
return l_display_name;

EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
end;

--
---------------------------get_grade_ladder_name_from_txn-----------------------------
--
Function get_grade_ladder_name_from_txn
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE)
Return Varchar2 is
cursor c1 is
select information5 grade_ladder_name from ben_copy_entity_results
where copy_entity_txn_id = p_pqh_copy_entity_txn_id
and table_alias = 'PGM'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information_category = 'GRADE_LADDER';
l_grade_ladder_name varchar2(240);

l_proc varchar2(72) := 'get_grade_ladder_name_from_txn';
begin
if g_debug then
	hr_utility.set_location('Entering '||l_proc, 5);
end if;

for gr_ldr in c1 loop
l_grade_ladder_name := gr_ldr.grade_ladder_name;
end loop;
return l_grade_ladder_name;

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 5);
end if;

EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
end;

--
---------------------------chk_default_ladder_exist-----------------------------
--

Procedure chk_default_ladder_exist
          ( p_pgm_id               in   number,
            p_business_group_id    in   number,
            p_effective_date       in   Date) IS
/* Author  : mvanakda
   Purpose : This procedure checks whether a Default Grade Ladder Exist
             for a business group or not.
*/

l_proc	    varchar2(72) := g_package|| 'chk_default_ladder_exist';
l_name      Ben_Pgm_F.Name%Type;
l_dummy     Char(1);

Cursor   csr_curr_grdldr IS
Select   Name
From     ben_pgm_f
Where    pgm_id = p_pgm_id
And      business_group_id = p_business_group_id
And      effective_end_date>= p_effective_date
And      pgm_typ_cd = 'GSP'
And      Dflt_Pgm_Flag = 'Y';



Cursor csr_default_chk IS
Select   Null
From     ben_pgm_f
Where    pgm_id <> nvl(p_pgm_id,-1)
And      business_group_id = p_business_group_id
And      p_effective_date Between Effective_Start_Date
And      nvl(Effective_End_Date, hr_general.end_of_time)
And      pgm_typ_cd = 'GSP'
And      Dflt_Pgm_Flag = 'Y';
--
Begin
if g_debug then
  hr_utility.set_location('ENTERING:'||l_proc, 5);
  hr_utility.set_location('p_pgm_id:'||p_pgm_id, 15);
  hr_utility.set_location('p_business_group_id:'||p_business_group_id, 20);
end if;
  --
  --
  If p_pgm_id IS NOT NULL Then
if g_debug then
       hr_utility.set_location(' Pgm Id Is not Null', 21);
end if;
       Open  csr_curr_grdldr;
       Fetch csr_curr_grdldr into l_name;
       If csr_curr_grdldr%Found Then
if g_debug then
           hr_utility.set_location('Current Grade Ladder is Default Grade Ladder' , 22);
end if;
           Open csr_default_chk;
           Fetch csr_default_chk into l_dummy;
           If csr_default_chk%found then
                   close csr_default_chk;
                   hr_utility.set_message(8302,'PQH_GSP_GRDLDR_DFLT_ERR');
                   hr_utility.set_message_token('LADDER',l_name);
                   hr_multi_message.add;
          Else
            close csr_default_chk;
         End if;
       End If;
       Close csr_curr_grdldr;
  End If;
  --
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 35);
end if;

End chk_default_ladder_exist;

--
---------------------------chk_add_steps_in_all_grades-----------------------------
--

Procedure chk_add_steps_in_all_grades
 ( p_copy_entity_txn_id   in   number,
   p_business_group_id    in   number) IS

/* Author  : mvanakda
   Purpose : This procedure checks if steps have been added to only some steps
             in a grade and warns the user that the setup cannot be saved unless steps
             are added to all the Grades.
*/

l_proc	    varchar2(72) := g_package|| 'chk_add_steps_in_all_grades';
l_copy_entity_result_id    Ben_Copy_Entity_Results.Copy_Entity_Result_Id%Type;
l_grade_name               Ben_Copy_Entity_Results.Information5%type;
l_dummy                    Varchar2(10);
l_no_step_grades           Varchar2(2000) := null;
l_no_ceil_grades           Varchar2(2000) := null;
l_found1                   Boolean := FALSE;
l_found2                   Boolean := FALSE;
l_steps_exists             varchar2(10);


Cursor csr_steps_exists
IS
Select  Null
FROM    BEN_COPY_ENTITY_RESULTS step
WHERE   step.copy_entity_txn_id = p_copy_entity_txn_id
AND     step.TABLE_ALIAS ='COP'
And     nvl(step.INFORMATION104,'PPP') <> 'UNLINK'
AND     step.result_type_cd = 'DISPLAY';


Cursor csr_grades  IS
Select  grd.Copy_Entity_Result_Id,  grd.Information5
From    Ben_Copy_Entity_Results grd
Where   grd.Copy_Entity_txn_Id   = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And     nvl(grd.Information104,'PPP') <> 'UNLINK'
And     grd.Table_Alias  	=  'CPP'
And     grd.Information4        =  p_business_group_id;


Cursor csr_steps(p_copy_entity_result_id in number) IS
Select Null
From   Ben_Copy_Entity_Results step
Where  step.Copy_Entity_txn_Id      = p_copy_entity_txn_id
And    step.Gs_Parent_Entity_Result_Id   = p_copy_entity_result_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    step.Table_Alias  	=  'COP'
And    nvl(step.Information104,'PPP')  <>  'UNLINK'
And    step.Information4        =  p_business_group_id;


Cursor csr_celing_step(p_copy_entity_result_id in number) IS
Select  Null
From    Ben_Copy_Entity_Results ceiling
Where   ceiling.Copy_Entity_txn_Id   = p_copy_entity_txn_id
And     ceiling.Gs_Parent_Entity_Result_Id   = p_copy_entity_result_id
And     ceiling.Table_Alias  	=  'COP'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And     nvl(ceiling.Information104,'PPP') <> 'UNLINK'
/*Information98 is used to store Ceiling Step Flag */
And     ceiling.Information98  = 'Y'
And     ceiling.Information4        =  p_business_group_id;


--
Begin
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 15);
  hr_utility.set_location('p_business_group_id:'||p_business_group_id, 20);
end if;
  --
  -- Check Steps Exists for a Transaction or not
  Open csr_steps_exists;
  Fetch csr_steps_exists into l_steps_exists;
  If csr_steps_exists%Found Then
        For l_rec in csr_grades
        Loop
            Open csr_steps(l_rec.copy_entity_result_id);
            Fetch csr_steps into l_dummy;
            If csr_steps%notfound then
                 l_no_step_grades := l_no_step_grades || l_rec.Information5 ||' , ';
                 l_found1 := TRUE;
            End If;
            Close csr_steps;


            Open csr_celing_step(l_rec.copy_entity_result_id);
            Fetch csr_celing_step into l_dummy;
            If csr_celing_step%notfound then
                  l_no_ceil_grades := l_no_ceil_grades || l_rec.Information5 ||' , ';
                  l_found2 := TRUE;
            End If;
            Close csr_celing_step;

         End Loop;
  End if;
  Close csr_steps_exists;

  l_no_step_grades := substr(l_no_step_grades,1,length(l_no_step_grades)-2);
  l_no_ceil_grades := substr(l_no_ceil_grades,1,length(l_no_ceil_grades)-2);
if g_debug then
  hr_utility.set_location('Grades not having Steps 1:'||substr(l_no_step_grades,1,50),50);
  hr_utility.set_location('Grades not having Steps 2:'||substr(l_no_step_grades,51,100),51);
  hr_utility.set_location('Grades not having Steps 3:'||substr(l_no_step_grades,101,150),52);
  hr_utility.set_location('Grades not having Ceiling Steps 1: '||substr(l_no_ceil_grades,1,50),55);
  hr_utility.set_location('Grades not having Ceiling Steps 2: '||substr(l_no_ceil_grades,51,100),55);
  hr_utility.set_location('Grades not having Ceiling Steps 3: '||substr(l_no_ceil_grades,101,150),55);
end if;

  If l_found1 then
         if g_debug then
              hr_utility.set_location('Grades not having Steps found',51);
         end  if;
         hr_utility.set_message(8302,'PQH_GSP_ADD_STEPS_IN_ALL_GRDS');
         hr_utility.set_message_token('GRADES',l_no_step_grades);

         hr_multi_message.add;


  End If;
  If l_found2 then
        if g_debug then
           hr_utility.set_location('Grades not having Celing Steps found',52);
         end if;
         hr_utility.set_message(8302,'PQH_GSP_ADD_CEIL_IN_ALL_GRDS');
         hr_utility.set_message_token('GRADES',l_no_ceil_grades);
         hr_multi_message.add;
   End If;
if g_debug then
hr_utility.set_location('Leaving:'||l_proc,100);
end if;

End chk_add_steps_in_all_grades;
--
---------------------------chk_valid_grd_in_grdldr-----------------------------
--
Procedure chk_valid_grd_in_grdldr
( p_copy_entity_txn_id     in   number,
  p_effective_date         in   date,
  p_business_group_id      in   Number) IS

/* Author  : mvanakda
   Purpose : This procedure used to check if grades are valid as of the
   grade ladder effective date
*/

l_proc	    varchar2(72) := g_package|| 'chk_valid_grd_in_grdldr';
l_dummy     Ben_Copy_Entity_Results.Information5%Type;
l_grades    Varchar2(2000);
l_found     Boolean := FALSE;

-- This cursor checks the newly created grades
/* Information5   : Grade Name
   Information306 : Grade Start Date
   Information307 : Grade End Date
 */
 -- Bug  : 3161418

Cursor csr_grades IS
Select grd.Information5 ,
       grd.Information306,
       grd.Information307
From   Ben_Copy_Entity_Results grd
Where  grd.Copy_Entity_txn_Id   = p_copy_entity_txn_id
AND    grd.Table_Alias = 'CPP'
AND    nvl(grd.Information104,'PPP') <> 'UNLINK'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND    p_effective_date Not BETWEEN grd.Information306
AND    nvl(grd.Information307,hr_general.end_of_time)
AND    Information4 = p_business_group_id;
BEGIN
if g_debug then
hr_utility.set_location('Entering:'||l_proc,10);
hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id,20);
hr_utility.set_location('p_effective_date:'||p_effective_date,30);
end if;

  For l_rec in csr_grades
  Loop
      l_grades := l_grades || l_rec.Information5 ||' , ';
      l_found := TRUE;
  End loop;
  l_grades := substr(l_grades,1,length(l_grades)-2);

if g_debug then
  hr_utility.set_location('Invalid Grades are ... :'||substr(l_grades,1,50),50);
  hr_utility.set_location('Invalid Grades are ... :'||substr(l_grades,51,100),51);
  hr_utility.set_location('Invalid Grades are ... :'||substr(l_grades,101,150),52);
end if;


  If l_found then
        hr_utility.set_message(8302,'PQH_GSP_INVALID_GRD_IN_GRDLDR');
        hr_utility.set_message_token('GRADES',l_grades);
        hr_multi_message.add;
  End If;

if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 15);
end if;
End chk_valid_grd_in_grdldr;

--
---------------------------chk_inactivate_grdldr-----------------------------
--

Procedure chk_inactivate_grdldr
 (p_pgm_id             in Number,
  p_effective_date     in Date,
  p_business_group_id  in Number,
  p_activate           in Varchar) IS


/* Author  : mvanakda
   Purpose : This procedure used to check if a grade ladder can be
             inactivated or not
*/

l_proc	       Varchar2(72) := g_package|| 'chk_inactivate_grdldr';
l_old_status   BEN_PGM_F.PGM_STAT_CD%Type;
l_dummy        Char(1);


Cursor csr_active_gl IS
Select null
From   Per_All_Assignments_F
Where  Grade_Ladder_Pgm_Id  = p_pgm_id
And    p_effective_date between effective_start_date
And    nvl(effective_end_date, hr_general.end_of_time)
And    Business_Group_Id = p_business_group_id;

Cursor csr_pgm_status
IS
Select pgm.PGM_STAT_CD -- Activate A , Inactivate I
From   BEN_PGM_F pgm
Where  pgm.Pgm_Id = p_pgm_id
And    pgm.Business_Group_Id = p_business_group_id
And    p_effective_date between pgm.effective_start_date
And    nvl(pgm.effective_end_date, hr_general.end_of_time);



Begin
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('p_pgm_id:'||p_pgm_id, 15);
  hr_utility.set_location('p_effective_date:'||p_effective_date, 20);
  hr_utility.set_location('p_activate:'||p_activate, 35);
end if;
  hr_multi_message.enable_message_list;

If p_pgm_id IS NOT NULL  Then
       if g_debug then
         hr_utility.set_location('PGM Id Not Null ', 40);
       end if;

         -- Get Status of PGM
         Open csr_pgm_status;
         Fetch csr_pgm_status into l_old_status;
         Close csr_pgm_status;
         if g_debug then
	          hr_utility.set_location('PGM Status :'||l_old_status, 41);
         end if;

         -- Raise the error in the following case.
         -- 1) If PGM is Active And
         -- 2) Emp Assignments exists on this PGM And
         -- 3) On Review And Submit Page changed status from Active to Inactive

         if (l_old_status = 'A' And p_activate = 'I') then

         Open csr_active_gl;
         Fetch csr_active_gl into l_dummy;
         If csr_active_gl%Found then
              Close csr_active_gl;
              if g_debug then
                     hr_utility.set_location('Found ', 45);
              end if;
              hr_utility.set_message(8302,'PQH_GSP_INACTIVATE_GRGLDR_ERR');
              hr_utility.raise_error;
         Else
           if g_debug then
                 hr_utility.set_location('Not Found ', 50);
           end if;
          Close csr_active_gl;
         End If;
       End If;  -- stauts check
 End If; -- Pgm Not Null

if g_debug then
 hr_utility.set_location('Leaving:'||l_proc, 55);
end if;
 EXCEPTION
   WHEN others THEN
     fnd_msg_pub.add;
End chk_inactivate_grdldr;

--
---------------------------Get_Emp_Los-----------------------------
--

Function Get_Emp_Los
(P_Person_id In Per_All_PEOPLE_F.Person_Id%TYPE,
 P_Effective_Date  In Date)
Return Number is
/* Venkatesh :- The following function is used to determine the Length of Service
    for a given Person. It is used in Approval UI */

Cursor LOS is
 Select Months_Between(P_Effective_Date,Start_Date) / 12
   from Per_All_people_F
  Where Person_id = p_Person_Id
    and P_Effective_Date
Between Effective_Start_Date and Effective_End_Date;

L_Los Number := 0;
begin

If P_Person_id is Not NULL and P_Effective_Date is Not NUll Then
   open Los;
   Fetch Los into L_Los;
   Close los;
End If;
Return l_los;

End Get_Emp_Los;

Function Get_Currency
(P_Corrency_Code In Fnd_Currencies_Vl.Currency_Code%TYPE)

Return Varchar2 is

Cursor Currency is
Select Name
  from Fnd_Currencies_Vl
 Where Currency_Code = P_Corrency_Code
   and Enabled_Flag = 'Y';

P_Currency_name Fnd_Currencies_Vl.Name%TYPE := NULL;
begin

If P_Corrency_Code is Not Null then
   open Currency;
   Fetch Currency into P_Currency_name;
   Close Currency;
End If;

Return P_Currency_name;
End;

Function Get_SpinalPoint_Name
(p_Point_id    IN       per_spinal_points.Spinal_Point_Id%TYPE)

Return Varchar2 is

Cursor POints is
Select spinal_point
  from per_spinal_points
 Where Spinal_point_id = p_Point_id;

P_Spinal_Point_name per_spinal_points.Spinal_Point%TYPE := NULL;
begin

If p_Point_id is Not Null then
   open POints;
   Fetch POints into P_Spinal_Point_name;
   Close POints;
End If;

Return P_Spinal_Point_name;
End;


--
---------------------------update_or_delete_grade-----------------------------
--

Procedure update_or_delete_grade
( p_copy_entity_txn_id     in   number,
  p_grade_result_id        in   number,
  p_effective_date         in   Date) IS
/* Author : mvankada
   Purpose : This procedure Update/Delete the grade record
 */

-- To Get Pgm_Id of PGM based on Txn_id
Cursor csr_pgm_id
IS
Select grdldr.Information1
From   Ben_Copy_Entity_Results grdldr
Where  grdldr.Table_Alias = 'PGM'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grdldr.Copy_Entity_Txn_Id = p_Copy_Entity_Txn_Id;

-- To Get Grade_Id (information253) of CPP based on Result_id  of CPP
Cursor csr_grade_id
IS
Select grd.Information253
From   Ben_Copy_Entity_Results grd
Where  grd.Table_Alias = 'CPP'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    grd.Copy_Entity_Result_Id = p_Grade_Result_Id;

-- Get Plan Record
Cursor csr_plan_result_id
IS
Select pln.Copy_Entity_Result_Id
From   Ben_Copy_Entity_Results pln
Where  pln.Gs_Mirror_Src_Entity_Result_Id = p_grade_result_id
And    pln.Copy_Entity_Txn_Id  = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    pln.Table_Alias = 'PLN';


Cursor csr_ovn (l_result_id in Number)
IS
Select Object_Version_Number
From   Ben_Copy_Entity_Results
Where  Copy_Entity_Result_Id = l_result_id;

l_pgm_id           Number;
l_grade_id         Number;
l_pln_result_id    Number;
l_ovn              Number;
l_result_id        Number;
l_proc	    varchar2(72) := g_package|| 'update_or_delete_grade';


Begin
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 15);
  hr_utility.set_location('p_grade_result_id:'||p_grade_result_id, 20);
  hr_utility.set_location('p_effective_date:'||p_effective_date, 25);
end if;


  Open csr_pgm_id;
  Fetch csr_pgm_id into l_pgm_id ;
  Close csr_pgm_id;

if g_debug then
  hr_utility.set_location('l_pgm_id:'||l_pgm_id, 30);
end if;

  Open csr_grade_id;
  Fetch csr_grade_id into l_grade_id;
  Close csr_grade_id;

if g_debug then
  hr_utility.set_location('l_grade_id:'||l_grade_id, 40);
end if;

If (l_pgm_id IS Not Null And l_grade_id IS Not Null) Then
if g_debug then
     hr_utility.set_location('Record is in Main Tables', 50);
end if;
     if p_grade_result_id IS NOT NULL Then
        Open csr_ovn(p_grade_result_id);
        Fetch csr_ovn into l_ovn;
        Close csr_ovn;

        ben_copy_entity_results_api.update_copy_entity_results(
	         p_copy_entity_result_id => p_grade_result_id,
	         p_effective_date        => p_effective_date,
	         p_information104        => 'UNLINK',
	         p_object_version_number => l_ovn,
                 p_information323        => null);

      end if;
Else
if g_debug then
     hr_utility.set_location('Record is in Staging Area', 50);
end if;
     if p_grade_result_id IS NOT NULL Then

         -- Update Plan Record with Gs_Mirror_Src_Entity_Result_Id as Null
         Open csr_plan_result_id;
         Fetch csr_plan_result_id into l_pln_result_id;
         Close csr_plan_result_id;

         Open csr_ovn(l_pln_result_id);
	 Fetch csr_ovn into l_ovn;
         Close csr_ovn;

         ben_copy_entity_results_api.update_copy_entity_results(
	 	         p_copy_entity_result_id        => l_pln_result_id,
	 	         p_effective_date               => p_effective_date,
	 	         p_Gs_Mr_Src_Entity_Result_Id   => NULL,
	 	         p_object_version_number        => l_ovn,
                         p_information323               => null);


         -- Delete PLIP Record.

         Open csr_ovn(p_grade_result_id);
	 Fetch csr_ovn into l_ovn;
         Close csr_ovn;

         ben_copy_entity_results_api.delete_copy_entity_results(
	                      p_copy_entity_result_id => p_grade_result_id,
	                      p_effective_date        => p_effective_date,
                              p_object_version_number => l_ovn);
     end if;

End if;
if g_debug then
hr_utility.set_location('Leaving:'||l_proc, 10);
end if;

End update_or_delete_grade;

--
---------------------------update_or_delete_step-----------------------------
--

Procedure update_or_delete_step
( p_copy_entity_txn_id     in   Number,
  p_step_result_id         in   Number,
  p_step_id                in   Number,
  p_point_result_id        in   Number,
  p_effective_date         in   Date) IS

/* Author : mvankada
   Purpose : This procedure Update/Deletes Step Record

   If the Record is in the Staging Area only
     1) If Use_Prg_Points = 'STEP' then  delete
         i) Point Record
         ii) Step Record
     2) If Use_Prg_Points = 'POINT' then  delete
         i) Step Record

   If the Record is in the Main Tables
     1) If Use_Prg_Points = 'STEP' then  Update the following recors information104 as UNLINK
         i) Point Record
         ii) Step Record
     2) If Use_Prg_Points = 'POINT' then  Update the following recors information104 as UNLINK
         i) Step Record

 */

-- To Get information1 (Pgm_ID) of PGM, based on TXN_ID
 Cursor csr_pgm_id
 IS
 Select  grdldr.information1    -- PGM_ID
 From    Ben_Copy_Entity_Results  grdldr
 Where   grdldr.Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
 AND     grdldr.Table_Alias =  'PGM';

-- To Get information253 (Grade_id) of CPP, based on Step Result Id
Cursor csr_grade_id
IS
Select  grd.information253
From    Ben_Copy_Entity_Results  grd
Where   grd.Table_Alias = 'CPP'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND     grd.copy_entity_result_id = (Select step.gs_parent_entity_result_id
                                     From   Ben_Copy_Entity_Results  step
                                     Where  step.Copy_Entity_Result_Id= p_step_result_id
                                     AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
                                     AND    step.Table_Alias = 'COP');

Cursor csr_ovn (l_result_id in Number)
IS
Select Object_Version_Number
From   Ben_Copy_Entity_Results
Where  Copy_Entity_Result_Id = l_result_id;


l_pgm_id   		Number;
l_grade_id    		Number;
l_use_points            Varchar2(20);
l_ovn                   Number;
l_result_id             Number;


l_proc	    varchar2(72) := g_package|| 'update_or_delete_step';


Begin
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 15);
  hr_utility.set_location('p_step_result_id:'||p_step_result_id, 20);
  hr_utility.set_location('p_step_id:'||p_step_id, 30);
  hr_utility.set_location('p_point_result_id:'||p_point_result_id, 40);
end if;


    l_use_points:= pqh_gsp_utility.USE_POINT_OR_STEP(p_copy_entity_txn_id=>p_copy_entity_txn_id);
if g_debug then
    hr_utility.set_location('l_use_points:'||l_use_points, 50);
end if;

    Open csr_pgm_id;
    Fetch csr_pgm_id into l_pgm_id;
    Close csr_pgm_id;
if g_debug then
    hr_utility.set_location('l_pgm_id:'||l_pgm_id,60);
end if;

    Open csr_grade_id;
    Fetch csr_grade_id into l_grade_id;
    Close csr_grade_id;
if g_debug then
    hr_utility.set_location('l_grade_id:'||l_grade_id,70);
end if;

    -- Rec In Main Tables
    If (l_pgm_id IS NOT Null And l_grade_id IS NOT Null And p_step_id IS NOT Null) Then
if g_debug then
    hr_utility.set_location('Rec is in Main Tables',80);
end if;

         -- Update Point Record
         if ((l_use_points = 'STEP') AND (p_point_result_id IS NOT NULL)) then

           Open csr_ovn(p_point_result_id);
	   Fetch csr_ovn into l_ovn;
	   Close csr_ovn;
	   ben_copy_entity_results_api.update_copy_entity_results(
	   	 	         p_copy_entity_result_id        => p_point_result_id,
	   	 	         p_effective_date               => p_effective_date,
	   	 	         p_information104               => 'UNLINK',
	   	 	         p_object_version_number        => l_ovn,
	                         p_information323               => null);

         end if;
if g_debug then
         hr_utility.set_location('Point Rec is Updated Sucessfully',90);
end if;

         -- Update Step Record
         if p_step_result_id IS NOT NULL then

             Open csr_ovn(p_step_result_id);
	     Fetch csr_ovn into l_ovn;
	     Close csr_ovn;
	     ben_copy_entity_results_api.update_copy_entity_results(
	     	   	 	         p_copy_entity_result_id        => p_step_result_id,
	     	   	 	         p_effective_date               => p_effective_date,
	     	   	 	         p_information104               => 'UNLINK',
	     	   	 	         p_object_version_number        => l_ovn,
	                                 p_information323               => null);

         End if;
if g_debug then
         hr_utility.set_location('Step Rec is Updated Sucessfully',100);
end if;
    Else
if g_debug then
       hr_utility.set_location('Record is in Staging Area Only',110);
end if;
       -- Delete Point Record
       if ((l_use_points = 'STEP') And  p_point_result_id IS NOT NULL) then

           Open csr_ovn(p_point_result_id);
	   Fetch csr_ovn into l_ovn;
	   Close csr_ovn;
	   ben_copy_entity_results_api.delete_copy_entity_results(
	   	                      p_copy_entity_result_id => p_point_result_id,
	   	                      p_effective_date        => p_effective_date,
	                              p_object_version_number => l_ovn);
       end if;
if g_debug then
       hr_utility.set_location('Point Rec is Deleted Sucessfully',120);
end if;

       -- Delete Step Record
        if p_step_result_id IS NOT NULL then

          Open csr_ovn(p_step_result_id);
	  Fetch csr_ovn into l_ovn;
	  Close csr_ovn;
	  ben_copy_entity_results_api.delete_copy_entity_results(
	  	   	                      p_copy_entity_result_id => p_step_result_id,
	  	   	                      p_effective_date        => p_effective_date,
	                                      p_object_version_number => l_ovn);
        end if;
if g_debug then
        hr_utility.set_location('Step Rec is Deleted Sucessfully',130);
end if;

    End if;
if g_debug then
hr_utility.set_location('Leaving :' ||l_proc, 200);
end if;
End update_or_delete_step;

--

--
---------------------------set_step_name-----------------------------
--

PROCEDURE set_step_name(p_copy_entity_txn_id in number,
			p_effective_start_date in date,
			p_grd_result_id in number)
IS
l_proc            varchar2(72) := g_package||'set_step_name';
CURSOR csr_points
IS
select  oipl.copy_entity_result_id,
        oipl.object_version_number
from    ben_copy_entity_results oipl,
        ben_copy_entity_results opt
where   nvl(oipl.information104,'PPP') <>  'UNLINK'
AND    nvl(oipl.result_type_cd,'DISPLAY') = 'DISPLAY'
AND    nvl(opt.result_type_cd,'DISPLAY') = 'DISPLAY'
and     oipl.table_alias = 'COP'
and     opt.table_alias = 'OPT'
and     oipl.copy_entity_txn_id = p_copy_entity_txn_id
and     oipl.information262 = opt.copy_entity_result_id
and     oipl.gs_parent_entity_result_id = p_grd_result_id
order by opt.information253;
stepnum NUMBER :=0;
begin
if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 10);
  hr_utility.set_location('p_effective_date:'||p_effective_start_date, 20);
  hr_utility.set_location('p_grd_result_id:'||p_grd_result_id, 30);
end if;
for i in csr_points loop
 stepnum :=stepnum+1;
  ben_copy_entity_results_api.update_copy_entity_results(
 p_copy_entity_result_id => i.copy_entity_result_id,
 p_effective_date        => p_effective_start_date,
 p_copy_entity_txn_id    => p_copy_entity_txn_id,
 p_information5          => fnd_message.get_string('PQH','PQH_GSP_STEP_PROMPT')||stepnum,
 p_information100        => fnd_message.get_string('PQH','PQH_GSP_STEP_PROMPT')||stepnum,
 p_object_version_number => i.object_version_number,
 p_information323        => null);
end loop;
if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 35);
end if;
END SET_STEP_NAME;

--
--------------------------- chk_unlink_grd_from_grdldr -----------------------------
--
Procedure chk_unlink_grd_from_grdldr
           (p_pgm_id               in   Number
           ,p_copy_entity_txn_id   in   Number
           ,p_business_group_id    in   Number
           ,p_effective_date       in   Date
           ,p_status               OUT NOCOPY   Varchar2
           ) IS
/*
  This procedure raises error if employee placements exists on unlinked grades
*/

 l_proc            varchar2(72) := g_package||'chk_unlink_grd_from_grdldr';
 l_dummy           char(1);
 l_found           Boolean;
 l_grd_war_found   Boolean;
 l_no_grades       Varchar2(4000) := null;
 l_no_war_grades   Varchar2(4000) := null;

 Cursor csr_grades
 IS
 Select Information253,    -- Grade Id
        Information5       -- Grade Name
 From   Ben_Copy_Entity_Results
 Where  Copy_Entity_Txn_Id = p_copy_entity_txn_id
 And    Table_Alias = 'CPP'
 And    Information253 IS NOT NULL
 AND    Nvl(Information104,'PPP') = 'UNLINK'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
 And    Information4 = p_Business_Group_Id;

 -- Check Grade is attached to an Employee
 Cursor csr_gl_grd_emp_assg (l_grade_id Number)
 IS
 Select  Null
 From   per_all_assignments_f assgt
 Where  grade_id = l_grade_id
 AND    Grade_Ladder_Pgm_Id     = p_pgm_id
 AND    p_Effective_Date BETWEEN assgt.effective_start_date
 AND    nvl(assgt.effective_end_date,hr_general.end_of_time)
 AND    assgt.business_group_id = p_Business_Group_Id;


 -- Check Grade is attached to an employee
 Cursor csr_grd_assg_emp (l_grade_id Number)
 IS
 Select Null
 From   per_all_assignments_f assgt
 Where  grade_id = l_grade_id
 AND    p_Effective_Date BETWEEN assgt.effective_start_date
 AND    nvl(assgt.effective_end_date,hr_general.end_of_time)
 AND    assgt.business_group_id = p_Business_Group_Id;

 -- Default Grade Ladder
 Cursor csr_default_grdldr
 IS
 Select   Null
 From     ben_pgm_f
 Where    pgm_id = p_pgm_id
 And      pgm_typ_cd = 'GSP'
 And      Dflt_Pgm_Flag = 'Y'
 And      business_group_id = p_business_group_id
 And      p_Effective_Date Between Effective_Start_date
 And      nvl(Effective_End_Date,hr_general.end_of_time);

 BEGIN
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_pgm_id :'||p_pgm_id ,10);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 15);
  hr_utility.set_location('p_business_group_id:'||p_business_group_id, 20);
  hr_utility.set_location('p_effective_date:'||p_effective_date, 25);
end if;
  p_status := null;

  If p_pgm_id IS NOT NULL Then
    Open csr_default_grdldr;
    Fetch csr_default_grdldr into l_dummy;
    If csr_default_grdldr%NotFound Then
    if g_debug then
         hr_utility.set_location('Not Default Grade Ladder', 26);
    end if;
         --If Emp Placements exists on  Grades then throw error msg
          For l_rec IN  csr_grades
          Loop
             Open csr_gl_grd_emp_assg(l_rec.Information253);
             Fetch csr_gl_grd_emp_assg into l_dummy;
             If csr_gl_grd_emp_assg%Found Then
                  l_no_grades := l_no_grades || l_rec.Information5 ||' , ';
                  l_found := TRUE;
             End If;
             Close csr_gl_grd_emp_assg;
          End Loop;
    Else
    if g_debug then
         hr_utility.set_location(' Default Grade Ladder', 27);
    end if;
        -- If Emp Placements exists on  Default Grade Ladder Grades then throw warning msg
           For l_rec IN  csr_grades
	   Loop
	             Open csr_grd_assg_emp(l_rec.Information253);
	             Fetch csr_grd_assg_emp into l_dummy;
	             If csr_grd_assg_emp%Found Then
	             if g_debug then
	                  hr_utility.set_location(' Grades are ... '||l_rec.Information5, 28);
	             end if;
	                  l_no_war_grades := l_no_war_grades || l_rec.Information5 ||' , ';
	                  l_grd_war_found  := TRUE;
	             End If;
	             Close csr_grd_assg_emp;
           End Loop;
    End if;
    Close csr_default_grdldr;

    If l_found then
    if g_debug then
          hr_utility.set_location(' Found Error Grades', 27);
    end if;
          l_no_grades := substr(l_no_grades,1,length(l_no_grades)-2);
          p_status := 'E';
          hr_utility.set_message(8302,'PQH_GSP_CANNOT_UNLINK_GRADES');
          hr_utility.set_message_token('GRADES',l_no_grades );
          hr_multi_message.add;
    End if;

    if l_grd_war_found then
    if g_debug then
              hr_utility.set_location(' Found Warning Grades', 27);
    end if;
              l_no_war_grades := substr(l_no_war_grades,1,length(l_no_war_grades)-2);
              hr_utility.set_location(' Length '||length(l_no_war_grades), 28);
              p_status := l_no_war_grades;
     end if;
   End If;
   if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 100);
    end if;
Exception
    When Others Then
    if g_debug then
       hr_utility.set_location('sqlerrm:'||substr(sqlerrm,1,50), 100);
       hr_utility.set_location('sqlerrm:'||substr(sqlerrm,51,100), 101);
       hr_utility.set_location('sqlerrm:'||substr(sqlerrm,101,150), 102);
    end if;

       p_status := null;
 END  chk_unlink_grd_from_grdldr;

--
--------------------------- chk_unlink_step_from_grdldr -----------------------------
--
Procedure chk_unlink_step_from_grdldr
           (p_copy_entity_txn_id   in   Number
           ,p_business_group_id    in   Number
           ,p_effective_date       in   Date
           ) IS
/*  This procedure raises error if Step is
         1)  Ceiling Step
         2)  Special Ceiling Step
         3)  Employee Placements on this Step
*/

 l_proc      varchar2(72) := g_package||'chk_unlink_step_from_grdldr ';
 l_dummy     char(1);
 l_found     Boolean;
 l_no_steps  Varchar2(4000) := null;

 Cursor csr_steps
 IS
 Select Information253, -- Step Id
        Information5    -- Step Name
        INFORMATION98   -- Ceiling Flag
 From   Ben_Copy_Entity_Results
 Where  Copy_Entity_Txn_Id = p_copy_entity_txn_id
 And    Table_Alias = 'COP'
 AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
 And    Information253 IS NOT NULL
 AND    Nvl(Information104,'PPP') = 'UNLINK'
 And    Information4   = p_business_group_id ;

 BEGIN
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_copy_entity_txn_id:'||p_copy_entity_txn_id, 15);
  hr_utility.set_location('p_business_group_id:'||p_business_group_id, 20);
  hr_utility.set_location('p_effective_date:'||p_effective_date, 25);
  end if;

  For l_rec IN csr_steps
  Loop
      PER_SPINAL_POINT_STEPS_PKG.del_chks_del(p_step_id => l_rec.Information253,
                                              p_sess    => p_effective_date);

      If (l_rec.INFORMATION98 = 'Y') Then  -- Ceiling_Step_Flag Values Y/N
                   hr_utility.set_message(801, 'PER_7937_DEL_CEIL_STEP');
                   hr_utility.raise_error;
      END IF;
  End Loop;

  if g_debug then
  hr_utility.set_location('Leaving:'||l_proc, 100);
  end if;

 END  chk_unlink_step_from_grdldr;


--
--------------------------- chk_grdldr_name_unique -----------------------------
--
 Procedure chk_grdldr_name_unique
           ( p_pgm_id               in   Number
            ,p_business_group_id    in   Number
            ,p_name                 in   varchar2
            )
 is
 l_proc      varchar2(72) := g_package||'chk_grdldr_name_unique';
 l_dummy    char(1);

 Cursor csr_name
 IS
 Select null
 From   Ben_Pgm_F
 Where  Pgm_Id <>  nvl(p_pgm_id,-1)
 And    Name = p_name
 And    Business_Group_Id = p_business_group_id;

 --
 Begin
 if g_debug then
   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.set_location('p_pgm_id :'||p_pgm_id ,10);
   hr_utility.set_location('p_business_group_id:'||p_business_group_id, 15);
   end if;


   --
   if g_debug then
   hr_utility.set_location('Chk Name...', 50);
   end if;
   Open csr_name;
   Fetch csr_name into l_dummy;
   If csr_name%Found then
       Close csr_name;
       hr_utility.set_message(8302,'PQH_GSP_GRDLDR_NAME_UNIQUE');
       hr_multi_message.add;
   Else
      Close csr_name;
   End If;
   --
   if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 15);
   end if;
 End chk_grdldr_name_unique;

--
--------------------------- chk_gl_sht_name_code_unique -----------------------------
--
 Procedure chk_gl_sht_name_code_unique
           ( p_pgm_id               in   Number
            ,p_business_group_id    in   Number
            ,p_short_name           in   varchar2 Default Null
            ,p_short_code           in   varchar2 Default Null)
 is
 l_proc      varchar2(72) := g_package||'chk_gl_sht_name_code_unique';
 l_dummy    char(1);


 Cursor csr_short_name
 IS
 Select null
 From   Ben_Pgm_F
 Where  Pgm_Id <>  nvl(p_pgm_id,-1)
 And    Short_Name = nvl(p_short_name,-1)
 And    Business_Group_Id = p_business_group_id
 And    p_short_name IS NOT NULL;

 Cursor csr_short_code
 IS
 Select null
 From   Ben_Pgm_F
 Where  Pgm_Id <>  nvl(p_pgm_id,-1)
 And    Short_Code = nvl(p_short_code,-1)
 And    Business_Group_Id = p_business_group_id
 And    p_short_code IS NOT NULL;

 --
 Begin
 if g_debug then
   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_utility.set_location('p_pgm_id :'||p_pgm_id ,10);
   hr_utility.set_location('p_business_group_id:'||p_business_group_id, 15);
   hr_utility.set_location('p_short_name:'||p_short_name, 20);
   hr_utility.set_location('p_short_code:'||p_short_code, 25);
   hr_utility.set_location('Chk Short Name...', 60);
 end if;

   Open csr_short_name;
   Fetch csr_short_name into l_dummy;
   If csr_short_name%Found then
       Close csr_short_name;
       hr_utility.set_message(8302,'PQH_GSP_GL_SHT_NAME_CODE_UNQ');
       hr_multi_message.add;
   Else
       Close csr_short_name;
   End If;
   --
if g_debug then
   hr_utility.set_location('Chk Short Code....', 70);
end if;
   Open csr_short_code;
   Fetch csr_short_code into l_dummy;
   If csr_short_code%Found then
       Close csr_short_code;
       hr_utility.set_message(8302,'PQH_GSP_GL_SHT_NAME_CODE_UNQ');
       hr_multi_message.add;
   Else
       Close csr_short_code;
   End If;
   --
if g_debug then
   hr_utility.set_location('Leaving:'||l_proc, 15);
end if;
 End chk_gl_sht_name_code_unique;


--
---------------------------validate_grade_ladder-----------------------------
--
/*
   The following procedure validates the grade ladder before it is saved.
*/
Procedure validate_grade_ladder(
   p_pgm_id                         in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_name                           in  varchar2
  ,p_pgm_stat_cd                    in  varchar2
  ,p_pgm_typ_cd                     in  varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number
  ,p_rt_strt_dt_cd                  in  varchar2
  ,p_rt_strt_dt_rl                  in  number
  ,p_pgm_uom                        in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_enrt_rl                        in  number
  ,p_auto_enrt_mthd_rl              in  number
  ,p_business_group_id              in  number
  ,p_Dflt_pgm_flag                  in  Varchar2
  ,p_Use_prog_points_flag           in  Varchar2
  ,p_Dflt_step_cd                   in  Varchar2
  ,p_Dflt_step_rl                   in  number
  ,p_Update_salary_cd               in  Varchar2
  ,p_Use_multi_pay_rates_flag       in  Varchar2
  ,p_dflt_element_type_id           in  number
  ,p_Dflt_input_value_id            in  number
  ,p_Use_scores_cd                  in  Varchar2
  ,p_Scores_calc_mthd_cd            in  Varchar2
  ,p_Scores_calc_rl                 in  number
  ,p_gsp_allow_override_flag        in  varchar2
  ,p_use_variable_rates_flag        in  varchar2
  ,p_salary_calc_mthd_cd            in  varchar2
  ,p_salary_calc_mthd_rl            in  number
  ,p_effective_date                 in  date
  ,p_short_name                     in  varchar2
  ,p_short_code                     in  varchar2
 ) is

l_proc	    varchar2(72) := g_package||'validate_grade_ladder';

BEGIN
if g_debug then
  hr_utility.set_location('Entering :' ||l_proc, 10);
end if;

  -- Check Grade Ladder Name is Unique with in the Business Group
if g_debug then
  hr_utility.set_location('Check Grade Ladder Name is Unique ', 20);
end if;
  pqh_gsp_utility.chk_grdldr_name_unique( p_pgm_id               => p_pgm_id
                                          ,p_business_group_id   => p_business_group_id
                                          ,p_name                => p_name);

  -- Check Grade Ladder , Short Name and Short Code is Unique with in the Business Group
  if g_debug then
  hr_utility.set_location('Check Grade Ladder Short Name and Short Code is Unique ', 25);
end if;

  If (p_short_name IS NOT NULL or p_short_code  IS NOT NULL) Then
      pqh_gsp_utility.chk_gl_sht_name_code_unique( p_pgm_id                 =>  p_pgm_id
                                                ,p_business_group_id    => p_business_group_id
                                                ,p_short_name           => p_short_name
                                                ,p_short_code           => p_short_code);

  End If;
  -- Check if there is only one default grade ladder in the business group
  if g_debug then
  hr_utility.set_location('Default Grade Ladder in BG ', 30);
  end if;

  pqh_gsp_utility.chk_default_ladder_exist ( p_pgm_id             => p_pgm_id,
                                             p_business_group_id  => p_business_group_id,
                                             p_effective_date     => p_effective_date);

  -- The system should not allow inactivating an existing grade ladder on
  -- which there are employee placements.

 /*
 if g_debug then
  hr_utility.set_location('Inactivated GL ', 40);
end if;
  pqh_gsp_utility.chk_inactivate_grdldr ( p_pgm_id             => p_pgm_id,
                                          p_effective_date     => p_effective_date,
                                          p_business_group_id  => p_business_group_id);
 */




-- Check if score calculation method is entered against lookup
-- Check if score calcultion method is rule, the fast formula is selected
-- Validate all lookups
if g_debug then
hr_utility.set_location('Leaving :' ||l_proc, 100);
end if;
End;
--
--
---------------------------chk_grdldr_grd_curreny_rate-----------------------------
--
Procedure chk_grdldr_grd_curreny_rate
(p_copy_entity_txn_id    In Number,
 p_business_group_id     In Number,
 p_effective_date        In Date) IS

-- fix for bug 7114098
l_pgm_id number;
cursor csr_pgm_val is
select information1
from Ben_Copy_Entity_Results
where Copy_Entity_Txn_Id = p_copy_entity_txn_id
and Information4 = p_business_group_id
and table_alias = 'PGM'  ;

-- fix for bug 7114098

-- Get Grade Ladder Details
Cursor csr_grdldr_details
IS
Select  Copy_Entity_Result_Id,
        Information50, -- Currency_Code
        Information41 -- Rate_Period
From    Ben_Copy_Entity_Results
Where   Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND     Table_Alias   = 'PGM'
AND     Result_Type_Cd = 'DISPLAY'
AND     Nvl(Information104,'PPP') <> 'UNLINK'
AND     Information4 = p_business_group_id ;


-- Get Grade Ids
Cursor csr_grade_ids(l_grdldr_result_id IN Number)
IS
Select  Information253, -- Grade Id
        Information5    -- Grade Name
From    Ben_Copy_Entity_Results
Where   Gs_Parent_Entity_Result_Id = l_grdldr_result_id
And     Copy_Entity_Txn_Id = p_copy_entity_txn_id
And     Table_Alias = 'CPP'
AND     Nvl(Information104,'PPP') <> 'UNLINK'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND     Information253 IS NOT NULL
AND     Information4 = p_business_group_id ;


Cursor csr_pgm_detials(l_grade_id IN Number, l_rate IN Varchar, l_currency IN Varchar) Is
 Select Pgm.ACTY_REF_PERD_CD, -- Rate
        Pgm.Pgm_uom           -- Currency
   From Ben_Pl_f Pl,
        Ben_Plip_F Plip,
        Ben_Pgm_F Pgm
  Where Pl.MAPPING_TABLE_PK_ID = l_grade_Id
    and Pl.MAPPING_TABLE_NAME  = 'PER_GRADES'
    and P_Effective_Date
Between Pl.Effective_Start_Date
    and Nvl(Pl.Effective_End_Date,hr_general.end_of_time)
    and Plip.Pl_Id  = Pl.Pl_Id
    and P_Effective_Date
Between Plip.Effective_Start_Date
    and Nvl(Plip.Effective_End_Date,hr_general.end_of_time)
    and Plip.Pgm_Id = Pgm.Pgm_Id
    and P_Effective_Date
Between Pgm.Effective_Start_Date
    and Nvl(Pgm.Effective_End_Date,hr_general.end_of_time)
    and pgm.Business_group_id = p_Business_Group_Id
    and (pgm.ACTY_REF_PERD_CD <> l_rate
     or  pgm.Pgm_Uom <> l_currency)
    and  Pgm_Typ_Cd = 'GSP'
    and l_pgm_id <> pgm.pgm_id; -- added for bug 7114098

l_proc	    varchar2(72) := g_package|| 'chk_grdldr_grd_curreny_rate';
l_curr_gl_result_id Number;
l_curr_gl_currency    Ben_Copy_Entity_Results.Information50%Type;
l_curr_gl_period      Ben_Copy_Entity_Results.Information41%Type;

l_target_currency     Ben_Pgm_F.PGM_UOM%Type;
l_target_period       Ben_Pgm_F.ACTY_REF_PERD_CD%Type;

l_dummy               Varchar2(4000) := null;
l_found               Boolean := FALSE;



BEGIN
if g_debug then
hr_utility.set_location('Entering :' ||l_proc, 10);
hr_utility.set_location('p_copy_entity_txn_id:' ||p_copy_entity_txn_id, 20);
hr_utility.set_location('p_business_group_id:' ||p_business_group_id, 30);
hr_utility.set_location('p_effective_date:' ||p_effective_date, 40);
end if;


Open csr_grdldr_details;
Fetch csr_grdldr_details into l_curr_gl_result_id,l_curr_gl_currency,l_curr_gl_period;
Close csr_grdldr_details;

if g_debug then
hr_utility.set_location('l_curr_gl_result_id:' ||l_curr_gl_result_id, 50);
hr_utility.set_location('l_curr_gl_currency:' ||l_curr_gl_currency, 60);
hr_utility.set_location('l_curr_gl_period:' ||l_curr_gl_period, 70);
end if;

-- fix for bug 7114098
open csr_pgm_val;
fetch csr_pgm_val into l_pgm_id;
close csr_pgm_val;
-- fix for bug 7114098

For l_grade_id_rec IN csr_grade_ids(l_curr_gl_result_id)
Loop

      Open csr_pgm_detials(l_grade_id_rec.Information253,l_curr_gl_period, l_curr_gl_currency);
      Fetch csr_pgm_detials into l_target_currency,l_target_period;
      If csr_pgm_detials%Found Then
           l_found := TRUE;
           l_dummy := l_dummy || l_grade_id_rec.Information5 ||' , ';
      End If;
      Close csr_pgm_detials;
End Loop;


if l_found Then
    l_dummy := substr(l_dummy,1,length(l_dummy)-2);
if g_debug then
    hr_utility.set_location('l_dummy 1:' ||substr(l_dummy,1,50), 80);
    hr_utility.set_location('l_dummy 2:' ||substr(l_dummy,51,100), 81);
    hr_utility.set_location('l_dummy 3:' ||substr(l_dummy,101,150), 82);
end if;

    hr_utility.set_message(8302,'PQH_GSP_GRDS_DIFF_CURR_PERIOD');
    hr_utility.set_message_token('GRADES',l_dummy );
    hr_multi_message.add;
end if;
if g_debug then
hr_utility.set_location('Leaving :' ||l_proc, 100);
end if;
END chk_grdldr_grd_curreny_rate;

--
--
---------------------------------------------------------------------------
-- This procedure validates if duplicate criteria set has been defined
-- and attached to the grade ladder.
--
Procedure chk_duplicate_crset_exists(
                           p_copy_entity_txn_id in number,
                           p_effective_date     in date,
                           p_cset_id            in number    default null,
                           p_location_id        in number    default null,
                           p_job_id             in number    default null,
                           p_org_id             in number    default null,
                           p_rule_id            in number    default null,
                           p_person_type_id     in number    default null,
                           p_service_area_id    in number    default null,
                           p_barg_unit_cd       in varchar2  default null,
                           p_full_part_time_cd  in varchar2  default null,
                           p_perf_type_cd       in varchar2  default null,
                           p_rating_type_cd     in varchar2  default null,
                           p_duplicate_exists  out nocopy varchar2,
                           p_duplicate_cset_name out nocopy varchar2) is
 --
 -- Select all crsets in the txn which are not equal to current crset
 --
 cursor csr_crset is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CRSET'
   and   p_effective_date between information2 and nvl(information3, to_date('31/12/4712','dd/mm/RRRR'))
   AND   nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
   and   INFORMATION161 <> nvl(p_cset_id, -1)
   order by information161,information2;
 --
 l_proc varchar2(200) := 'chk_duplicate_crset_exists';
 --
Begin
 --
 hr_utility.set_location('Entering :' ||l_proc, 5);
 --
 p_duplicate_exists := 'N';
 --
 For crset_rec in csr_crset loop
  --
  -- Check for duplicate criteria set
  --
  If (nvl(crset_rec.INFORMATION232,-1) = nvl(p_location_id,-1) and
      nvl(crset_rec.INFORMATION233,-1) = nvl(p_job_id,-1) and
      nvl(crset_rec.INFORMATION234,-1) = nvl(p_org_id,-1) and
      nvl(crset_rec.INFORMATION235,-1) = nvl(p_rule_id,-1) and
      nvl(crset_rec.INFORMATION236,-1) = nvl(p_person_type_id,-1) and
      nvl(crset_rec.INFORMATION237,-1) = nvl(p_service_area_id,-1) and
      nvl(crset_rec.INFORMATION101,'XXX') = nvl(p_barg_unit_cd,'XXX') and
      nvl(crset_rec.INFORMATION102,'XXX') = nvl(p_full_part_time_cd,'XXX') and
      nvl(crset_rec.INFORMATION103,'XXX') = nvl(p_perf_type_cd,'XXX') and
      nvl(crset_rec.INFORMATION104,'XXX') = nvl(p_rating_type_cd,'XXX')) then
         --
         p_duplicate_cset_name := crset_rec.INFORMATION151;
         p_duplicate_exists := 'Y';
         hr_utility.set_location('Duplicate :' ||p_duplicate_cset_name, 7);
         --
  End if;
  --
  --
 End loop;
 --
 hr_utility.set_location('Leaving :' ||l_proc, 10);
 --
End;
-------------------------------------------------------------------
-- This procedure validates if criteria set has been properly defined i.e
-- 1) Criteria set name is not null
-- 2) At least one criterion is entered
-- 3) If performance type is entered, rating type must also be entered
--
Procedure validate_crset_values(p_copy_entity_txn_id in number,
                                p_effective_date     in date)
is
 --
 cursor csr_crset is
   select *
   from ben_copy_entity_results
   where copy_entity_txn_id = p_copy_entity_txn_id
   and   table_alias        = 'CRSET'
   AND   nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
   and   dml_operation in ('INSERT','UPDATE') -- Check only insert/ updates crset
   order by information161,information2;
 --
 l_duplicate_exists varchar2(10);
 l_duplicate_cset_name varchar2(240);
 l_proc varchar2(200) := 'validate_crset_values';
 l_continue boolean;
 --
Begin
--
hr_utility.set_location('Entering :' ||l_proc, 5);
--
For crset_rec in csr_crset loop
 --
 l_continue := true;
 --
 -- Criteria set name should be entered. Ideally this error should never be raised.
 --
 If crset_rec.INFORMATION151 is NULL then
        hr_utility.set_message(8302,'PQH_GSP_CRI_SET_NAME_ERR');
        hr_multi_message.add;
        l_continue := false;
 End if;
 --
 -- Criteria set should have at least one criterion
 --
If l_continue then
  --
  hr_utility.set_location('Check 1' , 5);
  --
  If (crset_rec.INFORMATION232 IS NULL and
      crset_rec.INFORMATION233 IS NULL and
      crset_rec.INFORMATION234 IS NULL and
      crset_rec.INFORMATION235 IS NULL and
      crset_rec.INFORMATION236 IS NULL and
      crset_rec.INFORMATION237 IS NULL and
      crset_rec.INFORMATION101 IS NULL and
      crset_rec.INFORMATION102 IS NULL and
      crset_rec.INFORMATION103 IS NULL and
      crset_rec.INFORMATION104 IS NULL ) then
         --
         hr_utility.set_message(8302,'PQH_GSP_CRI_SET_NO_CRIT');
         hr_utility.set_message_token('CSET',crset_rec.INFORMATION151);
         hr_multi_message.add;
         l_continue := false;
         --
  End if;
  --
End if;

If l_continue then
  --
  --
  hr_utility.set_location('Perf Rating Check ' , 5);
  --
  -- If performance type is entered, rating type must also be entered.
  --
  If ((crset_rec.INFORMATION103 IS NULL and crset_rec.INFORMATION104 IS NOT NULL) OR
      (crset_rec.INFORMATION103 IS NOT NULL and crset_rec.INFORMATION104 IS NULL)) then
         --
         hr_utility.set_message(8302,'PQH_GSP_INVALID_PERF_RATING');
         hr_utility.set_message_token('CSET',crset_rec.INFORMATION151);
         hr_multi_message.add;
         l_continue := false;
         --
  End if;
 End if;
  --
  --
  -- Check if there exists a duplicate for the current criteria set in the transaction
  --
 If l_continue then
  --
  --
  hr_utility.set_location('Duplicate Check' || to_char(crset_rec.information161) , 5);
  --
      chk_duplicate_crset_exists(
                           p_copy_entity_txn_id  => p_copy_entity_txn_id,
                           p_effective_date      => p_effective_date,
                           p_cset_id             => crset_rec.information161,
                           p_location_id         => crset_rec.INFORMATION232,
                           p_job_id              => crset_rec.INFORMATION233,
                           p_org_id              => crset_rec.INFORMATION234,
                           p_rule_id             => crset_rec.INFORMATION235,
                           p_person_type_id      => crset_rec.INFORMATION236,
                           p_service_area_id     => crset_rec.INFORMATION237,
                           p_barg_unit_cd        => crset_rec.INFORMATION101,
                           p_full_part_time_cd   => crset_rec.INFORMATION102,
                           p_perf_type_cd        => crset_rec.INFORMATION103,
                           p_rating_type_cd      => crset_rec.INFORMATION104,
                           p_duplicate_exists    => l_duplicate_exists,
                           p_duplicate_cset_name => l_duplicate_cset_name);
   --
   If l_duplicate_exists = 'Y' then
     --
         hr_utility.set_location('Duplicate cset || l_duplicate_cset_name' , 5);
         hr_utility.set_message(8302,'PQH_GSP_DUPLICATE_CSETS_ERR');
         hr_utility.set_message_token('CSET1',crset_rec.INFORMATION151);
         hr_utility.set_message_token('CSET2',l_duplicate_cset_name);
         hr_multi_message.add;
     --
   End if;
   --
End if;
--
End loop;
--
hr_utility.set_location('Leaving :' ||l_proc, 10);
--
End;
---------------------------chk_review_submit_val-----------------------------
--
Procedure chk_review_submit_val
(p_copy_entity_txn_id     in   Number,
 p_effective_date         in   Date,
 p_pgm_id                 in   Number,
 p_business_group_id      in   Number,
 p_status                 OUT NOCOPY   Varchar2,
 p_prog_le_created_flag   OUT NOCOPY   Varchar2,
 p_sync_le_created_flag   OUT NOCOPY   Varchar2,
 p_plan_tp_created_flag   OUT NOCOPY   Varchar2
) IS
/*
Author  : mvankada
Purpose : This procedure checks all validations to be performed
          for Review and submit Page

*/

l_proc	    varchar2(72) := g_package||'chk_review_submit_val';
l_pt_le_status  Varchar2(30);
l_plan_type_start_date DATE:= get_gsp_plntyp_str_date(p_business_group_id,p_copy_entity_txn_id);
Cursor csr_pgm_details
IS
Select  Name,
        Short_Name,
        Short_Code
From    Ben_Pgm_F
Where   Pgm_id Is Not Null
And     Pgm_id = p_pgm_id
And     Business_Group_Id = p_business_group_id;

Cursor csr_grdldr_date
IS
Select Information2 EFFECTIVE_START_DATE
From   Ben_Copy_Entity_Results
Where  Copy_Entity_Txn_id = p_copy_entity_txn_id
And    Information4 = p_business_group_id
And    Table_Alias = 'PGM'
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
And    Information_Category = 'GRADE_LADDER';


l_name        Ben_Pgm_F.Name%Type;
l_short_name  Ben_Pgm_F.Short_Name%Type;
l_short_code  Ben_Pgm_F.Short_Code%Type;
l_status      Varchar2(20) := 'E';
l_error_status Varchar2(20) := 'E';
l_grdldr_date Date;

BEGIN
  hr_multi_message.enable_message_list;
if g_debug then
  hr_utility.set_location('Entering :' ||l_proc, 10);
end if;

  If p_pgm_id IS NOT NULL Then
     Open csr_pgm_details;
     Fetch csr_pgm_details into l_name,l_short_name,l_short_code;
     Close csr_pgm_details;
  End if;


 -- Check if there is only one default grade ladder in the business group
 -- The system should not allow inactivating an existing grade ladder on
 -- which there are employee placements.

 if p_pgm_id IS NOT NULL Then
    pqh_gsp_utility.validate_grade_ladder(p_pgm_id         => p_pgm_id
                                         ,p_effective_date => p_effective_date
                                         ,p_name           => l_name
                                         ,p_short_name     => l_short_name
                                         ,p_short_code     => l_short_code
                                         ,p_business_group_id =>p_business_group_id
                                         );
 end if;

 --  Check Grades can be removed from the Grade Ladder
if g_debug  then
   hr_utility.set_location('Check Grades can be removed from the Grade Ladder', 20);
end if;
   pqh_gsp_utility.chk_unlink_grd_from_grdldr
           (p_pgm_id             => p_pgm_id
           ,p_copy_entity_txn_id => p_copy_entity_txn_id
           ,p_business_group_id  => p_business_group_id
           ,p_effective_date     => p_effective_date
           ,p_status             => l_status
           );
if g_debug then
    hr_utility.set_location('After Check unlink grd from gl ',25);
    hr_utility.set_location('l_status :  '||substr(l_status,1,50),26);
    hr_utility.set_location('l_status :  '||substr(l_status,51,100),27);
    hr_utility.set_location('l_status :  '||substr(l_status,101,150),28);
    hr_utility.set_location('l_status :  '||substr(l_status,151,200),29);
end if;

 -- Check if steps have been added to only some steps in a grade
 -- and warns the user that the setup cannot be saved unless steps are added to all
 -- the Grades.

if g_debug then
    hr_utility.set_location('Only Some Steps are attached Validation', 30);
end if;
    pqh_gsp_utility.chk_add_steps_in_all_grades ( p_copy_entity_txn_id   => p_copy_entity_txn_id ,
                                                  p_business_group_id    => p_business_group_id);

 -- Get Grade Ladder Effective Date
    Open csr_grdldr_date;
    Fetch csr_grdldr_date into l_grdldr_date;
    Close csr_grdldr_date;

 -- Check if Grades are valid as of the Grade Ladder Effective Date


if g_debug then
    hr_utility.set_location('InValid Grades Validation', 40);
end if;
    pqh_gsp_utility.chk_valid_grd_in_grdldr ( p_copy_entity_txn_id    => p_copy_entity_txn_id,
                                              p_effective_date        => p_effective_date,
                                              p_business_group_id     => p_business_group_id);


 -- Check Currecny, Rate Period

if g_debug then
     hr_utility.set_location('Currecny, Rate Period Validation', 70);
end if;
     pqh_gsp_utility.chk_grdldr_grd_curreny_rate ( p_copy_entity_txn_id  => p_copy_entity_txn_id
                                                  ,p_business_group_id   => p_business_group_id
                                                  ,p_effective_date      => p_effective_date);

-- Check Steps can be removed from the Grade Ladder
if g_debug then
   hr_utility.set_location('Check Steps can be removed from the Grade Ladder', 80);
end if;

   pqh_gsp_utility.chk_unlink_step_from_grdldr
           (p_copy_entity_txn_id => p_copy_entity_txn_id
           ,p_business_group_id  => p_business_group_id
           ,p_effective_date     => p_effective_date
           );

-- Check for Plan Type and Life Event
if g_debug then
    hr_utility.set_location('Check Plan Type and Life Event', 85);
end if;
    pqh_gsp_stage_to_hr.setup_check( p_copy_entity_txn_id => p_copy_entity_txn_id,
                                     p_effective_date     => p_effective_date,
                                     p_business_group_id  => p_business_group_id,
                                     p_status             => l_pt_le_status,
                                     p_prog_le_created_flag   => p_prog_le_created_flag,
                                     p_sync_le_created_flag   => p_sync_le_created_flag,
                                     p_plan_tp_created_flag   => p_plan_tp_created_flag
                                     );

    if l_pt_le_status = 'WRONG-DATE-PROG-LE' then
        hr_utility.set_message(8302,'PQH_GSP_WRONG_ST_DT_PROG_LE');
        hr_utility.set_message_token('PLANTYPESTARTDATE',l_plan_type_start_date);
        hr_multi_message.add;
    elsif l_pt_le_status = 'MANY-PROG-LE' then
        hr_utility.set_message(8302,'PQH_GSP_MANY_PROG_LE');
        hr_multi_message.add;
    elsif l_pt_le_status = 'WRONG-DATE-SYNC-LE' then
        hr_utility.set_message(8302,'PQH_GSP_WRONG_ST_DT_SYNC_LE');
        hr_utility.set_message_token('PLANTYPESTARTDATE',l_plan_type_start_date);
        hr_multi_message.add;
    elsif l_pt_le_status = 'MANY-SYNC-LE' then
        hr_utility.set_message(8302,'PQH_GSP_MANY_SYNC_LE');
        hr_multi_message.add;
    elsif l_pt_le_status = 'WRONG-DATE-PT' then
        hr_utility.set_message(8302,'PQH_GSP_WRONG_ST_DT_PT');
        hr_multi_message.add;
    elsif l_pt_le_status = 'MANY-PT' then
        hr_utility.set_message(8302,'PQH_GSP_MANY_PT');
        hr_multi_message.add;
    elsif l_pt_le_status = 'PROG-LE-ERR' or l_pt_le_status = 'SYNC-LE-ERR'  or l_pt_le_status = 'PT-ERR' then
        hr_utility.set_message(8302,'PQH_GSP_PT_LE_ERR');
        hr_multi_message.add;
    else
       null;
    end if;

    --
    -- check values in crset.
    --
    validate_crset_values(p_copy_entity_txn_id => p_copy_entity_txn_id,
                          p_effective_date     => p_effective_date);
    --
    --
    if g_debug then
        hr_utility.set_location('Check FR PS Corps Review Submit Validatsons...', 87);
    end if;

     -- Adde a call for FR Corps.
     pqh_corps_utility.review_submit_valid_corps(p_copy_entity_txn_id => p_copy_entity_txn_id
                                                ,p_effective_date    => p_effective_date
                                                ,p_business_group_id => p_business_group_id
                                                ,p_status            => l_error_status);


    -- Call to raise any errors on multi-message list
     hr_multi_message.end_validation_set;

     p_status := l_status;
if g_debug then
     hr_utility.set_location('Leaving :' ||l_proc, 200);
end if;
Exception

  when hr_multi_message.error_message_exist then
     p_status := null;
if g_debug then
     hr_utility.set_location('Error  :' ||substr(sqlerrm,1,50), 240);
     hr_utility.set_location('Leaving:' || l_proc, 300);
end if;
  when others then
     p_status := null;

END chk_review_submit_val;


--
--
Function get_which_rates (p_copy_entity_txn_id	in Number) Return Varchar2 is
cursor c1 is
  select 1 from dual where exists (
   select 1
   FROM BEN_COPY_ENTITY_RESULTS
   WHERE NVL(INFORMATION104,'PPP') NOT IN ('UNLINK')
   AND TABLE_ALIAS ='COP'
   AND copy_entity_txn_id =  p_copy_entity_txn_id
   AND result_type_cd = 'DISPLAY'
   AND gs_parent_entity_result_id is not null);

cnt number;
l_use_point_or_step varchar2(20);
l_copy_entity_txn_id number;
l_get_which_rates varchar2(20);
l_proc varchar2(72) := g_package||'.get_which_rates';
begin
   l_use_point_or_step := use_point_or_step(p_copy_entity_txn_id);
    open c1;
   fetch c1 into cnt;
      if (c1%NOTFOUND) then
      l_get_which_rates := 'GRADE';
   else
      l_get_which_rates := l_use_point_or_step;
   end if;
   close c1;
   return l_get_which_rates;
EXCEPTION
   WHEN others THEN
      if g_debug then
        hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
      end if;
      return l_get_which_rates;
end get_which_rates;

Function get_rates_icon_enabled (p_copy_entity_txn_id	in Number,
 p_copy_entity_result_id in Number,
 p_rate_hgrid_node      in varchar2)
Return Varchar2 is
l_get_which_rates varchar2(20) := get_which_rates(p_copy_entity_txn_id);
l_icon varchar2(20) := 'NONE';
cnt number := 0;
cursor c1 is
select 1 from dual where exists (
select 1 from ben_copy_entity_results
	where copy_entity_txn_id = p_copy_entity_txn_id
	and gs_parent_entity_result_id = p_copy_entity_result_id);
l_proc varchar2(72) := g_package||'.get_rates_icon_enabled';
begin
if g_debug then
hr_utility.set_location('Entering '||l_proc, 5);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id, 10);
hr_utility.set_location('p_copy_entity_result_id '||p_copy_entity_result_id, 15);
hr_utility.set_location('p_rate_hgrid_node '||p_rate_hgrid_node, 20);
hr_utility.set_location('l_get_which_rates :'||l_get_which_rates, 25);
end if;

if (p_rate_hgrid_node = 'PGM') then
  if (l_get_which_rates = 'POINT') then
	l_icon := 'NONE';
  else
        open c1;
    	fetch c1 into cnt;
    	if (c1%NOTFOUND) then
		l_icon := 'DISABLED';
        else
	  	l_icon := 'ENABLED';
  	end if;
	close c1;
  end if;
elsif (p_rate_hgrid_node = 'CPP') then
  if (l_get_which_rates = 'POINT') then

        open c1;
        fetch c1 into cnt;
    	if (c1%NOTFOUND) then
		l_icon := 'DISABLED';
        else
		l_icon := 'ENABLED';
	end if;
       close c1;
  else
  	l_icon := 'NONE';
  end if;
else
l_icon := 'NONE';
end if;

if g_debug then
hr_utility.set_location('Successfull completion '||l_proc, 5);
end if;
return l_icon;

EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
end get_rates_icon_enabled;
--
-- Function to return the annualization factor for frequency codes used in Benefits.
--
Function pgm_freq_annual_factor
         (p_ref_perd_cd   in varchar2) return number  is
 --
 -- Local variable declaration
 --
 l_ret_cd   NUMBER;
 --
BEGIN
  --
  IF p_ref_perd_cd = 'PWK' THEN
    l_ret_cd := 52;
  ELSIF p_ref_perd_cd = 'BWK' THEN
    l_ret_cd := 26;
  ELSIF p_ref_perd_cd = 'SMO' THEN
    l_ret_cd := 24;
  ELSIF p_ref_perd_cd = 'PQU' THEN
    l_ret_cd := 4;
  ELSIF p_ref_perd_cd = 'PYR' THEN
    l_ret_cd := 1;
  ELSIF p_ref_perd_cd = 'SAN' THEN
    l_ret_cd := 2;
  ELSIF p_ref_perd_cd = 'MO' THEN
    l_ret_cd := 12;
  ELSIF p_ref_perd_cd = 'NOVAL' THEN
    l_ret_cd := 1;
  ELSIF p_ref_perd_cd = 'PHR' then
    --
    l_ret_cd := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
    if l_ret_cd is null then
      l_ret_cd := 2080;
    end if;
    --
  ELSE
    l_ret_cd := 1;
  END IF;
  --
  RETURN l_ret_cd;
 END pgm_freq_annual_factor;
--
-- Create Pay Rate for a Pay Scale
--
Procedure create_pay_rate (p_business_group_id  in number,
                         p_scale_id          in number,
                         p_rate_name         in varchar2,
                         p_rate_id           Out nocopy number,
                         p_ovn               Out nocopy number)
is
--
-- Local variables
--
l_rate_id  pay_rates.rate_id%type;
l_ovn      pay_rates.object_version_number%type;
l_proc     varchar2(100) := 'pqh_gsp_utility.create_pay_rate';
--
Begin
 --
 if g_debug then
hr_utility.set_location('Entering :'||l_proc, 5);
end if;

hr_rate_api.create_rate
  (p_validate                      => false
  ,p_effective_date                => trunc(sysdate)
  ,p_business_group_id             => p_business_group_id
  ,p_name                          => p_rate_name
  ,p_parent_spine_id               => p_scale_id
  ,p_rate_type                     => 'SP'
  ,p_rate_uom                      => 'M'
  ,p_object_version_number         => l_ovn
  ,p_rate_id                       => l_rate_id);
  --
  --
  p_rate_id := l_rate_id;
  p_ovn := l_ovn;
  --
  if g_debug then
hr_utility.set_location('Leaving :'||l_proc, 5);
end if;
  --
End;
--
-- Create Pay Rate for Grade Rates
--
Procedure create_pay_rate(p_business_group_id  in number,
                          p_ldr_period_code    in varchar2,
                          p_rate_id           Out nocopy number,
                          p_ovn               Out nocopy number)
is
--
-- Local variables
--
l_rate_id  pay_rates.rate_id%type;
l_ovn      pay_rates.object_version_number%type;
l_proc     varchar2(100) := 'pqh_gsp_utility.create_pay_rate';
--
Begin
 --
if g_debug then
hr_utility.set_location('Entering :'||l_proc, 5);
end if;

hr_rate_api.create_rate
  (p_validate                      => false
  ,p_effective_date                => trunc(sysdate)
  ,p_business_group_id             => p_business_group_id
  ,p_name                          => hr_general.decode_lookup('PQH_GSP_GEN_PAY_RATE_NAME',p_ldr_period_code)
  ,p_rate_type                     => 'G'
  ,p_rate_uom                      => 'M'
  ,p_object_version_number         => l_ovn
  ,p_rate_id                       => l_rate_id);
  --
  --
  p_rate_id := l_rate_id;
  p_ovn := l_ovn;
  --
if g_debug then
hr_utility.set_location('Leaving :'||l_proc, 5);
end if;
  --
End;
--
procedure step_exists_for_point(p_copy_entity_txn_id in number,
    p_points_result_id in number,
    p_status out nocopy varchar)
is
cursor csr_steps_for_point
is
select null
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and information262 = p_points_result_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information104 = 'LINK';
l_steps_for_point NUMBER;
begin
open csr_steps_for_point;
fetch csr_steps_for_point into l_steps_for_point;
if(csr_steps_for_point%NOTFOUND) then
p_status := 'N';
else
p_status := 'Y';
end if;
close csr_steps_for_point;
end step_exists_for_point;
--
procedure chk_scale_name(p_copy_entity_txn_id in number,
   p_business_group_id in number,
   p_copy_entity_result_id in number,
   p_parent_spine_id in number,
   p_name in varchar,
   p_status out nocopy varchar)
is
cursor csr_scale_name
is
select null
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and copy_entity_result_id <> p_copy_entity_result_id
and information98 = p_name
and table_alias = 'SCALE'
union
select null
from per_parent_spines
where name = p_name
and business_group_id = p_business_group_id
and parent_spine_id <> p_parent_spine_id;

Cursor plip_details
is
select information98,copy_entity_result_id,dml_operation
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'CPP'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information258 = p_copy_entity_result_id;
l_scale_name varchar2(30);
begin
open csr_scale_name;
fetch csr_scale_name into l_scale_name;
if(csr_scale_name%NOTFOUND) then
p_status := 'Y';
for i in plip_details loop
if i.information98<>p_name THEN
        update ben_copy_entity_results
        set information98         = p_name,
             dml_operation        =  get_dml_operation(i.dml_operation)
      where copy_entity_result_id = i.copy_entity_result_id;

END IF;
end loop;
else
p_status :='E';
end if;
close csr_scale_name;
end chk_scale_name;
--
-----IS_CRRATE_THERE_ICON--------------------
Function is_crrate_there_icon
(p_copy_entity_txn_id	in Number,
 p_copy_entity_result_id in Number,
 p_effective_date_in     in date,
 p_rate_hgrid_node      in varchar2)
Return Varchar2 is
l_proc varchar2(72) := g_package||'.is_crrate_there_icon';
l_get_which_rates varchar2(20) := get_which_rates(p_copy_entity_txn_id);
l_crrate_icon varchar2(50);
l_effective_date date;
begin
select action_date into l_effective_date from pqh_copy_entity_txns
where copy_entity_txn_id = p_copy_entity_txn_id;
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
end if;
if ((p_rate_hgrid_node = 'CPP') and (l_get_which_rates = 'GRADE')) then
l_crrate_icon := pqh_gsp_hr_to_stage.is_crrate_there(p_plip_cer_id        => p_copy_entity_result_id,
                                                  p_copy_entity_txn_id    => p_copy_entity_txn_id,
                                                  p_effective_date        => l_effective_date);
elsif ((p_rate_hgrid_node = 'COP') and ((l_get_which_rates = 'POINT') or (l_get_which_rates = 'STEP'))) then
l_crrate_icon := pqh_gsp_hr_to_stage.is_crrate_there(p_oipl_cer_id        => p_copy_entity_result_id,
                                                  p_copy_entity_txn_id    => p_copy_entity_txn_id,
                                                  p_effective_date        => l_effective_date);
else
l_crrate_icon := 'XYZ';
end if;

if g_debug then
  hr_utility.set_location('Successfull Completion '||l_proc,5);
end if;
return l_crrate_icon;

EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
raise;
end;


------------------------------------------------------

Function PGM_TO_BASIS_CONVERSION
(P_Pgm_ID               IN Number
,P_EFFECTIVE_DATE       IN Date
,P_AMOUNT               IN Number
,P_ASSIGNMENT_ID        IN Number)

Return Number Is

 CURSOR C_Pgm_rt_Perd IS
 Select Pgm.ACTY_REF_PERD_CD,
        Nvl(Cur.Precision,2),
        Update_Salary_Cd
  From  Ben_Pgm_f Pgm,
        Fnd_Currencies Cur
  Where Pgm.Pgm_id = P_Pgm_Id
    and P_Effective_Date
Between Pgm.Effective_Start_Date
    and Pgm.Effective_End_Date
    and Cur.Currency_Code(+) = Pgm.Pgm_Uom;

 CURSOR C_Pay_Basis IS
 select Ppb.Pay_Annualization_Factor,Ppb.Pay_basis
   From Per_All_Assignments_f asg,
        Per_Pay_Bases ppb
  where Asg.Assignment_id = P_Assignment_Id
    and P_effective_date
between Asg.Effective_Start_Date
    and Asg.Effective_End_Date
    and Ppb.Pay_Basis_Id = Asg.Pay_Basis_Id;

l_ref_perd_cd              Ben_Pgm_F.ACTY_REF_PERD_CD%TYPE;
l_precision                Fnd_Currencies.Precision%TYPE;
l_factor                   Per_Pay_Bases.Pay_Annualization_Factor%TYPE;
l_ret_amount               Number;
l_pay_annualization_factor Per_Pay_Bases.Pay_Annualization_Factor%TYPE;
l_update_Salary_cd         Ben_Pgm_F.Update_Salary_Cd%TYPE;
L_Payroll_name             pay_all_payrolls_f.Payroll_name%TYPE;
l_pay_basis                Per_Pay_Bases.Pay_basis%TYPE;
l_gl_ann_factor		   ben_pgm_extra_info.pgi_information5%TYPE;

Begin

  if g_debug then
    hr_utility.set_location('Entering PGM_TO_BASIS_CONVERSION', 5);
    hr_utility.set_location(' Parameters passed are as follows: ',6);
    hr_utility.set_location('P_Pgm_ID             '||P_Pgm_ID         ,6);
    hr_utility.set_location('P_EFFECTIVE_DATE     '||P_EFFECTIVE_DATE ,6);
    hr_utility.set_location('P_AMOUNT             '||P_AMOUNT         ,6);
    hr_utility.set_location('P_ASSIGNMENT_ID      '||P_ASSIGNMENT_ID  ,6);
  end if;

 OPEN  C_Pgm_rt_Perd;
FETCH C_Pgm_rt_Perd into l_ref_perd_cd,l_precision, l_Update_Salary_cd;
   IF C_Pgm_rt_Perd%NOTFOUND THEN
      l_ref_perd_cd := 'NOVAL';
  END IF;
CLOSE C_Pgm_rt_Perd;
  --

  --
If L_Update_Salary_Cd = 'SALARY_BASIS' Then

   OPEN c_pay_basis;
   FETCH c_pay_basis into l_factor,l_pay_basis;
   CLOSE C_Pay_Basis;

   l_gl_ann_factor := pqh_gsp_utility.get_gl_ann_factor(p_pgm_id => p_pgm_id);

   if l_gl_ann_factor  is not null then
        l_ret_amount := (p_amount*to_number(l_gl_ann_factor))/l_factor;
        return l_ret_amount;
   end if;


/*  To fix bug 4907433
 *  If the Grade Ladder frequency and the Salary Basis frequency are matching then
 *  Return the amount without any calculations
 */

   IF (l_pay_basis = 'MONTHLY' AND l_ref_perd_cd = 'MO')
   OR (l_pay_basis = 'HOURLY' AND l_ref_perd_cd = 'PHR')
   OR (l_pay_basis = 'ANNUAL' AND l_ref_perd_cd = 'PYR') THEN

  if g_debug then
  hr_utility.set_location('Salary basis frequency and Grade Ladder frequency matches', 15);
  hr_utility.set_location('So returning the Grade/Step rate as it is', 25);
  end if;

    -- RETURN trunc(p_amount,l_precision); -- Bug 6608606
   RETURN p_amount;

    END IF;

-- Bug Fix  4907433 ends

Elsif L_Update_Salary_Cd = 'SALARY_ELEMENT' Then

     per_pay_proposals_populate.get_payroll(P_Assignment_Id
                                           ,P_Effective_Date
                                           ,l_Payroll_name
                                           ,l_factor);
Else
  Return P_Amount;
End If;

IF l_factor is null or l_factor=0 THEN
   l_factor := 1;
END IF;

IF l_ref_perd_cd = 'PWK' THEN
   l_ret_amount := (p_amount*52)/l_factor;
ELSIF l_ref_perd_cd = 'BWK' THEN
   l_ret_amount := (p_amount*26)/l_factor;
ELSIF l_ref_perd_cd = 'SMO' THEN
   l_ret_amount := (p_amount*24)/l_factor;
ELSIF l_ref_perd_cd = 'PQU' THEN
   l_ret_amount := (p_amount*4)/l_factor;
ELSIF l_ref_perd_cd = 'PYR' THEN
   l_ret_amount := (p_amount*1)/l_factor;
ELSIF l_ref_perd_cd = 'SAN' THEN
   l_ret_amount := (p_amount*2)/l_factor;
ELSIF l_ref_perd_cd = 'MO' THEN
   l_ret_amount := (p_amount*12)/l_factor;
ELSIF l_ref_perd_cd = 'NOVAL' THEN
   l_ret_amount := (p_amount*1)/l_factor;
ELSIF l_ref_perd_cd = 'PHR' then

   l_pay_annualization_factor := to_number(fnd_profile.value('BEN_HRLY_ANAL_FCTR'));
   If l_pay_annualization_factor is null then
      l_pay_annualization_factor := 2080;
   End if;
 --
   l_ret_amount := (p_amount * l_pay_annualization_factor)/l_factor;
 --
ELSE
   l_ret_amount := (p_amount*1)/l_factor;
END IF;
  --
-- RETURN trunc(l_ret_amount,l_precision);   -- Bug 6608606
RETURN l_ret_amount;

End PGM_TO_BASIS_CONVERSION;

----------------------------------------------------------------------------------------------------

Function get_num_steps_in_grade(p_copy_entity_txn_id in number,
                                p_grade_cer_id in number)
Return Number is

cursor csr_steps_in_grade
is
select count(*) cnt
from ben_copy_entity_results
where table_alias = 'COP'
and copy_entity_txn_id = p_copy_entity_txn_id
and gs_parent_entity_result_id in
(select gs_mirror_src_entity_result_id
 from ben_copy_entity_results
 where table_alias = 'PLN' and copy_entity_txn_id = p_copy_entity_txn_id
 and nvl(result_type_cd,'DISPLAY') = 'DISPLAY' and copy_entity_result_id = p_grade_cer_id)
And    result_type_cd = 'DISPLAY'
And    Nvl(Information104,'PPP') <> 'UNLINK';

l_proc varchar2(72) := g_package||'.get_num_steps_in_grade';

step_cnt number;
begin
if g_debug then
  hr_utility.set_location('Entering  '||l_proc, 5);
end if;
for steps in csr_steps_in_grade loop
step_cnt := steps.cnt;
end loop;
if g_debug then
  hr_utility.set_location('Successfull completion  '||l_proc, 5);
end if;
return step_cnt;
EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
end get_num_steps_in_grade;

Function get_dflt_point_rate (p_copy_entity_txn_id  in number,
                               p_point_cer_id        in number,
                               p_effective_date      in date)
RETURN NUMBER
is
--
-- Local variables
--
Cursor csr_dflt_point_rate is
Select information297
 From ben_copy_entity_results
Where copy_entity_txn_id = p_copy_entity_txn_id
and INFORMATION278 = p_point_cer_id
and p_effective_date between information2 and information3
and table_alias = 'HRRATE'
and result_type_cd = 'DISPLAY';
--
l_point_rate number;
l_proc       varchar2(100) := 'pqh_gsp_utility.get_dflt_point_rate';
--
Begin
 --
if g_debug then
  hr_utility.set_location('Entering :'||l_proc, 5);
end if;
--
l_point_rate := 0;

Open csr_dflt_point_rate;
Fetch csr_dflt_point_rate into l_point_rate;
Close csr_dflt_point_rate;
--
if g_debug then
  hr_utility.set_location('Leaving :'||l_proc, 5);
end if;
--
Return l_point_rate;
--
End;

--

-- Added by vevenkat for Approval UI ----
--
--

Function Get_person_name (P_Person_id      IN Number,
                          P_Effective_Date IN  Date)
Return varchar2 is

 Cursor Csr_Person is
 Select Full_name
   From Per_All_people_F
  Where Person_id = P_Person_id
    and Nvl(P_Effective_Date, Sysdate)
Between Effective_Start_Date
    and Effective_End_Date;

L_Person_name per_All_people_F.Full_name%TYPE;
Begin

If P_Person_id is NOT NULL then

    Open Csr_Person;
   Fetch Csr_Person into L_Person_name;
   Close Csr_Person;

End If;

Return l_Person_Name;
End Get_Person_Name;

Function Get_Assgt_Status (P_Assgt_Status_Id IN Number)
Return varchar2 Is

Cursor Csr_Assgt_status is
Select User_Status
  From PER_ASSIGNMENT_STATUS_TYPES_TL
 where Assignment_Status_Type_Id = P_Assgt_Status_Id
   and language = userenv('LANG');

 L_User_Status  PER_ASSIGNMENT_STATUS_TYPES_TL.User_Status%TYPE;
begin

If P_Assgt_Status_Id is NOT NULL then
    Open Csr_Assgt_Status;
   Fetch Csr_Assgt_Status into l_User_Status;
   Close Csr_Assgt_Status;
End If;

Return L_USer_Status;
End Get_Assgt_Status;
-------------------------------------------------------------------
Procedure check_sal_basis_iv (p_input_value_id    in number,
                              p_basis_id          in number,
                              p_business_group_id in number,
                              p_exists_flag       Out nocopy varchar2)
is
--
-- Local variables
--
Cursor csr_sal_basis_iv is
Select 'x'
From per_pay_bases
where business_group_id = p_business_group_id
and rate_id is null
and input_value_id = p_input_value_id
and pay_basis_id <> p_basis_id;
--
l_dummy      varchar2(20);
l_proc       varchar2(100) := 'pqh_gsp_utility.check_sal_basis_iv';
--
Begin
 --
p_exists_flag := 'N';
if g_debug then
  hr_utility.set_location('Entering :'||l_proc, 5);
end if;
--
Open csr_sal_basis_iv;
Fetch csr_sal_basis_iv into l_dummy ;
If csr_sal_basis_iv%found then
   p_exists_flag := 'Y';
End if;
Close csr_sal_basis_iv;
--
if g_debug then
  hr_utility.set_location('Leaving :'||l_proc, 5);
end if;
--
End;

-------------------------------------------------------------------
procedure update_oipl_records(
                    p_effective_date          IN DATE,
                    p_copy_entity_result_id   IN ben_copy_entity_results.copy_entity_result_id%TYPE,
                    p_point_name            IN ben_copy_entity_results.information99%TYPE,
                    p_sequence              IN ben_copy_entity_results.information263%TYPE,
                    p_copy_entity_txn_id IN ben_copy_entity_results.copy_entity_txn_id%TYPE
                    )
IS


cursor csr_oipl_records
is
select copy_entity_result_id,object_version_number,dml_operation
from ben_copy_entity_results
where table_alias = 'COP'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information262 = p_copy_entity_result_id
and copy_entity_txn_id = p_copy_entity_txn_id;
r_oipl_record csr_oipl_records%ROWTYPE;
l_ovn NUMBER;
begin
for r_oipl_record in csr_oipl_records loop

l_ovn := r_oipl_record.object_version_number;
                    ben_copy_entity_results_api.update_copy_entity_results(
                     p_effective_date          => p_effective_date,
                     p_copy_entity_result_id   => r_oipl_record.copy_entity_result_id,
                     p_information99           => p_point_name,
                     p_information263          => p_sequence,
                     p_information323          => null,
                     p_dml_operation 		=>get_dml_operation(r_oipl_record.dml_operation),
                     p_object_version_number          => l_ovn
                    );
end loop;
end;
--
--
---------------------------move_data_stage_to_hr-----------------------------
--
Procedure move_data_stage_to_hr
(p_copy_entity_txn_id     in   Number,
 p_effective_date         in   Date,
 p_business_area          in   varchar2 default 'PQH_GSP_TASK_LIST',
 p_business_group_id      in   Number,
 p_datetrack_mode         in   Varchar2,
 p_error_msg              out  Nocopy Varchar2
) IS

l_proc   varchar2(72) := g_package||'move_data_stage_to_hr';
l_msg    varchar2(2000):= null;


Begin
  --
  -- Issue Savepoint
  savepoint move_data_stage_to_hr;
  --
  --
  -- Initialise Multiple Message Detection
  --
   hr_multi_message.enable_message_list;

if g_debug then
  hr_utility.set_location('Entering '||l_proc,100);
  hr_utility.set_location('p_copy_entity_txn_id :'||p_copy_entity_txn_id,20);
  hr_utility.set_location('p_effective_date     :'||p_effective_date ,30);
  hr_utility.set_location('p_business_group_id  :'||p_business_group_id ,40);
  hr_utility.set_location('p_datetrack_mode     :'||p_datetrack_mode,50);
end if;

pqh_gsp_stage_to_hr.gsp_data_push(p_copy_entity_txn_id => p_copy_entity_txn_id,
                        p_effective_date               => p_effective_date,
                        p_business_group_id            => p_business_group_id,
                        p_business_area                => p_business_area,
                        p_datetrack_mode               => p_datetrack_mode);
if g_debug then
  hr_utility.set_location('Leaving '||l_proc,100);
end if;

   --
   --
   -- Call to raise any errors on multi-message list
      hr_multi_message.end_validation_set;
  -- p_error_msg  := l_msg;

EXCEPTION
     when hr_api.validate_enabled then
           Rollback to move_data_stage_to_hr;
           null;
     when hr_multi_message.error_message_exist then
           Rollback to move_data_stage_to_hr;
           null;
     when others then
           l_msg := nvl(fnd_message.get,sqlerrm);
           p_error_msg  := l_msg;
           Rollback to move_data_stage_to_hr;
End move_data_stage_to_hr;

--
------------------ get_grade_name ----------------------------
--
--

PROCEDURE GET_GRADE_NAME (
p_grade_definition_id IN NUMBER,
p_business_group_id  IN NUMBER,
p_concatenated_segments OUT NOCOPY varchar2)
IS
CURSOR csr_segments
IS
select segment1,
segment2,
segment3,
segment4,
segment5,
segment6,
segment7,
segment8,
segment9,
segment10,
segment11,
segment12,
segment13,
segment14,
segment15,
segment16,
segment17,
segment18,
segment19,
segment20,
segment21,
segment22,
segment23,
segment24,
segment25,
segment26,
segment27,
segment28,
segment29,
segment30
from per_grade_definitions
where grade_definition_id = p_grade_definition_id;
segments csr_segments%ROWTYPE;
l_ccid number;
l_flex_num number;

BEGIN

open 	csr_segments;
fetch	csr_segments INTO segments;
close 	csr_segments;

select grade_structure into l_flex_num
from per_business_groups_perf
where business_group_id =p_business_group_id;

hr_kflex_utility.ins_or_sel_keyflex_comb
  (p_appl_short_name               => 'PER'
  ,p_flex_code                     => 'GRD'
  ,p_flex_num                      => l_flex_num
  ,p_segment1                       =>segments.segment1
  ,p_segment2                       =>segments.segment2
  ,p_segment3                       =>segments.segment3
  ,p_segment4                       =>segments.segment4
  ,p_segment5                       =>segments.segment5
  ,p_segment6                       =>segments.segment6
  ,p_segment7                       =>segments.segment7
  ,p_segment8                       =>segments.segment8
  ,p_segment9                       =>segments.segment9
  ,p_segment10                      =>segments.segment10
  ,p_segment11                      =>segments.segment11
  ,p_segment12                      =>segments.segment12
  ,p_segment13                      =>segments.segment13
  ,p_segment14                      =>segments.segment14
  ,p_segment15                      =>segments.segment15
  ,p_segment16                      =>segments.segment16
  ,p_segment17                      =>segments.segment17
  ,p_segment18                      =>segments.segment18
  ,p_segment19                      =>segments.segment19
  ,p_segment20                      =>segments.segment20
  ,p_segment21                      =>segments.segment21
  ,p_segment22                      =>segments.segment22
  ,p_segment23                      =>segments.segment23
  ,p_segment24                      =>segments.segment24
  ,p_segment25                      =>segments.segment25
  ,p_segment26                      =>segments.segment26
  ,p_segment27                      =>segments.segment27
  ,p_segment28                      =>segments.segment28
  ,p_segment29                      =>segments.segment29
  ,p_segment30                      =>segments.segment30
  ,p_ccid                          => l_ccid
  ,p_concat_segments_out           => p_concatenated_segments
  );
  hr_utility.set_location('cccid:'||l_ccid, 5);
  hr_utility.set_location('concatened segments:'||p_concatenated_segments,15);
END GET_GRADE_NAME;
---
--------- get_dml_operation -----------
--

FUNCTION GET_DML_OPERATION
(p_in_dml_operation IN ben_copy_entity_results.dml_operation%TYPE)
return VARCHAR2
is
p_out_dml_operation ben_copy_entity_results.dml_operation%TYPE;

begin
IF p_in_dml_operation = 'REUSE' THEN
  p_out_dml_operation := 'UPDATE';
ELSIF p_in_dml_operation = 'COPIED' THEN
  p_out_dml_operation := 'UPD_INS';
ELSE
  p_out_dml_operation := p_in_dml_operation;
END IF;


RETURN p_out_dml_operation;
END get_dml_operation;
--------------------------------------------------------------------------------
Procedure chk_no_asg_grd_ldr(p_asg_grade_ladder_id in number,
                             p_asg_grade_id        in number,
                             p_asg_org_id          in number,
                             p_asg_bg_id           in number,
                             p_effective_date      in date) IS
--
-- Declare cursor
--
cursor csr_chk_gsp_in_system is
select 'x'
from ben_pgm_f pgm
where pgm.business_group_id = p_asg_bg_id
and pgm.pgm_typ_cd = 'GSP'
and p_effective_date
between pgm.effective_start_date
and nvl(pgm.effective_end_date,to_date('31/12/4712','dd/mm/RRRR'));
--
l_exists varchar2(10);
--
Begin
--
-- if grade_id is enterd and grade_ladder is not entered,
-- need to check gsp is implemented in the system.
-- if the gsp is implemented, a warning message will be appear.
--
hr_utility.set_location('Entering chk_no_asg_grd_ldr', 5);
--
if p_asg_grade_id is not null and p_asg_grade_ladder_id is null then
open csr_chk_gsp_in_system;
fetch csr_chk_gsp_in_system into l_exists;
if csr_chk_gsp_in_system%FOUND then
close csr_chk_gsp_in_system;
--
-- This message is cofigurable(BUG3219215)
--
pqh_utility.set_message(800,'HR_289559_GRADE_LADDER_REQUIRE',p_asg_org_id);
pqh_utility.raise_error;
else
--
hr_utility.set_location('GSP not Implemented', 7);
--
close csr_chk_gsp_in_system;
end if;

end if;
--
--
hr_utility.set_location('Leaving chk_no_asg_grd_ldr', 10);
--
End chk_no_asg_grd_ldr;

FUNCTION  bus_area_pgm_entity_exist(p_bus_area_cd IN Varchar2,
                                    P_pgm_id IN NUMBER)
RETURN varchar2
IS
l_return  Varchar2(50);
BEGIN
    l_return := pqh_corps_utility.bus_area_pgm_entity_exist( p_bus_area_cd => p_bus_area_cd
                                                            ,P_pgm_id => P_pgm_id );
    RETURN l_return;
Return NULL;
END bus_area_pgm_entity_exist;
-----------------------------------------
---------- < chk_new_ceiling >-----------
--- < ggnanagu >-------------------------
   PROCEDURE chk_new_ceiling (
      p_effective_date   IN   DATE,
      p_grade_cer_id     IN   NUMBER,
      p_new_ceiling      IN   NUMBER
   )
   IS
/*
p_new_ceiling is the new ceiling sequence.
Throw error if there are placements above the New Ceiling sequence.
*/
      l_gspine_id   NUMBER;
      l_grade_id    NUMBER;

      CURSOR csr_grade_id
      IS
         SELECT information253
           FROM ben_copy_entity_results
          WHERE copy_entity_result_id = p_grade_cer_id
          and nvl(result_type_cd,'DISPLAY') = 'DISPLAY';

      CURSOR csr_gspine_id (p_grade_id IN NUMBER)
      IS
         SELECT grade_spine_id
           FROM per_grade_spines_f
          WHERE p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date
            AND grade_id = p_grade_id;
   BEGIN
      hr_multi_message.enable_message_list;
      hr_utility.set_location ('Inside chk_new_ceiling', 10);
      OPEN csr_grade_id;
      FETCH csr_grade_id INTO l_grade_id;
      CLOSE csr_grade_id;
      hr_utility.set_location ('Grade Id is :' || l_grade_id, 10);

      IF l_grade_id IS NOT NULL
      THEN
         hr_utility.set_location ('grade_id found ', 20);
         OPEN csr_gspine_id (l_grade_id);
         FETCH csr_gspine_id INTO l_gspine_id;

         IF csr_gspine_id%FOUND
         THEN
            hr_utility.set_location ('gspine_id found ' || l_gspine_id, 20);
            per_grade_spines_pkg.chk_low_ceiling (
               p_val_start      => p_effective_date,
               p_val_end        => p_effective_date,
               p_gspine_id      => l_gspine_id,
               p_new_ceil       => p_new_ceiling
            );
         END IF;
      END IF;

      -- Call to raise any errors on multi-message list
      hr_multi_message.end_validation_set;
      -- p_error_msg  := l_msg;
      hr_utility.set_location ('Leaving chk_new_ceiling', 90);
   EXCEPTION
      WHEN OTHERS
      THEN
fnd_msg_pub.add;
   END;


   PROCEDURE unlink_step_or_point (p_copy_entity_result_id IN NUMBER)
   IS
   BEGIN
      UPDATE ben_copy_entity_results
         SET information104 = 'UNLINK'
       WHERE copy_entity_result_id = p_copy_entity_result_id;
   END unlink_step_or_point;
--------------------------------------------------------------------------
   PROCEDURE chk_delete_option (
      p_copy_entity_txn_id   IN   NUMBER,
      p_opt_cer_id           IN   NUMBER,
      p_point_id             IN   NUMBER,
      p_opt_id               IN   NUMBER,
      p_pspine_id            IN   NUMBER,
      p_effective_date       IN   DATE
   )
   IS
      CURSOR csr_steps_for_point
      IS
         SELECT NULL
           FROM ben_copy_entity_results
          WHERE copy_entity_txn_id = p_copy_entity_txn_id
            AND information262 = p_opt_cer_id
          and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
            AND information104 = 'LINK';

      l_steps_for_point   NUMBER;
   BEGIN
      hr_multi_message.enable_message_list;
      hr_utility.set_location ('Inside Proc', 2);
      OPEN csr_steps_for_point;
      FETCH csr_steps_for_point INTO l_steps_for_point;

      IF (csr_steps_for_point%FOUND)
      THEN
         hr_utility.set_location ('Steps Error', 5);
         hr_utility.set_message (8302,'PER_7926_DEL_POINT_STEP');
         hr_utility.raise_error;
      END IF;

      hr_multi_message.end_validation_set;
hr_utility.set_location ('Leaving Proc', 2);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('Some errors', 20);
         fnd_msg_pub.ADD;
   END chk_delete_option;


---------------------------change_ceiling_step-----------------------------
--

      PROCEDURE change_ceiling_step (
         p_copy_entity_txn_id   IN   NUMBER,
         p_effective_date       IN   DATE,
         p_initial_ceiling_id   IN   NUMBER,
         p_final_ceiling_id     IN   NUMBER,
         p_grade_result_id      IN   NUMBER
      )
      IS
   /*
   Will throw error if there are employee placements above the new Ceiling Step.
   */
         CURSOR csr_init_step
         IS
            SELECT object_version_number, dml_operation
              FROM ben_copy_entity_results
             WHERE copy_entity_result_id = p_initial_ceiling_id;

         CURSOR csr_final_step
         IS
            SELECT object_version_number, dml_operation, information253,
                   information255, information263
              FROM ben_copy_entity_results
             WHERE copy_entity_result_id = p_final_ceiling_id;

         CURSOR csr_grade
         IS
            SELECT object_version_number, dml_operation
              FROM ben_copy_entity_results
             WHERE copy_entity_result_id = p_grade_result_id;

         l_initial_step        csr_init_step%ROWTYPE;
         l_final_step          csr_final_step%ROWTYPE;
         l_grade               csr_grade%ROWTYPE;
         l_final_step_cer_id   NUMBER;
         l_final_step_id       NUMBER;
         l_gspine_id           NUMBER;
      BEGIN
         hr_multi_message.enable_message_list;
         hr_utility.set_location ('Inside Proc..', 5);

         if p_initial_ceiling_id <> p_final_ceiling_id THEN
         OPEN csr_final_step;
         FETCH csr_final_step INTO l_final_step;

         IF csr_final_step%FOUND
         THEN
           l_gspine_id := l_final_step.information255;
            hr_utility.set_location (
               'Going to check for New Ceiling with the following..',
               15
            );
            hr_utility.set_location ('Going to check for New Ceiling..', 25);
            hr_utility.set_location ('Eff Date' || p_effective_date, 30);
            hr_utility.set_location (
               'gSpine id' || l_gspine_id,
               35
            );
            hr_utility.set_location (
               'New Ceiling Sequence' || l_final_step.information263,
               45
            );
           if l_gspine_id is not null THEN
            per_grade_spines_pkg.chk_low_ceiling (
               p_val_start      => p_effective_date,
               p_val_end        => p_effective_date,
               p_gspine_id      => l_gspine_id,
               p_new_ceil       => l_final_step.information263
            );
            END IF;
            ben_copy_entity_results_api.update_copy_entity_results (
               p_copy_entity_result_id      => p_final_ceiling_id,
               p_effective_date             => p_effective_date,
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_information98              => 'Y',
               p_object_version_number      => l_final_step.object_version_number,
               p_information323             => NULL,
               p_dml_operation              => get_dml_operation (
                                                  l_final_step.dml_operation
                                               )
            );
            l_final_step_cer_id := p_final_ceiling_id;
            l_final_step_id := l_final_step.information253;
         ELSE
            l_final_step_id := NULL;
            l_final_step_cer_id := NULL;
         END IF;

         CLOSE csr_final_step;
         OPEN csr_init_step;
         FETCH csr_init_step INTO l_initial_step;

         IF (csr_init_step%FOUND)
         THEN
            ben_copy_entity_results_api.update_copy_entity_results (
               p_copy_entity_result_id      => p_initial_ceiling_id,
               p_effective_date             => p_effective_date,
               p_copy_entity_txn_id         => p_copy_entity_txn_id,
               p_information98              => 'N',
               p_object_version_number      => l_initial_step.object_version_number,
               p_dml_operation              => get_dml_operation (
                                                  l_initial_step.dml_operation
                                               ),
               p_information323             => NULL
            );
         END IF;

         CLOSE csr_init_step;
         OPEN csr_grade;
         FETCH csr_grade INTO l_grade;
         CLOSE csr_grade;
         ben_copy_entity_results_api.update_copy_entity_results (
            p_copy_entity_result_id      => p_grade_result_id,
            p_effective_date             => p_effective_date,
            p_copy_entity_txn_id         => p_copy_entity_txn_id,
            p_information103             => 'Y',
            p_information262             => l_final_step_cer_id,
            p_information259             => l_final_step_id,
            p_object_version_number      => l_grade.object_version_number,
            p_information323             => NULL,
            p_dml_operation              => get_dml_operation (
                                               l_grade.dml_operation
                                            )
         );
         END IF;
         -- Call to raise any errors on multi-message list
         hr_multi_message.end_validation_set;
      -- p_error_msg  := l_msg;
      EXCEPTION
         WHEN OTHERS
         THEN
            fnd_msg_pub.ADD;
      END change_ceiling_step;

---
------------CHK_STEPS_IN_GRADE ---
--ggnanagu
 PROCEDURE chk_steps_in_grade (
      p_copy_entity_txn_id   IN              NUMBER,
      p_grade_result_id      IN              NUMBER,
      p_status               OUT NOCOPY      VARCHAR2
   )
   IS
      /*
will return N if there are no steps attached
will return Y if there are steps
Will throw an Error if there are Employee placements..
*/
      CURSOR csr_steps_in_grade
      IS
         SELECT NULL
           FROM ben_copy_entity_results
          WHERE table_alias = 'COP'
            AND copy_entity_txn_id = p_copy_entity_txn_id
            AND gs_parent_entity_result_id = p_grade_result_id
            AND result_type_cd = 'DISPLAY'
            AND NVL (information104, 'PPP') <> 'UNLINK';

      CURSOR csr_grade_scale_dets
      IS
         SELECT information253, information255
           FROM ben_copy_entity_results
          WHERE copy_entity_result_id = p_grade_result_id;


        cursor c1(p_pspine_id IN Number,
                   p_grd_id IN NUMBER,
                   p_effective_date IN DATE) is
        select 'x'
        from per_spinal_point_steps_f sps,
             per_grade_spines_f gs
        where gs.grade_spine_id = sps.grade_spine_id
        and gs.parent_spine_id = p_pspine_id
        and gs.grade_id = p_grd_id
        and exists
        (select null
         from per_spinal_point_placements_f sp
         where sp.step_id = sps.step_id
         and (p_effective_date between effective_start_date AND effective_end_date-1
         or effective_start_date >= p_effective_date ));


      --
      l_exists VARCHAR2(1);
      l_effdate DATE;
      l_steps_in_grade     NUMBER;
      l_grade_scale_dets   csr_grade_scale_dets%ROWTYPE;
   BEGIN
      hr_multi_message.enable_message_list;


    select action_date
    into l_effdate
    from pqh_copy_entity_txns
    where copy_entity_txn_id =    p_copy_entity_txn_id;



      OPEN csr_steps_in_grade;
      FETCH csr_steps_in_grade INTO l_steps_in_grade;

      IF (csr_steps_in_grade%FOUND)
      THEN
         p_status := 'Y';
         OPEN csr_grade_scale_dets;
         FETCH csr_grade_scale_dets INTO l_grade_scale_dets;

         IF csr_grade_scale_dets%FOUND
         THEN
            OPEN c1(p_pspine_id => l_grade_scale_dets.information255,
                   p_grd_id =>  l_grade_scale_dets.information253,
                   p_effective_date => l_effdate);

            fetch c1 into l_exists;
              IF c1%found THEN
                  hr_utility.set_message(801, 'PER_7933_DEL_GRDSPN_PLACE');
              close c1;
              hr_utility.raise_error;
             END IF;


/*            per_grade_spines_pkg.stb_del_validation (
               p_pspine_id      => l_grade_scale_dets.information255,
               p_grd_id         => l_grade_scale_dets.information253
            );*/
         END IF;

         CLOSE csr_grade_scale_dets;
      ELSE
         p_status := 'N';
      END IF;

      CLOSE csr_steps_in_grade;
      -- Call to raise any errors on multi-message list
      hr_multi_message.end_validation_set;
   -- p_error_msg  := l_msg;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_msg_pub.ADD;
   END chk_steps_in_grade;



--

Function get_dflt_salary_rate
(p_copy_entity_txn_id   in Number,
 p_copy_entity_result_id in Number,
 p_rate_hgrid_node      in varchar2)
Return Number is

l_proc varchar2(72) := g_package||'.get_dflt_salary_rate';

l_get_which_rates varchar2(20) := get_which_rates(p_copy_entity_txn_id);
dflt_sal_rate Number := null;


cursor grd_rates(l_action_dt in date) is
select copy_entity_txn_id, information297 from ben_copy_entity_results
where
copy_entity_txn_id = p_copy_entity_txn_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information277 in (
                select copy_entity_result_id
                from ben_copy_entity_results
                where table_alias ='PLN'
                and result_type_cd = 'DISPLAY'
                and gs_mirror_src_entity_result_id = p_copy_entity_result_id)
and table_alias = 'HRRATE' and l_action_dt
between nvl(information2, hr_general.start_of_time) and nvl(information3, hr_general.end_of_time);

    Cursor Csr_Action_Dt is
    Select Action_Date
      From Pqh_Copy_Entity_txns
     Where Copy_Entity_Txn_id = p_copy_entity_txn_id;

cursor point_cer is
select information262 from ben_copy_entity_results
where
copy_entity_txn_id = p_copy_entity_txn_id
and
copy_entity_result_id = p_copy_entity_result_id;

cursor pnt_rates(point_cer_id number,l_action_dt in date) is
select copy_entity_Txn_id, information297 from ben_copy_entity_results
where
copy_entity_txn_id = p_copy_entity_txn_id
and information278 = point_cer_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and table_alias = 'HRRATE' and l_action_dt

between nvl(information2, hr_general.start_of_time) and nvl(information3, hr_general.end_of_time);

l_point_cer_id number := -1;
l_action_date date;
cnt number := 0;
begin
if g_debug then
  hr_utility.set_location('Entering '||l_proc,5);
end if;

open csr_action_dt;
fetch csr_action_dt into l_action_date;
close csr_action_dt;

if ((p_rate_hgrid_node = 'CPP') and (l_get_which_rates = 'GRADE')) then
if g_debug then
  hr_utility.set_location('These are grade rates ',5);
end if;
        for each_pnt in grd_rates(l_action_date) loop
                dflt_sal_rate := each_pnt.information297;
        end loop;
elsif ((p_rate_hgrid_node = 'COP') and (l_get_which_rates = 'POINT')) then
if g_debug then
  hr_utility.set_location('These are point rates ',5);
end if;
        for each_pnt_cer_id in point_cer loop
                l_point_cer_id := each_pnt_cer_id.information262;
        end loop;

        for each_pnt in pnt_rates(l_point_cer_id,l_action_date) loop
                dflt_sal_rate := each_pnt.information297;
        end loop;

elsif ((p_rate_hgrid_node = 'COP') and (l_get_which_rates = 'STEP')) then
if g_debug then
  hr_utility.set_location('These are step rates '||l_proc,5);
end if;
        for each_pnt_cer_id in point_cer loop
                l_point_cer_id := each_pnt_cer_id.information262;
        end loop;

        for each_pnt in pnt_rates(l_point_cer_id,l_action_date) loop
                dflt_sal_rate := each_pnt.information297;
        end loop;
else
if g_debug then
  hr_utility.set_location('This node is not valid for dlft salary determination
'||l_proc,5);
end if;

        dflt_sal_rate := null;

end if;
if g_debug then
  hr_utility.set_location('Successfull Completion '||l_proc,5);
end if;
return dflt_sal_rate;

EXCEPTION WHEN others THEN
if g_debug then
  hr_utility.set_location('ERROR. Unhandled Exception occurred. ERROR in '||l_proc,5);
end if;
end get_dflt_salary_rate;

---------------------------------------------------------------------------
-----------------------< Update_frps_point_rate >--------------------------
---------------------------------------------------------------------------

procedure update_frps_point_rate(p_point_cer_id in number,
                              p_copy_entity_txn_id in number,
                              p_business_group_id in number,
                              p_salary_rate        in number,
                              p_gross_index        in number,
                              p_effective_date     in date
                              )
IS
l_salary_rate NUMBER;
BEGIN
if p_gross_index is null THEN
l_salary_rate := p_salary_rate;
ELSE
l_salary_rate := pqh_corps_utility.get_salary_rate(p_gross_index => p_gross_index,
                                                    p_effective_date =>p_effective_date,
                                                    p_copy_entity_txn_id => p_copy_entity_txn_id);
END IF;

pqh_gsp_hr_to_stage.update_frps_point_rate(p_point_cer_id  => p_point_cer_id,
                                 p_copy_entity_txn_id => p_copy_entity_txn_id,
                                 p_business_group_id  => p_business_group_id,
                                 p_point_value        => l_salary_rate,
                                 p_effective_date     => p_effective_date);
END update_frps_point_rate;

---------------------------------------------------------------------------------------------
-----------------------------< CHK_FROM_STEPS >----------------------------------------------
-------------------------------------------------------------------------------------------
Function chk_from_steps(p_parent_spine_id IN per_parent_spines.parent_spine_id%TYPE)
RETURN VARCHAR2
IS
l_status varchar2(1) := 'N';
cursor csr_grade_id
is
select grade_id
from per_grade_spines_f
where parent_spine_id = p_parent_spine_id;
Cursor Csr_Plan_id (p_grade_id IN NUMBER)
is
select pl_id
from ben_pl_f
where mapping_table_pk_id = p_grade_id
and mapping_table_name  = 'PER_GRADES';
Cursor Csr_Pgm_id (p_pl_id IN NUMBER)
is
select pgm_id
from ben_plip_f
where pl_id = p_pl_id;
Cursor Csr_Use_Points(p_pgm_id IN NUMBER)
is
select USE_PROG_POINTS_FLAG
from ben_pgm_f
where pgm_id = p_pgm_id;
begin
if g_debug then
hr_utility.set_location('Entering chk_from_steps : ',10);
end if;
for rec_grade_id in csr_grade_id
loop
if g_debug then
    hr_utility.set_location('Fetched the Grade Id : '||rec_grade_id.grade_id,20);
end if;
    for rec_plan_id in csr_plan_id(rec_grade_id.grade_id)
    loop
	if g_debug then
        hr_utility.set_location('Fetched the Plan Id : '||rec_plan_id.pl_id,30);
    end if;
        for rec_pgm_id in csr_pgm_id(rec_plan_id.pl_id)
        loop
    if g_debug then
            hr_utility.set_location('Fetched the Pgm Id : '||rec_pgm_id.pgm_id,40);
    end if;
            for rec_use_points IN csr_use_points(rec_pgm_id.pgm_id)
            loop
    if g_debug then
            hr_utility.set_location('Fetched the Flag : '||rec_use_points.use_prog_points_flag,50);
    end if;
                if rec_use_points.use_prog_points_flag = 'N' THEN
                l_status := 'Y';
    if g_debug then
                hr_utility.set_location('Changing the Status to : '||l_status,60);
    end if;
                END IF;
            end loop;
         end loop;
     end loop;
end loop;
hr_utility.set_location('Returning the Status as : '||l_status,90);
Return l_status;
Exception when others then
hr_utility.set_location('Error and returning : '||l_status,90);
 return 'N';
END chk_from_steps;

function check_crset(p_crset_type in VARCHAR2,p_crset_id IN NUMBER,p_copy_entity_txn_id IN NUMBER,p_scale_cer_id in number)
return varchar2
IS
Cursor csr_is_steps
Is
select information18
from ben_copy_entity_results
where table_alias = 'PGM'
and copy_entity_txn_id = p_copy_entity_txn_id
and result_type_cd = 'DISPLAY';
Cursor csr_crrate
is
select null
from ben_copy_entity_results
where information160 = p_crset_id
and table_alias = 'CRRATE'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and copy_entity_txn_id = p_copy_entity_txn_id
and information169 in
(select copy_entity_result_id
from ben_copy_entity_results
where table_alias = 'OPT'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and information256 = p_scale_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id);
l_crrate csr_crrate%ROWTYPE;
l_is_steps csr_is_steps%ROWTYPE;
begin
    OPEN  csr_is_steps;
    FETCH Csr_is_steps into l_is_steps;
    if l_is_steps.information18 = 'N' THEN
    close csr_is_steps;
    RETURN 'Y';
    END IF;
if p_crset_type <> 'POINT' then
return 'Y';
else
   open csr_crrate;
   fetch csr_crrate into l_crrate;
   if(csr_crrate%NOTFOUND)then
   return 'N';
   else
   return 'Y';
   end if;
   close csr_crrate;
end if;
end check_crset;

procedure change_scale_name(p_copy_entity_txn_id in number,p_pl_cer_id in number,p_short_name in varchar2)
is
Cursor csr_is_steps
Is
select information18
from ben_copy_entity_results
where table_alias = 'PGM'
and copy_entity_txn_id = p_copy_entity_txn_id
and result_type_cd = 'DISPLAY';

Cursor csr_plan_dtls
Is
select Gs_Mirror_Src_Entity_Result_Id,object_version_number
from ben_copy_entity_results
where copy_entity_result_id = p_pl_cer_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'PLN';

Cursor csr_plip_dtls(p_plip_cer_id in number)
Is
select information258,copy_entity_result_id,dml_operation
from ben_copy_entity_results
where table_alias = 'CPP'
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and copy_entity_txn_id = p_copy_entity_txn_id
and copy_entity_result_id = p_plip_cer_id;

Cursor csr_scale_dtls(p_scale_cer_id in number)
Is
Select Information98,copy_entity_result_id,dml_operation
from ben_copy_entity_results
where copy_entity_result_id = p_scale_cer_id
and table_alias = 'SCALE'
and copy_entity_txn_id = p_copy_entity_txn_id;

l_plan_dtls csr_plan_dtls%ROWTYPE;
l_plip_dtls csr_plip_dtls%ROWTYPE;
l_scale_dtls csr_scale_dtls%ROWTYPE;
l_is_steps csr_is_steps%ROWTYPE;
begin

    OPEN  csr_is_steps;
    FETCH Csr_is_steps into l_is_steps;
    if l_is_steps.information18 = 'Y' THEN
    RETURN;
    ELSE
    OPEN csr_plan_dtls;
    Fetch csr_plan_dtls into l_plan_dtls;
    IF csr_plan_dtls%NOTFOUND THEN
        hr_utility.set_location('No Plan avlbl. Exiting..',80);
        return;
    else
        hr_utility.set_location('Plip cer Id :..'||l_plan_dtls.Gs_Mirror_Src_Entity_Result_Id,20);
        OPEN csr_plip_dtls(l_plan_dtls.Gs_Mirror_Src_Entity_Result_Id);
        fetch csr_plip_dtls into l_plip_dtls;
        IF csr_plip_dtls%NOTFOUND THEN
        hr_utility.set_location('No Plip avlbl for Plan. Exiting..',90);
            return;
        else
        hr_utility.set_location('Scale cer Id :..'||l_plip_dtls.Information258,30);
            OPEN Csr_scale_dtls(l_plip_dtls.Information258);
            fetch csr_scale_dtls into l_scale_dtls;
            IF csr_scale_dtls%NOTFOUND THEN
            hr_utility.set_location('No scale avlbl for Plip... Exiting..',90);
               return;
            Else
            hr_utility.set_location('Scale Name is  :..'||l_scale_dtls.Information98,40);
            hr_utility.set_location('Grade Short Name Passed is  :..'||l_scale_dtls.Information98,45);
                if p_short_name = l_scale_dtls.Information98 then
            hr_utility.set_location('The names match ..Exiting..',95);
                return;
                else
            hr_utility.set_location('Got some work to do..',55);

            update ben_copy_entity_results
            set information98 = p_short_name
            , dml_operation = get_dml_operation(l_scale_dtls.dml_operation)
            where copy_entity_result_id = l_scale_dtls.copy_entity_result_id;

            update ben_copy_entity_results
            set information98 = p_short_name
            ,dml_operation = get_dml_operation(l_plip_dtls.dml_operation)
            where copy_entity_result_id = l_plip_dtls.copy_entity_result_id;

                end if;
            END IF;
        END IF;
    END IF;
    END IF;
END change_scale_name;

procedure remove_steps(p_copy_entity_txn_id IN NUMBER, p_grade_result_id IN NUMBER)
IS
    CURSOR csr_steps_in_grade
      IS
         SELECT copy_entity_result_id,
                dml_operation
           FROM ben_copy_entity_results
          WHERE table_alias = 'COP'
            AND copy_entity_txn_id = p_copy_entity_txn_id
            AND gs_parent_entity_result_id = p_grade_result_id
            AND result_type_cd = 'DISPLAY'
            AND NVL (information104, 'PPP') <> 'UNLINK';

    Cursor Csr_Action_Dt is
    Select Action_Date
      From Pqh_Copy_Entity_txns
     Where Copy_Entity_Txn_id = p_copy_entity_txn_id;

    l_Action_Date  date;
begin

    Open Csr_Action_Dt;
   Fetch Csr_Action_Dt Into L_Action_Date;
   Close Csr_Action_Dt;

   for rec_steps in csr_steps_in_grade loop

      /*  update ben_copy_entity_results
        set copy_entity_result_id = rec_steps.copy_entity_result_id,
            information104        = 'UNLINK',
             dml_operation        =  get_dml_operation(rec_steps.dml_operation)
         where copy_entity_result_id = rec_steps.copy_entity_result_id;  */

  Pqh_Gsp_Grd_Step_Remove.REMOVE_OIPL(P_COPY_ENTITY_TXN_ID    => p_copy_entity_txn_id
                                     ,P_COPY_ENTITY_RESULT_ID => rec_steps.copy_entity_result_id
                                     ,P_EFFECTIVE_DATE        => Nvl(L_Action_Date, hr_general.Effective_Date));

   end loop;


end remove_steps;
procedure change_rates_date(p_copy_entity_txn_id in number,p_pl_cer_id in number,p_start_date in DATE)
is
Cursor csr_plan_dtls
Is
select information307
from ben_copy_entity_results
where copy_entity_result_id = p_pl_cer_id
and copy_entity_txn_id = p_copy_entity_txn_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and table_alias = 'PLN';

Cursor Csr_rate_details(p_plan_old_date in date)
is
select information2,information3,copy_entity_result_id
from ben_copy_entity_results
where information277 =p_pl_cer_id
and nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
and table_alias in ('HRRATE','ABR')
and information2 = p_plan_old_date
and copy_entity_txn_id = p_copy_entity_txn_id;
l_plan_old_date date;
begin
if g_debug then
hr_utility.set_location('Entering change_rates_date',10);
hr_utility.set_location('Copy Entity Txn Id:'||p_copy_entity_txn_id,15);
hr_utility.set_location('Plan cer Id:'||p_pl_cer_id,20);
hr_utility.set_location('Start Date:'||p_start_date,25);
end if;
Open csr_plan_dtls;
fetch csr_plan_dtls into l_plan_old_date;
IF csr_plan_dtls%NOTFOUND THEN
if g_debug then
hr_utility.set_location('No Plan records exist',85);
hr_utility.set_location('Leaving change_rates_date',90);
end if;
return;
end if;

close csr_plan_dtls;
if l_plan_old_date = p_start_date THEN
if g_debug then
hr_utility.set_location('Old Date:'||l_plan_old_date,75);
hr_utility.set_location('No date Change needed',85);
hr_utility.set_location('Leaving change_rates_date',90);
end if;
return;
end if;
hr_utility.set_location('Old Date:'||l_plan_old_date,60);

for i in csr_rate_details(l_plan_old_date) loop
if g_debug then
hr_utility.set_location('Updating record with cer_id:'||i.copy_entity_result_id,40);
end if;

if i.information3 < p_start_date then
         hr_utility.set_message(8302,'PER_289567_GRADE_DATE_FROM');
         hr_utility.raise_error;
end if;

update ben_copy_entity_results
set information2 = p_start_date
where copy_entity_result_id = i.copy_entity_result_id;
if g_debug then
hr_utility.set_location('Updated record with cer_id:'||i.copy_entity_result_id,60);
end if;
end loop;
if g_debug then
hr_utility.set_location('Leaving change_rates_date',80);
end if;

END change_rates_date;

-----------
FUNCTION GET_CURRENCY_CODE(p_copy_entity_txn_id       in  number)
RETURN varchar2 IS
/*
  Author  : ggnanagu
  Purpose : This function returns the Currency code associated with the Grade Ladder
*/
l_result Varchar2(20);
l_proc   varchar2(72) := g_package||'USE_POINT_OR_STEP';

Cursor csr_currency_code
IS
Select  nvl(grdldr.INFORMATION50,'USD')   /* INFORMATION50 -> Currency Code */
FROM    Ben_Copy_Entity_Results grdldr
WHERE   grdldr.Copy_Entity_Txn_Id = p_copy_entity_txn_id
AND    nvl(result_type_cd,'DISPLAY') = 'DISPLAY'
AND     grdldr.Table_Alias        = 'PGM';


BEGIN

if g_debug then
hr_utility.set_location('Leaving '||l_proc,10);
hr_utility.set_location('p_copy_entity_txn_id '||p_copy_entity_txn_id,20);
end if;

Open csr_currency_code;
Fetch csr_currency_code into l_result;
Close csr_currency_code;

if g_debug then
hr_utility.set_location('l_result  '||l_result,25);
end if;
return l_result;

if g_debug then
hr_utility.set_location('Leaving '||l_proc,30);
end if;

EXCEPTION
When others THEN
    l_result := 'STEP';
    return l_result;

END GET_CURRENCY_CODE;

--
FUNCTION get_grd_start_date
(p_copy_entity_result_id in ben_copy_entity_results.copy_entity_result_id%TYPE)
RETURN DATE
IS
l_grd_start_date DATE;

begin

select information307
into l_grd_start_date
from ben_copy_entity_results
where copy_entity_result_id = p_copy_entity_result_id;


RETURN l_grd_start_date;
END get_grd_start_date;
procedure change_start_step(p_copy_entity_txn_id in number
                ,p_init_start_step in number
      			,p_final_start_step in number
    			,p_grade_result_id in number
            )
is
Cursor csr_indicator
is
select information103
from ben_copy_entity_results
where copy_entity_result_id =p_grade_result_id;
l_indicator varchar2(10);
begin
open csr_indicator;
fetch csr_indicator into l_indicator;
close csr_indicator;
if nvl(l_indicator,'X') = 'Y'
 then l_indicator := 'B';
else
 l_indicator := 'S';
end if;


update ben_copy_entity_results
set information228 = p_final_start_step
    ,information103 = l_indicator
    where copy_entity_result_id = p_grade_result_id;
end change_start_step;

--
FUNCTION get_formula_name (p_formula_id IN NUMBER, p_effective_date IN DATE)
      RETURN VARCHAR2
   IS
      CURSOR csr_formula_name
      IS
         SELECT ff.formula_name
           FROM ff_formulas_f ff
          WHERE ff.formula_id = p_formula_id
            AND p_effective_date BETWEEN ff.effective_start_date
                                     AND ff.effective_end_date;

      l_formula_name   ff_formulas_f.formula_name%TYPE;
   BEGIN

      OPEN csr_formula_name;
      FETCH csr_formula_name INTO l_formula_name;
      CLOSE csr_formula_name;

      RETURN l_formula_name;

   END get_formula_name;

   FUNCTION get_element_name (p_element_type_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR csr_element_name
      IS
         SELECT ettl.element_name
           FROM pay_element_types_f_tl ettl
          WHERE ettl.LANGUAGE = USERENV ('LANG')
            AND ettl.element_type_id = p_element_type_id;

      l_element_name   pay_element_types_f_tl.element_name%TYPE;
   BEGIN

      OPEN csr_element_name;
      FETCH csr_element_name INTO l_element_name;
      CLOSE csr_element_name;

      RETURN l_element_name;

   END get_element_name;

   FUNCTION get_input_val_name (p_input_value_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR csr_input_val_name
      IS
         SELECT ptl.NAME
           FROM pay_input_values_f_tl ptl
          WHERE ptl.LANGUAGE = USERENV ('LANG')
            AND ptl.input_value_id = p_input_value_id;

      l_input_val_name   pay_input_values_f_tl.NAME%TYPE;
   BEGIN

      OPEN csr_input_val_name;
      FETCH csr_input_val_name INTO l_input_val_name;
      CLOSE csr_input_val_name;

      RETURN l_input_val_name;

   END get_input_val_name;
--
FUNCTION get_bg_currency(p_business_group_id in  number) RETURN varchar2
is
begin
 return Hr_General.DEFAULT_CURRENCY_CODE(p_Business_group_Id);
end get_bg_currency;
--
PROCEDURE chk_grd_ldr_details (
   p_business_group_id   IN   NUMBER,
   p_name                IN   VARCHAR2,
   p_dflt_pgm_flag       IN   VARCHAR2,
   p_pgm_id              IN   NUMBER,
   p_effective_date      IN   DATE
)
IS
   CURSOR csr_name
   IS
      SELECT NULL
        FROM ben_pgm_f
       WHERE NAME = p_name
         AND business_group_id = p_business_group_id
         AND pgm_id <> NVL (p_pgm_id, -1);

   CURSOR csr_dflt_grd_ldr
   IS
      SELECT NAME
        FROM ben_pgm_f
       WHERE dflt_pgm_flag = 'Y'
         AND business_group_id = p_business_group_id
         AND pgm_id <> NVL (p_pgm_id, -1)
         AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_pgm_name   ben_pgm_f.NAME%TYPE;
   l_dummy      VARCHAR2 (10);
BEGIN
   hr_multi_message.enable_message_list;

   OPEN csr_name;

   FETCH csr_name
    INTO l_dummy;

   IF csr_name%FOUND
   THEN
      hr_utility.set_message (8302, 'PQH_GSP_GRDLDR_NAME_UNQ');
      hr_multi_message.ADD;
   END IF;

   CLOSE csr_name;

   IF p_dflt_pgm_flag = 'Y'
   THEN
      OPEN csr_dflt_grd_ldr;

      FETCH csr_dflt_grd_ldr
       INTO l_pgm_name;

      IF csr_dflt_grd_ldr%FOUND
      THEN
         hr_utility.set_message (8302, 'PQH_GSP_GRDLDR_DFLT_ERR');
         hr_utility.set_message_token ('LADDER', l_pgm_name);
         hr_multi_message.ADD;
      END IF;

      CLOSE csr_dflt_grd_ldr;
   END IF;
   hr_multi_message.end_validation_set;
EXCEPTION
   WHEN hr_multi_message.error_message_exist
   THEN
      NULL;
   WHEN OTHERS
   THEN
      RAISE;
END chk_grd_ldr_details;
--------------------------------------------------------
--------------< get_gl_ann_factor >---------------------
--------------------------------------------------------
function get_gl_ann_factor(p_pgm_id in number)
return varchar2
 IS
 Cursor csr_gl_ann_factor IS
 SELECT pgi_information5  rate_ann_factor
 FROM   ben_pgm_extra_info
 WHERE  pgm_id     = p_pgm_id
 AND    information_type = 'PQH_GSP_EXTRA_INFO';
 l_proc constant varchar2(72):= g_package||'get_gl_ann_factor';
 l_gl_ann_factor ben_pgm_extra_info.pgi_information5%TYPE;
BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);
   open   csr_gl_ann_factor;
   FETCH  csr_gl_ann_factor INTO l_gl_ann_factor;
  CLOSE  csr_gl_ann_factor;
  return l_gl_ann_factor;
    hr_utility.set_location(' Leaving:'||l_proc, 10);

 Exception
    WHEN Others THEN
        raise;
 END get_gl_ann_factor;


PROCEDURE upd_ceiling_info(p_grade_cer_id IN NUMBER, p_step_id IN number)
   IS
   BEGIN

update ben_copy_entity_results
  set  information259 =  p_step_id,
       information103 = 'Y'
where copy_entity_result_id = p_grade_cer_id
  and table_alias = 'CPP';

END upd_ceiling_info;

 --
End pqh_gsp_utility;


/
