--------------------------------------------------------
--  DDL for Package Body OKL_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FUNDING_PUB" AS
/* $Header: OKLPFUNB.pls 120.4 2007/11/20 08:23:33 dcshanmu noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
-- see FND_NEW_MESSAGES for full message text
G_NOT_FOUND                  CONSTANT VARCHAR2(30) := 'OKC_NOT_FOUND';  -- message_name
G_NOT_FOUND_V1               CONSTANT VARCHAR2(30) := 'VALUE1';         -- token 1
G_NOT_FOUND_V2               CONSTANT VARCHAR2(30) := 'VALUE2';         -- token 2

G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_UNIQUE';  -- never mind the blockhead that created the name

G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

G_NO_INIT_MSG                CONSTANT VARCHAR2(1)  := OKL_API.G_FALSE;
G_VIEW                       CONSTANT VARCHAR2(30) := 'OKL_TRX_AP_INVOICES_V';

G_FND_APP                    CONSTANT VARCHAR2(30) := OKL_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(30) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(30) := OKL_API.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED	 CONSTANT VARCHAR2(30) := OKL_API.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE             CONSTANT VARCHAR2(30) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE              CONSTANT VARCHAR2(30) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN             CONSTANT VARCHAR2(30) := OKL_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(30) := OKL_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(30) := OKL_API.G_CHILD_TABLE_TOKEN;
G_NO_PARENT_RECORD           CONSTANT VARCHAR2(30) :='OKL_NO_PARENT_RECORD';
G_NOT_SAME                   CONSTANT VARCHAR2(30) :='OKL_CANNOT_BE_SAME';

G_PREFUNDING_TYPE            CONSTANT VARCHAR2(30) :='PREFUNDING';
G_ASSET_TYPE                 CONSTANT VARCHAR2(30) :='ASSET';
G_INVOICE_TYPE               CONSTANT VARCHAR2(30) :='INVOICE';
G_FUNDING_TRX_TYPE           CONSTANT VARCHAR2(30) :='FUNDING';
----------------------------------------------------------------------------
-- Private Global variables
----------------------------------------------------------------------------

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Public Procedures and Functions
----------------------------------------------------------------------------
----------------------------------------------------------------------------
PROCEDURE create_funding_header(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tapv_rec                     IN tapv_rec_type
 ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_HEADER';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tapv_rec                 tapv_rec_type := p_tapv_rec;
  i                          NUMBER;
    l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_HEADER_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OKL_FUNDING_PVT.create_funding_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_HEADER_PUB;
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

  END create_funding_header;
----------------------------------------------------------------------------

PROCEDURE update_funding_header(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tapv_rec                     IN tapv_rec_type
 ,x_tapv_rec                     OUT NOCOPY tapv_rec_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_FUNDING_HEADER';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tapv_rec                 tapv_rec_type := p_tapv_rec;
  i                          NUMBER;
    l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT UPDATE_FUNDING_HEADER_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OKL_FUNDING_PVT.update_funding_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => l_tapv_rec,
      x_tapv_rec      => x_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO UPDATE_FUNDING_HEADER_PUB;
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

  END update_funding_header;

----------------------------------------------------------------------------

PROCEDURE delete_funding_header(
  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_tapv_rec                     IN tapv_rec_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_FUNDING_HEADER';
  l_api_version     CONSTANT NUMBER       := 1.0;

BEGIN
  -- Set API savepoint
  SAVEPOINT DELETE_FUNDING_HEADER_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

--    OKL_TAP_PVT.delete_row(
      OKL_TRX_AP_INVOICES_PUB.DELETE_TRX_AP_INVOICES(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => p_tapv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO DELETE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_FUNDING_HEADER_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO DELETE_FUNDING_HEADER_PUB;
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

END delete_funding_header;
----------------------------------------------------------------------------

PROCEDURE create_funding_lines(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
 ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_LINES';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tplv_tbl                 tplv_tbl_type := p_tplv_tbl;
  i                          NUMBER;
  l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_LINES_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OKL_FUNDING_PVT.create_funding_lines(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl,
      x_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_LINES_PUB;
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

  END create_funding_lines;

----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- dcshanmu - Added - Qucik Fund performance fix - start
----------------------------------------------------------------------------

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
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_LINES';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_LINES_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OKL_FUNDING_PVT.create_funding_lines(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_hdr_id	=>	p_hdr_id,
      p_khr_id      => p_khr_id,
      p_vendor_site_id	=> p_vendor_site_id,
      x_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_LINES_PUB;
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

  END create_funding_lines;

----------------------------------------------------------------------------
-- dcshanmu - Added - Qucik Fund performance fix - end
----------------------------------------------------------------------------


PROCEDURE update_funding_lines(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_tplv_tbl                     IN tplv_tbl_type
 ,x_tplv_tbl                     OUT NOCOPY tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_FUNDING_LINES';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_tplv_tbl                 tplv_tbl_type := p_tplv_tbl;
  i                          NUMBER;
  l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT UPDATE_FUNDING_LINES_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OKL_FUNDING_PVT.update_funding_lines(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl,
      x_tplv_tbl      => x_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_FUNDING_LINES_PUB;
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

END update_funding_lines;
----------------------------------------------------------------------------

PROCEDURE delete_funding_lines(
  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_tplv_tbl                     IN tplv_tbl_type
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_FUNDING_LINES';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_id                     OKL_TRX_AP_INVOICES_B.ID%TYPE;
  l_tplv_tbl        tplv_tbl_type := p_tplv_tbl;

    CURSOR c (p_line_id NUMBER)
    IS
      SELECT l.tap_id
        FROM OKL_TXL_AP_INV_LNS_B l
       WHERE l.id = p_line_id
    ;

BEGIN
  -- Set API savepoint
  SAVEPOINT DELETE_FUNDING_LINES_PUB;

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

/*

*/

/*** Begin API body ****************************************************/

    OPEN c (p_tplv_tbl(p_tplv_tbl.FIRST).id);
    FETCH c INTO l_id;
    CLOSE c;

    l_tplv_tbl(p_tplv_tbl.FIRST).tap_id := l_id;

--    OKL_TPL_PVT.delete_row(
    OKL_TXL_AP_INV_LNS_PUB.DELETE_TXL_AP_INV_LNS(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => p_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

-- sync funding header amount
    OKL_FUNDING_PVT.SYNC_HEADER_AMOUNT(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tplv_tbl      => l_tplv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*** End API body ******************************************************/

/*

*/
  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO DELETE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_FUNDING_LINES_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO DELETE_FUNDING_LINES_PUB;
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

END delete_funding_lines;
----------------------------------------------------------------------------
PROCEDURE create_funding_assets(
  p_api_version                  IN NUMBER
 ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
 ,p_fund_id                      IN NUMBER
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_FUNDING_ASSETS';
  l_api_version     CONSTANT NUMBER       := 1.0;
  i                          NUMBER;
  l_dummy VARCHAR2(1) := OKL_API.G_TRUE;

BEGIN
  -- Set API savepoint
  SAVEPOINT CREATE_FUNDING_ASSETS_PUB;

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

    OKL_FUNDING_PVT.create_funding_assets(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_fund_id       => p_fund_id);

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
    ROLLBACK TO CREATE_FUNDING_ASSETS_PUB;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_FUNDING_ASSETS_PUB;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO CREATE_FUNDING_ASSETS_PUB;
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

  END create_funding_assets;

----------------------------------------------------------------------------

END OKL_FUNDING_PUB;

/
