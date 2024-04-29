--------------------------------------------------------
--  DDL for Package Body OKE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_UTILS" AS
/* $Header: OKEUTILB.pls 120.3.12010000.2 2009/07/16 10:07:16 aveeraba ship $ */

--
-- Private Global Variables
--
G_Emp_ID        per_all_people_f.person_id%type := NULL;
G_Emp_Name      per_all_people_f.full_name%type := NULL;
G_User_ID       fnd_user.user_id%type           := NULL;
G_Yes           VARCHAR2(80)                    := NULL;
G_No            VARCHAR2(80)                    := NULL;

G_K_Hdr_ID_Curr NUMBER                          := NULL;
G_Fmt_Length    NUMBER                          := NULL;
G_Fmt_Mask      VARCHAR2(80)                    := NULL;

--
-- This is a body global variable storing the value of
-- USERENV('LANG').  The value is cached into this variable so that
-- calling functions do not have to hit the database to determine this
-- value.
--
G_Userenv_Lang  fnd_languages.language_code%TYPE;

--
-- Multi-Org Security Globals
--
G_Access        VARCHAR2(1)                     := NULL;



--
--  Name          : Curr_Emp_ID
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the employee ID derived from
--                  the current user
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : NUMBER
--

FUNCTION Curr_Emp_ID
RETURN NUMBER IS

CURSOR csr ( c_user_id number ) IS
  SELECT employee_id
  FROM   fnd_user
  WHERE  user_id = c_user_id;

BEGIN
  --
  -- Result is cached into a global variable to speed up repeated
  -- lookups.  In the extreme rare case when the USER_ID changed
  -- midstream, the last used USER_ID used to retrieve the
  -- employee ID is also cached to check for mismatch
  --
  IF (  G_Emp_ID IS NULL
     OR G_User_ID <> FND_GLOBAL.User_ID ) THEN
/*
    OPEN csr ( FND_GLOBAL.user_id );
    FETCH csr INTO G_Emp_ID;
    CLOSE csr;
*/
    G_Emp_ID := FND_GLOBAL.Employee_ID;
    G_User_ID := FND_GLOBAL.User_ID;

  END IF;

  RETURN ( G_Emp_ID );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( TO_NUMBER(NULL) );

END Curr_Emp_ID;

--
--  Name          : Curr_Emp_Name
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the employee name derived from
--                  the current user
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Curr_Emp_Name
RETURN VARCHAR2 IS

CURSOR csr ( c_person_id number ) IS
  SELECT full_name
  FROM   per_all_people_f
  WHERE  person_id = c_person_id;

BEGIN
  --
  -- Result is cached into a global variable to speed up repeated
  -- lookups.  In the extreme rare case when the USER_ID changed
  -- midstream, the last used USER_ID used to retrieve the
  -- employee name is also cached to check for mismatch
  --
  IF (  G_Emp_Name IS NULL
     OR G_User_ID <> FND_GLOBAL.User_ID ) THEN

    OPEN csr ( Curr_Emp_ID );
    FETCH csr INTO G_Emp_Name;
    CLOSE csr;

    G_User_ID := FND_GLOBAL.User_ID;

  END IF;

  RETURN ( G_Emp_Name );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( NULL );

END Curr_Emp_Name;


--
--  Name          : Yes_No / Sys_Yes_No
--  Pre-reqs      : None
--  Function      : This function returns the yes/no string based on the
--                  lookups YES_NO and SYS_YES_NO.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : VARCHAR2
--
--  Note          : The cached values are shared between Yes_No and
--                  Sys_Yes_No as the text is extremely unlikely to
--                  differ between the two lookups.
--

FUNCTION Yes_No
( X_Lookup_Code    IN VARCHAR2
) return varchar2 IS

CURSOR c IS
  SELECT meaning
  FROM   fnd_lookups
  WHERE  lookup_type = 'YES_NO'
  AND    lookup_code = X_Lookup_Code;

