--------------------------------------------------------
--  DDL for Package OKL_EQUIPMENT_EXCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EQUIPMENT_EXCHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLREQXS.pls 115.2 2002/11/30 08:46:59 spillaip noship $ */
  SUBTYPE thpv_tbl_type            IS okl_trx_assets_pvt.tavv_tbl_type;
  SUBTYPE tlpv_tbl_type            IS okl_txl_assets_pvt.tlvv_tbl_type;
  SUBTYPE talv_tbl_type 	   IS okl_txl_assets_pvt.tlvv_tbl_type;
  SUBTYPE iipv_tbl_type 	   IS okl_txl_itm_insts_pvt.iivv_tbl_type;
  SUBTYPE itiv_tbl_type 	   IS okl_iti_pvt.itiv_tbl_type;

  SUBTYPE cvmv_rec_type 	   IS OKL_OKC_MIGRATION_PVT.CVMV_REC_TYPE;


 FUNCTION GET_TAS_HDR_REC
        (p_thpv_tbl IN thpv_tbl_type
        ,p_no_data_found                OUT NOCOPY BOOLEAN
        ) RETURN thpv_tbl_type;
 FUNCTION get_status
        (p_status_code  IN      VARCHAR2)
        RETURN VARCHAR2;
 FUNCTION get_tal_rec
        (p_talv_tbl                     IN talv_tbl_type,
        x_no_data_found                OUT NOCOPY BOOLEAN)
         RETURN talv_tbl_type;
 FUNCTION get_vendor_name
        (p_vendor_id  IN      VARCHAR2)
        RETURN VARCHAR2;

 FUNCTION get_item_rec (
    p_itiv_tbl                     IN itiv_tbl_type,
    x_no_data_found                OUT NOCOPY BOOLEAN) RETURN itiv_tbl_type;

 FUNCTION get_exchange_type
        (p_tas_id  IN      NUMBER)
        RETURN VARCHAR2;

  PROCEDURE update_serial_number(
       p_api_version                    IN  NUMBER,
       p_init_msg_list                  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
       p_instance_id                    IN  NUMBER,
       p_instance_name                  IN  VARCHAR2,
       p_serial_number                  IN  VARCHAR2,
       p_inventory_item_id              IN  NUMBER,
       x_return_status                  OUT NOCOPY VARCHAR2,
       x_msg_count                      OUT NOCOPY NUMBER,
       x_msg_data                       OUT NOCOPY VARCHAR2);

   PROCEDURE store_exchange_details (
                        p_api_version                    IN  NUMBER,
                        p_init_msg_list                  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        p_thpv_tbl                       IN  thpv_tbl_type,
                        p_old_tlpv_tbl                   IN  tlpv_tbl_type,
                        p_new_tlpv_tbl                   IN  tlpv_tbl_type,
			p_old_iipv_tbl			 IN  iipv_tbl_type,
			p_new_iipv_tbl			 IN  iipv_tbl_type,
                        x_thpv_tbl                       OUT NOCOPY  thpv_tbl_type,
                        x_old_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
                        x_new_tlpv_tbl                   OUT NOCOPY  tlpv_tbl_type,
			x_old_iipv_tbl			 OUT NOCOPY  iipv_tbl_type,
			x_new_iipv_tbl			 OUT NOCOPY  iipv_tbl_type,
                        x_return_status                  OUT NOCOPY VARCHAR2,
                        x_msg_count                      OUT NOCOPY NUMBER,
                        x_msg_data                       OUT NOCOPY VARCHAR2);

   PROCEDURE exchange(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                p_tas_id                IN      NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2);

END okl_equipment_exchange_pvt;

 

/
