--------------------------------------------------------
--  DDL for Package HR_PERFORMANCE_RATINGS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERFORMANCE_RATINGS_BK3" AUTHID CURRENT_USER as
/* $Header: peprtapi.pkh 120.2 2006/02/13 14:12:27 vbala noship $ */

-- ---------------------------------------------------------------------------+
-- |--------------------<<delete_performance_rating_b>>------------------- |
-- ---------------------------------------------------------------------------+
Procedure delete_performance_rating_b
	(
		p_performance_rating_id  in  number,
		p_object_version_number  in  number
	);

-- ---------------------------------------------------------------------------+
-- |--------------------<<delete_performance_rating_a>>------------------- |
-- ---------------------------------------------------------------------------+
Procedure delete_performance_rating_a
	(
		p_performance_rating_id    in  number,
		p_object_version_number    in  number
	);

end hr_performance_ratings_bk3;

 

/