BEGIN

  IF ( X_Lookup_Code = 'Y' ) THEN
    IF ( G_Yes IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_Yes;
      CLOSE c;
    END IF;
    RETURN ( G_Yes );
  ELSIF ( X_Lookup_Code = 'N' ) THEN
    IF ( G_No IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_No;
      CLOSE c;
    END IF;
    RETURN ( G_No );
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF ( c%ISOPEN ) THEN
    CLOSE c;
  END IF;
  RETURN ( NULL );

END Yes_No;


FUNCTION Sys_Yes_No
( X_Lookup_Code    IN NUMBER
) return varchar2 IS

CURSOR c IS
  SELECT meaning
  FROM   mfg_lookups
  WHERE  lookup_type = 'SYS_YES_NO'
  AND    lookup_code = X_Lookup_Code;

BEGIN

  IF ( X_Lookup_Code = 'Y' ) THEN
    IF ( G_Yes IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_Yes;
      CLOSE c;
    END IF;
    RETURN ( G_Yes );
  ELSIF ( X_Lookup_Code = 'N' ) THEN
    IF ( G_No IS NULL ) THEN
      OPEN c;
      FETCH c INTO G_No;
      CLOSE c;
    END IF;
    RETURN ( G_No );
  ELSE
    RETURN ( NULL );
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF ( c%ISOPEN ) THEN
    CLOSE c;
  END IF;
  RETURN ( NULL );

END Sys_Yes_No;


--
--  Name          : Chg_Request_Num
--  Pre-reqs      : None
--  Function      : This function returns the related Change Request
--                  Number and Change Status for the given contract
--		    either for the current version or a specific
--		    major version.
--
--
--  Parameters    :
--  IN            : X_K_Header_ID           NUMBER
--                  X_Major_Version         NUMBER
--                  X_History_Use           VARCHAR2
--                  X_Curr_Indicator        VARCHAR2
--                  X_Current_Only          VARCHAR2
--  OUT           : X_Change_Request	    VARCHAR2
--		    X_Change_Status	    VARCHAR2
--

PROCEDURE Chg_Request_Num
( X_K_Header_ID           IN     NUMBER
, X_Major_Version         IN     NUMBER
, X_Current_Only          IN     VARCHAR2
, X_Curr_Indicator        IN     VARCHAR2
, X_Change_Request	  OUT NOCOPY	 VARCHAR2
, X_Change_Status	  OUT NOCOPY    VARCHAR2
, X_History_Use           IN     VARCHAR2
) IS

BEGIN
  --
  -- Logic moved to OKE_CHG_REQ_UTILS.GET_CHG_REQUEST
  --
  OKE_CHG_REQ_UTILS.Get_Chg_Request
  ( X_K_Header_ID
  , X_Major_Version
  , X_Change_Request
  , X_Change_Status
  , X_History_Use
  );

END;


--
--  Name          : Item_Number
--  Pre-reqs      : None
--  Function      : This function returns the item number for a given
--                  inventory organization and item ID.
--
--
--  Parameters    :
--  IN            : X_Inventory_Org_ID      NUMBER
--                  X_Item_ID               NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Number
( X_Inventory_Org_ID      IN     NUMBER
, X_Item_ID               IN     NUMBER
) RETURN VARCHAR2 IS

CURSOR ItemNum IS
  SELECT Item_Number
  FROM   mtl_item_flexfields
  WHERE  organization_id = X_Inventory_Org_ID
  AND    inventory_item_id = X_Item_ID;

L_Item_Number   VARCHAR2(2000);

BEGIN

  IF ( X_Inventory_Org_ID IS NULL OR X_Item_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  OPEN ItemNum;
  FETCH ItemNum INTO L_Item_Number;
  CLOSE ItemNum;

  RETURN ( L_Item_Number );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );
END Item_Number;


--
--  Name          : Item_Description
--  Pre-reqs      : None
--  Function      : This function returns the item description for a given
--                  inventory organization and item ID.
--
--
--  Parameters    :
--  IN            : X_Inventory_Org_ID      NUMBER
--                  X_Item_ID               NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Description
( X_Inventory_Org_ID      IN     NUMBER
, X_Item_ID               IN     NUMBER
) RETURN VARCHAR2 IS

CURSOR ItemDesc IS
  SELECT Description
  FROM   mtl_system_items
  WHERE  organization_id = X_Inventory_Org_ID
  AND    inventory_item_id = X_Item_ID;

L_Item_Description   VARCHAR2(2000);

BEGIN

  IF ( X_Inventory_Org_ID IS NULL OR X_Item_ID IS NULL ) THEN
    RETURN ( NULL );
  END IF;

  OPEN ItemDesc;
  FETCH ItemDesc INTO L_Item_Description;
  CLOSE ItemDesc;

  RETURN ( L_Item_Description );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );
END Item_Description;


--
--  Name          : Check_Unique
--  Pre-reqs      : None
--  Function      : This function checks uniqueness of a column
--                  value in the given table.
--
--  Parameters    :
--  IN            : X_K_Header_ID           NUMBER
--                  X_Major_Version         NUMBER
--                  X_Current_Only          VARCHAR2 DEFAULT Y
--                  X_Curr_Indicator        VARCHAR2 DEFAULT N
--  OUT           : None
--
--  Returns       : BOOLEAN
--

FUNCTION Check_Unique
( X_Table_Name      IN     VARCHAR2
, X_Column_Name     IN     VARCHAR2
, X_Column_Value    IN     VARCHAR2
, X_ROWID_Column    IN     VARCHAR2
, X_Row_ID          IN     VARCHAR2
, X_Translated      IN     VARCHAR2
) RETURN BOOLEAN IS

TYPE chk_unq_rc IS REF CURSOR;

c              chk_unq_rc;
stmt           VARCHAR2(2000);
dummy          NUMBER := 0;

BEGIN

  stmt := 'SELECT 1 FROM ' || X_Table_Name ||
          ' WHERE ' || X_Column_Name || ' = :column_value';

  IF ( X_Row_ID IS NOT NULL ) THEN
    stmt := stmt || ' AND ' || X_ROWID_Column || ' <> :row_id';
  END IF;

  IF ( X_Translated = 'Y' ) THEN
    stmt := stmt || ' AND LANGUAGE = USERENV(''LANG'')';
  END IF;

  --
  -- Check for existing records using NDS
  --
  IF ( X_Row_ID IS NOT NULL ) THEN
    OPEN c FOR stmt USING X_Column_Value , X_Row_ID;
  ELSE
    OPEN c FOR stmt USING X_Column_Value;
  END IF;
  FETCH c INTO dummy;

  IF ( c%notfound ) THEN
    CLOSE c;
    RETURN ( TRUE );
  END IF;

  RETURN ( FALSE );

EXCEPTION
  WHEN OTHERS THEN
    CLOSE c;
    RAISE;

END Check_Unique;



-- Function     get_location_description
-- Purpose:
--              returns location name by location_id
--
--
--
FUNCTION get_location_description(id NUMBER)
RETURN VARCHAR2  IS

l_return_val VARCHAR2(240);

CURSOR c_hr IS
SELECT nvl(description,'')
FROM hr_locations_all
WHERE location_id=id;

CURSOR c_hz IS
SELECT substr(address1,1,240)
FROM hz_locations
WHERE location_id=id;

CURSOR c_both IS
SELECT description
FROM hr_locations
WHERE location_id=id;

BEGIN

OPEN c_hr;
FETCH c_hr INTO l_return_val;
IF c_hr%NOTFOUND THEN
 OPEN c_hz;
 FETCH c_hz INTO l_return_val;
 IF c_hz%NOTFOUND THEN
  l_return_val:='ERROR-NO SUCH LOCATION_ID';
 END IF;
 CLOSE c_hz;
END IF;
CLOSE c_hr;
RETURN l_return_val;

END get_location_description;




-- Function     get_term_values
-- Purpose:
--              to be used by view definition oke_k_terms_v only
--
--
--
FUNCTION get_term_values(p_term_code VARCHAR2, p_term_value_pk1 VARCHAR2,
			p_term_value_pk2 VARCHAR2,p_call_option VARCHAR2 )
RETURN VARCHAR2  IS

v_chr1 varchar2(240);
v_chr2 varchar2(240);
v_date1 date;
v_date2 date;

begin

if p_term_code = 'AP_PAYMENT_TERMS' AND LTrim(RTrim(p_term_value_pk1,'0123456789'),'0123456789') IS NULL then

  SELECT NAME , DESCRIPTION , START_DATE_ACTIVE , END_DATE_ACTIVE
  INTO v_chr1 , v_chr2 , v_date1 , v_date2
  FROM AP_TERMS
  WHERE TERM_ID = to_number(p_term_value_pk1);

elsif p_term_code='IB_SHIPPING_METHOD' AND LTrim(RTrim(p_term_value_pk1,'0123456789'),'0123456789') IS NULL then

  SELECT DESCRIPTION , DESCRIPTION , TO_DATE(NULL) , DISABLE_DATE
  into v_chr1 , v_chr2 , v_date1 , v_date2
  FROM ORG_FREIGHT
  WHERE ORGANIZATION_ID = to_number(p_term_value_pk1)
  AND   FREIGHT_CODE = p_term_value_pk2;

elsif p_term_code='RA_PAYMENT_TERMS' then

  SELECT NAME , DESCRIPTION , START_DATE_ACTIVE , END_DATE_ACTIVE
  INTO v_chr1 , v_chr2 , v_date1 , v_date2
  FROM RA_TERMS
  WHERE TERM_ID = to_number(p_term_value_pk1);

else

  SELECT LU.MEANING , LU.DESCRIPTION , LU.START_DATE_ACTIVE , LU.END_DATE_ACTIVE
  INTO v_chr1 , v_chr2 , v_date1 , v_date2
  FROM FND_LOOKUP_VALUES_VL LU
  ,    OKE_TERMS_B T
  WHERE T.TERM_CODE = p_term_code
  AND   LU.VIEW_APPLICATION_ID = T.VIEW_APPLICATION_ID
  AND   LU.LOOKUP_TYPE = T.LOOKUP_TYPE
  AND   LU.LOOKUP_CODE = p_term_value_pk1;

end if;

if p_call_option='MEANING' then
  return v_chr1;
elsif p_call_option='DESCRIPTION' then
  return v_chr2;
elsif p_call_option='START_DATE_ACTIVE' then
  return v_date1;
elsif p_call_option='END_DATE_ACTIVE' then
  return v_date2;
else return 'ERROR';
end if;


END get_term_values;


-- Function     get_ob_terms
-- Purpose:     See specs in OKEUTILS.pls
--

FUNCTION get_term_value (p_id NUMBER,p_term_code VARCHAR2) RETURN VARCHAR2 IS
    l_term_value varchar2(80) := null;
    cursor c_term_value(id number,code varchar2) is
        select term_value_pk1
              from oke_k_terms
              where k_header_id = p_id
              and term_code = p_term_code
              and rownum=1;
BEGIN
    if p_term_code is not null then
        open c_term_value(p_id,p_term_code);
        fetch c_term_value into l_term_value;
        close c_term_value;
    end if;

    return l_term_value;
Exception
When others then
 if c_term_value%ISOPEN then
    close c_term_value;
 end if;
 return null;
END get_term_value;



-- Function     get_userenv_lang
-- Purpose:     See specs in OKEUTILS.pls
--              Briefly: This caches the value of userenv('lang') so
--              that subsequent calls do not result in a database hit
--
--
FUNCTION get_userenv_lang RETURN VARCHAR2  IS

BEGIN

-- Determine if this was determined before by examining the global
-- variable g_userenv_lang. If this is NOT null, return the value,
-- otherwise, determine the value, populate the global variable and
-- return the value.

  IF g_userenv_lang IS NULL
  THEN
	 g_userenv_lang := USERENV('LANG');
  END IF;

  RETURN g_userenv_lang;

END get_userenv_lang;


--
--  Name          : Get_K_Curr_Fmt_Mask
--  Pre-reqs      : None
--  Function      : This function returns the format mask for the
--                  currency of the given contract.  This is used in
--                  the flowdown view to speed up format time as the
--                  return value is cached.
--
--  Parameters    :
--  IN            : X_K_Header_ID           NUMBER
--                  X_Field_Length          NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Get_K_Curr_Fmt_Mask
( X_K_Header_ID     IN     NUMBER
, X_Field_Length    IN     NUMBER
) RETURN VARCHAR2 IS

CURSOR csr ( C_K_Header_ID   NUMBER
           , C_Field_Length  NUMBER ) IS
  SELECT FND_CURRENCY_CACHE.Get_Format_Mask
         ( Currency_Code , C_Field_Length )
  FROM   okc_k_headers_b
  WHERE  id = C_K_Header_ID;

BEGIN
  --
  -- Result is cached into a global variable to speed up repeated
  -- lookups.
  --
  IF (  G_K_Hdr_ID_Curr IS NULL
     OR G_Fmt_Mask IS NULL
     OR G_K_Hdr_ID_Curr <> X_K_Header_ID
     OR G_Fmt_Length <> X_Field_Length ) THEN

    OPEN csr ( X_K_Header_ID , X_Field_Length );
    FETCH csr INTO G_Fmt_Mask;
    CLOSE csr;

    G_K_Hdr_ID_Curr := X_K_Header_ID;
    G_Fmt_Length    := X_Field_Length;

  END IF;

  RETURN ( G_Fmt_Mask );

EXCEPTION
  WHEN OTHERS THEN
    RETURN ( FND_CURRENCY_CACHE.GET_FORMAT_MASK( 'USD' , 38 ) );

END Get_K_Curr_Fmt_Mask;


-- -------------------------------------------------------------------
-- Multi-Org Security
-- -------------------------------------------------------------------
PROCEDURE Set_Org_Context
( X_Org_ID       NUMBER
, X_Inv_Org_ID   NUMBER
) IS

  is_multi_org  VARCHAR2(1);

BEGIN

--   select nvl(multi_org_flag , 'N')
--   into   is_multi_org
--   from   fnd_product_groups
--   where  rownum = 1;
--
--   if ( is_multi_org = 'Y' and X_Org_ID <> -99 ) then
--     FND_CLIENT_INFO.Set_Org_Context(X_Org_ID);
--   end if;
  OKC_CONTEXT.Set_OKC_Org_Context(X_Org_ID , X_Inv_Org_ID);

END Set_Org_Context;


FUNCTION Org_ID
RETURN NUMBER IS
BEGIN

  -- RETURN nvl( to_number(rtrim(substr( userenv('CLIENT_INFO') , 1 , 10 ))) , -99 );

  RETURN nvl(mo_global.get_current_org_id,-99);

END Org_ID;


FUNCTION Cross_Org_Access
RETURN VARCHAR2 IS
BEGIN

  IF ( G_Access IS NULL ) THEN
    G_Access := nvl( fnd_profile.value('OKE_CROSS_ORG_ACCESS') , 'Y' );
  END IF;
  RETURN ( G_Access );

END Cross_Org_Access;


-- -------------------------------------------------------------------
-- PL/SQL Server Debugger
-- -------------------------------------------------------------------

--
-- All functions have been moved to OKE_DEBUG.  Procedures retained
-- for compilation dependencies only.
--
PROCEDURE Enable_Debug IS
BEGIN
  NULL;
END Enable_Debug;

PROCEDURE Disable_Debug IS
BEGIN
  NULL;
END Disable_Debug;

FUNCTION Debug_Mode
RETURN VARCHAR2 IS
BEGIN
  RETURN ( 'N' );
END Debug_Mode;

PROCEDURE Debug ( text  IN  VARCHAR2 ) IS
BEGIN
  NULL;
END Debug;

FUNCTION  IS_VALID_DATE_RANGE (P_DATE_FROM        IN  DATE
 		              ,P_DATE_TO          IN  DATE
 			      ,P_PROJECT_ID       IN  NUMBER
                              ) return number
IS
   d_proj_start_date      date;
   d_proj_end_date        date;
   n_valid                number :=1;
   n_invalid              number :=0;

BEGIN

  IF P_DATE_FROM IS NULL OR P_DATE_TO IS NULL OR p_project_id IS NULL THEN
     RETURN n_invalid;
  END IF;

  BEGIN
     select ppa.start_date
           ,ppa.completion_date
       into d_proj_start_date
           ,d_proj_end_date
       from pa_projects_all                ppa
      where ppa.project_id                =p_project_id
           ;
  EXCEPTION
     when no_data_found then
        RETURN n_invalid;
     when too_many_rows then
        RETURN n_invalid;
     when others then
        RETURN n_invalid;
  END;

  IF (P_DATE_FROM >= nvl(d_proj_start_date,P_DATE_FROM)) AND (P_DATE_TO <= nvl(d_proj_end_date,P_DATE_TO)) THEN
     RETURN n_valid;
  ELSE
     RETURN n_invalid;
  END IF;

END IS_VALID_DATE_RANGE;



FUNCTION Retrieve_Article_Text (P_id  		IN	NUMBER
				,P_position	IN	NUMBER
				,P_next_pos	OUT NOCOPY	NUMBER)return VARCHAR2

IS
    l_article_text	  CLOB;
    l_article_length	  NUMBER;
    l_append_text         VARCHAR2(32000);
    l_position		  NUMBER;
    l_read_length	  NUMBER := 10000;


CURSOR c_text IS
	select text
	from okc_k_articles_v where id = P_id;

BEGIN

OPEN c_text;
FETCH c_text INTO l_article_text;
CLOSE c_text;

l_article_length :=  dbms_lob.getlength(l_article_text);
l_position := p_position;

if l_article_length >= (l_position) then

	dbms_lob.read(l_article_text,l_read_length,l_position,l_append_text);
	p_next_pos := l_position + l_read_length;
end if;

return l_append_text;

END;


FUNCTION Retrieve_WF_Role_Name (P_header_id		IN NUMBER,
				P_role_id   		IN NUMBER)
return VARCHAR2 is

  Cursor Get_WF_User (person_id NUMBER)
  IS
  SELECT r.name
  FROM wf_roles r
  WHERE r.orig_system ='PER'
  AND   r.orig_system_id = person_id;

  Cursor Get_Header_Assignments
  IS
  SELECT Resource_source_id
  FROM PA_Project_Parties
  WHERE Resource_type_id = 101          -- employees only
  AND   Object_type = 'OKE_K_HEADERS'   -- header assignments only
  AND   Object_id   = P_header_id       -- for the requested header id only
  AND   Project_role_id = P_role_id     -- for the requested role
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active));
Cursor Get_Program_Assignments
  IS
  SELECT Resource_source_id
  FROM PA_Project_Parties pr, OKE_K_Headers
  WHERE Resource_type_id = 101         -- employees only
  AND   Object_type = 'OKE_PROGRAMS'   -- program  assignments only
  AND   Object_id   = program_id       -- for the program id
  AND   K_Header_id = P_header_id      -- related to the requested header id
  AND   Project_role_id = P_role_id    -- for the requested role
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active))
  and not exists ( -- Same Person shouldnot exist at contract level in any other role
  SELECT 'x'
  FROM PA_Project_Parties pr1
  WHERE Resource_type_id = 101
  AND   Object_type = 'OKE_K_HEADERS'
  AND   Object_id   = P_header_id
  AnD   pr.resource_id = pr1.resource_id
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active)))
  order by pr.creation_date;

  Cursor Get_Site_Assignments
  IS
  SELECT Resource_source_id
  FROM PA_Project_Parties pr
  WHERE Resource_type_id = 101         -- employees only
  AND   Object_type = 'OKE_PROGRAMS'   -- site assignments only
  AND   Object_id   = 0                -- for the program id is 0 for site
  AND   Project_role_id = P_role_id    -- for the requested role
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active))
  and not exists ( -- Same Person shouldnot exist at contract level in any other role
  SELECT 'x'
  FROM PA_Project_Parties pr1
  WHERE Resource_type_id = 101
  AND   Object_type = 'OKE_K_HEADERS'
  AND   Object_id   = P_header_id
  AnD   pr.resource_id = pr1.resource_id
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active)))
  and not exists ( -- Same Person shouldnot exist at program level in any other role
  SELECT 'x'
  FROM PA_Project_Parties pr2, OKE_K_Headers
  WHERE Resource_type_id = 101
  AND   Object_type = 'OKE_PROGRAMS'
  AND   Object_id   = program_id
  AND   K_Header_id = P_header_id
  AND   pr.resource_id = pr2.resource_id
  AND   Trunc(SYSDATE) >= Trunc(Start_Date_Active)
  AND   (End_Date_Active IS NULL  OR  Trunc(SYSDATE) <= Trunc(End_Date_Active)))
  order by pr.creation_date;

  l_person_id  NUMBER := -1;
  l_wf_user    VARCHAR2(200);

