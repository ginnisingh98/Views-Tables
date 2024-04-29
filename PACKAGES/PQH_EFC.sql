--------------------------------------------------------
--  DDL for Package PQH_EFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_EFC" AUTHID CURRENT_USER AS
/* $Header: pqefccon.pkh 120.4 2005/10/05 14:28:04 srajakum noship $ */
--

FUNCTION get_currency_cd
(
 p_primary_key        IN NUMBER,
 p_entity_cd          IN VARCHAR2,
 p_business_group_id  IN NUMBER
) RETURN varchar2;


--

FUNCTION convert_value
(
 p_primary_key        IN   NUMBER,
 p_entity_cd          IN   VARCHAR2,
 p_business_group_id  IN   NUMBER,
 p_unit_value         IN   NUMBER,
 p_column_no          IN   NUMBER
) RETURN number;



--

END; -- Package Specification PQH_EFC

 

/
