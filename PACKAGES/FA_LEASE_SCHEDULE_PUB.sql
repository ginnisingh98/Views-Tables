--------------------------------------------------------
--  DDL for Package FA_LEASE_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LEASE_SCHEDULE_PUB" AUTHID CURRENT_USER AS
/* $Header: FAPLSCS.pls 120.1.12010000.2 2009/07/19 12:15:55 glchen ship $ */
--
-- API name:           FA_LEASE_SCHEDULE_PUB
-- Type:               Public
-- Pre-reqs:           None.
-- Function/Procedure: Create Payments and Create Amortizationin FA.
--
-- Parameters:
-- IN:                 p_api_version
--                     p_calling_fn
--                     P_TRANS_REC
--                     This will be used to hold WHO information only.
--                     PX_LEASE_SCHEDULES_REC
--                     This will hold Lease Schedule information
--                     P_LEASE_ PAYMENTS_TBL
--                     This will hold Lease payment Information

----------------------------------------------------
-- PUBLIC PROCEDURE TO CREATE PAYMENTS
----------------------------------------------------

PROCEDURE CREATE_PAYMENTS  (
   P_API_VERSION              IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2 := FND_API.G_FALSE,
   P_COMMIT                   IN     VARCHAR2 := FND_API.G_FALSE,
   P_VALIDATION_LEVEL         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_CALLING_FN               IN     VARCHAR2,
   P_TRANS_REC		      IN     FA_API_TYPES.TRANS_REC_TYPE,
   PX_LEASE_SCHEDULES_REC     IN OUT NOCOPY FA_API_TYPES.LEASE_SCHEDULES_REC_TYPE,
   P_LEASE_PAYMENTS_TBL       IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE
);

----------------------------------------------------
-- PUBLIC PROCEDURE TO CREATE AMORTIZATION
----------------------------------------------------
PROCEDURE CREATE_AMORTIZATION  (
   P_API_VERSION              IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2 := FND_API.G_FALSE,
   P_COMMIT                   IN     VARCHAR2 := FND_API.G_FALSE,
   P_VALIDATION_LEVEL         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_CALLING_FN               IN     VARCHAR2,
   P_TRANS_REC		      IN     FA_API_TYPES.TRANS_REC_TYPE,
   P_PAYMENT_SCHEDULE_ID      IN     NUMBER
);

-------------------------------------------------------
-- PUBLIC PROCEDURE TO CREATE PAYMENTS AND AMORTIZATION
-------------------------------------------------------

PROCEDURE CREATE_LEASE_SCHEDULE (
   P_API_VERSION              IN     NUMBER,
   P_INIT_MSG_LIST            IN     VARCHAR2 := FND_API.G_FALSE,
   P_COMMIT                   IN     VARCHAR2 := FND_API.G_FALSE,
   P_VALIDATION_LEVEL         IN     NUMBER:=FND_API.G_VALID_LEVEL_FULL,
   X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                   OUT NOCOPY NUMBER,
   X_MSG_DATA                    OUT NOCOPY VARCHAR2,
   P_CALLING_FN               IN     VARCHAR2,
   P_TRANS_REC		      IN     FA_API_TYPES.TRANS_REC_TYPE,
   PX_LEASE_SCHEDULES_REC     IN OUT NOCOPY FA_API_TYPES.LEASE_SCHEDULES_REC_TYPE,
   P_LEASE_PAYMENTS_TBL       IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE
);

END FA_LEASE_SCHEDULE_PUB;

/
