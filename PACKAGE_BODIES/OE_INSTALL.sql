--------------------------------------------------------
--  DDL for Package Body OE_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INSTALL" AS
/* $Header: OEXINSTB.pls 115.4 99/10/14 13:53:59 porting ship  $ */

  --
  --
  -- Public Functions
  --

  FUNCTION Get_Active_Product

  RETURN VARCHAR2 IS


  BEGIN


 -- This procedure will always return ONT as the active product
 -- irrespective of whether it is installed or not.
 -- In Release 11.i, only the new Order management system is
 -- installed.


  if G_ACTIVE_PRODUCT = FND_API.G_MISS_CHAR THEN

           G_ACTIVE_PRODUCT := 'ONT';
  end if;

           return(G_ACTIVE_PRODUCT);
  EXCEPTION
    -- This should only execute if an invalid dep_appl_id was passed
    When Others then
	 G_ACTIVE_PRODUCT := 'N';
	 return(G_ACTIVE_PRODUCT);

END ;

FUNCTION Get_Status
RETURN VARCHAR2
IS
  l_application_short_name  VARCHAR2(30);
  l_ret_val           BOOLEAN;
  l_status            VARCHAR2(1);
  l_industry          VARCHAR2(1);
  l_ont_application_id      NUMBER := 660;

BEGIN
    /* Check if the global variable is set */
    if G_PRODUCT_STATUS = FND_API.G_MISS_CHAR THEN

	   -- Return the product status of Order Management
	   -- Make a call to fnd_installation.get function to check for the
	   -- installation status of Order Management and return the status.

	   l_ret_val := fnd_installation.get(l_ont_application_id,l_ont_application_id,l_status,l_industry);
	   if (l_status = 'I') then
		  G_PRODUCT_STATUS := 'I';
		  return(G_PRODUCT_STATUS);

	   elsif (l_status = 'S') then
		  G_PRODUCT_STATUS := 'S';
		  return(G_PRODUCT_STATUS);
        elsif (l_status = 'N') then
	       G_PRODUCT_STATUS := 'N';
		  return(G_PRODUCT_STATUS);
        end if;
    else
	 return(G_PRODUCT_STATUS);
    end if;

End Get_Status;

-- The purpose of this procedure is to create odd synonyms
-- on the interoperable objects based on the Order Entry
-- product which is ACTIVE. The procedure first checks
-- for which Order Entry is installed and then does the
-- the validation for whether the synonym already exists
-- on the required object. If a match does not exist,
-- then we recreate the synonym on the required object.

PROCEDURE Create_Interop_Synonym
(    p_schema_name     in varchar2
,    p_synonym_name    in varchar2
,    p_object_name     in varchar2
)
IS

   p_exact_match                      BOOLEAN;
   p_found_object_with_same_name      BOOLEAN;
   p_type_for_object_found            VARCHAR2(30);
   statement                          VARCHAR2(150);

BEGIN

    -- Check if the synonym already exists
    system.ad_apps_private.exact_synonym_match(p_schema_name,p_synonym_name,
    p_schema_name,p_object_name,p_exact_match,p_found_object_with_same_name,
    p_type_for_object_found);
    if NOT p_exact_match THEN
        system.ad_apps_private.drop_object(p_schema_name,
								   p_synonym_name,'SYNONYM');

        -- Recreate the synonym

        statement := 'create synonym '|| p_synonym_name ||' for '
							   || p_object_name;
        --dbms_output.put_line('Statement :'|| statement);

        system.ad_apps_private.do_apps_ddl(p_schema_name,statement);
   else
        -- Synonym already exists. Do nothing.
       -- dbms_output.put_line('Synonym already exists');
	   null;
   end if;

   EXCEPTION
	 When OTHERS then
		OE_MSG.Internal_Exception('OE_INSTALL.Create_Interop_Synonym',
				'Create_Interop_Synonym',NULL);

END Create_Interop_Synonym;

END OE_INSTALL;

/
