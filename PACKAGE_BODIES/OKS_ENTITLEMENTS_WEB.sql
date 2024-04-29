--------------------------------------------------------
--  DDL for Package Body OKS_ENTITLEMENTS_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENTITLEMENTS_WEB" AS
/* $Header: OKSJENWB.pls 120.19.12000000.2 2007/07/30 11:54:45 cgopinee ship $ */
---------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: simple_srch_rslts
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Simple Search JSP.
  ||     This procedure is used to retrieve contracts for default search criteria.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_party_id     -- Contract Party ID on which to search.
  ||     p_account_id            -- Account ID on which to search.
  ||
  || Out Parameters:
  ||     x_return_status  -- Success of the procedure.
  ||     x_msg_count      -- Error message count
  ||     x_msg_data       -- Error message
  ||     x_contract_tbl   -- Search results contract table
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE simple_srch_rslts(
    p_contract_party_id     IN  NUMBER,
    p_account_id            IN  VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_contract_tbl          OUT NOCOPY OKS_ENTITLEMENTS_WEB.output_tbl_contract
  )
  IS
    l_api_version    NUMBER := 1;
    l_init_msg_list  VARCHAR2(10) := 'T';
    l_contract_rec   OKS_ENTITLEMENTS_PUB.inp_cont_rec_type;
    l_clvl_id_tbl    OKS_ENTITLEMENTS_PUB.covlvl_id_tbl;
    l_contract_tbl   OKS_ENTITLEMENTS_PUB.output_tbl_contract;

    BEGIN
      x_return_status := G_RET_STS_SUCCESS;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.simple_srch_rslts',
                        'Input Params to simple_srch ' || ' ' ||
                        'p_contract_party_id: ' || p_contract_party_id || ' ' ||
                        'p_account_id : ' || p_account_id);
      END IF;

      -- Bug Fix #4749190. Account id will be passed as null when the user has the permission OKS_AUTHORED_CONTRACT_VIEW
      --                   , which shows all the conracts belongs to the party.

      IF p_account_id IS NOT NULL THEN
         l_clvl_id_tbl(1).covlvl_id := to_number(p_account_id);
         l_clvl_id_tbl(1).covlvl_code := 'OKX_CUSTACCT';
      END IF;

      l_contract_rec.contract_party_id := p_contract_party_id;
      l_contract_rec.request_date := SYSDATE;
      l_contract_rec.entitlement_check_YN := 'Y';

      OKS_ENTITLEMENTS_PUB.Search_Contracts(
        l_api_version,
        l_init_msg_list,
        l_contract_rec,
        l_clvl_id_tbl,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_contract_tbl
      );
      FOR j in 1..l_contract_tbl.COUNT
      LOOP
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.simple_srch_rslts',
                          'Contract Number : ' || l_contract_tbl(j).contract_number || l_contract_tbl(j).contract_number_modifier);
        END IF;
        x_contract_tbl(j).contract_number           := l_contract_tbl(j).contract_number;
        x_contract_tbl(j).contract_number_modifier  := l_contract_tbl(j).contract_number_modifier;
        x_contract_tbl(j).contract_category         := l_contract_tbl(j).contract_category;
        x_contract_tbl(j).contract_status_code      := l_contract_tbl(j).contract_status_code;
        x_contract_tbl(j).contract_category_meaning := l_contract_tbl(j).HD_cat_meaning;
        x_contract_tbl(j).contract_status_meaning   := l_contract_tbl(j).HD_sts_meaning;
        x_contract_tbl(j).known_as                  := l_contract_tbl(j).known_as;
        x_contract_tbl(j).short_description         := l_contract_tbl(j).short_description;
        x_contract_tbl(j).start_date                := l_contract_tbl(j).start_date;
        x_contract_tbl(j).end_date                  := l_contract_tbl(j).end_date;
        x_contract_tbl(j).date_terminated           := l_contract_tbl(j).date_terminated;
        x_contract_tbl(j).contract_amount           := l_contract_tbl(j).contract_amount;
        x_contract_tbl(j).amount_code               := l_contract_tbl(j).currency_code;
      END LOOP;

    EXCEPTION
      WHEN OTHERS
        THEN
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.simple_srch_rslts',
                          'Error occured ' || SQLerrm);
        END IF;
        OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END simple_srch_rslts;
----------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: cntrct_srch_rslts
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve contracts for given search criteria.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_number       -- Contract Number on which to search.
  ||     p_contract_status_code  -- Contract Status on which to search.
  ||     p_start_date_from       -- Contract Start Date From on which to search.
  ||     p_start_date_to         -- Contract Start Date End on which to search.
  ||     p_end_date_from         -- Contract End Date From on which to search.
  ||     p_end_date_to           -- Contract End Date End on which to search.
  ||     p_date_terminated_from  -- Contract Terminated Date From on which to search.
  ||     p_date_terminated_to    -- Contract Terminated Date End on which to search.
  ||     p_contract_party_id     -- Contract Party ID on which to search.
  ||     p_covlvl_site_id        -- Covered Level Site ID on which to search.
  ||     p_covlvl_site_name      -- Covered Level Site Name on which to search.
  ||     p_covlvl_system_id      -- Covered Level System ID on which to search.
  ||     p_covlvl_system_name    -- Covered Level System Name on which to search.
  ||     p_covlvl_product_id     -- Covered Level Product ID on which to search.
  ||     p_covlvl_product_name   -- Covered Level Product Name on which to search.
  ||     p_covlvl_system_id      -- Covered Level System ID on which to search.
  ||     p_covlvl_system_name    -- Covered Level System Name on which to search.
  ||     p_entitlement_check_YN  -- Flag to searh for Entitlement Contracts.
  ||     p_account_check_all     -- Flag tosearch for all accounts.
  ||     p_account_id            -- Account ID on which to search.
  ||     p_covlvl_party_id       -- Covered Level Party ID on which to search.
  ||     p_account_all_id        -- List of account ID's to search for all accounts.
  ||     p_covlvl_party_id       -- Party ID of the covered level.
  ||     p_account_all_id        -- Table of accounts if all the accounts are to be searched.
  ||
  || Out Parameters:
  ||     x_return_status  -- Success of the procedure.
  ||     x_msg_count      -- Error message count
  ||     x_msg_data       -- Error message
  ||     x_contract_tbl   -- Search results contract table
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE cntrct_srch_rslts(
    p_contract_number       IN  VARCHAR2,
    p_contract_status_code  IN  VARCHAR2,
    p_start_date_from       IN  DATE,
    p_start_date_to         IN  DATE,
    p_end_date_from         IN  DATE,
    p_end_date_to           IN  DATE,
    p_date_terminated_from  IN  DATE,
    p_date_terminated_to    IN  DATE,
    p_contract_party_id     IN  NUMBER,
    p_covlvl_site_id        IN  NUMBER,
    p_covlvl_site_name      IN  VARCHAR2,
    p_covlvl_system_id      IN  NUMBER,
    p_covlvl_system_name    IN  VARCHAR2,
    p_covlvl_product_id     IN  NUMBER,
    p_covlvl_product_name   IN  VARCHAR2,
    p_covlvl_item_id        IN  NUMBER,
    p_covlvl_item_name      IN  VARCHAR2,
    p_entitlement_check_YN  IN  VARCHAR2,
    p_account_check_all     IN  VARCHAR2,
    p_account_id            IN  VARCHAR2,
    p_covlvl_party_id       IN  VARCHAR2,
    p_account_all_id        IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_contract_tbl          OUT NOCOPY OKS_ENTITLEMENTS_WEB.output_tbl_contract
  )
  IS
    CURSOR party_sites_cur(p_party_id VARCHAR2, p_site_name VARCHAR2)
    IS
SELECT  PSE.PARTY_SITE_ID ID1
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_V hdr1,
     okc_k_items itm,
     HZ_PARTY_SITES PSE,
     HZ_LOCATIONS LCN
WHERE rle.jtot_object1_code ='OKX_PARTY'
      and rle.object1_id1   =to_number(p_party_id)
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.chr_id= hdr1.id
      and rle.dnz_chr_id= hdr1.id
      and itm.jtot_object1_code = 'OKX_PARTYSITE'
      and itm.dnz_chr_id = rle.chr_id
      and PSE.PARTY_SITE_ID = itm.object1_id1
      and LCN.LOCATION_ID = PSE.LOCATION_ID
      and LCN.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
      and PSE.PARTY_SITE_NAME=p_site_name;

    CURSOR party_items_cur(p_party_id VARCHAR2, p_item_name VARCHAR2)
    IS
SELECT B.INVENTORY_ITEM_ID ID1
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_V hdr1,
     okc_k_items itm,
     MTL_SYSTEM_ITEMS_B_KFV B,
     MTL_SYSTEM_ITEMS_TL T
WHERE     rle.jtot_object1_code='OKX_PARTY'
      and rle.object1_id1   =to_number(p_party_id)
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.chr_id=hdr1.id
      and rle.dnz_chr_id=hdr1.id
      and itm.dnz_chr_id = rle.chr_id
      and itm.jtot_object1_code = 'OKX_COVITEM'
      and B.INVENTORY_ITEM_ID = itm.object1_id1
      and B.ORGANIZATION_ID = itm.object1_id2
      and B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
      and B.ORGANIZATION_ID = T.ORGANIZATION_ID
      and T.LANGUAGE = userenv('LANG')
      and T.DESCRIPTION=p_item_name;

    CURSOR party_systems_cur(p_party_id VARCHAR2, p_system_name VARCHAR2)
    IS
SELECT B.SYSTEM_ID ID1
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_V hdr1,
     okc_k_items itm,
     CS_SYSTEMS_ALL_B B,
     CS_SYSTEMS_ALL_TL T
WHERE rle.jtot_object1_code='OKX_PARTY'
      and rle.object1_id1   =to_number(p_party_id)
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.chr_id=hdr1.id
      and rle.dnz_chr_id=hdr1.id
      and itm.jtot_object1_code = 'OKX_COVSYST'
      and itm.dnz_chr_id = rle.chr_id
      and B.SYSTEM_ID = itm.object1_id1
      and B.SYSTEM_ID = T.SYSTEM_ID
      and T.LANGUAGE = userenv('LANG')
      and T.NAME=p_system_name;

    CURSOR party_products_cur(p_party_id VARCHAR2, p_product_name VARCHAR2)
    IS
SELECT CP.INSTANCE_ID ID1
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_B hdr1,
     okc_k_items itm,
     CSI_ITEM_INSTANCES CP,
     MTL_SYSTEM_ITEMS_B_KFV BK
WHERE rle.jtot_object1_code = 'OKX_PARTY'
      and rle.object1_id1   = p_party_id
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.dnz_chr_id = hdr1.id
      and itm.dnz_chr_id = rle.chr_id
      and itm.jtot_object1_code = 'OKX_CUSTPROD'
      and CP.instance_id = itm.object1_id1
      and BK.INVENTORY_ITEM_ID = CP.INVENTORY_ITEM_ID
      and BK.ORGANIZATION_ID   = CP.inv_master_organization_id
      and BK.DESCRIPTION=p_product_name;

    l_api_version    NUMBER := 1;
    l_init_msg_list  VARCHAR2(10) := 'T';
    l_contract_rec   OKS_ENTITLEMENTS_PUB.inp_cont_rec_type;
    l_clvl_id_tbl    OKS_ENTITLEMENTS_PUB.covlvl_id_tbl;
    l_contract_tbl   OKS_ENTITLEMENTS_PUB.output_tbl_contract;
    l_clvl_tbl_indx  NUMBER :=1;

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.cntrct_srch_rslts',
                          'p_contract_number :' || p_contract_number || ' ' ||
                          'p_contract_status_code: ' || p_contract_status_code  || ' '||
                          'p_start_date_from : ' || p_start_date_from || ' ' ||
                          'p_start_date_to :' || p_start_date_to || ' ' ||
                          'p_end_date_from :' || p_end_date_from || ' ' ||
                          'p_end_date_to :'   || p_end_date_to   || ' ' ||
                          'p_date_terminated_from :' || p_date_terminated_from || ' ' ||
                          'p_date_terminated_to : '  || p_date_terminated_to   || ' ' ||
                          'p_contract_party_id : ' || p_contract_party_id ||  ' ' ||
                          'p_covlvl_site_id: ' || p_covlvl_site_id || ' ' ||
                          'p_covlvl_site_name :' || p_covlvl_site_name || ' '||
                          'p_covlvl_system_id :' || p_covlvl_system_id || ' '||
                          'p_covlvl_system_name: ' || p_covlvl_system_name || ' ' ||
                          'p_covlvl_product_id : ' || p_covlvl_product_id || ' ' ||
                          'p_covlvl_product_name : ' || p_covlvl_product_name || ' ' ||
                          'p_covlvl_item_id : ' || p_covlvl_item_id || ' ' ||
                          'p_covlvl_item_name :' || p_covlvl_item_name || ' ' ||
                          'p_entitlement_check_YN :' || p_entitlement_check_YN || ' ' ||
                          'p_account_check_all : ' || p_account_check_all ||  ' ' ||
                          'p_account_id :' || p_account_id || ' ' ||
                          'p_covlvl_party_id : ' || p_covlvl_party_id);
        END IF;
      x_return_status := G_RET_STS_SUCCESS;
/**
      IF p_covlvl_site_name IS NOT NULL
      THEN
        IF p_covlvl_site_id IS NULL
        THEN
          OPEN  party_sites_cur(p_contract_party_id, p_covlvl_site_name);
          FETCH party_sites_cur
          INTO
            l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id;
          CLOSE  party_sites_cur;
        ELSE
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_covlvl_site_id;
        END IF;
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_PARTYSITE';
        l_clvl_tbl_indx := l_clvl_tbl_indx+1;
      END IF;
**/

        IF p_covlvl_site_id IS NOT NULL
        THEN
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_covlvl_site_id;
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_PARTYSITE';
          l_clvl_tbl_indx := l_clvl_tbl_indx+1;
        END IF;

      IF p_covlvl_system_name IS NOT NULL
      THEN
        IF p_covlvl_system_id IS NULL
        THEN
            OPEN  party_systems_cur(p_contract_party_id, p_covlvl_system_name);
            FETCH party_systems_cur
            INTO
              l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id;
            CLOSE  party_systems_cur;
        ELSE
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_covlvl_system_id;
        END IF;
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_COVSYST';
        l_clvl_tbl_indx := l_clvl_tbl_indx+1;
      END IF;

      IF p_covlvl_product_name IS NOT NULL
      THEN
        IF p_covlvl_product_id IS NULL
        THEN
            OPEN  party_products_cur(p_contract_party_id, p_covlvl_product_name);
            FETCH party_products_cur
            INTO
              l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id;
            CLOSE  party_products_cur;
        ELSE
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_covlvl_product_id;
        END IF;
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_CUSTPROD';
        l_clvl_tbl_indx := l_clvl_tbl_indx+1;
      END IF;

      IF p_covlvl_item_name IS NOT NULL
      THEN
        IF p_covlvl_item_id IS NULL
        THEN
          OPEN  party_items_cur(p_contract_party_id, p_covlvl_item_name);
          FETCH party_items_cur
          INTO
            l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id;
          CLOSE  party_items_cur;
        ELSE
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_covlvl_item_id;
        END IF;
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_COVITEM';
        l_clvl_tbl_indx := l_clvl_tbl_indx+1;
      END IF;

      IF p_covlvl_party_id IS NOT NULL
      THEN
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := to_number(p_covlvl_party_id);
        l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_PARTY';
        l_clvl_tbl_indx := l_clvl_tbl_indx+1;
      END IF;

      IF p_account_check_all='ALL'
      THEN
        FOR i in 1..p_account_all_id.COUNT
        LOOP
          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.cntrct_srch_rslts',
                            'p_account_all_id(i).ID IS : ' || p_account_all_id(i).ID);
          END IF;
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := p_account_all_id(i).ID;
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_CUSTACCT';
          l_clvl_tbl_indx := l_clvl_tbl_indx+1;
        END LOOP;
      ELSE
        IF p_account_id IS NOT NULL
        THEN
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_id := to_number(p_account_id);
          l_clvl_id_tbl(l_clvl_tbl_indx).covlvl_code := 'OKX_CUSTACCT';
          l_clvl_tbl_indx := l_clvl_tbl_indx+1;
        END IF;
      END IF;

      l_contract_rec.contract_number := p_contract_number;
      l_contract_rec.contract_status_code := p_contract_status_code;
      l_contract_rec.start_date_from := p_start_date_from;
      l_contract_rec.start_date_to := p_start_date_to;
      l_contract_rec.end_date_from := p_end_date_from;
      l_contract_rec.end_date_to := p_end_date_to;
      l_contract_rec.date_terminated_from := p_date_terminated_from;
      l_contract_rec.date_terminated_to := p_date_terminated_to;
      l_contract_rec.contract_party_id := p_contract_party_id;
      l_contract_rec.request_date := SYSDATE;
      l_contract_rec.entitlement_check_YN := p_entitlement_check_YN;

      OKS_ENTITLEMENTS_PUB.Search_Contracts(
        l_api_version,
        l_init_msg_list,
        l_contract_rec,
        l_clvl_id_tbl,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_contract_tbl
      );

      FOR j in 1..l_contract_tbl.COUNT
      LOOP
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.cntrct_srch_rslts',
                          'Contract Number ' || l_contract_tbl(j).contract_number || l_contract_tbl(j).contract_number_modifier);
        END IF;

        x_contract_tbl(j).contract_number           := l_contract_tbl(j).contract_number;
        x_contract_tbl(j).contract_number_modifier  := l_contract_tbl(j).contract_number_modifier;
        x_contract_tbl(j).contract_category         := l_contract_tbl(j).contract_category;
        x_contract_tbl(j).contract_status_code      := l_contract_tbl(j).contract_status_code;
        x_contract_tbl(j).contract_category_meaning := l_contract_tbl(j).HD_cat_meaning;
        x_contract_tbl(j).contract_status_meaning   := l_contract_tbl(j).HD_sts_meaning;
        x_contract_tbl(j).known_as                  := l_contract_tbl(j).known_as;
        x_contract_tbl(j).short_description         := l_contract_tbl(j).short_description;
        x_contract_tbl(j).start_date                := l_contract_tbl(j).start_date;
        x_contract_tbl(j).end_date                  := l_contract_tbl(j).end_date;
        x_contract_tbl(j).date_terminated           := l_contract_tbl(j).date_terminated;
        x_contract_tbl(j).contract_amount           := l_contract_tbl(j).contract_amount;
        x_contract_tbl(j).amount_code               := l_contract_tbl(j).currency_code;
      END LOOP;

    EXCEPTION
      WHEN OTHERS
        THEN
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.cntrct_srch_rslts',
                          'Exception occured : ' || SQLerrm);
        END IF;
        OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END cntrct_srch_rslts;
