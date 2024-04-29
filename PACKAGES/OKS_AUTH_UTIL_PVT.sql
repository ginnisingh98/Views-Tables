--------------------------------------------------------
--  DDL for Package OKS_AUTH_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_AUTH_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRAUTS.pls 120.8 2006/06/21 16:50:57 tweichen noship $ */

/*
   For all procedures following parameters are standard
   p_api_version, p_init_msg_list, x_return_status, x_msg_count, x_msg_data
*/
 ----------------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ----------------------------------------------------------------------------------------
  G_PKG_NAME                           CONSTANT VARCHAR2(200) :=  'OKS_AUTH_UTIL_PVT';
  G_APP_NAME_OKS                       CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC                       CONSTANT VARCHAR2(3)   :=  'OKC';
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
  -- GLOBAL EXCEPTION
  ----------------------------------------------------------------------------------------
  G_ERROR                      EXCEPTION;
  G_DUPLICATE_RECORD           EXCEPTION;
  ----------------------------------------------------------------------------------------

  G_BULK_FETCH_LIMIT  CONSTANT NUMBER := 1000;

  g_serial_number  VARCHAR2(20) ;
  g_quantity       VARCHAR2(20) ;
  g_price          VARCHAR2(23) ;
  g_installed_at   VARCHAR2(28) ;
  g_ref            VARCHAR2(20) ;


  l_param_party_id NUMBER ;

l_chrv_tbl                      OKC_CONTRACT_PUB.chrv_tbl_type;
l_khrv_tbl                      OKS_CONTRACT_HDR_PUB.khrv_tbl_type;
l_klnv_tbl                      OKS_CONTRACT_LINE_PUB.klnv_tbl_type;

 -- BUG 4372877 --
 -- GCHADHA --
 -- 5/25/2005 --
TYPE get_prod_rec IS RECORD ( id1                 CSI_ITEM_INSTANCES.instance_ID%TYPE ,
                              install_location_Id CSI_ITEM_INSTANCES.install_location_id%TYPE,
                              quantity            CSI_ITEM_INSTANCES.quantity%TYPE,
			      instance_number     CSI_ITEM_INSTANCES.instance_number%TYPE,
                              unit_of_measure     CSI_ITEM_INSTANCES.unit_of_measure%Type,
                              unit_selling_price  OE_ORDER_LINES_ALL.unit_selling_price%TYPE,
                              inventory_item_id   CSI_ITEM_INSTANCES.inventory_item_id%TYPE,
                              serial_number       CSI_ITEM_INSTANCES.serial_number%TYPE,
                              id2                 VARCHAR2(1),
                              oe_line_id          NUMBER,
			     external_reference  CSI_ITEM_INSTANCES.external_reference%TYPE -- new

                            );

-- END GCHADHA --

 -- BUG 4372877 --
 -- GCHADHA --
 -- 5/25/2005 --
TYPE prod_rec IS RECORD (config_parent_id    CSI_ITEM_INSTANCES.instance_id%TYPE,
                         id1                 CSI_ITEM_INSTANCES.instance_ID%TYPE ,
                         install_location_Id CSI_ITEM_INSTANCES.install_location_id%TYPE,
                         quantity            CSI_ITEM_INSTANCES.quantity%TYPE,
                         instance_number     CSI_ITEM_INSTANCES.instance_number%TYPE,
                         unit_of_measure     CSI_ITEM_INSTANCES.unit_of_measure%Type,
                         unit_selling_price  OE_ORDER_LINES_ALL.unit_selling_price%TYPE,
                         inventory_item_id   CSI_ITEM_INSTANCES.inventory_item_id%TYPE,
                         parent_inventory_item_id CSI_ITEM_INSTANCES.inventory_item_id%TYPE,
                         serial_number       CSI_ITEM_INSTANCES.serial_number%TYPE,
                         id2                 VARCHAR2(1),
                         oe_line_id          NUMBER ,
                         model_level         NUMBER,
			 external_reference  CSI_ITEM_INSTANCES.external_reference%TYPE -- new
                         );
