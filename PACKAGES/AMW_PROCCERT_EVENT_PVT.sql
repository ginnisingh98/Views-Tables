--------------------------------------------------------
--  DDL for Package AMW_PROCCERT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCCERT_EVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvpces.pls 120.0 2005/05/31 18:10:17 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCCERT_EVENT_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_REFRESH_FLAG VARCHAR2(1) := 'N';
TYPE certification_array is TABLE of NUMBER INDEX by BINARY_INTEGER;
m_certification_list  certification_array;

FUNCTION Scope_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Evaluation_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Certification_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;


END AMW_PROCCERT_EVENT_PVT;


 

/