----------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_sites
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Sites for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Sites are to retrieved.
  ||     p_site_name_arg  -- Partial or full Name of the Party Site.
  ||
  || Out Parameters:
  ||     x_return_status        -- Success of the procedure.
  ||     x_party_sites_tbl_type -- Table whcih returns all the Party Sites
  ||                               and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_sites(
    p_party_id_arg         IN  VARCHAR2,
    p_site_name_arg        IN  VARCHAR2,
    x_return_status	       OUT NOCOPY VARCHAR2,
    x_party_sites_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_sites_tbl_type
  )
  IS
    CURSOR party_sites_cur(p_party_id VARCHAR2, p_site_name VARCHAR2)
    IS
      SELECT  DISTINCT
              PSE.PARTY_SITE_ID ID1,
              '#' ID2,
              PSE.PARTY_SITE_NAME NAME,
              SUBSTR(arp_addr_label_pkg.format_address(NULL,LCN.ADDRESS1,LCN.ADDRESS2,LCN.ADDRESS3,LCN.ADDRESS4,
		    LCN.CITY,LCN.COUNTY,LCN.STATE,LCN.PROVINCE,LCN.POSTAL_CODE,NULL,LCN.COUNTRY,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N','N',80,1,1),1,80) DESCRIPTION
      FROM OKC_K_PARTY_ROLES_B rle,
           OKC_K_HEADERS_ALL_V hdr1,
           okc_k_items itm,
           HZ_PARTY_SITES PSE,
           HZ_LOCATIONS LCN
     WHERE rle.jtot_object1_code = 'OKX_PARTY'
       and rle.object1_id1 = to_number(p_party_id)
       and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
       AND RLE.CLE_ID IS NULL
       and rle.chr_id= hdr1.id
       and rle.dnz_chr_id= hdr1.id
       and itm.jtot_object1_code = 'OKX_PARTYSITE'
       and itm.dnz_chr_id = rle.chr_id
       and PSE.PARTY_SITE_ID = itm.object1_id1
       and LCN.LOCATION_ID = PSE.LOCATION_ID
       and LCN.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
       and (PSE.PARTY_SITE_NAME like p_site_name or PSE.PARTY_SITE_NAME is NULL);

    l_party_sites_tbl_type  OKS_ENTITLEMENTS_WEB.party_sites_tbl_type;
    l_party_sites_tbl_indx  NUMBER :=1;

    BEGIN
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_sites',
                          'Inside Party Sites: ' ||  ' ' ||
                          'p_party_id_arg :'  || p_party_id_arg  || ' ' ||
                          'p_site_name_arg :' || p_site_name_arg );

    END IF;
      x_return_status := G_RET_STS_SUCCESS;
        FOR k IN party_sites_cur(p_party_id_arg, p_site_name_arg)
        LOOP
          l_party_sites_tbl_type(l_party_sites_tbl_indx).ID1         := k.id1;
          l_party_sites_tbl_type(l_party_sites_tbl_indx).ID2         := k.id2;
          l_party_sites_tbl_type(l_party_sites_tbl_indx).NAME        := k.name;
          l_party_sites_tbl_type(l_party_sites_tbl_indx).DESCRIPTION := k.description;
          l_party_sites_tbl_indx := l_party_sites_tbl_indx +1;
        END LOOP;

      x_party_sites_tbl_type := l_party_sites_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_sites;
----------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_items
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Items.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Sites are to retrieved.
  ||     p_item_name_arg  -- Partial or full Name of the Party Item.
  ||
  || Out Parameters:
  ||     x_return_status        -- Success of the procedure.
  ||     x_party_items_tbl_type -- Table which returns all the Party items
  ||                               and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_items(
    p_party_id_arg         IN  VARCHAR2,
    p_item_name_arg        IN  VARCHAR2,
    x_return_status	       OUT NOCOPY VARCHAR2,
    x_party_items_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_items_tbl_type
  )
  IS
    CURSOR party_items_cur(p_party_id VARCHAR2, p_item_name VARCHAR2)
    IS
SELECT DISTINCT
       B.INVENTORY_ITEM_ID ID1,
       B.ORGANIZATION_ID ID2,
       T.DESCRIPTION NAME,
       B.CONCATENATED_SEGMENTS DESCRIPTION
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_V hdr1,
     okc_k_items itm,
     MTL_SYSTEM_ITEMS_B_KFV B,
     MTL_SYSTEM_ITEMS_TL T
WHERE     rle.jtot_object1_code='OKX_PARTY'
      and rle.object1_id1   =to_number(p_party_id)
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.chr_id=hdr1.id
      and rle.dnz_chr_id=hdr1.id
      and itm.dnz_chr_id = rle.chr_id
      and itm.jtot_object1_code = 'OKX_COVITEM'
      and B.INVENTORY_ITEM_ID = itm.object1_id1
      and B.ORGANIZATION_ID = itm.object1_id2
      and B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
      and B.ORGANIZATION_ID = T.ORGANIZATION_ID
      and T.LANGUAGE = userenv('LANG')
      and T.DESCRIPTION like p_item_name;

    l_party_items_tbl_type  OKS_ENTITLEMENTS_WEB.party_items_tbl_type;
    l_party_items_tbl_indx  NUMBER :=1;

    BEGIN
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_items',
                          'Inside Party Items: ' ||  ' ' ||
                          'p_party_id_arg :'  || p_party_id_arg  || ' ' ||
                          'p_item_name_arg :' || p_item_name_arg );

        END IF;

        x_return_status := G_RET_STS_SUCCESS;
        FOR k IN party_items_cur(p_party_id_arg, p_item_name_arg)
        LOOP
          l_party_items_tbl_type(l_party_items_tbl_indx).ID1         := k.id1;
          l_party_items_tbl_type(l_party_items_tbl_indx).ID2         := k.id2;
          l_party_items_tbl_type(l_party_items_tbl_indx).NAME        := k.name;
          l_party_items_tbl_type(l_party_items_tbl_indx).DESCRIPTION := k.description;
          l_party_items_tbl_indx := l_party_items_tbl_indx +1;
        END LOOP;
      x_party_items_tbl_type := l_party_items_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_items;
-----------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_systems
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Systems for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Sites are to retrieved.
  ||     p_account_id_all   -- AccountID's for all the Systems to retrieved.
  ||     p_system_name_arg  -- Partial or full Name of the Party System.
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_party_systems_tbl_type -- Table which returns all the Party items
  ||                                 and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_systems(
    p_party_id_arg           IN  VARCHAR2,
    p_account_id_all         IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    p_system_name_arg        IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_party_systems_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_systems_tbl_type
  )
  IS
    CURSOR party_systems_cur(p_party_id VARCHAR2, p_system_name VARCHAR2)
    IS
SELECT DISTINCT
       B.SYSTEM_ID ID1,
       '#' ID2,
       T.NAME NAME,
       T.DESCRIPTION DESCRIPTION
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_V hdr1,
     okc_k_items itm,
     CS_SYSTEMS_ALL_B B,
     CS_SYSTEMS_ALL_TL T
WHERE rle.jtot_object1_code='OKX_PARTY'
      and rle.object1_id1   =to_number(p_party_id)
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.chr_id=hdr1.id
      and rle.dnz_chr_id=hdr1.id
      and itm.jtot_object1_code = 'OKX_COVSYST'
      and itm.dnz_chr_id = rle.chr_id
      and B.SYSTEM_ID = itm.object1_id1
      and B.SYSTEM_ID = T.SYSTEM_ID
      and T.LANGUAGE = userenv('LANG')
      AND T.NAME like p_system_name;

    l_party_systems_tbl_type  OKS_ENTITLEMENTS_WEB.party_systems_tbl_type;
    l_party_systems_tbl_indx  NUMBER :=1;
    l_account_tbl_indx  NUMBER :=1;

    BEGIN
          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_systems',
                          'Inside party_systems: ' ||  ' ' ||
                          'p_party_id_arg :'  || p_party_id_arg  || ' ' ||
                          'p_system_name_arg :' || p_system_name_arg );

          END IF;
          x_return_status := G_RET_STS_SUCCESS;
          FOR k IN party_systems_cur(p_party_id_arg, p_system_name_arg)
          LOOP
            l_party_systems_tbl_type(l_party_systems_tbl_indx).ID1         := k.id1;
            l_party_systems_tbl_type(l_party_systems_tbl_indx).ID2         := k.id2;
            l_party_systems_tbl_type(l_party_systems_tbl_indx).NAME        := k.name;
            l_party_systems_tbl_type(l_party_systems_tbl_indx).DESCRIPTION := k.description;
            l_party_systems_tbl_indx := l_party_systems_tbl_indx +1;
          END LOOP;
      x_party_systems_tbl_type := l_party_systems_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_systems;
------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_products
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Party Products for a given party.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg   -- PartyID for which the Sites are to retrieved.
  ||     p_account_id_all    -- AccountID's for all the Products to be retrieved.
  ||     p_product_name_arg  -- Partial or full Name of the Party Product.
  ||
  || Out Parameters:
  ||     x_return_status           -- Success of the procedure.
  ||     x_party_products_tbl_type -- Table which returns all the Party Products
  ||                                  and their information.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_products(
    p_party_id_arg            IN  VARCHAR2,
    p_account_id_all          IN  OKS_ENTITLEMENTS_WEB.account_all_id_tbl_type,
    p_product_name_arg        IN  VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_party_products_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_products_tbl_type
  )
  IS
    CURSOR party_products_cur(p_party_id VARCHAR2, p_product_name VARCHAR2)
    IS
SELECT DISTINCT
       CP.INSTANCE_ID ID1,
       '#' ID2,
       BK.DESCRIPTION NAME,
       BK.CONCATENATED_SEGMENTS || '-' || CP.instance_number DESCRIPTION
FROM OKC_K_PARTY_ROLES_B rle,
     OKC_K_HEADERS_ALL_B hdr1,
     OKC_K_ITEMS itm,
     CSI_ITEM_INSTANCES CP,
     MTL_SYSTEM_ITEMS_B_KFV BK
WHERE rle.jtot_object1_code = 'OKX_PARTY'
      and rle.object1_id1   =  p_party_id
      and rle.rle_code in ('CUSTOMER', 'SUBSCRIBER')
      AND RLE.CLE_ID IS NULL
      and rle.dnz_chr_id = hdr1.id
      and itm.dnz_chr_id = rle.chr_id
      and itm.jtot_object1_code = 'OKX_CUSTPROD'
      and CP.instance_id = itm.object1_id1
      and BK.INVENTORY_ITEM_ID = CP.INVENTORY_ITEM_ID
      and BK.ORGANIZATION_ID = CP.inv_master_organization_id
      AND BK.DESCRIPTION like p_product_name;

    l_party_products_tbl_type  OKS_ENTITLEMENTS_WEB.party_products_tbl_type;
    l_party_products_tbl_indx  NUMBER :=1;
    l_account_tbl_indx  NUMBER :=1;

    BEGIN
          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_products',
                          'Inside party_products: ' ||  ' ' ||
                          'p_party_id_arg :'  || p_party_id_arg  || ' ' ||
                          'p_product_name_arg :' || p_product_name_arg );

          END IF;
          x_return_status := G_RET_STS_SUCCESS;
          FOR k IN party_products_cur(p_party_id_arg, p_product_name_arg)
          LOOP
            l_party_products_tbl_type(l_party_products_tbl_indx).ID1         := k.id1;
            l_party_products_tbl_type(l_party_products_tbl_indx).ID2         := k.id2;
            l_party_products_tbl_type(l_party_products_tbl_indx).NAME        := k.name;
            l_party_products_tbl_type(l_party_products_tbl_indx).DESCRIPTION := k.description;
            l_party_products_tbl_indx := l_party_products_tbl_indx +1;
          END LOOP;
      x_party_products_tbl_type := l_party_products_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_products;
---------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: adv_search_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Search JSP.
  ||     This procedure is used to retrieve the Contract Categories and Statuses.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_party_id_arg  -- User Party ID.
  ||
  || Out Parameters:
  ||     x_return_status            -- Success of the procedure.
  ||     x_party_name               -- User Party Name.
  ||     x_contract_cat_tbl_type    -- Table which returns all the Contract Categories.
  ||     x_contract_status_tbl_type -- Table which returns all the Contract Statuses.
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE adv_search_overview(
    p_party_id_arg             IN  VARCHAR2,
    x_return_status	           OUT NOCOPY VARCHAR2,
    x_party_name               OUT NOCOPY VARCHAR2,
    x_contract_cat_tbl_type	   OUT NOCOPY OKS_ENTITLEMENTS_WEB.contract_cat_tbl_type,
    x_contract_status_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.contract_status_tbl_type
  )
  IS
    CURSOR party_name_cur(p_party_id VARCHAR2)
    IS
      SELECT party_name FROM hz_parties WHERE party_id=p_party_id;
    CURSOR contract_cat_cur
    IS
      SELECT CODE, MEANING FROM OKC_SUBCLASSES_V WHERE CLS_CODE = 'SERVICE' ORDER BY MEANING;
    CURSOR contract_status_cur
    IS
      SELECT CODE, MEANING FROM OKC_STATUSES_V ORDER BY MEANING;

    l_contract_cat_tbl_type    OKS_ENTITLEMENTS_WEB.contract_cat_tbl_type;
    l_contract_status_tbl_type OKS_ENTITLEMENTS_WEB.contract_status_tbl_type;
    l_party_name               VARCHAR2(500);

    l_contract_cat_tbl_indx    NUMBER :=1;
    l_contract_status_tbl_indx NUMBER :=1;

    BEGIN

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.adv_search_overview',
                          'Inside adv_search_overview : ' ||  ' ' ||
                          'p_party_id_arg :'  || p_party_id_arg );

      END IF;
      FOR i in contract_cat_cur
        LOOP
          l_contract_cat_tbl_type(l_contract_cat_tbl_indx).contract_cat_code    := i.CODE;
          l_contract_cat_tbl_type(l_contract_cat_tbl_indx).contract_cat_meaning := i.MEANING;
          l_contract_cat_tbl_indx := l_contract_cat_tbl_indx + 1;
        END LOOP;

      FOR j in contract_status_cur
        LOOP
          l_contract_status_tbl_type(l_contract_status_tbl_indx).contract_status_code    := j.CODE;
          l_contract_status_tbl_type(l_contract_status_tbl_indx).contract_status_meaning := j.MEANING;
          l_contract_status_tbl_indx := l_contract_status_tbl_indx + 1;
        END LOOP;

      OPEN  party_name_cur(p_party_id_arg);
      FETCH party_name_cur
      INTO
        l_party_name;
      CLOSE  party_name_cur;

      x_contract_cat_tbl_type    := l_contract_cat_tbl_type;
      x_contract_status_tbl_type := l_contract_status_tbl_type;
      x_party_name := l_party_name;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END adv_search_overview;
---------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: contract_number_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Contract Overview JSP.
  ||     This procedure is used to retrieve the Contract information
  ||     and all the Lines and Parties given the Contract Number and Modifier.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_number_arg   -- Contract Number
  ||     p_contract_modifier_arg -- Contract Modifer
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_hdr_rec_type      -- Record that contains all the Contract Header information
  ||     x_hdr_addr_rec_type -- Record that contains the Billing and Shipping
  ||                            Address of the Contract
  ||     x_party_tbl_type    -- Table that contains all the Contract Parties information
  ||     x_line_tbl_type     -- Table that contains all the Contract Lines information
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */
  PROCEDURE contract_number_overview(
    p_contract_number_arg   IN  VARCHAR2,
    p_contract_modifier_arg IN  VARCHAR2,
    x_return_status	        OUT NOCOPY VARCHAR2,
    x_hdr_rec_type	        OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_rec_type,
    x_hdr_addr_rec_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_addr_rec_type,
    x_party_tbl_type        OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_tbl_type,
    x_line_tbl_type         OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_tbl_type
  )
  IS
    CURSOR contract_number_id_cur(p_contract_number VARCHAR2)
    IS
      SELECT id FROM OKC_K_HEADERS_ALL_V
      WHERE contract_number=p_contract_number
        AND contract_number_modifier IS NULL;

    CURSOR contract_num_mod_id_cur(p_contract_number VARCHAR2, p_contract_modifier VARCHAR2)
    IS
      SELECT id FROM OKC_K_HEADERS_ALL_V
      WHERE contract_number=p_contract_number
        AND contract_number_modifier=p_contract_modifier;

    l_contract_id     NUMBER;
    l_contract_id_chr VARCHAR2(500);

    BEGIN

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.contract_number_overview',
                          'Inside contract_number_overview : ' ||  ' ' ||
                          'p_contract_number_arg :'   || p_contract_number_arg || ' ' ||
                          'p_contract_modifier_arg :' || p_contract_modifier_arg );

      END IF;

      x_return_status := G_RET_STS_SUCCESS;

      IF p_contract_modifier_arg='NULL' OR p_contract_modifier_arg IS NULL
      THEN
        OPEN contract_number_id_cur(p_contract_number_arg);
        FETCH contract_number_id_cur
        INTO  l_contract_id;
        CLOSE contract_number_id_cur;
      ELSE
        OPEN contract_num_mod_id_cur(p_contract_number_arg, p_contract_modifier_arg);
        FETCH contract_num_mod_id_cur
        INTO  l_contract_id;
        CLOSE contract_num_mod_id_cur;
      END IF;

      l_contract_id_chr := to_char(l_contract_id);

      contract_overview(
        l_contract_id_chr,
        x_return_status,
        x_hdr_rec_type,
        x_hdr_addr_rec_type,
        x_party_tbl_type,
        x_line_tbl_type
      );
    EXCEPTION
      WHEN OTHERS
        THEN
    	  OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END contract_number_overview;
---------------------------------------------------------------------

  FUNCTION duration_unit(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  )
  RETURN VARCHAR2
  IS
    l_duration        NUMBER;
    l_timeunit        VARCHAR2(25);
    l_return_status   VARCHAR2(100);

    BEGIN
      OKC_TIME_UTIL_PUB.get_duration(
        p_start_date,
        p_end_date,
        l_duration,
        l_timeunit,
        l_return_status
      );


    RETURN l_timeunit;
  END duration_unit;
---------------------------------------------------------------------

  FUNCTION duration_period(
    p_start_date IN  DATE,
    p_end_date   IN  DATE
  )
  RETURN NUMBER
  IS
    l_duration        NUMBER;
    l_timeunit        VARCHAR2(25);
    l_return_status   VARCHAR2(100);

    BEGIN
      OKC_TIME_UTIL_PUB.get_duration(
        p_start_date,
        p_end_date,
        l_duration,
        l_timeunit,
        l_return_status
      );


    RETURN l_duration;
  END duration_period;
------------------------------------------------------------------------------

  FUNCTION line_coverage_name(
    p_line_id       IN  NUMBER,
    p_lse_id        IN  NUMBER
  )
  RETURN VARCHAR2
  IS
   -- R12 Spanigra (Changed the cursor based on Coverage rearchitecture design)
--    CURSOR line_cov_name_cur( p_line_id NUMBER, p_lse_id NUMBER)
--    IS
--      SELECT name FROM okc_k_lines_v WHERE cle_id = p_line_id AND lse_id=p_lse_id;
    CURSOR line_cov_name_cur( p_line_id NUMBER)
    IS
      SELECT name
      FROM oks_k_lines_v srv,
            okc_k_lines_v cov
      WHERE srv.cle_id = p_line_id
      AND   srv.coverage_id = cov.id;

    l_line_cov_name  OKC_K_LINES_V.NAME%TYPE;

    BEGIN
--      OPEN  line_cov_name_cur(p_line_id, p_lse_id);
      OPEN  line_cov_name_cur(p_line_id); -- R12 Spanigra

      FETCH line_cov_name_cur
      INTO
        l_line_cov_name;
      CLOSE  line_cov_name_cur;

    RETURN l_line_cov_name;
  END line_coverage_name;
