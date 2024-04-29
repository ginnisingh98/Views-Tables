--------------------------------------------------------
--  DDL for Package Body OKL_SYSTEM_ACCT_OPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYSTEM_ACCT_OPT_PVT" AS
/* $Header: OKLRSYOB.pls 120.4 2006/12/11 15:25:36 rgooty noship $ */

  -- R12 SLA Uptake : Begin
  G_INVALID_ADO_MSG CONSTANT VARCHAR2(200)    := 'OKL_INVALID_ACC_DERIVATION_OPT';
  G_FROM_ADO        CONSTANT VARCHAR2(30)     := 'FROM_ADO';
  G_TO_ADO          CONSTANT VARCHAR2(30)     := 'TO_ADO';
  G_ADO_LOOKUP_TYPE CONSTANT VARCHAR2(30)     := 'OKL_ACCOUNT_DERIVATION_OPTION';
  G_ADO_ATS         CONSTANT VARCHAR2(30)     := 'ATS';
  G_ADO_AMB         CONSTANT VARCHAR2(30)     := 'AMB';

  FUNCTION GET_LOOKUP_MEANING( p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                              ,p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
    RETURN VARCHAR
    IS
    CURSOR fnd_lookup_csr(  p_lookup_type fnd_lookups.lookup_type%type
                           ,p_lookup_code fnd_lookups.lookup_code%type)
    IS
      SELECT MEANING
       FROM  FND_LOOKUPS FND
       WHERE FND.LOOKUP_TYPE = p_lookup_type
         AND FND.LOOKUP_CODE = p_lookup_code;

    l_return_value VARCHAR2(200) := OKL_API.G_MISS_CHAR;
  BEGIN
    IF (  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL )
    THEN
        OPEN fnd_lookup_csr( p_lookup_type, p_lookup_code );
        FETCH fnd_lookup_csr INTO l_return_value;
        CLOSE fnd_lookup_csr;
    END IF;
    return l_return_value;
  END;
  -- R12 SLA Uptake : End

PROCEDURE GET_SYSTEM_ACCT_OPT(p_api_version      IN    NUMBER,
                              p_init_msg_list    IN    VARCHAR2,
                              x_return_status    OUT   NOCOPY VARCHAR2,
                              x_msg_count        OUT   NOCOPY NUMBER,
                              x_msg_data         OUT   NOCOPY VARCHAR2,
			      p_set_of_books_id  IN    NUMBER,
                              x_saov_rec         OUT   NOCOPY saov_rec_type)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'GET_SYSTEM_ACCT_OPT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_saov_rec          saov_rec_type;
  l_stmt              VARCHAR2(3500);
  l_org_id            NUMBER;
  TYPE ref_cursor     IS REF CURSOR;
  sys_acct_csr        ref_cursor;


BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_stmt := '  SELECT ID
          ,CC_REP_CURRENCY_CODE
          ,CODE_COMBINATION_ID
          ,AEL_REP_CURRENCY_CODE
          ,SET_OF_BOOKS_ID
          ,OBJECT_VERSION_NUMBER
          ,REC_CCID
          ,REALIZED_GAIN_CCID
          ,REALIZED_LOSS_CCID
          ,TAX_CCID
          ,CROSS_CURRENCY_CCID
          ,ROUNDING_CCID
          ,AR_CLEARING_CCID
          ,PAYABLES_CCID
          ,LIABLITY_CCID
          ,PRE_PAYMENT_CCID
          ,FUT_DATE_PAY_CCID
          ,CC_ROUNDING_RULE
          ,CC_PRECISION
          ,CC_MIN_ACCT_UNIT
          ,DIS_TAKEN_CCID
          ,AP_CLEARING_CCID
          ,AEL_ROUNDING_RULE
          ,AEL_PRECISION
          ,AEL_MIN_ACCT_UNIT
          ,ORG_ID
          ,ATTRIBUTE_CATEGORY
          ,ATTRIBUTE1
          ,ATTRIBUTE2
          ,ATTRIBUTE3
          ,ATTRIBUTE4
          ,ATTRIBUTE5
          ,ATTRIBUTE6
          ,ATTRIBUTE7
          ,ATTRIBUTE8
          ,ATTRIBUTE9
          ,ATTRIBUTE10
          ,ATTRIBUTE11
          ,ATTRIBUTE12
          ,ATTRIBUTE13
          ,ATTRIBUTE14
          ,ATTRIBUTE15
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,CC_APPLY_ROUNDING_DIFFERENCE
          ,AEL_APPLY_ROUNDING_DIFFERENCE
          ,LKE_HOLD_DAYS
          --Added by Keerthi 12-Sep-2003
          ,STM_APPLY_ROUNDING_DIFFERENCE
          ,STM_ROUNDING_RULE
          --Added new field for bug 4884618(H)
          ,VALIDATE_KHR_START_DATE
          ,ACCOUNT_DERIVATION -- R12 SLA Uptake
    FROM OKL_SYS_ACCT_OPTS ';

    OPEN sys_acct_csr FOR l_stmt;

    FETCH sys_acct_csr INTO
               l_saov_rec.ID
              ,l_saov_rec.CC_REP_CURRENCY_CODE
              ,l_saov_rec.CODE_COMBINATION_ID
              ,l_saov_rec.AEL_REP_CURRENCY_CODE
              ,l_saov_rec.SET_OF_BOOKS_ID
              ,l_saov_rec.OBJECT_VERSION_NUMBER
              ,l_saov_rec.REC_CCID
              ,l_saov_rec.REALIZED_GAIN_CCID
              ,l_saov_rec.REALIZED_LOSS_CCID
              ,l_saov_rec.TAX_CCID
              ,l_saov_rec.CROSS_CURRENCY_CCID
              ,l_saov_rec.ROUNDING_CCID
              ,l_saov_rec.AR_CLEARING_CCID
              ,l_saov_rec.PAYABLES_CCID
              ,l_saov_rec.LIABLITY_CCID
              ,l_saov_rec.PRE_PAYMENT_CCID
              ,l_saov_rec.FUT_DATE_PAY_CCID
              ,l_saov_rec.CC_ROUNDING_RULE
              ,l_saov_rec.CC_PRECISION
              ,l_saov_rec.CC_MIN_ACCT_UNIT
              ,l_saov_rec.DIS_TAKEN_CCID
              ,l_saov_rec.AP_CLEARING_CCID
              ,l_saov_rec.AEL_ROUNDING_RULE
              ,l_saov_rec.AEL_PRECISION
              ,l_saov_rec.AEL_MIN_ACCT_UNIT
              ,l_saov_rec.ORG_ID
              ,l_saov_rec.ATTRIBUTE_CATEGORY
              ,l_saov_rec.ATTRIBUTE1
              ,l_saov_rec.ATTRIBUTE2
              ,l_saov_rec.ATTRIBUTE3
              ,l_saov_rec.ATTRIBUTE4
              ,l_saov_rec.ATTRIBUTE5
              ,l_saov_rec.ATTRIBUTE6
              ,l_saov_rec.ATTRIBUTE7
              ,l_saov_rec.ATTRIBUTE8
              ,l_saov_rec.ATTRIBUTE9
              ,l_saov_rec.ATTRIBUTE10
              ,l_saov_rec.ATTRIBUTE11
              ,l_saov_rec.ATTRIBUTE12
              ,l_saov_rec.ATTRIBUTE13
              ,l_saov_rec.ATTRIBUTE14
              ,l_saov_rec.ATTRIBUTE15
              ,l_saov_rec.CREATED_BY
              ,l_saov_rec.CREATION_DATE
              ,l_saov_rec.LAST_UPDATED_BY
              ,l_saov_rec.LAST_UPDATE_DATE
              ,l_saov_rec.LAST_UPDATE_LOGIN
              ,l_saov_rec.CC_APPLY_ROUNDING_DIFFERENCE
              ,l_saov_rec.AEL_APPLY_ROUNDING_DIFFERENCE
              ,l_saov_rec.LKE_HOLD_DAYS
              -- Added by Keerthi 10-Sep-2003 for Rounding of Amounts in Streams
              ,l_saov_rec.STM_APPLY_ROUNDING_DIFFERENCE
              ,l_saov_rec.STM_ROUNDING_RULE
              --Added new field for bug 4746246
              ,l_saov_rec.VALIDATE_KHR_START_DATE
              ,l_saov_rec.ACCOUNT_DERIVATION; -- R12 SLA Uptake

    CLOSE sys_acct_csr;

    x_saov_rec := l_saov_rec;

EXCEPTION

   WHEN OTHERS THEN
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END GET_SYSTEM_ACCT_OPT;




PROCEDURE UPDT_SYSTEM_ACCT_OPT(p_api_version    IN          NUMBER,
                               p_init_msg_list  IN          VARCHAR2,
                               x_return_status  OUT         NOCOPY VARCHAR2,
                               x_msg_count      OUT         NOCOPY NUMBER,
                               x_msg_data       OUT         NOCOPY VARCHAR2,
                               p_saov_rec       IN          saov_rec_type,
                               x_saov_rec       OUT         NOCOPY saov_rec_type)
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'UPDT_SYSTEM_ACCT_OPT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_init_msg_list     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_saov_rec_in       saov_rec_type;
  l_saov_rec_out      saov_rec_type;

 BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_SYSTEM_ACCT_OPT_PVT.GET_SYSTEM_ACCT_OPT(p_api_version        => 1.0,
                                               p_init_msg_list      => l_init_msg_list,
                                               x_return_status      => l_return_status,
                                               x_msg_count          => l_msg_count,
                                               x_msg_data           => l_msg_data,
                                               p_set_of_books_id    => p_saov_rec.set_of_books_id,
                                               x_saov_rec           => l_saov_rec_out);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (l_saov_rec_out.ID = OKL_API.G_MISS_NUM) OR
      (l_saov_rec_out.ID IS NULL) THEN

        OKL_SYS_ACCT_OPTS_PUB.INSERT_SYS_ACCT_OPTS(p_api_version   => 1.0,
                                                   p_init_msg_list => l_init_msg_list,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data,
                                                   p_saov_rec      => p_saov_rec,
                                                   x_saov_rec      => l_saov_rec_out);

    ELSE

        l_saov_rec_in  := p_saov_rec;
        -- R12 SLA Uptake : Begin
        -- Restrict the updation of the Account Derivation from AMB to ATS
        --  as only one time upgradation is possible from ATS to AMB.
        IF l_saov_rec_out.account_derivation = G_ADO_AMB AND
           l_saov_rec_in.account_derivation = G_ADO_ATS
        THEN
          -- Set the Error message
          OKL_API.SET_MESSAGE(
             p_app_name       => G_APP_NAME
            ,p_msg_name       => G_INVALID_ADO_MSG
            ,p_token1         => G_FROM_ADO
            ,p_token1_value   => GET_LOOKUP_MEANING(
                                   G_ADO_LOOKUP_TYPE,
                                   l_saov_rec_out.account_derivation)
            ,p_token2         => G_TO_ADO
            ,p_token2_value   => GET_LOOKUP_MEANING(
                                   G_ADO_LOOKUP_TYPE,
                                   l_saov_rec_in.account_derivation));
          -- Set the return status with Error
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          -- Raise the Exception
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        -- R12 SLA Uptake : End
        IF (p_saov_rec.id = OKL_API.G_MISS_NUM) THEN
            l_saov_rec_in.id := l_saov_rec_out.id;
        END IF;

        OKL_SYS_ACCT_OPTS_PUB.UPDATE_SYS_ACCT_OPTS(p_api_version       => 1.0,
                                                   p_init_msg_list     => l_init_msg_list,
                                                   x_return_status     => l_return_status,
                                                   x_msg_count         => l_msg_count,
                                                   x_msg_data          => l_msg_data,
                                                   p_saov_rec          => l_saov_rec_in,
                                                   x_saov_rec          => l_saov_rec_out);


    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_saov_rec       := l_saov_rec_out;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END UPDT_SYSTEM_ACCT_OPT;

END OKL_SYSTEM_ACCT_OPT_PVT;

/
