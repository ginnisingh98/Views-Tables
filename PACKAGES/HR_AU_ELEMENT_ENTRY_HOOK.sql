--------------------------------------------------------
--  DDL for Package HR_AU_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_ELEMENT_ENTRY_HOOK" AUTHID CURRENT_USER as
  --  $Header: peaushee.pkh 120.0 2005/05/31 05:58:41 appldev noship $
 --
  --  Copyright (C) 2000 Oracle Corporation
  --  All Rights Reserved
  --
  --  AU HRMS element entry legislative hook package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+-----------------------------------

  --  17 Jun 2001 RAGOVIND  1416342   Created
  --  04 SEP 2001 kaverma             Added procedure update_element_entry_values
  --  -------------------------------------------------------------------
  --  insert_absence_dev_desc_flex procedure
  --  -------------------------------------------------------------------

  procedure insert_absence_dev_desc_flex
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
  ,p_element_link_id                in     number
  ,p_creator_id                     in     number) ;


  --  -------------------------------------------------------------------
  --  update_element_entry_values procedure
  --  -------------------------------------------------------------------

 procedure update_element_entry_values
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
  ,p_creator_id                     in     number);


end hr_au_element_entry_hook ;

 

/
