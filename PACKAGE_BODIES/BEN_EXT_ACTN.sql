--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ACTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ACTN" as
/* $Header: benxactn.pkb 115.10 2003/02/08 06:58:37 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_actn.';  -- Global package name
--
-- procedure to initialize the globals - May, 99
-- ----------------------------------------------------------------------------
-- |---------------------< initialize_globals >-------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE initialize_globals IS
   --
   l_proc             varchar2(72) := g_package||'initialize_globals';
   --
BEGIN
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
    ben_ext_person.g_actn_prtt_enrt_actn_id       := null;
    ben_ext_person.g_actn_type_id       := null;
    ben_ext_person.g_actn_name          := null;
    ben_ext_person.g_actn_description   := null;
    ben_ext_person.g_actn_type          := null;
    ben_ext_person.g_actn_due_date      := null;
    ben_ext_person.g_actn_required_flag := null;
    ben_ext_person.g_actn_cmpltd_date   := null;
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End initialize_globals;
--
-- ----------------------------------------------------------------------------
-- |---------------------< main >---------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_person_id          in number,
                             p_prtt_enrt_rslt_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
  cursor c_actn (l_prtt_enrt_rslt_id number) is
    select
	     type.actn_typ_id     	action_id
	    ,type.name			action_name
	    ,type.description		action_desc
	    ,type.type_cd		action_type
          ,actn.due_dt		action_due_dt
	    ,actn.rqd_flag		action_rqd_flag
          ,actn.cmpltd_dt             action_cmpltd_dt
          ,actn.prtt_enrt_actn_id
	from ben_actn_typ    		type,
             ben_prtt_enrt_actn_f 	actn,
	     ben_prtt_enrt_rslt_f	rslt
       where
            actn.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
        and p_effective_date between actn.effective_start_date
                                 and actn.effective_end_date
        and actn.actn_typ_id = type.actn_typ_id
        and actn.prtt_enrt_rslt_id = rslt.prtt_enrt_rslt_id
        and rslt.person_id = p_person_id
      ;
 l_include varchar2(1) := 'Y';
 --
 BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   FOR actn IN c_actn(p_prtt_enrt_rslt_id) LOOP
        --
        initialize_globals;
        --
        l_include := 'Y';
        --
        ben_ext_evaluate_inclusion.Evaluate_action_item_Incl
                     (p_actn_typ_id       => actn.action_id,
                      p_prtt_enrt_actn_id => actn.prtt_enrt_actn_id,
                      p_include           => l_include);

        if l_include = 'Y' then

          -- fetch actions information into globals
          --
          ben_ext_person.g_actn_type_id       := actn.action_id;
          ben_ext_person.g_actn_name          := actn.action_name;
          ben_ext_person.g_actn_description   := actn.action_desc;
          ben_ext_person.g_actn_type          := actn.action_type;
          ben_ext_person.g_actn_due_date      := actn.action_due_dt;
          ben_ext_person.g_actn_required_flag := actn.action_rqd_flag;
          ben_ext_person.g_actn_cmpltd_date   := actn.action_cmpltd_dt;
          ben_ext_person.g_actn_prtt_enrt_actn_id       := actn.prtt_enrt_actn_id;
          --
          -- format and write
          --
          ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                     p_ext_file_id       => p_ext_file_id,
                                     p_data_typ_cd       => p_data_typ_cd,
                                     p_ext_typ_cd        => p_ext_typ_cd,
                                     p_rcd_typ_cd        => 'D',
                                     p_low_lvl_cd        => 'A',
                                     p_person_id         => p_person_id,
                                     p_chg_evt_cd        => p_chg_evt_cd,
                                     p_business_group_id => p_business_group_id,
                                     p_effective_date    => p_effective_date
                                     );
        end if;
     --
   END LOOP;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main
--
END; -- package

/
