--------------------------------------------------------
--  DDL for Package Body INV_COPY_ORGANIZATION_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COPY_ORGANIZATION_REPORT" AS
-- $Header: INVCORPB.pls 120.6.12000000.2 2007/02/26 11:30:07 myerrams ship $
--+===========================================================================+
--|               Copyright (c) YYYY Oracle Corporation                       |
--|                       Redwood Shores, CA, USA                             |
--|                         All rights reserved.                              |
--+===========================================================================+
--| FILENAME                                                                  |
--|   INVCORPB.pls                                                            |
--|                                                                           |
--| DESCRIPTION                                                               |
--|   This package will be used to generated the data required for Copy Orgn  |
--|    Report.                                                                |
--|                                                                           |
--| HISTORY                                                                   |
--|   07/21/2003 nkilleda  Created.                                           |
--|   02/27/2003 nkilleda  Bug 3441641 : Modified Validate_Locs procedure to  |
--|                         use location id to retrieve the creation date     |
--|                         instead of location code.                         |
--|   04/26/2004 nesoni   modified for bug 3550415                            |
--|   05/12/2004 aujain    Bug 3623168 Modified Get_Err_Org_Information       |
--|                        function for 10G compilation issue                 |
--|   24/05/2004 nkamaraj  Bug 3637921 Modified qeury to reduce cost and avoid|
--|                        FTS for the Item Revisions count                   |
--|   11/06/2004 shpandey  Bug 3683490 Added New function clob_to_varchar     |
--|                        added to convert clob                              |
--|                        field to varchar2 as to_char function(clob) is not |
--|                        supported for version 8i.                          |
--|  14/06/2004 shpandey   Modified the If condition used before inserting the|
--|                        Qualitative data into MTL_COPY_ORG_REPORT table.   |
--|                        for bug# 3678706.                                  |
--|  18/08/2004 aujain     Modified size of variables retreiving FND Messages |
--|                        for Bug 3838706.                                   |
--|  12/04/2004 shpandey   Added a function Get_Err_Wip_Acc_Classes for       |
--|                        supporting Wip Accounting Classes entity for R12   |
--|                        also modified procedure Validate_Locs for          |
--|                        supporting report if model org does not have       |
--|                        location attached to it. bug#4111958               |
--|  11/08/2005 nesoni     Modified for bug #3575494                          |
--|                        EntityTypes are replaced with lookup codes defined |
--|                        for new lookup type 'INV_COPY_ORG_REPORT_ENTITIES'.|
--|                        Commented unused local variable l_entity_type,     |
--|                        l_return_status, l_copyorg_time_stamp,             |
--|                        l_locs_validated, l_orgs_validated, l_copy_boms,   |
--|                        l_copy_routings, l_copy_items, l_copy_ship_net ,   |
--|                        l_assgn_hier, l_return_status, l_msg_count,        |
--|                        l_msg_data,l_excp_loc_cd_invalid,l_excp_loc_message|
--|                        l_org_id, l_error_status_flag, l_count,l_message   |
--|                        Commented unused global vairables:g_log_level      |
--|                        ,g_table_name                                      |
--|  09/09/2005 vmutyala   Modified java style comments to PLS comments for   |
--|                        bug:4599267                                        |
--|  12/12/2005 vmutyala   Modified Get_Err_Routings to remove inconsistancy  |
--|                        in comparing routings                              |
--|  19/12/2005 vmutyala   Modified Get_Err_Bom_Bom to remove inconsistancy   |
--|                        in comparing Bom                                   |
--|  20/01/2006 myerrams   Replaced the view BOM_BILL_OF_MATERIALS	      |
--|			   with BOM_STRUCTURES_B table. Bug: 4913484.	      |
--|  26/12/2006 myerrams   Bug5592181 Added New function Get_Err_StdOperations|
--|                        to Validate StandardOperations created for new org |
--|                        against those in model org.			      |
--+===========================================================================+

--=============================================================================
-- CONSTANTS
--=============================================================================
G_DEBUG_LEVEL VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_LEVEL'), '6');
G_DEBUG       VARCHAR2(1)  := 'N';
G_THRESHOLD NUMBER := 50;
--=============================================================================
-- PUBLIC VARIABLES
--=============================================================================
--g_log_level            NUMBER       := NULL;
g_log_mode             VARCHAR2(3)  := 'OFF'; -- possible values: OFF,SQL,SRS
g_group_code           VARCHAR2(30);
g_model_org_id         NUMBER;
g_organization_id      NUMBER;
g_model_org_code       VARCHAR2(10);
g_organization_code    VARCHAR2(10);
g_copy_boms            VARCHAR2(10);
g_copy_routings        VARCHAR2(10);
g_copy_items           VARCHAR2(10);
g_copy_ship_net        VARCHAR2(10);
g_assgn_hier           VARCHAR2(10);
g_location_status      VARCHAR2(10);
g_exp_modify_cnt       NUMBER;
g_exp_copy_cnt         NUMBER;
g_copy_cnt             NUMBER;
g_modify_cnt           NUMBER;
g_entity_idx           NUMBER;
g_entity_count         NUMBER;
g_entity_names         Char_Array;
g_not_to_copy          BOOLEAN:=false;
--g_table_name           VARCHAR2(100);
g_entity_type          VARCHAR2(100);
--------------------------------------------------------------------
-- Removed Support for Modified entities
--------------------------------------------------------------------
-- g_modified             BOOLEAN:=false;
--------------------------------------------------------------------
g_error_status_flag    BOOLEAN:=false;

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================

--=============================================================================
-- API NAME      : Generate_Report_Data
-- API TYPE      : PUBLIC
-- PRE-CONDITIONS: None.
-- COMMENTS      : PL/SQL API called from Before_Report trigger of the
--                 report. Calls initialize(), Validate_Locs() and
--                 Validate_Orgs() functions to generate report data.
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
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := ' Generate_Report_Data ';
  l_api_version     CONSTANT NUMBER := 1.0;
  ---------------------------------------------------------------------------
  -- The initialize procedure has been obsoleted as it is not required
  --   the procedure only initialized an array with the list of attrs
  --   that have been modified ( through Input XML )
  -- Since modified attributes are not longer supported, this procedure
  --   need not be called.
  ---------------------------------------------------------------------------
  --l_initialized     BOOLEAN:=true;
  ---------------------------------------------------------------------------
  --l_locs_validated  BOOLEAN:=true;
  --l_orgs_validated  BOOLEAN:=true;
  --l_copy_boms       BOOLEAN:=false;
  --l_copy_routings   BOOLEAN:=false;
  --l_copy_items      BOOLEAN:=false;
  --l_copy_ship_net   BOOLEAN:=false;
  --l_assgn_hier      BOOLEAN:=false;
  --l_return_status   VARCHAR2(30);
  --l_msg_count       NUMBER;
  --l_msg_data        VARCHAR2(100);

BEGIN
  -----------------------------------------------------------------------------
  -- Standard Start of API savepoint
  -----------------------------------------------------------------------------
  SAVEPOINT  Generate_Report_Data_PVT;

  IF G_DEBUG_LEVEL = '6'
  THEN
    G_DEBUG := 'Y';
  END IF;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Generate_Report_Data =>   '||
         'Input Paramters'          ||
         '-> '||p_group_code        ||
         ' , '||p_model_org_code    ||
         ' , '||p_organization_code ||
         ' , '||p_copy_boms         ||
         ' , '||p_copy_routings     ||
         ' , '||p_copy_items        ||
         ' , '||p_copy_ship_net     ||
         ' , '||p_assgn_hier        ||
         ' , '||p_location_status
    );
  END IF;

  --
  -- Assign values to global variables
  --
  g_organization_id   := Get_Organization_Id( p_organization_code );
  g_model_org_id      := Get_Organization_Id( p_model_org_code );
  g_group_code        := p_group_code;
  g_model_org_code    := p_model_org_code;
  g_organization_code := p_organization_code;
  g_copy_boms         := p_copy_boms;
  g_copy_routings     := p_copy_routings;
  g_copy_items        := p_copy_items;
  g_copy_ship_net     := p_copy_ship_net;
  g_assgn_hier        := p_assgn_hier;
  g_location_status   := p_location_status;
  -----------------------------------------------------------------------------
  -- Check for call compatibility.
  -----------------------------------------------------------------------------
  IF NOT FND_API.Compatible_API_Call( l_api_version
				    , p_api_version
				    , l_api_name
				    , G_PKG_NAME
				    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -----------------------------------------------------------------------------
  -- Initialize API message list if necessary.
  -- Initialize message list if p_init_msg_list is set to TRUE.
  -----------------------------------------------------------------------------
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  ---------------------------------------------------------------------------
  -- The initialize procedure has been obsoleted as it is not required
  --   the procedure only initialized an array with the list of attrs
  --   that have been modified ( through Input XML )
  -- Since modified attributes are not longer supported, this procedure
  --   need not be called.
  ---------------------------------------------------------------------------
  --IF G_DEBUG = 'Y' THEN
  --  FND_MSG_PUB.ADD_EXC_MSG
  --  ( G_PKG_NAME
  --  , l_api_name
  --  , '> initialize() for populating entity/attribute lists'
  --  );
  --  --dbms_output.put_line('> initialize for populating' ||
  --  --                     '  modified entity list'      );
  --END IF;
  -----------------------------------------------------------------------------
  -- Call initialize() function to initialize the entity list, attribute
  -- list, and modified attributes entered by user.
  -----------------------------------------------------------------------------
  --initialize;
  -----------------------------------------------------------------------------

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Validating location - writing messages to Report tab'
    );
    --dbms_output.put_line('> Validating location, '||
    --                     '  writing messages to Report tab' );
  END IF;
  ---------------------------------------------------------------------------
  -- Call Validate_Locs() function to validate the location
  -- created by Copy Org and write an appropriate message
  -- to the Report Table : MTL_COPY_ORG_REPORT.
  ---------------------------------------------------------------------------
  Validate_Locs;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Validating organization, writing messages to Report tab'
      );
    --dbms_output.put_line('> Validating organization, '||
    --                     'writing messages to Report tab');
  END IF;
  -------------------------------------------------------------------------
  -- Call Validate_Orgs() function to validate the organization
  -- created by Copy Org and write appropriate messages
  -- to the Report Table : MTL_COPY_ORG_REPORT.
  -------------------------------------------------------------------------
  Validate_Orgs();
  -------------------------------------------------------------------------
  -- Standard check of p_commit.
  -------------------------------------------------------------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  ---------------------------------------------------------------------------
  -- set return status to appropriate value based in org
  -- validation status.
  ---------------------------------------------------------------------------

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Generate_Report_Data_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get( p_count=>x_msg_count, p_data=>x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Generate_Report_Data_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get( p_count=>x_msg_count, p_data=>x_msg_data);

END Generate_Report_Data;

--=============================================================================
-- API NAME      : initialize()
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : initialize the list m_user_values with values
--                  from Report Table.
-- PARAMETERS    : None
-- EXCEPTIONS    : None.
--
-- This procedure is OBSOLETED as modified attributes are not supported
--   anymore by the Copy Org Report.
--=============================================================================
--PROCEDURE initialize
--IS
--  CURSOR l_user_values ( p_group_code VARCHAR2 )
--  IS
--    SELECT  entity_type, entity_name, field_name
--    FROM    mtl_copy_org_report
--    WHERE   rec_type = 'INPUT_XML'
--    AND     group_code = p_group_code;
--
--  l_user_rec   l_user_values%ROWTYPE;
--  l_usr_index  NUMBER:=1;
--
--  l_api_name   VARCHAR2(100):=' Initialize ';
--
--BEGIN
--
--  IF G_DEBUG = 'Y' THEN
--    FND_MSG_PUB.ADD_EXC_MSG
--    ( G_PKG_NAME
--    , l_api_name
--    , '> initialize'
--    );
--  END IF;
--
--  ---------------------------------------------------------------------------
--  -- Retrieve the list of entities and modified attributes
--  --  entered by the user, written by CopyLoader into the
--  --  copy org report table.
--  ---------------------------------------------------------------------------
--
--  OPEN l_user_values ( g_group_code );
--  FETCH l_user_values INTO l_user_rec;
--
--  IF l_user_values%NOTFOUND THEN
--    RETURN;
--  END IF;
--
--  LOOP
--    m_user_values(l_usr_index).entity_type := l_user_rec.entity_type;
--    m_user_values(l_usr_index).table_name  := l_user_rec.entity_name;
--    m_user_values(l_usr_index).field_name  := l_user_rec.field_name;
--    l_usr_index := l_usr_index + 1;
--
--    FETCH l_user_values INTO l_user_rec;
--    EXIT WHEN l_user_values%NOTFOUND;
--  END LOOP;
--  CLOSE l_user_values;
--
--  IF G_DEBUG = 'Y' THEN
--    FND_MSG_PUB.ADD_EXC_MSG
--    ( G_PKG_NAME
--    , l_api_name
--    , '< initialize'
--
--    );
--  END IF;
--EXCEPTION
--  WHEN OTHERS THEN
--    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
--    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
--    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
--    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
--    FND_MSG_PUB.Add;
--    RAISE;
--
--END initialize;
--
--=============================================================================
-- API NAME      : Validate_Orgs
-- PRE-CONDITIONS: New Organization, Location, Parameters must be created.
-- DESCRIPTION   : Validate the org and call the function to validate entities
--                  for model org against new org.
-- PARAMETERS    :
--   p_group_code         REQUIRED. Group code created for Copy Org request.
--   p_model_org_code     REQUIRED. Model organization to copy from.
--   p_organization_code  REQUIRED. New organization to be created.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Validate_Orgs
IS
  l_api_name           VARCHAR2(30):='Validate_Orgs';
  l_error_msg          VARCHAR2(100):='';
  l_status             VARCHAR2(10);
  l_rec_type           VARCHAR2(30):='NEW_ORGANIZATION_SUMMARY';

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Validate_Orgs '
    );
  END IF;
  ---------------------------------------------------------------------------
  -- Call function to validate all entity records
  ---------------------------------------------------------------------------
  l_status := Validate_Entities;
  ---------------------------------------------------------------------------
  -- Insert record into Report table for succesfully
  -- created organization.
  ---------------------------------------------------------------------------
  Insert_Row ( p_location_code        => ''
             , p_business_group_name  => ''
             , p_status               => l_status
             , p_error_msg            => l_error_msg
             , p_rec_type             => l_rec_type
             , p_entity_type          => ''
             , p_copy_cnt             => null
             , p_modify_cnt           => null
             , p_exp_copy_cnt         => null
             , p_exp_modify_cnt       => null
	     , p_entity_name          => ''
	     , p_entity_inconsistency => ''
             , p_put_orgs             => true
             );

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Validate_Orgs '
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Validate_Orgs;

