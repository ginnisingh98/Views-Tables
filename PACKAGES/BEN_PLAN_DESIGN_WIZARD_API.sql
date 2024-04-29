--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_WIZARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_WIZARD_API" AUTHID CURRENT_USER as
/* $Header: bepdwapi.pkh 120.1 2006/04/11 17:07 ashrivas noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< <write_route_and_hierarchy> >--------------------------|
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

procedure write_route_and_hierarchy(p_copy_entity_txn_id in number);

-- ----------------------------------------------------------------------------
-- |--------------------------< <update_result_rows> >--------------------------|
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

procedure update_result_rows(p_copy_entity_txn_id in number);

-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_entity> >--------------------------|
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


procedure delete_entity
(p_copy_entity_txn_id in Number
,p_copy_entity_result_id in Number
,p_table_alias in Varchar2
);
-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_Entity> >--------------------------|
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


procedure delete_Entity
(p_copy_entity_txn_id in Number
,p_copy_entity_result_id in Number
,p_table_alias in Varchar2
,p_top_level_entity in varchar2
);

-- p_process_validate  0 -- false
-- ----------------------------------------------------------------------------
-- |--------------------------< <pdw_submit_copy_request> >--------------------------|
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

procedure pdw_submit_copy_request(
  p_process_validate         in  number
 ,p_copy_entity_txn_id       in  number
 ,p_request_id               out nocopy number
 ,p_delete_failed            out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |--------------------------< <reuse_deleted_hierarchy> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
-- Prerequisites:
-- In Parameters:
--   Name                           Reqd Type     Description
-- Post Success:
--   Name                           Type     Description
-- Post Failure:
-- Access Status:
--   Internal Development Use Only.

procedure reuse_deleted_hierarchy
(p_copy_entity_txn_id in number
 ,p_copy_entity_result_id in number);

end ben_plan_design_wizard_api;

 

/
