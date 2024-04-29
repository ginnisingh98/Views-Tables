--------------------------------------------------------
--  DDL for Package OTA_OM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OM_DEBUG" AUTHID CURRENT_USER as
/* $Header: ottomdbg.pkh 120.0 2005/05/29 07:45:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <reset_debug_level> >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Out Parameters:
--   Name                       Reqd Type     	Description
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------
PROCEDURE RESET_DEBUG_LEVEL;


-- ----------------------------------------------------------------------------
-- |--------------------------< <set_debug_level> >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                       Reqd Type     	Description
--   p_debug_level					Debug Level
--
-- Out Parameters:
--   Name                       Reqd Type     	Description
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------
PROCEDURE SET_DEBUG_LEVEL (p_debug_level IN NUMBER);


END ota_om_debug;

 

/