--=============================================================================
-- PROC NAME     : Validate_Locs
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate the location for model org against new org.
-- PARAMETERS    : None.
--
--=============================================================================
PROCEDURE Validate_Locs
IS
  l_api_name             VARCHAR2(30):='Validate_Locs';
  l_creation_date        DATE;
  --l_copyorg_time_stamp   DATE;
  l_location_code        VARCHAR2(255);
  l_location_id          NUMBER;
  l_business_group_name  VARCHAR2(255);
  l_status               VARCHAR2(10);
  l_rec_type             VARCHAR2(30):='NEW_LOCATION_SUMMARY';
-- Modified for bug 3838706
--  l_message              VARCHAR2(255);
  l_message              VARCHAR2(2000);
  --l_org_id               NUMBER;
  --l_excp_loc_cd_invalid  EXCEPTION;
  --l_excp_loc_message     EXCEPTION;

    --shpandey, added for R12 bug#4111958
  l_model_loc_exists     BOOLEAN := TRUE;
BEGIN
  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Validate_Locs'
    );
  END IF;

  l_status := g_location_status;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '- Retrieving Location Code, Business Group Name'
    );
  END IF;
  ---------------------------------------------------------------------------
  -- get location code, business group name for model
  ---------------------------------------------------------------------------
  -- Bug 4111958 : Added the following query block to check if model org have
  -- location or not.
  IF (l_status = 'PRE_EXIST') THEN
  BEGIN
    SELECT  loc.location_code, hou1.name, loc.location_id
    INTO    l_location_code, l_business_group_name, l_location_id
    FROM    hr_locations loc
          , hr_all_organization_units hou
          , hr_all_organization_units hou1
    WHERE   loc.location_id = hou.location_id
    AND     hou1.organization_id = hou.business_group_id
    AND     hou.organization_id = g_model_org_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
         l_model_loc_exists := FALSE;
  END;
  END IF;
-- START OF IF bug 4111958
  IF l_model_loc_exists THEN
  ---------------------------------------------------------------------------
  -- get location code, business group name for model/new organization.
  ---------------------------------------------------------------------------
  -- Bug 3441641 : Added location_id to the select clause
  --  Location id is used in the query below to get creation time
  --
    BEGIN
      SELECT  loc.location_code, hou1.name, loc.location_id
      INTO    l_location_code, l_business_group_name, l_location_id
      FROM    hr_locations loc
	    , hr_all_organization_units hou
            , hr_all_organization_units hou1
      WHERE   loc.location_id = hou.location_id
      AND     hou1.organization_id = hou.business_group_id
      AND     hou.organization_id = g_organization_id;
    EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;
-- END OF IF bug 4111958

    IF G_DEBUG = 'Y' THEN
      FND_MSG_PUB.ADD_EXC_MSG
      ( G_PKG_NAME
      , l_api_name
      , '- Retrieving Location creation date, copy org req. timestamp.'
      );
    END IF;
  -------------------------------------------------------------------------
  -- get message for location for status - PRE_EXIST, SUCCESS
  -------------------------------------------------------------------------
  -- Bug 3441641 : Changed query to retrieve the creation date based on
  --   location id. Earlier it was based on location code, but this fails
  --   in case the report is run in pseudo translated environment.
  --
  -- Bug 4111958 changed the if logic.
    IF (l_status = 'PRE_EXIST' AND l_model_loc_exists) THEN
      BEGIN
        SELECT  creation_date
	INTO  l_creation_date
	FROM  hr_locations locs
        WHERE  locs.location_id = l_location_id;
        EXCEPTION
        WHEN OTHERS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    FND_MESSAGE.SET_NAME  (application=>'INV', name=>'PRE_EXIST_ERROR');
    FND_MESSAGE.SET_TOKEN ('CREATION_DATE' , l_creation_date );
    FND_MESSAGE.SET_TOKEN ('TIMESTAMP', null);
    l_message := FND_MESSAGE.GET();

    ELSIF l_status = 'SUCCESS' THEN
      l_message := '';
    END IF;
  -------------------------------------------------------------------------
  -- Write message to report table for location.
  -------------------------------------------------------------------------
    Insert_Row ( p_location_code        => l_location_code
               , p_business_group_name  => l_business_group_name
               , p_status               => l_status
               , p_error_msg            => l_message
               , p_rec_type             => l_rec_type
               , p_entity_type          => ''
               , p_copy_cnt             => null
               , p_modify_cnt           => null
               , p_exp_copy_cnt         => null
               , p_exp_modify_cnt       => null
               , p_entity_name          => ''
	       , p_entity_inconsistency => ''
               , p_put_orgs             => false
               );

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Validate_Locs'
    );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Validate_Locs;

--=============================================================================
-- API NAME      : Trim_Array
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Remove blank / null elements from the array.
-- PARAMETERS    :
--   p_in_array    REQUIRED. Input Array to be trimmed.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Trim_Array (p_in_array  Char_Array) RETURN Char_Array
IS
  l_out_array  Char_Array := Char_Array();
  l_out_ctr    NUMBER := 0;
  l_out_idx    NUMBER := 1;
BEGIN
  FOR i IN 1..p_in_array.COUNT
  LOOP
    IF p_in_array(i) IS NOT NULL
    THEN
       l_out_ctr := l_out_ctr + 1;
    END IF;
  END LOOP;
  l_out_array.EXTEND(l_out_ctr);
  FOR i IN 1..p_in_array.COUNT
  LOOP
    IF p_in_array(i) IS NOT NULL
    THEN
      l_out_array(l_out_idx) := p_in_array(i);
      l_out_idx := l_out_idx + 1;
    END IF;
  END LOOP;
  RETURN l_out_array;
END Trim_Array;

--=============================================================================
-- PROC NAME     : Init_Vars
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Initialize variables for processing entities.
-- PARAMETERS    : p_entity_type. REQUIRED : Entity Type being validated.
-- EXCEPTIONS    : None.
--
--=============================================================================
PROCEDURE Init_Vars ( p_entity_type IN VARCHAR2 )
IS
  l_api_name   VARCHAR2(100):=' Init_Vars ';

BEGIN
  g_exp_modify_cnt  := 0;
  g_exp_copy_cnt    := 0;
  g_copy_cnt        := 0;
  g_modify_cnt      := 0;
  g_entity_idx      := 1;
  g_entity_count    := 0;
  g_entity_names    := Char_Array();
  g_not_to_copy     := false;
  g_entity_type     := p_entity_type;
  --------------------------------------------------------------------
  -- Removed support for Modified records.
  --------------------------------------------------------------------
  --g_modified        := false;
  --g_modified        := Is_Entity_Modified( g_entity_type );
  --------------------------------------------------------------------

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Init_Vars;

--=============================================================================
-- PROC NAME     : Validate_Entities
-- PRE-CONDITIONS: New Organization, Location, Parameters must be created.
-- DESCRIPTION   : Validate all entities for model org against new org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Validate_Entities RETURN VARCHAR2
IS
  l_api_name           VARCHAR2(100):= ' Validate_Entities ';
  l_entity_idx         NUMBER:=1;
  --l_error_status_flag BOOLEAN:=false;
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;

  CURSOR l_bom_params ( p_org_id IN NUMBER ) IS
    SELECT  COUNT(organization_id)
    FROM    bom_parameters
    WHERE   ORGANIZATION_ID = p_org_id;

  CURSOR l_rcv_params ( p_org_id IN NUMBER ) IS
    SELECT  COUNT(organization_id)
    FROM    rcv_parameters
    WHERE   ORGANIZATION_ID = p_org_id;

/*shpandey, Added the following cursors for newly added entities for R12*/
  CURSOR l_wip_params ( p_org_id IN NUMBER ) IS
    SELECT  COUNT(organization_id)
    FROM    wip_parameters
    WHERE   ORGANIZATION_ID = p_org_id;

  CURSOR l_shipping_params ( p_org_id IN NUMBER ) IS
    SELECT  COUNT(organization_id)
    FROM    wsh_shipping_parameters
    WHERE   ORGANIZATION_ID = p_org_id;

  CURSOR l_planning_params ( p_org_id IN NUMBER ) IS
    SELECT  COUNT(organization_id)
    FROM    mrp_parameters
    WHERE   ORGANIZATION_ID = p_org_id;
/*shpandey,R12*/

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Validate_Entities'
    );
  END IF;
  /*-----------------------------------
  ---- Organization Information -------
  -----------------------------------*/
  Init_Vars('INV_ORGANIZATION_INFORMATION');
  g_entity_names := Get_Err_Org_Information;
  Put_Report_Data;

  /*-----------------------------------
  ---- Inventory Parameters     -------
  -----------------------------------*/
  Init_Vars('INV_PARAMETERS');
  g_entity_names.EXTEND;
  g_entity_names(l_entity_idx):=1;
  Put_Report_Data;

  /*-----------------------------------
  ---- BOM Parameters           -------
  -----------------------------------*/
  Init_Vars('BOM_PARAMETERS');
  Open  l_bom_params ( g_organization_id );
  Fetch l_bom_params Into l_new_org_count;
  Close l_bom_params;

  Open  l_bom_params ( g_model_org_id );
  Fetch l_bom_params Into l_model_org_count;
  Close l_bom_params;

  IF  l_new_org_count < l_model_org_count
  THEN
    g_entity_names.EXTEND;
    --Set entity name as null for parameters APIs. bug:3575494 bug:4599267
    --g_entity_names(g_entity_idx):=g_entity_type; bug:4599267
    g_entity_names(g_entity_idx):=null;
    g_entity_idx:=g_entity_idx+1;
  END IF;
  g_entity_names.EXTEND;
  g_entity_names(g_entity_idx):=l_model_org_count;
  Put_Report_Data;

  /*-----------------------------------
  ---- Receiving Parameters     -------
  -----------------------------------*/
  Init_Vars('RCV_PARAMETERS');
  Open  l_rcv_params ( g_organization_id );
  Fetch l_rcv_params Into l_new_org_count;
  Close l_rcv_params;

  Open  l_rcv_params ( g_model_org_id );
  Fetch l_rcv_params Into l_model_org_count;
  Close l_rcv_params;

  IF  l_new_org_count < l_model_org_count
  THEN
    g_entity_names.EXTEND;
    --Set entity name as null for parameters APIs. bug:3575494 bug:4599267
    --g_entity_names(g_entity_idx):=g_entity_type; bug:4599267
    g_entity_names(g_entity_idx):=null;

    g_entity_idx:=g_entity_idx+1;
  END IF;
  g_entity_names.EXTEND;
  g_entity_names(g_entity_idx):=l_model_org_count;
  Put_Report_Data;

/* shpandey, Added for R12, code block start*/
 /*-----------------------------------
   ---- WIP Parameters           -------
   -----------------------------------*/
  Init_Vars('WIP_PARAMETERS');
  Open  l_wip_params ( g_organization_id );
  Fetch l_wip_params Into l_new_org_count;
  Close l_wip_params;

  Open  l_wip_params ( g_model_org_id );
  Fetch l_wip_params Into l_model_org_count;
  Close l_wip_params;

  IF  l_new_org_count < l_model_org_count
  THEN
    g_entity_names.EXTEND;
    --Set entity name as null for parameters APIs. bug:3575494 bug:4599267
    --g_entity_names(g_entity_idx):=g_entity_type; bug:4599267
    g_entity_names(g_entity_idx):= null;

    g_entity_idx:=g_entity_idx+1;
  END IF;
  g_entity_names.EXTEND;
  g_entity_names(g_entity_idx):=l_model_org_count;
  Put_Report_Data;

 /*-----------------------------------
  ---- WIP Accounting Classes   -------
  -----------------------------------*/
  Init_Vars('WIP_ACCOUNTING_CLASSES');
  g_entity_names := Get_Err_Wip_Acc_Classes;
  Put_Report_Data;

  /*-----------------------------------
  ---- Shipping Parameters      -------
  -----------------------------------*/
  Init_Vars('WSH_SHIPPING_PARAMETERS');
  Open  l_shipping_params ( g_organization_id );
  Fetch l_shipping_params Into l_new_org_count;
  Close l_shipping_params;

  Open  l_shipping_params ( g_model_org_id );
  Fetch l_shipping_params Into l_model_org_count;
  Close l_shipping_params;

  IF  l_new_org_count < l_model_org_count
  THEN
    g_entity_names.EXTEND;
    --Set entity name as null for parameters APIs. bug:3575494 bug:4599267
    --g_entity_names(g_entity_idx):=g_entity_type; bug:4599267
    g_entity_names(g_entity_idx):= null;

    g_entity_idx:=g_entity_idx+1;
  END IF;
  g_entity_names.EXTEND;
  g_entity_names(g_entity_idx):=l_model_org_count;
  Put_Report_Data;

  /*-----------------------------------
  ---- Planning Parameters     -------
  -----------------------------------*/
  Init_Vars('MRP_PLANNING_PARAMETERS');
  Open  l_planning_params ( g_organization_id );
  Fetch l_planning_params Into l_new_org_count;
  Close l_planning_params;

  Open  l_planning_params ( g_model_org_id );
  Fetch l_planning_params Into l_model_org_count;
  Close l_planning_params;

  IF  l_new_org_count < l_model_org_count
  THEN
    g_entity_names.EXTEND;
    --Set entity name as null for parameters APIs. bug:3575494 bug:4599267
    --g_entity_names(g_entity_idx):=g_entity_type; bug:4599267
    g_entity_names(g_entity_idx):= null;
    g_entity_idx:=g_entity_idx+1;
  END IF;
  g_entity_names.EXTEND;
  g_entity_names(g_entity_idx):=l_model_org_count;
  Put_Report_Data;
