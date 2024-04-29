--------------------------------------------------------
--  DDL for Package Body BEN_CWB_WS_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_WS_IMPORT_PKG" as
/* $Header: bencwbwsim.pkb 120.13.12010000.7 2009/11/25 11:01:08 sgnanama ship $ */

g_package  Varchar2(30) := 'BEN_CWB_WS_IMPORT_PKG.';
g_debug boolean := hr_utility.debug_enabled;
TYPE g_iterface_seq_type is varray(6) of number;

/*
 This procedure is used by worksheet when rank is updated to
 prevent any duplicates getting created.
*/
procedure insert_new_rank
          (p_assignment_id            in number
          ,p_rank                     in number
          ,p_rank_by_person_id        in number
          ,p_level_number             in number
          ,p_assignment_extra_info_id out nocopy number
          ,p_object_version_number    out nocopy number) is
Cursor Csr_EIT_Dtls IS
SELECT  'Y'
FROM    PER_ASSIGNMENT_EXTRA_INFO ASS_EIT
WHERE   ASS_EIT.INFORMATION_TYPE   = 'CWBRANK'
AND     ASS_EIT.ASSIGNMENT_ID      = p_assignment_Id
AND     ASS_EIT.AEI_INFORMATION2   = p_rank_by_person_id
AND     ASS_EIT.AEI_INFORMATION5 IS  NULL
AND     ASS_EIT.AEI_INFORMATION6 IS  NULL;
l_exists char(1) := 'N';
begin
  --
  open  Csr_EIT_Dtls;
  fetch Csr_EIT_Dtls into l_exists;
  close Csr_EIT_Dtls;

  if l_exists = 'N' then
   hr_assignment_extra_info_api.create_assignment_extra_info
            (p_assignment_id                 => p_assignment_Id
            ,p_information_type              => 'CWBRANK'
            ,p_aei_information_category      => 'CWBRANK'
            ,p_aei_information1              => p_rank
            ,p_aei_information2              => p_rank_by_person_id
            ,p_aei_information4              => p_level_number
            ,p_assignment_extra_info_id      => p_assignment_extra_info_id
            ,p_object_version_number         => p_object_version_number);
  else
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.raise_error;
  end if;

end insert_new_rank;
--
--------------------------- UPDATE_RANK -----------------------------
--

PROCEDURE UPDATE_RANK(P_GROUP_PER_IN_LER_ID  IN  NUMBER
                      ,P_RANK                IN  NUMBER
                      ,P_USER_ID             IN  VARCHAR2) IS

Cursor Csr_Assignment_ID IS
Select pil_emp.assignment_id
      ,mgr.lvl_num
From   ben_per_in_ler pil_emp
      ,ben_cwb_group_hrchy mgr
      ,ben_per_in_ler pil_mgr
Where  pil_emp.per_in_ler_id = p_group_per_in_ler_id
and    pil_emp.per_in_ler_id = mgr.emp_per_in_ler_id
and    mgr.lvl_num > 0
and    mgr.mgr_per_in_ler_id = pil_mgr.per_in_ler_id
and    pil_mgr.person_id = p_user_id;

Cursor Csr_EIT_Dtls(l_assignment_Id IN  NUMBER )
IS
SELECT  ASS_EIT.ASSIGNMENT_EXTRA_INFO_ID ,
        ASS_EIT.OBJECT_VERSION_NUMBER
FROM    PER_ASSIGNMENT_EXTRA_INFO ASS_EIT
WHERE   ASS_EIT.INFORMATION_TYPE   = 'CWBRANK'
AND     ASS_EIT.ASSIGNMENT_ID      = l_assignment_Id
AND     ASS_EIT.AEI_INFORMATION2   = P_USER_ID
AND     ASS_EIT.AEI_INFORMATION5 IS  NULL
AND     ASS_EIT.AEI_INFORMATION6 IS  NULL;



l_proc   varchar2(72) := g_package||'UPDATE_RANK';
l_assignment_Id 		Number;
l_lvl_num                       number;
l_ovn           		Number;
l_assignment_extra_info_id 	Number;

BEGIN

if g_debug then
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('P_GROUP_PER_IN_LER_ID '||P_GROUP_PER_IN_LER_ID,20);
   hr_utility.set_location('P_RANK '||P_RANK,30);
   hr_utility.set_location('P_USER_ID '||P_USER_ID,35);
end if;

Open Csr_Assignment_ID;
Fetch Csr_Assignment_ID into l_assignment_Id, l_lvl_num;
Close Csr_Assignment_ID;

if g_debug then
   hr_utility.set_location('l_assignment_Id '||l_assignment_Id,70);
end if;


IF (l_assignment_Id IS NOT NULL) THEN
  --
  open  Csr_EIT_Dtls(l_assignment_Id);
  fetch Csr_EIT_Dtls into l_assignment_extra_info_id, l_ovn;
  close Csr_EIT_Dtls;

  if l_assignment_extra_info_id is not null then
     hr_assignment_extra_info_api.update_assignment_extra_info
       (p_assignment_extra_info_id      => l_assignment_extra_info_id
       ,p_object_version_number         => l_ovn
       ,p_aei_information_category      => 'CWBRANK'
       ,p_aei_information1              => P_RANK
       ,p_aei_information4              => l_lvl_num);
  else
      hr_assignment_extra_info_api.create_assignment_extra_info
    	    (p_assignment_id                 => l_assignment_Id
    	    ,p_information_type              => 'CWBRANK'
    	    ,p_aei_information_category      => 'CWBRANK'
    	    ,p_aei_information1              => P_RANK
    	    ,p_aei_information2              => P_USER_ID
            ,p_aei_information4              => l_lvl_num
    	    ,p_assignment_extra_info_id      => l_assignment_extra_info_id
  	    ,p_object_version_number         => l_ovn);
  end if;

END IF;

if g_debug then
   hr_utility.set_location('Leaving '||l_proc,100);
end if;

END UPDATE_RANK;


--
--------------------------- UPDATE_WS_AMOUNT -----------------------------
--

function UPDATE_WS_AMOUNT (P_PERSON_RATE_ID IN    NUMBER
                           ,P_WS_VAL         IN    NUMBER default null
                           ,p_add_val        in    number default null
                           ,P_USER_ID        IN    VARCHAR2
                           ,P_WS_RT_START_DATE IN   DATE    DEFAULT NULL)
return number
IS

Cursor Csr_PlRt_Dtls
IS
Select PlRt.GROUP_PER_IN_LER_ID     GROUP_PER_IN_LER_ID,
       PlRt.PL_ID                   PL_ID,
       PlRt.OIPL_ID                 OIPL_ID,
       PlRt.GROUP_PL_ID             GROUP_PL_ID,
       PlRt.GROUP_OIPL_ID           GROUP_OIPL_ID,
       PlRt.LF_EVT_OCRD_DT          LF_EVT_OCRD_DT,
       PlRt.Object_Version_Number   OVN,
       PlRt.ws_val                  ws_val,
       plrt.ws_rt_start_date        WS_RT_START_DATE
From   BEN_CWB_PERSON_RATES PlRt
      ,ben_cwb_pl_dsgn dsgn
Where  PlRt.PERSON_RATE_ID        = P_PERSON_RATE_ID
And    PlRt.ELIG_FLAG='Y'
and    plRt.pl_id = dsgn.pl_id
and    plRt.oipl_id = dsgn.oipl_id
and    plRt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
and    dsgn.ws_abr_id is not null;

Cursor Csr_Person_Id(l_USER_ID IN NUMBER)
IS
Select EMPLOYEE_ID
From   FND_USER
Where  User_Id = l_USER_ID;

l_upd_rec  Csr_PlRt_Dtls%RowType;
l_ovn      Number;
l_proc     varchar2(72) := g_package||'UPDATE_WS_AMOUNT';
l_USER_ID  Number;
l_person_id Number;
l_diff      number;
l_ws_val    number := p_ws_val;
l_ws_rt_start_date DATE;
BEGIN

if g_debug then
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('P_PERSON_RATE_ID '||P_PERSON_RATE_ID,20);
   hr_utility.set_location('P_WS_VAL '||l_WS_VAL,30);
   hr_utility.set_location('P_USER_ID '||P_USER_ID,36);
end if;

IF (P_USER_ID IS NOT NULL) THEN
   l_USER_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_USER_ID);
   hr_utility.set_location('l_USER_ID   :'||l_USER_ID,45);
END IF;

Open Csr_Person_Id(l_USER_ID);
Fetch Csr_Person_Id into l_person_id;
Close Csr_Person_Id;

     Open Csr_PlRt_Dtls;
     Fetch Csr_PlRt_Dtls into l_upd_rec;

     If Csr_PlRt_Dtls%Found Then
        l_ovn := l_upd_rec.OVN;

        if p_add_val is not null then
          l_ws_val := ben_cwb_utils.add_number_with_null_check
                         (l_upd_rec.ws_val, p_add_val);
        end if;
        l_diff :=  nvl(l_ws_val,0) - nvl(l_upd_rec.ws_val,0);
        --added by KMG
        IF  p_ws_rt_start_date = default_date THEN
           l_ws_rt_start_date := l_upd_rec.ws_rt_start_date;
        ELSE
           l_ws_rt_start_date := p_ws_rt_start_date;
        END IF;
        BEN_CWB_PERSON_RATES_API.update_person_rate
               (   p_group_per_in_ler_id          =>  l_upd_rec.GROUP_PER_IN_LER_ID
                  ,p_pl_id                         => l_upd_rec.PL_ID
                  ,p_oipl_id                       => l_upd_rec.OIPL_ID
                  ,p_group_pl_id                   => l_upd_rec.GROUP_PL_ID
                  ,p_group_oipl_id                 => l_upd_rec.GROUP_OIPL_ID
                  ,p_lf_evt_ocrd_dt                => l_upd_rec.LF_EVT_OCRD_DT
                  ,p_ws_val_last_upd_date          => trunc(Sysdate)
                  ,p_ws_val_last_upd_by            => l_person_id
                  ,p_ws_val                        => l_WS_VAL
                  ,p_object_version_number         => l_ovn
                  ,p_ws_rt_start_date              => l_ws_rt_start_date
                  );
     End if;
     Close Csr_PlRt_Dtls;

if g_debug then
   hr_utility.set_location('Leaving '||l_proc,100);
end if;

return l_diff;

END UPDATE_WS_AMOUNT;

--
--------------------------- REFRESH_PERSON_TASKS -----------------------------
--

PROCEDURE REFRESH_PERSON_TASKS (P_PERSON_RATE_ID        IN    NUMBER Default Null
                                ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_TASK_ID              IN    NUMBER
                                ,P_SEC_MGR_LER_ID       IN    NUMBER Default Null)
IS
Cursor csr_person_rate_info (l_person_rate_id IN Number)
IS
Select   group_pl_id
        ,lf_evt_ocrd_dt
from   ben_cwb_person_rates
where  person_rate_id = l_person_rate_id;

Cursor csr_person_tasks_info(l_group_pl_id In Number, l_lf_evt_ocrd_dt Date)
IS
Select    STATUS_CD
         ,OBJECT_VERSION_NUMBER
From     ben_cwb_person_tasks
Where    GROUP_PER_IN_LER_ID   = P_SEC_MGR_LER_ID
And      TASK_ID               = P_TASK_ID
And      GROUP_PL_ID           = l_group_pl_id
And      LF_EVT_OCRD_DT        = l_lf_evt_ocrd_dt ;

l_proc   varchar2(72) := g_package||'REFRESH_PERSON_TASKS';
l_rate_id        	Number;
l_group_pl_id     	Number;
l_status_cd             ben_cwb_person_tasks.STATUS_CD%Type;
l_ovn                   Number;
l_lf_evt_ocrd_dt  	Date;
BEGIN

hr_utility.set_location('Entering   :'||l_proc,10);

If P_PERSON_RATE_ID IS NOT NULL then
   l_rate_id := P_PERSON_RATE_ID;
Elsif P_OPT1_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT1_PERSON_RATE_ID;
Elsif P_OPT2_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT2_PERSON_RATE_ID;
Elsif P_OPT3_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT3_PERSON_RATE_ID;
Elsif P_OPT4_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT4_PERSON_RATE_ID;
End if;

