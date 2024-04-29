--------------------------------------------------------
--  DDL for Package Body OKL_AM_SHIPPING_INSTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SHIPPING_INSTR_PVT" AS
/* $Header: OKLRSHIB.pls 120.4 2006/09/26 09:58:21 zrehman noship $ */


  -- Start of comments
  --
  -- Procedure Name	  : create_shipping_instr
  -- Description	  : Creates the shipping instruction rec
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA - 19-DEC-2002 :  Bug # 2667636
  --                      Added logic to convert Insurance amt from contract currency to functional currency
  --                    SECHAWLA 07-FEB-03 Bug # 2789656
  --                      Added x_return_status parameter to okl_accounting_util call. Removed DEFAULT hint from
  --                      procedure parameters
  -- End of comments
  PROCEDURE create_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type) AS

    -- Cursor to get the khr_id and kle_id for the asset being shipped
    CURSOR okl_get_khr_kle_csr ( p_art_id IN NUMBER) IS
      SELECT  KLE.chr_id      khr_id,
              KLE.id          kle_id,
              ART.floor_price floor_price
      FROM    OKL_K_LINES_FULL_V    KLE,
              OKL_ASSET_RETURNS_V   ART
      WHERE   ART.id = p_art_id
      AND     ART.kle_id = KLE.id;

    -- Cursor to get the lessee info
    -- Fix for bug 3562321 - Added dnz_chr_id in the where clause to avoid fts.
    CURSOR okl_get_lessee_csr (p_khr_id IN NUMBER) IS
     select   CPLB.OBJECT1_ID1,
              CPLB.JTOT_OBJECT1_CODE
     from     OKC_K_PARTY_ROLES_B CPLB
     where    CPLB.RLE_CODE = 'LESSEE'
     and      CPLB.DNZ_CHR_ID = CPLB.CHR_ID
     and      CPLB.DNZ_CHR_ID = p_khr_id;

    lp_rasv_rec            rasv_rec_type := p_rasv_rec;
    lx_rasv_rec            rasv_rec_type;
    l_return_status        VARCHAR2(200);
    l_api_name             CONSTANT VARCHAR2(30) := 'create_shipping_instr';
    l_api_version          CONSTANT NUMBER      := 1;
    l_formula_name         CONSTANT VARCHAR2(30) := 'ASSET VALUE FOR INSURANCE';
    l_khr_id               NUMBER;
    l_kle_id               NUMBER;
    l_insurance_amt        NUMBER := 0;
    l_floor_price          NUMBER := 0;
    l_contact_method_id    NUMBER;
    l_id_value             VARCHAR2(200);
    l_id_type              VARCHAR2(200);
    l_id_code              VARCHAR2(3);
    l_party_object_tbl     OKL_AM_PARTIES_PVT.party_object_tbl_type;
    i                      NUMBER;

    --SECHAWLA  Bug # 2667636 : new declarations
    l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;
    l_contract_curr_code         okc_k_headers_b.currency_code%TYPE;
    lx_contract_currency         okl_k_headers_full_v.currency_code%TYPE;
    lx_currency_conversion_type  okl_k_headers_full_v.currency_conversion_type%TYPE;
    lx_currency_conversion_rate  okl_k_headers_full_v.currency_conversion_rate%TYPE;
    lx_currency_conversion_date  okl_k_headers_full_v.currency_conversion_date%TYPE;
    lx_converted_amount          NUMBER;
    l_sysdate                    DATE;

  BEGIN

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- SECHAWLA  Bug # 2667636 : using sysdate as transaction date for currency conversion routines
    SELECT SYSDATE INTO l_sysdate FROM DUAL;


    -- Get the khr_id and kle_id and floor price for the asset being shipped
    OPEN  okl_get_khr_kle_csr(lp_rasv_rec.art_id);
    FETCH okl_get_khr_kle_csr INTO l_khr_id, l_kle_id, l_floor_price;
    CLOSE okl_get_khr_kle_csr;


    -- SECHAWLA  Bug # 2667636 : get the functional and contract currency

    -- get the functional currency
    l_func_curr_code := okl_am_util_pvt.get_functional_currency;
    -- get the contract currency
    l_contract_curr_code := okl_am_util_pvt.get_chr_currency( p_chr_id => l_khr_id);

    -- Populate Asset Value For Insurance from formula, if the formula
    -- is not available then set the value to floor price of asset return
    OKL_AM_UTIL_PVT.get_formula_value(
             p_formula_name	                 => l_formula_name,
             p_chr_id	                     => l_khr_id,
             p_cle_id	                     => l_kle_id,
		     x_formula_value	             => l_insurance_amt,
		     x_return_status                 => l_return_status);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR l_insurance_amt <= 0 OR l_insurance_amt IS NULL THEN
      l_insurance_amt := l_floor_price;
    ELSE



      -- SECHAWLA  Bug # 2667636 : added the following logic to convert i9nsurance amt to functional currency
       IF l_contract_curr_code <> l_func_curr_code  THEN
           -- convert amount to functional currency
           --SECHAWLA 07-FEB-03 Bug # 2789656 : Added x_return_status parameter to the following procedure call
           okl_accounting_util.convert_to_functional_currency(
   	            p_khr_id  		  	       => l_khr_id,
   	            p_to_currency   		   => l_func_curr_code,
   	            p_transaction_date 	       => l_sysdate ,
   	            p_amount 			       => l_insurance_amt,
                x_return_status		       => x_return_status,
   	            x_contract_currency	       => lx_contract_currency,
   		        x_currency_conversion_type => lx_currency_conversion_type,
   		        x_currency_conversion_rate => lx_currency_conversion_rate,
   		        x_currency_conversion_date => lx_currency_conversion_date,
   		        x_converted_amount 	       => lx_converted_amount );

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

          l_insurance_amt := lx_converted_amount ;


      END IF;

    END IF;

    -- Get Lessee for contract, get the contact method id for lessee and default
    OPEN  okl_get_lessee_csr(l_khr_id);
    FETCH okl_get_lessee_csr INTO l_id_value, l_id_type;
    CLOSE okl_get_lessee_csr;

    -- Set the id_code
    IF    UPPER(l_id_type) = 'OKX_PARTY'      THEN
       l_id_code := 'P';
    ELSIF UPPER(l_id_type) = 'OKX_PARTYSITE'  THEN
       l_id_code := 'PS';
    ELSIF UPPER(l_id_type) = 'OKX_PCONTACT'   THEN
       l_id_code := 'PC';
    ELSIF UPPER(l_id_type) = 'OKX_VENDOR'     THEN
       l_id_code := 'V';
    ELSIF UPPER(l_id_type) = 'OKX_VENDORSITE' THEN
       l_id_code := 'VS';
    ELSIF UPPER(l_id_type) = 'OKX_VCONTACT'   THEN
       l_id_code := 'VC';
    ELSE -- default is PARTY
       l_id_code := 'P';
    END IF;

    -- Get the contact method id (refered to as Contact point id in parties api)
    OKL_AM_PARTIES_PVT.get_party_details(
             p_id_code                      => l_id_code,
             p_id_value                     => l_id_value,
             x_party_object_tbl             => l_party_object_tbl,
             x_return_status                => l_return_status);

    IF l_party_object_tbl.COUNT > 0 THEN
      i := l_party_object_tbl.FIRST;
      LOOP
        IF  l_party_object_tbl(i).pcp_id IS NOT NULL
        AND l_party_object_tbl(i).pcp_id <> OKL_API.G_MISS_NUM THEN
          l_contact_method_id := l_party_object_tbl(i).pcp_id;
          EXIT;
        END IF;
        EXIT WHEN (i = l_party_object_tbl.LAST);
        i := l_party_object_tbl.NEXT(i);
      END LOOP;
    END IF;

    -- Check if NULL
    IF l_insurance_amt IS NULL THEN
      l_insurance_amt := 0;
    END IF;

    -- Set the rasv rec
    lp_rasv_rec.insurance_amount := l_insurance_amt;
    lp_rasv_rec.pac_id := l_contact_method_id;

    -- Call TAPI to insert the row
    OKL_RELOCATE_ASSETS_PUB.insert_relocate_assets(
             p_api_version                  => p_api_version,
             p_init_msg_list                => OKL_API.G_FALSE,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_rasv_rec                     => lp_rasv_rec,
             x_rasv_rec                     => lx_rasv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set return variables
    x_return_status := l_return_status;
    x_rasv_rec := lx_rasv_rec;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF okl_get_khr_kle_csr%ISOPEN THEN
        CLOSE okl_get_khr_kle_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF okl_get_khr_kle_csr%ISOPEN THEN
        CLOSE okl_get_khr_kle_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      IF okl_get_khr_kle_csr%ISOPEN THEN
        CLOSE okl_get_khr_kle_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_shipping_instr;


  -- Start of comments
  --
  -- Procedure Name   : create_shipping_instr
  -- Description	  : Creates the shipping instructions records
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 07-FEB-03 Bug # 2789656
  --                       Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE create_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_shipping_instr';
    i                              NUMBER := 0;

  BEGIN

   OKL_API.init_msg_list(p_init_msg_list);
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP

       create_shipping_instr(
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i),
          x_rasv_rec                     => x_rasv_tbl(i));

         IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_return_status := x_return_status;
           END IF;
        END IF;
         EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_return_status;
    END IF;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_shipping_instr;


  -- Start of comments
  --
  -- Procedure Name	  : update_shipping_instr
  -- Description	  : Updates the shipping instructions rec
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 07-FEB-03 Bug # 2789656
  --                       Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE update_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type) AS

    lp_rasv_rec                      rasv_rec_type := p_rasv_rec;
    lx_rasv_rec                      rasv_rec_type;
    l_return_status                  VARCHAR2(200);
    l_api_name                       CONSTANT VARCHAR2(30) := 'create_shipping_instr';
    l_api_version                    CONSTANT NUMBER      := 1;

  BEGIN

      --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- If insurance amount is <=0 then error
    IF lp_rasv_rec.insurance_amount <= 0
    OR lp_rasv_rec.insurance_amount IS NULL
    OR lp_rasv_rec.insurance_amount = OKL_API.G_MISS_NUM THEN
      -- Message: You must enter a positive value for PROMPT.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_REQ_FIELD_POS_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_ASSET_VALUE_FOR_INSURANCE'));
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- PAC_ID mandatory
    IF lp_rasv_rec.pac_id IS NULL
    OR lp_rasv_rec.pac_id = OKL_API.G_MISS_NUM THEN
      -- Message: You must enter a value for PROMPT.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_CONTACT_METHOD'));
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- IST_ID mandatory
    IF lp_rasv_rec.ist_id IS NULL
    OR lp_rasv_rec.ist_id = OKL_API.G_MISS_NUM THEN
      -- Message: You must enter a value for PROMPT.
      OKL_API.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_SHIP_TO_PARTY'));
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Call TAPI to update the rec
    OKL_RELOCATE_ASSETS_PUB.update_relocate_assets(
             p_api_version                  => p_api_version,
             p_init_msg_list                => OKL_API.G_FALSE,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_rasv_rec                     => lp_rasv_rec,
             x_rasv_rec                     => lx_rasv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- set return variables
    x_return_status := l_return_status;
    x_rasv_rec := lx_rasv_rec;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_shipping_instr;

  -- Start of comments
  --
  -- Procedure Name	  : update_shipping_instr
  -- Description	  : Updates the shipping instructions records
  -- Business Rules   :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 07-FEB-03 Bug # 2789656
  --                       Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE update_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_shipping_instr';
    i                              NUMBER := 0;

  BEGIN

   OKL_API.init_msg_list(p_init_msg_list);
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP

        update_shipping_instr(
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i),
          x_rasv_rec                     => x_rasv_tbl(i));

         IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_return_status := x_return_status;
           END IF;
        END IF;
         EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_return_status;
    END IF;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_shipping_instr;

  -- Start of comments
  --
  -- Procedure Name	: send_shipping_instr
  -- Description	: Launches the shipping instructions WF
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- History        : SECHAWLA 07-FEB-03 Bug # 2789656
  --                       Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE send_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_rec                      IN rasv_rec_type,
    x_rasv_rec                      OUT NOCOPY rasv_rec_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'send_shipping_instr';
    lp_rasv_rec                    rasv_rec_type := p_rasv_rec;
    lx_rasv_rec                    rasv_rec_type;
    l_api_version                  CONSTANT NUMBER      := 1;
    l_event_name                   VARCHAR2(200);
  BEGIN

      --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the date_sent if not set
    IF lp_rasv_rec.date_shipping_instructions_sen IS NULL
    OR lp_rasv_rec.date_shipping_instructions_sen = OKL_API.G_MISS_DATE THEN

      SELECT SYSDATE INTO lp_rasv_rec.date_shipping_instructions_sen FROM DUAL;

    END IF;

    -- Call the update
    update_shipping_instr(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => l_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => lp_rasv_rec,
          x_rasv_rec                     => lx_rasv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Based on trans option launch the WF
    IF lx_rasv_rec.trans_option_accepted_yn = 'Y' THEN

       -- Get the WF event name
       l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                     p_wf_process_type   => 'OKLAMNTD',
                     p_wf_process_name   => 'NOTIFY_ITD_PROC',
                     x_return_status     => l_return_status);

       -- Raise exception when error
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Launch the Notify Internal Transport Department WF
       OKL_AM_WF.raise_business_event (
                          	p_transaction_id => lx_rasv_rec.art_id,
		                        p_event_name	   => 'oracle.apps.okl.am.notifytransdept');
    ELSE

       -- Get the WF event name
       l_event_name := OKL_AM_UTIL_PVT.get_wf_event_name(
                     p_wf_process_type   => 'OKLAMNSI',
                     p_wf_process_name   => 'SHIPPING_INSTRUCTION_PROC',
                     x_return_status     => l_return_status);

       -- Raise exception when error
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Launch the Shipping Instruction WF
       OKL_AM_WF.raise_business_event (
                          	p_transaction_id => lx_rasv_rec.art_id,
		                        p_event_name	   => 'oracle.apps.okl.am.notifyshipinstr');
    END IF;

    -- Set message on stack
    -- Workflow event EVENT_NAME has been requested.
    OKL_API.set_message(p_app_name     => 'OKL',
                        p_msg_name     => 'OKL_AM_WF_EVENT_MSG',
                        p_token1       => 'EVENT_NAME',
                        p_token1_value => l_event_name);

    x_return_status := l_return_status;
    x_rasv_rec := lx_rasv_rec;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_shipping_instr;

  -- Start of comments
  --
  -- Procedure Name	  : send_shipping_instr
  -- Description	  : Launches the shipping instructions WF
  -- Business Rules	  :
  -- Parameters		  :
  -- Version		  : 1.0
  -- History          : SECHAWLA 07-FEB-03 Bug # 2789656
  --                       Removed DEFAULT hint from procedure parameters
  -- End of comments
  PROCEDURE send_shipping_instr(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_rasv_tbl                      IN rasv_tbl_type,
    x_rasv_tbl                      OUT NOCOPY rasv_tbl_type) AS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'send_shipping_instr';
    i                              NUMBER := 0;

  BEGIN

   OKL_API.init_msg_list(p_init_msg_list);
    IF (p_rasv_tbl.COUNT > 0) THEN
      i := p_rasv_tbl.FIRST;
      LOOP

        send_shipping_instr(
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rasv_rec                     => p_rasv_tbl(i),
          x_rasv_rec                     => x_rasv_tbl(i));

         IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_return_status := x_return_status;
           END IF;
        END IF;
         EXIT WHEN (i = p_rasv_tbl.LAST);
        i := p_rasv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_return_status;
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END send_shipping_instr;


END OKL_AM_SHIPPING_INSTR_PVT;

/
