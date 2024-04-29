--------------------------------------------------------
--  DDL for Package IBY_FNDCPT_VLD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FNDCPT_VLD_PUB" AUTHID CURRENT_USER AS
/* $Header: ibypfcvs.pls 120.0.12010000.3 2009/10/19 11:16:21 sgogula ship $ */

-- Package global constants
G_PKG_NAME CONSTANT VARCHAR2(30):='IBY_FNDCPT_VLD_PUB';


-- Validate Citibank credit card batch
PROCEDURE Validate_Citibank_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
);

-- Validate FDCNorth credit card batch
PROCEDURE Validate_FDCNorth_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
);

-- Validate Paymentech credit card batch
PROCEDURE Validate_Paymentech_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
);


PROCEDURE Validate_SEPA_Mandate (
	p_assignment_id		IN	NUMBER,
        x_message 		OUT	NOCOPY	VARCHAR2,
	x_return_status         OUT	NOCOPY	VARCHAR2
);

-- Validate SEPA DD batch
PROCEDURE Validate_Sepa_DD_Batch (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 default FND_API.G_FALSE,
	P_MBATCH_ID		IN	NUMBER,
	x_return_status         OUT	NOCOPY	VARCHAR2,
	x_msg_count		OUT	NOCOPY	NUMBER,
	x_msg_data		OUT	NOCOPY	VARCHAR2
);

END IBY_FNDCPT_VLD_PUB;

/
