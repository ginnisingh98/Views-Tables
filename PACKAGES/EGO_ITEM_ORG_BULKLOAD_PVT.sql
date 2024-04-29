--------------------------------------------------------
--  DDL for Package EGO_ITEM_ORG_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_ORG_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOIOBKS.pls 115.1 2004/01/07 00:09:32 ppeddama noship $ */


  -- ===============================================
  -- CONSTANTS for concurrent program return values
  -- ===============================================
  --
  -- Value for getting the current dataset id for sql loader.
  --
  G_CURR_SET_PROCESS_ID            NUMBER := -1;

-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================

  PROCEDURE process_item_org_assignments(
     ERRBUF                OUT     NOCOPY VARCHAR2
    ,RETCODE               OUT     NOCOPY NUMBER
    ,p_Set_Process_ID      IN             NUMBER
    ,p_commit              IN             VARCHAR2 DEFAULT FND_API.G_TRUE
  					 );
   -- Start OF comments
   -- API name  : Process Item Org Assignments
   -- TYPE      : Concurrent Program
   -- Pre-reqs  : None
   -- FUNCTION  : Process and Load Item Org Assignments
   --
   -- Parameters:
   --     IN    :
   --             p_resultfmt_usage_id        IN      NUMBER
   --               Similar to job number. Maps one-to-one with Data_Set_Id,
   --               i.e. job number.
   --

END EGO_ITEM_ORG_BULKLOAD_PVT;

 

/
