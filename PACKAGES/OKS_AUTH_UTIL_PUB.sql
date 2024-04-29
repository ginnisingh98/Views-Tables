--------------------------------------------------------
--  DDL for Package OKS_AUTH_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AUTH_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPAUTS.pls 120.3 2005/11/09 05:43:28 maanand noship $ */

  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME               CONSTANT VARCHAR2(200) := 'OKS_AUTH_UTIL_PUB';
  G_APP_NAME_OKS           CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC           CONSTANT VARCHAR2(3)   :=  'OKC';
  G_SERIAL_NUMBER          CONSTANT VARCHAR2(10)  :=  'Srl: ';
  G_QUANTITY               CONSTANT VARCHAR2(10)  :=  '; Qty: ';
  G_PRICE                  CONSTANT VARCHAR2(10)  := '; Price: ';
  G_INSTALLED_AT           CONSTANT VARCHAR2(15)  := '; Installed @ ';
  G_REF                    CONSTANT VARCHAR2(10)  := '; Ref: ';
  -------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  -- GLOBAL_MESSAGE_CONSTANTS
  ----------------------------------------------------------------------------------------
  G_TRUE                       CONSTANT VARCHAR2(1)   :=  OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
  G_RET_STS_SUCCESS            CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30)  := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30)  := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30)  := 'SQLcode';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(30)  := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30)  := OKC_API.G_COL_NAME_TOKEN;
  ----------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ----------------------------------------------------------------------------------------
  G_ERROR                      EXCEPTION;
  ----------------------------------------------------------------------------------------

  --SUBTYPE DECLARATION
  SUBTYPE clvl_filter_rec IS OKS_AUTH_UTIL_PVT.clvl_filter_rec;
  SUBTYPE clvl_selections_tbl IS OKS_AUTH_UTIL_PVT.clvl_selections_tbl;
  SUBTYPE prod_selections_tbl IS OKS_AUTH_UTIL_PVT.prod_selections_tbl;
  SUBTYPE copy_source_rec IS OKS_AUTH_UTIL_PVT.copy_source_rec;
  SUBTYPE copy_target_tbl IS OKS_AUTH_UTIL_PVT.copy_target_tbl;
  SUBTYPE contact_point_rec IS OKS_AUTH_UTIL_PVT.contact_point_rec;
--  SUBTYPE contact_dtl_rec IS OKS_AUTH_UTIL_PVT.contact_dtl_rec;

--  SUBTYPE prod_rec        IS OKS_AUTH_UTIL_PVT.prod_rec;
--  SUBTYPE prod_tbl        IS OKS_AUTH_UTIL_PVT.prod_tbl;
--  SUBTYPE cust_id_rec     IS OKS_AUTH_UTIL_PVT.cust_id_rec;
--  SUBTYPE cust_id_tbl     IS OKS_AUTH_UTIL_PVT.cust_id_tbl;
------------------------------------------------------------------------
     ---- start --CONTACT CREATION 11.5.10+ OCT 2004
------------------------------------------------------------------------
SUBTYPE person_tbl_type IS OKS_AUTH_UTIL_PVT.person_tbl_type;
SUBTYPE relationship_tbl_type IS OKS_AUTH_UTIL_PVT.relationship_tbl_type;
SUBTYPE org_contact_tbl_type IS OKS_AUTH_UTIL_PVT.org_contact_tbl_type;
SUBTYPE party_site_tbl_type IS OKS_AUTH_UTIL_PVT.party_site_tbl_type;
SUBTYPE CUST_ACCOUNT_ROLE_tbl_TYPE IS OKS_AUTH_UTIL_PVT.CUST_ACCOUNT_ROLE_tbl_TYPE;
SUBTYPE CUST_ACCT_SITE_TBL_TYPE IS OKS_AUTH_UTIL_PVT.CUST_ACCT_SITE_TBL_TYPE;

-- GCHADHA --
-- 28-OCT-2004 --
---------------------------------------------------------------------------
     -------- MUTLI CURRENCY PROJECT -------------------
 -- Added two variable price_uom and line_price_uom for partial period project --


  TYPE multi_line_rec IS RECORD
    (
      id                     OKC_K_LINES_V.ID%TYPE,
      price_list_id          OKC_K_LINES_V.PRICE_LIST_ID%TYPE,
      lse_id                 OKC_K_LINES_V.LSE_ID%TYPE,
      line_pl_flag           Varchar2(1),
      line_number            OKC_K_LINES_V.LINE_NUMBER%TYPE
-- Change Request Partial Period --
--      price_uom              OKS_K_LINES_V.PRICE_UOM%TYPE, -- new
--      line_uom_flag         VARCHAR2(1)  -- new
-- Change request Partial Period --
  );
  TYPE multi_line_tbl IS TABLE OF multi_line_rec INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------------