/* R12 code block end*/

  /*-----------------------------------
  ---- Subinventories           -------
  -----------------------------------*/
  Init_Vars('SUBINVENTORIES');
  g_entity_names := Get_Err_Subinv_Names;
  Put_Report_Data;

  /*-----------------------------------
  ---- Locators                 -------
  -----------------------------------*/
  Init_Vars('LOCATORS');
  g_entity_names := Get_Err_Mtl_Item_Locations;
  Put_Report_Data;

  /*-----------------------------------
  ---- Hierarchy Relations      -------
  -----------------------------------*/
  IF  g_assgn_hier = 'Y'
  THEN
    Init_Vars('HIERARCHY_RELATIONS');
    g_entity_names := Get_Err_Hierarchy;
    Put_Report_Data;
  END IF;

  /*-----------------------------------
  ---- Shipping Networks        -------
  -----------------------------------*/
  IF  g_copy_ship_net = 'Y'
  THEN
    Init_Vars('SHIPPING_NETWORKS');
    g_entity_names := Get_Err_Ship_Net;
    Put_Report_Data;
  END IF;

  /*-----------------------------------
  ---- Routings                 -------
  -----------------------------------*/
  IF  g_copy_routings = 'Y'
  THEN
    Init_Vars('BOM_DEPARTMENTS');
    g_entity_names := Get_Err_Bom_Departments;
    Put_Report_Data;

    Init_Vars('BOM_DEPARTMENT_RESOURCES');
    g_entity_names := Get_Err_Bom_Dept_Res;
    Put_Report_Data;

    Init_Vars('BOM_RESOURCES');
    g_entity_names := Get_Err_Bom_Resources;
    Put_Report_Data;

    Init_Vars('CST_RESOURCE_COSTS');
    g_entity_names := Get_Err_Cst_Res_Costs;
    Put_Report_Data;

    Init_Vars('CST_RESOURCE_OVERHEAD');
    g_entity_names := Get_Err_Cst_Res_Ovhds;
    Put_Report_Data;

    Init_Vars('BOM_DEPARTMENT_CLASSES');
    g_entity_names := Get_Err_Bom_Dept_Classes;
    Put_Report_Data;

    Init_Vars('STANDARD_OPERATIONS');
    g_entity_names := Get_Err_StdOperations;
    Put_Report_Data;

    Init_Vars('ROUTINGS');
    g_entity_names := Get_Err_Routings;
    Put_Report_Data;
  END IF;

  /*-----------------------------------
  ---- BOMS                     -------
  -----------------------------------*/
  IF  g_copy_boms = 'Y'
  THEN
    Init_Vars('BOMS');
    g_entity_names := Get_Err_Bom_Bom;
    Put_Report_Data;
  END IF;

  /*-----------------------------------
  ---- BOMS Or ROUTINGS         -------
  -----------------------------------*/
  IF  g_copy_boms = 'Y'
  OR  g_copy_routings = 'Y'
  THEN
    Init_Vars('BOM_ALTERNATE_DESIGNATORS');
    g_entity_names := Get_Err_Bom_Alt_Desig;
    Put_Report_Data;
  END IF;

  /*-----------------------------------
  ---- Items                    -------
  -----------------------------------*/
  IF  g_copy_items = 'Y'
  THEN
    Init_Vars('ITEMS');
    g_entity_names := Get_Err_Mtl_Items;
    Put_Report_Data;

    Init_Vars('ITEM_CATEGORIES');
    g_entity_names := Get_Err_Mtl_Item_Cat;
    Put_Report_Data;

    Init_Vars('ITEM_REVISIONS');
    g_entity_names := Get_Err_Mtl_Item_Rev;
    Put_Report_Data;

    Init_Vars('ITEM_SUBINVENTORIES');
    g_entity_names := Get_Err_Mtl_Items_Subinv;
    Put_Report_Data;
  END IF;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Validate_Entities'
    );
  END IF;

  IF g_error_status_flag THEN
    RETURN 'ERROR';
  END IF;

  RETURN 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Validate_Entities;

--=============================================================================
-- FUNCTION NAME : Get_Err_Hierarchy
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate hierarchies to which new org is assigned against
--                   those for model org.
-- PARAMETERS    : None
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Hierarchy RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Hierarchy ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= 'Hierarchy Relations';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_hierarchy          VARCHAR2(100);

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT DISTINCT hier.NAME
    FROM   PER_ORG_STRUCTURE_ELEMENTS mdl
         , PER_ORG_STRUCTURE_VERSIONS ver
         , PER_ORGANIZATION_STRUCTURES hier
    WHERE  ORGANIZATION_ID_CHILD = p_model_org_id
    AND    ver.ORG_STRUCTURE_VERSION_ID = mdl.ORG_STRUCTURE_VERSION_ID
    AND    hier.ORGANIZATION_STRUCTURE_ID = ver.ORGANIZATION_STRUCTURE_ID
    AND    NOT EXISTS
     ( SELECT 'x'
       FROM   PER_ORG_STRUCTURE_ELEMENTS new
       WHERE  ORGANIZATION_ID_CHILD = p_organization_id
       AND    new.ORG_STRUCTURE_VERSION_ID = mdl.ORG_STRUCTURE_VERSION_ID
     );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(pos.ORG_STRUCTURE_ELEMENT_ID)
    FROM    PER_ORG_STRUCTURE_ELEMENTS pos
    WHERE   pos.ORGANIZATION_ID_CHILD = p_org_id;

BEGIN
  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Err_Hierarchy'
    );
    --dbms_output.put_line('> Get_Err_Hierarchy');
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_hierarchy;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_hierarchy;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_hierarchy;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx) := l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Hierarchy;
--=============================================================================
-- FUNCTION NAME : Get_Err_Subinv_Names
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate subinventories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Subinv_Names RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Subinv_Names ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Subinventories ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_subinventory       VARCHAR2(100);

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  msi.SECONDARY_INVENTORY_NAME
    FROM    MTL_SECONDARY_INVENTORIES msi
    WHERE   msi.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
    ( SELECT  'x'
      FROM    MTL_SECONDARY_INVENTORIES msi2
      WHERE   msi2.ORGANIZATION_ID = p_organization_id
      AND     msi.SECONDARY_INVENTORY_NAME = msi2.SECONDARY_INVENTORY_NAME
    );
  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(msi.SECONDARY_INVENTORY_NAME)
    FROM    MTL_SECONDARY_INVENTORIES msi
    WHERE   msi.ORGANIZATION_ID = p_org_id;

BEGIN
  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Err_Subinv_Names'
    );
    --dbms_output.put_line('> Get_Err_Subinv_Names');
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_subinventory;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_subinventory;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_subinventory;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx) := l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Subinv_Names;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Resources
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom resources created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Resources RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Resources ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Resources ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_res_code           VARCHAR2(100);

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  br1.RESOURCE_CODE rescode
    FROM    BOM_RESOURCES br1
    WHERE   br1.ORGANIZATION_ID = g_model_org_id
    AND     br1.COST_ELEMENT_ID IN (3,4) /* vmutyala added this condition to distinguish resource overheads and resources in the report */
    AND     NOT EXISTS  ( SELECT  'x'
                          FROM    BOM_RESOURCES br2
                          WHERE   br2.ORGANIZATION_ID = g_organization_id
                          AND     br2.RESOURCE_CODE = br1.RESOURCE_CODE
			  AND     br2.COST_ELEMENT_ID IN (3,4) /* vmutyala added this condition to distinguish
			                                   resource overheads and resources in the report */
                        );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(br.RESOURCE_CODE)
    FROM    BOM_RESOURCES br
    WHERE   br.ORGANIZATION_ID = p_org_id
    AND     br.COST_ELEMENT_ID IN (3,4);  /* vmutyala added this condition to distinguish resource overheads
                                         and resources in the report */

BEGIN
  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Err_Bom_Resources'
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_res_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_res_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;
      FETCH l_cursor INTO l_res_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;
  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Resources;
--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Departments
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom departments created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Departments RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Departments ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_entity_names       Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_dep_code           VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Departments ';

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  bd1.DEPARTMENT_CODE
    FROM    BOM_DEPARTMENTS bd1
    WHERE   bd1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS ( SELECT  'x'
                         FROM    BOM_DEPARTMENTS bd2
                         WHERE   bd2.ORGANIZATION_ID=p_organization_id
                         AND     bd2.DEPARTMENT_CODE=bd1.DEPARTMENT_CODE
                       );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(bd.DEPARTMENT_CODE)
    FROM    BOM_DEPARTMENTS bd
    WHERE   bd.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Err_Bom_Departments'
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_dep_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_dep_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_dep_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;
  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Departments;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Dept_Classes
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom department classes created for new org against
--                   those in model org.
-- PARAMETERS    :
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Dept_Classes RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Dept_Classes ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_entity_names       Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_dep_cls_code       VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Department Classes ';

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  bdc1.DEPARTMENT_CLASS_CODE
    FROM    BOM_DEPARTMENT_CLASSES bdc1
    WHERE   bdc1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    BOM_DEPARTMENT_CLASSES bdc2
        WHERE   bdc2.ORGANIZATION_ID = p_organization_id
        AND     bdc2.DEPARTMENT_CLASS_CODE = bdc1.DEPARTMENT_CLASS_CODE
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(ent.DEPARTMENT_CLASS_CODE)
    FROM    BOM_DEPARTMENT_CLASSES ent
    WHERE   ent.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_dep_cls_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_dep_cls_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_dep_cls_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;
  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Dept_Classes;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Alt_Desig
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate bom alternate designators created for new org
--                   against those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Alt_Desig RETURN Char_Array
IS
  l_alt_desig_code     VARCHAR2(100);
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Alt_Desig ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Alternate Designators ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  bad1.ALTERNATE_DESIGNATOR_CODE
    FROM    BOM_ALTERNATE_DESIGNATORS bad1
    WHERE   bad1.ORGANIZATION_ID=g_model_org_id
    AND     NOT EXISTS
      ( SELECT  bad2.ALTERNATE_DESIGNATOR_CODE
        FROM    BOM_ALTERNATE_DESIGNATORS bad2
        WHERE   bad2.ORGANIZATION_ID=g_organization_id
        AND     bad2.ALTERNATE_DESIGNATOR_CODE=bad1.ALTERNATE_DESIGNATOR_CODE
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(bad.ALTERNATE_DESIGNATOR_CODE)
    FROM    BOM_ALTERNATE_DESIGNATORS bad
    WHERE   bad.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_alt_desig_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_alt_desig_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_alt_desig_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Alt_Desig;
--=============================================================================
-- FUNCTION NAME : Get_Err_Ship_Net
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate shipping networks created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Ship_Net RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Ship_Net ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Shipping Networks ';
  l_model_count_from   NUMBER;
  l_model_count_to     NUMBER;
  l_model_org_count    NUMBER;
  l_new_count_from     NUMBER;
  l_new_count_to       NUMBER;
  l_new_org_count      NUMBER;
  l_org_code           VARCHAR2(100);

  CURSOR l_from  ( p_model_org_id     NUMBER
		 , p_organization_id  NUMBER
		 )
  IS
    SELECT  mp.ORGANIZATION_CODE
    FROM    MTL_INTERORG_PARAMETERS mip1
	  , MTL_PARAMETERS mp
    WHERE   mip1.FROM_ORGANIZATION_ID = p_model_org_id
    AND     mp.ORGANIZATION_ID = mip1.TO_ORGANIZATION_ID
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_INTERORG_PARAMETERS mip2
        WHERE   mip2.FROM_ORGANIZATION_ID = p_organization_id
        AND     mip2.TO_ORGANIZATION_ID = mip1.TO_ORGANIZATION_ID
      );

  CURSOR l_to  ( p_model_org_id     NUMBER
	       , p_organization_id  NUMBER
	       )
  IS
    SELECT  mp.ORGANIZATION_CODE
    FROM    MTL_INTERORG_PARAMETERS mip1
	  , MTL_PARAMETERS mp
    WHERE   mip1.TO_ORGANIZATION_ID = p_model_org_id
    AND     mp.ORGANIZATION_ID = mip1.FROM_ORGANIZATION_ID
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_INTERORG_PARAMETERS mip2
        WHERE   mip2.TO_ORGANIZATION_ID = p_organization_id
        AND     mip2.FROM_ORGANIZATION_ID = mip1.FROM_ORGANIZATION_ID
      );

  CURSOR l_cnt_csr1 ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(mip.TO_ORGANIZATION_ID)
    FROM    MTL_INTERORG_PARAMETERS mip
    WHERE   mip.FROM_ORGANIZATION_ID = p_org_id;

  CURSOR l_cnt_csr2 ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(mip.FROM_ORGANIZATION_ID)
    FROM    MTL_INTERORG_PARAMETERS mip
    WHERE   mip.TO_ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr1 ( g_model_org_id );
  FETCH l_cnt_csr1 INTO l_model_count_from;
  CLOSE l_cnt_csr1;

  OPEN  l_cnt_csr2 ( g_model_org_id );
  FETCH l_cnt_csr2 INTO l_model_count_to;
  CLOSE l_cnt_csr2;

  OPEN  l_cnt_csr1 ( g_organization_id );
  FETCH l_cnt_csr1 INTO l_new_count_from;
  CLOSE l_cnt_csr1;

  OPEN  l_cnt_csr2 ( g_organization_id );
  FETCH l_cnt_csr2 INTO l_new_count_to;
  CLOSE l_cnt_csr2;

  IF  l_new_count_from < l_model_count_from
  THEN
    OPEN l_from ( g_model_org_id, g_organization_id );
    FETCH l_from INTO l_org_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_org_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_from INTO l_org_code;
      EXIT WHEN l_from%NOTFOUND;
    END LOOP;
    CLOSE l_from;
  END IF;

  IF  l_new_count_to   < l_model_count_to
  THEN
    OPEN l_to ( g_model_org_id, g_organization_id );
    FETCH l_to INTO l_org_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_org_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_to INTO l_org_code;
      EXIT WHEN l_to%NOTFOUND;
    END LOOP;
    CLOSE l_to;
  END IF;
  l_model_org_count := l_model_count_from + l_model_count_to;
  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;
  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Ship_Net;
