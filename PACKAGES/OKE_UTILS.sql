--------------------------------------------------------
--  DDL for Package OKE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEUTILS.pls 120.1 2005/06/02 16:11:40 appldev  $ */


FUNCTION Curr_Emp_ID RETURN NUMBER;


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

FUNCTION Curr_Emp_Name RETURN VARCHAR2;


--
--  Name          : Yes_No / Sys_Yes_No
--  Pre-reqs      : None
--  Function      : This function returns the yes/no string based on the
--                  lookups YES_NO and SYS_YES_NO.
--
--
--  Parameters    :
--  IN            : X_Lookup_Code           VARCHAR2
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Yes_No
( X_Lookup_Code    IN VARCHAR2
) return varchar2;

FUNCTION Sys_Yes_No
( X_Lookup_Code    IN NUMBER
) return varchar2;


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
--                  X_Current_Only          VARCHAR2 DEFAULT Y
--                  X_Curr_Indicator        VARCHAR2 DEFAULT N
--  OUT           : X_Change_Request	    VARCHAR2
--		    X_Change_Status	    VARCHAR2
--  IN 	          : X_History_Use           VARCHAR2 DEFAULT N
--

PROCEDURE Chg_Request_Num
( X_K_Header_ID           IN     NUMBER
, X_Major_Version         IN     NUMBER   DEFAULT NULL
, X_Current_Only          IN     VARCHAR2 DEFAULT 'Y'
, X_Curr_Indicator        IN     VARCHAR2 DEFAULT 'N'
, X_Change_Request	  OUT NOCOPY	 VARCHAR2
, X_Change_Status	  OUT NOCOPY    VARCHAR2
, X_History_Use           IN     VARCHAR2 DEFAULT 'N'
) ;


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
) RETURN VARCHAR2;


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
) RETURN VARCHAR2;


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
, X_Translated      IN     VARCHAR2 DEFAULT 'N'
) RETURN BOOLEAN;




-- Function     get_location_description
-- Purpose:
--              returns location name by location_id
--
--
--
FUNCTION get_location_description(id NUMBER)
RETURN VARCHAR2;


-- Function     get_term_values
-- Purpose:
--              to be used by view definition oke_k_terms_v only
--
--
--
FUNCTION get_term_values(p_term_code VARCHAR2, p_term_value_pk1 VARCHAR2,
			p_term_value_pk2 VARCHAR2,p_call_option VARCHAR2 )
RETURN VARCHAR2;


-- Function     get_term_value
-- Purpose:
--              to be used by view definition oke_k_headers_full_v only
--
--
--

FUNCTION get_term_value (p_id NUMBER,p_term_code VARCHAR2)
RETURN VARCHAR2;




-- Function           get_userenv_lang
-- Purpose:           This function returns the value of USERENV('LANG').
--                    Once it has retrieved the value, it is cached
--                    and subsequent calls
--                    to this function from the same session, do not result in
--                    a database
--                    hit. This is because a := USERENV('LANG') results in a
--                    SELECT USERENV('LANG') FROM SYS.DUAL; and can be an
--                    overhead for mass INSERTs/UPDATEs.
--
--                    Caching is done in the global variable g_userenv_lang
--                    declared in the package BODY
--
--
-- In Parameters : None
-- Out Parameters: None
-- Return value  : VARCHAR2
--

FUNCTION get_userenv_lang RETURN VARCHAR2;


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
) RETURN VARCHAR2;


-- -------------------------------------------------------------------
-- Multi-Org Security
-- -------------------------------------------------------------------
PROCEDURE Set_Org_Context( X_Org_ID  NUMBER , X_Inv_Org_ID  NUMBER);
FUNCTION Org_ID RETURN NUMBER;
FUNCTION Cross_Org_Access RETURN VARCHAR2;


-- -------------------------------------------------------------------
-- PL/SQL Server Debugger
-- -------------------------------------------------------------------
PROCEDURE Enable_Debug;
PROCEDURE Disable_Debug;
FUNCTION  Debug_Mode RETURN VARCHAR2;
PROCEDURE Debug ( text  IN  VARCHAR2 );

FUNCTION  IS_VALID_DATE_RANGE (P_DATE_FROM        IN  DATE
 		              ,P_DATE_TO          IN  DATE
 			      ,P_PROJECT_ID       IN  NUMBER
                              ) return number;



FUNCTION Retrieve_Article_Text (P_id  		IN	NUMBER
				,P_position	IN	NUMBER
				,P_next_pos	OUT NOCOPY	NUMBER)return VARCHAR2;


--
--  Name          : Retrieve_WF_Role_Name
--  Pre-reqs      : None
--  Function      : retrieves the first 'person_id' for the specific contract
--                  (P_header_ID)that has a particular role (p_role_id).
--                  Use the P_order_x fields to determine where to look first,
--                  at the site, program, created by, or contract levels?
--
--
--  Parameters    :
--  IN            : P_Header_ID           K_Header_ID of the contract
--                  P_role_id             Role ID
--
--  OUT           : NAME                  from WF_ROLES table
--
--  Returns       : VARCHAR2
--

FUNCTION Retrieve_WF_Role_Name (P_header_id		IN NUMBER,
				P_role_id   		IN NUMBER)
return VARCHAR2;

-- Function Name : 	Set_Multi_org_Access
-- This API is created to support multi org access based on OKE profile option
-- 'OKE:Allow cross Org Acess'. If any implementation of Oracle Apps
-- has chosen not to use new MOAC Security profile feature then only
-- this Profile option will only come into play. This API will be called
-- from Pre-Form Trigger of Search and organizer screens just after
-- calling MO_GLOBAL.init.
PROCEDURE Set_Multi_org_Access;
END OKE_UTILS;

 

/
