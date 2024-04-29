--------------------------------------------------------
--  DDL for Package FA_LEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LEASE_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPLEAS.pls 120.1.12010000.2 2009/07/19 12:14:57 glchen ship $ */
--
-- API name: FA_LEASE_PUB
-- Type: Public
-- Pre-reqs: None.
-- Function/Procedure: Create Lease and Update Lease Information in FA.
--
-- Author: Rajeev Jessani
-- Parameters:
--    IN: p_api_version IN NUMBER                        Required
--        p_calling_fn  IN VARCHAR2
--        P_TRANS_REC   IN FA_API_TYPES.TRANS_REC_TYPE
--                         -- This will be used to hold WHO information only.
--        PX_LEASE_DETAILS_RECIN OUTFA_API_TYPES.LEASE_DETAILS_REC_TYPE
--                         -- This will hold Lease Details information
--
-------------------------------------------
-- CREATE LEASE PUBLIC API
-------------------------------------------

PROCEDURE CREATE_LEASE  (
   P_API_VERSION              IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2 := FND_API.G_FALSE,
   P_COMMIT                   IN     VARCHAR2 := FND_API.G_FALSE,
   P_VALIDATION_LEVEL         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_CALLING_FN               IN     VARCHAR2,
   P_TRANS_REC		      IN     FA_API_TYPES.TRANS_REC_TYPE,
   PX_LEASE_DETAILS_REC	      IN OUT NOCOPY FA_API_TYPES.LEASE_DETAILS_REC_TYPE
);

-------------------------------------------
-- UPDATE LEASE PUBLIC API
-------------------------------------------
PROCEDURE UPDATE_LEASE  (
   P_API_VERSION              IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2 := FND_API.G_FALSE,
   P_COMMIT                   IN     VARCHAR2 := FND_API.G_FALSE,
   P_VALIDATION_LEVEL         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_CALLING_FN               IN     VARCHAR2,
   P_TRANS_REC		      IN     FA_API_TYPES.TRANS_REC_TYPE,
   P_LEASE_DETAILS_REC_NEW    IN     FA_API_TYPES.LEASE_DETAILS_REC_TYPE
);
END FA_LEASE_PUB;

/
