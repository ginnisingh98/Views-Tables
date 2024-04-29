--------------------------------------------------------
--  DDL for Package OTA_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OM_UTIL" AUTHID CURRENT_USER as
/* $Header: otomutil.pkh 115.1 2002/11/26 15:57:39 arkashya noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <get_event_detail> >------------------------|
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
--  p_line_id			    NUMBER        Line ID
--  p_uom			    VARCHAR2      Unit of measure
--
-- Out Parameters:
--   Name                       Reqd Type     	Description
--  x_activity_name    		VARCHAR2	Activity Name
--  x_event_title		VARCHAR2	Event Title
--  x_course_start_date		DATE		Course Start Date
--  x_course_end_date		DATE		Course End Date
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
PROCEDURE get_event_detail
  (p_line_id        		IN	NUMBER,
   p_UOM			IN	VARCHAR2,
   x_activity_name		OUT   NOCOPY VARCHAR2,
   x_event_title		OUT   NOCOPY VARCHAR2,
   x_course_start_date		OUT   NOCOPY	DATE,
   x_course_end_date		OUT   NOCOPY    DATE
  );


END ota_om_util;

 

/
