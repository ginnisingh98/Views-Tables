--------------------------------------------------------
--  DDL for Package OKL_OPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLROPIS.pls 120.1 2005/10/30 04:35:26 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Sub type Open Interface records
  subtype oinv_rec_type is okl_oin_pvt.oinv_rec_type;
  subtype oinv_tbl_type is okl_oin_pvt.oinv_tbl_type;

  subtype oipv_rec_type is okl_oip_pvt.oipv_rec_type;
  subtype oipv_tbl_type is okl_oip_pvt.oipv_tbl_type;

  subtype iohv_rec_type is iex_ioh_pvt.iohv_rec_type;
  subtype iohv_tbl_type is iex_ioh_pvt.iohv_tbl_type;

  subtype oiav_rec_type is okl_oia_pvt.oiav_rec_type;
  subtype oiav_tbl_type is okl_oia_pvt.oiav_tbl_type;

  TYPE party_rec_type IS RECORD (
     party_id                       HZ_PARTIES.PARTY_ID%TYPE
    ,party_name                     HZ_PARTIES.PARTY_NAME%TYPE
    ,party_type                     HZ_PARTIES.PARTY_TYPE%TYPE
    ,date_of_birth                  HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE
    ,place_of_birth                 HZ_PERSON_PROFILES.PLACE_OF_BIRTH%TYPE
    ,person_identifier              HZ_PERSON_PROFILES.PERSON_IDENTIFIER%TYPE
    ,person_iden_type               HZ_PERSON_PROFILES.PERSON_IDEN_TYPE%TYPE
    ,country                        HZ_LOCATIONS.COUNTRY%TYPE
    ,address1                       HZ_LOCATIONS.ADDRESS3%TYPE
    ,address2                       HZ_LOCATIONS.ADDRESS2%TYPE
    ,address3                       HZ_LOCATIONS.ADDRESS1%TYPE
    ,address4                       HZ_LOCATIONS.ADDRESS4%TYPE
    ,city                           HZ_LOCATIONS.CITY%TYPE
    ,postal_code                    HZ_LOCATIONS.POSTAL_CODE%TYPE
    ,state                          HZ_LOCATIONS.STATE%TYPE
    ,province                       HZ_LOCATIONS.PROVINCE%TYPE
    ,county                         HZ_LOCATIONS.COUNTY%TYPE
    ,po_box_number                  HZ_LOCATIONS.PO_BOX_NUMBER%TYPE
    ,house_number                   HZ_LOCATIONS.HOUSE_NUMBER%TYPE
    ,street_suffix                  HZ_LOCATIONS.STREET_SUFFIX%TYPE
    ,apartment_number               HZ_LOCATIONS.APARTMENT_NUMBER%TYPE
    ,street                         HZ_LOCATIONS.STREET%TYPE
    ,rural_route_number             HZ_LOCATIONS.RURAL_ROUTE_NUMBER%TYPE
    ,street_number                  HZ_LOCATIONS.STREET_NUMBER%TYPE
    ,building                       HZ_LOCATIONS.BUILDING%TYPE
    ,floor                          HZ_LOCATIONS.FLOOR%TYPE
    ,suite                          HZ_LOCATIONS.SUITE%TYPE
    ,room                           HZ_LOCATIONS.ROOM%TYPE
    ,postal_plus4_code              HZ_LOCATIONS.POSTAL_PLUS4_CODE%TYPE
    ,phone_country_code             HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE
    ,phone_area_code                HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE
    ,phone_number                   HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE
    ,phone_extension                HZ_CONTACT_POINTS.PHONE_EXTENSION%TYPE);

  TYPE party_tbl_type IS TABLE OF party_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE contract_rec_type IS RECORD (
     khr_id                         OKC_K_HEADERS_V.ID%TYPE
    ,contract_number                OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE
    ,contract_type                  OKC_K_HEADERS_V.SCS_CODE%TYPE
    ,contract_status                OKC_K_HEADERS_V.STS_CODE%TYPE
    ,original_amount                OKL_OPEN_INT.ORIGINAL_AMOUNT%TYPE
    ,start_date                     OKC_K_HEADERS_V.START_DATE%TYPE
    ,close_date                     OKC_K_HEADERS_V.END_DATE%TYPE
    ,term_duration                  OKL_K_HEADERS.TERM_DURATION%TYPE
    ,monthly_payment_amount         OKL_OPEN_INT.MONTHLY_PAYMENT_AMOUNT%TYPE
    ,last_payment_date              OKL_OPEN_INT.LAST_PAYMENT_DATE%TYPE
    ,delinquency_occurance_date     OKL_OPEN_INT.DELINQUENCY_OCCURANCE_DATE%TYPE
    ,past_due_amount                OKL_OPEN_INT.PAST_DUE_AMOUNT%TYPE
    ,remaining_amount               OKL_OPEN_INT.REMAINING_AMOUNT%TYPE
    ,credit_indicator               OKL_OPEN_INT.CREDIT_INDICATOR%TYPE
    ,org_id                         OKL_OPEN_INT.ORG_ID%TYPE);

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_INVALID_PARTY               CONSTANT VARCHAR2(200) := 'OKL_INVALID_PARTY';
  G_INVALID_CONTRACT           	CONSTANT VARCHAR2(200) := 'OKL_INVALID_CONTRACT';
  G_INVALID_CASE                CONSTANT VARCHAR2(200) := 'OKL_INVALID_CASE';
  G_INVALID_ACTION_STATUS       CONSTANT VARCHAR2(200) := 'INVALID_ACTION_STATUS';
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := 'COL_NAME';
  G_COL_NAME1_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME1';
  G_COL_NAME2_TOKEN             CONSTANT VARCHAR2(200) := 'COL_NAME2';
  G_PARENT_TABLE_TOKEN	        CONSTANT VARCHAR2(200) := 'PARENT_TABLE';
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_PARENT_RECORD';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_OPI_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;

  PROCEDURE insert_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id              IN NUMBER,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);


  PROCEDURE process_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

  PROCEDURE process_pending_asset(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_iohv_rec                 IN iohv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2);

/*
  PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER);
*/

  PROCEDURE get_party(
     p_contract_id              IN NUMBER,
     x_party_rec                OUT NOCOPY party_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_guarantor(
     p_contract_id              IN NUMBER,
     x_party_tbl                OUT NOCOPY party_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_case(
     p_contract_id              IN NUMBER,
     x_cas_id                   OUT NOCOPY NUMBER,
     x_case_number              OUT NOCOPY VARCHAR2,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract(
     p_contract_id              IN NUMBER,
     x_contract_rec             OUT NOCOPY contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_contract_payment_info(
     p_contract_rec             IN contract_rec_type,
     x_contract_rec             OUT NOCOPY contract_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_case_owner(
     p_cas_id                    IN NUMBER,
     x_owner_resource_id         OUT NOCOPY NUMBER,
     x_resource_name             OUT NOCOPY VARCHAR2,
     x_resource_phone            OUT NOCOPY VARCHAR2,
     x_resource_email            OUT NOCOPY VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE get_assets(
     p_contract_id               IN NUMBER,
     x_oiav_tbl                  OUT NOCOPY oiav_tbl_type,
     x_return_status             OUT NOCOPY VARCHAR2);

--------------------------------------------------
-----------API SPEC ------------------------------
--------------------------------------------------
-- Procedure to merge parties
   PROCEDURE OKL_OPEN_INT_PARTY_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);

END OKL_OPI_PVT;

 

/
