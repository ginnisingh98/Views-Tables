--------------------------------------------------------
--  DDL for Package IGR_PERSON_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_PERSON_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRT06S.pls 120.0 2005/06/01 12:44:09 appldev noship $ */

PROCEDURE update_persontype_funnel(
             p_person_id           IN NUMBER,
             p_person_type_code    IN VARCHAR2,
	     p_funnel_status       IN VARCHAR2,
	     p_return_status       OUT NOCOPY VARCHAR2,
	     p_message_text        OUT NOCOPY VARCHAR2) ;

FUNCTION checkactiveXPersontype (
             p_person_id IN NUMBER,
	     p_person_type IN VARCHAR2)
	     RETURN BOOLEAN;

END igr_person_type_pkg;

 

/
