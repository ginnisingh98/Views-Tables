--------------------------------------------------------
--  DDL for Package Body GHR_FEHB_PLAN_DESIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_FEHB_PLAN_DESIGN" AS
/* $Header: ghfehbpd.pkb 120.2 2005/06/28 14:07:36 bgarg noship $ */

--
-- Package Variables
--
   g_package varchar2(100) := 'ghr_fehb_plan_design.';

procedure create_sub_life_events(p_target_business_group_id in number)
is
   l_ler_id                   ben_ler_f.ler_id%type;
   l_effective_start_date     ben_ler_f.effective_start_date%type;
   l_effective_end_date       ben_ler_f.effective_end_date%type;
   l_object_version_number    ben_ler_f.object_version_number%type;
   l_ler_name                 ben_ler_f.name%type;
   l_ler_short_code           ben_ler_f.short_code%type;
   l_target_business_group_id number := 1503;
   l_exists                   Varchar2(1);

   Cursor check_if_ler_exists is
      select 'Y'
      from   ben_ler_f
      where  name = l_ler_name
      and    business_group_id = p_target_business_group_id;
Begin
  for i in 1..3 Loop
      if i = 1 then
         l_ler_name := 'Change in Dependents';
      Elsif i = 2 then
         l_ler_name := 'Change in Marital Status';
      Elsif i = 3 then
         l_ler_name := 'Change in Dependents - End Date';
      End If;

      l_exists := 'N';
      for i in check_if_ler_exists Loop
         l_exists := 'Y';
      End Loop;
      If l_exists = 'N' Then
         ben_life_event_reason_api.create_life_event_reason(
                  p_ler_id                   => l_ler_id
                 ,p_effective_start_date     => l_effective_start_date
                 ,p_effective_end_date       => l_effective_end_date
                 ,p_name                     => l_ler_name
                 ,p_business_group_id        => p_target_business_group_id
                 ,p_object_version_number    => l_object_version_number
                 ,p_ovridg_le_flag           => 'N'
                 ,p_qualg_evt_flag           => 'N'
                 ,p_ck_rltd_per_elig_flag    => 'N'
                 ,p_cm_aply_flag             => 'N'
                 ,p_typ_cd                   => 'PRSNL'
                 --,p_short_code               => l_ler_short_code
                 ,p_effective_date           => to_date('1951/01/01','yyyy/mm/dd')
                 );
      End If;
    End Loop;
 End Create_sub_life_events;

Procedure create_person_type_usages (p_target_business_group_id in Number) is

       l_ff_id ff_formulas_f.formula_id%type;
       l_formula_name ff_formulas_f.formula_name%type;
       l_pt_name BEN_PER_INFO_CHG_CS_LER_F.name%type;
       l_source_table BEN_PER_INFO_CHG_CS_LER_F.source_table%type;
       l_source_column BEN_PER_INFO_CHG_CS_LER_F.source_column%type;
       l_le_name BEN_LER_F.name%type;


    cursor c_get_ler_id is
       select ler_id,effective_start_date from ben_ler_f
       where  name = l_le_name
       and    business_group_id = p_target_business_group_id;

           l_proc            varchar2(100) := 'create_person_type_usages';
           l_chg_cs_ler_id   number;
           l_per_info_cs_id  number;
           l_clpse_lf_evt_id ben_clpse_lf_evt_f.clpse_lf_evt_id%type;
           l_esd             date := to_date('1951/01/01','yyyy/mm/dd');
           l_eed             date := to_date('4712/12/31','yyyy/mm/dd');
           l_ovn             number;
           l_ler_id         ben_ler_f.ler_id%type;
           l_ler_id1         ben_ler_f.ler_id%type;
           l_ler_id2         ben_ler_f.ler_id%type;
           l_ler_id3         ben_ler_f.ler_id%type;
           l_effective_date  date;


    cursor c_get_ff_id is
      select formula_id
      from ff_formulas_f
      where formula_name = l_formula_name
      and l_effective_date between
      effective_start_date and effective_end_date;

    cursor c_chk_per_info_chg is
      select name,per_info_chg_cs_ler_id from BEN_PER_INFO_CHG_CS_LER_F
      where source_table      = l_source_table
      and source_column     = l_source_column
      and business_group_id = p_target_business_group_id;

    cursor c_chk_lpl(p_per_info_chg_cs_ler_id in number,
                     p_ler_id in number
                     ) is
    SELECT  'X'
    FROM    ben_ler_per_info_cs_ler_f
    WHERE   per_info_chg_cs_ler_id    = p_per_info_chg_cs_ler_id
    AND     ler_id                    = p_ler_id
    AND     business_group_id         = p_target_business_group_id;



    l_exists boolean default FALSE;
  Begin

