--------------------------------------------------------
--  DDL for Package CSE_WFM_TRX_GRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_WFM_TRX_GRP_PVT" AUTHID CURRENT_USER AS
/* $Header: CSEWBWRS.pls 120.1 2006/05/31 20:52:21 brmanesh noship $ */

  PROCEDURE wfm_transactions(
    p_api_version      IN NUMBER,
    p_commit           IN VARCHAR2,
    p_validation_level IN NUMBER,
    p_init_msg_list    IN VARCHAR2,
    p_transaction_type IN VARCHAR2,
    p_wfm_values_tbl   IN OUT NOCOPY cse_datastructures_pub.wfm_trx_values_tbl,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2);

END cse_wfm_trx_grp_pvt;

 

/
