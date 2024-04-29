--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_DESIGN_ELPRO_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_DESIGN_ELPRO_MODULE" as
/* $Header: bepdcprf.pkb 120.5 2006/02/28 03:29:19 rgajula noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_plan_design_elpro_module.';

--
-- Bug No: 3451872
--
function get_subj_to_cobra_message
  (
   p_subj_flag in varchar2
  ) return varchar2 is
  l_subj_message fnd_new_messages.message_text%type := null;
begin
  if p_subj_flag = 'Y' then
   l_subj_message := fnd_message.get_string('BEN','BEN_93608_PDC_SUBJ_TO_COBRA');
  end if;
  --
  return l_subj_message;
end get_subj_to_cobra_message;
--

--
-- Bug No: 3451872
--
function get_quald_bnf_message
  (
   p_bnf_flag in varchar2
  ) return varchar2 is
  l_bnf_message fnd_new_messages.message_text%type := null;
begin
  if p_bnf_flag = 'Y' then
   l_bnf_message := fnd_message.get_string('BEN','BEN_93607_PDC_COBRA_BEN');
  end if;
  --
  return l_bnf_message;
end get_quald_bnf_message;
--

--
-- Bug No: 3451872
--
function get_det_enrl_det_dt_name
  (
   p_lookup_code   in  varchar2
  ,p_lookup_type   in  varchar2
  ) return varchar2 is
cursor c_lookup_meaning(c_lookup_code in varchar2,c_lookup_type in varchar2) is
  select hl.meaning
  from   hr_lookups hl
  where  hl.lookup_code = c_lookup_code
  and    hl.lookup_type = c_lookup_type;
l_det_dt_meaning      hr_lookups.meaning%type;
begin
   -- Begin: Fetch Lookup Meaning for determination or enrollment date code
    l_det_dt_meaning := null ;
    open c_lookup_meaning(p_lookup_code,p_lookup_type);
    fetch c_lookup_meaning into l_det_dt_meaning;
    close c_lookup_meaning;
    --
    return l_det_dt_meaning;
end get_det_enrl_det_dt_name;
--
-- Bug 4169120 : Rate By Criteria
---------------------------------------------------------------
-----------------< map_org_pos_hierarchy >---------------------
---------------------------------------------------------------
--
PROCEDURE map_org_pos_hierarchy (
   p_val_type_cd                        IN   VARCHAR2,
   p_number1                            IN   NUMBER,
   p_number2                            IN   NUMBER,
   p_org_stru_name                      OUT  NOCOPY VARCHAR2,
   p_start_org_name                     OUT  NOCOPY VARCHAR2,
   p_pos_stru_name                      OUT  NOCOPY VARCHAR2,
   p_start_pos_name                     OUT  NOCOPY VARCHAR2,
   p_effective_date                     IN   DATE,
   p_business_group_id                  IN   NUMBER
)
IS
  --
   CURSOR c_org_stru_name (
      cv_org_stru_ver_id     NUMBER,
      cv_effective_date      DATE,
      cv_business_group_id   NUMBER
   )
   IS
      SELECT os.NAME
        FROM per_organization_structures_v os,
             per_org_structure_versions osv
       WHERE os.business_group_id = p_business_group_id
         AND os.organization_structure_id = osv.organization_structure_id
         AND osv.org_structure_version_id = cv_org_stru_ver_id
         AND p_effective_date BETWEEN osv.date_from
                                  AND NVL (osv.date_to, p_effective_date);
  --
   CURSOR c_start_org_name (
      cv_start_org_id        NUMBER,
      cv_business_group_id   NUMBER
   )
   IS
      SELECT NAME
        FROM hr_all_organization_units org
       WHERE org.organization_id = cv_start_org_id
         AND business_group_id = p_business_group_id;
  --
   CURSOR c_pos_stru_name (
      cv_pos_stru_ver_id     NUMBER,
      cv_effective_date      DATE,
      cv_business_group_id   NUMBER
   )
   IS
      SELECT ps.NAME
        FROM per_position_structures_v ps, per_pos_structure_versions psv
       WHERE ps.business_group_id = p_business_group_id
         AND ps.position_structure_id = psv.position_structure_id
         AND psv.pos_structure_version_id = cv_pos_stru_ver_id
         AND p_effective_date BETWEEN psv.date_from
                                  AND NVL (psv.date_to, p_effective_date);
  --
   CURSOR c_start_pos_name (
      cv_start_pos_id        NUMBER,
      cv_business_group_id   NUMBER,
      cv_effective_date      DATE
   )
   IS
      SELECT NAME
        FROM hr_all_positions_f_vl pos
       WHERE position_id = cv_start_pos_id
         AND business_group_id = cv_business_group_id
         AND cv_effective_date between pos.effective_start_date
                                   and pos.effective_end_date;
  --
BEGIN
  --
  if p_val_type_cd = 'ORG_HIER'
  then
    --
    open c_org_stru_name ( cv_org_stru_ver_id         => p_number1,
                           cv_effective_date          => p_effective_date,
                           cv_business_group_id       => p_business_group_id);
      --
      fetch c_org_stru_name into p_org_stru_name;
      --
    close c_org_stru_name;
    --
    open c_start_org_name ( cv_start_org_id            => p_number2,
                            cv_business_group_id       => p_business_group_id);
      --
      fetch c_start_org_name into p_start_org_name;
      --
    close c_start_org_name;
    --
  elsif p_val_type_cd = 'POS_HIER'
  then
    --
    open c_pos_stru_name ( cv_pos_stru_ver_id         => p_number1,
                           cv_effective_date          => p_effective_date,
                           cv_business_group_id       => p_business_group_id);
      --
      fetch c_pos_stru_name into p_pos_stru_name;
      --
    close c_pos_stru_name;
    --
    open c_start_pos_name ( cv_start_pos_id            => p_number2,
                            cv_business_group_id       => p_business_group_id,
                            cv_effective_date          => p_effective_date);
      --
      fetch c_start_pos_name into p_start_pos_name;
      --
    close c_start_pos_name;
    --
  end if;
  --
END map_org_pos_hierarchy;
--


--
-- This procedure is used to create a row for each of the comp objects
-- selected by the end user on search page into
-- pqh_copy_entity_txn table.
-- This procedure should also copy all the child table data into
-- above table as well.
--
procedure create_elpro_results
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number    -- Source Elpro
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in number
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_elpro_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_cv_result_type_cd  varchar2(30) := 'DISPLAY' ;
    --
    --

    --
    cursor c_parent_result(c_parent_pk_id number,
                     --   c_parent_table_name varchar2,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe
        -- pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     -- and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.result_type_cd = l_cv_result_type_cd
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     -- and   cpe.table_route_id = trt.table_route_id
     --and   trt.from_clause = 'OAB'
     --and   trt.where_clause = upper(c_parent_table_name) ;
     and   cpe.table_alias = c_parent_table_alias ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --cursor c_table_route(c_parent_table_name varchar2) is
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where --trt.from_clause = 'OAB'
     --and   trt.where_clause = upper(c_parent_table_name) ;
     -- trt.table_alias = c_parent_table_alias ;
     ---
  ---------------------------------------------------------------
  -- START OF BEN_PRTN_ELIG_F ----------------------
  ---------------------------------------------------------------
   cursor c_epa_from_parent(c_pgm_id number,c_ptip_id number,c_plip_id number,
                            c_pl_id number,c_oipl_id number) is
   select distinct prtn_elig_id
   from BEN_PRTN_ELIG_F
   where (c_pgm_id is not null and pgm_id = c_pgm_id ) or
         (c_ptip_id is not null and ptip_id = c_ptip_id ) or
         (c_plip_id is not null and plip_id = c_plip_id ) or
         (c_pl_id is not null and pl_id = c_pl_id ) or
         (c_oipl_id is not null and oipl_id = c_oipl_id ) ;
   --
   cursor c_epa(c_prtn_elig_id number,c_mirror_src_entity_result_id number,
                c_table_alias varchar2 ) is
   select  epa.*
   from BEN_PRTN_ELIG_F epa
   where  epa.prtn_elig_id = c_prtn_elig_id
     -- and epa.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTN_ELIG_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_prtn_elig_id
         -- and information4 = epa.business_group_id
           and information2 = epa.effective_start_date
           and information3 = epa.effective_end_date
        );
     l_prtn_elig_id                 number(15);
     l_out_epa_result_id            number(15);
     ---------------------------------------------------------------
     -- END OF BEN_PRTN_ELIG_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PRTN_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------
   cursor c_cep_from_parent(c_PRTN_ELIG_ID number) is
   select distinct prtn_elig_prfl_id
   from BEN_PRTN_ELIG_PRFL_F
   where  PRTN_ELIG_ID = c_PRTN_ELIG_ID;
   --
   cursor c_cep(c_prtn_elig_prfl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  cep.*
   from BEN_PRTN_ELIG_PRFL_F cep
   where  cep.prtn_elig_prfl_id = c_prtn_elig_prfl_id
     -- and cep.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTN_ELIG_PRFL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_prtn_elig_prfl_id
         -- and information4 = cep.business_group_id
           and information2 = cep.effective_start_date
           and information3 = cep.effective_end_date
        );
    l_prtn_elig_prfl_id                 number(15);
    l_out_cep_result_id   number(15);
    ---------------------------------------------------------------
    -- END OF BEN_PRTN_ELIG_PRFL_F ----------------------
    ---------------------------------------------------------------

   cursor c_elp_from_parent(c_PRTN_ELIG_PRFL_ID number) is
   select  distinct eligy_prfl_id
   from BEN_PRTN_ELIG_PRFL_F
   where  PRTN_ELIG_PRFL_ID = c_PRTN_ELIG_PRFL_ID;

    ---------------------------------------------------------------
    -- START OF BEN_PRTN_ELIGY_RL_F ----------------------
    ---------------------------------------------------------------
   cursor c_cer_from_parent(c_PRTN_ELIG_ID number) is
   select  prtn_eligy_rl_id
   from BEN_PRTN_ELIGY_RL_F
   where  PRTN_ELIG_ID = c_PRTN_ELIG_ID ;
   --
   cursor c_cer(c_prtn_eligy_rl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  cer.*
   from BEN_PRTN_ELIGY_RL_F cer
   where  cer.prtn_eligy_rl_id = c_prtn_eligy_rl_id
     -- and cpe.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe1
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe1.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_PRTN_ELIGY_RL_F'
         and cpe1.table_alias  = c_table_alias
	 and information1 = c_prtn_eligy_rl_id
         -- and information4 = cpe.business_group_id
           and information2 = cer.effective_start_date
           and information3 = cer.effective_end_date
        );
    l_prtn_eligy_rl_id                 number(15);
    l_out_cer_result_id   number(15);
    ---------------------------------------------------------------
    -- END OF BEN_PRTN_ELIGY_RL_F ----------------------
    ---------------------------------------------------------------
    --
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);

     l_mndtry_flag                  ben_prtn_elig_prfl_f.mndtry_flag%type;

     TYPE rt_ref_csr_typ IS REF CURSOR;
     c_parent_rec   rt_ref_csr_typ;
     l_parent_rec   BEN_PRTN_ELIG_F%ROWTYPE;
     l_Sql          Varchar2(2000) := NULL;
     l_Bind_Value   Ben_Pgm_F.Pgm_Id%TYPE := NULL;
     l_parent_prtn_elig_id number;

     --ENH Avoid duplicate ELPRO's
--Bug 5059695
     l_mirror_g_pdw_allow_dup_rslt  varchar2(30);
     l_dummy_g_pdw_allow_dup_rslt varchar2(30);
     l_dummy_parent_entity_rslt_id number(15);
--End Bug 5059695
     --ENH Avoid duplicate ELPRO's

   begin
       --
       l_number_of_copies := p_number_of_copies ;

-- Bug 5059695 : Fetch the transaction category
	if(ben_plan_design_elpro_module.g_copy_entity_txn_id <> p_copy_entity_txn_id) then

	   ben_plan_design_elpro_module.g_copy_entity_txn_id := p_copy_entity_txn_id;

	       open g_trasaction_categories(p_copy_entity_txn_id) ;
		fetch  g_trasaction_categories into ben_plan_design_elpro_module.g_trasaction_category;
	       close g_trasaction_categories;

	end if;
--End Bug 5059695

     ---------------------------------------------------------------
     -- START OF BEN_PRTN_ELIG_F ----------------------
     ---------------------------------------------------------------
     --
     If p_pgm_id is NOT NULL then

        l_Sql := 'select distinct prtn_elig_id from BEN_PRTN_ELIG_F where pgm_id = :pgm_id';

        l_Bind_Value := p_Pgm_id;

     Elsif p_ptip_id is NOT NULL then

        l_sql := 'select distinct prtn_elig_id from BEN_PRTN_ELIG_F where ptip_id = :ptip_id';

        l_Bind_Value := p_ptip_id;

     Elsif p_plip_id is NOT NULL then

        l_sql := 'select distinct prtn_elig_id from BEN_PRTN_ELIG_F where plip_id = :plip_id';

        l_Bind_Value := p_plip_id;

     Elsif p_pl_id is NOT NULL then

        l_sql := 'select distinct prtn_elig_id from BEN_PRTN_ELIG_F where pl_id = :pl_id';

        l_Bind_Value := p_pl_id;

     Elsif P_oipl_id is NOT NULL then

         l_sql := 'select distinct prtn_elig_id from BEN_PRTN_ELIG_F where Oipl_Id = :Oipl_Id';

         l_Bind_Value := P_oipl_id;
     Else

         Return;

     End If;
     hr_utility.set_location('qu 1'||substr(l_sql,1,40),10);
     hr_utility.set_location('qu 2'||substr(l_sql,41,40),10);
     hr_utility.set_location('qu 3'||substr(l_sql,81,40),10);

  /*   for l_parent_rec  in c_epa_from_parent( p_pgm_id,p_ptip_id,p_plip_id,p_pl_id,p_oipl_id ) loop */

      --
	If l_sql is Null Then
	   return;
        end If;

	OPEN c_parent_rec FOR l_sql Using l_Bind_Value;
	-- Fetch c_Parent_rec into l_prtn_elig_id;
	Loop

	Fetch c_Parent_rec into l_prtn_elig_id;

        hr_utility.set_location('data pulled '||l_prtn_elig_id,10);

        If c_Parent_Rec%NOTFOUND Then
           Close c_Parent_Rec;
	   Exit;

	End If;

        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        for l_epa_rec in c_epa(l_prtn_elig_id,l_mirror_src_entity_result_id,'EPA' ) loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('EPA');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := hr_general.decode_lookup('BEN_PRTN_ELIG_STRT',l_epa_rec.prtn_eff_strt_dt_cd)||' '||
                             hr_general.decode_lookup('BEN_PRTN_ELIG_END',l_epa_rec.prtn_eff_end_dt_cd);
                             --'Intersection';
          --
          if p_effective_date between l_epa_rec.effective_start_date and l_epa_rec.effective_end_date then
           --
             l_result_type_cd := 'DISPLAY';
          else
             l_result_type_cd := 'NO DISPLAY';
          end if;
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => null, -- Hide BEN_PRTN_ELIG_F for HGrid
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'EPA',
            p_information1     => l_epa_rec.prtn_elig_id,
            p_information2     => l_epa_rec.EFFECTIVE_START_DATE,
            p_information3     => l_epa_rec.EFFECTIVE_END_DATE,
            p_information4     => l_epa_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
	    p_information18    => l_epa_rec.trk_scr_for_inelg_flag,  -- BugNo 4242438
            p_information111     => l_epa_rec.epa_attribute1,
            p_information120     => l_epa_rec.epa_attribute10,
            p_information121     => l_epa_rec.epa_attribute11,
            p_information122     => l_epa_rec.epa_attribute12,
            p_information123     => l_epa_rec.epa_attribute13,
            p_information124     => l_epa_rec.epa_attribute14,
            p_information125     => l_epa_rec.epa_attribute15,
            p_information126     => l_epa_rec.epa_attribute16,
            p_information127     => l_epa_rec.epa_attribute17,
            p_information128     => l_epa_rec.epa_attribute18,
            p_information129     => l_epa_rec.epa_attribute19,
            p_information112     => l_epa_rec.epa_attribute2,
            p_information130     => l_epa_rec.epa_attribute20,
            p_information131     => l_epa_rec.epa_attribute21,
            p_information132     => l_epa_rec.epa_attribute22,
            p_information133     => l_epa_rec.epa_attribute23,
            p_information134     => l_epa_rec.epa_attribute24,
            p_information135     => l_epa_rec.epa_attribute25,
            p_information136     => l_epa_rec.epa_attribute26,
            p_information137     => l_epa_rec.epa_attribute27,
            p_information138     => l_epa_rec.epa_attribute28,
            p_information139     => l_epa_rec.epa_attribute29,
            p_information113     => l_epa_rec.epa_attribute3,
            p_information140     => l_epa_rec.epa_attribute30,
            p_information114     => l_epa_rec.epa_attribute4,
            p_information115     => l_epa_rec.epa_attribute5,
            p_information116     => l_epa_rec.epa_attribute6,
            p_information117     => l_epa_rec.epa_attribute7,
            p_information118     => l_epa_rec.epa_attribute8,
            p_information119     => l_epa_rec.epa_attribute9,
            p_information110     => l_epa_rec.epa_attribute_category,
            p_information17     => l_epa_rec.mx_poe_apls_cd,
            p_information13     => l_epa_rec.mx_poe_det_dt_cd,
            p_information269     => l_epa_rec.mx_poe_det_dt_rl,
            p_information267     => l_epa_rec.mx_poe_rl,
            p_information11     => l_epa_rec.mx_poe_uom,
            p_information266     => l_epa_rec.mx_poe_val,
            p_information258     => l_epa_rec.oipl_id,
            p_information260     => l_epa_rec.pgm_id,
            p_information261     => l_epa_rec.pl_id,
            p_information256     => l_epa_rec.plip_id,
            p_information16     => l_epa_rec.prtn_eff_end_dt_cd,
            p_information271     => l_epa_rec.prtn_eff_end_dt_rl,
            p_information15     => l_epa_rec.prtn_eff_strt_dt_cd,
            p_information270     => l_epa_rec.prtn_eff_strt_dt_rl,
            p_information259     => l_epa_rec.ptip_id,
            p_information12     => l_epa_rec.wait_perd_dt_to_use_cd,
            p_information264     => l_epa_rec.wait_perd_dt_to_use_rl,
            p_information268     => l_epa_rec.wait_perd_rl,
            p_information14     => l_epa_rec.wait_perd_uom,
            p_information287     => l_epa_rec.wait_perd_val,
            p_information265    => l_epa_rec.object_version_number,
           --

            -- END REPLACE PARAMETER LINES

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_epa_result_id is null then
              l_out_epa_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_epa_result_id := l_copy_entity_result_id ;
            end if;
            --
			if (l_epa_rec.mx_poe_det_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_epa_rec.mx_poe_det_dt_rl
					,p_business_group_id        => l_epa_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			 if (l_epa_rec.mx_poe_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_epa_rec.mx_poe_rl
					,p_business_group_id        => l_epa_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			 if (l_epa_rec.prtn_eff_end_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_epa_rec.prtn_eff_end_dt_rl
					,p_business_group_id        => l_epa_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

			 if (l_epa_rec.prtn_eff_strt_dt_rl is not null) then
			   ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  => l_epa_rec.prtn_eff_strt_dt_rl
					,p_business_group_id        => l_epa_rec.business_group_id
					,p_number_of_copies         =>  l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
			end if;

 			 if (l_epa_rec.wait_perd_dt_to_use_rl is not null) then
 			   ben_plan_design_program_module.create_formula_result(
 					p_validate                       => p_validate
 					,p_copy_entity_result_id  => l_copy_entity_result_id
 					,p_copy_entity_txn_id      => p_copy_entity_txn_id
 					,p_formula_id                  => l_epa_rec.wait_perd_dt_to_use_rl
 					,p_business_group_id        => l_epa_rec.business_group_id
 					,p_number_of_copies         =>  l_number_of_copies
 					,p_object_version_number  => l_object_version_number
 					,p_effective_date             => p_effective_date);
 			end if;

 			 if (l_epa_rec.wait_perd_rl is not null) then
 			   ben_plan_design_program_module.create_formula_result(
 					p_validate                       => p_validate
 					,p_copy_entity_result_id  => l_copy_entity_result_id
 					,p_copy_entity_txn_id      => p_copy_entity_txn_id
 					,p_formula_id                  => l_epa_rec.wait_perd_rl
 					,p_business_group_id        => l_epa_rec.business_group_id
 					,p_number_of_copies         =>  l_number_of_copies
 					,p_object_version_number  => l_object_version_number
 					,p_effective_date             => p_effective_date);
 			end if;

         end loop;
         --
     ---------------------------------------------------------------
     -- START OF BEN_PRTN_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_cep_from_parent(l_PRTN_ELIG_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_epa_result_id ;
        --
        l_prtn_elig_prfl_id := l_parent_rec.prtn_elig_prfl_id ;
        --
        for l_cep_rec in c_cep(l_parent_rec.prtn_elig_prfl_id,l_mirror_src_entity_result_id, 'CEP' ) loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CEP');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := ben_plan_design_program_module.get_eligy_prfl_name(l_cep_rec.eligy_prfl_id
                                                                               ,p_effective_date); --'Intersection';
          --
          if p_effective_date between l_cep_rec.effective_start_date
             and l_cep_rec.effective_end_date then
           --
             l_result_type_cd := 'DISPLAY';
          else
             l_result_type_cd := 'NO DISPLAY';
          end if;
            --
-- Bug 5059695
	    if(ben_plan_design_elpro_module.g_trasaction_category = 'PQHGSP') then
	        l_dummy_parent_entity_rslt_id := null;
	    else
	       l_dummy_parent_entity_rslt_id := p_parent_entity_result_id;
	    end if;
-- End Bug 5059695

          l_copy_entity_result_id := null;
          l_object_version_number := null;
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => l_dummy_parent_entity_rslt_id,  -- 4990825 SHOW BEN_PRTN_ELIG_PRFL_F as child for HGrid
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'CEP',
            p_information1     => l_cep_rec.prtn_elig_prfl_id,
            p_information2     => l_cep_rec.EFFECTIVE_START_DATE,
            p_information3     => l_cep_rec.EFFECTIVE_END_DATE,
            p_information4     => l_cep_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cep_rec.cep_attribute1,
            p_information120     => l_cep_rec.cep_attribute10,
            p_information121     => l_cep_rec.cep_attribute11,
            p_information122     => l_cep_rec.cep_attribute12,
            p_information123     => l_cep_rec.cep_attribute13,
            p_information124     => l_cep_rec.cep_attribute14,
            p_information125     => l_cep_rec.cep_attribute15,
            p_information126     => l_cep_rec.cep_attribute16,
            p_information127     => l_cep_rec.cep_attribute17,
            p_information128     => l_cep_rec.cep_attribute18,
            p_information129     => l_cep_rec.cep_attribute19,
            p_information112     => l_cep_rec.cep_attribute2,
            p_information130     => l_cep_rec.cep_attribute20,
            p_information131     => l_cep_rec.cep_attribute21,
            p_information132     => l_cep_rec.cep_attribute22,
            p_information133     => l_cep_rec.cep_attribute23,
            p_information134     => l_cep_rec.cep_attribute24,
            p_information135     => l_cep_rec.cep_attribute25,
            p_information136     => l_cep_rec.cep_attribute26,
            p_information137     => l_cep_rec.cep_attribute27,
            p_information138     => l_cep_rec.cep_attribute28,
            p_information139     => l_cep_rec.cep_attribute29,
            p_information113     => l_cep_rec.cep_attribute3,
            p_information140     => l_cep_rec.cep_attribute30,
            p_information114     => l_cep_rec.cep_attribute4,
            p_information115     => l_cep_rec.cep_attribute5,
            p_information116     => l_cep_rec.cep_attribute6,
            p_information117     => l_cep_rec.cep_attribute7,
            p_information118     => l_cep_rec.cep_attribute8,
            p_information119     => l_cep_rec.cep_attribute9,
            p_information110     => l_cep_rec.cep_attribute_category,
            p_information11     => l_cep_rec.elig_prfl_type_cd,
            p_information263    => l_cep_rec.eligy_prfl_id,
            p_information12     => l_cep_rec.mndtry_flag,
            p_information229    => l_cep_rec.prtn_elig_id,
	    p_information13     => l_cep_rec.compute_score_flag, -- Bug 4242438
            p_information265    => l_cep_rec.object_version_number,
           --

            -- END REPLACE PARAMETER LINES

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_cep_result_id is null then
              l_out_cep_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_cep_result_id := l_copy_entity_result_id ;
               l_mndtry_flag       := l_cep_rec.mndtry_flag ;
            end if;
            --
         end loop;
         --

	 l_mirror_g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_allow_dup_rslt;
         -- Create Eligibility Profiles and Criteria

 -- Bug 5059695
	    if(ben_plan_design_elpro_module.g_trasaction_category = 'PQHGSP') then
	        l_dummy_g_pdw_allow_dup_rslt := null;
	    else
	       l_dummy_g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
	    end if;
-- End Bug 5059695

         for l_parent_rec  in c_elp_from_parent(l_PRTN_ELIG_PRFL_ID) loop
           create_elig_prfl_results
           (
             p_validate                       => p_validate
            ,p_mirror_src_entity_result_id    => l_out_cep_result_id
            ,p_parent_entity_result_id        => p_parent_entity_result_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_eligy_prfl_id                  => l_parent_rec.eligy_prfl_id
            ,p_mndtry_flag                    => l_mndtry_flag
            ,p_business_group_id              => p_business_group_id
            ,p_number_of_copies               => p_number_of_copies
            ,p_object_version_number          => l_object_version_number
            ,p_effective_date                 => p_effective_date
	    ,p_no_dup_rslt		      => l_dummy_g_pdw_allow_dup_rslt
           );
	   -- ENH Avoid duplicates in Eligibility Profiles
	   --Passed the value PDW_NO_DUP_RSLT to create_elig_prfl_results so that
	   --no duplicate results are created
         end loop;

	 ben_plan_design_program_module.g_pdw_allow_dup_rslt := l_mirror_g_pdw_allow_dup_rslt;
	 -- ENH Avoid duplicates in Eligibility Profiles
	 --reset the global allow dup results to as it was before

       end loop;
     ---------------------------------------------------------------
     -- END OF BEN_PRTN_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------
     ---------------------------------------------------------------
     -- START OF BEN_PRTN_ELIGY_RL_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_cer_from_parent(l_PRTN_ELIG_ID) loop
        --
        l_mirror_src_entity_result_id := l_out_epa_result_id ;
        --
        l_prtn_eligy_rl_id := l_parent_rec.prtn_eligy_rl_id ;
        --
        for l_cer_rec in c_cer(l_parent_rec.prtn_eligy_rl_id,l_mirror_src_entity_result_id,'CER' ) loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('CER');
            fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := ben_plan_design_program_module.get_formula_name(l_cer_rec.formula_id
                                                                            ,p_effective_date); --'Intersection';
          --
          if p_effective_date between l_cer_rec.effective_start_date
             and l_cer_rec.effective_end_date then
           --
             l_result_type_cd := 'DISPLAY';
          else
             l_result_type_cd := 'NO DISPLAY';
          end if;
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => p_parent_entity_result_id, -- Result id of Pgm,Ptip,Plip or Oipl
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'CER',
            p_information1     => l_cer_rec.prtn_eligy_rl_id,
            p_information2     => l_cer_rec.EFFECTIVE_START_DATE,
            p_information3     => l_cer_rec.EFFECTIVE_END_DATE,
            p_information4     => l_cer_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_cer_rec.cer_attribute1,
            p_information120     => l_cer_rec.cer_attribute10,
            p_information121     => l_cer_rec.cer_attribute11,
            p_information122     => l_cer_rec.cer_attribute12,
            p_information123     => l_cer_rec.cer_attribute13,
            p_information124     => l_cer_rec.cer_attribute14,
            p_information125     => l_cer_rec.cer_attribute15,
            p_information126     => l_cer_rec.cer_attribute16,
            p_information127     => l_cer_rec.cer_attribute17,
            p_information128     => l_cer_rec.cer_attribute18,
            p_information129     => l_cer_rec.cer_attribute19,
            p_information112     => l_cer_rec.cer_attribute2,
            p_information130     => l_cer_rec.cer_attribute20,
            p_information131     => l_cer_rec.cer_attribute21,
            p_information132     => l_cer_rec.cer_attribute22,
            p_information133     => l_cer_rec.cer_attribute23,
            p_information134     => l_cer_rec.cer_attribute24,
            p_information135     => l_cer_rec.cer_attribute25,
            p_information136     => l_cer_rec.cer_attribute26,
            p_information137     => l_cer_rec.cer_attribute27,
            p_information138     => l_cer_rec.cer_attribute28,
            p_information139     => l_cer_rec.cer_attribute29,
            p_information113     => l_cer_rec.cer_attribute3,
            p_information140     => l_cer_rec.cer_attribute30,
            p_information114     => l_cer_rec.cer_attribute4,
            p_information115     => l_cer_rec.cer_attribute5,
            p_information116     => l_cer_rec.cer_attribute6,
            p_information117     => l_cer_rec.cer_attribute7,
            p_information118     => l_cer_rec.cer_attribute8,
            p_information119     => l_cer_rec.cer_attribute9,
            p_information110     => l_cer_rec.cer_attribute_category,
            p_information11     => l_cer_rec.drvbl_fctr_apls_flag,
            p_information251     => l_cer_rec.formula_id,
            p_information12     => l_cer_rec.mndtry_flag,
            p_information260     => l_cer_rec.ordr_to_aply_num,
            p_information229     => l_cer_rec.prtn_elig_id,
            p_information265    => l_cer_rec.object_version_number,
           --

            -- END REPLACE PARAMETER LINES

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_cer_result_id is null then
              l_out_cer_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_cer_result_id := l_copy_entity_result_id ;
            end if;
            --
              if (l_cer_rec.formula_id is not null) then
		  ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  =>  l_cer_rec.formula_id
			,p_business_group_id        => l_cer_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
		end if;
		--
         end loop;
         --
         hr_utility.set_location('end of per',10);
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_PRTN_ELIGY_RL_F ----------------------
    ---------------------------------------------------------------
         hr_utility.set_location('end of pe',10);
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_PRTN_ELIG_F ----------------------
    ---------------------------------------------------------------
       hr_utility.set_location('out of routine',10);
   end ;
--
procedure create_dep_elpro_result
  (
   p_validate                       in number     default 0 -- false
  ,p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in number
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_dep_elpro_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_cv_result_type_cd  varchar2(30) := 'DISPLAY' ;
    --
    cursor c_parent_result(c_parent_pk_id number,
                          c_parent_table_alias varchar2,
                          c_copy_entity_txn_id number) is
      select copy_entity_result_id mirror_src_entity_result_id
      from ben_copy_entity_results cpe
          -- pqh_table_route trt
      where cpe.information1= c_parent_pk_id
      and   cpe.result_type_cd = l_cv_result_type_cd
      and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
      -- and   cpe.table_route_id = trt.table_route_id
      and   cpe.table_alias = c_parent_table_alias ;
    ---
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    -- Cursor to get table_route_id
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    --   select table_route_id
    --   from pqh_table_route trt
    --   where -- trt.from_clause = 'OAB'
    --   trt.table_alias = c_parent_table_alias ;
    ---
   ---------------------------------------------------------------
   -- START OF BEN_APLD_DPNT_CVG_ELIG_PRFL_F ----------------------
   ---------------------------------------------------------------
   cursor c_ade_from_parent(c_pgm_id number,c_ptip_id number,c_pl_id number ) is
   select distinct apld_dpnt_cvg_elig_prfl_id
   from BEN_APLD_DPNT_CVG_ELIG_PRFL_F
   where  (c_pgm_id is not null and pgm_id = c_pgm_id ) or
          (c_ptip_id is not null and ptip_id = c_ptip_id) or
          (c_pl_id is not null and pl_id = c_pl_id) ;
   --
   cursor c_ade(c_apld_dpnt_cvg_elig_prfl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ade.*
   from BEN_APLD_DPNT_CVG_ELIG_PRFL_F ade
   where  ade.apld_dpnt_cvg_elig_prfl_id = c_apld_dpnt_cvg_elig_prfl_id
     -- and ade.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_APLD_DPNT_CVG_ELIG_PRFL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_apld_dpnt_cvg_elig_prfl_id
         -- and information4 = ade.business_group_id
           and information2 = ade.effective_start_date
           and information3 = ade.effective_end_date
        );
    l_apld_dpnt_cvg_elig_prfl_id                 number(15);
    l_out_ade_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_APLD_DPNT_CVG_ELIG_PRFL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
   ---------------------------------------------------------------
   cursor c_dce_from_parent(c_APLD_DPNT_CVG_ELIG_PRFL_ID number) is
   select distinct dpnt_cvg_eligy_prfl_id
   from BEN_APLD_DPNT_CVG_ELIG_PRFL_F
   where  APLD_DPNT_CVG_ELIG_PRFL_ID = c_APLD_DPNT_CVG_ELIG_PRFL_ID ;
   --
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
   ---------------------------------------------------------------

     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);

  begin
     l_number_of_copies := p_number_of_copies ;
     ---------------------------------------------------------------
     -- START OF BEN_APLD_DPNT_CVG_ELIG_PRFL_F ----------------------
     ---------------------------------------------------------------
     --
     for l_parent_rec  in c_ade_from_parent(p_pgm_id,p_ptip_id,p_pl_id) loop
        --
        l_mirror_src_entity_result_id := p_copy_entity_result_id ;
        --
        l_apld_dpnt_cvg_elig_prfl_id := l_parent_rec.apld_dpnt_cvg_elig_prfl_id ;
        --
        for l_ade_rec in c_ade(l_parent_rec.apld_dpnt_cvg_elig_prfl_id,l_mirror_src_entity_result_id,'ADE' ) loop
          --
          l_table_route_id := null ;
          open ben_plan_design_program_module.g_table_route('ADE');
          fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
          close ben_plan_design_program_module.g_table_route ;
          --
          l_information5  := ben_plan_design_program_module.get_dpnt_cvg_eligy_prfl_name
                                                            (l_ade_rec.dpnt_cvg_eligy_prfl_id
                                                             ,p_effective_date); --'Intersection';
          --
          if p_effective_date between l_ade_rec.effective_start_date
             and l_ade_rec.effective_end_date then
           --
             l_result_type_cd := 'DISPLAY';
          else
             l_result_type_cd := 'NO DISPLAY';
          end if;
            --
          l_copy_entity_result_id := null;
          l_object_version_number := null;
          ben_copy_entity_results_api.create_copy_entity_results(
            p_copy_entity_result_id          => l_copy_entity_result_id,
            p_copy_entity_txn_id             => p_copy_entity_txn_id,
            p_result_type_cd                 => l_result_type_cd,
            p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
            p_parent_entity_result_id        => null, -- Hide BEN_APLD_DPNT_CVG_ELIG_PRFL_F for HGrid
            p_number_of_copies               => l_number_of_copies,
            p_table_route_id                 => l_table_route_id,
	    P_TABLE_ALIAS                    => 'ADE',
            p_information1     => l_ade_rec.apld_dpnt_cvg_elig_prfl_id,
            p_information2     => l_ade_rec.EFFECTIVE_START_DATE,
            p_information3     => l_ade_rec.EFFECTIVE_END_DATE,
            p_information4     => l_ade_rec.business_group_id,
            p_information5     => l_information5 , -- 9999 put name for h-grid
            p_information111     => l_ade_rec.ade_attribute1,
            p_information120     => l_ade_rec.ade_attribute10,
            p_information121     => l_ade_rec.ade_attribute11,
            p_information122     => l_ade_rec.ade_attribute12,
            p_information123     => l_ade_rec.ade_attribute13,
            p_information124     => l_ade_rec.ade_attribute14,
            p_information125     => l_ade_rec.ade_attribute15,
            p_information126     => l_ade_rec.ade_attribute16,
            p_information127     => l_ade_rec.ade_attribute17,
            p_information128     => l_ade_rec.ade_attribute18,
            p_information129     => l_ade_rec.ade_attribute19,
            p_information112     => l_ade_rec.ade_attribute2,
            p_information130     => l_ade_rec.ade_attribute20,
            p_information131     => l_ade_rec.ade_attribute21,
            p_information132     => l_ade_rec.ade_attribute22,
            p_information133     => l_ade_rec.ade_attribute23,
            p_information134     => l_ade_rec.ade_attribute24,
            p_information135     => l_ade_rec.ade_attribute25,
            p_information136     => l_ade_rec.ade_attribute26,
            p_information137     => l_ade_rec.ade_attribute27,
            p_information138     => l_ade_rec.ade_attribute28,
            p_information139     => l_ade_rec.ade_attribute29,
            p_information113     => l_ade_rec.ade_attribute3,
            p_information140     => l_ade_rec.ade_attribute30,
            p_information114     => l_ade_rec.ade_attribute4,
            p_information115     => l_ade_rec.ade_attribute5,
            p_information116     => l_ade_rec.ade_attribute6,
            p_information117     => l_ade_rec.ade_attribute7,
            p_information118     => l_ade_rec.ade_attribute8,
            p_information119     => l_ade_rec.ade_attribute9,
            p_information110     => l_ade_rec.ade_attribute_category,
            p_information263     => l_ade_rec.apld_dpnt_cvg_elig_rl,
            p_information255     => l_ade_rec.dpnt_cvg_eligy_prfl_id,
            p_information11     => l_ade_rec.mndtry_flag,
            p_information260     => l_ade_rec.pgm_id,
            p_information261     => l_ade_rec.pl_id,
            p_information259     => l_ade_rec.ptip_id,
            p_information265     => l_ade_rec.object_version_number,
           --

            -- END REPLACE PARAMETER LINES

            p_object_version_number          => l_object_version_number,
            p_effective_date                 => p_effective_date       );
            --

            if l_out_ade_result_id is null then
              l_out_ade_result_id := l_copy_entity_result_id;
            end if;

            if l_result_type_cd = 'DISPLAY' then
               l_out_ade_result_id := l_copy_entity_result_id ;
            end if;
            --
              if (l_ade_rec.apld_dpnt_cvg_elig_rl is not null) then
				 ben_plan_design_program_module.create_formula_result(
					p_validate                       => p_validate
					,p_copy_entity_result_id  => l_copy_entity_result_id
					,p_copy_entity_txn_id      => p_copy_entity_txn_id
					,p_formula_id                  =>  l_ade_rec.apld_dpnt_cvg_elig_rl
					,p_business_group_id        =>  l_ade_rec.business_group_id
					,p_number_of_copies         => l_number_of_copies
					,p_object_version_number  => l_object_version_number
					,p_effective_date             => p_effective_date);
				end if;


         end loop;

         -- Create Dependent Eligibility Profiles and Criteria

         for l_parent_rec  in c_dce_from_parent(l_apld_dpnt_cvg_elig_prfl_id) loop
           create_dep_elig_prfl_results
           (
             p_validate                       => p_validate
            ,p_mirror_src_entity_result_id    => l_out_ade_result_id
            ,p_parent_entity_result_id        => p_parent_entity_result_id
            ,p_copy_entity_txn_id             => p_copy_entity_txn_id
            ,p_dpnt_cvg_eligy_prfl_id         => l_parent_rec.dpnt_cvg_eligy_prfl_id
            ,p_business_group_id              => p_business_group_id
            ,p_number_of_copies               => p_number_of_copies
            ,p_object_version_number          => l_object_version_number
            ,p_effective_date                 => p_effective_date
           );
         end loop;
         --
       end loop;
    ---------------------------------------------------------------
    -- END OF BEN_APLD_DPNT_CVG_ELIG_PRFL_F ----------------------
    ---------------------------------------------------------------
     null ;
  end ;

  procedure create_elig_prfl_results
  (
   p_validate                       in  number    default 0 -- false
  ,p_mirror_src_entity_result_id    in  number
  ,p_parent_entity_result_id        in  number
  ,p_copy_entity_txn_id             in  number
  ,p_eligy_prfl_id                  in  number
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2   default null
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_elig_prfl_results';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_cv_result_type_cd  varchar2(30) := 'DISPLAY' ;
    --
    cursor c_parent_result(c_parent_pk_id number,
                     --   c_parent_table_name varchar2,
                        c_parent_table_alias varchar2,
                        c_copy_entity_txn_id number) is
     select copy_entity_result_id mirror_src_entity_result_id
     from ben_copy_entity_results cpe
        -- pqh_table_route trt
     where cpe.information1= c_parent_pk_id
     -- and   cpe.result_type_cd = 'DISPLAY'
     and   cpe.result_type_cd = l_cv_result_type_cd
     and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
     -- and   cpe.table_route_id = trt.table_route_id
     --and   trt.from_clause = 'OAB'
     --and   trt.where_clause = upper(c_parent_table_name) ;
     and   cpe.table_alias = c_parent_table_alias ;
     ---
     -- Bug : 3752407 : Global cursor g_table_route will now be used
     -- Cursor to get table_route_id
     --cursor c_table_route(c_parent_table_name varchar2) is
     -- cursor c_table_route(c_parent_table_alias varchar2) is
     -- select table_route_id
     -- from pqh_table_route trt
     -- where --trt.from_clause = 'OAB'
     --and   trt.where_clause = upper(c_parent_table_name) ;
     -- trt.table_alias = c_parent_table_alias ;
     ---

   ---------------------------------------------------------------
   -- START OF BEN_ELIGY_PRFL_F ----------------------
   ---------------------------------------------------------------

   --
   cursor c_elp(c_eligy_prfl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  elp.*
   from BEN_ELIGY_PRFL_F elp
   where  elp.eligy_prfl_id = c_eligy_prfl_id
     -- and elp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIGY_PRFL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_eligy_prfl_id
         -- and information4 = elp.business_group_id
           and information2 = elp.effective_start_date
           and information3 = elp.effective_end_date
        );
    l_eligy_prfl_id                 number(15);
    l_out_elp_result_id   number(15);
    ---------------------------------------------------------------
    -- END OF BEN_ELIGY_PRFL_F ----------------------
    ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_CNTNG_PRTN_ELIG_PRFL_F ----------------------
   ---------------------------------------------------------------
   cursor c_cgp_from_parent(c_ELIGY_PRFL_ID number) is
   select  cntng_prtn_elig_prfl_id
   from BEN_CNTNG_PRTN_ELIG_PRFL_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_cgp(c_cntng_prtn_elig_prfl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  cgp.*
   from BEN_CNTNG_PRTN_ELIG_PRFL_F cgp
   where  cgp.cntng_prtn_elig_prfl_id = c_cntng_prtn_elig_prfl_id
     -- and cgp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_CNTNG_PRTN_ELIG_PRFL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_cntng_prtn_elig_prfl_id
         -- and information4 = cgp.business_group_id
           and information2 = cgp.effective_start_date
           and information3 = cgp.effective_end_date
        );
    l_cntng_prtn_elig_prfl_id                 number(15);
    l_out_cgp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_CNTNG_PRTN_ELIG_PRFL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIGY_PRFL_RL_F ----------------------
   ---------------------------------------------------------------
   cursor c_erl_from_parent(c_ELIGY_PRFL_ID number) is
   select  eligy_prfl_rl_id
   from BEN_ELIGY_PRFL_RL_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_erl(c_eligy_prfl_rl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  erl.*
   from BEN_ELIGY_PRFL_RL_F erl
   where  erl.eligy_prfl_rl_id = c_eligy_prfl_rl_id
     -- and erl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIGY_PRFL_RL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_eligy_prfl_rl_id
         -- and information4 = erl.business_group_id
           and information2 = erl.effective_start_date
           and information3 = erl.effective_end_date
        );
    l_eligy_prfl_rl_id                 number(15);
    l_out_erl_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIGY_PRFL_RL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_AGE_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eap_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_age_prte_id
   from BEN_ELIG_AGE_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eap(c_elig_age_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eap.*
   from BEN_ELIG_AGE_PRTE_F eap
   where  eap.elig_age_prte_id = c_elig_age_prte_id
     -- and eap.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_AGE_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_age_prte_id
         -- and information4 = eap.business_group_id
           and information2 = eap.effective_start_date
           and information3 = eap.effective_end_date
        );
   l_elig_age_prte_id                 number(15);
   l_out_eap_result_id   number(15);
   --
   cursor c_eap_drp(c_elig_age_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information246 age_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
        -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_AGE_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_age_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_AGE_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ASNT_SET_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ean_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_asnt_set_prte_id
   from BEN_ELIG_ASNT_SET_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ean(c_elig_asnt_set_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ean.*
   from BEN_ELIG_ASNT_SET_PRTE_F ean
   where  ean.elig_asnt_set_prte_id = c_elig_asnt_set_prte_id
     -- and ean.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
       --  and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ASNT_SET_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_asnt_set_prte_id
         -- and information4 = ean.business_group_id
           and information2 = ean.effective_start_date
           and information3 = ean.effective_end_date
        );
    l_elig_asnt_set_prte_id                 number(15);
    l_out_ean_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name(p_id in number) is
      select assignment_set_name
      from hr_assignment_sets
      where business_group_id = p_business_group_id
        and assignment_set_id = p_id;
    --
    l_mapping_id         number;
    l_mapping_name       varchar2(600);
    l_mapping_column_name1 pqh_attributes.attribute_name%type;
    l_mapping_column_name2 pqh_attributes.attribute_name%type;
    l_information172     varchar2(300);
    --
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ASNT_SET_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_BENFTS_GRP_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ebn_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_benfts_grp_prte_id
   from BEN_ELIG_BENFTS_GRP_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ebn(c_elig_benfts_grp_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ebn.*
   from BEN_ELIG_BENFTS_GRP_PRTE_F ebn
   where  ebn.elig_benfts_grp_prte_id = c_elig_benfts_grp_prte_id
     -- and ebn.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
       --  and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_BENFTS_GRP_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_benfts_grp_prte_id
         -- and information4 = ebn.business_group_id
           and information2 = ebn.effective_start_date
           and information3 = ebn.effective_end_date
        );
    l_elig_benfts_grp_prte_id                 number(15);
    l_out_ebn_result_id   number(15);
   --
   cursor c_ebn_bg(c_elig_benfts_grp_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information222 benfts_grp_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
        -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_BENFTS_GRP_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_benfts_grp_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_BENFTS_GRP_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_BRGNG_UNIT_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ebu_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_brgng_unit_prte_id
   from BEN_ELIG_BRGNG_UNIT_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ebu(c_elig_brgng_unit_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ebu.*
   from BEN_ELIG_BRGNG_UNIT_PRTE_F ebu
   where  ebu.elig_brgng_unit_prte_id = c_elig_brgng_unit_prte_id
     -- and ebu.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
        -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_BRGNG_UNIT_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_brgng_unit_prte_id
         -- and information4 = ebu.business_group_id
           and information2 = ebu.effective_start_date
           and information3 = ebu.effective_end_date
        );
    l_elig_brgng_unit_prte_id                 number(15);
    l_out_ebu_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_BRGNG_UNIT_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_CBR_QUALD_BNF_F ----------------------
   ---------------------------------------------------------------
   cursor c_ecq_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_cbr_quald_bnf_id
   from BEN_ELIG_CBR_QUALD_BNF_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ecq(c_elig_cbr_quald_bnf_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ecq.*
   from BEN_ELIG_CBR_QUALD_BNF_F ecq
   where  ecq.elig_cbr_quald_bnf_id = c_elig_cbr_quald_bnf_id
     -- and ecq.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
       --  and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_CBR_QUALD_BNF_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_cbr_quald_bnf_id
         -- and information4 = ecq.business_group_id
           and information2 = ecq.effective_start_date
           and information3 = ecq.effective_end_date
        );
    l_elig_cbr_quald_bnf_id                 number(15);
    l_out_ecq_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_CBR_QUALD_BNF_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_CMBN_AGE_LOS_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ecp_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_cmbn_age_los_prte_id
   from BEN_ELIG_CMBN_AGE_LOS_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ecp(c_elig_cmbn_age_los_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ecp.*
   from BEN_ELIG_CMBN_AGE_LOS_PRTE_F ecp
   where  ecp.elig_cmbn_age_los_prte_id = c_elig_cmbn_age_los_prte_id
     -- and ecp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_cmbn_age_los_prte_id
         -- and information4 = ecp.business_group_id
           and information2 = ecp.effective_start_date
           and information3 = ecp.effective_end_date
        );
   l_elig_cmbn_age_los_prte_id                 number(15);
   l_out_ecp_result_id   number(15);
   --
   cursor c_ecp_drp(c_elig_cmbn_age_los_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information223 cmbn_age_los_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_cmbn_age_los_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_CMBN_AGE_LOS_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_COMP_LVL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ecl_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_comp_lvl_prte_id
   from BEN_ELIG_COMP_LVL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ecl(c_elig_comp_lvl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ecl.*
   from BEN_ELIG_COMP_LVL_PRTE_F ecl
   where  ecl.elig_comp_lvl_prte_id = c_elig_comp_lvl_prte_id
     -- and ecl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_COMP_LVL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_comp_lvl_prte_id
         -- and information4 = ecl.business_group_id
           and information2 = ecl.effective_start_date
           and information3 = ecl.effective_end_date
        );
    l_elig_comp_lvl_prte_id                 number(15);
    l_out_ecl_result_id   number(15);
   --
   cursor c_ecl_drp(c_elig_comp_lvl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information254 comp_lvl_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_COMP_LVL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_comp_lvl_prte_id
         -- and information4 = p_business_group_id
        ;
   --
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_COMP_LVL_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PGM_F ----------------------
   ---------------------------------------------------------------
   cursor c_edg_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dpnt_cvrd_othr_pgm_id
   from BEN_ELIG_DPNT_CVRD_OTHR_PGM_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edg(c_elig_dpnt_cvrd_othr_pgm_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edg.*
   from BEN_ELIG_DPNT_CVRD_OTHR_PGM_F edg
   where  edg.elig_dpnt_cvrd_othr_pgm_id = c_elig_dpnt_cvrd_othr_pgm_id
     -- and edg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DPNT_CVRD_OTHR_PGM_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dpnt_cvrd_othr_pgm_id
         -- and information4 = edg.business_group_id
           and information2 = edg.effective_start_date
           and information3 = edg.effective_end_date
        );
    l_elig_dpnt_cvrd_othr_pgm_id                 number(15);
    l_out_edg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PGM_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PL_F ----------------------
   ---------------------------------------------------------------
   cursor c_edp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dpnt_cvrd_othr_pl_id
   from BEN_ELIG_DPNT_CVRD_OTHR_PL_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edp(c_elig_dpnt_cvrd_othr_pl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edp.*
   from BEN_ELIG_DPNT_CVRD_OTHR_PL_F edp
   where  edp.elig_dpnt_cvrd_othr_pl_id = c_elig_dpnt_cvrd_othr_pl_id
     -- and edp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DPNT_CVRD_OTHR_PL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dpnt_cvrd_othr_pl_id
         -- and information4 = edp.business_group_id
           and information2 = edp.effective_start_date
           and information3 = edp.effective_end_date
        );
    l_elig_dpnt_cvrd_othr_pl_id                 number(15);
    l_out_edp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_edt_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dpnt_cvrd_othr_ptip_id
   from BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edt(c_elig_dpnt_cvrd_othr_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edt.*
   from BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F edt
   where  edt.elig_dpnt_cvrd_othr_ptip_id = c_elig_dpnt_cvrd_othr_ptip_id
     -- and edt.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dpnt_cvrd_othr_ptip_id
         -- and information4 = edt.business_group_id
           and information2 = edt.effective_start_date
           and information3 = edt.effective_end_date
        );
    l_elig_dpnt_cvrd_othr_ptip_id                 number(15);
    l_out_edt_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DPNT_CVRD_PLIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_edi_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dpnt_cvrd_plip_id
   from BEN_ELIG_DPNT_CVRD_PLIP_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edi(c_elig_dpnt_cvrd_plip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edi.*
   from BEN_ELIG_DPNT_CVRD_PLIP_F edi
   where  edi.elig_dpnt_cvrd_plip_id = c_elig_dpnt_cvrd_plip_id
     -- and edi.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DPNT_CVRD_PLIP_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dpnt_cvrd_plip_id
         -- and information4 = edi.business_group_id
           and information2 = edi.effective_start_date
           and information3 = edi.effective_end_date
        );
    l_elig_dpnt_cvrd_plip_id                 number(15);
    l_out_edi_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DPNT_CVRD_PLIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DPNT_OTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_etd_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dpnt_othr_ptip_id
   from BEN_ELIG_DPNT_OTHR_PTIP_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_etd(c_elig_dpnt_othr_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  etd.*
   from BEN_ELIG_DPNT_OTHR_PTIP_F etd
   where  etd.elig_dpnt_othr_ptip_id = c_elig_dpnt_othr_ptip_id
     -- and etd.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DPNT_OTHR_PTIP_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dpnt_othr_ptip_id
         -- and information4 = etd.business_group_id
           and information2 = etd.effective_start_date
           and information3 = etd.effective_end_date
        );
    l_elig_dpnt_othr_ptip_id                 number(15);
    l_out_etd_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DPNT_OTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLD_STAT_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eds_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dsbld_stat_prte_id
   from BEN_ELIG_DSBLD_STAT_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eds(c_elig_dsbld_stat_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eds.*
   from BEN_ELIG_DSBLD_STAT_PRTE_F eds
   where  eds.elig_dsbld_stat_prte_id = c_elig_dsbld_stat_prte_id
     -- and eds.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLD_STAT_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dsbld_stat_prte_id
         -- and information4 = eds.business_group_id
           and information2 = eds.effective_start_date
           and information3 = eds.effective_end_date
        );
    l_elig_dsbld_stat_prte_id                 number(15);
    l_out_eds_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLD_STAT_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_EE_STAT_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ees_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_ee_stat_prte_id
   from BEN_ELIG_EE_STAT_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ees(c_elig_ee_stat_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ees.*
   from BEN_ELIG_EE_STAT_PRTE_F ees
   where  ees.elig_ee_stat_prte_id = c_elig_ee_stat_prte_id
     -- and ees.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_EE_STAT_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_ee_stat_prte_id
         -- and information4 = ees.business_group_id
           and information2 = ees.effective_start_date
           and information3 = ees.effective_end_date
        );
    l_elig_ee_stat_prte_id                 number(15);
    l_out_ees_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name1(p_id in number) is
      select nvl(atl.user_status, stl.user_status) dsp_meaning
      from per_assignment_status_types s,
           per_ass_status_type_amends a ,
           per_business_groups bus ,
           per_assignment_status_types_tl stl ,
           per_ass_status_type_amends_tl atl
      where a.assignment_status_type_id (+) = s.assignment_status_type_id
        and a.business_group_id (+) = p_business_group_id
        and nvl(s.business_group_id, p_business_group_id) = p_business_group_id
        and nvl(s.legislation_code, bus.legislation_code) = bus.legislation_code
        -- and bus.business_group_id = p_business_group_id
        and bus.business_group_id = nvl(s.business_group_id, p_business_group_id)
        and s.assignment_status_type_id = p_id
        and nvl(a.active_flag, s.active_flag) = 'Y'
        and atl.ass_status_type_amend_id (+) = a.ass_status_type_amend_id
        and atl.language (+) = userenv('LANG')
        and stl.assignment_status_type_id = s.assignment_status_type_id
        and stl.language  = userenv('LANG');
    --
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_EE_STAT_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ENRLD_ANTHR_OIPL_F ----------------------
   ---------------------------------------------------------------
   cursor c_eei_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_enrld_anthr_oipl_id
   from BEN_ELIG_ENRLD_ANTHR_OIPL_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eei(c_elig_enrld_anthr_oipl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eei.*
   from BEN_ELIG_ENRLD_ANTHR_OIPL_F eei
   where  eei.elig_enrld_anthr_oipl_id = c_elig_enrld_anthr_oipl_id
     -- and eei.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ENRLD_ANTHR_OIPL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_enrld_anthr_oipl_id
         -- and information4 = eei.business_group_id
           and information2 = eei.effective_start_date
           and information3 = eei.effective_end_date
        );
    l_elig_enrld_anthr_oipl_id                 number(15);
    l_out_eei_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ENRLD_ANTHR_OIPL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ENRLD_ANTHR_PGM_F ----------------------
   ---------------------------------------------------------------
   cursor c_eeg_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_enrld_anthr_pgm_id
   from BEN_ELIG_ENRLD_ANTHR_PGM_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eeg(c_elig_enrld_anthr_pgm_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eeg.*
   from BEN_ELIG_ENRLD_ANTHR_PGM_F eeg
   where  eeg.elig_enrld_anthr_pgm_id = c_elig_enrld_anthr_pgm_id
     -- and eeg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ENRLD_ANTHR_PGM_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_enrld_anthr_pgm_id
         -- and information4 = eeg.business_group_id
           and information2 = eeg.effective_start_date
           and information3 = eeg.effective_end_date
        );
    l_elig_enrld_anthr_pgm_id                 number(15);
    l_out_eeg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ENRLD_ANTHR_PGM_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ENRLD_ANTHR_PLIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_eai_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_enrld_anthr_plip_id
   from BEN_ELIG_ENRLD_ANTHR_PLIP_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eai(c_elig_enrld_anthr_plip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eai.*
   from BEN_ELIG_ENRLD_ANTHR_PLIP_F eai
   where  eai.elig_enrld_anthr_plip_id = c_elig_enrld_anthr_plip_id
     -- and eai.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ENRLD_ANTHR_PLIP_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_enrld_anthr_plip_id
         -- and information4 = eai.business_group_id
           and information2 = eai.effective_start_date
           and information3 = eai.effective_end_date
        );
    l_elig_enrld_anthr_plip_id                 number(15);
    l_out_eai_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ENRLD_ANTHR_PLIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ENRLD_ANTHR_PL_F ----------------------
   ---------------------------------------------------------------
   cursor c_eep_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_enrld_anthr_pl_id
   from BEN_ELIG_ENRLD_ANTHR_PL_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eep(c_elig_enrld_anthr_pl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eep.*
   from BEN_ELIG_ENRLD_ANTHR_PL_F eep
   where  eep.elig_enrld_anthr_pl_id = c_elig_enrld_anthr_pl_id
     -- and eep.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ENRLD_ANTHR_PL_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_enrld_anthr_pl_id
         -- and information4 = eep.business_group_id
           and information2 = eep.effective_start_date
           and information3 = eep.effective_end_date
        );
    l_elig_enrld_anthr_pl_id                 number(15);
    l_out_eep_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ENRLD_ANTHR_PL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ENRLD_ANTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   cursor c_eet_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_enrld_anthr_ptip_id
   from BEN_ELIG_ENRLD_ANTHR_PTIP_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eet(c_elig_enrld_anthr_ptip_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eet.*
   from BEN_ELIG_ENRLD_ANTHR_PTIP_F eet
   where  eet.elig_enrld_anthr_ptip_id = c_elig_enrld_anthr_ptip_id
     -- and eet.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ENRLD_ANTHR_PTIP_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_enrld_anthr_ptip_id
         -- and information4 = eet.business_group_id
           and information2 = eet.effective_start_date
           and information3 = eet.effective_end_date
        );
    l_elig_enrld_anthr_ptip_id                 number(15);
    l_out_eet_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ENRLD_ANTHR_PTIP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_FL_TM_PT_TM_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_efp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_fl_tm_pt_tm_prte_id
   from BEN_ELIG_FL_TM_PT_TM_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_efp(c_elig_fl_tm_pt_tm_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  efp.*
   from BEN_ELIG_FL_TM_PT_TM_PRTE_F efp
   where  efp.elig_fl_tm_pt_tm_prte_id = c_elig_fl_tm_pt_tm_prte_id
     -- and efp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_FL_TM_PT_TM_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_fl_tm_pt_tm_prte_id
         -- and information4 = efp.business_group_id
           and information2 = efp.effective_start_date
           and information3 = efp.effective_end_date
        );
    l_elig_fl_tm_pt_tm_prte_id                 number(15);
    l_out_efp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_FL_TM_PT_TM_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_GRD_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_egr_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_grd_prte_id
   from BEN_ELIG_GRD_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_egr(c_elig_grd_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  egr.*
   from BEN_ELIG_GRD_PRTE_F egr
   where  egr.elig_grd_prte_id = c_elig_grd_prte_id
     -- and egr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_GRD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_grd_prte_id
         -- and information4 = egr.business_group_id
           and information2 = egr.effective_start_date
           and information3 = egr.effective_end_date
        );
    l_elig_grd_prte_id                 number(15);
    l_out_egr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name2(p_id in number,p_date in date) is
      select gra.name dsp_name
      from per_grades_vl gra
      where business_group_id  = p_business_group_id
        and gra.grade_id = p_id
        and p_date between date_from and nvl(date_to, p_date) ;
    --
    cursor c_grade_start_date(c_grade_id number) is
    select date_from
    from per_grades
    where grade_id = c_grade_id;

    l_grade_start_date  per_grades.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_GRD_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_HRLY_SLRD_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ehs_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_hrly_slrd_prte_id
   from BEN_ELIG_HRLY_SLRD_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ehs(c_elig_hrly_slrd_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ehs.*
   from BEN_ELIG_HRLY_SLRD_PRTE_F ehs
   where  ehs.elig_hrly_slrd_prte_id = c_elig_hrly_slrd_prte_id
     -- and ehs.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_HRLY_SLRD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_hrly_slrd_prte_id
         -- and information4 = ehs.business_group_id
           and information2 = ehs.effective_start_date
           and information3 = ehs.effective_end_date
        );
    l_elig_hrly_slrd_prte_id                 number(15);
    l_out_ehs_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_HRLY_SLRD_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_HRS_WKD_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ehw_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_hrs_wkd_prte_id
   from BEN_ELIG_HRS_WKD_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ehw(c_elig_hrs_wkd_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ehw.*
   from BEN_ELIG_HRS_WKD_PRTE_F ehw
   where  ehw.elig_hrs_wkd_prte_id = c_elig_hrs_wkd_prte_id
     -- and ehw.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_HRS_WKD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_hrs_wkd_prte_id
         -- and information4 = ehw.business_group_id
           and information2 = ehw.effective_start_date
           and information3 = ehw.effective_end_date
        );
   l_elig_hrs_wkd_prte_id                 number(15);
   l_out_ehw_result_id   number(15);
   --
   cursor c_ehw_drp(c_elig_hrs_wkd_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information224 hrs_wkd_in_perd_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_HRS_WKD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_hrs_wkd_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_HRS_WKD_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_JOB_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ejp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_job_prte_id
   from BEN_ELIG_JOB_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ejp(c_elig_job_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ejp.*
   from BEN_ELIG_JOB_PRTE_F ejp
   where  ejp.elig_job_prte_id = c_elig_job_prte_id
     -- and ejp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_JOB_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_job_prte_id
         -- and information4 = ejp.business_group_id
           and information2 = ejp.effective_start_date
           and information3 = ejp.effective_end_date
        );
    l_elig_job_prte_id                 number(15);
    l_out_ejp_result_id   number(15);

    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name3(p_id in number,p_date in date) is
      select job.name dsp_name
      from per_jobs_vl job
      where job.business_group_id  = p_business_group_id
        and job.job_id = p_id
        and p_date between date_from and nvl(date_to,p_date);

   cursor c_job_start_date(c_job_id number) is
   select date_from
   from per_jobs
   where job_id = c_job_id;

   l_job_start_date      per_jobs.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_JOB_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_LBR_MMBR_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_elu_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_lbr_mmbr_prte_id
   from BEN_ELIG_LBR_MMBR_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_elu(c_elig_lbr_mmbr_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  elu.*
   from BEN_ELIG_LBR_MMBR_PRTE_F elu
   where  elu.elig_lbr_mmbr_prte_id = c_elig_lbr_mmbr_prte_id
     -- and elu.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_LBR_MMBR_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_lbr_mmbr_prte_id
         -- and information4 = elu.business_group_id
           and information2 = elu.effective_start_date
           and information3 = elu.effective_end_date
        );
    l_elig_lbr_mmbr_prte_id                 number(15);
    l_out_elu_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_LBR_MMBR_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_LGL_ENTY_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eln_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_lgl_enty_prte_id
   from BEN_ELIG_LGL_ENTY_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eln(c_elig_lgl_enty_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eln.*
   from BEN_ELIG_LGL_ENTY_PRTE_F eln
   where  eln.elig_lgl_enty_prte_id = c_elig_lgl_enty_prte_id
     -- and eln.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_LGL_ENTY_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_lgl_enty_prte_id
         -- and information4 = eln.business_group_id
           and information2 = eln.effective_start_date
           and information3 = eln.effective_end_date
        );
    l_elig_lgl_enty_prte_id                 number(15);
    l_out_eln_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name4(p_id in number,p_date in date) is
      select hou.name dsp_name
      from hr_organization_units_v hou ,
           hr_organization_information hoi
      where business_group_id  = p_business_group_id
        and hou.organization_id = p_id
        and p_date between date_from and nvl(date_to, p_date)
        and hou.organization_id = hoi.organization_id
        and hoi.org_information2 = 'Y'
        and hoi.org_information1 = 'HR_LEGAL'
        and hoi.org_information_context || '' ='CLASS' ;

   cursor c_organization_start_date(c_organization_id number) is
   select date_from
   from hr_all_organization_units
   where organization_id = c_organization_id;

   l_organization_start_date  hr_all_organization_units.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_LGL_ENTY_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_LOA_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_elr_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_loa_rsn_prte_id
   from BEN_ELIG_LOA_RSN_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_elr(c_elig_loa_rsn_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  elr.*
   from BEN_ELIG_LOA_RSN_PRTE_F elr
   where  elr.elig_loa_rsn_prte_id = c_elig_loa_rsn_prte_id
     -- and elr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_LOA_RSN_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_loa_rsn_prte_id
         -- and information4 = elr.business_group_id
           and information2 = elr.effective_start_date
           and information3 = elr.effective_end_date
        );
    l_elig_loa_rsn_prte_id                 number(15);
    l_out_elr_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name6(p_id in number,p_id1 in number,p_date in date) is
      select hl.meaning name
      from per_abs_attendance_reasons abr,
           hr_leg_lookups hl
      where abr.business_group_id = p_business_group_id
        and abr.absence_attendance_type_id = p_id
        and abr.abs_attendance_reason_id = p_id1
        and abr.name = hl.lookup_code
        and hl.lookup_type = 'ABSENCE_REASON'
        and hl.enabled_flag = 'Y'
        and p_date between
        nvl(hl.start_date_active, p_date)
        and nvl(hl.end_date_active, p_date);
     --
    cursor c_get_mapping_name5(p_id in number,p_date in date) is
      select abt.name
      from per_absence_attendance_types abt
      where abt.business_group_id = p_business_group_id
        and abt.absence_attendance_type_id  = p_id
        and  p_date between abt.date_effective
        and nvl(abt.date_end, p_date);
     --

     cursor c_absence_type_start_date(c_absence_attendance_type_id number) is
     select date_effective
     from per_absence_attendance_types
     where absence_attendance_type_id = c_absence_attendance_type_id;

     l_absence_type_start_date per_absence_attendance_types.date_effective%type;
     l_mapping_id1        number;
     l_mapping_name1      varchar2(600);
     --l_mapping_column_name1 pqh_attributes.attribute_name%type;
     --l_mapping_column_name2 pqh_attributes.attribute_name%type;
     l_information175     varchar2(600);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_LOA_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_LOS_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_els_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_los_prte_id
   from BEN_ELIG_LOS_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_els(c_elig_los_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  els.*
   from BEN_ELIG_LOS_PRTE_F els
   where  els.elig_los_prte_id = c_elig_los_prte_id
     -- and els.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_LOS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_los_prte_id
         -- and information4 = els.business_group_id
           and information2 = els.effective_start_date
           and information3 = els.effective_end_date
        );
   --
   l_elig_los_prte_id                 number(15);
   l_out_els_result_id   number(15);
   --
   cursor c_els_drp(c_elig_los_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information243 los_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_LOS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_los_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_LOS_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_LVG_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_elv_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_lvg_rsn_prte_id
   from BEN_ELIG_LVG_RSN_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_elv(c_elig_lvg_rsn_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  elv.*
   from BEN_ELIG_LVG_RSN_PRTE_F elv
   where  elv.elig_lvg_rsn_prte_id = c_elig_lvg_rsn_prte_id
     -- and elv.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_LVG_RSN_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_lvg_rsn_prte_id
         -- and information4 = elv.business_group_id
           and information2 = elv.effective_start_date
           and information3 = elv.effective_end_date
        );
    l_elig_lvg_rsn_prte_id                 number(15);
    l_out_elv_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_LVG_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_NO_OTHR_CVG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eno_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_no_othr_cvg_prte_id
   from BEN_ELIG_NO_OTHR_CVG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eno(c_elig_no_othr_cvg_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eno.*
   from BEN_ELIG_NO_OTHR_CVG_PRTE_F eno
   where  eno.elig_no_othr_cvg_prte_id = c_elig_no_othr_cvg_prte_id
     -- and eno.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
      --   and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_NO_OTHR_CVG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_no_othr_cvg_prte_id
         -- and information4 = eno.business_group_id
           and information2 = eno.effective_start_date
           and information3 = eno.effective_end_date
        );
    l_elig_no_othr_cvg_prte_id                 number(15);
    l_out_eno_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_NO_OTHR_CVG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_OPTD_MDCR_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eom_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_optd_mdcr_prte_id
   from BEN_ELIG_OPTD_MDCR_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eom(c_elig_optd_mdcr_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eom.*
   from BEN_ELIG_OPTD_MDCR_PRTE_F eom
   where  eom.elig_optd_mdcr_prte_id = c_elig_optd_mdcr_prte_id
     -- and eom.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_OPTD_MDCR_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_optd_mdcr_prte_id
         -- and information4 = eom.business_group_id
           and information2 = eom.effective_start_date
           and information3 = eom.effective_end_date
        );
    l_elig_optd_mdcr_prte_id                 number(15);
    l_out_eom_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_OPTD_MDCR_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ORG_UNIT_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eou_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_org_unit_prte_id
   from BEN_ELIG_ORG_UNIT_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eou(c_elig_org_unit_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eou.*
   from BEN_ELIG_ORG_UNIT_PRTE_F eou
   where  eou.elig_org_unit_prte_id = c_elig_org_unit_prte_id
     -- and eou.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ORG_UNIT_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_org_unit_prte_id
         -- and information4 = eou.business_group_id
           and information2 = eou.effective_start_date
           and information3 = eou.effective_end_date
        );
    l_elig_org_unit_prte_id                 number(15);
    l_out_eou_result_id   number(15);

    --
    -- pabodla : mapping data - Bug 2716749
    --
    cursor c_get_mapping_name7(p_id in number,p_date in date) is
           select  name
           from hr_all_organization_units_vl
           where business_group_id = business_group_id
             and organization_id = p_id
             and internal_external_flag = 'INT'
             and p_date between nvl(date_from, p_date)
                   and nvl(date_to, p_date)
             order by name;

    --
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ORG_UNIT_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_OTHR_PTIP_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eoy_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_othr_ptip_prte_id
   from BEN_ELIG_OTHR_PTIP_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eoy(c_elig_othr_ptip_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eoy.*
   from BEN_ELIG_OTHR_PTIP_PRTE_F eoy
   where  eoy.elig_othr_ptip_prte_id = c_elig_othr_ptip_prte_id
     -- and eoy.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_OTHR_PTIP_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_othr_ptip_prte_id
         -- and information4 = eoy.business_group_id
           and information2 = eoy.effective_start_date
           and information3 = eoy.effective_end_date
        );
    l_elig_othr_ptip_prte_id                 number(15);
    l_out_eoy_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_OTHR_PTIP_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PCT_FL_TM_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epf_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_pct_fl_tm_prte_id
   from BEN_ELIG_PCT_FL_TM_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epf(c_elig_pct_fl_tm_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epf.*
   from BEN_ELIG_PCT_FL_TM_PRTE_F epf
   where  epf.elig_pct_fl_tm_prte_id = c_elig_pct_fl_tm_prte_id
     -- and epf.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PCT_FL_TM_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pct_fl_tm_prte_id
         -- and information4 = epf.business_group_id
           and information2 = epf.effective_start_date
           and information3 = epf.effective_end_date
        );
    l_elig_pct_fl_tm_prte_id                 number(15);
    l_out_epf_result_id   number(15);
   --
   cursor c_epf_drp(c_elig_pct_fl_tm_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information233 pct_fl_tm_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_PCT_FL_TM_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pct_fl_tm_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PCT_FL_TM_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PER_TYP_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ept_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_per_typ_prte_id
   from BEN_ELIG_PER_TYP_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ept(c_elig_per_typ_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ept.*
   from BEN_ELIG_PER_TYP_PRTE_F ept
   where  ept.elig_per_typ_prte_id = c_elig_per_typ_prte_id
     -- and ept.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PER_TYP_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_per_typ_prte_id
         -- and information4 = ept.business_group_id
           and information2 = ept.effective_start_date
           and information3 = ept.effective_end_date
        );
    l_elig_per_typ_prte_id                 number(15);
    l_out_ept_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_person_type_name(p_person_typ_id in number) is
      select ptl.user_person_type
      from per_person_types ppt,
         hr_leg_lookups hrlkup,
         per_person_types_tl ptl
    where active_flag = 'Y'
      -- and business_group_id = p_business_group_id
      and hrlkup.lookup_type = 'PERSON_TYPE'
      and hrlkup.lookup_code =  ppt.system_person_type
      and ppt.active_flag = 'Y'
      and ppt.person_type_id = p_person_typ_id
      and ppt.person_type_id = ptl.person_type_id
      and ptl.language = userenv('LANG');
    --
    l_mapping_person_type_id   number;
    l_mapping_person_type_name varchar2(600);
    l_information172           varchar2(300);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PER_TYP_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PPL_GRP_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epg_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_ppl_grp_prte_id
   from BEN_ELIG_PPL_GRP_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epg(c_elig_ppl_grp_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epg.*
   from BEN_ELIG_PPL_GRP_PRTE_F epg
   where  epg.elig_ppl_grp_prte_id = c_elig_ppl_grp_prte_id
     -- and epg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PPL_GRP_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_ppl_grp_prte_id
         -- and information4 = epg.business_group_id
           and information2 = epg.effective_start_date
           and information3 = epg.effective_end_date
        );
    l_elig_ppl_grp_prte_id                 number(15);
    l_out_epg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PPL_GRP_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PRTT_ANTHR_PL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_prtt_anthr_pl_prte_id
   from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epp(c_elig_prtt_anthr_pl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epp.*
   from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F epp
   where  epp.elig_prtt_anthr_pl_prte_id = c_elig_prtt_anthr_pl_prte_id
     -- and epp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PRTT_ANTHR_PL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_prtt_anthr_pl_prte_id
         -- and information4 = epp.business_group_id
           and information2 = epp.effective_start_date
           and information3 = epp.effective_end_date
        );
    l_elig_prtt_anthr_pl_prte_id                 number(15);
    l_out_epp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PRTT_ANTHR_PL_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PSTL_CD_R_RNG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epz_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_pstl_cd_r_rng_prte_id
   from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epz(c_elig_pstl_cd_r_rng_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epz.*
   from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F epz
   where  epz.elig_pstl_cd_r_rng_prte_id = c_elig_pstl_cd_r_rng_prte_id
     -- and epz.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PSTL_CD_R_RNG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pstl_cd_r_rng_prte_id
         -- and information4 = epz.business_group_id
           and information2 = epz.effective_start_date
           and information3 = epz.effective_end_date
        );
    l_elig_pstl_cd_r_rng_prte_id                 number(15);
    l_out_epz_result_id   number(15);
   --
   cursor c_epz_pstl(c_elig_pstl_cd_r_rng_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information245 pstl_zip_rng_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_PSTL_CD_R_RNG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pstl_cd_r_rng_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PSTL_CD_R_RNG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PYRL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epy_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_pyrl_prte_id
   from BEN_ELIG_PYRL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epy(c_elig_pyrl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epy.*
   from BEN_ELIG_PYRL_PRTE_F epy
   where  epy.elig_pyrl_prte_id = c_elig_pyrl_prte_id
     -- and epy.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PYRL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pyrl_prte_id
         -- and information4 = epy.business_group_id
           and information2 = epy.effective_start_date
           and information3 = epy.effective_end_date
        );
    l_elig_pyrl_prte_id                 number(15);
    l_out_epy_result_id   number(15);
    --
    cursor c_get_mapping_name9(p_id in number,p_date date) is
      select prl.payroll_name dsp_payroll_name
      from pay_all_payrolls_f prl
      where prl.business_group_id  = p_business_group_id
        and prl.payroll_id = p_id
        and p_date between prl.effective_start_date and prl.effective_end_date ;
    --

    cursor c_payroll_start_date(c_payroll_id number) is
    select min(effective_start_date) effective_start_date
    from pay_all_payrolls_f
    where payroll_id = c_payroll_id;

    l_payroll_start_date pay_all_payrolls_f.effective_start_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PYRL_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PY_BSS_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epb_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_py_bss_prte_id
   from BEN_ELIG_PY_BSS_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epb(c_elig_py_bss_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epb.*
   from BEN_ELIG_PY_BSS_PRTE_F epb
   where  epb.elig_py_bss_prte_id = c_elig_py_bss_prte_id
     -- and epb.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PY_BSS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_py_bss_prte_id
         -- and information4 = epb.business_group_id
           and information2 = epb.effective_start_date
           and information3 = epb.effective_end_date
        );
    l_elig_py_bss_prte_id                 number(15);
    l_out_epb_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name10(p_id in number) is
     select name from per_pay_bases
     where business_group_id = p_business_group_id
       and pay_basis_id = p_id;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PY_BSS_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_SCHEDD_HRS_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_esh_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_schedd_hrs_prte_id
   from BEN_ELIG_SCHEDD_HRS_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_esh(c_elig_schedd_hrs_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  esh.*
   from BEN_ELIG_SCHEDD_HRS_PRTE_F esh
   where  esh.elig_schedd_hrs_prte_id = c_elig_schedd_hrs_prte_id
     -- and esh.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_SCHEDD_HRS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_schedd_hrs_prte_id
         -- and information4 = esh.business_group_id
           and information2 = esh.effective_start_date
           and information3 = esh.effective_end_date
        );
    l_elig_schedd_hrs_prte_id                 number(15);
    l_out_esh_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_SCHEDD_HRS_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_SVC_AREA_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_esa_from_parent(c_ELIGY_PRFL_ID number) is
   select distinct elig_svc_area_prte_id
   from BEN_ELIG_SVC_AREA_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_esa(c_elig_svc_area_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  esa.*
   from BEN_ELIG_SVC_AREA_PRTE_F esa
   where  esa.elig_svc_area_prte_id = c_elig_svc_area_prte_id
     -- and esa.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_SVC_AREA_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_svc_area_prte_id
         -- and information4 = esa.business_group_id
           and information2 = esa.effective_start_date
           and information3 = esa.effective_end_date
        );
    l_elig_svc_area_prte_id                 number(15);
    l_out_esa_result_id   number(15);
   --
   cursor c_esa_svc(c_elig_svc_area_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information241 svc_area_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_SVC_AREA_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_svc_area_prte_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_SVC_AREA_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_WK_LOC_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ewl_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_wk_loc_prte_id
   from BEN_ELIG_WK_LOC_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ewl(c_elig_wk_loc_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ewl.*
   from BEN_ELIG_WK_LOC_PRTE_F ewl
   where  ewl.elig_wk_loc_prte_id = c_elig_wk_loc_prte_id
     -- and ewl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_WK_LOC_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_wk_loc_prte_id
         -- and information4 = ewl.business_group_id
           and information2 = ewl.effective_start_date
           and information3 = ewl.effective_end_date
        );
    l_elig_wk_loc_prte_id                 number(15);
    l_out_ewl_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name15(p_id in number,p_date date) is
      select loc.location_code dsp_location_code
      from hr_locations loc
      where loc.location_id = p_id
        and p_date <= nvl( loc.inactive_date, p_date);

    cursor c_location_inactive_date(c_location_id number) is
    select inactive_date
    from hr_locations
    where location_id = c_location_id;

    l_location_inactive_date hr_locations.inactive_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_WK_LOC_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_SP_CLNG_PRG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_esp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_sp_clng_prg_prte_id
   from BEN_ELIG_SP_CLNG_PRG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_esp(c_elig_sp_clng_prg_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  esp.*
   from BEN_ELIG_SP_CLNG_PRG_PRTE_F esp
   where  esp.elig_sp_clng_prg_prte_id = c_elig_sp_clng_prg_prte_id
     -- and esp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_SP_CLNG_PRG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_sp_clng_prg_prte_id
         -- and information4 = esp.business_group_id
           and information2 = esp.effective_start_date
           and information3 = esp.effective_end_date
        );
    l_elig_sp_clng_prg_prte_id                 number(15);
    l_out_esp_result_id   number(15);
    --
    -- pabodla : mapping data
    -- 9999 resolve the sql
    cursor c_get_mapping_name12(p_id in number,p_date in date) is
      select a.name grade
       , d.step_id
      from per_grades_vl a,
           per_parent_spines b,
           per_spinal_points c,
           per_spinal_point_steps_f d,
           per_grade_spines e
      where d.spinal_point_id = c.spinal_point_id
        and   d.grade_spine_id  = e.grade_spine_id
        and   e.grade_id  = a.grade_id
        and   e.parent_spine_id  = b.parent_spine_id
        and p_date between
            nvl(d.effective_start_date,p_date)
            and nvl(d.effective_end_date,p_date);
    --

    cursor c_step_start_date(c_step_id number) is
    select min(effective_start_date) effective_start_date
    from per_spinal_point_steps_f
    where step_id = c_step_id;

    l_step_start_date per_spinal_point_steps_f.effective_start_date%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_SP_CLNG_PRG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PSTN_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eps_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_pstn_prte_id
   from BEN_ELIG_PSTN_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eps(c_elig_pstn_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eps.*
   from BEN_ELIG_PSTN_PRTE_F eps
   where  eps.elig_pstn_prte_id = c_elig_pstn_prte_id
     -- and eps.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PSTN_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_pstn_prte_id
         -- and information4 = eps.business_group_id
           and information2 = eps.effective_start_date
           and information3 = eps.effective_end_date
        );
    l_elig_pstn_prte_id                 number(15);
    l_out_eps_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name8(p_id in number) is
       select name
       from per_positions
       where business_group_id = p_business_group_id
         and position_id = p_id;

    cursor c_position_start_date(c_position_id number) is
     select date_effective
     from per_positions
     where position_id = c_position_id;

    l_position_start_date per_positions.date_effective%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PSTN_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PRBTN_PERD_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_epn_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_prbtn_perd_prte_id
   from BEN_ELIG_PRBTN_PERD_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_epn(c_elig_prbtn_perd_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epn.*
   from BEN_ELIG_PRBTN_PERD_PRTE_F epn
   where  epn.elig_prbtn_perd_prte_id = c_elig_prbtn_perd_prte_id
     -- and epn.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PRBTN_PERD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_prbtn_perd_prte_id
         -- and information4 = epn.business_group_id
           and information2 = epn.effective_start_date
           and information3 = epn.effective_end_date
        );
    l_elig_prbtn_perd_prte_id                 number(15);
    l_out_epn_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PRBTN_PERD_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_MRTL_STS_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_emp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_mrtl_sts_prte_id
   from BEN_ELIG_MRTL_STS_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_emp(c_elig_mrtl_sts_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  emp.*
   from BEN_ELIG_MRTL_STS_PRTE_F emp
   where  emp.elig_mrtl_sts_prte_id = c_elig_mrtl_sts_prte_id
     -- and emp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_MRTL_STS_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_mrtl_sts_prte_id
         -- and information4 = emp.business_group_id
           and information2 = emp.effective_start_date
           and information3 = emp.effective_end_date
        );
    l_elig_mrtl_sts_prte_id                 number(15);
    l_out_emp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_MRTL_STS_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_GNDR_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_egn_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_gndr_prte_id
   from BEN_ELIG_GNDR_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_egn(c_elig_gndr_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  egn.*
   from BEN_ELIG_GNDR_PRTE_F egn
   where  egn.elig_gndr_prte_id = c_elig_gndr_prte_id
     -- and egn.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_GNDR_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_gndr_prte_id
         -- and information4 = egn.business_group_id
           and information2 = egn.effective_start_date
           and information3 = egn.effective_end_date
        );
    l_elig_gndr_prte_id                 number(15);
    l_out_egn_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_GNDR_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLTY_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_edr_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dsblty_rsn_prte_id
   from BEN_ELIG_DSBLTY_RSN_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edr(c_elig_dsblty_rsn_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edr.*
   from BEN_ELIG_DSBLTY_RSN_PRTE_F edr
   where  edr.elig_dsblty_rsn_prte_id = c_elig_dsblty_rsn_prte_id
     -- and edr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLTY_RSN_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dsblty_rsn_prte_id
         -- and information4 = edr.business_group_id
           and information2 = edr.effective_start_date
           and information3 = edr.effective_end_date
        );
    l_elig_dsblty_rsn_prte_id                 number(15);
    l_out_edr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLTY_RSN_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLTY_DGR_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_edd_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dsblty_dgr_prte_id
   from BEN_ELIG_DSBLTY_DGR_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edd(c_elig_dsblty_dgr_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edd.*
   from BEN_ELIG_DSBLTY_DGR_PRTE_F edd
   where  edd.elig_dsblty_dgr_prte_id = c_elig_dsblty_dgr_prte_id
     -- and edd.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLTY_DGR_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dsblty_dgr_prte_id
         -- and information4 = edd.business_group_id
           and information2 = edd.effective_start_date
           and information3 = edd.effective_end_date
        );
    l_elig_dsblty_dgr_prte_id                 number(15);
    l_out_edd_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLTY_DGR_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_QUAL_TITL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eqt_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_qual_titl_prte_id
   from BEN_ELIG_QUAL_TITL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eqt(c_elig_qual_titl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eqt.*
   from BEN_ELIG_QUAL_TITL_PRTE_F eqt
   where  eqt.elig_qual_titl_prte_id = c_elig_qual_titl_prte_id
     -- and eqt.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_QUAL_TITL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_qual_titl_prte_id
         -- and information4 = eqt.business_group_id
           and information2 = eqt.effective_start_date
           and information3 = eqt.effective_end_date
        );
    l_elig_qual_titl_prte_id                 number(15);
    l_out_eqt_result_id   number(15);
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name11(p_id in number) is
      select name
      from per_qualification_types_vl
      where qualification_type_id  = p_id;

   ---------------------------------------------------------------
   -- END OF BEN_ELIG_QUAL_TITL_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_SUPPL_ROLE_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_est_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_suppl_role_prte_id
   from BEN_ELIG_SUPPL_ROLE_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_est(c_elig_suppl_role_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  est.*
   from BEN_ELIG_SUPPL_ROLE_PRTE_F est
   where  est.elig_suppl_role_prte_id = c_elig_suppl_role_prte_id
     -- and est.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_SUPPL_ROLE_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_suppl_role_prte_id
         -- and information4 = est.business_group_id
           and information2 = est.effective_start_date
           and information3 = est.effective_end_date
        );
    l_elig_suppl_role_prte_id                 number(15);
    l_out_est_result_id   number(15);
    --
    --
    -- pabodla : mapping data
    --
    cursor c_get_mapping_name13(p_id in number) is
      select displayed_name
      from per_job_groups
      where business_group_id = p_business_group_id
        and job_group_id = p_id;

    --
    cursor c_get_mapping_name14(p_id in number, p_id1 in number) is
      select name
      from per_jobs_vl
      where business_group_id = p_business_group_id
        and job_id = p_id
        and job_group_id = p_id1;

   ---------------------------------------------------------------
   -- END OF BEN_ELIG_SUPPL_ROLE_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLTY_CTG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ect_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dsblty_ctg_prte_id
   from BEN_ELIG_DSBLTY_CTG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ect(c_elig_dsblty_ctg_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ect.*
   from BEN_ELIG_DSBLTY_CTG_PRTE_F ect
   where  ect.elig_dsblty_ctg_prte_id = c_elig_dsblty_ctg_prte_id
     -- and ect.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLTY_CTG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dsblty_ctg_prte_id
         -- and information4 = ect.business_group_id
           and information2 = ect.effective_start_date
           and information3 = ect.effective_end_date
        );
    l_elig_dsblty_ctg_prte_id                 number(15);
    l_out_ect_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLTY_CTG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_COMPTNCY_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ecy_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_comptncy_prte_id
   from BEN_ELIG_COMPTNCY_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ecy(c_elig_comptncy_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ecy.*
   from BEN_ELIG_COMPTNCY_PRTE_F ecy
   where  ecy.elig_comptncy_prte_id = c_elig_comptncy_prte_id
     -- and ecy.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_COMPTNCY_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_comptncy_prte_id
         -- and information4 = ecy.business_group_id
           and information2 = ecy.effective_start_date
           and information3 = ecy.effective_end_date
        );
    l_elig_comptncy_prte_id                 number(15);
    l_out_ecy_result_id   number(15);
    --
    cursor c_get_mapping_name16(p_COMPETENCE_ID number,p_date date) is
    select name
      from per_competences_vl
     where competence_id = p_competence_id
       and p_date
           between  Date_from  and nvl(Date_to,  p_date);
    --
    cursor c_get_mapping_name17(p_rating_level_id number,
                                p_business_group_id number
                               ) is
     select rtl.name name
     from per_rating_levels_vl rtl
     where nvl(rtl.business_group_id, p_business_group_id) = p_business_group_id
     and   rtl.rating_level_id = p_rating_level_id;
    --
    cursor c_competence_start_date(c_competence_id number) is
    select date_from
    from per_competences
    where competence_id = c_competence_id;

    l_competence_start_date  per_competences.date_from%type;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_COMPTNCY_PRTE_F ----------------------
   ---------------------------------------------------------------

   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PERF_RTNG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_erg_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_perf_rtng_prte_id
   from BEN_ELIG_PERF_RTNG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_erg(c_elig_perf_rtng_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  erg.*
   from BEN_ELIG_PERF_RTNG_PRTE_F erg
   where  erg.elig_perf_rtng_prte_id = c_elig_perf_rtng_prte_id
     -- and erg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PERF_RTNG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_perf_rtng_prte_id
         -- and information4 = erg.business_group_id
           and information2 = erg.effective_start_date
           and information3 = erg.effective_end_date
        );
    l_elig_perf_rtng_prte_id                 number(15);
    l_out_erg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PERF_RTNG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_QUA_IN_GR_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eqg_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_qua_in_gr_prte_id
   from BEN_ELIG_QUA_IN_GR_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eqg(c_elig_qua_in_gr_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eqg.*
   from BEN_ELIG_QUA_IN_GR_PRTE_F eqg
   where  eqg.elig_qua_in_gr_prte_id = c_elig_qua_in_gr_prte_id
     -- and eqg.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_QUA_IN_GR_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_qua_in_gr_prte_id
         -- and information4 = eqg.business_group_id
           and information2 = eqg.effective_start_date
           and information3 = eqg.effective_end_date
        );
    l_elig_qua_in_gr_prte_id                 number(15);
    l_out_eqg_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_QUA_IN_GR_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TBCO_USE_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_etu_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_tbco_use_prte_id
   from BEN_ELIG_TBCO_USE_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_etu(c_elig_tbco_use_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  etu.*
   from BEN_ELIG_TBCO_USE_PRTE_F etu
   where  etu.elig_tbco_use_prte_id = c_elig_tbco_use_prte_id
     -- and etu.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_TBCO_USE_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_tbco_use_prte_id
         -- and information4 = etu.business_group_id
           and information2 = etu.effective_start_date
           and information3 = etu.effective_end_date
        );
    l_elig_tbco_use_prte_id                 number(15);
    l_out_etu_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TBCO_USE_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TTL_CVG_VOL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_etc_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_ttl_cvg_vol_prte_id
   from BEN_ELIG_TTL_CVG_VOL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_etc(c_elig_ttl_cvg_vol_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  etc.*
   from BEN_ELIG_TTL_CVG_VOL_PRTE_F etc
   where  etc.elig_ttl_cvg_vol_prte_id = c_elig_ttl_cvg_vol_prte_id
     -- and etc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_TTL_CVG_VOL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_ttl_cvg_vol_prte_id
         -- and information4 = etc.business_group_id
           and information2 = etc.effective_start_date
           and information3 = etc.effective_end_date
        );
    l_elig_ttl_cvg_vol_prte_id                 number(15);
    l_out_etc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TTL_CVG_VOL_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_TTL_PRTT_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_etp_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_ttl_prtt_prte_id
   from BEN_ELIG_TTL_PRTT_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_etp(c_elig_ttl_prtt_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  etp.*
   from BEN_ELIG_TTL_PRTT_PRTE_F etp
   where  etp.elig_ttl_prtt_prte_id = c_elig_ttl_prtt_prte_id
     -- and etp.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_TTL_PRTT_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_ttl_prtt_prte_id
         -- and information4 = etp.business_group_id
           and information2 = etp.effective_start_date
           and information3 = etp.effective_end_date
        );
    l_elig_ttl_prtt_prte_id                 number(15);
    l_out_etp_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_TTL_PRTT_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLD_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_edb_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_dsbld_prte_id
   from BEN_ELIG_DSBLD_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_edb(c_elig_dsbld_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edb.*
   from BEN_ELIG_DSBLD_PRTE_F edb
   where  edb.elig_dsbld_prte_id = c_elig_dsbld_prte_id
     -- and edb.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLD_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_dsbld_prte_id
         -- and information4 = edb.business_group_id
           and information2 = edb.effective_start_date
           and information3 = edb.effective_end_date
        );
    l_elig_dsbld_prte_id                 number(15);
    l_out_edb_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLD_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_HLTH_CVG_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_ehc_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_hlth_cvg_prte_id
   from BEN_ELIG_HLTH_CVG_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_ehc(c_elig_hlth_cvg_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ehc.*
   from BEN_ELIG_HLTH_CVG_PRTE_F ehc
   where  ehc.elig_hlth_cvg_prte_id = c_elig_hlth_cvg_prte_id
     -- and ehc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_HLTH_CVG_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_hlth_cvg_prte_id
         -- and information4 = ehc.business_group_id
           and information2 = ehc.effective_start_date
           and information3 = ehc.effective_end_date
        );
    l_elig_hlth_cvg_prte_id                 number(15);
    l_out_ehc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_HLTH_CVG_PRTE_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_ANTHR_PL_PRTE_F ----------------------
   ---------------------------------------------------------------
   cursor c_eop_from_parent(c_ELIGY_PRFL_ID number) is
   select  elig_anthr_pl_prte_id
   from BEN_ELIG_ANTHR_PL_PRTE_F
   where  ELIGY_PRFL_ID = c_ELIGY_PRFL_ID ;
   --
   cursor c_eop(c_elig_anthr_pl_prte_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eop.*
   from BEN_ELIG_ANTHR_PL_PRTE_F eop
   where  eop.elig_anthr_pl_prte_id = c_elig_anthr_pl_prte_id
     -- and eop.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_ANTHR_PL_PRTE_F'
         and cpe.table_alias  = c_table_alias
         and information1 = c_elig_anthr_pl_prte_id
         -- and information4 = eop.business_group_id
           and information2 = eop.effective_start_date
           and information3 = eop.effective_end_date
        );
    l_elig_anthr_pl_prte_id                 number(15);
    l_out_eop_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_ANTHR_PL_PRTE_F ----------------------
   ---------------------------------------------------------------

   ---------------------------------------------------------------
   ------------- START OF BEN_ELIGY_CRIT_VALUES_F ----------------
   ---------------------------------------------------------------
   CURSOR c_ecv_from_parent (cv_eligy_prfl_id NUMBER)
   IS
      SELECT eligy_crit_values_id
        FROM ben_eligy_crit_values_f
       WHERE eligy_prfl_id = cv_eligy_prfl_id;
   --
   CURSOR c_ecv (
      cv_eligy_crit_values_id          NUMBER,
      cv_mirror_src_entity_result_id   NUMBER,
      cv_table_alias                   VARCHAR2
   )
   IS
      SELECT ecv.*
        FROM ben_eligy_crit_values_f ecv
       WHERE ecv.eligy_crit_values_id = cv_eligy_crit_values_id
         AND NOT EXISTS (
                SELECT NULL
                  FROM ben_copy_entity_results cpe
                 WHERE copy_entity_txn_id = p_copy_entity_txn_id
                   AND mirror_src_entity_result_id =
                                                cv_mirror_src_entity_result_id
                   AND cpe.table_alias = cv_table_alias
                   AND information1 = cv_eligy_crit_values_id
                   AND information2 = ecv.effective_start_date
                   AND information3 = ecv.effective_end_date);
   --
   CURSOR c_egl_val_type_cd (cv_eligy_criteria_id NUMBER)
   IS
      SELECT crit_col1_val_type_cd
        FROM ben_eligy_criteria egl
       WHERE eligy_criteria_id = cv_eligy_criteria_id;
   --
   l_eligy_crit_values_id               number(15);
   l_out_ecv_result_id                  number(15);
   l_crit_col1_val_type_cd              varchar2(30);
   l_org_stru_name                      varchar2(30);
   l_start_org_name                     varchar2(240);
   l_pos_stru_name                      varchar2(30);
   l_start_pos_name                     varchar2(240);
   l_eligy_criteria_id                  NUMBER (15);
   --
   ---------------------------------------------------------------
   -------------- END OF BEN_ELIGY_CRIT_VALUES_F -----------------
   ---------------------------------------------------------------
/*
Bug : 4347039. Moved the code to copy BEN_ELIGY_CRITERIA data
into the procedure create_eligy_criteria_result
   ---------------------------------------------------------------
   --------------- START OF BEN_ELIGY_CRITERIA -------------------
   ---------------------------------------------------------------
   CURSOR c_egl (
      cv_eligy_criteria_id             NUMBER,
      cv_mirror_src_entity_result_id   NUMBER,
      cv_table_alias                   VARCHAR2
   )
   IS
      SELECT egl.*
        FROM ben_eligy_criteria egl
       WHERE egl.eligy_criteria_id = cv_eligy_criteria_id
         AND NOT EXISTS (
                SELECT NULL
                  FROM ben_copy_entity_results cpe
                 WHERE copy_entity_txn_id = p_copy_entity_txn_id
                   AND mirror_src_entity_result_id =
                                                cv_mirror_src_entity_result_id
                   AND cpe.table_alias = cv_table_alias
                   AND information1 = cv_eligy_criteria_id);

   --
   CURSOR c_value_set_name (cv_flex_value_set_id NUMBER)
   IS
      SELECT flex_value_set_name
        FROM fnd_flex_value_sets
       WHERE flex_value_set_id = cv_flex_value_set_id;
   --
   l_out_egl_result_id         NUMBER (15);
   l_egl_table_route_id        NUMBER (15);
   l_egl_result_type_cd        VARCHAR2 (30);

   l_egl_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
   l_egl_object_version_number ben_copy_entity_results.object_version_number%TYPE;
   l_flex_value_set_name       fnd_flex_value_sets.flex_value_set_name%TYPE;
   --
   ---------------------------------------------------------------
   ------------------ END OF BEN_ELIGY_CRITERIA ------------------
   ---------------------------------------------------------------
*/
     cursor c_object_exists(c_pk_id                number,
                            c_table_alias          varchar2) is
     select null
     from ben_copy_entity_results cpe
         -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and cpe.table_alias = c_table_alias
     and information1 = c_pk_id;

     l_dummy                        varchar2(1);

     --Bug 5059695
     l_dummy_parent_entity_rslt_id number(15);
     l_dummy_table_alias varchar2(30);
--End Bug 5059695

     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
  begin

    ---------------------------------------------------------------
    -- START OF BEN_ELIGY_PRFL_F ----------------------
    ---------------------------------------------------------------

    -- Bug 5059695 : Fetch the transaction category
	if(ben_plan_design_elpro_module.g_copy_entity_txn_id <> p_copy_entity_txn_id) then

	   ben_plan_design_elpro_module.g_copy_entity_txn_id := p_copy_entity_txn_id;

	       open g_trasaction_categories(p_copy_entity_txn_id) ;
		fetch  g_trasaction_categories into ben_plan_design_elpro_module.g_trasaction_category;
	       close g_trasaction_categories;

	end if;
--End Bug 5059695

      if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
        ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
      end if;

      if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
        open c_object_exists(p_eligy_prfl_id,'ELP');
        fetch c_object_exists into l_dummy;
        if c_object_exists%found then
          close c_object_exists;
          return;
        end if;
        close c_object_exists;
      end if;

      l_number_of_copies := p_number_of_copies;
      l_mirror_src_entity_result_id := p_mirror_src_entity_result_id ;

      --
      l_eligy_prfl_id := p_eligy_prfl_id ;
      --
      for l_elp_rec in c_elp(p_eligy_prfl_id,l_mirror_src_entity_result_id,'ELP' ) loop
      --
        l_table_route_id := null ;
        open ben_plan_design_program_module.g_table_route('ELP');
        fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
        close ben_plan_design_program_module.g_table_route ;
        --
        l_information5  := l_elp_rec.name; --'Intersection';
        --
        -- Display the text (Required) if mndtry_flag = 'Y'
        --
        if p_mndtry_flag = 'Y' then
          l_information5 := l_information5
                                   || fnd_message.get_string('BEN','BEN_93295_PDC_MNDTRY_FLAG');
        end if;
        --
        if p_effective_date between l_elp_rec.effective_start_date
           and l_elp_rec.effective_end_date then
          --
          l_result_type_cd := 'DISPLAY';
         else
          l_result_type_cd := 'NO DISPLAY';
         end if;
         --
         l_copy_entity_result_id := null;
         l_object_version_number := null;


 -- Bug 5059695
	    if(ben_plan_design_elpro_module.g_trasaction_category = 'PQHGSP') then
	        l_dummy_parent_entity_rslt_id := p_parent_entity_result_id;
		l_dummy_table_alias := null;
	    else
	       l_dummy_parent_entity_rslt_id := null;
	       l_dummy_table_alias := 'ELP';
	    end if;
-- End Bug 5059695


         ben_copy_entity_results_api.create_copy_entity_results(
                 p_copy_entity_result_id          => l_copy_entity_result_id,
                 p_copy_entity_txn_id             => p_copy_entity_txn_id,
                 p_result_type_cd                 => l_result_type_cd,
                 p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                 p_parent_entity_result_id        => l_dummy_parent_entity_rslt_id, -- 4990825 : dont Display ELP as child node
                 p_number_of_copies               => l_number_of_copies,
                 p_table_route_id                 => l_table_route_id,
		 P_TABLE_ALIAS                    => 'ELP',
                 p_information1     => l_elp_rec.eligy_prfl_id,
                 p_information2     => l_elp_rec.EFFECTIVE_START_DATE,
                 p_information3     => l_elp_rec.EFFECTIVE_END_DATE,
                 p_information4     => l_elp_rec.business_group_id,
                 p_information5     => l_information5 , -- 9999 put name for h-grid
		 p_information8     => l_dummy_table_alias, -- 4990825 : TO display ELP as TOP-node
				p_information75     => l_elp_rec.asg_typ_cd,
				p_information76     => l_elp_rec.asmt_to_use_cd,
				p_information20     => l_elp_rec.bnft_cagr_prtn_cd,
				p_information62     => l_elp_rec.cntng_prtn_elig_prfl_flag,
				p_information219     => l_elp_rec.description,
				p_information45     => l_elp_rec.elig_age_flag,
				p_information16     => l_elp_rec.elig_anthr_pl_flag,
				p_information52     => l_elp_rec.elig_asnt_set_flag,
				p_information42     => l_elp_rec.elig_benfts_grp_flag,
				p_information44     => l_elp_rec.elig_brgng_unit_flag,
				p_information32     => l_elp_rec.elig_cbr_quald_bnf_flag,
				p_information61     => l_elp_rec.elig_cmbn_age_los_flag,
				p_information54     => l_elp_rec.elig_comp_lvl_flag,
				p_information14     => l_elp_rec.elig_comptncy_flag,
				p_information36     => l_elp_rec.elig_dpnt_cvrd_pgm_flag,
				p_information71     => l_elp_rec.elig_dpnt_cvrd_pl_flag,
				p_information34     => l_elp_rec.elig_dpnt_cvrd_plip_flag,
				p_information35     => l_elp_rec.elig_dpnt_cvrd_ptip_flag,
				p_information77     => l_elp_rec.elig_dpnt_othr_ptip_flag,
				p_information11     => l_elp_rec.elig_dsbld_flag,
				p_information25     => l_elp_rec.elig_dsblty_ctg_flag,
				p_information26     => l_elp_rec.elig_dsblty_dgr_flag,
				p_information27     => l_elp_rec.elig_dsblty_rsn_flag,
				p_information49     => l_elp_rec.elig_ee_stat_flag,
				p_information69     => l_elp_rec.elig_enrld_oipl_flag,
				p_information70     => l_elp_rec.elig_enrld_pgm_flag,
				p_information68     => l_elp_rec.elig_enrld_pl_flag,
				p_information31     => l_elp_rec.elig_enrld_plip_flag,
				p_information33     => l_elp_rec.elig_enrld_ptip_flag,
				p_information48     => l_elp_rec.elig_fl_tm_pt_tm_flag,
				p_information24     => l_elp_rec.elig_gndr_flag,
				p_information50     => l_elp_rec.elig_grd_flag,
				p_information15     => l_elp_rec.elig_hlth_cvg_flag,
				p_information38     => l_elp_rec.elig_hrly_slrd_flag,
				p_information53     => l_elp_rec.elig_hrs_wkd_flag,
				p_information37     => l_elp_rec.elig_job_flag,
				p_information40     => l_elp_rec.elig_lbr_mmbr_flag,
				p_information41     => l_elp_rec.elig_lgl_enty_flag,
				p_information56     => l_elp_rec.elig_loa_rsn_flag,
				p_information46     => l_elp_rec.elig_los_flag,
				p_information72     => l_elp_rec.elig_lvg_rsn_flag,
				p_information28     => l_elp_rec.elig_mrtl_sts_flag,
				p_information67     => l_elp_rec.elig_no_othr_cvg_flag,
				p_information73     => l_elp_rec.elig_optd_mdcr_flag,
				p_information55     => l_elp_rec.elig_org_unit_flag,
				p_information51     => l_elp_rec.elig_pct_fl_tm_flag,
				p_information47     => l_elp_rec.elig_per_typ_flag,
				p_information17     => l_elp_rec.elig_perf_rtng_flag,
				p_information64     => l_elp_rec.elig_ppl_grp_flag,
				p_information29     => l_elp_rec.elig_prbtn_perd_flag,
				p_information63     => l_elp_rec.elig_prtt_pl_flag,
				p_information39     => l_elp_rec.elig_pstl_cd_flag,
				p_information19     => l_elp_rec.elig_pstn_flag,
				p_information66     => l_elp_rec.elig_ptip_prte_flag,
				p_information59     => l_elp_rec.elig_py_bss_flag,
				p_information57     => l_elp_rec.elig_pyrl_flag,
				p_information18     => l_elp_rec.elig_qua_in_gr_flag,
				p_information21     => l_elp_rec.elig_qual_titl_flag,
				p_information58     => l_elp_rec.elig_schedd_hrs_flag,
				p_information22     => l_elp_rec.elig_sp_clng_prg_pt_flag,
				p_information23     => l_elp_rec.elig_suppl_role_flag,
				p_information65     => l_elp_rec.elig_svc_area_flag,
				p_information74     => l_elp_rec.elig_tbco_use_flag,
				p_information12     => l_elp_rec.elig_ttl_cvg_vol_flag,
				p_information13     => l_elp_rec.elig_ttl_prtt_flag,
				p_information43     => l_elp_rec.elig_wk_loc_flag,
				p_information60     => l_elp_rec.eligy_prfl_rl_flag,
                                p_information78     => l_elp_rec.elig_crit_values_flag,  /* Bug 4169120 Rate By Criteria */
				p_information111     => l_elp_rec.elp_attribute1,
				p_information120     => l_elp_rec.elp_attribute10,
				p_information121     => l_elp_rec.elp_attribute11,
				p_information122     => l_elp_rec.elp_attribute12,
				p_information123     => l_elp_rec.elp_attribute13,
				p_information124     => l_elp_rec.elp_attribute14,
				p_information125     => l_elp_rec.elp_attribute15,
				p_information126     => l_elp_rec.elp_attribute16,
				p_information127     => l_elp_rec.elp_attribute17,
				p_information128     => l_elp_rec.elp_attribute18,
				p_information129     => l_elp_rec.elp_attribute19,
				p_information112     => l_elp_rec.elp_attribute2,
				p_information130     => l_elp_rec.elp_attribute20,
				p_information131     => l_elp_rec.elp_attribute21,
				p_information132     => l_elp_rec.elp_attribute22,
				p_information133     => l_elp_rec.elp_attribute23,
				p_information134     => l_elp_rec.elp_attribute24,
				p_information135     => l_elp_rec.elp_attribute25,
				p_information136     => l_elp_rec.elp_attribute26,
				p_information137     => l_elp_rec.elp_attribute27,
				p_information138     => l_elp_rec.elp_attribute28,
				p_information139     => l_elp_rec.elp_attribute29,
				p_information113     => l_elp_rec.elp_attribute3,
				p_information140     => l_elp_rec.elp_attribute30,
				p_information114     => l_elp_rec.elp_attribute4,
				p_information115     => l_elp_rec.elp_attribute5,
				p_information116     => l_elp_rec.elp_attribute6,
				p_information117     => l_elp_rec.elp_attribute7,
				p_information118     => l_elp_rec.elp_attribute8,
				p_information119     => l_elp_rec.elp_attribute9,
				p_information110     => l_elp_rec.elp_attribute_category,
				p_information170     => l_elp_rec.name,
				p_information30     => l_elp_rec.stat_cd,
                                p_information265    => l_elp_rec.object_version_number,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                 --

                 if l_out_elp_result_id is null then
                   l_out_elp_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                    l_out_elp_result_id := l_copy_entity_result_id ;
                 end if;
                 --
              end loop;

              -- Create criteria only if Eligibility profile row
              -- has been created
              --

              if l_out_elp_result_id is not null then
              --
              ---------------------------------------------------------------
              -- START OF BEN_CNTNG_PRTN_ELIG_PRFL_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_cgp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;

                 --
                 l_cntng_prtn_elig_prfl_id := l_parent_rec.cntng_prtn_elig_prfl_id ;
                 --
                 for l_cgp_rec in c_cgp(l_parent_rec.cntng_prtn_elig_prfl_id,l_mirror_src_entity_result_id,'CGP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('CGP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := l_cgp_rec.pymt_must_be_rcvd_num ||' '||
                                      hr_general.decode_lookup('BEN_TM_UOM', l_cgp_rec.pymt_must_be_rcvd_uom);
                                      --'Intersection';
                   --
                   if p_effective_date between l_cgp_rec.effective_start_date
                      and l_cgp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'CGP',
                     p_information1     => l_cgp_rec.cntng_prtn_elig_prfl_id,
                     p_information2     => l_cgp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_cgp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_cgp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_cgp_rec.cgp_attribute1,
					p_information120     => l_cgp_rec.cgp_attribute10,
					p_information121     => l_cgp_rec.cgp_attribute11,
					p_information122     => l_cgp_rec.cgp_attribute12,
					p_information123     => l_cgp_rec.cgp_attribute13,
					p_information124     => l_cgp_rec.cgp_attribute14,
					p_information125     => l_cgp_rec.cgp_attribute15,
					p_information126     => l_cgp_rec.cgp_attribute16,
					p_information127     => l_cgp_rec.cgp_attribute17,
					p_information128     => l_cgp_rec.cgp_attribute18,
					p_information129     => l_cgp_rec.cgp_attribute19,
					p_information112     => l_cgp_rec.cgp_attribute2,
					p_information130     => l_cgp_rec.cgp_attribute20,
					p_information131     => l_cgp_rec.cgp_attribute21,
					p_information132     => l_cgp_rec.cgp_attribute22,
					p_information133     => l_cgp_rec.cgp_attribute23,
					p_information134     => l_cgp_rec.cgp_attribute24,
					p_information135     => l_cgp_rec.cgp_attribute25,
					p_information136     => l_cgp_rec.cgp_attribute26,
					p_information137     => l_cgp_rec.cgp_attribute27,
					p_information138     => l_cgp_rec.cgp_attribute28,
					p_information139     => l_cgp_rec.cgp_attribute29,
					p_information113     => l_cgp_rec.cgp_attribute3,
					p_information140     => l_cgp_rec.cgp_attribute30,
					p_information114     => l_cgp_rec.cgp_attribute4,
					p_information115     => l_cgp_rec.cgp_attribute5,
					p_information116     => l_cgp_rec.cgp_attribute6,
					p_information117     => l_cgp_rec.cgp_attribute7,
					p_information118     => l_cgp_rec.cgp_attribute8,
					p_information119     => l_cgp_rec.cgp_attribute9,
					p_information110     => l_cgp_rec.cgp_attribute_category,
					p_information263     => l_cgp_rec.eligy_prfl_id,
					p_information170     => l_cgp_rec.name,
					p_information259     => l_cgp_rec.pymt_must_be_rcvd_num,
					p_information260     => l_cgp_rec.pymt_must_be_rcvd_rl,
					p_information11     => l_cgp_rec.pymt_must_be_rcvd_uom,
                                        p_information265    => l_cgp_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_cgp_result_id is null then
                       l_out_cgp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_cgp_result_id := l_copy_entity_result_id ;
                     end if;
                     --

                     if (l_cgp_rec.pymt_must_be_rcvd_rl is not null) then
			     ben_plan_design_program_module.create_formula_result(
			  	 p_validate               => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id     => p_copy_entity_txn_id
				,p_formula_id             => l_cgp_rec.pymt_must_be_rcvd_rl
				,p_business_group_id      => l_cgp_rec.business_group_id
				,p_number_of_copies       => l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date         => p_effective_date);
			  end if;


                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_CNTNG_PRTN_ELIG_PRFL_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIGY_PRFL_RL_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_erl_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;

                 --
                 l_eligy_prfl_rl_id := l_parent_rec.eligy_prfl_rl_id ;
                 --
                 for l_erl_rec in c_erl(l_parent_rec.eligy_prfl_rl_id,l_mirror_src_entity_result_id,'ERL' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ERL');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_formula_name(l_erl_rec.formula_id
                                                                                      ,p_effective_date); --'Intersection';
                   --
                   if p_effective_date between l_erl_rec.effective_start_date
                      and l_erl_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ERL',
                     p_information1     => l_erl_rec.eligy_prfl_rl_id,
                     p_information2     => l_erl_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_erl_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_erl_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_erl_rec.drvbl_fctr_apls_flag,
					p_information263     => l_erl_rec.eligy_prfl_id,
					p_information111     => l_erl_rec.erl_attribute1,
					p_information120     => l_erl_rec.erl_attribute10,
					p_information121     => l_erl_rec.erl_attribute11,
					p_information122     => l_erl_rec.erl_attribute12,
					p_information123     => l_erl_rec.erl_attribute13,
					p_information124     => l_erl_rec.erl_attribute14,
					p_information125     => l_erl_rec.erl_attribute15,
					p_information126     => l_erl_rec.erl_attribute16,
					p_information127     => l_erl_rec.erl_attribute17,
					p_information128     => l_erl_rec.erl_attribute18,
					p_information129     => l_erl_rec.erl_attribute19,
					p_information112     => l_erl_rec.erl_attribute2,
					p_information130     => l_erl_rec.erl_attribute20,
					p_information131     => l_erl_rec.erl_attribute21,
					p_information132     => l_erl_rec.erl_attribute22,
					p_information133     => l_erl_rec.erl_attribute23,
					p_information134     => l_erl_rec.erl_attribute24,
					p_information135     => l_erl_rec.erl_attribute25,
					p_information136     => l_erl_rec.erl_attribute26,
					p_information137     => l_erl_rec.erl_attribute27,
					p_information138     => l_erl_rec.erl_attribute28,
					p_information139     => l_erl_rec.erl_attribute29,
					p_information113     => l_erl_rec.erl_attribute3,
					p_information140     => l_erl_rec.erl_attribute30,
					p_information114     => l_erl_rec.erl_attribute4,
					p_information115     => l_erl_rec.erl_attribute5,
					p_information116     => l_erl_rec.erl_attribute6,
					p_information117     => l_erl_rec.erl_attribute7,
					p_information118     => l_erl_rec.erl_attribute8,
					p_information119     => l_erl_rec.erl_attribute9,
					p_information110     => l_erl_rec.erl_attribute_category,
					p_information251     => l_erl_rec.formula_id,
					p_information260     => l_erl_rec.ordr_to_aply_num,
                                        p_information265     => l_erl_rec.object_version_number,
					p_information295     => l_erl_rec.criteria_score,
					p_information296     => l_erl_rec.criteria_weight,

				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_erl_result_id is null then
                       l_out_erl_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_erl_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                      if (l_erl_rec.formula_id is not null) then
			   ben_plan_design_program_module.create_formula_result(
				p_validate                       => p_validate
				,p_copy_entity_result_id  => l_copy_entity_result_id
				,p_copy_entity_txn_id      => p_copy_entity_txn_id
				,p_formula_id                  => l_erl_rec.formula_id
				,p_business_group_id        => l_erl_rec.business_group_id
				,p_number_of_copies         =>  l_number_of_copies
				,p_object_version_number  => l_object_version_number
				,p_effective_date             => p_effective_date);
			end if;
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIGY_PRFL_RL_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_AGE_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eap_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;

                 --
                 l_elig_age_prte_id := l_parent_rec.elig_age_prte_id ;
                 --
                 for l_eap_rec in c_eap(l_parent_rec.elig_age_prte_id,l_mirror_src_entity_result_id,'EAP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EAP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_age_fctr_name(l_eap_rec.age_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_eap_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eap_rec.effective_start_date
                      and l_eap_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EAP',
                     p_information1     => l_eap_rec.elig_age_prte_id,
                     p_information2     => l_eap_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eap_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eap_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information246     => l_eap_rec.age_fctr_id,
					p_information111     => l_eap_rec.eap_attribute1,
					p_information120     => l_eap_rec.eap_attribute10,
					p_information121     => l_eap_rec.eap_attribute11,
					p_information122     => l_eap_rec.eap_attribute12,
					p_information123     => l_eap_rec.eap_attribute13,
					p_information124     => l_eap_rec.eap_attribute14,
					p_information125     => l_eap_rec.eap_attribute15,
					p_information126     => l_eap_rec.eap_attribute16,
					p_information127     => l_eap_rec.eap_attribute17,
					p_information128     => l_eap_rec.eap_attribute18,
					p_information129     => l_eap_rec.eap_attribute19,
					p_information112     => l_eap_rec.eap_attribute2,
					p_information130     => l_eap_rec.eap_attribute20,
					p_information131     => l_eap_rec.eap_attribute21,
					p_information132     => l_eap_rec.eap_attribute22,
					p_information133     => l_eap_rec.eap_attribute23,
					p_information134     => l_eap_rec.eap_attribute24,
					p_information135     => l_eap_rec.eap_attribute25,
					p_information136     => l_eap_rec.eap_attribute26,
					p_information137     => l_eap_rec.eap_attribute27,
					p_information138     => l_eap_rec.eap_attribute28,
					p_information139     => l_eap_rec.eap_attribute29,
					p_information113     => l_eap_rec.eap_attribute3,
					p_information140     => l_eap_rec.eap_attribute30,
					p_information114     => l_eap_rec.eap_attribute4,
					p_information115     => l_eap_rec.eap_attribute5,
					p_information116     => l_eap_rec.eap_attribute6,
					p_information117     => l_eap_rec.eap_attribute7,
					p_information118     => l_eap_rec.eap_attribute8,
					p_information119     => l_eap_rec.eap_attribute9,
					p_information110     => l_eap_rec.eap_attribute_category,
					p_information263     => l_eap_rec.eligy_prfl_id,
					p_information11     => l_eap_rec.excld_flag,
					p_information260     => l_eap_rec.ordr_num,
                                        p_information265    => l_eap_rec.object_version_number,
					p_information295    => l_eap_rec.criteria_score,
					p_information296    => l_eap_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eap_result_id is null then
                       l_out_eap_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eap_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                  for l_eap_rec in c_eap_drp(l_parent_rec.elig_age_prte_id,l_mirror_src_entity_result_id,'EAP' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_eap_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => l_eap_rec.age_fctr_id
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_AGE_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ASNT_SET_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ean_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_asnt_set_prte_id := l_parent_rec.elig_asnt_set_prte_id ;
                 --
                 for l_ean_rec in c_ean(l_parent_rec.elig_asnt_set_prte_id,l_mirror_src_entity_result_id,'EAN' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EAN');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_assignment_set_name(l_ean_rec.assignment_set_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ean_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ean_rec.effective_start_date
                      and l_ean_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name(l_ean_rec.assignment_set_id);
                   fetch c_get_mapping_name into l_mapping_name;
                   close c_get_mapping_name;
                   --
                   l_mapping_id   := l_ean_rec.assignment_set_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EAN',
                     p_information1     => l_ean_rec.elig_asnt_set_prte_id,
                     p_information2     => l_ean_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ean_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ean_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information111     => l_ean_rec.ean_attribute1,
					p_information120     => l_ean_rec.ean_attribute10,
					p_information121     => l_ean_rec.ean_attribute11,
					p_information122     => l_ean_rec.ean_attribute12,
					p_information123     => l_ean_rec.ean_attribute13,
					p_information124     => l_ean_rec.ean_attribute14,
					p_information125     => l_ean_rec.ean_attribute15,
					p_information126     => l_ean_rec.ean_attribute16,
					p_information127     => l_ean_rec.ean_attribute17,
					p_information128     => l_ean_rec.ean_attribute18,
					p_information129     => l_ean_rec.ean_attribute19,
					p_information112     => l_ean_rec.ean_attribute2,
					p_information130     => l_ean_rec.ean_attribute20,
					p_information131     => l_ean_rec.ean_attribute21,
					p_information132     => l_ean_rec.ean_attribute22,
					p_information133     => l_ean_rec.ean_attribute23,
					p_information134     => l_ean_rec.ean_attribute24,
					p_information135     => l_ean_rec.ean_attribute25,
					p_information136     => l_ean_rec.ean_attribute26,
					p_information137     => l_ean_rec.ean_attribute27,
					p_information138     => l_ean_rec.ean_attribute28,
					p_information139     => l_ean_rec.ean_attribute29,
					p_information113     => l_ean_rec.ean_attribute3,
					p_information140     => l_ean_rec.ean_attribute30,
					p_information114     => l_ean_rec.ean_attribute4,
					p_information115     => l_ean_rec.ean_attribute5,
					p_information116     => l_ean_rec.ean_attribute6,
					p_information117     => l_ean_rec.ean_attribute7,
					p_information118     => l_ean_rec.ean_attribute8,
					p_information119     => l_ean_rec.ean_attribute9,
					p_information110     => l_ean_rec.ean_attribute_category,
					p_information263     => l_ean_rec.eligy_prfl_id,
					p_information11     => l_ean_rec.excld_flag,
					p_information260     => l_ean_rec.ordr_num,
                              p_information166    => NULL, -- No ESD for Assignment Set
                                        p_information265    => l_ean_rec.object_version_number,
					p_information295    => l_ean_rec.criteria_score,
					p_information296    => l_ean_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ean_result_id is null then
                       l_out_ean_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ean_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ASNT_SET_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_BENFTS_GRP_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ebn_from_parent(l_ELIGY_PRFL_ID) loop
              --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_benfts_grp_prte_id := l_parent_rec.elig_benfts_grp_prte_id ;
                 --
                 for l_ebn_rec in c_ebn(l_parent_rec.elig_benfts_grp_prte_id,l_mirror_src_entity_result_id,'EBN' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EBN');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_benfts_grp_name(l_ebn_rec.benfts_grp_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ebn_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ebn_rec.effective_start_date
                      and l_ebn_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EBN',
                     p_information1     => l_ebn_rec.elig_benfts_grp_prte_id,
                     p_information2     => l_ebn_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ebn_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ebn_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information222     => l_ebn_rec.benfts_grp_id,
					p_information111     => l_ebn_rec.ebn_attribute1,
					p_information120     => l_ebn_rec.ebn_attribute10,
					p_information121     => l_ebn_rec.ebn_attribute11,
					p_information122     => l_ebn_rec.ebn_attribute12,
					p_information123     => l_ebn_rec.ebn_attribute13,
					p_information124     => l_ebn_rec.ebn_attribute14,
					p_information125     => l_ebn_rec.ebn_attribute15,
					p_information126     => l_ebn_rec.ebn_attribute16,
					p_information127     => l_ebn_rec.ebn_attribute17,
					p_information128     => l_ebn_rec.ebn_attribute18,
					p_information129     => l_ebn_rec.ebn_attribute19,
					p_information112     => l_ebn_rec.ebn_attribute2,
					p_information130     => l_ebn_rec.ebn_attribute20,
					p_information131     => l_ebn_rec.ebn_attribute21,
					p_information132     => l_ebn_rec.ebn_attribute22,
					p_information133     => l_ebn_rec.ebn_attribute23,
					p_information134     => l_ebn_rec.ebn_attribute24,
					p_information135     => l_ebn_rec.ebn_attribute25,
					p_information136     => l_ebn_rec.ebn_attribute26,
					p_information137     => l_ebn_rec.ebn_attribute27,
					p_information138     => l_ebn_rec.ebn_attribute28,
					p_information139     => l_ebn_rec.ebn_attribute29,
					p_information113     => l_ebn_rec.ebn_attribute3,
					p_information140     => l_ebn_rec.ebn_attribute30,
					p_information114     => l_ebn_rec.ebn_attribute4,
					p_information115     => l_ebn_rec.ebn_attribute5,
					p_information116     => l_ebn_rec.ebn_attribute6,
					p_information117     => l_ebn_rec.ebn_attribute7,
					p_information118     => l_ebn_rec.ebn_attribute8,
					p_information119     => l_ebn_rec.ebn_attribute9,
					p_information110     => l_ebn_rec.ebn_attribute_category,
					p_information263     => l_ebn_rec.eligy_prfl_id,
					p_information11     => l_ebn_rec.excld_flag,
					p_information260     => l_ebn_rec.ordr_num,
                                        p_information265    => l_ebn_rec.object_version_number,
					p_information295    => l_ebn_rec.criteria_score,
					p_information296    => l_ebn_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_ebn_result_id is null then
                       l_out_ebn_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ebn_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                  for l_ebn_rec in c_ebn_bg(l_parent_rec.elig_benfts_grp_prte_id,l_mirror_src_entity_result_id,'EBN' ) loop
                       ben_pd_rate_and_cvg_module.create_bnft_group_results
                          (
                           p_validate                     => p_validate
                          ,p_copy_entity_result_id        => l_out_ebn_result_id
                          ,p_copy_entity_txn_id           => p_copy_entity_txn_id
                          ,p_benfts_grp_id                => l_ebn_rec.benfts_grp_id
                          ,p_business_group_id            => p_business_group_id
                          ,p_number_of_copies             => p_number_of_copies
                          ,p_object_version_number        => l_object_version_number
                          ,p_effective_date               => p_effective_date
                          );
                  end loop;
                end loop;
              ---------------------------------------------------------------
              -- END OF BEN_ELIG_BENFTS_GRP_PRTE_F ----------------------
              ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_BRGNG_UNIT_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ebu_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_brgng_unit_prte_id := l_parent_rec.elig_brgng_unit_prte_id ;
                 --
                 for l_ebu_rec in c_ebu(l_parent_rec.elig_brgng_unit_prte_id,l_mirror_src_entity_result_id,'EBU' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EBU');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('BARGAINING_UNIT_CODE',l_ebu_rec.brgng_unit_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_ebu_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ebu_rec.effective_start_date
                      and l_ebu_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EBU',
                     p_information1     => l_ebu_rec.elig_brgng_unit_prte_id,
                     p_information2     => l_ebu_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ebu_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ebu_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_ebu_rec.brgng_unit_cd,
					p_information111     => l_ebu_rec.ebu_attribute1,
					p_information120     => l_ebu_rec.ebu_attribute10,
					p_information121     => l_ebu_rec.ebu_attribute11,
					p_information122     => l_ebu_rec.ebu_attribute12,
					p_information123     => l_ebu_rec.ebu_attribute13,
					p_information124     => l_ebu_rec.ebu_attribute14,
					p_information125     => l_ebu_rec.ebu_attribute15,
					p_information126     => l_ebu_rec.ebu_attribute16,
					p_information127     => l_ebu_rec.ebu_attribute17,
					p_information128     => l_ebu_rec.ebu_attribute18,
					p_information129     => l_ebu_rec.ebu_attribute19,
					p_information112     => l_ebu_rec.ebu_attribute2,
					p_information130     => l_ebu_rec.ebu_attribute20,
					p_information131     => l_ebu_rec.ebu_attribute21,
					p_information132     => l_ebu_rec.ebu_attribute22,
					p_information133     => l_ebu_rec.ebu_attribute23,
					p_information134     => l_ebu_rec.ebu_attribute24,
					p_information135     => l_ebu_rec.ebu_attribute25,
					p_information136     => l_ebu_rec.ebu_attribute26,
					p_information137     => l_ebu_rec.ebu_attribute27,
					p_information138     => l_ebu_rec.ebu_attribute28,
					p_information139     => l_ebu_rec.ebu_attribute29,
					p_information113     => l_ebu_rec.ebu_attribute3,
					p_information140     => l_ebu_rec.ebu_attribute30,
					p_information114     => l_ebu_rec.ebu_attribute4,
					p_information115     => l_ebu_rec.ebu_attribute5,
					p_information116     => l_ebu_rec.ebu_attribute6,
					p_information117     => l_ebu_rec.ebu_attribute7,
					p_information118     => l_ebu_rec.ebu_attribute8,
					p_information119     => l_ebu_rec.ebu_attribute9,
					p_information110     => l_ebu_rec.ebu_attribute_category,
					p_information263     => l_ebu_rec.eligy_prfl_id,
					p_information12     => l_ebu_rec.excld_flag,
					p_information260     => l_ebu_rec.ordr_num,
                                        p_information265    => l_ebu_rec.object_version_number,
					p_information295    => l_ebu_rec.criteria_score,
					p_information296    => l_ebu_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ebu_result_id is null then
                       l_out_ebu_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ebu_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_BRGNG_UNIT_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_CBR_QUALD_BNF_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ecq_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_cbr_quald_bnf_id := l_parent_rec.elig_cbr_quald_bnf_id ;
                 --
                 for l_ecq_rec in c_ecq(l_parent_rec.elig_cbr_quald_bnf_id,l_mirror_src_entity_result_id,'ECQ' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ECQ');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_cbr_quald_bnf_name(l_ecq_rec.ptip_id
                                                                                           ,l_ecq_rec.pgm_id
                                                                                           ,p_effective_date)
                                       --
                                       -- Bug no: 3451872
                                       --
                                       ||' '||get_quald_bnf_message(l_ecq_rec.quald_bnf_flag);
                                       --
                                       --'Intersection';
                   --
                   if p_effective_date between l_ecq_rec.effective_start_date
                      and l_ecq_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ECQ',
                     p_information1     => l_ecq_rec.elig_cbr_quald_bnf_id,
                     p_information2     => l_ecq_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ecq_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ecq_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_ecq_rec.ecq_attribute1,
					p_information120     => l_ecq_rec.ecq_attribute10,
					p_information121     => l_ecq_rec.ecq_attribute11,
					p_information122     => l_ecq_rec.ecq_attribute12,
					p_information123     => l_ecq_rec.ecq_attribute13,
					p_information124     => l_ecq_rec.ecq_attribute14,
					p_information125     => l_ecq_rec.ecq_attribute15,
					p_information126     => l_ecq_rec.ecq_attribute16,
					p_information127     => l_ecq_rec.ecq_attribute17,
					p_information128     => l_ecq_rec.ecq_attribute18,
					p_information129     => l_ecq_rec.ecq_attribute19,
					p_information112     => l_ecq_rec.ecq_attribute2,
					p_information130     => l_ecq_rec.ecq_attribute20,
					p_information131     => l_ecq_rec.ecq_attribute21,
					p_information132     => l_ecq_rec.ecq_attribute22,
					p_information133     => l_ecq_rec.ecq_attribute23,
					p_information134     => l_ecq_rec.ecq_attribute24,
					p_information135     => l_ecq_rec.ecq_attribute25,
					p_information136     => l_ecq_rec.ecq_attribute26,
					p_information137     => l_ecq_rec.ecq_attribute27,
					p_information138     => l_ecq_rec.ecq_attribute28,
					p_information139     => l_ecq_rec.ecq_attribute29,
					p_information113     => l_ecq_rec.ecq_attribute3,
					p_information140     => l_ecq_rec.ecq_attribute30,
					p_information114     => l_ecq_rec.ecq_attribute4,
					p_information115     => l_ecq_rec.ecq_attribute5,
					p_information116     => l_ecq_rec.ecq_attribute6,
					p_information117     => l_ecq_rec.ecq_attribute7,
					p_information118     => l_ecq_rec.ecq_attribute8,
					p_information119     => l_ecq_rec.ecq_attribute9,
					p_information110     => l_ecq_rec.ecq_attribute_category,
					p_information263     => l_ecq_rec.eligy_prfl_id,
					p_information262     => l_ecq_rec.ordr_num,
					p_information260     => l_ecq_rec.pgm_id,
					p_information259     => l_ecq_rec.ptip_id,
					p_information11     => l_ecq_rec.quald_bnf_flag,
                                        p_information265    => l_ecq_rec.object_version_number,
					p_information295    => l_ecq_rec.criteria_score,
					p_information296    => l_ecq_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ecq_result_id is null then
                       l_out_ecq_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ecq_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_CBR_QUALD_BNF_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_CMBN_AGE_LOS_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ecp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_cmbn_age_los_prte_id := l_parent_rec.elig_cmbn_age_los_prte_id ;
                 --
                 for l_ecp_rec in c_ecp(l_parent_rec.elig_cmbn_age_los_prte_id,l_mirror_src_entity_result_id,'ECP') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ECP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_cmbn_age_los_fctr_name(l_ecp_rec.cmbn_age_los_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ecp_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ecp_rec.effective_start_date
                      and l_ecp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ECP',
                     p_information1     => l_ecp_rec.elig_cmbn_age_los_prte_id,
                     p_information2     => l_ecp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ecp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ecp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information223     => l_ecp_rec.cmbn_age_los_fctr_id,
					p_information111     => l_ecp_rec.ecp_attribute1,
					p_information120     => l_ecp_rec.ecp_attribute10,
					p_information121     => l_ecp_rec.ecp_attribute11,
					p_information122     => l_ecp_rec.ecp_attribute12,
					p_information123     => l_ecp_rec.ecp_attribute13,
					p_information124     => l_ecp_rec.ecp_attribute14,
					p_information125     => l_ecp_rec.ecp_attribute15,
					p_information126     => l_ecp_rec.ecp_attribute16,
					p_information127     => l_ecp_rec.ecp_attribute17,
					p_information128     => l_ecp_rec.ecp_attribute18,
					p_information129     => l_ecp_rec.ecp_attribute19,
					p_information112     => l_ecp_rec.ecp_attribute2,
					p_information130     => l_ecp_rec.ecp_attribute20,
					p_information131     => l_ecp_rec.ecp_attribute21,
					p_information132     => l_ecp_rec.ecp_attribute22,
					p_information133     => l_ecp_rec.ecp_attribute23,
					p_information134     => l_ecp_rec.ecp_attribute24,
					p_information135     => l_ecp_rec.ecp_attribute25,
					p_information136     => l_ecp_rec.ecp_attribute26,
					p_information137     => l_ecp_rec.ecp_attribute27,
					p_information138     => l_ecp_rec.ecp_attribute28,
					p_information139     => l_ecp_rec.ecp_attribute29,
					p_information113     => l_ecp_rec.ecp_attribute3,
					p_information140     => l_ecp_rec.ecp_attribute30,
					p_information114     => l_ecp_rec.ecp_attribute4,
					p_information115     => l_ecp_rec.ecp_attribute5,
					p_information116     => l_ecp_rec.ecp_attribute6,
					p_information117     => l_ecp_rec.ecp_attribute7,
					p_information118     => l_ecp_rec.ecp_attribute8,
					p_information119     => l_ecp_rec.ecp_attribute9,
					p_information110     => l_ecp_rec.ecp_attribute_category,
					p_information263     => l_ecp_rec.eligy_prfl_id,
					p_information11     => l_ecp_rec.excld_flag,
					p_information12     => l_ecp_rec.mndtry_flag,
					p_information260     => l_ecp_rec.ordr_num,
                                        p_information265    => l_ecp_rec.object_version_number,
					p_information295    => l_ecp_rec.criteria_score,
					p_information296    => l_ecp_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_ecp_result_id is null then
                       l_out_ecp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ecp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                 for l_ecp_rec in c_ecp_drp(l_parent_rec.elig_cmbn_age_los_prte_id,l_mirror_src_entity_result_id,'ECP' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_ecp_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => null
                       ,p_cmbn_age_los_fctr_id          => l_ecp_rec.cmbn_age_los_fctr_id
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_CMBN_AGE_LOS_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_COMP_LVL_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ecl_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_comp_lvl_prte_id := l_parent_rec.elig_comp_lvl_prte_id ;
                 --
                 for l_ecl_rec in c_ecl(l_parent_rec.elig_comp_lvl_prte_id,l_mirror_src_entity_result_id,'ECL' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ECL');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_comp_lvl_fctr_name(l_ecl_rec.comp_lvl_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ecl_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ecl_rec.effective_start_date
                      and l_ecl_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ECL',
                     p_information1     => l_ecl_rec.elig_comp_lvl_prte_id,
                     p_information2     => l_ecl_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ecl_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ecl_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information254     => l_ecl_rec.comp_lvl_fctr_id,
					p_information111     => l_ecl_rec.ecl_attribute1,
					p_information120     => l_ecl_rec.ecl_attribute10,
					p_information121     => l_ecl_rec.ecl_attribute11,
					p_information122     => l_ecl_rec.ecl_attribute12,
					p_information123     => l_ecl_rec.ecl_attribute13,
					p_information124     => l_ecl_rec.ecl_attribute14,
					p_information125     => l_ecl_rec.ecl_attribute15,
					p_information126     => l_ecl_rec.ecl_attribute16,
					p_information127     => l_ecl_rec.ecl_attribute17,
					p_information128     => l_ecl_rec.ecl_attribute18,
					p_information129     => l_ecl_rec.ecl_attribute19,
					p_information112     => l_ecl_rec.ecl_attribute2,
					p_information130     => l_ecl_rec.ecl_attribute20,
					p_information131     => l_ecl_rec.ecl_attribute21,
					p_information132     => l_ecl_rec.ecl_attribute22,
					p_information133     => l_ecl_rec.ecl_attribute23,
					p_information134     => l_ecl_rec.ecl_attribute24,
					p_information135     => l_ecl_rec.ecl_attribute25,
					p_information136     => l_ecl_rec.ecl_attribute26,
					p_information137     => l_ecl_rec.ecl_attribute27,
					p_information138     => l_ecl_rec.ecl_attribute28,
					p_information139     => l_ecl_rec.ecl_attribute29,
					p_information113     => l_ecl_rec.ecl_attribute3,
					p_information140     => l_ecl_rec.ecl_attribute30,
					p_information114     => l_ecl_rec.ecl_attribute4,
					p_information115     => l_ecl_rec.ecl_attribute5,
					p_information116     => l_ecl_rec.ecl_attribute6,
					p_information117     => l_ecl_rec.ecl_attribute7,
					p_information118     => l_ecl_rec.ecl_attribute8,
					p_information119     => l_ecl_rec.ecl_attribute9,
					p_information110     => l_ecl_rec.ecl_attribute_category,
					p_information263     => l_ecl_rec.eligy_prfl_id,
					p_information11     => l_ecl_rec.excld_flag,
					p_information260     => l_ecl_rec.ordr_num,
                                        p_information265    => l_ecl_rec.object_version_number,
					p_information295    => l_ecl_rec.criteria_score,
					p_information296    => l_ecl_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_ecl_result_id is null then
                       l_out_ecl_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ecl_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                 hr_utility.set_location('Before create_drpar_results '||p_copy_entity_txn_id,11);
                 hr_utility.set_location(' l_out_ecl_result_id '||l_out_ecl_result_id,11);
                 for l_ecl_rec in c_ecl_drp(l_parent_rec.elig_comp_lvl_prte_id,l_mirror_src_entity_result_id,'ECL' ) loop
                    hr_utility.set_location(' l_ecl_rec.comp_lvl_fctr_id '||l_ecl_rec.comp_lvl_fctr_id,12);
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_ecl_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => l_ecl_rec.comp_lvl_fctr_id
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => null
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_COMP_LVL_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PGM_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edg_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dpnt_cvrd_othr_pgm_id := l_parent_rec.elig_dpnt_cvrd_othr_pgm_id ;
                 --
                 for l_edg_rec in c_edg(l_parent_rec.elig_dpnt_cvrd_othr_pgm_id,l_mirror_src_entity_result_id,'EDG' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDG');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pgm_name(l_edg_rec.pgm_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_edg_rec.ENRL_DET_DT_CD,'BEN_ENRL_DET_DT')
									  || get_subj_to_cobra_message(l_edg_rec.ONLY_PLS_SUBJ_COBRA_FLAG)
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_edg_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edg_rec.effective_start_date
                      and l_edg_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDG',
                     p_information1     => l_edg_rec.elig_dpnt_cvrd_othr_pgm_id,
                     p_information2     => l_edg_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edg_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edg_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_INFORMATION111     => l_edg_rec.EDG_ATTRIBUTE1,
                     p_INFORMATION120     => l_edg_rec.EDG_ATTRIBUTE10,
                     p_INFORMATION121     => l_edg_rec.EDG_ATTRIBUTE11,
                     p_INFORMATION122     => l_edg_rec.EDG_ATTRIBUTE12,
                     p_INFORMATION123     => l_edg_rec.EDG_ATTRIBUTE13,
                     p_INFORMATION124     => l_edg_rec.EDG_ATTRIBUTE14,
                     p_INFORMATION125     => l_edg_rec.EDG_ATTRIBUTE15,
                     p_INFORMATION126     => l_edg_rec.EDG_ATTRIBUTE16,
                     p_INFORMATION127     => l_edg_rec.EDG_ATTRIBUTE17,
                     p_INFORMATION128     => l_edg_rec.EDG_ATTRIBUTE18,
                     p_INFORMATION129     => l_edg_rec.EDG_ATTRIBUTE19,
                     p_INFORMATION112     => l_edg_rec.EDG_ATTRIBUTE2,
                     p_INFORMATION130     => l_edg_rec.EDG_ATTRIBUTE20,
                     p_INFORMATION131     => l_edg_rec.EDG_ATTRIBUTE21,
                     p_INFORMATION132     => l_edg_rec.EDG_ATTRIBUTE22,
                     p_INFORMATION133     => l_edg_rec.EDG_ATTRIBUTE23,
                     p_INFORMATION134     => l_edg_rec.EDG_ATTRIBUTE24,
                     p_INFORMATION135     => l_edg_rec.EDG_ATTRIBUTE25,
                     p_INFORMATION136     => l_edg_rec.EDG_ATTRIBUTE26,
                     p_INFORMATION137     => l_edg_rec.EDG_ATTRIBUTE27,
                     p_INFORMATION138     => l_edg_rec.EDG_ATTRIBUTE28,
                     p_INFORMATION139     => l_edg_rec.EDG_ATTRIBUTE29,
                     p_INFORMATION113     => l_edg_rec.EDG_ATTRIBUTE3,
                     p_INFORMATION140     => l_edg_rec.EDG_ATTRIBUTE30,
                     p_INFORMATION114     => l_edg_rec.EDG_ATTRIBUTE4,
                     p_INFORMATION115     => l_edg_rec.EDG_ATTRIBUTE5,
                     p_INFORMATION116     => l_edg_rec.EDG_ATTRIBUTE6,
                     p_INFORMATION117     => l_edg_rec.EDG_ATTRIBUTE7,
                     p_INFORMATION118     => l_edg_rec.EDG_ATTRIBUTE8,
                     p_INFORMATION119     => l_edg_rec.EDG_ATTRIBUTE9,
                     p_INFORMATION110     => l_edg_rec.EDG_ATTRIBUTE_CATEGORY,
                     p_INFORMATION263     => l_edg_rec.ELIGY_PRFL_ID,
                     p_INFORMATION13     => l_edg_rec.ENRL_DET_DT_CD,
                     p_INFORMATION11     => l_edg_rec.EXCLD_FLAG,
                     p_INFORMATION12     => l_edg_rec.ONLY_PLS_SUBJ_COBRA_FLAG,
                     p_INFORMATION261     => l_edg_rec.ORDR_NUM,
                     p_INFORMATION260     => l_edg_rec.PGM_ID,
                     p_information265    => l_edg_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edg_result_id is null then
                       l_out_edg_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edg_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PGM_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PL_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dpnt_cvrd_othr_pl_id := l_parent_rec.elig_dpnt_cvrd_othr_pl_id ;
                 --
                 for l_edp_rec in c_edp(l_parent_rec.elig_dpnt_cvrd_othr_pl_id,l_mirror_src_entity_result_id,'EDP') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pl_name(l_edp_rec.pl_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_edp_rec.CVG_DET_DT_CD,'BEN_CVG_DET_DT')
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_edp_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edp_rec.effective_start_date
                      and l_edp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDP',
                     p_information1     => l_edp_rec.elig_dpnt_cvrd_othr_pl_id,
                     p_information2     => l_edp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_INFORMATION12     => l_edp_rec.CVG_DET_DT_CD,
                     p_INFORMATION111     => l_edp_rec.EDP_ATTRIBUTE1,
                     p_INFORMATION120     => l_edp_rec.EDP_ATTRIBUTE10,
                     p_INFORMATION121     => l_edp_rec.EDP_ATTRIBUTE11,
                     p_INFORMATION122     => l_edp_rec.EDP_ATTRIBUTE12,
                     p_INFORMATION123     => l_edp_rec.EDP_ATTRIBUTE13,
                     p_INFORMATION124     => l_edp_rec.EDP_ATTRIBUTE14,
                     p_INFORMATION125     => l_edp_rec.EDP_ATTRIBUTE15,
                     p_INFORMATION126     => l_edp_rec.EDP_ATTRIBUTE16,
                     p_INFORMATION127     => l_edp_rec.EDP_ATTRIBUTE17,
                     p_INFORMATION128     => l_edp_rec.EDP_ATTRIBUTE18,
                     p_INFORMATION129     => l_edp_rec.EDP_ATTRIBUTE19,
                     p_INFORMATION112     => l_edp_rec.EDP_ATTRIBUTE2,
                     p_INFORMATION130     => l_edp_rec.EDP_ATTRIBUTE20,
                     p_INFORMATION131     => l_edp_rec.EDP_ATTRIBUTE21,
                     p_INFORMATION132     => l_edp_rec.EDP_ATTRIBUTE22,
                     p_INFORMATION133     => l_edp_rec.EDP_ATTRIBUTE23,
                     p_INFORMATION134     => l_edp_rec.EDP_ATTRIBUTE24,
                     p_INFORMATION135     => l_edp_rec.EDP_ATTRIBUTE25,
                     p_INFORMATION136     => l_edp_rec.EDP_ATTRIBUTE26,
                     p_INFORMATION137     => l_edp_rec.EDP_ATTRIBUTE27,
                     p_INFORMATION138     => l_edp_rec.EDP_ATTRIBUTE28,
                     p_INFORMATION139     => l_edp_rec.EDP_ATTRIBUTE29,
                     p_INFORMATION113     => l_edp_rec.EDP_ATTRIBUTE3,
                     p_INFORMATION140     => l_edp_rec.EDP_ATTRIBUTE30,
                     p_INFORMATION114     => l_edp_rec.EDP_ATTRIBUTE4,
                     p_INFORMATION115     => l_edp_rec.EDP_ATTRIBUTE5,
                     p_INFORMATION116     => l_edp_rec.EDP_ATTRIBUTE6,
                     p_INFORMATION117     => l_edp_rec.EDP_ATTRIBUTE7,
                     p_INFORMATION118     => l_edp_rec.EDP_ATTRIBUTE8,
                     p_INFORMATION119     => l_edp_rec.EDP_ATTRIBUTE9,
                     p_INFORMATION110     => l_edp_rec.EDP_ATTRIBUTE_CATEGORY,
                     p_INFORMATION263     => l_edp_rec.ELIGY_PRFL_ID,
                     p_INFORMATION11     => l_edp_rec.EXCLD_FLAG,
                     p_INFORMATION260     => l_edp_rec.ORDR_NUM,
                     p_INFORMATION261     => l_edp_rec.PL_ID,
                     p_information265    => l_edp_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edp_result_id is null then
                       l_out_edp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PL_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edt_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dpnt_cvrd_othr_ptip_id := l_parent_rec.elig_dpnt_cvrd_othr_ptip_id ;
                 --
                 for l_edt_rec in c_edt(l_parent_rec.elig_dpnt_cvrd_othr_ptip_id,l_mirror_src_entity_result_id,'EDT' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDT');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_ptip_name(l_edt_rec.ptip_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_edt_rec.ENRL_DET_DT_CD,'BEN_ENRL_DET_DT')
                                      || get_subj_to_cobra_message(l_edt_rec.ONLY_PLS_SUBJ_COBRA_FLAG)
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_edt_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edt_rec.effective_start_date
                      and l_edt_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDT',
                     p_information1     => l_edt_rec.elig_dpnt_cvrd_othr_ptip_id,
                     p_information2     => l_edt_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edt_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edt_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_INFORMATION111     => l_edt_rec.EDT_ATTRIBUTE1,
                     p_INFORMATION120     => l_edt_rec.EDT_ATTRIBUTE10,
                     p_INFORMATION121     => l_edt_rec.EDT_ATTRIBUTE11,
                     p_INFORMATION122     => l_edt_rec.EDT_ATTRIBUTE12,
                     p_INFORMATION123     => l_edt_rec.EDT_ATTRIBUTE13,
                     p_INFORMATION124     => l_edt_rec.EDT_ATTRIBUTE14,
                     p_INFORMATION125     => l_edt_rec.EDT_ATTRIBUTE15,
                     p_INFORMATION126     => l_edt_rec.EDT_ATTRIBUTE16,
                     p_INFORMATION127     => l_edt_rec.EDT_ATTRIBUTE17,
                     p_INFORMATION128     => l_edt_rec.EDT_ATTRIBUTE18,
                     p_INFORMATION129     => l_edt_rec.EDT_ATTRIBUTE19,
                     p_INFORMATION112     => l_edt_rec.EDT_ATTRIBUTE2,
                     p_INFORMATION130     => l_edt_rec.EDT_ATTRIBUTE20,
                     p_INFORMATION131     => l_edt_rec.EDT_ATTRIBUTE21,
                     p_INFORMATION132     => l_edt_rec.EDT_ATTRIBUTE22,
                     p_INFORMATION133     => l_edt_rec.EDT_ATTRIBUTE23,
                     p_INFORMATION134     => l_edt_rec.EDT_ATTRIBUTE24,
                     p_INFORMATION135     => l_edt_rec.EDT_ATTRIBUTE25,
                     p_INFORMATION136     => l_edt_rec.EDT_ATTRIBUTE26,
                     p_INFORMATION137     => l_edt_rec.EDT_ATTRIBUTE27,
                     p_INFORMATION138     => l_edt_rec.EDT_ATTRIBUTE28,
                     p_INFORMATION139     => l_edt_rec.EDT_ATTRIBUTE29,
                     p_INFORMATION113     => l_edt_rec.EDT_ATTRIBUTE3,
                     p_INFORMATION140     => l_edt_rec.EDT_ATTRIBUTE30,
                     p_INFORMATION114     => l_edt_rec.EDT_ATTRIBUTE4,
                     p_INFORMATION115     => l_edt_rec.EDT_ATTRIBUTE5,
                     p_INFORMATION116     => l_edt_rec.EDT_ATTRIBUTE6,
                     p_INFORMATION117     => l_edt_rec.EDT_ATTRIBUTE7,
                     p_INFORMATION118     => l_edt_rec.EDT_ATTRIBUTE8,
                     p_INFORMATION119     => l_edt_rec.EDT_ATTRIBUTE9,
                     p_INFORMATION110     => l_edt_rec.EDT_ATTRIBUTE_CATEGORY,
                     p_INFORMATION263     => l_edt_rec.ELIGY_PRFL_ID,
                     p_INFORMATION13     => l_edt_rec.ENRL_DET_DT_CD,
                     p_INFORMATION11     => l_edt_rec.EXCLD_FLAG,
                     p_INFORMATION12     => l_edt_rec.ONLY_PLS_SUBJ_COBRA_FLAG,
                     p_INFORMATION261     => l_edt_rec.ORDR_NUM,
                     p_INFORMATION259     => l_edt_rec.PTIP_ID,
                     p_information265    => l_edt_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edt_result_id is null then
                       l_out_edt_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edt_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DPNT_CVRD_OTHR_PTIP_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DPNT_CVRD_PLIP_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edi_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dpnt_cvrd_plip_id := l_parent_rec.elig_dpnt_cvrd_plip_id ;
                 --
                 for l_edi_rec in c_edi(l_parent_rec.elig_dpnt_cvrd_plip_id,l_mirror_src_entity_result_id,'EDI' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDI');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_plip_name(l_edi_rec.plip_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_edi_rec.ENRL_DET_DT_CD,'BEN_ENRL_DET_DT')
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_edi_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edi_rec.effective_start_date
                      and l_edi_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDI',
                     p_information1     => l_edi_rec.elig_dpnt_cvrd_plip_id,
                     p_information2     => l_edi_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edi_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edi_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_INFORMATION111     => l_edi_rec.EDI_ATTRIBUTE1,
                     p_INFORMATION120     => l_edi_rec.EDI_ATTRIBUTE10,
                     p_INFORMATION121     => l_edi_rec.EDI_ATTRIBUTE11,
                     p_INFORMATION122     => l_edi_rec.EDI_ATTRIBUTE12,
                     p_INFORMATION123     => l_edi_rec.EDI_ATTRIBUTE13,
                     p_INFORMATION124     => l_edi_rec.EDI_ATTRIBUTE14,
                     p_INFORMATION125     => l_edi_rec.EDI_ATTRIBUTE15,
                     p_INFORMATION126     => l_edi_rec.EDI_ATTRIBUTE16,
                     p_INFORMATION127     => l_edi_rec.EDI_ATTRIBUTE17,
                     p_INFORMATION128     => l_edi_rec.EDI_ATTRIBUTE18,
                     p_INFORMATION129     => l_edi_rec.EDI_ATTRIBUTE19,
                     p_INFORMATION112     => l_edi_rec.EDI_ATTRIBUTE2,
                     p_INFORMATION130     => l_edi_rec.EDI_ATTRIBUTE20,
                     p_INFORMATION131     => l_edi_rec.EDI_ATTRIBUTE21,
                     p_INFORMATION132     => l_edi_rec.EDI_ATTRIBUTE22,
                     p_INFORMATION133     => l_edi_rec.EDI_ATTRIBUTE23,
                     p_INFORMATION134     => l_edi_rec.EDI_ATTRIBUTE24,
                     p_INFORMATION135     => l_edi_rec.EDI_ATTRIBUTE25,
                     p_INFORMATION136     => l_edi_rec.EDI_ATTRIBUTE26,
                     p_INFORMATION137     => l_edi_rec.EDI_ATTRIBUTE27,
                     p_INFORMATION138     => l_edi_rec.EDI_ATTRIBUTE28,
                     p_INFORMATION139     => l_edi_rec.EDI_ATTRIBUTE29,
                     p_INFORMATION113     => l_edi_rec.EDI_ATTRIBUTE3,
                     p_INFORMATION140     => l_edi_rec.EDI_ATTRIBUTE30,
                     p_INFORMATION114     => l_edi_rec.EDI_ATTRIBUTE4,
                     p_INFORMATION115     => l_edi_rec.EDI_ATTRIBUTE5,
                     p_INFORMATION116     => l_edi_rec.EDI_ATTRIBUTE6,
                     p_INFORMATION117     => l_edi_rec.EDI_ATTRIBUTE7,
                     p_INFORMATION118     => l_edi_rec.EDI_ATTRIBUTE8,
                     p_INFORMATION119     => l_edi_rec.EDI_ATTRIBUTE9,
                     p_INFORMATION110     => l_edi_rec.EDI_ATTRIBUTE_CATEGORY,
                     p_INFORMATION263     => l_edi_rec.ELIGY_PRFL_ID,
                     p_INFORMATION11     => l_edi_rec.ENRL_DET_DT_CD,
                     p_INFORMATION12     => l_edi_rec.EXCLD_FLAG,
                     p_INFORMATION260     => l_edi_rec.ORDR_NUM,
                     p_INFORMATION256     => l_edi_rec.PLIP_ID,
                     p_information265    => l_edi_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edi_result_id is null then
                       l_out_edi_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edi_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DPNT_CVRD_PLIP_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DPNT_OTHR_PTIP_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_etd_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dpnt_othr_ptip_id := l_parent_rec.elig_dpnt_othr_ptip_id ;
                 --
                 for l_etd_rec in c_etd(l_parent_rec.elig_dpnt_othr_ptip_id,l_mirror_src_entity_result_id,'ETD' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ETD');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_ptip_name(l_etd_rec.ptip_id,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_etd_rec.excld_flag);
                                     --'Intersection';
                   --
                   if p_effective_date between l_etd_rec.effective_start_date
                      and l_etd_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ETD',
                     p_information1     => l_etd_rec.elig_dpnt_othr_ptip_id,
                     p_information2     => l_etd_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_etd_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_etd_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_INFORMATION263     => l_etd_rec.ELIGY_PRFL_ID,
                     p_INFORMATION111     => l_etd_rec.ETD_ATTRIBUTE1,
                     p_INFORMATION120     => l_etd_rec.ETD_ATTRIBUTE10,
                     p_INFORMATION121     => l_etd_rec.ETD_ATTRIBUTE11,
                     p_INFORMATION122     => l_etd_rec.ETD_ATTRIBUTE12,
                     p_INFORMATION123     => l_etd_rec.ETD_ATTRIBUTE13,
                     p_INFORMATION124     => l_etd_rec.ETD_ATTRIBUTE14,
                     p_INFORMATION125     => l_etd_rec.ETD_ATTRIBUTE15,
                     p_INFORMATION126     => l_etd_rec.ETD_ATTRIBUTE16,
                     p_INFORMATION127     => l_etd_rec.ETD_ATTRIBUTE17,
                     p_INFORMATION128     => l_etd_rec.ETD_ATTRIBUTE18,
                     p_INFORMATION129     => l_etd_rec.ETD_ATTRIBUTE19,
                     p_INFORMATION112     => l_etd_rec.ETD_ATTRIBUTE2,
                     p_INFORMATION130     => l_etd_rec.ETD_ATTRIBUTE20,
                     p_INFORMATION131     => l_etd_rec.ETD_ATTRIBUTE21,
                     p_INFORMATION132     => l_etd_rec.ETD_ATTRIBUTE22,
                     p_INFORMATION133     => l_etd_rec.ETD_ATTRIBUTE23,
                     p_INFORMATION134     => l_etd_rec.ETD_ATTRIBUTE24,
                     p_INFORMATION135     => l_etd_rec.ETD_ATTRIBUTE25,
                     p_INFORMATION136     => l_etd_rec.ETD_ATTRIBUTE26,
                     p_INFORMATION137     => l_etd_rec.ETD_ATTRIBUTE27,
                     p_INFORMATION138     => l_etd_rec.ETD_ATTRIBUTE28,
                     p_INFORMATION139     => l_etd_rec.ETD_ATTRIBUTE29,
                     p_INFORMATION113     => l_etd_rec.ETD_ATTRIBUTE3,
                     p_INFORMATION140     => l_etd_rec.ETD_ATTRIBUTE30,
                     p_INFORMATION114     => l_etd_rec.ETD_ATTRIBUTE4,
                     p_INFORMATION115     => l_etd_rec.ETD_ATTRIBUTE5,
                     p_INFORMATION116     => l_etd_rec.ETD_ATTRIBUTE6,
                     p_INFORMATION117     => l_etd_rec.ETD_ATTRIBUTE7,
                     p_INFORMATION118     => l_etd_rec.ETD_ATTRIBUTE8,
                     p_INFORMATION119     => l_etd_rec.ETD_ATTRIBUTE9,
                     p_INFORMATION110     => l_etd_rec.ETD_ATTRIBUTE_CATEGORY,
                     p_INFORMATION11     => l_etd_rec.EXCLD_FLAG,
                     p_INFORMATION257     => l_etd_rec.ORDR_NUM,
                     p_INFORMATION259     => l_etd_rec.PTIP_ID,
                     p_information265    => l_etd_rec.object_version_number,
                     p_object_version_number          => l_object_version_number,
                     p_effective_date                 => p_effective_date       );
                     --

                     if l_out_etd_result_id is null then
                       l_out_etd_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_etd_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DPNT_OTHR_PTIP_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DSBLD_STAT_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eds_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dsbld_stat_prte_id := l_parent_rec.elig_dsbld_stat_prte_id ;
                 --
                 for l_eds_rec in c_eds(l_parent_rec.elig_dsbld_stat_prte_id,l_mirror_src_entity_result_id,'EDS') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDS');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('REGISTERED_DISABLED',l_eds_rec.dsbld_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_eds_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eds_rec.effective_start_date
                      and l_eds_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDS',
                     p_information1     => l_eds_rec.elig_dsbld_stat_prte_id,
                     p_information2     => l_eds_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eds_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eds_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_eds_rec.dsbld_cd,
					p_information111     => l_eds_rec.eds_attribute1,
					p_information120     => l_eds_rec.eds_attribute10,
					p_information121     => l_eds_rec.eds_attribute11,
					p_information122     => l_eds_rec.eds_attribute12,
					p_information123     => l_eds_rec.eds_attribute13,
					p_information124     => l_eds_rec.eds_attribute14,
					p_information125     => l_eds_rec.eds_attribute15,
					p_information126     => l_eds_rec.eds_attribute16,
					p_information127     => l_eds_rec.eds_attribute17,
					p_information128     => l_eds_rec.eds_attribute18,
					p_information129     => l_eds_rec.eds_attribute19,
					p_information112     => l_eds_rec.eds_attribute2,
					p_information130     => l_eds_rec.eds_attribute20,
					p_information131     => l_eds_rec.eds_attribute21,
					p_information132     => l_eds_rec.eds_attribute22,
					p_information133     => l_eds_rec.eds_attribute23,
					p_information134     => l_eds_rec.eds_attribute24,
					p_information135     => l_eds_rec.eds_attribute25,
					p_information136     => l_eds_rec.eds_attribute26,
					p_information137     => l_eds_rec.eds_attribute27,
					p_information138     => l_eds_rec.eds_attribute28,
					p_information139     => l_eds_rec.eds_attribute29,
					p_information113     => l_eds_rec.eds_attribute3,
					p_information140     => l_eds_rec.eds_attribute30,
					p_information114     => l_eds_rec.eds_attribute4,
					p_information115     => l_eds_rec.eds_attribute5,
					p_information116     => l_eds_rec.eds_attribute6,
					p_information117     => l_eds_rec.eds_attribute7,
					p_information118     => l_eds_rec.eds_attribute8,
					p_information119     => l_eds_rec.eds_attribute9,
					p_information110     => l_eds_rec.eds_attribute_category,
					p_information263     => l_eds_rec.eligy_prfl_id,
					p_information12     => l_eds_rec.excld_flag,
					p_information260     => l_eds_rec.ordr_num,
                                        p_information265    => l_eds_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_eds_result_id is null then
                       l_out_eds_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eds_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DSBLD_STAT_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_EE_STAT_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ees_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_ee_stat_prte_id := l_parent_rec.elig_ee_stat_prte_id ;
                 --
                 for l_ees_rec in c_ees(l_parent_rec.elig_ee_stat_prte_id,l_mirror_src_entity_result_id,'EES' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EES');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_assignment_sts_type_name(l_ees_rec.assignment_status_type_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ees_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ees_rec.effective_start_date
                      and l_ees_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name1(l_ees_rec.assignment_status_type_id);
                   fetch c_get_mapping_name1 into l_mapping_name;
                   close c_get_mapping_name1;
                   --
                   l_mapping_id   := l_ees_rec.assignment_status_type_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EES',
                     p_information1     => l_ees_rec.elig_ee_stat_prte_id,
                     p_information2     => l_ees_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ees_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ees_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information111     => l_ees_rec.ees_attribute1,
					p_information120     => l_ees_rec.ees_attribute10,
					p_information121     => l_ees_rec.ees_attribute11,
					p_information122     => l_ees_rec.ees_attribute12,
					p_information123     => l_ees_rec.ees_attribute13,
					p_information124     => l_ees_rec.ees_attribute14,
					p_information125     => l_ees_rec.ees_attribute15,
					p_information126     => l_ees_rec.ees_attribute16,
					p_information127     => l_ees_rec.ees_attribute17,
					p_information128     => l_ees_rec.ees_attribute18,
					p_information129     => l_ees_rec.ees_attribute19,
					p_information112     => l_ees_rec.ees_attribute2,
					p_information130     => l_ees_rec.ees_attribute20,
					p_information131     => l_ees_rec.ees_attribute21,
					p_information132     => l_ees_rec.ees_attribute22,
					p_information133     => l_ees_rec.ees_attribute23,
					p_information134     => l_ees_rec.ees_attribute24,
					p_information135     => l_ees_rec.ees_attribute25,
					p_information136     => l_ees_rec.ees_attribute26,
					p_information137     => l_ees_rec.ees_attribute27,
					p_information138     => l_ees_rec.ees_attribute28,
					p_information139     => l_ees_rec.ees_attribute29,
					p_information113     => l_ees_rec.ees_attribute3,
					p_information140     => l_ees_rec.ees_attribute30,
					p_information114     => l_ees_rec.ees_attribute4,
					p_information115     => l_ees_rec.ees_attribute5,
					p_information116     => l_ees_rec.ees_attribute6,
					p_information117     => l_ees_rec.ees_attribute7,
					p_information118     => l_ees_rec.ees_attribute8,
					p_information119     => l_ees_rec.ees_attribute9,
					p_information110     => l_ees_rec.ees_attribute_category,
					p_information263     => l_ees_rec.eligy_prfl_id,
					p_information11     => l_ees_rec.excld_flag,
					p_information260     => l_ees_rec.ordr_num,
                              p_information166     => NULL, -- No ESD for Assignment Status
                                        p_information265    => l_ees_rec.object_version_number,
					p_information295    => l_ees_rec.criteria_score,
					p_information296    => l_ees_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ees_result_id is null then
                       l_out_ees_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ees_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_EE_STAT_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ENRLD_ANTHR_OIPL_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eei_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_enrld_anthr_oipl_id := l_parent_rec.elig_enrld_anthr_oipl_id ;
                 --
                 for l_eei_rec in c_eei(l_parent_rec.elig_enrld_anthr_oipl_id,l_mirror_src_entity_result_id,'EEI' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EEI');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_oipl_name(l_eei_rec.oipl_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_eei_rec.enrl_det_dt_cd,'BEN_ENRL_DET_DT')
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_eei_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eei_rec.effective_start_date
                      and l_eei_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EEI',
                     p_information1     => l_eei_rec.elig_enrld_anthr_oipl_id,
                     p_information2     => l_eei_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eei_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eei_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_eei_rec.eei_attribute1,
					p_information120     => l_eei_rec.eei_attribute10,
					p_information121     => l_eei_rec.eei_attribute11,
					p_information122     => l_eei_rec.eei_attribute12,
					p_information123     => l_eei_rec.eei_attribute13,
					p_information124     => l_eei_rec.eei_attribute14,
					p_information125     => l_eei_rec.eei_attribute15,
					p_information126     => l_eei_rec.eei_attribute16,
					p_information127     => l_eei_rec.eei_attribute17,
					p_information128     => l_eei_rec.eei_attribute18,
					p_information129     => l_eei_rec.eei_attribute19,
					p_information112     => l_eei_rec.eei_attribute2,
					p_information130     => l_eei_rec.eei_attribute20,
					p_information131     => l_eei_rec.eei_attribute21,
					p_information132     => l_eei_rec.eei_attribute22,
					p_information133     => l_eei_rec.eei_attribute23,
					p_information134     => l_eei_rec.eei_attribute24,
					p_information135     => l_eei_rec.eei_attribute25,
					p_information136     => l_eei_rec.eei_attribute26,
					p_information137     => l_eei_rec.eei_attribute27,
					p_information138     => l_eei_rec.eei_attribute28,
					p_information139     => l_eei_rec.eei_attribute29,
					p_information113     => l_eei_rec.eei_attribute3,
					p_information140     => l_eei_rec.eei_attribute30,
					p_information114     => l_eei_rec.eei_attribute4,
					p_information115     => l_eei_rec.eei_attribute5,
					p_information116     => l_eei_rec.eei_attribute6,
					p_information117     => l_eei_rec.eei_attribute7,
					p_information118     => l_eei_rec.eei_attribute8,
					p_information119     => l_eei_rec.eei_attribute9,
					p_information110     => l_eei_rec.eei_attribute_category,
					p_information263     => l_eei_rec.eligy_prfl_id,
					p_information12     => l_eei_rec.enrl_det_dt_cd,
					p_information11     => l_eei_rec.excld_flag,
					p_information258     => l_eei_rec.oipl_id,
					p_information261     => l_eei_rec.ordr_num,
                                        p_information265    => l_eei_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_eei_result_id is null then
                       l_out_eei_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eei_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ENRLD_ANTHR_OIPL_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ENRLD_ANTHR_PGM_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eeg_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_enrld_anthr_pgm_id := l_parent_rec.elig_enrld_anthr_pgm_id ;
                 --
                 for l_eeg_rec in c_eeg(l_parent_rec.elig_enrld_anthr_pgm_id,l_mirror_src_entity_result_id,'EEG' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EEG');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pgm_name(l_eeg_rec.pgm_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_eeg_rec.enrl_det_dt_cd,'BEN_ENRL_DET_DT')
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_eeg_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eeg_rec.effective_start_date
                      and l_eeg_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EEG',
                     p_information1     => l_eeg_rec.elig_enrld_anthr_pgm_id,
                     p_information2     => l_eeg_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eeg_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eeg_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
				    p_information111     => l_eeg_rec.eeg_attribute1,
					p_information120     => l_eeg_rec.eeg_attribute10,
					p_information121     => l_eeg_rec.eeg_attribute11,
					p_information122     => l_eeg_rec.eeg_attribute12,
					p_information123     => l_eeg_rec.eeg_attribute13,
					p_information124     => l_eeg_rec.eeg_attribute14,
					p_information125     => l_eeg_rec.eeg_attribute15,
					p_information126     => l_eeg_rec.eeg_attribute16,
					p_information127     => l_eeg_rec.eeg_attribute17,
					p_information128     => l_eeg_rec.eeg_attribute18,
					p_information129     => l_eeg_rec.eeg_attribute19,
					p_information112     => l_eeg_rec.eeg_attribute2,
					p_information130     => l_eeg_rec.eeg_attribute20,
					p_information131     => l_eeg_rec.eeg_attribute21,
					p_information132     => l_eeg_rec.eeg_attribute22,
					p_information133     => l_eeg_rec.eeg_attribute23,
					p_information134     => l_eeg_rec.eeg_attribute24,
					p_information135     => l_eeg_rec.eeg_attribute25,
					p_information136     => l_eeg_rec.eeg_attribute26,
					p_information137     => l_eeg_rec.eeg_attribute27,
					p_information138     => l_eeg_rec.eeg_attribute28,
					p_information139     => l_eeg_rec.eeg_attribute29,
					p_information113     => l_eeg_rec.eeg_attribute3,
					p_information140     => l_eeg_rec.eeg_attribute30,
					p_information114     => l_eeg_rec.eeg_attribute4,
					p_information115     => l_eeg_rec.eeg_attribute5,
					p_information116     => l_eeg_rec.eeg_attribute6,
					p_information117     => l_eeg_rec.eeg_attribute7,
					p_information118     => l_eeg_rec.eeg_attribute8,
					p_information119     => l_eeg_rec.eeg_attribute9,
					p_information110     => l_eeg_rec.eeg_attribute_category,
					p_information263     => l_eeg_rec.eligy_prfl_id,
					p_information11     => l_eeg_rec.enrl_det_dt_cd,
					p_information12     => l_eeg_rec.excld_flag,
					p_information261     => l_eeg_rec.ordr_num,
					p_information260     => l_eeg_rec.pgm_id,
                                        p_information265    => l_eeg_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_eeg_result_id is null then
                       l_out_eeg_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eeg_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ENRLD_ANTHR_PGM_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ENRLD_ANTHR_PLIP_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eai_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_enrld_anthr_plip_id := l_parent_rec.elig_enrld_anthr_plip_id ;
                 --
                 for l_eai_rec in c_eai(l_parent_rec.elig_enrld_anthr_plip_id,l_mirror_src_entity_result_id,'EAI' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EAI');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_plip_name(l_eai_rec.plip_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_eai_rec.enrl_det_dt_cd,'BEN_ENRL_DET_DT')
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_eai_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eai_rec.effective_start_date
                      and l_eai_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
                     P_TABLE_ALIAS                    => 'EAI',
                     p_information1     => l_eai_rec.elig_enrld_anthr_plip_id,
                     p_information2     => l_eai_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eai_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eai_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_eai_rec.eai_attribute1,
					p_information120     => l_eai_rec.eai_attribute10,
					p_information121     => l_eai_rec.eai_attribute11,
					p_information122     => l_eai_rec.eai_attribute12,
					p_information123     => l_eai_rec.eai_attribute13,
					p_information124     => l_eai_rec.eai_attribute14,
					p_information125     => l_eai_rec.eai_attribute15,
					p_information126     => l_eai_rec.eai_attribute16,
					p_information127     => l_eai_rec.eai_attribute17,
					p_information128     => l_eai_rec.eai_attribute18,
					p_information129     => l_eai_rec.eai_attribute19,
					p_information112     => l_eai_rec.eai_attribute2,
					p_information130     => l_eai_rec.eai_attribute20,
					p_information131     => l_eai_rec.eai_attribute21,
					p_information132     => l_eai_rec.eai_attribute22,
					p_information133     => l_eai_rec.eai_attribute23,
					p_information134     => l_eai_rec.eai_attribute24,
					p_information135     => l_eai_rec.eai_attribute25,
					p_information136     => l_eai_rec.eai_attribute26,
					p_information137     => l_eai_rec.eai_attribute27,
					p_information138     => l_eai_rec.eai_attribute28,
					p_information139     => l_eai_rec.eai_attribute29,
					p_information113     => l_eai_rec.eai_attribute3,
					p_information140     => l_eai_rec.eai_attribute30,
					p_information114     => l_eai_rec.eai_attribute4,
					p_information115     => l_eai_rec.eai_attribute5,
					p_information116     => l_eai_rec.eai_attribute6,
					p_information117     => l_eai_rec.eai_attribute7,
					p_information118     => l_eai_rec.eai_attribute8,
					p_information119     => l_eai_rec.eai_attribute9,
					p_information110     => l_eai_rec.eai_attribute_category,
					p_information263     => l_eai_rec.eligy_prfl_id,
					p_information12     => l_eai_rec.enrl_det_dt_cd,
					p_information11     => l_eai_rec.excld_flag,
					p_information260     => l_eai_rec.ordr_num,
					p_information256     => l_eai_rec.plip_id,
                                        p_information265    => l_eai_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
            --

                     if l_out_eai_result_id is null then
                       l_out_eai_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eai_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ENRLD_ANTHR_PLIP_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ENRLD_ANTHR_PL_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eep_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_enrld_anthr_pl_id := l_parent_rec.elig_enrld_anthr_pl_id ;
                 --
                 for l_eep_rec in c_eep(l_parent_rec.elig_enrld_anthr_pl_id,l_mirror_src_entity_result_id,'EEP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EEP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  :=ben_plan_design_program_module.get_pl_name(l_eep_rec.pl_id,p_effective_date)
                                     --
                                     -- Bug No: 3451872
                                     --
                                     || ' '
                                     || get_det_enrl_det_dt_name(l_eep_rec.enrl_det_dt_cd,'BEN_ENRL_DET_DT')
                                     --
                                     || ben_plan_design_program_module.get_exclude_message(l_eep_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eep_rec.effective_start_date
                      and l_eep_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EEP',
                     p_information1     => l_eep_rec.elig_enrld_anthr_pl_id,
                     p_information2     => l_eep_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eep_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eep_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_eep_rec.eep_attribute1,
					p_information120     => l_eep_rec.eep_attribute10,
					p_information121     => l_eep_rec.eep_attribute11,
					p_information122     => l_eep_rec.eep_attribute12,
					p_information123     => l_eep_rec.eep_attribute13,
					p_information124     => l_eep_rec.eep_attribute14,
					p_information125     => l_eep_rec.eep_attribute15,
					p_information126     => l_eep_rec.eep_attribute16,
					p_information127     => l_eep_rec.eep_attribute17,
					p_information128     => l_eep_rec.eep_attribute18,
					p_information129     => l_eep_rec.eep_attribute19,
					p_information112     => l_eep_rec.eep_attribute2,
					p_information130     => l_eep_rec.eep_attribute20,
					p_information131     => l_eep_rec.eep_attribute21,
					p_information132     => l_eep_rec.eep_attribute22,
					p_information133     => l_eep_rec.eep_attribute23,
					p_information134     => l_eep_rec.eep_attribute24,
					p_information135     => l_eep_rec.eep_attribute25,
					p_information136     => l_eep_rec.eep_attribute26,
					p_information137     => l_eep_rec.eep_attribute27,
					p_information138     => l_eep_rec.eep_attribute28,
					p_information139     => l_eep_rec.eep_attribute29,
					p_information113     => l_eep_rec.eep_attribute3,
					p_information140     => l_eep_rec.eep_attribute30,
					p_information114     => l_eep_rec.eep_attribute4,
					p_information115     => l_eep_rec.eep_attribute5,
					p_information116     => l_eep_rec.eep_attribute6,
					p_information117     => l_eep_rec.eep_attribute7,
					p_information118     => l_eep_rec.eep_attribute8,
					p_information119     => l_eep_rec.eep_attribute9,
					p_information110     => l_eep_rec.eep_attribute_category,
					p_information263     => l_eep_rec.eligy_prfl_id,
					p_information11     => l_eep_rec.enrl_det_dt_cd,
					p_information12     => l_eep_rec.excld_flag,
					p_information260     => l_eep_rec.ordr_num,
					p_information261     => l_eep_rec.pl_id,
                                        p_information265    => l_eep_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eep_result_id is null then
                       l_out_eep_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eep_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ENRLD_ANTHR_PL_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ENRLD_ANTHR_PTIP_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eet_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_enrld_anthr_ptip_id := l_parent_rec.elig_enrld_anthr_ptip_id ;
                 --
                 for l_eet_rec in c_eet(l_parent_rec.elig_enrld_anthr_ptip_id,l_mirror_src_entity_result_id,'EET' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EET');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_ptip_name(l_eet_rec.ptip_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || ' '
                                      || get_det_enrl_det_dt_name(l_eet_rec.enrl_det_dt_cd,'BEN_ENRL_DET_DT')
                                      || get_subj_to_cobra_message(l_eet_rec.only_pls_subj_cobra_flag)
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_eet_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eet_rec.effective_start_date
                      and l_eet_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EET',
                     p_information1     => l_eet_rec.elig_enrld_anthr_ptip_id,
                     p_information2     => l_eet_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eet_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eet_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_eet_rec.eet_attribute1,
					p_information120     => l_eet_rec.eet_attribute10,
					p_information121     => l_eet_rec.eet_attribute11,
					p_information122     => l_eet_rec.eet_attribute12,
					p_information123     => l_eet_rec.eet_attribute13,
					p_information124     => l_eet_rec.eet_attribute14,
					p_information125     => l_eet_rec.eet_attribute15,
					p_information126     => l_eet_rec.eet_attribute16,
					p_information127     => l_eet_rec.eet_attribute17,
					p_information128     => l_eet_rec.eet_attribute18,
					p_information129     => l_eet_rec.eet_attribute19,
					p_information112     => l_eet_rec.eet_attribute2,
					p_information130     => l_eet_rec.eet_attribute20,
					p_information131     => l_eet_rec.eet_attribute21,
					p_information132     => l_eet_rec.eet_attribute22,
					p_information133     => l_eet_rec.eet_attribute23,
					p_information134     => l_eet_rec.eet_attribute24,
					p_information135     => l_eet_rec.eet_attribute25,
					p_information136     => l_eet_rec.eet_attribute26,
					p_information137     => l_eet_rec.eet_attribute27,
					p_information138     => l_eet_rec.eet_attribute28,
					p_information139     => l_eet_rec.eet_attribute29,
					p_information113     => l_eet_rec.eet_attribute3,
					p_information140     => l_eet_rec.eet_attribute30,
					p_information114     => l_eet_rec.eet_attribute4,
					p_information115     => l_eet_rec.eet_attribute5,
					p_information116     => l_eet_rec.eet_attribute6,
					p_information117     => l_eet_rec.eet_attribute7,
					p_information118     => l_eet_rec.eet_attribute8,
					p_information119     => l_eet_rec.eet_attribute9,
					p_information110     => l_eet_rec.eet_attribute_category,
					p_information263     => l_eet_rec.eligy_prfl_id,
					p_information13     => l_eet_rec.enrl_det_dt_cd,
					p_information11     => l_eet_rec.excld_flag,
					p_information12     => l_eet_rec.only_pls_subj_cobra_flag,
					p_information261     => l_eet_rec.ordr_num,
					p_information259     => l_eet_rec.ptip_id,
                                        p_information265    => l_eet_rec.object_version_number,

				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eet_result_id is null then
                       l_out_eet_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eet_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ENRLD_ANTHR_PTIP_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_FL_TM_PT_TM_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_efp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_fl_tm_pt_tm_prte_id := l_parent_rec.elig_fl_tm_pt_tm_prte_id ;
                 --
                 for l_efp_rec in c_efp(l_parent_rec.elig_fl_tm_pt_tm_prte_id,l_mirror_src_entity_result_id,'EFP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EFP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('EMP_CAT',l_efp_rec.fl_tm_pt_tm_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_efp_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_efp_rec.effective_start_date
                      and l_efp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EFP',
                     p_information1     => l_efp_rec.elig_fl_tm_pt_tm_prte_id,
                     p_information2     => l_efp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_efp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_efp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_efp_rec.efp_attribute1,
					p_information120     => l_efp_rec.efp_attribute10,
					p_information121     => l_efp_rec.efp_attribute11,
					p_information122     => l_efp_rec.efp_attribute12,
					p_information123     => l_efp_rec.efp_attribute13,
					p_information124     => l_efp_rec.efp_attribute14,
					p_information125     => l_efp_rec.efp_attribute15,
					p_information126     => l_efp_rec.efp_attribute16,
					p_information127     => l_efp_rec.efp_attribute17,
					p_information128     => l_efp_rec.efp_attribute18,
					p_information129     => l_efp_rec.efp_attribute19,
					p_information112     => l_efp_rec.efp_attribute2,
					p_information130     => l_efp_rec.efp_attribute20,
					p_information131     => l_efp_rec.efp_attribute21,
					p_information132     => l_efp_rec.efp_attribute22,
					p_information133     => l_efp_rec.efp_attribute23,
					p_information134     => l_efp_rec.efp_attribute24,
					p_information135     => l_efp_rec.efp_attribute25,
					p_information136     => l_efp_rec.efp_attribute26,
					p_information137     => l_efp_rec.efp_attribute27,
					p_information138     => l_efp_rec.efp_attribute28,
					p_information139     => l_efp_rec.efp_attribute29,
					p_information113     => l_efp_rec.efp_attribute3,
					p_information140     => l_efp_rec.efp_attribute30,
					p_information114     => l_efp_rec.efp_attribute4,
					p_information115     => l_efp_rec.efp_attribute5,
					p_information116     => l_efp_rec.efp_attribute6,
					p_information117     => l_efp_rec.efp_attribute7,
					p_information118     => l_efp_rec.efp_attribute8,
					p_information119     => l_efp_rec.efp_attribute9,
					p_information110     => l_efp_rec.efp_attribute_category,
					p_information263     => l_efp_rec.eligy_prfl_id,
					p_information11     => l_efp_rec.excld_flag,
					p_information12     => l_efp_rec.fl_tm_pt_tm_cd,
					p_information260     => l_efp_rec.ordr_num,
                                        p_information265    => l_efp_rec.object_version_number,
					p_information295    => l_efp_rec.criteria_score,
					p_information296    => l_efp_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_efp_result_id is null then
                       l_out_efp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_efp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_FL_TM_PT_TM_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_GRD_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_egr_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_grd_prte_id := l_parent_rec.elig_grd_prte_id ;
                 --
                 for l_egr_rec in c_egr(l_parent_rec.elig_grd_prte_id,l_mirror_src_entity_result_id,'EGR' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EGR');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_grade_name(l_egr_rec.grade_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_egr_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_egr_rec.effective_start_date
                      and l_egr_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;


                   -- To store effective_start_date of grade
                   -- for Mapping - Bug 2958658
                   --
                   l_grade_start_date := null;
                   if l_egr_rec.grade_id is not null then
                     open c_grade_start_date(l_egr_rec.grade_id);
                     fetch c_grade_start_date into l_grade_start_date;
                     close c_grade_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name2(l_egr_rec.grade_id,NVL(l_grade_start_date,p_effective_date));
                   fetch c_get_mapping_name2 into l_mapping_name;
                   close c_get_mapping_name2;
                   --
                   l_mapping_id   := l_egr_rec.grade_id;
                   --
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EGR',
                     p_information1     => l_egr_rec.elig_grd_prte_id,
                     p_information2     => l_egr_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_egr_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_egr_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_egr_rec.egr_attribute1,
					p_information120     => l_egr_rec.egr_attribute10,
					p_information121     => l_egr_rec.egr_attribute11,
					p_information122     => l_egr_rec.egr_attribute12,
					p_information123     => l_egr_rec.egr_attribute13,
					p_information124     => l_egr_rec.egr_attribute14,
					p_information125     => l_egr_rec.egr_attribute15,
					p_information126     => l_egr_rec.egr_attribute16,
					p_information127     => l_egr_rec.egr_attribute17,
					p_information128     => l_egr_rec.egr_attribute18,
					p_information129     => l_egr_rec.egr_attribute19,
					p_information112     => l_egr_rec.egr_attribute2,
					p_information130     => l_egr_rec.egr_attribute20,
					p_information131     => l_egr_rec.egr_attribute21,
					p_information132     => l_egr_rec.egr_attribute22,
					p_information133     => l_egr_rec.egr_attribute23,
					p_information134     => l_egr_rec.egr_attribute24,
					p_information135     => l_egr_rec.egr_attribute25,
					p_information136     => l_egr_rec.egr_attribute26,
					p_information137     => l_egr_rec.egr_attribute27,
					p_information138     => l_egr_rec.egr_attribute28,
					p_information139     => l_egr_rec.egr_attribute29,
					p_information113     => l_egr_rec.egr_attribute3,
					p_information140     => l_egr_rec.egr_attribute30,
					p_information114     => l_egr_rec.egr_attribute4,
					p_information115     => l_egr_rec.egr_attribute5,
					p_information116     => l_egr_rec.egr_attribute6,
					p_information117     => l_egr_rec.egr_attribute7,
					p_information118     => l_egr_rec.egr_attribute8,
					p_information119     => l_egr_rec.egr_attribute9,
					p_information110     => l_egr_rec.egr_attribute_category,
					p_information263     => l_egr_rec.eligy_prfl_id,
					p_information11     => l_egr_rec.excld_flag,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information260     => l_egr_rec.ordr_num,
                              p_information166     => l_grade_start_date,
                              p_information265     => l_egr_rec.object_version_number,
			      p_information295    => l_egr_rec.criteria_score,
			      p_information296    => l_egr_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_egr_result_id is null then
                       l_out_egr_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_egr_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_GRD_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_HRLY_SLRD_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ehs_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_hrly_slrd_prte_id := l_parent_rec.elig_hrly_slrd_prte_id ;
                 --
                 for l_ehs_rec in c_ehs(l_parent_rec.elig_hrly_slrd_prte_id,l_mirror_src_entity_result_id,'EHS' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EHS');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('HOURLY_SALARIED_CODE',l_ehs_rec.hrly_slrd_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_ehs_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ehs_rec.effective_start_date
                      and l_ehs_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EHS',
                     p_information1     => l_ehs_rec.elig_hrly_slrd_prte_id,
                     p_information2     => l_ehs_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ehs_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ehs_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_ehs_rec.ehs_attribute1,
					p_information120     => l_ehs_rec.ehs_attribute10,
					p_information121     => l_ehs_rec.ehs_attribute11,
					p_information122     => l_ehs_rec.ehs_attribute12,
					p_information123     => l_ehs_rec.ehs_attribute13,
					p_information124     => l_ehs_rec.ehs_attribute14,
					p_information125     => l_ehs_rec.ehs_attribute15,
					p_information126     => l_ehs_rec.ehs_attribute16,
					p_information127     => l_ehs_rec.ehs_attribute17,
					p_information128     => l_ehs_rec.ehs_attribute18,
					p_information129     => l_ehs_rec.ehs_attribute19,
					p_information112     => l_ehs_rec.ehs_attribute2,
					p_information130     => l_ehs_rec.ehs_attribute20,
					p_information131     => l_ehs_rec.ehs_attribute21,
					p_information132     => l_ehs_rec.ehs_attribute22,
					p_information133     => l_ehs_rec.ehs_attribute23,
					p_information134     => l_ehs_rec.ehs_attribute24,
					p_information135     => l_ehs_rec.ehs_attribute25,
					p_information136     => l_ehs_rec.ehs_attribute26,
					p_information137     => l_ehs_rec.ehs_attribute27,
					p_information138     => l_ehs_rec.ehs_attribute28,
					p_information139     => l_ehs_rec.ehs_attribute29,
					p_information113     => l_ehs_rec.ehs_attribute3,
					p_information140     => l_ehs_rec.ehs_attribute30,
					p_information114     => l_ehs_rec.ehs_attribute4,
					p_information115     => l_ehs_rec.ehs_attribute5,
					p_information116     => l_ehs_rec.ehs_attribute6,
					p_information117     => l_ehs_rec.ehs_attribute7,
					p_information118     => l_ehs_rec.ehs_attribute8,
					p_information119     => l_ehs_rec.ehs_attribute9,
					p_information110     => l_ehs_rec.ehs_attribute_category,
					p_information263     => l_ehs_rec.eligy_prfl_id,
					p_information12     => l_ehs_rec.excld_flag,
					p_information11     => l_ehs_rec.hrly_slrd_cd,
					p_information260     => l_ehs_rec.ordr_num,
                                        p_information265    => l_ehs_rec.object_version_number,
					p_information295    => l_ehs_rec.criteria_score,
					p_information296    => l_ehs_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ehs_result_id is null then
                       l_out_ehs_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ehs_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_HRLY_SLRD_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_HRS_WKD_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ehw_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_hrs_wkd_prte_id := l_parent_rec.elig_hrs_wkd_prte_id ;
                 --
                 for l_ehw_rec in c_ehw(l_parent_rec.elig_hrs_wkd_prte_id,l_mirror_src_entity_result_id,'EHW' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EHW');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_hrs_wkd_in_perd_fctr_name(l_ehw_rec.hrs_wkd_in_perd_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ehw_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ehw_rec.effective_start_date
                      and l_ehw_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EHW',
                     p_information1     => l_ehw_rec.elig_hrs_wkd_prte_id,
                     p_information2     => l_ehw_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ehw_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ehw_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_ehw_rec.ehw_attribute1,
					p_information120     => l_ehw_rec.ehw_attribute10,
					p_information121     => l_ehw_rec.ehw_attribute11,
					p_information122     => l_ehw_rec.ehw_attribute12,
					p_information123     => l_ehw_rec.ehw_attribute13,
					p_information124     => l_ehw_rec.ehw_attribute14,
					p_information125     => l_ehw_rec.ehw_attribute15,
					p_information126     => l_ehw_rec.ehw_attribute16,
					p_information127     => l_ehw_rec.ehw_attribute17,
					p_information128     => l_ehw_rec.ehw_attribute18,
					p_information129     => l_ehw_rec.ehw_attribute19,
					p_information112     => l_ehw_rec.ehw_attribute2,
					p_information130     => l_ehw_rec.ehw_attribute20,
					p_information131     => l_ehw_rec.ehw_attribute21,
					p_information132     => l_ehw_rec.ehw_attribute22,
					p_information133     => l_ehw_rec.ehw_attribute23,
					p_information134     => l_ehw_rec.ehw_attribute24,
					p_information135     => l_ehw_rec.ehw_attribute25,
					p_information136     => l_ehw_rec.ehw_attribute26,
					p_information137     => l_ehw_rec.ehw_attribute27,
					p_information138     => l_ehw_rec.ehw_attribute28,
					p_information139     => l_ehw_rec.ehw_attribute29,
					p_information113     => l_ehw_rec.ehw_attribute3,
					p_information140     => l_ehw_rec.ehw_attribute30,
					p_information114     => l_ehw_rec.ehw_attribute4,
					p_information115     => l_ehw_rec.ehw_attribute5,
					p_information116     => l_ehw_rec.ehw_attribute6,
					p_information117     => l_ehw_rec.ehw_attribute7,
					p_information118     => l_ehw_rec.ehw_attribute8,
					p_information119     => l_ehw_rec.ehw_attribute9,
					p_information110     => l_ehw_rec.ehw_attribute_category,
					p_information263     => l_ehw_rec.eligy_prfl_id,
					p_information11     => l_ehw_rec.excld_flag,
					p_information224     => l_ehw_rec.hrs_wkd_in_perd_fctr_id,
					p_information260     => l_ehw_rec.ordr_num,
                                        p_information265    => l_ehw_rec.object_version_number,
					p_information295    => l_ehw_rec.criteria_score,
					p_information296    => l_ehw_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ehw_result_id is null then
                       l_out_ehw_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ehw_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                 for l_ehw_rec in c_ehw_drp(l_parent_rec.elig_hrs_wkd_prte_id,l_mirror_src_entity_result_id,'EHW' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_ehw_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => l_ehw_rec.hrs_wkd_in_perd_fctr_id
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => null
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_HRS_WKD_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_JOB_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ejp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_job_prte_id := l_parent_rec.elig_job_prte_id ;
                 --
                 for l_ejp_rec in c_ejp(l_parent_rec.elig_job_prte_id,l_mirror_src_entity_result_id,'EJP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EJP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_job_name(l_ejp_rec.job_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ejp_rec.excld_flag); --'Intersection';
                   --
                   if p_effective_date between l_ejp_rec.effective_start_date
                      and l_ejp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of job
                   -- for Mapping - Bug 2958658
                   --
                   l_job_start_date := null;
                   if l_ejp_rec.job_id is not null then
                     open c_job_start_date(l_ejp_rec.job_id);
                     fetch c_job_start_date into l_job_start_date;
                     close c_job_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --
                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name3(l_ejp_rec.job_id,NVL(l_job_start_date,p_effective_date));
                   fetch c_get_mapping_name3 into l_mapping_name;
                   close c_get_mapping_name3;
                   --
                   l_mapping_id   := l_ejp_rec.job_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EJP',
                     p_information1     => l_ejp_rec.elig_job_prte_id,
                     p_information2     => l_ejp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ejp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ejp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_ejp_rec.ejp_attribute1,
					p_information120     => l_ejp_rec.ejp_attribute10,
					p_information121     => l_ejp_rec.ejp_attribute11,
					p_information122     => l_ejp_rec.ejp_attribute12,
					p_information123     => l_ejp_rec.ejp_attribute13,
					p_information124     => l_ejp_rec.ejp_attribute14,
					p_information125     => l_ejp_rec.ejp_attribute15,
					p_information126     => l_ejp_rec.ejp_attribute16,
					p_information127     => l_ejp_rec.ejp_attribute17,
					p_information128     => l_ejp_rec.ejp_attribute18,
					p_information129     => l_ejp_rec.ejp_attribute19,
					p_information112     => l_ejp_rec.ejp_attribute2,
					p_information130     => l_ejp_rec.ejp_attribute20,
					p_information131     => l_ejp_rec.ejp_attribute21,
					p_information132     => l_ejp_rec.ejp_attribute22,
					p_information133     => l_ejp_rec.ejp_attribute23,
					p_information134     => l_ejp_rec.ejp_attribute24,
					p_information135     => l_ejp_rec.ejp_attribute25,
					p_information136     => l_ejp_rec.ejp_attribute26,
					p_information137     => l_ejp_rec.ejp_attribute27,
					p_information138     => l_ejp_rec.ejp_attribute28,
					p_information139     => l_ejp_rec.ejp_attribute29,
					p_information113     => l_ejp_rec.ejp_attribute3,
					p_information140     => l_ejp_rec.ejp_attribute30,
					p_information114     => l_ejp_rec.ejp_attribute4,
					p_information115     => l_ejp_rec.ejp_attribute5,
					p_information116     => l_ejp_rec.ejp_attribute6,
					p_information117     => l_ejp_rec.ejp_attribute7,
					p_information118     => l_ejp_rec.ejp_attribute8,
					p_information119     => l_ejp_rec.ejp_attribute9,
					p_information110     => l_ejp_rec.ejp_attribute_category,
					p_information263     => l_ejp_rec.eligy_prfl_id,
					p_information11     => l_ejp_rec.excld_flag,
					p_information226     => l_ejp_rec.job_id,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information260     => l_ejp_rec.ordr_num,
                              p_information166     => l_job_start_date,
                              p_information265    => l_ejp_rec.object_version_number,
			      p_information295    => l_ejp_rec.criteria_score,
			      p_information296    => l_ejp_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ejp_result_id is null then
                       l_out_ejp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ejp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_JOB_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_LBR_MMBR_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_elu_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_lbr_mmbr_prte_id := l_parent_rec.elig_lbr_mmbr_prte_id ;
                 --
                 for l_elu_rec in c_elu(l_parent_rec.elig_lbr_mmbr_prte_id,l_mirror_src_entity_result_id,'ELU' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ELU');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_lbr_mmbr_name(l_elu_rec.lbr_mmbr_flag)
                                      || ben_plan_design_program_module.get_exclude_message(l_elu_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_elu_rec.effective_start_date
                      and l_elu_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ELU',
                     p_information1     => l_elu_rec.elig_lbr_mmbr_prte_id,
                     p_information2     => l_elu_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_elu_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_elu_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_elu_rec.eligy_prfl_id,
					p_information111     => l_elu_rec.elu_attribute1,
					p_information120     => l_elu_rec.elu_attribute10,
					p_information121     => l_elu_rec.elu_attribute11,
					p_information122     => l_elu_rec.elu_attribute12,
					p_information123     => l_elu_rec.elu_attribute13,
					p_information124     => l_elu_rec.elu_attribute14,
					p_information125     => l_elu_rec.elu_attribute15,
					p_information126     => l_elu_rec.elu_attribute16,
					p_information127     => l_elu_rec.elu_attribute17,
					p_information128     => l_elu_rec.elu_attribute18,
					p_information129     => l_elu_rec.elu_attribute19,
					p_information112     => l_elu_rec.elu_attribute2,
					p_information130     => l_elu_rec.elu_attribute20,
					p_information131     => l_elu_rec.elu_attribute21,
					p_information132     => l_elu_rec.elu_attribute22,
					p_information133     => l_elu_rec.elu_attribute23,
					p_information134     => l_elu_rec.elu_attribute24,
					p_information135     => l_elu_rec.elu_attribute25,
					p_information136     => l_elu_rec.elu_attribute26,
					p_information137     => l_elu_rec.elu_attribute27,
					p_information138     => l_elu_rec.elu_attribute28,
					p_information139     => l_elu_rec.elu_attribute29,
					p_information113     => l_elu_rec.elu_attribute3,
					p_information140     => l_elu_rec.elu_attribute30,
					p_information114     => l_elu_rec.elu_attribute4,
					p_information115     => l_elu_rec.elu_attribute5,
					p_information116     => l_elu_rec.elu_attribute6,
					p_information117     => l_elu_rec.elu_attribute7,
					p_information118     => l_elu_rec.elu_attribute8,
					p_information119     => l_elu_rec.elu_attribute9,
					p_information110     => l_elu_rec.elu_attribute_category,
					p_information11     => l_elu_rec.excld_flag,
					p_information12     => l_elu_rec.lbr_mmbr_flag,
					p_information260     => l_elu_rec.ordr_num,
                                        p_information265    => l_elu_rec.object_version_number,
					p_information295    => l_elu_rec.criteria_score,
					p_information296    => l_elu_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_elu_result_id is null then
                       l_out_elu_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_elu_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_LBR_MMBR_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_LGL_ENTY_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eln_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_lgl_enty_prte_id := l_parent_rec.elig_lgl_enty_prte_id ;
                 --
                 for l_eln_rec in c_eln(l_parent_rec.elig_lgl_enty_prte_id,l_mirror_src_entity_result_id,'ELN' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ELN');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_organization_name(l_eln_rec.organization_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_eln_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eln_rec.effective_start_date
                      and l_eln_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of organization
                   -- for Mapping - Bug 2958658
                   --
                   l_organization_start_date := null;
                   if l_eln_rec.organization_id is not null then
                     open c_organization_start_date(l_eln_rec.organization_id);
                     fetch c_organization_start_date into l_organization_start_date;
                     close c_organization_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name4(l_eln_rec.organization_id,NVL(l_organization_start_date,p_effective_date));
                   fetch c_get_mapping_name4 into l_mapping_name;
                   close c_get_mapping_name4;
                   --
                   l_mapping_id   := l_eln_rec.organization_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ELN',
                     p_information1     => l_eln_rec.elig_lgl_enty_prte_id,
                     p_information2     => l_eln_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eln_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eln_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_eln_rec.eligy_prfl_id,
					p_information111     => l_eln_rec.eln_attribute1,
					p_information120     => l_eln_rec.eln_attribute10,
					p_information121     => l_eln_rec.eln_attribute11,
					p_information122     => l_eln_rec.eln_attribute12,
					p_information123     => l_eln_rec.eln_attribute13,
					p_information124     => l_eln_rec.eln_attribute14,
					p_information125     => l_eln_rec.eln_attribute15,
					p_information126     => l_eln_rec.eln_attribute16,
					p_information127     => l_eln_rec.eln_attribute17,
					p_information128     => l_eln_rec.eln_attribute18,
					p_information129     => l_eln_rec.eln_attribute19,
					p_information112     => l_eln_rec.eln_attribute2,
					p_information130     => l_eln_rec.eln_attribute20,
					p_information131     => l_eln_rec.eln_attribute21,
					p_information132     => l_eln_rec.eln_attribute22,
					p_information133     => l_eln_rec.eln_attribute23,
					p_information134     => l_eln_rec.eln_attribute24,
					p_information135     => l_eln_rec.eln_attribute25,
					p_information136     => l_eln_rec.eln_attribute26,
					p_information137     => l_eln_rec.eln_attribute27,
					p_information138     => l_eln_rec.eln_attribute28,
					p_information139     => l_eln_rec.eln_attribute29,
					p_information113     => l_eln_rec.eln_attribute3,
					p_information140     => l_eln_rec.eln_attribute30,
					p_information114     => l_eln_rec.eln_attribute4,
					p_information115     => l_eln_rec.eln_attribute5,
					p_information116     => l_eln_rec.eln_attribute6,
					p_information117     => l_eln_rec.eln_attribute7,
					p_information118     => l_eln_rec.eln_attribute8,
					p_information119     => l_eln_rec.eln_attribute9,
					p_information110     => l_eln_rec.eln_attribute_category,
					p_information11     => l_eln_rec.excld_flag,
					p_information260     => l_eln_rec.ordr_num,
					p_information252     => l_eln_rec.organization_id,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166     => l_organization_start_date,
                              p_information265    => l_eln_rec.object_version_number,
			      p_information295    => l_eln_rec.criteria_score,
			      p_information296    => l_eln_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eln_result_id is null then
                       l_out_eln_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eln_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_LGL_ENTY_PRTE_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ELIG_COMPTNCY_PRTE_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_ecy_from_parent(l_ELIGY_PRFL_ID) loop
             --

                l_mirror_src_entity_result_id := l_out_elp_result_id ;

                --
                l_elig_comptncy_prte_id := l_parent_rec.elig_comptncy_prte_id ;
                --
                for l_ecy_rec in c_ecy(l_parent_rec.elig_comptncy_prte_id,l_mirror_src_entity_result_id,'ECY' ) loop
                  --
                  l_table_route_id := null ;
                  open ben_plan_design_program_module.g_table_route('ECY');
                  fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                  close ben_plan_design_program_module.g_table_route ;
                  --
                  l_information5  := ben_plan_design_program_module.get_competence_rating_name
                                     (l_ecy_rec.competence_id
                                     ,l_ecy_rec.rating_level_id)
                                     || ben_plan_design_program_module.get_exclude_message(l_ecy_rec.excld_flag);
                                      -- 'Intersection'
                  --
                  if p_effective_date between l_ecy_rec.effective_start_date
                     and l_ecy_rec.effective_end_date then
                   --
                     l_result_type_cd := 'DISPLAY';
                  else
                     l_result_type_cd := 'NO DISPLAY';
                  end if;
                  --

                  -- To store effective_start_date of competence
                  -- for Mapping - Bug 2958658
                  --
                  l_competence_start_date := null;
                  if l_ecy_rec.competence_id is not null then
                    open c_competence_start_date(l_ecy_rec.competence_id);
                    fetch c_competence_start_date into l_competence_start_date;
                    close c_competence_start_date;
                  end if;

                  --
                  -- pabodla : MAPPING DATA : Store the mapping column information.
                  --
                  l_mapping_name := null;
                  l_mapping_id   := null;
                  l_mapping_name1:= null;
                  l_mapping_id1  := null;
                  --
                  -- Get the competence and Rating name to display on mapping page.
                  --
                  -- 9999 needs review
                  open c_get_mapping_name16(l_ecy_rec.competence_id,NVL(l_competence_start_date,p_effective_date));
                  fetch c_get_mapping_name16 into l_mapping_name;
                  close c_get_mapping_name16;
                  --
                  l_mapping_id   := l_ecy_rec.competence_id;
                  --
                  open c_get_mapping_name17(l_ecy_rec.rating_level_id,
                                            p_business_group_id);
                  fetch c_get_mapping_name17 into l_mapping_name1;
                  close c_get_mapping_name17;
                  --
                  l_mapping_id1   := l_ecy_rec.rating_level_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --
                  hr_utility.set_location('l_mapping_id '||l_mapping_id,100);
                  hr_utility.set_location('l_mapping_name '||l_mapping_name,100);
                  hr_utility.set_location('l_mapping_id1 '||l_mapping_id1,100);
                  hr_utility.set_location('l_mapping_name1 '||l_mapping_name1,100);
                  --

                  l_copy_entity_result_id := null;
                  l_object_version_number := null;
                  ben_copy_entity_results_api.create_copy_entity_results(
                    p_copy_entity_result_id           => l_copy_entity_result_id,
                    p_copy_entity_txn_id             => p_copy_entity_txn_id,
                    p_result_type_cd                 => l_result_type_cd,
                    p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                    p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                    p_number_of_copies               => l_number_of_copies,
                    p_table_route_id                 => l_table_route_id,
		    P_TABLE_ALIAS                    => 'ECY',
                    p_information1     => l_ecy_rec.elig_comptncy_prte_id,
                    p_information2     => l_ecy_rec.EFFECTIVE_START_DATE,
                    p_information3     => l_ecy_rec.EFFECTIVE_END_DATE,
                    p_information4     => l_ecy_rec.business_group_id,
                    p_information5     => l_information5 , -- 9999 put name for h-grid
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information111     => l_ecy_rec.ecy_attribute1,
					p_information120     => l_ecy_rec.ecy_attribute10,
					p_information121     => l_ecy_rec.ecy_attribute11,
					p_information122     => l_ecy_rec.ecy_attribute12,
					p_information123     => l_ecy_rec.ecy_attribute13,
					p_information124     => l_ecy_rec.ecy_attribute14,
					p_information125     => l_ecy_rec.ecy_attribute15,
					p_information126     => l_ecy_rec.ecy_attribute16,
					p_information127     => l_ecy_rec.ecy_attribute17,
					p_information128     => l_ecy_rec.ecy_attribute18,
					p_information129     => l_ecy_rec.ecy_attribute19,
					p_information112     => l_ecy_rec.ecy_attribute2,
					p_information130     => l_ecy_rec.ecy_attribute20,
					p_information131     => l_ecy_rec.ecy_attribute21,
					p_information132     => l_ecy_rec.ecy_attribute22,
					p_information133     => l_ecy_rec.ecy_attribute23,
					p_information134     => l_ecy_rec.ecy_attribute24,
					p_information135     => l_ecy_rec.ecy_attribute25,
					p_information136     => l_ecy_rec.ecy_attribute26,
					p_information137     => l_ecy_rec.ecy_attribute27,
					p_information138     => l_ecy_rec.ecy_attribute28,
					p_information139     => l_ecy_rec.ecy_attribute29,
					p_information113     => l_ecy_rec.ecy_attribute3,
					p_information140     => l_ecy_rec.ecy_attribute30,
					p_information114     => l_ecy_rec.ecy_attribute4,
					p_information115     => l_ecy_rec.ecy_attribute5,
					p_information116     => l_ecy_rec.ecy_attribute6,
					p_information117     => l_ecy_rec.ecy_attribute7,
					p_information118     => l_ecy_rec.ecy_attribute8,
					p_information119     => l_ecy_rec.ecy_attribute9,
					p_information110     => l_ecy_rec.ecy_attribute_category,
					p_information263     => l_ecy_rec.eligy_prfl_id,
					p_information11     => l_ecy_rec.excld_flag,
					p_information257     => l_ecy_rec.ordr_num,
					-- Data for MAPPING columns.
					p_information177    => l_mapping_name1,
					p_information178    => l_mapping_id1,
					-- END other product Mapping columns.
                              p_information166     => l_competence_start_date,
                              p_information306     => NULL,  -- No ESD for Rating Level
                              p_information265    => l_ecy_rec.object_version_number,
			      p_information295    => l_ecy_rec.criteria_score,
			      p_information296    => l_ecy_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                    --

                    if l_out_ecy_result_id is null then
                      l_out_ecy_result_id := l_copy_entity_result_id;
                    end if;

                    if l_result_type_cd = 'DISPLAY' then
                       l_out_ecy_result_id := l_copy_entity_result_id ;
                    end if;
                    --
                 end loop;
                 --
               end loop;
            ---------------------------------------------------------------
            -- END OF BEN_ELIG_COMPTNCY_PRTE_F ----------------------
            ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_LOA_RSN_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_elr_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_loa_rsn_prte_id := l_parent_rec.elig_loa_rsn_prte_id ;
                 --
                 for l_elr_rec in c_elr(l_parent_rec.elig_loa_rsn_prte_id,l_mirror_src_entity_result_id,'ELR' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ELR');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_absence_type_name(l_elr_rec.absence_attendance_type_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_elr_rec.excld_flag);
                                      --'Intersection'
                   --
                   if p_effective_date between l_elr_rec.effective_start_date
                      and l_elr_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of absence_type
                   -- and absence_reason for Mapping - Bug 2958658
                   --
                   l_absence_type_start_date := null;
                   if l_elr_rec.absence_attendance_type_id is not null then
                     open c_absence_type_start_date(l_elr_rec.absence_attendance_type_id);
                     fetch c_absence_type_start_date into l_absence_type_start_date;
                     close c_absence_type_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --
                   l_mapping_name := null;
                   l_mapping_id   := null;
                   l_mapping_name1:= null;
                   l_mapping_id1  := null;
                   --
                   -- Get the Leave of Absence name to display on mapping page.
                   --
                   -- 9999 needs review
                   open c_get_mapping_name5(l_elr_rec.absence_attendance_type_id,NVL(l_absence_type_start_date,p_effective_date));
                   fetch c_get_mapping_name5 into l_mapping_name;
                   close c_get_mapping_name5;
                   --
                   l_mapping_id   := l_elr_rec.absence_attendance_type_id;
                   --
                   open c_get_mapping_name6(l_elr_rec.absence_attendance_type_id,
                                            l_elr_rec.abs_attendance_reason_id,
                                            NVL(l_absence_type_start_date,p_effective_date));
                   fetch c_get_mapping_name6 into l_mapping_name1;
                   close c_get_mapping_name6;
                   --
                   l_mapping_id1   := l_elr_rec.abs_attendance_reason_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
                     P_TABLE_ALIAS                    => 'ELR',
                     p_information1     => l_elr_rec.elig_loa_rsn_prte_id,
                     p_information2     => l_elr_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_elr_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_elr_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					-- Data for MAPPING columns.
					p_information177    => l_mapping_name1,
					p_information178    => l_mapping_id1,
					-- END other product Mapping columns.
					p_information263     => l_elr_rec.eligy_prfl_id,
					p_information111     => l_elr_rec.elr_attribute1,
					p_information120     => l_elr_rec.elr_attribute10,
					p_information121     => l_elr_rec.elr_attribute11,
					p_information122     => l_elr_rec.elr_attribute12,
					p_information123     => l_elr_rec.elr_attribute13,
					p_information124     => l_elr_rec.elr_attribute14,
					p_information125     => l_elr_rec.elr_attribute15,
					p_information126     => l_elr_rec.elr_attribute16,
					p_information127     => l_elr_rec.elr_attribute17,
					p_information128     => l_elr_rec.elr_attribute18,
					p_information129     => l_elr_rec.elr_attribute19,
					p_information112     => l_elr_rec.elr_attribute2,
					p_information130     => l_elr_rec.elr_attribute20,
					p_information131     => l_elr_rec.elr_attribute21,
					p_information132     => l_elr_rec.elr_attribute22,
					p_information133     => l_elr_rec.elr_attribute23,
					p_information134     => l_elr_rec.elr_attribute24,
					p_information135     => l_elr_rec.elr_attribute25,
					p_information136     => l_elr_rec.elr_attribute26,
					p_information137     => l_elr_rec.elr_attribute27,
					p_information138     => l_elr_rec.elr_attribute28,
					p_information139     => l_elr_rec.elr_attribute29,
					p_information113     => l_elr_rec.elr_attribute3,
					p_information140     => l_elr_rec.elr_attribute30,
					p_information114     => l_elr_rec.elr_attribute4,
					p_information115     => l_elr_rec.elr_attribute5,
					p_information116     => l_elr_rec.elr_attribute6,
					p_information117     => l_elr_rec.elr_attribute7,
					p_information118     => l_elr_rec.elr_attribute8,
					p_information119     => l_elr_rec.elr_attribute9,
					p_information110     => l_elr_rec.elr_attribute_category,
					p_information11     => l_elr_rec.excld_flag,
					p_information259     => l_elr_rec.ordr_num,
                              p_information166     => l_absence_type_start_date,
                              p_information306     => l_absence_type_start_date,
                              p_information265    => l_elr_rec.object_version_number,
			      p_information295    => l_elr_rec.criteria_score,
			      p_information296    => l_elr_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_elr_result_id is null then
                       l_out_elr_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_elr_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_LOA_RSN_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_LOS_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_els_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_los_prte_id := l_parent_rec.elig_los_prte_id ;
                 --
                 for l_els_rec in c_els(l_parent_rec.elig_los_prte_id,l_mirror_src_entity_result_id,'ELS') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ELS');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_los_fctr_name(l_els_rec.los_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_els_rec.excld_flag);
                                      --'Intersection'
                   --
                   if p_effective_date between l_els_rec.effective_start_date
                      and l_els_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ELS',
                     p_information1     => l_els_rec.elig_los_prte_id,
                     p_information2     => l_els_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_els_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_els_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_els_rec.eligy_prfl_id,
					p_information111     => l_els_rec.els_attribute1,
					p_information120     => l_els_rec.els_attribute10,
					p_information121     => l_els_rec.els_attribute11,
					p_information122     => l_els_rec.els_attribute12,
					p_information123     => l_els_rec.els_attribute13,
					p_information124     => l_els_rec.els_attribute14,
					p_information125     => l_els_rec.els_attribute15,
					p_information126     => l_els_rec.els_attribute16,
					p_information127     => l_els_rec.els_attribute17,
					p_information128     => l_els_rec.els_attribute18,
					p_information129     => l_els_rec.els_attribute19,
					p_information112     => l_els_rec.els_attribute2,
					p_information130     => l_els_rec.els_attribute20,
					p_information131     => l_els_rec.els_attribute21,
					p_information132     => l_els_rec.els_attribute22,
					p_information133     => l_els_rec.els_attribute23,
					p_information134     => l_els_rec.els_attribute24,
					p_information135     => l_els_rec.els_attribute25,
					p_information136     => l_els_rec.els_attribute26,
					p_information137     => l_els_rec.els_attribute27,
					p_information138     => l_els_rec.els_attribute28,
					p_information139     => l_els_rec.els_attribute29,
					p_information113     => l_els_rec.els_attribute3,
					p_information140     => l_els_rec.els_attribute30,
					p_information114     => l_els_rec.els_attribute4,
					p_information115     => l_els_rec.els_attribute5,
					p_information116     => l_els_rec.els_attribute6,
					p_information117     => l_els_rec.els_attribute7,
					p_information118     => l_els_rec.els_attribute8,
					p_information119     => l_els_rec.els_attribute9,
					p_information110     => l_els_rec.els_attribute_category,
					p_information11     => l_els_rec.excld_flag,
					p_information243     => l_els_rec.los_fctr_id,
					p_information260     => l_els_rec.ordr_num,
                                        p_information265    => l_els_rec.object_version_number,
					p_information295    => l_els_rec.criteria_score,
					p_information296    => l_els_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_els_result_id is null then
                       l_out_els_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_els_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                 for l_els_rec in c_els_drp(l_parent_rec.elig_los_prte_id,l_mirror_src_entity_result_id,'ELS' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_els_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => l_els_rec.los_fctr_id
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => null
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_LOS_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_LVG_RSN_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_elv_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_lvg_rsn_prte_id := l_parent_rec.elig_lvg_rsn_prte_id ;
                 --
                 for l_elv_rec in c_elv(l_parent_rec.elig_lvg_rsn_prte_id,l_mirror_src_entity_result_id,'ELV') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ELV');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('LEAV_REAS',l_elv_rec.lvg_rsn_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_elv_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_elv_rec.effective_start_date
                      and l_elv_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ELV',
                     p_information1     => l_elv_rec.elig_lvg_rsn_prte_id,
                     p_information2     => l_elv_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_elv_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_elv_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_elv_rec.eligy_prfl_id,
					p_information111     => l_elv_rec.elv_attribute1,
					p_information120     => l_elv_rec.elv_attribute10,
					p_information121     => l_elv_rec.elv_attribute11,
					p_information122     => l_elv_rec.elv_attribute12,
					p_information123     => l_elv_rec.elv_attribute13,
					p_information124     => l_elv_rec.elv_attribute14,
					p_information125     => l_elv_rec.elv_attribute15,
					p_information126     => l_elv_rec.elv_attribute16,
					p_information127     => l_elv_rec.elv_attribute17,
					p_information128     => l_elv_rec.elv_attribute18,
					p_information129     => l_elv_rec.elv_attribute19,
					p_information112     => l_elv_rec.elv_attribute2,
					p_information130     => l_elv_rec.elv_attribute20,
					p_information131     => l_elv_rec.elv_attribute21,
					p_information132     => l_elv_rec.elv_attribute22,
					p_information133     => l_elv_rec.elv_attribute23,
					p_information134     => l_elv_rec.elv_attribute24,
					p_information135     => l_elv_rec.elv_attribute25,
					p_information136     => l_elv_rec.elv_attribute26,
					p_information137     => l_elv_rec.elv_attribute27,
					p_information138     => l_elv_rec.elv_attribute28,
					p_information139     => l_elv_rec.elv_attribute29,
					p_information113     => l_elv_rec.elv_attribute3,
					p_information140     => l_elv_rec.elv_attribute30,
					p_information114     => l_elv_rec.elv_attribute4,
					p_information115     => l_elv_rec.elv_attribute5,
					p_information116     => l_elv_rec.elv_attribute6,
					p_information117     => l_elv_rec.elv_attribute7,
					p_information118     => l_elv_rec.elv_attribute8,
					p_information119     => l_elv_rec.elv_attribute9,
					p_information110     => l_elv_rec.elv_attribute_category,
					p_information11     => l_elv_rec.excld_flag,
					p_information12     => l_elv_rec.lvg_rsn_cd,
					p_information260     => l_elv_rec.ordr_num,
                                        p_information265    => l_elv_rec.object_version_number,
					p_information295    => l_elv_rec.criteria_score,
					p_information296    => l_elv_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_elv_result_id is null then
                       l_out_elv_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_elv_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_LVG_RSN_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_NO_OTHR_CVG_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eno_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_no_othr_cvg_prte_id := l_parent_rec.elig_no_othr_cvg_prte_id ;
                 --
                 for l_eno_rec in c_eno(l_parent_rec.elig_no_othr_cvg_prte_id,l_mirror_src_entity_result_id,'ENO' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ENO');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('YES_NO',l_eno_rec.coord_ben_no_cvg_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eno_rec.effective_start_date
                      and l_eno_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ENO',
                     p_information1     => l_eno_rec.elig_no_othr_cvg_prte_id,
                     p_information2     => l_eno_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eno_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eno_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_eno_rec.coord_ben_no_cvg_flag,
					p_information263     => l_eno_rec.eligy_prfl_id,
					p_information111     => l_eno_rec.eno_attribute1,
					p_information120     => l_eno_rec.eno_attribute10,
					p_information121     => l_eno_rec.eno_attribute11,
					p_information122     => l_eno_rec.eno_attribute12,
					p_information123     => l_eno_rec.eno_attribute13,
					p_information124     => l_eno_rec.eno_attribute14,
					p_information125     => l_eno_rec.eno_attribute15,
					p_information126     => l_eno_rec.eno_attribute16,
					p_information127     => l_eno_rec.eno_attribute17,
					p_information128     => l_eno_rec.eno_attribute18,
					p_information129     => l_eno_rec.eno_attribute19,
					p_information112     => l_eno_rec.eno_attribute2,
					p_information130     => l_eno_rec.eno_attribute20,
					p_information131     => l_eno_rec.eno_attribute21,
					p_information132     => l_eno_rec.eno_attribute22,
					p_information133     => l_eno_rec.eno_attribute23,
					p_information134     => l_eno_rec.eno_attribute24,
					p_information135     => l_eno_rec.eno_attribute25,
					p_information136     => l_eno_rec.eno_attribute26,
					p_information137     => l_eno_rec.eno_attribute27,
					p_information138     => l_eno_rec.eno_attribute28,
					p_information139     => l_eno_rec.eno_attribute29,
					p_information113     => l_eno_rec.eno_attribute3,
					p_information140     => l_eno_rec.eno_attribute30,
					p_information114     => l_eno_rec.eno_attribute4,
					p_information115     => l_eno_rec.eno_attribute5,
					p_information116     => l_eno_rec.eno_attribute6,
					p_information117     => l_eno_rec.eno_attribute7,
					p_information118     => l_eno_rec.eno_attribute8,
					p_information119     => l_eno_rec.eno_attribute9,
					p_information110     => l_eno_rec.eno_attribute_category,
                                        p_information265    => l_eno_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eno_result_id is null then
                       l_out_eno_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eno_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_NO_OTHR_CVG_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_OPTD_MDCR_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eom_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_optd_mdcr_prte_id := l_parent_rec.elig_optd_mdcr_prte_id ;
                 --
                 for l_eom_rec in c_eom(l_parent_rec.elig_optd_mdcr_prte_id,l_mirror_src_entity_result_id,'EOM' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EOM');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('YES_NO',l_eom_rec.optd_mdcr_flag)
                                      || ben_plan_design_program_module.get_exclude_message(l_eom_rec.exlcd_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eom_rec.effective_start_date
                      and l_eom_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EOM',
                     p_information1     => l_eom_rec.elig_optd_mdcr_prte_id,
                     p_information2     => l_eom_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eom_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eom_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_eom_rec.eligy_prfl_id,
					p_information111     => l_eom_rec.eom_attribute1,
					p_information120     => l_eom_rec.eom_attribute10,
					p_information121     => l_eom_rec.eom_attribute11,
					p_information122     => l_eom_rec.eom_attribute12,
					p_information123     => l_eom_rec.eom_attribute13,
					p_information124     => l_eom_rec.eom_attribute14,
					p_information125     => l_eom_rec.eom_attribute15,
					p_information126     => l_eom_rec.eom_attribute16,
					p_information127     => l_eom_rec.eom_attribute17,
					p_information128     => l_eom_rec.eom_attribute18,
					p_information129     => l_eom_rec.eom_attribute19,
					p_information112     => l_eom_rec.eom_attribute2,
					p_information130     => l_eom_rec.eom_attribute20,
					p_information131     => l_eom_rec.eom_attribute21,
					p_information132     => l_eom_rec.eom_attribute22,
					p_information133     => l_eom_rec.eom_attribute23,
					p_information134     => l_eom_rec.eom_attribute24,
					p_information135     => l_eom_rec.eom_attribute25,
					p_information136     => l_eom_rec.eom_attribute26,
					p_information137     => l_eom_rec.eom_attribute27,
					p_information138     => l_eom_rec.eom_attribute28,
					p_information139     => l_eom_rec.eom_attribute29,
					p_information113     => l_eom_rec.eom_attribute3,
					p_information140     => l_eom_rec.eom_attribute30,
					p_information114     => l_eom_rec.eom_attribute4,
					p_information115     => l_eom_rec.eom_attribute5,
					p_information116     => l_eom_rec.eom_attribute6,
					p_information117     => l_eom_rec.eom_attribute7,
					p_information118     => l_eom_rec.eom_attribute8,
					p_information119     => l_eom_rec.eom_attribute9,
					p_information110     => l_eom_rec.eom_attribute_category,
					p_information12     => l_eom_rec.exlcd_flag,
					p_information11     => l_eom_rec.optd_mdcr_flag,
                                        p_information265    => l_eom_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eom_result_id is null then
                       l_out_eom_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eom_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_OPTD_MDCR_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_ORG_UNIT_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eou_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_org_unit_prte_id := l_parent_rec.elig_org_unit_prte_id ;
                 --
                 for l_eou_rec in c_eou(l_parent_rec.elig_org_unit_prte_id,l_mirror_src_entity_result_id,'EOU' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EOU');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_organization_name(l_eou_rec.organization_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_eou_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eou_rec.effective_start_date
                      and l_eou_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of organization
                   -- for Mapping - Bug 2958658
                   --
                   l_organization_start_date := null;
                   if l_eou_rec.organization_id is not null then
                     open c_organization_start_date(l_eou_rec.organization_id);
                     fetch c_organization_start_date into l_organization_start_date;
                     close c_organization_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name7(l_eou_rec.organization_id,NVL(l_organization_start_date,p_effective_date));
                   fetch c_get_mapping_name7 into l_mapping_name;
                   close c_get_mapping_name7;
                   --
                   l_mapping_id   := l_eou_rec.organization_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EOU',
                     p_information1     => l_eou_rec.elig_org_unit_prte_id,
                     p_information2     => l_eou_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eou_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eou_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_eou_rec.eligy_prfl_id,
					p_information111     => l_eou_rec.eou_attribute1,
					p_information120     => l_eou_rec.eou_attribute10,
					p_information121     => l_eou_rec.eou_attribute11,
					p_information122     => l_eou_rec.eou_attribute12,
					p_information123     => l_eou_rec.eou_attribute13,
					p_information124     => l_eou_rec.eou_attribute14,
					p_information125     => l_eou_rec.eou_attribute15,
					p_information126     => l_eou_rec.eou_attribute16,
					p_information127     => l_eou_rec.eou_attribute17,
					p_information128     => l_eou_rec.eou_attribute18,
					p_information129     => l_eou_rec.eou_attribute19,
					p_information112     => l_eou_rec.eou_attribute2,
					p_information130     => l_eou_rec.eou_attribute20,
					p_information131     => l_eou_rec.eou_attribute21,
					p_information132     => l_eou_rec.eou_attribute22,
					p_information133     => l_eou_rec.eou_attribute23,
					p_information134     => l_eou_rec.eou_attribute24,
					p_information135     => l_eou_rec.eou_attribute25,
					p_information136     => l_eou_rec.eou_attribute26,
					p_information137     => l_eou_rec.eou_attribute27,
					p_information138     => l_eou_rec.eou_attribute28,
					p_information139     => l_eou_rec.eou_attribute29,
					p_information113     => l_eou_rec.eou_attribute3,
					p_information140     => l_eou_rec.eou_attribute30,
					p_information114     => l_eou_rec.eou_attribute4,
					p_information115     => l_eou_rec.eou_attribute5,
					p_information116     => l_eou_rec.eou_attribute6,
					p_information117     => l_eou_rec.eou_attribute7,
					p_information118     => l_eou_rec.eou_attribute8,
					p_information119     => l_eou_rec.eou_attribute9,
					p_information110     => l_eou_rec.eou_attribute_category,
					p_information11     => l_eou_rec.excld_flag,
					p_information260     => l_eou_rec.ordr_num,
					p_information252     => l_eou_rec.organization_id,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166     => l_organization_start_date,
                              p_information265    => l_eou_rec.object_version_number,
			      p_information295    => l_eou_rec.criteria_score,
			      p_information296    => l_eou_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eou_result_id is null then
                       l_out_eou_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eou_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_ORG_UNIT_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_OTHR_PTIP_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eoy_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_othr_ptip_prte_id := l_parent_rec.elig_othr_ptip_prte_id ;
                 --
                 for l_eoy_rec in c_eoy(l_parent_rec.elig_othr_ptip_prte_id,l_mirror_src_entity_result_id,'EOY' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EOY');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_ptip_name(l_eoy_rec.ptip_id,p_effective_date)
                                      --
                                      -- Bug No: 3451872
                                      --
                                      || get_subj_to_cobra_message(l_eoy_rec.only_pls_subj_cobra_flag)
                                      --
                                      || ben_plan_design_program_module.get_exclude_message(l_eoy_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eoy_rec.effective_start_date
                      and l_eoy_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EOY',
                     p_information1     => l_eoy_rec.elig_othr_ptip_prte_id,
                     p_information2     => l_eoy_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eoy_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eoy_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_eoy_rec.eligy_prfl_id,
					p_information111     => l_eoy_rec.eoy_attribute1,
					p_information120     => l_eoy_rec.eoy_attribute10,
					p_information121     => l_eoy_rec.eoy_attribute11,
					p_information122     => l_eoy_rec.eoy_attribute12,
					p_information123     => l_eoy_rec.eoy_attribute13,
					p_information124     => l_eoy_rec.eoy_attribute14,
					p_information125     => l_eoy_rec.eoy_attribute15,
					p_information126     => l_eoy_rec.eoy_attribute16,
					p_information127     => l_eoy_rec.eoy_attribute17,
					p_information128     => l_eoy_rec.eoy_attribute18,
					p_information129     => l_eoy_rec.eoy_attribute19,
					p_information112     => l_eoy_rec.eoy_attribute2,
					p_information130     => l_eoy_rec.eoy_attribute20,
					p_information131     => l_eoy_rec.eoy_attribute21,
					p_information132     => l_eoy_rec.eoy_attribute22,
					p_information133     => l_eoy_rec.eoy_attribute23,
					p_information134     => l_eoy_rec.eoy_attribute24,
					p_information135     => l_eoy_rec.eoy_attribute25,
					p_information136     => l_eoy_rec.eoy_attribute26,
					p_information137     => l_eoy_rec.eoy_attribute27,
					p_information138     => l_eoy_rec.eoy_attribute28,
					p_information139     => l_eoy_rec.eoy_attribute29,
					p_information113     => l_eoy_rec.eoy_attribute3,
					p_information140     => l_eoy_rec.eoy_attribute30,
					p_information114     => l_eoy_rec.eoy_attribute4,
					p_information115     => l_eoy_rec.eoy_attribute5,
					p_information116     => l_eoy_rec.eoy_attribute6,
					p_information117     => l_eoy_rec.eoy_attribute7,
					p_information118     => l_eoy_rec.eoy_attribute8,
					p_information119     => l_eoy_rec.eoy_attribute9,
					p_information110     => l_eoy_rec.eoy_attribute_category,
					p_information11     => l_eoy_rec.excld_flag,
					p_information12     => l_eoy_rec.only_pls_subj_cobra_flag,
					p_information261     => l_eoy_rec.ordr_num,
					p_information259     => l_eoy_rec.ptip_id,
                                        p_information265    => l_eoy_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eoy_result_id is null then
                       l_out_eoy_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eoy_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_OTHR_PTIP_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PCT_FL_TM_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epf_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_pct_fl_tm_prte_id := l_parent_rec.elig_pct_fl_tm_prte_id ;
                 --
                 for l_epf_rec in c_epf(l_parent_rec.elig_pct_fl_tm_prte_id,l_mirror_src_entity_result_id,'EPF' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPF');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pct_fl_tm_fctr_name(l_epf_rec.pct_fl_tm_fctr_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_epf_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epf_rec.effective_start_date
                      and l_epf_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPF',
                     p_information1     => l_epf_rec.elig_pct_fl_tm_prte_id,
                     p_information2     => l_epf_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epf_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epf_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epf_rec.eligy_prfl_id,
					p_information111     => l_epf_rec.epf_attribute1,
					p_information120     => l_epf_rec.epf_attribute10,
					p_information121     => l_epf_rec.epf_attribute11,
					p_information122     => l_epf_rec.epf_attribute12,
					p_information123     => l_epf_rec.epf_attribute13,
					p_information124     => l_epf_rec.epf_attribute14,
					p_information125     => l_epf_rec.epf_attribute15,
					p_information126     => l_epf_rec.epf_attribute16,
					p_information127     => l_epf_rec.epf_attribute17,
					p_information128     => l_epf_rec.epf_attribute18,
					p_information129     => l_epf_rec.epf_attribute19,
					p_information112     => l_epf_rec.epf_attribute2,
					p_information130     => l_epf_rec.epf_attribute20,
					p_information131     => l_epf_rec.epf_attribute21,
					p_information132     => l_epf_rec.epf_attribute22,
					p_information133     => l_epf_rec.epf_attribute23,
					p_information134     => l_epf_rec.epf_attribute24,
					p_information135     => l_epf_rec.epf_attribute25,
					p_information136     => l_epf_rec.epf_attribute26,
					p_information137     => l_epf_rec.epf_attribute27,
					p_information138     => l_epf_rec.epf_attribute28,
					p_information139     => l_epf_rec.epf_attribute29,
					p_information113     => l_epf_rec.epf_attribute3,
					p_information140     => l_epf_rec.epf_attribute30,
					p_information114     => l_epf_rec.epf_attribute4,
					p_information115     => l_epf_rec.epf_attribute5,
					p_information116     => l_epf_rec.epf_attribute6,
					p_information117     => l_epf_rec.epf_attribute7,
					p_information118     => l_epf_rec.epf_attribute8,
					p_information119     => l_epf_rec.epf_attribute9,
					p_information110     => l_epf_rec.epf_attribute_category,
					p_information11     => l_epf_rec.excld_flag,
					p_information260     => l_epf_rec.ordr_num,
					p_information233     => l_epf_rec.pct_fl_tm_fctr_id,
                                        p_information265    => l_epf_rec.object_version_number,
					p_information295    => l_epf_rec.criteria_score,
					p_information296    => l_epf_rec.criteria_weight,

				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epf_result_id is null then
                       l_out_epf_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epf_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                 for l_epf_rec in c_epf_drp(l_parent_rec.elig_pct_fl_tm_prte_id,l_mirror_src_entity_result_id,'EPF' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_epf_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => l_epf_rec.pct_fl_tm_fctr_id
                       ,p_age_fctr_id                   => null
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PCT_FL_TM_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PER_TYP_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ept_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_per_typ_prte_id := l_parent_rec.elig_per_typ_prte_id ;
                 --
                 for l_ept_rec in c_ept(l_parent_rec.elig_per_typ_prte_id,l_mirror_src_entity_result_id,'EPT' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPT');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_person_type_name(l_ept_rec.person_type_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ept_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ept_rec.effective_start_date
                      and l_ept_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_person_type_name(l_ept_rec.person_type_id);
                   fetch c_get_person_type_name into l_mapping_name;
                   close c_get_person_type_name;
                   --
                   l_mapping_id   := l_ept_rec.person_type_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPT',
                     p_information1     => l_ept_rec.elig_per_typ_prte_id,
                     p_information2     => l_ept_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ept_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ept_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_ept_rec.eligy_prfl_id,
					p_information111     => l_ept_rec.ept_attribute1,
					p_information120     => l_ept_rec.ept_attribute10,
					p_information121     => l_ept_rec.ept_attribute11,
					p_information122     => l_ept_rec.ept_attribute12,
					p_information123     => l_ept_rec.ept_attribute13,
					p_information124     => l_ept_rec.ept_attribute14,
					p_information125     => l_ept_rec.ept_attribute15,
					p_information126     => l_ept_rec.ept_attribute16,
					p_information127     => l_ept_rec.ept_attribute17,
					p_information128     => l_ept_rec.ept_attribute18,
					p_information129     => l_ept_rec.ept_attribute19,
					p_information112     => l_ept_rec.ept_attribute2,
					p_information130     => l_ept_rec.ept_attribute20,
					p_information131     => l_ept_rec.ept_attribute21,
					p_information132     => l_ept_rec.ept_attribute22,
					p_information133     => l_ept_rec.ept_attribute23,
					p_information134     => l_ept_rec.ept_attribute24,
					p_information135     => l_ept_rec.ept_attribute25,
					p_information136     => l_ept_rec.ept_attribute26,
					p_information137     => l_ept_rec.ept_attribute27,
					p_information138     => l_ept_rec.ept_attribute28,
					p_information139     => l_ept_rec.ept_attribute29,
					p_information113     => l_ept_rec.ept_attribute3,
					p_information140     => l_ept_rec.ept_attribute30,
					p_information114     => l_ept_rec.ept_attribute4,
					p_information115     => l_ept_rec.ept_attribute5,
					p_information116     => l_ept_rec.ept_attribute6,
					p_information117     => l_ept_rec.ept_attribute7,
					p_information118     => l_ept_rec.ept_attribute8,
					p_information119     => l_ept_rec.ept_attribute9,
					p_information110     => l_ept_rec.ept_attribute_category,
					p_information11     => l_ept_rec.excld_flag,
					p_information260     => l_ept_rec.ordr_num,
					p_information12     => l_ept_rec.per_typ_cd,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166     => NULL, -- No ESD for Person Type
                                        p_information265    => l_ept_rec.object_version_number,
					p_information295    => l_ept_rec.criteria_score,
					p_information296    => l_ept_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ept_result_id is null then
                       l_out_ept_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ept_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PER_TYP_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PPL_GRP_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epg_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_ppl_grp_prte_id := l_parent_rec.elig_ppl_grp_prte_id ;
                 --
                 for l_epg_rec in c_epg(l_parent_rec.elig_ppl_grp_prte_id,l_mirror_src_entity_result_id,'EPG' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPG');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_people_group_name(l_epg_rec.people_group_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_epg_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epg_rec.effective_start_date
                      and l_epg_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPG',
                     p_information1     => l_epg_rec.elig_ppl_grp_prte_id,
                     p_information2     => l_epg_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epg_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epg_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epg_rec.eligy_prfl_id,
					p_information111     => l_epg_rec.epg_attribute1,
					p_information120     => l_epg_rec.epg_attribute10,
					p_information121     => l_epg_rec.epg_attribute11,
					p_information122     => l_epg_rec.epg_attribute12,
					p_information123     => l_epg_rec.epg_attribute13,
					p_information124     => l_epg_rec.epg_attribute14,
					p_information125     => l_epg_rec.epg_attribute15,
					p_information126     => l_epg_rec.epg_attribute16,
					p_information127     => l_epg_rec.epg_attribute17,
					p_information128     => l_epg_rec.epg_attribute18,
					p_information129     => l_epg_rec.epg_attribute19,
					p_information112     => l_epg_rec.epg_attribute2,
					p_information130     => l_epg_rec.epg_attribute20,
					p_information131     => l_epg_rec.epg_attribute21,
					p_information132     => l_epg_rec.epg_attribute22,
					p_information133     => l_epg_rec.epg_attribute23,
					p_information134     => l_epg_rec.epg_attribute24,
					p_information135     => l_epg_rec.epg_attribute25,
					p_information136     => l_epg_rec.epg_attribute26,
					p_information137     => l_epg_rec.epg_attribute27,
					p_information138     => l_epg_rec.epg_attribute28,
					p_information139     => l_epg_rec.epg_attribute29,
					p_information113     => l_epg_rec.epg_attribute3,
					p_information140     => l_epg_rec.epg_attribute30,
					p_information114     => l_epg_rec.epg_attribute4,
					p_information115     => l_epg_rec.epg_attribute5,
					p_information116     => l_epg_rec.epg_attribute6,
					p_information117     => l_epg_rec.epg_attribute7,
					p_information118     => l_epg_rec.epg_attribute8,
					p_information119     => l_epg_rec.epg_attribute9,
					p_information110     => l_epg_rec.epg_attribute_category,
					p_information11     => l_epg_rec.excld_flag,
					p_information257     => l_epg_rec.ordr_num,
					p_information261     => l_epg_rec.people_group_id,
                                        p_information265    => l_epg_rec.object_version_number,
					p_information295    => l_epg_rec.criteria_score,
					p_information296    => l_epg_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epg_result_id is null then
                       l_out_epg_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epg_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PPL_GRP_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PRTT_ANTHR_PL_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_prtt_anthr_pl_prte_id := l_parent_rec.elig_prtt_anthr_pl_prte_id ;
                 --
                 for l_epp_rec in c_epp(l_parent_rec.elig_prtt_anthr_pl_prte_id,l_mirror_src_entity_result_id,'EPP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pl_name(l_epp_rec.pl_id,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_epp_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epp_rec.effective_start_date
                      and l_epp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPP',
                     p_information1     => l_epp_rec.elig_prtt_anthr_pl_prte_id,
                     p_information2     => l_epp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epp_rec.eligy_prfl_id,
					p_information111     => l_epp_rec.epp_attribute1,
					p_information120     => l_epp_rec.epp_attribute10,
					p_information121     => l_epp_rec.epp_attribute11,
					p_information122     => l_epp_rec.epp_attribute12,
					p_information123     => l_epp_rec.epp_attribute13,
					p_information124     => l_epp_rec.epp_attribute14,
					p_information125     => l_epp_rec.epp_attribute15,
					p_information126     => l_epp_rec.epp_attribute16,
					p_information127     => l_epp_rec.epp_attribute17,
					p_information128     => l_epp_rec.epp_attribute18,
					p_information129     => l_epp_rec.epp_attribute19,
					p_information112     => l_epp_rec.epp_attribute2,
					p_information130     => l_epp_rec.epp_attribute20,
					p_information131     => l_epp_rec.epp_attribute21,
					p_information132     => l_epp_rec.epp_attribute22,
					p_information133     => l_epp_rec.epp_attribute23,
					p_information134     => l_epp_rec.epp_attribute24,
					p_information135     => l_epp_rec.epp_attribute25,
					p_information136     => l_epp_rec.epp_attribute26,
					p_information137     => l_epp_rec.epp_attribute27,
					p_information138     => l_epp_rec.epp_attribute28,
					p_information139     => l_epp_rec.epp_attribute29,
					p_information113     => l_epp_rec.epp_attribute3,
					p_information140     => l_epp_rec.epp_attribute30,
					p_information114     => l_epp_rec.epp_attribute4,
					p_information115     => l_epp_rec.epp_attribute5,
					p_information116     => l_epp_rec.epp_attribute6,
					p_information117     => l_epp_rec.epp_attribute7,
					p_information118     => l_epp_rec.epp_attribute8,
					p_information119     => l_epp_rec.epp_attribute9,
					p_information110     => l_epp_rec.epp_attribute_category,
					p_information11     => l_epp_rec.excld_flag,
					p_information260     => l_epp_rec.ordr_num,
					p_information261     => l_epp_rec.pl_id,
                                        p_information265    => l_epp_rec.object_version_number,
					--p_information295     => l_epp_rec.criteria_score,
					--p_information296     => l_epp_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epp_result_id is null then
                       l_out_epp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PRTT_ANTHR_PL_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PSTL_CD_R_RNG_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epz_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_pstl_cd_r_rng_prte_id := l_parent_rec.elig_pstl_cd_r_rng_prte_id ;
                 --
                 for l_epz_rec in c_epz(l_parent_rec.elig_pstl_cd_r_rng_prte_id,l_mirror_src_entity_result_id,'EPZ' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPZ');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pstl_zip_rng_name(l_epz_rec.pstl_zip_rng_id
                                                                                           ,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_epz_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epz_rec.effective_start_date
                      and l_epz_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPZ',
                     p_information1     => l_epz_rec.elig_pstl_cd_r_rng_prte_id,
                     p_information2     => l_epz_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epz_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epz_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epz_rec.eligy_prfl_id,
					p_information111     => l_epz_rec.epz_attribute1,
					p_information120     => l_epz_rec.epz_attribute10,
					p_information121     => l_epz_rec.epz_attribute11,
					p_information122     => l_epz_rec.epz_attribute12,
					p_information123     => l_epz_rec.epz_attribute13,
					p_information124     => l_epz_rec.epz_attribute14,
					p_information125     => l_epz_rec.epz_attribute15,
					p_information126     => l_epz_rec.epz_attribute16,
					p_information127     => l_epz_rec.epz_attribute17,
					p_information128     => l_epz_rec.epz_attribute18,
					p_information129     => l_epz_rec.epz_attribute19,
					p_information112     => l_epz_rec.epz_attribute2,
					p_information130     => l_epz_rec.epz_attribute20,
					p_information131     => l_epz_rec.epz_attribute21,
					p_information132     => l_epz_rec.epz_attribute22,
					p_information133     => l_epz_rec.epz_attribute23,
					p_information134     => l_epz_rec.epz_attribute24,
					p_information135     => l_epz_rec.epz_attribute25,
					p_information136     => l_epz_rec.epz_attribute26,
					p_information137     => l_epz_rec.epz_attribute27,
					p_information138     => l_epz_rec.epz_attribute28,
					p_information139     => l_epz_rec.epz_attribute29,
					p_information113     => l_epz_rec.epz_attribute3,
					p_information140     => l_epz_rec.epz_attribute30,
					p_information114     => l_epz_rec.epz_attribute4,
					p_information115     => l_epz_rec.epz_attribute5,
					p_information116     => l_epz_rec.epz_attribute6,
					p_information117     => l_epz_rec.epz_attribute7,
					p_information118     => l_epz_rec.epz_attribute8,
					p_information119     => l_epz_rec.epz_attribute9,
					p_information110     => l_epz_rec.epz_attribute_category,
					p_information11     => l_epz_rec.excld_flag,
					p_information260     => l_epz_rec.ordr_num,
					p_information245     => l_epz_rec.pstl_zip_rng_id,
                                        p_information265    => l_epz_rec.object_version_number,
					p_information295    => l_epz_rec.criteria_score,
					p_information296    => l_epz_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epz_result_id is null then
                       l_out_epz_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epz_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                  for l_epz_rec in c_epz_pstl(l_parent_rec.elig_pstl_cd_r_rng_prte_id,l_mirror_src_entity_result_id,'EPZ' ) loop
                     ben_pd_rate_and_cvg_module.create_postal_results
                         (
                            p_validate                    => p_validate
                           ,p_copy_entity_result_id       => l_out_epz_result_id
                           ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                           ,p_pstl_zip_rng_id             => l_epz_rec.pstl_zip_rng_id
                           ,p_business_group_id           => p_business_group_id
                           ,p_number_of_copies           => p_number_of_copies
                           ,p_object_version_number       => l_object_version_number
                           ,p_effective_date              => p_effective_date
                           ) ;
                  end loop;
              end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PSTL_CD_R_RNG_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PYRL_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epy_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_pyrl_prte_id := l_parent_rec.elig_pyrl_prte_id ;
                 --
                 for l_epy_rec in c_epy(l_parent_rec.elig_pyrl_prte_id,l_mirror_src_entity_result_id,'EPY' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPY');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_payroll_name(l_epy_rec.payroll_id
                                                                                     ,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_epy_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epy_rec.effective_start_date
                      and l_epy_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of payroll
                   -- for Mapping - Bug 2958658
                   --
                   l_payroll_start_date := null;
                   if l_epy_rec.payroll_id is not null then
                     open c_payroll_start_date(l_epy_rec.payroll_id);
                     fetch c_payroll_start_date into l_payroll_start_date;
                     close c_payroll_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name9(l_epy_rec.payroll_id,NVL(l_payroll_start_date,p_effective_date));
                   fetch c_get_mapping_name9 into l_mapping_name;
                   close c_get_mapping_name9;
                   --
                   l_mapping_id   := l_epy_rec.payroll_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPY',
                     p_information1     => l_epy_rec.elig_pyrl_prte_id,
                     p_information2     => l_epy_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epy_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epy_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epy_rec.eligy_prfl_id,
					p_information111     => l_epy_rec.epy_attribute1,
					p_information120     => l_epy_rec.epy_attribute10,
					p_information121     => l_epy_rec.epy_attribute11,
					p_information122     => l_epy_rec.epy_attribute12,
					p_information123     => l_epy_rec.epy_attribute13,
					p_information124     => l_epy_rec.epy_attribute14,
					p_information125     => l_epy_rec.epy_attribute15,
					p_information126     => l_epy_rec.epy_attribute16,
					p_information127     => l_epy_rec.epy_attribute17,
					p_information128     => l_epy_rec.epy_attribute18,
					p_information129     => l_epy_rec.epy_attribute19,
					p_information112     => l_epy_rec.epy_attribute2,
					p_information130     => l_epy_rec.epy_attribute20,
					p_information131     => l_epy_rec.epy_attribute21,
					p_information132     => l_epy_rec.epy_attribute22,
					p_information133     => l_epy_rec.epy_attribute23,
					p_information134     => l_epy_rec.epy_attribute24,
					p_information135     => l_epy_rec.epy_attribute25,
					p_information136     => l_epy_rec.epy_attribute26,
					p_information137     => l_epy_rec.epy_attribute27,
					p_information138     => l_epy_rec.epy_attribute28,
					p_information139     => l_epy_rec.epy_attribute29,
					p_information113     => l_epy_rec.epy_attribute3,
					p_information140     => l_epy_rec.epy_attribute30,
					p_information114     => l_epy_rec.epy_attribute4,
					p_information115     => l_epy_rec.epy_attribute5,
					p_information116     => l_epy_rec.epy_attribute6,
					p_information117     => l_epy_rec.epy_attribute7,
					p_information118     => l_epy_rec.epy_attribute8,
					p_information119     => l_epy_rec.epy_attribute9,
					p_information110     => l_epy_rec.epy_attribute_category,
					p_information11     => l_epy_rec.excld_flag,
					p_information260     => l_epy_rec.ordr_num,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166     => l_payroll_start_date,
                                        p_information265    => l_epy_rec.object_version_number,
					p_information295    => l_epy_rec.criteria_score,
					p_information296    => l_epy_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epy_result_id is null then
                       l_out_epy_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epy_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PYRL_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PY_BSS_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epb_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_py_bss_prte_id := l_parent_rec.elig_py_bss_prte_id ;
                 --
                 for l_epb_rec in c_epb(l_parent_rec.elig_py_bss_prte_id,l_mirror_src_entity_result_id,'EPB' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPB');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_pay_basis_name(l_epb_rec.pay_basis_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_epb_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epb_rec.effective_start_date
                      and l_epb_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name10(l_epb_rec.pay_basis_id);
                   fetch c_get_mapping_name10 into l_mapping_name;
                   close c_get_mapping_name10;
                   --
                   l_mapping_id   := l_epb_rec.pay_basis_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPB',
                     p_information1     => l_epb_rec.elig_py_bss_prte_id,
                     p_information2     => l_epb_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epb_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epb_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epb_rec.eligy_prfl_id,
					p_information111     => l_epb_rec.epb_attribute1,
					p_information120     => l_epb_rec.epb_attribute10,
					p_information121     => l_epb_rec.epb_attribute11,
					p_information122     => l_epb_rec.epb_attribute12,
					p_information123     => l_epb_rec.epb_attribute13,
					p_information124     => l_epb_rec.epb_attribute14,
					p_information125     => l_epb_rec.epb_attribute15,
					p_information126     => l_epb_rec.epb_attribute16,
					p_information127     => l_epb_rec.epb_attribute17,
					p_information128     => l_epb_rec.epb_attribute18,
					p_information129     => l_epb_rec.epb_attribute19,
					p_information112     => l_epb_rec.epb_attribute2,
					p_information130     => l_epb_rec.epb_attribute20,
					p_information131     => l_epb_rec.epb_attribute21,
					p_information132     => l_epb_rec.epb_attribute22,
					p_information133     => l_epb_rec.epb_attribute23,
					p_information134     => l_epb_rec.epb_attribute24,
					p_information135     => l_epb_rec.epb_attribute25,
					p_information136     => l_epb_rec.epb_attribute26,
					p_information137     => l_epb_rec.epb_attribute27,
					p_information138     => l_epb_rec.epb_attribute28,
					p_information139     => l_epb_rec.epb_attribute29,
					p_information113     => l_epb_rec.epb_attribute3,
					p_information140     => l_epb_rec.epb_attribute30,
					p_information114     => l_epb_rec.epb_attribute4,
					p_information115     => l_epb_rec.epb_attribute5,
					p_information116     => l_epb_rec.epb_attribute6,
					p_information117     => l_epb_rec.epb_attribute7,
					p_information118     => l_epb_rec.epb_attribute8,
					p_information119     => l_epb_rec.epb_attribute9,
					p_information110     => l_epb_rec.epb_attribute_category,
					p_information11     => l_epb_rec.excld_flag,
					p_information260     => l_epb_rec.ordr_num,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166     => NULL,  -- No ESD for Pay Basis
                                        p_information265    => l_epb_rec.object_version_number,
					p_information295    => l_epb_rec.criteria_score,
					p_information296    => l_epb_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_epb_result_id is null then
                       l_out_epb_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epb_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PY_BSS_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_SCHEDD_HRS_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_esh_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_schedd_hrs_prte_id := l_parent_rec.elig_schedd_hrs_prte_id ;
                 --
                 for l_esh_rec in c_esh(l_parent_rec.elig_schedd_hrs_prte_id,l_mirror_src_entity_result_id,'ESH' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ESH');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   -- Bug No: 3451872
                   --
                   if (l_esh_rec.schedd_hrs_rl is null) then
                   l_information5  := l_esh_rec.hrs_num ||' - ' ||l_esh_rec.max_hrs_num
                                      ||' '||hr_general.decode_lookup('FREQUENCY',l_esh_rec.freq_cd)
                                      || ben_plan_design_program_module.get_exclude_message(l_esh_rec.excld_flag);

                   else
				   l_information5  := ben_plan_design_program_module.get_formula_name(l_esh_rec.schedd_hrs_rl, p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_esh_rec.excld_flag);
                                      --'Intersection';
                   end if;
                   --
                   if p_effective_date between l_esh_rec.effective_start_date
                      and l_esh_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ESH',
                     p_information1     => l_esh_rec.elig_schedd_hrs_prte_id,
                     p_information2     => l_esh_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_esh_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_esh_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_esh_rec.determination_cd,
					p_information259     => l_esh_rec.determination_rl,
					p_information263     => l_esh_rec.eligy_prfl_id,
					p_information111     => l_esh_rec.esh_attribute1,
					p_information120     => l_esh_rec.esh_attribute10,
					p_information121     => l_esh_rec.esh_attribute11,
					p_information122     => l_esh_rec.esh_attribute12,
					p_information123     => l_esh_rec.esh_attribute13,
					p_information124     => l_esh_rec.esh_attribute14,
					p_information125     => l_esh_rec.esh_attribute15,
					p_information126     => l_esh_rec.esh_attribute16,
					p_information127     => l_esh_rec.esh_attribute17,
					p_information128     => l_esh_rec.esh_attribute18,
					p_information129     => l_esh_rec.esh_attribute19,
					p_information112     => l_esh_rec.esh_attribute2,
					p_information130     => l_esh_rec.esh_attribute20,
					p_information131     => l_esh_rec.esh_attribute21,
					p_information132     => l_esh_rec.esh_attribute22,
					p_information133     => l_esh_rec.esh_attribute23,
					p_information134     => l_esh_rec.esh_attribute24,
					p_information135     => l_esh_rec.esh_attribute25,
					p_information136     => l_esh_rec.esh_attribute26,
					p_information137     => l_esh_rec.esh_attribute27,
					p_information138     => l_esh_rec.esh_attribute28,
					p_information139     => l_esh_rec.esh_attribute29,
					p_information113     => l_esh_rec.esh_attribute3,
					p_information140     => l_esh_rec.esh_attribute30,
					p_information114     => l_esh_rec.esh_attribute4,
					p_information115     => l_esh_rec.esh_attribute5,
					p_information116     => l_esh_rec.esh_attribute6,
					p_information117     => l_esh_rec.esh_attribute7,
					p_information118     => l_esh_rec.esh_attribute8,
					p_information119     => l_esh_rec.esh_attribute9,
					p_information110     => l_esh_rec.esh_attribute_category,
					p_information13     => l_esh_rec.excld_flag,
					p_information14     => l_esh_rec.freq_cd,
					p_information288     => l_esh_rec.hrs_num,
					p_information287     => l_esh_rec.max_hrs_num,
					p_information264     => l_esh_rec.ordr_num,
					p_information12     => l_esh_rec.rounding_cd,
					p_information257     => l_esh_rec.rounding_rl,
					p_information258     => l_esh_rec.schedd_hrs_rl,
                                        p_information265    => l_esh_rec.object_version_number,
					p_information295    => l_esh_rec.criteria_score,
					p_information296    => l_esh_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_esh_result_id is null then
                       l_out_esh_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_esh_result_id := l_copy_entity_result_id ;
                     end if;
                     --

                     if (l_esh_rec.determination_rl is not null) then
		           ben_plan_design_program_module.create_formula_result(
			       p_validate               => p_validate
			      ,p_copy_entity_result_id  => l_copy_entity_result_id
			      ,p_copy_entity_txn_id     => p_copy_entity_txn_id
			      ,p_formula_id             => l_esh_rec.determination_rl
			      ,p_business_group_id      => l_esh_rec.business_group_id
			      ,p_number_of_copies       => l_number_of_copies
			      ,p_object_version_number  => l_object_version_number
			      ,p_effective_date         => p_effective_date);
		         end if;

                     if (l_esh_rec.rounding_rl is not null) then
		           ben_plan_design_program_module.create_formula_result(
			       p_validate               => p_validate
			      ,p_copy_entity_result_id  => l_copy_entity_result_id
			      ,p_copy_entity_txn_id     => p_copy_entity_txn_id
			      ,p_formula_id             => l_esh_rec.rounding_rl
			      ,p_business_group_id      => l_esh_rec.business_group_id
			      ,p_number_of_copies       => l_number_of_copies
			      ,p_object_version_number  => l_object_version_number
			      ,p_effective_date         => p_effective_date);
		         end if;

                     if (l_esh_rec.schedd_hrs_rl is not null) then
		           ben_plan_design_program_module.create_formula_result(
			       p_validate               => p_validate
			      ,p_copy_entity_result_id  => l_copy_entity_result_id
			      ,p_copy_entity_txn_id     => p_copy_entity_txn_id
			      ,p_formula_id             => l_esh_rec.schedd_hrs_rl
			      ,p_business_group_id      => l_esh_rec.business_group_id
			      ,p_number_of_copies       => l_number_of_copies
			      ,p_object_version_number  => l_object_version_number
			      ,p_effective_date         => p_effective_date);
		         end if;

                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_SCHEDD_HRS_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_SVC_AREA_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_esa_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_svc_area_prte_id := l_parent_rec.elig_svc_area_prte_id ;
                 --
                 for l_esa_rec in c_esa(l_parent_rec.elig_svc_area_prte_id,l_mirror_src_entity_result_id,'ESA' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ESA');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_svc_area_name(l_esa_rec.svc_area_id
                                                                                      ,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_esa_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_esa_rec.effective_start_date
                      and l_esa_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ESA',
                     p_information1     => l_esa_rec.elig_svc_area_prte_id,
                     p_information2     => l_esa_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_esa_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_esa_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_esa_rec.eligy_prfl_id,
					p_information111     => l_esa_rec.esa_attribute1,
					p_information120     => l_esa_rec.esa_attribute10,
					p_information121     => l_esa_rec.esa_attribute11,
					p_information122     => l_esa_rec.esa_attribute12,
					p_information123     => l_esa_rec.esa_attribute13,
					p_information124     => l_esa_rec.esa_attribute14,
					p_information125     => l_esa_rec.esa_attribute15,
					p_information126     => l_esa_rec.esa_attribute16,
					p_information127     => l_esa_rec.esa_attribute17,
					p_information128     => l_esa_rec.esa_attribute18,
					p_information129     => l_esa_rec.esa_attribute19,
					p_information112     => l_esa_rec.esa_attribute2,
					p_information130     => l_esa_rec.esa_attribute20,
					p_information131     => l_esa_rec.esa_attribute21,
					p_information132     => l_esa_rec.esa_attribute22,
					p_information133     => l_esa_rec.esa_attribute23,
					p_information134     => l_esa_rec.esa_attribute24,
					p_information135     => l_esa_rec.esa_attribute25,
					p_information136     => l_esa_rec.esa_attribute26,
					p_information137     => l_esa_rec.esa_attribute27,
					p_information138     => l_esa_rec.esa_attribute28,
					p_information139     => l_esa_rec.esa_attribute29,
					p_information113     => l_esa_rec.esa_attribute3,
					p_information140     => l_esa_rec.esa_attribute30,
					p_information114     => l_esa_rec.esa_attribute4,
					p_information115     => l_esa_rec.esa_attribute5,
					p_information116     => l_esa_rec.esa_attribute6,
					p_information117     => l_esa_rec.esa_attribute7,
					p_information118     => l_esa_rec.esa_attribute8,
					p_information119     => l_esa_rec.esa_attribute9,
					p_information110     => l_esa_rec.esa_attribute_category,
					p_information11     => l_esa_rec.excld_flag,
					p_information260     => l_esa_rec.ordr_num,
					p_information241     => l_esa_rec.svc_area_id,
                                        p_information265    => l_esa_rec.object_version_number,
					p_information295    => l_esa_rec.criteria_score,
					p_information296    => l_esa_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_esa_result_id is null then
                       l_out_esa_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_esa_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                  for l_esa_rec in c_esa_svc(l_parent_rec.elig_svc_area_prte_id,l_mirror_src_entity_result_id,'ESA' ) loop
                    ben_pd_rate_and_cvg_module.create_service_results
                      (
                       p_validate                => p_validate
                      ,p_copy_entity_result_id   => l_out_esa_result_id
                      ,p_copy_entity_txn_id      => p_copy_entity_txn_id
                      ,p_svc_area_id             => l_esa_rec.svc_area_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_number_of_copies           => p_number_of_copies
                      ,p_object_version_number   => l_object_version_number
                      ,p_effective_date          => p_effective_date
                      );
                  end loop;
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_SVC_AREA_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_WK_LOC_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ewl_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_wk_loc_prte_id := l_parent_rec.elig_wk_loc_prte_id ;
                 --
                 for l_ewl_rec in c_ewl(l_parent_rec.elig_wk_loc_prte_id,l_mirror_src_entity_result_id,'EWL') loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EWL');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_location_name(l_ewl_rec.location_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_ewl_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ewl_rec.effective_start_date
                      and l_ewl_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of location
                   -- for Mapping - Bug 2958658
                   --
                   l_location_inactive_date := null;
                   if l_ewl_rec.location_id is not null then
                     open c_location_inactive_date(l_ewl_rec.location_id);
                     fetch c_location_inactive_date into l_location_inactive_date;
                     close c_location_inactive_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name15(l_ewl_rec.location_id,NVL(l_location_inactive_date,p_effective_date));
                   fetch c_get_mapping_name15 into l_mapping_name;
                   close c_get_mapping_name15;
                   --
                   l_mapping_id   := l_ewl_rec.location_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EWL',
                     p_information1     => l_ewl_rec.elig_wk_loc_prte_id,
                     p_information2     => l_ewl_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ewl_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ewl_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_ewl_rec.eligy_prfl_id,
					p_information111     => l_ewl_rec.ewl_attribute1,
					p_information120     => l_ewl_rec.ewl_attribute10,
					p_information121     => l_ewl_rec.ewl_attribute11,
					p_information122     => l_ewl_rec.ewl_attribute12,
					p_information123     => l_ewl_rec.ewl_attribute13,
					p_information124     => l_ewl_rec.ewl_attribute14,
					p_information125     => l_ewl_rec.ewl_attribute15,
					p_information126     => l_ewl_rec.ewl_attribute16,
					p_information127     => l_ewl_rec.ewl_attribute17,
					p_information128     => l_ewl_rec.ewl_attribute18,
					p_information129     => l_ewl_rec.ewl_attribute19,
					p_information112     => l_ewl_rec.ewl_attribute2,
					p_information130     => l_ewl_rec.ewl_attribute20,
					p_information131     => l_ewl_rec.ewl_attribute21,
					p_information132     => l_ewl_rec.ewl_attribute22,
					p_information133     => l_ewl_rec.ewl_attribute23,
					p_information134     => l_ewl_rec.ewl_attribute24,
					p_information135     => l_ewl_rec.ewl_attribute25,
					p_information136     => l_ewl_rec.ewl_attribute26,
					p_information137     => l_ewl_rec.ewl_attribute27,
					p_information138     => l_ewl_rec.ewl_attribute28,
					p_information139     => l_ewl_rec.ewl_attribute29,
					p_information113     => l_ewl_rec.ewl_attribute3,
					p_information140     => l_ewl_rec.ewl_attribute30,
					p_information114     => l_ewl_rec.ewl_attribute4,
					p_information115     => l_ewl_rec.ewl_attribute5,
					p_information116     => l_ewl_rec.ewl_attribute6,
					p_information117     => l_ewl_rec.ewl_attribute7,
					p_information118     => l_ewl_rec.ewl_attribute8,
					p_information119     => l_ewl_rec.ewl_attribute9,
					p_information110     => l_ewl_rec.ewl_attribute_category,
					p_information11     => l_ewl_rec.excld_flag,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information260     => l_ewl_rec.ordr_num,
                              p_information166     => l_location_inactive_date,
                                        p_information265    => l_ewl_rec.object_version_number,
					p_information295    => l_ewl_rec.criteria_score,
					p_information296    => l_ewl_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ewl_result_id is null then
                       l_out_ewl_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ewl_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_WK_LOC_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_SP_CLNG_PRG_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_esp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_sp_clng_prg_prte_id := l_parent_rec.elig_sp_clng_prg_prte_id ;
                 --
                 for l_esp_rec in c_esp(l_parent_rec.elig_sp_clng_prg_prte_id,l_mirror_src_entity_result_id,'ESP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ESP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_sp_clng_step_name(l_esp_rec.special_ceiling_step_id
                                                                                          ,p_effective_date)
                                      || ben_plan_design_program_module.get_exclude_message(l_esp_rec.excld_flag);
                                      -- 'Intersection';
                   --
                   if p_effective_date between l_esp_rec.effective_start_date
                      and l_esp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;

                   -- To store effective_start_date of step
                   -- for Mapping - Bug 2958658
                   --
                   l_step_start_date := null;
                   if l_esp_rec.special_ceiling_step_id is not null then
                     open c_step_start_date(l_esp_rec.special_ceiling_step_id);
                     fetch c_step_start_date into l_step_start_date;
                     close c_step_start_date;
                   end if;

                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
/* 9999 uncomment after sql resolved
                   open c_get_mapping_name12(l_esp_rec.special_ceiling_step_id,NVL(l_step_start_date,p_effective_date));
                   fetch c_get_mapping_name12 into l_mapping_name;
                   close c_get_mapping_name12;
*/
                   --
                   l_mapping_id   := l_esp_rec.special_ceiling_step_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ESP',
                     p_information1     => l_esp_rec.elig_sp_clng_prg_prte_id,
                     p_information2     => l_esp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_esp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_esp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_esp_rec.eligy_prfl_id,
					p_information111     => l_esp_rec.esp_attribute1,
					p_information120     => l_esp_rec.esp_attribute10,
					p_information121     => l_esp_rec.esp_attribute11,
					p_information122     => l_esp_rec.esp_attribute12,
					p_information123     => l_esp_rec.esp_attribute13,
					p_information124     => l_esp_rec.esp_attribute14,
					p_information125     => l_esp_rec.esp_attribute15,
					p_information126     => l_esp_rec.esp_attribute16,
					p_information127     => l_esp_rec.esp_attribute17,
					p_information128     => l_esp_rec.esp_attribute18,
					p_information129     => l_esp_rec.esp_attribute19,
					p_information112     => l_esp_rec.esp_attribute2,
					p_information130     => l_esp_rec.esp_attribute20,
					p_information131     => l_esp_rec.esp_attribute21,
					p_information132     => l_esp_rec.esp_attribute22,
					p_information133     => l_esp_rec.esp_attribute23,
					p_information134     => l_esp_rec.esp_attribute24,
					p_information135     => l_esp_rec.esp_attribute25,
					p_information136     => l_esp_rec.esp_attribute26,
					p_information137     => l_esp_rec.esp_attribute27,
					p_information138     => l_esp_rec.esp_attribute28,
					p_information139     => l_esp_rec.esp_attribute29,
					p_information113     => l_esp_rec.esp_attribute3,
					p_information140     => l_esp_rec.esp_attribute30,
					p_information114     => l_esp_rec.esp_attribute4,
					p_information115     => l_esp_rec.esp_attribute5,
					p_information116     => l_esp_rec.esp_attribute6,
					p_information117     => l_esp_rec.esp_attribute7,
					p_information118     => l_esp_rec.esp_attribute8,
					p_information119     => l_esp_rec.esp_attribute9,
					p_information110     => l_esp_rec.esp_attribute_category,
					p_information11     => l_esp_rec.excld_flag,
					p_information257     => l_esp_rec.ordr_num,
					-- p_information258     => l_esp_rec.sp_clng_prgrssn_pt_cd,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
                              p_information166    => l_step_start_date,
                                        p_information265    => l_esp_rec.object_version_number,
					p_information295     => l_esp_rec.criteria_score,
					p_information296     => l_esp_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_esp_result_id is null then
                       l_out_esp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_esp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_SP_CLNG_PRG_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PSTN_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eps_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_pstn_prte_id := l_parent_rec.elig_pstn_prte_id ;
                 --
                 for l_eps_rec in c_eps(l_parent_rec.elig_pstn_prte_id,l_mirror_src_entity_result_id,'EPS' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPS');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_position_name(l_eps_rec.position_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_eps_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eps_rec.effective_start_date
                      and l_eps_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name8(l_eps_rec.position_id);
                   fetch c_get_mapping_name8 into l_mapping_name;
                   close c_get_mapping_name8;
                   --
                   l_mapping_id   := l_eps_rec.position_id;
                   --
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   -- To store effective_start_date of position
                   -- for Mapping - Bug 2958658
                   --
                   l_position_start_date := null;
                   if l_eps_rec.position_id is not null then
                     open c_position_start_date(l_eps_rec.position_id);
                     fetch c_position_start_date into l_position_start_date;
                     close c_position_start_date;
                   end if;

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPS',
                     p_information1     => l_eps_rec.elig_pstn_prte_id,
                     p_information2     => l_eps_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eps_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eps_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
			   p_information263     => l_eps_rec.eligy_prfl_id,

                           p_information111     => l_eps_rec.eps_attribute1,
			   p_information120     => l_eps_rec.eps_attribute10,
			   p_information121     => l_eps_rec.eps_attribute11,
			   p_information122     => l_eps_rec.eps_attribute12,
			   p_information123     => l_eps_rec.eps_attribute13,
			   p_information124     => l_eps_rec.eps_attribute14,
			   p_information125     => l_eps_rec.eps_attribute15,
			   p_information126     => l_eps_rec.eps_attribute16,
			   p_information127     => l_eps_rec.eps_attribute17,
			   p_information128     => l_eps_rec.eps_attribute18,
			   p_information129     => l_eps_rec.eps_attribute19,
			   p_information112     => l_eps_rec.eps_attribute2,
			   p_information130     => l_eps_rec.eps_attribute20,
			   p_information131     => l_eps_rec.eps_attribute21,
			   p_information132     => l_eps_rec.eps_attribute22,
			   p_information133     => l_eps_rec.eps_attribute23,
			   p_information134     => l_eps_rec.eps_attribute24,
			   p_information135     => l_eps_rec.eps_attribute25,
			   p_information136     => l_eps_rec.eps_attribute26,
			   p_information137     => l_eps_rec.eps_attribute27,
			   p_information138     => l_eps_rec.eps_attribute28,
			   p_information139     => l_eps_rec.eps_attribute29,
			   p_information113     => l_eps_rec.eps_attribute3,
			   p_information140     => l_eps_rec.eps_attribute30,
			   p_information114     => l_eps_rec.eps_attribute4,
			   p_information115     => l_eps_rec.eps_attribute5,
			   p_information116     => l_eps_rec.eps_attribute6,
			   p_information117     => l_eps_rec.eps_attribute7,
			   p_information118     => l_eps_rec.eps_attribute8,
			   p_information119     => l_eps_rec.eps_attribute9,
			   p_information110     => l_eps_rec.eps_attribute_category,

 			   p_information11     => l_eps_rec.excld_flag,
			   p_information261     => l_eps_rec.ordr_num,
			   -- Data for MAPPING columns.
			   p_information173    => l_mapping_name,
			   p_information174    => l_mapping_id,
			   p_information181    => l_mapping_column_name1,
			   p_information182    => l_mapping_column_name2,
			   -- END other product Mapping columns.
			   -- p_information257     => l_eps_rec.pstn_cd,
                     p_information166     => l_position_start_date,
                           p_information265    => l_eps_rec.object_version_number,
			   p_information295    => l_eps_rec.criteria_score,
			   p_information296    => l_eps_rec.criteria_weight,
			   --
  			   -- END REPLACE PARAMETER LINES
  			   p_object_version_number          => l_object_version_number,
			   p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eps_result_id is null then
                       l_out_eps_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eps_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PSTN_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_PRBTN_PERD_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_epn_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_prbtn_perd_prte_id := l_parent_rec.elig_prbtn_perd_prte_id ;
                 --
                 for l_epn_rec in c_epn(l_parent_rec.elig_prbtn_perd_prte_id,l_mirror_src_entity_result_id,'EPN' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EPN');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := l_epn_rec.probation_period ||'  '||
                                      hr_general.decode_lookup('QUALIFYING_UNITS',l_epn_rec.probation_unit)
                                      || ben_plan_design_program_module.get_exclude_message(l_epn_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_epn_rec.effective_start_date
                      and l_epn_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EPN',
                     p_information1     => l_epn_rec.elig_prbtn_perd_prte_id,
                     p_information2     => l_epn_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_epn_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_epn_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_epn_rec.eligy_prfl_id,
					p_information111     => l_epn_rec.epn_attribute1,
					p_information120     => l_epn_rec.epn_attribute10,
					p_information121     => l_epn_rec.epn_attribute11,
					p_information122     => l_epn_rec.epn_attribute12,
					p_information123     => l_epn_rec.epn_attribute13,
					p_information124     => l_epn_rec.epn_attribute14,
					p_information125     => l_epn_rec.epn_attribute15,
					p_information126     => l_epn_rec.epn_attribute16,
					p_information127     => l_epn_rec.epn_attribute17,
					p_information128     => l_epn_rec.epn_attribute18,
					p_information129     => l_epn_rec.epn_attribute19,
					p_information112     => l_epn_rec.epn_attribute2,
					p_information130     => l_epn_rec.epn_attribute20,
					p_information131     => l_epn_rec.epn_attribute21,
					p_information132     => l_epn_rec.epn_attribute22,
					p_information133     => l_epn_rec.epn_attribute23,
					p_information134     => l_epn_rec.epn_attribute24,
					p_information135     => l_epn_rec.epn_attribute25,
					p_information136     => l_epn_rec.epn_attribute26,
					p_information137     => l_epn_rec.epn_attribute27,
					p_information138     => l_epn_rec.epn_attribute28,
					p_information139     => l_epn_rec.epn_attribute29,
					p_information113     => l_epn_rec.epn_attribute3,
					p_information140     => l_epn_rec.epn_attribute30,
					p_information114     => l_epn_rec.epn_attribute4,
					p_information115     => l_epn_rec.epn_attribute5,
					p_information116     => l_epn_rec.epn_attribute6,
					p_information117     => l_epn_rec.epn_attribute7,
					p_information118     => l_epn_rec.epn_attribute8,
					p_information119     => l_epn_rec.epn_attribute9,
					p_information110     => l_epn_rec.epn_attribute_category,

					p_information12     => l_epn_rec.excld_flag,
					p_information257     => l_epn_rec.ordr_num,
                          --	p_information258     => l_epn_rec.prbtn_perd_cd,
				p_information287     => l_epn_rec.probation_period,
                          	p_information11     => l_epn_rec.probation_unit,
                          --  p_information259     => l_epn_rec.uom,
                                        p_information265    => l_epn_rec.object_version_number,
					p_information295     => l_epn_rec.criteria_score,
					p_information296     => l_epn_rec.criteria_weight,


					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_epn_result_id is null then
                       l_out_epn_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_epn_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PRBTN_PERD_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_MRTL_STS_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_emp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_mrtl_sts_prte_id := l_parent_rec.elig_mrtl_sts_prte_id ;
                 --
                 for l_emp_rec in c_emp(l_parent_rec.elig_mrtl_sts_prte_id,l_mirror_src_entity_result_id,'EMP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EMP');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('MAR_STATUS',l_emp_rec.marital_status)
                                      || ben_plan_design_program_module.get_exclude_message(l_emp_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_emp_rec.effective_start_date
                      and l_emp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EMP',
                     p_information1     => l_emp_rec.elig_mrtl_sts_prte_id,
                     p_information2     => l_emp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_emp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_emp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
                     p_information263     => l_emp_rec.eligy_prfl_id,

			   p_information111     => l_emp_rec.emp_attribute1,
			   p_information120     => l_emp_rec.emp_attribute10,
			   p_information121     => l_emp_rec.emp_attribute11,
			   p_information122     => l_emp_rec.emp_attribute12,
			   p_information123     => l_emp_rec.emp_attribute13,
			   p_information124     => l_emp_rec.emp_attribute14,
			   p_information125     => l_emp_rec.emp_attribute15,
			   p_information126     => l_emp_rec.emp_attribute16,
			   p_information127     => l_emp_rec.emp_attribute17,
			   p_information128     => l_emp_rec.emp_attribute18,
			   p_information129     => l_emp_rec.emp_attribute19,
			   p_information112     => l_emp_rec.emp_attribute2,
			   p_information130     => l_emp_rec.emp_attribute20,
			   p_information131     => l_emp_rec.emp_attribute21,
			   p_information132     => l_emp_rec.emp_attribute22,
			   p_information133     => l_emp_rec.emp_attribute23,
			   p_information134     => l_emp_rec.emp_attribute24,
			   p_information135     => l_emp_rec.emp_attribute25,
			   p_information136     => l_emp_rec.emp_attribute26,
			   p_information137     => l_emp_rec.emp_attribute27,
			   p_information138     => l_emp_rec.emp_attribute28,
			   p_information139     => l_emp_rec.emp_attribute29,
			   p_information113     => l_emp_rec.emp_attribute3,
			   p_information140     => l_emp_rec.emp_attribute30,
			   p_information114     => l_emp_rec.emp_attribute4,
			   p_information115     => l_emp_rec.emp_attribute5,
			   p_information116     => l_emp_rec.emp_attribute6,
			   p_information117     => l_emp_rec.emp_attribute7,
			   p_information118     => l_emp_rec.emp_attribute8,
			   p_information119     => l_emp_rec.emp_attribute9,
			   p_information110     => l_emp_rec.emp_attribute_category,

			   p_information12     => l_emp_rec.excld_flag,
			   p_information11     => l_emp_rec.marital_status,
	            -- p_information260     => l_emp_rec.mrtl_sts_cd,
                           p_information265    => l_emp_rec.object_version_number,
			   p_information295    => l_emp_rec.criteria_score,
			   p_information296    => l_emp_rec.criteria_weight,
			   --
			   -- END REPLACE PARAMETER LINES

			   p_object_version_number          => l_object_version_number,
			   p_effective_date                 => p_effective_date       );
                     --
                     --

                     if l_out_emp_result_id is null then
                       l_out_emp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_emp_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_MRTL_STS_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_GNDR_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_egn_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_gndr_prte_id := l_parent_rec.elig_gndr_prte_id ;
                 --
                 for l_egn_rec in c_egn(l_parent_rec.elig_gndr_prte_id,l_mirror_src_entity_result_id,'EGN' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EGN');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('SEX',l_egn_rec.sex)
                                      || ben_plan_design_program_module.get_exclude_message(l_egn_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_egn_rec.effective_start_date
                      and l_egn_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EGN',
                     p_information1     => l_egn_rec.elig_gndr_prte_id,
                     p_information2     => l_egn_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_egn_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_egn_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_egn_rec.egn_attribute1,
					p_information120     => l_egn_rec.egn_attribute10,
					p_information121     => l_egn_rec.egn_attribute11,
					p_information122     => l_egn_rec.egn_attribute12,
					p_information123     => l_egn_rec.egn_attribute13,
					p_information124     => l_egn_rec.egn_attribute14,
					p_information125     => l_egn_rec.egn_attribute15,
					p_information126     => l_egn_rec.egn_attribute16,
					p_information127     => l_egn_rec.egn_attribute17,
					p_information128     => l_egn_rec.egn_attribute18,
					p_information129     => l_egn_rec.egn_attribute19,
					p_information112     => l_egn_rec.egn_attribute2,
					p_information130     => l_egn_rec.egn_attribute20,
					p_information131     => l_egn_rec.egn_attribute21,
					p_information132     => l_egn_rec.egn_attribute22,
					p_information133     => l_egn_rec.egn_attribute23,
					p_information134     => l_egn_rec.egn_attribute24,
					p_information135     => l_egn_rec.egn_attribute25,
					p_information136     => l_egn_rec.egn_attribute26,
					p_information137     => l_egn_rec.egn_attribute27,
					p_information138     => l_egn_rec.egn_attribute28,
					p_information139     => l_egn_rec.egn_attribute29,
					p_information113     => l_egn_rec.egn_attribute3,
					p_information140     => l_egn_rec.egn_attribute30,
					p_information114     => l_egn_rec.egn_attribute4,
					p_information115     => l_egn_rec.egn_attribute5,
					p_information116     => l_egn_rec.egn_attribute6,
					p_information117     => l_egn_rec.egn_attribute7,
					p_information118     => l_egn_rec.egn_attribute8,
					p_information119     => l_egn_rec.egn_attribute9,
					p_information110     => l_egn_rec.egn_attribute_category,
					p_information263     => l_egn_rec.eligy_prfl_id,
					p_information12     => l_egn_rec.excld_flag,
					-- p_information258     => l_egn_rec.gndr_cd,
					p_information257     => l_egn_rec.ordr_num,
					p_information11     => l_egn_rec.sex,
                                        p_information265    => l_egn_rec.object_version_number,
					p_information295    => l_egn_rec.criteria_score,
					p_information296    => l_egn_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_egn_result_id is null then
                       l_out_egn_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_egn_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_GNDR_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DSBLTY_RSN_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edr_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dsblty_rsn_prte_id := l_parent_rec.elig_dsblty_rsn_prte_id ;
                 --
                 for l_edr_rec in c_edr(l_parent_rec.elig_dsblty_rsn_prte_id,l_mirror_src_entity_result_id,'EDR' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDR');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('DISABILITY_REASON',l_edr_rec.reason)
                                      || ben_plan_design_program_module.get_exclude_message(l_edr_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edr_rec.effective_start_date
                      and l_edr_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDR',
                     p_information1     => l_edr_rec.elig_dsblty_rsn_prte_id,
                     p_information2     => l_edr_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edr_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edr_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					-- p_information258     => l_edr_rec.dsblty_rsn_cd,
					p_information111     => l_edr_rec.edr_attribute1,
					p_information120     => l_edr_rec.edr_attribute10,
					p_information121     => l_edr_rec.edr_attribute11,
					p_information122     => l_edr_rec.edr_attribute12,
					p_information123     => l_edr_rec.edr_attribute13,
					p_information124     => l_edr_rec.edr_attribute14,
					p_information125     => l_edr_rec.edr_attribute15,
					p_information126     => l_edr_rec.edr_attribute16,
					p_information127     => l_edr_rec.edr_attribute17,
					p_information128     => l_edr_rec.edr_attribute18,
					p_information129     => l_edr_rec.edr_attribute19,
					p_information112     => l_edr_rec.edr_attribute2,
					p_information130     => l_edr_rec.edr_attribute20,
					p_information131     => l_edr_rec.edr_attribute21,
					p_information132     => l_edr_rec.edr_attribute22,
					p_information133     => l_edr_rec.edr_attribute23,
					p_information134     => l_edr_rec.edr_attribute24,
					p_information135     => l_edr_rec.edr_attribute25,
					p_information136     => l_edr_rec.edr_attribute26,
					p_information137     => l_edr_rec.edr_attribute27,
					p_information138     => l_edr_rec.edr_attribute28,
					p_information139     => l_edr_rec.edr_attribute29,
					p_information113     => l_edr_rec.edr_attribute3,
					p_information140     => l_edr_rec.edr_attribute30,
					p_information114     => l_edr_rec.edr_attribute4,
					p_information115     => l_edr_rec.edr_attribute5,
					p_information116     => l_edr_rec.edr_attribute6,
					p_information117     => l_edr_rec.edr_attribute7,
					p_information118     => l_edr_rec.edr_attribute8,
					p_information119     => l_edr_rec.edr_attribute9,
					p_information110     => l_edr_rec.edr_attribute_category,
					p_information263     => l_edr_rec.eligy_prfl_id,
					p_information12     => l_edr_rec.excld_flag,
					p_information257     => l_edr_rec.ordr_num,
					p_information11     => l_edr_rec.reason,
                                        p_information265    => l_edr_rec.object_version_number,
					p_information295    => l_edr_rec.criteria_score,
					p_information296    => l_edr_rec.criteria_weight,

				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edr_result_id is null then
                       l_out_edr_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edr_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DSBLTY_RSN_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_DSBLTY_DGR_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_edd_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dsblty_dgr_prte_id := l_parent_rec.elig_dsblty_dgr_prte_id ;
                 --
                 for l_edd_rec in c_edd(l_parent_rec.elig_dsblty_dgr_prte_id,l_mirror_src_entity_result_id,'EDD' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EDD');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := l_edd_rec.degree
                                      ||ben_plan_design_program_module.get_exclude_message(l_edd_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_edd_rec.effective_start_date
                      and l_edd_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EDD',
                     p_information1     => l_edd_rec.elig_dsblty_dgr_prte_id,
                     p_information2     => l_edd_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_edd_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_edd_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information287     => l_edd_rec.degree,
					-- p_information289     => l_edd_rec.dsblty_dgr,
					p_information111     => l_edd_rec.edd_attribute1,
					p_information120     => l_edd_rec.edd_attribute10,
					p_information121     => l_edd_rec.edd_attribute11,
					p_information122     => l_edd_rec.edd_attribute12,
					p_information123     => l_edd_rec.edd_attribute13,
					p_information124     => l_edd_rec.edd_attribute14,
					p_information125     => l_edd_rec.edd_attribute15,
					p_information126     => l_edd_rec.edd_attribute16,
					p_information127     => l_edd_rec.edd_attribute17,
					p_information128     => l_edd_rec.edd_attribute18,
					p_information129     => l_edd_rec.edd_attribute19,
					p_information112     => l_edd_rec.edd_attribute2,
					p_information130     => l_edd_rec.edd_attribute20,
					p_information131     => l_edd_rec.edd_attribute21,
					p_information132     => l_edd_rec.edd_attribute22,
					p_information133     => l_edd_rec.edd_attribute23,
					p_information134     => l_edd_rec.edd_attribute24,
					p_information135     => l_edd_rec.edd_attribute25,
					p_information136     => l_edd_rec.edd_attribute26,
					p_information137     => l_edd_rec.edd_attribute27,
					p_information138     => l_edd_rec.edd_attribute28,
					p_information139     => l_edd_rec.edd_attribute29,
					p_information113     => l_edd_rec.edd_attribute3,
					p_information140     => l_edd_rec.edd_attribute30,
					p_information114     => l_edd_rec.edd_attribute4,
					p_information115     => l_edd_rec.edd_attribute5,
					p_information116     => l_edd_rec.edd_attribute6,
					p_information117     => l_edd_rec.edd_attribute7,
					p_information118     => l_edd_rec.edd_attribute8,
					p_information119     => l_edd_rec.edd_attribute9,
					p_information110     => l_edd_rec.edd_attribute_category,
					p_information263     => l_edd_rec.eligy_prfl_id,
					p_information11     => l_edd_rec.excld_flag,
					p_information288     => l_edd_rec.ordr_num,
                                        p_information265    => l_edd_rec.object_version_number,
					p_information295    => l_edd_rec.criteria_score,
					p_information296    => l_edd_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_edd_result_id is null then
                       l_out_edd_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_edd_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DSBLTY_DGR_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_QUAL_TITL_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_eqt_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_qual_titl_prte_id := l_parent_rec.elig_qual_titl_prte_id ;
                 --
                 for l_eqt_rec in c_eqt(l_parent_rec.elig_qual_titl_prte_id,l_mirror_src_entity_result_id,'EQT' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EQT');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_qual_type_name(l_eqt_rec.qualification_type_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_eqt_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_eqt_rec.effective_start_date
                      and l_eqt_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --

                   l_mapping_name := null;
                   l_mapping_id   := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name11(l_eqt_rec.qualification_type_id);
                   fetch c_get_mapping_name11 into l_mapping_name;
                   close c_get_mapping_name11;
                   --
                   l_mapping_id   := l_eqt_rec.qualification_type_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EQT',
                     p_information1     => l_eqt_rec.elig_qual_titl_prte_id,
                     p_information2     => l_eqt_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_eqt_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_eqt_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_eqt_rec.eligy_prfl_id,
					p_information111     => l_eqt_rec.eqt_attribute1,
					p_information120     => l_eqt_rec.eqt_attribute10,
					p_information121     => l_eqt_rec.eqt_attribute11,
					p_information122     => l_eqt_rec.eqt_attribute12,
					p_information123     => l_eqt_rec.eqt_attribute13,
					p_information124     => l_eqt_rec.eqt_attribute14,
					p_information125     => l_eqt_rec.eqt_attribute15,
					p_information126     => l_eqt_rec.eqt_attribute16,
					p_information127     => l_eqt_rec.eqt_attribute17,
					p_information128     => l_eqt_rec.eqt_attribute18,
					p_information129     => l_eqt_rec.eqt_attribute19,
					p_information112     => l_eqt_rec.eqt_attribute2,
					p_information130     => l_eqt_rec.eqt_attribute20,
					p_information131     => l_eqt_rec.eqt_attribute21,
					p_information132     => l_eqt_rec.eqt_attribute22,
					p_information133     => l_eqt_rec.eqt_attribute23,
					p_information134     => l_eqt_rec.eqt_attribute24,
					p_information135     => l_eqt_rec.eqt_attribute25,
					p_information136     => l_eqt_rec.eqt_attribute26,
					p_information137     => l_eqt_rec.eqt_attribute27,
					p_information138     => l_eqt_rec.eqt_attribute28,
					p_information139     => l_eqt_rec.eqt_attribute29,
					p_information113     => l_eqt_rec.eqt_attribute3,
					p_information140     => l_eqt_rec.eqt_attribute30,
					p_information114     => l_eqt_rec.eqt_attribute4,
					p_information115     => l_eqt_rec.eqt_attribute5,
					p_information116     => l_eqt_rec.eqt_attribute6,
					p_information117     => l_eqt_rec.eqt_attribute7,
					p_information118     => l_eqt_rec.eqt_attribute8,
					p_information119     => l_eqt_rec.eqt_attribute9,
					p_information110     => l_eqt_rec.eqt_attribute_category,
					p_information11     => l_eqt_rec.excld_flag,
					p_information260     => l_eqt_rec.ordr_num,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information141     => l_eqt_rec.title,
                              p_information166     => NULL,  -- No ESD for Qualification Type
                                        p_information265    => l_eqt_rec.object_version_number,
					p_information295    => l_eqt_rec.criteria_score,
					p_information296    => l_eqt_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_eqt_result_id is null then
                       l_out_eqt_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_eqt_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_QUAL_TITL_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_SUPPL_ROLE_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_est_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_suppl_role_prte_id := l_parent_rec.elig_suppl_role_prte_id ;
                 --
                 for l_est_rec in c_est(l_parent_rec.elig_suppl_role_prte_id,l_mirror_src_entity_result_id,'EST' ) loop
                 --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('EST');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := ben_plan_design_program_module.get_job_name(l_est_rec.job_id)
                                      || ben_plan_design_program_module.get_exclude_message(l_est_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_est_rec.effective_start_date
                      and l_est_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   --
                   -- pabodla : MAPPING DATA : Store the mapping column information.
                   --
                   l_mapping_name := null;
                   l_mapping_id   := null;
                   l_mapping_name1:= null;
                   l_mapping_id1  := null;
                   --
                   -- Get the defined balance name to display on mapping page.
                   --
                   open c_get_mapping_name13(l_est_rec.job_group_id);
                   fetch c_get_mapping_name13 into l_mapping_name;
                   close c_get_mapping_name13;
                   --
                   l_mapping_id   := l_est_rec.job_group_id;

                   open c_get_mapping_name14(l_est_rec.job_id, l_est_rec.job_group_id);
                   fetch c_get_mapping_name14 into l_mapping_name1;
                   close c_get_mapping_name14;
                   --
                   l_mapping_id1   := l_est_rec.job_id;
                   --
                   --To set user friendly labels on the mapping page
                   --
                   l_mapping_column_name1 := null;
                   l_mapping_column_name2 :=null;
                   BEN_PLAN_DESIGN_TXNS_API.get_mapping_column_name(l_table_route_id,
                                                                    l_mapping_column_name1,
                                                                    l_mapping_column_name2,
                                                                    p_copy_entity_txn_id);
                   --

                   -- To store effective_start_date of job
                   -- for Mapping - Bug 2958658
                   --
                   l_job_start_date := null;
                   if l_est_rec.job_id is not null then
                     open c_job_start_date(l_est_rec.job_id);
                     fetch c_job_start_date into l_job_start_date;
                     close c_job_start_date;
                   end if;

                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'EST',
                     p_information1     => l_est_rec.elig_suppl_role_prte_id,
                     p_information2     => l_est_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_est_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_est_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_est_rec.eligy_prfl_id,
					p_information111     => l_est_rec.est_attribute1,
					p_information120     => l_est_rec.est_attribute10,
					p_information121     => l_est_rec.est_attribute11,
					p_information122     => l_est_rec.est_attribute12,
					p_information123     => l_est_rec.est_attribute13,
					p_information124     => l_est_rec.est_attribute14,
					p_information125     => l_est_rec.est_attribute15,
					p_information126     => l_est_rec.est_attribute16,
					p_information127     => l_est_rec.est_attribute17,
					p_information128     => l_est_rec.est_attribute18,
					p_information129     => l_est_rec.est_attribute19,
					p_information112     => l_est_rec.est_attribute2,
					p_information130     => l_est_rec.est_attribute20,
					p_information131     => l_est_rec.est_attribute21,
					p_information132     => l_est_rec.est_attribute22,
					p_information133     => l_est_rec.est_attribute23,
					p_information134     => l_est_rec.est_attribute24,
					p_information135     => l_est_rec.est_attribute25,
					p_information136     => l_est_rec.est_attribute26,
					p_information137     => l_est_rec.est_attribute27,
					p_information138     => l_est_rec.est_attribute28,
					p_information139     => l_est_rec.est_attribute29,
					p_information113     => l_est_rec.est_attribute3,
					p_information140     => l_est_rec.est_attribute30,
					p_information114     => l_est_rec.est_attribute4,
					p_information115     => l_est_rec.est_attribute5,
					p_information116     => l_est_rec.est_attribute6,
					p_information117     => l_est_rec.est_attribute7,
					p_information118     => l_est_rec.est_attribute8,
					p_information119     => l_est_rec.est_attribute9,
					p_information110     => l_est_rec.est_attribute_category,
					p_information11     => l_est_rec.excld_flag,
					-- Data for MAPPING columns.
					p_information173    => l_mapping_name,
					p_information174    => l_mapping_id,
					p_information181    => l_mapping_column_name1,
					p_information182    => l_mapping_column_name2,
					-- END other product Mapping columns.
					p_information226     => l_est_rec.job_id,
					-- Data for MAPPING columns.
					p_information177    => l_mapping_name1,
					p_information178    => l_mapping_id1,
					-- END other product Mapping columns.
					p_information257     => l_est_rec.ordr_num,
                              p_information166     => NULL,  --No ESD for Job Group
                              p_information306     => l_job_start_date,
                              p_information265    => l_est_rec.object_version_number,
			      p_information295    => l_est_rec.criteria_score,
			      p_information296    => l_est_rec.criteria_weight,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_est_result_id is null then
                       l_out_est_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_est_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_SUPPL_ROLE_PRTE_F ----------------------
             ---------------------------------------------------------------
             --------------------------------------------------------------
             -- START OF BEN_ELIG_DSBLTY_CTG_PRTE_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_ect_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_dsblty_ctg_prte_id := l_parent_rec.elig_dsblty_ctg_prte_id ;
                 --
                 for l_ect_rec in c_ect(l_parent_rec.elig_dsblty_ctg_prte_id,l_mirror_src_entity_result_id,'ECT' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ECT');
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := hr_general.decode_lookup('DISABILITY_CATEGORY',l_ect_rec.category)
                                      || ben_plan_design_program_module.get_exclude_message(l_ect_rec.excld_flag);
                                      --'Intersection';
                   --
                   if p_effective_date between l_ect_rec.effective_start_date
                      and l_ect_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id          => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ECT',
                     p_information1     => l_ect_rec.elig_dsblty_ctg_prte_id,
                     p_information2     => l_ect_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_ect_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_ect_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information12     => l_ect_rec.category,
					p_information111     => l_ect_rec.ect_attribute1,
					p_information120     => l_ect_rec.ect_attribute10,
					p_information121     => l_ect_rec.ect_attribute11,
					p_information122     => l_ect_rec.ect_attribute12,
					p_information123     => l_ect_rec.ect_attribute13,
					p_information124     => l_ect_rec.ect_attribute14,
					p_information125     => l_ect_rec.ect_attribute15,
					p_information126     => l_ect_rec.ect_attribute16,
					p_information127     => l_ect_rec.ect_attribute17,
					p_information128     => l_ect_rec.ect_attribute18,
					p_information129     => l_ect_rec.ect_attribute19,
					p_information112     => l_ect_rec.ect_attribute2,
					p_information130     => l_ect_rec.ect_attribute20,
					p_information131     => l_ect_rec.ect_attribute21,
					p_information132     => l_ect_rec.ect_attribute22,
					p_information133     => l_ect_rec.ect_attribute23,
					p_information134     => l_ect_rec.ect_attribute24,
					p_information135     => l_ect_rec.ect_attribute25,
					p_information136     => l_ect_rec.ect_attribute26,
					p_information137     => l_ect_rec.ect_attribute27,
					p_information138     => l_ect_rec.ect_attribute28,
					p_information139     => l_ect_rec.ect_attribute29,
					p_information113     => l_ect_rec.ect_attribute3,
					p_information140     => l_ect_rec.ect_attribute30,
					p_information114     => l_ect_rec.ect_attribute4,
					p_information115     => l_ect_rec.ect_attribute5,
					p_information116     => l_ect_rec.ect_attribute6,
					p_information117     => l_ect_rec.ect_attribute7,
					p_information118     => l_ect_rec.ect_attribute8,
					p_information119     => l_ect_rec.ect_attribute9,
					p_information110     => l_ect_rec.ect_attribute_category,
					p_information263     => l_ect_rec.eligy_prfl_id,
					p_information11     => l_ect_rec.excld_flag,
					p_information260     => l_ect_rec.ordr_num,
                                        p_information265    => l_ect_rec.object_version_number,
					p_information295    => l_ect_rec.criteria_score,
					p_information296    => l_ect_rec.criteria_weight,

				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_ect_result_id is null then
                       l_out_ect_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_ect_result_id := l_copy_entity_result_id ;
                     end if;
                     --
                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_DSBLTY_CTG_PRTE_F ----------------------
             ---------------------------------------------------------------

             ---------------------------------------------------------------
             -- START OF BEN_ELIG_PERF_RTNG_PRTE_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_erg_from_parent(l_ELIGY_PRFL_ID) loop
             --
              l_mirror_src_entity_result_id := l_out_elp_result_id ;
              --
              l_elig_perf_rtng_prte_id := l_parent_rec.elig_perf_rtng_prte_id ;
              --
              for l_erg_rec in c_erg(l_parent_rec.elig_perf_rtng_prte_id,l_mirror_src_entity_result_id,'ERG' ) loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('ERG');
              fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := hr_general.decode_lookup('EMP_INTERVIEW_TYPE',l_erg_rec.event_type)
                               ||' - '||hr_general.decode_lookup('PERFORMANCE_RATING',l_erg_rec.perf_rtng_cd)
                               || ben_plan_design_program_module.get_exclude_message(l_erg_rec.excld_flag);
                                 --'Intersection';
              --
              if p_effective_date between l_erg_rec.effective_start_date
              and l_erg_rec.effective_end_date then
              --
                l_result_type_cd := 'DISPLAY';
              else
                l_result_type_cd := 'NO DISPLAY';
              end if;
              --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id           => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'ERG',
                p_information1     => l_erg_rec.elig_perf_rtng_prte_id,
                p_information2     => l_erg_rec.EFFECTIVE_START_DATE,
                p_information3     => l_erg_rec.EFFECTIVE_END_DATE,
                p_information4     => l_erg_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
				p_information263     => l_erg_rec.eligy_prfl_id,
				p_information111     => l_erg_rec.erg_attribute1,
				p_information120     => l_erg_rec.erg_attribute10,
				p_information121     => l_erg_rec.erg_attribute11,
				p_information122     => l_erg_rec.erg_attribute12,
				p_information123     => l_erg_rec.erg_attribute13,
				p_information124     => l_erg_rec.erg_attribute14,
				p_information125     => l_erg_rec.erg_attribute15,
				p_information126     => l_erg_rec.erg_attribute16,
				p_information127     => l_erg_rec.erg_attribute17,
				p_information128     => l_erg_rec.erg_attribute18,
				p_information129     => l_erg_rec.erg_attribute19,
				p_information112     => l_erg_rec.erg_attribute2,
				p_information130     => l_erg_rec.erg_attribute20,
				p_information131     => l_erg_rec.erg_attribute21,
				p_information132     => l_erg_rec.erg_attribute22,
				p_information133     => l_erg_rec.erg_attribute23,
				p_information134     => l_erg_rec.erg_attribute24,
				p_information135     => l_erg_rec.erg_attribute25,
				p_information136     => l_erg_rec.erg_attribute26,
				p_information137     => l_erg_rec.erg_attribute27,
				p_information138     => l_erg_rec.erg_attribute28,
				p_information139     => l_erg_rec.erg_attribute29,
				p_information113     => l_erg_rec.erg_attribute3,
				p_information140     => l_erg_rec.erg_attribute30,
				p_information114     => l_erg_rec.erg_attribute4,
				p_information115     => l_erg_rec.erg_attribute5,
				p_information116     => l_erg_rec.erg_attribute6,
				p_information117     => l_erg_rec.erg_attribute7,
				p_information118     => l_erg_rec.erg_attribute8,
				p_information119     => l_erg_rec.erg_attribute9,
				p_information110     => l_erg_rec.erg_attribute_category,
				p_information13     => l_erg_rec.event_type,
				p_information11     => l_erg_rec.excld_flag,
				p_information257     => l_erg_rec.ordr_num,
				p_information12     => l_erg_rec.perf_rtng_cd,
                                p_information265    => l_erg_rec.object_version_number,
				p_information295    => l_erg_rec.criteria_score,
				p_information296    => l_erg_rec.criteria_weight,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                --

                if l_out_erg_result_id is null then
                  l_out_erg_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                  l_out_erg_result_id := l_copy_entity_result_id ;
                end if;
                --
               end loop;
               --
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_PERF_RTNG_PRTE_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ELIG_QUA_IN_GR_PRTE_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_eqg_from_parent(l_ELIGY_PRFL_ID) loop
             --
             l_mirror_src_entity_result_id := l_out_elp_result_id ;
             --
             l_elig_qua_in_gr_prte_id := l_parent_rec.elig_qua_in_gr_prte_id ;
             --
               for l_eqg_rec in c_eqg(l_parent_rec.elig_qua_in_gr_prte_id,l_mirror_src_entity_result_id,'EQG' ) loop
               --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EQG');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('BEN_CWB_QUAR_IN_GRD',l_eqg_rec.quar_in_grade_cd)
                                    || ben_plan_design_program_module.get_exclude_message(l_eqg_rec.excld_flag);
                                    -- 'Intersection';
                 --
                 if p_effective_date between l_eqg_rec.effective_start_date
                 and l_eqg_rec.effective_end_date then
                 --
                   l_result_type_cd := 'DISPLAY';
                 else
                   l_result_type_cd := 'NO DISPLAY';
                 end if;
                 --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id           => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EQG',
                   p_information1     => l_eqg_rec.elig_qua_in_gr_prte_id,
                   p_information2     => l_eqg_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_eqg_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_eqg_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
				p_information263     => l_eqg_rec.eligy_prfl_id,
				p_information111     => l_eqg_rec.eqg_attribute1,
				p_information120     => l_eqg_rec.eqg_attribute10,
				p_information121     => l_eqg_rec.eqg_attribute11,
				p_information122     => l_eqg_rec.eqg_attribute12,
				p_information123     => l_eqg_rec.eqg_attribute13,
				p_information124     => l_eqg_rec.eqg_attribute14,
				p_information125     => l_eqg_rec.eqg_attribute15,
				p_information126     => l_eqg_rec.eqg_attribute16,
				p_information127     => l_eqg_rec.eqg_attribute17,
				p_information128     => l_eqg_rec.eqg_attribute18,
				p_information129     => l_eqg_rec.eqg_attribute19,
				p_information112     => l_eqg_rec.eqg_attribute2,
				p_information130     => l_eqg_rec.eqg_attribute20,
				p_information131     => l_eqg_rec.eqg_attribute21,
				p_information132     => l_eqg_rec.eqg_attribute22,
				p_information133     => l_eqg_rec.eqg_attribute23,
				p_information134     => l_eqg_rec.eqg_attribute24,
				p_information135     => l_eqg_rec.eqg_attribute25,
				p_information136     => l_eqg_rec.eqg_attribute26,
				p_information137     => l_eqg_rec.eqg_attribute27,
				p_information138     => l_eqg_rec.eqg_attribute28,
				p_information139     => l_eqg_rec.eqg_attribute29,
				p_information113     => l_eqg_rec.eqg_attribute3,
				p_information140     => l_eqg_rec.eqg_attribute30,
				p_information114     => l_eqg_rec.eqg_attribute4,
				p_information115     => l_eqg_rec.eqg_attribute5,
				p_information116     => l_eqg_rec.eqg_attribute6,
				p_information117     => l_eqg_rec.eqg_attribute7,
				p_information118     => l_eqg_rec.eqg_attribute8,
				p_information119     => l_eqg_rec.eqg_attribute9,
				p_information110     => l_eqg_rec.eqg_attribute_category,
				p_information12     => l_eqg_rec.excld_flag,
				p_information260     => l_eqg_rec.ordr_num,
				p_information11     => l_eqg_rec.quar_in_grade_cd,
                                p_information265    => l_eqg_rec.object_version_number,
				p_information295    => l_eqg_rec.criteria_score,
				p_information296    => l_eqg_rec.criteria_weight,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                 --

                 if l_out_eqg_result_id is null then
                   l_out_eqg_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_eqg_result_id := l_copy_entity_result_id ;
                 end if;
                 --
               end loop;
               --
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_QUA_IN_GR_PRTE_F ----------------------
             ---------------------------------------------------------------

             ---------------------------------------------------------------
             -- START OF BEN_ELIG_TBCO_USE_PRTE_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_etu_from_parent(l_ELIGY_PRFL_ID) loop
             --
               l_mirror_src_entity_result_id := l_out_elp_result_id ;
               --
               l_elig_tbco_use_prte_id := l_parent_rec.elig_tbco_use_prte_id ;
               --
               for l_etu_rec in c_etu(l_parent_rec.elig_tbco_use_prte_id,l_mirror_src_entity_result_id,'ETU' ) loop
               --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('ETU');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('TOBACCO_USER',l_etu_rec.uses_tbco_flag)
                                    || ben_plan_design_program_module.get_exclude_message(l_etu_rec.excld_flag);
                                    --Intersection';
                 --
                 if p_effective_date between l_etu_rec.effective_start_date
                 and l_etu_rec.effective_end_date then
                 --
                   l_result_type_cd := 'DISPLAY';
                else
                   l_result_type_cd := 'NO DISPLAY';
                end if;
                --
                l_copy_entity_result_id := null;
                l_object_version_number := null;
                ben_copy_entity_results_api.create_copy_entity_results(
                  p_copy_entity_result_id           => l_copy_entity_result_id,
                  p_copy_entity_txn_id             => p_copy_entity_txn_id,
                  p_result_type_cd                 => l_result_type_cd,
                  p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                  p_number_of_copies               => l_number_of_copies,
                  p_table_route_id                 => l_table_route_id,
		  P_TABLE_ALIAS                    => 'ETU',
                  p_information1     => l_etu_rec.elig_tbco_use_prte_id,
                  p_information2     => l_etu_rec.EFFECTIVE_START_DATE,
                  p_information3     => l_etu_rec.EFFECTIVE_END_DATE,
                  p_information4     => l_etu_rec.business_group_id,
                  p_information5     => l_information5 , -- 9999 put name for h-grid
				p_information263     => l_etu_rec.eligy_prfl_id,
				p_information111     => l_etu_rec.etu_attribute1,
				p_information120     => l_etu_rec.etu_attribute10,
				p_information121     => l_etu_rec.etu_attribute11,
				p_information122     => l_etu_rec.etu_attribute12,
				p_information123     => l_etu_rec.etu_attribute13,
				p_information124     => l_etu_rec.etu_attribute14,
				p_information125     => l_etu_rec.etu_attribute15,
				p_information126     => l_etu_rec.etu_attribute16,
				p_information127     => l_etu_rec.etu_attribute17,
				p_information128     => l_etu_rec.etu_attribute18,
				p_information129     => l_etu_rec.etu_attribute19,
				p_information112     => l_etu_rec.etu_attribute2,
				p_information130     => l_etu_rec.etu_attribute20,
				p_information131     => l_etu_rec.etu_attribute21,
				p_information132     => l_etu_rec.etu_attribute22,
				p_information133     => l_etu_rec.etu_attribute23,
				p_information134     => l_etu_rec.etu_attribute24,
				p_information135     => l_etu_rec.etu_attribute25,
				p_information136     => l_etu_rec.etu_attribute26,
				p_information137     => l_etu_rec.etu_attribute27,
				p_information138     => l_etu_rec.etu_attribute28,
				p_information139     => l_etu_rec.etu_attribute29,
				p_information113     => l_etu_rec.etu_attribute3,
				p_information140     => l_etu_rec.etu_attribute30,
				p_information114     => l_etu_rec.etu_attribute4,
				p_information115     => l_etu_rec.etu_attribute5,
				p_information116     => l_etu_rec.etu_attribute6,
				p_information117     => l_etu_rec.etu_attribute7,
				p_information118     => l_etu_rec.etu_attribute8,
				p_information119     => l_etu_rec.etu_attribute9,
				p_information110     => l_etu_rec.etu_attribute_category,
				p_information11     => l_etu_rec.excld_flag,
				p_information260     => l_etu_rec.ordr_num,
				p_information12     => l_etu_rec.uses_tbco_flag,
                                p_information265    => l_etu_rec.object_version_number,
				p_information295    => l_etu_rec.criteria_score,
				p_information296    => l_etu_rec.criteria_weight,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                  --

                 if l_out_etu_result_id is null then
                   l_out_etu_result_id := l_copy_entity_result_id;
                 end if;

                 if l_result_type_cd = 'DISPLAY' then
                   l_out_etu_result_id := l_copy_entity_result_id ;
                 end if;
                 --
               end loop;
              --
             end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_TBCO_USE_PRTE_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ELIG_TTL_CVG_VOL_PRTE_F ----------------------
             ---------------------------------------------------------------
              --
              for l_parent_rec  in c_etc_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_ttl_cvg_vol_prte_id := l_parent_rec.elig_ttl_cvg_vol_prte_id ;
                 --
                 for l_etc_rec in c_etc(l_parent_rec.elig_ttl_cvg_vol_prte_id,l_mirror_src_entity_result_id,'ETC' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ETC');
                     fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  :=  l_etc_rec.mn_cvg_vol_amt || ' - ' ||l_etc_rec.mx_cvg_vol_amt
                                       || ben_plan_design_program_module.get_exclude_message(l_etc_rec.excld_flag);
                   --
                   if p_effective_date between l_etc_rec.effective_start_date
                      and l_etc_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id           => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ETC',
                     p_information1     => l_etc_rec.elig_ttl_cvg_vol_prte_id,
                     p_information2     => l_etc_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_etc_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_etc_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information14     => l_etc_rec.cvg_vol_det_cd,
					p_information261     => l_etc_rec.cvg_vol_det_rl,
					p_information263     => l_etc_rec.eligy_prfl_id,
					p_information111     => l_etc_rec.etc_attribute1,
					p_information120     => l_etc_rec.etc_attribute10,
					p_information121     => l_etc_rec.etc_attribute11,
					p_information122     => l_etc_rec.etc_attribute12,
					p_information123     => l_etc_rec.etc_attribute13,
					p_information124     => l_etc_rec.etc_attribute14,
					p_information125     => l_etc_rec.etc_attribute15,
					p_information126     => l_etc_rec.etc_attribute16,
					p_information127     => l_etc_rec.etc_attribute17,
					p_information128     => l_etc_rec.etc_attribute18,
					p_information129     => l_etc_rec.etc_attribute19,
					p_information112     => l_etc_rec.etc_attribute2,
					p_information130     => l_etc_rec.etc_attribute20,
					p_information131     => l_etc_rec.etc_attribute21,
					p_information132     => l_etc_rec.etc_attribute22,
					p_information133     => l_etc_rec.etc_attribute23,
					p_information134     => l_etc_rec.etc_attribute24,
					p_information135     => l_etc_rec.etc_attribute25,
					p_information136     => l_etc_rec.etc_attribute26,
					p_information137     => l_etc_rec.etc_attribute27,
					p_information138     => l_etc_rec.etc_attribute28,
					p_information139     => l_etc_rec.etc_attribute29,
					p_information113     => l_etc_rec.etc_attribute3,
					p_information140     => l_etc_rec.etc_attribute30,
					p_information114     => l_etc_rec.etc_attribute4,
					p_information115     => l_etc_rec.etc_attribute5,
					p_information116     => l_etc_rec.etc_attribute6,
					p_information117     => l_etc_rec.etc_attribute7,
					p_information118     => l_etc_rec.etc_attribute8,
					p_information119     => l_etc_rec.etc_attribute9,
					p_information110     => l_etc_rec.etc_attribute_category,
					p_information11     => l_etc_rec.excld_flag,
					p_information293     => l_etc_rec.mn_cvg_vol_amt,
					p_information294     => l_etc_rec.mx_cvg_vol_amt,
					p_information12     => l_etc_rec.no_mn_cvg_vol_amt_apls_flag,
					p_information13     => l_etc_rec.no_mx_cvg_vol_amt_apls_flag,
					p_information260     => l_etc_rec.ordr_num,
                                        p_information265    => l_etc_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                     --

                     if l_out_etc_result_id is null then
                       l_out_etc_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_etc_result_id := l_copy_entity_result_id ;
                     end if;
                     --

                      if (l_etc_rec.cvg_vol_det_rl is not null) then
		           ben_plan_design_program_module.create_formula_result(
			       p_validate               => p_validate
			      ,p_copy_entity_result_id  => l_copy_entity_result_id
			      ,p_copy_entity_txn_id     => p_copy_entity_txn_id
			      ,p_formula_id             => l_etc_rec.cvg_vol_det_rl
			      ,p_business_group_id      => l_etc_rec.business_group_id
			      ,p_number_of_copies       => l_number_of_copies
			      ,p_object_version_number  => l_object_version_number
			      ,p_effective_date         => p_effective_date);
		         end if;

                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_TTL_CVG_VOL_PRTE_F ----------------------
             ---------------------------------------------------------------
              ---------------------------------------------------------------
              -- START OF BEN_ELIG_TTL_PRTT_PRTE_F ----------------------
              ---------------------------------------------------------------
              --
              for l_parent_rec  in c_etp_from_parent(l_ELIGY_PRFL_ID) loop
                 --
                 l_mirror_src_entity_result_id := l_out_elp_result_id ;
                 --
                 l_elig_ttl_prtt_prte_id := l_parent_rec.elig_ttl_prtt_prte_id ;
                 --
                 for l_etp_rec in c_etp(l_parent_rec.elig_ttl_prtt_prte_id,l_mirror_src_entity_result_id,'ETP' ) loop
                   --
                   l_table_route_id := null ;
                   open ben_plan_design_program_module.g_table_route('ETP');
                     fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   close ben_plan_design_program_module.g_table_route ;
                   --
                   l_information5  := l_etp_rec.mn_prtt_num ||' - '||l_etp_rec.mx_prtt_num
                                      || ben_plan_design_program_module.get_exclude_message(l_etp_rec.excld_flag);
                   --
                   if p_effective_date between l_etp_rec.effective_start_date
                      and l_etp_rec.effective_end_date then
                    --
                      l_result_type_cd := 'DISPLAY';
                   else
                      l_result_type_cd := 'NO DISPLAY';
                   end if;
                     --
                   l_copy_entity_result_id := null;
                   l_object_version_number := null;
                   ben_copy_entity_results_api.create_copy_entity_results(
                     p_copy_entity_result_id           => l_copy_entity_result_id,
                     p_copy_entity_txn_id             => p_copy_entity_txn_id,
                     p_result_type_cd                 => l_result_type_cd,
                     p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                     p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                     p_number_of_copies               => l_number_of_copies,
                     p_table_route_id                 => l_table_route_id,
		     P_TABLE_ALIAS                    => 'ETP',
                     p_information1     => l_etp_rec.elig_ttl_prtt_prte_id,
                     p_information2     => l_etp_rec.EFFECTIVE_START_DATE,
                     p_information3     => l_etp_rec.EFFECTIVE_END_DATE,
                     p_information4     => l_etp_rec.business_group_id,
                     p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information263     => l_etp_rec.eligy_prfl_id,
					p_information111     => l_etp_rec.etp_attribute1,
					p_information120     => l_etp_rec.etp_attribute10,
					p_information121     => l_etp_rec.etp_attribute11,
					p_information122     => l_etp_rec.etp_attribute12,
					p_information123     => l_etp_rec.etp_attribute13,
					p_information124     => l_etp_rec.etp_attribute14,
					p_information125     => l_etp_rec.etp_attribute15,
					p_information126     => l_etp_rec.etp_attribute16,
					p_information127     => l_etp_rec.etp_attribute17,
					p_information128     => l_etp_rec.etp_attribute18,
					p_information129     => l_etp_rec.etp_attribute19,
					p_information112     => l_etp_rec.etp_attribute2,
					p_information130     => l_etp_rec.etp_attribute20,
					p_information131     => l_etp_rec.etp_attribute21,
					p_information132     => l_etp_rec.etp_attribute22,
					p_information133     => l_etp_rec.etp_attribute23,
					p_information134     => l_etp_rec.etp_attribute24,
					p_information135     => l_etp_rec.etp_attribute25,
					p_information136     => l_etp_rec.etp_attribute26,
					p_information137     => l_etp_rec.etp_attribute27,
					p_information138     => l_etp_rec.etp_attribute28,
					p_information139     => l_etp_rec.etp_attribute29,
					p_information113     => l_etp_rec.etp_attribute3,
					p_information140     => l_etp_rec.etp_attribute30,
					p_information114     => l_etp_rec.etp_attribute4,
					p_information115     => l_etp_rec.etp_attribute5,
					p_information116     => l_etp_rec.etp_attribute6,
					p_information117     => l_etp_rec.etp_attribute7,
					p_information118     => l_etp_rec.etp_attribute8,
					p_information119     => l_etp_rec.etp_attribute9,
					p_information110     => l_etp_rec.etp_attribute_category,
					p_information14     => l_etp_rec.excld_flag,
					p_information260     => l_etp_rec.mn_prtt_num,
					p_information261     => l_etp_rec.mx_prtt_num,
					p_information12     => l_etp_rec.no_mn_prtt_num_apls_flag,
					p_information13     => l_etp_rec.no_mx_prtt_num_apls_flag,
					p_information259     => l_etp_rec.ordr_num,
					p_information11     => l_etp_rec.prtt_det_cd,
					p_information262     => l_etp_rec.prtt_det_rl,
                                        p_information265    => l_etp_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );

                     --

                     if l_out_etp_result_id is null then
                       l_out_etp_result_id := l_copy_entity_result_id;
                     end if;

                     if l_result_type_cd = 'DISPLAY' then
                        l_out_etp_result_id := l_copy_entity_result_id ;
                     end if;
                     --

                     if (l_etp_rec.prtt_det_rl is not null) then
		           ben_plan_design_program_module.create_formula_result(
			       p_validate               => p_validate
			      ,p_copy_entity_result_id  => l_copy_entity_result_id
			      ,p_copy_entity_txn_id     => p_copy_entity_txn_id
			      ,p_formula_id             => l_etp_rec.prtt_det_rl
			      ,p_business_group_id      => l_etp_rec.business_group_id
			      ,p_number_of_copies       => l_number_of_copies
			      ,p_object_version_number  => l_object_version_number
			      ,p_effective_date         => p_effective_date);
		         end if;

                  end loop;
                  --
                end loop;
             ---------------------------------------------------------------
             -- END OF BEN_ELIG_TTL_PRTT_PRTE_F ----------------------
             ---------------------------------------------------------------
             ---------------------------------------------------------------
             -- START OF BEN_ELIG_DSBLD_PRTE_F ----------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_edb_from_parent(l_ELIGY_PRFL_ID) loop
             --
              l_mirror_src_entity_result_id := l_out_elp_result_id ;
              --
              l_elig_dsbld_prte_id := l_parent_rec.elig_dsbld_prte_id ;
              --
              for l_edb_rec in c_edb(l_parent_rec.elig_dsbld_prte_id,l_mirror_src_entity_result_id,'EDB' ) loop
              --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('EDB');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := hr_general.decode_lookup('REGISTERED_DISABLED',l_edb_rec.dsbld_cd)
                                   || ben_plan_design_program_module.get_exclude_message(l_edb_rec.excld_flag);
                                   -- 'Intersection';
                --
                if p_effective_date between l_edb_rec.effective_start_date
                and l_edb_rec.effective_end_date then
                --
                  l_result_type_cd := 'DISPLAY';
                else
                  l_result_type_cd := 'NO DISPLAY';
                end if;
                --
                l_copy_entity_result_id := null;
                l_object_version_number := null;
                ben_copy_entity_results_api.create_copy_entity_results(
                  p_copy_entity_result_id           => l_copy_entity_result_id,
                  p_copy_entity_txn_id             => p_copy_entity_txn_id,
                  p_result_type_cd                 => l_result_type_cd,
                  p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                  p_number_of_copies               => l_number_of_copies,
                  p_table_route_id                 => l_table_route_id,
		  P_TABLE_ALIAS                    => 'EDB',
                  p_information1     => l_edb_rec.elig_dsbld_prte_id,
                  p_information2     => l_edb_rec.EFFECTIVE_START_DATE,
                  p_information3     => l_edb_rec.EFFECTIVE_END_DATE,
                  p_information4     => l_edb_rec.business_group_id,
                  p_information5     => l_information5 , -- 9999 put name for h-grid
				p_information12     => l_edb_rec.dsbld_cd,
				p_information111     => l_edb_rec.edb_attribute1,
				p_information120     => l_edb_rec.edb_attribute10,
				p_information121     => l_edb_rec.edb_attribute11,
				p_information122     => l_edb_rec.edb_attribute12,
				p_information123     => l_edb_rec.edb_attribute13,
				p_information124     => l_edb_rec.edb_attribute14,
				p_information125     => l_edb_rec.edb_attribute15,
				p_information126     => l_edb_rec.edb_attribute16,
				p_information127     => l_edb_rec.edb_attribute17,
				p_information128     => l_edb_rec.edb_attribute18,
				p_information129     => l_edb_rec.edb_attribute19,
				p_information112     => l_edb_rec.edb_attribute2,
				p_information130     => l_edb_rec.edb_attribute20,
				p_information131     => l_edb_rec.edb_attribute21,
				p_information132     => l_edb_rec.edb_attribute22,
				p_information133     => l_edb_rec.edb_attribute23,
				p_information134     => l_edb_rec.edb_attribute24,
				p_information135     => l_edb_rec.edb_attribute25,
				p_information136     => l_edb_rec.edb_attribute26,
				p_information137     => l_edb_rec.edb_attribute27,
				p_information138     => l_edb_rec.edb_attribute28,
				p_information139     => l_edb_rec.edb_attribute29,
				p_information113     => l_edb_rec.edb_attribute3,
				p_information140     => l_edb_rec.edb_attribute30,
				p_information114     => l_edb_rec.edb_attribute4,
				p_information115     => l_edb_rec.edb_attribute5,
				p_information116     => l_edb_rec.edb_attribute6,
				p_information117     => l_edb_rec.edb_attribute7,
				p_information118     => l_edb_rec.edb_attribute8,
				p_information119     => l_edb_rec.edb_attribute9,
				p_information110     => l_edb_rec.edb_attribute_category,
				p_information263     => l_edb_rec.eligy_prfl_id,
				p_information11     => l_edb_rec.excld_flag,
				p_information260     => l_edb_rec.ordr_num,
                                p_information265    => l_edb_rec.object_version_number,
				p_information295    => l_edb_rec.criteria_score,
			        p_information296    => l_edb_rec.criteria_weight,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                  --

                  if l_out_edb_result_id is null then
                    l_out_edb_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                    l_out_edb_result_id := l_copy_entity_result_id ;
                 end if;
                 --
               end loop;
              --
             end loop;
            ---------------------------------------------------------------
            -- END OF BEN_ELIG_DSBLD_PRTE_F ----------------------
            ---------------------------------------------------------------
            ---------------------------------------------------------------
             -- START OF BEN_ELIG_HLTH_CVG_PRTE_F -------------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_ehc_from_parent(l_ELIGY_PRFL_ID) loop
             --
              l_mirror_src_entity_result_id := l_out_elp_result_id ;
              --
              l_elig_hlth_cvg_prte_id := l_parent_rec.elig_hlth_cvg_prte_id ;
              --
              for l_ehc_rec in c_ehc(l_parent_rec.elig_hlth_cvg_prte_id,l_mirror_src_entity_result_id,'EHC' ) loop
              --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('EHC');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := ben_plan_design_program_module.get_hlth_cvg_name(l_ehc_rec.pl_typ_opt_typ_id
                                                                                   ,l_ehc_rec.oipl_id
                                                                                   ,p_effective_date)
                                   || ben_plan_design_program_module.get_exclude_message(l_ehc_rec.excld_flag);
                                   --'Intersection';

                if p_effective_date between l_ehc_rec.effective_start_date
                and l_ehc_rec.effective_end_date then
                --
                  l_result_type_cd := 'DISPLAY';
                else
                  l_result_type_cd := 'NO DISPLAY';
                end if;
                --
                l_copy_entity_result_id := null;
                l_object_version_number := null;
                ben_copy_entity_results_api.create_copy_entity_results(
                  p_copy_entity_result_id           => l_copy_entity_result_id,
                  p_copy_entity_txn_id             => p_copy_entity_txn_id,
                  p_result_type_cd                 => l_result_type_cd,
                  p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                  p_number_of_copies               => l_number_of_copies,
                  p_table_route_id                 => l_table_route_id,
		  P_TABLE_ALIAS                    => 'EHC',
                  p_information1     => l_ehc_rec.elig_hlth_cvg_prte_id,
                  p_information2     => l_ehc_rec.EFFECTIVE_START_DATE,
                  p_information3     => l_ehc_rec.EFFECTIVE_END_DATE,
                  p_information4     => l_ehc_rec.business_group_id,
                  p_information5     => l_information5 , -- 9999 put name for h-grid
			p_INFORMATION111     => l_ehc_rec.EHC_ATTRIBUTE1,
                  p_INFORMATION120     => l_ehc_rec.EHC_ATTRIBUTE10,
                  p_INFORMATION121     => l_ehc_rec.EHC_ATTRIBUTE11,
                  p_INFORMATION122     => l_ehc_rec.EHC_ATTRIBUTE12,
                  p_INFORMATION123     => l_ehc_rec.EHC_ATTRIBUTE13,
                  p_INFORMATION124     => l_ehc_rec.EHC_ATTRIBUTE14,
                  p_INFORMATION125     => l_ehc_rec.EHC_ATTRIBUTE15,
                  p_INFORMATION126     => l_ehc_rec.EHC_ATTRIBUTE16,
                  p_INFORMATION127     => l_ehc_rec.EHC_ATTRIBUTE17,
                  p_INFORMATION128     => l_ehc_rec.EHC_ATTRIBUTE18,
                  p_INFORMATION129     => l_ehc_rec.EHC_ATTRIBUTE19,
                  p_INFORMATION112     => l_ehc_rec.EHC_ATTRIBUTE2,
                  p_INFORMATION130     => l_ehc_rec.EHC_ATTRIBUTE20,
                  p_INFORMATION131     => l_ehc_rec.EHC_ATTRIBUTE21,
                  p_INFORMATION132     => l_ehc_rec.EHC_ATTRIBUTE22,
                  p_INFORMATION133     => l_ehc_rec.EHC_ATTRIBUTE23,
                  p_INFORMATION134     => l_ehc_rec.EHC_ATTRIBUTE24,
                  p_INFORMATION135     => l_ehc_rec.EHC_ATTRIBUTE25,
                  p_INFORMATION136     => l_ehc_rec.EHC_ATTRIBUTE26,
                  p_INFORMATION137     => l_ehc_rec.EHC_ATTRIBUTE27,
                  p_INFORMATION138     => l_ehc_rec.EHC_ATTRIBUTE28,
                  p_INFORMATION139     => l_ehc_rec.EHC_ATTRIBUTE29,
                  p_INFORMATION113     => l_ehc_rec.EHC_ATTRIBUTE3,
                  p_INFORMATION140     => l_ehc_rec.EHC_ATTRIBUTE30,
                  p_INFORMATION114     => l_ehc_rec.EHC_ATTRIBUTE4,
                  p_INFORMATION115     => l_ehc_rec.EHC_ATTRIBUTE5,
                  p_INFORMATION116     => l_ehc_rec.EHC_ATTRIBUTE6,
                  p_INFORMATION117     => l_ehc_rec.EHC_ATTRIBUTE7,
                  p_INFORMATION118     => l_ehc_rec.EHC_ATTRIBUTE8,
                  p_INFORMATION119     => l_ehc_rec.EHC_ATTRIBUTE9,
                  p_INFORMATION110     => l_ehc_rec.EHC_ATTRIBUTE_CATEGORY,
                  p_INFORMATION263     => l_ehc_rec.ELIGY_PRFL_ID,
                  p_INFORMATION11     => l_ehc_rec.EXCLD_FLAG,
                  p_INFORMATION258     => l_ehc_rec.OIPL_ID,
                  p_INFORMATION261     => l_ehc_rec.ORDR_NUM,
                  p_INFORMATION228     => l_ehc_rec.PL_TYP_OPT_TYP_ID,
                  p_information265    => l_ehc_rec.object_version_number,
			--
			-- END REPLACE PARAMETER LINES
			p_object_version_number          => l_object_version_number,
			p_effective_date                 => p_effective_date       );
                  --

                  if l_out_ehc_result_id is null then
                    l_out_ehc_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                    l_out_ehc_result_id := l_copy_entity_result_id ;
                 end if;
                 --
               end loop;
              --
             end loop;
            ---------------------------------------------------------------
            -- END OF BEN_ELIG_HLTH_CVG_PRTE_F ----------------------
            ---------------------------------------------------------------
            ---------------------------------------------------------------
             -- START OF BEN_ELIG_ANTHR_PL_PRTE_F -------------------------
             ---------------------------------------------------------------
             --
             for l_parent_rec  in c_eop_from_parent(l_ELIGY_PRFL_ID) loop
             --
              l_mirror_src_entity_result_id := l_out_elp_result_id ;
              --
              l_elig_anthr_pl_prte_id := l_parent_rec.elig_anthr_pl_prte_id ;
              --
              for l_eop_rec in c_eop(l_parent_rec.elig_anthr_pl_prte_id,l_mirror_src_entity_result_id,'EOP' ) loop
              --
                l_table_route_id := null ;
                open ben_plan_design_program_module.g_table_route('EOP');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                close ben_plan_design_program_module.g_table_route ;
                --
                l_information5  := ben_plan_design_program_module.get_pl_name(l_eop_rec.pl_id
                                                                             ,p_effective_date)
                                   || ben_plan_design_program_module.get_exclude_message(l_eop_rec.excld_flag);
                                   --'Intersection';

                if p_effective_date between l_eop_rec.effective_start_date
                and l_eop_rec.effective_end_date then
                --
                  l_result_type_cd := 'DISPLAY';
                else
                  l_result_type_cd := 'NO DISPLAY';
                end if;
                --
                l_copy_entity_result_id := null;
                l_object_version_number := null;
                ben_copy_entity_results_api.create_copy_entity_results(
                  p_copy_entity_result_id           => l_copy_entity_result_id,
                  p_copy_entity_txn_id             => p_copy_entity_txn_id,
                  p_result_type_cd                 => l_result_type_cd,
                  p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                  p_parent_entity_result_id      => l_mirror_src_entity_result_id,
                  p_number_of_copies               => l_number_of_copies,
		  p_table_route_id                 => l_table_route_id,
                  P_TABLE_ALIAS                    => 'EOP',
                  p_information1     => l_eop_rec.elig_anthr_pl_prte_id,
                  p_information2     => l_eop_rec.EFFECTIVE_START_DATE,
                  p_information3     => l_eop_rec.EFFECTIVE_END_DATE,
                  p_information4     => l_eop_rec.business_group_id,
                  p_information5     => l_information5 , -- 9999 put name for h-grid
		  p_INFORMATION263     => l_eop_rec.ELIGY_PRFL_ID,
                  p_INFORMATION111     => l_eop_rec.EOP_ATTRIBUTE1,
                  p_INFORMATION120     => l_eop_rec.EOP_ATTRIBUTE10,
                  p_INFORMATION121     => l_eop_rec.EOP_ATTRIBUTE11,
                  p_INFORMATION122     => l_eop_rec.EOP_ATTRIBUTE12,
                  p_INFORMATION123     => l_eop_rec.EOP_ATTRIBUTE13,
                  p_INFORMATION124     => l_eop_rec.EOP_ATTRIBUTE14,
                  p_INFORMATION125     => l_eop_rec.EOP_ATTRIBUTE15,
                  p_INFORMATION126     => l_eop_rec.EOP_ATTRIBUTE16,
                  p_INFORMATION127     => l_eop_rec.EOP_ATTRIBUTE17,
                  p_INFORMATION128     => l_eop_rec.EOP_ATTRIBUTE18,
                  p_INFORMATION129     => l_eop_rec.EOP_ATTRIBUTE19,
                  p_INFORMATION112     => l_eop_rec.EOP_ATTRIBUTE2,
                  p_INFORMATION130     => l_eop_rec.EOP_ATTRIBUTE20,
                  p_INFORMATION131     => l_eop_rec.EOP_ATTRIBUTE21,
                  p_INFORMATION132     => l_eop_rec.EOP_ATTRIBUTE22,
                  p_INFORMATION133     => l_eop_rec.EOP_ATTRIBUTE23,
                  p_INFORMATION134     => l_eop_rec.EOP_ATTRIBUTE24,
                  p_INFORMATION135     => l_eop_rec.EOP_ATTRIBUTE25,
                  p_INFORMATION136     => l_eop_rec.EOP_ATTRIBUTE26,
                  p_INFORMATION137     => l_eop_rec.EOP_ATTRIBUTE27,
                  p_INFORMATION138     => l_eop_rec.EOP_ATTRIBUTE28,
                  p_INFORMATION139     => l_eop_rec.EOP_ATTRIBUTE29,
                  p_INFORMATION113     => l_eop_rec.EOP_ATTRIBUTE3,
                  p_INFORMATION140     => l_eop_rec.EOP_ATTRIBUTE30,
                  p_INFORMATION114     => l_eop_rec.EOP_ATTRIBUTE4,
                  p_INFORMATION115     => l_eop_rec.EOP_ATTRIBUTE5,
                  p_INFORMATION116     => l_eop_rec.EOP_ATTRIBUTE6,
                  p_INFORMATION117     => l_eop_rec.EOP_ATTRIBUTE7,
                  p_INFORMATION118     => l_eop_rec.EOP_ATTRIBUTE8,
                  p_INFORMATION119     => l_eop_rec.EOP_ATTRIBUTE9,
                  p_INFORMATION110     => l_eop_rec.EOP_ATTRIBUTE_CATEGORY,
                  p_INFORMATION11     => l_eop_rec.EXCLD_FLAG,
                  p_INFORMATION257     => l_eop_rec.ORDR_NUM,
                  p_INFORMATION261     => l_eop_rec.PL_ID,
                  p_information265    => l_eop_rec.object_version_number,
			--
			-- END REPLACE PARAMETER LINES
			p_object_version_number          => l_object_version_number,
			p_effective_date                 => p_effective_date       );
                  --

                  if l_out_eop_result_id is null then
                    l_out_eop_result_id := l_copy_entity_result_id;
                  end if;

                  if l_result_type_cd = 'DISPLAY' then
                    l_out_eop_result_id := l_copy_entity_result_id ;
                 end if;
                 --
               end loop;
              --
             end loop;
            ---------------------------------------------------------------
            -- END OF BEN_ELIG_HLTH_CVG_PRTE_F ----------------------
            ---------------------------------------------------------------
            --
            -- Bug 4169120 : Rate By Criteria
            --
            ---------------------------------------------------------------
            -------------- START OF BEN_ELIGY_CRIT_VALUES_F ---------------
            ---------------------------------------------------------------
             --
             for l_parent_rec in c_ecv_from_parent(l_ELIGY_PRFL_ID)
             loop
               --
               l_mirror_src_entity_result_id := l_out_elp_result_id ;
               --
               l_eligy_crit_values_id := l_parent_rec.eligy_crit_values_id ;
               --
               for l_ecv_rec in c_ecv(cv_eligy_crit_values_id        => l_parent_rec.eligy_crit_values_id,
                                      cv_mirror_src_entity_result_id => l_mirror_src_entity_result_id,
                                      cv_table_alias                 => 'ECV' )
               loop
                 --
                 l_table_route_id := null ;
                 --
                 open ben_plan_design_program_module.g_table_route('ECV');
                   --
                   fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                   --
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := ben_plan_design_program_module.get_eligy_criteria_name (l_ecv_rec.eligy_criteria_id ) ||
                                    ben_plan_design_program_module.get_exclude_message(l_ecv_rec.excld_flag);
                 --
                 if p_effective_date between l_ecv_rec.effective_start_date
                                         and l_ecv_rec.effective_end_date
                 then
                   --
                   l_result_type_cd := 'DISPLAY';
                   --
                 else
                   --
                   l_result_type_cd := 'NO DISPLAY';
                   --
                 end if;
                 --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 --
                 open c_egl_val_type_cd (l_ecv_rec.eligy_criteria_id );
                   --
                   fetch c_egl_val_type_cd into l_crit_col1_val_type_cd;
                   --
                   if l_crit_col1_val_type_cd in ('ORG_HIER', 'POS_HIER')
                   then
                     --
                     -- For Organization / Position Hierarchy type of criteria basis we will
                     -- copy following (so that we can auto map these values in bepdccp4.pkb STAGE -> BEN):
                     --
                     --       START_ORGANIZATION_NAME	INFORMATION187
                     --       START_POSITION_NAME	INFORMATION188
                     --       ORG_STRUCTURE_NAME	INFORMATION13
                     --       POS_STRUCTURE_NAME	INFORMATION14
                     --
                     map_org_pos_hierarchy ( p_val_type_cd       => l_crit_col1_val_type_cd,
                                             p_number1           => l_ecv_rec.number_value1,
                                             p_number2           => l_ecv_rec.number_value2,
                                             p_org_stru_name     => l_org_stru_name,
                                             p_start_org_name    => l_start_org_name,
                                             p_pos_stru_name     => l_pos_stru_name,
                                             p_start_pos_name    => l_start_pos_name,
                                             p_effective_date    => p_effective_date,
                                             p_business_group_id => l_ecv_rec.business_group_id
                                            );
                     --
                   else
                     --
                     l_org_stru_name   := null;
                     l_start_org_name  := null;
                     l_pos_stru_name   := null;
                     l_start_pos_name  := null;
                     --
                   end if;
                   --
                 close c_egl_val_type_cd ;
                 --
                 ben_copy_entity_results_api.create_copy_entity_results
                        (
                         p_copy_entity_result_id            => l_copy_entity_result_id,
                         p_copy_entity_txn_id               => p_copy_entity_txn_id,
                         p_result_type_cd                   => l_result_type_cd,
                         p_mirror_src_entity_result_id      => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id          => l_mirror_src_entity_result_id,
                         p_number_of_copies                 => l_number_of_copies,
                         p_table_route_id                   => l_table_route_id,
                         p_table_alias                      => 'ECV',
                         p_information1                     => l_ecv_rec.eligy_crit_values_id,
                         p_information2                     => l_ecv_rec.effective_start_date,
                         p_information3                     => l_ecv_rec.effective_end_date,
                         p_information4                     => l_ecv_rec.business_group_id,
                         p_information5                     => l_information5,
                         p_information11                    => l_ecv_rec.excld_flag,
                         p_information12                    => l_ecv_rec.legislation_code,
                         p_information13                    => l_org_stru_name,
                         p_information14                    => l_pos_stru_name,
                         p_information110                   => l_ecv_rec.ecv_attribute_category,
                         p_information111                   => l_ecv_rec.ecv_attribute1,
                         p_information112                   => l_ecv_rec.ecv_attribute2,
                         p_information113                   => l_ecv_rec.ecv_attribute3,
                         p_information114                   => l_ecv_rec.ecv_attribute4,
                         p_information115                   => l_ecv_rec.ecv_attribute5,
                         p_information116                   => l_ecv_rec.ecv_attribute6,
                         p_information117                   => l_ecv_rec.ecv_attribute7,
                         p_information118                   => l_ecv_rec.ecv_attribute8,
                         p_information119                   => l_ecv_rec.ecv_attribute9,
                         p_information120                   => l_ecv_rec.ecv_attribute10,
                         p_information121                   => l_ecv_rec.ecv_attribute11,
                         p_information122                   => l_ecv_rec.ecv_attribute12,
                         p_information123                   => l_ecv_rec.ecv_attribute13,
                         p_information124                   => l_ecv_rec.ecv_attribute14,
                         p_information125                   => l_ecv_rec.ecv_attribute15,
                         p_information126                   => l_ecv_rec.ecv_attribute16,
                         p_information127                   => l_ecv_rec.ecv_attribute17,
                         p_information128                   => l_ecv_rec.ecv_attribute18,
                         p_information129                   => l_ecv_rec.ecv_attribute19,
                         p_information130                   => l_ecv_rec.ecv_attribute20,
                         p_information131                   => l_ecv_rec.ecv_attribute21,
                         p_information132                   => l_ecv_rec.ecv_attribute22,
                         p_information133                   => l_ecv_rec.ecv_attribute23,
                         p_information134                   => l_ecv_rec.ecv_attribute24,
                         p_information135                   => l_ecv_rec.ecv_attribute25,
                         p_information136                   => l_ecv_rec.ecv_attribute26,
                         p_information137                   => l_ecv_rec.ecv_attribute27,
                         p_information138                   => l_ecv_rec.ecv_attribute28,
                         p_information139                   => l_ecv_rec.ecv_attribute29,
                         p_information140                   => l_ecv_rec.ecv_attribute30,
       		       --Bug 4592554
		         p_information181                   => l_ecv_rec.char_value3,
		         p_information182                   => l_ecv_rec.char_value4,
		       --End Bug 4592554
                         p_information185                   => l_ecv_rec.char_value1,
                         p_information186                   => l_ecv_rec.char_value2,
                         p_information187                   => l_start_org_name,
                         p_information188                   => l_start_pos_name,
                         p_information260                   => l_ecv_rec.ordr_num,          /* Bug 4314927 */
                         p_information263                   => l_ecv_rec.eligy_prfl_id,
                         p_information265                   => l_ecv_rec.object_version_number,
                         p_information272                   => l_ecv_rec.eligy_criteria_id, /* Bug 4314927 */
			 p_information295                   => l_ecv_rec.criteria_score,
			 p_information296                   => l_ecv_rec.criteria_weight,
       		       --Bug 4592554
		         p_information297                   => l_ecv_rec.number_value3,
		         p_information298                   => l_ecv_rec.number_value4,
		       --End Bug 4592554
                         p_information293                   => l_ecv_rec.number_value1,
                         p_information294                   => l_ecv_rec.number_value2,
                         p_information306                   => l_ecv_rec.date_value1,
                         p_information307                   => l_ecv_rec.date_value2,
		        --Bug 4592554
		         p_information308                   => l_ecv_rec.date_value3,
		         p_information309                   => l_ecv_rec.date_value4,
       		       --End Bug 4592554
                         p_object_version_number            => l_object_version_number,
                         p_effective_date                   => p_effective_date
                        );                 --
                 if l_out_ecv_result_id is null
                 then
                   --
                   l_out_ecv_result_id := l_copy_entity_result_id;
                   --
                 end if;
                 --
                 if l_result_type_cd = 'DISPLAY'
                 then
                   --
                   l_out_ecv_result_id := l_copy_entity_result_id ;
                   --
                 end if;
                 --
                 l_eligy_criteria_id := l_ecv_rec.eligy_criteria_id ;
                 --
               end loop;
               --
               ---------------------------------------------------------------
               ----------------- START OF BEN_ELIGY_CRITERIA -----------------
               ---------------------------------------------------------------
              -- Bug: 4347039. Moved the code to copy BEN_ELIGY_CRITERIA
              -- to the following procedure. PDW wanted externalizing this copying.
              --
              create_eligy_criteria_result (
               p_validate                   => p_validate
              ,p_copy_entity_result_id      => l_out_ecv_result_id
              ,p_copy_entity_txn_id         => p_copy_entity_txn_id
              ,p_eligy_criteria_id          => l_eligy_criteria_id
              ,p_business_group_id          => p_business_group_id
              ,p_number_of_copies           => p_number_of_copies
              ,p_object_version_number      => p_object_version_number
              ,p_effective_date             => p_effective_date
              ,p_parent_entity_result_id    => l_out_ecv_result_id);

             /*
             4347039: Commented out the whole logic.
             Moved this into the create_eligy_criteria_result procedure.
               --
               l_mirror_src_entity_result_id := l_out_ecv_result_id ;
               --
               --
               for l_egl_rec in c_egl(cv_eligy_criteria_id           => l_eligy_criteria_id,
                                      cv_mirror_src_entity_result_id => l_mirror_src_entity_result_id,
                                      cv_table_alias                 => 'EGL' )
               loop
                 --
                 l_egl_table_route_id := null ;
                 --
                 open ben_plan_design_program_module.g_table_route('EGL');
                   --
                   fetch ben_plan_design_program_module.g_table_route into l_egl_table_route_id ;
                   --
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_egl_result_type_cd := 'NO DISPLAY';
                 --
                 l_egl_copy_entity_result_id := null;
                 l_egl_object_version_number := null;
                 --
                 -- If criteria basis contains Value Set id then populate Value Set Name
                 -- in INFORMATION185 to use it again while auto-mapping in the target
                 -- business group in bepdccp1.pkb (stage -> ben)
                 --
                 l_flex_value_set_name := null;
                 --
                 if l_egl_rec.col1_value_set_id is not null
                 then
                   --
                   open c_value_set_name ( l_egl_rec.col1_value_set_id );
                     --
                     fetch c_value_set_name into l_flex_value_set_name;
                     --
                   close c_value_set_name;
                   --
                 end if;
                 --
                 ben_copy_entity_results_api.create_copy_entity_results
                        (
                         p_copy_entity_result_id            => l_egl_copy_entity_result_id,
                         p_copy_entity_txn_id               => p_copy_entity_txn_id,
                         p_result_type_cd                   => l_egl_result_type_cd,
                         p_mirror_src_entity_result_id      => l_mirror_src_entity_result_id,
                         p_parent_entity_result_id          => l_mirror_src_entity_result_id,
                         p_number_of_copies                 => l_number_of_copies,
                         p_table_route_id                   => l_egl_table_route_id,
                         p_table_alias                      => 'EGL',
                         p_information1                     => l_egl_rec.eligy_Criteria_id,
                         p_information4                     => l_egl_rec.business_group_id,
                         p_information5                     => l_egl_rec.name,
                         p_information11                    => l_egl_rec.short_code,
                         p_information12                    => l_egl_rec.criteria_type,
                         p_information13                    => l_egl_rec.crit_col1_val_type_cd,
                         p_information14                    => l_egl_rec.crit_col1_datatype,
                         p_information15                    => l_egl_rec.col1_lookup_type,
                         p_information16                    => l_egl_rec.access_table_name1,
                         p_information17                    => l_egl_rec.access_column_name1,
                         p_information18                    => l_egl_rec.time_entry_access_table_name1,
                         p_information19                    => l_egl_rec.time_entry_access_col_name1,
                         p_information20                    => l_egl_rec.crit_col2_val_type_cd,
                         p_information21                    => l_egl_rec.crit_col2_datatype,
                         p_information22                    => l_egl_rec.col2_lookup_type,
                         p_information23                    => l_egl_rec.access_table_name2,
                         p_information24                    => l_egl_rec.access_column_name2,
                         p_information25                    => l_egl_rec.time_entry_access_table_name2,
                         p_information26                    => l_egl_rec.time_entry_access_col_name2,
                         p_information27                    => l_egl_rec.allow_range_validation_flag,
                         p_information28                    => l_egl_rec.user_defined_flag,
                         p_information29                    => l_egl_rec.legislation_code,
                         p_information110                   => l_egl_rec.egl_attribute_category,
                         p_information111                   => l_egl_rec.egl_attribute1,
                         p_information112                   => l_egl_rec.egl_attribute2,
                         p_information113                   => l_egl_rec.egl_attribute3,
                         p_information114                   => l_egl_rec.egl_attribute4,
                         p_information115                   => l_egl_rec.egl_attribute5,
                         p_information116                   => l_egl_rec.egl_attribute6,
                         p_information117                   => l_egl_rec.egl_attribute7,
                         p_information118                   => l_egl_rec.egl_attribute8,
                         p_information119                   => l_egl_rec.egl_attribute9,
                         p_information120                   => l_egl_rec.egl_attribute10,
                         p_information121                   => l_egl_rec.egl_attribute11,
                         p_information122                   => l_egl_rec.egl_attribute12,
                         p_information123                   => l_egl_rec.egl_attribute13,
                         p_information124                   => l_egl_rec.egl_attribute14,
                         p_information125                   => l_egl_rec.egl_attribute15,
                         p_information126                   => l_egl_rec.egl_attribute16,
                         p_information127                   => l_egl_rec.egl_attribute17,
                         p_information128                   => l_egl_rec.egl_attribute18,
                         p_information129                   => l_egl_rec.egl_attribute19,
                         p_information130                   => l_egl_rec.egl_attribute20,
                         p_information131                   => l_egl_rec.egl_attribute21,
                         p_information132                   => l_egl_rec.egl_attribute22,
                         p_information133                   => l_egl_rec.egl_attribute23,
                         p_information134                   => l_egl_rec.egl_attribute24,
                         p_information135                   => l_egl_rec.egl_attribute25,
                         p_information136                   => l_egl_rec.egl_attribute26,
                         p_information137                   => l_egl_rec.egl_attribute27,
                         p_information138                   => l_egl_rec.egl_attribute28,
                         p_information139                   => l_egl_rec.egl_attribute29,
                         p_information140                   => l_egl_rec.egl_attribute30,
                         p_information170                   => l_egl_rec.name,
                         p_information185                   => l_flex_value_set_name,
                         p_information219                   => l_egl_rec.description,
                         p_information265                   => l_egl_rec.object_version_number,
                         p_information266                   => l_egl_rec.col1_value_set_id,
                         p_information267                   => l_egl_rec.col2_value_set_id,
                         p_information268                   => l_egl_rec.access_calc_rule,
                         p_object_version_number            => l_egl_object_version_number,
                         p_effective_date                   => p_effective_date
                        );
                 --
                 if l_egl_rec.access_calc_rule is not null
                 then
                   --
                   ben_plan_design_program_module.create_formula_result
                        (
                         p_validate                       =>  0,
                         p_copy_entity_result_id          =>  l_egl_copy_entity_result_id,
                         p_copy_entity_txn_id             =>  p_copy_entity_txn_id,
                         p_formula_id                     =>  l_egl_rec.access_calc_rule,
                         p_business_group_id              =>  l_egl_rec.business_group_id,
                         p_number_of_copies               =>  l_number_of_copies,
                         p_object_version_number          =>  l_object_version_number,
                         p_effective_date                 =>  p_effective_date
                        );
                   --
                 end if;
                 --
               end loop;
               -- */
               ---------------------------------------------------------------
               ------------------ END OF BEN_ELIGY_CRITERIA ------------------
               ---------------------------------------------------------------
               --
             end loop;
             --
            ---------------------------------------------------------------
            --------------- END OF BEN_ELIGY_CRIT_VALUES_F ----------------
            ---------------------------------------------------------------

           end if;
         ---------------------------------------------------------------
         -- END OF BEN_ELIGY_PRFL_F ----------------------
         ---------------------------------------------------------------

  end;

  procedure create_dep_elig_prfl_results
  (
   p_validate                       in  number    default 0 -- false
  ,p_mirror_src_entity_result_id    in  number
  ,p_parent_entity_result_id        in  number
  ,p_copy_entity_txn_id             in  number
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_no_dup_rslt                    in varchar2   default null
  ) is
    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'create_dep_elig_prfl_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    --
    l_cv_result_type_cd  varchar2(30) := 'DISPLAY' ;
    --
    cursor c_parent_result(c_parent_pk_id number,
                          c_parent_table_alias varchar2,
                          c_copy_entity_txn_id number) is
      select copy_entity_result_id mirror_src_entity_result_id
      from ben_copy_entity_results cpe
          -- pqh_table_route trt
      where cpe.information1= c_parent_pk_id
      and   cpe.result_type_cd = l_cv_result_type_cd
      and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
      -- and   cpe.table_route_id = trt.table_route_id
      and   cpe.table_alias = c_parent_table_alias ;
    ---
    -- Bug : 3752407 : Global cursor g_table_route will now be used
    -- Cursor to get table_route_id
    --
    -- cursor c_table_route(c_parent_table_alias varchar2) is
    --   select table_route_id
    --   from pqh_table_route trt
    --   where -- trt.from_clause = 'OAB'
    --   trt.table_alias = c_parent_table_alias ;
    ---

   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
   ---------------------------------------------------------------

   cursor c_dce(c_dpnt_cvg_eligy_prfl_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  dce.*
   from BEN_DPNT_CVG_ELIGY_PRFL_F dce
   where  dce.dpnt_cvg_eligy_prfl_id = c_dpnt_cvg_eligy_prfl_id
     -- and dce.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVG_ELIGY_PRFL_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvg_eligy_prfl_id
         -- and information4 = dce.business_group_id
           and information2 = dce.effective_start_date
           and information3 = dce.effective_end_date
        );
    l_dpnt_cvg_eligy_prfl_id                 number(15);
    l_out_dce_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVG_RQD_RLSHP_F ----------------------
   ---------------------------------------------------------------
   cursor c_dcr_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  dpnt_cvg_rqd_rlshp_id
   from BEN_DPNT_CVG_RQD_RLSHP_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_dcr(c_dpnt_cvg_rqd_rlshp_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  dcr.*
   from BEN_DPNT_CVG_RQD_RLSHP_F dcr
   where  dcr.dpnt_cvg_rqd_rlshp_id = c_dpnt_cvg_rqd_rlshp_id
     -- and dcr.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVG_RQD_RLSHP_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvg_rqd_rlshp_id
         -- and information4 = dcr.business_group_id
           and information2 = dcr.effective_start_date
           and information3 = dcr.effective_end_date
        );
    l_dpnt_cvg_rqd_rlshp_id                 number(15);
    l_out_dcr_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVG_RQD_RLSHP_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DPNT_CVRD_ANTHR_PL_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_dpc_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  dpnt_cvrd_anthr_pl_cvg_id
   from BEN_DPNT_CVRD_ANTHR_PL_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_dpc(c_dpnt_cvrd_anthr_pl_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  dpc.*
   from BEN_DPNT_CVRD_ANTHR_PL_CVG_F dpc
   where  dpc.dpnt_cvrd_anthr_pl_cvg_id = c_dpnt_cvrd_anthr_pl_cvg_id
     -- and dpc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DPNT_CVRD_ANTHR_PL_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dpnt_cvrd_anthr_pl_cvg_id
         -- and information4 = dpc.business_group_id
           and information2 = dpc.effective_start_date
           and information3 = dpc.effective_end_date
        );
    l_dpnt_cvrd_anthr_pl_cvg_id                 number(15);
    l_out_dpc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DPNT_CVRD_ANTHR_PL_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_DSGNTR_ENRLD_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_dec_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  dsgntr_enrld_cvg_id
   from BEN_DSGNTR_ENRLD_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_dec(c_dsgntr_enrld_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  dec.*
   from BEN_DSGNTR_ENRLD_CVG_F dec
   where  dec.dsgntr_enrld_cvg_id = c_dsgntr_enrld_cvg_id
     -- and dec.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_DSGNTR_ENRLD_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_dsgntr_enrld_cvg_id
         -- and information4 = dec.business_group_id
           and information2 = dec.effective_start_date
           and information3 = dec.effective_end_date
        );
    l_dsgntr_enrld_cvg_id                 number(15);
    l_out_dec_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_DSGNTR_ENRLD_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_AGE_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_eac_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select distinct elig_age_cvg_id
   from BEN_ELIG_AGE_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_eac(c_elig_age_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  eac.*
   from BEN_ELIG_AGE_CVG_F eac
   where  eac.elig_age_cvg_id = c_elig_age_cvg_id
     -- and eac.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_AGE_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_age_cvg_id
         -- and information4 = eac.business_group_id
           and information2 = eac.effective_start_date
           and information3 = eac.effective_end_date
        );
    l_elig_age_cvg_id                 number(15);
    l_out_eac_result_id   number(15);
   --
   cursor c_eac_drp(c_elig_age_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information246 age_fctr_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_AGE_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_age_cvg_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_AGE_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_DSBLD_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_edc_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  elig_dsbld_stat_cvg_id
   from BEN_ELIG_DSBLD_STAT_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_edc(c_elig_dsbld_stat_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  edc.*
   from BEN_ELIG_DSBLD_STAT_CVG_F edc
   where  edc.elig_dsbld_stat_cvg_id = c_elig_dsbld_stat_cvg_id
     -- and edc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_DSBLD_STAT_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_dsbld_stat_cvg_id
         -- and information4 = edc.business_group_id
           and information2 = edc.effective_start_date
           and information3 = edc.effective_end_date
        );
    l_elig_dsbld_stat_cvg_id                 number(15);
    l_out_edc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_DSBLD_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_MLTRY_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_emc_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  elig_mltry_stat_cvg_id
   from BEN_ELIG_MLTRY_STAT_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_emc(c_elig_mltry_stat_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  emc.*
   from BEN_ELIG_MLTRY_STAT_CVG_F emc
   where  emc.elig_mltry_stat_cvg_id = c_elig_mltry_stat_cvg_id
     -- and emc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_MLTRY_STAT_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_mltry_stat_cvg_id
         -- and information4 = emc.business_group_id
           and information2 = emc.effective_start_date
           and information3 = emc.effective_end_date
        );
    l_elig_mltry_stat_cvg_id                 number(15);
    l_out_emc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_MLTRY_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_MRTL_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_ems_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  elig_mrtl_stat_cvg_id
   from BEN_ELIG_MRTL_STAT_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_ems(c_elig_mrtl_stat_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  ems.*
   from BEN_ELIG_MRTL_STAT_CVG_F ems
   where  ems.elig_mrtl_stat_cvg_id = c_elig_mrtl_stat_cvg_id
     -- and ems.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_MRTL_STAT_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_mrtl_stat_cvg_id
         -- and information4 = ems.business_group_id
           and information2 = ems.effective_start_date
           and information3 = ems.effective_end_date
        );
    l_elig_mrtl_stat_cvg_id                 number(15);
    l_out_ems_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_MRTL_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_PSTL_CD_R_RNG_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_epl_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select distinct elig_pstl_cd_r_rng_cvg_id
   from BEN_ELIG_PSTL_CD_R_RNG_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_epl(c_elig_pstl_cd_r_rng_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  epl.*
   from BEN_ELIG_PSTL_CD_R_RNG_CVG_F epl
   where  epl.elig_pstl_cd_r_rng_cvg_id = c_elig_pstl_cd_r_rng_cvg_id
     -- and epl.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_PSTL_CD_R_RNG_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_pstl_cd_r_rng_cvg_id
         -- and information4 = epl.business_group_id
           and information2 = epl.effective_start_date
           and information3 = epl.effective_end_date
        );
    l_elig_pstl_cd_r_rng_cvg_id                 number(15);
    l_out_epl_result_id   number(15);
   --
   cursor c_epl_pstl(c_elig_pstl_cd_r_rng_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select distinct cpe.information245 pstl_zip_rng_id
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and mirror_src_entity_result_id = c_mirror_src_entity_result_id
         -- and trt.where_clause = 'BEN_ELIG_PSTL_CD_R_RNG_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_pstl_cd_r_rng_cvg_id
         -- and information4 = p_business_group_id
        ;
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_PSTL_CD_R_RNG_CVG_F ----------------------
   ---------------------------------------------------------------
   ---------------------------------------------------------------
   -- START OF BEN_ELIG_STDNT_STAT_CVG_F ----------------------
   ---------------------------------------------------------------
   cursor c_esc_from_parent(c_DPNT_CVG_ELIGY_PRFL_ID number) is
   select  elig_stdnt_stat_cvg_id
   from BEN_ELIG_STDNT_STAT_CVG_F
   where  DPNT_CVG_ELIGY_PRFL_ID = c_DPNT_CVG_ELIGY_PRFL_ID ;
   --
   cursor c_esc(c_elig_stdnt_stat_cvg_id number,c_mirror_src_entity_result_id number ,
                c_table_alias varchar2 ) is
   select  esc.*
   from BEN_ELIG_STDNT_STAT_CVG_F esc
   where  esc.elig_stdnt_stat_cvg_id = c_elig_stdnt_stat_cvg_id
     -- and esc.business_group_id = p_business_group_id
     and not exists (
         select /* */ null
         from ben_copy_entity_results cpe
              -- pqh_table_route trt
         where copy_entity_txn_id = p_copy_entity_txn_id
         -- and trt.table_route_id = cpe.table_route_id
         and ( -- c_mirror_src_entity_result_id is null or
               mirror_src_entity_result_id = c_mirror_src_entity_result_id )
         -- and trt.where_clause = 'BEN_ELIG_STDNT_STAT_CVG_F'
         and cpe.table_alias = c_table_alias
         and information1 = c_elig_stdnt_stat_cvg_id
         -- and information4 = esc.business_group_id
           and information2 = esc.effective_start_date
           and information3 = esc.effective_end_date
        );
    l_elig_stdnt_stat_cvg_id                 number(15);
    l_out_esc_result_id   number(15);
   ---------------------------------------------------------------
   -- END OF BEN_ELIG_STDNT_STAT_CVG_F ----------------------
   ---------------------------------------------------------------

     cursor c_object_exists(c_pk_id                number,
                            c_table_alias          varchar2) is
     select null
     from ben_copy_entity_results cpe
         -- pqh_table_route trt
     where copy_entity_txn_id = p_copy_entity_txn_id
     -- and trt.table_route_id = cpe.table_route_id
     and cpe.table_alias = c_table_alias
     and information1 = c_pk_id;

     l_dummy                     varchar2(1);

     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);

  begin

     if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
     end if;

     if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
       open c_object_exists(p_dpnt_cvg_eligy_prfl_id,'DCE');
       fetch c_object_exists into l_dummy;
       if c_object_exists%found then
         close c_object_exists;
         return;
       end if;
       close c_object_exists;
     end if;

     l_number_of_copies := p_number_of_copies ;
     l_mirror_src_entity_result_id := p_mirror_src_entity_result_id;
     l_dpnt_cvg_eligy_prfl_id := p_dpnt_cvg_eligy_prfl_id ;

       ---------------------------------------------------------------
       -- START OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
       ---------------------------------------------------------------
         --
         for l_dce_rec in c_dce(p_dpnt_cvg_eligy_prfl_id,l_mirror_src_entity_result_id,'DCE' ) loop
              --
              l_table_route_id := null ;
              open ben_plan_design_program_module.g_table_route('DCE');
                fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
              close ben_plan_design_program_module.g_table_route ;
              --
              l_information5  := l_dce_rec.name; --'Intersection';
              --
              if p_effective_date between l_dce_rec.effective_start_date
                 and l_dce_rec.effective_end_date then
               --
                 l_result_type_cd := 'DISPLAY';
              else
                 l_result_type_cd := 'NO DISPLAY';
              end if;
                --
              l_copy_entity_result_id := null;
              l_object_version_number := null;
              ben_copy_entity_results_api.create_copy_entity_results(
                p_copy_entity_result_id          => l_copy_entity_result_id,
                p_copy_entity_txn_id             => p_copy_entity_txn_id,
                p_result_type_cd                 => l_result_type_cd,
                p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                p_parent_entity_result_id        => p_parent_entity_result_id, --Result id of Pgm,Ptip,Plip or Oipl
                p_number_of_copies               => l_number_of_copies,
                p_table_route_id                 => l_table_route_id,
		P_TABLE_ALIAS                    => 'DCE',
                p_information1     => l_dce_rec.dpnt_cvg_eligy_prfl_id,
                p_information2     => l_dce_rec.EFFECTIVE_START_DATE,
                p_information3     => l_dce_rec.EFFECTIVE_END_DATE,
                p_information4     => l_dce_rec.business_group_id,
                p_information5     => l_information5 , -- 9999 put name for h-grid
				p_information111     => l_dce_rec.dce_attribute1,
				p_information120     => l_dce_rec.dce_attribute10,
				p_information121     => l_dce_rec.dce_attribute11,
				p_information122     => l_dce_rec.dce_attribute12,
				p_information123     => l_dce_rec.dce_attribute13,
				p_information124     => l_dce_rec.dce_attribute14,
				p_information125     => l_dce_rec.dce_attribute15,
				p_information126     => l_dce_rec.dce_attribute16,
				p_information127     => l_dce_rec.dce_attribute17,
				p_information128     => l_dce_rec.dce_attribute18,
				p_information129     => l_dce_rec.dce_attribute19,
				p_information112     => l_dce_rec.dce_attribute2,
				p_information130     => l_dce_rec.dce_attribute20,
				p_information131     => l_dce_rec.dce_attribute21,
				p_information132     => l_dce_rec.dce_attribute22,
				p_information133     => l_dce_rec.dce_attribute23,
				p_information134     => l_dce_rec.dce_attribute24,
				p_information135     => l_dce_rec.dce_attribute25,
				p_information136     => l_dce_rec.dce_attribute26,
				p_information137     => l_dce_rec.dce_attribute27,
				p_information138     => l_dce_rec.dce_attribute28,
				p_information139     => l_dce_rec.dce_attribute29,
				p_information113     => l_dce_rec.dce_attribute3,
				p_information140     => l_dce_rec.dce_attribute30,
				p_information114     => l_dce_rec.dce_attribute4,
				p_information115     => l_dce_rec.dce_attribute5,
				p_information116     => l_dce_rec.dce_attribute6,
				p_information117     => l_dce_rec.dce_attribute7,
				p_information118     => l_dce_rec.dce_attribute8,
				p_information119     => l_dce_rec.dce_attribute9,
				p_information110     => l_dce_rec.dce_attribute_category,
				p_information185     => l_dce_rec.dce_desc,
				p_information13     => l_dce_rec.dpnt_age_flag,
				p_information257     => l_dce_rec.dpnt_cvg_elig_det_rl,
				p_information11     => l_dce_rec.dpnt_cvg_eligy_prfl_stat_cd,
				p_information19     => l_dce_rec.dpnt_cvrd_in_anthr_pl_flag,
				p_information15     => l_dce_rec.dpnt_dsbld_flag,
				p_information20     => l_dce_rec.dpnt_dsgnt_crntly_enrld_flag,
				p_information17     => l_dce_rec.dpnt_mltry_flag,
				p_information16     => l_dce_rec.dpnt_mrtl_flag,
				p_information18     => l_dce_rec.dpnt_pstl_flag,
				p_information12     => l_dce_rec.dpnt_rlshp_flag,
				p_information14     => l_dce_rec.dpnt_stud_flag,
				p_information170     => l_dce_rec.name,
				p_information231     => l_dce_rec.regn_id,
                                p_information265    => l_dce_rec.object_version_number,
			   --

				-- END REPLACE PARAMETER LINES

				p_object_version_number          => l_object_version_number,
				p_effective_date                 => p_effective_date       );
                --

                if l_out_dce_result_id is null then
                  l_out_dce_result_id := l_copy_entity_result_id;
                end if;

                if l_result_type_cd = 'DISPLAY' then
                   l_out_dce_result_id := l_copy_entity_result_id ;
                end if;
                --
                   --
                     if (l_dce_rec.dpnt_cvg_elig_det_rl is not null) then
		      ben_plan_design_program_module.create_formula_result(
			p_validate                       => p_validate
			,p_copy_entity_result_id  => l_copy_entity_result_id
			,p_copy_entity_txn_id      => p_copy_entity_txn_id
			,p_formula_id                  =>  l_dce_rec.dpnt_cvg_elig_det_rl
			,p_business_group_id        =>  l_dce_rec.business_group_id
			,p_number_of_copies         =>  l_number_of_copies
			,p_object_version_number  => l_object_version_number
			,p_effective_date             => p_effective_date);
		     end if;
		--
             end loop;

            -- Create criteria only if Dependent Eligibility profile row
            -- has been created
            --

            if l_out_dce_result_id is not null then
            ---------------------------------------------------------------
            -- START OF BEN_DPNT_CVG_RQD_RLSHP_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_dcr_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_dpnt_cvg_rqd_rlshp_id := l_parent_rec.dpnt_cvg_rqd_rlshp_id ;
               --
               for l_dcr_rec in c_dcr(l_parent_rec.dpnt_cvg_rqd_rlshp_id,l_mirror_src_entity_result_id,'DCR' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('DCR');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('CONTACT',l_dcr_rec.per_relshp_typ_cd);
                                    --'Intersection';
                 --
                 if p_effective_date between l_dcr_rec.effective_start_date
                    and l_dcr_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'DCR',
                   p_information1     => l_dcr_rec.dpnt_cvg_rqd_rlshp_id,
                   p_information2     => l_dcr_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_dcr_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_dcr_rec.business_group_id,
                   p_information5     => l_information5 ,
					p_information12     => l_dcr_rec.cvg_strt_dt_cd,
					p_information258     => l_dcr_rec.cvg_strt_dt_rl,
					p_information13     => l_dcr_rec.cvg_thru_dt_cd,
					p_information257     => l_dcr_rec.cvg_thru_dt_rl,
					p_information111     => l_dcr_rec.dcr_attribute1,
					p_information120     => l_dcr_rec.dcr_attribute10,
					p_information121     => l_dcr_rec.dcr_attribute11,
					p_information122     => l_dcr_rec.dcr_attribute12,
					p_information123     => l_dcr_rec.dcr_attribute13,
					p_information124     => l_dcr_rec.dcr_attribute14,
					p_information125     => l_dcr_rec.dcr_attribute15,
					p_information126     => l_dcr_rec.dcr_attribute16,
					p_information127     => l_dcr_rec.dcr_attribute17,
					p_information128     => l_dcr_rec.dcr_attribute18,
					p_information129     => l_dcr_rec.dcr_attribute19,
					p_information112     => l_dcr_rec.dcr_attribute2,
					p_information130     => l_dcr_rec.dcr_attribute20,
					p_information131     => l_dcr_rec.dcr_attribute21,
					p_information132     => l_dcr_rec.dcr_attribute22,
					p_information133     => l_dcr_rec.dcr_attribute23,
					p_information134     => l_dcr_rec.dcr_attribute24,
					p_information135     => l_dcr_rec.dcr_attribute25,
					p_information136     => l_dcr_rec.dcr_attribute26,
					p_information137     => l_dcr_rec.dcr_attribute27,
					p_information138     => l_dcr_rec.dcr_attribute28,
					p_information139     => l_dcr_rec.dcr_attribute29,
					p_information113     => l_dcr_rec.dcr_attribute3,
					p_information140     => l_dcr_rec.dcr_attribute30,
					p_information114     => l_dcr_rec.dcr_attribute4,
					p_information115     => l_dcr_rec.dcr_attribute5,
					p_information116     => l_dcr_rec.dcr_attribute6,
					p_information117     => l_dcr_rec.dcr_attribute7,
					p_information118     => l_dcr_rec.dcr_attribute8,
					p_information119     => l_dcr_rec.dcr_attribute9,
					p_information110     => l_dcr_rec.dcr_attribute_category,
					p_information255     => l_dcr_rec.dpnt_cvg_eligy_prfl_id,
					p_information11     => l_dcr_rec.per_relshp_typ_cd,
                                        p_information265    => l_dcr_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_dcr_result_id is null then
                     l_out_dcr_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_dcr_result_id := l_copy_entity_result_id ;
                   end if;
                   --
                    if (l_dcr_rec.cvg_strt_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  =>  l_dcr_rec.cvg_strt_dt_rl
								,p_business_group_id        =>  l_dcr_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

                    if (l_dcr_rec.cvg_thru_dt_rl is not null) then
						   ben_plan_design_program_module.create_formula_result(
								p_validate                       => p_validate
								,p_copy_entity_result_id  => l_copy_entity_result_id
								,p_copy_entity_txn_id      => p_copy_entity_txn_id
								,p_formula_id                  =>  l_dcr_rec.cvg_thru_dt_rl
								,p_business_group_id        =>  l_dcr_rec.business_group_id
								,p_number_of_copies         =>  l_number_of_copies
								,p_object_version_number  => l_object_version_number
								,p_effective_date             => p_effective_date);
						end if;

 					--
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_DPNT_CVG_RQD_RLSHP_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_DPNT_CVRD_ANTHR_PL_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_dpc_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_dpnt_cvrd_anthr_pl_cvg_id := l_parent_rec.dpnt_cvrd_anthr_pl_cvg_id ;
               --
               for l_dpc_rec in c_dpc(l_parent_rec.dpnt_cvrd_anthr_pl_cvg_id,l_mirror_src_entity_result_id,'DPC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('DPC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := ben_plan_design_program_module.get_pl_name(l_dpc_rec.pl_id
                                                                                ,p_effective_date)
                                    || ben_plan_design_program_module.get_exclude_message(l_dpc_rec.excld_flag);
                                    --'Intersection';
                 --
                 if p_effective_date between l_dpc_rec.effective_start_date
                    and l_dpc_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'DPC',
                   p_information1     => l_dpc_rec.dpnt_cvrd_anthr_pl_cvg_id,
                   p_information2     => l_dpc_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_dpc_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_dpc_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information12     => l_dpc_rec.cvg_det_dt_cd,
					p_information111     => l_dpc_rec.dpc_attribute1,
					p_information120     => l_dpc_rec.dpc_attribute10,
					p_information121     => l_dpc_rec.dpc_attribute11,
					p_information122     => l_dpc_rec.dpc_attribute12,
					p_information123     => l_dpc_rec.dpc_attribute13,
					p_information124     => l_dpc_rec.dpc_attribute14,
					p_information125     => l_dpc_rec.dpc_attribute15,
					p_information126     => l_dpc_rec.dpc_attribute16,
					p_information127     => l_dpc_rec.dpc_attribute17,
					p_information128     => l_dpc_rec.dpc_attribute18,
					p_information129     => l_dpc_rec.dpc_attribute19,
					p_information112     => l_dpc_rec.dpc_attribute2,
					p_information130     => l_dpc_rec.dpc_attribute20,
					p_information131     => l_dpc_rec.dpc_attribute21,
					p_information132     => l_dpc_rec.dpc_attribute22,
					p_information133     => l_dpc_rec.dpc_attribute23,
					p_information134     => l_dpc_rec.dpc_attribute24,
					p_information135     => l_dpc_rec.dpc_attribute25,
					p_information136     => l_dpc_rec.dpc_attribute26,
					p_information137     => l_dpc_rec.dpc_attribute27,
					p_information138     => l_dpc_rec.dpc_attribute28,
					p_information139     => l_dpc_rec.dpc_attribute29,
					p_information113     => l_dpc_rec.dpc_attribute3,
					p_information140     => l_dpc_rec.dpc_attribute30,
					p_information114     => l_dpc_rec.dpc_attribute4,
					p_information115     => l_dpc_rec.dpc_attribute5,
					p_information116     => l_dpc_rec.dpc_attribute6,
					p_information117     => l_dpc_rec.dpc_attribute7,
					p_information118     => l_dpc_rec.dpc_attribute8,
					p_information119     => l_dpc_rec.dpc_attribute9,
					p_information110     => l_dpc_rec.dpc_attribute_category,
					p_information255     => l_dpc_rec.dpnt_cvg_eligy_prfl_id,
					p_information11     => l_dpc_rec.excld_flag,
					p_information260     => l_dpc_rec.ordr_num,
					p_information261     => l_dpc_rec.pl_id,
                                        p_information265    => l_dpc_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_dpc_result_id is null then
                     l_out_dpc_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_dpc_result_id := l_copy_entity_result_id ;
                   end if;
                   --
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_DPNT_CVRD_ANTHR_PL_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_DSGNTR_ENRLD_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_dec_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_dsgntr_enrld_cvg_id := l_parent_rec.dsgntr_enrld_cvg_id ;
               --
               for l_dec_rec in c_dec(l_parent_rec.dsgntr_enrld_cvg_id,l_mirror_src_entity_result_id,'DEC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('DEC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('YES_NO',l_dec_rec.dsgntr_crntly_enrld_flag);
                                 --'Intersection';
                 --
                 if p_effective_date between l_dec_rec.effective_start_date
                    and l_dec_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'DEC',
                   p_information1     => l_dec_rec.dsgntr_enrld_cvg_id,
                   p_information2     => l_dec_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_dec_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_dec_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information111     => l_dec_rec.dec_attribute1,
					p_information120     => l_dec_rec.dec_attribute10,
					p_information121     => l_dec_rec.dec_attribute11,
					p_information122     => l_dec_rec.dec_attribute12,
					p_information123     => l_dec_rec.dec_attribute13,
					p_information124     => l_dec_rec.dec_attribute14,
					p_information125     => l_dec_rec.dec_attribute15,
					p_information126     => l_dec_rec.dec_attribute16,
					p_information127     => l_dec_rec.dec_attribute17,
					p_information128     => l_dec_rec.dec_attribute18,
					p_information129     => l_dec_rec.dec_attribute19,
					p_information112     => l_dec_rec.dec_attribute2,
					p_information130     => l_dec_rec.dec_attribute20,
					p_information131     => l_dec_rec.dec_attribute21,
					p_information132     => l_dec_rec.dec_attribute22,
					p_information133     => l_dec_rec.dec_attribute23,
					p_information134     => l_dec_rec.dec_attribute24,
					p_information135     => l_dec_rec.dec_attribute25,
					p_information136     => l_dec_rec.dec_attribute26,
					p_information137     => l_dec_rec.dec_attribute27,
					p_information138     => l_dec_rec.dec_attribute28,
					p_information139     => l_dec_rec.dec_attribute29,
					p_information113     => l_dec_rec.dec_attribute3,
					p_information140     => l_dec_rec.dec_attribute30,
					p_information114     => l_dec_rec.dec_attribute4,
					p_information115     => l_dec_rec.dec_attribute5,
					p_information116     => l_dec_rec.dec_attribute6,
					p_information117     => l_dec_rec.dec_attribute7,
					p_information118     => l_dec_rec.dec_attribute8,
					p_information119     => l_dec_rec.dec_attribute9,
					p_information110     => l_dec_rec.dec_attribute_category,
					p_information255     => l_dec_rec.dpnt_cvg_eligy_prfl_id,
					p_information11     => l_dec_rec.dsgntr_crntly_enrld_flag,
                                        p_information265    => l_dec_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_dec_result_id is null then
                     l_out_dec_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_dec_result_id := l_copy_entity_result_id ;
                   end if;
                   --
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_DSGNTR_ENRLD_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_AGE_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_eac_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_age_cvg_id := l_parent_rec.elig_age_cvg_id ;
               --
               for l_eac_rec in c_eac(l_parent_rec.elig_age_cvg_id,l_mirror_src_entity_result_id,'EAC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EAC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := ben_plan_design_program_module.get_age_fctr_name(l_eac_rec.age_fctr_id)
                                    || ben_plan_design_program_module.get_exclude_message(l_eac_rec.excld_flag);
                                    --'Intersection';
                 --
                 if p_effective_date between l_eac_rec.effective_start_date
                    and l_eac_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EAC',
                   p_information1     => l_eac_rec.elig_age_cvg_id,
                   p_information2     => l_eac_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_eac_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_eac_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information246     => l_eac_rec.age_fctr_id,
					p_information12     => l_eac_rec.cvg_strt_cd,
					p_information257     => l_eac_rec.cvg_strt_rl,
					p_information13     => l_eac_rec.cvg_thru_cd,
					p_information258     => l_eac_rec.cvg_thru_rl,
					p_information255     => l_eac_rec.dpnt_cvg_eligy_prfl_id,
					p_information111     => l_eac_rec.eac_attribute1,
					p_information120     => l_eac_rec.eac_attribute10,
					p_information121     => l_eac_rec.eac_attribute11,
					p_information122     => l_eac_rec.eac_attribute12,
					p_information123     => l_eac_rec.eac_attribute13,
					p_information124     => l_eac_rec.eac_attribute14,
					p_information125     => l_eac_rec.eac_attribute15,
					p_information126     => l_eac_rec.eac_attribute16,
					p_information127     => l_eac_rec.eac_attribute17,
					p_information128     => l_eac_rec.eac_attribute18,
					p_information129     => l_eac_rec.eac_attribute19,
					p_information112     => l_eac_rec.eac_attribute2,
					p_information130     => l_eac_rec.eac_attribute20,
					p_information131     => l_eac_rec.eac_attribute21,
					p_information132     => l_eac_rec.eac_attribute22,
					p_information133     => l_eac_rec.eac_attribute23,
					p_information134     => l_eac_rec.eac_attribute24,
					p_information135     => l_eac_rec.eac_attribute25,
					p_information136     => l_eac_rec.eac_attribute26,
					p_information137     => l_eac_rec.eac_attribute27,
					p_information138     => l_eac_rec.eac_attribute28,
					p_information139     => l_eac_rec.eac_attribute29,
					p_information113     => l_eac_rec.eac_attribute3,
					p_information140     => l_eac_rec.eac_attribute30,
					p_information114     => l_eac_rec.eac_attribute4,
					p_information115     => l_eac_rec.eac_attribute5,
					p_information116     => l_eac_rec.eac_attribute6,
					p_information117     => l_eac_rec.eac_attribute7,
					p_information118     => l_eac_rec.eac_attribute8,
					p_information119     => l_eac_rec.eac_attribute9,
					p_information110     => l_eac_rec.eac_attribute_category,
					p_information11     => l_eac_rec.excld_flag,
                                        p_information265    => l_eac_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_eac_result_id is null then
                     l_out_eac_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_eac_result_id := l_copy_entity_result_id ;
                   end if;
                   --
                   if (l_eac_rec.cvg_strt_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_eac_rec.cvg_strt_rl
							,p_business_group_id        =>  l_eac_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

                    if (l_eac_rec.cvg_thru_rl is not null) then
					   ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  =>  l_eac_rec.cvg_thru_rl
							,p_business_group_id        =>  l_eac_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;
                   --
               end loop;
                --
               for l_eac_rec in c_eac_drp(l_parent_rec.elig_age_cvg_id,l_mirror_src_entity_result_id,'EAC' ) loop
                    ben_pd_rate_and_cvg_module.create_drpar_results
                      (
                        p_validate                      => p_validate
                       ,p_copy_entity_result_id         => l_out_eac_result_id
                       ,p_copy_entity_txn_id            => p_copy_entity_txn_id
                       ,p_comp_lvl_fctr_id              => null
                       ,p_hrs_wkd_in_perd_fctr_id       => null
                       ,p_los_fctr_id                   => null
                       ,p_pct_fl_tm_fctr_id             => null
                       ,p_age_fctr_id                   => l_eac_rec.age_fctr_id
                       ,p_cmbn_age_los_fctr_id          => null
                       ,p_business_group_id             => p_business_group_id
                       ,p_number_of_copies              => p_number_of_copies
                       ,p_object_version_number         => l_object_version_number
                       ,p_effective_date                => p_effective_date
                      );
                end loop;
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_AGE_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_DSBLD_STAT_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_edc_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_dsbld_stat_cvg_id := l_parent_rec.elig_dsbld_stat_cvg_id ;
               --
               for l_edc_rec in c_edc(l_parent_rec.elig_dsbld_stat_cvg_id,l_mirror_src_entity_result_id,'EDC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EDC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('REGISTERED_DISABLED',l_edc_rec.dsbld_cd);
                                 --'Intersection';
                 --
                 if p_effective_date between l_edc_rec.effective_start_date
                    and l_edc_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EDC',
                   p_information1     => l_edc_rec.elig_dsbld_stat_cvg_id,
                   p_information2     => l_edc_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_edc_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_edc_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_edc_rec.cvg_strt_cd,
					p_information260     => l_edc_rec.cvg_strt_rl,
					p_information12     => l_edc_rec.cvg_thru_cd,
					p_information261     => l_edc_rec.cvg_thru_rl,
					p_information255     => l_edc_rec.dpnt_cvg_eligy_prfl_id,
					p_information13     => l_edc_rec.dsbld_cd,
					p_information111     => l_edc_rec.edc_attribute1,
					p_information120     => l_edc_rec.edc_attribute10,
					p_information121     => l_edc_rec.edc_attribute11,
					p_information122     => l_edc_rec.edc_attribute12,
					p_information123     => l_edc_rec.edc_attribute13,
					p_information124     => l_edc_rec.edc_attribute14,
					p_information125     => l_edc_rec.edc_attribute15,
					p_information126     => l_edc_rec.edc_attribute16,
					p_information127     => l_edc_rec.edc_attribute17,
					p_information128     => l_edc_rec.edc_attribute18,
					p_information129     => l_edc_rec.edc_attribute19,
					p_information112     => l_edc_rec.edc_attribute2,
					p_information130     => l_edc_rec.edc_attribute20,
					p_information131     => l_edc_rec.edc_attribute21,
					p_information132     => l_edc_rec.edc_attribute22,
					p_information133     => l_edc_rec.edc_attribute23,
					p_information134     => l_edc_rec.edc_attribute24,
					p_information135     => l_edc_rec.edc_attribute25,
					p_information136     => l_edc_rec.edc_attribute26,
					p_information137     => l_edc_rec.edc_attribute27,
					p_information138     => l_edc_rec.edc_attribute28,
					p_information139     => l_edc_rec.edc_attribute29,
					p_information113     => l_edc_rec.edc_attribute3,
					p_information140     => l_edc_rec.edc_attribute30,
					p_information114     => l_edc_rec.edc_attribute4,
					p_information115     => l_edc_rec.edc_attribute5,
					p_information116     => l_edc_rec.edc_attribute6,
					p_information117     => l_edc_rec.edc_attribute7,
					p_information118     => l_edc_rec.edc_attribute8,
					p_information119     => l_edc_rec.edc_attribute9,
					p_information110     => l_edc_rec.edc_attribute_category,
                                        p_information265     => l_edc_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_edc_result_id is null then
                     l_out_edc_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_edc_result_id := l_copy_entity_result_id ;
                   end if;
                   --
					if (l_edc_rec.cvg_strt_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_edc_rec.cvg_strt_rl
							,p_business_group_id        =>  l_edc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;
                   		--
					if (l_edc_rec.cvg_thru_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_edc_rec.cvg_thru_rl
							,p_business_group_id        =>  l_edc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;
                   		--
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_DSBLD_STAT_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_MLTRY_STAT_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_emc_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_mltry_stat_cvg_id := l_parent_rec.elig_mltry_stat_cvg_id ;
               --
               for l_emc_rec in c_emc(l_parent_rec.elig_mltry_stat_cvg_id,l_mirror_src_entity_result_id,'EMC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EMC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('YES_NO',l_emc_rec.mltry_stat_cd);
                                 --'Intersection';
                 --
                 if p_effective_date between l_emc_rec.effective_start_date
                    and l_emc_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EMC',
                   p_information1     => l_emc_rec.elig_mltry_stat_cvg_id,
                   p_information2     => l_emc_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_emc_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_emc_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information12     => l_emc_rec.cvg_strt_cd,
					p_information257     => l_emc_rec.cvg_strt_rl,
					p_information13     => l_emc_rec.cvg_thru_cd,
					p_information258     => l_emc_rec.cvg_thru_rl,
					p_information255     => l_emc_rec.dpnt_cvg_eligy_prfl_id,
					p_information111     => l_emc_rec.emc_attribute1,
					p_information120     => l_emc_rec.emc_attribute10,
					p_information121     => l_emc_rec.emc_attribute11,
					p_information122     => l_emc_rec.emc_attribute12,
					p_information123     => l_emc_rec.emc_attribute13,
					p_information124     => l_emc_rec.emc_attribute14,
					p_information125     => l_emc_rec.emc_attribute15,
					p_information126     => l_emc_rec.emc_attribute16,
					p_information127     => l_emc_rec.emc_attribute17,
					p_information128     => l_emc_rec.emc_attribute18,
					p_information129     => l_emc_rec.emc_attribute19,
					p_information112     => l_emc_rec.emc_attribute2,
					p_information130     => l_emc_rec.emc_attribute20,
					p_information131     => l_emc_rec.emc_attribute21,
					p_information132     => l_emc_rec.emc_attribute22,
					p_information133     => l_emc_rec.emc_attribute23,
					p_information134     => l_emc_rec.emc_attribute24,
					p_information135     => l_emc_rec.emc_attribute25,
					p_information136     => l_emc_rec.emc_attribute26,
					p_information137     => l_emc_rec.emc_attribute27,
					p_information138     => l_emc_rec.emc_attribute28,
					p_information139     => l_emc_rec.emc_attribute29,
					p_information113     => l_emc_rec.emc_attribute3,
					p_information140     => l_emc_rec.emc_attribute30,
					p_information114     => l_emc_rec.emc_attribute4,
					p_information115     => l_emc_rec.emc_attribute5,
					p_information116     => l_emc_rec.emc_attribute6,
					p_information117     => l_emc_rec.emc_attribute7,
					p_information118     => l_emc_rec.emc_attribute8,
					p_information119     => l_emc_rec.emc_attribute9,
					p_information110     => l_emc_rec.emc_attribute_category,
					p_information11     => l_emc_rec.mltry_stat_cd,
                                        p_information265    => l_emc_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_emc_result_id is null then
                     l_out_emc_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_emc_result_id := l_copy_entity_result_id ;
                   end if;
                   --
					if (l_emc_rec.cvg_strt_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_emc_rec.cvg_strt_rl
							,p_business_group_id        => l_emc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

					if (l_emc_rec.cvg_thru_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_emc_rec.cvg_thru_rl
							,p_business_group_id        => l_emc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;


					 --
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_MLTRY_STAT_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_MRTL_STAT_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_ems_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_mrtl_stat_cvg_id := l_parent_rec.elig_mrtl_stat_cvg_id ;
               --
               for l_ems_rec in c_ems(l_parent_rec.elig_mrtl_stat_cvg_id,l_mirror_src_entity_result_id,'EMS' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EMS');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('MAR_STATUS',l_ems_rec.mrtl_stat_cd);
                                 --'Intersection';
                 --
                 if p_effective_date between l_ems_rec.effective_start_date
                    and l_ems_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EMS',
                   p_information1     => l_ems_rec.elig_mrtl_stat_cvg_id,
                   p_information2     => l_ems_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_ems_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_ems_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information12     => l_ems_rec.cvg_strt_cd,
					p_information258     => l_ems_rec.cvg_strt_rl,
					p_information13     => l_ems_rec.cvg_thru_cd,
					p_information259     => l_ems_rec.cvg_thru_rl,
					p_information255     => l_ems_rec.dpnt_cvg_eligy_prfl_id,
					p_information111     => l_ems_rec.ems_attribute1,
					p_information120     => l_ems_rec.ems_attribute10,
					p_information121     => l_ems_rec.ems_attribute11,
					p_information122     => l_ems_rec.ems_attribute12,
					p_information123     => l_ems_rec.ems_attribute13,
					p_information124     => l_ems_rec.ems_attribute14,
					p_information125     => l_ems_rec.ems_attribute15,
					p_information126     => l_ems_rec.ems_attribute16,
					p_information127     => l_ems_rec.ems_attribute17,
					p_information128     => l_ems_rec.ems_attribute18,
					p_information129     => l_ems_rec.ems_attribute19,
					p_information112     => l_ems_rec.ems_attribute2,
					p_information130     => l_ems_rec.ems_attribute20,
					p_information131     => l_ems_rec.ems_attribute21,
					p_information132     => l_ems_rec.ems_attribute22,
					p_information133     => l_ems_rec.ems_attribute23,
					p_information134     => l_ems_rec.ems_attribute24,
					p_information135     => l_ems_rec.ems_attribute25,
					p_information136     => l_ems_rec.ems_attribute26,
					p_information137     => l_ems_rec.ems_attribute27,
					p_information138     => l_ems_rec.ems_attribute28,
					p_information139     => l_ems_rec.ems_attribute29,
					p_information113     => l_ems_rec.ems_attribute3,
					p_information140     => l_ems_rec.ems_attribute30,
					p_information114     => l_ems_rec.ems_attribute4,
					p_information115     => l_ems_rec.ems_attribute5,
					p_information116     => l_ems_rec.ems_attribute6,
					p_information117     => l_ems_rec.ems_attribute7,
					p_information118     => l_ems_rec.ems_attribute8,
					p_information119     => l_ems_rec.ems_attribute9,
					p_information110     => l_ems_rec.ems_attribute_category,
					p_information11     => l_ems_rec.mrtl_stat_cd,
                                        p_information265    => l_ems_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_ems_result_id is null then
                     l_out_ems_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_ems_result_id := l_copy_entity_result_id ;
                   end if;
                   --
					if (l_ems_rec.cvg_strt_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_ems_rec.cvg_strt_rl
							,p_business_group_id        => l_ems_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

					if (l_ems_rec.cvg_thru_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_ems_rec.cvg_thru_rl
							,p_business_group_id        => l_ems_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

                   --
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_MRTL_STAT_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_PSTL_CD_R_RNG_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_epl_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_pstl_cd_r_rng_cvg_id := l_parent_rec.elig_pstl_cd_r_rng_cvg_id ;
               --
               for l_epl_rec in c_epl(l_parent_rec.elig_pstl_cd_r_rng_cvg_id,l_mirror_src_entity_result_id,'EPL' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('EPL');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := ben_plan_design_program_module.get_pstl_zip_rng_name(l_epl_rec.pstl_zip_rng_id
                                                                                      ,p_effective_date)
                                    || ben_plan_design_program_module.get_exclude_message(l_epl_rec.excld_flag);
                                    --'Intersection';
                 --
                 if p_effective_date between l_epl_rec.effective_start_date
                    and l_epl_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'EPL',
                   p_information1     => l_epl_rec.elig_pstl_cd_r_rng_cvg_id,
                   p_information2     => l_epl_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_epl_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_epl_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information255     => l_epl_rec.dpnt_cvg_eligy_prfl_id,
					p_information111     => l_epl_rec.epl_attribute1,
					p_information120     => l_epl_rec.epl_attribute10,
					p_information121     => l_epl_rec.epl_attribute11,
					p_information122     => l_epl_rec.epl_attribute12,
					p_information123     => l_epl_rec.epl_attribute13,
					p_information124     => l_epl_rec.epl_attribute14,
					p_information125     => l_epl_rec.epl_attribute15,
					p_information126     => l_epl_rec.epl_attribute16,
					p_information127     => l_epl_rec.epl_attribute17,
					p_information128     => l_epl_rec.epl_attribute18,
					p_information129     => l_epl_rec.epl_attribute19,
					p_information112     => l_epl_rec.epl_attribute2,
					p_information130     => l_epl_rec.epl_attribute20,
					p_information131     => l_epl_rec.epl_attribute21,
					p_information132     => l_epl_rec.epl_attribute22,
					p_information133     => l_epl_rec.epl_attribute23,
					p_information134     => l_epl_rec.epl_attribute24,
					p_information135     => l_epl_rec.epl_attribute25,
					p_information136     => l_epl_rec.epl_attribute26,
					p_information137     => l_epl_rec.epl_attribute27,
					p_information138     => l_epl_rec.epl_attribute28,
					p_information139     => l_epl_rec.epl_attribute29,
					p_information113     => l_epl_rec.epl_attribute3,
					p_information140     => l_epl_rec.epl_attribute30,
					p_information114     => l_epl_rec.epl_attribute4,
					p_information115     => l_epl_rec.epl_attribute5,
					p_information116     => l_epl_rec.epl_attribute6,
					p_information117     => l_epl_rec.epl_attribute7,
					p_information118     => l_epl_rec.epl_attribute8,
					p_information119     => l_epl_rec.epl_attribute9,
					p_information110     => l_epl_rec.epl_attribute_category,
					p_information11     => l_epl_rec.excld_flag,
					p_information260     => l_epl_rec.ordr_num,
					p_information245     => l_epl_rec.pstl_zip_rng_id,
                                        p_information265    => l_epl_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_epl_result_id is null then
                     l_out_epl_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_epl_result_id := l_copy_entity_result_id ;
                   end if;
                   --
                end loop;
                --
                for l_epl_rec in c_epl_pstl(l_parent_rec.elig_pstl_cd_r_rng_cvg_id,l_mirror_src_entity_result_id,'EPL' ) loop
                     ben_pd_rate_and_cvg_module.create_postal_results
                         (
                            p_validate                    => p_validate
                           ,p_copy_entity_result_id       => l_out_epl_result_id
                           ,p_copy_entity_txn_id          => p_copy_entity_txn_id
                           ,p_pstl_zip_rng_id             => l_epl_rec.pstl_zip_rng_id
                           ,p_business_group_id           => p_business_group_id
                           ,p_number_of_copies            => p_number_of_copies
                           ,p_object_version_number       => l_object_version_number
                           ,p_effective_date              => p_effective_date
                           ) ;
                end loop;
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_PSTL_CD_R_RNG_CVG_F ----------------------
           ---------------------------------------------------------------
            ---------------------------------------------------------------
            -- START OF BEN_ELIG_STDNT_STAT_CVG_F ----------------------
            ---------------------------------------------------------------
            --
            for l_parent_rec  in c_esc_from_parent(l_DPNT_CVG_ELIGY_PRFL_ID) loop
               --
               l_mirror_src_entity_result_id := l_out_dce_result_id ;
               --
               l_elig_stdnt_stat_cvg_id := l_parent_rec.elig_stdnt_stat_cvg_id ;
               --
               for l_esc_rec in c_esc(l_parent_rec.elig_stdnt_stat_cvg_id,l_mirror_src_entity_result_id,'ESC' ) loop
                 --
                 l_table_route_id := null ;
                 open ben_plan_design_program_module.g_table_route('ESC');
                 fetch ben_plan_design_program_module.g_table_route into l_table_route_id ;
                 close ben_plan_design_program_module.g_table_route ;
                 --
                 l_information5  := hr_general.decode_lookup('STUDENT_STATUS',l_esc_rec.stdnt_stat_cd);
                                    --'Intersection';
                 --
                 if p_effective_date between l_esc_rec.effective_start_date
                    and l_esc_rec.effective_end_date then
                  --
                    l_result_type_cd := 'DISPLAY';
                 else
                    l_result_type_cd := 'NO DISPLAY';
                 end if;
                   --
                 l_copy_entity_result_id := null;
                 l_object_version_number := null;
                 ben_copy_entity_results_api.create_copy_entity_results(
                   p_copy_entity_result_id          => l_copy_entity_result_id,
                   p_copy_entity_txn_id             => p_copy_entity_txn_id,
                   p_result_type_cd                 => l_result_type_cd,
                   p_mirror_src_entity_result_id    => l_mirror_src_entity_result_id,
                   p_parent_entity_result_id        => l_mirror_src_entity_result_id,
                   p_number_of_copies               => l_number_of_copies,
                   p_table_route_id                 => l_table_route_id,
		   P_TABLE_ALIAS                    => 'ESC',
                   p_information1     => l_esc_rec.elig_stdnt_stat_cvg_id,
                   p_information2     => l_esc_rec.EFFECTIVE_START_DATE,
                   p_information3     => l_esc_rec.EFFECTIVE_END_DATE,
                   p_information4     => l_esc_rec.business_group_id,
                   p_information5     => l_information5 , -- 9999 put name for h-grid
					p_information11     => l_esc_rec.cvg_strt_cd,
					p_information260     => l_esc_rec.cvg_strt_rl,
					p_information12     => l_esc_rec.cvg_thru_cd,
					p_information261     => l_esc_rec.cvg_thru_rl,
					p_information255     => l_esc_rec.dpnt_cvg_eligy_prfl_id,
					p_information111     => l_esc_rec.esc_attribute1,
					p_information120     => l_esc_rec.esc_attribute10,
					p_information121     => l_esc_rec.esc_attribute11,
					p_information122     => l_esc_rec.esc_attribute12,
					p_information123     => l_esc_rec.esc_attribute13,
					p_information124     => l_esc_rec.esc_attribute14,
					p_information125     => l_esc_rec.esc_attribute15,
					p_information126     => l_esc_rec.esc_attribute16,
					p_information127     => l_esc_rec.esc_attribute17,
					p_information128     => l_esc_rec.esc_attribute18,
					p_information129     => l_esc_rec.esc_attribute19,
					p_information112     => l_esc_rec.esc_attribute2,
					p_information130     => l_esc_rec.esc_attribute20,
					p_information131     => l_esc_rec.esc_attribute21,
					p_information132     => l_esc_rec.esc_attribute22,
					p_information133     => l_esc_rec.esc_attribute23,
					p_information134     => l_esc_rec.esc_attribute24,
					p_information135     => l_esc_rec.esc_attribute25,
					p_information136     => l_esc_rec.esc_attribute26,
					p_information137     => l_esc_rec.esc_attribute27,
					p_information138     => l_esc_rec.esc_attribute28,
					p_information139     => l_esc_rec.esc_attribute29,
					p_information113     => l_esc_rec.esc_attribute3,
					p_information140     => l_esc_rec.esc_attribute30,
					p_information114     => l_esc_rec.esc_attribute4,
					p_information115     => l_esc_rec.esc_attribute5,
					p_information116     => l_esc_rec.esc_attribute6,
					p_information117     => l_esc_rec.esc_attribute7,
					p_information118     => l_esc_rec.esc_attribute8,
					p_information119     => l_esc_rec.esc_attribute9,
					p_information110     => l_esc_rec.esc_attribute_category,
					p_information13     => l_esc_rec.stdnt_stat_cd,
                                        p_information265    => l_esc_rec.object_version_number,
				   --

					-- END REPLACE PARAMETER LINES

					p_object_version_number          => l_object_version_number,
					p_effective_date                 => p_effective_date       );
                   --

                   if l_out_esc_result_id is null then
                     l_out_esc_result_id := l_copy_entity_result_id;
                   end if;

                   if l_result_type_cd = 'DISPLAY' then
                      l_out_esc_result_id := l_copy_entity_result_id ;
                   end if;
                   --
					if (l_esc_rec.cvg_strt_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_esc_rec.cvg_strt_rl
							,p_business_group_id        => l_esc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

					if (l_esc_rec.cvg_thru_rl is not null) then
						ben_plan_design_program_module.create_formula_result(
							p_validate                       => p_validate
							,p_copy_entity_result_id  => l_copy_entity_result_id
							,p_copy_entity_txn_id      => p_copy_entity_txn_id
							,p_formula_id                  => l_esc_rec.cvg_thru_rl
							,p_business_group_id        => l_esc_rec.business_group_id
							,p_number_of_copies         =>  l_number_of_copies
							,p_object_version_number  => l_object_version_number
							,p_effective_date             => p_effective_date);
					end if;

                   --
                end loop;
                --
              end loop;
           ---------------------------------------------------------------
           -- END OF BEN_ELIG_STDNT_STAT_CVG_F ----------------------
           ---------------------------------------------------------------
             --
           end if;
        ---------------------------------------------------------------
        -- END OF BEN_DPNT_CVG_ELIGY_PRFL_F ----------------------
        ---------------------------------------------------------------
        --
  end create_dep_elig_prfl_results;

-- 4347039: Added the following procedure
procedure create_eligy_criteria_result
  (
   p_validate                       in  number     default 0 -- false
  ,p_copy_entity_result_id          in  number
  ,p_copy_entity_txn_id             in  number
  ,p_eligy_criteria_id              in  number
  ,p_business_group_id              in  number    default null
  ,p_number_of_copies               in  number    default 0
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_parent_entity_result_id        in  number
  ,p_no_dup_rslt                    in varchar2   default null
  ) is

    l_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
    l_proc varchar2(72) := g_package||'.create_eligy_criteria_result';
    l_object_version_number ben_copy_entity_results.object_version_number%TYPE;
    l_result_type_cd   varchar2(30) :=  'DISPLAY' ;

/*    cursor c_parent_result(c_parent_pk_id number,
                         c_parent_table_alias varchar2,
                         c_copy_entity_txn_id number) is
    select copy_entity_result_id mirror_src_entity_result_id
    from ben_copy_entity_results cpe
    where cpe.information1 = c_parent_pk_id
    and   cpe.result_type_cd = l_cv_result_type_cd
    and   cpe.copy_entity_txn_id = c_copy_entity_txn_id
    and   cpe.table_alias = c_parent_table_alias;
    */

   CURSOR c_egl (
      cv_eligy_criteria_id             NUMBER,
      cv_mirror_src_entity_result_id   NUMBER,
      cv_table_alias                   VARCHAR2
   )
   IS
      SELECT egl.*
        FROM ben_eligy_criteria egl
       WHERE egl.eligy_criteria_id = cv_eligy_criteria_id
         AND NOT EXISTS (
                SELECT NULL
                  FROM ben_copy_entity_results cpe
                 WHERE copy_entity_txn_id = p_copy_entity_txn_id
                   AND mirror_src_entity_result_id =
                                                cv_mirror_src_entity_result_id
                   AND cpe.table_alias = cv_table_alias
                   AND information1 = cv_eligy_criteria_id);

   --
   CURSOR c_value_set_name (cv_flex_value_set_id NUMBER)
   IS
      SELECT flex_value_set_name
        FROM fnd_flex_value_sets
       WHERE flex_value_set_id = cv_flex_value_set_id;
   --
   l_out_egl_result_id         NUMBER (15);
   l_egl_table_route_id        NUMBER (15);
   l_egl_result_type_cd        VARCHAR2 (30);
   l_eligy_criteria_id         NUMBER (15);
   l_egl_copy_entity_result_id ben_copy_entity_results.copy_entity_result_id%TYPE;
   l_egl_object_version_number ben_copy_entity_results.object_version_number%TYPE;
   l_flex_value_set_name       fnd_flex_value_sets.flex_value_set_name%TYPE;
   --
     cursor c_object_exists(c_pk_id                number,
                            c_table_alias          varchar2) is
     select null
     from ben_copy_entity_results cpe
     where copy_entity_txn_id = p_copy_entity_txn_id
     and cpe.table_alias = c_table_alias
     and information1 = c_pk_id;

     l_dummy                        varchar2(1);
     l_mirror_src_entity_result_id    number(15);
     l_table_route_id               number(15);
     l_result_type_cd               varchar2(30);
     l_information5                 ben_copy_entity_results.information5%type;
     l_number_of_copies             number(15);
     --
begin
    --
    if p_no_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
        ben_plan_design_program_module.g_pdw_allow_dup_rslt := ben_plan_design_program_module.g_pdw_no_dup_rslt;
    end if;
    --
    if ben_plan_design_program_module.g_pdw_allow_dup_rslt = ben_plan_design_program_module.g_pdw_no_dup_rslt then
        open c_object_exists(p_eligy_criteria_id,'EGL');
        fetch c_object_exists into l_dummy;
        if c_object_exists%found then
            close c_object_exists;
            return;
        end if;
        close c_object_exists;
    end if;
    --
    l_number_of_copies := p_number_of_copies ;
    --
    --
    ---------------------------------------------------------------
    ----------------- START OF BEN_ELIGY_CRITERIA -----------------
    ---------------------------------------------------------------
   --
   l_mirror_src_entity_result_id := p_copy_entity_result_id ;
   l_eligy_criteria_id := p_eligy_criteria_id;
   --
   --
   for l_egl_rec in c_egl(cv_eligy_criteria_id           => l_eligy_criteria_id,
                          cv_mirror_src_entity_result_id => l_mirror_src_entity_result_id,
                          cv_table_alias                 => 'EGL' )
   loop
     --
     l_egl_table_route_id := null ;
     --
    open ben_plan_design_program_module.g_table_route('EGL');
    fetch ben_plan_design_program_module.g_table_route into l_egl_table_route_id ;
    close ben_plan_design_program_module.g_table_route ;
     --
     l_egl_result_type_cd := 'NO DISPLAY';
     --
     l_egl_copy_entity_result_id := null;
     l_egl_object_version_number := null;
     --
     -- If criteria basis contains Value Set id then populate Value Set Name
     -- in INFORMATION185 to use it again while auto-mapping in the target
     -- business group in bepdccp1.pkb (stage -> ben)
     --
     l_flex_value_set_name := null;
     --
     if l_egl_rec.col1_value_set_id is not null then
        --
        open c_value_set_name ( l_egl_rec.col1_value_set_id );
        fetch c_value_set_name into l_flex_value_set_name;
        close c_value_set_name;
        --
     end if;
     --
     ben_copy_entity_results_api.create_copy_entity_results
            (
             p_copy_entity_result_id            => l_egl_copy_entity_result_id,
             p_copy_entity_txn_id               => p_copy_entity_txn_id,
             p_result_type_cd                   => l_egl_result_type_cd,
             p_mirror_src_entity_result_id      => l_mirror_src_entity_result_id,
             p_parent_entity_result_id          => l_mirror_src_entity_result_id,
             p_number_of_copies                 => l_number_of_copies,
             p_table_route_id                   => l_egl_table_route_id,
             p_table_alias                      => 'EGL',
             p_information1                     => l_egl_rec.eligy_Criteria_id,
             p_information4                     => l_egl_rec.business_group_id,
             p_information5                     => l_egl_rec.name,
             p_information11                    => l_egl_rec.short_code,
             p_information12                    => l_egl_rec.criteria_type,
             p_information13                    => l_egl_rec.crit_col1_val_type_cd,
             p_information14                    => l_egl_rec.crit_col1_datatype,
             p_information15                    => l_egl_rec.col1_lookup_type,
             p_information16                    => l_egl_rec.access_table_name1,
             p_information17                    => l_egl_rec.access_column_name1,
             p_information18                    => l_egl_rec.time_entry_access_table_name1,
             p_information19                    => l_egl_rec.time_entry_access_col_name1,
             p_information20                    => l_egl_rec.crit_col2_val_type_cd,
             p_information21                    => l_egl_rec.crit_col2_datatype,
             p_information22                    => l_egl_rec.col2_lookup_type,
             p_information23                    => l_egl_rec.access_table_name2,
             p_information24                    => l_egl_rec.access_column_name2,
             p_information25                    => l_egl_rec.time_entry_access_table_name2,
             p_information26                    => l_egl_rec.time_entry_access_col_name2,
             p_information27                    => l_egl_rec.allow_range_validation_flag,
             p_information28                    => l_egl_rec.user_defined_flag,
             p_information29                    => l_egl_rec.legislation_code,
            --Bug 4592554
	     p_information30                    => l_egl_rec.allow_range_validation_flag2,
	    --End Bug 4592554
             p_information110                   => l_egl_rec.egl_attribute_category,
             p_information111                   => l_egl_rec.egl_attribute1,
             p_information112                   => l_egl_rec.egl_attribute2,
             p_information113                   => l_egl_rec.egl_attribute3,
             p_information114                   => l_egl_rec.egl_attribute4,
             p_information115                   => l_egl_rec.egl_attribute5,
             p_information116                   => l_egl_rec.egl_attribute6,
             p_information117                   => l_egl_rec.egl_attribute7,
             p_information118                   => l_egl_rec.egl_attribute8,
             p_information119                   => l_egl_rec.egl_attribute9,
             p_information120                   => l_egl_rec.egl_attribute10,
             p_information121                   => l_egl_rec.egl_attribute11,
             p_information122                   => l_egl_rec.egl_attribute12,
             p_information123                   => l_egl_rec.egl_attribute13,
             p_information124                   => l_egl_rec.egl_attribute14,
             p_information125                   => l_egl_rec.egl_attribute15,
             p_information126                   => l_egl_rec.egl_attribute16,
             p_information127                   => l_egl_rec.egl_attribute17,
             p_information128                   => l_egl_rec.egl_attribute18,
             p_information129                   => l_egl_rec.egl_attribute19,
             p_information130                   => l_egl_rec.egl_attribute20,
             p_information131                   => l_egl_rec.egl_attribute21,
             p_information132                   => l_egl_rec.egl_attribute22,
             p_information133                   => l_egl_rec.egl_attribute23,
             p_information134                   => l_egl_rec.egl_attribute24,
             p_information135                   => l_egl_rec.egl_attribute25,
             p_information136                   => l_egl_rec.egl_attribute26,
             p_information137                   => l_egl_rec.egl_attribute27,
             p_information138                   => l_egl_rec.egl_attribute28,
             p_information139                   => l_egl_rec.egl_attribute29,
             p_information140                   => l_egl_rec.egl_attribute30,
             p_information170                   => l_egl_rec.name,
             p_information185                   => l_flex_value_set_name,
             p_information219                   => l_egl_rec.description,
             p_information265                   => l_egl_rec.object_version_number,
             p_information266                   => l_egl_rec.col1_value_set_id,
             p_information267                   => l_egl_rec.col2_value_set_id,
             p_information268                   => l_egl_rec.access_calc_rule,
            --Bug 4592554
	     p_information269                   => l_egl_rec.access_calc_rule2,
	     p_information270                   => l_egl_rec.time_access_calc_rule1,
	     p_information271                   => l_egl_rec.time_access_calc_rule2,
	    --End Bug 4592554
             p_object_version_number            => l_egl_object_version_number,
             p_effective_date                   => p_effective_date
            );
     --
     if l_egl_rec.access_calc_rule is not null
     then
       --
       ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0,
             p_copy_entity_result_id          =>  l_egl_copy_entity_result_id,
             p_copy_entity_txn_id             =>  p_copy_entity_txn_id,
             p_formula_id                     =>  l_egl_rec.access_calc_rule,
             p_business_group_id              =>  l_egl_rec.business_group_id,
             p_number_of_copies               =>  l_number_of_copies,
             p_object_version_number          =>  l_object_version_number,
             p_effective_date                 =>  p_effective_date
            );
       --
     end if;

--Bug 4592554

      if l_egl_rec.access_calc_rule2 is not null
     then
       --
       ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0,
             p_copy_entity_result_id          =>  l_egl_copy_entity_result_id,
             p_copy_entity_txn_id             =>  p_copy_entity_txn_id,
             p_formula_id                     =>  l_egl_rec.access_calc_rule2,
             p_business_group_id              =>  l_egl_rec.business_group_id,
             p_number_of_copies               =>  l_number_of_copies,
             p_object_version_number          =>  l_object_version_number,
             p_effective_date                 =>  p_effective_date
            );
       --
     end if;



      if l_egl_rec.time_access_calc_rule1 is not null
     then
       --
       ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0,
             p_copy_entity_result_id          =>  l_egl_copy_entity_result_id,
             p_copy_entity_txn_id             =>  p_copy_entity_txn_id,
             p_formula_id                     =>  l_egl_rec.time_access_calc_rule1,
             p_business_group_id              =>  l_egl_rec.business_group_id,
             p_number_of_copies               =>  l_number_of_copies,
             p_object_version_number          =>  l_object_version_number,
             p_effective_date                 =>  p_effective_date
            );
       --
     end if;




      if l_egl_rec.time_access_calc_rule2 is not null
     then
       --
       ben_plan_design_program_module.create_formula_result
            (
             p_validate                       =>  0,
             p_copy_entity_result_id          =>  l_egl_copy_entity_result_id,
             p_copy_entity_txn_id             =>  p_copy_entity_txn_id,
             p_formula_id                     =>  l_egl_rec.time_access_calc_rule2,
             p_business_group_id              =>  l_egl_rec.business_group_id,
             p_number_of_copies               =>  l_number_of_copies,
             p_object_version_number          =>  l_object_version_number,
             p_effective_date                 =>  p_effective_date
            );
       --
     end if;
     --
--End Bug 4592554

   end loop;
   --
   --
   ---------------------------------------------------------------
   ------------------ END OF BEN_ELIGY_CRITERIA ------------------
   ---------------------------------------------------------------
   --
end create_eligy_criteria_result;

end ben_plan_design_elpro_module;


/