------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: contract_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Contract Overview JSP.
  ||     This procedure is used to retrieve the Contract information
  ||     and all the Lines and Parties.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id_arg -- Contract ID
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_hdr_rec_type      -- Record that contains all the Contract Header information
  ||     x_hdr_addr_rec_type -- Record that contains the Billing and Shipping
  ||                            Address of the Contract
  ||     x_party_tbl_type    -- Table that contains all the Contract Parties information
  ||     x_line_tbl_type     -- Table that contains all the Contract Lines information
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE contract_overview(
    p_contract_id_arg   IN  VARCHAR2,
    x_return_status	    OUT NOCOPY VARCHAR2,
    x_hdr_rec_type	    OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_rec_type,
    x_hdr_addr_rec_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.hdr_addr_rec_type,
    x_party_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_tbl_type,
    x_line_tbl_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_tbl_type
  )
  IS
    CURSOR contract_hdr_cur( p_contract_id_arg VARCHAR2)
    IS
      SELECT
        hdr.ID HeaderId,
        hdr.CONTRACT_NUMBER ContractNumber,
        hdr.CONTRACT_NUMBER_MODIFIER Modifier,
        ver.MAJOR_VERSION||'.'||MINOR_VERSION Version,
        hdr.COGNOMEN KnownAs,
        hdr.SHORT_DESCRIPTION ShortDescription,
        hdr.ESTIMATED_AMOUNT Amount,
        hdr.CURRENCY_CODE Currency_code,
        hdr.STS_CODE StatusCode,
        sts.MEANING Status,
        hdr.SCS_CODE CatCode,
        cat.MEANING Category,
        ord.ORDER_NUMBER OrderNumber,
        hdr.START_DATE ContStartDate,
        hdr.END_DATE  ContEndDate
      FROM
        OKC_K_REL_OBJS_V rel,
        OKX_ORDER_HEADERS_V ord,
        OKC_STATUSES_V  sts,
        OKC_SUBCLASSES_V cat,
        OKC_K_VERS_NUMBERS_V ver,
        OKC_K_HEADERS_ALL_V hdr
      WHERE
        hdr.ID = to_number(p_contract_id_arg)
        AND hdr.sts_code = sts.code
        AND SYSDATE BETWEEN sts.start_date AND nvl(sts.end_date,SYSDATE)
        AND hdr.scs_code = cat.code
        AND hdr.id = ver.chr_id
        AND hdr.id = rel.chr_id(+)
        AND rel.cle_id IS NULL
        AND rel.object1_id1 = ord.id1(+)
        and rel.jtot_object1_code(+) = 'OKX_ORDERHEAD';

    CURSOR cntrct_hdr_period_cur(p_period_unit VARCHAR)
    IS
      /*SELECT fndLkups.meaning
      FROM   fnd_lookups fndLkups
      WHERE  fndLkups.lookup_code = p_period_unit
             and fndLkups.lookup_type = 'EGO_SRV_DURATION_PERIOD';*/
      /*Bug #6140663 - fp of 6026318*/
      SELECT unit_of_measure_tl
      FROM mtl_units_of_measure_tl
      WHERE uom_code = p_period_unit
      AND language = userenv('LANG');

    CURSOR cntrct_hdr_addr_bill_to_cur(p_contract_id NUMBER)
    IS

 SELECT okxCountry.Name BillToCountry
 FROM   HZ_CUST_SITE_USES_ALL CS,
        HZ_PARTY_SITES PS,
        HZ_LOCATIONS L,
        HZ_CUST_ACCT_SITES_ALL CA,
        OKX_CUSTOMER_ACCOUNTS_V cus_b,
        OKC_K_HEADERS_ALL_B hdr,
        OKX_COUNTRIES_V okxCountry
 WHERE  hdr.ID=p_contract_id
        AND CS.SITE_USE_ID = hdr.BILL_TO_SITE_USE_ID
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND CS.SITE_USE_CODE = 'BILL_TO'
        AND cus_b.id1 = CA.CUST_ACCOUNT_ID
        AND okxCountry.ID1=L.COUNTRY;

    CURSOR cntrct_hdr_addr_ship_to_cur(p_contract_id NUMBER)
    IS

     SELECT okxCountry.Name BillToCountry
     FROM   HZ_CUST_SITE_USES_ALL CS,
            HZ_PARTY_SITES PS,
            HZ_LOCATIONS L,
            HZ_CUST_ACCT_SITES_ALL CA,
            OKX_CUSTOMER_ACCOUNTS_V cus_b,
            OKC_K_HEADERS_ALL_B hdr,
            OKX_COUNTRIES_V okxCountry
      WHERE
        hdr.ID=p_contract_id
        AND CS.SITE_USE_ID = hdr.SHIP_TO_SITE_USE_ID
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND CS.SITE_USE_CODE = 'SHIP_TO'
        AND cus_b.id1 = CA.CUST_ACCOUNT_ID
        AND okxCountry.ID1=L.COUNTRY;


    CURSOR cntrct_hdr_bill_address_cur(p_contract_id NUMBER)
    IS

       SELECT
        hdr.ID ChrID,
        cus_b.NAME BillToCustomer,
        CS.LOCATION BillToSite,
        L.ADDRESS1||
          decode(L.ADDRESS2,NULL,NULL,' , '|| L.ADDRESS2)||
          decode(L.ADDRESS3,NULL,NULL,' , '||L.ADDRESS3)||
          decode(L.ADDRESS4,NULL,NULL,' , '||L.ADDRESS4)
        BillToAddress,
        L.CITY||
          decode(L.STATE,NULL,NULL,'  '||L.STATE)||
          decode(L.POSTAL_CODE,NULL,NULL,'  '||L.POSTAL_CODE)
        BillToCityStateZip
      FROM
        HZ_CUST_SITE_USES_ALL CS,
        HZ_PARTY_SITES PS,
        HZ_LOCATIONS L,
        HZ_CUST_ACCT_SITES_ALL CA,
        OKX_CUSTOMER_ACCOUNTS_V cus_b,
        OKC_K_HEADERS_ALL_V hdr
      WHERE hdr.ID= p_contract_id
        AND CS.SITE_USE_ID = hdr.BILL_TO_SITE_USE_ID
        AND CS.SITE_USE_CODE = 'BILL_TO'
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND cus_b.id1 = CA.CUST_ACCOUNT_ID;


    CURSOR cntrct_hdr_ship_address_cur(p_contract_id NUMBER)
    IS

      SELECT
        cus_s.NAME ShipToCustomer,
        CS.LOCATION ShipToSite,
        L.ADDRESS1||
          decode(L.ADDRESS2,NULL,NULL,' , '||L.ADDRESS2)||
          decode(L.ADDRESS3,NULL,NULL,' , '||L.ADDRESS3)||
          decode(L.ADDRESS4,NULL,NULL,' , '||L.ADDRESS4)
        ShipToAddress,
        L.CITY||
          decode(L.STATE,NULL,NULL,'  '||L.STATE)||
          decode(L.POSTAL_CODE,NULL,NULL,'  '||L.POSTAL_CODE)
        ShipToCityStateZip
      FROM
        OKX_CUSTOMER_ACCOUNTS_V cus_s,
        HZ_CUST_SITE_USES_ALL CS,
        HZ_PARTY_SITES PS,
        HZ_LOCATIONS L,
        HZ_CUST_ACCT_SITES_ALL CA,
        OKC_K_HEADERS_ALL_V hdr
      WHERE
        hdr.ID=p_contract_id
        AND CS.SITE_USE_ID = hdr.SHIP_TO_SITE_USE_ID
        AND CS.SITE_USE_CODE = 'SHIP_TO'
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND cus_s.ID1 = CA.CUST_ACCOUNT_ID;

    CURSOR cntrct_party_Bill_prof_cur(p_contract_id NUMBER)
    IS
         SELECT bil.PROFILE_NUMBER BillProfileNumber
         FROM   OKS_BILLING_PROFILES_V bil, OKS_K_HEADERS_B oksHdr
         WHERE  oksHdr.CHR_ID = p_contract_id AND bil.ID = oksHdr.BILLING_PROFILE_ID;

    CURSOR contract_party_cursor(p_contract_id NUMBER)
    IS
      SELECT
        hdr.id chr_id,
        pty.party_number PartyNumber,
        rle.rle_code RleCode,
        pty.name name,
        fnd.meaning Role,
        pty.gsa_indicator_flag Gsa
      FROM
        FND_LOOKUPS fnd,
        OKX_PARTIES_V pty,
        OKC_K_PARTY_ROLES_B rle,
        OKC_K_HEADERS_ALL_B hdr
      WHERE
        hdr.id=p_contract_id
        and rle.chr_id=hdr.id
        and rle.dnz_chr_id=hdr.id
        and rle.jtot_object1_code='OKX_PARTY'
        AND pty.id1=rle.object1_id1
        AND pty.id2='#'
        AND fnd.lookup_type='OKC_ROLE'
        AND fnd.lookup_code=rle.rle_code
      UNION
      SELECT
        hdr.id chr_id,
        pty.party_number PartyNumber,
        rle.rle_code RleCode,
        pty.name name,
        fnd.meaning Role,
        NULL Gsa
      FROM
        FND_LOOKUPS fnd,
        OKX_PARTIES_V pty,
        OKC_K_PARTY_ROLES_B rle,
        OKC_K_HEADERS_ALL_B hdr
      WHERE
        hdr.id=p_contract_id
        AND rle.chr_id=hdr.id
        AND rle.dnz_chr_id=hdr.id
        AND rle.jtot_object1_code='OKX_VENDOR'
        AND pty.id1=rle.object1_id1
        AND pty.id2='#'
        AND fnd.lookup_type='OKC_ROLE'
        AND fnd.lookup_code=rle.rle_code
      UNION
      SELECT
        hdr.id chr_id,
        NULL PartyNumber,
        rle.rle_code RleCode,
        pty.name name,
        fnd.meaning Role,
        NULL Gsa
      FROM
        FND_LOOKUPS fnd,
        OKX_ORGANIZATION_DEFS_V pty,
        OKC_K_PARTY_ROLES_B rle,
        OKC_K_HEADERS_ALL_B hdr
      WHERE
        hdr.id=p_contract_id
        AND rle.chr_id=hdr.id
        AND rle.dnz_chr_id=hdr.id
        AND rle.jtot_object1_code='OKX_OPERUNIT'
        AND pty.id1=rle.object1_id1
        AND pty.id2='#'
        AND fnd.lookup_type='OKC_ROLE'
        AND fnd.lookup_code=rle.rle_code;

    CURSOR cntrct_line_type_cur(p_lse_id NUMBER)
    IS
      select lnStyl.Name LineType
      from okc_line_styles_v lnStyl
      where lnStyl.id = p_lse_id;


    CURSOR contract_line_cursor(p_contract_id NUMBER)
    IS
      SELECT
        ln.DNZ_CHR_ID ChrId,
        ln.id LineID,
        ln.Start_Date lineStartDate,
        ln.LINE_NUMBER lineNumber,
        ln.End_Date lineEndDate,
        ln.Exception_YN Exemption,
        sys.concatenated_segments LineName,
        sys.description LineDescription,
        ln.lse_id LseID,
        itm.number_of_items Quantity
      FROM
        MTL_SYSTEM_ITEMS_KFV sys,
        okc_k_items itm,
        okc_k_lines_v ln
      WHERE
        ln.DNZ_CHR_ID=p_contract_id
        AND ln.lse_id IN (1,12,14,19)
        AND itm.cle_id=ln.id
        AND itm.JTOT_OBJECT1_CODE IN ('OKX_WARRANTY', 'OKX_SERVICE', 'OKX_USAGE') -- #4915688
        AND sys.inventory_item_id=itm.object1_id1
        AND sys.ORGANIZATION_ID=itm.object1_id2
       --  AND (sys.service_item_flag='Y' OR sys.usage_item_flag='Y') #4915688
        order by to_number(ln.line_number) ;

    CURSOR contract_sub_line_cursor(p_contract_id NUMBER, p_line_id NUMBER)
    IS
      SELECT
        cus.name AccountName,
        cus.description AccountDesc,
        cus.party_id Account
      FROM
        okx_customer_accounts_v cus,
        okc_k_lines_v ln
      WHERE
        ln.DNZ_CHR_ID = p_contract_id
        AND ln.id=p_line_id
        AND ln.lse_id IN (1,12,14,19)
        AND cus.id1=ln.CUST_ACCT_ID;

    CURSOR country_name_cur(p_country_code VARCHAR2)
    IS
      select okxCountry.Name CountryName
      from OKX_COUNTRIES_V okxCountry
      where okxCountry.ID1=p_country_code;


    CURSOR cntrct_line_addr_cur(p_line_id NUMBER)
    IS

      SELECT
        CS.SITE_USE_CODE AddressType,
        CS.LOCATION SiteName,
        L.ADDRESS1 Address1,
        L.ADDRESS2 Address2,
        L.ADDRESS3 Address3,
        L.ADDRESS4 Address4,
        L.CITY || ' ' ||  L.COUNTY City,
        L.STATE State,
        L.POSTAL_CODE ZipCode,
        L.COUNTRY Country
      FROM
          HZ_CUST_SITE_USES_ALL CS,
        HZ_PARTY_SITES PS,
        HZ_LOCATIONS L,
        HZ_CUST_ACCT_SITES_ALL CA,
        OKC_K_LINES_B okcLn
      WHERE okcLn.id = p_line_id
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND (CS.SITE_USE_ID = okcLn.BILL_TO_SITE_USE_ID
        OR  CS.SITE_USE_ID = okcLn.SHIP_TO_SITE_USE_ID);

    l_hdr_rec_type      OKS_ENTITLEMENTS_WEB.hdr_rec_type;
    l_hdr_addr_rec_type OKS_ENTITLEMENTS_WEB.hdr_addr_rec_type;
    l_party_tbl_type    OKS_ENTITLEMENTS_WEB.party_tbl_type;
    l_line_tbl_type     OKS_ENTITLEMENTS_WEB.line_tbl_type;

    l_party_tbl_indx  NUMBER :=1;
    l_line_tbl_indx   NUMBER :=1;
    l_duration        NUMBER;
    l_party_bill_prof VARCHAR2(100);
    l_timeunit        VARCHAR2(25);
    l_return_status   VARCHAR2(100);
    l_site_name	      VARCHAR2(40);
    l_address_type    VARCHAR2(360);
    l_address1	      VARCHAR2(240);
    l_address2	      VARCHAR2(240);
    l_address3	      VARCHAR2(240);
    l_address4        VARCHAR2(240);
    l_city            VARCHAR2(60);
    l_state	      VARCHAR2(60);
    l_zip             VARCHAR2(60);
    l_country         VARCHAR2(60);
    l_temp_lse_id     NUMBER;

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.contract_overview',
                          'Inside contract_overview : ' ||  ' ' ||
                          'p_contract_id_arg :'   || p_contract_id_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

        OPEN contract_hdr_cur( p_contract_id_arg );
        FETCH contract_hdr_cur
        INTO
          l_hdr_rec_type.header_id,
          l_hdr_rec_type.contract_number,
          l_hdr_rec_type.modifier,
          l_hdr_rec_type.version,
          l_hdr_rec_type.known_as,
          l_hdr_rec_type.short_description,
          l_hdr_rec_type.contract_amount,
          l_hdr_rec_type.currency_code,
          l_hdr_rec_type.sts_code,
          l_hdr_rec_type.status,
          l_hdr_rec_type.scs_code,
          l_hdr_rec_type.scs_category,
          l_hdr_rec_type.order_number,
          l_hdr_rec_type.start_date,
          l_hdr_rec_type.end_date;

        OKC_TIME_UTIL_PUB.get_duration(
          p_start_date    => l_hdr_rec_type.START_DATE,
          p_end_date      => l_hdr_rec_type.END_DATE,
          x_duration      => l_duration,
          x_timeunit      => l_timeunit,
          x_return_status => l_return_status
        );

        l_hdr_rec_type.duration := l_duration;
        l_hdr_rec_type.period_code := l_timeunit;

        IF l_return_status = G_RET_STS_SUCCESS
        THEN
          l_hdr_rec_type.DURATION    := l_duration;
          OPEN cntrct_hdr_period_cur(l_timeunit);
          FETCH cntrct_hdr_period_cur
           INTO
            l_hdr_rec_type.period_code;
          CLOSE cntrct_hdr_period_cur;
        ELSE
          x_return_status  := l_return_status ;
        END IF;

      IF contract_hdr_cur%found
      THEN
        OPEN cntrct_party_Bill_prof_cur(l_hdr_rec_type.header_id);
        FETCH cntrct_party_Bill_prof_cur
        INTO
          l_party_bill_prof;
        CLOSE cntrct_party_Bill_prof_cur;

        OPEN cntrct_hdr_bill_address_cur(l_hdr_rec_type.header_id);
        FETCH cntrct_hdr_bill_address_cur
        INTO
          l_hdr_addr_rec_type.header_id,
          l_hdr_addr_rec_type.bill_to_customer,
          l_hdr_addr_rec_type.bill_to_site,
          l_hdr_addr_rec_type.bill_to_address,
          l_hdr_addr_rec_type.bill_to_city_state_zip;
        CLOSE cntrct_hdr_bill_address_cur;

        OPEN cntrct_hdr_ship_address_cur(l_hdr_rec_type.header_id);
        FETCH cntrct_hdr_ship_address_cur
        INTO
          l_hdr_addr_rec_type.ship_to_customer,
          l_hdr_addr_rec_type.ship_to_site,
          l_hdr_addr_rec_type.ship_to_address,
          l_hdr_addr_rec_type.ship_to_city_state_zip;
        CLOSE cntrct_hdr_ship_address_cur;

        OPEN cntrct_hdr_addr_bill_to_cur(l_hdr_rec_type.header_id);
        FETCH cntrct_hdr_addr_bill_to_cur
        INTO
          l_hdr_addr_rec_type.bill_to_country;
        CLOSE cntrct_hdr_addr_bill_to_cur;

        OPEN cntrct_hdr_addr_ship_to_cur(l_hdr_rec_type.header_id);
        FETCH cntrct_hdr_addr_ship_to_cur
        INTO
          l_hdr_addr_rec_type.ship_to_country;
        CLOSE cntrct_hdr_addr_ship_to_cur;

        l_party_tbl_indx := 1;
        FOR j IN contract_party_cursor(l_hdr_rec_type.header_id)
        LOOP
          l_party_tbl_type(l_party_tbl_indx).header_id    := j.Chr_id;
          l_party_tbl_type(l_party_tbl_indx).rle_code     := j.RleCode;
          l_party_tbl_type(l_party_tbl_indx).party_role   := j.Role;
          l_party_tbl_type(l_party_tbl_indx).party_name   := j.Name;
          l_party_tbl_type(l_party_tbl_indx).party_number := j.PartyNumber;
          l_party_tbl_type(l_party_tbl_indx).gsa_flag     := j.Gsa;
          l_party_tbl_type(l_party_tbl_indx).bill_profile := l_party_bill_prof;
          l_party_tbl_indx := l_party_tbl_indx + 1;
        END LOOP;

        l_line_tbl_indx := 1;
        FOR k IN contract_line_cursor(l_hdr_rec_type.header_id)
        LOOP
          l_line_tbl_type(l_line_tbl_indx).header_id        := k.ChrId;
          l_line_tbl_type(l_line_tbl_indx).line_id          := k.LineID;
          l_line_tbl_type(l_line_tbl_indx).start_date       := k.lineStartDate;
          l_line_tbl_type(l_line_tbl_indx).line_number      := k.lineNumber;
          l_line_tbl_type(l_line_tbl_indx).end_date         := k.lineEndDate;
          l_line_tbl_type(l_line_tbl_indx).exemption        := k.Exemption;

          OPEN cntrct_line_type_cur(k.LseID);
          FETCH cntrct_line_type_cur
          INTO l_line_tbl_type(l_line_tbl_indx).line_type;
          CLOSE cntrct_line_type_cur;

          --l_line_tbl_type(l_line_tbl_indx).line_type        := k.LineType;
          l_line_tbl_type(l_line_tbl_indx).line_name        := k.LineName;
          l_line_tbl_type(l_line_tbl_indx).line_description := k.LineDescription;
          l_line_tbl_type(l_line_tbl_indx).quantity         := k.Quantity;
          l_temp_lse_id := k.LseID +1;
          l_line_tbl_type(l_line_tbl_indx).coverage_name  := line_coverage_name(k.LineID, l_temp_lse_id);

          OPEN contract_sub_line_cursor(l_hdr_rec_type.header_id, k.LineID);
          FETCH contract_sub_line_cursor
          INTO
            l_line_tbl_type(l_line_tbl_indx).account_name,
            l_line_tbl_type(l_line_tbl_indx).account_desc,
            l_line_tbl_type(l_line_tbl_indx).account_number;
          CLOSE contract_sub_line_cursor;

          OPEN cntrct_line_addr_cur(k.LineID);
          FETCH cntrct_line_addr_cur
          INTO
            l_address_type,
            l_site_name,
            l_address1,
            l_address2,
            l_address3,
            l_address4,
            l_city,
            l_state,
            l_zip,
            l_country;
          IF l_address_type = 'BILL_TO'
          THEN
            l_line_tbl_type(l_line_tbl_indx).bill_to_site := l_site_name;
            l_line_tbl_type(l_line_tbl_indx).bill_to_address := l_address1||' '||l_address2||' '||l_address3||' '||l_address4;
            l_line_tbl_type(l_line_tbl_indx).bill_to_city_state_zip := l_city||' '||l_state||' '||l_zip;

            OPEN country_name_cur(l_country);
            FETCH country_name_cur
            INTO l_line_tbl_type(l_line_tbl_indx).bill_to_country;
            CLOSE country_name_cur;

            --l_line_tbl_type(l_line_tbl_indx).bill_to_country := l_country;
          ELSIF l_address_type = 'SHIP_TO'
            THEN
              l_line_tbl_type(l_line_tbl_indx).ship_to_site := l_site_name;
              l_line_tbl_type(l_line_tbl_indx).ship_to_address := l_address1||' '||l_address2||' '||l_address3||' '||l_address4;
              l_line_tbl_type(l_line_tbl_indx).ship_to_city_state_zip := l_city||' '||l_state||' '||l_zip;

              OPEN country_name_cur(l_country);
              FETCH country_name_cur
              INTO l_line_tbl_type(l_line_tbl_indx).ship_to_country;
              CLOSE country_name_cur;

              --l_line_tbl_type(l_line_tbl_indx).ship_to_country := l_country;
            END IF;
            IF cntrct_line_addr_cur%found
            THEN
              FETCH cntrct_line_addr_cur
              INTO
                l_address_type,
                l_site_name,
                l_address1,
                l_address2,
                l_address3,
                l_address4,
                l_city,
                l_state,
                l_zip,
                l_country;
              IF l_address_type = 'BILL_TO'
              THEN
                l_line_tbl_type(l_line_tbl_indx).bill_to_site := l_site_name;
                l_line_tbl_type(l_line_tbl_indx).bill_to_address := l_address1||' '||l_address2||' '||l_address3||' '||l_address4;
                l_line_tbl_type(l_line_tbl_indx).bill_to_city_state_zip := l_city||' '||l_state||' , '||l_zip;

                OPEN country_name_cur(l_country);
                FETCH country_name_cur
                INTO l_line_tbl_type(l_line_tbl_indx).bill_to_country;
                CLOSE country_name_cur;

                --l_line_tbl_type(l_line_tbl_indx).bill_to_country := l_country;
              ELSIF l_address_type = 'SHIP_TO'
                THEN
                  l_line_tbl_type(l_line_tbl_indx).ship_to_site := l_site_name;
                  l_line_tbl_type(l_line_tbl_indx).ship_to_address := l_address1||' '||l_address2||' '||l_address3||' '||l_address4;
                  l_line_tbl_type(l_line_tbl_indx).ship_to_city_state_zip := l_city||' '||l_state||' '||l_zip;

                  OPEN country_name_cur(l_country);
                  FETCH country_name_cur
                  INTO l_line_tbl_type(l_line_tbl_indx).ship_to_country;
                  CLOSE country_name_cur;

                  --l_line_tbl_type(l_line_tbl_indx).ship_to_country := l_country;
                END IF;
            END IF;
 CLOSE cntrct_line_addr_cur;

            l_line_tbl_indx := l_line_tbl_indx + 1;
          END LOOP;

      END IF;
      x_hdr_rec_type      := l_hdr_rec_type;
      x_hdr_addr_rec_type := l_hdr_addr_rec_type;
      x_party_tbl_type    := l_party_tbl_type;
      x_line_tbl_type     := l_line_tbl_type;

      CLOSE  contract_hdr_cur ;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END contract_overview;
