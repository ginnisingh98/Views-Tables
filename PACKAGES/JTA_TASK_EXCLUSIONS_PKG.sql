--------------------------------------------------------
--  DDL for Package JTA_TASK_EXCLUSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_TASK_EXCLUSIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtavsems.pls 115.3 2002/05/13 10:01:28 pkm ship   $ */
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
 | SSALLAKA  3/13/02   created
  -- ---------   ------  -------------------------------------------------*/

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- SSALLAKA  03/13/2002 Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Insert_Row
    --  Type        : Public
    --  Function    : Insert the Exclusion  Data into Task_exclusion
    --                   table.
    --  Pre-reqs    : None.
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
    PROCEDURE Insert_Row (
      p_task_exclusion_id        IN NUMBER,
      p_task_id                  IN NUMBER,
      p_recurrence_rule_id       IN NUMBER,
      p_exclusion_date           IN DATE,
      p_created_by               IN NUMBER DEFAULT NULL,
      p_creation_date            IN DATE   DEFAULT NULL,
      p_last_updated_by          IN NUMBER DEFAULT NULL,
      p_last_update_date         IN DATE   DEFAULT NULL,
      p_last_update_login        IN NUMBER DEFAULT NULL,
      p_security_group_id        IN NUMBER DEFAULT NULL
      );


    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Update_Row
    --  Type        : Public
    --  Function    : Update a record with task_exclusion_id
    --  Pre-reqs    : None.
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
    PROCEDURE Update_Row (
      p_task_exclusion_id        IN NUMBER,
      p_task_id                  IN NUMBER,
      p_recurrence_rule_id       IN NUMBER,
      p_exclusion_date           IN DATE,
      p_last_updated_by          IN NUMBER DEFAULT NULL,
      p_last_update_date         IN DATE   DEFAULT NULL,
      p_last_update_login        IN NUMBER DEFAULT NULL
      );

    ---------------------------------------------------------------------
    -- Start of comments
    --  API name    : Delete_Row
    --  Type        : Public
    --  Function    : Delete a record with task_exclusion_id
    --
    --  Notes:
    --
    -- End of comments
    ---------------------------------------------------------------------
    PROCEDURE Delete_Row (
      p_task_exclusion_id        IN NUMBER
    );

END JTA_TASK_EXCLUSIONS_PKG;

 

/
