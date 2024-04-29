--------------------------------------------------------
--  DDL for Package INV_LABEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LABEL_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPLABS.pls 120.1 2005/06/20 23:24:18 appldev ship $ */

-- Table type definition for an array of transaction_id reocrds and input parameters
TYPE transaction_id_rec_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

txn_id_null_rec transaction_id_rec_type;

PROCEDURE print_label
(
	x_return_status 	OUT NOCOPY VARCHAR2     -- NOCOPY added as a part of Bug# 4380449
,	x_msg_count		OUT NOCOPY NUMBER       -- NOCOPY added as a part of Bug# 4380449
,	x_msg_data		OUT NOCOPY VARCHAR2     -- NOCOPY added as a part of Bug# 4380449
,	x_label_status		OUT NOCOPY VARCHAR2     -- NOCOPY added as a part of Bug# 4380449
,	p_api_version   	IN  NUMBER := 1.0
,	p_init_msg_list		IN  VARCHAR2 := fnd_api.g_false
,	p_commit	      	IN  VARCHAR2 := fnd_api.g_false
,	p_business_flow_code	IN  NUMBER DEFAULT NULL
,	p_transaction_id	IN  INV_LABEL_PUB.transaction_id_rec_type default INV_LABEL_PUB.txn_id_null_rec
,       p_transaction_identifier IN NUMBER DEFAULT NULL
);

END INV_LABEL_PUB;

 

/
