--------------------------------------------------------
--  DDL for Package FND_PII_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PII_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: fndpiuts.pls 120.1 2005/07/02 03:35:29 appldev noship $ */

--  Global constants

-- get the option for the party for a given business purpose code and attribute code
FUNCTION get_purpose_attr_option
(  p_purpose_code	     		 IN  VARCHAR2  DEFAULT NULL	,
   p_privacy_attribute_code      IN  VARCHAR2  DEFAULT NULL,
   p_party_id           	     IN  NUMBER    DEFAULT NULL
) RETURN VARCHAR2;

-- get the option for the party for a given attribute . if person is opted out of any one purpose
-- using the attribute then the return value is 'O'  which is opted out.
FUNCTION get_attribute_option
(  p_privacy_attribute_code      IN  VARCHAR2  DEFAULT NULL,
   p_party_id           	     IN  NUMBER    DEFAULT NULL
) RETURN VARCHAR2;

-- get the option for the party for a given business purpose code
FUNCTION get_purpose_option
(  p_purpose_code	     		 IN  VARCHAR2  DEFAULT NULL	,
   p_party_id           	     IN  NUMBER    DEFAULT NULL
) RETURN VARCHAR2;

END FND_PII_UTILITY_PVT;

 

/
