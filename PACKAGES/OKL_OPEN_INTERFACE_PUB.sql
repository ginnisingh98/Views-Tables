--------------------------------------------------------
--  DDL for Package OKL_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPEN_INTERFACE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPOPIS.pls 115.5 2002/11/30 08:37:22 spillaip noship $ */

subtype oinv_rec_type is okl_oin_pvt.oinv_rec_type;
subtype iohv_rec_type is iex_ioh_pvt.iohv_rec_type;

---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_OPEN_INTERFACE_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

---------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
---------------------------------------------------------------------------

PROCEDURE insert_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id              IN NUMBER,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

/*
PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER);
*/

PROCEDURE process_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


END okl_open_interface_pub;

 

/
