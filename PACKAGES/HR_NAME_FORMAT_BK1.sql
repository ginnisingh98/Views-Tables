--------------------------------------------------------
--  DDL for Package HR_NAME_FORMAT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAME_FORMAT_BK1" AUTHID CURRENT_USER as
/* $Header: hrnmfapi.pkh 120.7.12010000.2 2008/08/06 08:44:08 ubhat ship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_name_format_b >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_name_format_b
   (p_effective_date                in date
   ,p_format_name                   in varchar2
   ,p_legislation_code              in varchar2
   ,p_user_format_choice            in varchar2
   ,p_format_mask                   in varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_name_format_a >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_name_format_a
   (p_effective_date                in date
   ,p_format_name                   in varchar2
   ,p_legislation_code              in varchar2
   ,p_user_format_choice            in varchar2
   ,p_format_mask                   in varchar2
   ,p_name_format_id                in number
   ,p_object_version_number         in number
   );
end hr_name_format_bk1;

/