--------------------------------------------------------------------------------
  FUNCTION party_contact_name(
    p_owner_table_id  IN VARCHAR2,
    p_object1_id1     IN VARCHAR2,
    p_object1_id2     IN VARCHAR2,
    p_org_id          IN NUMBER
  )
  RETURN VARCHAR2
  IS
    CURSOR party_contact_name_cur1(p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2)
    IS
      SELECT
             C.LAST_NAME name
      FROM
             JTF_RS_RESOURCE_EXTNS RSC ,
             PO_VENDOR_SITES_ALL S ,
             PO_VENDOR_CONTACTS C
      WHERE
             RSC.CATEGORY = 'SUPPLIER_CONTACT'
             AND C.VENDOR_CONTACT_ID = RSC.SOURCE_ID
             AND S.VENDOR_SITE_ID = C.VENDOR_SITE_ID
             AND S.ORG_ID = sys_context('OKC_CONTEXT', 'ORG_ID')
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
      UNION ALL
      SELECT
             EMP.FULL_NAME name
             FROM JTF_RS_RESOURCE_EXTNS RSC ,
             FND_USER U ,
             OKX_PER_ALL_PEOPLE_V EMP
      WHERE
             RSC.CATEGORY = 'EMPLOYEE'
             AND EMP.PERSON_ID = RSC.SOURCE_ID
             AND U.USER_ID = RSC.USER_ID
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
      UNION ALL
      SELECT
             PARTY.PARTY_NAME name
      FROM
             JTF_RS_RESOURCE_EXTNS RSC ,
             FND_USER U ,
             HZ_PARTIES PARTY
      WHERE
             RSC.CATEGORY IN ( 'PARTY', 'PARTNER')
             AND PARTY.PARTY_ID = RSC.SOURCE_ID
             AND U.USER_ID = RSC.USER_ID
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2
      UNION ALL
      SELECT /*+ ordered */
             TL.RESOURCE_NAME name
      FROM
             JTF_RS_RESOURCE_EXTNS RSC
             ,JTF_RS_SALESREPS SRP
             ,JTF_RS_RESOURCE_EXTNS_TL TL  -- Bug Fix #5442182
             ,FND_USER U

      WHERE
             RSC.CATEGORY = 'OTHER'
             AND SRP.RESOURCE_ID = RSC.RESOURCE_ID
             AND U.USER_ID = RSC.USER_ID
             AND SRP.ORG_ID = sys_context('OKC_CONTEXT', 'ORG_ID')
             AND TL.RESOURCE_ID = SRP.RESOURCE_ID  -- Bug Fix #5442182
             AND TL.LANGUAGE = USERENV('LANG')     -- Bug Fix #5442182
             AND TL.CATEGORY = RSC.CATEGORY
             AND RSC.RESOURCE_ID = to_number(p_object1_id1)
             AND '#' = p_object1_id2;

    CURSOR party_contact_name_cur2(p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2)
    IS
      Select name From OKX_PARTY_CONTACTS_V Where id1 = to_number(p_object1_id1) and id2 = p_object1_id2;
    CURSOR party_contact_name_cur3(p_object1_id1 VARCHAR2, p_object1_id2 VARCHAR2)
    IS
      SELECT TL.RESOURCE_NAME
      FROM JTF_RS_SALESREPS S
          ,JTF_RS_RESOURCE_EXTNS_TL TL   -- Bug Fix #5442182
      WHERE S.salesrep_id = TO_NUMBER(p_object1_id1)
      AND   S.org_id = p_org_id
      AND   S.RESOURCE_ID = TL.RESOURCE_ID
      AND   TL.LANGUAGE = USERENV('LANG');



    l_party_contact_name  VARCHAR2(360);

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_contact_name',
                          'Inside party_contact_name : ' ||  ' ' ||
                          'p_owner_table_id :'   || p_owner_table_id || ' ' ||
                          'p_object1_id1 : '     || p_object1_id1    || ' ' ||
                          'p_object1_id2 : '     || p_object1_id2);

      END IF;
      IF p_owner_table_id = 'OKX_RESOURCE'
      THEN
        OPEN  party_contact_name_cur1(p_object1_id1 , p_object1_id2);
        FETCH party_contact_name_cur1
        INTO
          l_party_contact_name;
        CLOSE  party_contact_name_cur1;
      ELSIF p_owner_table_id = 'OKX_PCONTACT'
        THEN
        OPEN  party_contact_name_cur2(p_object1_id1 , p_object1_id2);
        FETCH party_contact_name_cur2
        INTO
          l_party_contact_name;
        CLOSE  party_contact_name_cur2;
      ELSIF p_owner_table_id = 'OKX_SALEPERS'
        THEN
        OPEN  party_contact_name_cur3(p_object1_id1 , p_object1_id2);
        FETCH party_contact_name_cur3
        INTO
          l_party_contact_name;
        CLOSE  party_contact_name_cur3;
       ELSIF p_owner_table_id = 'OKS_RSCGROUP' THEN
             l_party_contact_name :=  Okc_Util.GET_NAME_FROM_JTFV('OKS_RSCGROUP', p_object1_id1, p_object1_id2);
      END IF;
    RETURN l_party_contact_name;
  END party_contact_name;
-----------------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Party Details JSP.
  ||     This procedure is used to retrieve the Contact information of a given Party
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_id_arg    -- Contract ID of the Contract to which the Party belongs
  ||     p_party_rle_code_arg -- Party Code
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_party_contact_tbl_type -- Table that contains all the Contact information of a given Party
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_overview(
    p_contract_id_arg        IN  VARCHAR2,
    p_party_rle_code_arg     IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_party_contact_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.party_contact_tbl_type
  )
  IS
    CURSOR party_contact_email_cur( p_owner_table_id VARCHAR)
    IS
      Select EMAIL_ADDRESS Email
      From   OKS_CONTACT_POINTS_V
      Where
        OWNER_TABLE_ID = to_number(p_owner_table_id)
        and (CONTACT_POINT_TYPE = 'EMAIL' or CONTACT_POINT_TYPE = 'Email');

    CURSOR party_contacts_cur( p_contract_id_arg VARCHAR2, p_party_rle_code_arg VARCHAR2)
    IS
      Select
        rol.DNZ_CHR_ID ChrID,
        rol.RLE_CODE RleCode,
        con.JTOT_OBJECT1_CODE OwnerTableID,
        con.ROLE Role,
        con.START_DATE StartDate,
        con.END_DATE EndDate,
        con.object1_id1 ContactID,
        con.object1_id2 ID2
      from
        OKC_CONTACTS_V con,
        OKC_K_PARTY_ROLES_B rol
      where
        rol.dnz_chr_id = to_number(p_contract_id_arg)
        and rol.RLE_CODE = p_party_rle_code_arg
        and rol.CLE_ID is NULL
        and rol.JTOT_OBJECT1_CODE in ('OKX_PARTY','OKX_VENDOR','OKX_OPERUNIT')
        and con.CPL_ID = rol.ID;

     CURSOR get_org_id_cur(contract_id NUMBER) IS
            SELECT org_id
            FROM   OKC_K_HEADERS_ALL_B
            WHERE  id = contract_id;

     CURSOR salesrep_email_cur(p_org_id NUMBER,p_contact_id VARCHAR2) IS
            SELECT email_address
            FROM JTF_RS_SALESREPS
            WHERE salesrep_id = p_contact_id
            AND   org_id = p_org_id;

      CURSOR resource_email_cur(p_contact_id VARCHAR2) IS
            SELECT email_address
            FROM OKX_RESOURCES_V
            WHERE id1 = p_contact_id;

      CURSOR resource_group_email_cur(p_contact_id VARCHAR2) IS
            SELECT email_address
            FROM JTF_RS_GROUPS_B
            WHERE group_id = p_contact_id;

    l_party_contact_tbl_type OKS_ENTITLEMENTS_WEB.party_contact_tbl_type;

    l_party_contact_tbl_indx NUMBER :=1;
    l_org_id NUMBER;

    BEGIN

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_overview',
                          'Inside party_overview : ' ||  ' ' ||
                          'p_contract_id_arg :'   || p_contract_id_arg || ' ' ||
                          'p_party_rle_code_arg :' || p_party_rle_code_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      OPEN  get_org_id_cur(to_number(p_contract_id_arg));
      FETCH get_org_id_cur INTO l_org_id;
      CLOSE get_org_id_cur;

      l_party_contact_tbl_indx := 1;
      FOR j IN party_contacts_cur(p_contract_id_arg, p_party_rle_code_arg)
      LOOP
        l_party_contact_tbl_type(l_party_contact_tbl_indx).header_id      := j.ChrID;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).rle_code       := j.RleCode;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).owner_table_id := j.OwnerTableID;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).contact_role   := j.Role;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).start_date     := j.StartDate;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).end_date       := j.EndDate;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).contact_id     := j.ContactID;
        l_party_contact_tbl_type(l_party_contact_tbl_indx).contact_name   := party_contact_name(j.OwnerTableID, j.ContactID, j.ID2,l_org_id);

        IF j.OwnerTableID = 'OKX_SALEPERS' THEN
            OPEN  salesrep_email_cur(l_org_id,j.ContactID);
            FETCH salesrep_email_cur INTO  l_party_contact_tbl_type(l_party_contact_tbl_indx).primary_email;
            CLOSE salesrep_email_cur;
        ELSIF j.OwnerTableID = 'OKX_RESOURCE' THEN
            OPEN  resource_email_cur(j.ContactID);
            FETCH resource_email_cur INTO  l_party_contact_tbl_type(l_party_contact_tbl_indx).primary_email;
            CLOSE resource_email_cur;
        ELSIF j.OwnerTableID = 'OKS_RSCGROUP' THEN
            OPEN  resource_group_email_cur(j.ContactID);
            FETCH resource_group_email_cur INTO  l_party_contact_tbl_type(l_party_contact_tbl_indx).primary_email;
            CLOSE resource_group_email_cur;
        ELSE
           OPEN party_contact_email_cur(j.ContactID);
           FETCH party_contact_email_cur
           INTO
             l_party_contact_tbl_type(l_party_contact_tbl_indx).primary_email;
           CLOSE party_contact_email_cur;
        END IF;

        l_party_contact_tbl_indx := l_party_contact_tbl_indx + 1;
      END LOOP;

      x_party_contact_tbl_type := l_party_contact_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_overview;
---------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: party_contacts_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Party Contact Details JSP.
  ||     This procedure is used to retrieve the Contact Details information of a given Contact
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contact_id_arg -- Contact ID
  ||
  || Out Parameters:
  ||     x_return_status           -- Success of the procedure.
  ||     x_pty_cntct_dtls_tbl_type -- Table that contains all the Contact Details
  ||                                  information of a given Contact
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE party_contacts_overview(
    p_contact_id_arg          IN  VARCHAR2,
    x_return_status	          OUT NOCOPY VARCHAR2,
    x_pty_cntct_dtls_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.pty_cntct_dtls_tbl_type
  )
  IS
    CURSOR party_contact_details_cur(p_contact_id_arg VARCHAR2)
    IS
      Select
        OWNER_TABLE_ID Id,
        decode(
          CONTACT_POINT_TYPE,
          'EMAIL',
          'Email',
          'PHONE',
          'Phone',
          'FAX',
          'Fax',
          CONTACT_POINT_TYPE
        ) ContactType,
        EMAIL_ADDRESS Email,
        PHONE_LINE_TYPE PhoneLineType,
        PHONE_COUNTRY_CODE CountryCode,
        PHONE_AREA_CODE  AreaCode,
        PHONE_NUMBER pNumber,
        PHONE_EXTENSION Extension
      From
        OKS_CONTACT_POINTS_V
      Where  OWNER_TABLE_ID = to_number(p_contact_id_arg);

    l_pty_cntct_dtls_tbl_type OKS_ENTITLEMENTS_WEB.pty_cntct_dtls_tbl_type;

    l_party_contact_tbl_indx NUMBER :=1;

    BEGIN
     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.party_contacts_overview',
                          'Inside party_contacts_overview : ' ||  ' ' ||
                          'p_contact_id_arg :'   || p_contact_id_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      l_party_contact_tbl_indx := 1;
      FOR j IN party_contact_details_cur(p_contact_id_arg)
      LOOP
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).owner_table_id   := j.Id;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).contact_type     := j.ContactType;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).email_address    := j.Email;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).phone_type       := j.PhoneLineType;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).phone_country_cd := j.CountryCode;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).phone_area_cd    := j.AreaCode;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).phone_number     := j.pNumber;
        l_pty_cntct_dtls_tbl_type(l_party_contact_tbl_indx).phone_extension  := j.Extension;

        l_party_contact_tbl_indx := l_party_contact_tbl_indx + 1;
      END LOOP;

      x_pty_cntct_dtls_tbl_type := l_pty_cntct_dtls_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END party_contacts_overview;
----------------------------------------------------------------------------------

  FUNCTION customer_contact_address(p_party_roles_cle_id NUMBER)
  RETURN VARCHAR2
  IS
    CURSOR cust_cntct_addr_cur(p_party_roles_cle_id NUMBER)
    IS
      Select
        ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,L.ADDRESS1,L.ADDRESS2,L.ADDRESS3, L.ADDRESS4,L.CITY
        ,L.COUNTY,L.STATE,L.PROVINCE,L.POSTAL_CODE,NULL,L.COUNTRY,NULL, NULL,NULL,NULL,NULL,NULL,NULL
        ,'N','N',300,1,1) Address
      From
        OKC_K_LINES_B okcLn,
        OKC_K_HEADERS_ALL_B hdr,
        HZ_CUST_SITE_USES_ALL CS,
        HZ_PARTY_SITES PS,
        HZ_LOCATIONS L,
        HZ_CUST_ACCT_SITES_ALL CA,
        OKX_CUSTOMER_ACCOUNTS_V cus
      Where
        okcLn.id = p_party_roles_cle_id
        AND hdr.id = okcLn.dnz_chr_id
        and cus.ID1 = okcLn.CUST_ACCT_ID
        and cus.ID2 = '#'
        and CA.CUST_ACCOUNT_ID = cus.PARTY_ID
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
        AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
        AND PS.LOCATION_ID = L.LOCATION_ID
        AND CS.SITE_USE_CODE = 'BILL_TO'
        AND CS.ORG_ID = hdr.org_id
        AND rownum < 2;


    l_cust_cntct_addr  VARCHAR2(4000);

    BEGIN
      OPEN  cust_cntct_addr_cur(p_party_roles_cle_id);
      FETCH cust_cntct_addr_cur
        INTO
          l_cust_cntct_addr;
      CLOSE  cust_cntct_addr_cur;

    RETURN l_cust_cntct_addr;
  END customer_contact_address;