-- Change in Marital Status
     l_exists        := FALSE;
     l_le_name       := 'Change in Marital Status';
     l_pt_name       := 'Change in Marital Status';
     l_source_table  := 'PER_ALL_PEOPLE_F';
     l_source_column := 'MARITAL_STATUS';
     For i in c_get_ler_id loop
       l_ler_id1 := i.ler_id;
       l_effective_date := i.effective_start_date;
     End Loop;
     For chk_per_info_chg in c_chk_per_info_chg
     loop
       l_chg_cs_ler_id := chk_per_info_chg.per_info_chg_cs_ler_id;
       l_exists := TRUE;
       exit;
     end loop;

     IF l_ler_id1 is NOT NULL THEN
     IF NOT l_exists THEN
       l_formula_name := 'GHR_MARI_STATUS_LER_TRIGGER';

       FOR ff_rec IN c_get_ff_id
       LOOP
         l_ff_id := ff_rec.formula_id;
         exit;
       END LOOP;

     -- To create the Person Type Change
       ben_Person_Change_Cs_Ler_api.create_person_change_cs_ler
         (p_per_info_chg_cs_ler_id    =>  l_chg_cs_ler_id
         ,p_effective_start_date      =>  l_esd
         ,p_effective_end_date        =>  l_eed
         ,p_name                      =>  l_le_name
        , p_old_val                   =>  'OABANY'
         ,p_new_val                   =>  'OABANY'
         ,p_source_column             =>  l_source_column
         ,p_source_table              =>  l_source_table
         ,p_per_info_chg_cs_ler_rl    =>  l_ff_id
         ,p_business_group_id         =>  p_target_business_group_id
         ,p_object_version_number     =>  l_ovn
         ,p_effective_date            =>  l_effective_date
          );
      END IF;
     l_exists := FALSE;
     For chk_lpl in c_chk_lpl(l_chg_cs_ler_id,l_ler_id1)
     loop
       l_exists := TRUE;
       exit;
     end loop;
     IF NOT l_exists THEN
     hr_utility.set_location('Calling create_ler_per_info_cs:'|| l_proc, 10);

     -- To associate the Person Type Change with the LER
       ben_Ler_Per_Info_Cs_Ler_api.create_Ler_Per_Info_Cs_Ler
         (p_ler_per_info_cs_ler_id  => l_per_info_cs_id
         ,p_effective_start_date    => l_esd
         ,p_effective_End_date      => l_eed
         ,p_per_info_chg_cs_ler_id  => l_chg_cs_ler_id
         ,p_ler_id                  => l_ler_id1
         ,p_business_Group_id       => p_target_business_group_id
         ,p_object_version_number   => l_ovn
         ,p_effective_date          => l_effective_date
         );
    END IF;
    END IF;

