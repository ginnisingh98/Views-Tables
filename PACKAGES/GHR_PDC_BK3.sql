--------------------------------------------------------
--  DDL for Package GHR_PDC_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDC_BK3" AUTHID CURRENT_USER as
/* $Header: ghpdcapi.pkh 120.2 2005/10/02 01:58:10 aroussel $ */
--
--
-- delete_pdc_b
--
Procedure delete_pdc_b	(
	p_pd_classification_id      IN  number,
	p_pdc_object_version_number IN  number
	);
--
-- delete_pdc_a
--
Procedure delete_pdc_a	(
	p_pd_classification_id      IN  number,
	p_pdc_object_version_number IN  number
	);

end ghr_pdc_bk3;

 

/