--------------------------------------------------------------------------------

  FUNCTION covered_level_name(
    p_itm_jtot_obj1_arg VARCHAR2,
    p_itm_obj1_arg      VARCHAR2,
    p_itm_obj2_arg      VARCHAR2
  )
  RETURN VARCHAR2
  IS
    CURSOR party_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS
      select name
      from OKX_PARTIES_V
      where id1 = to_number(p_itm_obj1_arg) and id2 = p_itm_obj2_arg;
    CURSOR cust_accnt_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS
      select name
      from OKX_CUSTOMER_ACCOUNTS_V
      where id1 = to_number(p_itm_obj1_arg) and id2 = p_itm_obj2_arg;
    CURSOR cust_prod_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS
       select MTL.concatenated_segments
       from MTL_SYSTEM_ITEMS_KFV MTL,
           CSI_ITEM_INSTANCES CSI
       where csi.instance_id =  p_itm_obj1_arg
       and mtl.inventory_item_id = csi.inventory_item_id
       and mtl.organization_id =csi.inv_master_organization_id;

    CURSOR coverage_item_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS

      select concatenated_segments
      from MTL_SYSTEM_ITEMS_KFV
      where
        inventory_item_id = to_number(p_itm_obj1_arg)
        and organization_id = to_number(p_itm_obj2_arg)
        and serviceable_product_flag='Y';
    CURSOR coverage_system_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS
      select name
      from  CS_SYSTEMS_ALL_TL
      where system_id = to_number(p_itm_obj1_arg)
      and   language = userenv('lang');

    CURSOR coverage_site_cur(
      p_itm_obj1_arg VARCHAR2,
      p_itm_obj2_arg VARCHAR2
    )
    IS
      select party_site_number||'-'||name
      from OKX_PARTY_SITES_V
      where
        id1 = to_number(p_itm_obj1_arg)
        and id2 = p_itm_obj2_arg;

    l_name VARCHAR(450) := p_itm_jtot_obj1_arg;

    BEGIN
      IF p_itm_jtot_obj1_arg = 'OKX_PARTY'
      THEN
        OPEN  party_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH party_cur
        INTO  l_name;
        CLOSE party_cur;
      ELSIF p_itm_jtot_obj1_arg = 'OKX_CUSTACCT'
      THEN
        OPEN  cust_accnt_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH cust_accnt_cur
        INTO  l_name;
        CLOSE cust_accnt_cur;
      ELSIF p_itm_jtot_obj1_arg = 'OKX_CUSTPROD'
      THEN
        OPEN  cust_prod_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH cust_prod_cur
        INTO  l_name;
        CLOSE cust_prod_cur;
      ELSIF p_itm_jtot_obj1_arg = 'OKX_COVITEM'
      THEN
        OPEN  coverage_item_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH coverage_item_cur
        INTO  l_name;
        CLOSE coverage_item_cur;
      ELSIF p_itm_jtot_obj1_arg = 'OKX_COVSYST'
      THEN
        OPEN  coverage_system_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH coverage_system_cur
        INTO  l_name;
        CLOSE coverage_system_cur;
      ELSIF p_itm_jtot_obj1_arg = 'OKX_PARTYSITE'
      THEN
        OPEN  coverage_site_cur(p_itm_obj1_arg ,p_itm_obj2_arg);
        FETCH coverage_site_cur
        INTO  l_name;
        CLOSE coverage_site_cur;
      END IF;
    RETURN l_name;
  END covered_level_name;

----------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: line_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Line Details JSP.
  ||     This procedure is used to retrieve the Line information for a given Line and
  ||     also the Covered Levels and Customer Contacts information for the Line.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_line_id_arg -- Line ID
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_line_hdr_rec_type      -- Record that contains all the Line information
  ||     x_covered_level_tbl_type -- Table that contains all the Covered Levels information
  ||                                 for the given Line
  ||     x_cust_contacts_tbl_type -- Table that contains all the Customer Contacts information
  ||                                 for the given Line
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE line_overview(
    p_line_id_arg            IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_line_hdr_rec_type      OUT NOCOPY OKS_ENTITLEMENTS_WEB.line_hdr_rec_type,
    x_covered_level_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.covered_level_tbl_type,
    x_cust_contacts_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.cust_contacts_tbl_type
  )
  IS
    CURSOR line_renewal_cur(p_line_id_arg VARCHAR2)
    IS
      Select
        Fnd.Meaning RenewalType
      From
        OKC_K_LINES_B okcLn,
        FND_LOOKUPS Fnd
      Where
        okcLn.ID = to_number(p_line_id_arg)
        And Fnd.Lookup_Code = okcLn.LINE_RENEWAL_TYPE_CODE
        And Fnd.Lookup_Type = 'OKC_LINE_RENEWAL_TYPE';

    CURSOR line_amount_cur(p_line_id_arg VARCHAR2)
    IS
      Select  nvl(sum(line.PRICE_NEGOTIATED),0) LineAmount, line.currency_code Denomination
      From OKC_K_LINES_B line
      Where line.CLE_ID =  to_number(p_line_id_arg)
      Group By line.currency_code;

    CURSOR line_invoice_cur(p_line_id_arg VARCHAR2)
    IS

      /* Select
        oksLnTL.INVOICE_TEXT InvoiceText,
        oksLnB.INV_PRINT_FLAG InvoicePrintFlg
      From
        OKS_K_LINES_TL oksLnTL, OKS_K_LINES_B oksLnB
      Where
        oksLnB.Cle_Id = to_number(p_line_id_arg)
        And oksLnTL.ID = oksLnB.ID; */

      -- Bug Fix #4449290
      Select
        oksLnTL.INVOICE_TEXT InvoiceText
       ,fnd.MEANING InvoicePrintFlg
      From
        OKS_K_LINES_TL oksLnTL
       ,OKS_K_LINES_B oksLnB
       ,FND_LOOKUPS fnd
      Where oksLnB.Cle_Id = to_number(p_line_id_arg)
        And oksLnTL.ID = oksLnB.ID
        And language = userenv('LANG')
        And fnd.LOOKUP_TYPE = 'OKS_Y_N'
        And fnd.LOOKUP_CODE =  DECODE(oksLnB.INV_PRINT_FLAG,'N','N','Y') ;

    CURSOR line_tax_cur(p_line_id_arg VARCHAR2)
    IS

        Select oksLn.tax_classification_code TaxCode
               ,lok.meaning TaxStatus
               ,oksLn.EXEMPT_CERTIFICATE_NUMBER TaxExcemptCertificate
               ,oksLn.EXEMPT_REASON_CODE TaxExcemptCode
        From   OKS_K_LINES_B oksLn,
               FND_LOOKUPS  lok
        Where  oksLn.Cle_Id = to_number(p_line_id_arg)
        and    lok.lookup_type      =  'ZX_EXEMPTION_CONTROL'
        and    lok.lookup_code      =  oksLn.tax_status;

     /* Select
        oksLn.TAX_STATUS TaxStatusCode,
        lok.NAME  TaxStatus,
        to_char(oksLn.TAX_EXEMPTION_ID) TaxExcemptCode,
        tcd.NAME TaxCode
      From
        OKX_TAX_CODES_V tcd,
        OKX_LOOKUPS_V lok,
        OKS_K_LINES_B oksLn
      Where
        oksLn.Cle_Id = to_number(p_line_id_arg)
        and lok.Lookup_Code = oksLn.TAX_STATUS
        and lok.Lookup_type = 'TAX_CONTROL_FLAG'
        and oksLn.TAX_CODE = tcd.Id1(+); */
/*
    CURSOR line_coverage_cur(p_line_id_arg VARCHAR2)
    IS
      Select
        ln.ID CoverageLineID,
        ln.NAME CoverageName,
        ln.ITEM_DESCRIPTION CoverageDescription,
        ln.START_DATE CoverageStartDate,
        ln.END_DATE CoverageEndDate,
        decode(ln.lse_id,15,'Y','N') Warranty_YN
      From
        OKC_K_LINES_V ln
      Where
        ln.CLE_ID = to_number(p_line_id_arg)
        and ln.LSE_ID in (2,15,20);
*/
-- SPANIGRA: Added in R12 as per Coverage Rearchitecture design
    CURSOR line_coverage_cur(p_line_id_arg VARCHAR2)
    IS
      select
        oks.coverage_ID CoverageLineID,
        cov.NAME CoverageName,
        cov.ITEM_DESCRIPTION CoverageDescription,
        ln.START_DATE CoverageStartDate,
        ln.END_DATE CoverageEndDate,
        decode(cov.lse_id,15,'Y','N') Warranty_YN
      From
        OKC_K_LINES_b ln,
        OKS_K_LINES_b oks,
        OKC_K_LINES_V cov
      Where
        ln.ID = to_number(p_line_id_arg)
        and ln.id = oks.cle_id
        and cov.id = oks.coverage_id
        and cov.LSE_ID in (2,15,20);

    CURSOR line_coverage_sub_cur(p_coverage_id NUMBER)
    IS
      Select cvt.MEANING CoverageType
      From
        OKS_COV_TYPES_V cvt,
        OKS_K_LINES_B   oksLn
      Where
        oksLn.CLE_ID = p_coverage_id
        and cvt.CODE = oksLn.COVERAGE_TYPE;
/*
    CURSOR line_excep_coverage_cur(p_line_id_arg VARCHAR2)
    IS
      Select
        ln_c.ID CoverageID,
        to_char(oksLn.EXCEPTION_COV_ID) ExcCoverageLineID,
        ln.NAME ExcCoverageName,
        ln.item_description Description,
        ln.START_DATE StartDate,
        ln.END_DATE EndDate,
        decode(ln.lse_id,15,'Y','N') Warranty_YN
      From
        OKC_K_LINES_V ln,
        OKC_K_LINES_B ln_c,
        OKS_K_LINES_B oksLn
      Where
        ln_c.CLE_ID = to_number(p_line_id_arg) and
        ln.LSE_ID in (2,15,20)
        and oksLn.CLE_ID = ln_c.ID
        and ln.ID = oksLn.EXCEPTION_COV_ID;
*/
-- SPANIGRA: R12 - Modified due to COverage Rearchitecture design
    CURSOR line_excep_coverage_cur(p_line_id_arg VARCHAR2)
    IS
     SELECT
        oksrv.Coverage_ID CoverageID,
        to_char(okscov.EXCEPTION_COV_ID) ExcCoverageLineID,
        expcov.NAME ExcCoverageName,
        expcov.item_description Description,
        expcov.START_DATE StartDate,
        expcov.END_DATE EndDate,
        decode(expcov.lse_id,15,'Y','N') Warranty_YN
      from
           okc_k_lines_b srv,
           oks_k_lines_b oksrv,
           oks_k_lines_b okscov,
           okc_k_lines_v expcov
     Where srv.id = to_number(p_line_id_arg)
     AND srv.id = oksrv.cle_id
     AND oksrv.coverage_id = okscov.cle_id
     AND okscov.EXCEPTION_COV_ID = expcov.id;


    CURSOR line_excep_cov_type_cur(p_excep_coverage_type_id VARCHAR2)
    IS
     Select
        cvt.MEANING CoverageType
      From
        OKS_COV_TYPES_V cvt,
        OKS_K_LINES_B oksLn
      Where
        oksLn.CLE_ID = p_excep_coverage_type_id
        and cvt.CODE = oksLn.COVERAGE_TYPE;

    CURSOR covered_level_period_cur(p_period_unit VARCHAR)
    IS
      /*Bug #6140663 - fp of 6026318*/
      SELECT unit_of_measure_tl
      FROM mtl_units_of_measure_tl
      WHERE uom_code = p_period_unit
      AND language = userenv('LANG');

      /*SELECT fndLkups.meaning
      FROM   fnd_lookups fndLkups
      WHERE  fndLkups.lookup_code = p_period_unit
             and fndLkups.lookup_type = 'EGO_SRV_DURATION_PERIOD';*/

    CURSOR covered_level_cur(p_line_id_arg VARCHAR2)
    IS
      /* Select
        ln.ID  CoveredLevelId,
        ln.LSE_ID lseID,
        lnp.LINE_NUMBER||'.'||ln.LINE_NUMBER LineNumber,
        ln.START_DATE  StartDate,
        ln.END_DATE EndDate,
        ln.DATE_TERMINATED Terminated,
        decode (
          itm.JTOT_OBJECT1_CODE,
          'OKX_CUSTPROD',
          'Covered Product',
          'OKX_COVITEM',
          'Covered Item',
          'OKX_PARTYSITE',
          'Covered Site',
          'OKX_COVSYST',
          'Covered System',
          'OKX_CUSTACCT',
          'Covered Customer',
          'OKX_PARTY',
          'Covered Party',
          itm.JTOT_OBJECT1_CODE
        ) Coverage,
        itm.object1_id1 ObjId1,
        itm.object1_id2 ObjId2,
        itm.JTOT_OBJECT1_CODE JtotObj
      From
        okc_k_items itm,
        okc_k_lines_b ln,
        okc_k_lines_b lnp
      where
        lnp.ID = to_number(p_line_id_arg)
        and ln.cle_id = lnp.ID
        and ln.lse_id in (7,8,9,10,11,18,25,35)
        and itm.cle_id = ln.id; */

        -- Remove hard coded string for covered level

        Select
        ln.ID  CoveredLevelId,
        ln.LSE_ID lseID,
        lnp.LINE_NUMBER||'.'||ln.LINE_NUMBER LineNumber,
        ln.START_DATE  StartDate,
        ln.END_DATE EndDate,
        ln.DATE_TERMINATED Terminated,
        style.name Coverage,
        itm.object1_id1 ObjId1,
        itm.object1_id2 ObjId2,
        itm.JTOT_OBJECT1_CODE JtotObj
      From
        okc_k_items itm,
        okc_k_lines_b ln,
        okc_k_lines_b lnp,
        okc_line_styles_tl style
      where
        lnp.ID = to_number(p_line_id_arg)
        and ln.cle_id = lnp.ID
        and ln.lse_id in (7,8,9,10,11,18,25,35)
        and itm.cle_id = ln.id
        and style.id = ln.lse_id
        and style.language = userenv('LANG');

    CURSOR covered_level_sub_cur(p_covered_level_id NUMBER)
    IS
      Select
        Fnd.Meaning RenewalType
      From
        OKC_K_LINES_B okcLn,
        FND_LOOKUPS Fnd
      Where
        okcLn.Id = p_covered_level_id
        AND Fnd.Lookup_Code = okcLn.LINE_RENEWAL_TYPE_CODE
        And Fnd.Lookup_Type = 'OKC_LINE_RENEWAL_TYPE';

    CURSOR customer_contacts_cur(p_line_id_arg VARCHAR2)
    IS

      /* Select
        rol.CLE_ID ContractLineID,
        con.role Role,
        con.START_DATE StartDate,
        con.END_DATE EndDate,
        OKC_UTIL.GET_NAME_FROM_JTFV(con.jtot_object1_code,con.object1_id1,con.object1_id2) ContactName
      from
        OKC_CONTACTS_V con,
        OKC_K_PARTY_ROLES_B rol,
        OKC_K_LINES_B ln
      where
        ln.ID = to_number(p_line_id_arg)
        and rol.cle_id = ln.ID
        and rol.dnz_chr_id  = ln.dnz_chr_id
        and con.CPL_ID = rol.ID; */


        SELECT    FNDCONT.MEANING Role,
                  HZP.PARTY_NAME ContactName,
                  CONT.START_DATE StartDate,
                  CONT.END_DATE EndDate,
                  PR.CLE_ID ContractLineID
        FROM   OKC_K_LINES_B LINE,
               OKC_K_PARTY_ROLES_B PR,
               FND_LOOKUPS FNDCONT,
               OKC_CONTACTS CONT,
               HZ_PARTIES HZP,
               HZ_RELATIONSHIPS HZR,
               HZ_CUST_ACCOUNT_ROLES ACCROLE

        WHERE LINE.ID =   to_number(p_line_id_arg)
        AND PR.CLE_ID =  LINE.ID
        AND PR.DNZ_CHR_ID = LINE.DNZ_CHR_ID
        AND PR.RLE_CODE IN ('CUSTOMER','THIRD_PARTY','SUBSCRIBER')
        AND CONT.CRO_CODE = FNDCONT.LOOKUP_CODE
        AND CONT.JTOT_OBJECT1_CODE IN ('OKX_CONTADMN','OKX_CONTBILL','OKX_CONTSHIP','OKX_CONTTECH')
        AND FNDCONT.LOOKUP_TYPE = 'OKC_CONTACT_ROLE'
        AND PR.ID = CONT.CPL_ID
        AND TO_NUMBER(CONT.OBJECT1_ID1) = ACCROLE.CUST_ACCOUNT_ROLE_ID
        AND ACCROLE.PARTY_ID = HZR.PARTY_ID
        AND ACCROLE.ROLE_TYPE = 'CONTACT'
        AND HZR.RELATIONSHIP_CODE IN ('CONTACT_OF','EMPLOYEE_OF')
        AND HZR.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
        AND HZR.SUBJECT_ID = HZP.PARTY_ID  ;

    l_line_hdr_rec_type      OKS_ENTITLEMENTS_WEB.line_hdr_rec_type;
    l_covered_level_tbl_type OKS_ENTITLEMENTS_WEB.covered_level_tbl_type;
    l_cust_contacts_tbl_type OKS_ENTITLEMENTS_WEB.cust_contacts_tbl_type;

    l_covered_level_tbl_indx     NUMBER :=1;
    l_customer_contact_tbl_indx  NUMBER :=1;
    l_duration                   NUMBER;
    l_timeunit                   VARCHAR2(25);
    l_return_status              VARCHAR2(100);

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.line_overview',
                          'Inside line_overview : ' ||  ' ' ||
                          'p_line_id_arg :'   || p_line_id_arg);

      END IF;

      x_return_status := G_RET_STS_SUCCESS;

      OPEN  line_renewal_cur(p_line_id_arg);
      FETCH line_renewal_cur
      INTO  l_line_hdr_rec_type.renewal_type;
      CLOSE line_renewal_cur;

      OPEN  line_amount_cur(p_line_id_arg);
      FETCH line_amount_cur
      INTO
        l_line_hdr_rec_type.line_amount,
        l_line_hdr_rec_type.line_amount_denomination;
      CLOSE line_amount_cur;

      OPEN  line_invoice_cur(p_line_id_arg);
      FETCH line_invoice_cur
      INTO
        l_line_hdr_rec_type.invoice_text,
        l_line_hdr_rec_type.invoice_print_flag;
      CLOSE line_invoice_cur;

      OPEN  line_tax_cur(p_line_id_arg);
      FETCH line_tax_cur
      INTO
        l_line_hdr_rec_type.tax_status_code,
        l_line_hdr_rec_type.tax_status,
        l_line_hdr_rec_type.tax_exempt_code,
        l_line_hdr_rec_type.tax_code;
      CLOSE line_tax_cur;

      OPEN  line_coverage_cur(p_line_id_arg);
      FETCH line_coverage_cur
      INTO
        l_line_hdr_rec_type.coverage_id,
        l_line_hdr_rec_type.coverage_name,
        l_line_hdr_rec_type.coverage_description,
        l_line_hdr_rec_type.coverage_start_date,
        l_line_hdr_rec_type.coverage_end_date,
        l_line_hdr_rec_type.coverage_warranty_yn;
      CLOSE line_coverage_cur;

      OPEN line_coverage_sub_cur(l_line_hdr_rec_type.coverage_id);
      FETCH line_coverage_sub_cur
      INTO
        l_line_hdr_rec_type.coverage_type;
      CLOSE line_coverage_sub_cur;

      OPEN  line_excep_coverage_cur(p_line_id_arg);
      FETCH line_excep_coverage_cur
      INTO
        l_line_hdr_rec_type.exception_cov_id,
        l_line_hdr_rec_type.exception_cov_line_id,
        l_line_hdr_rec_type.exception_cov_name,
        l_line_hdr_rec_type.exception_cov_description,
        l_line_hdr_rec_type.exception_cov_start_date,
        l_line_hdr_rec_type.exception_cov_end_date,
        l_line_hdr_rec_type.exception_cov_warranty_yn;
      CLOSE line_excep_coverage_cur;

      OPEN  line_excep_cov_type_cur(l_line_hdr_rec_type.exception_cov_line_id);
      FETCH line_excep_cov_type_cur
      INTO  l_line_hdr_rec_type.exception_cov_type;
      CLOSE line_excep_cov_type_cur;
      BEGIN
        OKC_CONTEXT.set_okc_org_context;
        FOR j in covered_level_cur(p_line_id_arg)
        LOOP
          l_covered_level_tbl_type(l_covered_level_tbl_indx).line_number   := j.LineNumber;
          l_covered_level_tbl_type(l_covered_level_tbl_indx).covered_level := j.Coverage;
          l_covered_level_tbl_type(l_covered_level_tbl_indx).name          := covered_level_name(j.JtotObj, j.ObjId1 ,j.ObjId2);
          l_covered_level_tbl_type(l_covered_level_tbl_indx).start_date    := j.StartDate;
          l_covered_level_tbl_type(l_covered_level_tbl_indx).end_date      := j.EndDate;
          l_covered_level_tbl_type(l_covered_level_tbl_indx).terminated    := j.Terminated;

          OPEN  covered_level_sub_cur(j.CoveredLevelId);
          FETCH covered_level_sub_cur
          INTO
            l_covered_level_tbl_type(l_covered_level_tbl_indx).renewal_type;
          CLOSE covered_level_sub_cur;

          OKC_TIME_UTIL_PUB.get_duration(
            p_start_date    => j.StartDate,
            p_end_date      => j.EndDate,
            x_duration      => l_duration,
            x_timeunit      => l_timeunit,
            x_return_status => l_return_status
          );

          IF l_return_status = G_RET_STS_SUCCESS
          THEN
            l_covered_level_tbl_type(l_covered_level_tbl_indx).duration := l_duration;
            OPEN covered_level_period_cur(l_timeunit);
            FETCH covered_level_period_cur
              INTO
                l_covered_level_tbl_type(l_covered_level_tbl_indx).period;
            CLOSE covered_level_period_cur;
            --l_covered_level_tbl_type(l_covered_level_tbl_indx).period   := l_timeunit;
          ELSE
            x_return_status  := l_return_status ;
          END IF;

          l_covered_level_tbl_indx := l_covered_level_tbl_indx + 1;
        END LOOP;
      EXCEPTION
        WHEN
        OTHERS
          THEN
            x_return_status := 'ERROR IN lINE COVERED LEVELS';
      END;

      BEGIN
        OKC_CONTEXT.set_okc_org_context;
        FOR k IN customer_contacts_cur(p_line_id_arg)
        LOOP
          l_cust_contacts_tbl_type(l_customer_contact_tbl_indx).cust_contacts_role       := k.Role;
          l_cust_contacts_tbl_type(l_customer_contact_tbl_indx).cust_contacts_start_date := k.StartDate;
          l_cust_contacts_tbl_type(l_customer_contact_tbl_indx).cust_contacts_end_date   := k.EndDate;
          l_cust_contacts_tbl_type(l_customer_contact_tbl_indx).cust_contacts_name       := k.ContactName;
          l_cust_contacts_tbl_type(l_customer_contact_tbl_indx).cust_contacts_address    := customer_contact_address(k.ContractLineID);
          l_customer_contact_tbl_indx := l_customer_contact_tbl_indx +1;
        END LOOP;
      EXCEPTION
        WHEN
        OTHERS
          THEN
            x_return_status := 'ERROR IN LINE CUSTOMER CONTACT LEVELS::'||SQLerrm;
      END;

      x_line_hdr_rec_type      := l_line_hdr_rec_type;
      x_covered_level_tbl_type := l_covered_level_tbl_type;
      x_cust_contacts_tbl_type := l_cust_contacts_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END line_overview;
