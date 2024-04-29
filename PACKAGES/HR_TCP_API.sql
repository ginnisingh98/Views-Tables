--------------------------------------------------------
--  DDL for Package HR_TCP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCP_API" AUTHID CURRENT_USER as
/* $Header: hrtcpapi.pkh 120.0 2005/05/31 02:59:16 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_item_context_page >---------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template item context
--              tab page in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
-- Name                           Reqd Type     Description
-- p_template_item_context_id     Y    Number
-- p_template_tab_page_id         Y    Number
--
-- Post Success:
--
--
--   Name                           Type     Description
-- p_tcp_id  Number
-- p_object_version_number          Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_tcp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_template_item_context_id      in     number
  ,p_template_tab_page_id          in     number
  ,p_template_item_context_page_i     out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_item_context_page >---------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes a template item context
--              tab page from the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- p_tcp_id  Y    Number
-- p_object_version_number          Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_tcp
  (p_validate                      in     boolean  default false
  ,p_template_item_context_page_i  in number
  ,p_object_version_number         in number
  );
--
end hr_tcp_api;

 

/
