--------------------------------------------------------
--  DDL for Package IEX_CREDIT_HOLD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CREDIT_HOLD_API" AUTHID CURRENT_USER AS
/* $Header: iexvcdhs.pls 120.0 2005/07/05 16:15:03 appldev noship $ */


PROCEDURE UPDATE_CREDIT_HOLD
      (p_api_version      IN  NUMBER := 1.0,
       p_init_msg_list    IN  VARCHAR2 ,
       p_commit           IN  VARCHAR2 ,
       p_account_id       IN  NUMBER,
       p_site_id          IN  NUMBER,
       p_credit_hold      IN  VARCHAR2,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2);


END;

 

/