-- Change in Dependents
     l_exists           := FALSE;
     l_le_name          := 'Change in Dependents';
     l_pt_name          := 'Change in Dependents';
     l_source_column    := 'CONTACT_TYPE';
     l_source_table     := 'PER_CONTACT_RELATIONSHIPS';
     For i in c_get_ler_id loop
        l_ler_id2 := i.ler_id;
        l_effective_date := i.effective_start_date;
     End Loop;
     For chk_per_info_chg in c_chk_per_info_chg
     loop
       l_chg_cs_ler_id := chk_per_info_chg.per_info_chg_cs_ler_id;
       l_exists := TRUE;
       exit;
     end loop;

     IF l_ler_id2 is not null THEN
       IF NOT l_exists THEN
     -- To create the Person Type Change
       l_formula_name := 'GHR_CONT_LER_TRIGGER';

       FOR ff_rec IN c_get_ff_id
       LOOP
         l_ff_id := ff_rec.formula_id;
         exit;
       END LOOP;

       ben_Person_Change_Cs_Ler_api.create_person_change_cs_ler
         (p_per_info_chg_cs_ler_id    =>  l_chg_cs_ler_id
         ,p_effective_start_date      =>  l_esd
         ,p_effective_end_date        =>  l_eed
         ,p_name                      =>  l_le_name
        , p_old_val                   =>  'OABANY'
         ,p_new_val                   =>  'OABANY'
         ,p_source_column             =>  l_source_column
         ,p_source_table              =>  l_source_table
         ,p_per_info_chg_cs_ler_rl    => l_ff_id
         ,p_business_group_id         =>  p_target_business_group_id
         ,p_object_version_number     =>  l_ovn
         ,p_effective_date            =>  l_effective_date
          );
     END IF;
     l_exists := FALSE;
     For chk_lpl in c_chk_lpl(l_chg_cs_ler_id,l_ler_id2)
     loop
       l_exists := TRUE;
       exit;
     end loop;
     IF NOT l_exists THEN

     hr_utility.set_location('Calling create_ler_per_info_cs:'|| l_proc, 10);

     -- To associate the Person Type Change with the LER
       ben_Ler_Per_Info_Cs_Ler_api.create_Ler_Per_Info_Cs_Ler
         (p_ler_per_info_cs_ler_id  => l_per_info_cs_id
         ,p_effective_start_date    => l_esd
         ,p_effective_End_date      => l_eed
         ,p_per_info_chg_cs_ler_id  => l_chg_cs_ler_id
         ,p_ler_id                  => l_ler_id2
         ,p_business_Group_id       => p_target_business_group_id
         ,p_object_version_number   => l_ovn
         ,p_effective_date          => l_effective_date
         );
    END IF;
    END IF;
-- Change in Dependents -- End Date
     l_exists           := FALSE;
     l_le_name          := 'Change in Dependents - End Date';
     l_pt_name          := 'Change in Dependents - End Date';
     l_source_column    := 'DATE_END';
     l_source_table     := 'PER_CONTACT_RELATIONSHIPS';
     For i in c_get_ler_id loop
        l_ler_id2 := i.ler_id;
        l_effective_date := i.effective_start_date;
     End Loop;
     For chk_per_info_chg in c_chk_per_info_chg
     loop
       l_chg_cs_ler_id := chk_per_info_chg.per_info_chg_cs_ler_id;
       l_exists := TRUE;
       exit;
     end loop;

     IF l_ler_id2 is not null THEN
       IF NOT l_exists THEN
     -- To create the Person Type Change
       l_formula_name := 'GHR_CONT_LER_TRIGGER';

       FOR ff_rec IN c_get_ff_id
       LOOP
         l_ff_id := ff_rec.formula_id;
         exit;
       END LOOP;

       ben_Person_Change_Cs_Ler_api.create_person_change_cs_ler
         (p_per_info_chg_cs_ler_id    =>  l_chg_cs_ler_id
         ,p_effective_start_date      =>  l_esd
         ,p_effective_end_date        =>  l_eed
         ,p_name                      =>  l_le_name
        , p_old_val                   =>  'OABANY'
         ,p_new_val                   =>  'OABANY'
         ,p_source_column             =>  l_source_column
         ,p_source_table              =>  l_source_table
         ,p_per_info_chg_cs_ler_rl    => l_ff_id
         ,p_business_group_id         =>  p_target_business_group_id
         ,p_object_version_number     =>  l_ovn
         ,p_effective_date            =>  l_effective_date
          );
     END IF;
     l_exists := FALSE;
     For chk_lpl in c_chk_lpl(l_chg_cs_ler_id,l_ler_id2)
     loop
       l_exists := TRUE;
       exit;
     end loop;
     IF NOT l_exists THEN

     hr_utility.set_location('Calling create_ler_per_info_cs:'|| l_proc, 10);

     -- To associate the Person Type Change with the LER
       ben_Ler_Per_Info_Cs_Ler_api.create_Ler_Per_Info_Cs_Ler
         (p_ler_per_info_cs_ler_id  => l_per_info_cs_id
         ,p_effective_start_date    => l_esd
         ,p_effective_End_date      => l_eed
         ,p_per_info_chg_cs_ler_id  => l_chg_cs_ler_id
         ,p_ler_id                  => l_ler_id2
         ,p_business_Group_id       => p_target_business_group_id
         ,p_object_version_number   => l_ovn
         ,p_effective_date          => l_effective_date
         );
    END IF;
    END IF;

   -- Modified the processing to attach New life event with the address chnage.