----------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: coverage_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Coverage Details JSP.
  ||     This procedure is used to retrieve the Coverage information for a given Coverage and
  ||     also the Business Processes information for the Coverage.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_ID_arg -- Contract ID of the Line to which the Coverage belongs
  ||     p_coverage_ID_arg -- Coverage ID
  ||
  || Out Parameters:
  ||     x_return_status     -- Success of the procedure.
  ||     x_coverage_rec_type -- Record that contains all the Coverage information
  ||     x_bus_proc_tbl_type -- Table that contains all the Business Processes information
  ||                            for the given Coverage
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE coverage_overview(
    p_coverage_ID_arg   IN  VARCHAR2,
    p_contract_ID_arg   IN  VARCHAR2,
    x_return_status	    OUT NOCOPY VARCHAR2,
    x_coverage_rec_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.coverage_rec_type,
    x_bus_proc_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_tbl_type
  )
  IS
    CURSOR  coverage_warranty_cur(p_coverage_ID_arg VARCHAR2)
    IS
      Select
        fnd.MEANING WarrantyInheritance
      From
        FND_LOOKUPS fnd,
        OKS_K_LINEs_B oksLn
      Where
        oksLn.CLE_ID = to_number(p_coverage_ID_arg)
        and fnd.LOOKUP_TYPE = 'OKSWHETYPE'
        and fnd.LOOKUP_CODE = oksLn.INHERITANCE_TYPE;

    CURSOR  coverage_rules_cur(p_coverage_ID_arg VARCHAR2)
    IS
      Select
        oksLn.PROD_UPGRADE_YN FreeUpgrade,
        Fnd.MEANING TransferAllowed
      From
        OKS_K_LINES_B oksLn,
        FND_LOOKUPS   Fnd
      Where
        oksLn.CLE_ID =  to_number(p_coverage_ID_arg)
        AND Fnd.lookup_code = oksLn.TRANSFER_OPTION
        AND Fnd.lookup_type='OKS_TRANSFER_OPTIONS';

    CURSOR  business_proc_name_cur(p_coverage_ID_arg VARCHAR2)
    IS
      Select
        ln.ID BusProcessID,
        bus.NAME Name
      From
        OKC_K_ITEMS itm,
        OKX_BUS_PROCESSES_V bus,
        OKC_K_LINES_V ln
      Where
        ln.CLE_ID = to_number(p_coverage_ID_arg)
        and ln.LSE_ID in (3,16 ,21)
        and ln.ID = itm.CLE_ID
        and itm.JTOT_OBJECT1_CODE = 'OKX_BUSIPROC'
        and bus.ID1 = itm.OBJECT1_ID1
        and bus.ID2 = itm.OBJECT1_ID2;

      CURSOR  business_proc_offset_cur(business_proc_id NUMBER)
      IS
        Select
          oksLn.OFFSET_DURATION OffSetDuration,
          Fnd.Meaning OffsetPeriod
        From
          OKS_K_LINES_B oksLn,
          FND_LOOKUPS Fnd
        Where
         --  oksLn.dnz_chr_id  = to_number(p_contract_ID_arg)
           oksLn.CLE_ID = business_proc_id
          and Fnd.lookup_type = 'EGO_SRV_DURATION_PERIOD'
          and Fnd.lookup_code = oksLn.OFFSET_PERIOD;

      CURSOR business_proc_price_cur(business_proc_id NUMBER)
      IS
        Select
          prl.NAME PriceList
        From
          OKX_LIST_HEADERS_V prl,
          OKC_K_LINES_v okCLn
        Where
          okcLn.ID = business_proc_id
          and prl.ID1 = okcLn.Price_list_id;

      CURSOR business_proc_discount_cur(business_proc_id NUMBER)
      IS
        Select
          dis.NAME Discount
        From
          OKX_LIST_HEADERS_V dis,
          OKS_K_LINES_B oksLn
        Where
          oksLn.CLE_ID = business_proc_id
          and dis.ID1 = oksLn.DISCOUNT_LIST;

      l_coverage_rec_type  OKS_ENTITLEMENTS_WEB.coverage_rec_type;
      l_bus_proc_tbl_type  OKS_ENTITLEMENTS_WEB.bus_proc_tbl_type;

      l_bus_proc_tbl_indx  NUMBER := 1;

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.coverage_overview',
                          'Inside coverage_overview : ' ||  ' ' ||
                          'p_coverage_ID_arg :'   || p_coverage_ID_arg || ' ' ||
                          'p_contract_ID_arg : '  || p_contract_ID_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      OPEN  coverage_warranty_cur(p_coverage_ID_arg);
      FETCH coverage_warranty_cur
      INTO  l_coverage_rec_type.coverage_wrrnty_inheritance;
      CLOSE coverage_warranty_cur;

      OPEN  coverage_rules_cur(p_coverage_ID_arg);
      FETCH coverage_rules_cur
      INTO  l_coverage_rec_type.free_upgrade, l_coverage_rec_type.transfer_allowed;
      CLOSE coverage_rules_cur;


      FOR k IN business_proc_name_cur(p_coverage_ID_arg)
      LOOP
        l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_id   := k.BusProcessID;
        l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_name := k.Name;

        OPEN  business_proc_price_cur(k.BusProcessID);
        FETCH business_proc_price_cur
        INTO  l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_price_list;
        CLOSE business_proc_price_cur;

        OPEN  business_proc_offset_cur(k.BusProcessID);
        FETCH business_proc_offset_cur
        INTO
          l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_offset_duration,
          l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_offset_period;
        CLOSE business_proc_offset_cur;

        OPEN  business_proc_discount_cur(k.BusProcessID);
        FETCH business_proc_discount_cur
        INTO  l_bus_proc_tbl_type(l_bus_proc_tbl_indx).bus_proc_discount;
        CLOSE business_proc_discount_cur;

        l_bus_proc_tbl_indx := l_bus_proc_tbl_indx +1;
      END LOOP;

      x_coverage_rec_type := l_coverage_rec_type;
      x_bus_proc_tbl_type := l_bus_proc_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END coverage_overview;
