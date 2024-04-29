--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ELIG" AS
/* $Header: benxelig.pkb 120.6 2007/09/05 02:22:35 tjesumic noship $ */



g_package  varchar2(33)	:= '  ben_ext_elig.';  -- Global package name

TYPE t_number       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar2_30  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar2_600 IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
TYPE t_date         IS TABLE OF Date  INDEX BY BINARY_INTEGER;


--
-- ----------------------------------------------------------------------------
-- |------< get_rt_info >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure get_rt_info(
                      p_elig_per_elctbl_chc_id   in number
                      ) IS
--
  l_proc               varchar2(72) := g_package||'get_rt_info';
--
/*
 cursor ee_pre_tax_c is
  select
   sum(nvl(ecr1.val,ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.tx_typ_cd,ecr2.tx_typ_cd) = 'PRETAX'
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC');
*/

cursor ee_pre_tax_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
      p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
      and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
  and ecr1.tx_typ_cd ='PRETAX'
  and ecr1.acty_typ_cd in ('EEPLC', 'EEIC','EEPYC','PBC','PBC2','PXC') ;



cursor ee_pre_tax_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
       and  ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id
  and  ecr2.tx_typ_cd='PRETAX'
  and  ecr2.acty_typ_cd IN ('EEPLC','EEIC','EEPYC','PBC','PBC2','PXC') ;



--
/*
 cursor ee_after_tax_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
       ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.tx_typ_cd,ecr2.tx_typ_cd) = 'AFTERTAX'
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC');
*/

 cursor ee_after_tax_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
  and  ecr1.tx_typ_cd='AFTERTAX'
  and  ecr1.acty_typ_cd in ('EEPLC', 'EEIC' , 'EEPYC', 'PBC', 'PBC2', 'PXC')
       ;



  cursor ee_after_tax_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
       ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id
  and ecr2.tx_typ_cd='AFTERTAX'
  and ecr2.acty_typ_cd IN ('EEPLC', 'EEIC','EEPYC', 'PBC', 'PBC2', 'PXC')
      ;


--
/*
cursor ee_ttl_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('EEPLC', 'EEIC', 'EEPYC', 'PBC', 'PBC2', 'PXC');
*/

 cursor ee_ttl_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
  and  ecr1.acty_typ_cd in ('EEPLC', 'EEIC' , 'EEPYC', 'PBC', 'PBC2', 'PXC')
  ;



  cursor ee_ttl_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
       ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id
  and  ecr2.acty_typ_cd IN ('EEPLC', 'EEIC','EEPYC', 'PBC', 'PBC2', 'PXC')
    ;

--
/*
cursor er_ttl_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('ERPYC', 'ERMPLC', 'ERC');
*/

 cursor er_ttl_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
    and ecr1.acty_typ_cd in ('ERPYC', 'ERMPLC', 'ERC')
       ;



 cursor er_ttl_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and enb.enrt_bnft_id = ecr2.enrt_bnft_id
     and ecr2.acty_typ_cd IN ('ERPYC', 'ERMPLC', 'ERC')
     ;


--
/*
  cursor ee_ttl_dist_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
       ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('EEPYD', 'EERIID', 'PBD', 'PXD', 'PXD1');
*/

  cursor ee_ttl_dist_c is
  select
  sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
       and ecr1.acty_typ_cd in ('EEPYD', 'EERIID', 'PBD', 'PXD', 'PXD1')
      ;



  cursor ee_ttl_dist_enb_c is
  select
  sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and enb.enrt_bnft_id = ecr2.enrt_bnft_id
     and ecr2.acty_typ_cd IN ('EEPYD', 'EERIID', 'PBD', 'PXD', 'PXD1')
    ;


--
/*
  cursor er_ttl_dist_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) IN ('ERPYD', 'ERD');
*/

  cursor er_ttl_dist_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
     and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
     and ecr1.acty_typ_cd in ('ERPYD', 'ERD')
   ;



  cursor er_ttl_dist_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and enb.enrt_bnft_id = ecr2.enrt_bnft_id
     and ecr2.acty_typ_cd IN ('ERPYD', 'ERD')
     ;


--
/*
cursor ttl_oth_rt_c is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
  and nvl(ecr1.acty_typ_cd,ecr2.acty_typ_cd) NOT IN ('EEPYD', 'EEPRIID', 'PBD', 'PXD',
                                                     'PXD1', 'ERPYD', 'ERD', 'EEPLC',
                                                     'EEIC', 'EEPYC', 'PBC', 'PBC2',
                                                     'PXC', 'ERPYC', 'ERMPLC', 'ERC');
*/

 cursor ttl_oth_rt_c is
  select
   sum(ecr1.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id
     and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id
     and  ecr1.acty_typ_cd  not in ('EEPYD', 'EEPRIID', 'PBD', 'PXD',
                                                     'PXD1', 'ERPYD', 'ERD', 'EEPLC',
                                                     'EEIC', 'EEPYC', 'PBC', 'PBC2',
                                                     'PXC', 'ERPYC', 'ERMPLC', 'ERC')
   ;


  cursor ttl_oth_rt_enb_c is
  select
   sum(ecr2.val)
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
     p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id
     and enb.enrt_bnft_id = ecr2.enrt_bnft_id
     and ecr2.acty_typ_cd  not IN ('EEPYD', 'EEPRIID', 'PBD', 'PXD',
                                   'PXD1', 'ERPYD', 'ERD', 'EEPLC',
                                   'EEIC', 'EEPYC', 'PBC', 'PBC2',
                                   'PXC', 'ERPYC', 'ERMPLC', 'ERC')
     ;

--
cursor c_min_max_rt1 is
  select
       enr.mn_elcn_val,
       enr.mx_elcn_val,
       enr.incrmt_elcn_val,
       enr.dflt_val
  from ben_enrt_rt enr
  where enr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
--
  cursor c_min_max_rt2 is
  select
       enr.mn_elcn_val,
       enr.mx_elcn_val,
       enr.incrmt_elcn_val,
       enr.dflt_val
  from ben_enrt_rt enr,
       ben_enrt_bnft bnf
  where bnf.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
       and   bnf.enrt_bnft_id = enr.enrt_bnft_id;


-----cwb 2832419
  cursor ttl_type_cd_c(c_typ_cd varchar2) is
  select
   sum(nvl(ecr1.val,ecr2.val))
  from ben_elig_per_elctbl_chc ele,
       ben_enrt_rt ecr1,
       ben_enrt_rt ecr2,
       ben_enrt_bnft enb
  where
       p_elig_per_elctbl_chc_id = ele.elig_per_elctbl_chc_id and
     ele.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
       and ele.elig_per_elctbl_chc_id = ecr1.elig_per_elctbl_chc_id(+)
       and enb.enrt_bnft_id = ecr2.enrt_bnft_id (+)
    and (ecr1.acty_typ_cd = c_typ_cd or (ecr1.acty_typ_cd is null and ecr2.acty_typ_cd =  c_typ_cd)) ;


    l_rate_total  number ;
    l_enb_rate_total  number ;

--
begin
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  hr_utility.set_location('p_elig_per_elctbl_chc_id  '|| p_elig_per_elctbl_chc_id , 5);

  ben_ext_person.g_elig_ee_pre_tax_cost := null ;
  ben_ext_person.g_elig_ee_after_tax_cost := null ;
  ben_ext_person.g_elig_ee_ttl_cost := null ;
  ben_ext_person.g_elig_er_ttl_cost := null ;
  ben_ext_person.g_elig_ee_ttl_distribution := null ;
  ben_ext_person.g_elig_er_ttl_distribution := null ;
  ben_ext_person.g_elig_ttl_other_rate := null ;

  --
  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;
  open ee_pre_tax_c;
  fetch ee_pre_tax_c into l_rate_total;
  close ee_pre_tax_c;


  open ee_pre_tax_enb_c;
  fetch ee_pre_tax_enb_c into l_enb_rate_total;
  close ee_pre_tax_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
     ben_ext_person.g_elig_ee_pre_tax_cost := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0)  ;
  end if ;
  hr_utility.set_location('g_elig_ee_pre_tax_cost  '|| nvl(l_rate_total,0) ||'/'||nvl(l_enb_rate_total,0)||'/'|| ben_ext_person.g_elig_ee_pre_tax_cost , 5);
  --
  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open ee_after_tax_c;
  fetch ee_after_tax_c into l_rate_total;
  close ee_after_tax_c;

  open ee_after_tax_enb_c;
  fetch ee_after_tax_enb_c into l_enb_rate_total;
  close ee_after_tax_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
      ben_ext_person.g_elig_ee_after_tax_cost := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0)  ;
  end if ;

  hr_utility.set_location('g_elig_ee_after_tax_cost  '|| nvl(l_rate_total,0) ||'/'||nvl(l_enb_rate_total,0)||'/'|| ben_ext_person.g_elig_ee_after_tax_cost , 5);
  --
  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open ee_ttl_c;
  fetch ee_ttl_c into l_rate_total;
  close ee_ttl_c;


  open ee_ttl_enb_c;
  fetch ee_ttl_enb_c into l_enb_rate_total;
  close ee_ttl_enb_c;


  if l_rate_total is not null  or l_enb_rate_total is not null then
      ben_ext_person.g_elig_ee_ttl_cost := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0)  ;
  end if ;
  --

  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open er_ttl_c;
  fetch er_ttl_c into l_rate_total;
  close er_ttl_c;

  open er_ttl_enb_c;
  fetch er_ttl_enb_c into l_enb_rate_total;
  close er_ttl_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
      ben_ext_person.g_elig_er_ttl_cost := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0) ;
  end if ;
  --
  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open ee_ttl_dist_c;
  fetch ee_ttl_dist_c into l_rate_total;
  close ee_ttl_dist_c;


  open ee_ttl_dist_enb_c;
  fetch ee_ttl_dist_enb_c into l_enb_rate_total;
  close ee_ttl_dist_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
      ben_ext_person.g_elig_ee_ttl_distribution := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0) ;
  end if ;
  hr_utility.set_location('g_elig_ee_ttl_distribution  '|| nvl(l_rate_total,0) ||'/'||nvl(l_enb_rate_total,0)||'/'|| ben_ext_person.g_elig_ee_ttl_distribution , 5);
  --

  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open er_ttl_dist_c;
  fetch er_ttl_dist_c into l_rate_total;
  close er_ttl_dist_c;


  open er_ttl_dist_enb_c;
  fetch er_ttl_dist_enb_c into l_enb_rate_total;
  close er_ttl_dist_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
    ben_ext_person.g_elig_er_ttl_distribution := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0)  ;
  end if ;
  hr_utility.set_location('g_elig_er_ttl_distribution  '|| nvl(l_rate_total,0) ||'/'||nvl(l_enb_rate_total,0)||'/'|| ben_ext_person.g_elig_er_ttl_distribution , 5);
  --
  l_rate_total     := 0 ;
  l_enb_rate_total := 0 ;

  open ttl_oth_rt_c;
  fetch ttl_oth_rt_c into l_rate_total;
  close ttl_oth_rt_c;

  open ttl_oth_rt_enb_c;
  fetch ttl_oth_rt_enb_c into l_enb_rate_total;
  close ttl_oth_rt_enb_c;

  if l_rate_total is not null  or l_enb_rate_total is not null then
     ben_ext_person.g_elig_ttl_other_rate := nvl(l_rate_total,0) + nvl(l_enb_rate_total,0)  ;
  end if ;

  --
  open c_min_max_rt1;
  fetch c_min_max_rt1 into
    ben_ext_person.g_elig_min_amt,
    ben_ext_person.g_elig_max_amt,
    ben_ext_person.g_elig_incr_amt,
    ben_ext_person.g_elig_dflt_amt;
  -- if not found then try another path.
  if c_min_max_rt1%NOTFOUND then
    open c_min_max_rt2;
    fetch c_min_max_rt2 into
      ben_ext_person.g_elig_min_amt,
      ben_ext_person.g_elig_max_amt,
      ben_ext_person.g_elig_incr_amt,
      ben_ext_person.g_elig_dflt_amt;
    close c_min_max_rt2;
  end if;
  --
  close c_min_max_rt1;
  --
  --cwb 2832419
   open ttl_type_cd_c('CWBDB');
   fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_dst_bdgt;
   close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBES');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_elig_salary;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBGP');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_grant_price;
  close ttl_type_cd_c ;


  open ttl_type_cd_c('CWBMR1');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_misc_rate_1;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBMR2');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_misc_rate_2;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBMR3');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_misc_rate_3;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBOS');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_other_salary;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBR');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_reserve ;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBRA');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_recomond_amt;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBSS');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_stated_salary;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBTC');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_tot_compensation;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBWB');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_worksheet_bdgt;
  close ttl_type_cd_c ;

  open ttl_type_cd_c('CWBWS');
  fetch ttl_type_cd_c into  ben_ext_person.g_elig_ee_cwb_worksheet_amt;
  close ttl_type_cd_c ;

  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End get_rt_info;