-- Change in Primary Address
     l_exists         := FALSE;
     l_le_name        := 'Employee/Family member loses coverage under FEHB or another group plan';
     l_pt_name        := 'Employee/Family member loses coverage under FEHB or another group plan';
     l_source_table   := 'PER_ADDRESSES';
     l_source_column  := 'REGION_2';
     For i in c_get_ler_id loop
        l_ler_id3 := i.ler_id;
        l_effective_date := i.effective_start_date;
     End Loop;
     For chk_per_info_chg in c_chk_per_info_chg
     loop
       l_chg_cs_ler_id := chk_per_info_chg.per_info_chg_cs_ler_id;
       l_exists := TRUE;
       exit;
     end loop;
     IF l_ler_id3 is not null THEN
       IF NOT l_exists THEN
     -- Create the Person Type Change
       l_formula_name := 'GHR_ADDRESS_LER_TRIGGER';

       FOR ff_rec IN c_get_ff_id
       LOOP
         l_ff_id := ff_rec.formula_id;
         exit;
       END LOOP;

       ben_Person_Change_Cs_Ler_api.create_person_change_cs_ler
         (p_per_info_chg_cs_ler_id    =>  l_chg_cs_ler_id
         ,p_effective_start_date      =>  l_esd
         ,p_effective_end_date        =>  l_eed
         ,p_name                      =>  l_le_name
         ,p_old_val                   =>  'OABANY'
         ,p_new_val                   =>  'OABANY'
         ,p_source_column             =>  l_source_column
         ,p_source_table              =>  l_source_table
         ,p_per_info_chg_cs_ler_rl    => l_ff_id
         ,p_business_group_id         =>  p_target_business_group_id
         ,p_object_version_number     =>  l_ovn
         ,p_effective_date            =>  l_effective_date
          );
     END IF;
     l_exists := FALSE;
     For chk_lpl in c_chk_lpl(l_chg_cs_ler_id,l_ler_id3)
     loop
       l_exists := TRUE;
       exit;
     end loop;
     IF NOT l_exists THEN

     hr_utility.set_location('Calling create_ler_per_info_cs:'|| l_proc, 10);

     -- To associate the Person Type Change with the LER
       ben_Ler_Per_Info_Cs_Ler_api.create_Ler_Per_Info_Cs_Ler
         (p_ler_per_info_cs_ler_id  => l_per_info_cs_id
         ,p_effective_start_date    => l_esd
         ,p_effective_End_date      => l_eed
         ,p_per_info_chg_cs_ler_id  => l_chg_cs_ler_id
         ,p_ler_id                  => l_ler_id3
         ,p_business_Group_id       => p_target_business_group_id
         ,p_object_version_number   => l_ovn
         ,p_effective_date          => l_effective_date
         );
      END IF;
    END IF;

     hr_utility.set_location('Leaving:   '|| g_package||l_proc, 50);
  End create_person_type_usages;

Procedure create_collapse_rule (p_target_business_group_id in Number) is
           l_clpse_lf_evt_id ben_clpse_lf_evt_f.clpse_lf_evt_id%type;
           l_esd             date := to_date('1951/01/01','yyyy/mm/dd');
           l_eed             date := to_date('4712/12/31','yyyy/mm/dd');
           l_ovn             number;
           l_ler_id         ben_ler_f.ler_id%type;
           l_ler_id1         ben_ler_f.ler_id%type;
           l_ler_id2         ben_ler_f.ler_id%type;
           l_ler_id3         ben_ler_f.ler_id%type;
           l_effective_date  date;
           l_le_name BEN_LER_F.name%type;
           l_ctr number;
           l_proc            varchar2(100) := 'create_collapse_rule';
           l_seq             ben_clpse_lf_evt_f.seq%type;
    -- Check whether an existing Collapsing rule is there between
    -- the main life event and sub life events
    cursor c_chk_clp is
      select clpse_lf_evt_id
      from   ben_clpse_lf_evt_f clp
      where  clp.business_group_id = p_target_business_group_id
      and    eval_ler_id = l_ler_id
      and    ler1_id     = l_ler_id1
      and    ler2_id     = l_ler_id2
      and    ler3_id     = l_ler_id3;
    -- Get the maximum sequence number for the given business group id
    cursor c_get_clp_max_seq is
      select nvl(max(seq),0) seqnum
      from   ben_clpse_lf_evt_f clp
      where  clp.business_group_id = p_target_business_group_id;

    cursor c_chk_ler is
      select ler_id,effective_start_date from ben_ler_f
      where  name = l_le_name
      and    business_group_id = p_target_business_group_id;
