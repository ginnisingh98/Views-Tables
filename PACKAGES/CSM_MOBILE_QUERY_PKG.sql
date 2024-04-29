--------------------------------------------------------
--  DDL for Package CSM_MOBILE_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MOBILE_QUERY_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuqrys.pls 120.0.12010000.1 2009/08/03 06:25:43 appldev noship $ */


  /*
   * The function to be called by CSM_MOBILE_QUERY_PKG, for upward sync of
   * publication item CSM_QUERY
   */

-- Purpose: Update Query Instance changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_MOBILE_QUERY_PKG; -- Package spec

/
