--------------------------------------------------------
--  DDL for Package Body PQH_GSP_BEN_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GSP_BEN_VALIDATIONS" as
/* $Header: pqgspben.pkb 120.0.12010000.2 2008/08/05 13:35:25 ubhat ship $ */
-- dml_operation can be I(Insert)/ U(Update)/ D(Delete)
-- call to this validation routine is to be made after the actual event i.e.
-- insert update or delete should already have happened
-- we will try to check here that the event has not failed any GSP data
-- if any, we will be raising the error.

g_package  Varchar2(30) := 'pqh_gsp_ben_validations.';
g_debug boolean := hr_utility.debug_enabled;

--
---------------------------get_pl_type-----------------------------
--
Function get_pl_type(p_pl_id In number,
                     p_effective_date     In date,
                     p_Business_Group_Id  In Number)
Return    Varchar2 IS
l_proc    Varchar2(72) := g_package||'get_pl_type';
l_type    BEN_PL_TYP.OPT_TYP_CD%Type := NULL;
l_type_id Number;

Cursor csr_pl_type_id
IS
Select pl.Pl_Typ_Id
From   Ben_PL_F pl
Where  pl.Pl_Id = p_pl_id
And    pl.Business_Group_id = p_Business_Group_Id
And    p_effective_date BETWEEN Pl.effective_start_date
And    nvl(Pl.effective_end_date,hr_general.end_of_time);

Cursor csr_pl_type (l_pl_Typ_Id IN Number)
IS
Select  OPT_TYP_CD
From    BEN_PL_TYP_F Type
Where   Pl_Typ_Id = l_pl_Typ_Id
And     Business_Group_id = p_Business_Group_Id
And     p_effective_date  BETWEEN effective_start_date
And     nvl(effective_end_date,hr_general.end_of_time);

Begin

if g_debug then
      hr_utility.set_location('Entering'||l_proc,5);
      hr_utility.set_location('p_pl_id'||p_pl_id,10);
      hr_utility.set_location('p_effective_date'||p_effective_date,15);
      hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

Open csr_pl_type_id;
Fetch csr_pl_type_id into l_type_id;
Close csr_pl_type_id;

if g_debug then
      hr_utility.set_location('Plan Type Id '||l_type_id,25);
end if;
If l_type_id IS NOT NULL Then
     Open csr_pl_type(l_type_id);
     Fetch csr_pl_type into l_type;
     Close csr_pl_type;
End If;

if g_debug then
      hr_utility.set_location('Plan Type '||l_type,35);
      hr_utility.set_location('Leaving'||l_proc,100);
end if;
return l_type;
Exception
   When Others then
      return null;

End get_pl_type;

--
---------------------------get_plip_type-----------------------------
--
Function get_plip_type(p_plip_id In number,
                     p_effective_date     In date,
                     p_Business_Group_Id  In Number)
Return    Varchar2 IS
l_proc    Varchar2(72) := g_package||'get_plip_type';
l_pl_id   Number;
l_type    BEN_PL_TYP.OPT_TYP_CD%Type := NULL;
l_pgm_id  Number;
l_is_pgm_type_gsp  Varchar2(1) :='N';

Cursor csr_pl_id
IS
Select plip.Pl_Id,plip.Pgm_Id
From   Ben_PLIP_F plip
Where  plip.Plip_Id = p_plip_id
And    plip.Business_Group_id = p_Business_Group_Id
And    p_effective_date BETWEEN Plip.effective_start_date
And    nvl(Plip.effective_end_date,hr_general.end_of_time);


Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

Open csr_pl_id;
Fetch csr_pl_id into l_pl_id,l_pgm_id;
Close csr_pl_id;

if g_debug then
hr_utility.set_location('Plan Id '||l_pl_id,25);
hr_utility.set_location('PGM Id'||l_pgm_id,26);
end if;

If l_pgm_id IS NOT NULL Then

     l_is_pgm_type_gsp := is_pgm_type_gsp(p_Pgm_Id   => l_pgm_id,
                            p_Business_Group_Id => p_business_group_id,
                            p_Effective_Date    =>  p_effective_date
                           );
End If;

if g_debug then
hr_utility.set_location('Is PGM Type is GSP (Y/N)'||l_is_pgm_type_gsp,27);
end if;


If l_is_pgm_type_gsp = 'Y' And l_pl_id IS NOT NULL  Then
    l_type :=  get_pl_type( p_pl_id    => l_pl_id,
                  p_effective_date     => p_effective_date,
                  p_Business_Group_Id  => p_Business_Group_Id);
End If;

if g_debug then
hr_utility.set_location('Plan Type '||l_type,35);
hr_utility.set_location('Leaving'||l_proc,100);
end if;
return l_type;

Exception
   When Others then
      return null;
if g_debug then
hr_utility.set_location('Leaving'||l_proc,100);
end if;
End get_plip_type;

--
---------------------------chk_plip_emp_assign-----------------------------
--
Function chk_plip_emp_assign(p_plip_id           In number,
                             p_effective_date    In date,
                             p_business_group_id In Number)
Return Varchar2 IS
/*
Purpose : This Function returns 'Y' if emp assignments exists for a PLIP
          Otherwise returns 'N'

*/
l_proc          Varchar2(72) := g_package||'chk_plip_emp_assign';
l_grade_id      Number;
l_dummy         Char(1);
l_plip_type_cd  BEN_PL_TYP.OPT_TYP_CD%Type := NULL;
l_exists        Varchar2(1) :='N';

Cursor csr_grade_id
IS
SELECT MAPPING_TABLE_PK_ID -- GRADE_ID
FROM   BEN_PLIP_F PLIP,
       BEN_PL_F PL
WHERE  PLIP.PLIP_ID = p_plip_id
And    PLIP.PLIP_STAT_CD ='A'
AND    PLIP.PL_ID =PL.PL_ID
AND    PL.MAPPING_TABLE_NAME = 'PER_GRADES'
AND    PL.BUSINESS_GROUP_ID = p_business_group_id
AND    p_effective_date  BETWEEN  PLIP.EFFECTIVE_START_DATE
And    nvl(PLIP.Effective_End_Date, hr_general.end_of_time)
AND    p_effective_date  BETWEEN  PL.EFFECTIVE_START_DATE
And    nvl(PL.Effective_End_Date, hr_general.end_of_time);

Cursor csr_emp_placemnets (l_grade_id IN NUMBER)
IS
Select NULL
From   Per_All_Assignments_F Assgt
Where  Grade_Id     = l_grade_id
AND    p_Effective_Date BETWEEN Assgt.effective_start_date
AND    nvl(Assgt.effective_end_date,hr_general.end_of_time)
AND    Assgt.business_group_id = p_Business_Group_Id;


Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

-- Check PLIP Rec Type is GSP
l_plip_type_cd :=  get_plip_type( p_plip_id          => p_plip_id,
                                p_effective_date     => p_effective_date,
                                p_Business_Group_Id  => p_Business_Group_Id);
if g_debug then
hr_utility.set_location('PLIP Type '||l_plip_type_cd,30);
end if;

If Nvl(l_plip_type_cd,'PPP') = 'GSP' Then
--
--
      Open csr_grade_id;
      Fetch csr_grade_id into l_grade_id;
      Close csr_grade_id;
      --
      --
      if g_debug then
         hr_utility.set_location('Grade Id '||l_grade_id,40);
      end if;
      If l_grade_id IS NOT NULL Then
           Open csr_emp_placemnets(l_grade_id);
           Fetch csr_emp_placemnets into l_dummy;
           If csr_emp_placemnets%Found Then
               if g_debug then
                   hr_utility.set_location('Emp Placements are exists',50);
               end if;
               l_exists := 'Y';
           End If;
           Close csr_emp_placemnets;
      End If;
--
--
End If;
if g_debug then
       hr_utility.set_location('Leaving'||l_proc,100);
end if;
return l_exists;

Exception
  When others then
    return 'N';

end chk_plip_emp_assign;

--
---------------------------chk_opt_has_gsp_type-----------------------------
--
Function chk_opt_has_gsp_type(p_opt_id           In number,
                             p_effective_date    In date,
                             p_business_group_id In Number)
Return Varchar2 IS
/*
Purpose : This Function returns 'Y' if Option has GSP Plan Type.
          Otherwise returns 'N'

*/
l_proc   varchar2(72) := g_package||'chk_opt_has_gsp_type';
l_dummy  Char(1);
l_type  Varchar2(10) :='N';

Cursor csr_opt_type
IS
Select NULL
From   BEN_PL_TYP_OPT_TYP_F
Where  OPT_ID = p_opt_id
AND    BUSINESS_GROUP_ID = p_business_group_id
AND    p_effective_date  BETWEEN  EFFECTIVE_START_DATE
And    nvl(Effective_End_Date, hr_general.end_of_time)
And    PL_TYP_OPT_TYP_CD = 'GSP';

Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,10);
   hr_utility.set_location('p_opt_id:'||p_opt_id, 15);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 20);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 25);
end if;


   Open csr_opt_type;
   Fetch csr_opt_type into l_dummy;
   If csr_opt_type%Found Then
        l_type := 'Y';
   End If;
   Close csr_opt_type;
   if g_debug then
         hr_utility.set_location('Option has GSP Type (Y/N) :'||l_type, 45);
         hr_utility.set_location('Leaving:'||l_proc, 100);
   end if;
   return l_type;
Exception
    When others then
       return 'N';
End  chk_opt_has_gsp_type;


--
---------------------------chk_oipl_has_gsp_type-----------------------------
--
Function chk_oipl_has_gsp_type(p_oipl_id           In number,
                             p_effective_date    In date,
                             p_business_group_id In Number)
Return Varchar2 IS
/*
Purpose : This Function returns 'Y' if OIPL has GSP Plan Type.
          Otherwise returns 'N'

*/
l_proc             Varchar2(72) := g_package||'chk_oipl_has_gsp_type';
l_dummy            Char(1);
l_type             Varchar2(10) :='N';
l_opt_id           Number;

Cursor csr_opt_id
IS
Select Opt_Id
From   BEN_OIPL_F
Where  OIPL_ID = p_oipl_id
And    OIPL_STAT_CD = 'A'
AND    BUSINESS_GROUP_ID = p_business_group_id
AND    p_effective_date  BETWEEN  EFFECTIVE_START_DATE
And    nvl(Effective_End_Date, hr_general.end_of_time);

Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,10);
   hr_utility.set_location('p_oipl_id:'||p_oipl_id, 15);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 20);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 25);
