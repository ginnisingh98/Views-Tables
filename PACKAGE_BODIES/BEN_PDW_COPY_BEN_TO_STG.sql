--------------------------------------------------------
--  DDL for Package Body BEN_PDW_COPY_BEN_TO_STG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDW_COPY_BEN_TO_STG" AS
/* $Header: bepdwstg.pkb 120.20.12010000.1 2008/07/29 12:45:43 appldev ship $ */
g_package  varchar2(30) :='BEN_PDW_COPY_BEN_TO_STG';
PROCEDURE get_txn_details (
                            p_copy_entity_txn_id IN         NUMBER
                           ,p_business_group_id  OUT NOCOPY NUMBER
                           ,p_effective_date     OUT NOCOPY DATE
                          ) IS
Cursor csr_txn_details is
Select SRC_EFFECTIVE_DATE,CONTEXT_BUSINESS_GROUP_ID
From pqh_copy_entity_txns
Where copy_entity_txn_id=p_copy_entity_txn_id;
BEGIN
OPEN csr_txn_details;
FETCH csr_txn_details into p_effective_date, p_business_group_id ;
CLOSE  csr_txn_details;
END get_txn_details ;

    PROCEDURE copy_pl_typ_record
                               (p_pl_typ_id NUMBER,
                                p_effective_date DATE,
                                p_copy_entity_txn_id NUMBER,
                                p_business_group_id   Number,
                                p_copy_entity_result_id OUT NOCOPY NUMBER) is
   l_proc varchar2(72) := g_package||'.copy_pl_typ_record';
   cursor c_ptp IS
       select ptp.*
         from BEN_PL_TYP_F ptp
        where ptp.pl_typ_id = p_pl_typ_id
       --   and p_effective_date between effective_start_date and effective_end_date
          and NOT EXISTS (SELECT information1
                          FROM BEN_COPY_ENTITY_RESULTS cer
                         WHERE copy_entity_txn_id = p_copy_entity_txn_id
                           AND table_alias = 'PTP'
                           AND information1 = p_pl_typ_id
                           AND dml_operation = 'REUSE');

        l_ptp_rec BEN_PL_TYP_F%ROWTYPE;
        l_copy_entity_result_id NUMBER;
        l_result_type_cd VARCHAR2(30) := 'DISPLAY';
        l_mirror_src_entity_result_id NUMBER;
        l_number_of_copies NUMBER := 0;
        l_table_route_id NUMBER;
        l_information5 VARCHAR2(600) := '';
        l_object_version_number NUMBER;
--        l_ptp_rec  c_ptp%ROWTYPE;


        cursor c_table_route (c_table_alias VARCHAR) IS
         select table_route_id
           from pqh_table_route
          WHERE table_alias = c_table_alias;



    BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
      open c_table_route('PTP');
        fetch c_table_route into l_table_route_id ;
      close c_table_route ;



--   fetch c_ptp into l_ptp_rec;
   for  l_ptp_rec in c_ptp
   loop
      --IF C_PTP%FOUND THEN
        ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id           => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_mirror_src_entity_result_id,
            p_number_of_copies               => 1,
            p_table_route_id                 => l_table_route_id,
            p_table_alias                   => 'PTP',
            p_dml_operation                 => 'REUSE',
            P_INFORMATION1   =>   l_ptp_rec.PL_TYP_ID,
            P_INFORMATION2   =>   l_ptp_rec.EFFECTIVE_START_DATE,
            P_INFORMATION3   =>   l_ptp_rec.EFFECTIVE_END_DATE,
            P_INFORMATION4   =>   l_ptp_rec.BUSINESS_GROUP_ID,
            P_INFORMATION11   =>   l_ptp_rec.SHORT_CODE,
            P_INFORMATION12   =>   l_ptp_rec.SHORT_NAME,
            P_INFORMATION13   =>   l_ptp_rec.NO_MX_ENRL_NUM_DFND_FLAG,
            P_INFORMATION14   =>   l_ptp_rec.NO_MN_ENRL_NUM_DFND_FLAG,
            P_INFORMATION15   =>   l_ptp_rec.OPT_DSPLY_FMT_CD,
            P_INFORMATION16   =>   l_ptp_rec.COMP_TYP_CD,
            P_INFORMATION17   =>   l_ptp_rec.PL_TYP_STAT_CD,
            P_INFORMATION18   =>   l_ptp_rec.OPT_TYP_CD,
            P_INFORMATION110   =>   l_ptp_rec.PTP_ATTRIBUTE_CATEGORY,
            P_INFORMATION111   =>   l_ptp_rec.PTP_ATTRIBUTE1,
            P_INFORMATION112   =>   l_ptp_rec.PTP_ATTRIBUTE2,
            P_INFORMATION113   =>   l_ptp_rec.PTP_ATTRIBUTE3,
            P_INFORMATION114   =>   l_ptp_rec.PTP_ATTRIBUTE4,
            P_INFORMATION115   =>   l_ptp_rec.PTP_ATTRIBUTE5,
            P_INFORMATION116   =>   l_ptp_rec.PTP_ATTRIBUTE6,
            P_INFORMATION117   =>   l_ptp_rec.PTP_ATTRIBUTE7,
            P_INFORMATION118   =>   l_ptp_rec.PTP_ATTRIBUTE8,
            P_INFORMATION119   =>   l_ptp_rec.PTP_ATTRIBUTE9,
            P_INFORMATION120   =>   l_ptp_rec.PTP_ATTRIBUTE10,
            P_INFORMATION121   =>   l_ptp_rec.PTP_ATTRIBUTE11,
            P_INFORMATION122   =>   l_ptp_rec.PTP_ATTRIBUTE12,
            P_INFORMATION123   =>   l_ptp_rec.PTP_ATTRIBUTE13,
            P_INFORMATION124   =>   l_ptp_rec.PTP_ATTRIBUTE14,
            P_INFORMATION125   =>   l_ptp_rec.PTP_ATTRIBUTE15,
            P_INFORMATION126   =>   l_ptp_rec.PTP_ATTRIBUTE16,
            P_INFORMATION127   =>   l_ptp_rec.PTP_ATTRIBUTE17,
            P_INFORMATION128   =>   l_ptp_rec.PTP_ATTRIBUTE18,
            P_INFORMATION129   =>   l_ptp_rec.PTP_ATTRIBUTE19,
            P_INFORMATION130   =>   l_ptp_rec.PTP_ATTRIBUTE20,
            P_INFORMATION131   =>   l_ptp_rec.PTP_ATTRIBUTE21,
            P_INFORMATION132   =>   l_ptp_rec.PTP_ATTRIBUTE22,
            P_INFORMATION133   =>   l_ptp_rec.PTP_ATTRIBUTE23,
            P_INFORMATION134   =>   l_ptp_rec.PTP_ATTRIBUTE24,
            P_INFORMATION135   =>   l_ptp_rec.PTP_ATTRIBUTE25,
            P_INFORMATION136   =>   l_ptp_rec.PTP_ATTRIBUTE26,
            P_INFORMATION137   =>   l_ptp_rec.PTP_ATTRIBUTE27,
            P_INFORMATION138   =>   l_ptp_rec.PTP_ATTRIBUTE28,
            P_INFORMATION139   =>   l_ptp_rec.PTP_ATTRIBUTE29,
            P_INFORMATION140   =>   l_ptp_rec.PTP_ATTRIBUTE30,
            P_INFORMATION141   =>   l_ptp_rec.IVR_IDENT,
            P_INFORMATION170   =>   l_ptp_rec.NAME,
            P_INFORMATION260   =>   l_ptp_rec.MX_ENRL_ALWD_NUM,
            P_INFORMATION261   =>   l_ptp_rec.MN_ENRL_RQD_NUM,
            P_INFORMATION265   =>   l_ptp_rec.OBJECT_VERSION_NUMBER,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date
        );
            --
            p_copy_entity_result_id := l_copy_entity_result_id ;
  --      END IF;
end loop;
        --CLOSE C_PTP;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END;

FUNCTION Get_New_Enrt_Cd
(
  p_Enrt_Cd   Varchar2
) Return varchar2
 Is

 NEW_CHOS                         varchar2(15)     :=  'CC';
 NEW_NOTH                         varchar2(15)          :=  'NN';
 CUR_KEEP_CHOS                    varchar2(15)          :=  'CCKC';
 CUR_KEEP                         varchar2(15)     :=  'CCNC';
 CUR_CHOS                         varchar2(15)          :=  'CCON';
 CUR_LOSE                         varchar2(15)     :=  'CLON';

 CUR_KEEP_CHOS_NEW_CHOS           varchar2(15)                  :=  'CCKCNCC';
 CUR_KEEP_CHOS_NEW_NOTH           varchar2(15)          :=  'CCKCNN';
 CUR_CHOS_NEW_CHOS                varchar2(15)     :=  'CCONCC';
 CUR_CHOS_NEW_NOTH                varchar2(15)     :=  'CCONN';
 CUR_KEEP_NEW_CHOS                varchar2(15)     :=  'CKNCC';
 CUR_KEEP_NEW_NOTH                varchar2(15)     :=  'CKNN';
 CUR_LOSE_NEW_CHOS                varchar2(15)     :=  'CLNCC';
 CUR_LOSE_NEW_NOTH                varchar2(15)     :=  'CLONN';

 l_enrt_cd varchar2(15)  := null;
 Begin
    if  CUR_KEEP_CHOS_NEW_CHOS = p_enrt_cd then  l_enrt_cd :=NEW_CHOS;
        elsif  CUR_KEEP_CHOS_NEW_NOTH = p_enrt_cd then l_enrt_cd :=NEW_NOTH;
        elsif  CUR_CHOS_NEW_CHOS = p_enrt_cd then l_enrt_cd :=NEW_CHOS;
        elsif  CUR_CHOS_NEW_NOTH = p_enrt_cd then  l_enrt_cd :=NEW_NOTH ;
        elsif  CUR_KEEP_NEW_CHOS = p_enrt_cd then  l_enrt_cd :=NEW_CHOS;
        elsif  CUR_KEEP_NEW_NOTH = p_enrt_cd then  l_enrt_cd :=NEW_NOTH;
        elsif  CUR_LOSE_NEW_CHOS = p_enrt_cd then  l_enrt_cd :=NEW_CHOS;
        elsif  CUR_LOSE_NEW_NOTH = p_enrt_cd then  l_enrt_cd :=NEW_NOTH;
    end if ;

    return l_enrt_cd ;
 End Get_New_Enrt_Cd ;

 FUNCTION Get_Cur_Enrt_Cd
 (
    p_Enrt_Cd   Varchar2
 ) Return varchar2
 Is
 NEW_CHOS                         varchar2(15)     :=  'CC';
 NEW_NOTH                         varchar2(15)          :=  'NN';
 CUR_KEEP_CHOS                    varchar2(15)          :=  'CCKC';
 CUR_KEEP                         varchar2(15)     :=  'CCNC';
 CUR_CHOS                         varchar2(15)          :=  'CCON';
 CUR_LOSE                         varchar2(15)     :=  'CLON';

 CUR_KEEP_CHOS_NEW_CHOS           varchar2(15)                  :=  'CCKCNCC';
 CUR_KEEP_CHOS_NEW_NOTH           varchar2(15)          :=  'CCKCNN';
 CUR_CHOS_NEW_CHOS                varchar2(15)     :=  'CCONCC';
 CUR_CHOS_NEW_NOTH                varchar2(15)     :=  'CCONN';
 CUR_KEEP_NEW_CHOS                varchar2(15)     :=  'CKNCC';
 CUR_KEEP_NEW_NOTH                varchar2(15)     :=  'CKNN';
 CUR_LOSE_NEW_CHOS                varchar2(15)     :=  'CLNCC';
 CUR_LOSE_NEW_NOTH                varchar2(15)     :=  'CLONN';

 l_enrt_cd varchar2(15)  := null;
 Begin
    if  CUR_KEEP_CHOS_NEW_CHOS = p_enrt_cd  then l_enrt_cd :=CUR_KEEP_CHOS;
        elsif  CUR_KEEP_CHOS_NEW_NOTH = p_enrt_cd then  l_enrt_cd :=CUR_KEEP_CHOS;
        elsif  CUR_CHOS_NEW_CHOS        = p_enrt_cd  then l_enrt_cd :=CUR_CHOS;
        elsif  CUR_CHOS_NEW_NOTH        = p_enrt_cd then  l_enrt_cd :=CUR_CHOS;
        elsif  CUR_KEEP_NEW_CHOS        = p_enrt_cd then  l_enrt_cd :=CUR_KEEP;
        elsif  CUR_KEEP_NEW_NOTH        = p_enrt_cd  then l_enrt_cd :=CUR_KEEP;
        elsif  CUR_LOSE_NEW_CHOS        = p_enrt_cd then  l_enrt_cd :=CUR_LOSE;
        elsif  CUR_LOSE_NEW_NOTH        = p_enrt_cd then l_enrt_cd :=CUR_LOSE;
    end if;

    return l_enrt_cd ;
 End Get_Cur_Enrt_Cd;

procedure populate_extra_mapping_ELP(
                        p_copy_entity_txn_id in Number,
                        p_effective_date in Date,
                        p_elig_prfl_id in Number
                        )
is
l_proc varchar2(72) := g_package||'.populate_extra_mapping_ELP';
cursor c_crit ( p_parent_entity_result_id Number )
is
        select
                information5 overview_Name,
                table_alias,
                information174,
                information178,
                information185,
                information228,  -- pl_typ_opt_typ_id
                information258   -- oipl id
        from
                ben_copy_entity_results
        where
                copy_entity_txn_id = p_copy_entity_txn_id
                and parent_entity_result_id = p_parent_entity_result_id
-- Inorder to populate mappings for rows outside effective date removing date track where clause
                -- and p_effective_date between information2 and information3
                and information170 is null
for update of
        information170, information185;

l_name ben_copy_entity_results.information5%TYPE;
l_information185 ben_copy_entity_results.information170%TYPE;
l_parent_entity_result_id Number;
l_overview_name ben_copy_entity_results.information5%TYPE;
l_position Number;
l_business_group_id Number;

begin
hr_utility.set_location('Entering: '||l_proc,10);
        select
                context_business_group_id into l_business_group_id
        from
                pqh_copy_entity_txns
        where
                copy_entity_txn_id = p_copy_entity_txn_id;

        select
                copy_entity_result_id into l_parent_entity_result_id
        from
                ben_copy_entity_results
        where
                table_alias = 'ELP'
                and copy_entity_txn_id = p_copy_entity_txn_id
                and information1 = p_elig_prfl_id
                and p_effective_date between information2 and information3;
        for l_crit in c_crit(l_parent_entity_result_id)
        loop
                l_overview_name := l_crit.overview_name;
                l_position := instr(l_overview_name,'(');
                if l_position = 0
                then
                  l_name := l_overview_name;
                else
                  l_name := substr(l_overview_name,1,(l_position-2));
                end if;
                if l_crit.table_alias='ELR'
                then
                        select
                                name into l_name
                        from
                                per_absence_attendance_types
                        where
                                absence_attendance_type_id = l_crit.information174
                                and business_group_id = l_business_group_id
                                and date_effective <= p_effective_date
                                and (date_end is null or date_end >= p_effective_date);


                        begin
                        select
                                meaning into l_information185
                        from
                                per_abs_attendance_reasons
                                ,hr_leg_lookups
                         where
                                business_group_id = l_business_group_id
                                and abs_attendance_reason_id = l_crit.information178
                                and name = lookup_code
                                and lookup_type = 'ABSENCE_REASON'
                                and (start_date_active is null or start_date_active <= p_effective_date)
                                and (end_date_active is null or end_date_active >= p_effective_date);
                        Exception when no_data_found then
                                l_information185 := null;
                        end;

                        update
                                ben_copy_entity_results
                        set
                                information170 = l_name,
                                information185 = l_information185
                        where current of c_crit;

                elsif l_crit.table_alias='ECY'
                then
                        select
                                name into l_name
                        from
                                per_competences_vl
                        where
                                (business_group_id is null or business_group_id = l_business_group_id)
                                and competence_id =  l_crit.information174
                                and (date_from is null or date_from <= p_effective_date)
                                and (date_to is null or date_to >= p_effective_date);

                        begin
                        select
                                rtl.name into l_information185
                        from
                                per_rating_levels_vl rtl
                        where
                                (rtl.business_group_id is null or rtl.business_group_id=l_business_group_id)
                                and rtl.rating_level_id = l_crit.information178;
                        Exception when no_data_found then
                                l_information185 := null;
                        end;

                        update
                                ben_copy_entity_results
                        set
                                information170 = l_name,
                                information185 = l_information185
                        where current of c_crit;

                elsif l_crit.table_alias='EHC'
                then
                /* mapping not required
                        select
                                ptp.name || ' - ' || opt.name name into l_name
                        from
                                ben_pl_typ_opt_typ_f pto, ben_pl_typ_f ptp, ben_opt_f opt
                        where
                                pto.business_group_id = l_business_group_id
                                and pto.pl_typ_opt_typ_id = l_crit.information228
                                and p_effective_date between pto.effective_start_date and pto.effective_end_date
                                and pto.pl_typ_id = ptp.pl_typ_id
                                and pto.business_group_id = ptp.business_group_id
                                and p_effective_date between ptp.effective_start_date and ptp.effective_end_date
                                and pto.opt_id = opt.opt_id
                                and pto.business_group_id = opt.business_group_id
                                and p_effective_date between opt.effective_start_date and opt.effective_end_date;
                */

                        select
                                pln.name name into l_information185
                        from
                                ben_pl_typ_opt_typ_f pto, ben_oipl_f oipl, ben_pl_f pln
                        where
                                pto.business_group_id = l_business_group_id
                                and p_effective_date between pto.effective_start_date and pto.effective_end_date
                                and oipl.oipl_id = l_crit.information258
                                and p_effective_date between oipl.effective_start_date and oipl.effective_end_date
                                and pto.pl_typ_opt_typ_id = l_crit.information228
                                and pto.opt_id = oipl.opt_id
                                and pto.business_group_id = oipl.business_group_id
                                and oipl.pl_id = pln.pl_id
                                and oipl.business_group_id = pln.business_group_id
                                and p_effective_date between pln.effective_start_date and pln.effective_end_date;

                        update
                                ben_copy_entity_results
                        set
                                information185 = l_information185
                        where current of c_crit;
                -- if Criteria is any of tbe below listed, we should not copy mappings since mappings could be more than 240 characters ( UTF - 8)
                -- instead of copying mappings, we are showing the overview-name using join in Criteria Query
               elsif    not (l_crit.table_alias='EDT' or l_crit.table_alias='EDP' or l_crit.table_alias='EDI' or l_crit.table_alias='EDG'
                        or l_crit.table_alias='ETD' or l_crit.table_alias='EPP' or l_crit.table_alias='EOY'
                        or l_crit.table_alias='EEI' or l_crit.table_alias='EEP' or l_crit.table_alias='EET'
                        or l_crit.table_alias='EAI' or l_crit.table_alias='EEG' or l_crit.table_alias='ECQ' ) then

                        update
                                ben_copy_entity_results
                        set
                                information170 = l_name
                        where current of c_crit;
                end if;
    end loop;
hr_utility.set_location('Leaving: '||l_proc,20);
end populate_extra_mapping_ELP;

procedure populate_extra_mappings_ELP(
                        p_copy_entity_txn_id in Number,
                        p_effective_date in Date
                        )
is
l_proc varchar2(72) := g_package||'.populate_extra_mappings_ELP';
 cursor c_elp (
        p_copy_entity_txn_id Number,
        p_effective_date Date
        )
  is
        select
                information1 elig_prfl_id
        from
                ben_copy_entity_results
        where
                table_alias = 'ELP'
                and copy_entity_txn_id = p_copy_entity_txn_id
                and p_effective_date between information2 and information3 ;
begin
hr_utility.set_location('Entering: '||l_proc,10);
 for l_elp in c_elp(p_copy_entity_txn_id,p_effective_date)
 loop
         -- populate the extra mappings required for Criteria
        populate_extra_mapping_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => p_effective_date
        ,p_elig_prfl_id      => l_elp.elig_prfl_id);
 end loop;
hr_utility.set_location('Leaving: '||l_proc,20);
end populate_extra_mappings_ELP;


PROCEDURE populate_extra_Mapping_PLN
    (
       p_effective_date DATE,
       p_business_group_id NUMBER,
       p_copy_entity_txn_id NUMBER,
       p_copy_entity_result_id NUMBER
    ) IS


    l_opt_Typ_Cd  Varchar2(15);
    l_proc varchar2(72) := g_package||'.populate_extra_Mapping_PLN';
    BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
    -- Update Information11 with extra mapping
            Select
              ptp.Information18 into l_opt_Typ_Cd
            From
              Ben_copy_entity_results ptp,
              Ben_copy_entity_results pln
            Where
              ptp.copy_entity_txn_id = p_copy_entity_txn_id
              And pln.copy_entity_txn_id = ptp.copy_entity_txn_id
              And p_effective_date between ptp.information2 and ptp.information3
              And p_effective_date between pln.information2 and pln.information3
              And pln.table_alias='PLN'
              And ptp.table_alias='PTP'
              And ptp.information1=pln.Information248
              And pln.status <>'DELETE'
              And ptp.status <>'DELETE'
              And pln.copy_entity_result_id = p_copy_entity_result_id;

            Update
               Ben_copy_entity_results pln
            Set
               Information11 = l_opt_Typ_Cd
            Where
               copy_entity_result_id = p_copy_entity_result_id;
hr_utility.set_location('Leaving: '||l_proc,20);

   Exception When No_Data_Found Then
            Null;
END populate_extra_Mapping_PLN;


PROCEDURE populate_extra_mappings_CPY
(
   p_copy_entity_txn_id  Number
  ,p_business_group_id  Number
  ,p_effective_date     Date
)
Is

l_start_dt date ;
l_end_dt date ;
l_type     varchar2(25);
l_proc varchar2(72) := g_package||'.populate_extra_mappings_CPY';
--
-- Pick up All CPY for Pgm and Plan
cursor c_CPY(c_table_alias varchar2) is
      select
           cpy.*
      from
           BEN_COPY_ENTITY_RESULTS cpy
   where
     cpy.information4 = p_business_group_id
     And cpy.copy_entity_txn_id = p_copy_entity_txn_id
     And cpy.table_alias='CPY'
     --And cpy.information260 is not null
     and cpy.dml_operation <>'INSERT'
     and cpy.information311 is null
     for update ;
 --

Begin
hr_utility.set_location('Entering: '||l_proc,10);
        -- UPD CHANGE
        -- For Pdw Update we need to update the CPY rows with the YRP start -end date
        -- and year period type so that it gets shown in the UI

        For l_CPY_rec in c_CPY('CPY') Loop
          Begin
            --
              Select
                 Information309 ,
                 Information308 ,
                 Information12
                 into l_start_dt , l_end_dt , l_type
              From
                 Ben_copy_entity_results yrp
              Where
                 yrp.copy_entity_txn_id = p_copy_entity_txn_id
                 And yrp.table_alias='YRP'
                 And yrp.information1 = l_cpy_rec.Information240  ;

              -- Update the Plan Year Periods Extra Mappings
              Update
                  Ben_copy_entity_results cpy
                set
                  information311 = l_start_dt,
                  information310 = l_end_dt,
                  information12 = l_type
                where
                  current of c_CPY;
             --
           End ;
         End Loop ;
        -- END UPD CHANGE
hr_utility.set_location('Leaving: '||l_proc,20);
End populate_extra_mappings_CPY;

procedure populate_extra_Mappings_EPA(
                                   p_copy_entity_txn_id Number,
                                   p_effective_date Date
                                   )
 is
 l_proc varchar2(72) := g_package||'.populate_extra_Mappings_EPA';

        cursor c_epa (c_copy_entity_txn_id Number, c_effective_date Date) is
        select EPA.copy_entity_result_id,
        EPA.information1 prtn_elig_id,
        EPA.information260 PGM,
        EPA.information259 CTP,
        EPA.information256 CPP,
        EPA.information261 PLN,
        EPA.information258 COP
        from ben_copy_entity_results EPA
        where copy_entity_txn_id = c_copy_entity_txn_id
        and table_alias = 'EPA'
        and c_effective_date between information2 and information3
        for update of information20, information272;

        cursor c_cep (c_copy_entity_txn_id Number, c_effective_date Date, c_prtn_elig_id Number) is
        select CEP.copy_entity_result_id
        from ben_copy_entity_results CEP
        where copy_entity_txn_id = c_copy_entity_txn_id
        and table_alias = 'CEP'
        and c_effective_date between information2 and information3
        and information229 = c_prtn_elig_id
        for update of information20, information272;

        l_prtn_elig_id Number;
        l_compobj_id Number;
        l_compobj_type varchar2(30);

        BEGIN
	hr_utility.set_location('Entering: '||l_proc,10);
          FOR l_epa in c_epa( p_copy_entity_txn_id, p_effective_date )
           LOOP
             IF (l_epa.PGM is not  null) then
                l_compobj_id := l_epa.PGM;
                l_compobj_type := 'PGM';
             elsif (l_epa.CTP is not null) then
                l_compobj_id := l_epa.CTP;
                l_compobj_type := 'CTP';
              elsif (l_epa.CPP is not null) then

                l_compobj_id := l_epa.CPP;
                l_compobj_type := 'CPP';
              elsif (l_epa.PLN is not null) then
                l_compobj_id := l_epa.PLN;
                l_compobj_type := 'PLN';
              elsif (l_epa.COP is not null) then
                l_compobj_id := l_epa.COP;
                l_compobj_type := 'COP';
              end if;
              l_prtn_elig_id := l_epa.prtn_elig_id;

              /*dbms_output.put_line('COMPId: '||l_compobj_id);
              dbms_output.put_line('COMPTYPE: '||l_compobj_type);
              dbms_output.put_line('COMP_ID: '||l_prtn_elig_id);
              dbms_output.put_line('COMP_ID: '||l_epa.copy_entity_result_id);*/

              update
                ben_copy_entity_results
              set
                information20 = l_compobj_type,
                information272 = l_compobj_id
              Where Current Of c_epa ;
              -- copy_entity_result_id = l_epa.copy_entity_result_id;

              FOR l_cep in c_cep(p_copy_entity_txn_id, p_effective_date, l_prtn_elig_id)
                LOOP

                  update
                    ben_copy_entity_results
                  set
                    information20 = l_compobj_type,
                    information272 = l_compobj_id
                  where current of c_cep;
              END LOOP;
            END LOOP;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);
 END populate_extra_Mappings_EPA;

