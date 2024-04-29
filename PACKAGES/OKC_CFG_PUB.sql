--------------------------------------------------------
--  DDL for Package OKC_CFG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CFG_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPCFGS.pls 120.0 2005/05/26 09:25:54 appldev noship $ */

-- ---------------------------------------------------------------------------
-- RECORD        : au_rec_type
-- PURPOSE       : The au record/table structure will instantiate any
--                 config related Contract Line information that is
--                 obtained from Authoring form OKCAUDET.fmx.
-- ---------------------------------------------------------------------------
TYPE au_rec_type IS RECORD (
     id                     NUMBER       := FND_API.G_MISS_NUM,
     cle_id                 NUMBER       := FND_API.G_MISS_NUM,
     dnz_chr_id             NUMBER       := FND_API.G_MISS_NUM,
     config_hdr_id          NUMBER       := FND_API.G_MISS_NUM,
     config_rev_nbr         NUMBER       := FND_API.G_MISS_NUM,
     qty                    NUMBER       := FND_API.G_MISS_NUM,
     uom_code               VARCHAR2(3)  := FND_API.G_MISS_CHAR,
     config_complete_yn     VARCHAR2(3)  := FND_API.G_MISS_CHAR,
     config_valid_yn        VARCHAR2(3)  := FND_API.G_MISS_CHAR,
     inventory_item_id      VARCHAR2(100):= FND_API.G_MISS_CHAR,
     config_cre_date        DATE         := FND_API.G_MISS_DATE,
     line_number            VARCHAR2(30) := FND_API.G_MISS_CHAR,
     ctx_org                VARCHAR2(100):= FND_API.G_MISS_CHAR,
     start_date             DATE         := FND_API.G_MISS_DATE,
     end_date               DATE         := FND_API.G_MISS_DATE,
     currency_code          VARCHAR2(15) := FND_API.G_MISS_CHAR,
     lse_id                 NUMBER       := FND_API.G_MISS_NUM,
     price_negotiated       NUMBER       := FND_API.G_MISS_NUM,
     hdr_estimated_amt      NUMBER       := FND_API.G_MISS_NUM,
     hdr_price_list_id      NUMBER       := FND_API.G_MISS_NUM,
     item_jtot_obj_code     VARCHAR2(30) := FND_API.G_MISS_CHAR,
     item_object1_id1       VARCHAR2(40) := FND_API.G_MISS_CHAR,
     item_object1_id2       VARCHAR2(200):= FND_API.G_MISS_CHAR
  );

TYPE au_tbl_type IS TABLE OF au_rec_type
       INDEX BY BINARY_INTEGER;

-- ---------------------------------------------------------------------------
-- RECORD        : config_rec_type
-- PURPOSE       : The config record/table structure will be used
--                 to instantiate any config related detailed information
--                 that is obtained from Oracle Configurator schema.
-- ---------------------------------------------------------------------------
TYPE config_rec_type IS RECORD (
   config_hdr_id         NUMBER         := FND_API.G_MISS_NUM,
   config_rev_nbr        NUMBER         := FND_API.G_MISS_NUM,
   config_item_id        NUMBER         := FND_API.G_MISS_NUM,
   parent_config_item_id NUMBER         := FND_API.G_MISS_NUM,
   inventory_item_id     NUMBER         := FND_API.G_MISS_NUM,
   organization_id       NUMBER         := FND_API.G_MISS_NUM,
   component_code        VARCHAR2(1200) := FND_API.G_MISS_CHAR,
   quantity              NUMBER         := FND_API.G_MISS_NUM,
   uom_code              VARCHAR2(3)    := FND_API.G_MISS_CHAR,
   operation             VARCHAR2(10)   := FND_API.G_MISS_CHAR );

TYPE config_tbl_type IS TABLE OF config_rec_type
       INDEX BY BINARY_INTEGER;

-- ---------------------------------------------------------------------------
-- RECORD        : cz_track_rec_type
-- PURPOSE       : This record/table structure will be used
--                 to keep track of the config related detailed information
--                 that is obtained from Oracle Configurator schema along
--                 with the new contract line ids including parent ids. The
--                 model tree is correspondingly created as contract lines.
-- ---------------------------------------------------------------------------
TYPE cz_track_rec_type IS RECORD (
   config_item_id        NUMBER         := FND_API.G_MISS_NUM,
   parent_config_item_id NUMBER         := FND_API.G_MISS_NUM,
   inventory_item_id     NUMBER         := FND_API.G_MISS_NUM,
   component_code        VARCHAR2(1200) := FND_API.G_MISS_CHAR,
   id                    NUMBER         := FND_API.G_MISS_NUM,
   chr_id                NUMBER         := FND_API.G_MISS_NUM,
   cle_id                NUMBER         := FND_API.G_MISS_NUM,
   dnz_chr_id            NUMBER         := FND_API.G_MISS_NUM,
   top_model_line_id     NUMBER         := FND_API.G_MISS_NUM,
   config_hdr_id         NUMBER         := FND_API.G_MISS_NUM,
   config_rev_nbr        NUMBER         := FND_API.G_MISS_NUM,
   organization_id       NUMBER         := FND_API.G_MISS_NUM,
   line_index            NUMBER         := FND_API.G_MISS_NUM  );

