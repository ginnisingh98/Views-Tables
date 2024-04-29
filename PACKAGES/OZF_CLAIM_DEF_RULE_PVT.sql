--------------------------------------------------------
--  DDL for Package OZF_CLAIM_DEF_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_DEF_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcdrs.pls 120.1 2005/12/01 22:27:06 azahmed noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          ozf_claim_def_rule_pvt
-- Purpose
--
-- History
--
-- NOTE
--
-- ===============================================================

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name:
--        clam_def_rec_type
--   -------------------------------------------------------
--    Attributes:
--       defaulting_rule_id
--       object_version_number
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       claim_class
--       source_object_class
--       custom_setup_id
--       claim_type_id
--       reason_code_id
--       start_date
--       end_date
--       org_id
--
--    Required
--
--    Defaults
--
--    Note
--
--   End of Comments
--===================================================================
TYPE clam_def_rec_type IS RECORD
(
    defaulting_rule_id              NUMBER,
    object_version_number           NUMBER,
    last_update_date                DATE,
    last_updated_by                 NUMBER,
    creation_date                   DATE,
    created_by                      NUMBER,
    last_update_login               NUMBER,
    claim_class                     VARCHAR2(30),
    source_object_class             VARCHAR2(30),
    custom_setup_id                 NUMBER,
    claim_type_id                   NUMBER,
    reason_code_id                  NUMBER,
    start_date                      DATE,
    end_date                        DATE,
    org_id                          NUMBER
);

g_miss_type_rec          clam_def_rec_type := NULL;

TYPE clam_def_tbl_type IS TABLE OF clam_def_rec_type
INDEX BY BINARY_INTEGER;


PROCEDURE get_clam_def_rule(
    p_claim_rec               IN OZF_Claim_PVT.claim_rec_type,
    x_clam_def_rec_type       OUT NOCOPY clam_def_rec_type,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2
);

END ozf_claim_def_rule_pvt;

/
