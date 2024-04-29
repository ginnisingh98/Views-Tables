--------------------------------------------------------
--  DDL for Package Body OKC_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QUERY" AS
/*$Header: OKCQURYB.pls 120.2 2007/11/03 10:15:39 vgujarat ship $*/

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
-- Changed by msengupt on 02/09/2001 regarding deruving the new line name
-- Earlier version had dummy code as
--   return '-->' || p_line_descr;
--FUNCTION SetSublineIndent ( p_contract_id     IN  NUMBER,
--                            p_line_id         IN  NUMBER,
--                            p_line_descr      IN  VARCHAR2)
--   RETURN VARCHAR2 IS
--   IS
--   return '-->' || p_line_descr;
--END    SetSublineIndent;

FUNCTION SetSublineIndent ( p_contract_id     IN  NUMBER,
                            p_line_id         IN  NUMBER,
                            p_line_descr      IN  VARCHAR2)
   RETURN VARCHAR2 IS
  l_object1_id1 VARCHAR2(40);
  l_object1_id2 VARCHAR2(200);
  l_object_code VARCHAR2(30);
  --l_name	VARCHAR2(150);
  l_name        VARCHAR2(255);
  l_found       BOOLEAN;

  Cursor l_cimv_csr(p_cle_id NUMBER) Is
	SELECT
		cimv.OBJECT1_ID1,
		cimv.OBJECT1_ID2,
		cimv.JTOT_OBJECT1_CODE
	FROM OKC_K_ITEMS cimv
	WHERE cimv.CLE_ID = p_cle_id;
  BEGIN
   if p_line_descr is NOT NULL Then
	return p_line_descr;
   end if;
   l_name := NULL;
   open l_cimv_csr(p_line_id);
   fetch l_cimv_csr into l_object1_id1, l_object1_id2, l_object_code;
   l_found := l_cimv_csr%FOUND;
   close l_cimv_csr;
   If (l_found = TRUE) Then
     If (l_object1_id1 is not null) Then
	/* Short term solution - should be done at the Header level */
--		OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => p_contract_id);
         l_name := OKC_UTIL.get_name_from_jtfv(l_object_code, l_object1_id1, l_object1_id2);
     End If;
   End If;
   return l_name;

EXCEPTION
  when OTHERS then
    l_name := NULL;
    return l_name;

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
/*
   CURSOR cg(p_id  IN  NUMBER) IS
           select
		   count(*)
             from okc_k_grpings
            where cgp_parent_id = p_id
		   and included_chr_id is NULL;
*/
   CURSOR cg(p_id  IN  NUMBER) IS
           select /*+ FIRST_ROWS */
		   1
             from okc_k_grpings
            where cgp_parent_id = p_id
		   and included_cgp_id is NOT NULL;
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

---------------------------------------------------------------------
-- FUNCTION: GetKid
-- DESCRIPTION : Gets the contract number from the attribute value
--               from wf_notification_attributes for a notification_id
--               used in launchpad_inbox_view.
----------------------------------------------------------------------

FUNCTION GetKid(p_notification_id IN NUMBER,
	         p_att_name IN VARCHAR2)
RETURN NUMBER
IS
/*nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* v_id  okc_k_headers_b.id%TYPE; */
v_id  okc_k_headers_all_b.id%TYPE;
-- end bug # 4666846
BEGIN

   v_id := wf_notification.getattrnumber(p_notification_id,
				       p_att_name);
   IF v_id IS NOT NULL THEN
     RETURN(v_id);
   ELSE
     RETURN(NULL);
   END IF;

EXCEPTION
  when others then
    RETURN(NULL);
END GetKid;


---------------------------------------------------------------------
-- FUNCTION: GetKnumber
-- DESCRIPTION : Gets the contract number from the attribute value
--               from wf_notification_attributes for a notification_id
--               used in launchpad_inbox_view.
----------------------------------------------------------------------
FUNCTION GetKnumber(p_notification_id IN NUMBER,
		    p_att_name IN VARCHAR2)

