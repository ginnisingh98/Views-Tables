--------------------------------------------------------
--  DDL for Package OKL_ACCOUNTING_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNTING_PROCESS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPAECS.pls 120.5 2008/02/29 10:48:02 asawanka ship $ */


G_PKG_NAME              CONSTANT VARCHAR2(200) := 'OKL_ACCOUNTING_PROCESS_PUB';
G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

PROCEDURE DO_ACCOUNTING_CON(p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            p_start_date          IN   DATE,
                            p_end_date            IN   DATE,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            x_request_id          OUT NOCOPY  NUMBER);


END OKL_ACCOUNTING_PROCESS_PUB;


/