hr_utility.set_location('l_rate_id   :'||l_rate_id,20);

Open csr_person_rate_info(l_rate_id);
Fetch csr_person_rate_info into l_group_pl_id,l_lf_evt_ocrd_dt;
Close csr_person_rate_info;

hr_utility.set_location('l_group_pl_id           :'||l_group_pl_id,50);
hr_utility.set_location('l_lf_evt_ocrd_dt        :'||l_lf_evt_ocrd_dt,60);


Open csr_person_tasks_info(l_group_pl_id,l_lf_evt_ocrd_dt );
Fetch csr_person_tasks_info into l_status_cd,l_ovn;
Close  csr_person_tasks_info;

hr_utility.set_location('l_status_cd   :'||l_status_cd,70);
hr_utility.set_location('l_ovn         :'||l_ovn,80);

If l_status_cd = 'NS' then
   BEN_CWB_PERSON_TASKS_API.update_person_task
      (  p_group_per_in_ler_id           => P_SEC_MGR_LER_ID
        ,p_task_id                       => P_TASK_ID
        ,p_group_pl_id                   => l_group_pl_id
        ,p_lf_evt_ocrd_dt                => l_lf_evt_ocrd_dt
        ,p_status_cd                     => 'IP'
        ,p_task_last_update_date         => sysdate
        ,p_object_version_number         => l_ovn
        );
End If;

hr_utility.set_location('Leaving   :'||l_proc,100);

END REFRESH_PERSON_TASKS;

--
--------------------------- get_group_per_in_ler_id -----------------------------
--

FUNCTION get_group_per_in_ler_id (P_PERSON_RATE_ID      IN    NUMBER Default Null
                                ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
                                Return Number
IS
Cursor csr_group_per_in_ler_id (l_person_rate_id IN Number)
IS
Select group_per_in_ler_id
from   ben_cwb_person_rates
where  person_rate_id = l_person_rate_id;

l_proc   		Varchar2(72) := g_package||'get_group_per_in_ler_id';
l_rate_id 		Number;
l_group_per_in_ler_id 	Number;


BEGIN

hr_utility.set_location('Entering   :'||l_proc,10);

If P_PERSON_RATE_ID IS NOT NULL then
   l_rate_id := P_PERSON_RATE_ID;
Elsif P_OPT1_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT1_PERSON_RATE_ID;
Elsif P_OPT2_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT2_PERSON_RATE_ID;
Elsif P_OPT3_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT3_PERSON_RATE_ID;
Elsif P_OPT4_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT4_PERSON_RATE_ID;
End if;

hr_utility.set_location('l_rate_id   :'||l_rate_id,20);

Open csr_group_per_in_ler_id(l_rate_id);
Fetch csr_group_per_in_ler_id into l_group_per_in_ler_id;
Close csr_group_per_in_ler_id;

hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,40);
hr_utility.set_location('Leaving   :'||l_proc,100);

return l_group_per_in_ler_id;

End get_group_per_in_ler_id;

--
--------------------------- chk_processed_emp -----------------------------
--

PROCEDURE chk_processed_emp (P_PERSON_RATE_ID      IN    NUMBER Default Null
                                ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                                ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null
				,P_EMP_PER_IN_LER_ID    IN    NUMBER DEFAULT NULL
                                ,P_MGR_PER_IN_LER_ID    IN    NUMBER DEFAULT NULL)
IS
l_proc   		Varchar2(72) := g_package||'chk_processed_emp';
l_group_per_in_ler_id   Number;
l_pp_stat_cd            Ben_Cwb_Person_Info.POST_PROCESS_STAT_CD%Type;

Cursor csr_PP_STAT_CD (l_ler_id IN Number)
IS
Select POST_PROCESS_STAT_CD
From   Ben_Cwb_Person_Info
Where  Group_Per_In_Ler_Id = l_ler_id;

-- added by kmg for fixing bug#6830922
CURSOR csr_ws_stat_cd (l_ler_id IN NUMBER) IS
  SELECT submit_cd
  FROM   ben_cwb_person_groups mgr,
         ben_cwb_group_hrchy hrchy
  WHERE  hrchy.emp_per_in_ler_id =  l_ler_id
  and hrchy.mgr_per_in_ler_id = mgr.group_per_in_ler_id
  and hrchy.lvl_num = 1;
 l_submit_cd   ben_cwb_person_groups.submit_cd%TYPE;

 CURSOR csr_chk_hrchy(p_mgr_ler_id NUMBER,p_emp_ler_id NUMBER) IS		-- bug: 8996634
SELECT 'Y'
FROM DUAL
WHERE EXISTS (SELECT 'X'
              FROM BEN_CWB_GROUP_HRCHY
              WHERE  MGR_PER_IN_LER_ID = p_mgr_ler_id
              AND    EMP_PER_IN_LER_ID = p_emp_ler_id );
l_chk_hrchy VARCHAR2(10);

BEGIN
hr_utility.set_location('Entering   :'||l_proc,10);

l_group_per_in_ler_id := get_group_per_in_ler_id (P_PERSON_RATE_ID  =>P_PERSON_RATE_ID
                                ,P_OPT1_PERSON_RATE_ID  => P_OPT1_PERSON_RATE_ID
                                ,P_OPT2_PERSON_RATE_ID  => P_OPT2_PERSON_RATE_ID
                                ,P_OPT3_PERSON_RATE_ID  => P_OPT3_PERSON_RATE_ID
                                ,P_OPT4_PERSON_RATE_ID  => P_OPT4_PERSON_RATE_ID);

hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,40);

Open csr_PP_STAT_CD(l_group_per_in_ler_id);
Fetch csr_PP_STAT_CD into l_pp_stat_cd;
Close csr_PP_STAT_CD;

hr_utility.set_location('l_pp_stat_cd   :'||l_pp_stat_cd,50);

if l_pp_stat_cd IS NOT NULL then
   hr_utility.set_message(805,'BEN_93752_CWB_PROCESSES_EMP');
   hr_utility.raise_error;
End if;

-- added by kmg for fixing bug#6830922
OPEN csr_ws_stat_cd(l_group_per_in_ler_id);
FETCH csr_ws_stat_cd INTO l_submit_cd;
CLOSE csr_ws_stat_cd;
IF NVL(l_submit_cd,'NS') = 'SU' THEN
  hr_utility.set_message(805,'BEN_94711_CWB_WS_SUBMITTED');
  hr_utility.raise_error;
END IF;

hr_utility.trace('P_EMP_PER_IN_LER_ID:'||p_emp_per_in_ler_id);			-- bug: 8996634
hr_utility.trace('P_MGR_PER_IN_LER_ID:'||p_mgr_per_in_ler_id);
IF p_emp_per_in_ler_id IS NOT NULL AND p_mgr_per_in_ler_id IS NOT NULL THEN
  OPEN csr_chk_hrchy(p_mgr_per_in_ler_id,p_emp_per_in_ler_id);
  FETCH csr_chk_hrchy INTO l_chk_hrchy;
  hr_utility.trace('Inside the loop:'||l_CHK_HRCHY);
  CLOSE csr_chk_hrchy;
  IF NVL(l_chk_hrchy,'N') = 'N' THEN
  --- Create a new error message for this case
  hr_utility.trace('KMG_CHANGES: NOT IN HIERARCHY, RAISE ERROR');
  hr_utility.set_message(805,'BEN_94723_CWB_EMP_NOT_HRCHY');
  hr_utility.raise_error;
  END IF;
END IF;

hr_utility.set_location('Leaving   :'||l_proc,200);
END chk_processed_emp;



--
--------------------------- update_perf_rating -----------------------------
--
Procedure update_perf_rating(P_PROPOSED_PERFORMANCE_RATING IN Varchar2
                           ,P_ACTING_PERSON_ID     IN    NUMBER Default Null
                           ,P_PERSON_RATE_ID       IN    NUMBER Default Null
                           ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
IS

l_proc   		     Varchar2(72) := g_package||'update_perf_rating';
l_group_per_in_ler_id 	     Number;
l_rating                     Varchar2(30);

Cursor Csr_person_info(l_group_per_in_ler_id In Number)
IS
Select  per.assignment_id       Assignment_id
       ,per.person_id           Person_id
       ,per.business_group_id   business_group_id
       ,per.full_name           Person_name
From    ben_cwb_person_info per
Where   per.group_per_in_ler_id = l_group_per_in_ler_id;



Cursor Csr_pl_dsgn_info(l_group_per_in_ler_id In Number)
IS
Select  dsgn.EMP_INTERVIEW_TYP_CD
       ,dsgn.perf_revw_strt_dt
       ,dsgn.group_pl_id
From    ben_cwb_pl_dsgn dsgn
       ,ben_cwb_person_info inf
Where   dsgn.group_oipl_id  = -1
And     dsgn.pl_id = inf.group_pl_id
And     dsgn.lf_evt_ocrd_dt = inf.lf_evt_ocrd_dt
And     inf.group_per_in_ler_id = l_group_per_in_ler_id;


l_person_info     Csr_person_info%RowType;
l_pl_dsgn_info    Csr_pl_dsgn_info%RowType;

Begin
hr_utility.set_location('Entering   :'||l_proc,10);
--If P_PROPOSED_PERFORMANCE_RATING IS NOT NULL Then
	l_group_per_in_ler_id := get_group_per_in_ler_id (P_PERSON_RATE_ID  =>P_PERSON_RATE_ID
                                ,P_OPT1_PERSON_RATE_ID  => P_OPT1_PERSON_RATE_ID
                                ,P_OPT2_PERSON_RATE_ID  => P_OPT2_PERSON_RATE_ID
                                ,P_OPT3_PERSON_RATE_ID  => P_OPT3_PERSON_RATE_ID
                                ,P_OPT4_PERSON_RATE_ID  => P_OPT4_PERSON_RATE_ID);

	hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,40);


	Open csr_person_info(l_group_per_in_ler_id);
	Fetch csr_person_info into l_person_info;
	Close csr_person_info;

	hr_utility.set_location('l_person_info.Assignment_id      :'||l_person_info.Assignment_id,70);
	hr_utility.set_location('l_person_info.Person_id          :'||l_person_info.Person_id,80);
	hr_utility.set_location('l_person_info.business_group_id  :'||l_person_info.business_group_id,90);
	hr_utility.set_location('l_person_info.Person_name        :'||l_person_info.Person_name,100);

        Open Csr_pl_dsgn_info(l_group_per_in_ler_id);
	Fetch Csr_pl_dsgn_info into l_pl_dsgn_info;
	Close Csr_pl_dsgn_info;


	hr_utility.set_location('l_pl_dsgn_info.EMP_INTERVIEW_TYP_CD   :'||l_pl_dsgn_info.EMP_INTERVIEW_TYP_CD,120);
	hr_utility.set_location('l_pl_dsgn_info.perf_revw_strt_dt      :'||l_pl_dsgn_info.perf_revw_strt_dt,130);

	ben_cwb_asg_update.process_rating
	    (p_validate_data          =>  'Y'
	    ,p_assignment_id          => l_person_info.Assignment_id
	    ,p_person_id              => l_person_info.Person_id
	    ,p_business_group_id      => l_person_info.business_group_id
	    ,p_perf_revw_strt_dt      => to_char(l_pl_dsgn_info.perf_revw_strt_dt,'yyyy/mm/dd')
	    ,p_perf_type              => l_pl_dsgn_info.EMP_INTERVIEW_TYP_CD
	    ,p_perf_rating            => P_PROPOSED_PERFORMANCE_RATING
	    ,p_person_name            => l_person_info.Person_name
	    ,p_update_person_id       => P_ACTING_PERSON_ID
            ,p_update_date            => Sysdate
            ,p_group_pl_id            => l_pl_dsgn_info.group_pl_id);




--End If;
hr_utility.set_location('Leaving   :'||l_proc,100);
End update_perf_rating;


