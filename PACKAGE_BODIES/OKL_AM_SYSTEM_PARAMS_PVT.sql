--------------------------------------------------------
--  DDL for Package Body OKL_AM_SYSTEM_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SYSTEM_PARAMS_PVT" AS
/* $Header: OKLRASAB.pls 120.9.12010000.2 2009/08/18 08:11:03 nikshah ship $ */

  -- Start of comments
  --
  -- Procedure Name  : process_system_params
  -- Description     : procedure to create or update rec in OKL_SYSTEM_PARAMS_ALL_V
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE process_system_params(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type) IS

        l_api_name VARCHAR2(30) := 'process_system_params';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;


       -- DJANASWA Bug 6653304 start  Proj: Asset Repo for a Loan

        l_tax_book_1               OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%type;
        l_tax_book_2               OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%type;
        l_fa_location_id           OKL_SYSTEM_PARAMS_ALL.FA_LOCATION_ID%type;
        l_formula_id               OKL_SYSTEM_PARAMS_ALL.FORMULA_ID%type;
        l_asset_key_id             OKL_SYSTEM_PARAMS_ALL.ASSET_KEY_ID%type;
        l_asst_add_book_type_code  OKL_SYSTEM_PARAMS_ALL.ASST_ADD_BOOK_TYPE_CODE%TYPE;
        l_rpt_prod_book_type_code  OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE;
        l_tax_book_name_1          FA_BOOK_CONTROLS.BOOK_TYPE_NAME%TYPE;
        l_tax_book_name_2          FA_BOOK_CONTROLS.BOOK_TYPE_NAME%TYPE;

        l_tax_1                    OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%type;
        l_tax_2                    OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%type;
        l_asst_book_type_name      FA_BOOK_CONTROLS.BOOK_TYPE_NAME%TYPE;

        --NIKSHAH added below variables, bug # 8570053
        l_sec_rep_method           okl_sys_acct_opts.SECONDARY_REP_METHOD%TYPE;
        l_rpt_book_type            OKL_SYSTEM_PARAMS.rpt_prod_book_type_code%TYPE;
        --NIKSHAH added above variables, bug # 8570053
        G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

   CURSOR c_tax_book_csr (cp_asst_add_book_type_code VARCHAR2, cp_tax_book VARCHAR2) IS
     SELECT 'x'
     FROM fa_book_controls
     where book_class =  'TAX'
     AND   distribution_source_book = cp_asst_add_book_type_code
     AND   book_type_code = cp_tax_book;

   CURSOR c_asst_book_type_name_csr (cp_asst_add_book_type_code VARCHAR2) IS
     SELECT BOOK_TYPE_NAME
     FROM fa_book_controls
     where book_class =  'CORPORATE'
     AND   book_type_code = cp_asst_add_book_type_code;

   CURSOR c_tax_book_name_csr (cp_tax_book_code VARCHAR2) IS
     SELECT BOOK_TYPE_NAME
     FROM fa_book_controls
     where book_type_code = cp_tax_book_code;


      -- DJANASWA Bug 6653304 end  Proj: Asset Repo for a Loan

   --NIKSHAH added below cursor, bug # 8570053
   CURSOR c_get_sec_repr_method IS
   select secondary_rep_method, rpt_prod_book_type_code
   from   okl_system_params p, okl_sys_acct_opts a
   where  p.org_id = a.org_id;


  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                         'Begin(+)');
       END IF;

       -- Check API version, initialize message list and create savepoint
       l_return_status := OKL_API.start_activity(
                                       p_api_name      => l_api_name,
                                       p_pkg_name      => G_PKG_NAME,
                                       p_init_msg_list => p_init_msg_list,
                                       l_api_version   => l_api_version,
                                       p_api_version   => p_api_version,
                                       p_api_type      => '_PVT',
                                       x_return_status => x_return_status);

       -- Rollback if error setting activity for api
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;



       -- DJANASWA Bug 6653304 start  Proj: Asset Repo for a Loan