TYPE cz_track_tbl_type IS TABLE OF cz_track_rec_type
       INDEX BY BINARY_INTEGER;

-- ---------------------------------------------------------------------------
-- TYPE          : CHRV,CLEV,CIMV
-- PURPOSE       : Type cast for the Contract header,line and
--                 contract items tables. Usage can be in this API
--                 and/or the forms library OKCAUCFG.pld
-- ---------------------------------------------------------------------------
SUBTYPE chrv_tbl_type IS OKC_CONTRACT_PUB.chrv_tbl_type;
SUBTYPE chrv_rec_type IS OKC_CONTRACT_PUB.chrv_rec_type;

SUBTYPE clev_tbl_type IS OKC_CONTRACT_PUB.clev_tbl_type;
SUBTYPE clev_rec_type IS OKC_CONTRACT_PUB.clev_rec_type;

SUBTYPE cimv_rec_type IS OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
SUBTYPE cimv_tbl_type IS OKC_CONTRACT_ITEM_PUB.cimv_tbl_type;


-- ---------------------------------------------------------------------------
-- FUNCTION      : cle_config_check
-- PURPOSE       : To check whether the contract configuration exists
--                 in the okc_k_lines_v Returns Y or N.
--                 Default return value = N
-- ---------------------------------------------------------------------------
FUNCTION cle_config_check ( p_line_id         IN NUMBER,
                            p_config_hdr_id   IN NUMBER,
                            p_config_rev_nbr  IN NUMBER)
                            RETURN VARCHAR2;

-- ---------------------------------------------------------------------------
-- PROCEDURE     : build_cle_from_cz
-- PURPOSE       : Create/Update/Delete Contract Lines based on
--                 the termination of the configuration call.
--                 gets the configuration details from the
--                 CZ schema tables join to OKC lines table.
-- ---------------------------------------------------------------------------
PROCEDURE build_cle_from_cz (
                  p_api_version_number IN   NUMBER     := FND_API.G_MISS_NUM,
                  p_init_msg_list      IN   VARCHAR2   := FND_API.G_FALSE,
                  p_commit             IN   VARCHAR2   := FND_API.G_FALSE,
                  p_config_complete_yn IN   VARCHAR2   := 'N',
                  p_config_valid_yn    IN   VARCHAR2   := 'N',
                  p_au_line_rec        IN   OKC_CFG_PUB.au_rec_type,
                  p_config_rec         IN   OKC_CFG_PUB.config_rec_type,
                  x_cfg_list_price     OUT NOCOPY  NUMBER,
                  x_cfg_net_price      OUT NOCOPY  NUMBER,
                  x_return_status      OUT NOCOPY  VARCHAR2,
                  x_msg_count          OUT NOCOPY  NUMBER,
                  x_msg_data           OUT NOCOPY  VARCHAR2 );

-- ---------------------------------------------------------------------------
-- PROCEDURE     : config_qa_check
-- PURPOSE       : To call from QA check on a contract.
--                 to check whether the contract configuration
--                 is compelte and also valid.
-- INPUT         : Contract Header Id.
-- OUTPUT        : Contract Valid Y/N flag.
-- ---------------------------------------------------------------------------
PROCEDURE config_qa_check ( p_chr_id         IN         NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- PROCEDURE     : okc_pricing_callback
-- PURPOSE       : To calculate LIST or SELL price of the config
--                 items. Callback from the Configurator window.
--                 The price details are for display only.
--                 Configurator is called from the authoring form
--                    OKCAUDET.fmx
--                      -> OKCAUPRC.fmx
--                          -> OKCAUCFG.plx
--                               -> Oracle Configurator Window
--                                    -> Pricing_Callback
-- ---------------------------------------------------------------------------
PROCEDURE okc_pricing_callback( p_config_session_key    IN       VARCHAR2,
                                p_price_type            IN       VARCHAR2,
                                x_total_price           OUT NOCOPY      NUMBER );


-- ---------------------------------------------------------------------------
-- PROCEDURE     : copy_config
-- PURPOSE       : Creates new configuration header and revision while
--                 copying a contract. The newly copied contract will point
--                 to the newly created config header and revisions.
--                 This procedure is called from the contract COPY APIs.
--                 Procedure will handle all configured models in a contract.
-- ---------------------------------------------------------------------------
PROCEDURE copy_config ( p_dnz_chr_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2);

END OKC_CFG_PUB;

 

/
