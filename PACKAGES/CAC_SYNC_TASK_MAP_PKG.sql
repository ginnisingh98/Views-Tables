--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: cacvstms.pls 120.1 2005/07/02 02:21:17 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstms.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is used to insert/update/delete sync task            |
 |                      mapping record.                                  |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 18-Oct-2004   sachoudh         Created.                               |
 +======================================================================*/

    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Insert_Row
    --  Type        : Public
    --  Function    : Insert the To Do or Appointment Data into mapping
    --                   table.
    --  Pre-reqs    : None.
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
   PROCEDURE Insert_Row (
      p_task_sync_id        IN NUMBER,
      p_task_id             IN NUMBER,
      p_resource_id         IN NUMBER,
      p_principal_id        IN NUMBER
      );


    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Update_Row
    --  Type        : Public
    --  Function    : Update a record with task_sync_id
    --  Pre-reqs    : None.
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
    PROCEDURE Update_Row (
      p_task_sync_id        IN NUMBER,
      p_task_id             IN NUMBER,
      p_resource_id         IN NUMBER,
      p_principal_id        IN NUMBER
      );

    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Delete_Row
    --  Type        : Public
    --  Function    : Delete a record with task_sync_id
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
    PROCEDURE Delete_Row (
      p_task_sync_id        IN NUMBER
    );

END CAC_SYNC_TASK_MAP_PKG ;

 

/
