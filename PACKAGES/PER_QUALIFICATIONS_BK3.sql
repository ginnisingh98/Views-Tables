--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pequaapi.pkh 120.1.12010000.3 2009/03/12 11:30:11 dparthas ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_QUALIFICATION_B >-----------------------|
-- ----------------------------------------------------------------------------
--

procedure DELETE_QUALIFICATION_B
  (p_qualification_id              in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_QUALIFICATION_A >-----------------------|
-- ----------------------------------------------------------------------------
--

procedure DELETE_QUALIFICATION_A
  (p_qualification_id              in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  );

end PER_QUALIFICATIONS_BK3;

/
