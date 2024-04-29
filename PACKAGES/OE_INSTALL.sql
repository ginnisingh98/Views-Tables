--------------------------------------------------------
--  DDL for Package OE_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INSTALL" AUTHID CURRENT_USER AS
/* $Header: OEXINSTS.pls 115.2 99/08/09 12:25:58 porting ship  $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_INSTALL';
G_ACTIVE_PRODUCT       VARCHAR2(30)    := FND_API.G_MISS_CHAR;
G_PRODUCT_STATUS       VARCHAR2(30)    := FND_API.G_MISS_CHAR;
    --
    -- The purpose of this function is to identify which OE product is
    -- installed and active in a given environment. In the 11.i release,
    -- two OE products - OE and ONT could be installed/shared and other
    -- product teams will need to branch based on the which OE is installed
    -- and active.

  FUNCTION Get_Active_Product
  RETURN VARCHAR2;
  --pragma restrict_references( get_active_product, WNDS,WNPS);

  -- The purpose of this function is to find out which OE is
  -- installed. This will not necessariliy mean that it is ACTIVE.
  -- The function will return the a value of I for Installed if ONT
  -- is fully installed. Else, it will get the status for old OE and
  -- return back I, S or N for OE.

  FUNCTION Get_Status
  RETURN VARCHAR2;
  --pragma restrict_references(get_status, WNDS, WNPS);

  -- The purpose of this procedure is to create the odd synonyms on the
  -- interoperable objects based on the Order Entry product which is
  -- Active.

  Procedure Create_Interop_Synonym
            (p_schema_name      IN    VARCHAR2
            ,p_synonym_name     IN    VARCHAR2
            ,p_object_name      IN    VARCHAR2
            );

END OE_INSTALL;

 

/