begin
  hr_utility.set_location('Entering:   '|| g_package||l_proc, 5);
  -- Create the Sub Life Events
  create_sub_life_events(p_target_business_group_id);
  -- Create person type changes and Attach person type changes
  create_person_type_usages(p_target_business_group_id);
  -- Create Collpasing Rule
  -- Linking three sub life events to main life event 'Change in Family Status'
  l_clpse_lf_evt_id := NULL;
  for i in 1..4 Loop
    l_ctr := i;
    if i = 1 then
      l_le_name := 'Change in Family Status';
    elsif i = 2 then
      l_le_name := 'Change in Dependents';
    elsif i = 3 then
      l_le_name := 'Change in Marital Status';
    elsif i = 4 then
      l_le_name := 'Change in Dependents - End Date';
    end If;

    for chk_ler in c_chk_ler loop
      IF l_ctr = 1 then
        l_ler_id := chk_ler.ler_id;
        l_effective_date := chk_ler.effective_start_date;
      ELSIF l_ctr = 2 then
        l_ler_id1 := chk_ler.ler_id;
      ELSIF l_ctr = 3 then
        l_ler_id2 := chk_ler.ler_id;
      ELSIF l_ctr = 4 then
        l_ler_id3 := chk_ler.ler_id;
      END IF;
    End Loop;
  End Loop;
  For chk_clp in c_chk_clp loop
    l_clpse_lf_evt_id := chk_clp.clpse_lf_evt_id;
    exit;
  End Loop;
  IF l_clpse_lf_evt_id is NULL then
    IF l_ler_id is not null and
      l_ler_id1 is not null and
      l_ler_id2 is not null and
      l_ler_id3 is not null THEN
      For max_seq in c_get_clp_max_seq loop
        l_seq := max_seq.seqnum + 1;
        exit;
      End Loop;

      ben_clpse_lf_evt_api.create_clpse_lf_evt
         (p_validate               => FALSE
         ,p_clpse_lf_evt_id        => l_clpse_lf_evt_id
         ,p_effective_start_date   => l_esd
         ,p_effective_end_date     => l_eed
         ,p_business_group_id      => p_target_business_group_id
         ,p_eval_ler_id            => l_ler_id
         ,p_seq                    => l_seq
         ,p_ler1_id                => l_ler_id1
         ,p_bool1_cd               => 'OR'
         ,p_ler2_id                => l_ler_id2
         ,p_bool2_cd               => 'OR'
         ,p_ler3_id                => l_ler_id3
         ,p_eval_cd                => 'V'
         ,p_eval_ler_det_cd        => 'ELED'
         ,p_object_version_number  => l_ovn
         ,p_effective_date         => l_effective_date
       );
    END IF;
  END IF;
end create_collapse_rule;


  Procedure create_program_and_plans (p_target_business_group_id in Number) is
--
      l_proc                        Varchar2(100):= g_package||'create_program_and_plans';
      p_validate                    Number := 0;
      p_copy_entity_txn_id          Number;
      p_effective_date              Date;
      p_prefix_suffix_cd            Varchar2(2);
      p_prefix_suffix_text          Varchar2(2);
      p_reuse_object_flag           Varchar2(1);
      p_transaction_category_id     Number(15);
      l_effective_start_date        Date;
      l_effective_end_date          Date;
      Nothing_To_Do                 Exception;

--
      Cursor get_txn_category_id is
                   select transaction_category_id
                   from   pqh_transaction_categories
                   where  short_name = 'BEN_PDCPWZ';
      Cursor get_copy_txn_id is
                   select copy_entity_txn_id
                   from   pqh_copy_entity_txns
                   where  transaction_category_id = p_transaction_category_id
                   and    context_business_group_id = 0
                   and    display_name = 'GHR_FEHB_SEED_PROGRAM_DESIGN';
     Cursor update_program_status is
         select * from ben_pgm_f
         where  name = 'Federal Employees Health Benefits'
         and    business_group_id = p_target_business_group_id;