end if;


   Open csr_opt_id;
   Fetch csr_opt_id into l_opt_id;
   Close csr_opt_id;

   if g_debug then
         hr_utility.set_location('Opt Id:'||l_opt_id, 35);
   end if;

   If l_opt_id IS NOT NULL Then
        l_type := chk_opt_has_gsp_type(p_opt_id            => l_opt_id ,
                                       p_effective_date    => p_effective_date,
                                       p_business_group_id => p_business_group_id);
   End If;

   if g_debug then
      hr_utility.set_location('OIPL has GSP Type (Y/N) :'||l_type, 45);
      hr_utility.set_location('Leaving:'||l_proc, 100);
   end if;

   return l_type;
Exception
    When others then
       return 'N';
End  chk_oipl_has_gsp_type;

--
---------------------------get_step_id-----------------------------
--
Function get_step_id(p_spinal_point_Id     In number,
                     p_Grade_Id            IN Number,
                     p_effective_date    In date,
                     p_business_group_id In Number)
Return Number IS
/*
Purpose : This Function returns 'Y' if OIPL has GSP Plan Type.
          Otherwise returns 'N'

*/
l_proc       Varchar2(72) := g_package||'get_step_id';
l_step_id    Number := NULL;

Cursor csr_step_id
IS
Select   Step.step_id
From     per_spinal_points point,
         per_parent_spines Scale,
         per_grade_spines_f  spine,
         per_spinal_point_steps_f step
Where    point.SPINAL_POINT_ID   = p_spinal_point_Id
And      point.Business_Group_Id = p_business_group_id
And      Scale.PARENT_SPINE_ID   = point.PARENT_SPINE_ID
And      Scale.PARENT_SPINE_ID   = spine.PARENT_SPINE_ID
And      spine.GRADE_SPINE_ID    = step.GRADE_SPINE_ID
And      step.SPINAL_POINT_ID    = point.SPINAL_POINT_ID
And      spine.Grade_Id          = p_Grade_Id
AND      p_effective_date  BETWEEN  spine.EFFECTIVE_START_DATE
And      nvl(spine.Effective_End_Date, hr_general.end_of_time)
AND      p_effective_date  BETWEEN  step.EFFECTIVE_START_DATE
And      nvl(step.Effective_End_Date, hr_general.end_of_time);

Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,10);
   hr_utility.set_location('p_spinal_point_Id:'||p_spinal_point_Id, 15);
   hr_utility.set_location('p_Grade_Id:'||p_Grade_Id, 20);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 25);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 30);
end if;

   Open csr_step_id;
   Fetch csr_step_id into l_step_id;
   Close csr_step_id;

   if g_debug then
      hr_utility.set_location('Step Id:'||l_step_id, 35);
      hr_utility.set_location('Leaving:'||l_proc, 100);
   end if;

   return l_step_id;
Exception
    When others then
       return NULL;
End  get_step_id;

--
---------------------------chk_oipl_emp_assign-----------------------------
--
Function chk_oipl_emp_assign(p_oipl_id           In number,
                             p_effective_date    In date,
                             p_business_group_id In Number)
Return Varchar2 IS
/*
Purpose : This Function returns 'Y' if emp assignments exists for a OIPL
          Otherwise returns 'N'

*/
l_proc                 Varchar2(72) := g_package||'chk_oipl_emp_assign';
l_grade_id             Number;
l_spinal_point_id      Number;
l_step_id              Number;
l_gsp_type             Varchar2(1) :='N';
l_steps_exists_on_oipl              Varchar2(1) :='N';
l_dummy                Char(1);
l_plcmt_Esd            Date;
l_plcmt_Eed            Date;
l_Asgt_Esd             Date;
l_Asgt_Eed             Date;

Cursor csr_grade_point_id
IS
Select  pl.MAPPING_TABLE_PK_ID,  --   Grade_Id
        opt.MAPPING_TABLE_PK_ID  -- spinal_point_id
From    BEN_OIPL_F oipl,
        BEN_OPT_F  opt,
        BEN_PL_F   pl
Where   oipl.Oipl_Id   = p_oipl_id
And     oipl.OIPL_STAT_CD = 'A'
And     oipl.Pl_id     = pl.PL_ID
And     oipl.Business_Group_Id= p_business_group_id
And     oipl.opt_id = opt.opt_id
and     opt.MAPPING_TABLE_NAME= 'PER_SPINAL_POINTS'
And     pl.MAPPING_TABLE_NAME = 'PER_GRADES'
AND     p_effective_date  BETWEEN  oipl.EFFECTIVE_START_DATE
And     nvl(oipl.Effective_End_Date, hr_general.end_of_time)
AND     p_effective_date BETWEEN  PL.EFFECTIVE_START_DATE
And     nvl(PL.Effective_End_Date, hr_general.end_of_time);

cursor csr_point_placement(l_step_id IN Number) is
select Effective_Start_date, Effective_End_Date
from   per_spinal_point_placements_f
where  step_id = l_step_id
And    Business_Group_Id= p_business_group_id
and    p_effective_date between effective_start_date
and    nvl(effective_end_date,hr_general.end_of_time);
--
cursor  csr_emp_assign (l_step_id IN Number) is
select Effective_Start_Date, Effective_End_Date
from   per_all_assignments_f
where  special_ceiling_step_id = l_step_id
And    Business_Group_Id= p_business_group_id
and    p_effective_date between effective_start_date
and    nvl(effective_end_date,hr_general.end_of_time);

Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_oipl_id'||p_oipl_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

-- Check OIPL has GSP Plan Type
l_gsp_type := chk_oipl_has_gsp_type(p_oipl_id    => p_oipl_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id);

If l_gsp_type = 'Y' Then
     if g_debug then
     hr_utility.set_location('OIPL has GSP Plan Type',35);
     end if;
     --
     -- Get Grade Id, spinal_point_id
     --
     Open csr_grade_point_id;
     Fetch csr_grade_point_id into l_grade_id,l_spinal_point_id;
     Close csr_grade_point_id;

     if g_debug then
     hr_utility.set_location('Grade Id  :'||l_grade_id,40);
     hr_utility.set_location('Spinal Point Id : '||l_spinal_point_id,50);
     end if;

     l_step_Id := get_step_id(p_spinal_point_Id    => l_spinal_point_id,
                              p_Grade_Id           => l_grade_id,
                              p_effective_date     => p_effective_date,
                              p_business_group_id  => p_business_group_id);
     if g_debug then
         hr_utility.set_location('Step Id : '||l_step_Id,55);
     end if;

     /* Check step is
        1) Special Ceiling Step
        2) Employee Placements on this step
     */
     if l_step_Id IS NOT NULL Then
         open csr_point_placement(l_step_id);
	 fetch csr_point_placement into l_plcmt_Esd, l_plcmt_Eed;
	 IF csr_point_placement%found THEN
	    If P_Effective_Date >= l_plcmt_Eed Then
	       l_steps_exists_on_oipl := 'N';
	    Else
	      if g_debug then
	          hr_utility.set_location('Step has Point Placement ',55);
	      end if;
	      l_steps_exists_on_oipl := 'Y';
	    End if;
	 End if;
	 close csr_point_placement;

	 open csr_emp_assign(l_step_id);
	 fetch csr_emp_assign into l_Asgt_Esd, l_Asgt_Eed;

	 IF csr_emp_assign%found THEN
	     If P_Effective_Date >= l_Asgt_Eed Then
                l_steps_exists_on_oipl := 'N';
	     Else
	        if g_debug then
	            hr_utility.set_location('Step has Emp Placement ',65);
	        end if;
	 	l_steps_exists_on_oipl := 'Y';
	     End If;
	 End if;
	 close csr_emp_assign;

     end if; -- Step Id Not null
End If;
if g_debug then
       hr_utility.set_location('Leaving'||l_proc,100);
end if;
return l_steps_exists_on_oipl;

Exception
  When others then
    return 'N';

end chk_oipl_emp_assign;

--
---------------------------is_pgm_type_gsp-----------------------------
--
Function is_pgm_type_gsp(p_Pgm_Id            in Number,
                            p_Business_Group_Id in Number,
                            p_Effective_Date    in Date
                           )
Return Varchar2 IS
/*
Purpose : This function returns 'Y' If Pgm Type is GSP  else 'returns 'N'
*/

l_proc       varchar2(72) := g_package||'is_pgm_type_gsp';
l_dummy      char(1);
l_type       Varchar2(1) := 'N';

Cursor csr_pgm_typ
IS
Select Null
From   Ben_Pgm_F
Where  Pgm_id =  p_Pgm_Id
And    business_group_id = p_business_group_id
And    p_effective_date Between Effective_Start_Date
And    nvl(Effective_End_Date, hr_general.end_of_time)
And    PGM_TYP_CD = 'GSP'
And    PGM_STAT_CD = 'A';


Begin
if g_debug then
      hr_utility.set_location('Entering '||l_proc,5);
      hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
      hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
      hr_utility.set_location('p_Effective_Date:'||p_Effective_Date, 20);
end if;

Open csr_pgm_typ;
Fetch csr_pgm_typ into l_dummy;
If csr_pgm_typ%Found Then
   l_type := 'Y';
End If;
Close csr_pgm_typ;

if g_debug then
    hr_utility.set_location('Pgm Type is GSP (Y/N):'||l_type, 25);
    hr_utility.set_location('Leaving '||l_proc,100);
end if;

return l_type;
Exception
   when others then
     return 'N';
End is_pgm_type_gsp;


--
---------------------------chk_pgm_emp_assign-----------------------------
--
Function chk_pgm_emp_assign(p_Pgm_Id            in Number,
                            p_Business_Group_Id in Number,
                            p_Effective_Date    in Date
                           )
Return Varchar IS
/*
Purpose : This function returns 'Y' If Pgm has emp placements else 'returns 'N'
*/

l_proc       varchar2(72) := g_package||'chk_pgm_emp_assign';
l_dummy      char(1);
l_pgm_type   Varchar2(10);
l_exists     Varchar2(1) := 'N';

Cursor csr_pgm_typ
IS
Select PGM_TYP_CD
From   Ben_Pgm_F
Where  Pgm_id =  p_Pgm_Id
And    business_group_id = p_business_group_id
And    p_effective_date Between Effective_Start_Date
And    nvl(Effective_End_Date, hr_general.end_of_time)
And    PGM_STAT_CD = 'A';

Cursor csr_emp_placemnets
IS
Select NULL
From   Per_All_Assignments_F Assgt
Where  Grade_Ladder_Pgm_Id     = p_Pgm_Id
AND    p_Effective_Date BETWEEN Assgt.effective_start_date
AND    nvl(Assgt.effective_end_date,hr_general.end_of_time)
AND    Assgt.business_group_id = p_Business_Group_Id;

