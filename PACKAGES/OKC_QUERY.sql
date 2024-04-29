--------------------------------------------------------
--  DDL for Package OKC_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QUERY" AUTHID CURRENT_USER AS
/*$Header: OKCQURYS.pls 120.0 2005/05/26 09:39:22 appldev noship $*/

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

FUNCTION GetKid (p_notification_id  IN  NUMBER,
	         p_att_name         IN  VARCHAR2)
RETURN NUMBER;

--
--

FUNCTION GetKnumber (p_notification_id  IN  NUMBER,
		     p_att_name         IN  VARCHAR2)
RETURN VARCHAR2;

--
--
--MMadhavi added GetKmodifier
--
--

FUNCTION GetKmodifier (p_notification_id  IN  NUMBER,
		       p_att_name         IN  VARCHAR2)
RETURN VARCHAR2;

--
--

FUNCTION GetParentLineNumber ( p_line_id      IN  NUMBER)
RETURN VARCHAR2;

--
--
FUNCTION GetAuthorFormName  (p_class_code  IN  VARCHAR2)
RETURN VARCHAR2;


--
--
FUNCTION GetContractVersion  (p_contract_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION GetGroupName  (p_contract_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION GET_NUMBER(p_string IN VARCHAR2) RETURN NUMBER;


FUNCTION GET_K_ROLE_PARTY(p_contract_id IN NUMBER
					,p_party_role  IN VARCHAR2
					,p_party_name  IN VARCHAR2 := OKC_API.G_MISS_CHAR) RETURN BOOLEAN;

FUNCTION Get_Contract_Number(p_rtv_id  IN NUMBER )
RETURN VARCHAR2;

FUNCTION Get_Source_Doc_Number( p_coe_id IN NUMBER ) RETURN VARCHAR2;

--
--
FUNCTION GetFormFunctionName  (p_subclass_code  IN  VARCHAR2,
                               p_operation      IN VARCHAR2)
RETURN VARCHAR2;

--
--
--PROCEDURE GetEbizLinkName(x_function_name out varchar2);
FUNCTION GetEbizLinkName
--(p_col_name  IN  VARCHAR2)
RETURN VARCHAR2;

/* Added new function for Bug#2323327 */

FUNCTION  GetClassFunctionName ( p_cls_code  IN  VARCHAR2,
                                p_operation      IN VARCHAR2)
RETURN VARCHAR2 ;

--
--  function get_contact (moved here from OKC_RULE_PUB)
--
--  returns HZ_PARTIES related contacts points
--  otherwise (or if not found) returns contact description
--  through jtf_objects_vl
--
--  all parameters are regular jtf_objects related
--

function get_contact(
	p_object_code in varchar2,
	p_object_id1 in varchar2,
	p_object_id2 in varchar2
        )
return varchar2;

  FUNCTION GET_ADDRESS(
        p_object_code IN VARCHAR2,
        p_object_id1 in varchar2,
        p_object_id2 in varchar2,
        ADR_TYPE VARCHAR2 := 'MAIN'  -- ADDRESS TYPE : 'MAIN', 'BILL', 'SHIP'
  ) RETURN VARCHAR2;

  FUNCTION GET_EMAIL_FROM_JTFV(
        p_object_code IN VARCHAR2,
        p_object_id1 in varchar2,
        p_object_id2 in varchar2
  ) RETURN VARCHAR2;

  function get_contact_info(
        p_object_code in varchar2,
        p_object_id1 in varchar2,
        p_object_id2 in varchar2,
        p_info_type in varchar2     -- 'EMAIL', 'PHONE', 'FAX'
  ) return varchar2;

END OKC_QUERY;


 

/
