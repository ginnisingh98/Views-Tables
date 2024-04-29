--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_DELETE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_DELETE_API" AUTHID CURRENT_USER as
/* $Header: bepdwdel.pkh 120.1 2006/04/11 17:08 ashrivas noship $ */
-- p_validate 0 means false

-- ----------------------------------------------------------------------------
-- |--------------------------< <call_delete_apis> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--   Name                           Type     Description
-- Post Failure:
-- Access Status:
--   Internal Development Use Only.

procedure call_delete_apis
( p_process_validate in Number default 0
 ,p_copy_entity_txn_id in Number
 ,p_delete_failed out nocopy varchar2
) ;


-- this procedure will call delete apis on a limited set using the
-- p_pd_parent_entity_result_id  which is the id of the entity which was deleted

-- ----------------------------------------------------------------------------
-- |--------------------------< <call_delete_apis_for_hierarchy> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Prerequisites:
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--   Name                           Type     Description
-- Post Failure:
-- Access Status:
--   Internal Development Use Only.

procedure call_delete_apis_for_hierarchy
( p_process_validate in Number default 0
 ,p_copy_entity_txn_id in Number
 ,p_parent_entity_result_id in varchar2
 ,p_delete_failed out nocopy varchar2
) ;



end ben_plan_design_delete_api;

 

/
