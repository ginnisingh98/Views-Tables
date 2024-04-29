--------------------------------------------------------
--  DDL for Package OE_DEFAULTING_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULTING_FWK_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKS.pls 120.0 2005/06/01 01:09:05 appldev noship $ */

-- Performance Bug 1678746:
-- Add parameter p_attribute_code - if this is passed, then generate
-- handler package only for this attribute else generate for the
-- entity and all its attributes.
PROCEDURE Create_Entity_Def_Handler
(

 retcode                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 errbuf                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 p_application_id       IN  VARCHAR2,
 p_database_object_name IN  VARCHAR2,
 p_attribute_code       IN  VARCHAR2 DEFAULT NULL,
 p_generate_all         IN  VARCHAR2 DEFAULT 'Y'
);

PROCEDURE Create_Obj_Attr_Def_Handler
( p_application_id        IN  VARCHAR2,
 p_database_object_name   IN  VARCHAR2,
 p_attribute_code         IN  VARCHAR2,
 p_entity_code            IN  VARCHAR2,
 p_generation_level       IN  VARCHAR2 DEFAULT 'FULL',
 x_defaulting_api_pkg     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


PROCEDURE Assign
(   p_left	IN  VARCHAR2
,   p_right	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
);

PROCEDURE Pkg_Header
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
);

PROCEDURE Pkg_End
(   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
);

PROCEDURE Parameter
(   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'IN'
,   p_type	IN  VARCHAR2 := 'NUMBER'
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
);


PROCEDURE Text
(   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
);

PROCEDURE Comment
(   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER := 1
);

PROCEDURE Create_Entity_Def_Util_Handler
(
 p_application_id         IN VARCHAR2,
 p_database_object_name   IN VARCHAR2,
 p_entity_code            IN VARCHAR2,
 p_application_short_name IN VARCHAR2,
 p_obj_defaulting_enabled IN VARCHAR2  DEFAULT 'Y',
 p_generation_level       IN VARCHAR2  DEFAULT 'FULL'
);

PROCEDURE Create_OE_Def_Hdlr
(
 p_application_id	IN	VARCHAR2 ,
 p_database_object_name	IN	VARCHAR2 ,
 p_entity_code  	IN	VARCHAR2
);

END OE_Defaulting_Fwk_PUB;

 

/
