--------------------------------------------------------
--  DDL for Package HR_APPRAISALS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISALS_BK3" AUTHID CURRENT_USER as
/* $Header: peaprapi.pkh 120.5.12010000.4 2009/08/12 14:17:07 rvagvala ship $ */
--
--
--  delete_appraisal_b
--
Procedure delete_appraisal_b
	(
         p_appraisal_id                       in number,
         p_object_version_number              in number
	);
--
-- delete_appraisal_a
--
Procedure delete_appraisal_a
	(
         p_appraisal_id                       in number,
         p_object_version_number              in number
	);

end hr_appraisals_bk3;

/
