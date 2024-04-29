--------------------------------------------------------
--  DDL for Package OKL_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FUNDING_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPFUNS.pls 120.2 2007/11/20 08:23:07 dcshanmu ship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_FUNDING_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 subtype tapv_rec_type is okl_tap_pvt.tapv_rec_type;
 subtype tapv_tbl_type is okl_tap_pvt.tapv_tbl_type;
 subtype tplv_rec_type is okl_tpl_pvt.tplv_rec_type;
 subtype tplv_tbl_type is okl_tpl_pvt.tplv_tbl_type;

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------

 PROCEDURE create_funding_header(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tapv_rec                     IN tapv_rec_type
   ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
 );

 PROCEDURE update_funding_header(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tapv_rec                     IN tapv_rec_type
   ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
 );

 PROCEDURE delete_funding_header(
    p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tapv_rec                     IN tapv_rec_type
 );

  PROCEDURE create_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tplv_tbl                     IN tplv_tbl_type
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

  PROCEDURE create_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_hdr_id				IN NUMBER
   ,p_khr_id				IN NUMBER
   ,p_vendor_site_id		IN NUMBER
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

 PROCEDURE update_funding_lines(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tplv_tbl                     IN tplv_tbl_type
   ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
 );

 PROCEDURE delete_funding_lines(
    p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tplv_tbl                     IN tplv_tbl_type
 );

 PROCEDURE create_funding_assets(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_id                      IN NUMBER
 );


END OKL_FUNDING_PUB;

/