Begin
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
hr_utility.set_location('p_Effective_Date:'||p_Effective_Date, 20);
end if;

Open csr_pgm_typ;
Fetch csr_pgm_typ into l_pgm_type;
Close csr_pgm_typ;

if g_debug then
hr_utility.set_location('Program Type :'||l_pgm_type, 25);
end if;

If l_pgm_type = 'GSP' Then
   Open csr_emp_placemnets;
   Fetch csr_emp_placemnets into l_dummy;
   If csr_emp_placemnets%Found then
         if g_debug then
             hr_utility.set_location('Emp Placemnts exist on Program ',35);
         end if;
         l_exists := 'Y';
   End If;
   Close csr_emp_placemnets;
End If;

if g_debug then
   hr_utility.set_location('Leaving '||l_proc,100);
end if;
return l_exists;
Exception
   when others then
     return 'N';
End chk_pgm_emp_assign;

--
---------------------------chk_pgm_has_grades-----------------------------
--
Function chk_pgm_has_grades(p_Pgm_Id            in Number,
                            p_Business_Group_Id in Number,
                            p_Effective_Date    in Date
                           )
Return Varchar IS
/*
Purpose : This function returns 'Y' If Pgm has Grades else 'returns 'N'
*/

l_proc       varchar2(72) := g_package||'chk_pgm_has_grades';
l_dummy      char(1);
l_pgm_type   Varchar2(10);
l_exists     Varchar2(1) := 'N';

Cursor csr_grades
IS
Select NULL
From   BEN_PGM_F PGM,
       BEN_PLIP_F PLIP,
       BEN_PL_F PL
WHERE  PGM.PGM_ID = p_Pgm_Id
AND    PGM.PGM_TYP_CD = 'GSP'
AND    PGM.BUSINESS_GROUP_ID = p_Business_Group_Id
AND    PGM.PGM_ID = PLIP.PGM_ID
AND    PLIP.PL_ID = PL.PL_ID
AND    PL.MAPPING_TABLE_NAME = 'PER_GRADES'
AND    PL.MAPPING_TABLE_PK_ID IS NOT NULL
And    PGM.PGM_STAT_CD = 'A'
AND    PLIP.PLIP_STAT_CD = 'A'
AND    PL.PL_STAT_CD ='A'
AND    p_Effective_Date BETWEEN pgm.effective_start_date
AND    nvl(pgm.effective_end_date,hr_general.end_of_time)
AND    p_Effective_Date BETWEEN plip.effective_start_date
AND    nvl(plip.effective_end_date,hr_general.end_of_time)
AND    p_Effective_Date BETWEEN pl.effective_start_date
AND    nvl(pl.effective_end_date,hr_general.end_of_time);


Begin
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
hr_utility.set_location('p_Effective_Date:'||p_Effective_Date, 20);
end if;

Open csr_grades;
Fetch csr_grades into l_dummy;
If csr_grades%Found Then
   l_exists := 'Y';
End If;
Close csr_grades;

if g_debug then
hr_utility.set_location('Program has Grades (Y/N) :'||l_exists, 25);
hr_utility.set_location('Leaving '||l_proc,100);
end if;

return l_exists;
Exception
   when others then
     return 'N';
End chk_pgm_has_grades;

--
---------------------------chk_pl_exists_in_grdldr-----------------------------
--
Function chk_pl_exists_in_grdldr(p_pl_id              In number,
                                  p_effective_date     In date,
                                  p_Business_Group_Id  In Number)
Return Varchar2 IS
l_proc   varchar2(72) := g_package||'chk_pl_exists_in_grdldr';
l_dummy  Char(1);
l_exists  Varchar2(10) :='N';

Cursor csr_pl_in_grdldr
IS
Select Null
From   Ben_PL_F   pl,
       Ben_Plip_F plip,
       Ben_Pgm_F  Pgm
Where  pl.pl_id = p_pl_id
And    pl.MAPPING_TABLE_NAME = 'PER_GRADES'
And    pl.MAPPING_TABLE_PK_ID IS NOT NULL
And    pl.pl_id = plip.pl_id
And    plip.pgm_id = pgm.pgm_id
And    pgm.Business_Group_Id = p_Business_Group_Id
And    pgm.Pgm_Typ_Cd = 'GSP'
And    pl.PL_STAT_CD     = 'A'
And    plip.PLIP_STAT_CD = 'A'
And    pgm.PGM_STAT_CD   = 'A'
And    p_effective_date BETWEEN Pl.effective_start_date
and    nvl(Pl.effective_end_date,hr_general.end_of_time)
And    p_effective_date BETWEEN Plip.effective_start_date
and    nvl(Plip.effective_end_date,hr_general.end_of_time)
And    p_effective_date BETWEEN Pgm.effective_start_date
and    nvl(Pgm.effective_end_date,hr_general.end_of_time);

Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,5);
   hr_utility.set_location('p_pl_id'||p_pl_id,10);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 15);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 20);
end if;


   Open csr_pl_in_grdldr;
   Fetch csr_pl_in_grdldr into l_dummy;
   If csr_pl_in_grdldr%Found Then
        l_exists := 'Y';
   End If;
   Close csr_pl_in_grdldr;
  --
  --
  if g_debug then
     hr_utility.set_location('Leaving'||l_proc,100);
  end if;
  return l_exists;

Exception
   when others then
     return 'N';
End chk_pl_exists_in_grdldr;


--
---------------------------chk_opt_exists_in_gsp_pl-----------------------------
--
Function chk_opt_exists_in_gsp_pl(p_opt_id             In number,
                                  p_effective_date     In date,
                                  p_Business_Group_Id  In Number)
Return    Varchar2 IS

/* To check OPT is in GSP Plan perform following checks
  1) OPT has GSP Type
  2) OPT is in GSP Plan through PLIP

*/
l_proc    Varchar2(72) := g_package||'chk_opt_exists_in_gsp_pl';
l_dummy   Char(1);
l_exists  Varchar2(10) :='N';
l_opt_has_gsp_type Varchar2(1) := 'N';

Cursor csr_opt_in_pl
IS
Select  Null
FROM    BEN_OPT_F opt,
        BEN_OIPL_F oipl,
	BEN_PL_F   pl
WHERE   opt.opt_id = p_opt_id
AND     opt.Business_group_id = p_Business_Group_Id
AND     opt.opt_id = oipl.opt_id
AND     oipl.pl_id = pl.pl_id
AND     pl.MAPPING_TABLE_NAME = 'PER_GRADES'
AND     pl.MAPPING_TABLE_PK_ID IS NOT NULL
And     oipl.OIPL_STAT_CD = 'A'
AND     pl.PL_STAT_CD = 'A'
AND     p_effective_date BETWEEN opt.effective_start_date
AND     nvl(opt.effective_end_date,hr_general.end_of_time)
AND     p_effective_date BETWEEN oipl.effective_start_date
AND     nvl(oipl.effective_end_date,hr_general.end_of_time)
AND     p_effective_date BETWEEN pl.effective_start_date
AND     nvl(pl.effective_end_date,hr_general.end_of_time);

Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,5);
   hr_utility.set_location('p_opt_id'||p_opt_id,10);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 15);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 20);
end if;

   l_opt_has_gsp_type := chk_opt_has_gsp_type(p_opt_id => p_opt_id ,
                                  p_effective_date     => p_effective_date,
                                  p_business_group_id  => p_business_group_id);
   if g_debug then
      hr_utility.set_location('Is OPT has GSP Type (Y/N) '||l_opt_has_gsp_type,40);
   end if;

   If l_opt_has_gsp_type = 'Y' Then
         Open csr_opt_in_pl;
         Fetch csr_opt_in_pl into l_dummy;
         If csr_opt_in_pl%Found Then
              l_exists := 'Y';
         End If;
        Close csr_opt_in_pl;
   End if;
  if g_debug then
      hr_utility.set_location('OPT is in GSP Plan (Y/N) '||l_exists,90);
      hr_utility.set_location('Leaving'||l_proc,100);
  end if;
  return l_exists;

Exception
   when others then
     return 'N';
End chk_opt_exists_in_gsp_pl;


--
---------------------------chk_opt_exists_in_gsp_pgm-----------------------------
--
Function chk_opt_exists_in_gsp_pgm(p_opt_id             In number,
                                  p_effective_date     In date,
                                  p_Business_Group_Id  In Number)
Return    Varchar2 IS

/*
  To check opt is in PGM check the following
  1) Check OPT has GSP Type
  2) Check OPT is in GSP Plan through PLIP
  3) Check GSP Plan is in GSP Program

*/
l_proc                Varchar2(72) := g_package||'chk_opt_exists_in_gsp_pgm';
l_dummy               Char(1);
l_opt_exist_in_plan   Varchar2(1) := 'N';
l_pl_exists_in_grdldr Varchar2(1) := 'N';
l_pl_id             Number;

Cursor csr_pl_id
IS
Select  oipl.PL_ID
FROM    BEN_OPT_F opt,
        BEN_OIPL_F oipl
WHERE   opt.opt_id = p_opt_id
AND     opt.Business_group_id = p_Business_Group_Id
AND     opt.opt_id = oipl.opt_id
And     oipl.OIPL_STAT_CD = 'A'
AND     p_effective_date BETWEEN opt.effective_start_date
AND     nvl(opt.effective_end_date,hr_general.end_of_time)
AND     p_effective_date BETWEEN oipl.effective_start_date
AND     nvl(oipl.effective_end_date,hr_general.end_of_time);


Begin
if g_debug then
   hr_utility.set_location('Entering'||l_proc,5);
   hr_utility.set_location('p_opt_id'||p_opt_id,10);
   hr_utility.set_location('p_effective_date:'||p_effective_date, 15);
   hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 20);
end if;

   -- 1) Check OPT has GSP Type
   -- 2) Check OPT is in GSP Plan through PLIP

   l_opt_exist_in_plan := chk_opt_exists_in_gsp_pl(p_opt_id => p_opt_id ,
                                  p_effective_date     => p_effective_date,
                                  p_business_group_id  => p_business_group_id);
   if g_debug then
       hr_utility.set_location('Is OPT has GSP Type (Y/N) '||l_opt_exist_in_plan,40);
   end if;

   If l_opt_exist_in_plan = 'Y' Then

         -- Get PL Id
         Open csr_pl_id;
         Fetch csr_pl_id into l_pl_id;
         Close csr_pl_id;
         if g_debug then
            hr_utility.set_location('Plan Id  : '||l_pl_id,45);
         end if;


         If l_pl_id IS NOT NULL Then
             -- Check plan exists in GSP Program

             l_pl_exists_in_grdldr := chk_pl_exists_in_grdldr(p_pl_id =>l_pl_id,
	                                                      p_effective_date =>p_effective_date,
                                                              p_Business_Group_Id  =>p_business_group_id);

             if g_debug then
                  hr_utility.set_location(' Plan Exists in Grdldr (Y/N) : '||l_pl_exists_in_grdldr,55);
             end if;


         End if;

   End if;
  if g_debug then
     hr_utility.set_location('Finally Opt Exists in Gsp Pgm (Y/N)'||l_pl_exists_in_grdldr,90);
     hr_utility.set_location('Leaving'||l_proc,100);
  end if;

  return l_pl_exists_in_grdldr;

