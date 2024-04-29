--------------------------------------------------------
--  DDL for Package Body OKL_BLK_AST_UPD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BLK_AST_UPD_PUB" AS
/* $Header: OKLPBAUB.pls 120.2 2005/09/07 20:58:50 rkuttiya noship $ */

 --*************************************************************************--
 -- Start of comments
  -- Procedure Name	  : Update_Location
  -- Description	  : This procedure takes in location record parameter
  --                    calls pvt procedure to update location
  -- Business Rules   :
  -- Parameters		  : p_loc_rec - Location change record
  --
  -- Version		  : 1.0
  -- History          :
  -- End of comments
  --*************************************************************************--
PROCEDURE update_location(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                	 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_loc_rec                        IN  blk_rec_type,
                            x_return_status                	 OUT NOCOPY VARCHAR2,
                            x_msg_count                    	 OUT NOCOPY NUMBER,
                            x_msg_data                     	 OUT NOCOPY VARCHAR2)
  AS
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN

  --End Vertical User Hook Call

  --Call to private API

    OKL_BLK_AST_UPD_PVT.update_location( p_api_version                   => p_api_version,
                                        p_init_msg_list                  => p_init_msg_list,
                                        p_loc_rec                        => p_loc_rec,
                                        x_return_status                  => l_return_status,
                                        x_msg_count                      => l_msg_count,
                                        x_msg_data                       => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

 --End Call to Private API



  --End Vertical Post Processing Hook

  --Start Horizontal Post Processing Hook

  --End Horizontal Post Processing User Hook

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_BLK_AST_UPD_PUB','Update_Location');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_location;

--*************************************************************************--
 -- Start of comments
  -- Procedure Name	  : Update_Location
  -- Description	  : This procedure takes in location table parameter
  --                    calls pvt procedure to update location
  -- Business Rules   :
  -- Parameters		  : p_loc_tbl - Location change tbl
  --
  -- Version		  : 1.0
  -- History          :
  -- End of comments
  --*************************************************************************--


 PROCEDURE update_location(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                	 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            p_loc_tbl                        IN  blk_tbl_type,
                            x_return_status                	 OUT NOCOPY VARCHAR2,
                            x_msg_count                    	 OUT NOCOPY NUMBER,
                            x_msg_data                     	 OUT NOCOPY VARCHAR2)
  AS
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
  BEGIN





  --End Vertical User Hook Call

  --Call to private API

    OKL_BLK_AST_UPD_PVT.update_location( p_api_version                   => p_api_version,
                                        p_init_msg_list                  => p_init_msg_list,
                                        p_loc_tbl                        => p_loc_tbl,
                                        x_return_status                  => l_return_status,
                                        x_msg_count                      => l_msg_count,
                                        x_msg_data                       => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

 --End Call to Private API



  --End Vertical Post Processing Hook

  --Start Horizontal Post Processing Hook

  --End Horizontal Post Processing User Hook

  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_BLK_AST_UPD_PUB','Update_Location');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END update_location;

 END okl_blk_ast_upd_pub;

/
