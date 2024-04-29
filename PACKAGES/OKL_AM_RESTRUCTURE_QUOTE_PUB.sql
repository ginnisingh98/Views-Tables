--------------------------------------------------------
--  DDL for Package OKL_AM_RESTRUCTURE_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_RESTRUCTURE_QUOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRTQS.pls 115.0 2002/03/17 17:34:11 pkm ship        $ */

 SUBTYPE quot_rec_type IS OKL_AM_RESTRUCTURE_QUOTE_PVT.quot_rec_type;
 SUBTYPE quot_tbl_type IS OKL_AM_RESTRUCTURE_QUOTE_PVT.quot_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 ------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_RESTRUCTURE_QUOTE_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

 PROCEDURE create_restructure_quote(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_quot_rec                     IN  quot_rec_type
    ,x_quot_rec                     OUT  NOCOPY quot_rec_type);

 PROCEDURE create_restructure_quote(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_quot_tbl                     IN  quot_tbl_type
    ,x_quot_tbl                     OUT  NOCOPY quot_tbl_type);

 PROCEDURE update_restructure_quote(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_quot_rec                     IN  quot_rec_type
    ,x_quot_rec                     OUT  NOCOPY quot_rec_type);

 PROCEDURE update_restructure_quote(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_quot_tbl                     IN  quot_tbl_type
    ,x_quot_tbl                     OUT  NOCOPY quot_tbl_type);

END OKL_AM_RESTRUCTURE_QUOTE_PUB;

 

/
