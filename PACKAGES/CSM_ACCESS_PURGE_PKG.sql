--------------------------------------------------------
--  DDL for Package CSM_ACCESS_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_ACCESS_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeacps.pls 120.0.12010000.1 2008/07/28 16:12:47 appldev ship $ */

--
-- Purpose: Encapsulate various operations on counter.
--          Methods willbe called by workflow engine
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- TRAJASEK    28MAY07 Initial Revision
-----------------------------------------------------------

/****
 Procedure that deletes all acc records for an acc table for a resource
****/

PROCEDURE DELETE_ACC_FOR_USER( p_acc_table_name IN VARCHAR2
                                  , p_user_id IN NUMBER
                                  );

PROCEDURE DELETE_ACC_FOR_RESOURCE( p_acc_table_name IN VARCHAR2
                                  , p_resource_id IN NUMBER
                                  );

PROCEDURE PURGE_INVALID_ACC_DATA(p_status  OUT NOCOPY VARCHAR2,
                                     p_message OUT NOCOPY VARCHAR2);

END CSM_ACCESS_PURGE_PKG; -- Package spec of CSM_ACCESS_PURGE_PKG

/
