--------------------------------------------------------
--  DDL for Package INV_COPY_ORGANIZATION_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COPY_ORGANIZATION_REPORT" AUTHID CURRENT_USER AS
-- $Header: INVCORPS.pls 120.1.12000000.2 2007/02/26 11:28:05 myerrams ship $
--+===========================================================================+
--|               Copyright (c) YYYY Oracle Corporation                       |
--|                       Redwood Shores, CA, USA                             |
--|                         All rights reserved.                              |
--+===========================================================================+
--| FILENAME                                                                  |
--|   INVCORPS.pls                                                            |
--|                                                                           |
--| DESCRIPTION                                                               |
--|   This package will be used to generated the data required for Copy Orgn  |
--|    Report.                                                                |
--|                                                                           |
--| HISTORY                                                                   |
--|   07/21/2003 nkilleda  Created.                                           |
--|   04/26/2004 nesoni   modified for bug 3550415.                           |
--|                                New function Receiving_Subinv_Exist added. |
--|   11/06/2004 shpandey  Bug 3683490 Added New function clob_to_varchar     |
--|                        added to convert clob                              |
--|                        field to varchar2 as to_char function(clob) is not |
--|                        supported for version 8i.                          |
--|   12/04/2005 shpandey  Added a function Get_Err_Wip_Acc_Classes for       |
--|                        supporting Wip Accounting Classes entity for R12   |
--|   21/02/2007 myerrams  Bug5592181 Added New function Get_Err_StdOperations|
--|                        to Validate StandardOperations created for new org |
--|                        against those in model org.			      |
--+===========================================================================+
--=============================================================================
-- TYPE DECLARATIONS
--=============================================================================

--=============================================================================
-- Commented as these are not required anymore.
--=============================================================================
--TYPE Entity_Rec_Type IS RECORD
--( entity_type  VARCHAR2(100)
--, table_name   VARCHAR2(100)
--, field_name   VARCHAR2(100)
--);
--TYPE Entity_Table IS TABLE OF Entity_Rec_Type
--INDEX BY BINARY_INTEGER;
--
--m_user_values    Entity_Table;
--m_entities       Entity_Table;
--m_entities_pk    Entity_Table;
--m_entities_temp  Entity_Table;
--
--TYPE PK_Array IS TABLE OF VARCHAR2(30);
--TYPE Primary_Key_Rec IS RECORD
--( entity_type  VARCHAR2(100)
--, table_name   VARCHAR2(100)
--, primary_key  PK_Array
--);
--TYPE Primary_Key_Hash IS TABLE OF Primary_Key_Rec
--INDEX BY BINARY_INTEGER;
--
--m_primary_key_hash  Primary_Key_Hash;
--=============================================================================

TYPE Token_Rec IS RECORD
( token_name   VARCHAR2(100)
, token_value  VARCHAR2(100)
);
TYPE Token_Hash IS TABLE OF Token_Rec
INDEX BY BINARY_INTEGER;

TYPE Char_Array IS TABLE OF VARCHAR2(240);

TYPE Num_Array IS TABLE OF NUMBER;

TYPE Entity_Primary_Key IS REF CURSOR;

s_error_tokens  Token_Hash;

--=============================================================================
-- CONSTANTS
--=============================================================================
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'INV_COPY_ORGANIZATION_REPORT';

--=============================================================================
-- PUBLIC VARIABLES
--=============================================================================
g_variable  NUMBER;

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================

--=============================================================================
-- PROCEDURE NAME: Generate_Report_Data
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Main method called from Before_Report trigger of the report.
--                  Calls initialize(), Validate_Locs() and Validate_Orgs()
--                  functions to generate report data.
-- PARAMETERS    :
--   p_api_version       REQUIRED. As per standards.
--   p_init_msg_list     REQUIRED. As per standards.
--   p_commit            REQUIRED. As per standards.
--   x_return_status     REQUIRED. Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count         REQUIRED. As per standards.
--   x_msg_data          REQUIRED. As per standards.
--   p_group_code        REQUIRED. Group code created for Copy Org request.
--   p_model_org_code    REQUIRED. Model organization to copy from.
--   p_organization_code REQUIRED. New organization to be created.
--   p_copy_boms         REQUIRED. Flag indicating to Copy BOMs.
--   p_copy_routings     REQUIRED. Flag indicating to Copy Routings.
--   p_copy_items        REQUIRED. Flag indicating to Copy Items.
--   p_copy_ship_net     REQUIRED. Flag indicating to Copy Shipping Networks.
--   p_assgn_hier        REQUIRED. Flag indicating to Copy Assign Hierarchies.
--   p_location_status   REQUIRED. Flag indicating if loc was created by req.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Generate_Report_Data
( p_api_version       IN  NUMBER
, p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_group_code        IN  VARCHAR2
, p_model_org_code    IN  VARCHAR2
, p_organization_code IN  VARCHAR2
, p_copy_boms         IN  VARCHAR2
, p_copy_routings     IN  VARCHAR2
, p_copy_items        IN  VARCHAR2
, p_copy_ship_net     IN  VARCHAR2
, p_assgn_hier        IN  VARCHAR2
, p_location_status   IN  VARCHAR2
);