TYPE prod_tbl is Table of prod_rec INDEX BY BINARY_INTEGER;
-- END GCHADHA --

g_prod_rec prod_rec;
g_prod_tbl prod_tbl;

TYPE clvl_filter_rec IS RECORD(  clvl_level        VARCHAR2(200)
                                ,clvl_lse_id       Number
                                ,clvl_party_id     NUMBER
                                ,clvl_auth_org_id  NUMBER
                                ,clvl_name         VARCHAR2(1000)
                                ,clvl_description  VARCHAR2(1000)
                                ,clvl_inv_org_id   NUMBER
                                ,clvl_filter       VARCHAR2(25)
                                ,clvl_default      VARCHAR2(25)
                                ,clvl_find_id      NUMBER
                                ,clvl_organization_id NUMBER
                                ,clvl_display_pref VARCHAR2(25),
                                 lbl_serial_number   VARCHAR2(20),
                                 lbl_quantity        VARCHAR2(20),
                                 lbl_price           VARCHAR2(23)   ,
                                 lbl_installed_at    VARCHAR2(28),
                                 lbl_ref             VARCHAR2(20) );


TYPE clvl_filter_tbl  IS TABLE OF clvl_filter_rec INDEX BY BINARY_INTEGER;
g_clvl_filter_rec clvl_filter_rec;

-- BUG 4372877 --
 -- GCHADHA --
 -- 5/25/2005 --
TYPE prod_selections_rec IS RECORD ( rec_no       NUMBER,
                                     rec_name     VARCHAR2(15),
                                     rec_type     Varchar2(1),
                                     config_parent_id Number,
                                     cp_id        Number,
                                     cp_id2       Varchar2(1),
                                     ser_number   CSI_ITEM_INSTANCES.serial_Number%TYPE,
                                     ref_number   CSI_ITEM_INSTANCES.instance_Number%TYPE,
                                     quantity     CSI_ITEM_INSTANCES.quantity%TYPE,
                                     site_id      CSI_ITEM_INSTANCES.install_location_id%TYPE,
                                     site_name    VARCHAR2(2000), -- Bug 4915711
                                     inventory_item_id CSI_ITEM_INSTANCES.inventory_item_id%TYPE,
                                     id           Number,
                                     name         Varchar2(2000), -- Bug 4915711 --
                                     display_name Varchar2(2000), -- Bug 4915711 --
                                     description  OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE,
                                     uom_code     CSI_ITEM_INSTANCES.unit_of_measure%TYPE,
                                     orig_net_amt OE_ORDER_LINES_ALL.unit_selling_price%TYPE,
                                     price        Number,
                                     model_level Number,
				     ext_reference  CSI_ITEM_INSTANCES.external_reference%TYPE -- new
                                     );
 -- END GCHADHA --

  TYPE prod_selections_tbl IS TABLE OF prod_selections_rec INDEX BY BINARY_INTEGER;
  g_prod_selections_tbl prod_selections_tbl;

  TYPE clvl_selections_rec IS RECORD ( rec_no             NUMBER,
                                       rec_name           VARCHAR2(15),
                                       rec_type           VARCHAR2(1),
                                       id1                OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE,
                                       name               OKX_CUSTOMER_ACCOUNTS_V.name%TYPE,
                                       id2                OKX_CUSTOMER_ACCOUNTS_V.id2%TYPE,
                                       Party_id           OKX_PARTIES_V.id1%TYPE,
                                       party_name         OKX_PARTIES_V.name%TYPE,
                                       description        Varchar2(2000),
                                       display_name       VARCHAR2(500),
                                       clvl_id            NUMBER,
                                       clvl_name          VARCHAR2(200),
                                       lse_id             NUMBER,
                                       lse_name           VARCHAR2(20) );

  TYPE clvl_selections_tbl IS TABLE OF clvl_selections_rec INDEX BY BINARY_INTEGER;
  g_clvl_selections_tbl clvl_selections_tbl;


  TYPE cust_id_rec IS RECORD ( customer_id OKX_CUSTOMER_ACCOUNTS_V.id1%TYPE,
                               customer_name OKX_CUSTOMER_ACCOUNTS_V.name%TYPE);
  TYPE cust_id_tbl IS TABLE of cust_id_rec INDEX BY BINARY_INTEGER;

  TYPE party_id_rec IS RECORD ( party_id OKX_PARTIES_V.id1%TYPE,
                                party_name OKX_PARTIES_V.name%TYPE );

  TYPE party_id_tbl IS TABLE of party_id_rec INDEX BY BINARY_INTEGER;

  PROCEDURE GetSelections_prod(p_api_version         IN  NUMBER
                              ,p_init_msg_list       IN  VARCHAR2
                              ,p_clvl_filter_rec     IN  clvl_filter_rec
                              ,x_return_status       OUT NOCOPY VARCHAR2
                              ,x_msg_count           OUT NOCOPY NUMBER
                              ,x_msg_data            OUT NOCOPY VARCHAR2
                              ,x_prod_selections_tbl OUT NOCOPY prod_selections_tbl);

  PROCEDURE GetSelections_other(p_api_version         IN  NUMBER
                               ,p_init_msg_list       IN  VARCHAR2
                               ,p_clvl_filter_rec     IN  clvl_filter_rec
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2
                               ,x_clvl_selections_tbl OUT NOCOPY clvl_selections_tbl);


  /** Procedure for copying/splitting service lines **/
  TYPE copy_source_rec is RECORD(cle_id     NUMBER
                                ,item_id    VARCHAR2(40)
                                ,amount     NUMBER);
  TYPE copy_target_rec is RECORD(cle_id     NUMBER
                                ,item_id    VARCHAR2(40)
                                ,item_desc  VARCHAR2(1000)
                                ,amount     NUMBER
                                ,percentage NUMBER);
  TYPE copy_target_tbl is table of copy_target_rec INDEX BY BINARY_INTEGER;
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

