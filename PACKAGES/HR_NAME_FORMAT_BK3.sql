--------------------------------------------------------
--  DDL for Package HR_NAME_FORMAT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAME_FORMAT_BK3" AUTHID CURRENT_USER as
/* $Header: hrnmfapi.pkh 120.7.12010000.2 2008/08/06 08:44:08 ubhat ship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_name_format_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_name_format_b
   (p_name_format_id                in number
   ,p_object_version_number         in number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_name_format_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_name_format_a
   (p_name_format_id                in number
   ,p_object_version_number         in number
   );
end hr_name_format_bk3;

/