--
-- ----------------------------------------------------------------------------
-- |------< init_detl_globals >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure init_detl_globals IS
--
  l_proc               varchar2(72) := g_package||'init_detl_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
   --
    ben_ext_person.g_elig_enrt_strt_dt           := null;
    ben_ext_person.g_elig_enrt_end_dt            := null;
    ben_ext_person.g_elig_dflt_enrt_dt           := null;
    ben_ext_person.g_elig_uom                    := null;
    ben_ext_person.g_elig_pl_name                := null;
    ben_ext_person.g_elig_opt_name               := null;
    ben_ext_person.g_elig_cvg_amt                := null;
    ben_ext_person.g_elig_cvg_min_amt            := null;
    ben_ext_person.g_elig_cvg_max_amt            := null;
    ben_ext_person.g_elig_cvg_inc_amt            := null;
    ben_ext_person.g_elig_cvg_dfl_amt            := null;
    ben_ext_person.g_elig_cvg_dfl_flg            := null;
    ben_ext_person.g_elig_cvg_seq_no             := null;
    ben_ext_person.g_elig_cvg_onl_flg            := null;
    ben_ext_person.g_elig_cvg_calc_mthd          := null;
    ben_ext_person.g_elig_cvg_bnft_typ           := null;
    ben_ext_person.g_elig_cvg_bnft_uom           := null;
    ben_ext_person.g_elig_pl_ord_no              := null;
    ben_ext_person.g_elig_opt_ord_no             := null;
    ben_ext_person.g_elig_pl_id                  := null;
    ben_ext_person.g_elig_pl_typ_name            := null;
    ben_ext_person.g_elig_opt_id                 := null;
    ben_ext_person.g_elig_min_amt                := null;
    ben_ext_person.g_elig_max_amt                := null;
    ben_ext_person.g_elig_incr_amt               := null;
    ben_ext_person.g_elig_dflt_amt               := null;
    ben_ext_person.g_elig_elec_made_dt           := null;
    ben_ext_person.g_elig_program_id             := null;
    ben_ext_person.g_elig_program_name           := null;
    ben_ext_person.g_elig_er_ttl_cost            := null;
    ben_ext_person.g_elig_ee_ttl_cost            := null;
    ben_ext_person.g_elig_ee_after_tax_cost      := null;
    ben_ext_person.g_elig_ee_pre_tax_cost        := null;
    ben_ext_person.g_elig_total_premium_amt      := null;
    ben_ext_person.g_elig_total_premium_uom      := null;
    ben_ext_person.g_elig_rpt_group_name         := null;
    ben_ext_person.g_elig_rpt_group_id           := null;
    ben_ext_person.g_elig_pl_yr_strdt   	 := null;
    ben_ext_person.g_elig_pl_yr_enddt   	 := null;
    ben_ext_person.g_elig_pl_seq_num     	 := null;
    ben_ext_person.g_elig_pip_seq_num     	 := null;
    ben_ext_person.g_elig_ptp_seq_num     	 := null;
    ben_ext_person.g_elig_oip_seq_num     	 := null;
    ben_ext_person.g_elig_flex_01                := null;
    ben_ext_person.g_elig_flex_02                := null;
    ben_ext_person.g_elig_flex_03                := null;
    ben_ext_person.g_elig_flex_04                := null;
    ben_ext_person.g_elig_flex_05                := null;
    ben_ext_person.g_elig_flex_06                := null;
    ben_ext_person.g_elig_flex_07                := null;
    ben_ext_person.g_elig_flex_08                := null;
    ben_ext_person.g_elig_flex_09                := null;
    ben_ext_person.g_elig_flex_10                := null;
    ben_ext_person.g_elig_plan_flex_01           := null;
    ben_ext_person.g_elig_plan_flex_02           := null;
    ben_ext_person.g_elig_plan_flex_03           := null;
    ben_ext_person.g_elig_plan_flex_04           := null;
    ben_ext_person.g_elig_plan_flex_05           := null;
    ben_ext_person.g_elig_plan_flex_06           := null;
    ben_ext_person.g_elig_plan_flex_07           := null;
    ben_ext_person.g_elig_plan_flex_08           := null;
    ben_ext_person.g_elig_plan_flex_09           := null;
    ben_ext_person.g_elig_plan_flex_10           := null;
    ben_ext_person.g_elig_pgm_flex_01            := null;
    ben_ext_person.g_elig_pgm_flex_02            := null;
    ben_ext_person.g_elig_pgm_flex_03            := null;
    ben_ext_person.g_elig_pgm_flex_04            := null;
    ben_ext_person.g_elig_pgm_flex_05            := null;
    ben_ext_person.g_elig_pgm_flex_06            := null;
    ben_ext_person.g_elig_pgm_flex_07            := null;
    ben_ext_person.g_elig_pgm_flex_08            := null;
    ben_ext_person.g_elig_pgm_flex_09            := null;
    ben_ext_person.g_elig_pgm_flex_10            := null;
    ben_ext_person.g_elig_ptp_flex_01            := null;
    ben_ext_person.g_elig_ptp_flex_02            := null;
    ben_ext_person.g_elig_ptp_flex_03            := null;
    ben_ext_person.g_elig_ptp_flex_04            := null;
    ben_ext_person.g_elig_ptp_flex_05            := null;
    ben_ext_person.g_elig_ptp_flex_06            := null;
    ben_ext_person.g_elig_ptp_flex_07            := null;
    ben_ext_person.g_elig_ptp_flex_08            := null;
    ben_ext_person.g_elig_ptp_flex_09            := null;
    ben_ext_person.g_elig_ptp_flex_10            := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_01      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_02      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_03      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_04      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_05      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_06      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_07      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_08      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_09      := null;
    ben_ext_person.g_elig_pl_in_pgm_flex_10      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_01      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_02      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_03      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_04      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_05      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_06      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_07      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_08      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_09      := null;
    ben_ext_person.g_elig_opt_in_pl_flex_10      := null;
    ben_ext_person.g_elig_opt_flex_01            := null;
    ben_ext_person.g_elig_opt_flex_02            := null;
    ben_ext_person.g_elig_opt_flex_03            := null;
    ben_ext_person.g_elig_opt_flex_04            := null;
    ben_ext_person.g_elig_opt_flex_05            := null;
    ben_ext_person.g_elig_opt_flex_06            := null;
    ben_ext_person.g_elig_opt_flex_07            := null;
    ben_ext_person.g_elig_opt_flex_08            := null;
    ben_ext_person.g_elig_opt_flex_09            := null;
    ben_ext_person.g_elig_opt_flex_10            := null;
    ben_ext_person.g_elig_ler_id                 := null;
    ben_ext_person.g_elig_lfevt_name             := null;
    ben_ext_person.g_elig_lfevt_status           := null;
    ben_ext_person.g_elig_lfevt_note_dt          := null;
    ben_ext_person.g_elig_lfevt_ocrd_dt          := null;
    ben_ext_person.g_elig_per_elctbl_chc_id      := null;
    ----2559743
    ben_ext_person.g_elig_pl_fd_name             := null ;
    ben_ext_person.g_elig_pl_fd_code             := null ;
    ben_ext_person.g_elig_pgm_fd_name            := null ;
    ben_ext_person.g_elig_pgm_fd_code            := null ;
    ben_ext_person.g_elig_opt_fd_name            := null ;
    ben_ext_person.g_elig_opt_fd_code            := null ;
    ben_ext_person.g_elig_pl_typ_fd_name         := null ;
    ben_ext_person.g_elig_pl_typ_fd_code         := null ;
    ben_ext_person.g_elig_opt_pl_fd_name         := null ;
    ben_ext_person.g_elig_opt_pl_fd_code         := null ;
    ben_ext_person.g_elig_pl_pgm_fd_name         := null ;
    ben_ext_person.g_elig_pl_pgm_fd_code         := null ;
    ben_ext_person.g_elig_pl_typ_pgm_fd_name     := null ;
    ben_ext_person.g_elig_pl_typ_pgm_fd_code     := null ;
    ---cwb 2832419
    ben_ext_person.g_elig_ee_cwb_dst_bdgt               :=    null ;
    ben_ext_person.g_elig_ee_cwb_misc_rate_1            :=    null ;
    ben_ext_person.g_elig_ee_cwb_elig_salary            :=    null ;
    ben_ext_person.g_elig_ee_cwb_misc_rate_2            :=    null ;
    ben_ext_person.g_elig_ee_cwb_grant_price            :=    null ;
    ben_ext_person.g_elig_ee_cwb_other_salary           :=    null ;
    ben_ext_person.g_elig_ee_cwb_reserve                :=    null ;
    ben_ext_person.g_elig_ee_cwb_recomond_amt           :=    null ;
    ben_ext_person.g_elig_ee_cwb_stated_salary          :=    null ;
    ben_ext_person.g_elig_ee_cwb_tot_compensation       :=    null ;
    ben_ext_person.g_elig_ee_cwb_worksheet_bdgt         :=    null ;
    ben_ext_person.g_elig_ee_cwb_elig_salary            :=    null ;

    --cobra letter
    ben_ext_person.g_elig_cobra_payment_dys   := null;
    ben_ext_person.g_elig_cobra_admin_name    := null;
    ben_ext_person.g_elig_cobra_admin_org_name:= null;
    ben_ext_person.g_elig_cobra_admin_addr1   := null;
    ben_ext_person.g_elig_cobra_admin_addr2   := null;
    ben_ext_person.g_elig_cobra_admin_addr3   := null;
    ben_ext_person.g_elig_cobra_admin_city    := null;
    ben_ext_person.g_elig_cobra_admin_state   := null;
    ben_ext_person.g_elig_cobra_admin_country := null;
    ben_ext_person.g_elig_cobra_admin_zip     := null;
    ben_ext_person.g_elig_cobra_admin_phone   := null;

  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End init_detl_globals;