TYPE contact_point_rec IS RECORD
      (contact_point_id    NUMBER,
       contact_point_type  VARCHAR2(30),
       status	           VARCHAR2(30),
       owner_table_name	   VARCHAR2(30),
       owner_table_id	   NUMBER,
       primary_flag	   VARCHAR2(1),
       content_source_type VARCHAR2(30),
       email_address       VARCHAR2(2000),
       area_code           VARCHAR2(10),
       phone_country_code  VARCHAR2(10)); -- added phone country code for HZ


TYPE Clvl_Rec_Type IS RECORD
      (
        Coverage_Level_Line_Id     Number,
        Price_Unit                 Number,
        Price_Unit_Percent         Number,
        Price_Negotiated           Number
    );


/*TYPE contact_dtl_rec IS RECORD
(
  contact_id         NUMBER,
  contact_first_name VARCHAR2(2000),
  contact_name       VARCHAR2(2000),
  party_id           NUMBER,
  party_name         VARCHAR2(2000),
  email_point_id     NUMBER,
  email              VARCHAR2(2000),
  phone_point_id     NUMBER,
  phone              VARCHAR2(2000),
  fax_point_id       NUMBER,
  fax                VARCHAR2(2000),
  quote_site_id      NUMBER,
  quote_address      VARCHAR2(2000),
  quote_city         VARCHAR2(2000),
  quote_country      VARCHAR2(2000)

);
*/


PROCEDURE Create_Contact_Points
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_commit              IN   Varchar2,
  P_contact_point_rec   IN   contact_point_rec,
  x_return_status       OUT NOCOPY  Varchar2,
  x_msg_count           OUT NOCOPY  Number,
  x_msg_data            OUT NOCOPY  Varchar2,
  x_contact_point_id    OUT NOCOPY  Number);

