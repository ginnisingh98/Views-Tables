--------------------------------------------------------
--  DDL for Package PER_MEDICAL_ASSESSMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEDICAL_ASSESSMENT_BK3" AUTHID CURRENT_USER AS
/* $Header: pemeaapi.pkh 120.2 2005/10/22 01:23:54 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_medical_assessment_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_medical_assessment_b
  (p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_medical_assessment_a >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_medical_assessment_a
  (p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  );
--
END per_medical_assessment_bk3;

 

/