Exception
   when others then
     return 'N';
End chk_opt_exists_in_gsp_pgm;



--
---------------------------pgm_ins_val-----------------------------
--
procedure pgm_ins_val(p_Pgm_Id            in Number,
                      p_Business_Group_Id in Number,
                      p_Short_Name        in Varchar2,
                      p_Short_Code        in Varchar2,
                      p_Effective_Date    in Date,
                      p_Dflt_Pgm_Flag     in Varchar2) IS
--
--
/*
Purpose : This proedure performs these validataions
1) Grade Ladder Short Name, Short Code (only if entered) must be unique
   with in the business group.
2) Check there is only one Default Grade Ladder for a Business group.
*/
--
--
l_proc   varchar2(72) := g_package||'pgm_ins_val';
l_dummy  Char(1);

Cursor csr_short_name
 IS
 Select null
 From   Ben_Pgm_F
 Where  Pgm_Id <> nvl(p_pgm_id,-1)
 And    Short_Name = nvl(p_short_name,-1)
 And    Business_Group_Id = p_business_group_id
 And    PGM_TYP_CD ='GSP' ;


Cursor csr_short_code
 IS
 Select null
 From   Ben_Pgm_F
 Where  Pgm_Id <> nvl(p_pgm_id,-1)
 And    Short_Code = nvl(p_short_code,-1)
 And    Business_Group_Id = p_business_group_id
 And    PGM_TYP_CD ='GSP' ;


Cursor csr_default_grdldr IS
 Select   Null
 From     ben_pgm_f
 Where    pgm_id <> nvl(p_pgm_id,-1)
 And      PGM_TYP_CD ='GSP'
 And      Dflt_Pgm_Flag = 'Y'
 And      business_group_id = p_business_group_id
 And      effective_end_date>= p_effective_date;

Begin
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
hr_utility.set_location('p_Short_Name:'||p_Short_Name, 20);
hr_utility.set_location('p_Short_Code:'||p_Short_Code, 25);
hr_utility.set_location('p_Dflt_Pgm_Flag:'||p_Dflt_Pgm_Flag, 30);
end if;


--
--
if g_debug then
hr_utility.set_location('Chk Short Name...', 35);
end if;
--
--
If p_Short_Name IS NOT NULL Then
    Open csr_short_name;
    Fetch csr_short_name into l_dummy;
    If csr_short_name%Found then
        Close csr_short_name;
        hr_utility.set_message(8302,'PQH_GSP_GL_SHT_NAME_UNQ');
        hr_utility.raise_error;
    End If;
    Close csr_short_name;
End If;
--
--
if g_debug then
hr_utility.set_location('Chk Short Code....', 40);
end if;
--
--
If p_Short_Code IS NOT NULL Then
   Open csr_short_code;
   Fetch csr_short_code into l_dummy;
   If csr_short_code%Found then
       Close csr_short_code;
       hr_utility.set_message(8302,'PQH_GSP_GL_SHT_CODE_UNQ');
       hr_utility.raise_error;
   End If;
   Close csr_short_code;
End If;
--
--
if g_debug then
hr_utility.set_location('Chk Default Grade Ladder....', 45);
end if;
--
--
If p_Dflt_Pgm_Flag ='Y'  Then
   Open csr_default_grdldr;
   Fetch csr_default_grdldr into l_dummy;
   If csr_default_grdldr%Found then
       Close csr_default_grdldr;
       hr_utility.set_message(8302,'PQH_GSP_BEN_DFLT_GRDLDR');
       hr_utility.raise_error;
   End If;
   Close csr_default_grdldr;
End If;
--
--
if g_debug then
hr_utility.set_location('Leaving:'||l_proc, 100);
end if;

End;

--
---------------------------pgm_upd_val-----------------------------
--
procedure pgm_upd_val(p_Pgm_Id                   in Number,
                      p_Business_Group_Id        in Number,
                      p_Short_Name               in Varchar2,
                      p_Short_Code               in Varchar2,
                      p_Effective_Date           in Date,
                      p_Dflt_Pgm_Flag            in Varchar2,
                      p_Pgm_Typ_Cd               in Varchar2,
                      p_pgm_Stat_cd              in Varchar2,
                      p_Use_Prog_Points_Flag     In Varchar2,
                      p_Acty_Ref_Perd_Cd         In Varchar2 ,
                      p_Pgm_Uom                  In Varchar2) IS


/*
Purpose : This procedure perorms these Validations.
1) Check there is only one Default Grade Ladder for a Business group.
2) Grade Ladder Short Name, Short Code (only if entered) must be unique with in the business group.
3) If Employee Placements on this Grade Ladder Or Grades are attached to Program then
   *** 1.	Cannot Change Currency, Rate Period
   *** 2.	Cannot Change Use Progression Points flag
   *** 3.	Cannot Change Program Type
   *** 4.       Cannot Change Program Status

*/
l_proc                 Varchar2(72) := g_package||'pgm_upd_val';
l_dummy                Char(1);
l_pgm_type             Ben_Pgm_F.PGM_TYP_CD%Type;
l_pgm_status           Ben_Pgm_F.PGM_STAT_CD%Type;
l_pgm_points_flag      Ben_Pgm_F.USE_PROG_POINTS_FLAG%Type;
l_rate_period          Ben_Pgm_F.ACTY_REF_PERD_CD%Type;
l_currency             Ben_Pgm_F.PGM_UOM%Type;
l_exists               Varchar2(1) := 'N';
l_grd_exists           Varchar2(1) := 'N';



Begin
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
hr_utility.set_location('p_Short_Name:'||p_Short_Name, 20);
hr_utility.set_location('p_Short_Code:'||p_Short_Code, 25);
hr_utility.set_location('p_Dflt_Pgm_Flag:'||p_Dflt_Pgm_Flag, 30);
hr_utility.set_location('p_Pgm_Typ_Cd:'||p_Pgm_Typ_Cd, 35);
hr_utility.set_location('p_pgm_Stat_cd:'||p_pgm_Stat_cd, 40);
hr_utility.set_location('p_Acty_Ref_Perd_Cd:'||p_Acty_Ref_Perd_Cd, 41);
hr_utility.set_location('p_Pgm_Uom:'||p_Pgm_Uom, 42);
end if;

pqh_gsp_ben_validations.pgm_ins_val( p_Pgm_Id            => p_pgm_id,
                                     p_Business_Group_Id => p_business_group_id,
                                     p_Short_Name        => p_short_name,
                                     p_Short_Code        => p_short_code,
                                     p_Effective_Date    => p_effective_date,
                                     p_Dflt_Pgm_Flag     => p_Dflt_Pgm_Flag);


l_exists := chk_pgm_emp_assign(p_Pgm_Id         => p_Pgm_Id,
                            p_Business_Group_Id => p_Business_Group_Id,
                            p_Effective_Date    => p_Effective_Date);

if g_debug then
hr_utility.set_location('Emp Exists on Pgm (Y/N) :'||l_exists, 95);
end if;

l_grd_exists :=  chk_pgm_has_grades(p_Pgm_Id         => p_Pgm_Id,
                                           p_Business_Group_Id => p_Business_Group_Id,
                                           p_Effective_Date    => p_Effective_Date);

if g_debug then
hr_utility.set_location('Pgm has Grades (Y/N) :'||l_grd_exists, 100);
end if;

-- changed for Bug 7114098. Check for l_grd_exists has been removed as this check has already been
-- done earlier in pqh_gsp_utility.chk_grdldr_grd_curreny_rate, which is called well before the
-- current procedure.

-- If (l_exists = 'Y' OR l_grd_exists = 'Y') then
   IF (l_exists = 'Y') THEN                          -- bug 7114098

     if g_debug then
     hr_utility.set_location('Old Pgm Type :'||ben_pgm_shd.g_old_rec.pgm_typ_cd, 100);
     hr_utility.set_location('Old Pgm Status :'||ben_pgm_shd.g_old_rec.pgm_Stat_cd, 110);
     hr_utility.set_location('Old Points Flag :'||ben_pgm_shd.g_old_rec.Use_Prog_Points_Flag, 120);
     hr_utility.set_location('Old Rate Period :'||ben_pgm_shd.g_old_rec.Acty_Ref_Perd_Cd, 125);
     hr_utility.set_location('Old Currency :'||ben_pgm_shd.g_old_rec.Pgm_Uom, 130);
     end if;


     -- Program Type Cannot be Changed.
      if (ben_pgm_shd.g_old_rec.pgm_typ_cd <> p_Pgm_Typ_Cd) then
                  hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PGM_TYPE');
                  hr_utility.raise_error;
      end if;

     -- Program Status Cannot be Changed.
      if (ben_pgm_shd.g_old_rec.pgm_Stat_cd = 'A' And (ben_pgm_shd.g_old_rec.pgm_Stat_cd  <> p_pgm_Stat_cd)) then
                  hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PGM_STATUS');
                  hr_utility.raise_error;
     end if;

      -- Progression Points flag  Cannot be Changed.
     if (ben_pgm_shd.g_old_rec.use_prog_points_flag  <> p_Use_Prog_Points_Flag) then
                  hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PGM_PRG_FLAG');
                  hr_utility.raise_error;
      end if;


      -- Rate Period Cannot be Changed.
      if (ben_pgm_shd.g_old_rec.Acty_Ref_Perd_Cd <> p_Acty_Ref_Perd_Cd) then
                  hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PGM_RATE_PRD');
                  hr_utility.raise_error;
      end if;

      -- Currency Cannot be Changed.
      if (ben_pgm_shd.g_old_rec.Pgm_Uom <> p_Pgm_Uom) then
                  hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PGM_CURRENCY');
                  hr_utility.raise_error;
      end if;

 End if; -- emp Exists

if g_debug then
hr_utility.set_location('Leaving '||l_proc,100);
end if;

End;



--
---------------------------pgm_del_val-----------------------------
--
procedure pgm_del_val(p_Pgm_Id            in Number,
                      p_Business_Group_Id in Number,
                      p_Effective_Date    in Date
                      ) IS
