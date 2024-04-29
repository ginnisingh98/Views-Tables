--------------------------------------------------------
--  DDL for Package Body BEN_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SUM" as
/* $Header: bensumfm.pkb 115.1 2003/02/12 10:30:35 rpgupta noship $ */
--
g_package varchar2(50) := 'ben_sum.';
--
PROCEDURE sum_query
  (block_data IN OUT NOCOPY sumtab
  ,p_person_id IN NUMBER
  )
IS

  l_onum1_va     benutils.g_number_table := benutils.g_number_table();
  l_onum2_va     benutils.g_number_table := benutils.g_number_table();
  l_onum3_va     benutils.g_number_table := benutils.g_number_table();
  l_name_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_id_va        benutils.g_number_table := benutils.g_number_table();
  l_bgpid_va     benutils.g_number_table := benutils.g_number_table();
  l_perid_va     benutils.g_number_table := benutils.g_number_table();
  l_yn_lookcd_va benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_type_va      benutils.g_v2_150_table := benutils.g_v2_150_table();
  l_otypecd_va   benutils.g_v2_150_table := benutils.g_v2_150_table();

  l_init         sumtab;

  cursor c_eff_date
  is
    select se.effective_date
    from   fnd_sessions se
    where  se.session_id = USERENV('sessionid');

  cursor sumselect
    (c_per_id   number
    ,c_eff_date date
    )
  is
    SELECT /*+ ben_sum.sumselect */
           pep.pgm_id order_num1,
           -1 order_num2,
           -1 order_num3,
           pgm.name name,
           pep.pgm_id id,
           pep.business_group_id business_group_id,
           pep.person_id person_id,
           pep.elig_flag yn_lookcd,
           'PGM' type
,
           pgm.pgm_typ_cd object_type_cd
    from ben_elig_per_f pep,
         ben_per_in_ler pil,
         ben_pgm_f pgm
    WHERE pep.person_id = c_per_id
      and   pep.pgm_id = pgm.pgm_id
      and   pep.pl_id is null
/*
      and   pep.plip_id is null
      and   pep.ptip_id is null
*/
      and   c_eff_date
        between pgm.effective_start_date and pgm.effective_end_date
      and   c_eff_date
        between pep.effective_start_date and pep.effective_end_date
      and pil.per_in_ler_id (+)= pep.per_in_ler_id
      and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        or pil.per_in_ler_stat_cd is null )
    union
    select pep.pgm_id order_num1,
           pep.pl_id order_num2,
           -1 order_num3,
           '  ' || pl.name name,
           pep.pl_id id ,
           pep.business_group_id business_group_id ,
           pep.person_id person_id ,
           pep.elig_flag yn_lookcd,
           'PL' type
 ,
           pl.svgs_pl_flag object_type_cd
    from ben_elig_per_f pep ,
         ben_per_in_ler pil,
         ben_pl_f pl
    WHERE pep.person_id = c_per_id
      and   pep.pl_id = pl.pl_id
      and   pep.pgm_id is not null
      and   pep.pl_id is not null
      and   c_eff_date
        between pep.effective_start_date and pep.effective_end_date
      and   c_eff_date
        between pl.effective_start_date and pl.effective_end_date
      and   exists
        (select null
         from ben_plip_f
         where pl_id = pl.pl_id
        )
      and pil.per_in_ler_id (+)= pep.per_in_ler_id
      and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        or pil.per_in_ler_stat_cd is null )
    union
    select pep.pgm_id order_num1 ,
           pep.pl_id order_num2 ,
           pio.opt_id order_num3 ,
           '    ' || opt.name name ,
           pio.opt_id id ,
           pep.business_group_id business_group_id ,
           pep.person_id person_id ,
           pio.elig_flag yn_lookcd,
           'OPT' type