--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Bom
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate boms created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Bom RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Bom ';
  --l_count              NUMBER:=0;
  l_p_model_count      NUMBER;
  l_p_new_count        NUMBER;
  l_c1_model_count     NUMBER;
  l_c1_new_count       NUMBER;
  l_c2_model_count     NUMBER;
  l_c2_new_count       NUMBER;
  l_c3_model_count     NUMBER;
  l_c3_new_count       NUMBER;
  l_c4_model_count     NUMBER;
  l_c4_new_count       NUMBER;
  l_count_tmp          NUMBER;
  l_entity_names       Char_Array := Char_Array();
  l_entity_names_fin   Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_bom_code           VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Bill of Materials ';

  CURSOR l_parent ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  msi.CONCATENATED_SEGMENTS
    FROM    BOM_BILL_OF_MATERIALS bom
	  , MTL_SYSTEM_ITEMS_KFV msi
    WHERE   msi.ORGANIZATION_ID = bom.ORGANIZATION_ID
    AND     msi.INVENTORY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
    AND     bom.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_BILL_OF_MATERIALS bom1
        WHERE  bom1.ORGANIZATION_ID = p_organization_id
        AND    bom1.ASSEMBLY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
	/*vmutyala added this condition because alternate boms which are not copied are not being reported by earlier query*/
	AND    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NULL') = nvl(bom1.ALTERNATE_BOM_DESIGNATOR,'NULL')
      );

  CURSOR l_parent_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(ASSEMBLY_ITEM_ID)
    FROM    BOM_STRUCTURES_B	--myerrams, Bug: 4913484. Replaced the view BOM_BILL_OF_MATERIALS with BOM_STRUCTURES_B table
    WHERE   ORGANIZATION_ID = p_org_id;

  CURSOR l_child_1 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
   SELECT kfv.CONCATENATED_SEGMENTS, COUNT(bic.COMPONENT_SEQUENCE_ID)
   FROM   BOM_INVENTORY_COMPONENTS bic
        , BOM_BILL_OF_MATERIALS    bom
        , MTL_SYSTEM_ITEMS_KFV     kfv
   WHERE  bom.ORGANIZATION_ID = p_model_org_id
   AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
   AND    kfv.INVENTORY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
   AND    kfv.ORGANIZATION_ID = bom.ORGANIZATION_ID
   AND    NOT EXISTS
     (
       SELECT 'x'
       FROM   BOM_INVENTORY_COMPONENTS bic1
            , BOM_BILL_OF_MATERIALS    bom1
       WHERE  bom1.ORGANIZATION_ID = p_organization_id
       AND    bic1.BILL_SEQUENCE_ID = bom1.BILL_SEQUENCE_ID
       AND    bom1.ASSEMBLY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
/*vmutyala added this condition because alternate boms which are not copied are not being reported by earlier query*/
       AND    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NULL') = nvl(bom1.ALTERNATE_BOM_DESIGNATOR,'NULL')
       AND    nvl(bic.COMPONENT_ITEM_ID,1) = nvl(bic1.COMPONENT_ITEM_ID,1)
     )
   GROUP BY kfv.CONCATENATED_SEGMENTS;

  CURSOR l_child_1_cnt (p_org_id  NUMBER)
  IS
   SELECT COUNT(bic.COMPONENT_SEQUENCE_ID)
   FROM   BOM_INVENTORY_COMPONENTS bic
        , BOM_BILL_OF_MATERIALS    bom
   WHERE  bom.ORGANIZATION_ID = p_org_id
   AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID;

  CURSOR l_child_2 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS, COUNT(bsc.COMPONENT_SEQUENCE_ID)
    FROM   BOM_SUBSTITUTE_COMPONENTS bsc
         , BOM_INVENTORY_COMPONENTS  bic
         , BOM_BILL_OF_MATERIALS     bom
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  bom.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = bom.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
    AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
    AND    bsc.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID
    AND    NOT EXISTS
     (
       SELECT 'x'
       FROM   BOM_INVENTORY_COMPONENTS  bic1
            , BOM_BILL_OF_MATERIALS     bom1
            , BOM_SUBSTITUTE_COMPONENTS bsc1
       WHERE  bom1.ORGANIZATION_ID = p_organization_id
       AND    bic1.BILL_SEQUENCE_ID = bom1.BILL_SEQUENCE_ID
       AND    bsc1.COMPONENT_SEQUENCE_ID = bic1.COMPONENT_SEQUENCE_ID
       AND    bom1.ASSEMBLY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
/*vmutyala added this condition because alternate boms which are not copied are not being reported by earlier query*/
       AND    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NULL') = nvl(bom1.ALTERNATE_BOM_DESIGNATOR,'NULL')
       AND    nvl(bic.COMPONENT_ITEM_ID,1) = nvl(bic1.COMPONENT_ITEM_ID,1)
       AND    nvl(bsc.ACD_TYPE,1) = nvl(bsc1.ACD_TYPE,1)
       AND    bsc.SUBSTITUTE_COMPONENT_ID = bsc1.SUBSTITUTE_COMPONENT_ID
     )
    GROUP BY MSI.CONCATENATED_SEGMENTS;

  CURSOR l_child_2_cnt (p_org_id  NUMBER)
  IS
   SELECT COUNT(bsc.SUBSTITUTE_COMPONENT_ID)
   FROM   BOM_INVENTORY_COMPONENTS  bic
        , BOM_BILL_OF_MATERIALS     bom
        , BOM_SUBSTITUTE_COMPONENTS bsc
   WHERE  bom.ORGANIZATION_ID = p_org_id
   AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
   AND    bsc.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID;

  CURSOR l_child_3 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS, COUNT(brd.COMPONENT_SEQUENCE_ID)
    FROM   BOM_REFERENCE_DESIGNATORS brd
         , BOM_INVENTORY_COMPONENTS  bic
         , BOM_BILL_OF_MATERIALS     bom
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  bom.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = bom.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
    AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
    AND    brd.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID
    AND    NOT EXISTS
     (
       SELECT 'x'
       FROM   BOM_INVENTORY_COMPONENTS  bic1
            , BOM_BILL_OF_MATERIALS     bom1
            , BOM_REFERENCE_DESIGNATORS brd1
       WHERE  bom1.ORGANIZATION_ID = p_organization_id
       AND    bic1.BILL_SEQUENCE_ID = bom1.BILL_SEQUENCE_ID
       AND    brd1.COMPONENT_SEQUENCE_ID = bic1.COMPONENT_SEQUENCE_ID
       AND    bom1.ASSEMBLY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
 /*vmutyala added this condition because alternate boms which are not copied are not being reported by earlier query*/
       AND    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NULL') = nvl(bom1.ALTERNATE_BOM_DESIGNATOR,'NULL')
       AND    nvl(bic.COMPONENT_ITEM_ID,1) = nvl(bic1.COMPONENT_ITEM_ID,1)
       AND    brd.COMPONENT_REFERENCE_DESIGNATOR = brd1.COMPONENT_REFERENCE_DESIGNATOR
       AND    nvl(brd.ACD_TYPE,1) = nvl(brd1.ACD_TYPE,1)
     )
    GROUP BY MSI.CONCATENATED_SEGMENTS;

  CURSOR l_child_3_cnt (p_org_id  NUMBER)
  IS
   SELECT COUNT(brd.COMPONENT_REFERENCE_DESIGNATOR)
   FROM   BOM_INVENTORY_COMPONENTS  bic
        , BOM_BILL_OF_MATERIALS     bom
        , BOM_REFERENCE_DESIGNATORS brd
   WHERE  bom.ORGANIZATION_ID = p_org_id
   AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
   AND    brd.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID;

  CURSOR l_child_4 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS, COUNT(bco.COMPONENT_SEQUENCE_ID)
    FROM   BOM_COMPONENT_OPERATIONS  bco
         , BOM_INVENTORY_COMPONENTS  bic
         , BOM_BILL_OF_MATERIALS     bom
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  bom.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = bom.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
    AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
    AND    bco.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID
    AND    NOT EXISTS
     (
       SELECT 'x'
       FROM   BOM_INVENTORY_COMPONENTS  bic1
            , BOM_BILL_OF_MATERIALS     bom1
            , BOM_COMPONENT_OPERATIONS  bco1
       WHERE  bom1.ORGANIZATION_ID = p_organization_id
       AND    bic1.BILL_SEQUENCE_ID = bom1.BILL_SEQUENCE_ID
       AND    bco1.COMPONENT_SEQUENCE_ID = bic1.COMPONENT_SEQUENCE_ID
       AND    bom1.ASSEMBLY_ITEM_ID = bom.ASSEMBLY_ITEM_ID
 /*vmutyala added this condition because alternate boms which are not copied are not being reported by earlier query*/
       AND    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NULL') = nvl(bom1.ALTERNATE_BOM_DESIGNATOR,'NULL')
       AND    nvl(bic.COMPONENT_ITEM_ID,1) = nvl(bic1.COMPONENT_ITEM_ID,1)
     )
    GROUP BY MSI.CONCATENATED_SEGMENTS;

  CURSOR l_child_4_cnt (p_org_id  NUMBER)
  IS
   SELECT COUNT(bco.COMP_OPERATION_SEQ_ID)
   FROM   BOM_INVENTORY_COMPONENTS  bic
        , BOM_BILL_OF_MATERIALS     bom
        , BOM_COMPONENT_OPERATIONS  bco
   WHERE  bom.ORGANIZATION_ID = p_org_id
   AND    bic.BILL_SEQUENCE_ID = bom.BILL_SEQUENCE_ID
   AND    bco.COMPONENT_SEQUENCE_ID = bic.COMPONENT_SEQUENCE_ID;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_parent_cnt ( g_model_org_id );
  FETCH l_parent_cnt INTO l_p_model_count;
  CLOSE l_parent_cnt;

  OPEN  l_parent_cnt ( g_organization_id );
  FETCH l_parent_cnt INTO l_p_new_count;
  CLOSE l_parent_cnt;

  IF l_p_new_count < l_p_model_count
  THEN
    OPEN l_parent ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_parent INTO l_bom_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_bom_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_parent INTO l_bom_code;
      EXIT WHEN l_parent%NOTFOUND;
    END LOOP;
    CLOSE l_parent;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;

  END IF;

  OPEN  l_child_1_cnt ( g_model_org_id );
  FETCH l_child_1_cnt INTO l_c1_model_count;
  CLOSE l_child_1_cnt;

  OPEN  l_child_1_cnt ( g_organization_id );
  FETCH l_child_1_cnt INTO l_c1_new_count;
  CLOSE l_child_1_cnt;

  IF l_c1_new_count < l_c1_model_count
  THEN
    OPEN l_child_1 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_1 INTO l_bom_code, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_bom_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_1 INTO l_bom_code, l_count_tmp;
      EXIT WHEN l_child_1%NOTFOUND;
    END LOOP;
    CLOSE l_child_1;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  OPEN  l_child_2_cnt ( g_model_org_id );
  FETCH l_child_2_cnt INTO l_c2_model_count;
  CLOSE l_child_2_cnt;

  OPEN  l_child_2_cnt ( g_organization_id );
  FETCH l_child_2_cnt INTO l_c2_new_count;
  CLOSE l_child_2_cnt;

  IF l_c2_new_count < l_c2_model_count
  THEN
    OPEN l_child_2 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_2 INTO l_bom_code, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_bom_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_2 INTO l_bom_code, l_count_tmp;
      EXIT WHEN l_child_2%NOTFOUND;
    END LOOP;
    CLOSE l_child_2;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;

  END IF;

  OPEN  l_child_3_cnt ( g_model_org_id );
  FETCH l_child_3_cnt INTO l_c3_model_count;
  CLOSE l_child_3_cnt;

  OPEN  l_child_3_cnt ( g_organization_id );
  FETCH l_child_3_cnt INTO l_c3_new_count;
  CLOSE l_child_3_cnt;

  IF l_c3_new_count < l_c3_model_count
  THEN
    OPEN l_child_3 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_3 INTO l_bom_code, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_bom_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_3 INTO l_bom_code, l_count_tmp;
      EXIT WHEN l_child_3%NOTFOUND;
    END LOOP;
    CLOSE l_child_3;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;

  END IF;

  OPEN  l_child_4_cnt ( g_model_org_id );
  FETCH l_child_4_cnt INTO l_c4_model_count;
  CLOSE l_child_4_cnt;

  OPEN  l_child_4_cnt ( g_organization_id );
  FETCH l_child_4_cnt INTO l_c4_new_count;
  CLOSE l_child_4_cnt;

  IF l_c4_new_count < l_c4_model_count
  THEN
    OPEN l_child_4 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_4 INTO l_bom_code, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_bom_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_4 INTO l_bom_code, l_count_tmp;
      EXIT WHEN l_child_4%NOTFOUND;
    END LOOP;
    CLOSE l_child_4;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;

  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_p_model_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Bom;

--=============================================================================
-- FUNCTION NAME : Get_Err_Org_Information
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate org information created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Org_Information RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Org_Information ';
  --l_count              NUMBER:=0;
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;
  l_entity_names       Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_org_info_context   VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Organization Information ';

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  ent.ORG_INFORMATION_CONTEXT
    FROM    HR_ORGANIZATION_INFORMATION ent
    WHERE   ent.ORGANIZATION_ID = p_model_org_id
    AND   (   (ORG_INFORMATION_CONTEXT = 'CLASS'
               AND ORG_INFORMATION1 = 'INV'
              )
           OR (ORG_INFORMATION_CONTEXT <> 'CLASS'
               AND ORG_INFORMATION_CONTEXT IN
                   ( SELECT  ORG_INFORMATION_TYPE
                     FROM    HR_ORG_INFO_TYPES_BY_CLASS
                     WHERE   ORG_CLASSIFICATION = 'INV'
                   )
              )
          )
    MINUS
    SELECT  ent.ORG_INFORMATION_CONTEXT
    FROM    HR_ORGANIZATION_INFORMATION ent
    WHERE   ent.ORGANIZATION_ID = p_organization_id
    AND   (   (ORG_INFORMATION_CONTEXT = 'CLASS'
               AND ORG_INFORMATION1 = 'INV'
              )
           OR (ORG_INFORMATION_CONTEXT <> 'CLASS'
               AND ORG_INFORMATION_CONTEXT IN
                   ( SELECT  ORG_INFORMATION_TYPE
                     FROM    HR_ORG_INFO_TYPES_BY_CLASS
                     WHERE   ORG_CLASSIFICATION = 'INV'
                   )
              )
          );

  CURSOR l_cursor_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(ent.ORG_INFORMATION_CONTEXT)
    FROM    HR_ORGANIZATION_INFORMATION ent
    WHERE   ent.ORGANIZATION_ID = p_org_id
    AND   (   (ORG_INFORMATION_CONTEXT = 'CLASS'
               AND ORG_INFORMATION1 = 'INV'
              )
           OR (ORG_INFORMATION_CONTEXT <> 'CLASS'
               AND ORG_INFORMATION_CONTEXT IN
                   ( SELECT  ORG_INFORMATION_TYPE
                     FROM    HR_ORG_INFO_TYPES_BY_CLASS
                     WHERE   ORG_CLASSIFICATION = 'INV'
                   )
              )
          );

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cursor_cnt ( g_model_org_id );
  FETCH l_cursor_cnt INTO l_model_org_count;
  CLOSE l_cursor_cnt;

  OPEN  l_cursor_cnt ( g_organization_id );
  FETCH l_cursor_cnt INTO l_new_org_count;
  CLOSE l_cursor_cnt;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id, g_organization_id );
    FETCH l_cursor INTO l_org_info_context;
    LOOP
      IF  l_org_info_context <> null
      AND l_org_info_context <> ''
      THEN
        l_entity_names.EXTEND;
        l_entity_names(l_entity_arr_idx) := l_org_info_context;
        l_entity_arr_idx := l_entity_arr_idx + 1;

--      moved these statements after if block
--      for bug 3623168
--        FETCH l_cursor INTO l_org_info_context;
--        EXIT WHEN l_cursor%NOTFOUND;
      END IF;
