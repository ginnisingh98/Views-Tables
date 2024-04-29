--------------------------------------------------------
--  DDL for Package IEX_TRX_GRID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TRX_GRID_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvtrcs.pls 120.0.12010000.2 2010/02/05 12:45:02 gnramasa ship $ */

  PROCEDURE Set_Unpaid_Reason
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_del_ids          IN  VARCHAR2,
   p_unpaid_reason    IN  VARCHAR2,
   x_rows_processed   OUT NOCOPY NUMBER);

   PROCEDURE SET_STAGED_DUNNING_LEVEL
    (p_api_version      IN  NUMBER := 1.0,
     p_init_msg_list    IN  VARCHAR2,
     p_commit           IN  VARCHAR2,
     p_validation_level IN  NUMBER,
     p_delinquency_id   IN  NUMBER,
     p_stg_dunn_level   IN  NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2);

END;

/
