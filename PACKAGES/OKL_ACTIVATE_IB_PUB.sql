--------------------------------------------------------
--  DDL for Package OKL_ACTIVATE_IB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACTIVATE_IB_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPAIBS.pls 115.0 2002/03/18 01:04:46 pkm ship       $ */
--subtype definitions
subtype cimv_tbl_type    is  OKL_ACTIVATE_IB_PVT.cimv_tbl_type;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
G_PKG_NAME			  CONSTANT VARCHAR2(200) := 'OKL_ACTIVATE_IB_PUB';
G_APP_NAME			  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_SCOPE               CONSTANT VARCHAR2(4)   := '_PUB';
G_API_VERSION         NUMBER := 1.0;

--------------------------------------------------------------------------------
--Start of Comments
--API Name     : Activate_Ib_Instance
--Description  : API to activate item instances in Install Base for
--               an OKL contract
--Notes       : IN Parameters
--              p_chrv_id - contract header id of the contract being activated
--              p_call_mode - 'BOOK' for booking
--                          - 'REBOOK' for re-booking
--                          -'RELEASE' for re-lease
--                          right now this has no function it is supposed to
--                          take care of branching of logic for different
--                          processes in future
-- End of comments
--------------------------------------------------------------------------------
PROCEDURE   ACTIVATE_IB_INSTANCE(p_api_version   IN  NUMBER,
	                             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                             x_return_status   OUT NOCOPY VARCHAR2,
	                             x_msg_count       OUT NOCOPY NUMBER,
	                             x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chrv_id         IN  NUMBER,
                                 p_call_mode       IN  VARCHAR2,
                                 x_cimv_tbl        OUT NOCOPY cimv_tbl_type);
End OKL_ACTIVATE_IB_PUB;

 

/