--
-- ----------------------------------------------------------------------------
-- |------< init_detl_drvd_fctr_globals >-------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure init_detl_drvd_fctr_globals IS
--
  l_proc               varchar2(72) := g_package||'init_detl_drvd_fctr_globals';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
   --
    ben_ext_person.g_elig_age_val                := null;
    ben_ext_person.g_elig_los_val                := null;
    ben_ext_person.g_elig_age_uom                := null;
    ben_ext_person.g_elig_los_uom                := null;
    ben_ext_person.g_elig_comp_amt               := null;
    ben_ext_person.g_elig_comp_amt_uom           := null;
    ben_ext_person.g_elig_cmbn_age_n_los         := null;
    ben_ext_person.g_elig_hrs_wkd                := null;
    ben_ext_person.g_elig_pct_fl_tm              := null;
  --
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End init_detl_drvd_fctr_globals;
--
-- ----------------------------------------------------------------------------
-- |------< main >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure main
  (p_person_id          in number,
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
  l_include          varchar2(1) := 'Y';
  --
  /*
  The following cursor will be splited into many cursor
  cursor c_elig(p_person_id number) is
    select   + FIRST_ROWS(1) BEN_EXT_ELIG.main.c_elig
           pler.ler_id                  ler_id,
           pler.person_id               person_id,
           pler.per_in_ler_stat_cd      per_in_ler_stat_cd,
           pler.lf_evt_ocrd_dt          lf_evt_ocrd_dt,
           pler.ntfn_dt                 ntfn_dt,
           echc.pl_ordr_num             pl_seq_num,
           echc.plip_ordr_num           plip_seq_num,
           echc.ptip_ordr_num           ptip_seq_num,
           echc.oipl_ordr_num           oipl_seq_num,
           echc.pl_id                   pl_id,
           echc.epe_attribute1          flex_01,
           echc.epe_attribute2          flex_02,
           echc.epe_attribute3          flex_03,
           echc.epe_attribute4          flex_04,
           echc.epe_attribute5          flex_05,
           echc.epe_attribute6          flex_06,
           echc.epe_attribute7          flex_07,
           echc.epe_attribute8          flex_08,
           echc.epe_attribute9          flex_09,
           echc.epe_attribute10         flex_10,
           pl.name                      pl_name,
           pl.short_name                pl_fd_name,
           pl.short_code                pl_fd_code,
           pl.pln_attribute1            pl_flex_01,
           pl.pln_attribute2            pl_flex_02,
           pl.pln_attribute3            pl_flex_03,
           pl.pln_attribute4            pl_flex_04,
           pl.pln_attribute5            pl_flex_05,
           pl.pln_attribute6            pl_flex_06,
           pl.pln_attribute7            pl_flex_07,
           pl.pln_attribute8            pl_flex_08,
           pl.pln_attribute9            pl_flex_09,
           pl.pln_attribute10           pl_flex_10,
           ptp.name                     pl_type_name,
           ptp.short_name               ptp_fd_name,
           ptp.short_code               ptp_fd_code,
           ptp.ptp_attribute1           ptp_flex_01,
           ptp.ptp_attribute2           ptp_flex_02,
           ptp.ptp_attribute3           ptp_flex_03,
           ptp.ptp_attribute4           ptp_flex_04,
           ptp.ptp_attribute5           ptp_flex_05,
           ptp.ptp_attribute6           ptp_flex_06,
           ptp.ptp_attribute7           ptp_flex_07,
           ptp.ptp_attribute8           ptp_flex_08,
           ptp.ptp_attribute9           ptp_flex_09,
           ptp.ptp_attribute10          ptp_flex_10,
           plip.short_name              plip_fd_name,
           plip.short_code              plip_fd_code,
           plip.ordr_num                pl_ord_no,
           plip.cpp_attribute1          plip_flex_01,
           plip.cpp_attribute2          plip_flex_02,
           plip.cpp_attribute3          plip_flex_03,
           plip.cpp_attribute4          plip_flex_04,
           plip.cpp_attribute5          plip_flex_05,
           plip.cpp_attribute6          plip_flex_06,
           plip.cpp_attribute7          plip_flex_07,
           plip.cpp_attribute8          plip_flex_08,
           plip.cpp_attribute9          plip_flex_09,
           plip.cpp_attribute10         plip_flex_10,
           echc.elig_per_elctbl_chc_id  elig_per_elctbl_chc_id,
           echc.enrt_cvg_strt_dt        enrt_cvg_strt_dt,
           echc.yr_perd_id              yr_perd_id,
           echc.pl_typ_id               pl_typ_id,
           echc.last_update_date        last_update_date,
           echc.per_in_ler_id           per_in_ler_id,
           echc.prtt_enrt_rslt_id       prtt_enrt_rslt_id,
           opt.name                     opt_name,
           opt.opt_id                   opt_id,
           opt.short_name               opt_fd_name,
           opt.short_code               opt_fd_code,
           oipl.short_name              oipl_fd_name,
           oipl.short_code              oipl_fd_code,
           oipl.ordr_num                opt_ord_no,
           oipl.cop_attribute1          oipl_flex_01,
           oipl.cop_attribute2          oipl_flex_02,
           oipl.cop_attribute3          oipl_flex_03,
           oipl.cop_attribute4          oipl_flex_04,
           oipl.cop_attribute5          oipl_flex_05,
           oipl.cop_attribute6          oipl_flex_06,
           oipl.cop_attribute7          oipl_flex_07,
           oipl.cop_attribute8          oipl_flex_08,
           oipl.cop_attribute9          oipl_flex_09,
           oipl.cop_attribute10         oipl_flex_10,
           ptip.short_name              ptip_fd_name,
           ptip.short_code              ptip_fd_code,
           enb.val                      cvg_amt,
           enb.mn_val                   mn_val,
           enb.mx_val                   mx_val,
           enb.dflt_val                 dflt_val,
           enb.incrmt_val               incrmt_val,
           decode(enb.enrt_bnft_id , null,echc.dflt_flag, enb.dflt_flag)   dflt_flag,
           enb.nnmntry_uom              nnmntry_uom,
           enb.bnft_typ_cd              bnft_typ_cd,
           enb.entr_val_at_enrt_flag    entr_val_at_enrt_flag,
           enb.cvg_mlt_cd               cvg_mlt_cd,
           enb.ordr_num                 ordr_num,
           ppopl.enrt_perd_strt_dt      enrt_strt_dt,
           ppopl.enrt_perd_end_dt       enrt_end_dt,
           ppopl.dflt_enrt_dt           dflt_enrt_dt,
           ppopl.uom                    uom,
           ppopl.elcns_made_dt          elcn_made_dt,
           pgm.pgm_id          	    program_id,
           pgm.name          	    program_name,
           pgm.short_name           pgm_fd_name,
           pgm.short_code           pgm_fd_code,
           pgm.pgm_attribute1        pgm_flex_01,
           pgm.pgm_attribute2           pgm_flex_02,
           pgm.pgm_attribute3           pgm_flex_03,
           pgm.pgm_attribute4           pgm_flex_04,
           pgm.pgm_attribute5           pgm_flex_05,
           pgm.pgm_attribute6           pgm_flex_06,
           pgm.pgm_attribute7           pgm_flex_07,
           pgm.pgm_attribute8           pgm_flex_08,
           pgm.pgm_attribute9           pgm_flex_09,
           pgm.pgm_attribute10          pgm_flex_10,
           opt.opt_attribute1           opt_flex_01,
           opt.opt_attribute2           opt_flex_02,
           opt.opt_attribute3           opt_flex_03,
           opt.opt_attribute4           opt_flex_04,
           opt.opt_attribute5           opt_flex_05,
           opt.opt_attribute6           opt_flex_06,
           opt.opt_attribute7           opt_flex_07,
           opt.opt_attribute8           opt_flex_08,
           opt.opt_attribute9           opt_flex_09,
           opt.opt_attribute10          opt_flex_10,
           pl.cobra_pymt_due_dy_num
    from   ben_per_in_ler          pler,
           ben_elig_per_elctbl_chc echc,
           ben_pil_elctbl_chc_popl ppopl,
           ben_enrt_bnft           enb,
           ben_opt_f               opt,
           ben_pl_f                pl,
           ben_plip_f              plip,
           ben_oipl_f              oipl,
           ben_pgm_f               pgm,
           ben_pl_typ_f            ptp,
           ben_ptip_f              ptip                           -- 2732104
    where  pler.person_id = p_person_id
    and    pler.per_in_ler_id = echc.per_in_ler_id
    and    echc.pil_elctbl_chc_popl_id = ppopl.pil_elctbl_chc_popl_id
    and    echc.elctbl_flag = 'Y'
    and    echc.pgm_id = pgm.pgm_id(+) --removed -1 nvl statement
    and    echc.pl_id = pl.pl_id(+) --removed -1 nvl statement
    and    oipl.opt_id = opt.opt_id(+) --removed -1 nvl statement
    and    echc.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
    and    echc.oipl_id = oipl.oipl_id(+) --removed -1 nvl statement
    and    echc.plip_id = plip.plip_id(+) --removed -1 nvl statement
    and    echc.ptip_id = ptip.ptip_id(+) --removed -1 nvl statement  -- 2732104
    and    pl.pl_typ_id = ptp.pl_typ_id(+) --removed -1 nvl statement
    and    p_effective_date
           between nvl(pl.effective_start_date,p_effective_date)
           and     nvl(pl.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(opt.effective_start_date,p_effective_date)
           and     nvl(opt.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(plip.effective_start_date,p_effective_date)
           and     nvl(plip.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(oipl.effective_start_date,p_effective_date)
           and     nvl(oipl.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(ptp.effective_start_date,p_effective_date)
           and     nvl(ptp.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(pgm.effective_start_date,p_effective_date)
           and     nvl(pgm.effective_end_date ,p_effective_date)
    and    p_effective_date
           between nvl(ptip.effective_start_date,p_effective_date)
           and     nvl(ptip.effective_end_date ,p_effective_date)
    ;
   */

    --- Variale for  collection

     l_elig_ler_id_va                t_number;
     l_elig_person_id_va             t_number;
     l_elig_per_in_ler_stat_cd_va    t_varchar2_30;
     l_elig_lf_evt_ocrd_dt_va        t_date ;
     l_elig_ntfn_dt_va               t_date ;
     l_elig_pl_seq_num_va            t_number ;
     l_elig_plip_seq_num_va          t_number ;
     l_elig_ptip_seq_num_va          t_number ;
     l_elig_oipl_seq_num_va          t_number ;
     l_elig_pl_id_va                 t_number ;
     l_elig_flex_01_va               t_varchar2_600;
     l_elig_flex_02_va               t_varchar2_600;
     l_elig_flex_03_va               t_varchar2_600;
     l_elig_flex_04_va               t_varchar2_600;
     l_elig_flex_05_va               t_varchar2_600;
     l_elig_flex_06_va               t_varchar2_600;
     l_elig_flex_07_va               t_varchar2_600;
     l_elig_flex_08_va               t_varchar2_600;
     l_elig_flex_09_va               t_varchar2_600;
     l_elig_flex_10_va               t_varchar2_600;
     l_elig_per_elctbl_chc_id_va     t_number ;
     l_elig_enrt_cvg_strt_dt_va      t_date ;
     l_elig_yr_perd_id_va            t_number ;
     l_elig_pl_typ_id_va             t_number ;
     l_elig_plip_id_va               t_number ;
     l_elig_ptip_id_va               t_number ;
     l_elig_last_update_date_va      t_date ;
     l_elig_per_in_ler_id_va         t_number ;
     l_elig_prtt_enrt_rslt_id_va     t_number ;
     l_elig_program_id_va            t_number ;
     l_elig_oipl_id_va               t_number ;
     l_elig_enrt_strt_dt_va          t_date ;
     l_elig_enrt_end_dt_va           t_date ;
     l_elig_dflt_enrt_dt_va          t_date ;
     l_elig_uom_va                   t_varchar2_30;
     l_elig_elcn_made_dt_va          t_date ;
     l_elig_cvg_amt_va               t_number ;
     l_elig_mn_val_va                t_number ;
     l_elig_mx_val_va                t_number ;
     l_elig_dflt_val_va              t_number ;
     l_elig_incrmt_val_va            t_number ;
     l_elig_enrt_bnft_id_va          t_number ;
     l_elig_echc_dflt_flag_va        t_varchar2_30 ;
     l_elig_dflt_flag_va             t_varchar2_30 ;
     l_elig_nnmntry_uom_va           t_varchar2_30 ;
     l_elig_bnft_typ_cd_va           t_varchar2_30 ;
     l_elig_entr_val_at_flag_va      t_varchar2_30 ;
     l_elig_cvg_mlt_cd_va            t_varchar2_30 ;
     l_elig_ordr_num_va              t_number ;


    ---

   -- splited main cursor extract data from transaction
    cursor c_elig(p_person_id number) is
    select   /*+ FIRST_ROWS(1) BEN_EXT_ELIG.main.c_elig */
           pler.ler_id                  ler_id,
           pler.person_id               person_id,
           pler.per_in_ler_stat_cd      per_in_ler_stat_cd,
           pler.lf_evt_ocrd_dt          lf_evt_ocrd_dt,
           pler.ntfn_dt                 ntfn_dt,
           echc.pl_ordr_num             pl_seq_num,
           echc.plip_ordr_num           plip_seq_num,
           echc.ptip_ordr_num           ptip_seq_num,
           echc.oipl_ordr_num           oipl_seq_num,
           echc.pl_id                   pl_id,
           echc.epe_attribute1          flex_01,
           echc.epe_attribute2          flex_02,
           echc.epe_attribute3          flex_03,
           echc.epe_attribute4          flex_04,
           echc.epe_attribute5          flex_05,
           echc.epe_attribute6          flex_06,
           echc.epe_attribute7          flex_07,
           echc.epe_attribute8          flex_08,
           echc.epe_attribute9          flex_09,
           echc.epe_attribute10         flex_10,
           echc.elig_per_elctbl_chc_id  elig_per_elctbl_chc_id,
           echc.enrt_cvg_strt_dt        enrt_cvg_strt_dt,
           echc.yr_perd_id              yr_perd_id,
           echc.pl_typ_id               pl_typ_id,
           echc.plip_id                 plip_id,
           echc.ptip_id                 ptip_id,
           echc.last_update_date        last_update_date,
           echc.per_in_ler_id           per_in_ler_id,
           echc.prtt_enrt_rslt_id       prtt_enrt_rslt_id,
           echc.pgm_id                  program_id,
           echc.oipl_id                 ,
           ppopl.enrt_perd_strt_dt      enrt_strt_dt,
           ppopl.enrt_perd_end_dt       enrt_end_dt,
           ppopl.dflt_enrt_dt           dflt_enrt_dt,
           ppopl.uom                    uom,
           ppopl.elcns_made_dt          elcn_made_dt,
           enb.val                      cvg_amt,
           enb.mn_val                   mn_val,
           enb.mx_val                   mx_val,
           enb.dflt_val                 dflt_val,
           enb.incrmt_val               incrmt_val,
           --decode(enb.enrt_bnft_id , null,echc.dflt_flag, enb.dflt_flag)   dflt_flag,/* bug 5292 */
           enb.enrt_bnft_id             enrt_bnft_id,
           echc.dflt_flag               echc_dflt_flag ,
           enb.dflt_flag                dflt_flag,
           enb.nnmntry_uom              nnmntry_uom,
           enb.bnft_typ_cd              bnft_typ_cd,
           enb.entr_val_at_enrt_flag    entr_val_at_enrt_flag,
           enb.cvg_mlt_cd               cvg_mlt_cd,
           enb.ordr_num                 ordr_num
    from   ben_per_in_ler          pler,
           ben_elig_per_elctbl_chc echc,
           ben_pil_elctbl_chc_popl ppopl,
           ben_enrt_bnft           enb
    where  pler.person_id = p_person_id
    and    pler.per_in_ler_id = echc.per_in_ler_id
    and    echc.pil_elctbl_chc_popl_id = ppopl.pil_elctbl_chc_popl_id
    and    echc.elctbl_flag = 'Y'
    and    echc.elig_per_elctbl_chc_id = enb.elig_per_elctbl_chc_id(+)
    ;



  cursor c_oipl (p_oipl_id number
               , p_effective_date date) is
  select   oipl.opt_id                  opt_id,
           oipl.short_name              oipl_fd_name,
           oipl.short_code              oipl_fd_code,
           oipl.ordr_num                opt_ord_no,
           oipl.cop_attribute1          oipl_flex_01,
           oipl.cop_attribute2          oipl_flex_02,
           oipl.cop_attribute3          oipl_flex_03,
           oipl.cop_attribute4          oipl_flex_04,
           oipl.cop_attribute5          oipl_flex_05,
           oipl.cop_attribute6          oipl_flex_06,
           oipl.cop_attribute7          oipl_flex_07,
           oipl.cop_attribute8          oipl_flex_08,
           oipl.cop_attribute9          oipl_flex_09,
           oipl.cop_attribute10         oipl_flex_10
    from   ben_oipl_f oipl
   where  oipl_id = p_oipl_id
     and  p_effective_date
          between oipl.effective_start_date and   oipl.effective_end_date
   ;


   cursor c_pl (p_pl_id number ,
                p_effective_date date) is
   select  pl.name                      pl_name,
           pl.short_name                pl_fd_name,
           pl.short_code                pl_fd_code,
           pl.pln_attribute1            pl_flex_01,
           pl.pln_attribute2            pl_flex_02,
           pl.pln_attribute3            pl_flex_03,
           pl.pln_attribute4            pl_flex_04,
           pl.pln_attribute5            pl_flex_05,
           pl.pln_attribute6            pl_flex_06,
           pl.pln_attribute7            pl_flex_07,
           pl.pln_attribute8            pl_flex_08,
           pl.pln_attribute9            pl_flex_09,
           pl.pln_attribute10           pl_flex_10,
           pl.cobra_pymt_due_dy_num
   from ben_pl_f pl
   where pl.pl_id = p_pl_id
     and  p_effective_date
          between pl.effective_start_date and pl.effective_end_date
   ;


   cursor c_opt (p_opt_id number ,
                p_effective_date date) is
   select  opt.name                     opt_name,
           opt.short_name               opt_fd_name,
           opt.short_code               opt_fd_code,
           opt.opt_attribute1           opt_flex_01,
           opt.opt_attribute2           opt_flex_02,
           opt.opt_attribute3           opt_flex_03,
           opt.opt_attribute4           opt_flex_04,
           opt.opt_attribute5           opt_flex_05,
           opt.opt_attribute6           opt_flex_06,
           opt.opt_attribute7           opt_flex_07,
           opt.opt_attribute8           opt_flex_08,
           opt.opt_attribute9           opt_flex_09,
           opt.opt_attribute10          opt_flex_10
     from  ben_opt_f opt
    where  opt.opt_id = p_opt_id
      and  p_effective_date
          between opt.effective_start_date and opt.effective_end_date
   ;


   cursor c_pgm_info (p_pgm_id number ,
                p_effective_date date) is
   select  pgm.name          	    program_name,
           pgm.short_name           pgm_fd_name,
           pgm.short_code           pgm_fd_code,
           pgm.pgm_attribute1        pgm_flex_01,
           pgm.pgm_attribute2           pgm_flex_02,
           pgm.pgm_attribute3           pgm_flex_03,
           pgm.pgm_attribute4           pgm_flex_04,
           pgm.pgm_attribute5           pgm_flex_05,
           pgm.pgm_attribute6           pgm_flex_06,
           pgm.pgm_attribute7           pgm_flex_07,
           pgm.pgm_attribute8           pgm_flex_08,
           pgm.pgm_attribute9           pgm_flex_09,
           pgm.pgm_attribute10          pgm_flex_10
      from ben_pgm_f pgm
     where pgm.pgm_id = p_pgm_id
       and  p_effective_date
          between pgm.effective_start_date and pgm.effective_end_date
     ;


   cursor c_ptp (p_pl_typ_id number ,
                p_effective_date date) is
   select  ptp.name                     pl_type_name,
           ptp.short_name               ptp_fd_name,
           ptp.short_code               ptp_fd_code,
           ptp.ptp_attribute1           ptp_flex_01,
           ptp.ptp_attribute2           ptp_flex_02,
           ptp.ptp_attribute3           ptp_flex_03,
           ptp.ptp_attribute4           ptp_flex_04,
           ptp.ptp_attribute5           ptp_flex_05,
           ptp.ptp_attribute6           ptp_flex_06,
           ptp.ptp_attribute7           ptp_flex_07,
           ptp.ptp_attribute8           ptp_flex_08,
           ptp.ptp_attribute9           ptp_flex_09,
           ptp.ptp_attribute10          ptp_flex_10
     from ben_pl_typ_f ptp
    where p_pl_typ_id = ptp.pl_typ_id
      and p_effective_date
          between ptp.effective_start_date and ptp.effective_end_date
     ;




   cursor c_plip (p_plip_id number ,
                  p_effective_date date) is
   select  plip.short_name              plip_fd_name,
           plip.short_code              plip_fd_code,
           plip.ordr_num                pl_ord_no,
           plip.cpp_attribute1          plip_flex_01,
           plip.cpp_attribute2          plip_flex_02,
           plip.cpp_attribute3          plip_flex_03,
           plip.cpp_attribute4          plip_flex_04,
           plip.cpp_attribute5          plip_flex_05,
           plip.cpp_attribute6          plip_flex_06,
           plip.cpp_attribute7          plip_flex_07,
           plip.cpp_attribute8          plip_flex_08,
           plip.cpp_attribute9          plip_flex_09,
           plip.cpp_attribute10         plip_flex_10
     from  ben_plip_f plip
   where  p_plip_id   = plip.plip_id
      and  p_effective_date
          between plip.effective_start_date and plip.effective_end_date
      ;


   cursor c_ptip (p_ptip_id number ,
                  p_effective_date date) is
   select  ptip.short_name              ptip_fd_name,
           ptip.short_code              ptip_fd_code
     from  ben_ptip_f ptip
     where  p_ptip_id   = ptip.ptip_id
      and  p_effective_date
          between ptip.effective_start_date and ptip.effective_end_date
      ;




  --
  cursor c_pl_elig(l_pl_id number,l_ler_id number, l_person_id number) is
    select eper.pl_id,
           eper.age_val,
           eper.age_uom,
           eper.los_val,
           eper.los_uom,
           eper.comp_ref_amt,
           eper.comp_ref_uom,
           eper.cmbn_age_n_los_val,
           eper.hrs_wkd_val,
           eper.pct_fl_tm_val
    from   ben_elig_per_f eper
    where  eper.person_id = l_person_id
    and    eper.ler_id = l_ler_id
    and    eper.pl_id = l_pl_id
    and    eper.pgm_id is null
    and    p_effective_date
           between eper.effective_start_date
           and     eper.effective_end_date;
  --
  cursor c_pgm(l_pl_id number,l_ler_id number, l_person_id number) is
    select eper.pl_id,
           eper.age_val,
           eper.age_uom,
           eper.los_val,
           eper.los_uom,
           eper.comp_ref_amt,
           eper.comp_ref_uom,
           eper.cmbn_age_n_los_val,
           eper.hrs_wkd_val,
           eper.pct_fl_tm_val
    from   ben_elig_per_f eper
    where  eper.person_id = l_person_id
    and    eper.ler_id = l_ler_id
    and    eper.pl_id = l_pl_id
    and    eper.pgm_id is not null
    and    p_effective_date
           between eper.effective_start_date
           and     eper.effective_end_date;
  --
  cursor c_prem_tot(l_elig_per_elctbl_chc_id number) is
    select sum(epr.val),
           epr.uom
    from   ben_enrt_prem epr
    where  epr.elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
    group  by epr.uom;
  --
  cursor c_rpt_grp(l_elig_per_elctbl_chc_id number) is
    select grp.rptg_grp_id,
           grp.name
    from   ben_elig_per_elctbl_chc     chc,
           ben_popl_rptg_grp_f         prpg,
           ben_rptg_grp                grp
    where  chc.elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
    and    chc.pl_id = prpg.pl_id
    and    prpg.rptg_grp_id = grp.rptg_grp_id;
  --
  cursor c_pl_yr(l_elig_per_elctbl_chc_id number) is
    select yrpr.start_date,
           yrpr.end_date
    from   ben_elig_per_elctbl_chc     chc,
           ben_yr_perd                 yrpr
    where  chc.elig_per_elctbl_chc_id = l_elig_per_elctbl_chc_id
    and    chc.yr_perd_id = yrpr.yr_perd_id;
  --
  cursor c_ler (cp_per_in_ler_id number)  is
    select ler.ler_id
          ,ler.name
          ,pler.per_in_ler_stat_cd
          ,pler.ntfn_dt
          ,pler.lf_evt_ocrd_dt
    from   ben_per_in_ler pler
          ,ben_ler_f ler
    where  pler.person_id = p_person_id
    and    pler.per_in_ler_id = cp_per_in_ler_id
    and    pler.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date;
  --
  l_pl_id    ben_pl_f.pl_id%type;
  --

  -- for cobra aetter
  cursor c_cbradm_pl (p_pl_id number) is
  select cpr.name  admin_name,
         cpo.organization_id
  from  ben_popl_org_role_f cpr,
        ben_popl_org_f cpo
  where
      cpo.pl_id = p_pl_id
  AND cpr.popl_org_id = cpo.popl_org_id
  and cpr.org_role_typ_cd = 'ADM'
  and p_effective_date between cpr.effective_Start_date
      and  cpr.effective_end_date
  and p_effective_date between cpo.effective_Start_date
      and  cpo.effective_end_date  ;

  cursor c_cbradm_pgm (p_pgm_id number) is
  select cpr.name  admin_name,
         cpo.organization_id
  from  ben_popl_org_role_f cpr,
        ben_popl_org_f cpo
  where
      cpo.pgm_id = p_pgm_id
  AND cpr.popl_org_id = cpo.popl_org_id
  and cpr.org_role_typ_cd = 'ADM'
  and p_effective_date between cpr.effective_Start_date
      and  cpr.effective_end_date
  and p_effective_date between cpo.effective_Start_date
      and  cpo.effective_end_date ;


  cursor c_cbradm_adr(p_organization_id number) is
  select org.name  admin_org_name,
         loc.address_line_1 loc_addr1,
         loc.address_line_2 loc_addr2,
         loc.address_line_3 loc_addr3,
         loc.town_or_city   loc_city,
         loc.region_2       loc_state,
         loc.postal_code    loc_zip,
         loc.country        loc_country,
         loc.telephone_number_1 loc_phone
  from hr_all_organization_units org
       ,hr_locations loc
  where p_organization_id = org.organization_id
    AND org.location_id = loc.location_id ;

  l_organization_id   number;


Begin
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
  init_detl_globals;
  --
  ---FOR elig IN c_elig(p_person_id) LOOP
  --- the loop changed into an bulk collect

   open c_elig(p_person_id) ;
   fetch c_elig bulk collect into
     l_elig_ler_id_va                   ,
     l_elig_person_id_va                ,
     l_elig_per_in_ler_stat_cd_va       ,
     l_elig_lf_evt_ocrd_dt_va           ,
     l_elig_ntfn_dt_va                  ,
     l_elig_pl_seq_num_va               ,
     l_elig_plip_seq_num_va             ,
     l_elig_ptip_seq_num_va             ,
     l_elig_oipl_seq_num_va             ,
     l_elig_pl_id_va                    ,
     l_elig_flex_01_va                  ,
     l_elig_flex_02_va                  ,
     l_elig_flex_03_va                  ,
     l_elig_flex_04_va                  ,
     l_elig_flex_05_va                  ,
     l_elig_flex_06_va                  ,
     l_elig_flex_07_va                  ,
     l_elig_flex_08_va                  ,
     l_elig_flex_09_va                  ,
     l_elig_flex_10_va                  ,
     l_elig_per_elctbl_chc_id_va   ,
     l_elig_enrt_cvg_strt_dt_va         ,
     l_elig_yr_perd_id_va               ,
     l_elig_pl_typ_id_va                ,
     l_elig_plip_id_va                  ,
     l_elig_ptip_id_va                  ,
     l_elig_last_update_date_va         ,
     l_elig_per_in_ler_id_va            ,
     l_elig_prtt_enrt_rslt_id_va        ,
     l_elig_program_id_va               ,
     l_elig_oipl_id_va                  ,
     l_elig_enrt_strt_dt_va             ,
     l_elig_enrt_end_dt_va              ,
     l_elig_dflt_enrt_dt_va             ,
     l_elig_uom_va                      ,
     l_elig_elcn_made_dt_va             ,
     l_elig_cvg_amt_va                  ,
     l_elig_mn_val_va                   ,
     l_elig_mx_val_va                   ,
     l_elig_dflt_val_va                 ,
     l_elig_incrmt_val_va               ,
     l_elig_enrt_bnft_id_va             ,
     l_elig_echc_dflt_flag_va           ,
     l_elig_dflt_flag_va                ,
     l_elig_nnmntry_uom_va              ,
     l_elig_bnft_typ_cd_va              ,
     l_elig_entr_val_at_flag_va    ,
     l_elig_cvg_mlt_cd_va               ,
     l_elig_ordr_num_va                 ;

  close c_elig ;

  for i  IN  1  .. l_elig_per_elctbl_chc_id_va.count
  Loop


    -- determine the  default flag. The decode was removed from sql
    --decode(enb.enrt_bnft_id , null,echc.dflt_flag, enb.dflt_flag)   dflt_flag,
    -- by default the variable holds enb.dflt_flag value

    if l_elig_enrt_bnft_id_va(i) is null then
       l_elig_dflt_flag_va(i) := l_elig_echc_dflt_flag_va(i) ;
    end if ;

    --
    l_include := 'Y';

    -- we need to get option id for inclusion validation
    -- fusion try to cache the plan setup information
    -- intialize the variable
    ben_ext_person.g_elig_opt_id             := null ;
    ben_ext_person.g_elig_opt_pl_fd_name     := null ;
    ben_ext_person.g_elig_opt_pl_fd_code     := null ;
    ben_ext_person.g_elig_opt_ord_no         := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_01  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_02  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_03  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_04  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_05  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_06  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_07  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_08  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_09  := null ;
    ben_ext_person.g_elig_opt_in_pl_flex_10  := null ;

    if  l_elig_oipl_id_va(i) is not null then
        open c_oipl(l_elig_oipl_id_va(i), p_effective_date) ;
        fetch c_oipl into
               ben_ext_person.g_elig_opt_id      ,
               ben_ext_person.g_elig_opt_pl_fd_name ,
               ben_ext_person.g_elig_opt_pl_fd_code ,
               ben_ext_person.g_elig_opt_ord_no ,
               ben_ext_person.g_elig_opt_in_pl_flex_01,
               ben_ext_person.g_elig_opt_in_pl_flex_02,
               ben_ext_person.g_elig_opt_in_pl_flex_03,
               ben_ext_person.g_elig_opt_in_pl_flex_04,
               ben_ext_person.g_elig_opt_in_pl_flex_05,
               ben_ext_person.g_elig_opt_in_pl_flex_06,
               ben_ext_person.g_elig_opt_in_pl_flex_07,
               ben_ext_person.g_elig_opt_in_pl_flex_08,
               ben_ext_person.g_elig_opt_in_pl_flex_09,
               ben_ext_person.g_elig_opt_in_pl_flex_10
         ;
        close c_oipl ;
    end if ;


    --
    ben_ext_evaluate_inclusion.evaluate_eligibility_incl
                    (p_elct_pl_id              => l_elig_pl_id_va(i),
                     p_elct_enrt_strt_dt       => l_elig_enrt_cvg_strt_dt_va(i),
                     p_elct_yrprd_id           => l_elig_yr_perd_id_va(i),
                     p_elct_pgm_id             => l_elig_program_id_va(i),
                     p_elct_pl_typ_id          => l_elig_pl_typ_id_va(i),
                     p_elct_opt_id             => ben_ext_person.g_elig_opt_id ,
                     p_elct_last_upd_dt        => l_elig_last_update_date_va(i),
                     p_elct_per_in_ler_id      => l_elig_per_in_ler_id_va(i),
                     p_elct_ler_id             => l_elig_ler_id_va(i),
                     p_elct_per_in_ler_stat_cd => l_elig_per_in_ler_stat_cd_va(i),
                     p_elct_lf_evt_ocrd_dt     => l_elig_lf_evt_ocrd_dt_va(i),
                     p_elct_ntfn_dt            => l_elig_ntfn_dt_va(i),
                     p_prtt_enrt_rslt_id       => l_elig_prtt_enrt_rslt_id_va(i),
                     p_effective_date          => p_effective_date,
                     p_include => l_include
                     );
    --
    IF l_include = 'Y' THEN
      -- assign eligibility info to global variables
      --
      --- get plan setup information
      ben_ext_person.g_elig_pl_name      := null ;
      ben_ext_person.g_elig_pl_fd_name   := null ;
      ben_ext_person.g_elig_pl_fd_code   := null ;
      ben_ext_person.g_elig_plan_flex_01 := null ;
      ben_ext_person.g_elig_plan_flex_02 := null ;
      ben_ext_person.g_elig_plan_flex_03 := null ;
      ben_ext_person.g_elig_plan_flex_04 := null ;
      ben_ext_person.g_elig_plan_flex_05 := null ;
      ben_ext_person.g_elig_plan_flex_06 := null ;
      ben_ext_person.g_elig_plan_flex_07 := null ;
      ben_ext_person.g_elig_plan_flex_08 := null ;
      ben_ext_person.g_elig_plan_flex_09 := null ;
      ben_ext_person.g_elig_plan_flex_10 := null ;
      ben_ext_person.g_elig_cobra_payment_dys := null ;


      if l_elig_pl_id_va(i) is not null then
         open c_pl(l_elig_pl_id_va(i),p_effective_date) ;
         fetch c_pl into
              ben_ext_person.g_elig_pl_name     ,
              ben_ext_person.g_elig_pl_fd_name  ,
              ben_ext_person.g_elig_pl_fd_code  ,
              ben_ext_person.g_elig_plan_flex_01,
              ben_ext_person.g_elig_plan_flex_02,
              ben_ext_person.g_elig_plan_flex_03,
              ben_ext_person.g_elig_plan_flex_04,
              ben_ext_person.g_elig_plan_flex_05,
              ben_ext_person.g_elig_plan_flex_06,
              ben_ext_person.g_elig_plan_flex_07,
              ben_ext_person.g_elig_plan_flex_08,
              ben_ext_person.g_elig_plan_flex_09,
              ben_ext_person.g_elig_plan_flex_10,
              ben_ext_person.g_elig_cobra_payment_dys
              ;
         close c_pl ;
      end if ;

      ben_ext_person.g_elig_opt_name               := null;
      ben_ext_person.g_elig_opt_fd_name            := null;
      ben_ext_person.g_elig_opt_fd_code            := null;
      ben_ext_person.g_elig_opt_flex_01            := null;
      ben_ext_person.g_elig_opt_flex_02            := null;
      ben_ext_person.g_elig_opt_flex_03            := null;
      ben_ext_person.g_elig_opt_flex_04            := null;
      ben_ext_person.g_elig_opt_flex_05            := null;
      ben_ext_person.g_elig_opt_flex_06            := null;
      ben_ext_person.g_elig_opt_flex_07            := null;
      ben_ext_person.g_elig_opt_flex_08            := null;
      ben_ext_person.g_elig_opt_flex_09            := null;
      ben_ext_person.g_elig_opt_flex_10            := null;

      if ben_ext_person.g_elig_opt_id is not null then
         open c_opt (ben_ext_person.g_elig_opt_id,p_effective_date) ;
         fetch c_opt into
               ben_ext_person.g_elig_opt_name      ,
               ben_ext_person.g_elig_opt_fd_name   ,
               ben_ext_person.g_elig_opt_fd_code   ,
               ben_ext_person.g_elig_opt_flex_01   ,
               ben_ext_person.g_elig_opt_flex_02   ,
               ben_ext_person.g_elig_opt_flex_03   ,
               ben_ext_person.g_elig_opt_flex_04   ,
               ben_ext_person.g_elig_opt_flex_05   ,
               ben_ext_person.g_elig_opt_flex_06   ,
               ben_ext_person.g_elig_opt_flex_07   ,
               ben_ext_person.g_elig_opt_flex_08   ,
               ben_ext_person.g_elig_opt_flex_09   ,
               ben_ext_person.g_elig_opt_flex_10
               ;
        close c_opt ;
      end if ;

      ben_ext_person.g_elig_program_name           := null ;
      ben_ext_person.g_elig_pgm_fd_name            := null ;
      ben_ext_person.g_elig_pgm_fd_code            := null ;
      ben_ext_person.g_elig_pgm_flex_01            := null ;
      ben_ext_person.g_elig_pgm_flex_02            := null ;
      ben_ext_person.g_elig_pgm_flex_03            := null ;
      ben_ext_person.g_elig_pgm_flex_04            := null ;
      ben_ext_person.g_elig_pgm_flex_05            := null ;
      ben_ext_person.g_elig_pgm_flex_06            := null ;
      ben_ext_person.g_elig_pgm_flex_07            := null ;
      ben_ext_person.g_elig_pgm_flex_08            := null ;
      ben_ext_person.g_elig_pgm_flex_09            := null ;
      ben_ext_person.g_elig_pgm_flex_10            := null ;


      if l_elig_program_id_va(i) is not null then
         open c_pgm_info (l_elig_program_id_va(i),p_effective_date) ;
         fetch c_pgm_info into
               ben_ext_person.g_elig_program_name  ,
               ben_ext_person.g_elig_pgm_fd_name   ,
               ben_ext_person.g_elig_pgm_fd_code   ,
               ben_ext_person.g_elig_pgm_flex_01   ,
               ben_ext_person.g_elig_pgm_flex_02   ,
               ben_ext_person.g_elig_pgm_flex_03   ,
               ben_ext_person.g_elig_pgm_flex_04   ,
               ben_ext_person.g_elig_pgm_flex_05   ,
               ben_ext_person.g_elig_pgm_flex_06   ,
               ben_ext_person.g_elig_pgm_flex_07   ,
               ben_ext_person.g_elig_pgm_flex_08   ,
               ben_ext_person.g_elig_pgm_flex_09   ,
               ben_ext_person.g_elig_pgm_flex_10
               ;
          close c_pgm_info ;
      end if ;

      ben_ext_person.g_elig_pl_typ_name       := null ;
      ben_ext_person.g_elig_pl_typ_fd_name    := null ;
      ben_ext_person.g_elig_pl_typ_fd_code    := null ;
      ben_ext_person.g_elig_ptp_flex_01       := null ;
      ben_ext_person.g_elig_ptp_flex_02       := null ;
      ben_ext_person.g_elig_ptp_flex_03       := null ;
      ben_ext_person.g_elig_ptp_flex_04       := null ;
      ben_ext_person.g_elig_ptp_flex_05       := null ;
      ben_ext_person.g_elig_ptp_flex_06       := null ;
      ben_ext_person.g_elig_ptp_flex_07       := null ;
      ben_ext_person.g_elig_ptp_flex_08       := null ;
      ben_ext_person.g_elig_ptp_flex_09       := null ;
      ben_ext_person.g_elig_ptp_flex_10       := null ;


      if l_elig_pl_typ_id_va(i) is not null then
         open c_ptp (l_elig_pl_typ_id_va(i),p_effective_date) ;
         fetch c_ptp into
              ben_ext_person.g_elig_pl_typ_name     ,
              ben_ext_person.g_elig_pl_typ_fd_name  ,
              ben_ext_person.g_elig_pl_typ_fd_code  ,
              ben_ext_person.g_elig_ptp_flex_01     ,
              ben_ext_person.g_elig_ptp_flex_02     ,
              ben_ext_person.g_elig_ptp_flex_03     ,
              ben_ext_person.g_elig_ptp_flex_04     ,
              ben_ext_person.g_elig_ptp_flex_05     ,
              ben_ext_person.g_elig_ptp_flex_06     ,
              ben_ext_person.g_elig_ptp_flex_07     ,
              ben_ext_person.g_elig_ptp_flex_08     ,
              ben_ext_person.g_elig_ptp_flex_09     ,
              ben_ext_person.g_elig_ptp_flex_10
              ;
         close c_ptp ;
      end if ;

      ben_ext_person.g_elig_pl_pgm_fd_name         := null ;
      ben_ext_person.g_elig_pl_pgm_fd_code         := null ;
      ben_ext_person.g_elig_pl_ord_no              := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_01      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_02      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_03      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_04      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_05      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_06      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_07      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_08      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_09      := null ;
      ben_ext_person.g_elig_pl_in_pgm_flex_10      := null ;



      if l_elig_plip_id_va(i) is not null then
         open c_plip (l_elig_plip_id_va(i),p_effective_date) ;
         fetch c_plip into
               ben_ext_person.g_elig_pl_pgm_fd_name    ,
               ben_ext_person.g_elig_pl_pgm_fd_code    ,
               ben_ext_person.g_elig_pl_ord_no         ,
               ben_ext_person.g_elig_pl_in_pgm_flex_01 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_02 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_03 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_04 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_05 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_06 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_07 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_08 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_09 ,
               ben_ext_person.g_elig_pl_in_pgm_flex_10
            ;

         close c_plip ;
      end if ;



      ben_ext_person.g_elig_pl_typ_pgm_fd_name     := null ;
      ben_ext_person.g_elig_pl_typ_pgm_fd_code     := null ;

      if l_elig_ptip_id_va(i) is not null then
         open c_ptip (l_elig_ptip_id_va(i),p_effective_date) ;
         fetch c_ptip into
             ben_ext_person.g_elig_pl_typ_pgm_fd_name ,
             ben_ext_person.g_elig_pl_typ_pgm_fd_code
             ;
         close c_ptip ;
      end if ;



      ben_ext_person.g_elig_per_elctbl_chc_id      := l_elig_per_elctbl_chc_id_va(i);
      ben_ext_person.g_elig_cvg_amt                := l_elig_cvg_amt_va(i);
      ben_ext_person.g_elig_cvg_min_amt            := l_elig_mn_val_va(i);
      ben_ext_person.g_elig_cvg_max_amt            := l_elig_mx_val_va(i);
      ben_ext_person.g_elig_cvg_inc_amt            := l_elig_incrmt_val_va(i);
      ben_ext_person.g_elig_cvg_dfl_amt            := l_elig_dflt_val_va(i);
      ben_ext_person.g_elig_cvg_dfl_flg            := l_elig_dflt_flag_va(i);
      ben_ext_person.g_elig_cvg_seq_no             := l_elig_ordr_num_va(i);
      ben_ext_person.g_elig_cvg_onl_flg            := l_elig_entr_val_at_flag_va(i);
      ben_ext_person.g_elig_cvg_calc_mthd          := l_elig_cvg_mlt_cd_va(i);
      ben_ext_person.g_elig_cvg_bnft_typ           := l_elig_bnft_typ_cd_va(i);
      ben_ext_person.g_elig_cvg_bnft_uom           := l_elig_nnmntry_uom_va(i);
      ben_ext_person.g_elig_enrt_strt_dt           := l_elig_enrt_strt_dt_va(i);
      ben_ext_person.g_elig_enrt_end_dt            := l_elig_enrt_end_dt_va(i);
      ben_ext_person.g_elig_dflt_enrt_dt           := l_elig_dflt_enrt_dt_va(i);
      ben_ext_person.g_elig_uom                    := l_elig_uom_va(i);
      ben_ext_person.g_elig_pl_id                  := l_elig_pl_id_va(i);
      ben_ext_person.g_elig_pl_typ_id              := l_elig_pl_typ_id_va(i);
      ben_ext_person.g_elig_elec_made_dt           := l_elig_elcn_made_dt_va(i);
      ben_ext_person.g_elig_program_id             := l_elig_program_id_va(i);
      ben_ext_person.g_elig_pl_seq_num             := l_elig_pl_seq_num_va(i);
      ben_ext_person.g_elig_pip_seq_num     	   := l_elig_plip_seq_num_va(i);
      ben_ext_person.g_elig_ptp_seq_num     	   := l_elig_ptip_seq_num_va(i);
      ben_ext_person.g_elig_oip_seq_num            := l_elig_oipl_seq_num_va(i);
      ben_ext_person.g_elig_flex_01                := l_elig_flex_01_va(i);
      ben_ext_person.g_elig_flex_02                := l_elig_flex_02_va(i);
      ben_ext_person.g_elig_flex_03                := l_elig_flex_03_va(i);
      ben_ext_person.g_elig_flex_04                := l_elig_flex_04_va(i);
      ben_ext_person.g_elig_flex_05                := l_elig_flex_05_va(i);
      ben_ext_person.g_elig_flex_06                := l_elig_flex_06_va(i);
      ben_ext_person.g_elig_flex_07                := l_elig_flex_07_va(i);
      ben_ext_person.g_elig_flex_08                := l_elig_flex_08_va(i);
      ben_ext_person.g_elig_flex_09                := l_elig_flex_09_va(i);
      ben_ext_person.g_elig_flex_10                := l_elig_flex_10_va(i);
      --
      --
      init_detl_drvd_fctr_globals;
      --
      open c_pl_elig(l_elig_pl_id_va(i) ,l_elig_ler_id_va(i) ,l_elig_person_id_va(i));
        --
        fetch c_pl_elig into l_pl_id,
                             ben_ext_person.g_elig_age_val,
                             ben_ext_person.g_elig_age_uom,
                             ben_ext_person.g_elig_los_val,
                             ben_ext_person.g_elig_los_uom,
                             ben_ext_person.g_elig_comp_amt,
                             ben_ext_person.g_elig_comp_amt_uom,
                             ben_ext_person.g_elig_cmbn_age_n_los,
                             ben_ext_person.g_elig_hrs_wkd,
                             ben_ext_person.g_elig_pct_fl_tm;
        --
        if c_pl_elig%notfound then
          --
          open c_pgm(l_elig_pl_id_va(i) ,l_elig_ler_id_va(i) ,l_elig_person_id_va(i));
            --
            fetch c_pgm into l_pl_id,
                             ben_ext_person.g_elig_age_val,
                             ben_ext_person.g_elig_age_uom,
                             ben_ext_person.g_elig_los_val,
                             ben_ext_person.g_elig_los_uom ,
                             ben_ext_person.g_elig_comp_amt,
                             ben_ext_person.g_elig_comp_amt_uom,
                             ben_ext_person.g_elig_cmbn_age_n_los,
                             ben_ext_person.g_elig_hrs_wkd,
                             ben_ext_person.g_elig_pct_fl_tm;
            --
          close c_pgm;
          --
        end if;
        --
      close c_pl_elig;
      --
      -- Addition rate informations
      --
      if ben_extract.g_chcrt_csr = 'Y' then
        --
        get_rt_info( p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id_va(i));
        --
      end if;
      --
      -- Premium informations
      --

      if ben_extract.g_eprem_csr = 'Y' then
        --
        open c_prem_tot(l_elig_per_elctbl_chc_id_va(i));
          --
          fetch c_prem_tot into ben_ext_person.g_elig_total_premium_amt
                              , ben_ext_person.g_elig_total_premium_uom;
          --
        close c_prem_tot;
        --
      end if;
      --
      --
      -- Reporting group informations
      --
      if ben_extract.g_ergrp_csr = 'Y' then
        --
        open c_rpt_grp(l_elig_per_elctbl_chc_id_va(i));
          --
          fetch c_rpt_grp into ben_ext_person.g_elig_rpt_group_id,
                               ben_ext_person.g_elig_rpt_group_name;
          --
        close c_rpt_grp;
        --
      end if;
      --
      --
      -- Plan Year informations
      --
      if ben_extract.g_eplyr_csr = 'Y' then
        --
        open c_pl_yr(l_elig_per_elctbl_chc_id_va(i));
          --
          fetch c_pl_yr into ben_ext_person.g_elig_pl_yr_strdt,
                             ben_ext_person.g_elig_pl_yr_enddt;
          --
        close c_pl_yr;
        --
      end if;
      --
      -- Life Event informations
      --
      if ben_extract.g_eler_csr = 'Y' then
        --
        open c_ler(l_elig_per_in_ler_id_va(i)) ;
          --
          fetch c_ler  into ben_ext_person.g_elig_ler_id,
                           ben_ext_person.g_elig_lfevt_name,
                           ben_ext_person.g_elig_lfevt_status,
                           ben_ext_person.g_elig_lfevt_note_dt,
                           ben_ext_person.g_elig_lfevt_ocrd_dt;
          --
        close c_ler;
        --
      end if;

      --
       -- cobra admin information
       hr_utility.set_location(' cobra  cursor   ' || ben_Extract.g_cbradm_csr  ,160);
       if ben_Extract.g_cbradm_csr = 'Y'  then

           hr_utility.set_location('getting  cobra  admin  ' ,160);
             open c_cbradm_pl(l_elig_pl_id_va(i));
             fetch c_cbradm_pl into ben_ext_person.g_elig_cobra_admin_name ,
                                       l_organization_id  ;
             if  c_cbradm_pl%notfound then
                 open c_cbradm_pgm(l_elig_program_id_va(i));
                 fetch c_cbradm_pgm into ben_ext_person.g_elig_cobra_admin_name ,
                                            l_organization_id  ;
                 close c_cbradm_pgm ;
             end if ;
             close  c_cbradm_pl ;
              hr_utility.set_location(' cobra  admin  ' || ben_ext_person.g_elig_cobra_admin_name  ,160);
             --- cobra admin address
             if l_organization_id is not null then

                hr_utility.set_location('getting  cobra  admin  address ' ,160);
                open  c_cbradm_adr(l_organization_id ) ;
                fetch c_cbradm_adr into
                      ben_ext_person.g_elig_cobra_admin_org_name
                     ,ben_ext_person.g_elig_cobra_admin_addr1
                     ,ben_ext_person.g_elig_cobra_admin_addr2
                     ,ben_ext_person.g_elig_cobra_admin_addr3
                     ,ben_ext_person.g_elig_cobra_admin_city
                     ,ben_ext_person.g_elig_cobra_admin_state
                     ,ben_ext_person.g_elig_cobra_admin_zip
                     ,ben_ext_person.g_elig_cobra_admin_country
                     ,ben_ext_person.g_elig_cobra_admin_phone;
                close c_cbradm_adr ;
                hr_utility.set_location(' cobra org admin  ' || ben_ext_person.g_elig_cobra_admin_org_name  ,160);
                hr_utility.set_location(' cobra org city  ' || ben_ext_person.g_elig_cobra_admin_city  ,160);
             end if ;
          end if ;
          -- cobra end

      -- format and write
      --
      ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                   p_ext_file_id       => p_ext_file_id,
                                   p_data_typ_cd       => p_data_typ_cd,
                                   p_ext_typ_cd        => p_ext_typ_cd,
                                   p_rcd_typ_cd        => 'D',  --detail
                                   p_low_lvl_cd        => 'G',  --eligibility?
                                   p_person_id         => p_person_id,
                                   p_chg_evt_cd        => null,
                                   p_business_group_id => p_business_group_id,
                                   p_effective_date    => p_effective_date);
      --
      -- Call Eligible Dependents routine
      --
      if ben_extract.g_eligdpnt_lvl = 'Y' then
        --
        ben_ext_elig_dpnt.main
          (p_person_id              => p_person_id,
           p_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id_va(i),
           p_ext_rslt_id            => p_ext_rslt_id,
           p_ext_file_id            => p_ext_file_id,
           p_data_typ_cd            => p_data_typ_cd,
           p_ext_typ_cd             => p_ext_typ_cd,
           p_chg_evt_cd             => p_chg_evt_cd,
           p_business_group_id      => p_business_group_id,
           p_effective_date         => p_effective_date);
        --
      end if;
      --
    END IF;
    --
  END LOOP;
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
END;
END;

/
