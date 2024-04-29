--------------------------------------------------------
--  DDL for Package Body BEN_BIS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BIS_UTILS" as
/* $Header: benbisut.pkb 120.0 2005/05/28 03:43:35 appldev noship $ */
/* ===========================================================================
 * Name:
 *   Batch_utils
 * Purpose:
 *   This package is provide all batch utility and data structure to simply
 *   batch process.
 * History:
 *   Date        Who       Version  What?
 *   ----------- --------- -------  -----------------------------------------
 *   25-Sep-2003 vsethi     115.0    Created.
 *   13-May-2004 hmani      115.1    Added three functions
 *                                   get_group_pl_name, get_group_opt_name
 *                                   get_group_oipl_name
 * ===========================================================================
*/
--
-- Global variables declaration.
--

--
-- ============================================================================
--                          <<Function: get_pl_name>>
-- ============================================================================
--
Function get_pl_name(p_pl_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select name
  from 	 ben_pl_f pl
  where  pl_id = p_pl_id
  and    business_group_id = p_business_group_id
  and 	 p_effective_date between effective_start_date and effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_pl_name;
--
-- ============================================================================
--                          <<Function: get_group_pl_name>>
-- ============================================================================
--
Function get_group_pl_name(p_pl_id              in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select name
  from 	 ben_pl_f pl
  where  pl_id = p_pl_id
  and 	 p_effective_date between effective_start_date and effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_group_pl_name;

--
-- ============================================================================
--                          <<Function: get_pgm_name>>
-- ============================================================================
--
Function get_pgm_name(p_pgm_id            in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select name
  from 	 ben_pgm_f pgm
  where  pgm_id = p_pgm_id
  and    business_group_id = p_business_group_id
  and 	 p_effective_date between effective_start_date and effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_pgm_name;
--
-- ============================================================================
--                          <<Function: get_opt_name>>
-- ============================================================================
--
Function get_opt_name(p_opt_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select name
  from 	 ben_opt_f
  where  opt_id = p_opt_id
  and    business_group_id = p_business_group_id
  and 	 p_effective_date between effective_start_date and effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_opt_name;

--
--
-- ============================================================================
--                          <<Function: get_group_opt_name>>
-- ============================================================================
--
Function get_group_opt_name(p_opt_id              in number
                          ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select name
  from 	 ben_opt_f
  where  opt_id = p_opt_id
  and 	 p_effective_date between effective_start_date and effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_group_opt_name;

--
-- ============================================================================
--                          <<Function: get_plip_name>>
-- ============================================================================
--
Function get_plip_name(p_plip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select pgm.name|| ' - '|| pln.name
  from 	 ben_pl_f pln,
  	 ben_pgm_f pgm,
  	 ben_plip_f plip
  where  plip.plip_id = p_plip_id
  and    pgm.pgm_id   = plip.pgm_id
  and    pln.pl_id    = plip.pl_id
  and    plip.business_group_id = p_business_group_id
  and 	 p_effective_date between plip.effective_start_date and plip.effective_end_date
  and 	 p_effective_date between pln.effective_start_date and pln.effective_end_date
  and 	 p_effective_date between pgm.effective_start_date and pgm.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_plip_name;

--
-- ============================================================================
--                          <<Function: get_ptip_name>>
-- ============================================================================
--
Function get_ptip_name(p_ptip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select pgm.name|| ' - ' || plt.name
  from 	 ben_pl_typ_f plt,
  	 ben_pgm_f pgm,
  	 ben_ptip_f ptip
  where  ptip.ptip_id = p_ptip_id
  and    pgm.pgm_id   = ptip.pgm_id
  and    plt.pl_typ_id   = ptip.pl_typ_id
  and    ptip.business_group_id = p_business_group_id
  and 	 p_effective_date between ptip.effective_start_date and ptip.effective_end_date
  and 	 p_effective_date between plt.effective_start_date and plt.effective_end_date
  and 	 p_effective_date between pgm.effective_start_date and pgm.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_ptip_name;

--
-- ============================================================================
--                          <<Function: get_oipl_name>>
-- ============================================================================
--
Function get_oipl_name(p_oipl_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select pln.name|| ' - '|| opt.name
  from 	 ben_pl_f pln,
  	 ben_opt_f opt,
  	 ben_oipl_f oipl
  where  oipl.oipl_id = p_oipl_id
  and    opt.opt_id   = oipl.opt_id
  and    pln.pl_id    = oipl.pl_id
  and    oipl.business_group_id = p_business_group_id
  and 	 p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  and 	 p_effective_date between opt.effective_start_date and opt.effective_end_date
  and 	 p_effective_date between pln.effective_start_date and pln.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_oipl_name;
--
--
-- ============================================================================
--                          <<Function: get_group_oipl_name>>
-- ============================================================================
--
Function get_group_oipl_name(p_oipl_id              in number
                            ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select pln.name|| ' - '|| opt.name
  from 	 ben_pl_f pln,
  	 ben_opt_f opt,
  	 ben_oipl_f oipl
  where  oipl.oipl_id = p_oipl_id
  and    opt.opt_id   = oipl.opt_id
  and    pln.pl_id    = oipl.pl_id
  and 	 p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  and 	 p_effective_date between opt.effective_start_date and opt.effective_end_date
  and 	 p_effective_date between pln.effective_start_date and pln.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_group_oipl_name;
--
-- ============================================================================
--                          <<Function: get_oiplip_name>>
-- ============================================================================
--
Function get_oiplip_name(p_oiplip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select pgm.name || ' - '|| pln.name|| ' - '|| opt.name
  from 	 ben_pl_f pln,
  	 ben_opt_f opt,
  	 ben_oipl_f oipl,
  	 ben_oiplip_f oiplip,
  	 ben_plip_f plip,
  	 ben_pgm_f pgm
  where  oiplip.oiplip_id = p_oiplip_id
  and    oipl.oipl_id   = oiplip.oipl_id
  and    opt.opt_id     = oipl.opt_id
  and    pln.pl_id      = oipl.pl_id
  and    plip.plip_id   = oiplip.plip_id
  and    pgm.pgm_id     = plip.pgm_id
  and    oiplip.business_group_id = p_business_group_id
  and 	 p_effective_date between oiplip.effective_start_date and oiplip.effective_end_date
  and 	 p_effective_date between oipl.effective_start_date and oipl.effective_end_date
  and 	 p_effective_date between opt.effective_start_date and opt.effective_end_date
  and 	 p_effective_date between pln.effective_start_date and pln.effective_end_date
  and 	 p_effective_date between plip.effective_start_date and plip.effective_end_date
  and 	 p_effective_date between pgm.effective_start_date and pgm.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_oiplip_name;

--
-- ============================================================================
--                          <<Function: get_cmbn_plip_name>>
-- ============================================================================
--
Function get_cmbn_plip_name(p_cmbn_plip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select cplip.name
  from   ben_cmbn_plip_f cplip
  where  cplip.cmbn_plip_id    = p_cmbn_plip_id
  and    cplip.business_group_id = p_business_group_id
  and    p_effective_date between cplip.effective_start_date and cplip.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_cmbn_plip_name;

--
-- ============================================================================
--                          <<Function: get_cmbn_ptip_name>>
-- ============================================================================
--
Function get_cmbn_ptip_name(p_cmbn_ptip_id              in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select cptip.name
  from 	 ben_cmbn_ptip_f cptip
  where  cptip.cmbn_ptip_id = p_cmbn_ptip_id
  and    cptip.business_group_id = p_business_group_id
  and  	 p_effective_date between cptip.effective_start_date  and cptip.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_cmbn_ptip_name;

--
-- ============================================================================
--                          <<Function: get_cmbn_ptip_opt_name>>
-- ============================================================================
--
Function get_cmbn_ptip_opt_name(p_cmbn_ptip_opt_id   in number
                    ,p_business_group_id  in number
                    ,p_effective_date     in date
                    ) return varchar2
is
--
  cursor c1 is
  select cpt.name
  from   ben_cmbn_ptip_opt_f cpt
  where  cpt.cmbn_ptip_opt_id = p_cmbn_ptip_opt_id
  and    cpt.business_group_id = p_business_group_id
  and    p_effective_date between cpt.effective_start_date and cpt.effective_end_date;
  --
  ret_str    varchar2(1500);
  --
Begin
    --
    open c1;
    fetch c1 into ret_str;
    close c1;
    --
    return ret_str;
    --
End get_cmbn_ptip_opt_name;

--
end ben_bis_utils;

/
