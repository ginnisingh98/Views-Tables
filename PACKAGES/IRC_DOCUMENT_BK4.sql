--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BK4" AUTHID CURRENT_USER as
/* $Header: iridoapi.pkh 120.7.12010000.1 2008/07/28 12:41:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_DOCUMENT_TRACK_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT_TRACK_b
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_person_id			   in    number
  ,p_party_id			   in	  number
  ,p_assignment_id		   in    number
  ,p_object_version_number         in     number
  ,p_end_date			   in     date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_DOCUMENT_TRACK_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT_TRACK_a
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_person_id			   in    number
  ,p_party_id			   in	  number
  ,p_assignment_id		   in    number
  ,p_object_version_number         in     number
  ,p_end_date			   in     date
  );
--
end IRC_DOCUMENT_BK4;

/