RETURN VARCHAR2 is
CURSOR k_cur(x in number)
IS
select k.contract_number
/*nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* from okc_k_headers_b k  */
from okc_k_headers_all_b k
--end bug # 4666846
where k.id = x;
k_rec     k_cur%ROWTYPE;
/*nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* v_id      okc_k_headers_b.id%TYPE;
x_knumber okc_k_headers_b.contract_number%TYPE; */
v_id      okc_k_headers_all_b.id%TYPE;
x_knumber okc_k_headers_all_b.contract_number%TYPE;
--end bug # 4666846
BEGIN

   v_id := wf_notification.getattrnumber(p_notification_id,
				       p_att_name);
   IF v_id IS NOT NULL THEN
     OPEN k_cur(v_id);
     FETCH k_cur INTO k_rec;
       x_knumber := k_rec.contract_number;
     CLOSE k_cur;
       RETURN(x_knumber);
   ELSE
     x_knumber := 'Not Available';
     RETURN(x_knumber);
   END IF;

EXCEPTION
  when others then
    x_knumber := 'Not Available';
    RETURN(x_knumber);
END GetKnumber;

--
--
--mmadhavi added GetKmodifier
---------------------------------------------------------------------------
-- FUNCTION: GetKnumber
-- DESCRIPTION : Gets the contract number modifier from the attribute value
--               from wf_notification_attributes for a notification_id
--               used in launchpad_inbox_view.
---------------------------------------------------------------------------
FUNCTION GetKmodifier(p_notification_id IN NUMBER,
		      p_att_name IN VARCHAR2)

RETURN VARCHAR2 is
CURSOR k_cur(x in number)
IS
select k.contract_number_modifier
/*nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* from okc_k_headers_b k */
from okc_k_headers_all_b k
-- end bug # 4666846
where k.id = x;
k_rec     k_cur%ROWTYPE;
/*nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* v_id      okc_k_headers_b.id%TYPE;
x_knumber okc_k_headers_b.contract_number_modifier%TYPE; */
v_id      okc_k_headers_all_b.id%TYPE;
x_knumber okc_k_headers_all_b.contract_number_modifier%TYPE;
-- end bug # 4666846
BEGIN

   v_id := wf_notification.getattrnumber(p_notification_id,
				         p_att_name);
   IF v_id IS NOT NULL THEN
     OPEN k_cur(v_id);
     FETCH k_cur INTO k_rec;
       x_knumber := k_rec.contract_number_modifier;
     CLOSE k_cur;
       RETURN(x_knumber);
   ELSE
     x_knumber := 'Not Available';
     RETURN(x_knumber);
   END IF;

EXCEPTION
  when others then
    x_knumber := 'Not Available';
    RETURN(x_knumber);
END GetKmodifier;

--
--

-- ================================================================================== --
--                                                                                    --
-- GetAuthorFormName
-- DESCRIPTION: gets the Authoring form name for the Class code passed                --
--                                                                                    --
-- ================================================================================== --
--
FUNCTION  GetAuthorFormName ( p_class_code  IN  VARCHAR2) RETURN VARCHAR2 IS

    CURSOR s (c_code  IN  VARCHAR2) IS
	 SELECT fct.function_name
	   FROM okc_classes_b cls,
		   fnd_form_functions fct
       WHERE cls.code = c_code
         AND cls.fff_function_id = fct.function_id;

    fct_name   FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE := null;

BEGIN
   OPEN s (p_class_code);
   FETCH s INTO fct_name;
   CLOSE s;

   return fct_name;

EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		 IF s%ISOPEN THEN
		    close s;
		    return 'none found';
           ELSE
		    return 'none found';
           END IF;

END   GetAuthorFormName;



--
--
-- ==================================================================================== --
--                                                                                      --
--  FUNCTION: GetContractVersion                                                        --
--  DESCRIPTION: returns the major/minor versions in a formated string for the          --
--               the contract id passed                                                 --
--                                                                                      --
-- ==================================================================================== --
--
FUNCTION GetContractVersion (p_contract_id   IN  NUMBER)
RETURN VARCHAR2 IS

  CURSOR s (k_id  IN  NUMBER) IS
    SELECT major_version
		 ,minor_version
      FROM okc_k_vers_numbers
     WHERE chr_id = k_id;

	maj_ver     NUMBER(4) := 0;
	min_ver     NUMBER := 0;

BEGIN
    OPEN s(p_contract_id);
    FETCH s into maj_ver, min_ver;
    CLOSE s;

    return ltrim(to_char(maj_ver,'9999')) || '.' || ltrim(to_char(min_ver));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	    IF s%ISOPEN THEN
             close s;
             return 'none';
         ELSE
             return 'none';
         END IF;


