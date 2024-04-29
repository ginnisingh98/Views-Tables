--------------------------------------------------------
--  DDL for Package OKL_ACTIVATE_IB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACTIVATE_IB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAIBS.pls 120.3 2006/05/12 22:29:21 rpillay noship $ */
    -- simple entity object subtype definitions
    subtype iipv_rec_type            is   okl_txl_itm_insts_pub.iipv_rec_type;
    subtype iipv_tbl_type            is   okl_txl_itm_insts_pub.iipv_tbl_type;
    subtype inst_rec_type            is   CSI_DATASTRUCTURES_PUB.instance_rec;
    subtype ext_attrib_tbl_type      is   CSI_DATASTRUCTURES_PUB.extend_attrib_values_tbl;
    subtype trx_rec_type             is   CSI_DATASTRUCTURES_PUB.transaction_rec;
    subtype party_tbl_type           is   CSI_DATASTRUCTURES_PUB.party_tbl;
    subtype party_account_tbl_type   is   CSI_DATASTRUCTURES_PUB.party_account_tbl;
    subtype pricing_attribs_tbl_type is   CSI_DATASTRUCTURES_PUB.pricing_attribs_tbl;
    subtype org_units_tbl_type       is   CSI_DATASTRUCTURES_PUB.organization_units_tbl;
    subtype instance_asset_tbl_type  is   CSI_DATASTRUCTURES_PUB.instance_asset_tbl;
    subtype cimv_rec_type            is   okl_okc_migration_pvt.cimv_rec_type;
    subtype cimv_tbl_type            is   okl_okc_migration_pvt.cimv_tbl_type;

---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			               CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			  CONSTANT VARCHAR2(200) := 'OKL_ACTIVATE_IB_PVT';
  G_APP_NAME			  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE qc;
  PROCEDURE api_copy;
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
Procedure ACTIVATE_IB_INSTANCE(p_api_version   IN  NUMBER,
	                             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                             x_return_status   OUT NOCOPY VARCHAR2,
	                             x_msg_count       OUT NOCOPY NUMBER,
	                             x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chrv_id         IN  NUMBER,
                                 p_call_mode       IN  VARCHAR2,
                                 x_cimv_tbl        OUT NOCOPY cimv_tbl_type);
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : ACTIVATE_RBK_IB_INST
  --Purpose               : Calls IB API to create an item instance in IB
  --                        Selects ib instance to create given a top line
  --                        for a new line created during rebook
  --Modification History  :
  --01-May-2002    avsingh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
Procedure ACTIVATE_RBK_IB_INST(p_api_version         IN  NUMBER,
	                           p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                           x_return_status       OUT NOCOPY VARCHAR2,
	                           x_msg_count           OUT NOCOPY NUMBER,
	                           x_msg_data            OUT NOCOPY VARCHAR2,
                               p_fin_ast_cle_id      IN  NUMBER,
                               x_cimv_tbl            OUT NOCOPY cimv_tbl_type);
--Bug# 3533936
------------------------------------------------------------------------------
  --Start of comments
  --
  --API Name              : RELEASE_IB_INSTANCE
  --Purpose               : Calls IB API to modify item instance in IB
  --                        during re-lease asset
  --Modification History  :
  --05-APR-2004    avsingh  Created
  --Notes :  Assigns values to transaction_type_id and source_line_ref_id
  --End of Comments
------------------------------------------------------------------------------
PROCEDURE RELEASE_IB_INSTANCE
                        (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER
                        );

--Bug# 5207066
PROCEDURE RBK_SRL_NUM_IB_INSTANCE
                        (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rbk_fin_ast_cle_id IN NUMBER,
                         p_rbk_chr_id    IN  NUMBER
                        );

End OKL_ACTIVATE_IB_PVT;

/
