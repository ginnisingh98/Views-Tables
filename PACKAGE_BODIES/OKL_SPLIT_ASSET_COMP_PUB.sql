--------------------------------------------------------
--  DDL for Package Body OKL_SPLIT_ASSET_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPLIT_ASSET_COMP_PUB" as
/* $Header: OKLPSACB.pls 115.1 2002/07/29 18:37:20 cklee noship $ */

------------------------------------------------------------------------------
    PROCEDURE create_split_asset_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN advv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
    IS

    l_api_version     CONSTANT NUMBER       := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'create_split_asset_comp';
    l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
  -- Set API savepoint
  SAVEPOINT create_split_asset_comp_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

--    OKL_ASD_PVT.insert_row(p_api_version,
    OKL_SPLIT_ASSET_COMP_PVT.create_split_asset_comp(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_asdv_tbl,
                           x_asdv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_split_asset_comp_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

    END create_split_asset_comp;

------------------------------------------------------------------------------

   PROCEDURE update_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type,
     x_asdv_tbl                     OUT NOCOPY advv_tbl_type)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'update_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
  -- Set API savepoint
  SAVEPOINT update_split_asset_comp_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
--     OKL_ASD_PVT.update_row(p_api_version,
    OKL_SPLIT_ASSET_COMP_PVT.update_split_asset_comp(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl,
                            x_asdv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_split_asset_comp_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

   END update_split_asset_comp;
------------------------------------------------------------------------------

   PROCEDURE delete_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_asdv_tbl                     IN advv_tbl_type)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'delete_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
  -- Set API savepoint
  SAVEPOINT delete_split_asset_comp_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
--     OKL_ASD_PVT.delete_row(p_api_version,
    OKL_SPLIT_ASSET_COMP_PVT.delete_split_asset_comp(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_asdv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_split_asset_comp_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

   END delete_split_asset_comp;
------------------------------------------------------------------------------

   PROCEDURE process_split_asset_comp(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tal_id                       IN NUMBER)
     IS

     l_api_version     CONSTANT NUMBER       := 1.0;
     l_api_name          CONSTANT VARCHAR2(30) := 'process_split_asset_comp';
     l_return_status              VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
  -- Set API savepoint
  SAVEPOINT process_split_asset_comp_pub;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
--
-- process code here
--
    OKL_SPLIT_ASSET_COMP_PVT.process_split_asset_comp(p_api_version,
                            p_init_msg_list,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            p_tal_id);
--
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO process_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_split_asset_comp_pub;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO process_split_asset_comp_pub;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

   END process_split_asset_comp;


END OKL_SPLIT_ASSET_COMP_PUB;

/
