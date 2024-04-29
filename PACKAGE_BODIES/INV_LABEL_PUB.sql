--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PUB" AS
/* $Header: INVPLABB.pls 120.1 2005/06/20 23:30:01 appldev ship $ */

PROCEDURE print_label
(
	x_return_status 	OUT NOCOPY VARCHAR2  -- NOCOPY added as a part of Bug# 4380449
,	x_msg_count		OUT NOCOPY NUMBER    -- NOCOPY added as a part of Bug# 4380449
,	x_msg_data		OUT NOCOPY VARCHAR2  -- NOCOPY added as a part of Bug# 4380449
,	x_label_status		OUT NOCOPY VARCHAR2  -- NOCOPY added as a part of Bug# 4380449
,	p_api_version   	IN  NUMBER := 1.0
,	p_init_msg_list		IN  VARCHAR2 := fnd_api.g_false
,	p_commit	      	IN  VARCHAR2 := fnd_api.g_false
,	p_business_flow_code	IN  NUMBER DEFAULT NULL
,	p_transaction_id	IN  INV_LABEL_PUB.transaction_id_rec_type default INV_LABEL_PUB.txn_id_null_rec
,p_transaction_identifier IN NUMBER DEFAULT NULL
)IS

	l_transaction_id     	INV_LABEL.transaction_id_rec_type;
	i 			BINARY_INTEGER;

BEGIN
        -- Initialize API return status to success

        x_return_status := FND_API.G_RET_STS_SUCCESS;

       FOR i IN 1..p_transaction_id.count()
       LOOP
       		l_transaction_id(1) := p_transaction_id(i);

        	inv_label.print_label(
	 	      	x_return_status       	=> x_return_status
		,       x_msg_count          	=> x_msg_count
		,       x_msg_data           	=> x_msg_data
		,       x_label_status       	=> x_label_status
		,       p_api_version        	=> 1.0
		,       p_print_mode        	=> 1
		,       p_business_flow_code    => p_business_flow_code
		,       p_transaction_id        => l_transaction_id
                ,p_transaction_identifier       =>p_transaction_identifier
);

	END LOOP;



END print_label;

END INV_LABEL_PUB;

/
