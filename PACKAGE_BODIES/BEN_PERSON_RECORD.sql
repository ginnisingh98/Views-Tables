--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_RECORD" AS
/* $Header: benperrec.pkb 120.0.12010000.3 2009/04/10 12:55:37 pvelvano noship $ */


-- Procedure to populate the record structure with Person Benefits Data
procedure GET_BEN_DETAILS (p_ben_details in out NOCOPY ben_record_details,
                           p_person_id NUMBER,p_effective_date DATE,
			   p_business_group_id NUMBER) is

/*Cursor to fetch Dependent Enrollments Data*/
cursor c_get_dep_details(p_person_id NUMBER,p_effective_date DATE,p_business_group_id NUMBER) is

select dependent_full_name, relation, plan_type_name, 'COVERED'
from
(
select    pln.name Plan_Name,
	   opt.name Option_Name,
	   plt.name plan_type_name,
       (select name from ben_pgm_f pgm
               where p_effective_date  between pgm.effective_start_date
                           and pgm.effective_end_date
	       and pgm.pgm_id=epe.pgm_id
	       and pgm.business_group_id      = p_business_group_id) Program_Name,
       ppf.first_name||' '||ppf.last_name || ' ' || ppf.suffix                 Dependent,
       ppf.national_identifier                             Ssn,
       (select HR_GENERAL.DECODE_LOOKUP('CONTACT',pcr.contact_type)
        from per_contact_relationships pcr
       where pcr.personal_flag = 'Y'
		 and pcr.person_id = pen.person_id
		 and pcr.contact_person_id = pdp.dpnt_person_id
		 and p_effective_date   between nvl(pcr.date_start, p_effective_date )
		                and nvl(pcr.date_end, p_effective_date )
		 and decode(pcr.contact_type,'S',1,'D',2,'A',3,'C',4,'O',5,'T',6,'P',7,8) <=
		 	 		(select decode(pcr2.contact_type,'S',1,'D',2,'A',3,'C',4,'O',5,'T',6,'P',7,8)
					 from per_contact_relationships pcr2
		            where pcr2.person_id = pcr.person_id
					 and pcr2.contact_person_id = pcr.contact_person_id
					 and p_effective_date  between nvl(pcr2.date_start, p_effective_date )
					 and nvl(pcr2.date_end, p_effective_date )
					 and pcr2.personal_flag = 'Y'
				  )
		 and rownum = 1
				) 	    Relation,
       epe.per_in_ler_id,
       epe.pgm_id,
       ler.name le_name,
       ppf.full_name dependent_full_name,
       pdp.cvg_strt_dt,
       to_date(null) cvg_thru_dt
from     ben_elig_per_elctbl_chc   epe,
         ben_prtt_enrt_rslt_f      pen,
         ben_elig_cvrd_dpnt_f      pdp,
         per_contact_relationships pcr,
         per_people_f          ppf,
         ben_pl_typ_f              plt,
         ben_pl_f                  pln,
	 ben_opt_f		   opt,
	 ben_oipl_f 		   oipl,
         ben_per_in_ler            pil,
	 ben_ler_f                 ler
where   epe.prtt_enrt_rslt_id      = pen.prtt_enrt_rslt_id
and     epe.pl_id                  = pln.pl_id
and     epe.pl_typ_id              = plt.pl_typ_id
and     pen.prtt_enrt_rslt_id      = pdp.prtt_enrt_rslt_id
and     pen.prtt_enrt_rslt_stat_cd is null
and    pen.enrt_cvg_thru_dt        = to_date('31-12-4712','DD-MM-YYYY')
and     pdp.dpnt_person_id         = pcr.contact_person_id
and     pcr.contact_person_id      = ppf.person_id
and     pcr.personal_flag      = 'Y'
and     epe.prtt_enrt_rslt_id is not null
and     epe.per_in_ler_id          = pil.per_in_ler_id
and     pil.ler_id          = ler.ler_id
and     pcr.person_id              = pil.person_id
and     pil.per_in_ler_stat_cd  not in ('VOIDD', 'BCKDT')
-- Code Changes for bug 7689952 -  Start
--and     pil.per_in_ler_id = l_per_in_ler_id
and pen.enrt_cvg_thru_dt >= pen.effective_start_date
and pil.per_in_ler_id = pen.per_in_ler_id
and pen.enrt_cvg_thru_dt >= p_effective_date
-- Code Changes for bug 7689952 - End
--and     epe.pgm_id        = :8
and     pil.person_id = p_person_id
and     p_effective_date  between ler.effective_start_date
                           and ler.effective_end_date
and     p_effective_date  between pdp.effective_start_date
                           and pdp.effective_end_date
and     p_effective_date  between pln.effective_start_date
                           and pln.effective_end_date
and     p_effective_date  between plt.effective_start_date
                           and plt.effective_end_date
and     p_effective_date  between nvl(pcr.date_start, p_effective_date )
                           and nvl(pcr.date_end, p_effective_date )
and     p_effective_date  between ppf.effective_start_date
                           and ppf.effective_end_date
and     p_effective_date  between pen.effective_start_date
                           and pen.effective_end_date
and     pdp.cvg_thru_dt = to_date('31-12-4712','DD-MM-YYYY')
and     pdp.per_in_ler_id = pil.per_in_ler_id
and 	pen.oipl_id = oipl.oipl_id(+)
and 	oipl.opt_id = opt.opt_id(+)
and 	decode (opt.opt_id, null, 'N' , opt.invk_wv_opt_flag ) = 'N'
and 	p_effective_date between
    	oipl.effective_start_date (+) and
    	oipl.effective_end_date (+)
and 	p_effective_date between
    	opt.effective_start_date (+) and
    	opt.effective_end_date (+)
  and pcr.business_group_id      = p_business_group_id
  and ppf.business_group_id      = p_business_group_id
  and plt.business_group_id      = p_business_group_id
  and pln.business_group_id      = p_business_group_id
  and opt.business_group_id      = p_business_group_id
  and oipl.business_group_id      = p_business_group_id
  and pil.business_group_id      = p_business_group_id
  and epe.business_group_id      = p_business_group_id
  and pen.business_group_id      = p_business_group_id
  and pdp.business_group_id      = p_business_group_id
  and ler.business_group_id      = p_business_group_id
  );

