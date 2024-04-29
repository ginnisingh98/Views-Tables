--------------------------------------------------------
--  DDL for Package OE_CHECKLINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CHECKLINE_PUB" AUTHID CURRENT_USER AS
/*  $Header: OEXCHKLS.pls 120.0 2005/06/01 01:48:26 appldev noship $ */

--  Global constant holding the package name


Procedure Is_Line_Frozen( p_application_id               IN NUMBER,
                          p_entity_short_name            in VARCHAR2,
                          p_validation_entity_short_name in VARCHAR2,
                          p_validation_tmplt_short_name in VARCHAR2,
                          p_record_set_tmplt_short_name in VARCHAR2,
                          p_scope in VARCHAR2,
                          p_result OUT NOCOPY /* file.sql.39 change */ NUMBER );
END;

 

/