END  GetContractVersion;

FUNCTION GetGroupName (p_contract_id            IN  NUMBER)
RETURN VARCHAR2 IS

   CURSOR cg(p_contract_id  IN  NUMBER) IS
           select g.name
             from okc_k_grpings, okc_k_groups_v g
            where included_chr_id = p_contract_id
		    and cgp_parent_id = g.id and
			   ((g.public_YN  = 'Y') or
			    (g.public_YN = 'N' and user_id = FND_GLOBAL.USER_ID));
   gpname        VARCHAR2(300);
   cnt        NUMBER := 0;

BEGIN
  gpname := 0;
  open cg(p_contract_id);
  LOOP
  fetch cg into gpname;
  EXIT WHEN cg%NOTFOUND;
  cnt := cnt + 1;
  if cnt = 2 then
    exit;
  end if;
  END LOOP;
  close cg;
  if cnt = 0 then
   return NULL;
  elsif cnt = 2 then
   return '*';
  else
   return gpname;
  end if;

EXCEPTION
  WHEN OTHERS THEN
   return '?????';

END   GetGroupName;

FUNCTION get_number(p_string IN VARCHAR2)
   RETURN NUMBER IS
    l_number  NUMBER;
   BEGIN
    l_number := TO_NUMBER(p_string);
    RETURN (l_number);
   EXCEPTION
    WHEN OTHERS THEN
       RETURN  1;
   END get_number;


-- Returns TRUE if role or role and party are in a given contract.
FUNCTION GET_K_ROLE_PARTY(p_contract_id IN NUMBER
					,p_party_role  IN VARCHAR2
					,p_party_name  IN VARCHAR2) RETURN BOOLEAN IS

-- Variables
   l_party_name  VARCHAR2(60);

-- Cursors
   CURSOR pty_csr IS
   SELECT kpr.rle_code, kpr.object1_id1, kpr.object1_id2, kpr.jtot_object1_code
   FROM   okc_k_party_roles_v kpr
   WHERE  dnz_chr_id = p_contract_id
   AND    rle_code   = p_party_role;


BEGIN

  FOR r_pty_csr IN pty_csr LOOP

    IF p_party_name <> OKC_API.G_MISS_CHAR THEN

	  l_party_name := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => r_pty_csr.jtot_object1_code
										,p_id1         => r_pty_csr.object1_id1
										,p_id2         => r_pty_csr.object1_id2 );

	  IF l_party_name = p_party_name THEN -- role and party exist in contract
          RETURN(TRUE);
       END IF;

    ELSE -- role exists in contract
	 RETURN(TRUE);
    END IF;

  END LOOP;

  RETURN(FALSE); -- role or role and party not found in contract

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(FALSE);

END; -- FUNCTION GET_K_ROLE_PARTY


FUNCTION Get_Contract_Number(p_rtv_id  IN NUMBER )
RETURN VARCHAR2 IS

/*
  This function takes the resolved_timevalues ID as input and
  returns the contract number.
*/
/* nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
/* l_contract_number   okc_k_headers_b.contract_number%TYPE;*/
l_contract_number   okc_k_headers_all_b.contract_number%TYPE;
--end bug # 4666846

CURSOR csr_k_no IS
SELECT k.contract_number
FROM  okc_resolved_timevalues_v rtv,
      okc_timevalues   tve,
/* nechatur 18-oct-2005 bug # 4666846  replacing  okc_k_headers_b to okc_k_headers_all_b */
     /* okc_k_headers_b  k */
     okc_k_headers_all_b  k
     -- end #4666846
WHERE rtv.tve_id = tve.id
  AND tve.dnz_chr_id = k.id
  AND rtv.id = p_rtv_id;


BEGIN

  OPEN csr_k_no;
    FETCH csr_k_no INTO l_contract_number;
  CLOSE csr_k_no;

  RETURN l_contract_number;

EXCEPTION
  WHEN OTHERS THEN
   RETURN null;
END; -- end Get_Contract_Number

FUNCTION Get_source_doc_number(p_coe_id  IN NUMBER ) RETURN VARCHAR2 IS
--
--  This function takes the condition occurrence id as input and
--  returns the the document source number (e.g. contract number).
--  Used by Events to set the document number when creating a task.
--

