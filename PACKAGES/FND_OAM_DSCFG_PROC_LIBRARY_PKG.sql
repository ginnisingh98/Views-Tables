--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_PROC_LIBRARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_PROC_LIBRARY_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCPROCLIBS.pls 120.1 2005/12/14 14:40 yawu noship $ */

   ---------------
   -- Constants --
   ---------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This procedure is used to disable all triggers for tables which will be modified
   -- by the Engine.  For each disabled trigger, a new DSCFG_OBJECT is created identifying
   -- the trigger so the companion RE_ENABLE_DISABLED_TRIGGERS method can undo these
   -- actions after execution.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   None, config_instance_id pulled from INSTANCES_PKG state.
   -- Return Statuses:
   --   None, status written to ERRORS_FOUND_FLAG/MESSAGE of failed objects.
   PROCEDURE DISABLE_TARGET_TABLES_TRIGGERS;
   PROCEDURE RE_ENABLE_DISABLED_TRIGGERS;

   -- This procedure is used to disable all primary keys for tables which will be modified
   -- by the Engine.  For each disabled primary key, a new DSCFG_OBJECT is created identifying
   -- the primary key so the companion ENABLE_DISABLED_PRIMARY_KEYS method can undo these
   -- actions after execution.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   None, config_instance_id pulled from INSTANCES_PKG state.
   -- Return Statuses:
   --   None, status written to ERRORS_FOUND_FLAG/MESSAGE of failed objects.
   PROCEDURE DISABLE_TARGET_PRIMARY_KEYS;
   PROCEDURE ENABLE_DISABLED_PRIMARY_KEYS;

END FND_OAM_DSCFG_PROC_LIBRARY_PKG;

 

/