--    Added these two statements for bug 3623168
      FETCH l_cursor INTO l_org_info_context;
      EXIT WHEN l_cursor%NOTFOUND;

    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=to_char(l_model_org_count);

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Org_Information;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Items
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate items, categories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Items RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Mtl_Items ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Items ';
  l_item_name          VARCHAR2(100);
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  kfv.CONCATENATED_SEGMENTS
    FROM    MTL_SYSTEM_ITEMS_B msi1
	  , MTL_SYSTEM_ITEMS_KFV kfv
    WHERE   kfv.ORGANIZATION_ID = msi1.ORGANIZATION_ID
    AND     kfv.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
    AND     msi1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_SYSTEM_ITEMS_B msi2
        WHERE   msi2.INVENTORY_ITEM_ID = msi1.INVENTORY_ITEM_ID
        AND     msi2.ORGANIZATION_ID = p_organization_id
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(msi.INVENTORY_ITEM_ID)
    FROM    MTL_SYSTEM_ITEMS_B msi
    WHERE   msi.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_item_name;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Mtl_Items;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Cat
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item categories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Cat RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):=' Get_Err_Mtl_Item_Cat ';
  l_entity_arr_idx     NUMBER:=1;
  l_entity_names       Char_Array:= Char_Array();
  --l_entity_type        VARCHAR2(100):=' Item Categories ';
  l_item_name          VARCHAR2(100);
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  distinct kfv.CONCATENATED_SEGMENTS
    FROM    MTL_ITEM_CATEGORIES mic1
          , MTL_CATEGORIES_KFV kfv
    WHERE   kfv.CATEGORY_ID = mic1.CATEGORY_ID
    AND     mic1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_ITEM_CATEGORIES mic2
        WHERE   mic2.CATEGORY_ID = mic1.CATEGORY_ID
        AND     mic2.ORGANIZATION_ID = p_organization_id
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(DISTINCT kfv.CONCATENATED_SEGMENTS)
    FROM    MTL_ITEM_CATEGORIES mic1
          , MTL_CATEGORIES_KFV kfv
    WHERE   kfv.CATEGORY_ID = mic1.CATEGORY_ID
    AND     mic1.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_item_name;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Mtl_Item_Cat;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Rev
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item revisions created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Rev RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):=' Get_Err_Mtl_Item_Rev ';
  l_entity_arr_idx     NUMBER:=1;
  l_entity_names       Char_Array:= Char_Array();
  --l_entity_type        VARCHAR2(100):=' Item Revisions ';
  l_item_name          VARCHAR2(100);
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  kfv.CONCATENATED_SEGMENTS||': '||rev1.REVISION
    FROM    MTL_ITEM_REVISIONS rev1
	  , MTL_SYSTEM_ITEMS_KFV kfv
    WHERE   kfv.ORGANIZATION_ID = rev1.ORGANIZATION_ID
    AND     kfv.INVENTORY_ITEM_ID = rev1.INVENTORY_ITEM_ID
    AND     rev1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_ITEM_REVISIONS rev2
        WHERE   rev2.REVISION = rev1.REVISION
        AND     rev2.INVENTORY_ITEM_ID = rev1.INVENTORY_ITEM_ID
        AND     rev2.ORGANIZATION_ID = p_organization_id
      );

-- Bug : 3637921 Modified the MTL_ITEM_REVISIONS view usage with
-- 	 with the MTL_ITEM_REVISIONS_B base table.
  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(rev.REVISION_ID)
    FROM    MTL_ITEM_REVISIONS_B rev
    WHERE   rev.ORGANIZATION_ID=p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_item_name;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;

  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Mtl_Item_Rev;

--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Items_Subinv
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate item subinventories created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Items_Subinv RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Mtl_Items_Subinv ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_entity_names       Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_item_name          VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Item Subinventory ';

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  kfv.CONCATENATED_SEGMENTS||': '||sub1.SECONDARY_INVENTORY
    FROM    MTL_ITEM_SUB_INVENTORIES sub1
          , MTL_SYSTEM_ITEMS_KFV kfv
    WHERE   kfv.ORGANIZATION_ID = sub1.ORGANIZATION_ID
    AND     kfv.INVENTORY_ITEM_ID = sub1.INVENTORY_ITEM_ID
    AND     sub1.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_ITEM_SUB_INVENTORIES sub2
        WHERE   sub2.SECONDARY_INVENTORY = sub1.SECONDARY_INVENTORY
        AND     sub2.INVENTORY_ITEM_ID = sub1.INVENTORY_ITEM_ID
        AND     sub2.ORGANIZATION_ID = p_organization_id
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(sub.SECONDARY_INVENTORY)
    FROM    MTL_ITEM_SUB_INVENTORIES sub
    WHERE   sub.ORGANIZATION_ID=p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_item_name;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Mtl_Items_Subinv;
--=============================================================================
-- FUNCTION NAME : Get_Err_Mtl_Item_Locations
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate Item Locations created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Mtl_Item_Locations RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Mtl_Item_Locations ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Item Locations ';
  l_item_name          VARCHAR2(100);
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER:=0;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  kfv1.CONCATENATED_SEGMENTS
    FROM    MTL_ITEM_LOCATIONS loc1
	  , MTL_ITEM_LOCATIONS_KFV kfv1
    WHERE   kfv1.ORGANIZATION_ID=loc1.ORGANIZATION_ID
    AND     kfv1.INVENTORY_LOCATION_ID=loc1.INVENTORY_LOCATION_ID
    AND     loc1.ORGANIZATION_ID=p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    MTL_ITEM_LOCATIONS loc2
              , MTL_ITEM_LOCATIONS_KFV kfv2
        WHERE   loc2.ORGANIZATION_ID=p_organization_id
        AND     kfv2.INVENTORY_LOCATION_ID=loc2.INVENTORY_LOCATION_ID
        AND     kfv2.ORGANIZATION_ID=loc2.ORGANIZATION_ID
        AND     kfv2.CONCATENATED_SEGMENTS=kfv1.CONCATENATED_SEGMENTS
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(loc.INVENTORY_LOCATION_ID)
    FROM    MTL_ITEM_LOCATIONS loc
    WHERE   loc.ORGANIZATION_ID=p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_item_name;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Mtl_Item_Locations;
--=============================================================================
-- FUNCTION NAME : Get_Unique_List
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Remove duplicate entries from an array.
-- PARAMETERS    :
--   p_array       REQUIRED. Array containing duplicate records.
--
-- RETURNS       : Array containing unique records ( Char_Array )
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Unique_List ( p_array Char_Array ) RETURN Char_Array
IS
  l_unique_list    Char_Array := Char_Array();
  l_counter        NUMBER     := 1;
  b_duplicate_rec  BOOLEAN    := false;
BEGIN
  l_unique_list.extend(p_array.COUNT);
  FOR j IN 1..p_array.COUNT
  LOOP
    FOR i IN 1..j
    LOOP
      IF ( p_array(j) = l_unique_list(i) )
      THEN
        b_duplicate_rec := true;
      END IF;
    END LOOP;
    IF NOT b_duplicate_rec
    THEN
      l_unique_list(l_counter) := p_array(j);
      l_counter := l_counter + 1;
    END IF;
    b_duplicate_rec := false;
  END LOOP;
  RETURN (l_unique_list);
END Get_Unique_List;

--=============================================================================
-- FUNCTION NAME : Get_Err_StdOperations
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate StandardOperations created for new org against
--                   those in model org.
-- PARAMETERS    :
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_StdOperations RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_StdOperations ';
  l_model_org_count    NUMBER;
  l_p_count_mdl        NUMBER;
  l_p_count_new        NUMBER;
  l_c1_count_mdl       NUMBER;
  l_c1_count_new       NUMBER;
  l_c2_count_mdl       NUMBER;
  l_c2_count_new       NUMBER;

  l_count_tmp          NUMBER:=0;
  l_entity_names       Char_Array := Char_Array();
  l_entity_names_fin   Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_std_op_code        BOM_STANDARD_OPERATIONS.OPERATION_CODE%TYPE;
-------------------------------------------------------------------
-------------------------------------------------------------------
  CURSOR l_parent ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  DISTINCT stdops.OPERATION_CODE
    FROM    BOM_STANDARD_OPERATIONS stdops
    WHERE   stdops.ORGANIZATION_ID = p_model_org_id
    AND     stdops.Line_Id is null and stdops.Operation_type = 1	--myerrams, testing
    AND     NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_STANDARD_OPERATIONS stdops1
        WHERE  stdops1.ORGANIZATION_ID = p_organization_id
        AND    stdops1.OPERATION_CODE = stdops.OPERATION_CODE
      );

  CURSOR l_parent_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(stdops.STANDARD_OPERATION_ID)
    FROM    BOM_STANDARD_OPERATIONS stdops
    WHERE   stdops.ORGANIZATION_ID = p_org_id
    AND     stdops.Line_Id is null and stdops.Operation_type = 1;	--myerrams, testing
-------------------------------------------------------------------
-------------------------------------------------------------------
  CURSOR l_child_1 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
    SELECT stdops.OPERATION_CODE
         , COUNT(stdopres.RESOURCE_ID)
    FROM   BOM_STD_OP_RESOURCES   stdopres
         , BOM_STANDARD_OPERATIONS   stdops
	 , BOM_RESOURCES res
    WHERE  stdopres.STANDARD_OPERATION_ID = stdops.STANDARD_OPERATION_ID
    AND	   stdops.ORGANIZATION_ID = p_model_org_id
    AND    stdops.Line_Id is null and stdops.Operation_type = 1		--myerrams, testing
    AND	   res.RESOURCE_ID = stdopres.RESOURCE_ID

    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_STD_OP_RESOURCES stdopres1
             , BOM_STANDARD_OPERATIONS  stdops1
	     , BOM_RESOURCES res1
        WHERE  stdops1.ORGANIZATION_ID = p_organization_id
        AND    stdopres1.STANDARD_OPERATION_ID = stdops1.STANDARD_OPERATION_ID
        AND    stdopres1.RESOURCE_SEQ_NUM = stdopres.RESOURCE_SEQ_NUM
	AND    res1.RESOURCE_ID = stdopres1.RESOURCE_ID
	AND    res1.RESOURCE_CODE = res.RESOURCE_CODE
	AND    stdops1.OPERATION_CODE = stdops.OPERATION_CODE		--myerrams, testing
      )
    GROUP BY stdops.OPERATION_CODE;

  CURSOR l_child_1_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(stdopres.RESOURCE_ID)
    FROM   BOM_STD_OP_RESOURCES   stdopres
         , BOM_STANDARD_OPERATIONS   stdops
    WHERE   stdopres.STANDARD_OPERATION_ID = stdops.STANDARD_OPERATION_ID
    AND     stdops.Line_Id is null and stdops.Operation_type = 1	--myerrams, testing
    AND     stdops.ORGANIZATION_ID = p_org_id;
-------------------------------------------------------------------
-------------------------------------------------------------------
CURSOR l_child_2 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
   SELECT stdops.OPERATION_CODE
         , COUNT(stdsubopres.SUBSTITUTE_GROUP_NUM)
    FROM   BOM_STD_SUB_OP_RESOURCES  stdsubopres
         , BOM_STD_OP_RESOURCES      stdopres
         , BOM_STANDARD_OPERATIONS   stdops
         , BOM_RESOURCES             res
    WHERE  stdops.ORGANIZATION_ID = p_model_org_id
    AND    stdops.Line_Id is null and stdops.Operation_type = 1		--myerrams, testing
    AND    stdopres.SUBSTITUTE_GROUP_NUM = stdsubopres.SUBSTITUTE_GROUP_NUM
    AND    stdops.STANDARD_OPERATION_ID = stdopres.STANDARD_OPERATION_ID
    AND	   stdops.STANDARD_OPERATION_ID = stdsubopres.STANDARD_OPERATION_ID
    AND    res.RESOURCE_ID = stdsubopres.RESOURCE_ID
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_STD_SUB_OP_RESOURCES  stdsubopres1
             , BOM_STD_OP_RESOURCES      stdopres1
             , BOM_STANDARD_OPERATIONS   stdops1
             , BOM_RESOURCES res1
        WHERE  stdops1.STANDARD_OPERATION_ID = stdsubopres1.STANDARD_OPERATION_ID
        AND    stdops1.STANDARD_OPERATION_ID = stdopres1.STANDARD_OPERATION_ID
        AND    stdops1.ORGANIZATION_ID = p_organization_id
        AND    res1.RESOURCE_ID = stdsubopres1.RESOURCE_ID
        AND    res1.RESOURCE_CODE = res.RESOURCE_CODE
        AND    stdopres1.SUBSTITUTE_GROUP_NUM = stdsubopres1.SUBSTITUTE_GROUP_NUM
        AND    stdsubopres.SUBSTITUTE_GROUP_NUM = stdsubopres1.SUBSTITUTE_GROUP_NUM
        AND    stdsubopres.REPLACEMENT_GROUP_NUM = stdsubopres1.REPLACEMENT_GROUP_NUM
      )
    GROUP BY stdops.OPERATION_CODE;

  CURSOR l_child_2_cnt ( p_org_id  NUMBER )
  IS
   SELECT COUNT(stdsubopres.SUBSTITUTE_GROUP_NUM)
    FROM   BOM_STD_SUB_OP_RESOURCES  stdsubopres
         , BOM_STD_OP_RESOURCES      stdopres
         , BOM_STANDARD_OPERATIONS   stdops
    WHERE  stdops.ORGANIZATION_ID = p_org_id
    AND    stdops.Line_Id is null and stdops.Operation_type = 1		--myerrams, testing
    AND    stdopres.SUBSTITUTE_GROUP_NUM = stdsubopres.SUBSTITUTE_GROUP_NUM
    AND    stdops.STANDARD_OPERATION_ID = stdopres.STANDARD_OPERATION_ID
    AND	   stdops.STANDARD_OPERATION_ID = stdsubopres.STANDARD_OPERATION_ID;
-------------------------------------------------------------------
-------------------------------------------------------------------
BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_parent_cnt ( g_model_org_id );
  FETCH l_parent_cnt INTO l_p_count_mdl;
  CLOSE l_parent_cnt;

  OPEN  l_parent_cnt ( g_organization_id );
  FETCH l_parent_cnt INTO l_p_count_new;
  CLOSE l_parent_cnt;

  IF l_p_count_new < l_p_count_mdl
  THEN
    OPEN l_parent ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_parent INTO l_std_op_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_std_op_code;

      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_parent INTO l_std_op_code;
      EXIT WHEN l_parent%NOTFOUND;
    END LOOP;
    CLOSE l_parent;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;
-------------------------------------------------------------------
-------------------------------------------------------------------
  IF l_p_count_new = 0
  THEN
    l_entity_names.EXTEND;
    l_entity_names(l_entity_arr_idx):=l_p_count_mdl;
    RETURN l_entity_names;
  END IF;
-------------------------------------------------------------------
-------------------------------------------------------------------
  OPEN  l_child_1_cnt ( g_model_org_id );
  FETCH l_child_1_cnt INTO l_c1_count_mdl;
  CLOSE l_child_1_cnt;

  OPEN  l_child_1_cnt ( g_organization_id );
  FETCH l_child_1_cnt INTO l_c1_count_new;
  CLOSE l_child_1_cnt;

  IF l_c1_count_new < l_c1_count_mdl
  THEN
    OPEN l_child_1 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_1 INTO l_std_op_code,  l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_std_op_code;

      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_1 INTO l_std_op_code,  l_count_tmp;
      EXIT WHEN l_child_1%NOTFOUND;
    END LOOP;
    CLOSE l_child_1;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;
-------------------------------------------------------------------
-------------------------------------------------------------------
  OPEN  l_child_2_cnt ( g_model_org_id );
  FETCH l_child_2_cnt INTO l_c2_count_mdl;
  CLOSE l_child_2_cnt;

  OPEN  l_child_2_cnt ( g_organization_id );
  FETCH l_child_2_cnt INTO l_c2_count_new;
  CLOSE l_child_2_cnt;

  IF l_c2_count_new < l_c2_count_mdl
  THEN
    OPEN l_child_2 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_2 INTO l_std_op_code, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_std_op_code;

      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_2 INTO l_std_op_code, l_count_tmp;
      EXIT WHEN l_child_2%NOTFOUND;
    END LOOP;
    CLOSE l_child_2;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_p_count_mdl;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_StdOperations;

