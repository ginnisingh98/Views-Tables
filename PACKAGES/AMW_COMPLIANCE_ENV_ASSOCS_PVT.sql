--------------------------------------------------------
--  DDL for Package AMW_COMPLIANCE_ENV_ASSOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_COMPLIANCE_ENV_ASSOCS_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvenvs.pls 120.0 2005/05/31 20:31:01 appldev noship $ */

-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_PRESENT
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Compliance Environment
-- History
--          12.09.2004 tsho: bug 3902348 fixed
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_PRESENT (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_pk1                 IN         NUMBER,
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Compliance Environment
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_PRESENT_MEAN (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_pk1                 IN         NUMBER,
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_DISABLE
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          specified Compliance Environment should be disabled or not.
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_DISABLE (
    p_compliance_env_id   IN         NUMBER,
    p_object_type         IN         VARCHAR2,
    p_pk1                 IN         NUMBER,
    p_object_id           IN         NUMBER     := NULL,
    p_pk2                 IN         NUMBER     := NULL,
    p_pk3                 IN         NUMBER     := NULL,
    p_pk4                 IN         NUMBER     := NULL,
    p_pk5                 IN         NUMBER     := NULL
) RETURN VARCHAR2;




-- ===============================================================
-- Procedure name
--          PROCESS_COMPLIANCE_ENV_ASSOCS
-- Purpose
-- 		    Update the compliance environment associations depending
--          on the specified p_select_flag .
--          The p_pk1 is co-related with p_object_type, for exampel:
--          if p_object_type is SETUP_RISK_TYPE, then
--          p_pk1 is SETUP_RISK_TYPE_ID .
-- ===============================================================
PROCEDURE PROCESS_COMPLIANCE_ENV_ASSOCS (
                   p_init_msg_list       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_commit              IN         VARCHAR2   := FND_API.G_FALSE,
                   p_validate_only       IN         VARCHAR2   := FND_API.G_FALSE,
                   p_select_flag         IN         VARCHAR2,
                   p_compliance_env_id   IN         NUMBER,
                   p_object_type         IN         VARCHAR2,
                   p_pk1                 IN         NUMBER,
                   p_pk2                 IN         NUMBER     := NULL,
                   p_pk3                 IN         NUMBER     := NULL,
                   p_pk4                 IN         NUMBER     := NULL,
                   p_pk5                 IN         NUMBER     := NULL,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2
);

-- ===============================================================
-- Function name
--          COMPLIANCE_ENVS_IN_USE
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Compliance Environment is used for assoication
--          if it's in used, return 'Y', else, return 'N'.
-- Notes
--          don't need to bother which p_object_type it's associated with.
--          as long as it appears in amw_compliance_env_assocs table,
--          the return value will be 'Y'.
-- ===============================================================
FUNCTION COMPLIANCE_ENVS_IN_USE (
    p_compliance_env_id   IN         NUMBER
) RETURN VARCHAR2;

-- ----------------------------------------------------------------------
END  AMW_COMPLIANCE_ENV_ASSOCS_PVT;

 

/