/*
Purpose : This procedure perorms these Validations.
1) Cannot Delete a Grade Ladder if Employee Placements exists on this Grade Ladder.
*/

l_proc       varchar2(72) := g_package||'pgm_del_val';
l_exists     Varchar2(1) := 'N';

Begin
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
end if;

l_exists := chk_pgm_emp_assign(p_Pgm_Id         => p_Pgm_Id,
                            p_Business_Group_Id => p_Business_Group_Id,
                            p_Effective_Date    => p_Effective_Date);

if g_debug then
hr_utility.set_location('Emp Exists on Pgm (Y/N) :'||l_exists, 25);
end if;

If l_exists = 'Y' then
       hr_utility.set_message(8302,'PQH_GSP_BEN_NOT_DEL_PGM');
       hr_utility.raise_error;
End If;

if g_debug then
hr_utility.set_location('Leaving '||l_proc,100);
end if;

End pgm_del_val;


--
---------------------------pgm_validations-----------------------------
--
procedure pgm_validations(p_pgm_id                      in Number,
                          p_dml_operation               in Varchar2,
                          p_effective_date              in Date,
                          p_business_group_id           in Number        Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_short_name                  in Varchar2      Default NULL,
                          p_short_code                  in Varchar2      Default NULL,
                          p_Dflt_Pgm_Flag               in Varchar2      Default 'N',
                          p_Pgm_Typ_Cd                  in Varchar2      Default NULL,
                          p_pgm_Stat_cd                 in Varchar2      Default 'I',
                          p_Use_Prog_Points_Flag        in Varchar2      Default 'N',
                          p_Acty_Ref_Perd_Cd            In Varchar2      Default NULL,
                          p_Pgm_Uom                     In Varchar2      Default NULL)



IS
l_proc             Varchar2(72) := g_package||'pgm_validations';
l_pgm_type_is_gsp  Varchar2(1) := 'N';

begin
-- validations to be performed in this are
-- people shouldnot be assigned to the deleted grade ladder
-- only one default grade ladder
-- currency periodicity is not changed, which doesnot match with other setup
-- use points flag is not changed, which doesnot match with other setup
-- etc


--
--
if g_debug then
hr_utility.set_location('Entering '||l_proc,5);
hr_utility.set_location('p_Pgm_Id :'||p_Pgm_Id ,10);
hr_utility.set_location('p_Business_Group_Id:'||p_Business_Group_Id, 15);
hr_utility.set_location('p_Short_Name:'||p_Short_Name, 20);
hr_utility.set_location('p_Short_Code:'||p_Short_Code, 25);
hr_utility.set_location('p_Dflt_Pgm_Flag:'||p_Dflt_Pgm_Flag, 30);
hr_utility.set_location('p_pgm_Stat_cd:'||p_pgm_Stat_cd, 35);
hr_utility.set_location('p_Use_Prog_Points_Flag:'||p_Use_Prog_Points_Flag, 40);
hr_utility.set_location('p_Acty_Ref_Perd_Cd:'||p_Acty_Ref_Perd_Cd, 45);
hr_utility.set_location('p_Pgm_Uom:'||p_Pgm_Uom, 50);

end if;

 l_pgm_type_is_gsp  := is_pgm_type_gsp(p_Pgm_Id  => p_pgm_id,
                            p_Business_Group_Id     => p_business_group_id,
                            p_Effective_Date        => p_effective_date );

 if g_debug then
 hr_utility.set_location('Is PGM Type is GSP (Y/N):'||l_pgm_type_is_gsp, 85);
 end if;

 If l_pgm_type_is_gsp = 'Y' Then

    --
    -- Perform Insert Validations
    --
    If p_dml_operation = 'I' then

         if g_debug then
            hr_utility.set_location(' PGM Insert Validations ', 90);
         end if;
         pqh_gsp_ben_validations.pgm_ins_val( p_Pgm_Id       => p_pgm_id,
                                         p_Business_Group_Id => p_business_group_id,
                                         p_Short_Name        => p_short_name,
                                         p_Short_Code        => p_short_code,
                                         p_Effective_Date    => p_effective_date,
                                         p_Dflt_Pgm_Flag     => p_Dflt_Pgm_Flag);
    End if;
    --
    -- Perform Update Validations
    --
    If p_dml_operation = 'U' then

        if g_debug then
           hr_utility.set_location(' PGM Update Validations ', 95);
        end if;
        pqh_gsp_ben_validations.pgm_upd_val( p_Pgm_Id        => p_pgm_id,
                                         p_Business_Group_Id => p_business_group_id,
                                         p_Short_Name        => p_short_name,
                                         p_Short_Code        => p_short_code,
                                         p_Effective_Date    => p_effective_date,
                                         p_Dflt_Pgm_Flag     => p_Dflt_Pgm_Flag,
                                         p_Pgm_Typ_Cd                => p_Pgm_Typ_Cd,
                                         p_pgm_Stat_cd               => p_pgm_Stat_cd,
                                         p_Use_Prog_Points_Flag      => p_Use_Prog_Points_Flag,
                                         p_Acty_Ref_Perd_Cd          => p_Acty_Ref_Perd_Cd,
                                         p_Pgm_Uom                   => p_Pgm_Uom);
    End if;

    --
    -- Perform Delete Validations
    --

    If p_dml_operation = 'D' then

        if g_debug then
           hr_utility.set_location(' PGM Delete Validations ', 100);
        end if;
        pqh_gsp_ben_validations.pgm_del_val( p_Pgm_Id        => p_pgm_id,
                                         p_Business_Group_Id => p_business_group_id,
                                         p_Effective_Date    => p_effective_date);
    End if;

End If;

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,150);
end if;

end pgm_validations;


--
---------------------------pl_ins_val-----------------------------
--
procedure pl_ins_val(p_pl_id          in number,
                     p_effective_date in date)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'pl_ins_val';
Begin
if g_debug then
    hr_utility.set_location('Entering'||l_proc,10);
end if;

if g_debug then
    hr_utility.set_location('Leaving'||l_proc,100);
end if;

end pl_ins_val;

--
---------------------------pl_upd_val-----------------------------
--
procedure pl_upd_val(p_pl_id                   In number,
                     p_effective_date          In date,
                     p_Business_Group_Id       In Number,
                     p_pl_Typ_Id               In Number,
                     p_Mapping_Table_PK_ID     In Number,
                     p_pl_stat_cd                  IN Varchar2)
IS
/*
Purpose : To Perform these Validations.
1) Once the plan is attached to Grade Ladder through PLIP.
  *** 1.  Cannot Change Plan Type
  *** 2.  Cannot Update Plan Status from Activate to Inactive/Closed/Pending

2) User Cannot change Grade which is mapped to Plan if
     Plan is mapped to Grade and
     Plan is attached to Grade Ladder through PLIP and
     PLIP has Employee placements

*/
l_proc               Varchar2(72) := g_package||'pl_upd_val';
l_exists             Varchar2(10);
l_exist_pl_type_cd   BEN_PL_TYP.OPT_TYP_CD%Type;
l_new_pl_type_cd     BEN_PL_TYP.OPT_TYP_CD%Type;
l_grade_id           BEN_PL_F.Mapping_Table_PK_ID%Type;
l_status             BEN_PL_F.PL_STAT_CD%Type;
l_plip_id            Number;
l_emp_exists         Varchar2(1) :='N';
l_plan_Typ_Id        Number;



Cursor  csr_pl_type (l_plan_Typ_Id IN Number)
IS
Select  OPT_TYP_CD
From    BEN_PL_TYP_F Type
Where   Pl_Typ_Id = l_plan_Typ_Id
And     Business_Group_id = p_business_group_id
And     p_effective_date BETWEEN effective_start_date
And     nvl(effective_end_date,hr_general.end_of_time);


Cursor csr_plip_id
IS
Select  PLIP_ID
From    BEN_PLIP_F
Where   Pl_Id = p_pl_Id
And     business_group_id = p_business_group_id
And     p_effective_date Between Effective_Start_Date
And     nvl(Effective_End_Date, hr_general.end_of_time)
And     PLIP_STAT_CD = 'A';


Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_pl_id'||p_pl_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_pl_Typ_Id'||p_pl_Typ_Id,25);
hr_utility.set_location('Old pl_Typ_Id'||ben_pln_shd.g_old_rec.PL_TYP_ID,30);
hr_utility.set_location('p_Mapping_Table_PK_ID'||p_Mapping_Table_PK_ID,35);
hr_utility.set_location('Old Mapping_Table_PK_ID'||ben_pln_shd.g_old_rec.Mapping_Table_PK_ID,40);
hr_utility.set_location('p_pl_stat_cd'||p_pl_stat_cd,45);
hr_utility.set_location('Old pl_stat_cd'||ben_pln_shd.g_old_rec.pl_stat_cd,60);
end if;

l_exists := chk_pl_exists_in_grdldr(p_pl_id => p_pl_id,
                        p_effective_date    => p_effective_date,
                        p_Business_Group_Id => p_Business_Group_Id);
--
--
if g_debug then
   hr_utility.set_location('Plan Exists in Program : '||l_exists,90);
end if;
If l_exists = 'Y' Then

     Open csr_pl_type(ben_pln_shd.g_old_rec.PL_TYP_ID);
     Fetch csr_pl_type into l_exist_pl_type_cd;
     Close csr_pl_type;


     if g_debug then
        hr_utility.set_location('Old Plan Type : '||l_exist_pl_type_cd,100);
     end if;

     If (l_exist_pl_type_cd = 'GSP' ) Then

        --
        -- Cannot Update Plan Type
        --

        Open csr_pl_type(p_pl_Typ_Id);
        Fetch csr_pl_type into l_new_pl_type_cd;
        Close csr_pl_type;
        if g_debug then
            hr_utility.set_location('New Plan Type : '||l_new_pl_type_cd,145);
        end if;


        if g_debug then
	   hr_utility.set_location('New Plan Type : '||l_new_pl_type_cd,155);
        end if;
        If (l_exist_pl_type_cd <> l_new_pl_type_cd ) Then
            hr_utility.set_message(8302,'PQH_GSP_NOT_PL_UPD_PGM_TYPE');
            hr_utility.raise_error;
        End If;

      --
	-- Cannot Update Status
	--

	if g_debug then
	   hr_utility.set_location('Old Plan Status  : '||ben_pln_shd.g_old_rec.pl_stat_cd,165);
	end if;


	If (ben_pln_shd.g_old_rec.pl_stat_cd = 'A' And  ben_pln_shd.g_old_rec.pl_stat_cd <> p_pl_stat_cd)Then
	   hr_utility.set_message(8302,'PQH_GSP_NOT_PL_UPD_PGM_STATUS');
	   hr_utility.raise_error;
        End If;

       --
       -- Cannot Update Grade Id if Employees are placed on Grade
       --

       -- Get PLIP Id

       Open csr_plip_id;
       Fetch csr_plip_id into l_plip_id;
       Close csr_plip_id;
       if g_debug then
          hr_utility.set_location('PLIP Id : '||l_plip_id,175);
       end if;


       if l_plip_id IS NOT NULL Then
           l_emp_exists := chk_plip_emp_assign(p_plip_id           => l_plip_id,
                                               p_effective_date    => p_effective_date,
                                               p_business_group_id =>p_Business_Group_Id);
           if g_debug then
              hr_utility.set_location('Emp Placements exists (Y/N) : '||l_emp_exists,190);
           end if;

           if l_emp_exists = 'Y' Then

                if g_debug then
                    hr_utility.set_location('Old Grade Id  : '||ben_pln_shd.g_old_rec.Mapping_Table_PK_ID,200);
                end if;


                If (ben_pln_shd.g_old_rec.Mapping_Table_PK_ID <> p_Mapping_Table_PK_ID)Then
                       hr_utility.set_message(8302,'PQH_GSP_NOT_PL_UPD_EMP_GRD_ID');
                       hr_utility.raise_error;
                End If;
          end if;

        end if;-- plip id is not null

     end if;  -- GSP

  End If;  -- Pl Exists in PGM

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,300);
end if;

