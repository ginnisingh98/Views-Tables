--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BK1" AUTHID CURRENT_USER as
/* $Header: iridoapi.pkh 120.7.12010000.1 2008/07/28 12:41:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_DOCUMENT_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_DOCUMENT_b
  (p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_end_date			   in     Date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CREATE_DOCUMENT_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_DOCUMENT_a
  (p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_document_id                   in     number
  ,p_object_version_number         in     number
  ,p_end_date			   in     Date
  );
--
end IRC_DOCUMENT_BK1;

/
