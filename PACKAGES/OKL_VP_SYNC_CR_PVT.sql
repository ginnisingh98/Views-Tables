--------------------------------------------------------
--  DDL for Package OKL_VP_SYNC_CR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_SYNC_CR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCRSS.pls 120.4 2005/10/11 10:40:47 sjalasut noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_VP_SYNC_CR_PVT';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_agr_header
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_agr_header
  -- Description     : synchronizes the change request header with original
  --                   agreement header. only end date can be extended, comments and
  --                   short description can also be synced between change req and
  --                   original agreement
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_agr_header(p_api_version   IN  NUMBER
                           ,p_init_msg_list IN  VARCHAR2
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER
                           ,x_msg_data      OUT NOCOPY VARCHAR2
                           ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                           ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                           );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_non_primary_parties
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_non_primary_parties
  -- Description     : handles synchronizing non primary parties between the change request
  --                   and original agreement id
  --                   non primary parties are all parties except OKX_VENDOR and OKX_LESSEE
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_non_primary_parties(p_api_version   IN  NUMBER
                                    ,p_init_msg_list IN  VARCHAR2
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    ,x_msg_count     OUT NOCOPY NUMBER
                                    ,x_msg_data      OUT NOCOPY VARCHAR2
                                    ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                    ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                    );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_party_contacts
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_party_contacts
  -- Description     : handles synchrnonization of party contacts, this includes both
  --                   primary and non primary party contacts
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_party_contacts(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                               ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                               );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_article_changes
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_article_changes
  -- Description     : handles synchrnonization of standard and non standard articles
  --                   between the change request and the original agreement
  --                   this api deletes all articles on the original agreement and then
  --                   creates all articles from the change request
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_article_changes(p_api_version   IN  NUMBER
                                ,p_init_msg_list IN  VARCHAR2
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,x_msg_data      OUT NOCOPY VARCHAR2
                                ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                );


  -------------------------------------------------------------------------------
  -- PROCEDURE sync_vendor_billing
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_vendor_billing
  -- Description     : handles synchrnonization of Vendor Billing Information
  --                   between the change request and the original agreement
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : Aug 22, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_vendor_billing(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                               ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_associations
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_associations
  -- Description     : handles synchronization of associations for change request type of
  --                   ASSOCIATION for a program agreement
  --                   in case of ASSOCIATION, new templates are added to the original agreement
  --                   end dates are synched up on the existing records, and any records deleted
  --                   from change request are also deleted from the original agreement
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_associations(p_api_version   IN  NUMBER
                             ,p_init_msg_list IN  VARCHAR2
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_count     OUT NOCOPY NUMBER
                             ,x_msg_data      OUT NOCOPY VARCHAR2
                             ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                             ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                             ,p_change_request_id IN okl_vp_change_requests.id%TYPE
                             );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_agr_associations
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_associations
  -- Description     : handles synchronization of associations for change request type of
  --                   AGREEMENT for a program agreement
  --                   in case of AGREEMENT, new templates are added to the original agreement
  --                   end dates are synched up on the existing records, and any records deleted
  --                   from change request are also deleted from the original agreement
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_agr_associations(p_api_version   IN  NUMBER
                                 ,p_init_msg_list IN  VARCHAR2
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count     OUT NOCOPY NUMBER
                                 ,x_msg_data      OUT NOCOPY VARCHAR2
                                 ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                 ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                 ,p_change_request_id IN okl_vp_change_requests.id%TYPE
                                 );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_elig_criteria
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_elig_criteria
  -- Description     : handles synchronization of eligiility criteria
  --                   the eligibility criteria on the original agreement is deleted
  --                   and re-created from the change request.
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_elig_criteria(p_api_version   IN  NUMBER
                              ,p_init_msg_list IN  VARCHAR2
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_msg_count     OUT NOCOPY NUMBER
                              ,x_msg_data      OUT NOCOPY VARCHAR2
                              ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                              ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                              );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_change_request
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_change_request
  -- Description     : handles creation of change request header for Operating Agreement and Program Agreement
  --                   main synchornization api that calls the following apis in the following order
  --                   a. sync_agr_header
  --                   b. sync_non_primary_parties
  --                   c. sync_party_contacts
  --                   d. sync_article_changes
  --                   e. sync_associations
  --                   f. sync_elig_criteria
  --                   g. sync_terms (for a AGREEMENT type of change request)
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : May 18, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_change_request(p_api_version   IN  NUMBER
                               ,p_init_msg_list IN  VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_change_request_id IN okl_vp_change_requests.id%TYPE);

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_terms
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_terms
  -- Description     : handles synchronization of terms and conditions on the change request agreement
  --                   associated with an AGREEMENT type of change request, onto the originating
  --                   vendor agreement
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : Sep 21, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_terms(p_api_version   IN  NUMBER
                      ,p_init_msg_list IN  VARCHAR2
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_msg_count     OUT NOCOPY NUMBER
                      ,x_msg_data      OUT NOCOPY VARCHAR2
                      ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                      ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                      );

  -------------------------------------------------------------------------------
  -- PROCEDURE sync_vendor_disb_setup
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : sync_vendor_disb_setup
  -- Description     : handles synchronization of program agreement vendor disbursement setup
  -- Parameters      : IN p_orig_chr_id original agreement chr_id
  --                   IN p_creq_chr_id agreement id associated with the change request
  -- Version         : 1.0
  -- History         : Sep 21, 05 sjalasut created
  -- End of comments
  PROCEDURE sync_vendor_disb_setup(p_api_version   IN  NUMBER
                                  ,p_init_msg_list IN  VARCHAR2
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2
                                  ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                  ,p_creq_chr_id   IN okc_k_headers_b.id%TYPE
                                  );

END okl_vp_sync_cr_pvt;

 

/