--=============================================================================
-- API NAME      : initialize()
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : initialize the lists m_user_values with values
--                   from Report Table.
-- PARAMETERS    : None
-- EXCEPTIONS    : None.
--
-- This procedure has been obsoleted as modification of attribute values
--   through UI is no longer supported in Copy Org.
--=============================================================================
--PROCEDURE initialize;

--=============================================================================
-- API NAME      : Get_Unique_List
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Remove duplicate entries from an array.
-- PARAMETERS    :
--   p_array       REQUIRED. Array containing duplicate records.
--
-- RETURNS       : Array containing unique records ( Char_Array )
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Unique_List ( p_array Char_Array ) RETURN Char_Array;

--=============================================================================
-- PROC NAME     : Validate_Orgs
-- PRE-CONDITIONS: New Organization, Location, Parameters must be created.
-- DESCRIPTION   : Validate the org and call the function to validate entities
--                  for model org against new org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Validate_Orgs;

--=============================================================================
-- PROC NAME     : Validate_Locs
-- PRE-CONDITIONS: New Organization, Location, Parameters must be created.
-- DESCRIPTION   : Validate the location for model org against new org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Validate_Locs;

--=============================================================================
-- FUNCTION NAME : Validate_Entities
-- PRE-CONDITIONS: New Organization, Location, Parameters must be created.
-- DESCRIPTION   : Validate all entities for model org against new org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Validate_Entities RETURN VARCHAR2;

--=============================================================================
-- FUNCTION NAME : Get_Err_Subinv_Names
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate subinventories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Subinv_Names RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Resources
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom resources created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Resources RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Departments
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom departments created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Departments RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Ship_Net
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate shipping networks created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Ship_Net RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Bom
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate boms created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Bom RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Org_Information
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate org information created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Org_Information RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Items
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate items created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Items RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Items_Subinv
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item subinventories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Items_Subinv RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Cat
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item categories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Cat RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Rev
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item revisions created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Rev RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_StdOperations
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate StandardOperations created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_StdOperations RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Routings
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate routings created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Routings RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Locations
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate Item Locations created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Locations RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Dept_Res
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate department resources created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Dept_Res RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Cst_Res_Ovhds
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate resource overheads created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Cst_Res_Ovhds RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Cst_Res_Costs
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate resource costs created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Cst_Res_Costs RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Dept_Classes
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom department classes created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Dept_Classes RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Alt_Desig
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom alternate designators created for new org
--                   against those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Alt_Desig RETURN Char_Array;

--=============================================================================
-- FUNCTION NAME : Get_Err_Hierarchy
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate hierarchies to which new org is assigned against
--                   those for model org.
-- PARAMETERS    : None
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Hierarchy RETURN Char_Array;