BEGIN

 OPEN Get_Header_Assignments;
 FETCH Get_Header_Assignments INTO l_person_id;
 IF Get_Header_Assignments%NOTFOUND THEN
   OPEN Get_Program_Assignments;
   FETCH Get_Program_Assignments INTO l_person_id;
   IF Get_Program_Assignments%NOTFOUND THEN
     OPEN Get_Site_Assignments;
     FETCH Get_Site_Assignments INTO l_person_id;
     IF Get_Site_Assignments%NOTFOUND THEN
	CLOSE Get_Site_Assignments;
	CLOSE Get_Program_Assignments;
	CLOSE Get_Header_Assignments;
	return NULL;
     END IF;
     CLOSE Get_Site_Assignments;
   END IF;
   CLOSE Get_Program_Assignments;
 END IF;
 CLOSE Get_Header_Assignments;

 OPEN Get_WF_User(l_person_id);
 FETCH Get_WF_User INTO l_wf_user;
 IF Get_WF_User%NOTFOUND THEN
   CLOSE Get_WF_User;
   return NULL;
 END IF;
 CLOSE Get_WF_User;

return l_wf_user;

END Retrieve_WF_Role_Name;

PROCEDURE Set_Multi_org_Access IS
BEGIN
 If nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'),'N')='N'
     and nvl( fnd_profile.value('OKE_CROSS_ORG_ACCESS') , 'Y' ) ='Y' then
        mo_global.set_policy_context('B', NULL);
 End if;
END Set_Multi_org_Access;



END OKE_UTILS;

/
