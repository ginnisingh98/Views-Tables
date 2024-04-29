--------------------------------------------------------
--  DDL for Package HR_NZ_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_ELEMENT_ENTRY_HOOK" AUTHID CURRENT_USER as
  --  $Header: penzlhee.pkh 120.0.12010000.1 2008/07/28 05:03:56 appldev ship $
  --
  --  Copyright (C) 2000 Oracle Corporation
  --  All Rights Reserved
  --
  --  NZ HRMS element entry legislative hook package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+------------------------------------------
  --  19 Jan 2000 JTurner  1098494   Now uses CREATOR_ID instead of SOURCE_ID
  --                                 to join element entries to absences
  --  18 JAN 2000 JTURNER  1098494   Created

  --  -------------------------------------------------------------------------
  --  populate_absence_dev_desc_flex procedure
  --  -------------------------------------------------------------------------

  procedure populate_absence_dev_desc_flex
  (p_effective_date                 in     date
  ,p_element_entry_id               in     number
  ,p_creator_type                   in     varchar2
  ,p_element_link_id                in     number
  ,p_creator_id                     in     number) ;

end hr_nz_element_entry_hook ;

/