--=============================================================================
-- PROC NAME     : Insert_Row
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Get the translated message from FND MESSAGES table.
-- PARAMETERS    :
--    p_location_code        > Location Code
--    p_business_group_name  > Business Group Name
--    p_status               > Status for Location / Organization
--    p_error_msg            > Error Message
--    p_rec_type             > REQUIRED. Record Type
--    p_entity_type          > Entity Type
--    p_copy_cnt             > Act Count of Records Copied
--    p_modify_cnt           > Act Count of Records Modified
--    p_exp_copy_cnt         > Exp Count of Records to be Copied
--    p_exp_modify_cnt       > Exp Count of Records to be Modified
--    p_entity_name          > Entity Record that was not copied
--    p_entity_inconsistency > Error message ( Not Copied / Not Modified )
--    p_put_orgs             > Flag to determine if org codes need to be
--                              inserted for any row.
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Insert_Row
( p_location_code        IN  VARCHAR2
, p_business_group_name  IN  VARCHAR2
, p_status               IN  VARCHAR2
, p_error_msg            IN  VARCHAR2
, p_rec_type             IN  VARCHAR2
, p_entity_type          IN  VARCHAR2
, p_copy_cnt             IN  NUMBER
, p_modify_cnt           IN  NUMBER
, p_exp_copy_cnt         IN  NUMBER
, p_exp_modify_cnt       IN  NUMBER
, p_entity_name          IN  VARCHAR2
, p_entity_inconsistency IN  VARCHAR2
, p_put_orgs             IN  BOOLEAN
);

--=============================================================================
-- FUNCTION NAME : Get_Organization_Id
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Get the organization Id for this org code.
-- PARAMETERS    :
--   p_org_code    REQUIRED. Org Code to be converted to Id.
--
-- EXCEPTIONS    : None.
--=============================================================================
FUNCTION Get_Organization_Id ( p_org_code  IN  VARCHAR2 ) RETURN NUMBER;

--=============================================================================
-- FUNCTION NAME : Is_Entity_Modified
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Return True if there are any attributes to be modified
--                   for this entity
-- PARAMETERS    :
--   p_entity_type REQUIRED. Entity to be checked for modifications.
--
-- EXCEPTIONS    : None.
--
-- This procedure has been obsoleted as modification of attribute values
--   through UI is no longer supported in Copy Org.
--=============================================================================
--FUNCTION Is_Entity_Modified ( p_entity_type  IN  VARCHAR2 ) RETURN BOOLEAN;

--=============================================================================
-- PROC NAME     : Put_Report_Data
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Insert records for Qualitative / Quantitative data
--                  for all entities.
-- PARAMETERS    : None
--
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Put_Report_Data;

--=============================================================================
-- PROC NAME     : Init_Vars
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Initialize variables for processing entities.
-- PARAMETERS    : p_entity_type. REQUIRED : Entity Type being validated.
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Init_Vars ( p_entity_type IN VARCHAR2 );

--=============================================================================
-- FUNCTION NAME : Get_Fnd_Message
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Get the translated message from FND MESSAGES table.
-- PARAMETERS    :
--   p_msg_name           REQUIRED. Name of the error message.
--   p_token_array        REQUIRED. List of token name/values in error message.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Fnd_Message
( p_msg_name               IN  VARCHAR2
, p_token_array            IN  Token_Hash
) RETURN VARCHAR2;

--=============================================================================
-- FUNCTION NAME : Purge_Copy_Org_Report
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Purge records from the Copy Org Report table for the
--                  group code.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Purge_Copy_Org_Report RETURN BOOLEAN;

--=============================================================================
--Bug: 3550415. New function added to verify if Receiving Subinventories exist
-- corresponding to Model Org
--=============================================================================
-- FUNCTION NAME : Receiving_Subinv_Exist
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Returns TRUE if Receiving Subinventories exist for the
--                 model org else returns FALSE.
-- PARAMETERS    :
-- p_organization_id           REQUIRED. Organization Id.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Receiving_Subinv_Exist(p_organization_id IN  NUMBER ) RETURN VARCHAR2;
--=============================================================================
--Bug: 3683490. New function added to convert clob field to varchar2
--              as to_char() function is not supported for version 8i.
--=============================================================================
/*
** -------------------------------------------------------------------------
** Function: clob_to_varchar
** Description: Takes in a CLOB database object and returns the
**              corresponding VARCHAR2 object
** Input:
**      lobsrc
**              The CLOB to be converted into a VARCHAR2 string
**
** Returns:
**      The VARCHAR2 string that was converted from the passed in CLOB
** --------------------------------------------------------------------------
*/

FUNCTION clob_to_varchar ( lobsrc IN CLOB ) return VARCHAR2;

--=============================================================================
-- FUNCTION NAME : Get_Err_Wip_Acc_Classes
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate wip accounting classes created for new org against
--                 those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
-- shpandey, added the function below for R12 development.
--=============================================================================
FUNCTION Get_Err_Wip_Acc_Classes RETURN Char_Array;

END INV_COPY_ORGANIZATION_REPORT;

 

/
