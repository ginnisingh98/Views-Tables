--------------------------------------------------------
--  DDL for Package CSTPCFMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPCFMS" AUTHID CURRENT_USER AS
/* $Header: CSTCFMSS.pls 120.0.12010000.1 2008/07/24 17:19:44 appldev ship $ */

FUNCTION WIP_CFM_CBR (
    i_org_id                    NUMBER,
    i_user_id                   NUMBER,
    i_login_id                  NUMBER,
    i_acct_period_id            NUMBER,
    i_wip_entity_id             NUMBER,
    err_buf              OUT NOCOPY    VARCHAR2)
RETURN INTEGER;

PROCEDURE wip_cfm_complete (
    i_trx_id               IN      NUMBER,
    i_org_id               IN      NUMBER,
    i_inv_item_id          IN      NUMBER,
    i_txn_qty              IN      NUMBER,
    i_wip_entity_id        IN      NUMBER,
    i_txn_src_type_id      IN      NUMBER,
    i_flow_schedule        IN      NUMBER,
    i_txn_action_id        IN      NUMBER,
    i_user_id              IN      NUMBER,
    i_login_id             IN      NUMBER,
    i_request_id           IN      NUMBER,
    i_prog_appl_id         IN      NUMBER,
    i_prog_id              IN      NUMBER,
    err_num                OUT NOCOPY     NUMBER,
    err_code               OUT NOCOPY     VARCHAR2,
    err_msg                OUT NOCOPY     VARCHAR2);

PROCEDURE wip_cfm_assy_return (
    i_trx_id               IN      NUMBER,
    i_org_id               IN      NUMBER,
    i_inv_item_id          IN      NUMBER,
    i_txn_qty              IN      NUMBER,
    i_wip_entity_id        IN      NUMBER,
    i_txn_src_type_id      IN      NUMBER,
    i_flow_schedule        IN      NUMBER,
    i_txn_action_id        IN      NUMBER,
    i_user_id              IN      NUMBER,
    i_login_id             IN      NUMBER,
    i_request_id           IN      NUMBER,
    i_prog_appl_id         IN      NUMBER,
    i_prog_id              IN      NUMBER,
    err_num                OUT NOCOPY     NUMBER,
    err_code               OUT NOCOPY     VARCHAR2,
    err_msg                OUT NOCOPY     VARCHAR2);

PROCEDURE wip_cfm_var_relief (
    i_wip_entity_id	IN	NUMBER,
    i_txn_action_id	IN	NUMBER,
    i_acct_period_id	IN	NUMBER,
    i_org_id		IN	NUMBER,
    i_txn_date		IN	DATE,
    i_user_id		IN	NUMBER,
    i_login_id		IN	NUMBER,
    i_request_id	IN	NUMBER,
    i_prog_id		IN	NUMBER,
    i_prog_appl_id	IN	NUMBER,
    err_num		OUT NOCOPY	NUMBER,
    err_code		OUT NOCOPY	VARCHAR2,
    err_msg		OUT NOCOPY	VARCHAR2);

END CSTPCFMS;

/
