--------------------------------------------------------
--  DDL for Package OKL_DFLEX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DFLEX_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRDFUS.pls 120.0 2005/10/18 17:29:49 rpillay noship $ */

  TYPE DFF_Rec_Type IS RECORD
  (
   attribute_category  VARCHAR2(30)  := NULL,
   attribute1          VARCHAR2(150) := NULL,
   attribute2          VARCHAR2(150) := NULL,
   attribute3          VARCHAR2(150) := NULL,
   attribute4          VARCHAR2(150) := NULL,
   attribute5          VARCHAR2(150) := NULL,
   attribute6          VARCHAR2(150) := NULL,
   attribute7          VARCHAR2(150) := NULL,
   attribute8          VARCHAR2(150) := NULL,
   attribute9          VARCHAR2(150) := NULL,
   attribute10         VARCHAR2(150) := NULL,
   attribute11         VARCHAR2(150) := NULL,
   attribute12         VARCHAR2(150) := NULL,
   attribute13         VARCHAR2(150) := NULL,
   attribute14         VARCHAR2(150) := NULL,
   attribute15         VARCHAR2(150) := NULL
  );

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_DFLEX_UTIL_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

  PROCEDURE validate_desc_flex
  (p_api_version                  IN  NUMBER
  ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_appl_short_name              IN  VARCHAR2
  ,p_descflex_name                IN  VARCHAR2
  ,p_segment_partial_name         IN  VARCHAR2
  ,p_segment_values_rec           IN  DFF_Rec_type
  );

  PROCEDURE update_contract_add_info
  (p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_chr_id                       IN  NUMBER
  ,p_add_info_rec                 IN  DFF_Rec_type
  );

  PROCEDURE update_line_add_info
  (p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_cle_id                       IN  NUMBER
  ,p_add_info_rec                 IN  DFF_Rec_type
  );

END OKL_DFLEX_UTIL_PVT;

 

/
