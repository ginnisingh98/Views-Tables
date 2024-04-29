--------------------------------------------------------
--  DDL for Package GMO_SETUP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_SETUP_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGSTPS.pls 120.1 2005/08/05 04:08 rahugupt noship $ */

--This function would check if GMO is enabled or not.

-- Start of comments
-- API name             : is_gmo_enabled
-- Type                 : Group Utility.
-- Function             : checks if gmo is enabled
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :
-- OUT                  :
-- End of comments

FUNCTION IS_GMO_ENABLED RETURN VARCHAR2;

--This function would check if GMO is enabled or not.

-- Start of comments
-- API name             : is_device_func_enabled
-- Type                 : Group Utility.
-- Function             : checks if gmo device functionality is enabled
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :
-- OUT                  :
-- End of comments

FUNCTION IS_DEVICE_FUNC_ENABLED RETURN VARCHAR2;

END GMO_SETUP_GRP;

 

/