Procedure update_promotions(P_PROPOSED_JOB IN Varchar2
                           ,P_PROPOSED_POSITION IN Varchar2
                           ,P_PROPOSED_GRADE IN Varchar2
                           ,P_CHANGE_REASON IN Varchar2
                           ,P_ACTING_PERSON_ID     IN    NUMBER Default Null
                           ,P_PERSON_RATE_ID       IN    NUMBER Default Null
                           ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                           ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
IS

l_proc   		     Varchar2(72) := g_package||'update_promotions';
l_group_per_in_ler_id 	     Number;
l_job_id                     Varchar2(30) := null;
l_pos_id                     Varchar2(30) := null;
l_grade_id                     Varchar2(30)  := null;
l_change_reason                Varchar2(50)  := P_CHANGE_REASON;

Cursor Csr_person_info(l_group_per_in_ler_id In Number)
IS
Select  per.assignment_id       Assignment_id
       ,per.person_id           Person_id
       ,per.business_group_id   business_group_id
       ,per.full_name           Person_name
From    ben_cwb_person_info per
Where   per.group_per_in_ler_id = l_group_per_in_ler_id;



Cursor Csr_pl_dsgn_info(l_group_per_in_ler_id In Number)
IS
Select  dsgn.EMP_INTERVIEW_TYP_CD
       ,to_char(dsgn.asg_updt_eff_date,'yyyy/mm/dd') asg_updt_eff_date
       ,dsgn.group_pl_id
From    ben_cwb_pl_dsgn dsgn
       ,ben_cwb_person_info inf
Where   dsgn.group_oipl_id  = -1
And     dsgn.pl_id = inf.group_pl_id
And     dsgn.lf_evt_ocrd_dt = inf.lf_evt_ocrd_dt
And     inf.group_per_in_ler_id = l_group_per_in_ler_id;

cursor Csr_person_asg(l_assignment_id  In Number, l_asg_updt_eff_date In Varchar2)
is
select  txn.attribute3 change_reason
       ,to_number(txn.attribute5) job_id
       ,to_number(txn.attribute6) position_id
       ,to_number(txn.attribute7) grade_id
from ben_transaction txn
where txn.transaction_id = l_assignment_id
and txn.transaction_type  = 'CWBASG'|| trim(l_asg_updt_eff_date);

cursor c_job (bg_id In Number)  is
select j.job_id
from per_jobs_tl jtl , per_jobs j
where jtl.name = P_PROPOSED_JOB
and jtl.language = 'US'
and jtl.job_id = j.job_id
and j.business_group_id = bg_id
and rownum =1;

cursor c_position (bg_id In Number) is
select p.position_id
from hr_all_positions_f_tl ptl, hr_all_positions_f p
where ptl.name = P_PROPOSED_POSITION
and ptl.language = 'US'
and ptl.position_id = p.position_id
and p.business_group_id = bg_id
and rownum =1;

cursor c_grade (bg_id In Number) is
select p.grade_id
from per_grades_tl ptl, per_grades p
where ptl.name = P_PROPOSED_GRADE
and ptl.language = 'US'
and ptl.grade_id = p.grade_id
and p.business_group_id = bg_id
and rownum =1;

l_person_info     Csr_person_info%RowType;
l_pl_dsgn_info    Csr_pl_dsgn_info%RowType;
l_person_asg      Csr_person_asg%RowType;

Begin
hr_utility.set_location('Entering   :'||l_proc,10);
--If P_PROPOSED_PERFORMANCE_RATING IS NOT NULL Then
	l_group_per_in_ler_id := get_group_per_in_ler_id (P_PERSON_RATE_ID  =>P_PERSON_RATE_ID
                                ,P_OPT1_PERSON_RATE_ID  => P_OPT1_PERSON_RATE_ID
                                ,P_OPT2_PERSON_RATE_ID  => P_OPT2_PERSON_RATE_ID
                                ,P_OPT3_PERSON_RATE_ID  => P_OPT3_PERSON_RATE_ID
                                ,P_OPT4_PERSON_RATE_ID  => P_OPT4_PERSON_RATE_ID);

	hr_utility.set_location('l_group_per_in_ler_id   :'||l_group_per_in_ler_id,40);


	Open csr_person_info(l_group_per_in_ler_id);
	Fetch csr_person_info into l_person_info;
	Close csr_person_info;

	hr_utility.set_location('l_person_info.Assignment_id      :'||l_person_info.Assignment_id,70);
	hr_utility.set_location('l_person_info.Person_id          :'||l_person_info.Person_id,80);
	hr_utility.set_location('l_person_info.business_group_id  :'||l_person_info.business_group_id,90);
	hr_utility.set_location('l_person_info.Person_name        :'||l_person_info.Person_name,100);

        Open Csr_pl_dsgn_info(l_group_per_in_ler_id);
	Fetch Csr_pl_dsgn_info into l_pl_dsgn_info;
	Close Csr_pl_dsgn_info;

	Open Csr_person_asg(l_person_info.Assignment_id, l_pl_dsgn_info.asg_updt_eff_date);
	Fetch Csr_person_asg into l_person_asg;
	Close Csr_person_asg;


	hr_utility.set_location('l_pl_dsgn_info.EMP_INTERVIEW_TYP_CD   :'||l_pl_dsgn_info.EMP_INTERVIEW_TYP_CD,120);
	hr_utility.set_location('l_pl_dsgn_info.ASG_UPDT_EFF_DATE      :'||l_pl_dsgn_info.ASG_UPDT_EFF_DATE,130);

    -- 8925417
    if(l_pl_dsgn_info.asg_updt_eff_date is null) then
       hr_utility.set_message(805,'BEN_93191_PROMO_EFFDT_NOT_DFND');
       hr_utility.raise_error;
    end if;

    if(P_PROPOSED_JOB = default_string) then
        l_job_id := l_person_asg.job_id;
    else
        open c_job (l_person_info.business_group_id);
        fetch c_job into l_job_id;
        close c_job;
    end if;
    hr_utility.set_location('l_job_id     :'|| l_job_id,130);
    if(P_PROPOSED_POSITION = default_string) then
        l_pos_id := l_person_asg.position_id;
    else
        open c_position (l_person_info.business_group_id);
        fetch c_position  into l_pos_id;
        close c_position;
    end if;
    hr_utility.set_location('l_pos_id     :'|| l_pos_id,130);
    if(P_PROPOSED_GRADE = default_string) then
        l_grade_id := l_person_asg.grade_id;
    else
        open c_grade(l_person_info.business_group_id);
        fetch c_grade  into l_grade_id;
        close c_grade;
    end if;
    hr_utility.set_location('l_grade_id     :'|| l_grade_id,130);
    if(P_CHANGE_REASON = default_string) then
        l_change_reason := l_person_asg.change_reason;
    end if;

	ben_cwb_asg_update.process_promotions
	    (p_validate_data          =>  'Y'
	    ,p_assignment_id          => l_person_info.Assignment_id
	    ,p_person_id              => l_person_info.Person_id
	    ,p_business_group_id      => l_person_info.business_group_id
	    ,p_asg_updt_eff_date      => l_pl_dsgn_info.asg_updt_eff_date --to_char(l_pl_dsgn_info.asg_updt_eff_date,'yyyy/mm/dd')
	    ,p_change_reason          => l_change_reason
	    ,p_job_id                 => l_job_id
        ,p_position_id            => l_pos_id
        ,p_grade_id               => l_grade_id
        ,p_people_group_id        =>  null
     ,p_soft_coding_keyflex_id =>  null
     ,p_ass_attribute1         =>  null
     ,p_ass_attribute2         =>  null
     ,p_ass_attribute3         =>  null
     ,p_ass_attribute4         =>  null
     ,p_ass_attribute5         =>  null
     ,p_ass_attribute6         =>  null
     ,p_ass_attribute7         =>  null
     ,p_ass_attribute8         =>  null
     ,p_ass_attribute9         =>  null
     ,p_ass_attribute10        =>  null
     ,p_ass_attribute11        =>  null
     ,p_ass_attribute12        =>  null
     ,p_ass_attribute13        =>  null
     ,p_ass_attribute14        =>  null
     ,p_ass_attribute15        =>  null
     ,p_ass_attribute16        =>  null
     ,p_ass_attribute17        =>  null
     ,p_ass_attribute18        =>  null
     ,p_ass_attribute19        =>  null
     ,p_ass_attribute20        =>  null
     ,p_ass_attribute21        =>  null
     ,p_ass_attribute22        =>  null
     ,p_ass_attribute23        =>  null
     ,p_ass_attribute24        =>  null
     ,p_ass_attribute25        =>  null
     ,p_ass_attribute26        =>  null
     ,p_ass_attribute27        =>  null
     ,p_ass_attribute28        =>  null
     ,p_ass_attribute29        =>  null
     ,p_ass_attribute30        =>  null
	    ,p_person_name            => l_person_info.Person_name
	    ,p_update_person_id       => P_ACTING_PERSON_ID
        ,p_update_date            => Sysdate
        ,p_group_pl_id            => l_pl_dsgn_info.group_pl_id);




--End If;
hr_utility.set_location('Leaving   :'||l_proc,100);
End update_promotions;

--
procedure update_other_rates (P_PERSON_RATE_ID IN    NUMBER
                           ,p_interface_seq    IN    g_iterface_seq_type
                           ,p_values           in    g_iterface_seq_type
                           ,p_interface_code   in    varchar2
                           ,p_base_layout_code in    varchar2 )
IS
p_final_values g_iterface_seq_type := g_iterface_seq_type(null,null,null,null,null,null);
Cursor Csr_PlRt_Dtls
IS
Select PlRt.GROUP_PER_IN_LER_ID     GROUP_PER_IN_LER_ID,
       PlRt.PL_ID                   PL_ID,
       PlRt.OIPL_ID                 OIPL_ID,
       PlRt.GROUP_PL_ID             GROUP_PL_ID,
       PlRt.GROUP_OIPL_ID           GROUP_OIPL_ID,
       PlRt.LF_EVT_OCRD_DT          LF_EVT_OCRD_DT,
       PlRt.Object_Version_Number   OVN,
       PlRt.STAT_SAL_VAL,
       PlRt.OTH_COMP_VAL,
       PlRt.TOT_COMP_VAL,
       PlRt.MISC1_VAL,
       PlRt.MISC2_VAL,
       PlRt.MISC3_VAL
From   BEN_CWB_PERSON_RATES PlRt
      ,ben_cwb_pl_dsgn dsgn
Where  PlRt.PERSON_RATE_ID        = P_PERSON_RATE_ID
And    PlRt.ELIG_FLAG='Y'
and    plRt.pl_id = dsgn.pl_id
and    plRt.oipl_id = dsgn.oipl_id
and    plRt.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt;
--and    dsgn.ws_abr_id is not null;

cursor csr_is_read_only (l_seq1 in number,l_seq2 in number,l_seq3 in number,
                            l_seq4 in number,l_seq5 in number, l_seq6 in number) is
select interface_seq_num, decode(nvl(lay.read_only_flag,'N')||nvl(intf.read_only_flag,'N'), 'NN','N','Y') read_only
  from bne_interface_cols_b intf, bne_layout_cols lay
  where  intf.interface_code = nvl(p_interface_code,'BEN_CWB_WRK_SHT_INTF')
  and intf.application_id = 800
  and intf.interface_code = lay.interface_code
  and lay.layout_code = nvl(p_base_layout_code,'BEN_CWB_WRK_SHT_BASE_LYT')
  and lay.application_id = 800
  and intf.sequence_num = lay.interface_seq_num
  and intf.sequence_num in (l_seq1,l_seq2,l_seq3,l_seq4,l_seq5,l_seq6);

l_proc     varchar2(72) := g_package||'update_other_rates';

BEGIN

if g_debug then
   hr_utility.set_location('Entering '||l_proc,10);
   hr_utility.set_location('P_PERSON_RATE_ID '||P_PERSON_RATE_ID,20);
end if;

for l_upd_rec in Csr_PlRt_Dtls loop
    p_final_values(1) := l_upd_rec.STAT_SAL_VAL;
    p_final_values(2) := l_upd_rec.OTH_COMP_VAL;
    p_final_values(3) := l_upd_rec.TOT_COMP_VAL;
    p_final_values(4) := l_upd_rec.MISC1_VAL;
    p_final_values(5) := l_upd_rec.MISC2_VAL;
    p_final_values(6) := l_upd_rec.MISC3_VAL;
end loop;

if g_debug then
   hr_utility.set_location(l_proc,20);
end if;

for l_upd_rec in Csr_PlRt_Dtls loop
    for l_is_read_only in csr_is_read_only(p_interface_seq(1),p_interface_seq(2),p_interface_seq(3),
                                    p_interface_seq(4),p_interface_seq(5),p_interface_seq(6))
    loop
            IF(l_is_read_only.interface_seq_num = p_interface_seq(1) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(1) := check_number_col_avble(l_upd_rec.STAT_SAL_VAL,p_values(1) );
            ELSIF(l_is_read_only.interface_seq_num = p_interface_seq(2) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(2) := check_number_col_avble(l_upd_rec.OTH_COMP_VAL,p_values(2) );
            ELSIF(l_is_read_only.interface_seq_num = p_interface_seq(3) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(3) := check_number_col_avble(l_upd_rec.TOT_COMP_VAL,p_values(3) );
            ELSIF(l_is_read_only.interface_seq_num = p_interface_seq(4) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(4) := check_number_col_avble(l_upd_rec.MISC1_VAL,p_values(4) );
            ELSIF(l_is_read_only.interface_seq_num = p_interface_seq(5) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(5) := check_number_col_avble(l_upd_rec.MISC2_VAL,p_values(5) );
            ELSIF(l_is_read_only.interface_seq_num = p_interface_seq(6) AND l_is_read_only.read_only = 'N') THEN
	           p_final_values(6) := check_number_col_avble(l_upd_rec.MISC3_VAL,p_values(6) );
            END IF;
    end loop;
    if g_debug then
        hr_utility.set_location(l_proc,30);
    end if;
    BEN_CWB_PERSON_RATES_API.update_person_rate
               (   p_group_per_in_ler_id          =>  l_upd_rec.GROUP_PER_IN_LER_ID
                  ,p_pl_id                         => l_upd_rec.PL_ID
                  ,p_oipl_id                       => l_upd_rec.OIPL_ID
                  ,p_group_pl_id                   => l_upd_rec.GROUP_PL_ID
                  ,p_group_oipl_id                 => l_upd_rec.GROUP_OIPL_ID
                  ,p_lf_evt_ocrd_dt                => l_upd_rec.LF_EVT_OCRD_DT
				  ,p_stat_sal_val                  =>   p_final_values(1)
				  ,p_oth_comp_val                  =>   p_final_values(2)
				  ,p_tot_comp_val                  =>   p_final_values(3)
				  ,p_misc1_val                     =>   p_final_values(4)
				  ,p_misc2_val                     =>   p_final_values(5)
				  ,p_misc3_val        		   =>   p_final_values(6)
                  ,p_object_version_number         => l_upd_rec.ovn
                  );
end loop;

if g_debug then
   hr_utility.set_location('Leaving '||l_proc,100);
end if;

END update_other_rates;

--
--------------------------- REFRESH_SUMMARY_GROUP_PL -----------------------------
--

PROCEDURE REFRESH_SUMMARY_GROUP_PL (P_PERSON_RATE_ID       IN    NUMBER Default Null
                                   ,P_OPT1_PERSON_RATE_ID  IN    NUMBER Default Null
                                   ,P_OPT2_PERSON_RATE_ID  IN    NUMBER Default Null
                                   ,P_OPT3_PERSON_RATE_ID  IN    NUMBER Default Null
                                   ,P_OPT4_PERSON_RATE_ID  IN    NUMBER Default Null)
IS
Cursor csr_group_pl_id (l_person_rate_id IN Number)
IS
Select group_pl_id,
       lf_evt_ocrd_dt
from   ben_cwb_person_rates
where  person_rate_id = l_person_rate_id;


l_rate_id         Number;
l_group_pl_id     Number;
l_lf_evt_ocrd_dt  Date;
BEGIN

If P_PERSON_RATE_ID IS NOT NULL then
   l_rate_id := P_PERSON_RATE_ID;
Elsif P_OPT1_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT1_PERSON_RATE_ID;
Elsif P_OPT2_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT2_PERSON_RATE_ID;
Elsif P_OPT3_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT3_PERSON_RATE_ID;
Elsif P_OPT4_PERSON_RATE_ID IS  NOT NULL then
    l_rate_id := P_OPT4_PERSON_RATE_ID;
End if;

Open csr_group_pl_id(l_rate_id);
Fetch csr_group_pl_id into l_group_pl_id,l_lf_evt_ocrd_dt;
Close csr_group_pl_id;

ben_cwb_summary_pkg.refresh_summary_group_pl(P_GROUP_PL_ID    => l_group_pl_id
                                            ,P_LF_EVT_OCRD_DT => l_lf_evt_ocrd_dt);

END REFRESH_SUMMARY_GROUP_PL;

function get_plan_person_rate_id(p_opt_person_rate_id in number)
return number is
  CURSOR   c_get_pl_per_rates IS
  SELECT   PlRt.person_rate_id
  FROM     BEN_CWB_PERSON_RATES PlRt
          ,ben_cwb_person_rates optRt
  WHERE    optRt.PERSON_RATE_ID     = p_opt_person_rate_id
  and      optRt.group_per_in_ler_id = plRt.group_per_in_ler_id
  and      optRt.pl_id = plRt.pl_id
  and      plRt.oipl_id  = -1;

 l_return_val number := null;
begin
  open  c_get_pl_per_rates;
  fetch c_get_pl_per_rates into l_return_val;
  close c_get_pl_per_rates;

  return l_return_val;
end;

--
---------------------------handle_row-----------------------------
--

PROCEDURE handle_row
(
    P_EMP_NAME                      IN     VARCHAR2
   ,P_MGR_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_RANK                          IN     NUMBER      DEFAULT NULL
   ,P_YEARS_EMPLOYED                IN     NUMBER      DEFAULT NULL
   ,P_BASE_SALARY                   IN     NUMBER      DEFAULT NULL
   ,P_PL_NAME                       IN     VARCHAR2    DEFAULT NULL
   ,P_PL_XCHG_RATE                  IN     NUMBER      DEFAULT NULL
   ,P_PL_STAT_SAL_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_ELIG_SAL_VAL               IN     NUMBER      DEFAULT NULL
   ,P_PL_TOT_COMP_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_OTH_COMP_VAL               IN     NUMBER      DEFAULT default_number
   ,P_PL_WS_VAL                     IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_MIN_VAL                 IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_MAX_VAL                 IN     NUMBER      DEFAULT NULL
   ,P_PL_WS_INCR_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_VAL                    IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_MIN_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_REC_MAX_VAL                IN     NUMBER      DEFAULT NULL
   ,P_PL_MISC1_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_MISC2_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_MISC3_VAL                  IN     NUMBER      DEFAULT default_number
   ,P_PL_WS_LAST_UPD_DATE           IN     DATE	       DEFAULT NULL
   ,P_PL_WS_LAST_UPD_NAME           IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT1_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT1_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT1_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT1_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT1_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT1_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT1_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT2_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT2_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT2_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT2_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT2_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT2_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT2_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT3_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT3_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_OTH_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT3_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT3_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT3_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT3_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT3_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_NAME                     IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_XCHG_RATE                IN     NUMBER      DEFAULT NULL
   ,P_OPT4_STAT_SAL_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT4_ELIG_SAL_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT4_TOT_COMP_VAL             IN     NUMBER      DEFAULT default_number
   ,P_OPT4_OTH_COMP_VAL             IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_VAL                   IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_MIN_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_MAX_VAL               IN     NUMBER      DEFAULT NULL
   ,P_OPT4_WS_INCR_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_VAL                  IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_MIN_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_REC_MAX_VAL              IN     NUMBER      DEFAULT NULL
   ,P_OPT4_MISC1_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_MISC2_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_MISC3_VAL                IN     NUMBER      DEFAULT default_number
   ,P_OPT4_WS_LAST_UPD_DATE         IN     DATE	       DEFAULT NULL
   ,P_OPT4_WS_LAST_UPD_NAME         IN     VARCHAR2    DEFAULT NULL
   ,P_EMPLOYEE_NUMBER               IN     VARCHAR2    DEFAULT NULL
   ,P_EMP_CATEGORY                  IN     VARCHAR2    DEFAULT NULL
   ,P_ASSIGNMENT_STATUS             IN     VARCHAR2    DEFAULT NULL
   ,P_PEOPLE_GROUP_NAME             IN     VARCHAR2    DEFAULT NULL
   ,P_EMAIL_ADDR                    IN     VARCHAR2    DEFAULT NULL
   ,P_START_DATE                    IN     DATE	       DEFAULT NULL
   ,P_ORIGINAL_START_DATE           IN     DATE	       DEFAULT NULL
   ,P_NORMAL_HOURS                  IN     NUMBER      DEFAULT NULL
   ,P_PAYROLL_NAME                  IN     VARCHAR2    DEFAULT NULL
   ,P_BUSINESS_GROUP_NAME           IN     VARCHAR2    DEFAULT NULL
   ,P_ORG_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_LOC_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_JOB_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_POS_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_GRD_NAME                      IN     VARCHAR2    DEFAULT NULL
   ,P_COUNTRY                       IN     VARCHAR2    DEFAULT NULL
   ,P_YEARS_IN_JOB                  IN     NUMBER      DEFAULT NULL
   ,P_YEARS_IN_POSITION             IN     NUMBER      DEFAULT NULL
   ,P_YEARS_IN_GRADE                IN     NUMBER      DEFAULT NULL
   ,P_GRADE_RANGE                   IN     VARCHAR2    DEFAULT NULL
   ,P_GRADE_MID_POINT               IN     NUMBER      DEFAULT NULL
   ,P_GRD_QUARTILE                  IN     VARCHAR2    DEFAULT NULL
   ,P_GRD_COMPARATIO                IN     NUMBER      DEFAULT NULL
   ,P_PERFORMANCE_RATING            IN     VARCHAR2    DEFAULT NULL
   ,P_PERFORMANCE_RATING_TYPE       IN     VARCHAR2    DEFAULT NULL
   ,P_PERFORMANCE_RATING_DATE       IN     DATE	       DEFAULT NULL
   ,P_LAST_RANK                     IN     NUMBER      DEFAULT NULL
   ,P_LAST_MGR_NAME                 IN     VARCHAR2    DEFAULT NULL
   ,P_RANK_QUARTILE                 IN     NUMBER      DEFAULT NULL
   ,P_TOTAL_RANK                    IN     NUMBER      DEFAULT NULL
   ,P_CHANGE_REASON                 IN     VARCHAR2    DEFAULT default_string
   ,P_BASE_SALARY_CHANGE_DATE       IN     DATE	       DEFAULT NULL
   ,P_LF_EVT_OCRD_DT                IN     DATE	       DEFAULT NULL
   ,P_MGR_LER_ID                    IN     NUMBER      DEFAULT NULL
   ,P_PL_PERSON_RATE_ID             IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT1_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT2_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT3_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_P_OPT4_PERSON_RATE_ID         IN     VARCHAR2    DEFAULT NULL
   ,P_LVL_NUM		            IN     NUMBER      DEFAULT NULL
   ,P_CUSTOM_SEGMENT1	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT2	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT3	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT4	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT5	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT6	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT7	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT8	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT9	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT10	            IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT11	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT12	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT13	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT14	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT15	            IN     NUMBER      DEFAULT default_number
   ,P_PROPOSED_PERFORMANCE_RATING   IN     VARCHAR2    DEFAULT NULL
   ,P_PROPOSED_JOB	            IN     VARCHAR2    DEFAULT default_string
   ,P_PLAN_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_UOM                      IN     VARCHAR2    DEFAULT NULL
   ,P_USER_ID                       IN     VARCHAR2    DEFAULT NULL
   ,P_PROPOSED_GRADE                IN     VARCHAR2    DEFAULT default_string
   ,P_PROPOSED_POSITION             IN     VARCHAR2    DEFAULT default_string
   ,P_PROPOSED_GROUP                IN     VARCHAR2    DEFAULT NULL
   ,P_TASK_ID                       IN     VARCHAR2    DEFAULT NULL
   ,P_SEC_MGR_LER_ID		    IN     VARCHAR2    DEFAULT NULL
   ,P_ACTING_PERSON_ID		    IN     VARCHAR2    DEFAULT NULL
   ,P_DOWNLOAD_SWITCH               IN     VARCHAR2    DEFAULT NULL
   ,P_CPI_ATTRIBUTE_CATEGORY        IN     VARCHAR2    DEFAULT NULL
   ,P_CPI_ATTRIBUTE1                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE2                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE3                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE4                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE5                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE6                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE7                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE8                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE9                IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE10               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE11               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE12               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE13               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE14               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE15               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE16               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE17               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE18               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE19               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE20               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE21               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE22               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE23               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE24               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE25               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE26               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE27               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE28               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE29               IN     VARCHAR2    DEFAULT default_string
   ,P_CPI_ATTRIBUTE30               IN     VARCHAR2    DEFAULT default_string
   ,P_CUSTOM_SEGMENT16	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT17	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT18	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT19	            IN     NUMBER      DEFAULT default_number
   ,P_CUSTOM_SEGMENT20	            IN     NUMBER      DEFAULT default_number
   ,P_PL_CURRENCY                   IN     VARCHAR2    DEFAULT NULL
   ,P_OPT1_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT2_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT3_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_OPT4_CURRENCY                 IN     VARCHAR2    DEFAULT NULL
   ,P_PL_RT_START_DATE              IN     DATE        DEFAULT default_date
   ,P_OPT1_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT2_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT3_RT_START_DATE            IN     DATE        DEFAULT default_date
   ,P_OPT4_RT_START_DATE            IN     DATE        DEFAULT default_date

) IS

CURSOR   Csr_get_pl_ws_val(l_PL_PERSON_RATE_ID IN NUMBER)
IS
SELECT   PlRt.WS_VAL
FROM     BEN_CWB_PERSON_RATES PlRt
WHERE    PlRt.PERSON_RATE_ID     = l_PL_PERSON_RATE_ID;

CURSOR csr_cpi_flex_info(l_group_per_in_ler_id IN NUMBER)
IS
SELECT cpi_attribute_category,
       cpi_attribute1,
       cpi_attribute2,
       cpi_attribute3,
       cpi_attribute4,
       cpi_attribute5,
       cpi_attribute6,
       cpi_attribute7,
       cpi_attribute8,
       cpi_attribute9,
       cpi_attribute10,
       cpi_attribute11,
       cpi_attribute12,
       cpi_attribute13,
       cpi_attribute14,
       cpi_attribute15,
       cpi_attribute16,
       cpi_attribute17,
       cpi_attribute18,
       cpi_attribute19,
       cpi_attribute20,
       cpi_attribute21,
       cpi_attribute22,
       cpi_attribute23,
       cpi_attribute24,
       cpi_attribute25,
       cpi_attribute26,
       cpi_attribute27,
       cpi_attribute28,
       cpi_attribute29,
       cpi_attribute30,
       custom_segment1,
       custom_segment2,
       custom_segment3,
       custom_segment4,
       custom_segment5,
       custom_segment6,
       custom_segment7,
       custom_segment8,
       custom_segment9,
       custom_segment10,
       custom_segment11,
       custom_segment12,
       custom_segment13,
       custom_segment14,
       custom_segment15,
       custom_segment16,
       custom_segment17,
       custom_segment18,
       custom_segment19,
       custom_segment20,
       object_version_number
FROM ben_cwb_person_info
WHERE group_per_in_ler_id = l_group_per_in_ler_id;

CURSOR csr_get_group_plan_info(l_group_per_in_ler_id IN NUMBER)
IS
SELECT group_pl_id, lf_evt_ocrd_dt
FROM ben_per_in_ler
WHERE per_in_ler_id = l_group_per_in_ler_id
AND ROWNUM < 2;

  cursor csr_custom_integrator(l_group_pl_id in Number,
  			                   l_lf_evt_ocrd_dt in Date) is
  select 'BEN_CWB_WS_INTF_' || trim(group_pl_id) intf,
  	     'BEN_CWB_WS_LYT1_' || trim(group_pl_id) base_layout
  from ben_cwb_pl_dsgn
  where custom_integrator is not null
    and group_pl_id = l_group_pl_id
    and lf_evt_ocrd_dt = l_lf_evt_ocrd_dt;

cursor csr_is_read_only (l_intf in varchar2,
                         l_base_layout in varchar2) is
select interface_seq_num, decode(nvl(lay.read_only_flag,'N')||nvl(intf.read_only_flag,'N'), 'NN','N','Y') read_only
  from bne_interface_cols_b intf, bne_layout_cols lay
  where  intf.interface_code = nvl(l_intf,'BEN_CWB_WRK_SHT_INTF')
  and intf.application_id = 800
  and intf.interface_code = lay.interface_code
  and lay.layout_code = nvl(l_base_layout,'BEN_CWB_WRK_SHT_BASE_LYT')
  and lay.application_id = 800
  and intf.sequence_num = lay.interface_seq_num
  and ((intf.sequence_num between 200 and 234) or (intf.sequence_num between 136 and 150));

l_interfac_code        bne_interface_cols_b.interface_code%TYPE;
l_base_layout_code     bne_layout_cols.layout_code%TYPE;
l_is_read_only         csr_is_read_only%RowType;
l_pl_ws_val            BEN_CWB_PERSON_RATES.WS_VAL%Type;
l_group_per_in_ler_id  BEN_CWB_PERSON_RATES.GROUP_PER_IN_LER_ID%Type;
l_cpi_attribute_category  BEN_CWB_PERSON_INFO.cpi_attribute_category%TYPE;
l_cpi_attribute1       BEN_CWB_PERSON_INFO.cpi_attribute1%TYPE;
l_cpi_attribute2       BEN_CWB_PERSON_INFO.cpi_attribute2%TYPE;
l_cpi_attribute3       BEN_CWB_PERSON_INFO.cpi_attribute3%TYPE;
l_cpi_attribute4       BEN_CWB_PERSON_INFO.cpi_attribute4%TYPE;
l_cpi_attribute5       BEN_CWB_PERSON_INFO.cpi_attribute5%TYPE;
l_cpi_attribute6       BEN_CWB_PERSON_INFO.cpi_attribute6%TYPE;
l_cpi_attribute7       BEN_CWB_PERSON_INFO.cpi_attribute7%TYPE;
l_cpi_attribute8       BEN_CWB_PERSON_INFO.cpi_attribute8%TYPE;
l_cpi_attribute9       BEN_CWB_PERSON_INFO.cpi_attribute9%TYPE;
l_cpi_attribute10      BEN_CWB_PERSON_INFO.cpi_attribute10%TYPE;
l_cpi_attribute11      BEN_CWB_PERSON_INFO.cpi_attribute11%TYPE;
l_cpi_attribute12      BEN_CWB_PERSON_INFO.cpi_attribute12%TYPE;
l_cpi_attribute13      BEN_CWB_PERSON_INFO.cpi_attribute13%TYPE;
l_cpi_attribute14      BEN_CWB_PERSON_INFO.cpi_attribute14%TYPE;
l_cpi_attribute15      BEN_CWB_PERSON_INFO.cpi_attribute15%TYPE;
l_cpi_attribute16      BEN_CWB_PERSON_INFO.cpi_attribute16%TYPE;
l_cpi_attribute17      BEN_CWB_PERSON_INFO.cpi_attribute17%TYPE;
l_cpi_attribute18      BEN_CWB_PERSON_INFO.cpi_attribute18%TYPE;
l_cpi_attribute19      BEN_CWB_PERSON_INFO.cpi_attribute19%TYPE;
l_cpi_attribute20      BEN_CWB_PERSON_INFO.cpi_attribute20%TYPE;
l_cpi_attribute21      BEN_CWB_PERSON_INFO.cpi_attribute21%TYPE;
l_cpi_attribute22      BEN_CWB_PERSON_INFO.cpi_attribute22%TYPE;
l_cpi_attribute23      BEN_CWB_PERSON_INFO.cpi_attribute23%TYPE;
l_cpi_attribute24      BEN_CWB_PERSON_INFO.cpi_attribute24%TYPE;
l_cpi_attribute25      BEN_CWB_PERSON_INFO.cpi_attribute25%TYPE;
l_cpi_attribute26      BEN_CWB_PERSON_INFO.cpi_attribute26%TYPE;
l_cpi_attribute27      BEN_CWB_PERSON_INFO.cpi_attribute27%TYPE;
l_cpi_attribute28      BEN_CWB_PERSON_INFO.cpi_attribute28%TYPE;
l_cpi_attribute29      BEN_CWB_PERSON_INFO.cpi_attribute29%TYPE;
l_cpi_attribute30      BEN_CWB_PERSON_INFO.cpi_attribute30%TYPE;
l_custom_segment1      BEN_CWB_PERSON_INFO.custom_segment1%TYPE;
l_custom_segment2      BEN_CWB_PERSON_INFO.custom_segment2%TYPE;
l_custom_segment3      BEN_CWB_PERSON_INFO.custom_segment3%TYPE;
l_custom_segment4      BEN_CWB_PERSON_INFO.custom_segment4%TYPE;
l_custom_segment5      BEN_CWB_PERSON_INFO.custom_segment5%TYPE;
l_custom_segment6      BEN_CWB_PERSON_INFO.custom_segment6%TYPE;
l_custom_segment7      BEN_CWB_PERSON_INFO.custom_segment7%TYPE;
l_custom_segment8      BEN_CWB_PERSON_INFO.custom_segment8%TYPE;
l_custom_segment9      BEN_CWB_PERSON_INFO.custom_segment9%TYPE;
l_custom_segment10     BEN_CWB_PERSON_INFO.custom_segment10%TYPE;
l_custom_segment11     BEN_CWB_PERSON_INFO.custom_segment11%TYPE;
l_custom_segment12     BEN_CWB_PERSON_INFO.custom_segment12%TYPE;
l_custom_segment13     BEN_CWB_PERSON_INFO.custom_segment13%TYPE;
l_custom_segment14     BEN_CWB_PERSON_INFO.custom_segment14%TYPE;
l_custom_segment15     BEN_CWB_PERSON_INFO.custom_segment15%TYPE;
l_custom_segment16     BEN_CWB_PERSON_INFO.custom_segment16%TYPE;
l_custom_segment17     BEN_CWB_PERSON_INFO.custom_segment17%TYPE;
l_custom_segment18     BEN_CWB_PERSON_INFO.custom_segment18%TYPE;
l_custom_segment19     BEN_CWB_PERSON_INFO.custom_segment19%TYPE;
l_custom_segment20     BEN_CWB_PERSON_INFO.custom_segment20%TYPE;
l_ovn                  BEN_CWB_PERSON_INFO.object_version_number%TYPE;
l_proc   varchar2(72) := g_package||'handle_row';
l_pl_person_rate_id    Number := null;
l_opt1_person_rate_id  Number := null;
l_opt2_person_rate_id  Number := null;
l_opt3_person_rate_id  Number := null;
l_opt4_person_rate_id  Number := null;
l_task_id	       Number := null;
l_sec_mgr_ler_id       Number := null;
l_acting_person_id     Number := null;
l_decrypt_switch       varchar2(200) := null;
l_download_switch      varchar2(200) := null;
l_diff                 number := null;
l_group_pl_id Number := null;
l_lf_evt_ocrd_dt Date := null;

BEGIN

If g_debug then
   hr_utility.set_location('Entering '||l_proc,10);
End if;

--Clear message
   hr_utility.clear_message;

-- Issue Savepoint
    savepoint update_data;
--
--
BEN_CWB_SUMMARY_PKG.delete_pl_sql_tab;



IF  (P_PL_PERSON_RATE_ID  IS  NULL
     AND  P_P_OPT1_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT2_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT3_PERSON_RATE_ID IS  NULL
     AND  P_P_OPT4_PERSON_RATE_ID IS  NULL) THEN

     hr_utility.set_message(805,'BEN_CWB_PL_OPT_NOT_EXISTS');
     hr_utility.raise_error;
END IF;

IF (P_PL_PERSON_RATE_ID IS NOT NULL) THEN
   l_PL_PERSON_RATE_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_PL_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_PL_PERSON_RATE_ID   :'||l_PL_PERSON_RATE_ID,20);
   End if;
END IF;

IF (P_P_OPT1_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT1_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT1_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT1_PERSON_RATE_ID :'||l_OPT1_PERSON_RATE_ID,30);
   End if;
END IF;

IF (P_P_OPT2_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT2_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT2_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT2_PERSON_RATE_ID :'||l_OPT2_PERSON_RATE_ID,40);
   End if;
END IF;

IF (P_P_OPT3_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT3_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT3_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT3_PERSON_RATE_ID :'||l_OPT3_PERSON_RATE_ID,50);
   End if;
END IF;

IF (P_P_OPT4_PERSON_RATE_ID IS NOT NULL) THEN
   l_OPT4_PERSON_RATE_ID := BEN_CWB_WEBADI_UTILS.decrypt(P_P_OPT4_PERSON_RATE_ID);
   If g_debug then
    hr_utility.set_location('l_OPT4_PERSON_RATE_ID :'||l_OPT4_PERSON_RATE_ID,60);
   End if;
END IF;

IF (P_TASK_ID IS NOT NULL) THEN
   l_TASK_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_TASK_ID);
   If g_debug then
    hr_utility.set_location('l_TASK_ID   :'||l_TASK_ID,65);
   End if;
END IF;

IF (P_SEC_MGR_LER_ID IS NOT NULL) THEN
   l_SEC_MGR_LER_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_SEC_MGR_LER_ID);
   If g_debug then
    hr_utility.set_location('l_SEC_MGR_LER_ID   :'||l_SEC_MGR_LER_ID,67);
   End if;
END IF;

IF (P_ACTING_PERSON_ID IS NOT NULL) THEN
   l_ACTING_PERSON_ID   := BEN_CWB_WEBADI_UTILS.decrypt(P_ACTING_PERSON_ID);
   If g_debug then
    hr_utility.set_location('P_ACTING_PERSON_ID   :'||l_ACTING_PERSON_ID,68);
   End if;
END IF;

-- Using hexadecimal to store the upload column availability information.

IF (P_DOWNLOAD_SWITCH IS NOT NULL) THEN
   l_decrypt_switch    := BEN_CWB_WEBADI_UTILS.decrypt(p_download_switch);
   l_download_switch   := lpad(ben_cwb_webadi_utils.int2bin(ben_cwb_webadi_utils.hex2int(substr(l_decrypt_switch,1,7))),28,0);
   l_download_switch   := nvl(l_download_switch || lpad(nvl(ben_cwb_webadi_utils.int2bin(ben_cwb_webadi_utils.hex2int(substr(rtrim(l_decrypt_switch),8,14))),'0'),28,0),'0');
   if g_debug then
    hr_utility.set_location('p_download_switch (Decrypted)  :'||l_decrypt_switch,69);
   End if;
   l_download_switch   := REPLACE(REPLACE(l_download_switch,'1','2'),'0','1');
   l_download_switch   := substr(l_download_switch,2);
   if g_debug then
    hr_utility.set_location('l_final_download_Switch   :'||l_download_switch,70);
   End if;
END IF;

If g_debug then
   hr_utility.set_location('P_PL_WS_VAL   : '||P_PL_WS_VAL,75);
   hr_utility.set_location('P_OPT1_WS_VAL : '||P_OPT1_WS_VAL,80);
   hr_utility.set_location('P_OPT2_WS_VAL : '||P_OPT2_WS_VAL,90);
   hr_utility.set_location('P_OPT3_WS_VAL : '||P_OPT3_WS_VAL,100);
   hr_utility.set_location('P_OPT4_WS_VAL : '||P_OPT4_WS_VAL,110);
End if;


 l_group_per_in_ler_id := get_group_per_in_ler_id(l_PL_PERSON_RATE_ID,
                                                  l_OPT1_PERSON_RATE_ID,
                                                  l_OPT2_PERSON_RATE_ID,
                                                  l_OPT3_PERSON_RATE_ID,
                                                  l_OPT4_PERSON_RATE_ID);

-- Check for people that have already been Processed.
-- If already processed, raise error.

chk_processed_emp (P_PERSON_RATE_ID       => l_PL_PERSON_RATE_ID
                   ,P_OPT1_PERSON_RATE_ID  => l_OPT1_PERSON_RATE_ID
                   ,P_OPT2_PERSON_RATE_ID  => l_OPT2_PERSON_RATE_ID
                   ,P_OPT3_PERSON_RATE_ID  => l_OPT3_PERSON_RATE_ID
                   ,P_OPT4_PERSON_RATE_ID  => l_OPT4_PERSON_RATE_ID
                   ,P_EMP_PER_IN_LER_ID    => l_group_per_in_ler_id			-- bug: 8996634
                   ,P_MGR_PER_IN_LER_ID    => l_SEC_MGR_LER_ID);

 If g_debug then
   hr_utility.set_location('l_group_per_in_ler_id : '||l_group_per_in_ler_id,111);
 End if;

l_interfac_code := null;
l_base_layout_code := null;
FOR l_get_group_plan_info in csr_get_group_plan_info(l_group_per_in_ler_id) loop
    FOR l_custom_integrator in csr_custom_integrator (l_get_group_plan_info.group_pl_id, l_get_group_plan_info.lf_evt_ocrd_dt) loop
        l_interfac_code := l_custom_integrator.intf;
        l_base_layout_code := l_custom_integrator.base_layout;
        If g_debug then
            hr_utility.set_location('l_interfac_code   : '||l_interfac_code,112);
            hr_utility.set_location('l_base_layout_code : '||l_base_layout_code,113);
        end if;
    END LOOP;
END LOOP;

 -- If No Options Exist then allow Modifying the Plan Worksheet Amount
 IF (l_PL_PERSON_RATE_ID IS NOT NULL
     AND  l_OPT1_PERSON_RATE_ID IS  NULL
     AND  l_OPT2_PERSON_RATE_ID IS  NULL
     AND  l_OPT3_PERSON_RATE_ID IS  NULL
     AND  l_OPT4_PERSON_RATE_ID IS  NULL   ) THEN

     If g_debug then
        hr_utility.set_location('No Options Exists',120);
     end if;

 IF(substr(l_DOWNLOAD_SWITCH,1,1) = '2') THEN
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID => l_PL_PERSON_RATE_ID
                         ,P_WS_VAL         => P_PL_WS_VAL
                         ,P_USER_ID        => P_USER_ID
                         ,P_WS_RT_START_DATE =>P_PL_RT_START_DATE );
     If g_debug then
        hr_utility.set_location('Updated Plan WS Amt Sucessfully',130);
     End if;
    End If;

    -- ER: ability to update other rates
    IF(substr(l_DOWNLOAD_SWITCH,39,1) = '2') THEN
        update_other_rates(P_PERSON_RATE_ID => l_PL_PERSON_RATE_ID
                          ,p_interface_seq  => g_iterface_seq_type(8,10,11,19,20,21)
                          ,p_values         => g_iterface_seq_type(P_PL_STAT_SAL_VAL,P_PL_OTH_COMP_VAL,P_PL_TOT_COMP_VAL,
                                                    P_PL_MISC1_VAL,P_PL_MISC2_VAL,P_PL_MISC3_VAL)
                          ,p_interface_code => l_interfac_code
                          ,p_base_layout_code => l_base_layout_code );
      If g_debug then
        hr_utility.set_location('Updated Plan Other Rates Sucessfully',130);
      End if;
    End If;

 ELSE
 -- Update Option Record with Modified Option Worksheet Amount

     If g_debug then
        hr_utility.set_location('Options Exists',140);
     end if;

     -- Plan :
     -- If Option Rates exists for a Plan
     --    and User tries to update Plan WS Val then Raise Error

     Open Csr_get_pl_ws_val(l_PL_PERSON_RATE_ID);
     Fetch Csr_get_pl_ws_val into l_pl_ws_val;
     Close Csr_get_pl_ws_val;

     If g_debug then
        hr_utility.set_location('l_pl_ws_val :'||l_pl_ws_val,150);
     end if;

     IF (l_pl_ws_val <> P_PL_WS_VAL) THEN
        hr_utility.set_message(805,'BEN_7830_CWB_NOT_UPD_PL_WSVAL');
        hr_utility.raise_error;
     END IF;

     -- Option 1 :
     IF  (l_OPT1_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,2,1) = '2') THEN
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID => l_OPT1_PERSON_RATE_ID
                          ,P_WS_VAL         => P_OPT1_WS_VAL
                          ,P_USER_ID        => P_USER_ID
                          ,P_WS_RT_START_DATE => P_OPT1_RT_START_DATE);
         if l_pl_person_rate_id is null then
           l_pl_person_rate_id :=get_plan_person_rate_id(l_OPT1_PERSON_RATE_ID);
         end if;

 	 IF NVL(l_diff,0) <> 0 THEN  -- bug: 8845299
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID =>  l_PL_PERSON_RATE_ID
                              ,p_add_val  => l_diff
                              ,P_USER_ID        => P_USER_ID
                              ,P_WS_RT_START_DATE => P_PL_RT_START_DATE);
	end if;

        If g_debug then
           hr_utility.set_location('Updated Option1 WS Amt Sucessfully',160);
        end if;

     END IF;

    -- ER: ability to update other rates
     IF  (l_OPT1_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,40,1) = '2') THEN
     update_other_rates(P_PERSON_RATE_ID => l_OPT1_PERSON_RATE_ID
                          ,p_interface_seq  => g_iterface_seq_type(26,28,29,37,38,39)
                          ,p_values         => g_iterface_seq_type(P_OPT1_STAT_SAL_VAL,P_OPT1_OTH_COMP_VAL,P_OPT1_TOT_COMP_VAL,
                                                    P_OPT1_MISC1_VAL,P_OPT1_MISC2_VAL,P_OPT1_MISC3_VAL)
                          ,p_interface_code => l_interfac_code
                          ,p_base_layout_code => l_base_layout_code );
        If g_debug then
          hr_utility.set_location('Updated Option 1 Other Rates Sucessfully',130);
        End if;
     END IF;

     -- Option 2 :
     IF  (l_OPT2_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,3,1) = '2') THEN
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID => l_OPT2_PERSON_RATE_ID
                          ,P_WS_VAL         => P_OPT2_WS_VAL
                          ,P_USER_ID        => P_USER_ID
                          ,P_WS_RT_START_DATE => P_OPT2_RT_START_DATE);
         if l_pl_person_rate_id is null then
           l_pl_person_rate_id :=get_plan_person_rate_id(l_OPT1_PERSON_RATE_ID);         end if;

	 IF NVL(l_diff,0) <> 0 THEN  -- bug: 8845299
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID =>  l_PL_PERSON_RATE_ID
                              ,p_add_val  => l_diff
                              ,P_USER_ID        => P_USER_ID
                              ,P_WS_RT_START_DATE => P_PL_RT_START_DATE);
	end if;

        If g_debug then
           hr_utility.set_location('Updated Option2 WS Amt Sucessfully',170);
        end if;

     END IF;

     -- ER: ability to update other rates
     IF  (l_OPT1_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,41,1) = '2') THEN
     update_other_rates(P_PERSON_RATE_ID => l_OPT2_PERSON_RATE_ID
                          ,p_interface_seq  => g_iterface_seq_type(44,46,47,55,56,57)
                          ,p_values         => g_iterface_seq_type(P_OPT2_STAT_SAL_VAL,P_OPT2_OTH_COMP_VAL,P_OPT2_TOT_COMP_VAL,
                                                    P_OPT2_MISC1_VAL,P_OPT2_MISC2_VAL,P_OPT2_MISC3_VAL)
                          ,p_interface_code => l_interfac_code
                          ,p_base_layout_code => l_base_layout_code );
        If g_debug then
          hr_utility.set_location('Updated Option 2 Other Rates Sucessfully',130);
        End if;
     END IF;

     -- Option 3 :
     IF  (l_OPT3_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,4,1) = '2') THEN
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID => l_OPT3_PERSON_RATE_ID
                          ,P_WS_VAL         => P_OPT3_WS_VAL
                          ,P_USER_ID        => P_USER_ID
                          ,P_WS_RT_START_DATE => P_OPT3_RT_START_DATE);
         if l_pl_person_rate_id is null then
           l_pl_person_rate_id :=get_plan_person_rate_id(l_OPT1_PERSON_RATE_ID);         end if;

	  IF NVL(l_diff,0) <> 0 THEN  -- bug: 8845299
          l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID =>  l_PL_PERSON_RATE_ID
                              ,p_add_val  => l_diff
                              ,P_USER_ID        => P_USER_ID
                              ,P_WS_RT_START_DATE => P_PL_RT_START_DATE);
	end if;

        If g_debug then
           hr_utility.set_location('Updated Option3 WS Amt Sucessfully',180);
        end if;


     END IF;

     -- ER: ability to update other rates
     IF  (l_OPT1_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,42,1) = '2') THEN
     update_other_rates(P_PERSON_RATE_ID => l_OPT3_PERSON_RATE_ID
                          ,p_interface_seq  => g_iterface_seq_type(62,64,65,73,74,75)
                          ,p_values         => g_iterface_seq_type(P_OPT3_STAT_SAL_VAL,P_OPT3_OTH_COMP_VAL,P_OPT3_TOT_COMP_VAL,
                                                    P_OPT3_MISC1_VAL,P_OPT3_MISC2_VAL,P_OPT3_MISC3_VAL)
                          ,p_interface_code => l_interfac_code
                          ,p_base_layout_code => l_base_layout_code );
        If g_debug then
          hr_utility.set_location('Updated Option 3 Other Rates Sucessfully',130);
        End if;
     END IF;

     -- Option 4 :
     IF  (l_OPT4_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,5,1) = '2') THEN
         l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID => l_OPT4_PERSON_RATE_ID
                          ,P_WS_VAL         => P_OPT4_WS_VAL
                          ,P_USER_ID        => P_USER_ID
                          ,P_WS_RT_START_DATE => P_OPT4_RT_START_DATE);
         if l_pl_person_rate_id is null then
           l_pl_person_rate_id :=get_plan_person_rate_id(l_OPT1_PERSON_RATE_ID);         end if;

	  IF NVL(l_diff,0) <> 0 THEN  -- bug: 8845299
          l_diff := UPDATE_WS_AMOUNT(P_PERSON_RATE_ID =>  l_PL_PERSON_RATE_ID
                              ,p_add_val  => l_diff
                              ,P_USER_ID        => P_USER_ID
                              ,P_WS_RT_START_DATE => P_PL_RT_START_DATE);
	end if;

        If g_debug then
           hr_utility.set_location('Updated Option4 WS Amt Sucessfully',190);
        end if;


     END IF;

     -- ER: ability to update other rates
     IF  (l_OPT1_PERSON_RATE_ID IS NOT NULL AND substr(l_DOWNLOAD_SWITCH,43,1) = '2') THEN
     update_other_rates(P_PERSON_RATE_ID => l_OPT4_PERSON_RATE_ID
                          ,p_interface_seq  => g_iterface_seq_type(80,82,83,91,92,93)
                          ,p_values         => g_iterface_seq_type(P_OPT4_STAT_SAL_VAL,P_OPT4_OTH_COMP_VAL,P_OPT4_TOT_COMP_VAL,
                                                    P_OPT4_MISC1_VAL,P_OPT4_MISC2_VAL,P_OPT4_MISC3_VAL)
                          ,p_interface_code => l_interfac_code
                          ,p_base_layout_code => l_base_layout_code );
        If g_debug then
          hr_utility.set_location('Updated Option 4 Other Rates Sucessfully',130);
        End if;
     END IF;

 END IF;

 If g_debug then
  hr_utility.set_location('Updated Worksheet Amount Sucessfully ',200);
 End if;


 -- Update Rank


 IF(substr(l_DOWNLOAD_SWITCH,7,1) = '2') THEN

    UPDATE_RANK(P_GROUP_PER_IN_LER_ID  => l_group_per_in_ler_id
               ,P_RANK                 => P_RANK
               ,P_USER_ID              => l_ACTING_PERSON_ID);
 If g_debug then
  hr_utility.set_location('Updated Rank Sucessfully ',220);
 End if;

 END IF;

