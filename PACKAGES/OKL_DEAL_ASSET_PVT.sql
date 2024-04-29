--------------------------------------------------------
--  DDL for Package OKL_DEAL_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEAL_ASSET_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRDASS.pls 120.1.12010000.2 2010/05/11 10:16:03 smadhava ship $ */

-------------------------------------------------------------------------------------------------
-- COMPOSITE VARIABLES
-------------------------------------------------------------------------------------------------
  TYPE las_rec_type IS RECORD (deal_type              OKL_K_HEADERS.DEAL_TYPE%TYPE,
                               inventory_item_id      MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
                               inventory_org_id       MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
                               inventory_item_name    MTL_SYSTEM_ITEMS_TL.DESCRIPTION%TYPE,
                               release_asset_flag     BOOLEAN,
                               asset_id               FA_ADDITIONS_B.ASSET_ID%TYPE,
                               asset_number           FA_ADDITIONS_B.ASSET_NUMBER%TYPE,
                               description            FA_ADDITIONS_TL.DESCRIPTION%TYPE,
                               unit_cost              OKC_K_LINES_B.PRICE_UNIT%TYPE,
                               units                  NUMBER,
                               old_units              NUMBER,
                               model_number           OKL_K_LINES.MODEL_NUMBER%TYPE,
                               manufacturer_name      OKL_TXL_ASSETS_B.MANUFACTURER_NAME%TYPE,
                               year_manufactured      OKL_TXL_ASSETS_B.YEAR_MANUFACTURED%TYPE,
                               party_site_use_id      NUMBER,
                               party_site_name        HZ_PARTY_SITES.PARTY_SITE_NAME%TYPE, -- Bug#9690862
                               fa_location_id         OKL_TXL_ASSETS_B.FA_LOCATION_ID%TYPE,
                               fa_location_name       VARCHAR2(210),
                               asset_key_id           OKL_TXL_ASSETS_B.ASSET_KEY_ID%TYPE,
                               asset_key_name         VARCHAR2(300),
                               prescribed_asset_yn    OKL_K_LINES.PRESCRIBED_ASSET_YN%TYPE,
                               date_delivery_expected OKL_K_LINES.DATE_DELIVERY_EXPECTED%TYPE,
                               date_funding_expected  OKL_K_LINES.DATE_FUNDING_EXPECTED%TYPE,
                               residual_percentage    OKL_K_LINES.RESIDUAL_PERCENTAGE%TYPE,
                               residual_value         OKL_K_LINES.RESIDUAL_VALUE%TYPE,
                               residual_code          OKL_K_LINES.RESIDUAL_CODE%TYPE,
                               guranteed_amount       OKL_K_LINES.RESIDUAL_GRNTY_AMOUNT%TYPE,
                               rvi_premium            OKL_K_LINES.RVI_PREMIUM%TYPE,
                               currency_code          OKC_K_HEADERS_B.CURRENCY_CODE%TYPE,
                               dnz_chr_id             OKC_K_LINES_B.DNZ_CHR_ID%TYPE,
                               clev_fin_id            OKC_K_LINES_B.ID%TYPE,
                               clev_model_id          OKC_K_LINES_B.ID%TYPE,
                               clev_fa_id             OKC_K_LINES_B.ID%TYPE,
                               clev_ib_id             OKC_K_LINES_B.ID%TYPE,
                               -- gboomina added tal_id to populate corp deprn id
			       -- while creating asset and corp book deprn together.
                               tal_id                 OKL_TXL_ASSETS_B.ID%TYPE,
                               attribute_category     OKL_K_LINES.ATTRIBUTE_CATEGORY%TYPE,
                               attribute1             OKL_K_LINES.ATTRIBUTE1%TYPE,
                               attribute2             OKL_K_LINES.ATTRIBUTE2%TYPE,
                               attribute3             OKL_K_LINES.ATTRIBUTE3%TYPE,
                               attribute4             OKL_K_LINES.ATTRIBUTE4%TYPE,
                               attribute5             OKL_K_LINES.ATTRIBUTE5%TYPE,
                               attribute6             OKL_K_LINES.ATTRIBUTE6%TYPE,
                               attribute7             OKL_K_LINES.ATTRIBUTE7%TYPE,
                               attribute8             OKL_K_LINES.ATTRIBUTE8%TYPE,
                               attribute9             OKL_K_LINES.ATTRIBUTE9%TYPE,
                               attribute10            OKL_K_LINES.ATTRIBUTE10%TYPE,
                               attribute11            OKL_K_LINES.ATTRIBUTE11%TYPE,
                               attribute12            OKL_K_LINES.ATTRIBUTE12%TYPE,
                               attribute13            OKL_K_LINES.ATTRIBUTE13%TYPE,
                               attribute14            OKL_K_LINES.ATTRIBUTE14%TYPE,
                               attribute15            OKL_K_LINES.ATTRIBUTE15%TYPE);

  TYPE addon_rec_type IS RECORD (
    cleb_addon_id        OKC_K_LINES_B.ID%TYPE,
    dnz_chr_id           OKC_K_LINES_B.dnz_chr_id%TYPE,
    price_unit           OKC_K_LINES_B.price_unit%TYPE,
    inventory_item_id    MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
    inventory_org_id     MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
    jtot_object1_code    OKC_K_ITEMS.jtot_object1_code%TYPE,
    number_of_items      OKC_K_ITEMS.number_of_items%TYPE,
    manufacturer_name    OKL_K_LINES.manufacturer_name%TYPE,
    model_number         OKL_K_LINES.model_number%TYPE,
    year_of_manufacture  OKL_K_LINES.year_of_manufacture%TYPE,
    vendor_name          PO_VENDORS.vendor_name%TYPE,
    party_role_id        OKC_K_PARTY_ROLES_B.cpl_id%TYPE,
    vendor_id            OKC_K_PARTY_ROLES_B.object1_id1%TYPE,
    object1_id2          OKC_K_PARTY_ROLES_B.object1_id2%TYPE,
    rle_code             OKC_K_PARTY_ROLES_B.rle_code%TYPE,
    comments             OKC_K_LINES_TL.comments%TYPE);

  TYPE addon_tbl_type IS TABLE OF addon_rec_type INDEX BY BINARY_INTEGER;

  TYPE down_payment_rec_type IS RECORD (
       cleb_fin_id                  OKC_K_LINES_B.id%TYPE,
       dnz_chr_id                   OKC_K_LINES_B.dnz_chr_id%TYPE,
       asset_number                 OKC_K_LINES_TL.name%TYPE,
       asset_cost                   OKL_K_LINES.oec%TYPE,
       description                  OKC_K_LINES_TL.item_description%TYPE,
       basis                        FND_LOOKUPS.lookup_code%TYPE,
       down_payment                 OKL_K_LINES.capital_reduction%TYPE,
       down_payment_receiver_code   OKL_K_LINES.down_payment_receiver_code%TYPE,
       capitalize_down_payment_yn   OKL_K_LINES.capitalize_down_payment_yn%TYPE);

  TYPE down_payment_tbl_type IS TABLE OF down_payment_rec_type INDEX BY BINARY_INTEGER;

  TYPE tradein_rec_type is record
  (
     cleb_fin_id      OKC_K_LINES_B.id%TYPE,
     dnz_chr_id       OKC_K_LINES_B.dnz_chr_id%TYPE,
     asset_number     OKC_K_LINES_TL.name%TYPE,
     asset_cost       OKL_K_LINES.oec%TYPE,
     description      OKC_K_LINES_TL.item_description%TYPE,
     tradein_amount   OKL_K_LINES.tradein_amount%TYPE
   );

  TYPE tradein_tbl_type is table of tradein_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE process_line_billing_setup(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_rgpv_rec       IN  OKL_DEAL_TERMS_PVT.billing_setup_rec_type,
            x_rgpv_rec       OUT NOCOPY OKL_DEAL_TERMS_PVT.billing_setup_rec_type);

   PROCEDURE load_line_billing_setup(
      p_api_version                IN  NUMBER,
      p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2,
      p_dnz_chr_id                 IN  NUMBER,
      p_cle_id                     IN  NUMBER,
      x_billing_setup_rec          OUT NOCOPY OKL_DEAL_TERMS_PVT.billing_setup_rec_type);

  PROCEDURE create_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_rec      IN  addon_rec_type,
            x_addon_rec      OUT NOCOPY addon_rec_type);

  PROCEDURE create_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_tbl      IN  addon_tbl_type,
            x_addon_tbl      OUT NOCOPY addon_tbl_type);

  PROCEDURE update_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_rec      IN  addon_rec_type,
            x_addon_rec      OUT NOCOPY addon_rec_type);

  PROCEDURE update_assetaddon_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_addon_tbl      IN  addon_tbl_type,
            x_addon_tbl      OUT NOCOPY addon_tbl_type);

  PROCEDURE create_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_las_rec        IN  las_rec_type,
            x_las_rec        OUT NOCOPY las_rec_type);

  PROCEDURE update_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_las_rec        IN  las_rec_type,
            x_las_rec        OUT NOCOPY las_rec_type);

  PROCEDURE load_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER,
            p_clev_fin_id    IN  NUMBER,
            x_las_rec        OUT NOCOPY las_rec_type);

  FUNCTION addon_ship_to_site_name(
           p_site_use_id     IN NUMBER
           )
            RETURN VARCHAR2;

  PROCEDURE allocate_amount_tradein (
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  NUMBER,
            p_tradein_amount       IN  NUMBER,
            p_mode                 IN  VARCHAR2,
            x_tradein_tbl          OUT NOCOPY tradein_tbl_type);

  PROCEDURE allocate_amount_down_payment (
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_chr_id               IN  NUMBER,
            p_down_payment         IN  NUMBER,
            p_basis                IN  VARCHAR2,
            p_mode                 IN  VARCHAR2,
            x_down_payment_tbl     OUT NOCOPY down_payment_tbl_type);

   FUNCTION get_subsidy_amount(
            p_khr_id         IN  NUMBER,
            p_subsidy_id IN  NUMBER)
            RETURN VARCHAR2;

   FUNCTION get_down_payment_amount(
            p_khr_id         IN  NUMBER)
            RETURN VARCHAR2;

End OKL_DEAL_ASSET_PVT;

/
