--------------------------------------------------------
--  DDL for Package CS_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_PARTIES_PKG" AUTHID CURRENT_USER AS
/* $Header: csxptss.pls 115.2 2004/08/25 18:19:27 epajaril ship $ */
FUNCTION Get_Party_Phone
	(
	 p_party_id IN NUMBER,
	 p_telephone_type	IN	VARCHAR2
	)
RETURN VARCHAR2;

FUNCTION Get_Party_Email
	(
		p_party_id IN NUMBER
	)
RETURN VARCHAR2;

FUNCTION Get_Party_Fax
	(
		p_party_id IN NUMBER
	)
RETURN VARCHAR2;
END CS_Parties_PKG;

 

/
