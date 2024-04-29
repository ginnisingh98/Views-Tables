--------------------------------------------------------
--  DDL for Package CSM_QUERY_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_QUERY_INSTANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuqis.pls 120.0.12010000.2 2009/08/17 05:52:59 trajasek noship $ */


  /*
   * The function to be called by CSM_QUERY_INSTANCE_PKG, for upward sync of
   * publication item CSM_QUERY_INSTANCES
   */

-- Purpose: Update Query Instance changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           p_from_sync     IN VARCHAR2 DEFAULT 'N',
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_QUERY_INSTANCE_PKG; -- Package spec

/
