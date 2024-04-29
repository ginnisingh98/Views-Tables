--------------------------------------------------------
--  DDL for Package CSTPSMCW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSMCW" AUTHID CURRENT_USER AS
/* $Header: CSTSMCWS.pls 115.9 2002/11/22 22:36:46 visrivas ship $ */

PROCEDURE COST_LOT_TXN ( p_api_version  	IN  NUMBER,
                         p_transaction_id	IN  NUMBER,
                         p_request_id           IN  NUMBER,
                         x_err_num              IN OUT NOCOPY NUMBER,
                         x_err_code             IN OUT NOCOPY VARCHAR2,
                         x_err_msg              IN OUT NOCOPY VARCHAR2);


PROCEDURE LOT_TXN_COST_PROCESSOR(RETCODE OUT NOCOPY number,
                                 ERRBUF OUT NOCOPY varchar2,
                                 p_org_id in number,
                                 p_group_id in number);

END CSTPSMCW;

 

/
