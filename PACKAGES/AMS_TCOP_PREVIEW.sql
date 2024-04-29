--------------------------------------------------------
--  DDL for Package AMS_TCOP_PREVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_PREVIEW" AUTHID CURRENT_USER AS
/* $Header: amsvtcps.pls 120.1 2005/07/20 06:18:58 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_PREVIEW
-- Purpose
--
-- This package contains all the program units for preview
--
-- History
--
-- NOTE
--
-- End of Comments
G_PACKAGE_NAME CONSTANT VARCHAR2(30) := 'AMS_TCOP_PREVIEW';
-- ===============================================================
-- Start of Comments
-- Name
-- REFRESH
--
-- Purpose
-- This function is called from Business Event
--
FUNCTION REFRESH(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2;

FUNCTION FORCE_REFRESH(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2;

PROCEDURE   PREVIEW_FATIGUE(p_list_header_id  IN  NUMBER);

PROCEDURE   REGENERATE_PREVIEW( p_list_header_id  IN  NUMBER);
PROCEDURE   REGENERATE_PREVIEW_DAYS( p_list_header_id  IN  NUMBER , p_no_of_days IN NUMBER);

END AMS_TCOP_PREVIEW;

 

/