--
 Begin

   hr_utility.set_location('Entering:'|| g_package||l_proc, 5);

   Open get_txn_category_id;
   Fetch get_txn_category_id into p_transaction_category_id;
   hr_utility.trace('Transaction Category Id  :'|| p_transaction_category_id);
   hr_utility.set_location('Opening cursor get_copy_txn_id      '||l_proc, 10);
   --dbms_output.put_line('txn category id   '||p_transaction_category_id);

   Open get_copy_txn_id;
   fetch get_copy_txn_id into p_copy_entity_txn_id;
   If get_copy_txn_id%notfound  then
      Raise Nothing_to_do;
   End If;
   hr_utility.trace('Copy entity Txn. Id  :'|| p_copy_entity_txn_id);
   --dbms_output.put_line('copy_entity_txn_id  :'||p_copy_entity_txn_id );

  ----------------------------
  /* This update is introduced to open the lookup type delivererd by Benefits team */
  /* which is being used only by GHr customers for now. It would be open for all   */
  /* customers at a later date, at which point this update can be removed form here */

  update FND_LOOKUP_VALUES
  set    end_date_active = null,
         description = null,
         last_updated_by = 1
  where  lookup_code = 'FDPPELD'
  and    lookup_type = 'BEN_ENRT_CVG_STRT'
  and    language    = 'US' ;

  -----------------------
   --   Set the variables
   p_effective_date            := to_date('12/31/2020','MM/DD//YYYY');
   p_prefix_suffix_cd          := null;
   p_prefix_suffix_text        := null;
   p_reuse_object_flag         := 'Y';

   BEN_PD_COPY_TO_BEN_five.g_ghr_mode := 'TRUE';

   --dbms_output.put_line('now callinmg..........');
   BEN_PD_COPY_TO_BEN_TWO.create_stg_to_ben_rows(p_validate,
                                                 p_copy_entity_txn_id,
                                                 p_effective_date,
                                                 p_prefix_suffix_text,
                                                 p_reuse_object_flag,
                                                 p_target_business_group_id,
                                                 p_prefix_suffix_cd);
   --dbms_output.put_line('BACK');
   For i in update_program_status Loop
       ben_Program_api.update_program(
                p_pgm_id                   => i.pgm_id
                ,p_effective_start_date    => l_effective_start_date
                ,p_effective_end_date      => l_effective_end_date
                ,p_pgm_stat_cd             => 'A'
                ,p_object_version_number   => i.object_version_number
                ,p_effective_date          => i.effective_start_date
                ,p_datetrack_mode          => 'CORRECTION'
       );
   End Loop;

  If get_txn_category_id%ISOPEN then
     CLOSE get_txn_category_id;
  End If;
  If get_copy_txn_id%ISOPEN then
     CLOSE get_copy_txn_id;
  End If;
  hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);

  Exception
     When Nothing_to_do Then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       null;
     When others then
       If get_txn_category_id%ISOPEN then
           CLOSE get_txn_category_id;
       End If;
       If get_copy_txn_id%ISOPEN then
           CLOSE get_copy_txn_id;
       End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 70);
       Raise;
  End create_program_and_plans;



  Procedure populate_fehb_plan_design (p_errbuf     OUT NOCOPY VARCHAR2,
                                       p_retcode    OUT NOCOPY NUMBER,
                                       p_target_business_group_id in Number) is

      Cursor check_pgm_exists is
             select 'Y' from ben_pgm_f
             where  name = 'Federal Employees Health Benefits'
             and    business_group_id = p_target_business_group_id;

      l_proc           varchar2(100):= 'Populate_fehb_plan_design.';
      p_exists         Varchar2(1):= 'N';
      l_err_msg        Varchar2(2000);
      Nothing_To_Do    Exception;


  Begin
      hr_utility.set_location('entering  :'|| g_package||l_proc, 10);
      hr_utility.trace('Business Group Id   ' ||p_target_business_group_id);
      Open check_pgm_exists;
      Fetch check_pgm_exists into p_exists;
      If check_pgm_exists%NOTFOUND Then
         p_exists := 'N';
      End If;
      If p_exists = 'Y' then
         Raise nothing_to_do;
      End If;

      Savepoint  create_plan_design;
      --dbms_output.put_line('now starting plan design  ' ||p_target_business_group_id);
      create_program_and_plans(p_target_business_group_id);
      hr_utility.trace('After create_program_and_plans....');
      create_collapse_rule(p_target_business_group_id);
      --commit;
      If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
      End If;
      hr_utility.set_location('Leaving  :'|| g_package||l_proc, 50);
  Exception
     When Nothing_to_do Then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
        null;
     When others then
        If check_pgm_exists%ISOPEN then
           CLOSE check_pgm_exists;
        End If;
       hr_utility.set_location('Leaving  :'|| g_package||l_proc, 60);
       hr_utility.trace('Error  ' ||sqlerrm(sqlcode));
       l_err_msg := substr(p_target_business_group_id||':'||nvl(fnd_message.get,sqlerrm),1,1999) ;
       rollback to create_plan_design;
       ghr_wgi_pkg.create_ghr_errorlog
          (p_program_name            =>  l_proc,
           p_log_text                =>  l_err_msg,
           p_message_name            =>  null,
           p_log_date                =>  sysdate
           );
       commit;
  End populate_fehb_plan_design;

 /*

  Procedure populate_fehb_pd_all_bgs is

     Cursor c_get_business_group_id is
       select business_group_id from per_business_groups;
       --where business_group_id = 2670;

       l_proc      varchar2(100):= 'Populate_fehb_pd_all_bgs.';
       p_errbuf    varchar(2000);
       p_retcode   number;

  Begin
      hr_utility.set_location('entering  :'|| g_package||l_proc, 10);
      For i in c_get_business_group_id Loop
        Begin
           hr_utility.trace('Business Group Id   ' ||i.business_group_id);
           ghr_fehb_plan_design.populate_fehb_plan_design(
                      p_errbuf     , p_retcode  ,
                      i.business_group_id);
        End;
      End Loop;
      hr_utility.set_location('Leaving  :'|| l_proc, 50);
  End populate_fehb_pd_all_bgs;
  */


     Procedure get_recs_for_fehb_migration(p_errbuf     OUT NOCOPY Varchar2
                                          ,p_retcode    OUT NOCOPY Number
                                          ,p_business_group_id in Number) is


       l_option_code    ben_opt_f.short_code%type;
       l_pt_flag        Varchar2(1);

     Cursor c_fehb_migration is
     SELECT eef.effective_start_date start_date,
            eef.assignment_id,
            elt.element_name,
            eef.element_entry_id,
            eef.object_version_number,
        ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                        'Enrollment',
                                                        eef.effective_start_date) enrollment,
        ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                       'Health Plan',
                                                       eef.effective_start_date) health_plan,
        ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                       'Pre tax Waiver',
                                                        eef.effective_start_date) pt_flag,
        ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                       'Temps Total Cost',
                                                        eef.effective_start_date) Temps_cost,
            asg.person_id


      FROM   pay_element_entries_f eef,
             pay_element_types_f elt,
             per_all_assignments_f asg
      WHERE  eef.assignment_id = asg.assignment_id
      and    elt.element_type_id = eef.element_type_id
      AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND elt.effective_end_date
      AND    eef.effective_start_date BETWEEN asg.effective_start_date  AND asg.effective_end_date
      and    eef.effective_end_date = hr_api.g_eot
      and    asg.business_group_id  = p_business_group_id
      AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                                     p_business_group_id,
                                                                     eef.effective_start_date))
                          IN  ('HEALTH BENEFITS'
--                          ,'HEALTH BENEFITS PRE TAX'
                          )
       order by eef.assignment_id,element_name;
     begin
       -- set program name
          ghr_mto_int.set_log_program_name('GHR_FEHB_MIGRATION');
       for fehb_migration in c_fehb_migration loop
           l_option_code := null;
           l_pt_flag   := nvl(fehb_migration.pt_flag,'N');
           If fehb_migration.enrollment = 'Y' Then
              l_option_code :=  null;
           ElsIf l_pt_flag = 'Y' and fehb_migration.enrollment in ('1','2','4','5') then
              l_option_code := fehb_migration.enrollment||'A';
           Elsif l_pt_flag = 'N' and fehb_migration.enrollment in ('1','2','4','5') then
              l_option_code := fehb_migration.enrollment||'P';
           Else
              l_option_code := fehb_migration.enrollment;
           ENd If;
           --dbms_output.put_line('2.Option   ' ||l_option_code);
           --dbms_output.put_line('person_id  ' ||fehb_migration.person_id);
           --dbms_output.put_line('temps_total_cost  ' ||fehb_migration.temps_cost);
           ghr_general.ghr_fehb_migrate(fehb_migration.assignment_id,
                                        p_business_group_id,
                                        fehb_migration.person_id,
                                        fehb_migration.start_date,
                                        fehb_migration.health_plan,
                                        l_option_code,
                                        fehb_migration.element_entry_id,
                                        fehb_migration.object_version_number,
                                        fehb_migration.temps_cost);
           commit;
       End Loop;
     end get_recs_for_fehb_migration;

end ghr_fehb_plan_design;

/
