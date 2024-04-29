--------------------------------------------------------
--  DDL for Package HR_RATING_LEVELS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATING_LEVELS_BK3" AUTHID CURRENT_USER as
/* $Header: pertlapi.pkh 120.1 2005/11/28 03:22:49 dsaxby noship $ */
--
--
--  delete_rating_level_b
--
Procedure delete_rating_level_b
	(
		p_rating_level_id        in   number	,
		p_object_version_number  in   number
	);
--
-- delete_rating_level_a
--
Procedure delete_rating_level_a
	(
		p_rating_level_id        in    number	,
		p_object_version_number  in    number
	);

end hr_rating_levels_bk3;

 

/