procedure populate_extra_mappings_VPF(
                                                p_copy_entity_txn_id Number,
                                                p_effective_date Date)
is
l_proc varchar2(72) := g_package||'.populate_extra_mappings_VPF';
cursor c_vpf
is
select
        copy_entity_result_id,
        information1 vrbl_rt_prfl_id,
        information266,
        information186,
	information2 effective_date
from
        ben_copy_entity_results
where
        table_alias = 'VPF'
        and copy_entity_txn_id = p_copy_entity_txn_id
-- Inorder to populate mappings for rows outside effective date removing date track where clause
        -- and p_effective_date between information2 and information3
        and (information186 is null or information266 is null)
for update of information266, information186;

l_elig_prfl_id Number;
l_elig_prfl_name ben_copy_entity_results.information170%type;

begin
hr_utility.set_location('Entering: '||l_proc,10);
	-- dbms_output.put_line('Before Cursor');
        FOR l_vpf in c_vpf
        LOOP
                -- dbms_output.put_line('Modifying '||l_vpf.vrbl_rt_prfl_id);
        Begin
                select
                        elp.information1 , elp.information170
                        into l_elig_prfl_id, l_elig_prfl_name
                from
                        ben_copy_entity_Results elp,
                        ben_copy_entity_results vep
                where
                        elp.table_alias = 'ELP'
                        and elp.copy_entity_txn_id = p_copy_entity_Txn_id
                        and l_vpf.effective_date between elp.information2 and elp.information3
                        and vep.table_alias = 'VEP'
                        and vep.copy_entity_txn_id = elp.copy_entity_txn_id
                        and l_vpf.effective_date between vep.information2 and vep.information3
                        and vep.information263 = elp.information1
                        and vep.information262 = l_vpf.vrbl_rt_prfl_id;


                update
                        ben_copy_entity_results
                set
                        information266 = l_elig_prfl_id,
                        information186 = l_elig_prfl_name
                where current of c_vpf;
        Exception When No_Data_Found Then
            Null;
        end;
        END LOOP;
hr_utility.set_location('Leaving: '||l_proc,20);
end populate_extra_mappings_VPF;


    PROCEDURE populate_extra_Mapping_LEN
      (
        p_copy_entity_result_id Number,
        p_effective_date        Date
      )
    Is
l_proc varchar2(72) := g_package||'.populate_extra_Mapping_LEN';
    Begin
hr_utility.set_location('Entering: '||l_proc,10);
      Update
        Ben_copy_entity_results len1
      Set
        Information170 = (
                          Select
                           ler.information170 Name
                        From
                           Ben_copy_entity_results len,
                           Ben_copy_entity_results ler
                        Where
                           len.copy_entity_result_id = p_copy_entity_result_id
                           And ler.copy_entity_txn_id = len.copy_entity_txn_id
                           And p_effective_date between len.information2 and len.information3
                           And p_effective_date between ler.information2 and ler.information3
                           and ler.table_alias='LER'
                           and len.table_alias='LEN'
                           and len.information257 = ler.information1
                          )
      Where
          len1.copy_entity_result_id = p_copy_entity_result_id ;
hr_utility.set_location('Leaving: '||l_proc,20);
    End populate_extra_Mapping_LEN;

    PROCEDURE populate_extra_Mappings_LEN
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_LEN';
      Cursor C_LEN is
        Select
           len.copy_entity_result_id
        From
           Ben_copy_entity_results len,
           Ben_copy_entity_results pet
        Where
           len.copy_entity_txn_id = p_copy_entity_txn_id
           And len.copy_entity_txn_id = pet.copy_entity_txn_id
           And p_effective_date between len.information2 and len.information3
           And p_effective_date between pet.information2 and pet.information3
           and pet.table_alias='PET'
           and len.table_alias='LEN'
           and pet.information11='L'
           and len.information232 = pet.information1
           and pet.information260= p_pgm_id;

    Begin
hr_utility.set_location('Entering: '||l_proc,10);
      For l_LEN in c_LEN Loop

          populate_extra_mapping_LEN(l_LEN.copy_entity_result_id,p_effective_date);
      End Loop ;
hr_utility.set_location('Leaving: '||l_proc,20);
    End populate_extra_Mappings_LEN;

     FUNCTION Get_Dflt_New_Enrt_Cd
 (
   p_Enrt_Cd   Varchar2
 ) Return varchar2
 Is

 l_enrt_cd varchar2(15)  := null;

 Begin
    if         'NDCN'   = p_enrt_cd then  l_enrt_cd := 'DFLT';
        elsif  'NSDCSD' = p_enrt_cd then  l_enrt_cd :='DFLT';
        elsif  'NSDCS'  = p_enrt_cd then  l_enrt_cd :='DFLT';
        elsif  'NDCSEDR'= p_enrt_cd then  l_enrt_cd :='DFLT';

        elsif  'NNCN'   = p_enrt_cd then  l_enrt_cd :='NODFLT';
        elsif  'NNCD'   = p_enrt_cd then  l_enrt_cd :='NODFLT';
        elsif  'NNCS'   = p_enrt_cd then  l_enrt_cd :='NODFLT';
        elsif  'NNCSEDR'= p_enrt_cd then  l_enrt_cd :='NODFLT';

    end if ;

    return l_enrt_cd ;


 End Get_Dflt_New_Enrt_Cd ;

 FUNCTION Get_Dflt_Old_Enrt_Cd
 (
   p_Enrt_Cd   Varchar2
 ) Return varchar2
 Is

 l_enrt_cd varchar2(15)  := null;

 Begin
    if         'NDCN'   = p_enrt_cd then  l_enrt_cd := 'DB';
        elsif  'NSDCSD' = p_enrt_cd then  l_enrt_cd :='DFLT';
        elsif  'NSDCS'  = p_enrt_cd then  l_enrt_cd :='SR';
        elsif  'NDCSEDR'= p_enrt_cd then  l_enrt_cd :='RR';

        elsif  'NNCN'   = p_enrt_cd then  l_enrt_cd :='DB';
        elsif  'NNCD'   = p_enrt_cd then  l_enrt_cd :='DFLT';
        elsif  'NNCS'   = p_enrt_cd then  l_enrt_cd :='SR';
        elsif  'NNCSEDR'= p_enrt_cd then  l_enrt_cd :='RR';

    end if ;

    return l_enrt_cd ;


 End Get_Dflt_Old_Enrt_Cd ;

    PROCEDURE populate_extra_Mappings_LPR
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_LPR';
      -- Select All LPR records which have a default enrollment logic defined
      --
      -- Information15-> dflt logic , Information13 -dflt flag
      Cursor C_LPR is
        Select
           LPR.copy_entity_result_id,
           LPR.information15,
           LPR.information13,
           LPR.information261,
           LPR.information256,
           LPR.information257 ler_id,
           LPR.information2 effective_date
        From
           Ben_copy_entity_results LPR
        Where
           LPR.copy_entity_txn_id = p_copy_entity_txn_id
           And LPR.copy_entity_txn_id = LPR.copy_entity_txn_id
           --And p_effective_date between LPR.information2 and LPR.information3
           And LPR.table_alias='LPR1'
           --And LPR.information260= p_pgm_id
           And LPR.information15 is not null
           And LPR.information103 is null -- not populated already
           And LPR.dml_operation <>'DELETE'
         For Update of LPR.Information103,LPR.information104;

cursor c_lpr1(
        p_copy_entity_txn_id Number,
        p_effective_date Date)
is
        select
                information16 ENRT_CD,
                information101 NEW_ENRT_CD,
                information102 CUR_ENRT_CD
        from
                ben_copy_entity_results
        where
                copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'LPR1'
                and information16 is not null
               -- and p_effective_date between information2 and information3
                and dml_operation <> 'DELETE'
for update of information101, information102;

l_new_enrt_cd ben_copy_entity_results.information101%type;
l_cur_enrt_cd ben_copy_entity_results.information102%type;

plipCopyEntityResultId  ben_copy_entity_results.copy_entity_result_id%type;
l_pl_id               ben_pl_f.pl_id%type ;

 l_new_dflt_enrt_cd  varchar2(15);
 l_old_dflt_enrt_cd  varchar2(15);
 l_default_object_id Number;
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     --dbms_output.put_line(' pgm id  '|| p_pgm_id|| ' txn id '|| to_char(p_copy_entity_txn_id));
     For l_LPR in c_LPR Loop
      --
      --dbms_output.put_line(' here '||l_LPR.information15 );
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_LPR.information15);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_LPR.information15);

      -- Get plipCopyEntityResultId
      --  Populate information162 with level copy result id
      Select
        copy_entity_result_id ,information261 into plipCopyEntityResultId,l_pl_id
      From
         ben_copy_entity_results
      where
         copy_entity_txn_id = p_copy_entity_txn_id
         and l_LPR.effective_date between information2 and information3
         and table_alias='CPP'
         and information1 = l_LPR.information256;
      --

      -- populate default object copy result id for COP or CPP
      -- Make a Try with the Options in this Plan
      -- Does any of them have default object flag set ?
      Begin
          --
          --
          Select
            cop.copy_entity_result_id into l_default_object_id
          From
            Ben_copy_entity_results lop,
            Ben_copy_entity_results cop
          Where
            lop.copy_entity_txn_id = p_copy_entity_txn_id
            And lop.copy_entity_txn_id = cop.copy_entity_txn_id
            And l_LPR.effective_date between lop.information2 and lop.information3
            And l_LPR.effective_date between cop.information2 and cop.information3
            And lop.table_alias     ='LOP'
            And cop.table_alias     = 'COP'
            And cop.information1    = lop.information258
            And cop.information261  = l_pl_id
            And lop.information12 ='Y'
            And lop.information257 = l_LPR.ler_id
            And lop.dml_operation <>'DELETE'
            and rownum=1;
          --DBMS_OUTPUT.PUT_LINE(' DEFAULT OBJECT ID IS 1'||l_default_object_id);
          --
        Exception When No_Data_Found Then
         --
         -- Hard Luck - No options in plan level has default object set
        --DBMS_OUTPUT.PUT_LINE(' DEFAULT OBJECT ID IS 2'||l_default_object_id ||' '||l_pl_id);
          l_default_object_id := null ;
         --
        End ;
        --DBMS_OUTPUT.PUT_LINE(' DEFAULT OBJECT ID IS '||l_default_object_id ||' EFF DT '||P_EFFECTIVE_DATE);

      If l_LPR.information13 ='Y'  and l_default_object_id is null then
       --
       -- Is this Plan the  default object for this level ?
          l_default_object_id := plipCopyEntityResultId;
       --
      End If ;

  --dbms_output.put_line(' here '|| l_new_dflt_enrt_cd);

      -- Update the New and Old Default enrollment Logic by parsing the combined dflt enrt logic
      Update
             Ben_copy_entity_results LPR1
      Set
             LPR1.information103 =l_new_dflt_enrt_cd,
             LPR1.information104 =l_old_dflt_enrt_cd,
             LPR1.information160 = l_default_object_id,
             lpr1.information161 = lpr1.copy_entity_result_id,
             lpr1.information162 = plipCopyEntityResultId
      Where current of c_LPR;
      --
      End Loop ;
    --
    for l_lpr1 in c_lpr1(p_copy_entity_txn_id, p_effective_date)
        loop
                l_new_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_new_enrt_cd(l_lpr1.ENRT_CD);
                l_cur_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_cur_enrt_cd(l_lpr1.ENRT_CD);
                update
                        ben_copy_entity_results
                set
                        information101 = l_new_enrt_cd,
                        information102 = l_cur_enrt_cd
                where current of c_lpr1;
        end loop;
hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_LPR;

 PROCEDURE populate_extra_Mappings_LOP
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_LOP';
      -- Select All LOP records which have a default enrollment logic defined
      --
      -- Information16-> dflt logic , Information18 -dflt flag
      Cursor C_LOP is
        Select
           LOP.copy_entity_result_id,
           LOP.information16,
           LOP.information258,
           LOP.information2 effective_date
        From
           Ben_copy_entity_results LOP
        Where
           LOP.copy_entity_txn_id = p_copy_entity_txn_id
           And LOP.copy_entity_txn_id = LOP.copy_entity_txn_id
           --And p_effective_date between LOP.information2 and LOP.information3
           And LOP.table_alias='LOP'
           And LOP.information16 is not null
           And LOP.information103 is  null
           And LOP.dml_operation <>'DELETE'
         For Update of LOP.Information103,LOP.information104;

         l_new_dflt_enrt_cd  varchar2(15);
         l_old_dflt_enrt_cd  varchar2(15);

         oiplCopyEntityResultId  Number ;
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_LOP in c_LOP Loop
      --
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_LOP.information16);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_LOP.information16);

      -- Get oiplCopyEntityResultId

      Select
        copy_entity_result_id into oiplCopyEntityResultId
      From
         ben_copy_entity_results
      where
         copy_entity_txn_id = p_copy_entity_txn_id
         and l_LOP.effective_date between information2 and information3
         and table_alias='COP'
         and information1 = l_LOP.information258;
      --

      -- Update the New and Old Default enrollment Logic by parsing the combined dflt enrt logic
      Update
             Ben_copy_entity_results LOP1
      Set
             LOP1.information103 =l_new_dflt_enrt_cd,
             LOP1.information104 =l_old_dflt_enrt_cd,
             -- If OIpl has the defaults flag set then make this the default object for this level
             LOP1.Information160= decode(LOP1.Information12,'Y',oiplCopyEntityResultId,null),
             lOP1.information161 = lOP1.copy_entity_result_id,
             lop1.information162 = oiplCopyEntityResultId
      Where current of c_LOP;

      --
      End Loop ;
    --
 hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_LOP;

 PROCEDURE populate_extra_Mappings_COP
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_COP';
      -- Select All COP records which have a default enrollment logic defined
      --
      Cursor C_COP is
        Select
           COP.copy_entity_result_id,
           COP.information26
        From
           Ben_copy_entity_results COP
        Where
           COP.copy_entity_txn_id = p_copy_entity_txn_id
           And COP.copy_entity_txn_id = COP.copy_entity_txn_id
           --And p_effective_date between COP.information2 and COP.information3
           And COP.table_alias='COP'
           And COP.information26 is not null
           And COP.information106 is null
           And COP.dml_operation <>'DELETE'
         For Update of COP.Information106,COP.information107;

         l_new_dflt_enrt_cd  varchar2(15);
         l_old_dflt_enrt_cd  varchar2(15);
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_COP in c_COP Loop
      --
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_COP.information26);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_COP.information26);

      -- Update the New and Old Default enrollment Logic by parsing the combined dflt enrt logic
      Update
             Ben_copy_entity_results COP1
      Set
             COP1.information106 =l_new_dflt_enrt_cd,
             COP1.information107 =l_old_dflt_enrt_cd,
             -- If OIpl has the defaults flag set then make this the default object for this level
             COP1.Information160= decode(COP1.Information18,'Y',COP1.copy_entity_result_id,null)
      Where current of c_COP;

      --
      End Loop ;
    --
 hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_COP;


    PROCEDURE copy_pln_record_pcp(p_effective_date DATE,
                                  p_business_group_id NUMBER,
                                  p_copy_entity_txn_id NUMBER) IS
    p_object_version_number NUMBER;
    l_copy_entity_result_id NUMBER;
    l_business_group_id     NUMBER;
    l_effective_date        DATE;
    l_proc varchar2(72) := g_package||'.copy_pln_record_pcp';

    CURSOR cur_new_ctp IS
    SELECT cpp.information261 pl_id
     FROM ben_copy_entity_results cpp
    WHERE cpp.copy_entity_txn_id = p_copy_entity_txn_id
      AND cpp.table_alias = TABLE_ALIAS_CPP
      AND cpp.information261 NOT IN
            (SELECT pln.information1
               FROM ben_copy_entity_results pln
              WHERE pln.copy_entity_txn_id = p_copy_entity_txn_id
                AND pln.table_alias = TABLE_ALIAS_PLN );
    BEGIN
        hr_utility.set_location('Entering: '||l_proc,10);
        FOR new_ctp IN cur_new_ctp
        LOOP
            hr_utility.set_location('copy plan: '||new_ctp.pl_id,20);
            /*
            BEN_PLAN_DESIGN_PLAN_MODULE.CREATE_PLAN_RESULT
               (p_copy_entity_result_id     => l_copy_entity_result_id
                ,p_copy_entity_txn_id       => p_copy_entity_txn_id
                ,p_pl_id                    => new_ctp.pl_id
                ,p_business_group_id        => p_business_group_id
                ,p_number_of_copies         => 1
                ,p_object_version_number    => p_object_version_number
                ,p_effective_date           => p_effective_date
                ,p_no_dup_rslt              => 'PDW_NO_DUP_RSLT'
                ,p_plan_in_program          => 'Y'
               );
            */
            copy_pln_record_pcp
            (
              p_effective_date     =>p_effective_date,
              p_business_group_id  => p_business_group_id,
              p_copy_entity_txn_id => p_copy_entity_txn_id,
              p_pl_Id              => new_ctp.pl_id
            ) ;
         END LOOP;

         hr_utility.set_location('delete duplicate rows ',30);
         /*kmullapu:
         We are using Plan Copy to fetch all child records of existing plan to staging.Now if we Attach Plan A
         and Plan B to a txn and if Child X is attached to both , it will get copied twice, leading to problems in
         other pages.Hence this delete.

         get_txn_details (
                                     p_copy_entity_txn_id
                                    ,l_business_group_id
                                    ,l_effective_date
                          );
         DELETE FROM ben_copy_entity_results
         WHERE copy_entity_txn_id = p_copy_entity_txn_id
         AND copy_entity_result_id NOT IN
                        ( SELECT MIN(copy_entity_result_id)
                            FROM ben_copy_entity_results
                           WHERE copy_entity_txn_id = p_copy_entity_txn_id
                             AND NVL(dml_operation, DML_OPER_REUSE) = DML_OPER_REUSE
                             AND ( result_type_cd='DISPLAY' or
                                   l_effective_date between information2 and information3
                        )
                           GROUP BY table_alias, information1)
         AND NVL(DML_OPERATION, DML_OPER_REUSE) = DML_OPER_REUSE and
                 TABLE_ALIAS <> 'BEN_PDW_TASK_LIST';

         */

  -- mark the future data Exists column
  mark_future_data_exists(p_copy_entity_txn_id);
 hr_utility.set_location('Leaving: '||l_proc,40);
    END copy_pln_record_pcp;


    PROCEDURE copy_pln_record_pcp(p_effective_date DATE,
                                      p_business_group_id NUMBER,
                                      p_copy_entity_txn_id NUMBER,
                                      p_pl_Id  NUMBER) IS
        p_object_version_number NUMBER;
        l_copy_entity_result_id NUMBER;
        l_business_group_id     NUMBER;
        l_effective_date        DATE;
        l_opt_typ_cd            Varchar2(15) ;
        l_proc varchar2(72) := g_package||'.copy_pln_record_pcp';

        BEGIN
            hr_utility.set_location('Entering: '||l_proc,10);

            hr_utility.set_location('copy plan: '||p_pl_id,20);

            BEN_PLAN_DESIGN_PLAN_MODULE.CREATE_PLAN_RESULT
                   (p_copy_entity_result_id     => l_copy_entity_result_id
                    ,p_copy_entity_txn_id       => p_copy_entity_txn_id
                    ,p_pl_id                    => p_pl_Id
                    ,p_business_group_id        => p_business_group_id
                    ,p_number_of_copies         => 1
                    ,p_object_version_number    => p_object_version_number
                    ,p_effective_date           => p_effective_date
                    ,p_no_dup_rslt              => 'PDW_NO_DUP_RSLT'
                    ,p_plan_in_program          => 'Y'
                   );

            populate_extra_Mapping_PLN
            (
                 p_effective_date       =>p_effective_date,
                 p_business_group_id    => p_business_group_id,
                 p_copy_entity_txn_id   => p_copy_entity_txn_id,
                 p_copy_entity_result_id=> l_copy_entity_result_id
            );

            -- Call Extyra Mappings for COP
            populate_extra_Mappings_COP
            (
                    p_copy_entity_txn_id => p_copy_entity_txn_id,
                    p_effective_date     => p_effective_date,
                    p_pgm_id             => null
            );

	  -- Call Extra Mappings For EPA
	  populate_extra_mappings_EPA
          (
             p_copy_entity_txn_id => p_copy_entity_txn_id,
             p_effective_date => p_effective_date
          );

           populate_extra_mappings_CPY
           (
             p_copy_entity_txn_id  => p_copy_entity_txn_id
            ,p_business_group_id   => p_business_group_id
            ,p_effective_date      => p_effective_date
           );

            populate_extra_Mappings_LPR
            (
                    p_copy_entity_txn_id =>p_copy_entity_txn_id,
                    p_effective_date     =>p_effective_date,
                    p_pgm_id             =>null
            );

            populate_extra_Mappings_LOP
            (
                    p_copy_entity_txn_id =>p_copy_entity_txn_id,
                    p_effective_date     =>p_effective_date,
                    p_pgm_id             =>null
            );

            populate_extra_mappings_VPF(
                p_copy_entity_txn_id => p_copy_entity_txn_id,
                p_effective_date =>p_effective_date);

           -- populate the extra mappings required for Criteria
                populate_extra_mappings_elp(
                p_copy_entity_txn_id => p_copy_entity_txn_id
                ,p_effective_date    => p_effective_date
                );

   -- mark the future data Exists column
   mark_future_data_exists(p_copy_entity_txn_id);

    hr_utility.set_location('Leaving: '||l_proc,40);
    END copy_pln_record_pcp;

    PROCEDURE remove_dpnt_rows
                        (p_copy_entity_txn_id NUMBER,
                         p_id NUMBER,
                         p_table_alias VARCHAR2) IS
    l_proc varchar2(72) := g_package||'.remove_dpnt_rows';

    BEGIN
        hr_utility.set_location('Entering: '||l_proc,10);

        IF (p_table_alias =  TABLE_ALIAS_CPP) THEN

            hr_utility.set_location('Deleting CPP rows: '||p_id,20);

            DELETE
              FROM ben_copy_entity_results
             WHERE copy_entity_txn_id = p_copy_entity_txn_id
               AND information256 = p_id
               AND table_alias in (TABLE_ALIAS_LPR);
        END IF;

        hr_utility.set_location('Leaving: '||l_proc,20);

    END remove_dpnt_rows;

   /*

   PROCEDURE copy_pln_record_all (p_pl_id NUMBER,
                                 p_effective_date DATE,
                                 p_business_group_id NUMBER,
                                 p_copy_entity_txn_id NUMBER,
                                 p_copy_entity_result_id OUT NOCOPY NUMBER,
                                 p_ptp_copy_entity_result_id OUT NOCOPY NUMBER) IS
    cursor c_pln IS
       select pln.*
         from BEN_PL_F pln
        where pln.pl_id = p_pl_id
          and p_effective_date between effective_start_date and effective_end_date
          and NOT EXISTS (SELECT information1
                          FROM BEN_COPY_ENTITY_RESULTS cer
                         WHERE copy_entity_txn_id = p_copy_entity_txn_id
                           AND table_alias = 'PLN'
                           AND information1 = p_pl_id
                           AND dml_operation = 'REUSE');

        l_pln_rec BEN_PL_F%ROWTYPE;
        l_copy_entity_result_id NUMBER;
        l_ptp_copy_entity_result_id NUMBER;
        l_result_type_cd VARCHAR2(30) := 'HIDE';
        l_mirror_src_entity_result_id NUMBER;
        l_number_of_copies NUMBER := 0;
        l_table_route_id NUMBER;
        l_object_version_number NUMBER;

        cursor c_table_route (c_table_alias VARCHAR) IS
         select table_route_id
           from pqh_table_route
          WHERE table_alias = c_table_alias;
    BEGIN


      open c_table_route('PLN');
        fetch c_table_route into l_table_route_id ;
      close c_table_route ;

      open c_pln;
      fetch c_pln into l_pln_rec;
      IF c_pln%FOUND THEN
        ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id           => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_mirror_src_entity_result_id,
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
            p_table_alias                   => 'PLN',
            p_dml_operation                 => 'REUSE',
            P_INFORMATION1   =>   l_pln_rec.PL_ID,
            P_INFORMATION2   =>   l_pln_rec.EFFECTIVE_START_DATE,
            P_INFORMATION3   =>   l_pln_rec.EFFECTIVE_END_DATE,
            P_INFORMATION4   =>   l_pln_rec.BUSINESS_GROUP_ID,
            P_INFORMATION12   =>   l_pln_rec.NIP_DFLT_FLAG,
            P_INFORMATION13   =>   l_pln_rec.FRFS_DISTR_MTHD_CD,
            P_INFORMATION14   =>   l_pln_rec.PL_YR_NOT_APPLCBL_FLAG,
            P_INFORMATION15   =>   l_pln_rec.HC_SVC_TYP_CD,
            P_INFORMATION16   =>   l_pln_rec.NIP_ACTY_REF_PERD_CD,
            P_INFORMATION17   =>   l_pln_rec.ENRT_CD,
            P_INFORMATION18   =>   l_pln_rec.PRORT_PRTL_YR_CVG_RSTRN_CD,
            P_INFORMATION19   =>   l_pln_rec.PL_STAT_CD,
            P_INFORMATION20   =>   l_pln_rec.ENRT_CVG_STRT_DT_CD,
            P_INFORMATION21   =>   l_pln_rec.ENRT_CVG_END_DT_CD,
            P_INFORMATION22   =>   l_pln_rec.NIP_ENRT_INFO_RT_FREQ_CD,
            P_INFORMATION23   =>   l_pln_rec.VRFY_FMLY_MMBR_CD,
            P_INFORMATION24   =>   l_pln_rec.ALWS_TMPRY_ID_CRD_FLAG,
            P_INFORMATION25   =>   l_pln_rec.DRVBL_DPNT_ELIG_FLAG,
            P_INFORMATION26   =>   l_pln_rec.DRVBL_FCTR_PRTN_ELIG_FLAG,
            P_INFORMATION27   =>   l_pln_rec.DPNT_NO_CTFN_RQD_FLAG,
            P_INFORMATION28   =>   l_pln_rec.MAY_ENRL_PL_N_OIPL_FLAG,
            P_INFORMATION29   =>   l_pln_rec.DPNT_CVD_BY_OTHR_APLS_FLAG,
            P_INFORMATION30   =>   l_pln_rec.DPNT_ADRS_RQD_FLAG,
            P_INFORMATION31   =>   l_pln_rec.DPNT_LEG_ID_RQD_FLAG,
            P_INFORMATION32   =>   l_pln_rec.DPNT_DOB_RQD_FLAG,
            P_INFORMATION33   =>   l_pln_rec.DRVBL_FCTR_APLS_RTS_FLAG,
            P_INFORMATION34   =>   l_pln_rec.ELIG_APLS_FLAG,
            P_INFORMATION35   =>   l_pln_rec.NO_MX_OPTS_NUM_APLS_FLAG,
            P_INFORMATION36   =>   l_pln_rec.ALWS_QDRO_FLAG,
            P_INFORMATION37   =>   l_pln_rec.ALWS_QMCSO_FLAG,
            P_INFORMATION38   =>   l_pln_rec.HGHLY_CMPD_RL_APLS_FLAG,
            P_INFORMATION39   =>   l_pln_rec.ENRT_PL_OPT_FLAG,
            P_INFORMATION40   =>   l_pln_rec.FRFS_APLY_FLAG,
            P_INFORMATION41   =>   l_pln_rec.SVGS_PL_FLAG,
            P_INFORMATION42   =>   l_pln_rec.TRK_INELIG_PER_FLAG,
            P_INFORMATION43   =>   l_pln_rec.USE_ALL_ASNTS_ELIG_FLAG,
            P_INFORMATION44   =>   l_pln_rec.USE_ALL_ASNTS_FOR_RT_FLAG,
            P_INFORMATION45   =>   l_pln_rec.VSTG_APLS_FLAG,
            P_INFORMATION46   =>   l_pln_rec.PRTN_ELIG_OVRID_ALWD_FLAG,
            P_INFORMATION47   =>   l_pln_rec.HC_PL_SUBJ_HCFA_APRVL_FLAG,
            P_INFORMATION48   =>   l_pln_rec.WVBL_FLAG,
            P_INFORMATION49   =>   l_pln_rec.INVK_FLX_CR_PL_FLAG,
            P_INFORMATION50   =>   l_pln_rec.INVK_DCLN_PRTN_PL_FLAG,
            P_INFORMATION51   =>   l_pln_rec.ALWS_REIMBMTS_FLAG,
            P_INFORMATION52   =>   l_pln_rec.ALWS_UNRSTRCTD_ENRT_FLAG,
            P_INFORMATION53   =>   l_pln_rec.BNF_ADDL_INSTN_TXT_ALWD_FLAG,
            P_INFORMATION54   =>   l_pln_rec.BNF_ADRS_RQD_FLAG,
            P_INFORMATION55   =>   l_pln_rec.BNF_CTFN_RQD_FLAG,
            P_INFORMATION56   =>   l_pln_rec.BNF_CNTNGT_BNFS_ALWD_FLAG,
            P_INFORMATION57   =>   l_pln_rec.BNF_LEGV_ID_RQD_FLAG,
            P_INFORMATION58   =>   l_pln_rec.BNF_MAY_DSGT_ORG_FLAG,
            P_INFORMATION59   =>   l_pln_rec.BNF_QDRO_RL_APLS_FLAG,
            P_INFORMATION60   =>   l_pln_rec.BNF_DSGE_MNR_TTEE_RQD_FLAG,
            P_INFORMATION61   =>   l_pln_rec.NO_MN_CVG_AMT_APLS_FLAG,
            P_INFORMATION62   =>   l_pln_rec.NO_MX_CVG_AMT_APLS_FLAG,
            P_INFORMATION63   =>   l_pln_rec.NO_MN_CVG_INCR_APLS_FLAG,
            P_INFORMATION64   =>   l_pln_rec.NO_MX_CVG_INCR_APLS_FLAG,
            P_INFORMATION65   =>   l_pln_rec.NO_MN_OPTS_NUM_APLS_FLAG,
            P_INFORMATION66   =>   l_pln_rec.BNF_DOB_RQD_FLAG,
            P_INFORMATION67   =>   l_pln_rec.PL_CD,
            P_INFORMATION68   =>   l_pln_rec.CVG_INCR_R_DECR_ONLY_CD,
            P_INFORMATION69   =>   l_pln_rec.RQD_PERD_ENRT_NENRT_UOM,
            P_INFORMATION70   =>   l_pln_rec.SUBJ_TO_IMPTD_INCM_CD,
            P_INFORMATION71   =>   l_pln_rec.SUBJ_TO_IMPTD_INCM_TYP_CD,
            P_INFORMATION72   =>   l_pln_rec.UNSSPND_ENRT_CD,
            P_INFORMATION73   =>   l_pln_rec.IMPTD_INCM_CALC_CD,
            P_INFORMATION74   =>   l_pln_rec.RT_END_DT_CD,
            P_INFORMATION75   =>   l_pln_rec.RT_STRT_DT_CD,
            P_INFORMATION76   =>   l_pln_rec.PER_CVRD_CD,
            P_INFORMATION77   =>   l_pln_rec.BNFT_OR_OPTION_RSTRCTN_CD,
            P_INFORMATION78   =>   l_pln_rec.PCP_CD,
            P_INFORMATION79   =>   l_pln_rec.MX_WTG_PERD_PRTE_UOM,
            P_INFORMATION80   =>   l_pln_rec.MX_WTG_DT_TO_USE_CD,
            P_INFORMATION81   =>   l_pln_rec.NIP_PL_UOM,
            P_INFORMATION82   =>   l_pln_rec.BNF_DFLT_BNF_CD,
            P_INFORMATION83   =>   l_pln_rec.BNF_PCT_AMT_ALWD_CD,
            P_INFORMATION84   =>   l_pln_rec.CMPR_CLMS_TO_CVG_OR_BAL_CD,
            P_INFORMATION85   =>   l_pln_rec.DPNT_CVG_END_DT_CD,
            P_INFORMATION86   =>   l_pln_rec.DPNT_CVG_STRT_DT_CD,
            P_INFORMATION87   =>   l_pln_rec.DPNT_DSGN_CD,
            P_INFORMATION88   =>   l_pln_rec.NIP_DFLT_ENRT_CD,
            P_INFORMATION89   =>   l_pln_rec.BNF_DSGN_CD,
            P_INFORMATION90   =>   l_pln_rec.PRMRY_FNDG_MTHD_CD,
            P_INFORMATION91   =>   l_pln_rec.DFLT_TO_ASN_PNDG_CTFN_CD,
            P_INFORMATION92   =>   l_pln_rec.ENRT_MTHD_CD,
            P_INFORMATION93   =>   l_pln_rec.SHORT_CODE,
            P_INFORMATION94   =>   l_pln_rec.SHORT_NAME,
            P_INFORMATION95   =>   l_pln_rec.FUNCTION_CODE,
            P_INFORMATION96   =>   l_pln_rec.FRFS_CNTR_DET_CD,
            P_INFORMATION97   =>   l_pln_rec.FRFS_DISTR_DET_CD,
            P_INFORMATION98   =>   l_pln_rec.POST_TO_GL_FLAG,
            P_INFORMATION99   =>   l_pln_rec.FRFS_VAL_DET_CD,
            P_INFORMATION100   =>   l_pln_rec.FRFS_PORTION_DET_CD,
            P_INFORMATION101   =>   l_pln_rec.BNDRY_PERD_CD,
            P_INFORMATION110   =>   l_pln_rec.PLN_ATTRIBUTE_CATEGORY,
            P_INFORMATION111   =>   l_pln_rec.PLN_ATTRIBUTE1,
            P_INFORMATION112   =>   l_pln_rec.PLN_ATTRIBUTE2,
            P_INFORMATION113   =>   l_pln_rec.PLN_ATTRIBUTE3,
            P_INFORMATION114   =>   l_pln_rec.PLN_ATTRIBUTE4,
            P_INFORMATION115   =>   l_pln_rec.PLN_ATTRIBUTE5,
            P_INFORMATION116   =>   l_pln_rec.PLN_ATTRIBUTE6,
            P_INFORMATION117   =>   l_pln_rec.PLN_ATTRIBUTE7,
            P_INFORMATION118   =>   l_pln_rec.PLN_ATTRIBUTE8,
            P_INFORMATION119   =>   l_pln_rec.PLN_ATTRIBUTE9,
            P_INFORMATION120   =>   l_pln_rec.PLN_ATTRIBUTE10,
            P_INFORMATION121   =>   l_pln_rec.PLN_ATTRIBUTE11,
            P_INFORMATION122   =>   l_pln_rec.PLN_ATTRIBUTE12,
            P_INFORMATION123   =>   l_pln_rec.PLN_ATTRIBUTE13,
            P_INFORMATION124   =>   l_pln_rec.PLN_ATTRIBUTE14,
            P_INFORMATION125   =>   l_pln_rec.PLN_ATTRIBUTE15,
            P_INFORMATION126   =>   l_pln_rec.PLN_ATTRIBUTE16,
            P_INFORMATION127   =>   l_pln_rec.PLN_ATTRIBUTE17,
            P_INFORMATION128   =>   l_pln_rec.PLN_ATTRIBUTE18,
            P_INFORMATION129   =>   l_pln_rec.PLN_ATTRIBUTE19,
            P_INFORMATION130   =>   l_pln_rec.PLN_ATTRIBUTE20,
            P_INFORMATION131   =>   l_pln_rec.PLN_ATTRIBUTE21,
            P_INFORMATION132   =>   l_pln_rec.PLN_ATTRIBUTE22,
            P_INFORMATION133   =>   l_pln_rec.PLN_ATTRIBUTE23,
            P_INFORMATION134   =>   l_pln_rec.PLN_ATTRIBUTE24,
            P_INFORMATION135   =>   l_pln_rec.PLN_ATTRIBUTE25,
            P_INFORMATION136   =>   l_pln_rec.PLN_ATTRIBUTE26,
            P_INFORMATION137   =>   l_pln_rec.PLN_ATTRIBUTE27,
            P_INFORMATION138   =>   l_pln_rec.PLN_ATTRIBUTE28,
            P_INFORMATION139   =>   l_pln_rec.PLN_ATTRIBUTE29,
            P_INFORMATION140   =>   l_pln_rec.PLN_ATTRIBUTE30,
            P_INFORMATION141   =>   l_pln_rec.MAPPING_TABLE_NAME,
            P_INFORMATION142   =>   l_pln_rec.IVR_IDENT,
            P_INFORMATION170   =>   l_pln_rec.NAME,
            P_INFORMATION185   =>   l_pln_rec.URL_REF_NAME,
            P_INFORMATION235   =>   l_pln_rec.BNFT_PRVDR_POOL_ID,
            P_INFORMATION248   =>   l_pln_rec.PL_TYP_ID,
            P_INFORMATION250   =>   l_pln_rec.ACTL_PREM_ID,
            P_INFORMATION257   =>   l_pln_rec.FRFS_DISTR_MTHD_RL,
            P_INFORMATION258   =>   l_pln_rec.DPNT_CVG_END_DT_RL,
            P_INFORMATION259   =>   l_pln_rec.DPNT_CVG_STRT_DT_RL,
            P_INFORMATION260   =>   l_pln_rec.ENRT_CVG_END_DT_RL,
            P_INFORMATION262   =>   l_pln_rec.ENRT_CVG_STRT_DT_RL,
            P_INFORMATION263   =>   l_pln_rec.CR_DSTR_BNFT_PRVDR_POOL_ID,
            P_INFORMATION264   =>   l_pln_rec.VRFY_FMLY_MMBR_RL,
            P_INFORMATION265   =>   l_pln_rec.OBJECT_VERSION_NUMBER,
            P_INFORMATION266   =>   l_pln_rec.ORDR_NUM,
            P_INFORMATION267   =>   l_pln_rec.MX_CVG_WCFN_MLT_NUM,
            P_INFORMATION268   =>   l_pln_rec.PRORT_PRTL_YR_CVG_RSTRN_RL,
            P_INFORMATION269   =>   l_pln_rec.MN_OPTS_RQD_NUM,
            P_INFORMATION270   =>   l_pln_rec.MX_OPTS_ALWD_NUM,
            P_INFORMATION271   =>   l_pln_rec.MX_CVG_MLT_INCR_NUM,
            P_INFORMATION272   =>   l_pln_rec.DFLT_TO_ASN_PNDG_CTFN_RL,
            P_INFORMATION273   =>   l_pln_rec.MX_CVG_MLT_INCR_WCF_NUM,
            P_INFORMATION274   =>   l_pln_rec.ENRT_RL,
            P_INFORMATION275   =>   l_pln_rec.MX_WTG_DT_TO_USE_RL,
            P_INFORMATION276   =>   l_pln_rec.RQD_PERD_ENRT_NENRT_RL,
            P_INFORMATION277   =>   l_pln_rec.RT_END_DT_RL,
            P_INFORMATION278   =>   l_pln_rec.RT_STRT_DT_RL,
            P_INFORMATION279   =>   l_pln_rec.POSTELCN_EDIT_RL,
            P_INFORMATION280   =>   l_pln_rec.PLN_MN_CVG_ALWD_AMT,
            P_INFORMATION281   =>   l_pln_rec.AUTO_ENRT_MTHD_RL,
            P_INFORMATION282   =>   l_pln_rec.MX_WTG_PERD_RL,
            P_INFORMATION283   =>   l_pln_rec.MN_CVG_RL,
            P_INFORMATION284   =>   l_pln_rec.MX_CVG_RL,
            P_INFORMATION285   =>   l_pln_rec.COBRA_PYMT_DUE_DY_NUM,
            P_INFORMATION286   =>   l_pln_rec.NIP_DFLT_ENRT_DET_RL,
            P_INFORMATION287   =>   l_pln_rec.COST_ALLOC_KEYFLEX_1_ID,
            P_INFORMATION288   =>   l_pln_rec.COST_ALLOC_KEYFLEX_2_ID,
            P_INFORMATION289   =>   l_pln_rec.MX_WTG_PERD_PRTE_VAL,
            P_INFORMATION290   =>   l_pln_rec.BNF_MN_DSGNTBL_PCT_VAL,
            P_INFORMATION293   =>   l_pln_rec.BNF_PCT_INCRMT_VAL,
            P_INFORMATION294   =>   l_pln_rec.MAPPING_TABLE_PK_ID,
            P_INFORMATION295   =>   l_pln_rec.MX_CVG_WCFN_AMT,
            P_INFORMATION296   =>   l_pln_rec.MN_CVG_ALWD_AMT,
            P_INFORMATION297   =>   l_pln_rec.MX_CVG_INCR_ALWD_AMT,
            P_INFORMATION298   =>   l_pln_rec.MX_CVG_INCR_WCF_ALWD_AMT,
            P_INFORMATION299   =>   l_pln_rec.MX_CVG_ALWD_AMT,
            P_INFORMATION300   =>   l_pln_rec.MN_CVG_RQD_AMT,
            P_INFORMATION301   =>   l_pln_rec.RQD_PERD_ENRT_NENRT_VAL,
            P_INFORMATION302   =>   l_pln_rec.BNF_INCRMT_AMT,
            P_INFORMATION303   =>   l_pln_rec.BNF_MN_DSGNTBL_AMT,
            P_INFORMATION304   =>   l_pln_rec.FRFS_MX_CRYFWD_VAL,
            P_INFORMATION306   =>   l_pln_rec.INCPTN_DT,
            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date
        );
            --
            p_copy_entity_result_id := l_copy_entity_result_id ;

        -- COPY PL_TYP record
        copy_pl_typ_record (p_pl_typ_id => l_pln_rec.PL_TYP_ID,
                            p_effective_date => p_effective_date,
                            p_copy_entity_txn_id => p_copy_entity_txn_id,
                            p_copy_entity_result_id => l_ptp_copy_entity_result_id);

            p_ptp_copy_entity_result_id := l_ptp_copy_entity_result_id;
        END IF;
        CLOSE c_pln;



    END;

    */

  Procedure create_ler_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  )
  is
  l_proc varchar2(72) := g_package||'.create_ler_result';
  -- Summary of changes
  -- Added Table_alias and Removed typ_cd filter on LE Trigger
  -- Setting two who_columns
  Begin
  hr_utility.set_location('Entering: '||l_proc,10);
  ben_plan_design_plan_module.create_ler_result(
                     p_validate              => p_validate
                    ,p_copy_entity_result_id => p_copy_entity_result_id
                    ,p_copy_entity_txn_id    => p_copy_entity_txn_id
                    ,p_ler_id                => p_ler_id
                    ,p_business_group_id     => p_business_group_id
                    ,p_number_of_copies      => 1
                    ,p_object_version_number => p_object_version_number
                    ,p_effective_date        => p_effective_date
                   ,p_no_dup_rslt                    =>  'PDW_NO_DUP_RSLT'
                    ) ;




 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);
  End create_ler_result ;

/* This procedure is used to copy Delpro from ben to staging and is called when Delpro is directly viewed from the shuttle */

Procedure create_dep_elpro_result
(
    p_copy_entity_txn_id   in Number,
    p_effective_date       in Date,
    p_business_group_id    in Number,
    p_dep_elig_prfl_id         in Number
)
is
l_ovn_number Number;
l_proc varchar2(72) := g_package||'.create_dep_elpro_result';
begin
hr_utility.set_location('Entering: '||l_proc,10);
--
--Call plan copy api to copy Profile and its criteria
--
ben_plan_design_elpro_module.create_dep_elig_prfl_results
  (
   p_copy_entity_txn_id             => p_copy_entity_txn_id
  ,p_mirror_src_entity_result_id    => null
  ,p_parent_entity_result_id        => null
  ,p_dpnt_cvg_eligy_prfl_id         => p_dep_elig_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_number_of_copies               => 1
  ,p_object_version_number          => l_ovn_number
  ,p_effective_date                 => p_effective_date
  ,p_no_dup_rslt                    => 'PDW_NO_DUP_RSLT'
  );

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
End create_dep_elpro_result;

/* This procedure is used to copy Elpro from ben to staging and is called when elpro is directly viewed from the shuttle */

Procedure create_elpro_result
(
    p_copy_entity_txn_id   in Number,
    p_effective_date       in Date,
    p_business_group_id    in Number,
    p_elig_prfl_id         in Number
)
is
l_ovn_number Number;
l_proc varchar2(72) := g_package||'.create_elpro_result';
begin
hr_utility.set_location('Entering: '||l_proc,10);
--
--Call plan copy api to copy Profile and its criteria
--
ben_plan_design_elpro_module.create_elig_prfl_results
  (
   p_copy_entity_txn_id             => p_copy_entity_txn_id
  ,p_mirror_src_entity_result_id    => null
  ,p_parent_entity_result_id        => null
  ,p_eligy_prfl_id                  => p_elig_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_number_of_copies               => 1
  ,p_object_version_number          => l_ovn_number
  ,p_effective_date                 => p_effective_date
  ,p_no_dup_rslt                    => 'PDW_NO_DUP_RSLT'
  );

 -- populate the extra mappings required for Criteria
     populate_extra_mapping_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => p_effective_date
        ,p_elig_prfl_id      => p_elig_prfl_id);

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
End create_elpro_result;

/*-------------------------------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++ Prtn Elpro Procedures +++++++++++++++++++++++++++++++++++++++
-------------------------------------------------------------------------------------------------------*/
/*
                         Private Methods For Eligibility Profiles

*/


FUNCTION get_prfl_name(
                      p_eligy_prfl_id IN Number
                     ,p_copy_entity_txn_id IN Number
                      )
RETURN VARCHAR2 IS
Cursor csr_txn_prfl_name (
                          c_eligy_prfl_id NUMBER
                         ,c_copy_entity_txn_id NUMBER
                          )
IS
Select information170 name
from ben_copy_entity_results
where table_alias='ELP'
and copy_entity_txn_id=c_copy_entity_txn_id
and information1=c_eligy_prfl_id;
l_rec csr_txn_prfl_name%ROWTYPE;

BEGIN

OPEN csr_txn_prfl_name(p_eligy_prfl_id,p_copy_entity_txn_id );
FETCH csr_txn_prfl_name into l_rec;
CLOSE csr_txn_prfl_name;
return l_rec.name;

END get_prfl_name;
-- For a EPA record copy all eligy prfl in to staging

PROCEDURE create_elig_prfl_results(
                           p_copy_entity_txn_id IN NUMBER
                          ,p_prtn_elig_id       IN NUMBER

                         ) IS
l_proc varchar2(72) := g_package||'.create_elig_prfl_results';

--
Cursor csr_txn_prfl(c_prtn_elig_id NUMBER) IS
Select cep.information263 ELIGY_PRFL_ID,
       cep.information12  mndtry_flag ,
       cep.copy_entity_result_id
From ben_copy_entity_results cep
Where cep.copy_entity_txn_id=p_copy_entity_txn_id
and   cep.table_alias='CEP'
and   cep.INFORMATION229=c_prtn_elig_id;

--
Cursor csr_chk_elp_exist (c_eligy_prfl_id NUMBER
                   ,c_copy_txn_id NUMBER ) IS
Select 1
From ben_copy_entity_results
Where table_alias='ELP'
and copy_entity_txn_id=c_copy_txn_id
and information1=c_eligy_prfl_id;

--
l_dummy  Varchar2(30);
l_effective_date DATE;
l_business_group_id NUMBER;
l_ovn_number NUMBER;

--
BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
--
get_txn_details (
                  p_copy_entity_txn_id
                 ,l_business_group_id
                 ,l_effective_date
                );
--
FOR l_rec in csr_txn_prfl(p_prtn_elig_id)
LOOP                                       -- for each profile attached to this prtn_elig_id
OPEN csr_chk_elp_exist(l_rec.ELIGY_PRFL_ID,p_copy_entity_txn_id);
FETCH csr_chk_elp_exist into l_dummy;
IF csr_chk_elp_exist%NOTFOUND   -- if this profile is not already existing in staging
THEN
--
--Call plan copy api to copy Profile and its criteria
--
ben_plan_design_elpro_module.create_elig_prfl_results
            (
             p_mirror_src_entity_result_id    => l_rec.copy_entity_result_id
            ,p_parent_entity_result_id        => l_rec.copy_entity_result_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_eligy_prfl_id                  => l_rec.ELIGY_PRFL_ID
            ,p_mndtry_flag                    => l_rec.MNDTRY_FLAG
            ,p_business_group_id              => l_business_group_id
            ,p_number_of_copies               => 1
            ,p_object_version_number          => l_ovn_number
            ,p_effective_date                 => l_effective_date
            ,p_no_dup_rslt              => 'PDW_NO_DUP_RSLT'
           );