end pl_upd_val;

--
---------------------------pl_del_val-----------------------------
--
procedure pl_del_val(p_pl_id          in number,
                     p_effective_date in date)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'pl_del_val';
Begin
if g_debug then
    hr_utility.set_location('Entering'||l_proc,10);
end if;

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,100);
end if;

end pl_del_val;


--
---------------------------pl_validations-----------------------------
--
procedure pl_validations(p_pl_id              In number,
                         p_effective_date     In date,
                         p_Business_Group_Id  In Number     Default hr_general.GET_BUSINESS_GROUP_ID,
                         p_dml_operation      In varchar2,
                         p_pl_Typ_Id          In Number     Default NULL,
                         p_Mapping_Table_PK_ID     In Number    Default NULL,
                         p_pl_stat_cd              IN Varchar2  Default 'I')
IS

l_proc   varchar2(72) := g_package||'pl_validations';
begin
-- validations to be performed in this routine are
-- there should not be any assignment on the grade linked if getting deleted or disabled
-- this should be the only plan linked to the grade
-- etc
if g_debug then
   hr_utility.set_location('Entering'||l_proc,5);
   hr_utility.set_location('p_pl_id'||p_pl_id,10);
   hr_utility.set_location('p_dml_operation'||p_dml_operation,11);
   hr_utility.set_location('p_effective_date'||p_effective_date,15);
   hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
   hr_utility.set_location('p_pl_Typ_Id'||p_pl_Typ_Id,24);
   hr_utility.set_location('p_Mapping_Table_PK_ID'||p_Mapping_Table_PK_ID,26);
   hr_utility.set_location('p_pl_stat_cd'||p_pl_stat_cd,28);
end if;

If p_dml_operation = 'I' Then
    if g_debug then
       hr_utility.set_location('Plan Insert Validations',40);
    end if;
    pl_ins_val(p_pl_id          => p_pl_id,
               p_effective_date => p_effective_date);
end if;

If p_dml_operation = 'U' Then
   if g_debug then
      hr_utility.set_location('Plan Update Validations',45);
   end if;
   pl_upd_val(p_pl_id               => p_pl_id,
              p_effective_date      => p_effective_date,
              p_Business_Group_Id   => p_Business_Group_Id,
              p_pl_Typ_Id           => p_pl_Typ_Id,
              p_Mapping_Table_PK_ID => p_Mapping_Table_PK_ID,
              p_pl_stat_cd          => p_pl_stat_cd);
end if;

If p_dml_operation = 'D' Then
    if g_debug then
       hr_utility.set_location('Plan Delete Validations',50);
    end if;
    pl_del_val(p_pl_id          => p_pl_id,
               p_effective_date => p_effective_date);
end if;

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,100);
end if;

end pl_validations;

--
---------------------------plip_ins_val-----------------------------
--
procedure plip_ins_val( p_plip_id            In number,
                        p_effective_date     In date,
                        p_business_group_id  In Number)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'plip_ins_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

if g_debug then
hr_utility.set_location('Leaving'||l_proc,100);
end if;

end plip_ins_val;

--
---------------------------plip_upd_val-----------------------------
--
procedure plip_upd_val( p_plip_id            In number,
                        p_effective_date     In date,
                        p_business_group_id  In Number,
                        p_Plip_Stat_Cd        In Varchar)
IS
/*
Purpose : To Perform these Validations.
1) PLIP Record Status cannot be changed from Activate to Inactive/Closed/Pending
   if employee placemnents exists on this PLIP.

*/
l_proc          Varchar2(72) := g_package||'plip_upd_val';
l_exists        Varchar2(1)  :='N';
l_status        Ben_PlIP_F.PLIP_STAT_CD%Type;


Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_Plip_Stat_Cd'||p_Plip_Stat_Cd,20);
hr_utility.set_location('Old Plip_Stat_Cd'||ben_cpp_shd.g_old_rec.PLIP_STAT_CD,25);
end if;

-- Check Emp Placements Exists on PLIP Rec

-- If Y then emp exists on PLIP Rec else Not Exists

l_exists := chk_plip_emp_assign(p_plip_id        =>  p_plip_id,
                             p_effective_date    => p_effective_date ,
                             p_business_group_id => p_business_group_id);
if g_debug then
hr_utility.set_location('Emp Placements Exists on PLIP Rec (Y/N) :'||l_exists,30);
end if;
If l_exists = 'Y' Then
      --


           if (ben_cpp_shd.g_old_rec.PLIP_STAT_CD = 'A' And ben_cpp_shd.g_old_rec.PLIP_STAT_CD <> p_Plip_Stat_Cd) Then
                hr_utility.set_location('Cannot Change Status ',55);
                hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PLIP_STATUS');
                hr_utility.raise_error;
          end if;

End If;

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,100);
end if;

end plip_upd_val;

--
---------------------------plip_del_val-----------------------------
--
procedure plip_del_val(p_plip_id           In number,
                       p_effective_date    In date,
                       p_business_group_id In Number)
IS
/*
Purpose : To Perform these Validations.
1) PLIP Record cannot be deleted if employee placemnents exists on this PLIP
*/
l_proc          Varchar2(72) := g_package||'plip_del_val';
l_exists        Varchar2(1)  :='N';

Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

-- Check Emp Placements Exists on PLIP Rec if Y then emp exists on PLIP Rec else Not Exists

     l_exists := chk_plip_emp_assign(p_plip_id        =>  p_plip_id,
                                     p_effective_date    => p_effective_date ,
                                     p_business_group_id => p_business_group_id);

     if g_debug then
       hr_utility.set_location('Emp Placements Exists on PLIP Rec (Y/N) :'||l_exists,30);
     end if;
     If l_exists = 'Y' Then

         if g_debug then
             hr_utility.set_location('Emp Placements are exists',50);
         end if;
         hr_utility.set_message(8302,'PQH_GSP_NOT_DEL_PLIP');
         hr_utility.raise_error;
      end if;

if g_debug then
   hr_utility.set_location('Leaving'||l_proc,100);
end if;
end plip_del_val;


--
---------------------------plip_validations-----------------------------
--

procedure plip_validations(p_plip_id           In Number,
                           p_effective_date    In Date,
                           p_dml_operation     In Varchar2,
                           p_business_group_id In Number    Default hr_general.GET_BUSINESS_GROUP_ID,
                           p_Plip_Stat_Cd        In Varchar Default 'I')
IS
l_proc    Varchar2(72) := g_package||'plip_validations';
l_is_pgm_type_gsp Varchar2(1) := 'N';


begin
-- validations to be performed in this routine are
-- there should not be any assignment on the grade linked if getting deleted or
-- disabled etc
if g_debug then
hr_utility.set_location('Entering'||l_proc,10);
hr_utility.set_location('p_plip_id'||p_plip_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_Plip_Stat_Cd'||p_Plip_Stat_Cd,25);
hr_utility.set_location('Old Plip_Stat_Cd'||ben_cpp_shd.g_old_rec.PLIP_STAT_CD,30);
hr_utility.set_location('p_dml_operation'||p_dml_operation,35);
end if;




      If p_dml_operation = 'I' Then
         if g_debug then
            hr_utility.set_location('PLIP Insert Validations',45);
         end if;

         plip_ins_val( p_plip_id           => p_plip_id,
                  p_effective_date    => p_effective_date,
                  p_business_group_id => p_business_group_id);
      end if;

      If p_dml_operation = 'U' Then
           if g_debug then
              hr_utility.set_location('PLIP Update Validations',55);
           end if;
           plip_upd_val( p_plip_id           => p_plip_id,
                  p_effective_date           => p_effective_date,
                  p_business_group_id        => p_business_group_id,
                  p_Plip_Stat_Cd             => p_Plip_Stat_Cd
                  );
      end if;

     If p_dml_operation = 'D' Then
         if g_debug then
            hr_utility.set_location('PLIP Delete Validations',65);
         end if;
         plip_del_val( p_plip_id           => p_plip_id,
                       p_effective_date    => p_effective_date,
                       p_business_group_id => p_business_group_id);
      end if;



if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end plip_validations;


--
---------------------------opt_ins_val-----------------------------
--
procedure opt_ins_val(p_opt_id          in number,
                     p_effective_date   in date,
                     p_business_group_id in number)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'opt_ins_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_opt_id'||p_opt_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end opt_ins_val;

--
---------------------------opt_upd_val-----------------------------
--
procedure opt_upd_val(p_opt_id            in number,
                      p_effective_date    in date,
                      p_business_group_id in number,
                      p_mapping_table_pk_id in Number)
IS
/*
Purpose : To Perform these Validations.
1) If Option exists in Program through OIPL then
      1. Cannot Update Option Status from Activate to Inactive/Closed/Pending
      2. Cannot Update Option Type.
2) User Cannot change Step which is mapped to Option if
     Option is mapped to Step and
     Option is attached to Grade Ladder through OIPL and
     OIPL has Employee placements

*/
l_proc                   Varchar2(72) := g_package||'opt_upd_val';
l_opt_exist_in_pgm       Varchar2(1) := 'N';
l_oipl_has_emp_assign    Varchar2(1) := 'N';
l_oipl_id                Number;
l_point_id               Number;

Cursor csr_oipl_id
IS
Select oipl_id
From   BEN_OIPL_F
Where  opt_id = p_opt_id
AND    Business_group_id = p_business_group_id
AND    p_effective_date  BETWEEN effective_start_date
AND    nvl(effective_end_date,hr_general.end_of_time)
And    OIPL_STAT_CD = 'A';

Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_opt_id'||p_opt_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_mapping_table_pk_id'||p_mapping_table_pk_id,25);
hr_utility.set_location('Old mapping_table_pk_id'||ben_opt_shd.g_old_rec.MAPPING_TABLE_PK_ID,30);
end if;


