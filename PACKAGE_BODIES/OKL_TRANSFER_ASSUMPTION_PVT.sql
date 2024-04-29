--------------------------------------------------------
--  DDL for Package Body OKL_TRANSFER_ASSUMPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANSFER_ASSUMPTION_PVT" AS
/* $Header: OKLRTNAB.pls 120.1 2005/10/30 03:17:30 appldev noship $ */
 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
  subtype khrv_rec_type is OKL_KHR_pvt.khrv_rec_type;
  subtype chrv_rec_type is okl_okc_migration_pvt.chrv_rec_type;

----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
G_CONTRACT_FINANCED_AMOUNT    constant varchar2(40) :='CONTRACT_FINANCED_AMOUNT';
G_LINE_FINANCED_AMOUNT        constant varchar2(40) :='LINE_FINANCED_AMOUNT';
----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_tna_creditline
-- Description     : Calculate total Transfers and Assumption amount based on
--                   pass in Contarct and correlated credit line ID and update
--                   credit line tna amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_tna_creditline(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type -- contract ID
   ,p_credit_line_id               IN  okc_k_headers_b.id%type -- credit line ID
   ,p_formula_name                 IN VARCHAR2
   ,p_credit_flag                  IN BOOLEAN default false
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_tna_creditline';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_src_chr_not_found  boolean := false;
  l_credit_tna     NUMBER;
  l_orig_credit_tna     NUMBER;

  l_chrv_rec         chrv_rec_type;
  l_khrv_rec         khrv_rec_type;
  x_chrv_rec         chrv_rec_type;
  x_khrv_rec         khrv_rec_type;


cursor c_credit_tna (p_chr_id okc_k_headers_b.id%TYPE)
  is
  select NVL(khr.TOT_CL_NET_TRANSFER_AMT,0)
from okl_k_headers khr
where khr.id = p_chr_id
;


begin
  -- Set API savepoint
  SAVEPOINT update_tna_creditline;

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

    OKL_EXECUTE_FORMULA_PUB.execute(
      p_api_version   => l_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_formula_name  => p_formula_name,
      p_contract_id   => p_chr_id,
      x_value         => l_credit_tna);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- get credit line tna amount
    open c_credit_tna(p_credit_line_id);
    fetch c_credit_tna into l_orig_credit_tna;
    close c_credit_tna;

    -- set credit line record's value
    l_chrv_rec.id := p_credit_line_id;
    l_khrv_rec.id := p_credit_line_id;

    -- change to negative sign if credit flag is true
    if (p_credit_flag) then
      l_credit_tna := -l_credit_tna;
    end if;

    l_khrv_rec.TOT_CL_NET_TRANSFER_AMT := l_orig_credit_tna + l_credit_tna;

    okl_contract_pvt.update_contract_header(
      p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_restricted_update   => 'F',
      p_chrv_rec            => l_chrv_rec,
      p_khrv_rec            => l_khrv_rec,
      x_chrv_rec            => x_chrv_rec,
      x_khrv_rec            => x_khrv_rec);

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
    ROLLBACK TO update_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_tna_creditline;
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

end update_tna_creditline;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_full_tna_creditline
-- Description     : Calculate total Transfers and Assumption amount based on
--                   pass in contract ID and update correlated credit lines' tna amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_full_tna_creditline(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_full_tna_creditline';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_src_credit_id      NUMBER;
  l_dst_credit_id      NUMBER;
  l_src_chr_id         NUMBER;
  l_src_chr_not_found  boolean := false;

cursor c_src_chr (p_chr_id okc_k_headers_b.id%TYPE)
  is
  select chr.ORIG_SYSTEM_ID1
from okc_k_headers_b chr
where chr.id = p_chr_id
;

begin
  -- Set API savepoint
  SAVEPOINT update_full_tna_creditline;

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
/*
       -> contract T and A
       5.1 get credit line ID for destination contract if any (ignore if credit line not found?)
       5.2 get source contract's ID via okc_k_headers_b.ORIG_SYSTEM_ID1 (raise system error if not found)
       5.3 get credit line ID for source contract if any (ignore if credit line not found?)

       5.4
       IF source contract credit line exists THEN
         get total T and A for source contract via formula CONTRACT_FINANCED_AMOUNT
         Update (add this amount as positive to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT)
         T and A for source contract's credit line
       END IF;

       5.5
       IF destination contract credit line exists THEN
         get total T and A for destination contract via formula CONTRACT_FINANCED_AMOUNT
         Update (add this amount as negative to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT)
         T and A for destination contract's credit line
       END IF;

*/

  -- get credit line ID for destination contract if any (ignore if credit line not found?)
  l_dst_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);

  -- get source contract's ID via okc_k_headers_b.ORIG_SYSTEM_ID1
  open c_src_chr(p_chr_id);
  fetch c_src_chr into l_src_chr_id;
  l_src_chr_not_found := c_src_chr%notfound;
  close c_src_chr;

  -- raise system error if data not found
  if l_src_chr_not_found then
    -- add new message
    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  end if;

  -- get credit line ID for source contract if any (ignore if credit line not found?)
  l_src_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(l_src_chr_id);

  -- IF source contract credit line exists THEN
  --   get total T for source contract via formula CONTRACT_FINANCED_AMOUNT
  --   Update (add this amount as positive to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T for source contract's credit line
  -- END IF;
  if l_src_credit_id is not null then

    update_tna_creditline(
      p_api_version    => l_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => p_chr_id,--l_src_chr_id, based on destination contract financed amount
      p_credit_line_id => l_src_credit_id,
      p_formula_name   => G_CONTRACT_FINANCED_AMOUNT,
      p_credit_flag    => false);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  end if;

  -- IF destination contract credit line exists THEN
  --   get total T for destination contract via formula CONTRACT_FINANCED_AMOUNT
  --   Update (add this amount as negative to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T for destination contract's credit line
  -- END IF;
  if l_dst_credit_id is not null then

    update_tna_creditline(
      p_api_version    => l_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => p_chr_id,
      p_credit_line_id => l_dst_credit_id,
      p_formula_name   => G_CONTRACT_FINANCED_AMOUNT,
      p_credit_flag    => true);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  end if;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_full_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_full_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_full_tna_creditline;
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

end update_full_tna_creditline;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_partial_tna_creditline
-- Description     : Calculate Transfers and Assumption amount for for the
--                   source and destination contract's asset and update correlated
--                   credit line's tna amount
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_partial_tna_creditline(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  okc_k_headers_b.id%type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_partial_tna_creditline';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_src_credit_id      NUMBER;
  l_dst_credit_id      NUMBER;
  l_src_chr_id         NUMBER;
  l_src_chr_not_found  boolean := false;
  l_src_credit_tna     NUMBER;
  l_dst_credit_tna     NUMBER;
  l_src_orig_credit_tna     NUMBER;
  l_dst_orig_credit_tna     NUMBER;

  l_chrv_rec         chrv_rec_type;
  l_khrv_rec         khrv_rec_type;
  x_chrv_rec         chrv_rec_type;
  x_khrv_rec         khrv_rec_type;


cursor c_credit_tna (p_chr_id okc_k_headers_b.id%TYPE)
  is
  select NVL(khr.TOT_CL_NET_TRANSFER_AMT,0)
from okl_k_headers khr
where khr.id = p_chr_id
;

-- source contarct and it's top line ids
cursor c_src_chr (p_chr_id okc_k_headers_b.id%TYPE)
  is
  select src_cle.dnz_chr_id,
         src_cle.id cle_id
from  okc_k_lines_b src_cle,
      okc_k_lines_b cle,
      okc_line_styles_b lse
where src_cle.id = cle.ORIG_SYSTEM_ID1
and lse.id = cle.lse_id
and lse.lty_code = 'FREE_FORM1'
and cle.dnz_chr_id = p_chr_id -- destination contract ID
;

begin
  -- Set API savepoint
  SAVEPOINT update_partial_tna_creditline;

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
/*
       -> contract T and A
       -- only one destination credit line
       5.1 get credit line ID for destination contract if any (raise error if credit line not found?)

       5.2
       <<loop of destination contract asset lines>>
        Loop

            -- Source contract T and A
            -- May refer from multiple contracts if it's partial transfer
            5.2.1 get credit line ID for source contract if any (raise error if credit line not found?)
            IF credit line found THEN
                 5.2.1.1 get source contract's asset top line via okc_k_lines_b.ORIG_SYSTEM_ID1
                 5.2.1.2 get total T and A for source contract asset via formula LINE_CAP_AMOUNT
                 5.2.1.3 Update (add this amount as positive to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T and A for source contract's credit line
            END IF;

      end loop;

      IF destination credit line found THEN
        5.3.1 get total T and A for destination contract asset via formula LINE_CAP_AMOUNT
        5.3.2 Update (add this amount as negative to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T and A for destination contract's credit line
      END IF;

*/

  -- only one destination credit line
  -- get credit line ID for destination contract if any (ignore error if credit line not found?)
  l_dst_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(p_chr_id);

  -- <<loop of destination contract asset lines>>
  -- Loop
  For r_src_chr in c_src_chr(p_chr_id) loop
    -- Source contract T and A
    -- May refer from multiple contracts if it's partial transfer
    -- get credit line ID for source contract if any (ignore if credit line not found?)
    l_src_credit_id := OKL_CREDIT_PUB.get_creditline_by_chrid(r_src_chr.dnz_chr_id);

    -- IF credit line found THEN
    --  get source contract's asset top line via okc_k_lines_b.ORIG_SYSTEM_ID1
    --  get total T and A for source contract asset via formula LINE_CAP_AMOUNT
    --  Update (add this amount as positive to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T and A for source contract's credit line
    -- END IF;
    if l_src_credit_id is not null then

      update_tna_creditline(
        p_api_version    => l_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_chr_id         => r_src_chr.dnz_chr_id,
        p_credit_line_id => l_src_credit_id,
        p_formula_name   => G_LINE_FINANCED_AMOUNT,
        p_credit_flag    => false);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    end if;

  end loop;
  -- end loop;

  -- IF destination credit line found THEN
  --   get total T and A for destination contract asset via formula CONTRACT_CAP_AMOUNT
  --   Update (add this amount as negative to OKL_K_HEADERS.TOT_CL_NET_TRANSFER_AMT) T and A for destination contract's credit line
  -- END IF;
  if l_dst_credit_id is not null then

    update_tna_creditline(
      p_api_version    => l_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => p_chr_id,
      p_credit_line_id => l_dst_credit_id,
      p_formula_name   => G_CONTRACT_FINANCED_AMOUNT,
      p_credit_flag    => true);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  end if;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_partial_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_partial_tna_creditline;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_partial_tna_creditline;
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

end update_partial_tna_creditline;


END OKL_TRANSFER_ASSUMPTION_PVT;

/
