--------------------------------------------------------
--  DDL for Package XLE_UPGRADE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_UPGRADE_UTILS" AUTHID CURRENT_USER AS
/* $Header: xleupgutils.pls 120.2 2005/09/22 05:37:21 rbasker ship $ */

-- /*==========================================================================
 -- API name     : Get_Default_legal_context
 -- Type         : public
 -- Pre-reqs     : Upgrade Data
 -- Description  :
 --              This API is returns the Default Legal Context (Legal Entity ID)
 --              given an OU.  This API derives the LE ID from user mapping in
 --              preupgrade tables
 --
 -- Version      :   Current Version 1.0
 --                  Initial Version 1.0
 --  Parameters  :
 --  IN          :
 --                  p_org_id			IN NUMBER   Required
 --
 -- OUT          :   x_return_status  OUT VARCHAR2
 --                  x_msg_count      OUT NUMBER
 --                  x_msg_data       OUT VARCHAR2
 --                  x_dlc            OUT NUMBER
 -- /*=========================================================================

  PROCEDURE Get_default_Legal_Context
     ( x_return_status      OUT NOCOPY  VARCHAR2,
       x_msg_count          OUT NOCOPY  NUMBER,
       x_msg_data           OUT NOCOPY  VARCHAR2,
       p_org_id             IN          NUMBER,
       x_dlc                OUT NOCOPY  NUMBER );

END XLE_UPGRADE_UTILS;

 

/
