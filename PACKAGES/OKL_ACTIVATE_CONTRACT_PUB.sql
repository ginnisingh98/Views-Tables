--------------------------------------------------------
--  DDL for Package OKL_ACTIVATE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACTIVATE_CONTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPACOS.pls 115.0 2002/03/18 01:04:25 pkm ship       $ */
--------------------------------------------------------------------------------
--Api Name     : Activate Contract
--Description  : Will call the FA Activation and IB Activation public apis
--               Will be called from the activate button on the booking screen
--Notes        :
--               IN Parameters -
--      IN Parameters -
--                     p_chr_id    - contract id to be activated
--                     p_call_mode - 'BOOK' for booking
--                                   'REBOOK' for rebooking
--                                   'RELEASE' for release
--End of Comments
--------------------------------------------------------------------------------
G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_ACTIVATE_CONTRACT_PUB';
G_APP_NAME   CONSTANT VARCHAR2(200) := OKL_API.G_APP_NAME;
Procedure ACTIVATE_CONTRACT(p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_chrv_id       IN  NUMBER,
                            p_call_mode     IN  VARCHAR2);
END OKL_ACTIVATE_CONTRACT_PUB;

 

/
