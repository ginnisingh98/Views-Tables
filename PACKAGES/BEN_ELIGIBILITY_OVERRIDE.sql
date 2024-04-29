--------------------------------------------------------
--  DDL for Package BEN_ELIGIBILITY_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBILITY_OVERRIDE" AUTHID CURRENT_USER as
/* $Header: benovrel.pkh 120.0.12000000.1 2007/01/19 18:39:19 appldev noship $ */
--
type g_lvl_typ is record (lvl_name varchar2(60),
                          meaning  hr_lookups.meaning%type,
                          counter  number);
type g_rec is table of g_lvl_typ index by binary_integer;

procedure update_elig_hierarchy
(p_person_id          in number,
 p_pgm_id             in number,
 p_ptip_id            in number,
 p_plip_id            in number,
 p_pl_id              in number,
 p_elig_per_id        in number,
 p_elig_flag          in varchar2,
 p_dt_mode            in varchar2,
 p_business_group_id  in number,
 p_per_in_ler_id      in number,
 p_effective_date     in date,
 p_out_mesg          out nocopy varchar2);

procedure create_elig_hierarchy
(p_elig_per           in ben_elig_per_f%rowtype,
 p_cobj_level         in varchar2,
 p_dt_mode            in varchar2,
 p_business_group_id  in number,
 p_effective_date     in date,
 p_out_mesg          out nocopy varchar2);

procedure reset_counter_rec;

function chk_if_enrolled
(p_pgm_id in number,
 p_pl_id in number,
 p_oipl_id in number,
 p_business_group_id in number,
 p_person_id in number,
 p_effective_date in date)
return varchar2;

End ben_eligibility_override;

 

/