END IF;
CLOSE csr_chk_elp_exist;

 -- populate the extra mappings required for Criteria
     populate_extra_mapping_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => l_effective_date
        ,p_elig_prfl_id      => l_rec.ELIGY_PRFL_ID);

END LOOP;

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END create_elig_prfl_results;
---
---Dumping all Eligibility Profiles in to Staging
---
PROCEDURE dump_elig_prfls(
                          p_copy_entity_txn_id IN NUMBER
                         ) is
--
l_effective_date DATE;
l_business_group_id NUMBER;
l_ovn_number NUMBER;
l_proc varchar2(72) := g_package||'.dump_elig_prfls';

--
CURSOR get_bg_eligy_prfl  IS
Select eligy_prfl_id
From ben_eligy_prfl_f
where business_group_id =l_business_group_id
and l_effective_date between effective_start_date and effective_end_date
and stat_cd='A' and BNFT_CAGR_PRTN_CD='BNFT'
and eligy_prfl_id not in (select information1
                          from ben_copy_entity_results
                          where copy_entity_txn_id=p_copy_entity_txn_id
                          and table_alias='ELP'
                         );

BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
--
get_txn_details (
                  p_copy_entity_txn_id
                 ,l_business_group_id
                 ,l_effective_date
                );
--
FOR l_rec in get_bg_eligy_prfl
LOOP                                       -- for each profile not it staging
--
--Call plan copy api to copy Profile and its criteria
--
ben_plan_design_elpro_module.create_elig_prfl_results
            (
             p_mirror_src_entity_result_id    => p_copy_entity_txn_id
            ,p_parent_entity_result_id        => p_copy_entity_txn_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_eligy_prfl_id                  => l_rec.ELIGY_PRFL_ID
            ,p_mndtry_flag                    => null
            ,p_business_group_id              => l_business_group_id
            ,p_number_of_copies               => 1
            ,p_object_version_number          => l_ovn_number
            ,p_effective_date                 => l_effective_date
            ,p_no_dup_rslt                    => 'PDW_NO_DUP_RSLT'
           );
END LOOP;
hr_utility.set_location('Leaving: '||l_proc,20);
END dump_elig_prfls;

---

PROCEDURE create_vapro_results
                         (
                           p_copy_entity_txn_id IN NUMBER
                          ,p_vrbl_cvg_rt_id     IN NUMBER
                          ,p_vrbl_usg_code      IN VARCHAR2
                         ) IS
l_proc varchar2(72) := g_package||'.create_vapro_results';

Cursor csr_txn_prfl IS
Select xyz.information262 VRBL_RT_PRFL_ID,
       xyz.copy_entity_result_id
From  ben_copy_entity_results xyz
Where xyz.copy_entity_txn_id=p_copy_entity_txn_id
and   xyz.table_alias=decode(p_vrbl_usg_code,'CVG','BVR1','AVR')
and   decode(table_alias,'BVR1',information238,information253)=p_vrbl_cvg_rt_id
and   dml_operation <> 'DELETE';

Cursor csr_rate_row(l_effective_Date date) is
select dml_operation,
       datetrack_mode,
       information32 uses_vrbl_rt_flag,
       future_data_exists
       from ben_copy_entity_results abr
       where abr.copy_entity_txn_id = p_copy_entity_txn_id
       and table_alias = 'ABR'
       and information1 = p_vrbl_cvg_rt_id
       and l_effective_date between information2 and information3
       and dml_operation <> 'DELETE';
--
l_rate_vpf_exits  varchar2(1):='N';
l_effective_date DATE;
l_business_group_id NUMBER;
l_ovn_number number;
l_RT_ELIG_PRFL_FLAG  varchar2(1):='N';
l_elig_prfl_id NUMBER;
l_elp_name varchar2(240);
l_rate_row csr_rate_row%rowtype;
--
BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
--
get_txn_details (
                  p_copy_entity_txn_id
                 ,l_business_group_id
                 ,l_effective_date
                );
--
FOR l_rec in csr_txn_prfl
LOOP
l_rate_vpf_exits:='Y';
ben_pd_rate_and_cvg_module.create_vapro_results
 (
  P_COPY_ENTITY_RESULT_ID        => l_rec.copy_entity_result_id
 ,P_COPY_ENTITY_TXN_ID           => p_copy_entity_txn_id
 ,P_VRBL_RT_PRFL_ID              => l_rec.VRBL_RT_PRFL_ID
 ,P_BUSINESS_GROUP_ID            => l_business_group_id
 ,P_NUMBER_OF_COPIES             => 1
 ,P_OBJECT_VERSION_NUMBER        => l_ovn_number
 ,P_EFFECTIVE_DATE               => l_effective_date
 ,P_PARENT_ENTITY_RESULT_ID      => l_rec.copy_entity_result_id
 ,P_NO_DUP_RSLT                  => 'PDW_NO_DUP_RSLT'
 );

 /* Below code copies the Elpro name attached to Vapro into information186 of
 * VPF row for those vapros which have Elpro attached, not Criteria attached */
 if(p_vrbl_usg_code='CVG')
 THEN
  Begin
   select
        information83 into l_RT_ELIG_PRFL_FLAG
   from
        ben_copy_entity_results
   where
        table_alias = 'VPF'
        and copy_entity_txn_id = p_copy_entity_txn_id
        and information1 = l_rec.VRBL_RT_PRFL_ID
        and l_effective_date between information2 and information3;

   if(l_RT_ELIG_PRFL_FLAG = 'Y')
   THEN
    select
        elp.information1,
        elp.information170 into l_elig_prfl_id, l_elp_name
    from
        ben_copy_entity_results vpf,
        ben_copy_entity_results vep,
        ben_copy_entity_results elp
    where
        vpf.copy_entity_txn_id = elp.copy_entity_txn_id
        and vpf.copy_entity_txn_id = vep.copy_entity_txn_id
        and vpf.copy_entity_txn_id = p_copy_entity_txn_id
        and vpf.table_alias = 'VPF'
        and vep.table_alias = 'VEP'
        and elp.table_alias = 'ELP'
        and vpf.information1 = l_rec.VRBL_RT_PRFL_ID
        and vpf.information1 = vep.information262
        and elp.information1 = vep.information263
        and l_effective_date between vpf.information2 and vpf.information3
        and l_effective_date between vep.information2 and vep.information3
        and l_effective_date between elp.information2 and elp.information3;

     update
        ben_copy_entity_results
     set
        INFORMATION266 = l_elig_prfl_id,
        INFORMATION186 = l_elp_name
     where
        copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'VPF'
        and information1 = l_rec.VRBL_RT_PRFL_ID
        and l_effective_date between information2 and information3;
    end if;

     -- populate the extra mappings required for Criteria
     populate_extra_mapping_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => l_effective_date
        ,p_elig_prfl_id      => l_elig_prfl_id);

    Exception When No_Data_Found Then
            Null;
    end;
 end if;

END LOOP;

if(p_vrbl_usg_code='RT') THEN

 open csr_rate_row(l_effective_date);
   fetch csr_rate_row into l_rate_row;
 close csr_rate_row;
-- if the dml_operation is reuse or update make it update
-- if there exists some future row..make the date track mode as Correction else make it update'

 if (l_rate_row.dml_operation = 'REUSE' or l_rate_row.dml_operation = 'UPDATE') and l_rate_row.uses_vrbl_rt_flag = l_rate_vpf_exits then
 -- then make no change since there is no change to rate row.
  null;
 elsif (l_rate_row.dml_operation = 'REUSE' or l_rate_row.dml_operation = 'UPDATE') and l_rate_row.uses_vrbl_rt_flag <> l_rate_vpf_exits then
 -- there can be two cases when future date may or may not exists
 -- if the future data exists we need to set datetrack mode to correction  because we are not asking the question on page.
    if l_rate_row.future_data_exists = 'Y' then
      Update ben_copy_entity_results
      set INFORMATION32=l_rate_vpf_exits,
      dml_operation = 'UPDATE',
      datetrack_mode = 'CORRECTION'
      where copy_entity_txn_id=p_copy_entity_txn_id
      and table_alias='ABR'
      and information1= p_vrbl_cvg_rt_id
      and l_effective_date between information2 and information3;
    else
      Update ben_copy_entity_results
      set INFORMATION32=l_rate_vpf_exits,
      dml_operation = 'UPDATE',
      datetrack_mode = 'UPDATE'
      where copy_entity_txn_id=p_copy_entity_txn_id
      and table_alias='ABR'
      and information1= p_vrbl_cvg_rt_id
      and l_effective_date between information2 and information3;
    end if;
else
-- for create cases we just need to set the uses variable rate flag.

 Update ben_copy_entity_results
 set INFORMATION32=l_rate_vpf_exits
 where copy_entity_txn_id=p_copy_entity_txn_id and table_alias='ABR'
 and information1= p_vrbl_cvg_rt_id
 and l_effective_date between information2 and information3;
end if;

END IF;

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END create_vapro_results;


/* This procedure copies extra columns into VPF */
procedure copy_vrbl_rt_prfl(
                                        p_copy_entity_txn_id Number,
                                        p_business_group_id Number,
                                        p_effective_date Date,
                                        p_vrbl_rt_prfl_id Number,
                                        p_parent_result_id Number)
is
l_proc varchar2(72) := g_package||'.copy_vrbl_rt_prfl';

cursor c_vpf (
        p_copy_entity_txn_id Number,
        p_effective_date Date,
        p_vrbl_rt_prfl_id Number)
 is
select
        information186,
        information266,
        copy_entity_result_id
from
        ben_copy_entity_results
where
        table_alias = 'VPF'
        and copy_entity_txn_id = p_copy_entity_txn_id
        and information1 = p_vrbl_rt_prfl_id
        and p_effective_date between information2 and information3
        and (information266 is null or information186 is null)
        and dml_operation <> 'DELETE'
        and status='VALID'
for update of information266, information186;

l_ovn_number Number;
l_elig_prfl_id Number;
l_elpro_name ben_copy_entity_results.information170%type;
copy_extra_mappings varchar2(1);

begin
hr_utility.set_location('Entering: '||l_proc,10);
copy_extra_mappings := 'N';

ben_pd_rate_and_cvg_module.create_vapro_results
 (
  P_VALIDATE                                     => 1
 ,P_COPY_ENTITY_RESULT_ID        => null
 ,P_COPY_ENTITY_TXN_ID           => p_copy_entity_txn_id
 ,P_VRBL_RT_PRFL_ID              => p_vrbl_rt_prfl_id
 ,P_BUSINESS_GROUP_ID            => p_business_group_id
 ,P_NUMBER_OF_COPIES             => 1
 ,P_OBJECT_VERSION_NUMBER        => l_ovn_number
 ,P_EFFECTIVE_DATE               => p_effective_date
 ,P_PARENT_ENTITY_RESULT_ID      => p_parent_result_id
 ,P_NO_DUP_RSLT                  => 'PDW_NO_DUP_RSLT'
 );



 For l_vpf in c_vpf(p_copy_entity_txn_id,p_effective_date,p_vrbl_rt_prfl_id)
 LOOP
   Begin
        select
                elp.information1,
        elp.information170 into l_elig_prfl_id, l_elpro_name
    from
        ben_copy_entity_results vpf,
        ben_copy_entity_results vep,
        ben_copy_entity_results elp
    where
        vpf.copy_entity_txn_id = elp.copy_entity_txn_id
        and vpf.copy_entity_txn_id = vep.copy_entity_txn_id
        and vpf.copy_entity_txn_id = p_copy_entity_txn_id
        and vpf.table_alias = 'VPF'
        and vep.table_alias = 'VEP'
        and elp.table_alias = 'ELP'
        and vpf.information1 = p_VRBL_RT_PRFL_ID
        and vpf.information1 = vep.information262
        and elp.information1 = vep.information263
        and p_effective_date between vpf.information2 and vpf.information3
        and vpf.dml_operation <> 'DELETE' and vpf.status='VALID'
        and p_effective_date between vep.information2 and vep.information3
        and vep.dml_operation <> 'DELETE' and vep.status='VALID'
        and p_effective_date between elp.information2 and elp.information3
        and elp.dml_operation <> 'DELETE' and elp.status='VALID';

    update
        ben_copy_entity_results
    set
        information266 = l_elig_prfl_id,
        information186 = l_elpro_name
    where
        current of c_vpf;
    Exception When No_Data_Found Then
            Null;
    end;
  end LOOP;

   -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
 hr_utility.set_location('Leaving: '||l_proc,20);
end copy_vrbl_rt_prfl;




---
/*                        Dependant Elig Profiles
The following procedures call plan copy apis to selectively copy delpro to staging area.
Out of the following procedures we can probably ask plan copy to provide a public function create_dep_elpro_results
which will just coy a Dpny Elig and its criteria


*/
FUNCTION get_dpnt_prfl_name(
                      p_eligy_prfl_id IN Number
                     ,p_copy_entity_txn_id IN Number
                      )
RETURN VARCHAR2 IS
Cursor csr_txn_prfl_name (
                          c_eligy_prfl_id NUMBER
                         ,c_copy_entity_txn_id NUMBER
                          )
IS
Select information170 name
from ben_copy_entity_results
where table_alias='DCE'
and copy_entity_txn_id=c_copy_entity_txn_id
and information1=c_eligy_prfl_id;
l_rec csr_txn_prfl_name%ROWTYPE;
BEGIN
OPEN csr_txn_prfl_name(p_eligy_prfl_id,p_copy_entity_txn_id );
FETCH csr_txn_prfl_name into l_rec;
CLOSE csr_txn_prfl_name;
return l_rec.name;
END get_dpnt_prfl_name;
--------------------------------------------------------------------

procedure create_dep_elpro_results
(
    p_copy_entity_txn_id             in  number
   ,p_dpnt_dsgn_object_id            in  number
   ,p_dpnt_dsgn_level_code           in  varchar2
) is
l_proc varchar2(72) := g_package||'.create_dep_elpro_results';
--
Cursor csr_txn_prfl(c_dpnt_dsgn_object_id  number ,c_dpnt_dsgn_level_code varchar2) IS
Select ade.information255 ELIGY_PRFL_ID,
       ade.information11  mndtry_flag ,
       ade.copy_entity_result_id
From ben_copy_entity_results ade
Where ade.copy_entity_txn_id=p_copy_entity_txn_id
and   ade.table_alias='ADE'
and   decode(c_dpnt_dsgn_level_code,'PL',ade.information261,'PTIP',ade.information259)=c_dpnt_dsgn_object_id;
--
Cursor csr_chk_dce_exist (c_eligy_prfl_id NUMBER
                   ,c_copy_txn_id NUMBER ) IS
Select 1
From ben_copy_entity_results
Where table_alias='DCE'
and copy_entity_txn_id=c_copy_txn_id
and information1=c_eligy_prfl_id;

--
l_dummy  Varchar2(30);
l_effective_date DATE;
l_business_group_id NUMBER;
l_ovn_number NUMBER;

--
BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
--
get_txn_details (
                  p_copy_entity_txn_id
                 ,l_business_group_id
                 ,l_effective_date
                );
--
FOR l_rec in csr_txn_prfl(p_dpnt_dsgn_object_id  ,p_dpnt_dsgn_level_code  )
LOOP                                       -- for each profile attached to this prtn_elig_id
OPEN csr_chk_dce_exist(l_rec.ELIGY_PRFL_ID,p_copy_entity_txn_id);
FETCH csr_chk_dce_exist into l_dummy;
IF csr_chk_dce_exist%NOTFOUND   -- if this profile is not already existing in staging
THEN
--
--Call plan copy api to copy Profile and its criteria
--
ben_plan_design_elpro_module.create_dep_elig_prfl_results
  (
   p_mirror_src_entity_result_id    => l_rec.copy_entity_result_id
  ,p_parent_entity_result_id        => l_rec.copy_entity_result_id
  ,p_copy_entity_txn_id             => p_copy_entity_txn_id
  ,p_dpnt_cvg_eligy_prfl_id         => l_rec.ELIGY_PRFL_ID
  ,p_business_group_id              => l_business_group_id
  ,p_number_of_copies               => 1
  ,p_object_version_number          => l_ovn_number
  ,p_effective_date                 => l_effective_date
  ,p_no_dup_rslt                    =>  'PDW_NO_DUP_RSLT'
  );

 /*
 -- populate the extra mappings required for Criteria
     populate_extra_mapping_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => l_effective_date
        ,p_elig_prfl_id      => l_rec.eligy_prfl_id);*/

END IF;
CLOSE csr_chk_dce_exist;
END LOOP;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
end create_dep_elpro_results;

 procedure create_dep_elig_crtr_results
 (
   p_copy_entity_txn_id             in  number
  ,p_parent_entity_result_id        in  number
 ) IS
 l_proc varchar2(72) := g_package||'.create_dep_elig_crtr_results';

 Cursor csr_dep_elig_criteria (c_parent_id NUMBER) IS
 Select table_alias,INFORMATION261, INFORMATION246
 From ben_copy_entity_results
 Where parent_entity_result_id=c_parent_id;

 l_ovn_number NUMBER;
 l_effective_date DATE;
 l_business_group_id  NUMBER;

 BEGIN
 hr_utility.set_location('Entering: '||l_proc,10);
  get_txn_details (
                                      p_copy_entity_txn_id
                                     ,l_business_group_id
                                     ,l_effective_date
                   );
 For l_rec in csr_dep_elig_criteria(p_parent_entity_result_id)
 LOOP
 IF l_rec.table_alias='EAC' THEN
 ben_pd_rate_and_cvg_module.create_drpar_results
     (
      p_copy_entity_result_id =>null
     ,p_copy_entity_txn_id    => p_copy_entity_txn_id
     ,p_comp_lvl_fctr_id      => null
     ,p_hrs_wkd_in_perd_fctr_id    => null
     ,p_los_fctr_id          => null
     ,p_pct_fl_tm_fctr_id    => null
     ,p_age_fctr_id              => l_rec.INFORMATION246
     ,p_cmbn_age_los_fctr_id     => null
     ,p_business_group_id         => null
     ,p_number_of_copies          => null
     ,p_object_version_number      => l_ovn_number
     ,p_effective_date          => l_effective_date
     ,p_no_dup_rslt             => 'PDW_NO_DUP_RSLT'
     );
 ELSE IF l_rec.table_alias='DPC' THEN
 copy_pln_record_pcp(l_effective_date
                    ,l_business_group_id
                    ,p_copy_entity_txn_id
                    ,l_rec.INFORMATION261);
 END IF;
 END IF;
 END LOOP;

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END create_dep_elig_crtr_results;
-------------------------------------------------------------------------------------------
FUNCTION staged_record_exists(
p_table_alias IN VARCHAR2
,p_information1 IN NUMBER
,p_copy_entity_txn_id IN NUMBER
)
RETURN boolean IS

CURSOR csr_rec_exists IS
Select 'Y'
From BEN_COPY_ENTITY_RESULTS
Where copy_entity_txn_id=p_copy_entity_txn_id
AND table_alias=p_table_alias
AND information1=p_information1
AND result_type_cd='DISPLAY';

l_rec_exists BOOLEAN :=false;
l_dummy VARCHAR2(1);
BEGIN
OPEN  csr_rec_exists;
FETCH csr_rec_exists into l_dummy;
if csr_rec_exists%FOUND THEN l_rec_exists:=true; END IF;
CLOSE  csr_rec_exists;
return l_rec_exists;
END staged_record_exists;

procedure create_elig_crtr_results
 (
   p_copy_entity_txn_id             in  number
  ,p_parent_entity_result_id        in  number
 ) IS
 l_proc varchar2(72) := g_package||'.create_elig_crtr_results';
 --
 Cursor csr_elig_epg_criteria (c_parent_id NUMBER) IS
 Select table_alias,INFORMATION261,copy_entity_result_id,information5,information11
 From ben_copy_entity_results
 Where parent_entity_result_id=c_parent_id and TABLE_ALIAS='EPG';
 --
 Cursor csr_elig_criteria (c_parent_id NUMBER) IS
 Select table_alias, INFORMATION222,INFORMATION223,INFORMATION224,INFORMATION233,INFORMATION241,INFORMATION243,INFORMATION245,
 INFORMATION246,INFORMATION254,INFORMATION272
 From ben_copy_entity_results
 Where parent_entity_result_id=c_parent_id
 and TABLE_ALIAS in ('EAP','ECL','ECP','EHW','ELS','EPF','EBN','EPZ','ESA','ECV');
--

Cursor key_id_flex_num(c_bg_id NUMBER) IS
select org_information5
from  hr_organization_information org
      where org.organization_id =c_bg_id
and   org.org_information_context = 'Business Group Information';
--
 l_ovn_number         NUMBER;
 l_effective_date     DATE;
 l_business_group_id  NUMBER;
 l_ppl_flx            VARCHAR2(240);
 l_table_alias VARCHAR2(30);
 l_information1 NUMBER;
 l_id_flex_num hr_organization_information.ORG_INFORMATION5%TYPE;

 BEGIN
 hr_utility.set_location('Entering: '||l_proc,10);
  get_txn_details (
                                      p_copy_entity_txn_id
                                     ,l_business_group_id
                                     ,l_effective_date
                   );
 /*
  *Copy concatenated People Group segment Values to Information1
  */
 For l_rec in csr_elig_epg_criteria(p_parent_entity_result_id)
 LOOP
 IF (l_rec.table_alias='EPG' and l_rec.INFORMATION5  is NULL) THEN
   IF l_id_FLEX_NUM is NULL THEN
     OPEN key_id_flex_num(l_business_group_id);
     FETCH key_id_flex_num into l_id_flex_num;
     CLOSE key_id_flex_num;
   END IF;
 hr_kflex_utility.UPD_OR_SEL_KEYFLEX_COMB
   (P_APPL_SHORT_NAME     =>'PAY',
    P_FLEX_CODE        =>'GRP',
    P_FLEX_NUM     =>to_number(trunc(l_id_flex_num)),
    p_ccid=>l_rec.Information261,
    P_CONCAT_SEGMENTS_OUT =>l_ppl_flx
   );
 IF l_rec.information11='Y' THEN
   l_ppl_flx :=l_ppl_flx|| fnd_message.get_string('BEN','BEN_93294_PDC_EXCLUDE_FLAG');
 END IF;
 UPDATE ben_copy_entity_results set INFORMATION5= l_ppl_flx where copy_entity_result_id=l_rec.copy_entity_result_id;
 END IF;
 END LOOP;
 /*
  * For 6 drvd Factors + service Area + Bnft Group + Postal Codes we have to copy them to stage if they are used
  */
 For l_rec in csr_elig_criteria(p_parent_entity_result_id)
 LOOP
 l_table_alias :=null;
 IF     l_rec.table_alias='EAP' THEN  l_information1 :=l_rec.information246;   l_table_alias :='AGF';
 elsif  l_rec.table_alias='ECP' THEN  l_information1 :=l_rec.information223;   l_table_alias :='CLA';
 elsif  l_rec.table_alias='ECL' THEN  l_information1 :=l_rec.information254;   l_table_alias :='CLF';
 elsif  l_rec.table_alias='EHW' THEN  l_information1 :=l_rec.information224;   l_table_alias :='HWF';
 elsif  l_rec.table_alias='ELS' THEN  l_information1 :=l_rec.information243;   l_table_alias :='LSF';
 elsif  l_rec.table_alias='EPF' THEN  l_information1 :=l_rec.information233;   l_table_alias :='PFF';
 elsif  l_rec.table_alias='ECV' THEN  l_information1 :=l_rec.information272;   l_table_alias :='EGL';
 END IF;
 IF l_table_alias is NOT NULL THEN
 copy_drvd_factor(p_copy_entity_txn_id  ,l_table_alias ,l_information1);
 ELSIF l_rec.table_alias='EBN' THEN
 -- modified the table alias from BRG to BNG since rows of BRG are not created/copied
 IF (NOT staged_record_exists('BNG',l_rec.information222,p_copy_entity_txn_id)) THEN
 ben_pd_rate_and_cvg_module.create_bnft_group_results
   (
    p_copy_entity_result_id          => null
   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
   ,p_benfts_grp_id                  =>l_rec.information222
   ,p_business_group_id              =>l_business_group_id
   ,p_number_of_copies               =>1
   ,p_object_version_number          =>l_ovn_number
   ,p_effective_date                 =>l_effective_date
   ) ;
 END IF;
 --
 ELSIF l_rec.table_alias='ESA' THEN
 -- modified the table alias from SAR to SVA since rows of SAR are not created/copied
 IF (NOT staged_record_exists('SVA',l_rec.information241,p_copy_entity_txn_id)) THEN
  ben_pd_rate_and_cvg_module.create_service_results
   (
    p_copy_entity_result_id          => null
   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
   ,p_svc_area_id                    =>l_rec.information241
   ,p_business_group_id              =>l_business_group_id
   ,p_number_of_copies               =>1
   ,p_object_version_number          =>l_ovn_number
   ,p_effective_date                 =>l_effective_date
   ) ;
  END IF;
 --
 ELSIF l_rec.table_alias='EPZ' THEN
 IF (NOT staged_record_exists('RZR',l_rec.information245,p_copy_entity_txn_id)) THEN
  ben_pd_rate_and_cvg_module.create_postal_results
   (
    p_copy_entity_result_id          => null
   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
   ,p_pstl_zip_rng_id                =>l_rec.information245
   ,p_business_group_id              =>l_business_group_id
   ,p_number_of_copies               =>1
   ,p_object_version_number          =>l_ovn_number
   ,p_effective_date                 =>l_effective_date
  ) ;
 END IF;
 END IF;
 END LOOP;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);
