--------------------------------------------------------
--  DDL for Package Body OKC_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QUERY_PVT" AS
/*$Header: OKCPLCHB.pls 120.0 2005/05/26 09:38:47 appldev noship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

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
-- ---------------------------------------------------------------------------------
-- FUNCTION: GetContractPartyName                                                 --
-- DESCRIPTION:     --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                       --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION GetContractPartyName ( p_contract_id     IN  NUMBER,
                                p_class_code      IN  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
   return 'ContractName TBD';

END    GetContractPartyName;


--

--
-- ---------------------------------------------------------------------------------
-- FUNCTION: GetContractAmountDisplay                                             --
-- DESCRIPTION:     --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                       --
--                                                                                --
-- -
--
FUNCTION GetContractDisplayAmount ( p_contract_id     IN  NUMBER,
                                    p_class_code      IN  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
    return '1.00 USD';

END    GetContractDisplayAmount;


--
-- ---------------------------------------------------------------------------------
-- FUNCTION: SetSublineIndent                                                     --
-- DESCRIPTION:     --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                       --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION SetSublineIndent ( p_contract_id     IN  NUMBER,
                            p_line_id         IN  NUMBER,
                            p_line_descr      IN  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
   return '-->' || p_line_descr;

END    SetSublineIndent;


--
-- ---------------------------------------------------------------------------------
-- FUNCTION: GetContractPartyName                                                 --
-- DESCRIPTION:     --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                       --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION GetLinePartyName ( p_contract_id     IN  NUMBER,
                            p_line_id         IN  NUMBER)
RETURN VARCHAR2 IS

BEGIN
   return 'LineName TBD';

END    GetLinePartyName;


--
-- ---------------------------------------------------------------------------------
-- FUNCTION: GetParentLineNUMber                                                --
-- DESCRIPTION:     --
--            using the record passed                                             --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                       --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
--
FUNCTION GetParentLineNumber ( p_line_id      IN  NUMBER)
RETURN VARCHAR2 IS

BEGIN
   return 'TBD';

END    getParentLineNumber;



--
-- ---------------------------------------------------------------------------------
-- FUNCTION: GetChildCount                                                        --
-- DESCRIPTION:  gets a count of the number of child groups in OKC_K_GRPINGS      --
--            using the recordid passed                                           --
-- DEPENDENCIES: none                                                             --
-- CHANGE HISTORY:                                                                --
--                                                                                --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION GetChildCount (p_group_id            IN  NUMBER)
RETURN NUMBER IS

   CURSOR cg(p_id  IN  NUMBER) IS
           select count(*)
             from okc_k_grpings
            where cgp_parent_id = p_id;
   ret        NUMBER;

BEGIN
  ret := 0;
  open cg(p_group_id);
  fetch cg into ret;
  close cg;
  return ret;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      return 0;
  WHEN OTHERS THEN
      raise_application_error(-20471,'Exception in GetChildCount for ' || to_char(p_group_id)
                              , TRUE);

END   GetChildCount;

END OKC_QUERY_PVT;

/
