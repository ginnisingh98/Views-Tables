--------------------------------------------------------
--  DDL for Package AMS_TCOP_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvtcrs.pls 115.0 2003/11/17 00:16:37 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_ENGINE_PKG
-- Purpose
--
-- This package contains all the program units for traffic cop
-- Engine
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- Apply_Fatigue_Rules
--
-- Purpose
-- This procedure applies fatigue rules on the Target Group of Schedule.
--
G_PACKAGE_NAME  CONSTANT VARCHAR2(30) := 'AMS_TCOP_ENGINE_PKG';

Procedure Apply_Fatigue_Rules(
  p_schedule_id NUMBER
) ;


END AMS_TCOP_ENGINE_PKG;

 

/
