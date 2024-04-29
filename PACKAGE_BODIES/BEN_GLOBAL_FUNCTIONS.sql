--------------------------------------------------------
--  DDL for Package Body BEN_GLOBAL_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GLOBAL_FUNCTIONS" as
/* $Header: beglbfnc.pkb 120.1 2006/05/02 07:09:16 rbingi noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      18-Dec-00	mhoyes     Created.
  115.3      02-May-06  rbingi     Bug5160398: Considering rates attatched to
                                    opt_id. Added proc get_vpf_par_pgm_r_pl_id
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_global_functions.';
--
function is_plnip_related
  (p_pl_id   in number
  ,p_oipl_id in number
  )
return varchar2
is

  cursor c_plnip
    (c_pl_id in number
    )
  is
    select null
    from ben_pl_f pln
    where pln.pl_id = c_pl_id
    and not exists
      (select null
       from ben_plip_f cpp
       where pln.pl_id = cpp.pl_id);

  cursor c_oiplnip
    (c_oipl_id in number
    )
  is
    select null
    from ben_oipl_f cop
    where cop.oipl_id = c_oipl_id
    and not exists
      (select null
       from ben_plip_f cpp
       where cop.pl_id = cpp.pl_id);

  l_dummy  varchar2(1);
  l_return varchar2(1);

begin
  --
  l_return := 'N';
  --
  if p_pl_id is not null then
    --
    open c_plnip
      (c_pl_id => p_pl_id
      );
    fetch c_plnip into l_dummy;
    if c_plnip%found then
      --
      l_return := 'Y';
      --
    end if;
    close c_plnip;
    --
  elsif p_oipl_id is not null then
    --
    open c_oiplnip
      (c_oipl_id => p_oipl_id
      );
    fetch c_oiplnip into l_dummy;
    if c_oiplnip%found then
      --
      l_return := 'Y';
      --
    end if;
    close c_oiplnip;
    --
  end if;
  --
  return l_return;
  --
end is_plnip_related;
--
function get_par_plnip_id
  (p_pl_id   in number
  ,p_oipl_id in number
  ,p_opt_id  in number default null
  )
return number
is

  cursor c_plnip
    (c_pl_id in number
    )
  is
    select pln.pl_id
    from ben_pl_f pln
    where pln.pl_id = c_pl_id
    and not exists
      (select null
       from ben_plip_f cpp
       where pln.pl_id = cpp.pl_id);

  cursor c_oiplnip
    (c_oipl_id in number
    )
  is
    select cop.pl_id
    from ben_oipl_f cop
    where cop.oipl_id = c_oipl_id
    and not exists
      (select null
       from ben_plip_f cpp
       where cop.pl_id = cpp.pl_id);

  cursor c_opt_id
    (c_opt_id in number
    )
  is
    select pl_id
    from ben_oipl_f cop
    where cop.opt_id = c_opt_id
    and not exists
      (select null
       from ben_plip_f
       where cop.pl_id = cop.pl_id)
    order by pl_id;

  l_return number;

begin
  --
  l_return := null;
  --
  if p_pl_id is not null then
    --
    open c_plnip
      (c_pl_id => p_pl_id
      );
    fetch c_plnip into l_return;
    close c_plnip;
    --
  elsif p_oipl_id is not null then
    --
    open c_oiplnip
      (c_oipl_id => p_oipl_id
      );
    fetch c_oiplnip into l_return;
    close c_oiplnip;
    --
  elsif p_opt_id is not null then
    --
    open c_opt_id
      (p_opt_id
      );
    fetch c_opt_id into l_return;
    close c_opt_id;
    --
  end if;
  --
  return l_return;
  --
end get_par_plnip_id;
--
function get_par_pgm_id
  (p_pgm_id         in number
  ,p_ptip_id        in number
  ,p_pl_id          in number
  ,p_plip_id        in number
  ,p_oipl_id        in number
  ,p_oiplip_id      in number
  ,p_opt_id         in number default null
  )
return number
is

  cursor c_oipl
    (c_oipl_id  in number
    )
  is
    select cpp.pgm_id
    from ben_oipl_f cop,
         ben_plip_f cpp
    where cop.oipl_id = c_oipl_id
    and   cop.pl_id   = cpp.pl_id;

  cursor c_oiplip
    (c_oiplip_id in number
    )
  is
    select cpp.pgm_id
    from ben_oiplip_f opp,
         ben_plip_f cpp
    where opp.oiplip_id = c_oiplip_id
    and   opp.plip_id   = cpp.plip_id;

  cursor c_pl
    (c_pl_id  in number
    )
  is
    select cpp.pgm_id
    from ben_plip_f cpp
    where cpp.pl_id = c_pl_id;

  cursor c_plip
    (c_plip_id  in number
    )
  is
    select cpp.pgm_id
    from ben_plip_f cpp
    where cpp.plip_id = c_plip_id;

  cursor c_ptip
    (c_ptip_id  in number
    )
  is
    select cpp.pgm_id
    from ben_ptip_f cpp
    where cpp.ptip_id = c_ptip_id;

  cursor c_opt
    (c_opt_id in number
    )
  is
     select cpp.pgm_id
     from ben_oipl_f cop,
          ben_plip_f cpp
     where cop.opt_id = c_opt_id
     and cpp.pl_id = cop.pl_id
     order by cop.oipl_id, cpp.pl_id;

  l_return number;

begin
  --
  l_return := null;
  --
  if p_oipl_id is not null then
    --
    open c_oipl
      (c_oipl_id  => p_oipl_id
      );
    fetch c_oipl into l_return;
    close c_oipl;
    --
  elsif p_oiplip_id is not null then
    --
    open c_oiplip
      (c_oiplip_id => p_oiplip_id
      );
    fetch c_oiplip into l_return;
    close c_oiplip;
    --
  elsif p_plip_id is not null then
    --
    open c_plip
      (c_plip_id  => p_plip_id
      );
    fetch c_plip into l_return;
    close c_plip;
    --
  elsif p_pl_id is not null then
    --
    open c_pl
      (c_pl_id  => p_pl_id
      );
    fetch c_pl into l_return;
    close c_pl;
    --
  elsif p_ptip_id is not null then
    --
    open c_ptip
      (c_ptip_id  => p_ptip_id
      );
    fetch c_ptip into l_return;
    close c_ptip;
    --
  elsif p_pgm_id is not null then
    --
    l_return := p_pgm_id;
    --
  elsif p_opt_id is not null then
    --
    open c_opt
      (c_opt_id => p_opt_id
      );
    fetch c_opt into l_return;
    close c_opt;
    --
  end if;
  --
  return l_return;
  --
end get_par_pgm_id;
--
function is_monetary_abr
  (p_acty_base_rt_id in number
  )
return varchar2
is

  cursor c_abr
    (c_abr_id in number
    )
  is
    select null
    from ben_acty_base_rt_f abr
    where abr.acty_base_rt_id = c_abr_id
    and nnmntry_uom is null;

  l_dummy  varchar2(1);
  l_return varchar2(1);

begin
  --
  l_return := 'N';
  --
  if p_acty_base_rt_id is not null then
    --
    open c_abr
      (c_abr_id => p_acty_base_rt_id
      );
    fetch c_abr into l_dummy;
    if c_abr%found then
      --
      l_return := 'Y';
      --
    end if;
    close c_abr;
    --
  end if;
  --
  return l_return;
  --
end is_monetary_abr;
--
function get_abr_par_pgm_id
  (p_acty_base_rt_id in number
  )
return number
is

  cursor c_abr
    (c_abr_id  in number
    )
  is
    select abr.pgm_id,
           abr.ptip_id,
           abr.pl_id,
           abr.plip_id,
           abr.oipl_id,
           abr.oiplip_id
    from ben_acty_base_rt_f abr
    where abr.acty_base_rt_id = c_abr_id;

  l_abr_row c_abr%rowtype;

  l_return number;

begin
  --
  l_return := null;
  --
  open c_abr
    (c_abr_id => p_acty_base_rt_id
    );
  fetch c_abr into l_abr_row;
  close c_abr;
  --
  if p_acty_base_rt_id is not null then
    --
    l_return := ben_global_functions.get_par_pgm_id
                  (p_pgm_id    => l_abr_row.pgm_id
                  ,p_ptip_id   => l_abr_row.ptip_id
                  ,p_pl_id     => l_abr_row.pl_id
                  ,p_plip_id   => l_abr_row.plip_id
                  ,p_oipl_id   => l_abr_row.oipl_id
                  ,p_oiplip_id => l_abr_row.oiplip_id
                  );
    --
  end if;
  --
  return l_return;
  --
end get_abr_par_pgm_id;
--
function get_abr_par_plnip_id
  (p_acty_base_rt_id in number
  )
return number
is

  cursor c_abr
    (c_abr_id  in number
    )
  is
    select abr.pgm_id,
           abr.ptip_id,
           abr.pl_id,
           abr.plip_id,
           abr.oipl_id,
           abr.oiplip_id
    from ben_acty_base_rt_f abr
    where abr.acty_base_rt_id = c_abr_id;

  l_abr_row c_abr%rowtype;

  l_return number;

begin
  --
  l_return := null;
  --
  open c_abr
    (c_abr_id => p_acty_base_rt_id
    );
  fetch c_abr into l_abr_row;
  close c_abr;
  --
  if p_acty_base_rt_id is not null then
    --
    l_return := ben_global_functions.get_par_plnip_id
                  (p_pl_id     => l_abr_row.pl_id
                  ,p_oipl_id   => l_abr_row.oipl_id
                  );
    --
  end if;
  --
  return l_return;
  --
end get_abr_par_plnip_id;
--
function get_ecr_abrpar_pgm_id
  (p_enrt_rt_id in number
  )
return number
is

  cursor c_ecr
    (c_ecr_id  in number
    )
  is
    select ecr.acty_base_rt_id
    from ben_enrt_rt ecr
    where ecr.enrt_rt_id = c_ecr_id;

  l_abr_id number;

  l_return number;

begin
  --
  l_return := null;
  --
  open c_ecr
    (c_ecr_id => p_enrt_rt_id
    );
  fetch c_ecr into l_abr_id;
  close c_ecr;
  --
  if p_enrt_rt_id is not null then
    --
    l_return := ben_global_functions.get_abr_par_pgm_id
                  (p_acty_base_rt_id => l_abr_id
                  );
    --
  end if;
  --
  return l_return;
  --
end get_ecr_abrpar_pgm_id;
--
function get_vpf_par_pgm_r_pl_id(
  p_vrbl_rt_prfl_id in number,
  p_vpf_usg_cd      in varchar2,
  p_pgm_nip_lvl     in varchar2
  )
return number
is
 cursor c_get_rt_par_pgmpl_id(p_vpf_id number) is
  select ben_global_functions.get_par_pgm_id
           (abr.pgm_id,abr.ptip_id,abr.pl_id,abr.plip_id,abr.oipl_id,abr.oiplip_id,abr.opt_id) pgm_id,
         ben_global_functions.get_par_plnip_id(abr.pl_id,abr.oipl_id,abr.opt_id) nip_id
  from ben_acty_vrbl_rt_f avr
     , ben_acty_base_rt_f abr
  where avr.vrbl_rt_prfl_id = p_vpf_id
  and avr.acty_base_rt_id = abr.acty_base_rt_id
  and abr.nnmntry_uom is null
  and avr.effective_start_date between abr.effective_start_date
                                   and abr.effective_end_date;
 --
cursor c_get_cvg_par_pgmpl_id(p_vpf_id number) is
 select ben_global_functions.get_par_pgm_id
         (null,null,ccm.pl_id,ccm.plip_id,ccm.oipl_id,null) pgm_id,
        ben_global_functions.get_par_plnip_id(ccm.pl_id,ccm.oipl_id) nip_id
 from ben_bnft_vrbl_rt_f bvr
    , ben_cvg_amt_calc_mthd_f ccm
 where bvr.vrbl_rt_prfl_id = p_vpf_id
 and bvr.cvg_amt_calc_mthd_id = ccm.cvg_amt_calc_mthd_id
 and bvr.effective_start_date between ccm.effective_start_date
                                  and ccm.effective_end_date;
 --
cursor c_get_acp_par_pgmpl_id(p_vpf_id number) is
 select ben_global_functions.get_par_pgm_id
        (null,null,apr.pl_id,null,apr.oipl_id,null) pgm_id,
        ben_global_functions.get_par_plnip_id(apr.pl_id,apr.oipl_id) pl_id
 from ben_actl_prem_vrbl_rt_f apv
    , ben_actl_prem_f apr
 where apv.vrbl_rt_prfl_id = p_vpf_id
 and apv.actl_prem_id = apr.actl_prem_id
 and apv.effective_start_date between apr.effective_start_date
                                  and apr.effective_end_date;
 --
 l_par_pgm_id number;
 l_par_nip_id number;
 --
begin
 --
  if p_vpf_usg_cd = 'RT' then
   --
   open c_get_rt_par_pgmpl_id(p_vrbl_rt_prfl_id);
   fetch c_get_rt_par_pgmpl_id
      into l_par_pgm_id
          ,l_par_nip_id;
   close c_get_rt_par_pgmpl_id;
   --
  elsif p_vpf_usg_cd = 'CVG' then
   --
   Open c_get_cvg_par_pgmpl_id(p_vrbl_rt_prfl_id);
   fetch c_get_cvg_par_pgmpl_id
      into l_par_pgm_id
          ,l_par_nip_id;
   close c_get_cvg_par_pgmpl_id;
   --
  elsif p_vpf_usg_cd = 'ACP' then
   --
   Open c_get_acp_par_pgmpl_id(p_vrbl_rt_prfl_id);
   fetch c_get_acp_par_pgmpl_id
      into l_par_pgm_id
          ,l_par_nip_id;
   close c_get_acp_par_pgmpl_id;
   --
  end if;
 --
 if p_pgm_nip_lvl = 'PGM' then
  return l_par_pgm_id;
 elsif p_pgm_nip_lvl = 'PL' then
  return l_par_nip_id;
 end if;
 --
end get_vpf_par_pgm_r_pl_id;
--
function round_monetary_value
  (p_rnd_code_type    in varchar2
  ,p_rounding_cd      in varchar2
  ,p_rounding_rl      in varchar2
  ,p_effective_date   in date
  ,p_monetary_value   in number
  )
return number
is

  cursor c_ecr
    (c_ecr_id  in number
    )
  is
    select ecr.acty_base_rt_id
    from ben_enrt_rt ecr
    where ecr.enrt_rt_id = c_ecr_id;

  l_return number;

begin
  --
  if p_rounding_cd is null then
    --
    return p_monetary_value;
    --
  end if;
  --
  if p_rnd_code_type = 'ABR' then
    --
    l_return := benutils.do_rounding
                  (p_rounding_cd    => p_rounding_cd
                  ,p_rounding_rl    => p_rounding_rl
                  ,p_value          => p_monetary_value
                  ,p_effective_date => p_effective_date
                  );
    --
  end if;
  --
  return l_return;
  --
end round_monetary_value;
--
end ben_global_functions;

/
