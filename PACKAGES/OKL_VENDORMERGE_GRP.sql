--------------------------------------------------------
--  DDL for Package OKL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
  /* $Header: OKLRVMAS.pls 120.0.12000000.1 2007/04/12 10:38:40 pagarg noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_VENDORMERGE';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                    CONSTANT VARCHAR2(30)  := '_GRP';
  G_INIT_VERSION                CONSTANT NUMBER        := 1.0;

  -- ------------------------------------------------------------------------ *
  -- PROCEDURE    : Merge_Vendor
  -- ------------------------------------------------------------------------ *
  -- Description:
  --    This procedure updates OKL data when two vendors are merged.
  -- ------------------------------------------------------------------------ *

  PROCEDURE MERGE_VENDOR
  (p_api_version           IN          NUMBER
  ,p_init_msg_list         IN          VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_commit                IN          VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_validation_level      IN          NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_return_status         OUT NOCOPY  VARCHAR2
  ,p_msg_count             OUT NOCOPY  NUMBER
  ,p_msg_data              OUT NOCOPY  VARCHAR2
  ,p_vendor_id             IN          NUMBER
  ,p_dup_vendor_id         IN          NUMBER
  ,p_vendor_site_id        IN          NUMBER
  ,p_dup_vendor_site_id    IN          NUMBER
  ,p_party_id              IN          NUMBER
  ,P_dup_party_id          IN          NUMBER
  ,p_party_site_id         IN          NUMBER
  ,p_dup_party_site_id     IN          NUMBER
  );

END OKL_VENDORMERGE_GRP;

 

/