PROCEDURE Update_Contact_Points
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  P_commit              IN   Varchar2,
  P_contact_point_rec   IN   contact_point_rec,
  x_return_status       OUT NOCOPY  Varchar2,
  x_msg_count           OUT NOCOPY  Number,
  x_msg_data            OUT NOCOPY  Varchar2);


PROCEDURE CreateOperationInstance(p_chr_id IN NUMBER
                                   ,p_object1_id1 IN VARCHAR2
                                   ,p_object1_id2 IN VARCHAR2
                                   ,p_jtot_object1_code IN VARCHAR2
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_oie_id OUT NOCOPY NUMBER);

PROCEDURE CreateOperationLines(p_chr_id IN NUMBER
                                ,p_object_line_id IN NUMBER
                                ,p_subject_line_id IN NUMBER
                                ,p_oie_id IN NUMBER
                           --BUG#4066428 01/24/05 hkamdar
                           --     ,x_return_status OUT NOCOPY NUMBER);
                                ,x_return_status OUT NOCOPY VARCHAR2);
			   --End BUG#4066428 01/24/05 hkamdar
FUNCTION get_item_desc(p_inventory_item_id IN NUMBER)
return VARCHAR2  ;

FUNCTION get_item_name(p_inventory_item_id IN NUMBER)
return VARCHAR2  ;

FUNCTION get_item_name(p_inventory_item_id IN NUMBER,
                       p_organization_id    IN NUMBER)
return VARCHAR2  ;


FUNCTION get_item_desc(p_inventory_item_id IN NUMBER,
                       p_organization_id    IN NUMBER)
return VARCHAR2  ;

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



PROCEDURE line_contact_name_addr(
          p_object_code       IN  VARCHAR2,
          p_id1               IN  VARCHAR2,
          p_id2               IN  VARCHAR2,
          x_name              OUT NOCOPY VARCHAR2,
          x_addr              OUT NOCOPY okx_cust_sites_v.description%type);


  TYPE opn_lines_rec Is Record
  (creation_date  DATE,
   subject_chr_id NUMBER,
   object_chr_id  NUMBER,
   subject_cle_id NUMBER,
   object_cle_id  NUMBER
   );

   Type opn_lines_tbl is TABLE of opn_lines_rec index by binary_integer;

   PROCEDURE select_renewal_info
           (p_chr_id IN NUMBER,
            x_operation_lines_tbl OUT NOCOPY opn_lines_tbl
          );

   PROCEDURE update_renewal_info
              (p_operation_lines_tbl IN opn_lines_tbl,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_count     OUT NOCOPY NUMBER,
               x_msg_data      OUT NOCOPY VARCHAR2
               );

  TYPE price_adj_rec IS RECORD(list_line_id NUMBER,
                               cle_id       NUMBER,
                               chr_id       NUMBER);

  PROCEDURE CheckDuplicatePriceAdj(p_api_version   IN  NUMBER
                                  ,p_init_msg_list IN  VARCHAR2
                                  ,p_pradj_rec     IN  price_adj_rec
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_count     OUT NOCOPY NUMBER
                                  ,x_msg_data      OUT NOCOPY VARCHAR2);

   /** newly added procedure to calculate cascade service price */

  PROCEDURE Cascade_Service_Price(
                                   p_api_version        IN  NUMBER,
                                   p_init_msg_lISt      IN  VARCHAR2,
                                   p_contract_line_id   IN  NUMBER,
                                   p_new_service_price  IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2
                                 );


/*** PROCEDURE delete_contract  (
                             p_api_version      IN NUMBER,
                             p_init_msg_list    IN NUMBER,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2,
                             p_chrv_tbl         IN  okc_contract_pub.chrv_tbl_type );


PROCEDURE Copy_Contract(
                             p_api_version       IN VARCHAR2
                             p_init_msg_list     IN VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             p_chr_id            IN  NUMBER,
                             p_contract_number   IN  VARCHAR2,
                             p_contract_number_modifier IN VARCHAR2,
                             p_to_template_yn     IN  VARCHAR2,
                             p_renew_ref_yn       IN  VARCHAR2,
                             x_chr_id             OUT NOCOPY NUMBER ); ***/

