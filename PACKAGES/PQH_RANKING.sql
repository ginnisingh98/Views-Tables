--------------------------------------------------------
--  DDL for Package PQH_RANKING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANKING" AUTHID CURRENT_USER AS
/* $Header: pqrnkpkg.pkh 120.0 2005/05/29 02:36:50 appldev noship $ */
--
--
 FUNCTION  is_workflow_enabled ( p_pgm_id in number) return varchar2;
--
 PROCEDURE get_pgi_info (
           p_pgm_id in number
           ,p_workflow_enabled out nocopy varchar2
           ,p_rank_enabled out nocopy varchar2
           ,p_handle_duplicate out nocopy varchar2
           ,p_group_score  out nocopy varchar2
           ,p_result out nocopy varchar2);
--
 PROCEDURE compute_total_score (
       p_benefit_action_id in number
      ,p_module         in varchar2
      ,p_per_in_ler_id  in number
      ,p_person_id      in number
      ,p_effective_date in date
      );
--
--
 PROCEDURE assign_ranks_for_CWB (
        p_benefit_action_id     IN NUMBER) ;
--
 FUNCTION get_criteria_name (
        p_tab_short_name in varchar2) RETURN VARCHAR2;
--
PROCEDURE compute_rank_for_GSP (
          errbuf              out nocopy VARCHAR2,
          retcode             out nocopy NUMBER,
          p_business_group_id in NUMBER,
          p_pgm_id            in NUMBER,
          p_pl_id             in NUMBER,
          p_process_dt_start  in VARCHAR2,
          p_process_dt_end    in VARCHAR2,
          p_benefit_action_id in NUMBER,
          p_audit_log         in VARCHAR2,
          p_commit_data       in VARCHAR2,
          p_rank_wf_pending   in VARCHAR2
         );
--
END; -- Package Specification PQH_RANKING

 

/
