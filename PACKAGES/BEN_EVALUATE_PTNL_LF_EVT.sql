--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_PTNL_LF_EVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_PTNL_LF_EVT" AUTHID CURRENT_USER as
/* $Header: benptnle.pkh 120.0.12000000.5 2007/06/02 06:17:55 rgajula noship $ */
--

--Start 6086392
     TYPE g_bckdt_pil_tabtype IS TABLE OF BEN_PER_IN_LER.BCKT_PER_IN_LER_ID%TYPE INDEX BY BINARY_INTEGER;
     g_bckdt_pil_tbl g_bckdt_pil_tabtype;
--End 6086392


procedure eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode   in varchar2
                               ,p_effective_date in date
                               ,p_created_ler_id out NOCOPY number) ;
--
-- CWB Changes :
-- This procedure evaluates potential life events for
-- Compensation work bench.
--
procedure cwb_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode   in varchar2
                               ,p_effective_date in date
                               ,p_lf_evt_ocrd_dt in date
                               ,p_ptnl_ler_for_per_id in number
                               ,p_created_ler_id out NOCOPY number) ;
--
-- CWB Changes :
-- This procedure evaluates potential life events for
-- Compensation work bench.
--
procedure absences_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id           in number
                               ,p_business_group_id   in number
                               ,p_ler_id              in number default null
                               ,p_mode                in varchar2
                               ,p_effective_date      in date
                               ,p_created_ler_id      out NOCOPY number);
--
-- GRADE/STEP : process the grade/step potential life events.
--
procedure grd_stp_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode in varchar2
                               ,p_effective_date in date
                               ,p_created_ler_id out NOCOPY number
                               ,p_lf_evt_oper_cd in varchar2 default null);    /* GSP Rate Sync*/
--
-- iRec
--
procedure irec_eval_ptnl_per_for_ler(p_validate in boolean default false
                               ,p_person_id in number
                               ,p_business_group_id in number
                               ,p_ler_id in number default null
                               ,p_mode   in varchar2
                               ,p_effective_date in date
                               ,p_lf_evt_ocrd_dt in date
                               ,p_assignment_id  in number
                               ,p_ptnl_ler_for_per_id in number
                               ,p_created_ler_id out NOCOPY number);
--
end ben_evaluate_ptnl_lf_evt;

 

/
