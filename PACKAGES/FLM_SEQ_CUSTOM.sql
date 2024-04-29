--------------------------------------------------------
--  DDL for Package FLM_SEQ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SEQ_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: FLMSQCPS.pls 115.1 2004/05/21 00:54:41 sshi noship $  */

PROCEDURE Get_Attribute_Value (
                p_api_version_number    IN      NUMBER,
		p_org_id		IN 	NUMBER,
		p_id			IN	NUMBER,
                p_attribute_id          IN 	NUMBER,
                p_attribute_type        IN      NUMBER,
         	p_other_id              IN 	NUMBER,
          	p_other_name            IN 	VARCHAR2,
                x_value_num		OUT     NOCOPY NUMBER,
		x_value_name		OUT	NOCOPY VARCHAR2,
                x_return_status         OUT     NOCOPY  VARCHAR2,
                x_msg_count             OUT     NOCOPY  NUMBER,
                x_msg_data              OUT     NOCOPY  VARCHAR2);

PROCEDURE Post_Process_Demand (
                p_api_version_number    IN      NUMBER,
		p_seq_task_id		IN	NUMBER,
                x_return_status         OUT     NOCOPY  VARCHAR2,
                x_msg_count             OUT     NOCOPY  NUMBER,
                x_msg_data              OUT     NOCOPY  VARCHAR2);

END FLM_SEQ_CUSTOM;

 

/