BEN_CWB_SUMMARY_PKG.save_pl_sql_tab;

If g_debug then
 hr_utility.set_location('save_pl_sql_tab Sucessfully ',230);
End if;

-- Proposed Performance Rating

IF(substr(l_DOWNLOAD_SWITCH,6,1) = '2') THEN
    update_perf_rating(P_PROPOSED_PERFORMANCE_RATING =>P_PROPOSED_PERFORMANCE_RATING
                             ,P_ACTING_PERSON_ID     => l_ACTING_PERSON_ID
                             ,P_PERSON_RATE_ID       => l_PL_PERSON_RATE_ID
                             ,P_OPT1_PERSON_RATE_ID  => l_OPT1_PERSON_RATE_ID
                             ,P_OPT2_PERSON_RATE_ID  => l_OPT2_PERSON_RATE_ID
                             ,P_OPT3_PERSON_RATE_ID  => l_OPT3_PERSON_RATE_ID
                             ,P_OPT4_PERSON_RATE_ID  => l_OPT4_PERSON_RATE_ID);
If g_debug then
  hr_utility.set_location('Updated Proposed Performance Rating Sucessfully ',240);
End if;
END IF;

IF(substr(l_DOWNLOAD_SWITCH,38,1) = '2') THEN
    update_promotions(P_PROPOSED_JOB =>P_PROPOSED_JOB
                             ,P_PROPOSED_POSITION => P_PROPOSED_POSITION
                             ,P_PROPOSED_GRADE => P_PROPOSED_GRADE
                             ,P_CHANGE_REASON => P_CHANGE_REASON
                             ,P_ACTING_PERSON_ID     => l_ACTING_PERSON_ID
                             ,P_PERSON_RATE_ID       => l_PL_PERSON_RATE_ID
                             ,P_OPT1_PERSON_RATE_ID  => l_OPT1_PERSON_RATE_ID
                             ,P_OPT2_PERSON_RATE_ID  => l_OPT2_PERSON_RATE_ID
                             ,P_OPT3_PERSON_RATE_ID  => l_OPT3_PERSON_RATE_ID
                             ,P_OPT4_PERSON_RATE_ID  => l_OPT4_PERSON_RATE_ID);

