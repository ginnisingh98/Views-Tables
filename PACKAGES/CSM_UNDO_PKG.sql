--------------------------------------------------------
--  DDL for Package CSM_UNDO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_UNDO_PKG" AUTHID CURRENT_USER AS
/* $Header: csmucuds.pls 120.0.12010000.1 2009/08/21 16:26:38 trajasek noship $ */


  /*
   * The function to be called by CSM_UNDO_PKG, for upward sync of
   * publication item CSM_CLIENT_UNDO
   */

-- Purpose: Do Undo of Client  changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );


END CSM_UNDO_PKG; -- Package spec

/
