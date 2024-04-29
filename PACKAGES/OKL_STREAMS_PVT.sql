--------------------------------------------------------
--  DDL for Package OKL_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLCSTMS.pls 120.1 2005/05/30 12:26:26 kthiruva noship $ */

  SUBTYPE stmv_rec_type IS Okl_Stm_Pvt.stmv_rec_type;
  SUBTYPE stmv_tbl_type IS Okl_Stm_Pvt.stmv_tbl_type;

  SUBTYPE selv_rec_type IS Okl_Sel_Pvt.selv_rec_type;
  SUBTYPE selv_tbl_type IS Okl_Sel_Pvt.selv_tbl_type;
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_STREAMS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  --PROCEDURE ADD_LANGUAGE;

  --Object type procedure for insert
  PROCEDURE create_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_rec                     IN  stmv_rec_type
    ,p_selv_tbl                     IN  selv_tbl_type
    ,x_stmv_rec                     OUT NOCOPY stmv_rec_type
    ,x_selv_tbl                     OUT NOCOPY selv_tbl_type
     );

 --Object type procedure for insert(master-table,detail-table)
  PROCEDURE create_streams(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
     ,p_selv_tbl                    IN selv_tbl_type
     ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type
     ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     );

  --Added by kthiruva on 12-May-2005
  --For Streams Performance
  --Bug 4346646-Start of Changes

  --Object type procedure for insert(master-table,detail-table)
  PROCEDURE create_streams_perf(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
     ,p_selv_tbl                    IN selv_tbl_type
     ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type
     ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     );
  --Bug 4346646-End of Changes

  --Object type procedure for update
  PROCEDURE update_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_rec                     IN  stmv_rec_type
    ,p_selv_tbl                     IN  selv_tbl_type
    ,x_stmv_rec                     OUT NOCOPY stmv_rec_type
    ,x_selv_tbl                     OUT NOCOPY selv_tbl_type
     );

  --Object type procedure for validate
  PROCEDURE validate_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_rec                     IN  stmv_rec_type
    ,p_selv_tbl                     IN  selv_tbl_type
     );



  PROCEDURE create_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_tbl                     IN  stmv_tbl_type,
     x_stmv_tbl                     OUT NOCOPY stmv_tbl_type);

  PROCEDURE create_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_rec                     IN  stmv_rec_type,
     x_stmv_rec                     OUT NOCOPY stmv_rec_type);

  PROCEDURE lock_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,

     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_tbl                     IN  stmv_tbl_type);

  PROCEDURE lock_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_rec                     IN  stmv_rec_type);

  PROCEDURE update_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_tbl                     IN  stmv_tbl_type,
     x_stmv_tbl                     OUT NOCOPY stmv_tbl_type);

  PROCEDURE update_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_rec                     IN  stmv_rec_type,
     x_stmv_rec                     OUT NOCOPY stmv_rec_type);

  PROCEDURE delete_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_tbl                     IN  stmv_tbl_type);

  PROCEDURE delete_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_rec                     IN stmv_rec_type);

   PROCEDURE validate_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_tbl                     IN  stmv_tbl_type);

  PROCEDURE validate_streams(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_stmv_rec                     IN  stmv_rec_type);


  PROCEDURE create_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_tbl                     IN  selv_tbl_type,
     x_selv_tbl                     OUT NOCOPY selv_tbl_type);

  PROCEDURE create_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_rec                     IN  selv_rec_type,
     x_selv_rec                     OUT NOCOPY selv_rec_type);

  PROCEDURE lock_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_tbl                     IN  selv_tbl_type);

  PROCEDURE lock_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_rec                     IN  selv_rec_type);

  PROCEDURE update_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_tbl                     IN  selv_tbl_type,
     x_selv_tbl                     OUT NOCOPY selv_tbl_type);

  PROCEDURE update_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_rec                     IN  selv_rec_type,
     x_selv_rec                     OUT NOCOPY selv_rec_type);

  PROCEDURE delete_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_tbl                     IN  selv_tbl_type);

  PROCEDURE delete_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_rec                     IN  selv_rec_type);

   PROCEDURE validate_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_tbl                     IN  selv_tbl_type);

  PROCEDURE validate_stream_elements(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_selv_rec                     IN  selv_rec_type);
  PROCEDURE version_stream(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_khr_id 		            IN NUMBER,
     p_major_version 		    IN NUMBER) ;

END Okl_Streams_Pvt;

 

/