END create_elig_crtr_results;

PROCEDURE copy_bnft_bal(
p_copy_entity_txn_id IN NUMBER,
p_information1 IN NUMBER
) IS
l_ovn_number         NUMBER;
l_effective_date     DATE;
l_business_group_id  NUMBER;
l_proc varchar2(72) := g_package||'.copy_bnft_bal';
BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
IF NOT staged_record_exists('BNB',p_information1,p_copy_entity_txn_id) THEN
get_txn_details (p_copy_entity_txn_id ,l_business_group_id,l_effective_date);
 ben_pd_rate_and_cvg_module.create_bnft_bal_results
  (
   p_copy_entity_result_id          => null
  ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
  ,p_bnfts_bal_id                   =>p_information1
  ,p_business_group_id              =>l_business_group_id
  ,p_number_of_copies               =>1
  ,p_object_version_number          =>l_ovn_number
  ,p_effective_date                 =>l_effective_date
  ) ;
END IF;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END copy_bnft_bal;

/* This function returns the relevant Criteria Name of the COBRA criteria
The criteria Name could be Program or Program - PlanType Name
The complexity is to always show the Pgm or PlanType name from Staging first
and only if it is not present in Staging, show it from BEN */
FUNCTION get_COBRA_criteria_name(
    p_copy_entity_txn_id Number,
    p_pgm_id Number,
    p_ctp_id Number
   )
RETURN VARCHAR2 is

l_effective_date Date;
l_business_group_id Number;
l_overview_name ben_copy_entity_results.information5%type;

begin
    get_txn_details(p_copy_entity_txn_id,l_business_group_id,l_effective_date);
    l_overview_name := null;
    if(p_pgm_id is not null) then -- only Program is selected
       begin
            select -- if PGM is copied to staging, return the Pgm Name in Staging
                information170 into l_overview_name
            from
                ben_copy_entity_results
            where
                copy_entity_txn_id = p_copy_entity_txn_id
		and information1 = p_pgm_id
                and table_alias = 'PGM'
                and l_effective_date between information2 and information3;
        Exception when No_Data_Found Then
            begin
                select
                    name into l_overview_name
                from
            	   ben_pgm_f pgm
                where
            	   pgm.business_group_id = l_business_group_id
		   and pgm.pgm_id = p_pgm_id
            	   and l_effective_date between pgm.effective_start_date and pgm.effective_end_date;
            Exception when No_Data_Found Then
                -- We should ideally never reach here
                RAISE;
            end;
        end;
    elsif (p_ctp_id is not null) then -- PlanType in Pgm is chosen
    begin
        select -- if Pgm and Plan Type is copied to staging, then return their names in staging
            pgm.information170 || ' - ' || ptp.information170 into l_overview_name
        from
            ben_copy_entity_results pgm,
            ben_copy_entity_results ctp,
            ben_copy_entity_results ptp
        where
            ctp.copy_entity_txn_id = p_copy_entity_txn_id
            and ctp.table_alias = 'CTP'
            and ptp.copy_entity_txn_id = ctp.copy_entity_txn_id
            and ptp.table_alias = 'PTP'
            and pgm.copy_entity_txn_id = ctp.copy_entity_txn_id
            and pgm.table_alias = 'PGM'
            and ctp.information1 = p_ctp_id
    	    and l_effective_date between ctp.information2 and ctp.information3
    	    and ptp.information1 = ctp.information248
	    and l_effective_date between ptp.information2 and ptp.information3
	    and pgm.information1 = ctp.information260
            and l_effective_date between pgm.information2 and pgm.information3;
        Exception when No_Data_Found Then
            begin
                select
                    pgm.name || ' - ' || ptp.name into l_overview_name
                from
                    ben_pgm_f pgm,
                	ben_ptip_f ctp,
                	ben_pl_typ_f ptp
                where
                    ctp.business_group_id = l_business_group_id
                    and ctp.ptip_id = p_ctp_id
                    and ctp.pgm_id = pgm.pgm_id
	            and ptp.pl_typ_id = ctp.pl_typ_id
	            and ctp.business_group_id = pgm.business_group_id
	            and ptp.business_group_id = pgm.business_group_id
	            and l_effective_date between pgm.effective_start_date and pgm.effective_end_date
                    and l_effective_date between ptp.effective_start_date and ptp.effective_end_date
                    and l_effective_date between ctp.effective_start_date and ctp.effective_end_date;
            Exception when No_Data_Found Then
                -- We should ideally never reach here
                 RAISE;
            end;
        end;
    end if;
    return l_overview_name;
end get_COBRA_criteria_name;

------------------------------------------------------------------------------------------------------


/* This Procedure will be called from Plan Design wizard pre-processor
   to
   1.  Create Plan Year Periods from the existing Year periods attached to PGM
       This procedure will add all year periods to all the Plans in
       the Transaction

   2.  Sync the Sequence Numbers of Program Year Periods so that the sewuence numbers
       are ordered in PUI
*/
--
Procedure create_Plan_Yr_Periods
(
   p_copy_entity_txn_id Number
  ,p_effective_Date    Date
  ,p_business_group_id Number
)
is
l_proc varchar2(72) := g_package||'.create_Plan_Yr_Periods';
--
 Cursor C_PLN(p_copy_entity_txn_id number ,p_effective_date Date) is
    Select cpe.* from
      Ben_copy_entity_results  cpe
      Where
        cpe.copy_Entity_txn_Id = p_copy_entity_txn_id
        And cpe.Table_Alias='PLN'
        --And cpe.Dml_operation='INSERT'
        And cpe.Dml_operation <> 'DELETE'
        And p_effective_date between cpe.Information2 And cpe.Information3 ;

 Cursor C_CPY(p_copy_entity_txn_id number) is
   Select cpe.* from
     Ben_copy_entity_results  cpe
     Where
       cpe.copy_Entity_txn_Id = p_copy_entity_txn_id
       And cpe.Table_Alias='CPY'
       --And cpe.Dml_operation='INSERT'
       And cpe.Dml_operation <> 'DELETE'
       And cpe.Information260 is not null
       Order by cpe.Information311,cpe.Information310

     For Update of cpe.Information262  ;

 l_copy_entity_result_id Number ;
 l_pkId Number ;
 l_object_version_number Number ;
 l_RESULT_TYPE_CD   Varchar2(15) ;
 l_Sequence_Number  Number(15) ;
 l_pgm_Yr_Perd_Sequence_Number Number(15) :=10 ;
--
Begin
--
hr_utility.set_location('Entering: '||l_proc,10);
   fnd_msg_pub.initialize ;
   l_RESULT_TYPE_CD :='DISPLAY' ;

   /*
   -- Delete any existing CPY rows for PLN
   delete from ben_copy_entity_results
    where
      copy_entity_txn_id =p_copy_entity_txn_id
      And table_Alias='CPY'
      And information261 is not null ;
   -- end delete

   -- Sync the Program Year Period Sequence Number
   --
   For l_CPY in c_CPY(p_copy_entity_txn_id) Loop
          --
           -- Sync the Sequence Numbers of PGM Yr Period so that they are in order
  -- --dbms_output.put_line(' pgm sequence  '||l_pgm_Yr_Perd_Sequence_Number || ' for '||l_CPY.information311 ||'-'||l_CPY.information310);

           Update Ben_Copy_Entity_Results

             Set Information262 = l_pgm_Yr_Perd_Sequence_Number

           Where Current Of c_CPY ;

           l_pgm_Yr_Perd_Sequence_Number  := l_pgm_Yr_Perd_Sequence_Number  + 10 ;

   End Loop ;
    -- End Sync the Program Year Period Sequence Number
   */
   --



   -- Construct the Plan year Periods

   -- Open and Create the CPY Rows for PLN
   For l_PLN in c_PLN(p_copy_entity_txn_id,p_effective_date) Loop
   --
       -- Get the Next Sequence Number from Ben
       -- It will start from 10 if there are no CPY records already existing

         Select
            max(ordr_num)+10 into l_Sequence_Number

         From

           Ben_Popl_Yr_Perd cpy

         Where
           cpy.pl_id = l_PLN.Information1
           And cpy.business_group_id = p_business_group_id;


       if l_sequence_number is null then
         l_Sequence_Number := 10 ;
       End If ;

       For l_CPY in c_CPY(p_copy_entity_txn_id) Loop
       --
           l_copy_entity_result_id := null;
           l_object_version_number := null;


           Begin
           --
            -- Find out if this YRP is already attached to PLN via any CPY
            Select
               8 into l_pkId

              From

                Ben_Popl_Yr_Perd cpy,
                Ben_Yr_Perd      yrp
              Where
                cpy.pl_id = l_PLN.Information1
                And cpy.business_group_id = p_business_group_id
                And cpy.business_group_id = yrp.business_group_id
                And cpy.yr_perd_id = yrp.yr_perd_id
                And yrp.start_date = l_CPY.information311
                And yrp.end_date   = l_CPY.information310;

            /*Select
               8 into l_pkId

              From

                Ben_copy_entity_results cpy

              Where
                cpy.copy_entity_txn_id = p_copy_entity_txn_id
                And p_effective_date between cpy.information2 and cpy.information3
                And cpy.information261 = l_PLN.Information1
                And cpy.information311 =l_CPY.information311
                And cpy.information310 = l_CPY.information310
                And cpy.dml_operation <>'DELETE' ;*/


           Exception When No_Data_Found then
              --
               -- If there are No Records for this Year Period in Ben then create a CPY Row for
               -- a YRP

               Select BEN_POPL_YR_PERD_S.nextval into l_pkId
                 From dual ;
               -- dbms_output.put_line(' yrp id '||to_char(l_CPY.information1));
               ben_copy_entity_results_api.create_copy_entity_results
                  (
                    p_copy_entity_result_id          => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_number_of_copies               => 1,
                    p_dml_operation    =>'INSERT' ,
                    p_table_Alias      => 'CPY' ,
                    p_information1     => l_pkId,
                    p_information4     => l_CPY.information4,
                    p_information5     => l_CPY.information311 ||'-'||l_CPY.information310, -- 9999 put name for h-grid
                    --p_information265   => 0,
                    --
                    p_information261      => l_PLN.information1, -- Plan Id
                    p_Information262      => l_Sequence_Number ,
                    p_information240      => l_CPY.information240, -- Year Period Id

                    --
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date

                   );
               -- dbms_output.put_line(' RESULT ID '||L_Sequence_Number);

                l_Sequence_Number := l_Sequence_Number + 10 ;

               --
            --
           End ;

       End Loop ;
   --
   End Loop ;

 -- mark the future data Exists column
  mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);

--
End create_Plan_Yr_Periods ;

/*
FUNCTION decode_Person_Change(
   Name   varchar2
   ) Return varchar2

Is
 l_Code   varchar2(15);

Begin

  if(Name ='Any Value' ) then
          return 'OABANY';
      elsIf ( Name = 'No Value') then
          return 'NULL';
      elsIf (Name = 'Ex-employee') then
          return 'EMP';
      elsIf (Name = 'Employee') then
          return 'EX_EMP';
      elsIf (Name ='Fulltime-Regular') then
          return 'FR';

      elsIf (Name ='Parttime-Regular') then
          return 'PR';
      elsIf (Name ='Marriage')       then
          return 'M' ;
      elsIf (Name ='Birth of a Child') then
          return 'BC';
      elsIf (Name ='Applicant')       then
          return 'APL' ;


  End If;

  return null ;
End ;


*/


Function chkName
(
   p_effective_date     Date
  ,p_Name               Varchar2
  ,p_business_group_id  Number
)
Return Varchar2
Is
l_name  Varchar2(500);
l_Temp Varchar2(500);

Begin
        l_name := p_name ;
        l_name := hr_general.decode_lookup('BEN_PDW_SEEDED_LE_TRIGGERS',l_name);

        -- Chk if this Trigger is already existing
        Begin

        Select psl.Name  into l_temp
        From
         BEN_PER_INFO_CHG_CS_LER_F  psl
        Where
         psl.business_group_id = p_business_group_id
         And p_effective_date between psl.effective_start_date and psl.effective_end_date
         And psl.Name = l_name ;

        Exception
         When  No_Data_Found  then
         -- Name does not exist
         l_temp :=Null ;

         When  Others  then
         -- Multiple Rows with Same Name
         l_Temp := 'EX';

        End ;

        -- If a Trigger exists with this name then Create a Trigger
        -- with Name with _1 appended
        If (l_temp is Not Null) then

        l_name := l_name || hr_general.decode_lookup('BEN_PDW_DPNT_BNF_HGRID_LABEL','DUP') ;

        End If ;
        return l_name ;
End ;


/*
   This procedure is used to decode the person id for PER_PERSON_TYPES from lookup code
   NB: There can be multiple user names for a given system name. For decoding we will have
   to limit the rows to 1. We can use the default one as specified by DEFAULT_FLAG ='Y'
*/
--
Function decode_Value
(
  p_business_group_id Number,
  p_val Varchar2 ,
  p_ler_trigger_code  Varchar2
)
return varchar2

Is
l_Val    Varchar2(100);

Begin
--
l_Val := p_val ;

If p_ler_trigger_code in ('NEWHIRENE','NEWHIREAE','REHIRE') then
--
 Begin
  --
    Select

      to_char(PERSON_TYPE_ID) into l_val
    From
      Per_Person_Types  ppt
    Where
      ppt.System_Person_Type =p_val
      And ppt.ACTIVE_FLAG='Y'
      And ppt.Business_Group_Id = p_business_group_id
      And ppt.default_flag='Y' ;
 Exception When No_Data_Found Then
     Null ;
 End ;
--
End If ;

return l_Val ;

--
End decode_Value;
--
Procedure create_Life_Event_Triggers
(

   p_copy_entity_txn_id  Number
  ,p_business_group_id   Number
  ,p_effective_date      Date
  ,p_effective_end_date  Date
)
is
l_proc varchar2(72) := g_package||'.create_Life_Event_Triggers';

--
-- All psl in Ben for duplicate Check
Cursor c_PSL(p_business_group_id Number ,
             p_effective_date Date,
             p_source_table  varchar2,
             p_source_column varchar2,
             p_old_Val      varchar2,
             P_new_val      varchar2 ) is

 Select
   psl.*

 from
    BEN_PER_INFO_CHG_CS_LER_F  psl
 Where
    psl.business_group_id = p_business_group_id
    And p_effective_date between psl.effective_start_date and psl.effective_end_date
    And
    (
     Upper(psl.SOURCE_TABLE)     = upper(p_source_table)
     And upper(psl.Source_column)=upper(p_source_column)
     And psl.Old_Val              = p_old_val
     And NVL(psl.New_Val,-1)     = p_new_Val
     ) ;

 -- All PSL in Txn which have a LPL attached to it
 Cursor c_CPE is
  Select cpe.*
   from
  Ben_copy_entity_Results cpe,
  Ben_copy_entity_Results lpl
  Where
    cpe.copy_entity_txn_id=0
    And cpe.Table_Alias ='PSL'
    And lpl.copy_entity_txn_id=p_copy_entity_txn_id
    And lpl.Table_Alias='LPL'
    And p_effective_date between lpl.Information2 and lpl.Information3
    And lpl.Information258 = cpe.copy_entity_result_id
    And lpl.dml_operation='INSERT' ;



l_per_info_chg_cs_ler_id  Number ;
l_source_table            varchar2(200);
l_source_column           varchar2(200);
l_Object_Version_Number   Number ;
l_count                   Number ;
l_name                    Varchar2(500);
l_copy_entity_result_id   Number ;
l_pkId                    Number;
l_temp                    Varchar2(500);
l_effective_Start_Date    Date ;
l_effective_End_Date      Date ;
l_result_type_cd          Varchar2(15)  ;
--


Begin
hr_utility.set_location('Entering: '||l_proc,10);
   l_result_type_cd := 'DISPLAY';
   -- check if triggers are existing

   For l_CPE in c_CPE Loop
   --
       l_name := l_CPE.information15 ;
       l_per_info_chg_cs_ler_id := null;
       For l_PSL_rec in c_PSL
          (p_business_group_id,p_effective_date,l_CPE.INFORMATION11,l_CPE.INFORMATION12,
             l_CPE.INFORMATION13,l_CPE.INFORMATION14)  Loop

          -- When the Trigger is existing get the PSL Id
          l_per_info_chg_cs_ler_id := l_PSL_rec.per_info_chg_cs_ler_id ;

          -- dbms_output.put_line('existing is '||l_psl_rec.name);
          /** Manual Change - Replace this with Plan Copy
              Copy PSL Row to Staging
          */

          ben_copy_entity_results_api.create_copy_entity_results(
                           p_copy_entity_result_id           => l_copy_entity_result_id,
                           p_copy_entity_txn_id             => p_copy_entity_txn_id,
                           p_result_type_cd                 => 'DISPLAY',
                           p_number_of_copies               => 1,
                           p_table_alias                    => 'PSL',
                           p_Dml_Operation                  =>'REUSE',
                           p_information1     => l_psl_rec.per_info_chg_cs_ler_id,
                           p_information2     => l_psl_rec.EFFECTIVE_START_DATE,
                           p_information3     => l_psl_rec.EFFECTIVE_END_DATE,
                           p_information4     => l_psl_rec.business_group_id,
                           p_information5     => null , -- 9999 put name for h-grid
                           p_information218     => l_psl_rec.name,
                           p_information186     => l_psl_rec.new_val,
                           p_information185     => l_psl_rec.old_val,
                           p_information260     => l_psl_rec.per_info_chg_cs_ler_rl,
                           p_information111     => l_psl_rec.psl_attribute1,
                           p_information120     => l_psl_rec.psl_attribute10,
                           p_information121     => l_psl_rec.psl_attribute11,
                           p_information122     => l_psl_rec.psl_attribute12,
                           p_information123     => l_psl_rec.psl_attribute13,
                           p_information124     => l_psl_rec.psl_attribute14,
                           p_information125     => l_psl_rec.psl_attribute15,
                           p_information126     => l_psl_rec.psl_attribute16,
                           p_information127     => l_psl_rec.psl_attribute17,
                           p_information128     => l_psl_rec.psl_attribute18,
                           p_information129     => l_psl_rec.psl_attribute19,
                           p_information112     => l_psl_rec.psl_attribute2,
                           p_information130     => l_psl_rec.psl_attribute20,
                           p_information131     => l_psl_rec.psl_attribute21,
                           p_information132     => l_psl_rec.psl_attribute22,
                           p_information133     => l_psl_rec.psl_attribute23,
                           p_information134     => l_psl_rec.psl_attribute24,
                           p_information135     => l_psl_rec.psl_attribute25,
                           p_information136     => l_psl_rec.psl_attribute26,
                           p_information137     => l_psl_rec.psl_attribute27,
                           p_information138     => l_psl_rec.psl_attribute28,
                           p_information139     => l_psl_rec.psl_attribute29,
                           p_information113     => l_psl_rec.psl_attribute3,
                           p_information140     => l_psl_rec.psl_attribute30,
                           p_information114     => l_psl_rec.psl_attribute4,
                           p_information115     => l_psl_rec.psl_attribute5,
                           p_information116     => l_psl_rec.psl_attribute6,
                           p_information117     => l_psl_rec.psl_attribute7,
                           p_information118     => l_psl_rec.psl_attribute8,
                           p_information119     => l_psl_rec.psl_attribute9,
                           p_information110     => l_psl_rec.psl_attribute_category,
                           p_information141     => l_psl_rec.source_column,
                           p_information142     => l_psl_rec.source_table,
                           p_information219     => l_psl_rec.whatif_lbl_txt,
                           p_information187     => null,
                           p_information188     => null,
                           p_information265     => l_psl_rec.object_version_number,
                           p_object_version_number          => l_object_version_number,
                           p_effective_date                 => p_effective_date       );

                /** Manual Change - Replace this with Plan Copy
                    Copy PSL Row to Staging
                */
                --

          --
       End Loop;

        --dbms_output.put_line('ID IS  '||l_per_info_chg_cs_ler_id);

       If l_per_info_chg_cs_ler_id is null Then
           --
           -- Create This Trigger in Staging Table as it does not exist
           --
           --
           -- Get the Name of Life Event Trigger from Lookup
           --l_mirror_name :=l_name ;

           --dbms_output.put_line('name is '||l_name);
           l_per_info_chg_cs_ler_id :=null ;
           Select
             BEN_PER_INFO_CHG_CS_LER_F_S.nextVal into
             l_per_info_chg_cs_ler_id
           From dual ;

           -- Get the Name for the Ler Trigger
           l_name := chkName(p_effective_date,l_CPE.Information15,p_business_group_id);


           -- Create the Life event Triggers in Staging
           ben_copy_entity_results_api.create_copy_entity_results
                  (
                    p_copy_entity_result_id          => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_information2                   => p_effective_date,
                    p_information3                   => p_effective_end_date,

                    p_number_of_copies               => 1,
                    p_dml_operation    =>'INSERT' ,
                    p_table_Alias      => 'PSL' ,
                    p_information1     => l_per_info_chg_cs_ler_id,
                    p_information4     => p_business_group_id,
                    p_information11    =>'N',
                    p_information141   => upper(l_CPE.INFORMATION12), --SOURCE COLUMN
                    p_information142   => upper(l_CPE.INFORMATION11), --SOURCE TABLE
                    p_Information185   => decode_Value( p_business_group_id,
                                                       l_CPE.INFORMATION13,
                                                       l_CPE.Information15), -- OLD_VAL
                    p_INFORMATION186   => decode_Value( p_business_group_id,
                                                       l_CPE.INFORMATION14,
                                                       l_CPE.Information15), -- NEW_VAL
                    p_INFORMATION218   => l_Name,
                    --
                    p_object_version_number          => l_object_version_number,
                    p_effective_date                 => p_effective_date

                   );
             --
       --
      End If ;


      -- Update the Foreign Key to PSL Table in LPL with appropriate Foreign Key Id

      Update   Ben_Copy_Entity_Results
      Set
            INFORMATION258 = l_per_info_chg_cs_ler_id          --           PER_INFO_CHG_CS_LER_ID
      Where
          Copy_Entity_Txn_Id= p_copy_entity_txn_id
          --And p_effective_date between Information2 And Information3
          And Table_Alias='LPL'
          And Information258 = l_CPE.Copy_entity_result_id ;
          --And Information258= 369;

   --
   End Loop;

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);
End create_Life_Event_Triggers ;




