--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CWB" as
/* $Header: benxcwbn.pkb 120.1 2006/03/22 11:00:13 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_cwb.';  -- Global package name
--
-- procedure to initialize enrt globals - May, 99
-- ----------------------------------------------------------------------------
-- |------< initialize_enrt_globals >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure initialize_group_globals IS
--
  l_proc      varchar2(72) := g_package||'initialize_group_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  --
   ben_ext_person.g_CWB_Budget_PL_ID                    :=  null ;
   ben_ext_person.g_CWB_Budget_Access                   :=  null ;
   ben_ext_person.g_CWB_Budget_Approval                 :=  null ;
   ben_ext_person.g_CWB_Budget_Approval_Date            :=  null ;
   ben_ext_person.g_CWB_Budget_Dist_Budget_Value        :=  null ;
   ben_ext_person.g_CWB_Budget_Due_Date                 :=  null ;
   ben_ext_person.g_CWB_Budget_Group_Option_Name        :=  null ;
   ben_ext_person.g_CWB_Budget_Group_Plan_Name          :=  null ;
   ben_ext_person.g_CWB_Budget_Last_Updt_By             :=  null ;
   ben_ext_person.g_CWB_Budget_Last_Updt_dt             :=  null ;
   ben_ext_person.g_CWB_Budget_Population               :=  null ;
   ben_ext_person.g_CWB_Budget_Resv_Max_Value           :=  null ;
   ben_ext_person.g_CWB_Budget_Resv_Min_Value           :=  null ;
   ben_ext_person.g_CWB_Budget_Resv_Value               :=  null ;
   ben_ext_person.g_CWB_Budget_Resv_Val_Updt_By         :=  null ;
   ben_ext_person.g_CWB_Budget_Resv_Val_Updt_dt         :=  null ;
   ben_ext_person.g_CWB_Budget_Submit_date              :=  null ;
   ben_ext_person.g_CWB_Budget_Submit_Name              :=  null ;
   ben_ext_person.g_CWB_Budget_WS_Budget_Value          :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Default_Val         :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Issue_date          :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Issue_Value         :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Max_Value           :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Min_Value           :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Val_Updt_By         :=  null ;
   ben_ext_person.g_CWB_Dist_Budget_Val_Updt_dt         :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Issue_Date            :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Issue_Value           :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Max_Value             :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Min_Value             :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Val_Updt_By           :=  null ;
   ben_ext_person.g_CWB_WS_Budget_Val_Updt_dt           :=  null ;


  --
  hr_utility.set_location('Exiting'||l_proc, 15);
--
End initialize_group_globals;



Procedure initialize_rate_globals IS
--
  l_proc      varchar2(72) := g_package||'initialize_rate_globals';
--
Begin
 --
 hr_utility.set_location('Entering'||l_proc, 5);
 ben_ext_person.g_CWB_Awrd_Elig_Flag             :=   null ;
 ben_ext_person.g_CWB_Awrd_Elig_Salary_Value     :=   null ;
 ben_ext_person.g_CWB_Awrd_Group_Option_Name     :=   null ;
 ben_ext_person.g_CWB_Awrd_Group_Plan_Name       :=   null ;
 ben_ext_person.g_CWB_Awrd_Plan_Name             :=   null ;
 ben_ext_person.g_CWB_Awrd_Option_Name           :=   null ;
 ben_ext_person.g_CWB_Awrd_Misc_Value1           :=   null ;
 ben_ext_person.g_CWB_Awrd_Misc_Value2           :=   null ;
 ben_ext_person.g_CWB_Awrd_Misc_Value3           :=   null ;
 ben_ext_person.g_CWB_Awrd_Other_Comp_Value      :=   null ;
 ben_ext_person.g_CWB_Awrd_Recorded_Value        :=   null ;
 ben_ext_person.g_CWB_Awrd_Stated_Salary_Value   :=   null ;
 ben_ext_person.g_CWB_Awrd_Total_Comp_Value      :=   null ;
 ben_ext_person.g_CWB_Awrd_WS_Maximum_Value      :=   null ;
 ben_ext_person.g_CWB_Awrd_WS_Minimum_Value      :=   null ;
 ben_ext_person.g_CWB_Awrd_WS_Value              :=   null ;
 hr_utility.set_location('Exiting'||l_proc, 15);
 --
End initialize_rate_globals;



PROCEDURE extract_person_groups
    (                        p_person_id          in number,
                             p_per_in_ler_id      in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is

 l_proc      varchar2(72) := g_package||'extract_person_groups';

 cursor c_cwg is
 select
     cwg.GROUP_PL_ID,
     cwg.GROUP_OIPL_ID,
     cwg.LF_EVT_OCRD_DT,
     cwg.ACCESS_CD,
     cwg.APPROVAL_CD,
     cwg.APPROVAL_DATE,
     cwg.DIST_BDGT_VAL,
     cwg.DUE_DT,
     pl.name pl_name ,
     --oipl.name opt_name ,
     cwg.LAST_UPDATED_BY,
     cwg.LAST_UPDATE_DATE,
     cwg.BDGT_POP_CD,
     cwg.RSRV_MX_VAL,
     cwg.RSRV_MN_VAL,
     cwg.RSRV_VAL,
     cwg.RSRV_VAL_LAST_UPD_BY,
     cwg.RSRV_VAL_LAST_UPD_DATE,
     cwg.SUBMIT_DATE,
     cwg.SUBMIT_CD,
     cwg.WS_BDGT_VAL,
     cwg.DFLT_DIST_BDGT_VAL,
     cwg.DIST_BDGT_ISS_DATE,
     cwg.DIST_BDGT_ISS_VAL,
     cwg.DIST_BDGT_MX_VAL,
     cwg.DIST_BDGT_MN_VAL,
     cwg.DIST_BDGT_VAL_LAST_UPD_BY,
     cwg.DIST_BDGT_VAL_LAST_UPD_DATE,
     cwg.WS_BDGT_ISS_DATE,
     cwg.WS_BDGT_ISS_VAL,
     cwg.WS_BDGT_MN_VAL,
     cwg.WS_BDGT_MX_VAL,
     cwg.WS_BDGT_VAL_LAST_UPD_DATE ,
     cwg.WS_BDGT_VAL_LAST_UPD_BY
 from BEN_CWB_PERSON_GROUPS cwg ,
      ben_cwb_pl_dsgn  pl
  --    ben_cwb_pl_dsgn  oipl
 where GROUP_PER_IN_LER_ID = p_per_in_ler_id
 and   pl.pl_id = cwg.GROUP_PL_ID
 and   pl.oipl_id = -1                    --- for the plan record oipl is -1
 and   cwg.lf_evt_ocrd_dt  =   pl.lf_evt_ocrd_dt
 --and   oipl.oipl_id = cwg.GROUP_OIPL_ID
 --and   oipl.pl_id = cwg.GROUP_PL_ID
 --and   cwg.lf_evt_ocrd_dt  =   oipl.lf_evt_ocrd_dt

 ;


 cursor c_name (l_pl_id  number ,
                l_oipl_id number ,
                l_date    date ) is
 select  name
   from  ben_cwb_pl_dsgn
  where  pl_id      =  l_pl_id
    and  oipl_id    =  l_oipl_id
    and  lf_evt_ocrd_dt = l_date
 ;


begin

  hr_utility.set_location('Entering'||l_proc, 5);
  --
  initialize_group_globals ;
  --
  for l_cwg  in c_cwg
  Loop
     ben_ext_person.g_CWB_Budget_PL_ID                    :=  l_cwg.GROUP_PL_ID ;
     ben_ext_person.g_CWB_Budget_Access                   :=  l_cwg.ACCESS_CD ;
     ben_ext_person.g_CWB_Budget_Approval                 :=  l_cwg.APPROVAL_CD ;
     ben_ext_person.g_CWB_Budget_Approval_Date            :=  l_cwg.APPROVAL_DATE ;
     ben_ext_person.g_CWB_Budget_Dist_Budget_Value        :=  l_cwg.DIST_BDGT_VAL ;
     ben_ext_person.g_CWB_Budget_Due_Date                 :=  l_cwg.DUE_DT ;
     --ben_ext_person.g_CWB_Budget_Group_Option_Name        :=  l_cwg.opt_name ;
     ben_ext_person.g_CWB_Budget_Group_Plan_Name          :=  l_cwg.pl_name ;
     ben_ext_person.g_CWB_Budget_Last_Updt_By             :=  l_cwg.LAST_UPDATED_BY ;
     ben_ext_person.g_CWB_Budget_Last_Updt_dt             :=  l_cwg.LAST_UPDATE_DATE ;
     ben_ext_person.g_CWB_Budget_Population               :=  l_cwg.BDGT_POP_CD ;
     ben_ext_person.g_CWB_Budget_Resv_Max_Value           :=  l_cwg.RSRV_MX_VAL ;
     ben_ext_person.g_CWB_Budget_Resv_Min_Value           :=  l_cwg.RSRV_MN_VAL ;
     ben_ext_person.g_CWB_Budget_Resv_Value               :=  l_cwg.RSRV_VAL ;
     ben_ext_person.g_CWB_Budget_Resv_Val_Updt_By         :=  l_cwg.RSRV_VAL_LAST_UPD_BY ;
     ben_ext_person.g_CWB_Budget_Resv_Val_Updt_dt         :=  l_cwg.RSRV_VAL_LAST_UPD_DATE ;
     ben_ext_person.g_CWB_Budget_Submit_date              :=  l_cwg.SUBMIT_DATE ;
     ben_ext_person.g_CWB_Budget_Submit_Name              :=  l_cwg.SUBMIT_CD ;
     ben_ext_person.g_CWB_Budget_WS_Budget_Value          :=  l_cwg.DFLT_DIST_BDGT_VAL ;
     ben_ext_person.g_CWB_Dist_Budget_Default_Val         :=  l_cwg.DFLT_DIST_BDGT_VAL ;
     ben_ext_person.g_CWB_Dist_Budget_Issue_date          :=  l_cwg.DIST_BDGT_ISS_DATE ;
     ben_ext_person.g_CWB_Dist_Budget_Issue_Value         :=  l_cwg.DIST_BDGT_ISS_VAL ;
     ben_ext_person.g_CWB_Dist_Budget_Max_Value           :=  l_cwg.DIST_BDGT_MX_VAL ;
     ben_ext_person.g_CWB_Dist_Budget_Min_Value           :=  l_cwg.DIST_BDGT_MN_VAL ;
     ben_ext_person.g_CWB_Dist_Budget_Val_Updt_By         :=  l_cwg.DIST_BDGT_VAL_LAST_UPD_BY ;
     ben_ext_person.g_CWB_Dist_Budget_Val_Updt_dt         :=  l_cwg.DIST_BDGT_VAL_LAST_UPD_DATE ;
     ben_ext_person.g_CWB_WS_Budget_Issue_Date            :=  l_cwg.WS_BDGT_ISS_DATE ;
     ben_ext_person.g_CWB_WS_Budget_Issue_Value           :=  l_cwg.WS_BDGT_ISS_VAL ;
     ben_ext_person.g_CWB_WS_Budget_Max_Value             :=  l_cwg.WS_BDGT_MX_VAL ;
     ben_ext_person.g_CWB_WS_Budget_Min_Value             :=  l_cwg.WS_BDGT_MN_VAL ;
     ben_ext_person.g_CWB_WS_Budget_Val_Updt_By           :=  l_cwg.WS_BDGT_VAL_LAST_UPD_BY ;
     ben_ext_person.g_CWB_WS_Budget_Val_Updt_dt           :=  l_cwg.WS_BDGT_VAL_LAST_UPD_DATE ;

     --- get the option namme
     if  l_cwg.group_oipl_id is not null and  l_cwg.group_oipl_id <> -1  then

         open c_name (l_cwg.group_pl_id ,
                      l_cwg.group_oipl_id ,
                      l_cwg.lf_evt_ocrd_dt) ;
         fetch c_name into ben_ext_person.g_CWB_Budget_Group_Option_Name ;
         close c_name ;

     end if ;

     ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                  p_ext_file_id       => p_ext_file_id,
                                  p_data_typ_cd       => p_data_typ_cd,
                                  p_ext_typ_cd        => p_ext_typ_cd,
                                  p_rcd_typ_cd        => 'D',
                                  p_low_lvl_cd        => 'WG',
                                  p_person_id         => p_person_id,
                                  p_business_group_id => p_business_group_id,
                                  p_effective_date    => p_effective_date
                                  );
  end Loop  ;
  hr_utility.set_location('Exiting'||l_proc, 15);


end extract_person_groups ;



PROCEDURE extract_person_rates
    (                        p_person_id          in number,
                             p_per_in_ler_id      in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is


 l_proc      varchar2(72) := g_package||'extract_person_rates';

 cursor c_cwr is
 select
       cpr.Group_pl_id,
       cpr.pl_id ,
       cpr.group_oipl_id,
       cpr.oipl_id ,
       pl1.name group_pl_name,
       pl2.name Pl_name ,
       cpr.ELIG_FLAG  ,
       cpr.ELIG_SAL_VAL  ,
       cpr.MISC1_VAL  ,
       cpr.MISC2_VAL  ,
       cpr.MISC3_VAL  ,
       cpr.OTH_COMP_VAL  ,
       cpr.REC_VAL  ,
       cpr.STAT_SAL_VAL  ,
       cpr.TOT_COMP_VAL  ,
       cpr.WS_MN_VAL  ,
       cpr.WS_MX_VAL  ,
       cpr.WS_VAL     ,
       cpr.lf_evt_ocrd_dt
 From
   ben_cwb_person_rates cpr  ,
   ben_cwb_pl_dsgn  pl1 ,
   ben_cwb_pl_dsgn  pl2
 where
   cpr.group_per_in_ler_id  =   p_per_in_ler_id
   and cpr.group_pl_id   = pl1.pl_id
   and pl1.oipl_id       = -1
   and cpr.lf_evt_ocrd_dt =  pl1.lf_evt_ocrd_dt
   and cpr.group_pl_id   = pl2.pl_id
   and pl2.oipl_id       = -1
   and cpr.lf_evt_ocrd_dt =  pl2.lf_evt_ocrd_dt
;

 cursor c_oipl (p_oipl_id number,
                p_pl_id   number,
                p_lf_evt_ocrd_dt date) is
 select oipl.name
 from   ben_cwb_pl_dsgn  oipl
 where oipl.oipl_id = p_oipl_id
   and oipl.pl_id   = p_pl_id
   and p_lf_evt_ocrd_dt  = oipl.lf_evt_ocrd_dt
 ;

begin

  hr_utility.set_location('Entering'||l_proc, 5);
  --
  initialize_rate_globals() ;
  --
  for l_cwr  in   c_cwr
  Loop

     ben_ext_person.g_CWB_Awrd_Elig_Flag                 :=   l_Cwr.ELIG_FLAG     ;
     ben_ext_person.g_CWB_Awrd_Elig_Salary_Value         :=   l_Cwr.ELIG_SAL_VAL  ;
     ben_ext_person.g_CWB_Awrd_Group_Plan_Name           :=   l_cwr.group_pl_name ;
     ben_ext_person.g_CWB_Awrd_Plan_Name                 :=   l_cwr.pl_name       ;
     ben_ext_person.g_CWB_Awrd_Misc_Value1               :=   l_Cwr.MISC1_VAL     ;
     ben_ext_person.g_CWB_Awrd_Misc_Value2               :=   l_Cwr.MISC2_VAL     ;
     ben_ext_person.g_CWB_Awrd_Misc_Value3               :=   l_Cwr.MISC3_VAL     ;
     ben_ext_person.g_CWB_Awrd_Other_Comp_Value          :=   l_Cwr.OTH_COMP_VAL  ;
     ben_ext_person.g_CWB_Awrd_Recorded_Value            :=   l_Cwr.REC_VAL       ;
     ben_ext_person.g_CWB_Awrd_Stated_Salary_Value       :=   l_Cwr.STAT_SAL_VAL  ;
     ben_ext_person.g_CWB_Awrd_Total_Comp_Value          :=   l_Cwr.TOT_COMP_VAL  ;
     ben_ext_person.g_CWB_Awrd_WS_Maximum_Value          :=   l_Cwr.WS_MN_VAL     ;
     ben_ext_person.g_CWB_Awrd_WS_Minimum_Value          :=   l_Cwr.WS_MX_VAL     ;
     ben_ext_person.g_CWB_Awrd_WS_Value                  :=   l_Cwr.WS_VAL        ;

     if nvl(l_cwr.group_oipl_id,-1)  <> -1   then
        open c_oipl(l_cwr.group_oipl_id,l_cwr.group_pl_id , l_cwr.lf_evt_ocrd_dt)  ;
        fetch c_oipl into  ben_ext_person.g_CWB_Awrd_Group_Option_Name ;
        close c_oipl ;
     end if ;

     if nvl(l_cwr.oipl_id,-1) <> -1   then
        open c_oipl(l_cwr.oipl_id,l_cwr.pl_id , l_cwr.lf_evt_ocrd_dt)  ;
        fetch c_oipl into  ben_ext_person.g_CWB_Awrd_Option_Name ;
        close c_oipl ;
     end if ;


     ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                  p_ext_file_id       => p_ext_file_id,
                                  p_data_typ_cd       => p_data_typ_cd,
                                  p_ext_typ_cd        => p_ext_typ_cd,
                                  p_rcd_typ_cd        => 'D',
                                  p_low_lvl_cd        => 'WR',
                                  p_person_id         => p_person_id,
                                  p_business_group_id => p_business_group_id,
                                  p_effective_date    => p_effective_date
                                  );

  end Loop ;
  hr_utility.set_location('Exiting'||l_proc, 15);


end extract_person_rates ;




 --
END;  -- package

/