--=============================================================================
-- FUNCTION NAME : Get_Err_Routings
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate routings created for new org against
--                   those in model org.
-- PARAMETERS    :
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Routings RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Routings ';
  --l_count              NUMBER:=0;
  l_model_org_count    NUMBER;
  l_p_count_mdl        NUMBER;
  l_p_count_new        NUMBER;
  l_c1_count_mdl       NUMBER;
  l_c1_count_new       NUMBER;
  l_c2_count_mdl       NUMBER;
  l_c2_count_new       NUMBER;
  l_c3_count_mdl       NUMBER;
  l_c3_count_new       NUMBER;
  l_c4_count_mdl       NUMBER;
  l_c4_count_new       NUMBER;
  l_ins_rec_cnt        NUMBER;
  l_count_tmp          NUMBER:=0;
  l_entity_names       Char_Array := Char_Array();
  l_entity_names_fin   Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER := 1;
  l_item_name          VARCHAR2(100);
  l_alternate          VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Routings ';

/* vmutyala modified the cursor to add condition
nvl(boru1.ALTERNATE_ROUTING_DESIGNATOR, 'NULL') = nvl(boru.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
to the inner query */
  CURSOR l_parent ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  DISTINCT msi.CONCATENATED_SEGMENTS, boru.ALTERNATE_ROUTING_DESIGNATOR
    FROM    BOM_OPERATIONAL_ROUTINGS boru
          , MTL_SYSTEM_ITEMS_KFV msi
    WHERE   msi.ORGANIZATION_ID = boru.ORGANIZATION_ID
    AND     msi.INVENTORY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
    AND     boru.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_OPERATIONAL_ROUTINGS boru1
        WHERE  boru1.ORGANIZATION_ID = p_organization_id
        AND    boru1.ASSEMBLY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
	AND    nvl(boru1.ALTERNATE_ROUTING_DESIGNATOR, 'NULL') = nvl(boru.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
      );

  CURSOR l_parent_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(boru.ASSEMBLY_ITEM_ID)
    FROM    BOM_OPERATIONAL_ROUTINGS boru
    WHERE   boru.ORGANIZATION_ID = p_org_id;

/* vmutyala modified the l_child_1 cursor because bos1.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
would never be true for two different organizations
  CURSOR l_child_1 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT MSI.CONCATENATED_SEGMENTS
         , BOR.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(OPERATION_SEQ_NUM)
    FROM   BOM_OPERATION_SEQUENCES   BOS
         , BOM_OPERATIONAL_ROUTINGS  BOR
         , MTL_SYSTEM_ITEMS_KFV MSI
    WHERE  MSI.INVENTORY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
    AND    MSI.ORGANIZATION_ID = BOR.ORGANIZATION_ID
    AND    BOS.ROUTING_SEQUENCE_ID = BOR.ROUTING_SEQUENCE_ID
    AND    BOR.ORGANIZATION_ID = p_model_org_id
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_OPERATION_SEQUENCES   bos1
             , BOM_OPERATIONAL_ROUTINGS  bor1
        WHERE  bos1.ROUTING_SEQUENCE_ID = bor1.ROUTING_SEQUENCE_ID
        AND    bor1.ORGANIZATION_ID = p_organization_id
        AND    bos1.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , BOR.ALTERNATE_ROUTING_DESIGNATOR;
*/

  CURSOR l_child_1 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT MSI.CONCATENATED_SEGMENTS
         , BOR.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(OPERATION_SEQ_NUM)
    FROM   BOM_OPERATION_SEQUENCES   BOS
         , BOM_OPERATIONAL_ROUTINGS  BOR
         , MTL_SYSTEM_ITEMS_KFV MSI
    WHERE  MSI.INVENTORY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
    AND    MSI.ORGANIZATION_ID = BOR.ORGANIZATION_ID
    AND    BOS.ROUTING_SEQUENCE_ID = BOR.ROUTING_SEQUENCE_ID
    AND    BOR.ORGANIZATION_ID = p_model_org_id
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_OPERATION_SEQUENCES   bos1
             , BOM_OPERATIONAL_ROUTINGS  bor1
        WHERE  bos1.ROUTING_SEQUENCE_ID = bor1.ROUTING_SEQUENCE_ID
        AND    bor1.ORGANIZATION_ID = p_organization_id
        AND    bos1.OPERATION_TYPE = bos.OPERATION_TYPE
	AND    bos1.OPERATION_SEQ_NUM = bos.OPERATION_SEQ_NUM
	AND    bos1.EFFECTIVITY_DATE = bos.EFFECTIVITY_DATE
        AND    bor1.ASSEMBLY_ITEM_ID = bor.ASSEMBLY_ITEM_ID
        AND    nvl(bor1.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
               = nvl(bor.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , BOR.ALTERNATE_ROUTING_DESIGNATOR;

  CURSOR l_child_1_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(bos.OPERATION_SEQUENCE_ID)
    FROM    BOM_OPERATIONAL_ROUTINGS boru
          , BOM_OPERATION_SEQUENCES  bos
    WHERE   bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND     boru.ORGANIZATION_ID = p_org_id;

/* vmutyala modified the l_child_2 cursor because bor1.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
would never be true for two different organizations and acd_type could be null
  CURSOR l_child_2 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS
         , boru.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(bor.RESOURCE_ID)
    FROM   BOM_OPERATION_RESOURCES   bor
         , BOM_OPERATION_SEQUENCES   bos
         , BOM_OPERATIONAL_ROUTINGS  boru
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  boru.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = boru.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
    AND    bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND    bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_OPERATIONAL_ROUTINGS boru1
             , BOM_OPERATION_SEQUENCES  bos1
             , BOM_OPERATION_RESOURCES  bor1
        WHERE  boru1.ORGANIZATION_ID = p_organization_id
        AND    bos1.ROUTING_SEQUENCE_ID = boru1.ROUTING_SEQUENCE_ID
        AND    bor1.OPERATION_SEQUENCE_ID = bos1.OPERATION_SEQUENCE_ID
        AND    bor1.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
        AND    bor1.RESOURCE_SEQ_NUM = bor.RESOURCE_SEQ_NUM
        AND    bor1.ACD_TYPE = bor.ACD_TYPE
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , boru.ALTERNATE_ROUTING_DESIGNATOR;
*/
  CURSOR l_child_2 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS
         , boru.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(bor.RESOURCE_ID)
    FROM   BOM_OPERATION_RESOURCES   bor
         , BOM_OPERATION_SEQUENCES   bos
         , BOM_OPERATIONAL_ROUTINGS  boru
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  boru.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = boru.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
    AND    bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND    bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_OPERATIONAL_ROUTINGS boru1
             , BOM_OPERATION_SEQUENCES  bos1
             , BOM_OPERATION_RESOURCES  bor1
        WHERE  boru1.ORGANIZATION_ID = p_organization_id
        AND    bos1.ROUTING_SEQUENCE_ID = boru1.ROUTING_SEQUENCE_ID
        AND    bor1.OPERATION_SEQUENCE_ID = bos1.OPERATION_SEQUENCE_ID
        AND    bor1.RESOURCE_SEQ_NUM = bor.RESOURCE_SEQ_NUM
        AND    nvl(bor1.ACD_TYPE, 1) = nvl(bor.ACD_TYPE, 1)
        AND    bos1.OPERATION_TYPE = bos.OPERATION_TYPE
	AND    bos1.OPERATION_SEQ_NUM = bos.OPERATION_SEQ_NUM
	AND    bos1.EFFECTIVITY_DATE = bos.EFFECTIVITY_DATE
        AND    boru1.ASSEMBLY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
        AND    nvl(boru1.ALTERNATE_ROUTING_DESIGNATOR, 'NULL') = nvl(boru.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , boru.ALTERNATE_ROUTING_DESIGNATOR;
  CURSOR l_child_2_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(bor.RESOURCE_SEQ_NUM)
    FROM    BOM_OPERATIONAL_ROUTINGS boru
          , BOM_OPERATION_SEQUENCES  bos
          , BOM_OPERATION_RESOURCES  bor
    WHERE   bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND     bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND     boru.ORGANIZATION_ID = p_org_id;

  /* vmutyala modified l_child_3 cursor because bsor1.OPERATION_SEQUENCE_ID = bsor.OPERATION_SEQUENCE_ID
  and  bsor1.RESOURCE_ID = bsor.RESOURCE_ID will never be true for two different organizations
  CURSOR l_child_3 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS
         , boru.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(bsor.SUBSTITUTE_GROUP_NUM)
    FROM   BOM_SUB_OPERATION_RESOURCES bsor
         , BOM_OPERATION_RESOURCES   bor
         , BOM_OPERATION_SEQUENCES   bos
         , BOM_OPERATIONAL_ROUTINGS  boru
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  boru.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = boru.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
    AND    bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND    bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND    bsor.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
    AND    bsor.RESOURCE_ID = bor.RESOURCE_ID
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_SUB_OPERATION_RESOURCES  bsor1
             , BOM_OPERATION_RESOURCES      bor1
             , BOM_OPERATION_SEQUENCES      bos1
             , BOM_OPERATIONAL_ROUTINGS     boru1
        WHERE  boru1.ORGANIZATION_ID = p_organization_id
        AND    bos1.ROUTING_SEQUENCE_ID = boru1.ROUTING_SEQUENCE_ID
        AND    bor1.OPERATION_SEQUENCE_ID = bos1.OPERATION_SEQUENCE_ID
        AND    bsor1.OPERATION_SEQUENCE_ID = bor1.OPERATION_SEQUENCE_ID
        AND    bsor1.RESOURCE_ID = bor1.RESOURCE_ID
        AND    bsor1.OPERATION_SEQUENCE_ID = bsor.OPERATION_SEQUENCE_ID
        AND    bsor1.RESOURCE_ID = bsor.RESOURCE_ID
        AND    bsor1.SUBSTITUTE_GROUP_NUM = bsor.SUBSTITUTE_GROUP_NUM
        AND    bsor1.REPLACEMENT_GROUP_NUM = bsor.REPLACEMENT_GROUP_NUM
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , boru.ALTERNATE_ROUTING_DESIGNATOR;
*/

  CURSOR l_child_3 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
 		   )
  IS
    SELECT msi.CONCATENATED_SEGMENTS
         , boru.ALTERNATE_ROUTING_DESIGNATOR
         , COUNT(bsor.SUBSTITUTE_GROUP_NUM)
    FROM   BOM_SUB_OPERATION_RESOURCES bsor
         , BOM_OPERATION_RESOURCES   bor
         , BOM_OPERATION_SEQUENCES   bos
         , BOM_OPERATIONAL_ROUTINGS  boru
         , MTL_SYSTEM_ITEMS_KFV      msi
    WHERE  boru.ORGANIZATION_ID = p_model_org_id
    AND    msi.ORGANIZATION_ID = boru.ORGANIZATION_ID
    AND    msi.INVENTORY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
    AND    bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND    bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND    bsor.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
    AND    bsor.RESOURCE_ID = bor.RESOURCE_ID
    AND    NOT EXISTS
      ( SELECT 'x'
        FROM   BOM_SUB_OPERATION_RESOURCES  bsor1
             , BOM_OPERATION_RESOURCES      bor1
             , BOM_OPERATION_SEQUENCES      bos1
             , BOM_OPERATIONAL_ROUTINGS     boru1
        WHERE  boru1.ORGANIZATION_ID = p_organization_id
        AND    bos1.ROUTING_SEQUENCE_ID = boru1.ROUTING_SEQUENCE_ID
        AND    bor1.OPERATION_SEQUENCE_ID = bos1.OPERATION_SEQUENCE_ID
        AND    bsor1.OPERATION_SEQUENCE_ID = bor1.OPERATION_SEQUENCE_ID
        AND    bsor1.RESOURCE_ID = bor1.RESOURCE_ID
       -- AND    bsor1.OPERATION_SEQUENCE_ID = bsor.OPERATION_SEQUENCE_ID
       -- AND    bsor1.RESOURCE_ID = bsor.RESOURCE_ID
        AND    bor1.RESOURCE_SEQ_NUM = bor.RESOURCE_SEQ_NUM
        AND    nvl(bor1.ACD_TYPE, 1) = nvl(bor.ACD_TYPE, 1)
        AND    bos1.OPERATION_TYPE = bos.OPERATION_TYPE
	AND    bos1.OPERATION_SEQ_NUM = bos.OPERATION_SEQ_NUM
	AND    bos1.EFFECTIVITY_DATE = bos.EFFECTIVITY_DATE
        AND    boru1.ASSEMBLY_ITEM_ID = boru.ASSEMBLY_ITEM_ID
        AND    nvl(boru1.ALTERNATE_ROUTING_DESIGNATOR, 'NULL') = nvl(boru.ALTERNATE_ROUTING_DESIGNATOR, 'NULL')
        AND    bsor1.SUBSTITUTE_GROUP_NUM = bsor.SUBSTITUTE_GROUP_NUM
        AND    bsor1.REPLACEMENT_GROUP_NUM = bsor.REPLACEMENT_GROUP_NUM
      )
    GROUP BY MSI.CONCATENATED_SEGMENTS
           , boru.ALTERNATE_ROUTING_DESIGNATOR;

  CURSOR l_child_3_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(bsor.SUBSTITUTE_GROUP_NUM)
    FROM    BOM_OPERATIONAL_ROUTINGS boru
          , BOM_OPERATION_SEQUENCES  bos
          , BOM_OPERATION_RESOURCES  bor
          , BOM_SUB_OPERATION_RESOURCES  bsor
    WHERE   bsor.RESOURCE_ID = bor.RESOURCE_ID
    AND     bsor.OPERATION_SEQUENCE_ID = bor.OPERATION_SEQUENCE_ID
    AND     bor.OPERATION_SEQUENCE_ID = bos.OPERATION_SEQUENCE_ID
    AND     bos.ROUTING_SEQUENCE_ID = boru.ROUTING_SEQUENCE_ID
    AND     boru.ORGANIZATION_ID = p_org_id;

  CURSOR l_child_4 ( p_model_org_id     NUMBER
		   , p_organization_id  NUMBER
		   )
  IS
    SELECT  kfv.CONCATENATED_SEGMENTS
    FROM    MTL_RTG_ITEM_REVISIONS rev
	  , MTL_SYSTEM_ITEMS_KFV   kfv
    WHERE   kfv.ORGANIZATION_ID = rev.ORGANIZATION_ID
    AND     kfv.INVENTORY_ITEM_ID = rev.INVENTORY_ITEM_ID
    AND     rev.ORGANIZATION_ID = p_model_org_id
    AND     NOT EXISTS
      ( SELECT 'x'
        FROM   MTL_RTG_ITEM_REVISIONS rev1
        WHERE  rev1.ORGANIZATION_ID = p_organization_id
        AND    rev1.INVENTORY_ITEM_ID = rev.INVENTORY_ITEM_ID
        AND    rev1.PROCESS_REVISION = rev.PROCESS_REVISION
      );

  CURSOR l_child_4_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(rev.PROCESS_REVISION)
    FROM    MTL_RTG_ITEM_REVISIONS rev
    WHERE   rev.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_parent_cnt ( g_model_org_id );
  FETCH l_parent_cnt INTO l_p_count_mdl;
  CLOSE l_parent_cnt;

  OPEN  l_parent_cnt ( g_organization_id );
  FETCH l_parent_cnt INTO l_p_count_new;
  CLOSE l_parent_cnt;

  IF l_p_count_new < l_p_count_mdl
  THEN
    OPEN l_parent ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_parent INTO l_item_name, l_alternate;
    LOOP
      l_entity_names.EXTEND;
      IF  l_alternate IS NOT NULL
      AND l_alternate <> ''
      THEN
        l_entity_names(l_entity_arr_idx) := l_item_name||', '||l_alternate;
      ELSE
        l_entity_names(l_entity_arr_idx) := l_item_name;
      END IF;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_parent INTO l_item_name, l_alternate;
      EXIT WHEN l_parent%NOTFOUND;
    END LOOP;
    CLOSE l_parent;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  IF l_p_count_new = 0
  THEN
    l_entity_names.EXTEND;
    l_entity_names(l_entity_arr_idx):=l_p_count_mdl;
    RETURN l_entity_names;
  END IF;

  OPEN  l_child_1_cnt ( g_model_org_id );
  FETCH l_child_1_cnt INTO l_c1_count_mdl;
  CLOSE l_child_1_cnt;

  OPEN  l_child_1_cnt ( g_organization_id );
  FETCH l_child_1_cnt INTO l_c1_count_new;
  CLOSE l_child_1_cnt;

  IF l_c1_count_new < l_c1_count_mdl
  THEN
    OPEN l_child_1 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_1 INTO l_item_name, l_alternate, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      IF  l_alternate IS NOT NULL
      AND l_alternate <> ''
      THEN
        l_entity_names(l_entity_arr_idx) := l_item_name||', '||l_alternate;
      ELSE
        l_entity_names(l_entity_arr_idx) := l_item_name;
      END IF;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_1 INTO l_item_name, l_alternate, l_count_tmp;
      EXIT WHEN l_child_1%NOTFOUND;
    END LOOP;
    CLOSE l_child_1;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  OPEN  l_child_2_cnt ( g_model_org_id );
  FETCH l_child_2_cnt INTO l_c2_count_mdl;
  CLOSE l_child_2_cnt;

  OPEN  l_child_2_cnt ( g_organization_id );
  FETCH l_child_2_cnt INTO l_c2_count_new;
  CLOSE l_child_2_cnt;

  IF l_c2_count_new < l_c2_count_mdl
  THEN
    OPEN l_child_2 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_2 INTO l_item_name, l_alternate, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      IF  l_alternate IS NOT NULL
      AND l_alternate <> ''
      THEN
        l_entity_names(l_entity_arr_idx) := l_item_name||', '||l_alternate;
      ELSE
        l_entity_names(l_entity_arr_idx) := l_item_name;
      END IF;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_2 INTO l_item_name, l_alternate, l_count_tmp;
      EXIT WHEN l_child_2%NOTFOUND;
    END LOOP;
    CLOSE l_child_2;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  OPEN  l_child_3_cnt ( g_model_org_id );
  FETCH l_child_3_cnt INTO l_c3_count_mdl;
  CLOSE l_child_3_cnt;

  OPEN  l_child_3_cnt ( g_organization_id );
  FETCH l_child_3_cnt INTO l_c3_count_new;
  CLOSE l_child_3_cnt;

  IF l_c3_count_new < l_c3_count_mdl
  THEN
    OPEN l_child_3 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_3 INTO l_item_name, l_alternate, l_count_tmp;
    LOOP
      l_entity_names.EXTEND;
      IF  l_alternate IS NOT NULL
      AND l_alternate <> ''
      THEN
        l_entity_names(l_entity_arr_idx) := l_item_name||', '||l_alternate;
      ELSE
        l_entity_names(l_entity_arr_idx) := l_item_name;
      END IF;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_3 INTO l_item_name, l_alternate, l_count_tmp;
      EXIT WHEN l_child_3%NOTFOUND;
    END LOOP;
    CLOSE l_child_3;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  OPEN  l_child_4_cnt ( g_model_org_id );
  FETCH l_child_4_cnt INTO l_c4_count_mdl;
  CLOSE l_child_4_cnt;

  OPEN  l_child_4_cnt ( g_organization_id );
  FETCH l_child_4_cnt INTO l_c4_count_new;
  CLOSE l_child_4_cnt;

  IF l_c4_count_new < l_c4_count_mdl
  THEN
    OPEN l_child_4 ( g_model_org_id
                   , g_organization_id
                   );
    FETCH l_child_4 INTO l_item_name;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_item_name;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_child_4 INTO l_item_name;
      EXIT WHEN l_child_4%NOTFOUND;
    END LOOP;
    CLOSE l_child_4;

    l_entity_names_fin := Trim_Array(Get_Unique_List(l_entity_names));
    l_entity_names     := l_entity_names_fin;
    l_entity_arr_idx   := l_entity_names.COUNT + 1;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_p_count_mdl;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Routings;

--=============================================================================
-- FUNCTION NAME : Get_Err_Bom_Dept_Res
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate department resources created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Bom_Dept_Res RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Bom_Dept_Res ';
  --l_count              NUMBER:=0;
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;
  l_entity_names       Char_Array := Char_Array();
  l_entity_arr_idx     NUMBER:=1;
  l_res_code           VARCHAR2(100);
  l_dept_code          VARCHAR2(100);
  --l_entity_type        VARCHAR2(100):= ' Department-Resources ';

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  bd.DEPARTMENT_CODE, br.RESOURCE_CODE
    FROM    BOM_DEPARTMENT_RESOURCES ent
          , BOM_DEPARTMENTS bd
	  , BOM_RESOURCES br
    WHERE   br.RESOURCE_ID = ent.RESOURCE_ID
    AND     ent.RESOURCE_ID IN ( SELECT  br.RESOURCE_ID
                                 FROM    BOM_RESOURCES br
				 WHERE   br.ORGANIZATION_ID=p_model_org_id
			       )
    AND     bd.DEPARTMENT_ID = ent.DEPARTMENT_ID
    AND     ent.DEPARTMENT_ID IN ( SELECT  bd.DEPARTMENT_ID
                                   FROM    BOM_DEPARTMENTS bd
				   WHERE   bd.ORGANIZATION_ID=p_model_org_id
				 )
    MINUS
    SELECT  bd.DEPARTMENT_CODE, br.RESOURCE_CODE
    FROM    BOM_DEPARTMENT_RESOURCES ent
          , BOM_DEPARTMENTS bd
	  , BOM_RESOURCES br
    WHERE   br.RESOURCE_ID = ent.RESOURCE_ID
    AND     ent.RESOURCE_ID IN ( SELECT  br.RESOURCE_ID
                                 FROM    BOM_RESOURCES br
				 WHERE   br.ORGANIZATION_ID=p_organization_id
			       )
    AND     bd.DEPARTMENT_ID = ent.DEPARTMENT_ID
    AND     ent.DEPARTMENT_ID IN ( SELECT  bd.DEPARTMENT_ID
                                   FROM    BOM_DEPARTMENTS bd
				   WHERE   bd.ORGANIZATION_ID=p_organization_id
				 );

  CURSOR l_cursor_cnt ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(ent.RESOURCE_ID)
    FROM    BOM_DEPARTMENT_RESOURCES ent
    WHERE   ent.RESOURCE_ID IN
      (
        SELECT  br.RESOURCE_ID
        FROM    BOM_RESOURCES br
  	WHERE   br.ORGANIZATION_ID=p_org_id
      )
    AND     ent.DEPARTMENT_ID IN
      (
        SELECT  bd.DEPARTMENT_ID
        FROM    BOM_DEPARTMENTS bd
	WHERE   bd.ORGANIZATION_ID=p_org_id
      );

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cursor_cnt ( g_model_org_id );
  FETCH l_cursor_cnt INTO l_model_org_count;
  CLOSE l_cursor_cnt;

  OPEN  l_cursor_cnt ( g_organization_id );
  FETCH l_cursor_cnt INTO l_new_org_count;
  CLOSE l_cursor_cnt;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_dept_code, l_res_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_dept_code ||' : '||l_res_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_dept_code, l_res_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Bom_Dept_Res;

--=============================================================================
-- FUNCTION NAME : Get_Err_Cst_Res_Costs
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate resource costs created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Cst_Res_Costs RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):=' Get_Err_Cst_Res_Costs ';
  l_cost_type          VARCHAR2(100);
  l_entity_arr_idx     NUMBER:=1;
  l_entity_names       Char_Array:= Char_Array();
  --l_entity_type        VARCHAR2(100):=' Resource Costs ';
  l_model_org_count    NUMBER:=0;
  l_new_org_count      NUMBER:=0;
  l_res_code           VARCHAR2(100);

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  br1.RESOURCE_CODE, cct1.COST_TYPE
    FROM    CST_RESOURCE_COSTS crc1
          , CST_COST_TYPES cct1
	  , BOM_RESOURCES br1
    WHERE   crc1.ORGANIZATION_ID = p_model_org_id
    AND     br1.RESOURCE_ID = crc1.RESOURCE_ID
    AND     cct1.COST_TYPE_ID = crc1.COST_TYPE_ID
    AND     NOT EXISTS ( SELECT  'x'
                         FROM    CST_RESOURCE_COSTS crc2
                               , CST_COST_TYPES cct2
                               , BOM_RESOURCES br2
                         WHERE   crc2.ORGANIZATION_ID = p_organization_id
                         AND     br2.RESOURCE_ID = crc2.RESOURCE_ID
                         AND     br2.RESOURCE_CODE = br1.RESOURCE_CODE
                         AND     cct2.COST_TYPE_ID = crc2.COST_TYPE_ID
                         AND     cct2.COST_TYPE = cct1.COST_TYPE
                       );
  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(crc.RESOURCE_ID)
    FROM    CST_RESOURCE_COSTS crc
    WHERE   crc.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_res_code, l_cost_type;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_res_code ||' : '||l_cost_type;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_res_code, l_cost_type;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Cst_Res_Costs;
--=============================================================================
-- FUNCTION NAME : Get_Err_Cst_Res_Ovhds
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate resource overheads created for new org against
--                   those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Get_Err_Cst_Res_Ovhds RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Cst_Res_Ovhds ';
  l_cost_type          VARCHAR2(100);
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' Resource Overheads ';
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER;
  l_res_code           VARCHAR2(100);
  l_res_ovhd           VARCHAR2(100);

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  br1.RESOURCE_CODE
          , cct1.COST_TYPE
          , br2.RESOURCE_CODE
    FROM    CST_RESOURCE_OVERHEADS crh1
          , CST_COST_TYPES cct1
	  , BOM_RESOURCES br1
	  , BOM_RESOURCES br2
    WHERE   crh1.ORGANIZATION_ID = p_model_org_id
    AND     br1.RESOURCE_ID = crh1.RESOURCE_ID
    AND     br2.RESOURCE_ID = crh1.OVERHEAD_ID
    AND     cct1.COST_TYPE_ID = crh1.COST_TYPE_ID
    AND     NOT EXISTS ( SELECT  'x'
                         FROM    CST_RESOURCE_OVERHEADS crh2
                               , CST_COST_TYPES cct2
                               , BOM_RESOURCES br3
                         WHERE   crh2.ORGANIZATION_ID = p_organization_id
                         AND     br3.RESOURCE_ID = crh2.RESOURCE_ID
                         AND     br3.RESOURCE_CODE = br1.RESOURCE_CODE
                         AND     cct2.COST_TYPE_ID = crh2.COST_TYPE_ID
                         AND     cct2.COST_TYPE = cct1.COST_TYPE
                       );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(crh.RESOURCE_ID)
    FROM    CST_RESOURCE_OVERHEADS crh
    WHERE   crh.ORGANIZATION_ID = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Err_Cst_Res_Ovhds'
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_res_code, l_cost_type, l_res_ovhd;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_res_code ||' : '||
                                          l_cost_type||' , '||l_res_ovhd;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_res_code, l_cost_type, l_res_ovhd;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Get_Err_Cst_Res_Ovhds'
    );
  END IF;

  RETURN l_entity_names;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Err_Cst_Res_Ovhds;

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
PROCEDURE Put_Report_Data
IS
  l_model_rec_cnt     NUMBER:=0;
  l_new_rec_cnt       NUMBER:=0;
  l_not_to_copy       BOOLEAN:=false;
  l_mesg_name         VARCHAR2(100);
  l_entity_err        VARCHAR2(100);
