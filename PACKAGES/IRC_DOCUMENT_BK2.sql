--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BK2" AUTHID CURRENT_USER as
/* $Header: iridoapi.pkh 120.7.12010000.1 2008/07/28 12:41:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_DOCUMENT_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT_b
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< UPDATE_DOCUMENT_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT_a
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_type                          in     varchar2
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_description                   in     varchar2
  ,p_object_version_number         in     number
  );
--
end IRC_DOCUMENT_BK2;

/
