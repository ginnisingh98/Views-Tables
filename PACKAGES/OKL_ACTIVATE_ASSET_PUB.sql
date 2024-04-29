--------------------------------------------------------
--  DDL for Package OKL_ACTIVATE_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACTIVATE_ASSET_PUB" AUTHID CURRENT_USER As
/* $Header: OKLPACAS.pls 115.3 2002/06/12 12:42:44 pkm ship       $ */
SUBTYPE cimv_rec_type is  OKL_ACTIVATE_ASSET_PVT.cimv_rec_type;
SUBTYPE cimv_tbl_type is  OKL_ACTIVATE_ASSET_PVT.cimv_tbl_type;
G_APP_NAME     CONSTANT VARCHAR2(200) := OKL_API.G_APP_NAME;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : ACTIVATE_ASSET
--Description    : Selects the 'CFA' - Create Asset Transaction from a ready to be
--                 Booked Contract which has passed Approval
--                 and created assets in FA
--
--History        :
--                 03-Nov-2001  avsingh Created
-- Notes         :
--      IN Parameters -
--                     p_chr_id    - contract id to be activated
--                     p_call_mode - 'BOOK' for booking
--                                   'REBOOK' for rebooking
--                                   'RELEASE' for release
--                    x_cimv_tbl   - OKC line source table showing
--                                   fa links in ID1 , ID2 columns
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE  ACTIVATE_ASSET(p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chrv_id       IN  NUMBER,
                          p_call_mode     IN  VARCHAR2,
                          x_cimv_tbl      OUT NOCOPY cimv_tbl_type);

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  REBOOK_ASSET (Activate code branch for rebook)
--Description    :  Will be called from activate asset and make rebook adjustments
--                  in FA
--History        :
--                 21-Mar-2002  ashish.singh Created
-- Notes         :
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook copied contract
--
--                     This APi should be called after syncronization of copied k
--                     to the original (being re-booked ) K
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE REBOOK_ASSET  (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rbk_chr_id    IN  NUMBER);

PROCEDURE RELEASE_ASSET (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER);
END OKL_ACTIVATE_ASSET_PUB;

 

/