/*Cursor to fetch Beneficaries Data*/
  cursor c_get_ben_details(p_person_id NUMBER,p_effective_date DATE,p_business_group_id NUMBER) is
 select Plan_Type_Name,Plan_Name, Option_Name, Beneficiary, Ssn, Relation,  Primary_Bnf, Contingent_Bnf,
 le_name,beneficiary_full_name,Primary_Bnf_Amt,Contingent_Bnf_Amt
from  (select plt.name Plan_Type_Name,pln.name         Plan_Name, opt.name Option_Name,
       ppf.last_name last_name,
       ppf.first_name first_name,
       decode(pbn.organization_id, null, ppf.first_name||
       ' '||ppf.last_name || ' ' || ppf.suffix,
              org.name)    Beneficiary,
       nvl(ppf.full_name, org.name) beneficiary_full_name,
       ppf.national_identifier          Ssn,
       nvl(HR_GENERAL.DECODE_LOOKUP('CONTACT',pcr.contact_type),
           decode(pbn.organization_id, null,
           HR_GENERAL.DECODE_LOOKUP('BEN_EXT_RLSHP','SLF'),
           HR_GENERAL.DECODE_LOOKUP('BEN_EXT_RLSHP','TP')))           Relation,              sum(decode(pbn.prmry_cntngnt_cd,'PRIMY',pbn.pct_dsgd_num,0))   Primary_Bnf,       sum(decode(pbn.prmry_cntngnt_cd,'CNTNGNT',pbn.pct_dsgd_num,0)) Contingent_Bnf,
    sum(decode(pbn.prmry_cntngnt_cd,'PRIMY',pbn.amt_dsgd_val,0))   Primary_Bnf_Amt,       sum(decode(pbn.prmry_cntngnt_cd,'CNTNGNT',pbn.amt_dsgd_val,0)) Contingent_Bnf_Amt,
       pcr.contact_type      contact_type,
       ler.name le_name,
       ppf.date_of_birth    date_of_birth,
       pen.ptip_ordr_num     ptip_ordr_num,
       pen.plip_ordr_num     plip_ordr_num,
       pen.pl_ordr_num       pl_ordr_num,
       pen.oipl_ordr_num     oipl_ordr_num,
       pen.bnft_ordr_num     bnft_ordr_num
      from per_people_f          ppf,
     per_contact_relationships pcr,
     ben_prtt_enrt_rslt_f      pen,
     ben_pl_bnf_f              pbn,
     ben_pl_typ_f              plt,
     ben_pl_f                  pln,
     hr_all_organization_units org,
     ben_opt_f opt,
     ben_oipl_f oipl,
     ben_per_in_ler            pil,
     ben_ler_f                 ler
where pen.pl_id           = pln.pl_id
-- Code Changes for bug 7689952 -  Start
--and (pen.per_in_ler_id = l_per_in_ler_id)
and pen.enrt_cvg_thru_dt >= pen.effective_start_date
and pen.enrt_cvg_thru_dt >= p_effective_date
-- Code Changes for bug 7689952 -  End
and pen.oipl_id = oipl.oipl_id(+)
and oipl.opt_id = opt.opt_id(+)
and decode (opt.opt_id, null, 'N' , opt.invk_wv_opt_flag ) = 'N'
and pln.invk_dcln_prtn_pl_flag = 'N'
and pen.person_id = p_person_id
and pen.prtt_enrt_rslt_id = pbn.prtt_enrt_rslt_id
and pbn.per_in_ler_id          = pil.per_in_ler_id
and pil.ler_id          = ler.ler_id
and exists (select null from ben_per_in_ler pil
            where pil.per_in_ler_id = pbn.per_in_ler_id
   and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT'))
and pen.prtt_enrt_rslt_stat_cd IS NULL
and pen.enrt_cvg_thru_dt = to_date('31-12-4712','DD-MM-YYYY')
and pen.pl_typ_id         = plt.pl_typ_id
and pcr.personal_flag(+)     = 'Y'
and pcr.person_id(+) = p_person_id
and pbn.bnf_person_id  = pcr.contact_person_id(+)
and pbn.bnf_person_id  = ppf.person_id(+)
and pbn.organization_id = org.organization_id(+)
and p_effective_date  between ler.effective_start_date
                and ler.effective_end_date
and p_effective_date  between plt.effective_start_date
                and plt.effective_end_date
and p_effective_date  between pbn.effective_start_date
                and pbn.effective_end_date
and p_effective_date  between
    nvl(ppf.effective_start_date, p_effective_date ) and
    nvl(ppf.effective_end_date, p_effective_date )
and p_effective_date between pen.effective_start_date
                and pen.effective_end_date
and p_effective_date  between pln.effective_start_date
                and pln.effective_end_date
and p_effective_date  between
    nvl(org.date_from, p_effective_date ) and
    nvl(org.date_to, p_effective_date )
and p_effective_date between
    oipl.effective_start_date (+) and
    oipl.effective_end_date (+)
and p_effective_date  between
    opt.effective_start_date (+) and
    opt.effective_end_date (+)
  and ppf.business_group_id      = p_business_group_id
  and pcr.business_group_id      = p_business_group_id
  and pen.business_group_id      = p_business_group_id
  and pbn.business_group_id      = p_business_group_id
  and plt.business_group_id      = p_business_group_id
  and pln.business_group_id      = p_business_group_id
  and opt.business_group_id      = p_business_group_id
  and oipl.business_group_id      = p_business_group_id
  and org.business_group_id(+)      = p_business_group_id
  and ler.business_group_id      = p_business_group_id
and (pcr.contact_relationship_id is null or
     (pcr.contact_relationship_id is not null and
      (p_effective_date  between
       nvl(pcr.date_start, p_effective_date ) and
       nvl(pcr.date_end, p_effective_date )) or
      ((pcr.date_start = (select max(pcr2.date_start)
                          from per_contact_relationships pcr2
                          where pcr2.contact_person_id = pcr.contact_person_id
                          and pcr2.person_id = pcr.person_id
                          and pcr2.personal_flag = 'Y')) and
        not exists (select null
                    from PER_CONTACT_RELATIONSHIPS pcr3
                    where pcr3.contact_person_id = pcr.contact_person_id
                    and pcr3.person_id = pcr.person_id
                    and pcr3.personal_flag = 'Y'
                    and p_effective_date  between
                    nvl(pcr3.date_start, p_effective_date )
                    and nvl(pcr3.date_end, p_effective_date )))
))
group by plt.name,
         pln.name,
  opt.name,
         ppf.first_name,
         ppf.last_name,
         ppf.suffix,
         ppf.full_name,
         pbn.organization_id,
         org.name,
         ppf.national_identifier,
         pcr.contact_type,
  ler.name,
         ppf.date_of_birth,
         pln.bnf_cntngt_bnfs_alwd_flag,
         pen.ptip_ordr_num,
         pen.plip_ordr_num,
         pen.pl_ordr_num,
         pen.oipl_ordr_num,
         pen.bnft_ordr_num
)order by ptip_ordr_num,
          plip_ordr_num,
          pl_ordr_num,
          oipl_ordr_num,
          bnft_ordr_num,
          Plan_Name,
          decode(contact_type,'S',1,'D',1,'A',2,
                              'C',2,'O',2,'T',2,'P',3,4),
          date_of_birth,
          last_name,
          first_name,
          Beneficiary;

/*Cursor to fetch Person Enrollments Data*/
cursor c_get_pgm_enrt_details(p_person_id NUMBER,p_effective_date DATE,p_business_group_id NUMBER) is
  SELECT plan_type_name,
         plan_name,
         option_name
  FROM
  (
  SELECT elc.plt_name plan_type_name,
       pln.name plan_name,
       opt.name option_name,
       elc.Program_Name,
       elc.Coverage,
       elc.le_name,
       elc.per_in_ler_id,
       elc.pgm_id,
       elc.sspndd_flag,
       elc.crntly_enrd_flag,
       elc.elctbl_flag,
       elc.enrt_cvg_strt_dt,
       elc.enrt_cvg_thru_dt,
       decode(elc.sspndd_flag,'Y','Suspended') suspended,
       decode(elc.interim, 'Y', 'Interim') interim
FROM
(
SELECT epe.ptip_ordr_num         ptip_ordr_num,
      epe.plip_ordr_num          plip_ordr_num,
      pen.pl_ordr_num            pl_ordr_num,
      epe.oipl_ordr_num          oipl_ordr_num,
      pen.bnft_ordr_num          bnft_ordr_num,
	  plt.name 		 plt_name,
	  pen.person_id 	 person_id,
      pen.bnft_amt               Coverage,
      epe.per_in_ler_id          per_in_ler_id,
      pen.sspndd_flag,
      epe.crntly_enrd_flag,
      epe.elctbl_flag,
      pen.enrt_cvg_strt_dt ,
      decode(pen.enrt_cvg_thru_dt,to_date('31-12-4712','DD-MM-YYYY'),to_date(null),pen.enrt_cvg_thru_dt) enrt_cvg_thru_dt,
      decode(pen1.prtt_enrt_rslt_id , null, 'N', 'Y') interim,
      ler.name le_name,
      (select name from ben_pgm_f pgm
               where p_effective_date  between pgm.effective_start_date
                           and pgm.effective_end_date
	       and pgm.pgm_id=epe.pgm_id
	       and pgm.business_group_id      = p_business_group_id) Program_Name,
      epe.pgm_id	             pgm_id,
      epe.ptip_id                   ptip_id,
      epe.plip_id                   plip_id,
      epe.oiplip_id                 oiplip_id,
      epe.pl_id,
      epe.oipl_id
FROM ben_elig_per_elctbl_chc epe,
     ben_enrt_bnft           beb,
     ben_prtt_enrt_rslt_f    pen,
     ben_pl_typ_f            plt,
     ben_pil_elctbl_chc_popl pel,
     ben_prtt_enrt_rslt_f    pen1,
     ben_ler_f ler
WHERE pen.prtt_enrt_rslt_id = pen1.rplcs_sspndd_rslt_id (+)
  and  ( p_effective_date)  between pen1.effective_start_date (+)
                                       and pen1.effective_end_date (+)
  and pen1.prtt_enrt_rslt_stat_cd (+) is NULL
  and pen1.enrt_cvg_thru_dt (+) =to_date('31-12-4712','DD-MM-YYYY')
 -- Code Changes for bug 7689952 -  Start
--and  epe.per_in_ler_id = l_per_in_ler_id
  and pen.per_in_ler_id = epe.per_in_ler_id
  and pen.enrt_cvg_thru_dt >= pen.effective_start_date
  and pen.enrt_cvg_thru_dt >= p_effective_date
--Code Changes for bug 7689952 - End
  and pen.person_id = p_person_id
  and epe.business_group_id      = p_business_group_id
  and plt.business_group_id      = p_business_group_id
  and ler.business_group_id      = p_business_group_id
  AND ((epe.elctbl_flag = 'N' and
          (nvl(beb.crntly_enrld_flag, epe.crntly_enrd_flag) = 'Y'
          or epe.auto_enrt_flag = 'Y'))
        or epe.elctbl_flag = 'Y')
  AND epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
  AND epe.pl_typ_id              = plt.pl_typ_id
  AND decode(beb.enrt_bnft_id, null, epe.prtt_enrt_rslt_id, beb.prtt_enrt_rslt_id) = pen.prtt_enrt_rslt_id
  AND epe.business_group_id      = beb.business_group_id(+)
  AND epe.elig_per_elctbl_chc_id = beb.elig_per_elctbl_chc_id (+)
  AND ( p_effective_date)  BETWEEN pen.effective_start_date
                         AND pen.effective_end_date
  AND ( p_effective_date)  BETWEEN plt.effective_start_date
                         AND plt.effective_end_date
  AND ( p_effective_date)  BETWEEN ler.effective_start_date
                         AND ler.effective_end_date
  AND pen.enrt_cvg_thru_dt = to_date('31-12-4712','DD-MM-YYYY')
  and pen.ler_id=ler.ler_id
  AND epe.comp_lvl_cd NOT IN ('PLANFC' ,'PLANIMP')
  AND pen.prtt_enrt_rslt_stat_cd is null
UNION
SELECT epe.ptip_ordr_num         ptip_ordr_num,
      epe.plip_ordr_num          plip_ordr_num,
      pen.pl_ordr_num            pl_ordr_num,
      epe.oipl_ordr_num          oipl_ordr_num,
      pen.bnft_ordr_num          bnft_ordr_num,
	  plt.name 		 plt_name,
	  pen.person_id 	 person_id,
      pen.bnft_amt               Coverage,
      epe.per_in_ler_id          per_in_ler_id,
      pen.sspndd_flag,
      epe.crntly_enrd_flag,
      epe.elctbl_flag,
      pen.enrt_cvg_strt_dt ,
      decode(pen.enrt_cvg_thru_dt,
to_date('31-12-4712','DD-MM-YYYY'),to_date(null),pen.enrt_cvg_thru_dt) enrt_cvg_thru_dt,
      decode(pen1.prtt_enrt_rslt_id , null, 'N', 'Y') interim,
      ler.name le_name,
      (select name from ben_pgm_f pgm
               where p_effective_date  between pgm.effective_start_date
                           and pgm.effective_end_date
	       and pgm.pgm_id=epe.pgm_id
	       and pgm.business_group_id      = p_business_group_id) Program_Name,
      epe.pgm_id	             pgm_id,
      epe.ptip_id                   ptip_id,
      epe.plip_id                   plip_id,
      epe.oiplip_id                 oiplip_id,
      epe.pl_id,
      epe.oipl_id
FROM ben_elig_per_elctbl_chc epe,
     ben_enrt_bnft           beb,
     ben_prtt_enrt_rslt_f    pen,
     ben_pl_typ_f            plt,
     ben_pil_elctbl_chc_popl pel,
     ben_prtt_enrt_rslt_f    pen1,
     ben_ler_f ler
WHERE pen.prtt_enrt_rslt_id = pen1.rplcs_sspndd_rslt_id (+)
  and  (p_effective_date)  between pen1.effective_start_date (+)
                                       and pen1.effective_end_date (+)
  and pen1.prtt_enrt_rslt_stat_cd (+) is NULL
  and pen1.enrt_cvg_thru_dt (+)  =to_date('31-12-4712','DD-MM-YYYY')
  -- Code Changes for bug 7689952 -  Start
 -- and epe.per_in_ler_id = l_per_in_ler_id
  and pen.enrt_cvg_thru_dt >= pen.effective_start_date
  and pen.per_in_ler_id=epe.per_in_ler_id
  and pen.enrt_cvg_thru_dt >= p_effective_date
-- Code Changes for bug 7689952 - End
  and pen.person_id = p_person_id
  and epe.business_group_id      = p_business_group_id
  and plt.business_group_id      = p_business_group_id
  and ler.business_group_id      = p_business_group_id
  AND ((epe.elctbl_flag = 'N' and
          (nvl(beb.crntly_enrld_flag, epe.crntly_enrd_flag) = 'Y'
          or epe.auto_enrt_flag = 'Y'))
        or epe.elctbl_flag = 'Y')
  AND epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id
  AND epe.pl_typ_id              = plt.pl_typ_id
  AND decode(beb.enrt_bnft_id, null, epe.prtt_enrt_rslt_id, beb.prtt_enrt_rslt_id) = pen.prtt_enrt_rslt_id
  AND epe.business_group_id      = beb.business_group_id(+)
  AND epe.elig_per_elctbl_chc_id = beb.elig_per_elctbl_chc_id (+)
  AND (p_effective_date)  BETWEEN pen.effective_start_date
                         AND pen.effective_end_date
  AND (p_effective_date)  BETWEEN plt.effective_start_date
                         AND plt.effective_end_date
  AND ( p_effective_date)  BETWEEN ler.effective_start_date
                         AND ler.effective_end_date
  AND pen.enrt_cvg_thru_dt = to_date('31-12-4712','DD-MM-YYYY')
  and pen.ler_id=ler.ler_id
  AND epe.comp_lvl_cd NOT IN ('PLANFC' ,'PLANIMP')
  AND pen.prtt_enrt_rslt_stat_cd is null
)                            elc,
     ben_pl_f                pln,
     ben_oipl_f              oipl,
     ben_opt_f               opt,
     ben_ptip_f              ptip,
     ben_plip_f              plip
where elc.pl_id                  = pln.pl_id
  AND elc.ptip_id                = ptip.ptip_id
  AND elc.plip_id                = plip.plip_id
  AND elc.oipl_id                = oipl.oipl_id(+)
  AND oipl.opt_id                = opt.opt_id(+)
  and pln.business_group_id      = p_business_group_id
  and oipl.business_group_id      = p_business_group_id
  and opt.business_group_id      = p_business_group_id
  and ptip.business_group_id      = p_business_group_id
  and plip.business_group_id      = p_business_group_id
  AND ( p_effective_date)  BETWEEN pln.effective_start_date
                         AND pln.effective_end_date
  AND ( p_effective_date)  BETWEEN oipl.effective_start_date(+)
                         AND oipl.effective_end_date(+)
  AND ( p_effective_date)  BETWEEN opt.effective_start_date(+)
                         AND opt.effective_end_date(+)
  AND ( p_effective_date)  BETWEEN ptip.effective_start_date
                         AND ptip.effective_end_date
  AND ( p_effective_date)  BETWEEN plip.effective_start_date
                         AND plip.effective_end_date
ORDER BY elc.ptip_ordr_num,
elc.plip_ordr_num,
elc.pl_ordr_num,
elc.oipl_ordr_num,
elc.bnft_ordr_num
);
p_cnt number := 1;
begin
	open c_get_dep_details(p_person_id,p_effective_date,p_business_group_id);
	FETCH c_get_dep_details BULK COLLECT INTO p_ben_details.dependent;
	close c_get_dep_details;

	p_cnt := p_ben_details.dependent.count + 1;

	for h in c_get_ben_details(p_person_id,p_effective_date,p_business_group_id)
   loop
	p_ben_details.dependent(p_cnt).name := h.beneficiary_full_name;
	p_ben_details.dependent(p_cnt).relationship := h.Relation;
	p_ben_details.dependent(p_cnt).type_of_benefit := h.plan_name;
	if h.Primary_Bnf is not null then
		p_ben_details.dependent(p_cnt).coverage := to_char(h.Primary_Bnf);
	elsif h.Contingent_Bnf is not null then
        	p_ben_details.dependent(p_cnt).coverage := to_char(h.Contingent_Bnf);
	elsif h.Primary_Bnf_amt is not null then
		p_ben_details.dependent(p_cnt).coverage := to_char(h.Primary_Bnf_amt);
	elsif h.Contingent_Bnf_amt is not null then
		p_ben_details.dependent(p_cnt).coverage := to_char(h.Contingent_Bnf_amt);
	end if;
	p_cnt := p_cnt + 1;
   end loop;

	open c_get_pgm_enrt_details(p_person_id,p_effective_date,p_business_group_id);
	FETCH c_get_pgm_enrt_details BULK COLLECT INTO p_ben_details.benefit;
	close c_get_pgm_enrt_details;

end GET_BEN_DETAILS ;
--

END BEN_PERSON_RECORD;
--

/
