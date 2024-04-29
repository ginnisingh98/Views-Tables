--------------------------------------------------------
--  DDL for Package OKS_QP_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_QP_INT" AUTHID CURRENT_USER AS
/* $Header: OKSGPINS.pls 120.0 2005/05/25 18:01:06 appldev noship $ */

   G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
   G_INVALID_VALUE        CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
   G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

   G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := OKC_API.G_RET_STS_UNEXP_ERROR;

   ------------------------------------------------------------------
   -- GLOBAL EXCEPTION
   ------------------------------------------------------------------
   G_EXC_ERROR                     EXCEPTION;
   G_EXC_UNEXPECTED_ERROR          EXCEPTION;

   ------------------------------------------------------------------
   --  Global constant holding the package name
   ------------------------------------------------------------------
   G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OKS_QP_INT';
   G_APP_NAME              CONSTANT VARCHAR2(3)  := 'OKS';

   PROCEDURE GET_CONVERSION_FACTOR (
                 p_api_version       IN         NUMBER,
                 p_init_msg_list     IN         VARCHAR2,
                 p_start_date        IN         DATE,
                 p_end_date          IN         DATE,
                 p_pb_uom            IN         VARCHAR2,
                 x_factor            OUT NOCOPY NUMBER,
                 x_return_status     OUT NOCOPY VARCHAR2,
                 x_msg_count         OUT NOCOPY NUMBER,
                 x_msg_data          OUT NOCOPY VARCHAR2
       );

END OKS_QP_INT;

 

/
