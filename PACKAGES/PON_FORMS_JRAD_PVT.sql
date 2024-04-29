--------------------------------------------------------
--  DDL for Package PON_FORMS_JRAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_FORMS_JRAD_PVT" AUTHID CURRENT_USER AS
-- $Header: PONFMJRS.pls 120.0 2005/06/01 17:22:36 appldev noship $

PROCEDURE CREATE_JRAD(	p_form_id 	IN 		NUMBER,
  			x_result	OUT NOCOPY  	VARCHAR2,
  			x_error_code    OUT NOCOPY  	VARCHAR2,
  			x_error_message OUT NOCOPY  	VARCHAR2
 );


END PON_FORMS_JRAD_PVT;

 

/