-- Modified for Bug 3838706
--  l_message           VARCHAR2(240):='';
  l_message           VARCHAR2(2000):='';
  l_entity_count      NUMBER:=0;
  l_api_name          VARCHAR2(100):=' Put_Report_Data ';

BEGIN

  BEGIN
    l_model_rec_cnt := g_entity_names(g_entity_names.COUNT);
    l_new_rec_cnt   := l_model_rec_cnt - (g_entity_names.COUNT - 1);
  EXCEPTION
    WHEN OTHERS THEN
      l_model_rec_cnt := 0;
      l_new_rec_cnt   := 0;
      l_not_to_copy   := true;
  END;

  IF NOT l_not_to_copy
  THEN

    IF l_new_rec_cnt > l_model_rec_cnt
    THEN
      l_new_rec_cnt := l_model_rec_cnt;
    END IF;

    --------------------------------------------------------------------
    -- Get copied / modified counts for entity .
    -- Modified records column has been removed from the report
    --   as decided in the telecon on 30/10/2003
    -- No check for modified flag is required anymor.
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    --IF  g_modified
    --THEN
    --  g_exp_modify_cnt := g_exp_modify_cnt + l_model_rec_cnt;
    --  g_modify_cnt     := g_modify_cnt     + l_new_rec_cnt;
    --  l_mesg_name      := 'NOT_MODIFIED_ERROR';
    --  l_entity_err     := 'NOT COPIED AND NOT MODIFIED';
    --ELSE
    --------------------------------------------------------------------
    g_exp_copy_cnt := g_exp_copy_cnt   + l_model_rec_cnt;
    g_copy_cnt     := g_copy_cnt       + l_new_rec_cnt;
    l_mesg_name    := 'NOT_COPIED_ERROR';
    l_entity_err   := 'NOT COPIED';
    --------------------------------------------------------------------
    --END IF;
    --------------------------------------------------------------------
    IF G_DEBUG = 'Y' THEN
    --------------------------------------------------------------------
    -- Commenting dbms_output statements.
    --------------------------------------------------------------------
    --  dbms_output.put_line
    --  (                  g_entity_type ||
    --  '- Copied Records(Exp/Actual)  :'||g_exp_copy_cnt
    --					 ||'/'
    --					 ||g_copy_cnt
    --------------------------------------------------------------------
    -- Removed support for Modified records.
    --------------------------------------------------------------------
    --					 ||
    --	'- Modified Records(Exp/Actual):'||g_exp_modify_cnt
    --					 ||'/'
    --					 ||g_modify_cnt
    --------------------------------------------------------------------
    --  );
      FND_MSG_PUB.ADD_EXC_MSG
      ( G_PKG_NAME
      , l_api_name
      , '- Copied Records(Exp/Actual)  :'||g_exp_copy_cnt
					 ||'/'
					 ||g_copy_cnt
    --------------------------------------------------------------------
    -- Removed support for Modified records.
    --------------------------------------------------------------------
    -- 					 ||
    --	'- Modified Records(Exp/Actual):'||g_exp_modify_cnt
    --					 ||'/'
    --					 ||g_modify_cnt
    --------------------------------------------------------------------
      );
    END IF;