PROCEDURE update_quantity(p_cle_id         IN NUMBER,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2
                                 );
-- start contact creation OCT 2004

TYPE CUST_ACCOUNT_ROLE_REC_TYPE IS RECORD(
party_id              NUMBER,
cust_account_id       NUMBER,
role_type             VARCHAR2(30),
cust_account_role_id  NUMBER,
cust_acct_site_id     NUMBER,
primary_flag          VARCHAR2(1),
status                VARCHAR2(1)
);

TYPE CUST_ACCOUNT_ROLE_tbl_TYPE IS TABLE OF CUST_ACCOUNT_ROLE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE CUST_ACCT_SITE_REC_TYPE IS RECORD(
Cust_account_id     NUMBER,
party_site_id       NUMBER,
cust_acct_site_id   NUMBER
);

TYPE CUST_ACCT_SITE_TBL_TYPE IS TABLE OF CUST_ACCT_SITE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE PERSON_REC_TYPE IS RECORD(
  party_id                  NUMBER,
  person_pre_name_adjunct   VARCHAR2(30),
  person_first_name         VARCHAR2(150),
  person_last_name          VARCHAR2(150)
);

TYPE person_tbl_type IS TABLE OF PERSON_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE relationship_rec_type IS RECORD(
    relationship_id                 NUMBER,
    subject_id                      NUMBER,
    subject_type                    VARCHAR2(30),
    subject_table_name              VARCHAR2(30),
    object_id                       NUMBER,
    object_type                     VARCHAR2(30),
    object_table_name               VARCHAR2(30),
    relationship_code               VARCHAR2(30),
    relationship_type               VARCHAR2(30)
);

TYPE relationship_tbl_type IS TABLE OF relationship_rec_type INDEX BY BINARY_INTEGER;

TYPE org_contact_rec_type IS RECORD(
    org_contact_id                  NUMBER,
    job_title                       VARCHAR2(100),
    job_title_code                  VARCHAR2(30),
    party_site_id                  NUMBER
);

TYPE org_contact_tbl_type IS TABLE OF org_contact_rec_type INDEX BY BINARY_INTEGER;

TYPE party_site_rec_type IS RECORD(
    party_site_id            NUMBER,
    party_id                 NUMBER,
    location_id              NUMBER,
    mailstop                 VARCHAR2(30)
);

TYPE party_site_tbl_type IS TABLE OF party_site_rec_type INDEX BY BINARY_INTEGER;
-- added the following procedure for contact creation oct 2004
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
-- end contact creation OCT2004--
 /**** Partial Period Computation Project  **/
FUNCTION Is_Line_Eligible(
                          p_api_version        IN  NUMBER,
                          p_init_msg_list      IN  VARCHAR2,
                          p_contract_hdr_id    IN  NUMBER, -- VARCHAR2
			  p_contract_line_id   IN  NUMBER,
			  p_price_list_id      IN  NUMBER,
                          p_intent	       IN  VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2
			  ) RETURN BOOLEAN;
 /**** Partial Period Computation Project  **/

     PROCEDURE check_update_amounts (
                                    p_api_version                           IN NUMBER,
                                    p_init_msg_list                         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_commit                                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                    p_chr_id                                IN NUMBER,
                                    x_msg_count                             OUT NOCOPY    NUMBER,
                                    x_msg_data                              OUT NOCOPY    VARCHAR2,
                                    x_return_status                         OUT NOCOPY    VARCHAR2
                                    );

FUNCTION get_net_reading(p_counter_id NUMBER)
RETURN  NUMBER ;

END OKS_AUTH_UTIL_PVT;

 

/
