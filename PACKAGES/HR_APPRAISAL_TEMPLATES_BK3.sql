--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_TEMPLATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_TEMPLATES_BK3" AUTHID CURRENT_USER as
/* $Header: peaptapi.pkh 120.4.12010000.6 2010/02/09 15:05:01 psugumar ship $ */
--
-- --------------------------------------------------------------------------
-- |-----------------------< delete_appraisal_template_b >------------------|
-- --------------------------------------------------------------------------

Procedure delete_appraisal_template_b
	(
       p_appraisal_template_id              in number,
       p_object_version_number              in number
	);
-- --------------------------------------------------------------------------
-- |-----------------------< delete_appraisal_template_a >------------------|
-- --------------------------------------------------------------------------

Procedure delete_appraisal_template_a
	(
       p_appraisal_template_id              in number,
       p_object_version_number              in number
	);

end hr_appraisal_templates_bk3;

/
