--------------------------------------------------------
--  DDL for Package PAY_CA_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_ARCHIVE_UTILS" AUTHID CURRENT_USER AS
/* $Header: pycaroep.pkh 120.0.12000000.1 2007/01/17 17:24:43 appldev noship $ */

--
-- Function/Procedures (See Package Body for detailed description)
--


FUNCTION get_archive_value	(p_archive_action_id 	in NUMBER,
				       p_db_name 	in VARCHAR2)
RETURN VARCHAR2;

--
PRAGMA RESTRICT_REFERENCES(get_archive_value, WNDS);
--

FUNCTION get_archive_value	(p_asg_action_id 	in NUMBER,
				       p_context		in VARCHAR2,
					 p_context_name   in VARCHAR2,
					 p_db_name        in VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_archive_value, WNDS);



end pay_ca_archive_utils;


 

/
