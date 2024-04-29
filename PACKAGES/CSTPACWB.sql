--------------------------------------------------------
--  DDL for Package CSTPACWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACWB" AUTHID CURRENT_USER AS
/* $Header: CSTPACBS.pls 115.3 2002/11/08 23:23:58 awwang ship $ */

PROCEDURE cost_in (
 I_TRX_ID			IN   	NUMBER,
 I_LAYER_ID			IN	NUMBER,
 I_COMM_ISS_FLAG		IN	NUMBER,
 I_COST_TXN_ACTION_ID		IN	NUMBER,
 I_TXN_QTY			IN	NUMBER,
 I_PERIOD_ID			IN	NUMBER,
 I_WIP_ENTITY_ID		IN	NUMBER,
 I_ORG_ID			IN	NUMBER,
 I_USER_ID			IN	NUMBER,
 I_REQUEST_ID			IN	NUMBER,
 ERR_NUM			OUT NOCOPY	NUMBER,
 ERR_CODE			OUT NOCOPY	VARCHAR2,
 ERR_MSG			OUT NOCOPY	VARCHAR2);

PROCEDURE cost_out (
 I_TRX_ID                       IN      NUMBER,
 I_TXN_QTY                      IN      NUMBER,
 I_PERIOD_ID			IN	NUMBER,
 I_WIP_ENTITY_ID                IN      NUMBER,
 I_ORG_ID                       IN      NUMBER,
 I_USER_ID                      IN      NUMBER,
 I_REQUEST_ID                   IN      NUMBER,
 ERR_NUM                        OUT NOCOPY     NUMBER,
 ERR_CODE                       OUT NOCOPY     VARCHAR2,
 ERR_MSG                        OUT NOCOPY     VARCHAR2);

END CSTPACWB;

 

/
