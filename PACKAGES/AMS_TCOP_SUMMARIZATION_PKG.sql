--------------------------------------------------------
--  DDL for Package AMS_TCOP_SUMMARIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_SUMMARIZATION_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvtcms.pls 115.0 2003/11/17 00:21:11 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_SUMMARIZATION_PKG
-- Purpose
--
-- This package contains all the program units for summarizing
-- contacts made through fatigue schedules
--
-- History
--
-- NOTE
--
-- End of Comments

-- Declare Package Variables

G_PACKAGE_NAME    VARCHAR2(30) := 'AMS_TCOP_SUMMARIZATION_PKG';

-- ===============================================================
-- Start of Comments
-- Name
-- SUMMARIZE_LIST_CONTACTS
--
-- Purpose
-- This procedure considers the set of parties available in the given Target Group.
-- For these parties, it summarizes the number of contacts made by fatiguing schedules in the periods
-- specified in the Fatigue Rule Setup
--
PROCEDURE SUMMARIZE_LIST_CONTACTS( p_list_header_id NUMBER,
                                   p_activity_id    NUMBER
                                 );

-- ===============================================================
-- Start of Comments
-- Name
-- SUMMARIZE_ALL_FATIGUE_CONTACTS
--
-- Purpose
-- This procedure summarizes all fatiguing contacts for the periods
-- specified in Fatigue Rule Setup
--
PROCEDURE   SUMMARIZE_ALL_FATIGUE_CONTACTS;

-- ===============================================================
-- Start of Comments
-- Name
-- UPDATE_CONTACT_COUNT
--
-- Purpose
-- This procedure updates contact count for all the contacted parties
--
PROCEDURE      UPDATE_CONTACT_COUNT(p_party_id_list   JTF_NUMBER_TABLE
                                    ,p_schedule_id    NUMBER
                                    ,p_activity_id    NUMBER
                                    ,p_global_rule_id NUMBER
                                    ,p_channel_rule_id   NUMBER
                                   );

END AMS_TCOP_SUMMARIZATION_PKG;

 

/
