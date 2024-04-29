--------------------------------------------------------
--  DDL for Package PV_ATTRIBUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ATTRIBUTE_UTIL" AUTHID CURRENT_USER AS
/* $Header: pvxvauts.pls 120.1 2005/09/01 12:55:44 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ATTRIBUTE_UTIL
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================




---------------------------------------------------------------------
-- FUNCTION
--    GET_ATTR_VALUES_HISTORY
--
-- PURPOSE
--    Based on the attribute_id, entity, entity_id, This function returns the attribute values appended with comma.
--
-- PARAMETERS
--    attribute_id, entity, entity_id
--    returns values separated by comma as varchar2
--
-- NOTES
--
---------------------------------------------------------------------

TYPE lov_data_rec_type IS RECORD
(
	code		VARCHAR2(30) ,
	meaning		VARCHAR2(4000),
	description	VARCHAR2(240)

);

g_miss_lov_data_rec          lov_data_rec_type;
TYPE  lov_data_tbl_type      IS TABLE OF lov_data_rec_type INDEX BY BINARY_INTEGER;
g_miss_lov_data_tbl          lov_data_tbl_type;

g_user_currency_code       CONSTANT VARCHAR(30)	:=nvl(fnd_profile.value('ICX_PREFERRED_CURRENCY'), 'USD');

FUNCTION GET_ATTR_VALUES_HISTORY (      p_attribute_id     NUMBER,
                                        p_entity   VARCHAR2,
                                        p_entity_id     NUMBER,
					p_version	NUMBER,
					p_attr_data_type VARCHAR2,
					p_lov_string	VARCHAR2,
					p_user_date_format VARCHAR2
				 )
RETURN VARCHAR2 DETERMINISTIC;


FUNCTION GET_ATTR_VALUES (		p_attribute_id     NUMBER,
                                        p_entity   VARCHAR2,
                                        p_entity_id     NUMBER,
					p_attr_data_type VARCHAR2,
					p_lov_string	VARCHAR2,
					p_is_snap_shot	VARCHAR2,
					p_snap_shot_date	VARCHAR2,
					p_user_date_format  VARCHAR2
				 )
RETURN VARCHAR2 DETERMINISTIC;



END PV_ATTRIBUTE_UTIL;

 

/
