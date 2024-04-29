--------------------------------------------------------
--  DDL for Package ZPB_EXTERNAL_BP_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_EXTERNAL_BP_PUBLISH" AUTHID CURRENT_USER AS
/* $Header: zpbpbpes.pls 120.0.12010.2 2005/12/23 12:11:46 appldev noship $  */

  PROCEDURE START_BUSINESS_PROCESS(
    P_api_version       IN  NUMBER,
    P_init_msg_list     IN  VARCHAR2,
    P_validation_level  IN  NUMBER,
    P_bp_name           IN  VARCHAR2,
    P_ba_name           IN  VARCHAR2,
    P_horizon_start     IN  DATE DEFAULT NULL,
    P_horizon_end       IN  DATE DEFAULT NULL,
    P_send_date         IN  DATE DEFAULT NULL,
    x_start_member      OUT NOCOPY VARCHAR2,
    x_end_member        OUT NOCOPY VARCHAR2,
    X_item_key          OUT NOCOPY VARCHAR2,
    X_msg_count         OUT NOCOPY NUMBER,
    X_msg_data          OUT NOCOPY VARCHAR2,
    X_return_status     OUT NOCOPY VARCHAR2
    );
END ZPB_EXTERNAL_BP_PUBLISH ;

 

/
