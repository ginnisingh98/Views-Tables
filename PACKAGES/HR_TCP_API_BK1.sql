--------------------------------------------------------
--  DDL for Package HR_TCP_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCP_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrtcpapi.pkh 120.0 2005/05/31 02:59:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_template_item_context_page_b >--------------|
-- ----------------------------------------------------------------------------
--
procedure create_tcp_b
  (p_effective_date                in     date
  ,p_template_item_context_id      in     number
  ,p_template_tab_page_id          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_template_item_context_page_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tcp_a
  (p_effective_date                in     date
  ,p_template_item_context_id      in     number
  ,p_template_tab_page_id          in     number
  ,p_template_item_context_page_i  in    number
  ,p_object_version_number         in     number
  );
--
end hr_tcp_api_bk1;

 

/