--END GCHADHA --



-- end contact creation
  PROCEDURE GetSelections_prod(p_api_version         IN  NUMBER
                              ,p_init_msg_list       IN  VARCHAR2
                              ,p_clvl_filter_rec     IN  clvl_filter_rec
                              ,x_return_status       OUT NOCoPY VARCHAR2
                              ,x_msg_count           OUT NOCoPY NUMBER
                              ,x_msg_data            OUT NOCoPY VARCHAR2
                              ,x_prod_selections_tbl OUT NOCoPY prod_selections_tbl);

  PROCEDURE GetSelections_other(p_api_version         IN  NUMBER
                               ,p_init_msg_list       IN  VARCHAR2
                               ,p_clvl_filter_rec     IN  clvl_filter_rec
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2
                               ,x_clvl_selections_tbl OUT NOCOPY clvl_selections_tbl);

  PROCEDURE CopyService(p_api_version   IN  NUMBER
                       ,p_init_msg_list IN  VARCHAR2
                       ,p_source_rec    IN  copy_source_rec
                       ,p_target_tbl    IN  copy_target_tbl
                       ,x_return_status OUT NOCOPY VARCHAR2
                       ,x_msg_count     OUT NOCOPY NUMBER
                       ,x_msg_data      OUT NOCOPY VARCHAR2
		             ,p_change_status IN  VARCHAR2 DEFAULT 'Y'); -- LLC Added additional flag parameter to the call
				   									  -- to not allow change of status of sublines of the
													  -- topline during update service


   TYPE cur_rec Is Record
    (
     description           VARCHAR2(240),
     segment1              VARCHAR2(40),
     concatenated_segments VARCHAR2(40)
    );

  TYPE hdr_cur_rec Is Record
    (
     short_description          VARCHAR2(240),
     contract_number            VARCHAR2(120),
     contract_number_modifier   VARCHAR2(120),
     start_date                 DATE,
     end_date                   DATE,
     currency_code              OKC_K_HEADERS_B.CURRENCY_CODE%TYPE
    );

  TYPE line_cur_rec Is Record
    (
     line_number          VARCHAR2(150),
     start_date           DATE,
     end_date             DATE,
     cognomen             VARCHAR2(300),
     lse_id               NUMBER
    );

  TYPE in_parameter_record Is Record
   (
    chr_id               NUMBER,
    line_id              NUMBER,
    organization_id      NUMBER,
    inventory_item_id    NUMBER
   );

   PROCEDURE COPY_PARAMETER(
                           p_api_version         IN NUMBER,
                           p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           p_in_parameter_record IN  in_parameter_record,
                           x_cur_rec             OUT NOCOPY cur_rec,
                           x_hdr_cur_rec         OUT NOCOPY hdr_cur_rec,
                           x_line_cur_rec        OUT NOCOPY line_cur_rec,
                           x_return_status       OUT NOCOPY VARCHAR2,
                           x_msg_count           OUT NOCOPY NUMBER,
                           x_msg_data            OUT NOCOPY VARCHAR2 );

FUNCTION chk_counter (p_object1_id1 NUMBER,
				  p_cle_id      NUMBER,
				  p_lse_id      NUMBER DEFAULT NULL) RETURN NUMBER;

FUNCTION chk_event (p_object1_id1               NUMBER DEFAULT NULL,
				p_cle_id                    NUMBER DEFAULT NULL,
				p_lse_id                    NUMBER DEFAULT NULL,
				p_counter_group_id          NUMBER DEFAULT NULL,
				p_template_counter_group_id NUMBER DEFAULT NULL) RETURN NUMBER;



PROCEDURE Contact_Point
 (
  p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2,
  P_commit              IN   VARCHAR2,
  P_contact_point_rec   IN   contact_point_rec,
  x_return_status       OUT  NOCOPY VARCHAR2,
  x_msg_count           OUT  NOCOPY NUMBER,
  x_msg_data            OUT  NOCOPY VARCHAR2,
  x_contact_point_id    OUT  NOCOPY NUMBER);



