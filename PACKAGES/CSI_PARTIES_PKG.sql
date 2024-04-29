--------------------------------------------------------
--  DDL for Package CSI_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PARTIES_PKG" AUTHID CURRENT_USER AS
/* $Header: csixptss.pls 115.2 2002/11/12 00:38:01 rmamidip noship $*/

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
END CSI_PARTIES_PKG;

 

/