,
           null object_type_cd
    from ben_elig_per_opt_f pio ,
         ben_elig_per_f pep ,
         ben_per_in_ler pil,
         ben_pl_f pl ,
         ben_opt_f opt
    WHERE pep.person_id = c_per_id
      and   pio.elig_per_id = pep.elig_per_id
      and   pio.opt_id = opt.opt_id
      and   pep.pl_id = pl.pl_id
      and   pep.pgm_id is not null
      and   pep.pl_id is not null
      and   c_eff_date
        between pep.effective_start_date and pep.effective_end_date
      and   c_eff_date
        between pio.effective_start_date and pio.effective_end_date
      and   c_eff_date
        between opt.effective_start_date and opt.effective_end_date
      and   c_eff_date
        between pl.effective_start_date and pl.effective_end_date
      and exists
        (select null from ben_plip_f where pl_id = pl.pl_id)
      and pil.per_in_ler_id (+)= pio.per_in_ler_id
      and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        or pil.per_in_ler_stat_cd is null )
    union
    select 9999999999999999999999999999999 order_num1 ,
           pep.pl_id order_num2 ,
           -1 order_num3 ,
           pl.name name ,
           pl.pl_id id ,
           pep.business_group_id business_group_id ,
           pep.person_id person_id ,
           pep.elig_flag yn_lookcd,
           'PL' type
,
           pl.svgs_pl_flag object_type_cd
    from ben_elig_per_f pep ,
         ben_per_in_ler pil,
         ben_pl_f pl
    WHERE pep.person_id = c_per_id
      and pep.pl_id = pl.pl_id
      and pep.pgm_id is null
      and c_eff_date
        between pep.effective_start_date and pep.effective_end_date
      and c_eff_date
        between pl.effective_start_date and pl.effective_end_date
      and not exists
        (select null from ben_plip_f
         where pl_id = pl.pl_id
        )
      and pil.per_in_ler_id (+)= pep.per_in_ler_id
      and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        or pil.per_in_ler_stat_cd is null )
    union
    select 9999999999999999999999999999999 order_num1 ,
           pep.pl_id order_num2 ,
           pio.opt_id order_num3 ,
           '  ' || opt.name name ,
           pio.opt_id id ,
           pep.business_group_id business_group_id ,
           pep.person_id person_id ,
           pio.elig_flag yn_lookcd,
           'OPT' type
,
           null object_type_cd
    from ben_elig_per_opt_f pio ,
         ben_elig_per_f pep ,
         ben_per_in_ler pil,
         ben_pl_f pl ,
         ben_opt_f opt
    WHERE pep.person_id = c_per_id
      and   pio.elig_per_id = pep.elig_per_id
      and   pio.opt_id = opt.opt_id
      and   pep.pl_id = pl.pl_id
      and   pep.pgm_id is null
      and   pep.pl_id is not null
      and   c_eff_date
        between pep.effective_start_date and pep.effective_end_date
      and   c_eff_date
        between pio.effective_start_date and pio.effective_end_date
      and   c_eff_date
        between opt.effective_start_date and opt.effective_end_date
      and   c_eff_date
        between pl.effective_start_date and pl.effective_end_date
      and   not exists
        (select null from ben_plip_f
         where pl_id = pl.pl_id
        )
      and pil.per_in_ler_id (+)= pio.per_in_ler_id
      and ( pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        or pil.per_in_ler_stat_cd is null )
    order by order_num1,
             order_num2,
             order_num3;

  l_eff_date   date;

BEGIN
  --
  block_data := l_init;
  --
  open c_eff_date;
  fetch c_eff_date into l_eff_date;
  close c_eff_date;
  --
  open sumselect
    (c_per_id   => p_person_id
    ,c_eff_date => l_eff_date
    );
  fetch sumselect BULK COLLECT INTO l_onum1_va,
                                    l_onum2_va,
                                    l_onum3_va,
                                    l_name_va,
                                    l_id_va,
                                    l_bgpid_va,
                                    l_perid_va,
                                    l_yn_lookcd_va,
                                    l_type_va,
                                    l_otypecd_va;
  close sumselect;
  --
  if l_onum1_va.count > 0 then
    --
    for elenum in l_onum1_va.first .. l_onum1_va.last
    loop
      --
      block_data(elenum-1).order_num1        := l_onum1_va(elenum);
      block_data(elenum-1).order_num2        := l_onum2_va(elenum);
      block_data(elenum-1).order_num3        := l_onum3_va(elenum);
      block_data(elenum-1).name              := l_name_va(elenum);
      block_data(elenum-1).id                := l_id_va(elenum);
      block_data(elenum-1).business_group_id := l_bgpid_va(elenum);
      block_data(elenum-1).person_id         := l_perid_va(elenum);
      block_data(elenum-1).meaning           := l_yn_lookcd_va(elenum);
      block_data(elenum-1).type              := l_type_va(elenum);
      block_data(elenum-1).object_type_cd    := l_otypecd_va(elenum);
      --
    end loop;
    --
  end if;
  --
END sum_query;
--
end ben_sum;

/
