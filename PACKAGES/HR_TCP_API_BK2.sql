--------------------------------------------------------
--  DDL for Package HR_TCP_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TCP_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrtcpapi.pkh 120.0 2005/05/31 02:59:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_template_item_context_page_b >--------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tcp_b
  (p_template_item_context_page_i  in    number
  ,p_object_version_number         in number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_template_item_context_page_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tcp_a
  (p_template_item_context_page_i  in    number
  ,p_object_version_number         in number
  );
--
end hr_tcp_api_bk2;

 

/