-- Checks OPT has GSP Type and OPT exists in GSP Program
l_opt_exist_in_pgm := chk_opt_exists_in_gsp_pgm(p_opt_id => p_opt_id,
                                  p_effective_date       => p_effective_date,
                                  p_Business_Group_Id    => p_business_group_id);

if g_debug then
hr_utility.set_location('OPT exists in GSP Program (Y/N) :'||l_opt_exist_in_pgm,55);
end if;

If (l_opt_exist_in_pgm = 'Y') Then

   -- Get OIPL Id
   Open csr_oipl_id;
   Fetch csr_oipl_id into l_oipl_id;
   Close csr_oipl_id;
   if g_debug then
   hr_utility.set_location('OIPL Id :'||l_oipl_id,60);
   end if;

   If l_oipl_id IS NOT NULL Then

         -- Check OIPL has Emp Placements
         l_oipl_has_emp_assign  := chk_oipl_emp_assign(p_oipl_id           => l_oipl_id,
                                                    p_effective_date       => p_effective_date,
                                                    p_business_group_id    => p_business_group_id);
         if g_debug then
            hr_utility.set_location('OIPL has Emp Placements (Y/N) :'||l_oipl_has_emp_assign,70);
         end if;

         If l_oipl_has_emp_assign = 'Y' Then


             if g_debug then
                hr_utility.set_location('Old Point Id :'||ben_opt_shd.g_old_rec.MAPPING_TABLE_PK_ID,80);
             end if;

             -- Cannot change Step which is mapped to Option
             If (ben_opt_shd.g_old_rec.MAPPING_TABLE_PK_ID <> p_mapping_table_pk_id) Then
                    hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_OPT_STEP_ID');
                    hr_utility.raise_error;
             End if;


         End if; -- l_oipl_has_emp_assign

   End if; --l_oipl_id IS NOT NULL


end if; --l_opt_exist_in_pgm

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end opt_upd_val;

--
---------------------------opt_del_val-----------------------------
--
procedure opt_del_val(p_opt_id           in number,
                     p_effective_date    in date,
                     p_business_group_id in number)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'opt_del_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_opt_id'||p_opt_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end opt_del_val;


--
---------------------------opt_validations-----------------------------
--

procedure opt_validations(p_opt_id            in number,
                          p_effective_date    in date,
                          p_dml_operation     in varchar2,
                          p_Business_Group_Id in Number   Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_mapping_table_pk_id in Number Default NULL)
IS
l_proc   varchar2(72) := g_package||'plip_validations';
begin
-- validations to be performed in this routine are
-- there should not be any assignment on the step linked if getting deleted or disabled
-- this should be only option linked to the point
-- etc
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_opt_id'||p_opt_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_dml_operation'||p_dml_operation,25);
hr_utility.set_location('p_mapping_table_pk_id'||p_mapping_table_pk_id,35);
hr_utility.set_location('Old mapping_table_pk_id'||ben_opt_shd.g_old_rec.MAPPING_TABLE_PK_ID,40);
end if;


if p_dml_operation = 'I' Then
   if g_debug then
      hr_utility.set_location('Perform OPT Insert Validations',45);
   end if;

      opt_ins_val(p_opt_id            => p_opt_id,
                  p_effective_date    => p_effective_date,
                  p_business_group_id => p_Business_Group_Id);

end if;

if p_dml_operation = 'U' Then
   if g_debug then
      hr_utility.set_location('Perform OPT Update Validations',50);
   end if;

      opt_upd_val(p_opt_id            => p_opt_id,
                  p_effective_date    => p_effective_date,
                  p_business_group_id => p_Business_Group_Id,
                  p_mapping_table_pk_id => p_mapping_table_pk_id);

end if;

if p_dml_operation = 'D' Then
   if g_debug then
      hr_utility.set_location('Perform OPT Delete Validations',55);
   end if;

   opt_del_val(p_opt_id            => p_opt_id,
               p_effective_date    => p_effective_date,
               p_business_group_id => p_Business_Group_Id);
end if;



if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end opt_validations;

--
---------------------------oipl_ins_val-----------------------------
--
procedure oipl_ins_val(p_oipl_id          in number,
                     p_effective_date in date)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'oipl_ins_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,10);
end if;

if g_debug then
hr_utility.set_location('Leaving'||l_proc,100);
end if;

end oipl_ins_val;

--
---------------------------oipl_upd_val-----------------------------
--
procedure oipl_upd_val(p_oipl_id           in number,
                       p_effective_date    in date,
                       p_Business_Group_Id in Number,
                       p_oipl_stat_cd      In Varchar2)
IS
/*
Purpose : To Perform these Validations.
1) OIPL Status cannot be changed from Activate to Inactive/Closed/Pending
   If OIPL is mapped to Step and the step have employee assignments.

*/
l_proc               Varchar2(72) := g_package||'oipl_upd_val';
l_status             BEN_OIPL_F.OIPL_STAT_CD%Type;
l_emp_exists         Varchar2(1)  := 'N';
l_oipl_has_gsp_type  Varchar2(1)  := 'N';

Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_oipl_id'||p_oipl_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_oipl_stat_cd'||p_oipl_stat_cd,25);
end if;


l_emp_exists := chk_oipl_emp_assign(p_oipl_id    => p_oipl_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id);

if g_debug then
  hr_utility.set_location('Step Has Emp Placements (Y/N) : '||l_emp_exists ,30);
end if;

l_oipl_has_gsp_type := chk_oipl_has_gsp_type(p_oipl_id          => p_oipl_id,
                                             p_effective_date   => p_effective_date,
                                             p_business_group_id=> p_business_group_id);
if g_debug then
  hr_utility.set_location('OIPL has GSP Type (Y/N) : '||l_oipl_has_gsp_type ,40);
end if;

if (l_oipl_has_gsp_type = 'Y' And l_emp_exists = 'Y') Then


    if g_debug then
      hr_utility.set_location('Old OIPL Status : '||ben_cop_shd.g_old_rec.OIPL_STAT_CD,35);
    end if;

    if (ben_cop_shd.g_old_rec.OIPL_STAT_CD IS NOT NULL And
       (ben_cop_shd.g_old_rec.OIPL_STAT_CD = 'A' And l_status <> p_oipl_stat_cd)) Then
           hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_PLIP_STAT');
           hr_utility.raise_error;
    End if;


end if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end oipl_upd_val;

--
---------------------------oipl_del_val-----------------------------
--
procedure oipl_del_val(p_oipl_id          in number,
                       p_effective_date in date,
                       p_business_group_id In Number)
IS
/*
Purpose : To Perform these Validations.
1) OIPL cannot be deleted if the OIPL is mapped to Step and the Steps have employee assignments.
*/
l_proc               Varchar2(72)   := g_package||'oipl_del_val';
l_emp_exists         Varchar2(1):= 'N';
l_oipl_has_gsp_type  Varchar2(1):= 'N';
Begin

if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_oipl_id'||p_oipl_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
end if;


l_emp_exists := chk_oipl_emp_assign(p_oipl_id    => p_oipl_id,
                             p_effective_date    => p_effective_date,
                             p_business_group_id => p_business_group_id);

if g_debug then
  hr_utility.set_location('Step Has Emp Placements (Y/N) : '||l_emp_exists ,30);
end if;

l_oipl_has_gsp_type := chk_oipl_has_gsp_type(p_oipl_id          => p_oipl_id,
                                             p_effective_date   => p_effective_date,
                                             p_business_group_id=> p_business_group_id);
if g_debug then
  hr_utility.set_location('OIPL has GSP Type (Y/N) : '||l_oipl_has_gsp_type ,40);
end if;

if (l_oipl_has_gsp_type = 'Y' AND l_emp_exists = 'Y') Then
        hr_utility.set_message(8302,'PQH_GSP_NOT_DEL_OIPL');
        hr_utility.raise_error;
end if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end oipl_del_val;


--
---------------------------oipl_validations-----------------------------
--

procedure oipl_validations(p_oipl_id           in number,
                           p_dml_operation     in varchar2,
                           p_effective_date    in date,
                           p_Business_Group_Id in Number   Default hr_general.GET_BUSINESS_GROUP_ID,
                           p_oipl_stat_cd      in Varchar2 Default 'I')
IS
l_proc   varchar2(72) := g_package||'oipl_validations';
begin
-- validations to be performed in this routine are
-- there should not be any assignment on the step linked if getting deleted or disabled
-- this should be only option linked to the point
-- etc

if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_oipl_id'||p_oipl_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_Business_Group_Id'||p_Business_Group_Id,20);
hr_utility.set_location('p_oipl_stat_cd'||p_oipl_stat_cd,25);
hr_utility.set_location('Old oipl_stat_cd'||ben_cop_shd.g_old_rec.OIPL_STAT_CD,30);
hr_utility.set_location('p_dml_operation'||p_dml_operation,45);
end if;

If p_dml_operation = 'I' Then
    if g_debug then
       hr_utility.set_location('OIPL Insert Validations',55);
    end if;
    oipl_ins_val(p_oipl_id        => p_oipl_id,
                 p_effective_date => p_effective_date);
End if;

If p_dml_operation = 'U' Then
    if g_debug then
       hr_utility.set_location('OIPL Update Validations',65);
    end if;
    oipl_upd_val(p_oipl_id           => p_oipl_id,
                 p_effective_date    => p_effective_date,
                 p_Business_Group_Id => p_Business_Group_Id,
                 p_oipl_stat_cd      => p_oipl_stat_cd);
End if;

If p_dml_operation = 'D' Then
    if g_debug then
      hr_utility.set_location('OIPL Delete Validations',75);
    end if;
    oipl_del_val(p_oipl_id           => p_oipl_id,
                 p_effective_date    => p_effective_date,
                 p_business_group_id => p_business_group_id);
End if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end oipl_validations;

--
---------------------------abr_ins_val-----------------------------
--
procedure abr_ins_val(p_abr_id           in number,
                      p_effective_date    in date,
                      p_business_group_id IN Number)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'abr_ins_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_abr_id'||p_abr_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_business_group_id'||p_business_group_id,20);