l_source_doc_number_yn   VARCHAR2(200);
l_acn_id              OKC_ACTIONS_V.ID%TYPE;
l_cnh_id              OKC_CONDITION_HEADERS_V.ID%TYPE;
l_aae_id              OKC_ACTION_ATTRIBUTES_V.ID%TYPE;
l_aae_value           OKC_ACTION_ATT_VALS_V.VALUE%TYPE;

CURSOR c_cnh_id IS
SELECT cnh_id
FROM   okc_condition_occurs
WHERE  id = p_coe_id;

CURSOR c_acn_id IS
SELECT acn_id
FROM   okc_condition_headers_b
where  id = l_cnh_id;

CURSOR c_aae_id IS
SELECT id
FROM   okc_action_attributes_b
WHERE  acn_id = l_acn_id
AND    source_doc_number_yn = 'Y';

CURSOR c_aae_value IS
SELECT value
FROM   okc_action_att_vals
WHERE  aae_id = l_aae_id
AND    coe_id = p_coe_id;

BEGIN

  -- get the condition header id
  OPEN  c_cnh_id;
  FETCH c_cnh_id INTO l_cnh_id;
     IF c_cnh_id%NOTFOUND THEN
        return p_coe_id;
     END IF;
  CLOSE c_cnh_id;

  -- get the action id used in the condition
  OPEN  c_acn_id;
  FETCH c_acn_id INTO l_acn_id;
     IF c_acn_id%NOTFOUND THEN
        return p_coe_id;
     END IF;
  CLOSE c_acn_id;

  -- get each attribute that is marked as a document source number
  FOR r_aae_id IN c_aae_id LOOP

      l_aae_id := r_aae_id.id;

      -- get the value of the action attribute
      FOR r_aae_value IN c_aae_value LOOP
          IF r_aae_value.value IS NULL THEN
             EXIT;
          END IF;
          IF l_aae_value IS NOT NULL THEN
             l_aae_value := l_aae_value ||' '|| r_aae_value.value;
          ELSE
             l_aae_value := r_aae_value.value;
          END IF;
      END LOOP; -- c_aae_value
  END LOOP; -- c_aae_id

  IF l_aae_value IS NOT NULL THEN
     return l_aae_value;
  ELSE
     return p_coe_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   RETURN p_coe_id;
END; -- end Get_source_doc_number


--
--
-- ================================================================================== --
--                                                                                    --
-- GetFormFunctionName
-- DESCRIPTION: gets the form function name for the Class code passed                --
--                                                                                    --
-- ================================================================================== --
--
FUNCTION  GetFormFunctionName ( p_subclass_code  IN  VARCHAR2,
                                p_operation      IN VARCHAR2)
RETURN VARCHAR2 IS

    CURSOR s (c_subclass_code  IN  VARCHAR2,
              c_operation      IN  VARCHAR2) IS
	 SELECT fct.function_name
	   FROM okc_subclasses_b scls,
                okc_class_operations opr,
	        fnd_form_functions fct
       WHERE scls.code = c_subclass_code
         AND scls.cls_code = opr.cls_code
         AND opr.opn_code = c_operation
         AND opr.detail_function_id = fct.function_id;

    fct_name   FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE := null;

BEGIN
   OPEN s (p_subclass_code,p_operation);
   FETCH s INTO fct_name;
   CLOSE s;

   return fct_name;

EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		 IF s%ISOPEN THEN
		    close s;
		    return NULL;
           ELSE
		    return NULL;
           END IF;

END   GetFormFunctionName;


--
--
/*
PROCEDURE GetEbizLinkName ( x_function_name out nocopy VARCHAR2) IS
BEGIN
   x_function_name :=  'OKC_KPRINT_JSP';

END    getEbizLinkName;
*/


