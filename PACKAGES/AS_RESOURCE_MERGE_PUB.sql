--------------------------------------------------------
--  DDL for Package AS_RESOURCE_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_RESOURCE_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: asxrsmrs.pls 115.0 2004/01/23 01:31:12 ffang noship $ */

-- Start of Comments
-- Package name : AS_RESOURCE_MERGE_PUB
--
-- Purpose      : This package should be called in event subscription of
--                event oracle.apps.jtf.jres.resource.update.effectdate.
--                It will update the salesforce_id(resource_id) column in AS
--                tables due to resource merge.
--
-- NOTES
--
-- HISTORY
--   12/31/03  FFANG    Created.
--
--

FUNCTION update_resource_enddate (
    p_subscription_guid      in raw,
    p_event                  in out NOCOPY wf_event_t )
RETURN VARCHAR2;

END AS_RESOURCE_MERGE_PUB;

 

/