PROCEDURE CREATE_CII_FOR_SUBSCRIPTION
(
      p_api_version   IN NUMBER,
      p_init_msg_list IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count     OUT NOCOPY NUMBER,
      x_msg_data      OUT NOCOPY VARCHAR2,
      p_cle_id        IN NUMBER,
      p_quantity      IN NUMBER DEFAULT 1,
      x_instance_id   OUT NOCOPY NUMBER

 );

 PROCEDURE DELETE_CII_FOR_SUBSCRIPTION
  ( p_api_version   IN NUMBER,
      p_init_msg_list IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count     OUT NOCOPY NUMBER,
      x_msg_data      OUT NOCOPY VARCHAR2,
      p_instance_id   IN NUMBER
    ) ;

FUNCTION def_sts_code(p_ste_code VARCHAR2) RETURN VARCHAR2;
FUNCTION get_ste_code(p_sts_code VARCHAR2) RETURN VARCHAR2;
-- start contact creation 10+ OCT 2004
PROCEDURE create_person (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_tbl                       IN      PERSON_TBL_TYPE,
    x_party_id                         OUT NOCOPY     NUMBER,
    x_party_number                     OUT NOCOPY     VARCHAR2,
    x_profile_id                       OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
   );

PROCEDURE update_person (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_tbl                       IN      PERSON_TBL_TYPE,
    p_party_object_version_number      IN      NUMBER,
    x_profile_id                       OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
   );

PROCEDURE create_org_contact (
    p_init_msg_list                    IN       VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
    p_relationship_tbl_type            IN       relationship_tbl_type,
    x_org_contact_id                   OUT NOCOPY      NUMBER,
    x_party_rel_id                     OUT NOCOPY      NUMBER,
    x_party_id                         OUT NOCOPY      NUMBER,
    x_party_number                     OUT NOCOPY      VARCHAR2,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
   );
PROCEDURE update_org_contact (
    p_init_msg_list                    IN       VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_tbl                  IN       ORG_CONTACT_TBL_TYPE,
    p_relationship_tbl_type            IN       relationship_tbl_type,
    p_cont_object_version_number       IN OUT NOCOPY   NUMBER,
    p_rel_object_version_number        IN OUT NOCOPY   NUMBER,
    p_party_object_version_number      IN OUT NOCOPY   NUMBER,
    x_return_status                    OUT NOCOPY      VARCHAR2,
    x_msg_count                        OUT NOCOPY      NUMBER,
    x_msg_data                         OUT NOCOPY      VARCHAR2
  );

PROCEDURE create_party_site (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
    x_party_site_id                 OUT NOCOPY         NUMBER,
    x_party_site_number             OUT NOCOPY         VARCHAR2,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
  );

PROCEDURE update_party_site (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_tbl                IN          PARTY_SITE_TBL_TYPE,
    p_object_version_number         IN OUT NOCOPY      NUMBER,
    x_return_status                 OUT NOCOPY         VARCHAR2,
    x_msg_count                     OUT NOCOPY         NUMBER,
    x_msg_data                      OUT NOCOPY         VARCHAR2
  );

PROCEDURE create_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
    x_cust_account_role_id                  OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
  ) ;
PROCEDURE update_cust_account_role (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_role_tbl                 IN     CUST_ACCOUNT_ROLE_tbl_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
  ) ;
PROCEDURE create_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
    x_cust_acct_site_id                     OUT NOCOPY    NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
  );

PROCEDURE update_cust_acct_site (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_tbl                    IN     CUST_ACCT_SITE_TBL_TYPE,
    p_object_version_number                 IN OUT NOCOPY NUMBER,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
  );

-- GCHADHA --
-- MULTI CURRENCY PROJECT --
--28-OCT-2004 --
-- ADDED A NEW PROCEDURE COMPUTE_PRICE_MULTIPLE_LINE --
PROCEDURE COMPUTE_PRICE_MULTIPLE_LINE(
     p_api_version             IN         NUMBER,
     p_detail_tbl                  IN         MULTI_LINE_TBL,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_status_tbl                  OUT NOCOPY oks_qp_int_pvt.Pricing_Status_tbl
);
--END GCHADHA --
-- GCHADHA --
-- BUG 4053911 --
-- 15-DEC-2004 --
---------------------------------------------------------------------------
PROCEDURE DELETE_PRICE_ADJUST_LINE(
     p_api_version                 IN         NUMBER,
     p_chr_id                      IN         NUMBER,
     p_header_currency             IN         VARCHAR2 );
---------------------------------------------------------------------------
--END GCHADHA --

-------- Partial Period Computation Project -----
Function is_not_subscrip(p_cle_id Number) return varchar2;
--------- Partial Period Computation Project -----


-- end contact creation 10+ OCT 2004
END OKS_AUTH_UTIL_PUB;

 

/
