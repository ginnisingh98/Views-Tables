--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BK7" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
--
--
-- update_delivered_dates_b
--
Procedure update_delivered_dates_b	(
        p_activity_version_id                  in number,
        p_old_start_date                       in date,
        p_start_date                           in date,
        p_old_end_date                         in date,
        p_end_date                             in date
	);
--
-- create_competence_element_a
--
Procedure update_delivered_dates_a	(
        p_activity_version_id                  in number,
        p_old_start_date                       in date,
        p_start_date                           in date,
        p_old_end_date                         in date,
        p_end_date                             in date
	);

end hr_competence_element_bk7;

 

/