If g_debug then
  hr_utility.set_location('Updated Proposed Promotion Sucessfully ',240);
End if;
END IF;

-- Update Person Tasks Table
REFRESH_PERSON_TASKS (P_PERSON_RATE_ID       => l_PL_PERSON_RATE_ID
                     ,P_OPT1_PERSON_RATE_ID  => l_OPT1_PERSON_RATE_ID
                     ,P_OPT2_PERSON_RATE_ID  => l_OPT2_PERSON_RATE_ID
                     ,P_OPT3_PERSON_RATE_ID  => l_OPT3_PERSON_RATE_ID
                     ,P_OPT4_PERSON_RATE_ID  => l_OPT4_PERSON_RATE_ID
                     ,P_TASK_ID              => l_TASK_ID
                     ,P_SEC_MGR_LER_ID       => l_SEC_MGR_LER_ID );

If g_debug then
 hr_utility.set_location('Update Person Tasks Table Sucessfully ',250);
End if;

-- Update the CPI Flex
-- Update CPI Flex
OPEN csr_cpi_flex_info(l_group_per_in_ler_id);
FETCH csr_cpi_flex_info INTO l_cpi_attribute_category,
                             l_cpi_attribute1,
                             l_cpi_attribute2,
                             l_cpi_attribute3,
                             l_cpi_attribute4,
                             l_cpi_attribute5,
                             l_cpi_attribute6,
                             l_cpi_attribute7,
                             l_cpi_attribute8,
                             l_cpi_attribute9,
                             l_cpi_attribute10,
                             l_cpi_attribute11,
                             l_cpi_attribute12,
                             l_cpi_attribute13,
                             l_cpi_attribute14,
                             l_cpi_attribute15,
                             l_cpi_attribute16,
                             l_cpi_attribute17,
                             l_cpi_attribute18,
                             l_cpi_attribute19,
                             l_cpi_attribute20,
                             l_cpi_attribute21,
                             l_cpi_attribute22,
                             l_cpi_attribute23,
                             l_cpi_attribute24,
                             l_cpi_attribute25,
                             l_cpi_attribute26,
                             l_cpi_attribute27,
                             l_cpi_attribute28,
                             l_cpi_attribute29,
                             l_cpi_attribute30,
			     l_custom_segment1,
                             l_custom_segment2,
                             l_custom_segment3,
                             l_custom_segment4,
                             l_custom_segment5,
                             l_custom_segment6,
                             l_custom_segment7,
                             l_custom_segment8,
                             l_custom_segment9,
                             l_custom_segment10,
                             l_custom_segment11,
                             l_custom_segment12,
                             l_custom_segment13,
                             l_custom_segment14,
                             l_custom_segment15,
                             l_custom_segment16,
                             l_custom_segment17,
                             l_custom_segment18,
                             l_custom_segment19,
                             l_custom_segment20,
                             l_ovn;
