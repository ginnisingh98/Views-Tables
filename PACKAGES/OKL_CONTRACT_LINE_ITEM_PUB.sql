--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_LINE_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_LINE_ITEM_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPCLIS.pls 115.2 2002/12/20 19:08:33 smereddy noship $ */

  subtype klev_rec_type is OKL_CONTRACT_LINE_ITEM_PVT.klev_rec_type;
  subtype klev_tbl_type is OKL_CONTRACT_LINE_ITEM_PVT.klev_tbl_type;
  subtype clev_rec_type is OKL_CONTRACT_LINE_ITEM_PVT.clev_rec_type;
  subtype clev_tbl_type is OKL_CONTRACT_LINE_ITEM_PVT.clev_tbl_type;
  subtype cimv_rec_type is OKL_CONTRACT_LINE_ITEM_PVT.cimv_rec_type;
  subtype cimv_tbl_type is OKL_CONTRACT_LINE_ITEM_PVT.cimv_tbl_type;

  subtype line_item_tbl_type is okl_contract_line_item_pvt.line_item_tbl_type;

-- Global variables for user hooks
  G_PKG_NAME  CONSTANT VARCHAR2(200) := 'okl_contract_line_item_pub';
  G_APP_NAME  CONSTANT VARCHAR2(3)   :=  'OKL';

  g_klev_rec  klev_rec_type;
  g_klev_tbl  klev_tbl_type;
  g_clev_rec  clev_rec_type;
  g_clev_tbl  clev_tbl_type;
  g_cimv_rec  cimv_rec_type;
  g_cimv_tbl  cimv_tbl_type;

  PROCEDURE create_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type,
      x_line_item_tbl                OUT NOCOPY line_item_tbl_type
      );

   PROCEDURE update_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type,
      x_line_item_tbl                OUT NOCOPY line_item_tbl_type
      );

  PROCEDURE delete_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type
      );

  PROCEDURE create_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type);

  PROCEDURE update_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type);

  PROCEDURE delete_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type);

 PROCEDURE create_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type);

  PROCEDURE delete_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type);

  PROCEDURE update_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type);

End OKL_CONTRACT_LINE_ITEM_PUB;

 

/
