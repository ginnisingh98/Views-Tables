--------------------------------------------------------
--  DDL for Package HR_FORM_WINDOWS_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_WINDOWS_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrfwnapi.pkh 120.0 2005/05/31 00:33:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_window_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_window_b
  (p_form_window_id                in number
  ,p_object_version_number         in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_window_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_window_a
  (p_form_window_id                in number
  ,p_object_version_number         in number
  );
--
end hr_form_windows_api_bk2;

 

/
