--------------------------------------------------------
--  DDL for Package OKL_ACCT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCT_EVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCAETS.pls 115.3 2002/02/05 11:48:37 pkm ship       $ */

 SUBTYPE aetv_rec_type IS okl_aet_pvt.aetv_rec_type;
 SUBTYPE aetv_tbl_type IS okl_aet_pvt.aetv_tbl_type;

 SUBTYPE aehv_rec_type IS okl_aeh_pvt.aehv_rec_type;
 SUBTYPE aehv_tbl_type IS okl_aeh_pvt.aehv_tbl_type;

 SUBTYPE aelv_rec_type IS okl_ael_pvt.aelv_rec_type;
 SUBTYPE aelv_tbl_type IS okl_ael_pvt.aelv_tbl_type;

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ACCT_EVENT_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 --Object type procedure for insert
 PROCEDURE create_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
    ,p_aehv_tbl                     IN aehv_tbl_type

    ,p_aelv_tbl                     IN aelv_tbl_type

    ,x_aetv_rec                     OUT NOCOPY aetv_rec_type
    ,x_aehv_tbl                     OUT NOCOPY aehv_tbl_type
    ,x_aelv_tbl                     OUT NOCOPY aelv_tbl_type
    );

 --Object type procedure for update
 PROCEDURE update_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
   ,p_aehv_tbl                     IN aehv_tbl_type
	,p_aelv_tbl                     IN aelv_tbl_type
   ,x_aetv_rec                     OUT NOCOPY aetv_rec_type
   ,x_aehv_tbl                     OUT NOCOPY aehv_tbl_type
   ,x_aelv_tbl                     OUT NOCOPY aelv_tbl_type
    );

 --Object type procedure for validate
 PROCEDURE validate_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
   ,p_aehv_tbl                     IN aehv_tbl_type
   ,p_aelv_tbl                     IN aelv_tbl_type
    );


 PROCEDURE create_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type,
    x_aetv_tbl                     OUT NOCOPY aetv_tbl_type);

 PROCEDURE create_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type,
    x_aetv_rec                     OUT NOCOPY aetv_rec_type);

 PROCEDURE lock_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type);

 PROCEDURE lock_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type);

 PROCEDURE update_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type,
    x_aetv_tbl                     OUT NOCOPY aetv_tbl_type);

 PROCEDURE update_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type,
    x_aetv_rec                     OUT NOCOPY aetv_rec_type);

 PROCEDURE delete_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type);

 PROCEDURE delete_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type);

  PROCEDURE validate_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_tbl                     IN aetv_tbl_type);

 PROCEDURE validate_acct_event(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aetv_rec                     IN aetv_rec_type);


 PROCEDURE create_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type);

 PROCEDURE create_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type);

 PROCEDURE lock_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

 PROCEDURE lock_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);

 PROCEDURE update_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type);

 PROCEDURE update_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type);

 PROCEDURE delete_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

 PROCEDURE delete_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);

  PROCEDURE validate_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

 PROCEDURE validate_acct_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);


 PROCEDURE create_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type);

 PROCEDURE create_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type);

 PROCEDURE lock_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

 PROCEDURE lock_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

 PROCEDURE update_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type);

 PROCEDURE update_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type);

 PROCEDURE delete_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

 PROCEDURE delete_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

  PROCEDURE validate_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

 PROCEDURE validate_acct_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

END okl_acct_event_pvt;


 

/
