--------------------------------------------------------
--  DDL for Package OKC_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QUERY_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCPLCHS.pls 120.0 2005/05/25 22:31:14 appldev noship $*/

--===================
-- TYPES
--===================
-- add your type declarations here if any
--



--===================
-- PACKAGE CONSTANTS
--===================
--
	x_msg_count	NUMBER;
	x_msg_data	VARCHAR2(2000);
	x_return_status	VARCHAR2(1);

--===================
-- LOCAL PROCEDURES AND FUNCTIONS
--===================
--


--===================
-- PACKAGE PROCEDURES AND FUNCTIONS
--===================
--

--
--
FUNCTION GetContractPartyName ( p_contract_id     IN  NUMBER,
                                p_class_code      IN  VARCHAR2)
RETURN VARCHAR2;

--
--
FUNCTION GetContractDisplayAmount ( p_contract_id     IN  NUMBER,
                                    p_class_code      IN  VARCHAR2)
RETURN VARCHAR2;

--
--
FUNCTION SetSublineIndent ( p_contract_id     IN  NUMBER,
                            p_line_id         IN  NUMBER,
                            p_line_descr      IN  VARCHAR2)
RETURN VARCHAR2;

--
--
FUNCTION GetLinePartyName ( p_contract_id     IN  NUMBER,
                            p_line_id         IN  NUMBER)
RETURN VARCHAR2;

--
--
FUNCTION GetChildCount (p_group_id            IN  NUMBER)
RETURN NUMBER;

--
--
FUNCTION GetParentLineNumber ( p_line_id      IN  NUMBER)
RETURN VARCHAR2;

END OKC_QUERY_PVT;

 

/
