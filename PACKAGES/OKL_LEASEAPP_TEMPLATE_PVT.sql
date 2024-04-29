--------------------------------------------------------
--  DDL for Package OKL_LEASEAPP_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASEAPP_TEMPLATE_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRLATS.pls 120.1 2005/11/23 11:17:32 viselvar noship $ */

  SUBTYPE latv_rec_type IS OKL_LAT_PVT.latv_rec_type;
  SUBTYPE lavv_rec_type IS OKL_LAV_PVT.lavv_rec_type;
  TYPE error_msg_rec  IS RECORD (
      error_message    VARCHAR2(2500) DEFAULT OKL_API.G_MISS_CHAR
     ,error_type_code  VARCHAR2(30)   DEFAULT OKL_API.G_MISS_CHAR
     ,error_type_meaning VARCHAR2(30) DEFAULT OKL_API.G_MISS_CHAR);
  TYPE error_msgs_tbl_type IS TABLE OF error_msg_rec
       INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKL_LEASEAPP_TEMPLATE_PVT';
  G_APP_NAME                      CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN                CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR		          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	                CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_INIT_VERSION                  CONSTANT NUMBER        := 1.0;
  G_INIT_TMPLT_STATUS             CONSTANT VARCHAR2(100) := 'NEW';
  G_STATUS_ACTIVE                 CONSTANT VARCHAR2(30)  := 'ACTIVE';
  G_STATUS_UNDERREVISION          CONSTANT VARCHAR2(30)  := 'UNDEREVISION';
  G_STATUS_SUBMITTEDFORAPPROVAL   CONSTANT VARCHAR2(30)  := 'SUBFORAPPROVED';
  G_STATUS_INVALID                CONSTANT VARCHAR2(30)  := 'INVALID';
  G_STATUS_REJECTED               CONSTANT VARCHAR2(30)  := 'REJECTED';
  G_DEFAULT_MODE                  CONSTANT VARCHAR2(10)  := 'DUPLICATE';
  G_TYPE_ERROR                    CONSTANT VARCHAR2(12)  := 'E';
  G_TYPE_WARNING                  CONSTANT VARCHAR2(12)  := 'W';
  G_CP_SET_OUTCOME                CONSTANT VARCHAR2(30)  := 'CP_SET_OUTCOME';
  G_TEMPLATE_NUMBER               CONSTANT VARCHAR2(30)  := 'TEMPLATE_NUMBER';
  G_OKL_VAL_CHECKLIST_TEMPLATE    CONSTANT VARCHAR2(30)  := 'OKL_VAL_CHECKLIST_TEMPLATE';
  G_OKL_VAL_CONTRACT_TEMPLATE     CONSTANT VARCHAR2(30)  := 'OKL_VAL_CONTRACT_TEMPLATE';

  PROCEDURE create_leaseapp_template(
     p_api_version                IN NUMBER,
     p_init_msg_list              IN VARCHAR2,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2,
     p_latv_rec                   IN  latv_rec_type,
     x_latv_rec                   OUT NOCOPY latv_rec_type,
     p_lavv_rec                   IN  lavv_rec_type,
     x_lavv_rec                   OUT NOCOPY lavv_rec_type);

  PROCEDURE update_leaseapp_template(
     p_api_version                IN NUMBER,
     p_init_msg_list              IN VARCHAR2,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2,
     p_latv_rec                   IN  latv_rec_type,
     x_latv_rec                   OUT NOCOPY latv_rec_type,
     p_lavv_rec                   IN  lavv_rec_type,
     x_lavv_rec                   OUT NOCOPY lavv_rec_type,
     p_ident_flag                 IN VARCHAR2);

  PROCEDURE version_duplicate_lseapp_tmpl(
     p_api_version                IN NUMBER,
     p_init_msg_list              IN VARCHAR2,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2,
     p_latv_rec                   IN latv_rec_type,
     x_latv_rec                   OUT NOCOPY latv_rec_type,
     p_lavv_rec                   IN  lavv_rec_type,
     x_lavv_rec                   OUT NOCOPY lavv_rec_type,
     p_mode                       IN VARCHAR2);

  PROCEDURE validate_lease_app_template(
     p_api_version                IN NUMBER,
     p_init_msg_list              IN VARCHAR2,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2,
     p_latv_rec                   IN latv_rec_type,
     x_latv_rec                   OUT NOCOPY latv_rec_type,
     p_lavv_rec                   IN lavv_rec_type,
     x_lavv_rec                   OUT NOCOPY lavv_rec_type,
     p_during_upd_flag            IN VARCHAR2,
     x_error_msgs_tbl             OUT NOCOPY error_msgs_tbl_type);

  PROCEDURE max_valid_from_date(
     p_api_version               IN NUMBER,
     p_init_msg_list             IN VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2,
     p_latv_rec                  IN latv_rec_type,
     x_latv_rec                  OUT NOCOPY latv_rec_type);

  -- Bug#4741121 - smadhava  - Added - Start
  -- Start of comments
  --
  -- Procedure Name  : activate_lat
  -- Description     : Procedure to change the status of LAT once the workflow is approved
  -- Business Rules  : The LAT version and header statuses are moved to ACTIVE.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE activate_lat (p_api_version        IN NUMBER,
                          p_init_msg_list      IN VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_lat_version_id     IN         NUMBER);
  -- Bug#4741121 - smadhava  - Added - End
END OKL_LEASEAPP_TEMPLATE_PVT;

 

/