----------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: bus_proc_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Business Process Details JSP.
  ||     This procedure is used to retrieve the Business Process information for a
  ||     given Line Business Process also the Reaction Times, Resolution Times,
  ||     Billing Types, Coverage Times and Preferred Resources information for
  ||     the given Business Process.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_contract_ID_arg -- Contract ID of the Line to which the Coverage
  ||                          and to which the Business Process belongs.
  ||     p_bus_proc_ID_arg -- Business Processes ID
  ||
  || Out Parameters:
  ||     x_return_status             -- Success of the procedure.
  ||     x_bus_proc_hdr_rec_type     -- Record that contains all the Business Processes information
  ||     x_coverage_times_tbl_type   -- Table that contains all the Coverage Times information
  ||                                    for the given Business Processes
  ||     x_reaction_times_tbl_type   -- Table that contains all the Reaction Times information
  ||                                    for the given Business Processes
  ||     x_resolution_times_tbl_type -- Table that contains all the Resolution Times information
  ||                                    for the given Business Processes
  ||     x_pref_resource_tbl_type    -- Table that contains all the Preferred Resources information
  ||                                    for the given Business Processes
  ||     x_bus_proc_bil_typ_tbl_type -- Table that contains all the Billing Types information
  ||                                    for the given Business Processes
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE bus_proc_overview(
    p_bus_proc_ID_arg              IN  VARCHAR2,
    p_contract_ID_arg              IN  VARCHAR2,
    x_return_status	               OUT NOCOPY VARCHAR2,
    x_bus_proc_hdr_rec_type        OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_hdr_rec_type,
    x_coverage_times_tbl_type      OUT NOCOPY OKS_ENTITLEMENTS_WEB.coverage_times_tbl_type,
    x_reaction_times_tbl_type      OUT NOCOPY OKS_ENTITLEMENTS_WEB.reaction_times_tbl_type,
    x_resolution_times_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.resolution_times_tbl_type,
    x_pref_resource_tbl_type       OUT NOCOPY OKS_ENTITLEMENTS_WEB.pref_resource_tbl_type,
    x_bus_proc_bil_typ_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.bus_proc_bil_typ_tbl_type
  )
  IS
    CURSOR bus_proc_hdr_cur(p_bus_proc_ID_arg VARCHAR2)
    IS
      Select
        tmz.NAME TimeZone
      From
        OKS_COVERAGE_TIMEZONES cvr,
        OKX_TIMEZONES_V tmz
      Where
        cvr.CLE_ID = to_number(p_bus_proc_ID_arg)
        and tmz.TIMEZONE_ID = cvr.TIMEZONE_ID
       -- and rownum < 2;
        and default_yn = 'Y';

    CURSOR coverage_times_cur(p_bus_proc_ID_arg VARCHAR2)
    IS
      select decode(length(CovTImes.start_hour),1,'0' ||CovTImes.start_hour,CovTImes.start_hour) ||':'||
             decode(length(CovTImes.start_minute),1,CovTImes.start_minute || '0',CovTImes.start_minute) StartTime,
             decode(length(CovTImes.end_hour),1,'0' ||CovTImes.end_hour,CovTImes.end_hour) ||':'||
             decode(length(CovTImes.end_minute),1,CovTImes.end_minute || '0',CovTImes.end_minute) EndTime,
             CovTImes.Sunday_YN Sun,
             CovTImes.Monday_YN Mon,
             CovTImes.Tuesday_YN Tue,
             CovTImes.Wednesday_YN Wed,
             CovTImes.Thursday_YN Thr,
             CovTImes.Friday_YN Fri,
             CovTImes.Saturday_YN Sat
      from   oks_coverage_timeZones CovTimeZones,
             okx_timezones_v OkxTimeZones,
             oks_coverage_times CovTimes
      where  CovTimeZones.timezone_id = OkxTimeZones.timezone_id
             and CovTimeZones.cle_id = to_number(p_bus_proc_ID_arg)
             and CovTImes.COV_TZE_LINE_ID=CovTimeZones.id
             and CovTimeZones.default_yn = 'Y';

    CURSOR reaction_times_cur(p_bus_proc_ID_arg VARCHAR2)
    IS
      select IncidentSeverities.Name SeverityName,
             ServiceLines.react_time_name Severity,
             ServiceLines.work_thru_yn WorkThrough,
             ServiceLines.react_active_yn Active,
             ActTimes.uom_code UOM,
             NVL2 (ActTimes.sun_duration, (floor(ActTimes.sun_duration/60))||':'||decode(LENGTH(mod (ActTimes.sun_duration, 60)), 1, '0'||(mod (ActTimes.sun_duration, 60)), (mod (ActTimes.sun_duration, 60))), null ) Sunday,
             NVL2 (ActTimes.mon_duration, (floor(ActTimes.mon_duration/60))||':'||decode(LENGTH(mod (ActTimes.mon_duration, 60)), 1, '0'||(mod (ActTimes.mon_duration, 60)), (mod (ActTimes.mon_duration, 60))), null ) Monday,
             NVL2 (ActTimes.tue_duration, (floor(ActTimes.tue_duration/60))||':'||decode(LENGTH(mod (ActTimes.tue_duration, 60)), 1, '0'||(mod (ActTimes.tue_duration, 60)), (mod (ActTimes.tue_duration, 60))), null ) Tuesday,
             NVL2 (ActTimes.wed_duration, (floor(ActTimes.wed_duration/60))||':'||decode(LENGTH(mod (ActTimes.wed_duration, 60)), 1, '0'||(mod (ActTimes.wed_duration, 60)), (mod (ActTimes.wed_duration, 60))), null ) Wednesday,
             NVL2 (ActTimes.thu_duration, (floor(ActTimes.thu_duration/60))||':'||decode(LENGTH(mod (ActTimes.thu_duration, 60)), 1, '0'||(mod (ActTimes.thu_duration, 60)), (mod (ActTimes.thu_duration, 60))), null ) Thursday,
             NVL2 (ActTimes.fri_duration, (floor(ActTimes.fri_duration/60))||':'||decode(LENGTH(mod (ActTimes.fri_duration, 60)), 1, '0'||(mod (ActTimes.fri_duration, 60)), (mod (ActTimes.fri_duration, 60))), null ) Friday,
             NVL2 (ActTimes.sat_duration, (floor(ActTimes.sat_duration/60))||':'||decode(LENGTH(mod (ActTimes.sat_duration, 60)), 1, '0'||(mod (ActTimes.sat_duration, 60)), (mod (ActTimes.sat_duration, 60))), null ) Saturday
      from   oks_action_time_types ActTimeTypes,
             oks_action_times ActTimes,
             okc_k_lines_v CoreLines,
             oks_k_lines_v ServiceLines,
             OKX_INCIDENT_SEVERITS_V IncidentSeverities
      where  ActTimeTypes.cle_id = CoreLines.id
             and ActTimeTypes.action_type_code='RCN'
             and ActTimeTypes.cle_id = ActTimes.cle_id
             and ActTimeTypes.id = ActTimes.cov_action_type_id
             and ServiceLines.cle_id = CoreLines.id
             and IncidentSeverities.id1 = ServiceLines.incident_severity_id
             and CoreLines.cle_id = to_number(p_bus_proc_ID_arg);

    CURSOR resolution_times_cur(p_bus_proc_ID_arg VARCHAR2)
    IS
      select IncidentSeverities.Name SeverityName,
             ServiceLines.react_time_name Severity,
             ServiceLines.work_thru_yn WorkThrough,
             ServiceLines.react_active_yn Active,
             ActTimes.uom_code UOM,
             NVL2 (ActTimes.sun_duration, (floor(ActTimes.sun_duration/60))||':'||decode(LENGTH(mod (ActTimes.sun_duration, 60)), 1, '0'||(mod (ActTimes.sun_duration, 60)), (mod (ActTimes.sun_duration, 60))), null ) Sunday,
             NVL2 (ActTimes.mon_duration, (floor(ActTimes.mon_duration/60))||':'||decode(LENGTH(mod (ActTimes.mon_duration, 60)), 1, '0'||(mod (ActTimes.mon_duration, 60)), (mod (ActTimes.mon_duration, 60))), null ) Monday,
             NVL2 (ActTimes.tue_duration, (floor(ActTimes.tue_duration/60))||':'||decode(LENGTH(mod (ActTimes.tue_duration, 60)), 1, '0'||(mod (ActTimes.tue_duration, 60)), (mod (ActTimes.tue_duration, 60))), null ) Tuesday,
             NVL2 (ActTimes.wed_duration, (floor(ActTimes.wed_duration/60))||':'||decode(LENGTH(mod (ActTimes.wed_duration, 60)), 1, '0'||(mod (ActTimes.wed_duration, 60)), (mod (ActTimes.wed_duration, 60))), null ) Wednesday,
             NVL2 (ActTimes.thu_duration, (floor(ActTimes.thu_duration/60))||':'||decode(LENGTH(mod (ActTimes.thu_duration, 60)), 1, '0'||(mod (ActTimes.thu_duration, 60)), (mod (ActTimes.thu_duration, 60))), null ) Thursday,
             NVL2 (ActTimes.fri_duration, (floor(ActTimes.fri_duration/60))||':'||decode(LENGTH(mod (ActTimes.fri_duration, 60)), 1, '0'||(mod (ActTimes.fri_duration, 60)), (mod (ActTimes.fri_duration, 60))), null ) Friday,
             NVL2 (ActTimes.sat_duration, (floor(ActTimes.sat_duration/60))||':'||decode(LENGTH(mod (ActTimes.sat_duration, 60)), 1, '0'||(mod (ActTimes.sat_duration, 60)), (mod (ActTimes.sat_duration, 60))), null ) Saturday
      from   oks_action_time_types ActTimeTypes,
             oks_action_times ActTimes,
             okc_k_lines_v CoreLines,
             oks_k_lines_v ServiceLines,
             OKX_INCIDENT_SEVERITS_V IncidentSeverities
      where  ActTimeTypes.cle_id = CoreLines.id
             and ActTimeTypes.action_type_code='RSN'
             and ActTimeTypes.cle_id = ActTimes.cle_id
             and ActTimeTypes.id = ActTimes.cov_action_type_id
             and ServiceLines.cle_id = CoreLines.id
             and IncidentSeverities.id1 = ServiceLines.incident_severity_id
             and CoreLines.cle_id =  to_number(p_bus_proc_ID_arg);

      /*CURSOR pref_rsrcs_cur(p_bus_proc_ID_arg VARCHAR2, p_contract_ID_arg VARCHAR2)
      IS
        select
          pty.cle_id businessprocessid,
          pty.rle_code rlecode,
          con.role resourcetype,
          C.LAST_NAME name2
        from
          okc_contacts_v con,
          okc_k_party_roles_b pty ,
          JTF_RS_RESOURCE_EXTNS RSC ,
          PO_VENDOR_SITES_ALL S ,
          PO_VENDOR_CONTACTS C
        where
          pty.cle_id = to_number(p_bus_proc_ID_arg)
          and pty.dnz_chr_id = to_number(p_contract_ID_arg)
          and con.cpl_id = pty.id
          and con.jtot_object1_code ='okx_resource'
          AND con.object1_id1 = RSC.RESOURCE_ID
          AND con.object1_id2 = '#'
          AND RSC.CATEGORY = 'SUPPLIER_CONTACT'
          AND C.VENDOR_CONTACT_ID = RSC.SOURCE_ID
          AND S.VENDOR_SITE_ID = C.VENDOR_SITE_ID
          AND S.ORG_ID = sys_context('OKC_CONTEXT', 'ORG_ID')
        union all
        select
          pty.cle_id businessprocessid,
          pty.rle_code rlecode,
          con.role resourcetype,
          EMP.FULL_NAME name2
        from
          okc_contacts_v con,
          okc_k_party_roles_b pty ,
          JTF_RS_RESOURCE_EXTNS RSC ,
          FND_USER U ,
          OKX_PER_ALL_PEOPLE_V EMP
        where
          pty.cle_id = to_number(p_bus_proc_ID_arg)
          and pty.dnz_chr_id = to_number(p_contract_ID_arg)
          and con.cpl_id = pty.id
          and con.jtot_object1_code ='okx_resource'
          and RSC.CATEGORY = 'EMPLOYEE'
          AND EMP.PERSON_ID = RSC.SOURCE_ID
          AND U.USER_ID = RSC.USER_ID
          AND con.object1_id1 = RSC.RESOURCE_ID
          AND con.object1_id2 = '#'
        union all
        select
          pty.cle_id businessprocessid,
          pty.rle_code rlecode,
          con.role resourcetype,
          PARTY.PARTY_NAME name2
        from
          okc_contacts_v con,
          okc_k_party_roles_b pty ,
          JTF_RS_RESOURCE_EXTNS RSC ,
          FND_USER U ,
          HZ_PARTIES PARTY
        where
          pty.cle_id = to_number(p_bus_proc_ID_arg)
          and pty.dnz_chr_id = to_number(p_contract_ID_arg)
          and con.cpl_id = pty.id
          and con.jtot_object1_code ='okx_resource'
          AND RSC.CATEGORY IN ( 'PARTY', 'PARTNER')
          AND PARTY.PARTY_ID = RSC.SOURCE_ID
          AND U.USER_ID = RSC.USER_ID
          AND con.object1_id1 = RSC.RESOURCE_ID
          AND con.object1_id2 = '#'
        union all
        select
          pty.cle_id businessprocessid,
          pty.rle_code rlecode,
          con.role resourcetype,
          SRP.NAME name2
        from
          okc_contacts_v con,
          okc_k_party_roles_b pty ,
          JTF_RS_RESOURCE_EXTNS RSC ,
          FND_USER U ,
          JTF_RS_SALESREPS SRP
        where
          pty.cle_id = to_number(p_bus_proc_ID_arg)
          and pty.dnz_chr_id = to_number(p_contract_ID_arg)
          and con.cpl_id = pty.id
          and con.jtot_object1_code ='okx_resource'
          and RSC.CATEGORY = 'OTHER'
          AND SRP.RESOURCE_ID = RSC.RESOURCE_ID
          AND U.USER_ID = RSC.USER_ID
          AND SRP.ORG_ID = sys_context('OKC_CONTEXT', 'ORG_ID')
          AND con.object1_id1 = RSC.RESOURCE_ID
          AND con.object1_id2 = '#'; */


      CURSOR pref_rsrcs_cur(p_bus_proc_ID_arg VARCHAR2)
      IS
         SELECT  PartyRoles.cle_id businessprocessid
                 ,PartyRoles.rle_code rlecode
                 ,RoleLookup.meaning resourcetype
                 ,DECODE (RSC.CATEGORY
                 ,'SUPPLIER_CONTACT', DECODE(substr(vendor_contact.PERSON_FIRST_NAME,1,15),
                     NULL, substr(vendor_contact.PERSON_LAST_NAME,1,15),
                     substr(vendor_contact.PERSON_LAST_NAME,1,15)||', '||substr(vendor_contact.PERSON_FIRST_NAME,1,15))
                 ,'EMPLOYEE', employee.full_name
                 ,'PARTNER', hz_party.party_name
                 ,'PARTY', hz_party.party_name
                 ) name2

          FROM  OKC_K_LINES_B okcline,
               JTF_RS_RESOURCE_EXTNS RSC,
               OKC_CONTACTS Contacts,
               FND_LOOKUPS RoleLookup,
               OKC_K_PARTY_ROLES_B PartyRoles,
               AP_SUPPLIER_CONTACTS ap_supp_contact,
               HZ_PARTIES vendor_contact,
               PER_ALL_PEOPLE_F employee,
               HZ_PARTIES hz_party
          WHERE
               okcline.ID = to_number(p_bus_proc_ID_arg)
               AND PartyRoles.cle_id = okcline.ID
               AND  PartyRoles.dnz_chr_id = okcline.dnz_chr_id
               AND Contacts.cpl_id = PartyRoles.id
               AND Contacts.OBJECT1_ID1 = RSC.RESOURCE_ID
               AND Contacts.JTOT_OBJECT1_CODE ='OKX_RESOURCE'
               AND RoleLookup.lookup_type = 'OKC_CONTACT_ROLE'
               AND Contacts.CRO_CODE = RoleLookup.lookup_code
               AND RSC.SOURCE_ID = ap_supp_contact.vendor_contact_id (+)
               AND ap_supp_contact.PER_PARTY_ID = vendor_contact.party_id (+)
               AND RSC.SOURCE_ID = employee.person_id (+)
               AND trunc(sysdate)between employee.effective_start_date (+) AND employee.effective_end_date (+)
               AND RSC.SOURCE_ID = hz_party.PARTY_ID (+)
               UNION ALL
                 SELECT PartyRoles.cle_id businessprocessid
                ,PartyRoles.rle_code rlecode
                ,RoleLookup.meaning resourcetype
                ,resource_group.group_name name2
          FROM OKC_K_LINES_B okcline,
              JTF_RS_GROUPS_TL resource_group,
              OKC_CONTACTS Contacts,
              FND_LOOKUPS RoleLookup,
              OKC_K_PARTY_ROLES_B PartyRoles

          WHERE  okcline.ID = to_number(p_bus_proc_ID_arg)
              AND PartyRoles.cle_id = okcline.ID
              AND  PartyRoles.dnz_chr_id = okcline.dnz_chr_id
              AND Contacts.cpl_id = PartyRoles.id
              AND Contacts.OBJECT1_ID1 = resource_group.group_id
              AND Contacts.JTOT_OBJECT1_CODE ='OKS_RSCGROUP'
              AND resource_group.language = USERENV ('LANG')
              AND RoleLookup.lookup_type = 'OKC_CONTACT_ROLE'
              AND Contacts.CRO_CODE = RoleLookup.lookup_code;

      CURSOR bill_types_cur(p_bus_proc_ID_arg VARCHAR2)
      IS
        Select
          ln.CLE_ID BusinessProceeID,
          ln.ID BillTypeID,
          bil.NAME,
          trn.NAME||'-'||csl.meaning BillType,
          csl.MEANING,
          to_char(oksLn.DISCOUNT_AMOUNT) MaxAmount,
          to_char(oksLn.DISCOUNT_PERCENT) Per_Covered
        From
          CS_LOOKUPS csl,
          OKX_TRANSACTION_TYPES_V trn,
          OKX_TXN_BILLING_TYPES_V bil,
          OKC_K_ITEMS itm,
          OKC_K_LINES_B ln,
          OKS_K_LINES_B oksLn
        Where
          ln.CLE_ID = to_number(p_bus_proc_ID_arg)
          AND ln.LSE_ID in (5,23,59) -- Fix #4238239
          and itm.CLE_ID = ln.ID
          and itm.jtot_object1_code = 'OKX_BILLTYPE'
          and bil.ID1 = itm.OBJECT1_ID1
          and bil.ID2 = itm.OBJECT1_ID2
          and bil.TRANSACTION_TYPE_ID = trn.TRANSACTION_TYPE_ID
          and csl.LOOKUP_CODE = bil.BILLING_TYPE
          and csl.LOOKUP_TYPE   = 'MTL_SERVICE_BILLABLE_FLAG'
          and oksLn.Cle_Id = ln.ID;

      CURSOR bill_types_sub_cur(p_bill_type_id NUMBER)
      IS
        SELECT  fnd.meaning,
                mtl.UNIT_OF_MEASURE,
                bsh.FLAT_RATE,
                bsh.PERCENT_OVER_LIST_PRICE

        FROM   oks_billrate_schedules  bsh ,
               okc_k_lines_b lines,
               mtl_units_of_measure_tl mtl,
               fnd_lookups fnd
        WHERE  bsh.cle_id = lines.id
               and lines.lse_id in (6,24,60)
               and lines.cle_id = p_bill_type_id
               and mtl.UOM_CODE(+) =  bsh.UOM
               and mtl.language(+) = userenv('LANG')
               and fnd.lookup_type(+) = 'OKS_BILLING_RATE'
               and fnd.lookup_code(+) = bsh.bill_rate_code
               and bsh.holiday_yn = 'N';

    l_bus_proc_hdr_rec_type     OKS_ENTITLEMENTS_WEB.bus_proc_hdr_rec_type;
    l_coverage_times_tbl_type   OKS_ENTITLEMENTS_WEB.coverage_times_tbl_type;
    l_reaction_times_tbl_type   OKS_ENTITLEMENTS_WEB.reaction_times_tbl_type;
    l_resolution_times_tbl_type OKS_ENTITLEMENTS_WEB.resolution_times_tbl_type;
    l_pref_resource_tbl_type    OKS_ENTITLEMENTS_WEB.pref_resource_tbl_type;
    l_bus_proc_bil_typ_tbl_type OKS_ENTITLEMENTS_WEB.bus_proc_bil_typ_tbl_type;

    l_coverage_times_tbl_indx   NUMBER := 1;
    l_reaction_times_tbl_indx   NUMBER := 1;
    l_resolution_times_tbl_indx NUMBER := 1;
    l_pref_resource_tbl_indx    NUMBER := 1;
    l_bus_proc_billing_tbl_indx NUMBER := 1;
    l_previous_reaction_id      NUMBER := 1;
    l_previous_resolution_id    NUMBER := 1;

    BEGIN

       IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.bus_proc_overview',
                          'Inside bus_proc_overview : ' ||  ' ' ||
                          'p_bus_proc_ID_arg :'   || p_bus_proc_ID_arg|| ' ' ||
                          'p_contract_ID_arg : '  || p_contract_ID_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      OPEN bus_proc_hdr_cur(p_bus_proc_ID_arg);
      FETCH bus_proc_hdr_cur
      INTO l_bus_proc_hdr_rec_type.bus_proc_hdr_time_zone;
      CLOSE bus_proc_hdr_cur;

      FOR i in coverage_times_cur(p_bus_proc_ID_arg)
      LOOP
        LOOP
          IF(l_coverage_times_tbl_indx=1)
          THEN
            IF(i.Sun='Y') OR (i.Sun='y')
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Sunday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=2)
          THEN
            IF((i.Mon='Y') OR (i.Mon='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Monday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=3)
          THEN
            IF((i.Tue='Y') OR (i.Tue='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Tuesday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=4)
          THEN
            IF((i.Wed='Y') OR (i.Wed='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Wednesday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=5)
          THEN
            IF((i.Thr='Y') OR (i.Thr='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Thursday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=6)
          THEN
            IF((i.Fri='Y') OR (i.Fri='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Friday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          ELSIF(l_coverage_times_tbl_indx=7)
          THEN
            IF((i.Sat='Y') OR (i.Sat='y'))
            THEN
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).day_of_week := 'Saturday';
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).start_time := i.StartTime;
              l_coverage_times_tbl_type(l_coverage_times_tbl_indx).end_time := i.EndTime;
            END IF;
          END IF;
          l_coverage_times_tbl_indx := l_coverage_times_tbl_indx + 1;
          EXIT WHEN l_coverage_times_tbl_indx > 7;
        END LOOP;
         l_coverage_times_tbl_indx :=1;
      END LOOP;

      FOR j in reaction_times_cur(p_bus_proc_ID_arg)
      LOOP
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).name         := j.SeverityName;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).severity     := j.Severity;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).work_thru_yn := j.WorkThrough;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).active_yn    := j.Active;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).sun          := j.Sunday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).mon          := j.Monday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).tue          := j.Tuesday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).wed          := j.Wednesday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).thr          := j.Thursday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).fri          := j.Friday;
        l_reaction_times_tbl_type(l_reaction_times_tbl_indx).sat          := j.Saturday;

        l_reaction_times_tbl_indx := l_reaction_times_tbl_indx + 1;
      END LOOP;

      FOR n in resolution_times_cur(p_bus_proc_ID_arg)
      LOOP
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).name         := n.SeverityName;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).severity     := n.Severity;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).work_thru_yn := n.WorkThrough;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).active_yn    := n.Active;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).sun          := n.Sunday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).mon          := n.Monday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).tue          := n.Tuesday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).wed          := n.Wednesday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).thr          := n.Thursday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).fri          := n.Friday;
        l_resolution_times_tbl_type(l_resolution_times_tbl_indx).sat          := n.Saturday;

        l_resolution_times_tbl_indx := l_resolution_times_tbl_indx + 1;
      END LOOP;

      FOR k in pref_rsrcs_cur(p_bus_proc_ID_arg)
      LOOP
        l_pref_resource_tbl_type(l_pref_resource_tbl_indx).resource_type := k.ResourceType;
        l_pref_resource_tbl_type(l_pref_resource_tbl_indx).name := k.Name2;

        l_pref_resource_tbl_indx := l_pref_resource_tbl_indx + 1;
      END LOOP;

      FOR l in bill_types_cur(p_bus_proc_ID_arg)
      LOOP
        l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).bill_type   := l.BillType;
        l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).max_amount  := l.MaxAmount;
        l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).per_covered := l.Per_Covered;

        OPEN  bill_types_sub_cur(l.BillTypeID);
        FETCH bill_types_sub_cur
        INTO
          l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).billing_rate,
          l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).unit_of_measure,
          l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).flat_rate,
          l_bus_proc_bil_typ_tbl_type(l_bus_proc_billing_tbl_indx).per_over_list_price;
        CLOSE bill_types_sub_cur;

        l_bus_proc_billing_tbl_indx := l_bus_proc_billing_tbl_indx + 1;
      END LOOP;

      x_bus_proc_hdr_rec_type     := l_bus_proc_hdr_rec_type;
      x_coverage_times_tbl_type   := l_coverage_times_tbl_type;
      x_reaction_times_tbl_type   := l_reaction_times_tbl_type;
      x_resolution_times_tbl_type := l_resolution_times_tbl_type;
      x_pref_resource_tbl_type    := l_pref_resource_tbl_type;
      x_bus_proc_bil_typ_tbl_type := l_bus_proc_bil_typ_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END bus_proc_overview;
