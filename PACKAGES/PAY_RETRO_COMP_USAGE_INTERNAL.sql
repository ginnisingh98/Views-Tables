--------------------------------------------------------
--  DDL for Package PAY_RETRO_COMP_USAGE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_COMP_USAGE_INTERNAL" AUTHID CURRENT_USER as
/* $Header: pyrcubsi.pkh 115.0 2003/09/24 10:08 thabara noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< populate_retro_comp_usages >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure populates retro component usages and their child element
--   span usages for the specified element type. Records will be created by
--   copying from the retro component usages defined for the corresponding
--   classification.
--
--   This procedure is intended to be called when a new element type is being
--   introduced.
--
-- Prerequisites:
--   The element type must exist on the specified effective date.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  Date     Effective Date
--   p_element_type_id              Yes  Number   Element Type ID
--
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
--
-- Post Failure:
--   The procedure will not create a retro component usage and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure populate_retro_comp_usages
  (p_effective_date                in     date
  ,p_element_type_id               in     number
  );

-- ----------------------------------------------------------------------------
-- |---------------------< delete_child_retro_comp_usages >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure deletes child retro component usages of an element type
--   and deletes dependent element span usages accordingly.
--
--   This procedure is intended to be called when an element type is being
--   deleted.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  Date     Effective Date
--   p_element_type_id              Yes  Number   Element Type ID
--
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
--
-- Post Failure:
--   The procedure will not delete records and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_child_retro_comp_usages
  (p_effective_date                in     date
  ,p_element_type_id               in     number
  );


end pay_retro_comp_usage_internal;

 

/
