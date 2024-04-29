--------------------------------------------------------
--  DDL for Package AR_FIRSTPARTY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_FIRSTPARTY_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARXLESTS.pls 120.1 2004/12/03 22:55:21 orashid noship $ */


-----------------------------------------------------------------
-- PROCEDURE GET_LEGAL_ENTITY_ID_OU
-- Use this instead of XLE_FIRSTPARTY_UTILS.GET_LEGAL_ENTITY_ID_OU
--  to retrieve the value of legal_entity_id for org_id
-----------------------------------------------------------------
PROCEDURE GET_LEGAL_ENTITY_ID_OU
	(p_operating_unit   IN number,
	 p_legal_entity_id  OUT NOCOPY number
	);


END AR_FIRSTPARTY_UTILS;

 

/