FUNCTION Interim_Coverage_Lookup (lookupField in varchar2, lookupCd in varchar2) RETURN varchar2 IS
BEGIN
    IF (lookupField like 'ApplIntrmCvgList2') then
        IF ( (lookupCd like 'CASDFNDF') or
        (lookupCd like 'CASDFNMN') or
        (lookupCd like 'CASDFNNL') or
        (lookupCd like 'CASDFNNT') or
        (lookupCd like 'CSEDFNDF') or
        (lookupCd like 'CSEDFNMN') or
        (lookupCd like 'CSEDFNNL') or
        (lookupCd like 'CSEDFNNT')) then return 'DEC';

        end if;


        IF ( (lookupCd like 'CASMNNDF') or
        (lookupCd like 'CASMNNMN') or
        (lookupCd like 'CASMNNNL') or
        (lookupCd like 'CASMNNNT') or
        (lookupCd like 'CSEMNNDF') or
        (lookupCd like 'CSEMNNMN') or
        (lookupCd like 'CSEMNNNL') or
        (lookupCd like 'CSEMNNNT')) then return 'LLEMC';

        end if;

        IF ( (lookupCd like 'CASNLNDF') or
        (lookupCd like 'CASNLNMN') or
        (lookupCd like 'CASNLNNL') or
        (lookupCd like 'CASNLNNT') or
        (lookupCd like 'CSENLNDF') or
        (lookupCd like 'CSENLNNL') or
        (lookupCd like 'CSENLNMN') or
        (lookupCd like 'CSENLNNT')) then return 'OLLCE';

        end if;

        IF ( (lookupCd like 'CASNTNDF') or
        (lookupCd like 'CASNTNMN') or
        (lookupCd like 'CASNTNNL') or
        (lookupCd like 'CASNTNNT') or
        (lookupCd like 'CSENTNDF') or
        (lookupCd like 'CSENTNMN') or
        (lookupCd like 'CSENTNNL') or
        (lookupCd like 'CSENTNNT')) then return 'NONE';

        end if;

        IF ( (lookupCd like 'CASSMNDF') or
        (lookupCd like 'CASSMNMN') or
        (lookupCd like 'CASSMNNL') or
        (lookupCd like 'CASSMNNT') or
        (lookupCd like 'CSESMNDF') or
        (lookupCd like 'CSESMNMN') or
        (lookupCd like 'CSESMNNL') or
        (lookupCd like 'CSESMNNT')) then return 'KPPRVCVG';

        end if;
    end if;



    IF (lookupField like 'IntrmCvgCndtn1')
    then
        IF ( (lookupCd like 'CASDFNDF') or
        (lookupCd like 'CASDFNMN') or
        (lookupCd like 'CASDFNNL') or
        (lookupCd like 'CASDFNNT') or
        (lookupCd like 'CASMNNDF') or
        (lookupCd like 'CASMNNMN') or
        (lookupCd like 'CASMNNNL') or
        (lookupCd like 'CASMNNNT') or
        (lookupCd like 'CASNLNDF') or
        (lookupCd like 'CASNLNMN') or
        (lookupCd like 'CASNLNNL') or
        (lookupCd like 'CASNLNNT') or
        (lookupCd like 'CASNTNDF') or
        (lookupCd like 'CASNTNMN') or
        (lookupCd like 'CASNTNNL') or
        (lookupCd like 'CASNTNNT') or
        (lookupCd like 'CASSMNDF') or
        (lookupCd like 'CASSMNMN') or
        (lookupCd like 'CASSMNNL') or
        (lookupCd like 'CASSMNNT')) then return 'PRTTENRLDINPLTYP';

        end if;

        IF((lookupCd like 'CSEDFNDF') or
            (lookupCd like 'CSEDFNMN') or
            (lookupCd like 'CSEDFNNL') or
            (lookupCd like 'CSEDFNNT') or
            (lookupCd like 'CSEMNNDF') or
            (lookupCd like 'CSEMNNMN') or
            (lookupCd like 'CSEMNNNL') or
            (lookupCd like 'CSEMNNNT') or
            (lookupCd like 'CSENLNDF') or
            (lookupCd like 'CSENLNMN') or
            (lookupCd like 'CSENLNNL') or
            (lookupCd like 'CSENLNNT') or
            (lookupCd like 'CSENTNDF') or
            (lookupCd like 'CSENTNMN') or
            (lookupCd like 'CSENTNNL') or
            (lookupCd like 'CSENTNNT') or
            (lookupCd like 'CSESMNDF') or
            (lookupCd like 'CSESMNMN') or
            (lookupCd like 'CSESMNNL') or
            (lookupCd like 'CSESMNNT')) then return 'PRTTENRLDPLINPLTYP';

         end if;
    end if; -- IntrmCondtn1

    IF (lookupField like 'ApplIntrmCvgList1')
    then
        IF ((lookupCd like 'CASDFNDF') or
        (lookupCd like 'CASMNNDF') or
        (lookupCd like 'CASNLNDF') or
        (lookupCd like 'CASNTNDF') or
        (lookupCd like 'CASSMNDF') or
        (lookupCd like 'CSEDFNDF') or
        (lookupCd like 'CSEMNNDF') or
        (lookupCd like 'CSENLNDF') or
        (lookupCd like 'CSENTNDF') or
        (lookupCd like 'CSESMNDF')) then return 'DEC' ;

        end if;

        IF((lookupCd like 'CASDFNMN') or
        (lookupCd like 'CASMNNMN') or
        (lookupCd like 'CASNLNMN') or
        (lookupCd like 'CASNTNMN') or
        (lookupCd like 'CASSMNMN') or
        (lookupCd like 'CSEDFNMN') or
        (lookupCd like 'CSEMNNMN') or
        (lookupCd like 'CSENLNMN') or
        (lookupCd like 'CSENTNMN') or
        (lookupCd like 'CSESMNMN')) then return 'LLEMC';

        end if;

        IF ((lookupCd like 'CASDFNNL') or
        (lookupCd like 'CASMNNNL') or
        (lookupCd like 'CASNLNNL') or
        (lookupCd like 'CASNTNNL') or
        (lookupCd like 'CASSMNNL') or
        (lookupCd like 'CSEDFNNL') or
        (lookupCd like 'CSEMNNNL') or
        (lookupCd like 'CSENLNNL') or
        (lookupCd like 'CSENTNNL') or
        (lookupCd like 'CSESMNNL')) then return 'OLLCE';

        end if;

        IF ((lookupCd like 'CASDFNNT') or
        (lookupCd like 'CASMNNNT') or
        (lookupCd like 'CASNLNNT') or
        (lookupCd like 'CASNTNNT') or
        (lookupCd like 'CASSMNNT') or
        (lookupCd like 'CSEDFNNT') or
        (lookupCd like 'CSEMNNNT') or
        (lookupCd like 'CSENLNNT') or
        (lookupCd like 'CSENTNNT') or
        (lookupCd like 'CSESMNNT')) then return 'NONE';

        end if;
    end if;  --  ApplIntCvgCd2

    IF (lookupField like 'ApplIntrmCvgList4')
    then
        IF ((lookupCd like 'CASDFNDF') or
        (lookupCd like 'CASDFNMN') or
        (lookupCd like 'CASDFNNL') or
        (lookupCd like 'CASDFNNT') or
        (lookupCd like 'CSODFNDF') or
        (lookupCd like 'CSODFNMN') or
        (lookupCd like 'CSODFNNL') or
        (lookupCd like 'CSODFNNT') or
        (lookupCd like 'CSEDFNDF') or
        (lookupCd like 'CSEDFNMN') or
        (lookupCd like 'CSEDFNNL') or
        (lookupCd like 'CSEDFNNT')) then return 'DEC';

        end if;

        IF ((lookupCd like 'CASMNNDF') or
        (lookupCd like 'CASMNNMN') or
        (lookupCd like 'CASMNNNL') or
        (lookupCd like 'CASMNNNT') or
        (lookupCd like 'CSOMNNDF') or
        (lookupCd like 'CSOMNNMN') or
        (lookupCd like 'CSOMNNNL') or
        (lookupCd like 'CSOMNNNT') or
        (lookupCd like 'CSEMNNDF') or
        (lookupCd like 'CSEMNNMN') or
        (lookupCd like 'CSEMNNNT') or
        (lookupCd like 'CSEMNNNL')) then return 'LLEMC';

        end if;

        IF ((lookupCd like 'CASNLNDF') or
        (lookupCd like 'CASNLNMN') or
        (lookupCd like 'CASNLNNL') or
        (lookupCd like 'CASNLNNT') or
        (lookupCd like 'CSONLNNL') or
        (lookupCd like 'CSONLNNT') or
        (lookupCd like 'CSONLNDF') or
        (lookupCd like 'CSONLNMN') or
        (lookupCd like 'CSENLNDF') or
        (lookupCd like 'CSENLNMN') or
        (lookupCd like 'CSENLNNL') or
        (lookupCd like 'CSENLNNT')) then return 'OLLCE';

        end if;


        IF ((lookupCd like 'CASNTNDF') or
        (lookupCd like 'CASNTNMN') or
        (lookupCd like 'CASNTNNL') or
        (lookupCd like 'CASNTNNT') or
        (lookupCd like 'CSONTNDF') or
        (lookupCd like 'CSONTNMN') or
        (lookupCd like 'CSONTNNL') or
        (lookupCd like 'CSONTNNT') or
        (lookupCd like 'CSENTNDF') or
        (lookupCd like 'CSENTNMN') or
        (lookupCd like 'CSENTNNL') or
        (lookupCd like 'CSENTNNT')) then return 'NONE';

        end if;

        IF ((lookupCd like 'CASSMNDF') or
        (lookupCd like 'CASSMNMN') or
        (lookupCd like 'CASSMNNL') or
        (lookupCd like 'CASSMNNT') or
        (lookupCd like 'CSOSMNDF') or
        (lookupCd like 'CSOSMNMN') or
        (lookupCd like 'CSOSMNNL') or
        (lookupCd like 'CSOSMNNT') or
        (lookupCd like 'CSESMNDF') or
        (lookupCd like 'CSESMNMN') or
        (lookupCd like 'CSESMNNL') or
        (lookupCd like 'CSESMNNT')) then return 'KPPRVCVG';

        end if;
    end if;

        IF (lookupField like 'IntrmCvgCndtn2')
        then
            IF((lookupCd like 'CASDFNDF') or
            (lookupCd like 'CASDFNMN') or
            (lookupCd like 'CASDFNNL') or
            (lookupCd like 'CASDFNNT') or
            (lookupCd like 'CASMNNDF') or
            (lookupCd like 'CASMNNMN') or
            (lookupCd like 'CASMNNNL') or
            (lookupCd like 'CASMNNNT') or
            (lookupCd like 'CASNLNDF') or
            (lookupCd like 'CASNLNMN') or
            (lookupCd like 'CASNLNNL') or
            (lookupCd like 'CASNLNNT') or
            (lookupCd like 'CASNTNDF') or
            (lookupCd like 'CASNTNMN') or
            (lookupCd like 'CASNTNNL') or
            (lookupCd like 'CASNTNNT') or
            (lookupCd like 'CASSMNDF') or
            (lookupCd like 'CASSMNMN') or
            (lookupCd like 'CASSMNNL') or
            (lookupCd like 'CASSMNNT')) then return 'PRTTENRLDINPLTYP';

            end if;

            IF ((lookupCd like 'CSODFNDF') or
            (lookupCd like 'CSODFNMN') or
            (lookupCd like 'CSODFNNL') or
            (lookupCd like 'CSODFNNT') or
            (lookupCd like 'CSOMNNDF') or
            (lookupCd like 'CSOMNNMN') or
            (lookupCd like 'CSOMNNNL') or
            (lookupCd like 'CSOMNNNT') or
            (lookupCd like 'CSONLNDF') or
            (lookupCd like 'CSONLNMN') or
            (lookupCd like 'CSONLNNL') or
            (lookupCd like 'CSONLNNT') or
            (lookupCd like 'CSONTNDF') or
            (lookupCd like 'CSONTNMN') or
            (lookupCd like 'CSONTNNL') or
            (lookupCd like 'CSONTNNT') or
            (lookupCd like 'CSOSMNDF') or
            (lookupCd like 'CSOSMNMN') or
            (lookupCd like 'CSOSMNNL') or
            (lookupCd like 'CSOSMNNT')) then return  'PRTTENRLDOPTINPL';

            end if;

            IF((lookupCd like 'CSEDFNDF') or
            (lookupCd like 'CSEDFNMN') or
            (lookupCd like 'CSEDFNNL') or
            (lookupCd like 'CSEDFNNT') or
            (lookupCd like 'CSEMNNDF') or
            (lookupCd like 'CSEMNNMN') or
            (lookupCd like 'CSEMNNNL') or
            (lookupCd like 'CSEMNNNT') or
            (lookupCd like 'CSENLNDF') or
            (lookupCd like 'CSENLNMN') or
            (lookupCd like 'CSENLNNL') or
            (lookupCd like 'CSENLNNT') or
            (lookupCd like 'CSENTNDF') or
            (lookupCd like 'CSENTNMN') or
            (lookupCd like 'CSENTNNL') or
            (lookupCd like 'CSENTNNT') or
            (lookupCd like 'CSESMNDF') or
            (lookupCd like 'CSESMNMN') or
            (lookupCd like 'CSESMNNL') or
            (lookupCd like 'CSESMNNT')) then return 'PRTTENRLDPLINPLTYP';

            end if;
        end if;


    IF (lookupField like 'ApplIntrmCvgList3')
    then
        IF((lookupCd like 'CASDFNDF') or (lookupCd like 'CASMNNDF') or (lookupCd like 'CASNLNDF') or
        (lookupCd like 'CASNTNDF') or (lookupCd like 'CASSMNDF') or (lookupCd like 'CSODFNDF') or
        (lookupCd like 'CSOMNNDF') or (lookupCd like 'CSONLNDF') or (lookupCd like 'CSONTNDF') or
        (lookupCd like 'CSOSMNDF') or (lookupCd like 'CSEDFNDF') or (lookupCd like 'CSEMNNDF') or
        (lookupCd like 'CSENLNDF') or (lookupCd like 'CSENTNDF') or (lookupCd like 'CSESMNDF') )
        then return 'DEC';

        end if;

        IF ((lookupCd like 'CASDFNMN') or
        (lookupCd like 'CASMNNMN') or
        (lookupCd like 'CASNLNMN') or
        (lookupCd like 'CASNTNMN') or
        (lookupCd like 'CASSMNMN') or
        (lookupCd like 'CSODFNMN') or
        (lookupCd like 'CSOMNNMN') or
        (lookupCd like 'CSONLNMN') or
        (lookupCd like 'CSONTNMN') or
        (lookupCd like 'CSOSMNMN') or
        (lookupCd like 'CSEDFNMN') or
        (lookupCd like 'CSEMNNMN') or
        (lookupCd like 'CSENLNMN') or
        (lookupCd like 'CSENTNMN') or
        (lookupCd like 'CSESMNMN') ) then return 'LLEMC';

        end if;

        IF ((lookupCd like 'CASDFNNL') or
        (lookupCd like 'CASMNNNL') or
        (lookupCd like 'CASNLNNL') or
        (lookupCd like 'CASNTNNL') or
        (lookupCd like 'CASSMNNL') or
        (lookupCd like 'CSODFNNL') or
        (lookupCd like 'CSOMNNNL') or
        (lookupCd like 'CSONLNNL') or
        (lookupCd like 'CSONTNNL') or
        (lookupCd like 'CSOSMNNL') or
        (lookupCd like 'CSEDFNNL') or
        (lookupCd like 'CSEMNNNL') or
        (lookupCd like 'CSENLNNL') or
        (lookupCd like 'CSENTNNL') or
        (lookupCd like 'CSESMNNL')) then return 'OLLCE';

        end if;

        IF ((lookupCd like 'CASDFNNT') or
        (lookupCd like 'CASMNNNT') or
        (lookupCd like 'CASNLNNT') or
        (lookupCd like 'CASNTNNT') or
        (lookupCd like 'CASSMNNT') or
        (lookupCd like 'CSODFNNT') or
        (lookupCd like 'CSOMNNNT') or
        (lookupCd like 'CSONLNNT') or
        (lookupCd like 'CSONTNNT') or
        (lookupCd like 'CSOSMNNT') or
        (lookupCd like 'CSEDFNNT') or
        (lookupCd like 'CSEMNNNT') or
        (lookupCd like 'CSENLNNT') or
        (lookupCd like 'CSENTNNT') or
        (lookupCd like 'CSESMNNT')) then return 'NONE';

        end if;  -- ApplIntrmCvgList4
     end if;
     return null;

END Interim_Coverage_Lookup;

/* This procedure copies all the Postal Zip and Benefits Grp factor in business group in to Staging. This is required
   since we allow modification of existing PoastalZip/ Bnfts Grp by displaying all of them at a time in the Factor Page */
Procedure copy_PostalZip_Bnft_Grp(
        p_copy_entity_txn_id in Number
        ) is

        cursor c_RZR(p_business_group_id Number) is
        select
                PSTL_ZIP_RNG_ID
        from
                BEN_PSTL_ZIP_RNG_F
        where
                business_group_id = p_business_group_id;

        cursor c_BNG(p_business_group_id Number) is
        select
                BENFTS_GRP_ID
        from
                BEN_BENFTS_GRP
        where business_group_id = p_business_group_id;

l_business_group_id          NUMBER;
l_ovn_number                 NUMBER;
l_effective_date             DATE;
l_proc varchar2(72) := g_package||'.copy_PostalZip_Bnft_Grp';

begin
hr_utility.set_location('Entering: '||l_proc,10);
        get_txn_details(
                p_copy_entity_txn_id,
                l_business_group_id,
                l_effective_date
                );

        FOR l_RZR in c_RZR(l_business_group_id)
        Loop
            IF (NOT staged_record_exists('RZR',l_RZR.PSTL_ZIP_RNG_ID,p_copy_entity_txn_id)) THEN
                ben_pd_rate_and_cvg_module.create_postal_results(
                    p_copy_entity_result_id          => null
                   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
                   ,p_pstl_zip_rng_id                =>l_RZR.PSTL_ZIP_RNG_ID
                   ,p_business_group_id              =>l_business_group_id
                   ,p_number_of_copies               =>1
                   ,p_object_version_number          =>l_ovn_number
                   ,p_effective_date                 =>l_effective_date
                   ) ;
             end if;
        end loop;

        FOR l_BNG in c_BNG(l_business_group_id)
        Loop
           IF (NOT staged_record_exists('BNG',l_BNG.BENFTS_GRP_ID,p_copy_entity_txn_id)) THEN
                ben_pd_rate_and_cvg_module.create_bnft_group_results(
                    p_copy_entity_result_id          => null
                   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
                   ,p_benfts_grp_id                  =>l_BNG.BENFTS_GRP_ID
                   ,p_business_group_id              =>l_business_group_id
                   ,p_number_of_copies               =>1
                   ,p_object_version_number          =>l_ovn_number
                   ,p_effective_date                 =>l_effective_date
                   ) ;
             END if;
        END Loop;
commit;
hr_utility.set_location('Leaving: '||l_proc,20);
end copy_PostalZip_Bnft_Grp;

Procedure Create_YRP_Result
(

   p_copy_entity_txn_id  Number
  ,p_business_group_id  Number
  ,p_effective_date     Date

)

Is
l_proc varchar2(72) := g_package||'.Create_YRP_Result';


---------------------------------------------------------------
-- START OF BEN_YR_PERD ----------------------
---------------------------------------------------------------

   cursor c_yrp(c_table_alias varchar2) is
   select  yrp.*
   from BEN_YR_PERD yrp
   where

     yrp.business_group_id = p_business_group_id
     and not exists (
         select null
         from ben_copy_entity_results cpe,
              pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
           and trt.table_route_id = cpe.table_route_id

           and trt.table_alias = c_table_alias
           and information1 = yrp.yr_perd_id
           and information4 = yrp.business_group_id
    );

   cursor c_table_route(c_parent_table_alias varchar2) is
       select table_route_id
       from pqh_table_route trt
       where
       trt.table_alias = c_parent_table_alias ;


    l_out_yrp_result_id  Number(15);
    l_copy_entity_result_id Number ;
    l_Object_Version_Number      Number;
    l_TABLE_ROUTE_ID  Number ;
    l_INFORMATION5  Varchar2(500);
    l_RESULT_TYPE_CD  varchar2(10);

---------------------------------------------------------------
-- END OF BEN_YR_PERD ----------------------
---------------------------------------------------------------

Begin
hr_utility.set_location('Entering: '||l_proc,10);

      for l_yrp_rec in c_yrp('YRP') loop
        --
        --
            l_table_route_id := null ;
            open c_table_route('YRP');
            fetch c_table_route into l_table_route_id ;
            close c_table_route ;
            --
            l_information5  := TO_CHAR(l_yrp_rec.start_date,'DD-Mon-YYYY')||' -  '||
                              TO_CHAR(l_yrp_rec.end_date,'DD-Mon-YYYY'); --'Intersection';
            --

            l_result_type_cd := 'DISPLAY';
            --
            l_copy_entity_result_id := null;
            l_object_version_number := null;

            -- Call Plan Copy api for copying yrp rows during pdw insert
            /*ben_plan_design_plan_module.create_yr_perd_result
            (
               p_copy_entity_txn_id => p_copy_entity_txn_id
              ,p_effective_date     => p_effective_date
              ,p_version_number     => l_object_version_number
              ,p_copy_entity_result_id=> l_copy_entity_result_id
             );*/

             -- added param "p_no_dup_rslt => 'PDW_NO_DUP_RSLT'"
             ben_plan_design_plan_module.create_yr_perd_result
                (
                        p_copy_entity_result_id          => l_copy_entity_result_id
                        ,p_copy_entity_txn_id             => p_copy_entity_txn_id
                        ,p_yr_perd_id                     => l_YRP_rec.yr_perd_id
                        ,p_business_group_id              => p_business_group_id
                        ,p_number_of_copies               => 1
                        ,p_object_version_number          => l_object_version_number
                        ,p_effective_date                 => p_effective_date
                        ,p_parent_entity_result_id        => l_copy_entity_result_id
                        ,p_no_dup_rslt                    => 'PDW_NO_DUP_RSLT'
                );


            -- commented out custom create_yrp implementation

          end loop;

          populate_extra_mappings_CPY
          (
            p_copy_entity_txn_id  => p_copy_entity_txn_id
           ,p_business_group_id   => p_business_group_id
           ,p_effective_date      => p_effective_date
          );

        -- woraround - for Now Dump All Elpros into staging
        -- we are now dumping elpros only in Criteria Set page where it is required
        -- dumping them here makes the program page very ineffecient
        -- dump_elig_prfls(p_copy_entity_txn_id);

        -- This is to copy all the PZips and BnftsGrps in BG to staging
       -- copy_PostalZip_Bnft_Grp(p_copy_entity_txn_id);
        --
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
End Create_YRP_Result;

--
-- This  Function implements the Pre-Processor for Plan Design Wizard. It will do the following
-- * Attach all Year Periods to All Plans in Txn
-- * Create Seeded Life Event Triggers if not already there
--

PROCEDURE pre_Processor(
   p_validate            Number
  , p_copy_entity_txn_id  Number
  ,p_business_group_id   Number
  ,p_effective_date      Date
  ,p_exception OUT NOCOPY Varchar2

 )

 is

 --pragma AUTONOMOUS_TRANSACTION;

 l_Temp   Varchar2(500);
 l_proc varchar2(72) := g_package||'.pre_Processor';
 l_max_sequence Number;
 l_sequence Number;

 cursor c_cpp_sequence is
 select
        information263 ordr_num
 from
        ben_copy_entity_results
 where
        copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'CPP'
        and p_effective_date between information2 and information3
        and information263 is null
 for update of information263;

 cursor c_ctp_sequence is
 select
        information268 ordr_num
 from
        ben_copy_entity_results
 where
        copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'CTP'
        and p_effective_date between information2 and information3
        and information268 is null
 for update of information268;

 Begin
 hr_utility.set_location('Entering: '||l_proc,10);
     --
      l_temp:=Null ;
      fnd_msg_pub.initialize ;

      -- Create Plan Year Periods
       create_Plan_Yr_Periods
       (
         p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
       );


      -- Create Life Event Triggers
       create_Life_Event_Triggers
       (
          p_copy_entity_txn_id => p_copy_entity_txn_id
         ,p_business_group_id  => p_business_group_id
         ,p_effective_date     => p_effective_date
         ,p_effective_end_date => to_date('31-12-4712','DD-MM-YYYY')
       );

       -- Fill the sequence number for Imputed Shell Plan and Imputed Shell Plan Type
       -- All CPP and CTP records will already have sequence numbers entered
       -- CPP and CTP records with no sequence numbers will be of Imputed Shell plan / plantypes
        max_sequence(
        p_copy_entity_txn_id,
        p_effective_date,
        'CPP',
        NULL,
        l_max_sequence);
       l_sequence := (round((l_max_sequence/10),0)+1)*10;
       for p_cpp in c_cpp_sequence loop
         update
              ben_copy_entity_results
         set
              information263 = l_sequence
         where current of c_cpp_sequence;
       l_sequence := l_sequence + 10;
       end loop;

       max_sequence(
        p_copy_entity_txn_id,
        p_effective_date,
        'CTP',
        NULL,
        l_max_sequence);
       l_sequence := (round((l_max_sequence/10),0)+1)*10;
       for p_ctp in c_ctp_sequence loop
         update
              ben_copy_entity_results
         set
              information268 = l_sequence
         where current of c_ctp_sequence;
       l_sequence := l_sequence + 10;
       end loop;

     p_Exception :=Null ;
 --    if p_validate = 0 then
 --        commit ;
 --    else
 --        rollback ;
 --    End If ;
         --
 hr_utility.set_location('Leaving: '||l_proc,20);
 Exception When Others Then
     p_Exception := sqlerrm ;
     rollback;
     raise ;

 End pre_Processor;

FUNCTION GET_BALANCE_NAME(  p_balance_id IN Number,
                   p_bnft_balance_id IN NUMBER,
                   p_business_group_id IN Number,
                   p_copy_entity_txn_id IN NUMBER,
                   p_effective_date IN DATE
                )
RETURN VARCHAR2 IS
Cursor csr_balance(c_balance_id NUMBER,c_bg_id NUMBER) IS
select pbt.balance_name||' - '||pbd.dimension_name name
from pay_balance_types pbt,pay_balance_dimensions pbd, pay_defined_balances pdb
where (pdb.business_group_id is null or pdb.business_group_id = c_bg_id )
and pdb.balance_type_id = pbt.balance_type_id
and pdb.balance_dimension_id = pbd.balance_dimension_id
and pdb.defined_balance_id=c_balance_id;

Cursor csr_bnft_balance( c_balance_id NUMBER,c_bg_id NUMBER,c_effective_date DATE) IS
select name
from ben_bnfts_bal_f
where business_group_id = c_bg_id
and c_effective_date between effective_start_date and effective_end_date
and bnfts_bal_id =c_balance_id;

Cursor csr_new_bnft_balance(c_balance_id NUMBER,c_txn_id NUMBER,c_effective_date DATE) IS
select information170
from ben_copy_entity_results where
table_alias='BNB' and copy_entity_txn_id=c_txn_id
and information1=c_balance_id and
c_effective_date between information2 and information3;

l_name varchar2(240);
BEGIN
IF p_balance_id is NOT NULL
THEN
 OPEN csr_balance(p_balance_id,p_business_group_id);
 FETCH csr_balance INTO l_name;
 CLOSE csr_balance;
