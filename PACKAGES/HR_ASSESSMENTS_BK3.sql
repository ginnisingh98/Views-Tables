--------------------------------------------------------
--  DDL for Package HR_ASSESSMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: peasnapi.pkh 120.1 2005/10/02 02:11:35 aroussel $ */
--
-- --------------------------------------------------------------------------
-- |------------------------< delete_assessment_b >-------------------------|
-- --------------------------------------------------------------------------

Procedure delete_assessment_b
	(
        p_assessment_id                 in number,
        p_object_version_number         in number
	);
-- --------------------------------------------------------------------------
-- |------------------------< delete_assessment_a >-------------------------|
-- --------------------------------------------------------------------------


Procedure delete_assessment_a
	(
        p_assessment_id                 in number,
        p_object_version_number         in number
	);

end hr_assessments_bk3;

 

/
