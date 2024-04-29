--------------------------------------------------------
--  DDL for Package BEN_CWB_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_APPROVALS" AUTHID CURRENT_USER as
/* $Header: bencwbap.pkh 120.1 2005/12/23 02:41 aupadhya noship $ */



-- ----------------------------------------------------------------------------
-- |-------------------------< approve_all_managers >---------------------|
-- ----------------------------------------------------------------------------


 procedure approve_all_managers
   			(p_group_per_in_ler_id in number,
   			 p_group_pl_id in number,
   			 p_group_oipl_id in number,
   			 p_task_id in number,
   			 p_effective_date date,
   			 p_login_person_id in number
  			 );

-- ----------------------------------------------------------------------------
-- |-------------------------< getNextApprover >---------------------|
-- ----------------------------------------------------------------------------


procedure getNextApprover(p_per_in_ler_id in number,
			  p_ben_cwb_profile_disp_name in varchar2,
			  p_approver_name out nocopy varchar2,
			  p_approver_id out nocopy number,
			  p_last_approver_name out nocopy varchar2);

end BEN_CWB_APPROVALS;

 

/
