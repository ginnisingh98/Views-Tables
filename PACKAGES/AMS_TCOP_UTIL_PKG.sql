--------------------------------------------------------
--  DDL for Package AMS_TCOP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvtcus.pls 115.1 2003/11/17 18:59:58 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_UTIL_PKG
-- Purpose
--
-- This package contains all the traffic cop related utilities
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- Is_Fatigue_Rule_Applicable
--
-- Purpose
-- This function verifies if Fatigue Rule is applicable for
-- this schedule or not
-- Return Value
-- It returns 'Y' if Fatigue Rule is applicable for this schedule
-- It returns 'N' if Fatigue Rule is not applicable for this schedule
--
function Is_Fatigue_Rule_Applicable (
  p_schedule_id number
) return varchar2 ;

END AMS_TCOP_UTIL_PKG;

 

/