ELSE
   OPEN csr_bnft_balance(p_bnft_balance_id,p_business_group_id,p_effective_date);
  FETCH csr_bnft_balance INTO l_name;
  CLOSE csr_bnft_balance;
  IF l_name is null THEN
  OPEN csr_new_bnft_balance(p_bnft_balance_id,p_copy_entity_txn_id,p_effective_date);
   FETCH csr_new_bnft_balance INTO l_name;
  CLOSE csr_new_bnft_balance;
 END IF;
END IF;
RETURN l_name;
END GET_BALANCE_NAME;

FUNCTION GET_CURRENCY(p_currency_code IN VARCHAR2,p_effective_date IN DATE)
RETURN VARCHAR2 IS
CURSOR csr_currency (c_currency_code VARCHAR2, c_effective_date DATE) IS
select name
from fnd_currencies_vl
where (start_date_active is null or start_date_active <=c_effective_date)
and (end_date_active is null or end_date_active >= c_effective_date)
and enabled_flag = 'Y' and currency_code=c_currency_code;

l_name fnd_currencies_vl.NAME%TYPE;
BEGIN
OPEN csr_currency (p_currency_code ,p_effective_date );
FETCH csr_currency into l_name;
CLOSE csr_currency;
RETURN l_name;
END GET_CURRENCY;
/*
 * Generic Function to get Information170 column..to be used in VO's
 */
 Function get_stage_object_Name(
                p_copy_entity_txn_id IN NUMBER
               ,p_table_alias        IN VARCHAR2
               ,p_information1       IN NUMBER
               )
Return VARCHAR2  IS
Cursor csr_stage_obj(
        p_effective_date Date
        )
IS
Select information170
From ben_copy_entity_results
Where copy_entity_txn_id=p_copy_entity_txn_id
and table_alias=p_table_alias
and information1=p_information1
and p_effective_date between nvl(information2,p_effective_date) and nvl(information3,p_effective_date);

l_name ben_copy_entity_results.information170%TYPE;
l_table_name pqh_table_route.where_clause%TYPE;
l_effective_date pqh_copy_entity_txns.SRC_EFFECTIVE_DATE%TYPE;
l_bg_id pqh_copy_entity_txns.CONTEXT_BUSINESS_GROUP_ID%TYPE;
Begin
get_txn_details(
        p_copy_entity_txn_id,
        l_bg_id,
        l_effective_date
        );

if p_table_alias='PFF'
then
   begin
        select information218 into l_name
        from ben_copy_entity_results
        where copy_entity_txn_id=p_copy_entity_txn_id
        and table_alias=p_table_alias
        and information1=p_information1;
   Exception when no_data_found then
     l_name := null;
   end;
   return l_name;
 elsif p_table_alias='RZR'
 then
   begin
        select information142||' - '|| information141 into l_name
        from ben_copy_entity_results
        where copy_entity_txn_id=p_copy_entity_txn_id
        and table_alias=p_table_alias
        and information1=p_information1
        and rownum=1;
   Exception when no_data_found then
     l_name := null;
   end;
   Return l_name;
else
Open csr_stage_obj(l_effective_date);
Fetch csr_stage_obj into l_name;
-- The below code is to ensure that if the Plan is not found in staging, the Plan name is retrieved from the ben table
IF (csr_stage_obj%NOTFOUND  and p_table_alias ='PLN') then
 begin

 select
        name into l_name
 from
        ben_pl_f
 where
        pl_id = p_information1
        and business_group_id = l_bg_id
        and l_effective_date between effective_start_date and effective_end_date;

 Exception when no_data_found then
   null;
 end;
end if;

Close csr_stage_obj;
Return l_name;
end if;
End get_stage_object_Name;

/*
 *Procedure to copy drvd factors
 */
PROCEDURE copy_drvd_factor(
                p_copy_entity_txn_id IN NUMBER
               ,p_table_alias        IN VARCHAR2
               ,p_information1       IN NUMBER
               ) IS
l_proc varchar2(72) := g_package||'.copy_drvd_factor';

Cursor csr_rec_exists is
Select 'Y'
From BEN_COPY_ENTITY_RESULTS
Where copy_entity_txn_id=p_copy_entity_txn_id
And table_alias=p_table_alias
And information1=p_information1
And result_type_cd='DISPLAY';
--

l_dummy VARCHAR2(1);
l_comp_lvl_fctr_id           NUMBER;
l_hrs_wkd_in_perd_fctr_id    NUMBER;
l_los_fctr_id                NUMBER;
l_pct_fl_tm_fctr_id          NUMBER;
l_age_fctr_id                NUMBER;
l_cmbn_age_los_fctr_id      NUMBER;
l_business_group_id          NUMBER;
l_ovn_number                 NUMBER;
l_effective_date             DATE;
BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
OPEN csr_rec_exists;
FETCH csr_rec_exists into l_dummy;
IF csr_rec_exists%NOTFOUND THEN
--
get_txn_details (
                                      p_copy_entity_txn_id
                                     ,l_business_group_id
                                     ,l_effective_date
                );

IF  p_table_alias='BNG' THEN
 IF (NOT staged_record_exists('BNG',p_information1,p_copy_entity_txn_id)) THEN
 ben_pd_rate_and_cvg_module.create_bnft_group_results
   (
    p_copy_entity_result_id          => null
   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
   ,p_benfts_grp_id                  =>p_information1
   ,p_business_group_id              =>l_business_group_id
   ,p_number_of_copies               =>1
   ,p_object_version_number          =>l_ovn_number
   ,p_effective_date                 =>l_effective_date
   ) ;
   RETURN;
 END IF;
 --
 ELSIF p_table_alias='SVA' THEN
 IF (NOT staged_record_exists('SVA',p_information1,p_copy_entity_txn_id)) THEN
-- setting g_pdw_allow_dup_rlst to ensure that duplicat Postal Zip values are not copied in to staging
 ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
  ben_pd_rate_and_cvg_module.create_service_results
   (
    p_copy_entity_result_id          => null
   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
   ,p_svc_area_id                    =>p_information1
   ,p_business_group_id              =>l_business_group_id
   ,p_number_of_copies               =>1
   ,p_object_version_number          =>l_ovn_number
   ,p_effective_date                 =>l_effective_date
   ) ;
   ben_plan_design_program_module.g_pdw_allow_dup_rslt := NULL ;
   RETURN;
  END IF;
 --
 ELSIF p_table_alias='RZR' THEN
	 IF (NOT staged_record_exists('RZR',p_information1,p_copy_entity_txn_id)) THEN
	  ben_pd_rate_and_cvg_module.create_postal_results
	   (
	    p_copy_entity_result_id          => null
	   ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
	   ,p_pstl_zip_rng_id                =>p_information1
	   ,p_business_group_id              =>l_business_group_id
	   ,p_number_of_copies               =>1
	   ,p_object_version_number          =>l_ovn_number
	   ,p_effective_date                 =>l_effective_date
	  ) ;
	  RETURN;
	 END IF;
 ELSIF p_table_alias='EGL' THEN
	IF (NOT staged_record_exists('EGL',p_information1,p_copy_entity_txn_id)) THEN
	ben_plan_design_elpro_module.create_eligy_criteria_result
	(
	  p_copy_entity_result_id   => null
	  ,p_copy_entity_txn_id     => p_copy_entity_txn_id
	  ,p_eligy_criteria_id      => p_information1
	  ,p_business_group_id      => l_business_group_id
	  ,p_number_of_copies       => 1
	  ,p_object_version_number  => l_ovn_number
	  ,p_effective_date         => l_effective_date
	  ,p_parent_entity_result_id => null
	  ,p_no_dup_rslt            => 'PDW_NO_DUP_RSLT'
	  );
	 END IF;
 END IF;
 --
if  p_table_alias='AGF' THEN  l_age_fctr_id :=p_information1;
elsif  p_table_alias='CLA' THEN  l_cmbn_age_los_fctr_id :=p_information1;
elsif  p_table_alias='CLF' THEN  l_comp_lvl_fctr_id :=p_information1;
elsif  p_table_alias='HWF' THEN  l_hrs_wkd_in_perd_fctr_id :=p_information1;
elsif  p_table_alias='LSF' THEN  l_los_fctr_id :=p_information1;
elsif  p_table_alias='PFF' THEN  l_pct_fl_tm_fctr_id :=p_information1;
end if;
--
ben_pd_rate_and_cvg_module.create_drpar_results
     (
      p_copy_entity_result_id    =>null
     ,p_copy_entity_txn_id       => p_copy_entity_txn_id
     ,p_comp_lvl_fctr_id         => l_comp_lvl_fctr_id
     ,p_hrs_wkd_in_perd_fctr_id  => l_hrs_wkd_in_perd_fctr_id
     ,p_los_fctr_id              => l_los_fctr_id
     ,p_pct_fl_tm_fctr_id        => l_pct_fl_tm_fctr_id
     ,p_age_fctr_id              => l_age_fctr_id
     ,p_cmbn_age_los_fctr_id     => l_cmbn_age_los_fctr_id
     ,p_business_group_id        => l_business_group_id
     ,p_number_of_copies         => 1
     ,p_object_version_number    => l_ovn_number
     ,p_effective_date           => l_effective_date
     ,p_no_dup_rslt              => 'PDW_NO_DUP_RSLT'
     );
END IF;
CLOSE csr_rec_exists;
 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);
hr_utility.set_location('Leaving: '||l_proc,20);
END copy_drvd_factor;
-- This should return the max sequence based on past present and future rows
procedure max_sequence(
        p_copy_entity_txn_id IN Number,
        p_effective_date IN Date,
        p_table_alias IN varchar2,
        p_plan_id IN Number,
        p_max_sequence OUT NOCOPY Number) is
l_proc varchar2(72) := g_package||'.max_sequence';
  cursor max_cpp_sequence(c_copy_entity_txn_id Number, c_effective_date Date) is
        select max(information263)
        from ben_copy_entity_results
        where table_alias = 'CPP'
        and copy_entity_txn_id = c_copy_entity_txn_id;
      --  and c_effective_date between information2 and information3;

  cursor max_ctp_sequence(c_copy_entity_txn_id Number, c_effective_date Date) is
        select max(information268)
        from ben_copy_entity_results
        where table_alias = 'CTP'
        and copy_entity_txn_id = c_copy_entity_txn_id;
      --  and c_effective_date between information2 and information3;


  cursor max_cop_sequence(c_copy_entity_txn_id Number, c_effective_date Date, c_plan_id Number) is
        select max(information263)
        from ben_copy_entity_results
        where table_alias = 'COP'
        and copy_entity_txn_id = c_copy_entity_txn_id
        and information261 = c_plan_id;
    --        and c_effective_date between information2 and information3;
begin
hr_utility.set_location('Entering: '||l_proc,10);
	if p_table_alias = 'CPP' then
          open max_cpp_sequence(p_copy_entity_txn_id,p_effective_date);
          fetch max_cpp_sequence into p_max_sequence;
          close max_cpp_sequence;
        elsif p_table_alias = 'CTP' then
          open max_ctp_sequence(p_copy_entity_txn_id,p_effective_date);
          fetch max_ctp_sequence into p_max_sequence;
          close max_ctp_sequence;
        elsif  p_table_alias = 'COP' then
          open max_cop_sequence(p_copy_entity_txn_id,p_effective_date,p_plan_id);
          fetch max_cop_sequence into p_max_sequence;
          close max_cop_sequence;
        end if;
hr_utility.set_location('Entering: '||l_proc,10);
end;

FUNCTION fetch_drvd_factor_result
(
 p_copy_entity_txn_id IN NUMBER
,p_table_alias        IN VARCHAR2
,p_information1       IN NUMBER
)
RETURN NUMBER IS
Cursor csr_drvd_result IS
Select COPY_ENTITY_RESULT_ID From BEN_COPY_ENTITY_RESULTS
Where copy_entity_txn_id=p_copy_entity_txn_id
And table_alias=p_table_alias
And information1=p_information1
And result_type_cd='DISPLAY';

l_copy_entity_result_id NUMBER;
BEGIN
copy_drvd_factor(p_copy_entity_txn_id  ,p_table_alias  ,p_information1);
OPEN csr_drvd_result;
FETCH csr_drvd_result into l_copy_entity_result_id;
CLOSE csr_drvd_result;
RETURN l_copy_entity_result_id;
END fetch_drvd_factor_result;


PROCEDURE populate_extra_Mapping_ENP
      (
        p_copy_entity_result_id Number,
        p_effective_date        Date
      )
    Is
    --
    l_Strt_Dt Date ;
    l_End_Dt  Date ;
    l_enp_name ben_copy_entity_results.information5%type;
    l_proc varchar2(72) := g_package||'.populate_extra_Mapping_ENP';

    Cursor c_ENP is
     Select
           yrp.information309 strt_dt,
           yrp.information308 end_dt
     From
           Ben_copy_entity_results yrp,
           Ben_copy_entity_results enp
     Where
           ENP.copy_entity_result_id = p_copy_entity_result_id
           And yrp.copy_entity_txn_id = ENP.copy_entity_txn_id
           and yrp.table_alias='YRP'
           and ENP.table_alias='ENP'
           and ENP.information240 = yrp.information1 ;
    --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_ENP in c_ENP Loop
     --
     -- The below code is to populate information5 of ENP in a format required
     -- for displaying on Enrollment Requirements Cvg and Rate Hgrids
     Begin
        select
                meaning||' '||to_char(enp.information318,'yyyy-mm-dd')||' '||to_char(enp.information317,'yyyy-mm-dd') into l_enp_name
        from
                hr_lookups,
                ben_copy_entity_results enp,
                ben_copy_entity_results pet
        where
                lookup_type = 'BEN_ENRT_TYP_CYCL'
                and enp.copy_entity_result_id = p_copy_entity_result_id
                and pet.copy_entity_txn_id = enp.copy_entity_txn_id
                and pet.table_alias = 'PET'
                and enp.information232 = pet.information1
                and lookup_code = pet.information11
                and p_effective_date between pet.information2 and pet.information3;


             Update
                Ben_copy_entity_results ENP1
              Set
                ENP1.Information310 = l_ENP.strt_dt,
                ENP1.Information311 = l_ENP.end_dt,
                ENP1.Information5 = l_enp_name
              Where
                ENP1.copy_entity_result_id = p_copy_entity_result_id ;

      Exception When No_Data_Found Then
              l_enp_name := null;
      End;
     --
     End Loop ;

    --
    hr_utility.set_location('Leaving: '||l_proc,20);
    End populate_extra_Mapping_ENP;

    PROCEDURE populate_extra_Mappings_ENP
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_ENP';
      Cursor C_ENP is
        Select
           ENP.copy_entity_result_id
        From
           Ben_copy_entity_results ENP,
           Ben_copy_entity_results pet
        Where
           ENP.copy_entity_txn_id = p_copy_entity_txn_id
           And ENP.copy_entity_txn_id = pet.copy_entity_txn_id
           And p_effective_date between pet.information2 and pet.information3
           and pet.table_alias='PET'
           and ENP.table_alias='ENP'
           and pet.information11 in ('O','A')
           and ENP.information232 = pet.information1
           and pet.information260= p_pgm_id;

    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
      For l_ENP in c_ENP Loop

          populate_extra_mapping_ENP(l_ENP.copy_entity_result_id,p_effective_date);

      End Loop ;
hr_utility.set_location('Leaving: '||l_proc,20);
End populate_extra_Mappings_ENP;


 PROCEDURE populate_extra_Mappings_CTP
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_CTP';
      -- Select All CTP records which have a default enrollment logic defined
      --
      Cursor C_CTP is
        Select
           ctp.copy_entity_result_id,
           ctp.information45,
           ctp.information248,
           ctp.information2 effective_date -- Add effective Date for populating mappings
        From
           Ben_copy_entity_results ctp
        Where
           ctp.copy_entity_txn_id = p_copy_entity_txn_id
           And ctp.copy_entity_txn_id = ctp.copy_entity_txn_id
           --And p_effective_date between ctp.information2 and ctp.information3
           And ctp.table_alias='CTP'
           And ctp.information260= p_pgm_id
           And ctp.information45 is not null
           And ctp.information106 is  null -- not populated already
           And ctp.dml_operation <>'DELETE'
         For Update of ctp.Information106,ctp.information107;

          -- Select All CTP records which have a Enrollment Code defined
         Cursor C_Enrt_CTP is
                select
                        information44 ENRT_CD,
                        information101 NEW_ENRT_CD,
                        information102 CUR_ENRT_CD
                from
                        ben_copy_entity_results
                where
                        copy_entity_txn_id = p_copy_entity_txn_id
                        and table_alias = 'CTP'
                        and information44 is not null
                       -- and p_effective_date between information2 and information3
                        and dml_operation <> 'DELETE'
        for update of information101, information102;

         l_new_dflt_enrt_cd  varchar2(15);
         l_old_dflt_enrt_cd  varchar2(15);
         l_new_enrt_cd  ben_copy_entity_results.information101%type;
         l_cur_enrt_cd  ben_copy_entity_results.information102%type;
         l_default_object_id Number;
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_CTP in c_CTP Loop
      --
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_CTP.information45);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_CTP.information45);

      --
      -- Find any plans under this ptp which has default flag set
      Begin
       --
              Select
                 cpp.copy_entity_result_id into l_default_object_id
              From
                 ben_copy_entity_results cpp
                 ,ben_copy_entity_results pln
              Where
                 cpp.copy_entity_txn_id = p_copy_entity_txn_id
                 -- Take Effective Date from the cursor above
                 And l_CTP.effective_date between cpp.information2 and cpp.information3
                 And cpp.information13 ='Y'
                 And cpp.information260= p_pgm_id
                 And pln.copy_entity_txn_id = cpp.copy_entity_txn_id
                 And l_CTP.effective_date between pln.information2 and pln.information3
                 And pln.information248 = l_CTP.information248
                 And pln.information1 = cpp.information261
                 And cpp.table_alias='CPP'
                 And pln.table_alias='PLN'
                 And cpp.dml_operation <>'DELETE'
                 And pln.dml_operation <>'DELETE'
                 and rownum =1 ;

        --
      Exception When No_Data_Found Then
              l_default_object_id := null;
      End  ;

      if l_default_Object_id is null then
      --
      Begin
              Select
                 cop.copy_entity_result_id into l_default_object_id
              From
                 ben_copy_entity_results pln
                 ,ben_copy_entity_results cop
              Where
                 pln.copy_entity_txn_id = p_copy_entity_txn_id
                 And l_CTP.effective_date between pln.information2 and pln.information3
                 And cop.copy_entity_txn_id=pln.copy_entity_txn_id
                 And l_CTP.effective_date between cop.information2 and cop.information3
                 And pln.information1 = cop.information261
                 And pln.information248= l_CTP.information248
                 And cop.information18 ='Y'
                 And pln.table_alias='PLN'
                 And cop.table_alias='COP'
                 And pln.dml_operation <>'DELETE'
                 And cop.dml_operation <>'DELETE'
                 and rownum =1 ;
      Exception When No_Data_Found Then
              l_default_object_id := null;
      End  ;

       --
      End If;


      Update
             Ben_copy_entity_results ctp1
      Set
             ctp1.information106 =l_new_dflt_enrt_cd  ,
             ctp1.information107 =l_old_dflt_enrt_cd ,
             ctp1.information160 = l_default_object_Id
      Where current of c_CTP;
      --
      End Loop ;
    --
      -- Now update the New and Cur Enrt Codes from Enrt_CD
      For L_Enrt_Ctp in C_Enrt_Ctp
      loop
                l_new_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_new_enrt_cd(L_Enrt_Ctp.ENRT_CD);
                l_cur_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_cur_enrt_cd(L_Enrt_Ctp.ENRT_CD);

                update
                        ben_copy_entity_results
                set
                        information101 = l_new_enrt_cd,
                        information102 = l_cur_enrt_cd
                where current of C_Enrt_Ctp;
        End Loop;
hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_CTP;

 PROCEDURE populate_extra_Mappings_LCT
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_LCT';
      -- Select All LCT records which have a default enrollment logic defined
      --
      -- Information12-> dflt logic , Information11 -dflt flag
      Cursor C_LCT is
        Select
           ctp.copy_entity_result_id,
           ctp.information12,
           ctp.information248,
           ctp.information259,
           ctp.information257 ler_id,
           ctp.information2 effective_date
        From
           Ben_copy_entity_results ctp
        Where

           ctp.copy_entity_txn_id = p_copy_entity_txn_id
           And ctp.copy_entity_txn_id = ctp.copy_entity_txn_id
           --And p_effective_date between ctp.information2 and ctp.information3
           And ctp.table_alias='LCT'
           --And ctp.information260= p_pgm_id
           And ctp.information12 is not null
           And ctp.information103 is null
           And ctp.dml_operation <>'DELETE'
         For Update of ctp.Information103,ctp.information104;

        -- Pick up all the LCT's for which Enrollment Code has been defined
cursor c_enrt_lct
is
        select
                information14 ENRT_CD,
                information101 NEW_ENRT_CD,
                information102 CUR_ENRT_CD
        from
                ben_copy_entity_results
        where
                copy_entity_txn_id = p_copy_entity_txn_id
                and table_alias = 'LCT'
                and information14 is not null
               -- and p_effective_date between information2 and information3
                and dml_operation <> 'DELETE'
for update of information101, information102;

l_new_enrt_cd ben_copy_entity_results.information101%type;
l_cur_enrt_cd ben_copy_entity_results.information102%type;
ptipCopyEntityResultId  ben_copy_entity_results.copy_entity_result_id%type;
l_ptp_id   ben_pl_typ_f.pl_typ_id%type;
l_new_dflt_enrt_cd  varchar2(15);
l_old_dflt_enrt_cd  varchar2(15);
l_default_object_id Number;
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --

     For l_LCT in c_LCT Loop
      --
      -- Get ptipCopyEntityResultId

      Select
        copy_entity_result_id,information248 into ptipCopyEntityResultId,l_ptp_id
      From
         ben_copy_entity_results
      where
         copy_entity_txn_id = p_copy_entity_txn_id
         and l_LCT.effective_date between information2 and information3
         and table_alias='CTP'
         and information1 = l_LCT.information259;

        --dbms_output.put_line('ptp id is '||l_ptp_id);
      --
       -- Find any plans under this lct which has default flag set

      Begin
       --
             Select
                 cpp.copy_entity_result_id into l_default_object_id
              From
                 ben_copy_entity_results lpr1
                 ,ben_copy_entity_results cpp
                 ,ben_copy_entity_results pln
                 ,ben_copy_entity_results ctp
              Where
                 lpr1.copy_entity_txn_id      = p_copy_entity_txn_id
                 And ctp.copy_entity_txn_id    = lpr1.copy_entity_txn_id
                 And cpp.copy_entity_txn_id   = lpr1.copy_entity_txn_id
                 And pln.copy_entity_txn_id   = cpp.copy_entity_txn_id

                 And l_LCT.effective_date between pln.information2 and pln.information3
                 And l_LCT.effective_date between ctp.information2 and ctp.information3
                 And l_LCT.effective_date between lpr1.information2 and lpr1.information3
                 And l_LCT.effective_date between cpp.information2 and cpp.information3

                 And ctp.information248   = l_ptp_id
                 And lpr1.information256  = cpp.information1
                 And lpr1.information13  ='Y'
                 And lpr1.information257 = l_LCT.ler_id
                 --And cpp.information260  = p_pgm_id
                 And pln.information248 = ctp.information248
                 And pln.information1 = cpp.information261

                 And lpr1.table_alias = 'LPR1'
                 And ctp.table_alias  = 'CTP'
                 And cpp.table_alias  = 'CPP'
                 And pln.table_alias  = 'PLN'

                 And lpr1.dml_operation <> 'DELETE'
                 And ctp.dml_operation <> 'DELETE'
                 And cpp.dml_operation <> 'DELETE'
                 And pln.dml_operation <> 'DELETE'

                 and rownum = 1 ;
        --
      Exception When No_Data_Found Then
              l_default_object_id := null;
      End  ;

      -- Bad Luck No Plan has default flag set
      -- We need to check for oipl's which have default flag under this lct
      if l_default_Object_id is null then
      Begin
      --
        Select
              cop.copy_entity_result_id into l_default_object_id
        From
               ben_copy_entity_results lop
               ,ben_copy_entity_results cop
               ,ben_copy_entity_results cpp
               ,ben_copy_entity_results pln
               ,ben_copy_entity_results ctp
        Where
                lop.copy_entity_txn_id      = p_copy_entity_txn_id
                And ctp.copy_entity_txn_id  = lop.copy_entity_txn_id
                And cpp.copy_entity_txn_id  = lop.copy_entity_txn_id
                And pln.copy_entity_txn_id  = cpp.copy_entity_txn_id
                And cop.copy_entity_txn_id  = pln.copy_entity_txn_id

                And l_LCT.effective_date between pln.information2 and pln.information3
                And l_LCT.effective_date between ctp.information2 and ctp.information3
                And l_LCT.effective_date between lop.information2 and lop.information3
                And l_LCT.effective_date between cop.information2 and cop.information3
                And l_LCT.effective_date between cpp.information2 and cpp.information3

                And ctp.information248   = l_ptp_id
                And lop.information258     = cop.information1
                And lop.information12 ='Y'
                And lop.information257 = l_LCT.ler_id
                --And cpp.information260  = p_pgm_id
                And pln.information248 = ctp.information248
                And pln.information1 = cpp.information261

                And cpp.information261 = cop.information261


                And lop.table_alias = 'LOP'
                And ctp.table_alias  = 'CTP'
                And cpp.table_alias  = 'CPP'
                And pln.table_alias  = 'PLN'
                And cop.table_alias  = 'COP'

                And lop.dml_operation <> 'DELETE'
                And ctp.dml_operation <> 'DELETE'
                And cpp.dml_operation <> 'DELETE'
                And pln.dml_operation <> 'DELETE'
                And cop.dml_operation <> 'DELETE'

                and rownum = 1 ;

       --
       Exception When No_Data_Found Then
              l_default_object_id := null;
       End  ;
      End If;

      --
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_LCT.information12);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_LCT.information12);

      --

      -- populate the extra mappings namely new and old dflt enrt codes
      -- also populate the composite id to that of the row copy entity result id
      -- so copied lct records will not show any groupings but wil be simply one to one
      -- grouping will hamper performance
      Update
             Ben_copy_entity_results ctp1
      Set
             ctp1.information103 =l_new_dflt_enrt_cd,
             ctp1.information104 =l_old_dflt_enrt_cd,
             ctp1.information160 = l_default_object_id,
             ctp1.information161 = ctp1.copy_entity_result_id,
             ctp1.information162 = ptipCopyEntityResultId
      Where current of c_LCT;
      --
      End Loop ;
    --
      for l_lct in c_enrt_lct
        loop
                l_new_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_new_enrt_cd(l_lct.ENRT_CD);
                l_cur_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_cur_enrt_cd(l_lct.ENRT_CD);
                update
                        ben_copy_entity_results
                set
                        information101 = l_new_enrt_cd,
                        information102 = l_cur_enrt_cd
                where current of c_enrt_lct;
      end loop;
hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_LCT;

 PROCEDURE populate_extra_Mappings_CPP
      (
            p_copy_entity_txn_id Number,
            p_effective_date     Date,
            p_pgm_id             Number
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mappings_CPP';
      -- Select All CPP records which have a default enrollment logic defined
      --
      Cursor C_CPP is
        Select
           CPP.copy_entity_result_id,
           CPP.information21,
           CPP.information13,
           CPP.information261,
           CPP.information2 effective_date
        From
           Ben_copy_entity_results CPP
        Where
           CPP.copy_entity_txn_id = p_copy_entity_txn_id
           And CPP.copy_entity_txn_id = CPP.copy_entity_txn_id
           --And p_effective_date between CPP.information2 and CPP.information3
           And CPP.table_alias='CPP'
           And CPP.information260= p_pgm_id
           And CPP.information21 is not null
           And CPP.information106 is  null -- not populated already
           And CPP.dml_operation <>'DELETE'
         For Update of CPP.Information106,CPP.information107;

           -- Select All CPP records which have enrollment code defined
         Cursor C_Enrt_CPP is
                select
                        information22 ENRT_CD,
                        information101 NEW_ENRT_CD,
                        information102 CUR_ENRT_CD
                from
                        ben_copy_entity_results
                where
                        copy_entity_Txn_id = p_copy_entity_txn_id
                        and table_alias = 'CPP'
                       -- and p_effective_date between information2 and information3
                        and dml_operation <> 'DELETE'
        for update of information101, information102;

        l_new_enrt_cd ben_copy_entity_results.information101%type;
        l_cur_enrt_cd ben_copy_entity_results.information102%type;
         l_new_dflt_enrt_cd  varchar2(15);
         l_old_dflt_enrt_cd  varchar2(15);
         l_default_object_id Number;
       --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_CPP in c_CPP Loop
      --
      l_new_dflt_enrt_cd := get_Dflt_New_Enrt_cd(l_CPP.information21);
      l_old_dflt_enrt_cd := get_Dflt_Old_Enrt_cd(l_CPP.information21);

      If l_CPP.information13 ='Y' then
       --
          l_default_object_id := l_CPP.copy_entity_result_id;
       --
      Else
       --
             Begin
                  --
                  Select
                    cop.copy_entity_result_id into l_default_object_id
                  From
                    Ben_copy_entity_results cop
                  Where
                    cop.copy_entity_txn_id = p_copy_entity_txn_id
                    And l_CPP.effective_date between cop.information2 and cop.information3
                    And cop.table_alias     = 'COP'
                    And cop.information261  = l_CPP.information261
                    And cop.information18 ='Y'
                    and rownum =1;
                  --
              Exception When No_Data_Found Then
                 --
                  l_default_object_id := null ;
                 --
              End ;
       --
      End If ;

      -- Update the New and Old Default enrollment Logic by parsing the combined dflt enrt logic
      Update
             Ben_copy_entity_results CPP1
      Set
             CPP1.information106 =l_new_dflt_enrt_cd,
             CPP1.information107 =l_old_dflt_enrt_cd,
             CPP1.information160 = l_default_object_id
      Where current of c_CPP;
      --
      End Loop ;
    --

      -- Now update the New and Cur Enrt Codes from Enrt_CD
      for l_cpp in C_Enrt_CPP loop
                l_new_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_new_enrt_cd(L_Cpp.ENRT_CD);
                l_cur_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_cur_enrt_cd(L_Cpp.ENRT_CD);

                update
                        ben_copy_entity_results
                set
                        information101 = l_new_enrt_cd,
                        information102 = l_cur_enrt_cd
                where current of C_Enrt_Cpp;
        End Loop;


hr_utility.set_location('Leaving: '||l_proc,20);
 End populate_extra_Mappings_CPP;

 PROCEDURE populate_extra_Mapping_PGM
      (
        p_copy_entity_txn_id Number,
        p_effective_date        Date
      )
    Is
    l_proc varchar2(72) := g_package||'.populate_extra_Mapping_PGM';
    --
    cursor c_PGM is
         Select pgm.*
         from
           Ben_copy_entity_results pgm
         Where
           pgm.copy_entity_txn_id = p_copy_entity_txn_id
           And pgm.table_alias='PGM'
         for update of pgm.information101,pgm.information102;

    l_new_enrt_cd varchar2(15);
    l_cur_enrt_cd varchar2(15);
    --
    Begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
     For l_PGM in c_PGM Loop
      --
             l_new_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_new_enrt_cd(l_PGM.information51) ;
             l_cur_enrt_cd := BEN_PDW_COPY_BEN_TO_STG.get_cur_enrt_cd(l_PGM.information51) ;

             Update
                   Ben_copy_entity_results pgm1
             Set
                   information101= l_new_enrt_cd,
                   information102= l_cur_enrt_cd
             Where current of c_PGM ;
      --
     End Loop ;
    --
hr_utility.set_location('Leaving: '||l_proc,20);
End populate_extra_Mapping_PGM;


PROCEDURE create_program_result
(
     p_copy_entity_result_id           NUMBER
     ,p_copy_entity_txn_id             NUMBER
     ,p_pgm_id                         NUMBER
     ,p_business_group_id              NUMBER
     ,p_number_of_copies               NUMBER
     ,p_object_version_number          NUMBER
     ,p_effective_date                 DATE
     ,p_no_dup_rslt                    VARCHAR2
      ) IS
 l_proc varchar2(72) := g_package||'.create_program_result';
--
Cursor C_CPP is
 Select
   pln.copy_entity_result_id
 From
   Ben_copy_entity_results cpp,
   Ben_copy_entity_results pln
 Where
   cpp.copy_entity_txn_id = p_copy_entity_txn_id
   And pln.copy_entity_txn_id = cpp.copy_entity_txn_id
   And p_effective_date between cpp.information2 and cpp.information3
   And p_effective_date between pln.information2 and pln.information3
   And cpp.table_alias ='CPP'
   And pln.table_alias ='PLN'
   And cpp.information260 = p_pgm_id
   And pln.status<>'DELETE'
   And cpp.status<>'DELETE'
   And cpp.information261 = pln.information1 ;
/*
Cursor C_CPP is
   Select
   pln.copy_entity_result_id
 From
   Ben_copy_entity_results cpp,
   Ben_copy_entity_results pln
 Where
   cpp.copy_entity_txn_id = 229
   And pln.copy_entity_txn_id = cpp.copy_entity_txn_id
   And sysdate between cpp.information2 and cpp.information3
   And sysdate between pln.information2 and pln.information3
   And cpp.table_alias ='CPP'
   And pln.table_alias ='PLN'
   And cpp.information260 = 310
   And pln.status<>'DELETE'
   And cpp.status<>'DELETE'
   And cpp.information261 = pln.information1 ;  */
--
l_copy_entity_result_id    Number ;
l_object_version_number    Number ;
--

BEGIN
hr_utility.set_location('Entering: '||l_proc,10);
  --
  --dbms_output.put_line('CALLING PGM COPY1');
  -- Call PCP API
  ben_plan_design_program_module.create_program_result (
                                    p_copy_entity_result_id           =>l_copy_entity_result_id
                                    ,p_copy_entity_txn_id             =>p_copy_entity_txn_id
                                    ,p_pgm_id                         =>p_pgm_id
                                    ,p_business_group_id              =>p_business_group_id
                                    ,p_number_of_copies               =>p_number_of_copies
                                    ,p_object_version_number          =>l_object_version_number
                                    ,p_effective_date                 =>p_effective_date
                                    ,p_no_dup_rslt                    =>p_no_dup_rslt
                                  );

-- This is to copy all the PZips and BnftsGrps in BG to staging
 copy_PostalZip_Bnft_Grp(p_copy_entity_txn_id);

 --
 -- Add Call to Extra Mappings here

 -- extra mappings for PGM
 populate_extra_Mapping_PGM(p_copy_entity_txn_id,p_effective_date);

 populate_extra_mappings_CPY
          (
            p_copy_entity_txn_id  => p_copy_entity_txn_id
           ,p_business_group_id   => p_business_group_id
           ,p_effective_date      => p_effective_date
          );

 --dbms_output.put_line('AFTER POPULATE OPGM');

 -- Call Extra Mappings For PLN
 For l_CPP in C_CPP Loop
 --
    populate_extra_Mapping_PLN
            (
                 p_effective_date        => p_effective_date,
                 p_business_group_id     => p_business_group_id,
                 p_copy_entity_txn_id    => p_copy_entity_txn_id,
                 p_copy_entity_result_id => l_CPP.copy_entity_result_id
            );
 --
 End Loop ;

-- Call Extyra Mappings for CTP

populate_extra_Mappings_CTP
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );
-- Call Extyra Mappings for CPP

populate_extra_Mappings_CPP
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );
-- Call Extyra Mappings for COP
populate_extra_Mappings_COP
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );

-- Call Extyra Mappings for CTP
populate_extra_Mappings_LCT
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );
-- Call Extyra Mappings for CPP
populate_extra_Mappings_LPR
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );
-- Call Extyra Mappings for COP
populate_extra_Mappings_LOP
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
  );


 -- Call Extra Mappings For EAP

    populate_extra_mappings_EPA
          (
                  p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date => p_effective_date
          );
 -- Call Extra Mappings for VPF
populate_extra_mappings_VPF
          (
                  p_copy_entity_txn_id => p_copy_entity_txn_id,
                  p_effective_date => p_effective_date
          );

 -- populate the extra mappings required for Criteria
 populate_extra_mappings_elp(
        p_copy_entity_txn_id => p_copy_entity_txn_id
        ,p_effective_date    => p_effective_date
);


 -- Call Extra Mappings for LEN
 populate_extra_Mappings_LEN
      (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
      );

 populate_extra_Mappings_ENP
 (
            p_copy_entity_txn_id => p_copy_entity_txn_id,
            p_effective_date     => p_effective_date,
            p_pgm_id             => p_pgm_id
 );


 -- Dump All elpros in Staging . This will get shown in Criteria Set Hgrid in Cvg, Rates, Imputed Income
 -- we are now dumping elpros only in Criteria Set page where it is required
 -- dumping them here makes the program page very ineffecient
 -- enabling it again after enabling the concurrent process

   dump_elig_prfls(p_copy_entity_txn_id);

 -- mark the future data Exists column
 mark_future_data_exists(p_copy_entity_txn_id);

hr_utility.set_location('Leaving: '||l_proc,20);
 --
 Exception When Others then
   raise ;
 --
 --
END create_program_result;

PROCEDURE mark_future_data_exists(p_copy_entity_txn_id in NUMBER)
AS

l_context pqh_copy_entity_txns.context%type;
 --  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

select context  into l_context
from pqh_copy_entity_txns
where copy_entity_txn_id = p_copy_entity_txn_id ;

-- If it is "GSP" context (Eligibility integration with GSP)
-- donot execute Mark Future Data exists code
-- Deleting duplicate rows and converting result_type_cd
-- from  NO DISPLAY to DISPLAY is undesirable for GSP
-- For now, GSP will mark the column FUTURE_DATA_EXISTS with Y
if ( l_context <> 'GSP')
then
   -- first delete the duplicate rows
   delete from  ben_copy_entity_results
        where rowid in ( select min(rowid)
        from ben_copy_entity_results
        where copy_entity_txn_id = p_copy_entity_txn_id
        and information1 is not null
        group by  table_alias,information1, information2, information3
        having count( table_alias) > 1 );

   --  update the selected one to Y

    update ben_copy_entity_results a
            set future_data_exists ='Y'
            where a.copy_entity_txn_id = p_copy_entity_txn_id
            and a.future_data_exists is null
            and a.information3 < to_date('4712/12/31','YYYY/MM/DD')
            and exists
            ( select 'Y' from ben_copy_entity_results b
              where b.copy_entity_txn_id = a.copy_entity_txn_id
              and b.table_alias = a.table_alias
              and b.information1 = a.information1
              and b.information2 = a.information3+1);
   -- update all others to N

        update ben_copy_entity_results
            set future_data_exists = nvl(future_Data_exists,'N'),
            result_type_cd = 'DISPLAY'
            where copy_entity_txn_id = p_copy_entity_txn_id;
end if;

--   COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    RAISE;
END mark_future_data_exists;
--
--- CALL TO COPY OF THE  FORMULAS
--
PROCEDURE  Create_Formula_FF_Result
		(
                 p_validate IN Number
		,p_copy_entity_result_id       IN  Number
                ,p_copy_entity_txn_id	      IN  Number
                ,p_formula_id		      IN  Number
                ,p_business_group_id	      IN  Number
                ,p_number_of_copies  IN Number
                ,p_object_version_number OUT nocopy Number
                ,p_effective_date             IN  Date)Is
l_proc  varchar2(72) := g_package||'.Create_Formula_FF_Result';
begin
hr_utility.set_location('Entering: '||l_proc,10);
--
--Call plan copy api to copy Formula
--
                ben_plan_design_program_module.create_formula_result
                (
                 p_validate                       =>  p_validate
                ,p_copy_entity_result_id          =>  p_copy_entity_result_id
                ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
                ,p_formula_id                     =>  p_formula_id
                ,p_business_group_id              =>  p_business_group_id
                ,p_number_of_copies               =>  p_number_of_copies
                ,p_object_version_number          =>  p_object_version_number
                ,p_effective_date                 =>  p_effective_date
               ,p_copy_to_clob 	  =>  'y'
                );

 mark_future_data_exists(p_copy_entity_txn_id);
 -- Commit after copying the Fast Formula so that rows donot remain locked
 -- in the transaction
 commit;
 hr_utility.set_location('Leaving: '||l_proc,20);
End Create_Formula_FF_Result;

  FUNCTION get_rule_name(p_copy_entity_txn_id IN Number
		       ,p_id IN Number
		       ,p_table_alias      IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_business_group_id Number;
  l_effective_date Date;
  l_rule_name  ben_copy_entity_results.information170%type;
  BEGIN
get_txn_details (p_copy_entity_txn_id ,l_business_group_id,l_effective_date);
 if (p_id is not null) THEN
  begin
  Select fff.information112 into l_rule_name
  from ben_copy_entity_results fff,
  ben_copy_entity_results ben
  where fff.table_alias='FFF'
  and fff.copy_entity_txn_id=p_copy_entity_txn_id
  and ben.copy_entity_txn_id=p_copy_entity_txn_id
  and fff.information1=decode(p_table_alias,'CTP',ben.INFORMATION277,'CPP',ben.INFORMATION264,'COP',ben.INFORMATION266,'PLN',ben.information272,'LPR1',ben.INFORMATION263,'LOP',ben.INFORMATION264,'LCT',ben.INFORMATION13,'CCM',ben.INFORMATION266)
  and ben.information1=p_id
  and l_effective_date between ben.information2 and ben.information3
  and l_effective_date between fff.information2 and fff.information3;
  Exception when No_Data_Found Then
  RAISE;
end;
end if;
 return l_rule_name;
END get_rule_name;

procedure update_task_list_row(p_copy_entity_txn_id Number,p_effective_date Date)
is
cursor c_pgm is  select information1 pgm_id, information170 name,  information36 Alws_Unrstrctd_Enrt_Flag,information50 pgm_uom
from ben_copy_entity_results
where copy_entity_txn_id = p_copy_entity_txn_id
and table_alias = 'PGM'
and p_effective_date between information2 and information3;

l_pgmrow  c_pgm%rowtype;

begin
      -- update a tasklist row.
    open c_pgm;
      fetch c_pgm into l_pgmrow;
    close c_pgm;
     if(l_pgmrow.pgm_id is not null) then
      update ben_copy_entity_results
       set INFORMATION260 = l_pgmrow.pgm_id  /*SAVED_TASK_PGMID*/
      ,INFORMATION185 = l_pgmrow.name    /* SAVED_PROGRAM_NAME*/
      ,INFORMATION14  = l_pgmrow.Alws_Unrstrctd_Enrt_Flag /* PGM_ALWS_UNRSTRCTD*/
      ,INFORMATION15  = l_pgmrow.pgm_uom   /*PGM_UOM */
      ,INFORMATION100 =  'Y' -- PROGRAM_TASK,
      ,INFORMATION101  = 'Y' --  PLAN_AND_OPTIONS_TASK,
      ,INFORMATION102  = 'Y' --  SCHEDULING_TASK,
      ,INFORMATION103  = 'Y' --  ENROLLMENT_REQUIREMENTS_TASK,
      ,INFORMATION104  = 'Y' --  ELIGIBILITY_PROFILE_TASK,
      ,INFORMATION105  = 'Y' --  DEFAULT_ENROLLMENT_TASK,
      ,INFORMATION106  = 'Y' --  REVIEW_AND_SUBMIT_TASK
       where copy_entity_txn_id = p_copy_entity_txn_id
        and table_alias = 'BEN_PDW_TASK_LIST' ;
     end if;

exception
when others then
  rollback;
  raise;
end update_task_list_row;


PROCEDURE create_program_result
(    p_copy_entity_result_id           NUMBER
     ,p_copy_entity_txn_id             NUMBER
     ,p_pgm_id                         NUMBER
     ,p_business_group_id              NUMBER
     ,p_number_of_copies               NUMBER
     ,p_object_version_number          NUMBER
     ,p_effective_date                 DATE
     ,p_no_dup_rslt                    VARCHAR2
     ,p_copy_mode                IN    VARCHAR2
     ,p_request_id               OUT   NOCOPY NUMBER
 ) IS
 l_proc varchar2(72) := g_package||'.create_program_result';
begin

  if p_copy_mode = 'ONLINE' then
    create_program_result
     (p_copy_entity_result_id => p_copy_entity_result_id
     ,p_copy_entity_txn_id    => p_copy_entity_txn_id
     ,p_pgm_id                => p_pgm_id
     ,p_business_group_id     => p_business_group_id
     ,p_number_of_copies      => p_number_of_copies
     ,p_object_version_number => p_object_version_number
     ,p_effective_date        => p_effective_date
     ,p_no_dup_rslt           => p_no_dup_rslt
     );
   elsif p_copy_mode = 'CONCUR' then
      -- call the concurrent process
       p_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BEPDWSTG'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_copy_entity_result_id
                       ,argument2   => p_copy_entity_txn_id
                       ,argument3   => p_pgm_id
                       ,argument4   => p_business_group_id
                       ,argument5   => p_number_of_copies
                       ,argument6   => p_object_version_number
		       ,argument7   => fnd_date.date_to_canonical(p_effective_date)
		       ,argument8   => p_no_dup_rslt);

          update pqh_copy_entity_txns
	    set status             = 'COPYING_IN_PROGRESS'
            ,start_with            = null
	    where copy_entity_txn_id = p_copy_entity_txn_id;
    end if;
exception
 when others then
  rollback;
  raise;
end create_program_result;

procedure process (
      errbuf                       OUT   NOCOPY      VARCHAR2
     ,retcode                      OUT   NOCOPY      NUMBER
     ,p_copy_entity_result_id      IN    NUMBER      DEFAULT NULL
     ,p_copy_entity_txn_id         IN    NUMBER
     ,p_pgm_id                     IN    NUMBER
     ,p_business_group_id          IN    NUMBER
     ,p_number_of_copies           IN    NUMBER
     ,p_object_version_number      IN    NUMBER      DEFAULT NULL
     ,p_effective_date             IN    VARCHAR2
     ,p_no_dup_rslt                IN    VARCHAR2
   ) is

 begin
      create_program_result
     (p_copy_entity_result_id => p_copy_entity_result_id
     ,p_copy_entity_txn_id    => p_copy_entity_txn_id
     ,p_pgm_id                => p_pgm_id
     ,p_business_group_id     => p_business_group_id
     ,p_number_of_copies      => p_number_of_copies
     ,p_object_version_number => p_object_version_number
     ,p_effective_date        => fnd_date.canonical_to_date(p_effective_date)
     ,p_no_dup_rslt           => p_no_dup_rslt
     );
     -- update the tasklist row
        update_task_list_row(p_copy_entity_txn_id,fnd_date.canonical_to_date(p_effective_date));
     -- update the status of the row.
      update pqh_copy_entity_txns
	    set status               = 'COPIED'  /* To disable View Log Icon */
               ,start_with          = 'BEN_PDW_PLN_OVVW_FUNC' /*enable the continue icon*/
               where copy_entity_txn_id = p_copy_entity_txn_id;

  -- finally commit
      commit;

 exception
  when others then

    rollback;
    --  update the txn row
            update pqh_copy_entity_txns
	    set status               = 'ERROR' /* To disable View Log Icon */
                ,start_with           = null /*disable the continue icon*/
            where copy_entity_txn_id = p_copy_entity_txn_id;
     commit;
     raise;
  end process;

-- this row needs to be created for the proper functioning of Plan Design Wizard.
procedure copy_elig_pzip_bnftgrp( p_copy_entity_txn_id      IN    NUMBER)
is
begin
   dump_elig_prfls(p_copy_entity_txn_id);
   copy_PostalZip_Bnft_Grp(p_copy_entity_txn_id);
   -- mark the future data Exists column
   mark_future_data_exists(p_copy_entity_txn_id);
exception
when others then
  rollback;
  raise;
end;


PROCEDURE copy_elig_pzip_bnft_to_stg
(     p_copy_entity_txn_id       IN     NUMBER
     ,p_copy_mode                IN    VARCHAR2
     ,p_request_id               OUT   NOCOPY NUMBER
 ) IS
 l_proc varchar2(72) := g_package||'.copy_elig_pzip_bnftgrp';

begin

  if p_copy_mode = 'ONLINE' then

    copy_elig_pzip_bnftgrp(p_copy_entity_txn_id);

  elsif p_copy_mode = 'CONCUR' then
      -- call the concurrent process
       p_request_id := fnd_request.submit_request
                       (application => 'BEN'
                       ,program     => 'BEPDWELG'
                       ,description => NULL
                       ,sub_request => FALSE
                       ,argument1   => p_copy_entity_txn_id);
       update pqh_copy_entity_txns
	    set status            = 'COPYING_IN_PROGRESS'
	   ,start_with            = null
	    where copy_entity_txn_id = p_copy_entity_txn_id;
    end if;
exception
 when others then
  rollback;
  raise;
end copy_elig_pzip_bnft_to_stg;


procedure copy_elig_pzip_bnftgrp (
      errbuf                       OUT   NOCOPY      VARCHAR2
     ,retcode                      OUT   NOCOPY      NUMBER
     ,p_copy_entity_txn_id      IN    NUMBER
   ) is

begin
 -- copy all the eligibility profiles, zip code and benefit groups in this process.
    copy_elig_pzip_bnftgrp(p_copy_entity_txn_id);
-- update the status of the row.
     update pqh_copy_entity_txns
       set status               = 'COPIED'  /* To disable View Log Icon */
      ,start_with          = 'BEN_PDW_PLN_OVVW_FUNC' /*show the continue icon*/
       where copy_entity_txn_id = p_copy_entity_txn_id;

commit;
exception
when others then
    rollback;
    --  update the txn row
           update pqh_copy_entity_txns
	    set status               = 'ERROR' /* To disable View Log Icon */
            ,start_with           = null /*disable the continue icon*/
            where copy_entity_txn_id = p_copy_entity_txn_id;
     commit;
     raise;
end copy_elig_pzip_bnftgrp;
END BEN_PDW_COPY_BEN_TO_STG;

/
