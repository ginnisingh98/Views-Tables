--------------------------------------------------------
--  DDL for Package HR_RATING_SCALES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_SCALES_BK3" AUTHID CURRENT_USER as
/* $Header: perscapi.pkh 120.1 2005/11/28 03:22:27 dsaxby noship $ */
--
--
--  delete_rating_scale_b
--
Procedure delete_rating_scale_b
	(
		p_rating_scale_id        in    number	,
		p_object_version_number  in    number
	);
--
-- delete_rating_scale_a
--
Procedure delete_rating_scale_a
	(
		p_rating_scale_id       in   number	,
		p_object_version_number in   number
	);

end hr_rating_scales_bk3;

 

/
