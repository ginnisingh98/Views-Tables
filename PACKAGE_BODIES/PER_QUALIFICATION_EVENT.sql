--------------------------------------------------------
--  DDL for Package Body PER_QUALIFICATION_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUALIFICATION_EVENT" as
/* $Header: pequabev.pkb 120.0.12010000.4 2009/03/12 13:13:46 dparthas noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_QUALIFICATION_EVENT.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< RAISE_BUSINESS_EVENT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure RAISE_BUSINESS_EVENT
  (p_event                         in     varchar2,
   p_qualification_id              in     number,
   p_object_version_number         in     number,
   p_person_id                     in     number
  )
is
  l_proc                varchar2(72) := g_package||'RAISE_BUSINESS_EVENT';
begin
  IF p_event = 'DELETE' THEN
    per_qualifications_be3.delete_qualification_a
      (p_qualification_id      => p_qualification_id,
       p_object_version_number => p_object_version_number,
       p_person_id             => p_person_id);
  END IF;
end RAISE_BUSINESS_EVENT;
--
end PER_QUALIFICATION_EVENT;

/
