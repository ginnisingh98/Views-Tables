--------------------------------------------------------
--  DDL for Package IRC_DOCUMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DOCUMENT_BK3" AUTHID CURRENT_USER as
/* $Header: iridoapi.pkh 120.7.12010000.1 2008/07/28 12:41:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_DOCUMENT_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_DOCUMENT_b
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  ,p_party_id			   in	  number
  ,p_end_date			   in     Date
  ,p_type                          in     varchar2
  ,p_purge			   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_DOCUMENT_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_DOCUMENT_a
  (p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  ,p_party_id			   in	  number
  ,p_end_date			   in     Date
  ,p_type                          in     varchar2
  ,p_purge			   in     varchar2
  );
--
end IRC_DOCUMENT_BK3;

/