CLOSE csr_cpi_flex_info;


FOR l_is_read_only in csr_is_read_only(l_interfac_code,l_base_layout_code) LOOP

IF(l_is_read_only.interface_seq_num = '136' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment1  := check_varchar_col_avble(l_custom_segment1 ,p_custom_segment1);
END IF;
IF(l_is_read_only.interface_seq_num = '137' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment2  := check_varchar_col_avble(l_custom_segment2 ,p_custom_segment2);
END IF;
IF(l_is_read_only.interface_seq_num = '138' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment3  := check_varchar_col_avble(l_custom_segment3 ,p_custom_segment3);
END IF;
IF(l_is_read_only.interface_seq_num = '139' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment4  := check_varchar_col_avble(l_custom_segment4 ,p_custom_segment4);
END IF;
IF(l_is_read_only.interface_seq_num = '140' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment5  := check_varchar_col_avble(l_custom_segment5 ,p_custom_segment5);
END IF;
IF(l_is_read_only.interface_seq_num = '141' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment6  := check_varchar_col_avble(l_custom_segment6 ,p_custom_segment6);
END IF;
IF(l_is_read_only.interface_seq_num = '142' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment7  := check_varchar_col_avble(l_custom_segment7 ,p_custom_segment7);
END IF;
IF(l_is_read_only.interface_seq_num = '143' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment8  := check_varchar_col_avble(l_custom_segment8 ,p_custom_segment8);
END IF;
IF(l_is_read_only.interface_seq_num = '144' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment9  := check_varchar_col_avble(l_custom_segment9 ,p_custom_segment9);
END IF;
IF(l_is_read_only.interface_seq_num = '145' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment10 := check_varchar_col_avble(l_custom_segment10,p_custom_segment10);
END IF;
IF(l_is_read_only.interface_seq_num = '146' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment11 := check_number_col_avble(l_custom_segment11,p_custom_segment11);
END IF;
IF(l_is_read_only.interface_seq_num = '147' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment12 := check_number_col_avble(l_custom_segment12,p_custom_segment12);
END IF;
IF(l_is_read_only.interface_seq_num = '148' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment13 := check_number_col_avble(l_custom_segment13,p_custom_segment13);
END IF;
IF(l_is_read_only.interface_seq_num = '149' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment14 := check_number_col_avble(l_custom_segment14,p_custom_segment14);
END IF;
IF(l_is_read_only.interface_seq_num = '150' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment15 := check_number_col_avble(l_custom_segment15,p_custom_segment15);
END IF;
IF(l_is_read_only.interface_seq_num = '230' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment16 := check_number_col_avble(l_custom_segment16,p_custom_segment16);
END IF;
IF(l_is_read_only.interface_seq_num = '231' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment17 := check_number_col_avble(l_custom_segment17,p_custom_segment17);
END IF;
IF(l_is_read_only.interface_seq_num = '232' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment18 := check_number_col_avble(l_custom_segment18,p_custom_segment18);
END IF;
IF(l_is_read_only.interface_seq_num = '233' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment19 := check_number_col_avble(l_custom_segment19,p_custom_segment19);
END IF;
IF(l_is_read_only.interface_seq_num = '234' AND l_is_read_only.read_only = 'N') THEN
	l_custom_segment20 := check_number_col_avble(l_custom_segment20,p_custom_segment20);
END IF;

IF(l_is_read_only.interface_seq_num = '200' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,8,1) = '2') THEN
 l_cpi_attribute1 := check_varchar_col_avble(l_cpi_attribute1 ,p_cpi_attribute1);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute1',251);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '201' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,9,1) = '2') THEN
 l_cpi_attribute2 := check_varchar_col_avble(l_cpi_attribute2 ,p_cpi_attribute2);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute2',252);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '202' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,10,1) = '2') THEN
 l_cpi_attribute3 := check_varchar_col_avble(l_cpi_attribute3 ,p_cpi_attribute3);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute3',253);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '203' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,11,1) = '2') THEN
 l_cpi_attribute4 := check_varchar_col_avble(l_cpi_attribute4 ,p_cpi_attribute4);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute4',254);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '204' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,12,1) = '2') THEN
 l_cpi_attribute5 := check_varchar_col_avble(l_cpi_attribute5 ,p_cpi_attribute5);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute5',255);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '205' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,13,1) = '2') THEN
 l_cpi_attribute6 := check_varchar_col_avble(l_cpi_attribute6 ,p_cpi_attribute6);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute6',256);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '206' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,14,1) = '2') THEN
 l_cpi_attribute7 := check_varchar_col_avble(l_cpi_attribute7 ,p_cpi_attribute7);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute7',257);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '207' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,15,1) = '2') THEN
 l_cpi_attribute8 := check_varchar_col_avble(l_cpi_attribute8 ,p_cpi_attribute8);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute8',258);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '208' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,16,1) = '2') THEN
 l_cpi_attribute9 := check_varchar_col_avble(l_cpi_attribute9 ,p_cpi_attribute9);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute9',259);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '209' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,17,1) = '2') THEN
 l_cpi_attribute10 := check_varchar_col_avble(l_cpi_attribute10 ,p_cpi_attribute10);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute10',260);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '210' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,18,1) = '2') THEN
 l_cpi_attribute11 := check_varchar_col_avble(l_cpi_attribute11 ,p_cpi_attribute11);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute11',261);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '211' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,19,1) = '2') THEN
 l_cpi_attribute12 := check_varchar_col_avble(l_cpi_attribute12 ,p_cpi_attribute12);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute12',262);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '212' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,20,1) = '2') THEN
 l_cpi_attribute13 := check_varchar_col_avble(l_cpi_attribute13 ,p_cpi_attribute13);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute13',263);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '213' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,21,1) = '2') THEN
 l_cpi_attribute14 := check_varchar_col_avble(l_cpi_attribute14 ,p_cpi_attribute14);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute14',264);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '214' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,22,1) = '2') THEN
 l_cpi_attribute15 := check_varchar_col_avble(l_cpi_attribute15 ,p_cpi_attribute15);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute15',265);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '215' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,23,1) = '2') THEN
 l_cpi_attribute16 := check_varchar_col_avble(l_cpi_attribute16 ,p_cpi_attribute16);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute16',266);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '216' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,24,1) = '2') THEN
 l_cpi_attribute17 := check_varchar_col_avble(l_cpi_attribute17 ,p_cpi_attribute17);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute17',267);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '217' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,25,1) = '2') THEN
 l_cpi_attribute18 := check_varchar_col_avble(l_cpi_attribute18 ,p_cpi_attribute18);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute18',268);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '218' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,26,1) = '2') THEN
 l_cpi_attribute19 := check_varchar_col_avble(l_cpi_attribute19 ,p_cpi_attribute19);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute19',269);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '219' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,27,1) = '2') THEN
 l_cpi_attribute20 := check_varchar_col_avble(l_cpi_attribute20 ,p_cpi_attribute20);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute20',270);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '220' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,28,1) = '2') THEN
 l_cpi_attribute21 := check_varchar_col_avble(l_cpi_attribute21 ,p_cpi_attribute21);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute21',271);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '221' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,29,1) = '2') THEN
 l_cpi_attribute22 := check_varchar_col_avble(l_cpi_attribute22 ,p_cpi_attribute22);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute22',272);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '222' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,30,1) = '2') THEN
 l_cpi_attribute23 := check_varchar_col_avble(l_cpi_attribute23 ,p_cpi_attribute23);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute23',273);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '223' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,31,1) = '2') THEN
 l_cpi_attribute24 := check_varchar_col_avble(l_cpi_attribute24 ,p_cpi_attribute24);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute24',274);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '224' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,32,1) = '2') THEN
 l_cpi_attribute25 := check_varchar_col_avble(l_cpi_attribute25 ,p_cpi_attribute25);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute25',275);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '225' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,33,1) = '2') THEN
 l_cpi_attribute26 := check_varchar_col_avble(l_cpi_attribute26 ,p_cpi_attribute26);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute26',276);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '226' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,34,1) = '2') THEN
 l_cpi_attribute27 := check_varchar_col_avble(l_cpi_attribute27 ,p_cpi_attribute27);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute27',277);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '227' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,35,1) = '2') THEN
 l_cpi_attribute28 := check_varchar_col_avble(l_cpi_attribute28 ,p_cpi_attribute28);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute28',278);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '228' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,36,1) = '2') THEN
 l_cpi_attribute29 := check_varchar_col_avble(l_cpi_attribute29 ,p_cpi_attribute29);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute29',279);
 End if;
END IF;
END IF;
IF(l_is_read_only.interface_seq_num = '229' AND l_is_read_only.read_only = 'N') THEN
IF(substr(l_DOWNLOAD_SWITCH,37,1) = '2') THEN
 l_cpi_attribute30 := check_varchar_col_avble(l_cpi_attribute30 ,p_cpi_attribute30);
 If g_debug then
  hr_utility.set_location('Upload CPI Attribute30',280);
 End if;
END IF;
END IF;

END LOOP;

BEN_CWB_PERSON_INFO_API.update_person_info
                   ( P_GROUP_PER_IN_LER_ID => l_GROUP_PER_IN_LER_ID
                    ,P_CPI_ATTRIBUTE_CATEGORY  => P_CPI_ATTRIBUTE_CATEGORY
                    ,P_CPI_ATTRIBUTE1  => L_CPI_ATTRIBUTE1
                    ,P_CPI_ATTRIBUTE2  => L_CPI_ATTRIBUTE2
                    ,P_CPI_ATTRIBUTE3  => l_CPI_ATTRIBUTE3
                    ,P_CPI_ATTRIBUTE4  => l_CPI_ATTRIBUTE4
                    ,P_CPI_ATTRIBUTE5  => l_CPI_ATTRIBUTE5
                    ,P_CPI_ATTRIBUTE6  => l_CPI_ATTRIBUTE6
                    ,P_CPI_ATTRIBUTE7  => l_CPI_ATTRIBUTE7
                    ,P_CPI_ATTRIBUTE8  => l_CPI_ATTRIBUTE8
                    ,P_CPI_ATTRIBUTE9  => l_CPI_ATTRIBUTE9
                    ,P_CPI_ATTRIBUTE10 => l_CPI_ATTRIBUTE10
                    ,P_CPI_ATTRIBUTE11 => l_CPI_ATTRIBUTE11
                    ,P_CPI_ATTRIBUTE12 => l_CPI_ATTRIBUTE12
                    ,P_CPI_ATTRIBUTE13 => l_CPI_ATTRIBUTE13
                    ,P_CPI_ATTRIBUTE14 => l_CPI_ATTRIBUTE14
                    ,P_CPI_ATTRIBUTE15 => l_CPI_ATTRIBUTE15
                    ,P_CPI_ATTRIBUTE16 => l_CPI_ATTRIBUTE16
                    ,P_CPI_ATTRIBUTE17 => l_CPI_ATTRIBUTE17
                    ,P_CPI_ATTRIBUTE18 => l_CPI_ATTRIBUTE18
                    ,P_CPI_ATTRIBUTE19 => l_CPI_ATTRIBUTE19
                    ,P_CPI_ATTRIBUTE20 => l_CPI_ATTRIBUTE20
                    ,P_CPI_ATTRIBUTE21 => l_CPI_ATTRIBUTE21
                    ,P_CPI_ATTRIBUTE22 => l_CPI_ATTRIBUTE22
                    ,P_CPI_ATTRIBUTE23 => l_CPI_ATTRIBUTE23
                    ,P_CPI_ATTRIBUTE24 => l_CPI_ATTRIBUTE24
                    ,P_CPI_ATTRIBUTE25 => l_CPI_ATTRIBUTE25
                    ,P_CPI_ATTRIBUTE26 => l_CPI_ATTRIBUTE26
                    ,P_CPI_ATTRIBUTE27 => l_CPI_ATTRIBUTE27
                    ,P_CPI_ATTRIBUTE28 => l_CPI_ATTRIBUTE28
                    ,P_CPI_ATTRIBUTE29 => l_CPI_ATTRIBUTE29
                    ,P_CPI_ATTRIBUTE30 => l_CPI_ATTRIBUTE30
		    ,P_CUSTOM_SEGMENT1  => l_CUSTOM_SEGMENT1
		    ,P_CUSTOM_SEGMENT2  => l_CUSTOM_SEGMENT2
		    ,P_CUSTOM_SEGMENT3  => l_CUSTOM_SEGMENT3
		    ,P_CUSTOM_SEGMENT4  => l_CUSTOM_SEGMENT4
		    ,P_CUSTOM_SEGMENT5  => l_CUSTOM_SEGMENT5
		    ,P_CUSTOM_SEGMENT6  => l_CUSTOM_SEGMENT6
		    ,P_CUSTOM_SEGMENT7  => l_CUSTOM_SEGMENT7
		    ,P_CUSTOM_SEGMENT8  => l_CUSTOM_SEGMENT8
		    ,P_CUSTOM_SEGMENT9  => l_CUSTOM_SEGMENT9
		    ,P_CUSTOM_SEGMENT10 => l_CUSTOM_SEGMENT10
		    ,P_CUSTOM_SEGMENT11 => l_CUSTOM_SEGMENT11
		    ,P_CUSTOM_SEGMENT12 => l_CUSTOM_SEGMENT12
		    ,P_CUSTOM_SEGMENT13 => l_CUSTOM_SEGMENT13
		    ,P_CUSTOM_SEGMENT14 => l_CUSTOM_SEGMENT14
		    ,P_CUSTOM_SEGMENT15 => l_CUSTOM_SEGMENT15
		    ,P_CUSTOM_SEGMENT16 => l_CUSTOM_SEGMENT16
		    ,P_CUSTOM_SEGMENT17 => l_CUSTOM_SEGMENT17
		    ,P_CUSTOM_SEGMENT18 => l_CUSTOM_SEGMENT18
		    ,P_CUSTOM_SEGMENT19 => l_CUSTOM_SEGMENT19
                    ,P_CUSTOM_SEGMENT20 => l_CUSTOM_SEGMENT20
                    ,P_OBJECT_VERSION_NUMBER => L_OVN);
If g_debug then
  hr_utility.set_location('Updated CPI Flex Rating Sucessfully ',281);
End if;

--
-- Call the routine for dynamic calculations.
--
open csr_get_group_plan_info(l_group_per_in_ler_id);
fetch csr_get_group_plan_info into l_group_pl_id, l_lf_evt_ocrd_dt;
close csr_get_group_plan_info;
--
ben_cwb_dyn_calc_pkg.run_dynamic_calculations(
            p_group_per_in_ler_id => l_group_per_in_ler_id
           ,p_group_pl_id         => l_group_pl_id
           ,p_lf_evt_ocrd_dt      => l_lf_evt_ocrd_dt
           ,p_raise_error         => true);
--

If g_debug then
  hr_utility.set_location('Leaving '||l_proc,290);
End if;

 EXCEPTION
       WHEN Others THEN
       if g_debug then
              hr_utility.set_location('sqlerrm:'||substr(sqlerrm,1,50), 300);
              hr_utility.set_location('sqlerrm:'||substr(sqlerrm,51,100), 301);
              hr_utility.set_location('sqlerrm:'||substr(sqlerrm,101,150), 302);
       end if;

      Rollback to Update_data;

END handle_row;

function check_varchar_col_avble(old_val varchar2, new_val varchar2)
return varchar2
is
begin
if nvl(new_val, 'X') <> default_string then
 return new_val;
else
 return old_val;
end if;
end check_varchar_col_avble;

function check_number_col_avble(old_val number, new_val number)
return number
is
begin
if nvl(new_val, 1) <> default_number then
 return new_val;
else
 return old_val;
end if;
end check_number_col_avble;

END BEN_CWB_WS_IMPORT_PKG;


/
