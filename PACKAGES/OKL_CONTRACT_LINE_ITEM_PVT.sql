--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_LINE_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_LINE_ITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCLIS.pls 115.4 2003/09/23 14:20:31 kthiruva noship $ */

subtype klev_rec_type is okl_kle_pvt.klev_rec_type;
subtype klev_tbl_type is okl_kle_pvt.klev_tbl_type;
subtype clev_rec_type is okl_okc_migration_pvt.clev_rec_type;
subtype clev_tbl_type is okl_okc_migration_pvt.clev_tbl_type;
subtype cimv_rec_type is okl_okc_migration_pvt.cimv_rec_type;
subtype cimv_tbl_type is okl_okc_migration_pvt.cimv_tbl_type;

TYPE link_ast_rec_type is record (id1         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR,
                              id2         OKC_K_ITEMS_V.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR,
                              name        VARCHAR2(250) := OKL_API.G_MISS_CHAR,
                              object_code VARCHAR2(30)  := OKL_API.G_MISS_CHAR);
TYPE link_ast_tbl_type is table of link_ast_rec_type INDEX BY BINARY_INTEGER;

G_PKG_NAME   	              CONSTANT VARCHAR2(200) := 'okl_contract_line_item_pvt';
G_APP_NAME  	              CONSTANT VARCHAR2(3) :=  'OKL';

TYPE line_item_rec_type is record (
        chr_id  okl_k_lines_full_v.id%type,
        parent_cle_id okl_k_lines_full_v.id%type,
        cle_id okl_k_lines_full_v.id%type,
	item_id okc_k_items_v.id%type,
	item_id1 okc_k_items_v.object1_id1%type,
	item_id2 okc_k_items_v.object1_id2%type,
	item_object1_code okc_k_items_v.jtot_object1_code%type,
	item_description okc_k_lines_tl.item_description%type,
	name okc_k_lines_tl.name%type,
	capital_amount okl_k_lines_full_v.capital_amount%type,
	serv_cov_prd_id okl_k_lines.id%type
	);
TYPE line_item_tbl_type is table of line_item_rec_type INDEX BY BINARY_INTEGER;

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

  PROCEDURE delete_contract_line_item(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type);

END OKL_CONTRACT_LINE_ITEM_PVT;

 

/
