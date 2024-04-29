--------------------------------------------------------
--  DDL for Package EGO_METADATA_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_METADATA_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVMDBS.pls 120.1.12010000.4 2010/06/11 13:51:40 kjonnala noship $ */

------------------------------------------------------------------------------
-- Global variables and constants declarations
------------------------------------------------------------------------------

  -------------------------------------------------------------------------
  --  Debug Profile option used to write Error_Handler.Write_Debug       --
  --  Profile option name = INV_DEBUG_TRACE ;                            --
  --  User Profile Option Name = INV: Debug Trace                        --
  --  Values: 1 (True) ; 0 (False)                                       --
  --  NOTE: This better than MRP_DEBUG which is used at many places.     --
  -------------------------------------------------------------------------
   G_DEBUG                      VARCHAR2(10);



------------------------------------------------------------------------------
-- WHO columns
------------------------------------------------------------------------------

    G_REQUEST_ID                  NUMBER;
    G_PROGRAM_APPLICATION_ID      NUMBER;
    G_PROGRAM_ID                  NUMBER;
    G_USER_NAME                   FND_USER.USER_NAME%TYPE;
    G_USER_ID                     NUMBER;
    G_LOGIN_ID                    NUMBER;

------------------------------------------------------------------------------
-- CONSTANTS required by the Lock related procedures
------------------------------------------------------------------------------

 G_VALUE_SET                      CONSTANT  VARCHAR2(30)  := 'EGO_VALUE_SET';
 G_ITEM_CATALOG_CATEGORY          CONSTANT  VARCHAR2(30)  := 'EGO_ITEM_CATALOG_CATEGORY';


 G_ENTITY_VS_VER                  CONSTANT  VARCHAR2(30)  := 'VS_VERSION';
 G_ENTITY_VS_HEADER_TAB           CONSTANT  VARCHAR2(240) := 'EGO_FLEX_VALUE_SET_INTF';
 G_ENTITY_ICC_VER                 CONSTANT  VARCHAR2(30)  := 'ICC_VERSIONS';
 G_ENTITY_ICC_HEADER_TAB          CONSTANT  VARCHAR2(240) := 'EGO_ICC_VERS_INTERFACE';


---------------------------------------------------------------------------
--   API return status
--
--      G_RET_STS_SUCCESS means that the API was successful in performing
--      all the operation requested by its caller.
--
--      G_RET_STS_ERROR means that the API failed to perform one or more
--      of the operations requested by its caller.
--
--      G_RET_STS_UNEXP_ERROR means that the API was not able to perform
--      any of the operations requested by its callers because of an
--      unexpected error.
-----------------------------------------------------------------------------

    G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

-------------------------------------------------------------------------------
--   Concurrent Program Return Codes
-------------------------------------------------------------------------------
    G_CONC_RETCODE_SUCCESS       CONSTANT    NUMBER :=  0;
    G_CONC_RETCODE_WARNING       CONSTANT    NUMBER :=  1;
    G_CONC_RETCODE_ERROR         CONSTANT    NUMBER :=  2;


-------------------------------------------------------------------------------
--   Package Name, used while logging debug messages
-------------------------------------------------------------------------------
   G_PKG_NAME    CONSTANT VARCHAR2(30) := 'EGO_METADATA_BULKLOAD_PVT';


------------------------------------------------------------------------------
-- Procedure Declarations
------------------------------------------------------------------------------

/********************************************************************************
 --   Procedure     : write_debug
 --   Purpose       : Writes the debug messages into concurrent program log
 --   IN Parameters :
 --                   p_msg - string to be written onto concurrent program log
 --   OUT Parameters:
 --                   None
********************************************************************************/

PROCEDURE Write_Debug (p_msg  IN  VARCHAR2);


