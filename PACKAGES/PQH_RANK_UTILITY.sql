--------------------------------------------------------
--  DDL for Package PQH_RANK_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RANK_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pqrnkutl.pkh 120.2 2005/06/17 14:36:06 nsanghal noship $ */
--
--
function is_ranking_enabled_for_txn(
	p_copy_entity_txn_id in number )
return varchar2 ;


function get_ben_action_id(
	 p_per_in_ler_id	in number
	,p_pgm_id		in number
	,p_pl_id		in number )
return number;

procedure update_proposed_rank (
     p_proposed_rank    in number
	,p_assignment_id	in number
    ,p_life_event_dt   in date
	,p_pgm_id		in number
	,p_pl_id		in number  );

procedure update_proposed_rank (
         p_proposed_rank        in number
        ,p_per_in_ler_id	in number
	,p_pgm_id		in number
	,p_pl_id		in number  );

function get_rank (
	 p_rank_type		in varchar2
	,p_per_in_ler_id	in number
    ,p_pgm_id		in number
	,p_pl_id		in number )
return number;

function get_total_score(
	 p_per_in_ler_id	in number
	,p_pgm_id		in number
	,p_pl_id		in number )
return number;

function get_grade_ladder_option (
	 p_pgm_id	in number
	,p_option	in varchar2)
return Varchar2 ;

function is_ranking_enabled_for_bg (
	p_business_group_id	in number)
return Varchar2 ;

function is_ranking_enabled_for_person(p_person_id            in number
                                      ,p_business_group_id    in number
                                      ,p_effective_date       in date)
return varchar2;

-- ---------------------------------------------------------------
-- ---- Added by Nischal to Initate workflow from approval UI ----
-- ---------- <on_approval_init_workflow > -----------------------
-- ---------------------------------------------------------------
procedure on_approval_init_workflow(
       p_elctbl_chc_id  in number
      ,p_pgm_id         in number
      ,p_person_id      in number
      ,p_person_name    in varchar2
      ,p_prog_dt        in date
      ,p_sal_chg_dt     in date
      ,p_comments       in varchar2
      ,p_ameTranType    in varchar2
      ,p_ameAppId       in varchar2
      ,p_itemType       in varchar2
      ,p_processName    in varchar2
      ,p_functionName   in varchar2
      ,p_currentUser    in varchar2
      ,p_supervisorId   in number  );

End pqh_rank_utility;

 

/