-- Added validations for the new columns added to the table okl_system_params_all.
-- 1. If any one or more of the following fields has values: Tax Asset Book 1, Tax Asset Book 2,
--    Asset Key, Fixed Asset Location, Asset Cost Formula
--    then ensure that all of the following fields have values:
--    Asset Addition Corporate Book, Tax Asset Book 1, Fixed Asset Location
-- 2. If Tax Asset Book 1 and/or  Tax Asset Book 2 have values then ensure that they are tax books related to
--    the 'Asset Addition Corporate Book'.
-- 3. There are no duplicate values among the following 3 fields: Reporting Product Asset Book,
--    Tax Asset Book 1, Tax Asset Book 2

        l_tax_book_1              := null;
        l_tax_book_2              := null;
        l_fa_location_id          := null;
        l_formula_id              := null;
        l_asset_key_id            := null;
        l_asst_add_book_type_code := NULL;
        l_rpt_prod_book_type_code := NULL;
        l_tax_book_name_1         := NULL;
        l_tax_book_name_2         := NULL;
        l_asst_book_type_name     := NULL;

        l_tax_book_1              := p_sypv_rec.TAX_BOOK_1;
        l_tax_book_2              := p_sypv_rec.TAX_BOOK_2;
        l_fa_location_id          := p_sypv_rec.FA_LOCATION_ID;
        l_formula_id              := p_sypv_rec.FORMULA_ID;
        l_asset_key_id            := p_sypv_rec.ASSET_KEY_ID;
        l_asst_add_book_type_code := p_sypv_rec.ASST_ADD_BOOK_TYPE_CODE;
        l_rpt_prod_book_type_code := p_sypv_rec.RPT_PROD_BOOK_TYPE_CODE;