end if;



if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end abr_ins_val;

--
---------------------------abr_upd_val-----------------------------
--

procedure abr_upd_val(p_abr_id            in number,
                          p_effective_date    in date,
                          p_business_group_id IN Number,
                          p_pl_id             In Number        Default NULL,
                          p_opt_id            In Number        Default NULL,
                          p_acty_typ_cd       In Varchar2      Default NULL,
                          p_Acty_Base_RT_Stat_Cd       In Varchar2 Default 'I')


IS
/*
Purpose : To Perform these Validations.
1) If Rate is attached to Plan/Option and employees placed on PLIP/OIPL.
    1.	Cannot Update Standard Rate Status
    2.	Cannot Update Activity Type

*/
l_proc        Varchar2(72) := g_package||'abr_upd_val';
l_status      BEN_ACTY_BASE_RT_F.ACTY_BASE_RT_STAT_CD%Type;
l_activity    BEN_ACTY_BASE_RT_F.ACTY_TYP_CD%Type;
l_plip_id     Number;
l_oipl_id     Number;

l_pl_exists_in_grdldr     Varchar2(1)   := 'N';
l_plip_emp_assign         Varchar2(1)   := 'N';
l_pl_exists               Varchar2(1)   := 'N';

l_oipl_emp_assign         Varchar2(1)   := 'N';
l_opt_exists_in_gsp_pgm   Varchar2(1)   := 'N';
l_opt_exists              Varchar2(1)   := 'N';




Cursor csr_plip_id
IS
Select PLIP_ID
From   BEN_PLIP_F
Where  PL_ID = p_pl_id
AND    PLIP_STAT_CD = 'A'
And    Business_Group_Id = p_business_group_id
And    p_effective_date BETWEEN effective_start_date
AND    nvl(effective_end_date,hr_general.end_of_time);


Cursor csr_oipl_id
IS
Select OIPL_ID
From   BEN_OIPL_F
Where  OPT_ID = p_opt_id
And    Business_Group_Id = p_business_group_id
And    p_effective_date BETWEEN effective_start_date
AND    nvl(effective_end_date,hr_general.end_of_time);


Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_abr_id'||p_abr_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_business_group_id'||p_business_group_id,20);
hr_utility.set_location('p_pl_id'||p_pl_id,35);
hr_utility.set_location('p_opt_id'||p_opt_id,40);
hr_utility.set_location('p_acty_typ_cd'||p_acty_typ_cd,45);
hr_utility.set_location('p_Acty_Base_RT_Stat_Cd'||p_Acty_Base_RT_Stat_Cd,55);
end if;

-- Check PL Type is GSP
-- And PL exists in PGM through PLIP
-- And PLIP has Emp Placements

 If p_pl_id  IS NOT NULL Then

          l_pl_exists_in_grdldr := chk_pl_exists_in_grdldr(p_pl_id             =>  p_pl_id,
                                                           p_effective_date    =>  p_effective_date,
                                                           p_Business_Group_Id => p_business_group_id);

          if g_debug then
            hr_utility.set_location('PL exists in GSP Pgm (Y/N) '||l_pl_exists_in_grdldr,65);
          end if;


          Open csr_plip_id;
          Fetch csr_plip_id into l_plip_id;
          Close csr_plip_id;
          if g_debug then
             hr_utility.set_location('PLIP Id '||l_plip_id,75);
          end if;

          if l_pl_exists_in_grdldr = 'Y' And l_plip_id IS NOT NULL Then

              l_plip_emp_assign := chk_plip_emp_assign(p_plip_id         =>l_plip_id,
	                                          p_effective_date    =>  p_effective_date,
                                                  p_business_group_id => p_business_group_id);
          end if;

          if g_debug then
            hr_utility.set_location('PLIP has Emp Assignments (Y/N) '||l_plip_emp_assign,85);
          end if;
 End If;
 l_pl_exists := l_plip_emp_assign;



-- Check OPT has GSP
-- And OPT exists in PGM through OIPL
-- And OIPL has Emp Placements


 If p_opt_id  IS NOT NULL Then

          l_opt_exists_in_gsp_pgm := chk_opt_exists_in_gsp_pgm(p_opt_id          =>  p_opt_id,
                                                           p_effective_date    =>  p_effective_date,
                                                           p_Business_Group_Id => p_business_group_id);

          if g_debug then
            hr_utility.set_location('OPT exists in GSP Pgm (Y/N) '||l_opt_exists_in_gsp_pgm,95);
          end if;


          Open csr_oipl_id;
          Fetch csr_oipl_id into l_oipl_id;
          Close csr_oipl_id;
          if g_debug then
             hr_utility.set_location('OIPL Id '||l_oipl_id,100);
          end if;

          if l_opt_exists_in_gsp_pgm = 'Y' And l_plip_id IS NOT NULL Then

              l_oipl_emp_assign := chk_oipl_emp_assign(p_oipl_id         =>l_oipl_id,
	                                          p_effective_date    =>  p_effective_date,
                                                  p_business_group_id => p_business_group_id);
          end if;

          if g_debug then
             hr_utility.set_location('OIPL has Emp Assignments (Y/N) '||l_oipl_emp_assign,105);
          end if;

 End If;
 l_opt_exists := l_oipl_emp_assign;


 If (l_pl_exists = 'Y' OR l_opt_exists = 'Y' ) Then



     if g_debug then
       hr_utility.set_location('Old Status   :  '||ben_abr_shd.g_old_rec.ACTY_BASE_RT_STAT_CD,115);
       hr_utility.set_location('Old Activity :  '||ben_abr_shd.g_old_rec.ACTY_TYP_CD,120);
     end if;

     -- Cannot Change Status
     if ( ben_abr_shd.g_old_rec.ACTY_BASE_RT_STAT_CD='A' And
          ben_abr_shd.g_old_rec.ACTY_BASE_RT_STAT_CD <> p_Acty_Base_RT_Stat_Cd) Then
             hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_ABR_STATUS');
             hr_utility.raise_error;
     end if;

     -- Cannot Change Activity
     if ( ben_abr_shd.g_old_rec.ACTY_TYP_CD <> p_acty_typ_cd ) Then
        hr_utility.set_message(8302,'PQH_GSP_NOT_UPD_ABR_ACTIVITY');
        hr_utility.raise_error;
     end if;

 End If;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end abr_upd_val;

--
---------------------------abr_del_val-----------------------------
--
procedure abr_del_val(p_abr_id            in number,
                      p_effective_date    in date,
                      p_business_group_id IN Number)
IS
/*
Purpose : To Perform these Validations.
*/
l_proc   varchar2(72) := g_package||'abr_del_val';
Begin
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_abr_id'||p_abr_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_business_group_id'||p_business_group_id,20);
end if;

if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end abr_del_val;


--
---------------------------abr_validations-----------------------------
--
procedure abr_validations(p_abr_id            in number,
                          p_dml_operation     in varchar2,
                          p_effective_date    in date,
                          p_business_group_id IN Number          Default hr_general.GET_BUSINESS_GROUP_ID,
                          p_pl_id             In Number          Default NULL,
                          p_opt_id            In Number          Default NULL,
                          p_acty_typ_cd       In Varchar2        Default NULL,
                          p_Acty_Base_RT_Stat_Cd   In Varchar2       Default 'I')
IS
/*
Purpose : To Perform these Validations.
*/
l_proc            Varchar2(72) := g_package||'abr_validations';
l_activity_type   BEN_ACTY_BASE_RT_F.ACTY_TYP_CD%Type;

Cursor csr_activity_type
IS
Select ACTY_TYP_CD
From   BEN_ACTY_BASE_RT_F
Where  ACTY_BASE_RT_ID = p_abr_id
And    Business_Group_Id = p_business_group_id
And    p_effective_date BETWEEN effective_start_date
AND    nvl(effective_end_date,hr_general.end_of_time);


begin
-- validations to be performed in this routine are
-- this should be only rate linked to the point or grade
-- etc
if g_debug then
hr_utility.set_location('Entering'||l_proc,5);
hr_utility.set_location('p_abr_id'||p_abr_id,10);
hr_utility.set_location('p_effective_date'||p_effective_date,15);
hr_utility.set_location('p_business_group_id'||p_business_group_id,20);
hr_utility.set_location('p_dml_operation'||p_dml_operation,25);
hr_utility.set_location('p_pl_id'||p_pl_id,35);
hr_utility.set_location('p_opt_id'||p_opt_id,40);
hr_utility.set_location('p_acty_typ_cd'||p_acty_typ_cd,45);
hr_utility.set_location('Old acty_typ_cd'||ben_abr_shd.g_old_rec.ACTY_TYP_CD,46);
hr_utility.set_location('p_Acty_Base_RT_Stat_Cd'||p_Acty_Base_RT_Stat_Cd,55);
hr_utility.set_location('Old Acty_Base_RT_Stat_Cd'||ben_abr_shd.g_old_rec.ACTY_BASE_RT_STAT_CD,65);
end if;

-- Get Activity Type
Open csr_activity_type;
Fetch csr_activity_type into l_activity_type;
Close csr_activity_type;
if g_debug then
   hr_utility.set_location('Activity Type'||l_activity_type,55);
end if;

if l_activity_type = 'GSPSA' Then

    if p_dml_operation = 'I' then
        if g_debug then
          hr_utility.set_location('Perform ABR Insert Validations',60);
        end if;
        abr_ins_val(p_abr_id            => p_abr_id,
                    p_effective_date    => p_effective_date,
                    p_business_group_id => p_business_group_id);
    end if;


    if p_dml_operation = 'U' then
       if g_debug then
          hr_utility.set_location('Perform ABR Update Validations',70);
       end if;


       abr_upd_val(p_abr_id                   => p_abr_id,
                   p_effective_date           => p_effective_date,
                   p_business_group_id        => p_business_group_id,
                   p_pl_id                    => p_pl_id,
                   p_opt_id                   => p_opt_id,
                   p_acty_typ_cd              => p_acty_typ_cd,
                   p_Acty_Base_RT_Stat_Cd     => p_Acty_Base_RT_Stat_Cd);
    end if;



    if p_dml_operation = 'D' then
       if g_debug then
       hr_utility.set_location('Perform ABR Delete Validations',80);
       end if;
       abr_del_val(p_abr_id            => p_abr_id,
                   p_effective_date    => p_effective_date,
                   p_business_group_id => p_business_group_id);
    end if;

end if;
if g_debug then
  hr_utility.set_location('Leaving'||l_proc,100);
end if;

end abr_validations;
end pqh_gsp_ben_validations;

/
