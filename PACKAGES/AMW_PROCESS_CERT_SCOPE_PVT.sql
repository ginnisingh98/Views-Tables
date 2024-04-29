--------------------------------------------------------
--  DDL for Package AMW_PROCESS_CERT_SCOPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCESS_CERT_SCOPE_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvpcss.pls 120.1 2005/07/05 18:26:58 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCESS_CERT_SCOPE_PVT
-- Purpose
--
-- History
--
-- File Name :- amwvpcss.pls
-- NOTE
--
-- End of Comments
-- ===============================================================



PROCEDURE insert_audit_units(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_certification_id		    IN	 NUMBER,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
);

-- Removed the following procedure to fix bug 4474874
-- This procedure is only called in AMW_POPULATE_HIERARCHIES_PVT
-- (amwphierb.pls). amwphierb.pls has been obsolete.
/*
PROCEDURE insert_specific_audit_units(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_certification_id		    IN	     NUMBER,
    p_org_tbl                   IN       AMW_POPULATE_HIERARCHIES_PVT.g_org_tbl%TYPE,
    p_process_tbl               IN       AMW_POPULATE_HIERARCHIES_PVT.g_process_tbl%TYPE,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
);
*/


END amw_process_cert_scope_pvt;


 

/