--Bug: 3550415.
--If Location already exists then Receiving Subinventories are not migrated, in such scenario
--add proper message to Report.
IF (g_location_status = 'PRE_EXIST') AND  (g_entity_type = 'SUBINVENTORIES') THEN
 IF (Receiving_Subinv_Exist(g_model_org_id) = 'TRUE') THEN
  FND_MESSAGE.SET_NAME (application=>'INV', name=>'INV_REC_SUB_INV_NOT_MIGRATED');
  l_message := FND_MESSAGE.GET();
 END IF;
END IF;
    -------------------------------------------------------------------------
    -- Insert record counts for new / model org into report table.
    -------------------------------------------------------------------------
    IF  l_model_rec_cnt > 0
    THEN
      Insert_Row ( p_location_code        => ''
                 , p_business_group_name  => ''
                 , p_status               => ''
                 , p_error_msg            => l_message
                 , p_rec_type             => 'ENTITY_TYPE_SUMMARY'
                 , p_entity_type          => g_entity_type
                 , p_copy_cnt             => g_copy_cnt
                 , p_exp_copy_cnt         => g_exp_copy_cnt
                 , p_modify_cnt           => g_modify_cnt
                 , p_exp_modify_cnt       => g_exp_modify_cnt
                 , p_entity_name          => ''
                 , p_entity_inconsistency => ''
                 , p_put_orgs             => true
                 );
    END IF;
    --dbms_output.put_line('Quant');
    -------------------------------------------------------------------------
    -- Get Threshold message if error records > G_THRESHOLD
    -------------------------------------------------------------------------
    IF g_entity_names.COUNT >= G_THRESHOLD
    THEN
      FND_MESSAGE.SET_NAME (application=>'INV', name=>'INV_CO_THRESHOLD_MSG');
      FND_MESSAGE.SET_TOKEN('entity_type', g_entity_type);
      FND_MESSAGE.SET_TOKEN('threshold'  , G_THRESHOLD);
      g_entity_names.EXTEND;
      g_entity_names(G_THRESHOLD) := '> '||FND_MESSAGE.GET();
      l_entity_count := G_THRESHOLD - 1;
      l_message := g_entity_names(G_THRESHOLD);
      Insert_Row ( p_location_code        => ''
                 , p_business_group_name  => ''
                 , p_status               => ''
                 , p_error_msg            => l_message
                 , p_rec_type             => 'INCONSISTENT_ENTITY_SUMMARY'
                 , p_entity_type          => g_entity_type
                 , p_copy_cnt             => null
                 , p_exp_copy_cnt         => null
                 , p_modify_cnt           => null
                 , p_exp_modify_cnt       => null
                 , p_entity_name          => g_entity_names(G_THRESHOLD)
                 , p_entity_inconsistency => l_entity_err
                 , p_put_orgs             => true
                 );
    ELSE
      l_entity_count := g_entity_names.COUNT - 1;
    END IF;
    -------------------------------------------------------------------------
    -- Insert qualitative data if error records cnt > 1 into report table.
    -------------------------------------------------------------------------
    --dbms_output.put_line(g_entity_type||': '||l_entity_count);
--shpandey, modified the condition below from "=" to ">=" to handle single failed entity
--for bug# 3678706
    IF l_entity_count >= 1
-- end of fix for bug# 3678706
    THEN
      FND_MESSAGE.SET_NAME  ( application=>'INV', name=>l_mesg_name );
      FND_MESSAGE.SET_TOKEN ( 'entity_type', g_entity_type );
      l_message := FND_MESSAGE.GET();
      --dbms_output.put_line(l_message);
      FORALL i IN 1..l_entity_count
        INSERT INTO mtl_copy_org_report
        ( GROUP_CODE
        , MODEL_ORGANIZATION_CODE
        , ORGANIZATION_CODE
        , ERROR_MSG
        , REC_TYPE
        , ENTITY_TYPE
        , ENTITY_NAME
        , ENTITY_INCONSISTENCY
        )
        VALUES
        ( g_group_code
        , g_model_org_code
        , g_organization_code
        , l_message
        , 'INCONSISTENT_ENTITY_SUMMARY'
        , g_entity_type
        , ' - '||g_entity_names(i)
        , l_entity_err
        );
        g_error_status_flag := true;
    END IF;
  END IF;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Put_Report_Data'
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Put_Report_Data;

--=============================================================================
-- PROC NAME     : Insert_Row
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Get the translated message from FND MESSAGES table.
-- PARAMETERS    :
--   p_msg_name           REQUIRED. Name of the error message.
--   p_token_array        REQUIRED. List of token name/values in error message.
--
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
)
IS
  --l_message        VARCHAR2(1000);
  l_new_org        VARCHAR2(10):='';
  l_model_org      VARCHAR2(10):='';
  l_api_name       VARCHAR2(100):=' Insert_Row ';
BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Insert_Row '
    );
  END IF;

  IF p_put_orgs THEN
    l_new_org   := g_organization_code;
    l_model_org := g_model_org_code;
  END IF;

  INSERT INTO MTL_COPY_ORG_REPORT
  ( group_code
  , model_organization_code
  , organization_code
  , location_code
  , business_group_name
  , status
  , error_msg
  , rec_type
  , entity_type
  , copied_count
  , modified_count
  , expected_copied_count
  , expected_modified_count
  , entity_name
  , entity_inconsistency
  )
  VALUES
  ( g_group_code
  , l_model_org
  , l_new_org
  , p_location_code
  , p_business_group_name
  , p_status
  , p_error_msg
  , p_rec_type
  , p_entity_type
  , p_copy_cnt
  , p_modify_cnt
  , p_exp_copy_cnt
  , p_exp_modify_cnt
  , p_entity_name
  , p_entity_inconsistency
  );

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Insert_Row '
    );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Insert_Row;
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
-- This FUNCTION is OBSOLETED as support for Modified entities has
--   been removed from FPJ.  (as decided on 10/30/2003)
--=============================================================================
--FUNCTION Is_Entity_Modified ( p_entity_type  IN  VARCHAR2 ) RETURN BOOLEAN
--IS
--  l_api_name   VARCHAR2(100):=' Is_Entity_Modified ';
--BEGIN
--  FOR j IN 1..m_user_values.COUNT
--  LOOP
--    IF m_user_values(j).entity_type = p_entity_type
--    THEN
--      RETURN true;
--    END IF;
--  END LOOP;
--
--  IF G_DEBUG = 'Y' THEN
--    FND_MSG_PUB.ADD_EXC_MSG
--    ( G_PKG_NAME
--    , l_api_name
--    , '< Is_Entity_Modified '
--    );
--  END IF;
--  RETURN false;
--END Is_Entity_Modified;
--=============================================================================
-- FUNCTION NAME : Get_Organization_Id
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Get the organization Id for this org code.
-- PARAMETERS    :
--   p_org_code    REQUIRED. Org Code to be converted to Id.
--
-- EXCEPTIONS    : None.
--=============================================================================
FUNCTION Get_Organization_Id ( p_org_code  IN  VARCHAR2 ) RETURN NUMBER
IS
  l_org_id    NUMBER;
  l_api_name  VARCHAR2(100):=' Get_Organization_Id ';
BEGIN
  SELECT  organization_id
  INTO    l_org_id
  FROM    mtl_parameters
  WHERE   organization_code = p_org_code;

  RETURN l_org_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Get_Organization_Id;
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
( p_msg_name       IN  VARCHAR2
, p_token_array    IN  Token_Hash
) RETURN VARCHAR2
IS
-- Modified for bug 3838706
--  l_message    VARCHAR2(1000);
  l_message    VARCHAR2(2000);
  l_app        VARCHAR2(10):='INV';
  l_api_name   VARCHAR2(100):=' Get_Fnd_Message ';
BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Get_Fnd_Message '
    );
  END IF;

  FND_MESSAGE.SET_NAME( application => l_app, name => p_msg_name );
  FOR i IN 1..p_token_array.COUNT
  LOOP
    FND_MESSAGE.SET_TOKEN
     ( p_token_array(i).token_name
     , p_token_array(i).token_value
     );
  END LOOP;

  SELECT FND_MESSAGE.GET()
  INTO   l_message
  FROM   dual;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Get_Fnd_Message '
    );
  END IF;

  RETURN l_message;

END Get_Fnd_Message;
--=============================================================================
-- FUNCTION NAME : Purge_Copy_Org_Report
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Purge records from the Copy Org Report table for the
--                  group code.
-- PARAMETERS    :
--   p_group_code  REQUIRED. Group code created for Copy Org request.
--
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Purge_Copy_Org_Report RETURN BOOLEAN
IS
  l_group_code  VARCHAR2(30);
  l_api_name    VARCHAR2(100):=' Purge_Copy_Org_Report ';

BEGIN
  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Purge Report Data'
    );
  END IF;

  IF (g_group_code = 'SEED') THEN
    RETURN false;
  END IF;

  DELETE  mtl_copy_org_report
  WHERE  group_code = g_group_code;

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '< Purge Report Data'
    );
  END IF;

  RETURN true;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Purge_Copy_Org_Report;

--Bug: 3550415. New function added to verify if Receiving Subinventories exist
-- corresponding to Model Org
--=============================================================================
-- FUNCTION NAME : Receiving_Subinv_Exist
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Returns TRUE if Receiving Subinventories exist for the
--                 model org else returns FALSE.
-- PARAMETERS    :
-- p_organization_id           REQUIRED. Organization Id.
-- EXCEPTIONS    : None.
--
--=============================================================================
FUNCTION Receiving_Subinv_Exist (p_organization_id IN  NUMBER ) RETURN VARCHAR2
IS
  l_api_name    VARCHAR2(100):='Receiving_Subinv_Exist';
  l_receiving_subinv_count   NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , '> Receiving_Subinv_Exist '
    );
  END IF;

  SELECT  1
      INTO    l_receiving_subinv_count
      FROM    MTL_SECONDARY_INVENTORIES
      WHERE   ORGANIZATION_ID = p_organization_id
      AND SUBINVENTORY_TYPE = 2
      AND ROWNUM = 1;

  IF G_DEBUG = 'Y' THEN
      FND_MSG_PUB.ADD_EXC_MSG
      ( G_PKG_NAME
      , l_api_name
      , '< Receiving_Subinv_Exist '
      );
  END IF;

  IF l_receiving_subinv_count > 0 THEN
   RETURN 'TRUE';
  ELSE
   RETURN 'FALSE';
  END IF;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN 'FALSE';
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
    FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
    FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
    FND_MSG_PUB.Add;
    RAISE;

END Receiving_Subinv_Exist;
--=============================================================================
--Bug: 3683490. New function added to convert clob field to varchar2
--              as to_char function() is not supported for version 8i.
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

FUNCTION clob_to_varchar( lobsrc IN CLOB ) RETURN VARCHAR2
IS
-- Modified for bug 3838706
  buffer VARCHAR2( 2000 );
--  buffer VARCHAR2( 1800 );

  amount NUMBER;
BEGIN
-- Modified for bug 3838706
  amount := 2000;
--  amount := 1800;

  IF lobsrc IS NOT NULL THEN
    DBMS_LOB.READ( lobsrc, amount, 1, buffer );
  END IF;

  RETURN buffer;
END clob_to_varchar;

--=============================================================================
-- FUNCTION NAME : Get_Err_Wip_Acc_Classes
-- PRE-CONDITIONS: None.
-- DESCRIPTION   : Validate Wip Accounting classes created for new org against
--                 those in model org.
-- PARAMETERS    : None.
-- EXCEPTIONS    : None.
-- shpandey, added the function below for R12 development.
--=============================================================================
FUNCTION Get_Err_Wip_Acc_Classes RETURN Char_Array
IS
  l_api_name           VARCHAR2(100):= ' Get_Err_Wip_Acc_Classes ';
  l_entity_arr_idx     NUMBER := 1;
  l_entity_names       Char_Array := Char_Array();
  --l_entity_type        VARCHAR2(100):= ' WIP Accounting Classes ';
  l_class_code         VARCHAR2(10);
  l_model_org_count    NUMBER;
  l_new_org_count      NUMBER:=0;

  CURSOR l_cursor ( p_model_org_id     NUMBER
		  , p_organization_id  NUMBER
		  )
  IS
    SELECT  wac1.class_code
    FROM    wip_accounting_classes wac1
    WHERE   wac1.organization_id = p_model_org_id
    AND     NOT EXISTS
      ( SELECT  'x'
        FROM    wip_accounting_classes wac2
        WHERE   wac2.organization_id = p_organization_id
	AND     wac1.class_code = wac2.class_code
      );

  CURSOR l_cnt_csr ( p_org_id  NUMBER )
  IS
    SELECT  COUNT(wac.class_code)
    FROM    wip_accounting_classes wac
    WHERE   wac.organization_id = p_org_id;

BEGIN

  IF G_DEBUG = 'Y' THEN
    FND_MSG_PUB.ADD_EXC_MSG
    ( G_PKG_NAME
    , l_api_name
    , 'IN  INVCORPB: '||l_api_name
    );
  END IF;

  OPEN  l_cnt_csr ( g_model_org_id );
  FETCH l_cnt_csr INTO l_model_org_count;
  CLOSE l_cnt_csr;

  OPEN  l_cnt_csr ( g_organization_id );
  FETCH l_cnt_csr INTO l_new_org_count;
  CLOSE l_cnt_csr;

  IF l_new_org_count < l_model_org_count
  THEN
    OPEN l_cursor ( g_model_org_id
                  , g_organization_id
                  );
    FETCH l_cursor INTO l_class_code;
    LOOP
      l_entity_names.EXTEND;
      l_entity_names(l_entity_arr_idx) := l_class_code;
      l_entity_arr_idx := l_entity_arr_idx + 1;

      FETCH l_cursor INTO l_class_code;
      EXIT WHEN l_cursor%NOTFOUND;
    END LOOP;
    CLOSE l_cursor;
  END IF;

  l_entity_names.EXTEND;
  l_entity_names(l_entity_arr_idx):=l_model_org_count;

  RETURN l_entity_names;
EXCEPTION
WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME(application=>'FND',name=>'FND_AS_UNEXPECTED_ERROR');
   FND_MESSAGE.SET_TOKEN('error_text', SQLERRM(sqlcode));
   FND_MESSAGE.SET_TOKEN('pkg_name' , G_PKG_NAME);
   FND_MESSAGE.SET_TOKEN('procedure_name' , l_api_name );
   FND_MSG_PUB.Add;
   RAISE;

END Get_Err_Wip_Acc_Classes;


END INV_COPY_ORGANIZATION_REPORT;

/