--  Tax Book 1 is NOT NULL, others are NULL
       IF  (l_tax_book_1 IS NOT NULL AND l_tax_book_1 <> OKL_API.G_MISS_CHAR)  THEN

           IF  ( l_asst_add_book_type_code IS NULL OR  l_asst_add_book_type_code =  OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset Addition Corporate Book cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_CORPORATE_BOOK_MISSING');
           END IF;


           IF  (l_fa_location_id IS NULL OR l_fa_location_id = OKL_API.G_MISS_NUM)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_fa_location_id cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_FA_LOCATION_ID_MISSING');
           END IF;

       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;

--  LOCATION_ID is NOT NULL, others are NULL
       IF  (l_fa_location_id IS NOT NULL AND l_fa_location_id <> OKL_API.G_MISS_NUM)  THEN

           IF  ( l_asst_add_book_type_code IS NULL OR  l_asst_add_book_type_code =  OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset Addition Corporate Book cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_CORPORATE_BOOK_MISSING');
           END IF;

           IF  (l_tax_book_1 IS  NULL OR l_tax_book_1 = OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_tax_book_1 cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_TAX_BOOK_1_MISSING');
           END IF;


       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;

--  ASSET KEY is NOT NULL, others are NULL
       IF  (l_asset_key_id IS NOT NULL AND l_asset_key_id <> OKL_API.G_MISS_NUM) THEN

           IF  ( l_asst_add_book_type_code IS NULL OR  l_asst_add_book_type_code =  OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset Addition Corporate Book cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_CORPORATE_BOOK_MISSING');
           END IF;

           IF  (l_tax_book_1 IS  NULL OR l_tax_book_1 = OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_tax_book_1 cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_TAX_BOOK_1_MISSING');
           END IF;

           IF  (l_fa_location_id IS NULL OR l_fa_location_id = OKL_API.G_MISS_NUM)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_fa_location_id cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_FA_LOCATION_ID_MISSING');

          END IF;

       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;

--  FORMULA_ID is NOT NULL, others are NULL

       IF  (l_formula_id IS NOT NULL AND l_formula_id <> OKL_API.G_MISS_NUM) THEN

           IF  ( l_asst_add_book_type_code IS NULL OR  l_asst_add_book_type_code =  OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset Addition Corporate Book cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_CORPORATE_BOOK_MISSING');
           END IF;

           IF  (l_tax_book_1 IS  NULL OR l_tax_book_1 = OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_tax_book_1 cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_TAX_BOOK_1_MISSING');
           END IF;


           IF  (l_fa_location_id IS NULL OR l_fa_location_id = OKL_API.G_MISS_NUM)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_fa_location_id cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_FA_LOCATION_ID_MISSING');

          END IF;


       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;

--  TAX BOOK 2 is NOT NULL, others are NULL

       IF  (l_tax_book_2 IS  NOT NULL AND  l_tax_book_2 <> OKL_API.G_MISS_CHAR) THEN

           IF  ( l_asst_add_book_type_code IS NULL OR  l_asst_add_book_type_code =  OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   -- Asset Addition Corporate Book cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_CORPORATE_BOOK_MISSING');
           END IF;

           IF  (l_tax_book_1 IS  NULL OR l_tax_book_1 = OKL_API.G_MISS_CHAR)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_tax_book_1 cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_TAX_BOOK_1_MISSING');
           END IF;

           IF  (l_fa_location_id IS NULL OR l_fa_location_id = OKL_API.G_MISS_NUM)
                THEN
                   l_return_status := OKL_API.G_RET_STS_ERROR;
                   --  l_fa_location_id cannot be NULL.
                   OKL_API.set_message(      p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_FA_LOCATION_ID_MISSING');

          END IF;


       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;


-- corporate book and tax books are valid combinations
                      OPEN c_asst_book_type_name_csr (l_asst_add_book_type_code);
                      FETCH c_asst_book_type_name_csr INTO l_asst_book_type_name;
                      CLOSE c_asst_book_type_name_csr;

                       OPEN c_tax_book_name_csr (l_tax_book_1);
                       FETCH c_tax_book_name_csr INTO l_tax_book_name_1;
                       CLOSE c_tax_book_name_csr;

                       OPEN c_tax_book_name_csr (l_tax_book_2);
                       FETCH c_tax_book_name_csr INTO l_tax_book_name_2;
                       CLOSE c_tax_book_name_csr;

       IF  ( l_asst_add_book_type_code IS NOT NULL AND  l_asst_add_book_type_code <>  OKL_API.G_MISS_CHAR)  THEN
           IF (l_tax_book_1 IS NOT NULL AND  l_tax_book_1 <>  OKL_API.G_MISS_CHAR) THEN
              OPEN  c_tax_book_csr (l_asst_add_book_type_code, l_tax_book_1);
              FETCH c_tax_book_csr INTO l_tax_1;
                  IF c_tax_book_csr%NOTFOUND THEN

                      l_return_status := OKL_API.G_RET_STS_ERROR;
                      OKL_API.SET_MESSAGE(p_app_name          => 'OKL',
                                    p_msg_name          => 'OKL_AM_INVALID_TAX_BOOK',
                                            p_token1        => 'TAX_BOOK',
                                            p_token1_value  =>  l_tax_book_name_1,
                                            p_token2        => 'CORPORATE_BOOK',
                                            p_token2_value  =>  l_asst_book_type_name);
                     --  RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
             CLOSE c_tax_book_csr;
          END IF;

          IF (l_tax_book_2 IS NOT NULL AND  l_tax_book_2 <>  OKL_API.G_MISS_CHAR) THEN
              OPEN  c_tax_book_csr (l_asst_add_book_type_code, l_tax_book_2);
              FETCH c_tax_book_csr INTO l_tax_2;
                  IF c_tax_book_csr%NOTFOUND THEN

                      l_return_status := OKL_API.G_RET_STS_ERROR;
                      OKL_API.SET_MESSAGE(p_app_name          => 'OKL',
                                    p_msg_name          => 'OKL_AM_INVALID_TAX_BOOK',
                                            p_token1        => 'TAX_BOOK',
                                            p_token1_value  =>  l_tax_book_name_2,
                                            p_token2        => 'CORPORATE_BOOK',
                                            p_token2_value  =>  l_asst_book_type_name);
                     -- RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF;
             CLOSE c_tax_book_csr;

         END IF;
     END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;

-- no duplicate l_rpt_prod_book_type_code and tax book 1 and Tax Book 2
--Commented below if by NIKSHAH for bug 8570053
/*
       IF (l_rpt_prod_book_type_code IS NOT NULL AND  l_rpt_prod_book_type_code <>  OKL_API.G_MISS_CHAR) THEN

           IF (l_tax_book_1 IS NOT NULL AND  l_tax_book_1 <>  OKL_API.G_MISS_CHAR) THEN

                    IF (l_rpt_prod_book_type_code = l_tax_book_1) THEN
                          -- l_rpt_prod_book_type_code and Tax Book 1 cannot be the same.
                        l_return_status := OKL_API.G_RET_STS_ERROR;
                        OKL_API.set_message(p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_TAX_BOOK_2_DUPLICATE',
                                            p_token1        => 'TAX_BOOK2',
                                            p_token1_value  =>  l_tax_book_name_1);
                   END IF;
            END IF;


           IF (l_tax_book_2 IS NOT NULL AND  l_tax_book_2 <>  OKL_API.G_MISS_CHAR) THEN

                    IF (l_rpt_prod_book_type_code = l_tax_book_2) THEN
                          -- l_rpt_prod_book_type_code and Tax Book 2 cannot be the same.
                        l_return_status := OKL_API.G_RET_STS_ERROR;
                        OKL_API.set_message(p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_TAX_BOOK_2_DUPLICATE',
                                            p_token1        => 'TAX_BOOK2',
                                            p_token1_value  =>  l_tax_book_name_2);
                   END IF;
            END IF;

       END IF;
*/
-- no duplicate tax books
       IF (l_tax_book_1 IS NOT NULL AND  l_tax_book_1 <>  OKL_API.G_MISS_CHAR) THEN

           IF (l_tax_book_2 IS NOT NULL AND  l_tax_book_2 <>  OKL_API.G_MISS_CHAR) THEN

                    IF (l_tax_book_1 = l_tax_book_2) THEN
                          -- Tax Book1 and Tax Book 2 cannot be the same.
                        l_return_status := OKL_API.G_RET_STS_ERROR;
                        OKL_API.set_message(p_app_name      => 'OKL',
                                            p_msg_name      => 'OKL_AM_TAX_BOOK_2_DUPLICATE',
                                            p_token1        => 'TAX_BOOK2',
                                            p_token1_value  =>  l_tax_book_name_2);
                   END IF;
            END IF;

       END IF;

       IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_HALT_VALIDATION;
          -- RAISE G_EXCEPTION_ERROR;
       END IF;


      -- DJANASWA Bug 6653304 end  Proj: Asset Repo for a Loan

      --Added conditions for Tax asset book1, Tax asset book2
      --as per the bug 8570053 by NIKSHAH
      --START #8570053
      OPEN c_get_sec_repr_method;
      FETCH c_get_sec_repr_method INTO l_sec_rep_method, l_rpt_book_type;
      CLOSE c_get_sec_repr_method;

      IF l_sec_rep_method IS NOT NULL AND
         l_tax_book_1 IS NOT NULL AND
         l_tax_book_2 IS NOT NULL
      THEN
        IF l_sec_rep_method <> 'NOT_APPLICABLE' THEN
          IF l_tax_book_1 <> l_rpt_book_type AND l_tax_book_2 <> l_rpt_book_type THEN
            l_return_status := OKL_API.G_RET_STS_ERROR;
            OKL_API.set_message(p_app_name      => 'OKL',
                                p_msg_name      => 'OKL_AM_RPT_PROD_AST_BOOK');
          END IF;
        END IF;
      END IF;
      IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      --END #8570053


       -- If no id passed then insert else update
       IF p_sypv_rec.id IS NULL OR p_sypv_rec.id = G_MISS_NUM THEN

          -- Call TAPI insert
          OKL_SYSTEM_PARAMS_ALL_PUB.insert_system_parameters(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec,
                    x_sypv_rec       => x_sypv_rec);

          -- raise exception if api returns error
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;
       ELSE

          -- Call TAPI update
          OKL_SYSTEM_PARAMS_ALL_PUB.update_system_parameters(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => G_FALSE,
                    x_return_status  => l_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_sypv_rec       => p_sypv_rec,
                    x_sypv_rec       => x_sypv_rec);

          -- raise exception if api returns error
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;
       END IF;

       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                         'End(-)');
       END IF;

  EXCEPTION


      WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          IF c_tax_book_csr%ISOPEN THEN
             CLOSE c_tax_book_csr;
          END IF;

             x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;


      WHEN G_EXCEPTION_ERROR THEN
          IF c_tax_book_csr%ISOPEN THEN
             CLOSE c_tax_book_csr;
          END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
          IF c_tax_book_csr%ISOPEN THEN
             CLOSE c_tax_book_csr;
          END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
          IF c_tax_book_csr%ISOPEN THEN
             CLOSE c_tax_book_csr;
          END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_SYSTEM_PARAMS_PVT.process_system_params',
                             'EXP - OTHERS');
           END IF;
  END process_system_params;

END OKL_AM_SYSTEM_PARAMS_PVT;

/
