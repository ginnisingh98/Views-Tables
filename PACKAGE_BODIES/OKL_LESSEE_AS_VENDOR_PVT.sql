--------------------------------------------------------
--  DDL for Package Body OKL_LESSEE_AS_VENDOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LESSEE_AS_VENDOR_PVT" AS
/* $Header: OKLRLVPB.pls 115.0 2003/10/09 00:48:58 cklee noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
  --------------------------------------------------------------------------
  ----- Validate Vendor
  --------------------------------------------------------------------------
  FUNCTION validate_vendor(
    p_ppydv_rec     ppydv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.vendor_id IS NULL) OR
       (p_ppydv_rec.vendor_id = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Pay As Vendor');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.vendor_id IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Pay As Vendor');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Vendor Site
  --------------------------------------------------------------------------
  FUNCTION validate_vendor_site(
    p_ppydv_rec     ppydv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.pay_site_id IS NULL) OR
       (p_ppydv_rec.pay_site_id = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Pay Site');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.pay_site_id IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Pay Site');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Payment Term
  --------------------------------------------------------------------------
  FUNCTION validate_payment_term(
    p_ppydv_rec     ppydv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.payment_term_id IS NULL) OR
       (p_ppydv_rec.payment_term_id = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Payment Term');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_ppydv_rec.payment_term_id IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Payment Term');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
    p_ppydv_rec     ppydv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:

    l_return_status := validate_vendor(p_ppydv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_vendor_site(p_ppydv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_header_attributes;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_lessee_as_vendor
-- Description     : wrapper api for create party payment details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_lessee_as_vendor(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  OKC_K_HEADERS_B.ID%TYPE
   ,p_ppydv_rec                    IN  ppydv_rec_type
   ,x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_lessee_as_vendor';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_ppydv_rec        ppydv_rec_type := p_ppydv_rec;
--  lx_ppydv_rec        ppydv_rec_type := x_ppydv_rec;
  l_cpl_id           okc_k_party_roles_b.id%type;

cursor c_cpl_id (p_chr_id number)
is
select kpr.id
from okc_k_party_roles_b kpr
where kpr.rle_code = 'LESSEE'
and kpr.dnz_chr_id = p_chr_id
;

begin
  -- Set API savepoint
  SAVEPOINT create_lessee_as_vendor;

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

    -- get cpl_id
    open c_cpl_id(p_chr_id);
    fetch c_cpl_id into l_cpl_id;
    close c_cpl_id;

    lp_ppydv_rec.cpl_id := l_cpl_id;

    l_return_status := validate_header_attributes(lp_ppydv_rec, G_INSERT_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

      okl_pyd_pvt.insert_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ppydv_rec       => lp_ppydv_rec,
          x_ppydv_rec       => x_ppydv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    lp_ppydv_rec.id := x_ppydv_rec.id;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_lessee_as_vendor;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_lessee_as_vendor;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_lessee_as_vendor;
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

end create_lessee_as_vendor;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_lessee_as_vendor
-- Description     : wrapper api for update party payment details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_lessee_as_vendor(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_ppydv_rec                    IN  ppydv_rec_type
   ,x_ppydv_rec                    OUT NOCOPY ppydv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_lessee_as_vendor';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_ppydv_rec        ppydv_rec_type := p_ppydv_rec;
--  lx_ppydv_rec        ppydv_rec_type := x_ppydv_rec;

begin
  -- Set API savepoint
  SAVEPOINT update_lessee_as_vendor;

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

    l_return_status := validate_header_attributes(lp_ppydv_rec, G_UPDATE_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

      okl_pyd_pvt.update_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_ppydv_rec       => lp_ppydv_rec,
          x_ppydv_rec       => x_ppydv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_lessee_as_vendor;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_lessee_as_vendor;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_lessee_as_vendor;
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

end update_lessee_as_vendor;


END OKL_LESSEE_AS_VENDOR_PVT;

/
