--------------------------------------------------------
--  DDL for Package AR_TRANSACTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRANSACTION_GRP" AUTHID CURRENT_USER AS
/* $Header: ARXGTRXS.pls 115.2 2004/04/29 20:11:29 vsidhart noship $ */

PROCEDURE COMPLETE_TRANSACTION(
      p_api_version           IN      	  NUMBER,
      p_init_msg_list         IN      	  VARCHAR2 := NULL,
      p_commit                IN      	  VARCHAR2 := NULL,
      p_validation_level	  IN          NUMBER   := NULL,
      p_customer_trx_id       IN          ra_customer_trx.customer_trx_id%type,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2);


PROCEDURE INCOMPLETE_TRANSACTION(
      p_api_version           IN      	  NUMBER,
      p_init_msg_list         IN      	  VARCHAR2 := NULL,
      p_commit                IN      	  VARCHAR2 := NULL,
      p_validation_level	  IN          NUMBER   := NULL,
      p_customer_trx_id       IN          ra_customer_trx.customer_trx_id%type,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2);

END AR_TRANSACTION_GRP;


 

/
