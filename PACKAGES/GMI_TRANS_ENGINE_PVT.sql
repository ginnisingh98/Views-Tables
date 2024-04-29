--------------------------------------------------------
--  DDL for Package GMI_TRANS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_TRANS_ENGINE_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVTXNS.pls 115.11 2002/11/05 18:40:48 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVTXNS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For creation of           |
 |     inventory Transcations For IC_TRAN_PND                              |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     26-May-2000  P.J.Schofield                                          |
 |                  Added support for ic_tran_cmp                          |
 |     14-JUN-2001  H.Verdding                                             |
 |                  Added Function check_close_period B1834369             |
 |     04-NOV-2002  J.DiIorio BUG#2643440 11.5.1J                          |
 |                  Added nocopy.                                          |
 +=========================================================================+
  API Name  : GMI_TRANS_ENGINE_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              inventory transactions.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

*/
/*  Define Procedures And Functions :   */


PROCEDURE CREATE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_COMPLETED_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_CMP%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_table_name         IN  VARCHAR2        DEFAULT 'IC_TRAN_CMP'
);

PROCEDURE DELETE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_PENDING_TRANSACTION
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_PENDING_TO_COMPLETED
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN  VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN  VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE PENDING_TRANSACTION_BUILD
( p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
);

PROCEDURE COMPLETED_TRANSACTION_BUILD
( p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_row           OUT NOCOPY IC_TRAN_PND%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
);

Procedure SET_DEFAULTS
( p_tran_rec           IN   GMI_TRANS_ENGINE_PUB.ictran_rec
, x_tran_rec           OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
);

FUNCTION CLOSE_PERIOD_CHECK
( p_tran_rec           IN   GMI_TRANS_ENGINE_PUB.ictran_rec
, p_retry_flag         IN   NUMBER
, x_tran_rec           IN OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN;


END GMI_TRANS_ENGINE_PVT;

 

/