----------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: usage_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Usage Details JSP.
  ||     This procedure is used to retrieve the Usage information for a given Usage Line and
  ||     also the Covered Products information for the Usage.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_line_id_arg -- Line ID
  ||
  || Out Parameters:
  ||     x_return_status          -- Success of the procedure.
  ||     x_usage_hdr_rec_type     -- Record that contains all the Usage Line information
  ||     x_covered_prods_tbl_type -- Table that contains all the Covered Products information
  ||                                 for the given Line
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE usage_overview(
    p_line_id_arg            IN  VARCHAR2,
    x_return_status	         OUT NOCOPY VARCHAR2,
    x_usage_hdr_rec_type     OUT NOCOPY OKS_ENTITLEMENTS_WEB.usage_hdr_rec_type,
    x_covered_prods_tbl_type OUT NOCOPY OKS_ENTITLEMENTS_WEB.covered_prods_tbl_type
  )
  IS
    CURSOR usage_invoice_cur(p_line_id_arg VARCHAR2)
    IS
    /*  Select oksLn.INVOICE_TEXT InvoiceText,
             oksLn.INV_PRINT_FLAG InvoicePrintFlg
      From   OKS_K_LINES_V oksLn
      Where  oksLn.Cle_Id = to_number(p_line_id_arg); */

      Select
        oksLnTL.INVOICE_TEXT InvoiceText
       ,fnd.MEANING InvoicePrintFlg
      From
        OKS_K_LINES_TL oksLnTL
       ,OKS_K_LINES_B oksLnB
       ,FND_LOOKUPS fnd
      Where oksLnB.Cle_Id = to_number(p_line_id_arg)
        And oksLnTL.ID = oksLnB.ID
        And language = userenv('LANG')
        And fnd.LOOKUP_TYPE = 'OKS_Y_N'
        And fnd.LOOKUP_CODE =  DECODE(oksLnB.INV_PRINT_FLAG,'N','N','Y') ;

    CURSOR usage_amount_cur(p_line_id_arg VARCHAR2)
    IS
      Select nvl(sum(line.PRICE_NEGOTIATED),0) LineAmount
      From OKC_K_LINES_B line
      Where line.CLE_ID =  to_number(p_line_id_arg);

    CURSOR get_orgId(p_line_id VARCHAR2)
    IS
     Select hdr.org_id
     FROM   okc_k_lines_b ln,
            okc_k_headers_All_b hdr
     WHERE  ln.id  = to_number(p_line_id)
     AND    hdr.id = ln.dnz_chr_id;

    CURSOR usage_tax_cur(p_line_id_arg VARCHAR2)
    IS

        Select lok.meaning TaxStatus
               ,oksLn.tax_classification_code TaxCode
        From   OKS_K_LINES_B oksLn,
               FND_LOOKUPS  lok
        Where  oksLn.Cle_Id = to_number(p_line_id_arg)
        and    lok.lookup_type      =  'ZX_EXEMPTION_CONTROL'
        and    lok.lookup_code      =  oksLn.tax_status;

     /* Select
        lok.NAME  TaxStatus,
        tcd.NAME TaxCode
      From
        OKX_TAX_CODES_V tcd,
        OKX_LOOKUPS_V lok,
        OKS_K_LINES_B oksLn
      Where
        oksLn.Cle_Id = to_number(p_line_id_arg)
        and lok.Lookup_Code = oksLn.TAX_STATUS
        and lok.Lookup_type = 'TAX_CONTROL_FLAG'
        and oksLn.TAX_CODE = tcd.Id1(+); */

    CURSOR usage_hdr_cur(p_line_id_arg VARCHAR2)
    IS
      Select
        decode(to_char(oksLn.AVERAGING_INTERVAL),Null,'N','Y') AveragingAllowed,
        to_char(oksLn.AVERAGING_INTERVAL) AveragingInterval,
        decode(oksLn.SETTLEMENT_INTERVAL,1,'Y','N') SettlementAgainstActualUsage,
        decode(
          oksLn.USAGE_TYPE,
          'FRT',
          'Fixed Per Period',
          'VRT',
          'Actual Per Period',
          'QTY',
          'Actual By Quantity',
          'NPR',
          'Negotiated Price',
          oksLn.USAGE_TYPE
        )UsageType
      From
        OKX_UNITS_OF_MEASURE_V uom,
        OKS_K_LINES_B oksLn
      Where
        oksLn.CLE_ID = to_number(p_line_id_arg)
        and uom.UOM_CODE(+) = oksLn.USAGE_PERIOD;

    CURSOR covered_products_cur(p_line_id_arg VARCHAR2)
    IS
      SELECT sub_line.line_number          LineNumber,
             okcLnV.cognomen               LineRef,
             oksLnV.invoice_text           InvoiceText,
             rul.usage_period              Period,
             to_char(rul.minimum_quantity) Rate_Minimum,
             to_char(rul.default_quantity) Rate_Default,
             rul.amcv_flag                 AMCV_YN,
             to_char(rul.fixed_quantity)   Rate_Fixed,
             to_char(rul.usage_duration)   NoOf_TUOM_per,
             rul.level_yn                  Level_YN,
             mtl.Unit_of_measure           UOM,
             to_char(rul.base_reading)     NetReading,
             '#'                           Reading,
             sub_line.price_negotiated     Price,
             okcItms.object1_id1           ItemObject1_Id1
       FROM  OKC_K_LINES_B           sub_line,
             OKS_K_LINES_B           rul,
             OKC_K_LINES_V           okcLnV,
             OKS_K_LINES_V           oksLnV,
             OKC_K_ITEMS             okcItms,
             MTL_UNITS_OF_MEASURE_TL mtl
       WHERE sub_line.cle_id = to_number(p_line_id_arg)
             AND rul.cle_id = sub_line.id
             AND okcLnV.cle_id = sub_line.cle_id
             AND oksLnV.cle_id = sub_line.id
             AND sub_line.lse_id in (8,7,9,10,11,13,25,35)
             AND okcItms.cle_id = sub_line.id
             AND mtl.uom_code = okcItms.uom_code
             AND mtl.language = USERENV('LANG')
             AND not exists (select 1 from okc_k_rel_objs rel
                             WHERE rel.cle_id = sub_line.id );

    CURSOR covered_products_sub_cur(p_covered_prod_id VARCHAR2)
    IS

      /* Select
        sys.NAME  Name,
        cgrp.SOURCE_OBJECT_CODE||';'||cp.CURRENT_SERIAL_NUMBER||';'||cp.REFERENCE_NUMBER SourceDetails,
        sys.DESCRIPTION Description
      From
        OKX_SYSTEM_ITEMS_V sys,
        OKX_CUST_PROD_V cp,
        OKX_COUNTER_GROUPS_V cgrp,
        OKX_COUNTERS_V ct
      Where
        ct.ID1 = to_number(p_covered_prod_id)
        and  sys.ID1 = cp.INVENTORY_ITEM_ID
        and  sys.ID2 = okc_context.get_okc_organization_id
        and cgrp.COUNTER_GROUP_ID = ct.COUNTER_GROUP_ID
        and cgrp.SOURCE_OBJECT_ID = cp.CUSTOMER_PRODUCT_ID
        and cgrp.SOURCE_OBJECT_CODE = 'CP'
      UNION
      Select
        sys.NAME Name,
        cgrp.SOURCE_OBJECT_CODE||';'||hdr.CONTRACT_NUMBER||';'||hdr.CONTRACT_NUMBER_MODIFIER SourceDetails,
        sys.DESCRIPTION Description
      From
        OKX_SYSTEM_ITEMS_V sys,
        OKC_K_HEADERS_ALL_B hdr,
        OKC_K_ITEMS_V itm,
        OKC_K_LINES_B ln,
        OKX_COUNTER_GROUPS_V cgrp,
        OKX_COUNTERS_V ct
      Where
        ct.ID1 = to_number(p_covered_prod_id)
        and cgrp.counter_group_id = ct.counter_group_id
        and cgrp.source_object_code = 'CONTRACT_LINE'
        and cgrp.source_object_id = itm.cle_id
        and itm.object1_id1 = sys.id1
        and ln.ID = itm.CLE_ID
        and ln.CHR_ID = hdr.ID
        and sys.id2 = hdr.INV_ORGANIZATION_ID; */

     Select
       sys.concatenated_segments  Name,
       cca.SOURCE_OBJECT_CODE||';'||cp.SERIAL_NUMBER||';'||cp.INSTANCE_NUMBER SourceDetails,
       sys.DESCRIPTION Description
     From
       MTL_SYSTEM_ITEMS_B_KFV sys,
       CSI_ITEM_INSTANCES cp,
       CS_CSI_COUNTER_GROUPS CCG,
       csi_counters_b ccb,
       csi_counter_associations cca
     Where  ccb.COUNTER_ID = to_number(p_covered_prod_id)
       and  sys.INVENTORY_ITEM_ID = cp.INVENTORY_ITEM_ID
       and  sys.ORGANIZATION_ID =   cp.INV_MASTER_ORGANIZATION_ID
       AND  ccg.template_flag = 'N'
       AND ccg.counter_group_id = ccb.group_id
       AND ccb.counter_id = cca.counter_id
       and cca.SOURCE_OBJECT_CODE = 'CP'
       and cca.source_object_id = cp.instance_id
     UNION ALL
     Select
       sys.concatenated_segments  Name,
       cca.SOURCE_OBJECT_CODE||';'||hdr.CONTRACT_NUMBER||';'||hdr.CONTRACT_NUMBER_MODIFIER SourceDetails,
       sys.DESCRIPTION Description
     From
       MTL_SYSTEM_ITEMS_B_KFV sys,
       OKC_K_HEADERS_ALL_B hdr,
       OKC_K_ITEMS itm,
       OKC_K_LINES_B ln,
       CS_CSI_COUNTER_GROUPS CCG,
       csi_counters_b ccb,
       csi_counter_associations cca
     Where
       ccb.COUNTER_ID = to_number(p_covered_prod_id)
       and  ccg.template_flag = 'N'
       and ccg.counter_group_id = ccb.group_id
       and ccb.counter_id = cca.counter_id
       and cca.source_object_code = 'CONTRACT_LINE'
       and cca.source_object_id = itm.cle_id
       and itm.object1_id1 = sys.inventory_item_id
       and itm.object1_id2 = sys.organization_id
       and ln.ID = itm.CLE_ID
       and ln.DNZ_CHR_ID = hdr.ID
       AND ln.cle_ID IS NULL ;

    l_usage_hdr_rec_type     OKS_ENTITLEMENTS_WEB.usage_hdr_rec_type;
    l_covered_prods_tbl_type OKS_ENTITLEMENTS_WEB.covered_prods_tbl_type;

    l_covered_prod_tbl_indx NUMBER := 1;
    l_org_id  NUMBER;
    BEGIN

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.usage_overview',
                          'Inside Usage Overview : ' ||  ' ' ||
                          'p_line_id_arg :'   || p_line_id_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      OPEN  usage_hdr_cur(p_line_id_arg);
      FETCH usage_hdr_cur
      INTO
        l_usage_hdr_rec_type.usage_avg_allowed,
        l_usage_hdr_rec_type.usage_avg_interval,
        l_usage_hdr_rec_type.usage_avg_settlement_allowed,
        l_usage_hdr_rec_type.usage_type;
      CLOSE usage_hdr_cur;

      OPEN usage_invoice_cur(p_line_id_arg);
      FETCH usage_invoice_cur
      INTO
        l_usage_hdr_rec_type.usage_invoice_text,
        l_usage_hdr_rec_type.usage_invoice_print_flag;
      CLOSE usage_invoice_cur;

      OPEN usage_tax_cur(p_line_id_arg);
      FETCH usage_tax_cur
      INTO
        l_usage_hdr_rec_type.usage_tax_status,
        l_usage_hdr_rec_type.usage_tax_code;
      CLOSE usage_tax_cur;

      OPEN usage_amount_cur(p_line_id_arg);
      FETCH usage_amount_cur
      INTO  l_usage_hdr_rec_type.usage_amount;
      CLOSE usage_amount_cur;

      OPEN   get_orgId(p_line_id_arg);
      FETCH  get_orgId INTO l_org_id;
      CLOSE  get_orgId;

      FOR j IN covered_products_cur(p_line_id_arg)
      LOOP
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_ID           := j.ItemObject1_Id1;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_line_Number  := j.LineNumber;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_line_ref     := j.LineRef;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_invoice_text := j.InvoiceText;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_period       := j.Period;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_rate_minimum := j.Rate_Minimum;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_rate_default := j.Rate_Default;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_amcv         := j.AMCV_YN;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_rate_fixed   := j.Rate_Fixed;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_level_yn     := j.Level_YN;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_uom          := j.UOM;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_net_reading  := j.NetReading;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_reading      := j.Reading;
        l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_price        := j.Price;

        OPEN  covered_products_sub_cur(j.ItemObject1_Id1);
        FETCH covered_products_sub_cur
        INTO
          l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_name,
          l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_details,
          l_covered_prods_tbl_type(l_covered_prod_tbl_indx).covered_prod_description;
        CLOSE covered_products_sub_cur;

        l_covered_prod_tbl_indx := l_covered_prod_tbl_indx +1;
      END LOOP;

      x_usage_hdr_rec_type     := l_usage_hdr_rec_type;
      x_covered_prods_tbl_type := l_covered_prods_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END usage_overview;
----------------------------------------------------------------------------------

  /*
  ||==========================================================================
  || PROCEDURE: product_overview
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure is invoked in the Entitlement Product Details JSP.
  ||     This procedure is used to retrieve the Product information for a given Covered Product and
  ||     also the COunters information for the Covered Product.
  ||
  || Pre Conditions:
  ||
  || In Parameters:
  ||     p_covered_prod_ID_arg -- Covered Product ID
  ||
  || Out Parameters:
  ||     x_return_status    -- Success of the procedure.
  ||     x_counter_tbl_type -- Table that contains all the Counters information
  ||                           for the given Product
  ||
  || In Out Parameters:
  ||
  || Post Success:
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||==========================================================================
  */

  PROCEDURE product_overview(
    p_covered_prod_ID_arg IN  VARCHAR2,
    x_return_status	      OUT NOCOPY VARCHAR2,
    x_counter_tbl_type    OUT NOCOPY OKS_ENTITLEMENTS_WEB.counter_tbl_type
  )
  IS
    CURSOR counter_cur(p_covered_prod_ID_arg VARCHAR2)
    IS
      /* SELECT
             CG.NAME || '.' || CT.NAME name ,
             CT.TYPE type ,
             IT.NAME sourcedetails ,
             CII.SERIAL_NUMBER serialnumber ,
             CII.INSTANCE_NUMBER referencenumber,
             CT.UOM_CODE uom ,
             CT.NET_READING netreading ,
             CT.VALUE_TIMESTAMP timestamp
        FROM
             OKX_COUNTER_GROUPS_V CG ,
             OKX_COUNTERS_V CT ,
             CSI_ITEM_INSTANCES CII ,
             OKX_SYSTEM_ITEMS_V IT
       WHERE
             CG.COUNTER_GROUP_ID = CT.COUNTER_GROUP_ID
             AND CT.USAGE_ITEM_ID IS NOT NULL
             AND CG.SOURCE_OBJECT_ID = CII.INSTANCE_ID
             AND CG.SOURCE_OBJECT_CODE = 'CP'
             AND IT.ID1 = CII.INVENTORY_ITEM_ID
             AND IT.ORGANIZATION_ID = SYS_CONTEXT('OKC_CONTEXT', 'ORGANIZATION_ID')
             AND CT.COUNTER_ID = to_number(p_covered_prod_ID_arg)
       UNION
       SELECT
             CG.NAME || '.' || CT.NAME name ,
             CT.TYPE type ,
             KL.NAME|| '-' ||KH.CONTRACT_NUMBER sourcedetails ,
             NULL serialnumber ,
             NULL referencenumber ,
             CT.UOM_CODE uom ,
             CT.NET_READING netreading ,
             CT.VALUE_TIMESTAMP timestamp
       FROM
             OKX_COUNTER_GROUPS_V CG ,
             OKX_COUNTERS_V CT ,
             OKC_K_LINES_B KL ,
             OKC_K_HEADERS_ALL_B KH
       WHERE
             CG.COUNTER_GROUP_ID = CT.COUNTER_GROUP_ID
             AND CT.USAGE_ITEM_ID IS NOT NULL
             AND CG.SOURCE_OBJECT_ID = KL.ID
             AND CG.SOURCE_OBJECT_CODE = 'CONTRACT_LINE'
             AND KH.ID = KL.DNZ_CHR_ID
             AND CT.COUNTER_ID = to_number(p_covered_prod_ID_arg); */

      -- Bug Fix #5090507
      SELECT CCG.NAME || '.' || CCT.NAME name ,
             lkup.meaning type ,
             sys.concatenated_segments sourcedetails ,
             CII.SERIAL_NUMBER serialnumber ,
             CII.INSTANCE_NUMBER referencenumber,
             CCB.UOM_CODE uom ,
             CV.NET_READING netreading ,
             CV.VALUE_TIMESTAMP timestamp
        FROM   MTL_SYSTEM_ITEMS_B_KFV sys,
               CSI_ITEM_INSTANCES CII,
               CS_CSI_COUNTER_GROUPS CCG,
               csi_counters_b ccb,
               csi_counters_tl cct,
               csi_counter_associations cca,
               CSI_COUNTER_READINGS CV,
               csi_lookups lkup
     Where  ccb.COUNTER_ID = to_number(p_covered_prod_ID_arg)
       and  sys.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
       and  sys.ORGANIZATION_ID =  CII.INV_MASTER_ORGANIZATION_ID
       AND  ccg.template_flag = 'N'
       AND ccg.counter_group_id = ccb.group_id
       AND ccb.counter_id = cca.counter_id
       and cca.SOURCE_OBJECT_CODE = 'CP'
       and cca.source_object_id = cII.instance_id
       and CV.COUNTER_ID (+) = CCB.COUNTER_ID
       AND CV.COUNTER_VALUE_ID (+) = CSI_COUNTER_READINGS_PVT.get_latest_reading(CCB.COUNTER_ID)
       AND ccb.counter_id = cct.counter_id
       AND cct.language = USERENV('LANG')
       AND lkup.lookup_type = 'CSI_COUNTER_TYPE'
       AND ccb.counter_type = lkup.lookup_code
       UNION
       SELECT
             CCG.NAME || '.' || CCT.NAME name ,
             lkup.meaning type ,
             SYS.CONCATENATED_SEGMENTS || '-' ||KH.CONTRACT_NUMBER || KH.CONTRACT_NUMBER_MODIFIER sourcedetails ,
             NULL serialnumber ,
             NULL referencenumber,
             CCB.UOM_CODE uom ,
             CV.NET_READING netreading ,
             CV.VALUE_TIMESTAMP timestamp
       FROM  MTL_SYSTEM_ITEMS_B_KFV sys,
             CS_CSI_COUNTER_GROUPS CCG,
             csi_counters_b ccb,
             csi_counters_tl cct,
             csi_counter_associations cca,
             CSI_COUNTER_READINGS CV,
             csi_lookups lkup,
             OKC_K_ITEMS KI,
             OKC_K_LINES_B KL ,
             OKC_K_HEADERS_ALL_B KH
       WHERE sys.INVENTORY_ITEM_ID = KI.OBJECT1_ID1
       and  sys.ORGANIZATION_ID = KI.OBJECT1_ID2
       AND  ccg.template_flag = 'N'
       AND ccg.counter_group_id = ccb.group_id
       AND ccb.counter_id = cca.counter_id
       and cca.SOURCE_OBJECT_CODE = 'CONTRACT_LINE'
       and cca.source_object_id = KL.id
       and CV.COUNTER_ID (+) = CCB.COUNTER_ID
       AND CV.COUNTER_VALUE_ID (+) = CSI_COUNTER_READINGS_PVT.get_latest_reading(CCB.COUNTER_ID)
       AND ccb.counter_id = cct.counter_id
       AND cct.language = USERENV('LANG')
       AND lkup.lookup_type = 'CSI_COUNTER_TYPE'
       AND ccb.counter_type = lkup.lookup_code
       AND KH.ID = KL.DNZ_CHR_ID
       AND KL.ID = KI.CLE_ID
       AND KI.JTOT_OBJECT1_CODE IN('OKX_SERVICE','OKX_WARRANTY','OKX_USAGE')
       AND CCB.COUNTER_ID = to_number(p_covered_prod_ID_arg);

    l_counter_tbl_type  OKS_ENTITLEMENTS_WEB.counter_tbl_type;

    l_covered_prod_tbl_indx NUMBER := 1;

    BEGIN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.product_overview',
                          'Inside product_overview : ' ||  ' ' ||
                          'p_covered_prod_ID_arg :'   || p_covered_prod_ID_arg);

      END IF;
      x_return_status := G_RET_STS_SUCCESS;

      FOR j in counter_cur(p_covered_prod_ID_arg)
      LOOP
        l_counter_tbl_type(l_covered_prod_tbl_indx).counter_type := j.Type;
        l_counter_tbl_type(l_covered_prod_tbl_indx).counter_uom_code := j.UOM;
        l_counter_tbl_type(l_covered_prod_tbl_indx).counter_name := j.Name;
        l_counter_tbl_type(l_covered_prod_tbl_indx).counter_time_stamp := j.TimeStamp;
        l_counter_tbl_type(l_covered_prod_tbl_indx).counter_net_reading := j.NetReading;

        l_covered_prod_tbl_indx := l_covered_prod_tbl_indx + 1;
      END LOOP;

      x_counter_tbl_type := l_counter_tbl_type;

    EXCEPTION
      WHEN OTHERS
        THEN
	    OKC_API.set_message(
          p_app_name     => g_app_name_oks,
          p_msg_name     => g_unexpected_error,
          p_token1       => g_sqlcode_token,
          p_token1_value => SQLcode,
          p_token2       => g_sqlerrm_token,
          p_token2_value => SQLerrm
        );
        x_return_status := g_ret_sts_unexp_error;

  END product_overview;
----------------------------------------------------------------------------------
END OKS_ENTITLEMENTS_WEB;

/
