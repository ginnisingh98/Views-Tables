--------------------------------------------------------
--  DDL for Package PER_QUALIFICATION_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATION_EVENT" AUTHID CURRENT_USER as
/* $Header: pequabev.pkh 120.0.12010000.5 2009/03/12 13:13:06 dparthas noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< RAISE_BUSINESS_EVENT >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This raises the Delete Qualification Business Event
--
--
procedure RAISE_BUSINESS_EVENT
  (p_event                         in     varchar2,
   p_qualification_id              in     number,
   p_object_version_number         in     number,
   p_person_id                     in     number
  );
--
end PER_QUALIFICATION_EVENT;

/