FUNCTION GetEbizLinkName
--( p_col_name IN VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
   return 'OKC_KPRINT_JSP';

END    getEbizLinkName;

/* Added new function for Bug#2323327 */

FUNCTION  GetClassFunctionName ( p_cls_code  IN  VARCHAR2,
                                p_operation      IN VARCHAR2)
RETURN VARCHAR2 IS

    CURSOR s (c_cls_code  IN  VARCHAR2,
              c_operation      IN  VARCHAR2) IS
	 SELECT fct.function_name
	   FROM okc_class_operations opr,
	        fnd_form_functions fct
       WHERE opr.cls_code = c_cls_code
         AND opr.opn_code = c_operation
         AND opr.detail_function_id = fct.function_id;

    fct_name   FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE := null;

BEGIN
   OPEN s (p_cls_code,p_operation);
   FETCH s INTO fct_name;
   CLOSE s;

   return fct_name;

EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		 IF s%ISOPEN THEN
		    close s;
		    return NULL;
           ELSE
		    return NULL;
           END IF;

END   GetClassFunctionName;

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
return varchar2 is
  L_MESSAGE varchar2(2000);
  L_EMAIL_ADDRESS varchar2(100);
  L_PHONE_COUNTRY_CODE varchar2(100);
  L_PHONE_AREA_CODE varchar2(100);
  L_PHONE_NUMBER varchar2(100);
  L_PHONE_EXTENSION varchar2(100);
  L_FAX_COUNTRY_CODE varchar2(100);
  L_FAX_AREA_CODE varchar2(100);
  L_FAX_NUMBER varchar2(100);
  L_FAX_EXTENSION varchar2(100);
cursor l_primary_contact_phone_csr(pcode varchar2, pid number) is
  select
    EMAIL_ADDRESS,
    PHONE_COUNTRY_CODE,
    PHONE_AREA_CODE,
    PHONE_NUMBER,
    PHONE_EXTENSION
  from okx_contact_points_v
  where PRIMARY_FLAG = 'Y'
    and owner_table_name = 'HZ_PARTIES'
    and owner_table_id = pid
    and pcode = 'OKX_PCONTACT'
;
cursor l_primary_contact_fax_csr(pid number) is
  select
    PHONE_COUNTRY_CODE 	FAX_COUNTRY_CODE,
    PHONE_AREA_CODE 	FAX_AREA_CODE,
    PHONE_NUMBER 	FAX_NUMBER,
    PHONE_EXTENSION 	FAX_EXTENSION
  from okx_contact_points_v
  where PHONE_LINE_TYPE = 'FAX'
    and owner_table_name = 'HZ_PARTIES'
    and owner_table_id = pid
    and status = 'A'
;
   --
   l_proc varchar2(72) := 'OKC_QUERY.get_contact';
   --

begin




  open l_primary_contact_phone_csr(p_object_code, p_object_id1);
  fetch l_primary_contact_phone_csr into L_EMAIL_ADDRESS,L_PHONE_COUNTRY_CODE,L_PHONE_AREA_CODE,L_PHONE_NUMBER,L_PHONE_EXTENSION;
  close l_primary_contact_phone_csr;
  if (L_PHONE_NUMBER is null) then




    return OKC_RULE_PUB.get_object_dsc(p_object_code, p_object_id1, p_object_id2);
  end if;

  open l_primary_contact_fax_csr(p_object_id1);
  fetch l_primary_contact_fax_csr into L_FAX_COUNTRY_CODE,L_FAX_AREA_CODE,L_FAX_NUMBER,L_FAX_EXTENSION;
  close l_primary_contact_fax_csr;

  FND_MESSAGE.SET_NAME(application => 'OKC', name => 'OKC_GET_CONTACT');
    FND_MESSAGE.SET_TOKEN(token => 'EMAIL_ADDRESS'	, value => L_EMAIL_ADDRESS);
    FND_MESSAGE.SET_TOKEN(token => 'PHONE_COUNTRY_CODE'	, value => L_PHONE_COUNTRY_CODE);
    FND_MESSAGE.SET_TOKEN(token => 'PHONE_AREA_CODE'	, value => L_PHONE_AREA_CODE);
    FND_MESSAGE.SET_TOKEN(token => 'PHONE_NUMBER'       , value => L_PHONE_NUMBER);
    FND_MESSAGE.SET_TOKEN(token => 'PHONE_EXTENSION'	, value => L_PHONE_EXTENSION);
    FND_MESSAGE.SET_TOKEN(token => 'FAX_COUNTRY_CODE'	, value => L_FAX_COUNTRY_CODE);
    FND_MESSAGE.SET_TOKEN(token => 'FAX_AREA_CODE'	, value => L_FAX_AREA_CODE);
    FND_MESSAGE.SET_TOKEN(token => 'FAX_NUMBER'		, value => L_FAX_NUMBER);
    FND_MESSAGE.SET_TOKEN(token => 'FAX_EXTENSION'	, value => L_FAX_EXTENSION);




  return FND_MESSAGE.get;
end;

  -- Currentely it's hardcoded for Contracts for Sales
  -- When ADDRESS is required for any ORG JTF SOURCE we will retrieve it
FUNCTION Get_Address(
    p_object_code IN VARCHAR2,
    p_object_id1 in varchar2,
    p_object_id2 in varchar2,
    ADR_TYPE IN VARCHAR2       -- ADDRESS TYPE : 'MAIN', 'BILL', 'SHIP'
  ) RETURN VARCHAR2 IS
	l_address VARCHAR2(2000);
	l_sql_stmt VARCHAR2(3900);
	l_not_found BOOLEAN;

	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;
 BEGIN

  -- START OF HARDCODED SECTION --
  IF p_object_code = 'OKX_OPERUNIT' OR p_object_code = 'OKX_LEGAL_ENTITY' THEN
    l_sql_stmt := 'select ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,LOC.ADDRESS_LINE_1,LOC.ADDRESS_LINE_2,LOC.ADDRESS_LINE_3,'
                || 'NULL,LOC.TOWN_OR_CITY,NULL,NULL,LOC.REGION_1,LOC.POSTAL_CODE,NULL,LOC.COUNTRY,NULL,NULL,NULL,NULL,NULL,NULL, NULL,''N'',''N'',200,1,1) ADDRESS '
                || ' from HR_LOCATIONS_ALL LOC, HR_ALL_ORGANIZATION_UNITS OU'
                || ' WHERE OU.ORGANIZATION_ID=:id1 and LOC.LOCATION_ID(+) = OU.LOCATION_ID';
   ELSIF p_object_code = 'OKX_PARTY' THEN
    l_sql_stmt := 'select ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,'
                  ||'CITY,COUNTY,STATE,PROVINCE,POSTAL_CODE,NULL,COUNTRY,NULL,NULL,NULL,NULL,NULL,NULL, NULL,''N'',''N'',200,1,1) ADDRESS from OKX_PARTIES_V WHERE ID1 = :id_1';
  END IF;
  -- END OF HARDCODED SECTION --

  IF l_sql_stmt IS NOT NULL THEN
    open c for l_sql_stmt using p_object_id1;
    fetch c into l_address;
    l_not_found := c%NOTFOUND;
    close c;
  END IF;

	If (l_not_found OR l_sql_stmt IS NULL ) Then
    l_address := 'it should be an '||ADR_TYPE||' address for '||p_object_code||' #'||p_object_id1;
    return NULL;
	End if;
	return l_address;
 EXCEPTION
  when OTHERS then
	  If (c%ISOPEN) Then
		Close c;
	  End If;
	  return 'Retrieving Address Error:'||sqlerrm||': '||l_sql_stmt;
END;

FUNCTION GET_EMAIL_FROM_JTFV(
    p_object_code IN VARCHAR2,
    p_object_id1 in varchar2,
    p_object_id2 in varchar2
 ) RETURN VARCHAR2 IS
	l_name	VARCHAR2(255);
	l_from_table VARCHAR2(200);
	l_where_clause VARCHAR2(2000);
	l_sql_stmt VARCHAR2(500);
	l_not_found BOOLEAN := TRUE;

	Cursor jtfv_csr IS
		SELECT FROM_TABLE, WHERE_CLAUSE
		FROM JTF_OBJECTS_B
		WHERE OBJECT_CODE = p_object_code;
	Type SOURCE_CSR IS REF CURSOR;
	c SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into l_from_table, l_where_clause;
	l_not_found := jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If (l_not_found) Then
		return NULL;
	End if;

  l_sql_stmt := 'SELECT EMAIL_ADDRESS FROM ' || l_from_table
			       || ' WHERE ID1 = :id_1 AND ID2 = :id2';
  If (l_where_clause is not null) Then
    l_sql_stmt := l_sql_stmt || ' AND ' || l_where_clause;
  End If;
  open c for l_sql_stmt using p_object_id1, p_object_id2;
  fetch c into l_name;
  l_not_found := c%NOTFOUND;
  close c;

	If (l_not_found) Then
    return NULL;
	End if;
	return l_name;
 EXCEPTION
  when OTHERS then
    If (jtfv_csr%ISOPEN) Then
      Close jtfv_csr;
	  End If;
	  If (c%ISOPEN) Then
      Close c;
	  End If;
	  return NULL;
END;
--
--  function get_contact
--
--  returns HZ_PARTIES related contacts points
--  otherwise (or if not found) returns contact description
--  through jtf_objects_vl
--
--  all parameters are regular jtf_objects related
--
function Get_Email_From_Cont_Points(
    p_object_code in varchar2,
    p_object_id1 in varchar2,
    p_object_id2 in varchar2
  ) return varchar2 is
  -- OKC_UTIL
  -- OKC_RULE_PUB
  L_RETVAL varchar2(2000);
	l_not_found BOOLEAN := TRUE;
  cursor c(pid number) is
   select EMAIL_ADDRESS
    from okx_contact_points_v
    where owner_table_name = 'HZ_PARTIES'
      and owner_table_id = pid
      and EMAIL_ADDRESS IS NOT NULL
    order by decode(PRIMARY_FLAG,'Y',1,2)
   ;
 BEGIN
  IF p_object_code = 'OKX_PCONTACT' THEN
    open c( p_object_id1 );
    fetch c into L_retval;
    l_not_found := c%NOTFOUND;
    close c;
  END IF;
	If (l_not_found) Then
    return NULL;
	End if;
	return l_retval;
 EXCEPTION
  when OTHERS then
	  If (c%ISOPEN) Then
      Close c;
	  End If;
	  return NULL;
END;

function Get_Phone(
    p_object_code in varchar2,
    p_object_id1 in varchar2,
    p_object_id2 in varchar2
  ) return varchar2 is
  -- OKC_UTIL
  -- OKC_RULE_PUB
  L_RETVAL varchar2(2000);
	l_not_found BOOLEAN := TRUE;
  cursor c1(pid number) is
   select decode(PNT.PHONE_COUNTRY_CODE,NULL,NULL,'+'||PNT.PHONE_COUNTRY_CODE||' ')
        ||decode(PNT.PHONE_AREA_CODE,NULL,NULL,'('||PNT.PHONE_AREA_CODE||')')
        ||PNT.PHONE_NUMBER||decode(PNT.PHONE_EXTENSION,NULL,NULL,'.'||PNT.PHONE_EXTENSION) PHONE
    from okx_contact_points_v PNT
    where owner_table_name = 'HZ_PARTIES'
      and owner_table_id = pid
      and PHONE_NUMBER IS NOT NULL
    order by decode(PRIMARY_FLAG,'Y',1,2)
   ;
  cursor c2(pid number) is
   select WORK_TELEPHONE PHONE
    from OKX_BUYERS_V
    where id1 = pid
   ;
 BEGIN
  IF p_object_code = 'OKX_PCONTACT' THEN
    open c1( p_object_id1 );
    fetch c1 into L_retval;
    l_not_found := c1%NOTFOUND;
    close c1;
   ELSIF p_object_code = 'OKX_BUYER' THEN
    open c2( p_object_id1 );
    fetch c2 into L_retval;
    l_not_found := c2%NOTFOUND;
    close c2;
  END IF;
	If (l_not_found) Then
    return NULL;
	End if;
	return l_retval;
 EXCEPTION
  when OTHERS then
	  If (c1%ISOPEN) Then
      Close c1;
	  End If;
	  If (c2%ISOPEN) Then
      Close c2;
	  End If;
	  return NULL;
END;

function get_contact_info(
    p_object_code in varchar2,
    p_object_id1 in varchar2,
    p_object_id2 in varchar2,
    p_info_type in varchar2     -- 'EMAIL', 'PHONE', 'FAX'
  ) return varchar2 is
  -- OKC_UTIL
  -- OKC_RULE_PUB
  L_RETVAL varchar2(2000);
begin

  IF p_info_type = 'EMAIL' THEN
    l_retval := GET_EMAIL_FROM_JTFV( p_object_code, p_object_id1, p_object_id2 );
    IF l_retval IS NULL THEN
      l_retval := Get_Email_From_Cont_Points( p_object_code, p_object_id1, p_object_id2 );
    END IF;
   ELSIF p_info_type = 'PHONE' THEN
      l_retval := Get_Phone( p_object_code, p_object_id1, p_object_id2 );
--   ELSIF p_info_type = 'FAX' THEN
--      l_retval := Get_Fax_From_Cont_Points( p_object_code, p_object_id1, p_object_id2 );
  END IF;
  return l_retval;
end;

END OKC_QUERY;

/