/*************************************************************************************************
 --   Procedure     :  import_metadata
 --   Purpose       :  Main method called by the concurrent program EGOIMDCP executable
 --                    Co-ordinates the import of all metadata entities.
 --   IN Parameters :
 --                    p_import_vs  - indicates whether valuesets should be imported or not
 --                    p_import_ag  - indicates whether attribute groups should be imported or not
 --                    p_import_icc - indicates whether Item Catalog Categories should be imported
 --                                   or not
 --                    p_set_process_id - batch_id/set_processed_id for grouping the records to be
 --                                       processed together in a batch.
 --                    p_del_proc_recs  - indicates whether successfully imported records
 --                                      (process_status=7) should be deleted or not
 --                                      from the interface tables.
 --
 --   OUT Parameters:
 --                    errbuf       - error msg to be returned back to concurrent program
 --                                   incase of any failure.
 --                    retcode      - return code to be passed to concurrent program
 --                                   0 - SUCCESS, 1- WARNING , 2- ERROR
 **************************************************************************************************/

PROCEDURE import_metadata( errbuf  OUT  NOCOPY VARCHAR2,
                           retcode OUT  NOCOPY NUMBER,
                           p_import_vs      IN VARCHAR2,
                           p_import_ag      IN VARCHAR2,
                           p_import_icc     IN VARCHAR2,
                           p_set_process_id IN NUMBER,
                           p_del_proc_recs  IN VARCHAR2
                           );


/*************************************************************************************************
 --   Procedure     :  Get_Lock_Info
 --   Purpose       :  Procedure which gets the lock attibutes for an entity
 --   IN Parameters :
 --                    p_object_name - Object name to lock , EGO_ITEM_CATALOG_CATEGORY , EGO_VALUE_SET
 --                    p_pk1_value..p_pk5_value  - Primary key attributes used for identifying the object
 --                                                in the ego_object_lcks table
 --
 --
 --   OUT Parameters:
 --                    x_locking_party_id    - if locked, party id who has locked the object
 --                    x_lock_flag           - lock flag value L (locked), U ( unlocked)
 --                    x_return_msg         -  Return error message if any
 --                    x_return_status         - Returns S (Success), E ( Error) , U ( unexpected error)
 **************************************************************************************************/


PROCEDURE Get_Lock_Info (   p_object_name       IN  VARCHAR2
                           ,p_pk1_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk2_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk3_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk4_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk5_value         IN  VARCHAR2 DEFAULT NULL
                           ,x_locking_party_id  OUT NOCOPY NUMBER
                           ,x_lock_flag         OUT NOCOPY VARCHAR2
                           ,x_return_msg        OUT NOCOPY VARCHAR2
                           ,x_return_status     OUT NOCOPY VARCHAR2
                       );


/*************************************************************************************************
 --   Procedure     :  Lock_Unlock_Object
 --   Purpose       :  Procedure which gets the lock attibutes for an entity
 --   IN Parameters :
 --                    p_object_name - Object name to lock , EGO_ITEM_CATALOG_CATEGORY , EGO_VALUE_SET
 --                    p_pk1_value..p_pk5_value  - Primary key attributes used for identifying the object
 --                                                in the ego_object_lcks table
 --                    p_party_id    - Party id who wants to lock the object,
 --                    p_lock_flag - Boolean to indictae - true ( lock object), false ( unlock object)
 --
 --
 --   OUT Parameters:
 --                    x_return_msg         -  Return error message if any
 --                    x_return_status         - Returns S (Success), E ( Error) , U ( unexpected error)
 **************************************************************************************************/


PROCEDURE Lock_Unlock_Object  ( p_object_name   IN  VARCHAR2
                               ,p_pk1_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk2_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk3_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk4_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk5_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_party_id      IN  NUMBER   DEFAULT NULL
                               ,p_lock_flag     IN  BOOLEAN
                               ,x_return_msg    OUT NOCOPY VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                          );


/*************************************************************************************************
 --   Procedure     :  Get_Party_Name
 --   Purpose       :  Procedure which gets the party name given the party_id
 --   IN Parameters :
 --                    p_party_id - id of the party

 --   OUT Parameters:
 --                   p_party_name - name of the party
 **************************************************************************************************/

  PROCEDURE  Get_Party_Name ( p_party_id    IN          NUMBER,
                              x_party_name  OUT NOCOPY  VARCHAR2 );



END EGO_METADATA_BULKLOAD_PVT;

/
