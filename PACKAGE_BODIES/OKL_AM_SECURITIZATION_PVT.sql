--------------------------------------------------------
--  DDL for Package Body OKL_AM_SECURITIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SECURITIZATION_PVT" AS
/* $Header: OKLRASZB.pls 120.17.12010000.2 2008/08/01 20:35:03 appldev ship $ */


    -- rmunjulu EDAT
    -- declare g_add_params as global variable, so that it can be passed to all formulae
    g_add_params		okl_execute_formula_pub.ctxt_val_tbl_type;
    -- rmunjulu 4398936 Added the following global variable for bug
    g_call_ad_flag boolean default false;

    -- gboomina Bug 4775555 - Start
    G_DATE_EFFECTIVE_FROM DATE;
    G_PARTIAL_YN VARCHAR2(3);
    -- cklee R12 bug7164915/okl.h Bug 7009075 - Added - Start
/*========================================================================
 | PUBLIC PROCEDURE create_inv_khr_obligation
 |
 | DESCRIPTION
 |      Processes invester contract obligation for rent. This procedure was
 |      created from logic written in disburse_investor_rent to separate logic
 |      for creation of investor KHR obligation from investor disb adjustment.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_rec      IN     Record of asset for processing
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-MAY-2008           smadhava          Created.
 *=======================================================================*/
  PROCEDURE create_inv_khr_obligation(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ia_id             IN  NUMBER,
    p_effective_date    IN  DATE DEFAULT NULL,
    p_transaction_date  IN  DATE DEFAULT NULL,
    p_asset_rec			IN  qte_asset_type) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_next_trx_val_csr IS
       SELECT okl_sif_seq.nextval
       FROM   dual;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_loop_counter NUMBER;
    l_formula_amount    NUMBER := 0;
    l_formula_name      CONSTANT VARCHAR2(40)  := 'INVESTOR_RENT_DISBURSEMENT';
    l_rent_sty          CONSTANT VARCHAR2(50)  := 'INVESTOR_CNTRCT_OBLIGATION_PAY'; -- SMODUGA 15-Oct-04 Bug 3925469
    l_disbursement_amount   NUMBER;

    l_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    l_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;
    x_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    x_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;

    l_sty_id        NUMBER;
    l_trx_id        NUMBER;
    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag          BOOLEAN;
  BEGIN
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
            ,'Begin (+)');
    END IF;

    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag := FALSE;
    IF g_add_params.COUNT > 0
    THEN
        FOR l_loop_counter IN g_add_params.FIRST..g_add_params.LAST
        LOOP
            IF g_add_params(l_loop_counter).name = 'inv_agr_id'
            THEN
                l_flag := TRUE;
                g_add_params(l_loop_counter).value := p_ia_id;
            END IF;
        END LOOP;
    END IF;
    IF l_flag = FALSE
    THEN
        l_loop_counter := NVL(g_add_params.LAST, 0) + 1;
        g_add_params(l_loop_counter).name := 'inv_agr_id';
        g_add_params(l_loop_counter).value := p_ia_id;
    END IF;

    -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
    OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_id,
                                             l_rent_sty,
                                             l_return_status,
                                             l_sty_id);

    IF l_sty_id IS NULL OR l_sty_id = OKL_API.G_MISS_NUM THEN
      --message logging
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                    ,'OKL_STREAMS_UTIL.get_primary_stream_type returned no values');
       END IF;

       -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
       OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'STY_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_asset_rec.p_amount IS NOT NULL THEN
      --message logging
      IF (FND_LOG.LEVEL_STATEMENT >=
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                        ,'calling OKL_AM_UTIL_PVT.get_formula_value with'
                        ||' formula name '||l_formula_name);
      END IF;

      OKL_AM_UTIL_PVT.get_formula_value(
                     p_formula_name  =>  l_formula_name
                    ,p_chr_id        =>  p_asset_rec.p_khr_id
                    ,p_cle_id        =>  p_asset_rec.p_kle_id
     				,p_additional_parameters => g_add_params -- rmunjulu EDAT
                    ,x_formula_value =>  l_formula_amount
                    ,x_return_status =>  l_return_status);

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- message logging
      IF (FND_LOG.LEVEL_STATEMENT >=
                  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                        ,'returning from OKL_AM_UTIL_PVT.get_formula_value'
                        ||', status is '
                        ||l_return_status
                        ||' and l_formula_amount is '
                        ||l_formula_amount);
      END IF;

      OPEN get_next_trx_val_csr;
      FETCH get_next_trx_val_csr INTO l_trx_id;
      CLOSE get_next_trx_val_csr;

      l_disbursement_amount :=
                      (p_asset_rec.p_amount * l_formula_amount);
      -- stream header parameters
      l_stmv_rec.khr_id       := p_asset_rec.p_khr_id;
      l_stmv_rec.kle_id       := p_asset_rec.p_kle_id;
      l_stmv_rec.sty_id       := l_sty_id;
      l_stmv_rec.SGN_CODE     := 'MANL';
      l_stmv_rec.SAY_CODE     := 'CURR';
      l_stmv_rec.TRANSACTION_NUMBER   :=  l_trx_id;
      l_stmv_rec.ACTIVE_YN    := 'Y';

      -- rmunjulu 3910833 added code to set source_id and source_table
      l_stmv_rec.source_id := p_ia_id;
      l_stmv_rec.source_table := G_SOURCE_TABLE;

      -- stream element parameters
      l_selv_tbl(1).stream_element_date  := p_transaction_date; -- rmunjulu EDAT
      -- 04 Nov 2004 PAGARG Bug# 3954752
      l_selv_tbl(1).amount    := l_disbursement_amount;
      l_selv_tbl(1).ACCRUED_YN           := 'N';
      l_selv_tbl(1).SE_LINE_NUMBER       := 1;

      --message logging
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                        ,'calling OKL_STREAMS_PUB.create_streams ');
      END IF;

      OKL_STREAMS_PUB.create_streams(
                                 p_api_version    => p_api_version
                                ,p_init_msg_list  => p_init_msg_list
                                ,x_return_status  => l_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_stmv_rec       => l_stmv_rec
                                ,p_selv_tbl       => l_selv_tbl
                                ,x_stmv_rec       => x_stmv_rec
                                ,x_selv_tbl       => x_selv_tbl  );

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --message logging
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                        ,'returning from OKL_STREAMS_PUB.create_streams,'
                        ||' status is '||l_return_status);
      END IF;
    END IF;

    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
            ,'End (-)');
    END IF;

    x_return_status := l_return_status;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                , 'Handled exception occured');
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          'create_inv_khr_obligation',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                , 'Expected exception occured');
        END IF;

        x_return_status := OKL_API.HANDLE_EXCEPTIONS
        (
          'create_inv_khr_obligation',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_inv_khr_obligation'
                , 'When others exception occured');
        END IF;

        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


    END create_inv_khr_obligation;
    -- cklee R12 bug7164915/okl.h Bug 7009075 - Added - End

   /*========================================================================
    | PROCEDURE do_disb_adjustments
    |
    | DESCRIPTION
    |      do investor disbursement adjustments during full termination
    |
    | MODIFICATION HISTORY
    | 26-sep-05             rmunjulu         INVESTOR_DISB_ADJUSTMENTS
    *=======================================================================*/
      PROCEDURE do_disb_adjustments (
                        p_api_version               IN  NUMBER,
                        p_init_msg_list     IN  VARCHAR2,
                        x_msg_count                 OUT NOCOPY NUMBER,
                        x_msg_data                  OUT NOCOPY VARCHAR2,
                        p_ia_id             IN  NUMBER,
                        p_khr_id            IN  NUMBER,
                        p_kle_id            IN  NUMBER,
                        p_partial_yn        IN  VARCHAR2,
                        p_quote_eff_date    IN  DATE,
                                            x_return_status     OUT NOCOPY VARCHAR2) IS

              -- get already disbursed amounts over and above termination date
          CURSOR get_disb_streams_csr(
                                         p_ia_id IN NUMBER,
                                     p_kle_id IN NUMBER,
                                     p_quote_eff_date IN DATE,
                                     p_invdisbas_sty_id IN NUMBER,
                                     p_rbkadj_sty_id IN NUMBER) IS
                   SELECT
                             sum(ste.amount)
                      FROM
                 OKL_STRM_ELEMENTS             STE,
                             OKL_STREAMS                            STM,
                             OKL_STRM_TYPE_V                        STY
                   WHERE ste.amount               <> 0
                   AND          stm.id                           = ste.stm_id
           AND   sty.id                   IN (p_invdisbas_sty_id) -- pick INVESTOR RENT DISB BASIS streams only
                   AND          ste.date_billed          IS NOT NULL  -- already disbursed (fake and real both)
                   AND          stm.active_yn                   = 'Y'        -- always active streams only
                   AND          stm.say_code                   = 'CURR'     -- always current streams only
                   AND          sty.id                           = stm.sty_id
                   AND   stm.kle_id               = p_kle_id   -- for the terminated asset
                   AND   ste.stream_element_date  > p_quote_eff_date -- pick streams greater than termination date
           AND   stm.source_id            = p_ia_id;

              -- get disbusement amounts which are not yet disbursed but which will be
              -- disbursed over and above termination date
          CURSOR get_disb_streams_csr2(
                                         p_ia_id IN NUMBER,
                                     p_kle_id IN NUMBER,
                                     p_quote_eff_date IN DATE,
                                     p_invdisbas_sty_id IN NUMBER,
                                     p_rbkadj_sty_id IN NUMBER) IS
                   SELECT
                             sum(ste.amount)
                      FROM
                 OKL_STRM_ELEMENTS             STE,
                             OKL_STREAMS                            STM,
                             OKL_STRM_TYPE_V                        STY,
                             OKL_STRM_ELEMENTS         BILLED_STE
                   WHERE ste.amount               <> 0
                   AND          stm.id                           = ste.stm_id
           AND   sty.id                   IN (p_invdisbas_sty_id) -- pick INVESTOR RENT DISB BASIS streams only
                   AND          ste.date_billed          IS NULL         -- NOT YET disbursed (fake or real)
                   AND   ste.sel_id               = billed_ste.id -- original billing stream was billed
                   AND   billed_ste.date_billed   IS NOT NULL
                   AND          stm.active_yn                   = 'Y'           -- always active streams only
                   AND          stm.say_code                   = 'CURR'        -- always current streams only
                   AND          sty.id                           = stm.sty_id
                   AND   stm.kle_id               = p_kle_id      -- for the terminated asset
                   AND   ste.stream_element_date  > p_quote_eff_date -- pick streams greater than termination date
           AND   stm.source_id            = p_ia_id ;

          CURSOR get_next_trx_val_csr IS
           SELECT okl_sif_seq.nextval
           FROM   dual;

           l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
           l_invdisbas_sty_id  NUMBER;
           l_rbkadj_sty_id  NUMBER;
           l_adj_amount NUMBER := 0;
           l_adj_amount2 NUMBER := 0;
           l_trx_id NUMBER;
           l_stmv_rec          OKL_STM_PVT.stmv_rec_type;
           l_selv_tbl          OKL_SEL_PVT.selv_tbl_type;
           x_stmv_rec          OKL_STM_PVT.stmv_rec_type;
           x_selv_tbl          OKL_SEL_PVT.selv_tbl_type;
           l_api_name VARCHAR2(30) := 'inv_disb';
           l_api_version NUMBER := 1;
           l_term_adj_amount NUMBER;

      BEGIN

         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'START+');
         END IF;

         l_return_status := OKL_API.start_activity(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => l_return_status);

         IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- get disbursement amounts only when FULL TERMINATION
         IF p_partial_yn = 'N' THEN

           -- get rebook disbursement stream purpose
           OKL_STREAMS_UTIL.get_primary_stream_type(
                                    p_khr_id               => p_ia_id,
                                    p_primary_sty_purpose  => 'INVESTOR_DISB_ADJUSTMENT',
                                    x_return_status        => l_return_status,
                                    x_primary_sty_id       => l_rbkadj_sty_id);

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'get_primary_stream_type INVESTOR_DISB_ADJUSTMENT returns '||l_return_status);
           END IF;

           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

                   -- get investor rent disb basis stream purpose
           OKL_STREAMS_UTIL.get_primary_stream_type(
                                    p_khr_id               => p_ia_id,
                                    p_primary_sty_purpose  => 'INVESTOR_RENT_DISB_BASIS',
                                    x_return_status        => l_return_status,
                                    x_primary_sty_id       => l_invdisbas_sty_id);

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'get_primary_stream_type INVESTOR_RENT_DISB_BASIS returns '||l_return_status);
           END IF;

           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           OPEN get_disb_streams_csr(
                                             p_ia_id,
                                     p_kle_id ,
                                     p_quote_eff_date ,
                                     l_invdisbas_sty_id ,
                                     l_rbkadj_sty_id );
           FETCH get_disb_streams_csr INTO l_adj_amount;
           CLOSE get_disb_streams_csr;


           OPEN get_disb_streams_csr2(
                                             p_ia_id,
                                     p_kle_id ,
                                     p_quote_eff_date ,
                                     l_invdisbas_sty_id ,
                                     l_rbkadj_sty_id );
           FETCH get_disb_streams_csr2 INTO l_adj_amount2;
           CLOSE get_disb_streams_csr2;


           l_term_adj_amount := nvl(l_adj_amount,0) + nvl(l_adj_amount2,0);

           IF l_term_adj_amount <> 0 THEN

                      OPEN get_next_trx_val_csr;
              FETCH get_next_trx_val_csr INTO l_trx_id;
              CLOSE get_next_trx_val_csr;

              -- stream header parameters
              l_stmv_rec.khr_id               := p_khr_id;
              l_stmv_rec.kle_id               := p_kle_id;
              l_stmv_rec.sty_id               := l_rbkadj_sty_id;
              l_stmv_rec.SGN_CODE             := 'MANL';
              l_stmv_rec.SAY_CODE             := 'CURR';
              l_stmv_rec.transaction_number   := l_trx_id;
              l_stmv_rec.active_yn            := 'Y';
              l_stmv_rec.source_id            := p_ia_id;
              l_stmv_rec.source_table         := G_SOURCE_TABLE;
              l_stmv_rec.date_current         := sysdate;

              -- stream element parameters
              l_selv_tbl(1).stream_element_date  := sysdate; --***
              l_selv_tbl(1).amount               := l_term_adj_amount * -1; -- rmunjulu always negate the amount
              l_selv_tbl(1).accrued_yn           := 'N';
              l_selv_tbl(1).se_line_number       := 1;

              OKL_STREAMS_PUB.create_streams(
                                    p_api_version    => p_api_version
                                   ,p_init_msg_list  => OKL_API.G_FALSE
                                   ,x_return_status  => l_return_status
                                   ,x_msg_count      => x_msg_count
                                   ,x_msg_data       => x_msg_data
                                   ,p_stmv_rec       => l_stmv_rec
                                   ,p_selv_tbl       => l_selv_tbl
                                   ,x_stmv_rec       => x_stmv_rec
                                   ,x_selv_tbl       => x_selv_tbl);

              IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                      , 'create_streams returns '||l_return_status);
              END IF;

              IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

           END IF;
         END IF;

         x_return_status := l_return_status;

         OKL_API.end_activity(x_msg_count  => x_msg_count
                             ,x_msg_data   => x_msg_data);

         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'END-');
         END IF;

       EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'Handled exception occured');
           END IF;
           x_return_status := OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
           );

       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'Unexpected exception occured');
           END IF;
           x_return_status := OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
           );

       WHEN OTHERS THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments'
                   , 'When others exception occured');
           END IF;
           OKL_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      END;
    -- gboomina Bug 4775555 - End

 /* sosharma Start changes */

      PROCEDURE do_disb_adjustments_loan (
                        p_api_version               IN  NUMBER,
                        p_init_msg_list     IN  VARCHAR2,
                        x_msg_count                 OUT NOCOPY NUMBER,
                        x_msg_data                  OUT NOCOPY VARCHAR2,
                        p_ia_id             IN  NUMBER,
                        p_khr_id            IN  NUMBER,
                        p_kle_id            IN  NUMBER,
                        p_partial_yn        IN  VARCHAR2,
                        p_quote_eff_date    IN  DATE,
                                            x_return_status     OUT NOCOPY VARCHAR2) IS

              -- get already disbursed amounts over and above termination date
          CURSOR get_disb_streams_csr(
                                         p_ia_id IN NUMBER,
                                     p_kle_id IN NUMBER,
                                     p_quote_eff_date IN DATE,
                                     p_invdisbas_sty_id IN NUMBER,
                                     p_intdisbas_sty_id  NUMBER,
                                     p_rbkadj_sty_id IN NUMBER) IS
                   SELECT
                             sum(ste.amount)
                      FROM
                 OKL_STRM_ELEMENTS             STE,
                             OKL_STREAMS                            STM,
                             OKL_STRM_TYPE_V                        STY
                   WHERE ste.amount               <> 0
                   AND          stm.id                           = ste.stm_id
           AND   sty.id                   IN (p_invdisbas_sty_id,p_intdisbas_sty_id) -- pick INVESTOR Principal,interest DISB BASIS streams only
                   AND          ste.date_billed          IS NOT NULL  -- already disbursed (fake and real both)
                   AND          stm.active_yn                   = 'Y'        -- always active streams only
                   AND          stm.say_code                   = 'CURR'     -- always current streams only
                   AND          sty.id                           = stm.sty_id
                   AND   stm.kle_id               = p_kle_id   -- for the terminated asset
                   AND   ste.stream_element_date  > p_quote_eff_date -- pick streams greater than termination date
           AND   stm.source_id            = p_ia_id;

              -- get disbusement amounts which are not yet disbursed but which will be
              -- disbursed over and above termination date
          CURSOR get_disb_streams_csr2(
                                         p_ia_id IN NUMBER,
                                     p_kle_id IN NUMBER,
                                     p_quote_eff_date IN DATE,
                                     p_invdisbas_sty_id IN NUMBER,
                                     p_intdisbas_sty_id IN NUMBER,
                                     p_rbkadj_sty_id IN NUMBER) IS
                   SELECT
                             sum(ste.amount)
                      FROM
                 OKL_STRM_ELEMENTS             STE,
                             OKL_STREAMS                            STM,
                             OKL_STRM_TYPE_V                        STY,
                             OKL_STRM_ELEMENTS         BILLED_STE
                   WHERE ste.amount               <> 0
                   AND          stm.id                           = ste.stm_id
           AND   sty.id                   IN (p_invdisbas_sty_id,p_intdisbas_sty_id) -- pick INVESTOR Principal,interest DISB BASIS streams only
                   AND          ste.date_billed          IS NULL         -- NOT YET disbursed (fake or real)
                   AND   ste.sel_id               = billed_ste.id -- original billing stream was billed
                   AND   billed_ste.date_billed   IS NOT NULL
                   AND          stm.active_yn                   = 'Y'           -- always active streams only
                   AND          stm.say_code                   = 'CURR'        -- always current streams only
                   AND          sty.id                           = stm.sty_id
                   AND   stm.kle_id               = p_kle_id      -- for the terminated asset
                   AND   ste.stream_element_date  > p_quote_eff_date -- pick streams greater than termination date
           AND   stm.source_id            = p_ia_id ;

          CURSOR get_next_trx_val_csr IS
           SELECT okl_sif_seq.nextval
           FROM   dual;

           l_return_status VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
           l_invdisbas_sty_id  NUMBER;
           l_intdisbas_sty_id  NUMBER;
           l_rbkadj_sty_id  NUMBER;
           l_adj_amount NUMBER := 0;
           l_adj_amount2 NUMBER := 0;
           l_trx_id NUMBER;
           l_stmv_rec          OKL_STM_PVT.stmv_rec_type;
           l_selv_tbl          OKL_SEL_PVT.selv_tbl_type;
           x_stmv_rec          OKL_STM_PVT.stmv_rec_type;
           x_selv_tbl          OKL_SEL_PVT.selv_tbl_type;
           l_api_name VARCHAR2(30) := 'inv_disb';
           l_api_version NUMBER := 1;
           l_term_adj_amount NUMBER;

      BEGIN

         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'START+');
         END IF;

         l_return_status := OKL_API.start_activity(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => l_return_status);

         IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         -- get disbursement amounts only when FULL TERMINATION
         IF p_partial_yn = 'N' THEN

           -- get rebook disbursement stream purpose
           OKL_STREAMS_UTIL.get_primary_stream_type(
                                    p_khr_id               => p_ia_id,
                                    p_primary_sty_purpose  => 'INVESTOR_DISB_ADJUSTMENT',
                                    x_return_status        => l_return_status,
                                    x_primary_sty_id       => l_rbkadj_sty_id);

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'get_primary_stream_type INVESTOR_DISB_ADJUSTMENT returns '||l_return_status);
           END IF;

           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

                   -- get investor investor disb basis stream purpose
           OKL_STREAMS_UTIL.get_primary_stream_type(
                                    p_khr_id               => p_ia_id,
                                    p_primary_sty_purpose  => 'INVESTOR_PRINCIPAL_DISB_BASIS',
                                    x_return_status        => l_return_status,
                                    x_primary_sty_id       => l_invdisbas_sty_id);

             OKL_STREAMS_UTIL.get_primary_stream_type(
                                    p_khr_id               => p_ia_id,
                                    p_primary_sty_purpose  => 'INVESTOR_INTEREST_DISB_BASIS',
                                    x_return_status        => l_return_status,
                                    x_primary_sty_id       => l_intdisbas_sty_id);

           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'get_primary_stream_type INVESTOR_RENT_DISB_BASIS returns '||l_return_status);
           END IF;

           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           OPEN get_disb_streams_csr(
                                             p_ia_id,
                                     p_kle_id ,
                                     p_quote_eff_date ,
                                     l_invdisbas_sty_id ,
                                     l_intdisbas_sty_id ,
                                     l_rbkadj_sty_id );
           FETCH get_disb_streams_csr INTO l_adj_amount;
           CLOSE get_disb_streams_csr;


           OPEN get_disb_streams_csr2(
                                             p_ia_id,
                                     p_kle_id ,
                                     p_quote_eff_date ,
                                     l_invdisbas_sty_id ,
                                     l_intdisbas_sty_id ,
                                     l_rbkadj_sty_id );
           FETCH get_disb_streams_csr2 INTO l_adj_amount2;
           CLOSE get_disb_streams_csr2;


           l_term_adj_amount := nvl(l_adj_amount,0) + nvl(l_adj_amount2,0);

           IF l_term_adj_amount <> 0 THEN

                      OPEN get_next_trx_val_csr;
              FETCH get_next_trx_val_csr INTO l_trx_id;
              CLOSE get_next_trx_val_csr;

              -- stream header parameters
              l_stmv_rec.khr_id               := p_khr_id;
              l_stmv_rec.kle_id               := p_kle_id;
              l_stmv_rec.sty_id               := l_rbkadj_sty_id;
              l_stmv_rec.SGN_CODE             := 'MANL';
              l_stmv_rec.SAY_CODE             := 'CURR';
              l_stmv_rec.transaction_number   := l_trx_id;
              l_stmv_rec.active_yn            := 'Y';
              l_stmv_rec.source_id            := p_ia_id;
              l_stmv_rec.source_table         := G_SOURCE_TABLE;
              l_stmv_rec.date_current         := sysdate;

              -- stream element parameters
              l_selv_tbl(1).stream_element_date  := sysdate; --***
              l_selv_tbl(1).amount               := l_term_adj_amount * -1; -- rmunjulu always negate the amount
              l_selv_tbl(1).accrued_yn           := 'N';
              l_selv_tbl(1).se_line_number       := 1;

              OKL_STREAMS_PUB.create_streams(
                                    p_api_version    => p_api_version
                                   ,p_init_msg_list  => OKL_API.G_FALSE
                                   ,x_return_status  => l_return_status
                                   ,x_msg_count      => x_msg_count
                                   ,x_msg_data       => x_msg_data
                                   ,p_stmv_rec       => l_stmv_rec
                                   ,p_selv_tbl       => l_selv_tbl
                                   ,x_stmv_rec       => x_stmv_rec
                                   ,x_selv_tbl       => x_selv_tbl);

              IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                      , 'create_streams returns '||l_return_status);
              END IF;

              IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

           END IF;
         END IF;

         x_return_status := l_return_status;

         OKL_API.end_activity(x_msg_count  => x_msg_count
                             ,x_msg_data   => x_msg_data);

         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
             ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'END-');
         END IF;

       EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'Handled exception occured');
           END IF;
           x_return_status := OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
           );

       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'Unexpected exception occured');
           END IF;
           x_return_status := OKC_API.HANDLE_EXCEPTIONS
           (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PVT'
           );

       WHEN OTHERS THEN

           IF get_disb_streams_csr%ISOPEN THEN
              CLOSE get_disb_streams_csr;
           END IF;

           IF get_disb_streams_csr2%ISOPEN THEN
              CLOSE get_disb_streams_csr2;
           END IF;

           IF get_next_trx_val_csr%ISOPEN THEN
              CLOSE get_next_trx_val_csr;
           END IF;

           --message logging
           IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                   ,'OKL_AM_SECURITIZATION_PVT.do_disb_adjustments_loan'
                   , 'When others exception occured');
           END IF;
           OKL_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);

         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      END;
  /* sosharma end changes*/

/*========================================================================
 | PUBLIC PROCEDURE PROCESS_SECURITIZED_STREAMS
 |
 | DESCRIPTION
 |      Main procedure, determines if securitized items existif so,
 |      disbursements are created.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called externally from Termination Quote Acceptance workflow (OKLAMPPT).
 |      The associated workflow PACKAGE.procedure name is,
 |      OKL_AM_QUOTES_WF.chk_securitization.
 |
 |      Called externally from Asset Dsiposition PACKAGE.procedure name is,
 |      OKL_AM_ASSET_DISPOSE_PVT.dispose_asset.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_quote_id       IN     Termination Quote Identifier when called from
 |                              termincation quote acceptance.
 |      p_kle_id         IN     Asset Line identifier pased when called from
 |                              asset disposition.
 |      p_khr_id         IN     Contract Header identifier passed when called
 |                              from asset disposition
 |      p_sale_price     IN     Disposition Amount passed when called from
 |                              asset disposition.
 |      p_call_origin    IN     Used internally to identify where the has been
 |                              made from.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-OCT-2003           MDokal            Created.
 | 05-Nov-2003           MDokal      Changed x_return_status to l_return_status
 | 13-NOV-2003           MDokal      Bug #3247596 Ensure l_asset_tbl.COUNT > 0.
 | 24-Sep-2004           rmunjulu    3910833 Added code to pass investor id to
 |                                   disburse rent and disburse rv
 | 06-Oct-2004           rmunjulu    EDAT Added Parameters to get transaction
 |                                   date and effective date and do processing
 |                                   based on those
 | 18-Oct-2004           rmunjulu    EDAT Added code to pass quote_id to formula
 | 04-Nov-2004           PAGARG      3954752 changed to get kle_ids from AMCFIA if
 |                                   contract_obligation not found
 | 24-Nov-2004           rmunjulu    EDAT Modified to initialize and pass correct
 |                                   dates to calling APIs
 | 11-Jan-2005           PAGARG      3948473 Set the flag if kle_id is null in
 |                                   get_qte_asset_details_csr and check the flag
 |                                   to populate asset table with AMCFIA quote line
 | 12-Jan-2005           PAGARG      Bug 3954752 Set the flag and initialise the
 |                                   counter also if kle_id is null in
 |                                   get_qte_asset_details_csr. So that
 |                                   l_asset_table is populated fresh.
 | 07-Dec-2005           gboomina    Bug 4775555 - INVESTOR_DISB_ADJUSTSMENTS
 | 17-Jan-2008           sosharma    Modifications to include fixed loans in
 |                                   Investor Agreement
 *=======================================================================*/
  PROCEDURE process_securitized_streams(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_quote_id			IN  NUMBER,
    p_kle_id            IN  NUMBER,
    p_khr_id            IN  NUMBER,
    p_sale_price        IN  NUMBER,
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_call_origin       IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- rmunjulu EDAT 24-Nov-04
    CURSOR get_khr_id_csr(c_quote_id NUMBER) IS
        SELECT KHR_ID,
		       NVL(PARTIAL_YN, 'N') PARTIAL_YN,
		       date_effective_from, -- rmunjulu EDAT 24-Nov-04
		       date_accepted -- rmunjulu EDAT 24-Nov-04
        FROM   OKL_TRX_QUOTES_V
        WHERE  ID = c_quote_id;

    CURSOR get_rv_khr_id_csr(c_kle_id NUMBER) IS
        SELECT CHR_ID
        FROM   OKC_K_LINES_B
        WHERE  ID = c_kle_id;

    CURSOR get_qte_asset_details_csr(c_quote_id NUMBER) IS
        SELECT KLE_ID, -- STY_ID,
               SUM(AMOUNT) AMOUNT
               --, QLT_CODE
        FROM   OKL_TXL_QUOTE_LINES_B
        WHERE  QTE_ID = c_quote_id
        AND    QLT_CODE IN ('AMBCOC','AMCTUR','AMCTOC') -- qualify as CO lines
        GROUP BY KLE_ID, STY_ID, QLT_CODE
        ORDER BY KLE_ID;

    CURSOR get_rv_streams_csr(c_khr_id IN NUMBER,
                              c_kle_id IN NUMBER) IS
        SELECT  STM.id
        FROM    OKL_STREAMS_V         STM,
                OKL_STRM_TYPE_B       STY
        WHERE   STM.khr_id            = c_khr_id
        AND     STM.kle_id            = c_kle_id
        AND     STM.say_code          = 'CURR'
        AND     STM.STY_ID            = STY.ID
        AND     stream_type_subclass  = 'RESIDUAL';

    -- 04 Nov 2004 PAGARG Bug# 3954752
    -- get the quoted assets
    CURSOR get_qte_assets_csr(c_quote_id NUMBER) IS
        SELECT KLE_ID,
               0 AMOUNT
        FROM   OKL_TXL_QUOTE_LINES_B
        WHERE  QTE_ID = c_quote_id
        AND    QLT_CODE IN ('AMCFIA');

	-- Bug# 7009075 - Added - Start
	-- Cursor to fetch the latest of buy back dates on a contract
    CURSOR get_max_buy_back_date(p_khr_id OKC_K_HEADERS_B.ID%TYPE, p_sty_code OKL_POOL_CONTENTS.STY_CODE%TYPE) IS
      SELECT TRUNC(MAX(POX.DATE_EFFECTIVE))
        FROM OKL_POOL_CONTENTS POC,
             OKL_POOL_TRANSACTIONS POX
       WHERE POC.KHR_ID = p_khr_id
       AND POC.STY_CODE = p_sty_code
       AND POX.POL_ID = POC.POL_ID
       AND POX.TRANSACTION_NUMBER = POC.TRANSACTION_NUMBER_IN
	   AND POX.TRANSACTION_REASON = 'BUY_BACK';

	-- Cursor to fetch the active pool contents for a contract line. Cursor
	-- fetches the pool content that is latest first
    CURSOR get_active_poc(p_khr_id OKC_K_HEADERS_B.ID%TYPE
                        , p_kle_id OKC_K_LINES_B.ID%TYPE
                    	, p_sty_code OKL_POOL_CONTENTS.STY_CODE%TYPE) IS
      SELECT POOL.KHR_ID IA_ID
           , POC.STREAMS_TO_DATE
        FROM OKL_POOL_CONTENTS POC
           , OKL_POOLS POOL
       WHERE POOL.ID = POC.POL_ID
	     AND POC.KHR_ID = p_khr_id
         AND POC.KLE_ID = p_kle_id
         AND POC.STATUS_CODE = 'ACTIVE'
         AND EXISTS (SELECT '1'
              FROM OKL_STREAMS STMB,
                   OKL_STRM_TYPE_B STYB
              WHERE stmb.sty_id = styb.id
              AND   stmb.khr_id = POC.khr_id
              AND   stmb.kle_id = POC.kle_id
			  AND   stmb.id = POC.stm_id
              AND   styb.stream_type_subclass =p_sty_code
              )
	   ORDER BY POC.STREAMS_TO_DATE DESC;
	-- Bug# 7009075 - Added - End

        /* sosharma 17-jan-2008
        cursor to fetch the book classification of a contract
        Start changes
        */
    CURSOR get_bok_class_csr(p_khr_id NUMBER) IS
        SELECT deal_type
        FROM   OKL_K_HEADERS khr
        WHERE  khr.id = p_khr_id;

        /* sosharma end changes*/


/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'proc_secure_streams';
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_disb_type         VARCHAR2(20);
    l_kle_id            NUMBER;
    l_khr_id            NUMBER;
    l_loop_counter      NUMBER := 0;
    l_is_securitized    VARCHAR2(1) := OKC_API.G_FALSE;

    lp_stmv_tbl         OKL_STREAMS_PUB.stmv_tbl_type;
    lx_stmv_tbl         OKL_STREAMS_PUB.stmv_tbl_type;

    l_stm_id            NUMBER;
    l_stm_id_not_found  BOOLEAN := FALSE;
    l_asset_tbl         asset_tbl_type;

    l_inv_agmt_chr_id_tbl OKL_SECURITIZATION_PVT.inv_agmt_chr_id_tbl_type;
    l_transaction_reason    VARCHAR2(50);
    l_partial               VARCHAR2(1)  := '0';   -- rmunjulu 4398936 initialized this variable

    -- rmunjulu 3910833
    l_ia_id NUMBER;

    -- rmunjulu EDAT
    l_sysdate DATE;
    l_effective_date DATE;
    l_transaction_date DATE;

    -- 02 Nov 2004 PAGARG Bug# 3954752
    no_cob_exception EXCEPTION;

    -- rmunjulu EDAT 24-Nov-04
    l_quote_accpt_date DATE;
    l_quote_eff_date DATE;
    l_effective_from_date DATE;
    l_acceptance_date DATE;
    l_sys_date DATE;
    -- PAGARG 3948473
    l_flag BOOLEAN;

   --sosharma added to get book classification
   l_book_class VARCHAR2(50);

    -- Bug# 7009075 - Added
    l_max_buy_back_date DATE;
    l_stream_to_date DATE;
    l_create_inv_khr_oblig BOOLEAN DEFAULT FALSE;
    l_temp_ia_id OKC_K_HEADERS_B.ID%TYPE;

  BEGIN

    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            ,'Begin (+)');
    END IF;

    --message logging
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            ,'calling Okl_Api.START_ACTIVITY');
    END IF;

    -- Check API version, initialize message list and create savepoint.
    l_return_status := Okl_Api.START_ACTIVITY(
                                            p_api_name      => l_api_name,
                                            p_pkg_name      => G_PKG_NAME,
                                            p_init_msg_list => p_init_msg_list,
                                            l_api_version   => l_api_version,
                                            p_api_version   => p_api_version,
                                            p_api_type      => G_API_TYPE,
                                            x_return_status => l_return_status);

    --message logging
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            ,'returning from Okl_Api.START_ACTIVITY, status is '
            ||l_return_status);
    END IF;

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT sysdate INTO l_sysdate FROM dual;

    -- Check which parameters have been passed to determine
    -- the origin of the call
    -- rmunjulu 24-Nov-04 Changed OR to AND in the below IF
    IF (p_quote_id IS NOT NULL) AND (p_quote_id <> OKL_API.G_MISS_NUM) THEN

       -- rmunjulu EDAT
       -- set the operands for formula engine with quote_id
       g_add_params(1).name := 'quote_id';
       g_add_params(1).value := to_char(p_quote_id);

       l_disb_type := 'RENT';

        -- rmunjulu bug 4398936 - START
        OPEN get_khr_id_csr(p_quote_id);
        FETCH get_khr_id_csr INTO l_khr_id, l_partial, l_effective_from_date, l_acceptance_date;
        IF get_khr_id_csr%notfound THEN
            CLOSE get_khr_id_csr;
            --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                    ,'cursor get_khr_id_csr returned no values');
            END IF;

            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Quote Id');
            x_return_status := G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE get_khr_id_csr;

          /* sosharma 17-01-2008
          modifications to include loans in Investor agreement
          Based on the deal type variable l_disb_type is set to loan
          Start Changes
          */
            OPEN get_bok_class_csr(l_khr_id);
            FETCH get_bok_class_csr INTO l_book_class;
            IF get_bok_class_csr%NOTFOUND THEN
               CLOSE  get_bok_class_csr;
               x_return_status := G_RET_STS_ERROR;
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            CLOSE  get_bok_class_csr;

            IF l_book_class = 'LOAN' THEN
                l_disb_type := 'LOAN_PAYMENT';
            END IF;

         /* sosharma end changes*/
        -- rmunjulu 4398936 - END
        --gboomina Bug 4775555 INVESTOR_DISB_ADJUSTMENTS - Start
        IF NVL(l_partial,'N') = 'Y' THEN
          -- need to check if no more assets
          l_partial := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_true_partial_quote(
                                   p_quote_id     => p_quote_id,
                                   p_contract_id  => l_khr_id);
        END IF;
        G_PARTIAL_YN  := l_partial; -- rmunjulu set partial yn global flag
        G_DATE_EFFECTIVE_FROM := l_effective_from_date; -- rmunjulu set effective from date global flag
        --gboomina Bug 4775555 - End

    -- rmunjulu 24-Nov-04 Changed OR to AND in the below ELSIF
    ELSIF ((p_kle_id IS NOT NULL) AND (p_kle_id <> OKL_API.G_MISS_NUM)) AND
       ((p_sale_price IS NOT NULL) AND (p_sale_price <> OKL_API.G_MISS_NUM)) THEN

        l_disb_type := 'RESIDUAL';

    ELSE

        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                ,'parameter p_quote_id is null or (p_kle_id and p_sale_price)'
                ||' are null');
        END IF;

        OKL_API.set_message(p_app_name      => G_APP_NAME,
                            p_msg_name      => G_REQUIRED_VALUE);
        x_return_status := G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- check if securitized items exist for the underlying contract

    IF l_disb_type = 'RENT' OR l_disb_type = 'LOAN_PAYMENT'  THEN

       -- rmunjulu 4398936 start -- commented out
       /*
        OPEN get_khr_id_csr(p_quote_id);
        FETCH get_khr_id_csr INTO l_khr_id, l_partial, l_effective_from_date, l_acceptance_date;
        IF get_khr_id_csr%notfound THEN
            CLOSE get_khr_id_csr;
            --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                    ,'cursor get_khr_id_csr returned no values');
            END IF;

            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Quote Id');
            x_return_status := G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE get_khr_id_csr;
   	   */
       -- rmunjulu 4398936 end

        -- rmunjulu EDAT 24-Nov-04
        l_quote_accpt_date := l_acceptance_date;
        l_quote_eff_date :=  l_effective_from_date;

    ELSIF l_disb_type = 'RESIDUAL' THEN
        OPEN get_rv_khr_id_csr(p_kle_id);
        FETCH get_rv_khr_id_csr INTO l_khr_id;
        IF get_rv_khr_id_csr%notfound THEN
            CLOSE get_rv_khr_id_csr;
            --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                    ,'cursor get_rv_khr_id_csr returned no values');
            END IF;

            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Asset Id');
            x_return_status := G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE get_rv_khr_id_csr;


        -- rmunjulu EDAT 24-Nov-04
        -- If quote exists then effective date is quote effective date else sysdate
        IF nvl(okl_am_lease_loan_trmnt_pvt.g_quote_exists,'N') = 'Y' THEN

            l_quote_accpt_date := okl_am_lease_loan_trmnt_pvt.g_quote_accept_date;
            l_quote_eff_date := okl_am_lease_loan_trmnt_pvt.g_quote_eff_from_date;

        ELSE

            l_quote_accpt_date := l_sysdate; -- rmunjulu 4398936 changed to l_sysdate
            l_quote_eff_date :=  l_sysdate; -- rmunjulu 4398936 changed to l_sysdate

        END IF;
    END IF;

    IF (l_khr_id IS NOT NULL) THEN
        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                ,'calling OKL_SECURITIZATION_PVT.check_khr_securitized');
        END IF;

        -- check if Contract is securitized
        OKL_SECURITIZATION_PVT.check_khr_securitized(
                              p_api_version          => p_api_version
                             ,p_init_msg_list        => p_init_msg_list
                             ,x_return_status        => l_return_status
                             ,x_msg_count            => x_msg_count
                             ,x_msg_data             => x_msg_data
                             ,p_khr_id               => l_khr_id
                             ,p_effective_date       => l_quote_eff_date -- rmunjulu EDAT 24-Nov-04
                             ,p_stream_type_subclass => l_disb_type
                             ,x_value                => l_is_securitized
                             ,x_inv_agmt_chr_id_tbl  => l_inv_agmt_chr_id_tbl );

        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- rmunjulu 3910833
        -- get the investor agreement for this contract's RENT or RESIDUAL streams
        IF l_inv_agmt_chr_id_tbl.COUNT > 0 THEN

           l_ia_id := l_inv_agmt_chr_id_tbl(l_inv_agmt_chr_id_tbl.FIRST).khr_id;

        END IF;

        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                ,'returning from OKL_SECURITIZATION_PVT.check_khr_securitized'
                ||', status is '||l_return_status);
        END IF;
    ELSE
        l_is_securitized := OKC_API.G_FALSE;  -- not securitized
    END IF;

    IF l_partial = 'Y' THEN
        -- modifiy call origin
        l_transaction_reason :=
                         OKL_SECURITIZATION_PVT.G_TRX_REASON_ASSET_TERMINATION;
    ELSE
        l_transaction_reason := p_call_origin;
    END IF;

    --- rmunjulu 4398936 Added the following condition.
    g_call_ad_flag := FALSE;
    IF (l_partial ='N' OR l_partial = '0') THEN
     g_call_ad_flag := TRUE;
    END IF;

	-- Bug# 7009075 - Moved - Start
	-- For RENT, we need to see if contract has ever been securitized -check not to be specific to
	-- a date. Because Investor Contract Obligation streams are to be created only if the
	-- contract still has securitized streams on an investor pool. This means after all buy back
	-- transactions, if there is an investor pool securitizing the contract, then we allow
	-- creation of Investor Contract Obligation streams. Hence for RENT alone we donot directly
	-- check using 'l_is_securitized' flag
	IF l_inv_agmt_chr_id_tbl.COUNT > 0 THEN
        IF l_disb_type = 'RENT' THEN
            -- Find asset details from the quote id supplied and store in a table
            -- PAGARG 3948473
            l_flag := FALSE;
            -- PAGARG 3954752
            l_loop_counter := 0;
            FOR l_qte_asset_details_rec IN get_qte_asset_details_csr(p_quote_id) LOOP

                l_loop_counter := l_loop_counter+1;

                IF  l_qte_asset_details_rec.kle_id IS NOT NULL THEN
                    --store the kle_id details
                    l_asset_tbl(l_loop_counter).p_kle_id
                                             := l_qte_asset_details_rec.kle_id;
                -- PAGARG 3948473
                ELSE
                  l_flag := TRUE;
                END IF;

                l_asset_tbl(l_loop_counter).p_khr_id   := l_khr_id;
                l_asset_tbl(l_loop_counter).p_amount
                                             := l_qte_asset_details_rec.amount;
            END LOOP; -- get_qte_asset_details_csr

            -- 04 Nov 2004 PAGARG Bug# 3954752
            -- no contract obligation found, get kle_id from AMCFIA quote lines
            -- amount will be 0
            -- PAGARG 3948473
            IF l_asset_tbl.count = 0 OR l_flag = TRUE THEN
               -- PAGARG 3954752
               l_loop_counter := 0;
               l_asset_tbl.DELETE;

               -- get all quote assets, amount will be zero in this case
               FOR get_qte_assets_rec IN get_qte_assets_csr (p_quote_id) LOOP

                  l_loop_counter := l_loop_counter+1;

                  IF  get_qte_assets_rec.kle_id IS NOT NULL THEN
                     --store the kle_id details
                     l_asset_tbl(l_loop_counter).p_kle_id
                                                   := get_qte_assets_rec.kle_id;
                  END IF;

                  l_asset_tbl(l_loop_counter).p_khr_id   := l_khr_id;
                  l_asset_tbl(l_loop_counter).p_amount
                                                := get_qte_assets_rec.amount;
               END LOOP;
            END IF;

            -- Bug# 7009075 - Added - Start
            l_max_buy_back_date := null;
            -- Check if contract was bought back atleast once and get latest of the buy back dates
            OPEN get_max_buy_back_date(l_khr_id, 'RENT');
              FETCH get_max_buy_back_date INTO l_max_buy_back_date;
            CLOSE get_max_buy_back_date;
            -- Bug# 7009075 - Added - End

            --mdokal Bug #3247596
            IF l_asset_tbl.COUNT > 0 THEN
              FOR l_loop_counter IN l_asset_tbl.FIRST..l_asset_tbl.LAST
              LOOP
                IF l_asset_tbl(l_loop_counter).p_amount IS NOT NULL THEN

                  l_create_inv_khr_oblig := FALSE;
                  l_stream_to_date := null;
                  -- Check if contract ever was bought back
                  IF l_max_buy_back_date IS NULL THEN
                    -- get Active pool content stream to date for this asset
					OPEN get_active_poc(l_khr_id, l_asset_tbl(l_loop_counter).p_kle_id, 'RENT');
					  FETCH get_active_poc INTO l_temp_ia_id, l_stream_to_date;
                      -- if contract has active RENT pool contents for this asset,
   					  -- create investor contract obligation streams
					  IF get_active_poc%FOUND THEN
					    l_create_inv_khr_oblig := TRUE;
					  END IF;
					CLOSE get_active_poc;
                  ELSE -- implies contract was bought back atleast once
                    -- get the latest Active pool content stream to date for this asset
					OPEN get_active_poc(l_khr_id, l_asset_tbl(l_loop_counter).p_kle_id, 'RENT');
					  FETCH get_active_poc INTO l_temp_ia_id, l_stream_to_date;
					CLOSE get_active_poc;
                    -- if there are active RENT pool contents beyond the last buy back date,
					-- create investor contract obligation streams
					IF l_max_buy_back_date < NVL(TRUNC(l_stream_to_date),l_max_buy_back_date) THEN
					  l_create_inv_khr_oblig := TRUE;
					END IF;
                  END IF; -- end of l_max_buy_back_date NULL check

                  -- Create investor contract obligation streams
                  IF l_create_inv_khr_oblig THEN
                    create_inv_khr_obligation(
					                 p_api_version       => p_api_version
                                    ,p_init_msg_list     => p_init_msg_list
                                    ,x_return_status     => l_return_status
                                    ,x_msg_count         => x_msg_count
                                    ,x_msg_data          => x_msg_data
                                    ,p_ia_id             => l_temp_ia_id -- rmunjulu 3910833
                                    ,p_effective_date    => l_quote_eff_date   -- rmunjulu EDAT 24-Nov-04
                                    ,p_transaction_date  => l_quote_accpt_date -- rmunjulu EDAT 24-Nov-04
                                    ,p_asset_rec         => l_asset_tbl(l_loop_counter));
                    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF;

                  -- Do disbursement adjustments if contract is securitized as of termination date
                  IF l_is_securitized = OKC_API.G_TRUE THEN
                    do_disb_adjustments (
                        p_api_version     => p_api_version,
                        p_init_msg_list   => OKL_API.G_FALSE,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data,
                        p_ia_id           => l_ia_id,
                        p_khr_id          => l_asset_tbl(l_loop_counter).p_khr_id,
                        p_kle_id          => l_asset_tbl(l_loop_counter).p_kle_id,
                        p_partial_yn      => G_PARTIAL_YN,
                        p_quote_eff_date  => G_DATE_EFFECTIVE_FROM,
                        x_return_status   => l_return_status);

                    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                  END IF; -- end of l_is_securitized check
                END IF; -- end of check for amount not null
              END LOOP; -- end of for loop over l_asset_tbl
            END IF; -- end of check for l_asset_tbl.COUNT > 0
	  END IF;
	END IF; -- end of check for l_inv_agmt_chr_id_tbl.COUNT > 0
	-- Bug# 7009075 - Moved - End

    IF l_is_securitized = OKC_API.G_TRUE THEN  -- this contract is securitized.

        IF  l_disb_type = 'RESIDUAL' THEN

            -- Disburse Investor Residual Stream
            disburse_investor_rv(    p_api_version       => p_api_version
                                    ,p_init_msg_list     => p_init_msg_list
                                    ,x_return_status     => l_return_status
                                    ,x_msg_count         => x_msg_count
                                    ,x_msg_data          => x_msg_data
                                    ,p_khr_id            => l_khr_id
                                    ,p_kle_id            => p_kle_id
                                    ,p_ia_id             => l_ia_id -- rmunjulu 3910833
                                    ,p_effective_date    => l_quote_eff_date   -- rmunjulu EDAT 24-Nov-04
                                    ,p_transaction_date  => l_quote_accpt_date -- rmunjulu EDAT 24-Nov-04
                                    ,p_sale_price        => p_sale_price);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            -- Historize Residual Value Stream
            -- set the tbl type for streams pub
            l_loop_counter := 1;

            FOR rv_streams_rec IN get_rv_streams_csr(p_khr_id, p_kle_id) LOOP

               lp_stmv_tbl(l_loop_counter).khr_id    := p_khr_id;
               lp_stmv_tbl(l_loop_counter).khr_id    := p_khr_id;
               lp_stmv_tbl(l_loop_counter).active_yn := 'N';
               lp_stmv_tbl(l_loop_counter).id        := rv_streams_rec.id;
               lp_stmv_tbl(l_loop_counter).say_code  := 'HIST';
               lp_stmv_tbl(l_loop_counter).date_history  := SYSDATE;

               l_loop_counter := l_loop_counter + 1;

            END LOOP; -- get_rv_streams_csr
            --message logging
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                    ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                    ,'calling OKL_STREAMS_PUB.update_streams');
            END IF;

            -- historize rv streams
            OKL_STREAMS_PUB.update_streams(
               p_api_version     => p_api_version,
               p_init_msg_list   => OKC_API.G_FALSE,
               x_return_status   => l_return_status,
               x_msg_count       => x_msg_count,
               x_msg_data        => x_msg_data,
               p_stmv_tbl        => lp_stmv_tbl,
               x_stmv_tbl        => lx_stmv_tbl);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                OKL_API.set_message( p_app_name    => G_APP_NAME,
                                     p_msg_name    => 'OKL_AM_ERR_UPD_STREAMS');
             END IF;
             --message logging
             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                        ,'returning from OKL_STREAMS_PUB.update_streams'
                        ||', status is '||l_return_status);
              END IF;

        /*   sosharma 17-01-2008
          modifications to include loans in Investor agreement
          Start Changes
        */

          ELSIF l_disb_type = 'LOAN_PAYMENT' THEN

            -- Find asset details from the quote id supplied and store in a table
            l_flag := FALSE;
            l_loop_counter := 0;
            FOR l_qte_asset_details_rec IN get_qte_asset_details_csr(p_quote_id) LOOP

                l_loop_counter := l_loop_counter+1;

                IF  l_qte_asset_details_rec.kle_id IS NOT NULL THEN
                    --store the kle_id details
                    l_asset_tbl(l_loop_counter).p_kle_id
                                             := l_qte_asset_details_rec.kle_id;
                ELSE
                  l_flag := TRUE;
                END IF;

                l_asset_tbl(l_loop_counter).p_khr_id   := l_khr_id;
                l_asset_tbl(l_loop_counter).p_amount
                                             := l_qte_asset_details_rec.amount;
            END LOOP; -- get_qte_asset_details_csr

            -- no contract obligation found, get kle_id from AMCFIA quote lines
            -- amount will be 0
            IF l_asset_tbl.count = 0 OR l_flag = TRUE THEN
               l_loop_counter := 0;
               l_asset_tbl.DELETE;

               -- get all quote assets, amount will be zero in this case
               FOR get_qte_assets_rec IN get_qte_assets_csr (p_quote_id) LOOP

                  l_loop_counter := l_loop_counter+1;

                  IF  get_qte_assets_rec.kle_id IS NOT NULL THEN
                     --store the kle_id details
                     l_asset_tbl(l_loop_counter).p_kle_id
                                                   := get_qte_assets_rec.kle_id;
                  END IF;

                  l_asset_tbl(l_loop_counter).p_khr_id   := l_khr_id;
                  l_asset_tbl(l_loop_counter).p_amount
                                                := get_qte_assets_rec.amount;
               END LOOP;
            END IF;

            IF l_asset_tbl.COUNT > 0 THEN
                -- Disburse Investor Loan Payment Stream
                disburse_investor_loan_payment(  p_api_version       => p_api_version
                                    ,p_init_msg_list     => p_init_msg_list
                                    ,x_return_status     => l_return_status
                                    ,x_msg_count         => x_msg_count
                                    ,x_msg_data          => x_msg_data
                                    ,p_ia_id             => l_ia_id
                                    ,p_effective_date    => l_quote_eff_date
                                    ,p_transaction_date  => l_quote_accpt_date
                                    ,p_asset_tbl         => l_asset_tbl);

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END IF;

     --     END IF;

        END IF;

        --mdokal Bug #3247596
        IF l_disb_type = 'RESIDUAL' OR l_asset_tbl.COUNT > 0 THEN

            -- Create Pool Transaction Record
            create_pool_transaction(
                 p_api_version		  => p_api_version
                ,p_init_msg_list	  => p_init_msg_list
                ,x_return_status	  => l_return_status
                ,x_msg_count		  => x_msg_count
                ,x_msg_data			  => x_msg_data
                ,p_asset_tbl		  => l_asset_tbl
                ,p_transaction_reason => l_transaction_reason
                ,p_khr_id             => l_khr_id
                ,p_kle_id             => p_kle_id
                ,p_effective_date     => l_quote_eff_date   -- rmunjulu EDAT 24-Nov-04
                ,p_transaction_date   => l_quote_accpt_date -- rmunjulu EDAT 24-Nov-04
                ,p_disb_type          => l_disb_type);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF; -- mdokal Bug #3247596 End
    END IF;

    --message logging
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            ,'calling Okl_Api.END_ACTIVITY');
    END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;
    --message logging
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            ,' returning from Okl_Api.END_ACTIVITY, status is ||'
            ||x_return_status);
    END IF;
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
            , 'End (-)');
    END IF;

    EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

        IF get_khr_id_csr%ISOPEN THEN
           CLOSE get_khr_id_csr;
        END IF;

        IF get_rv_khr_id_csr%ISOPEN THEN
           CLOSE get_rv_khr_id_csr;
        END IF;

        IF get_qte_asset_details_csr%ISOPEN THEN
           CLOSE get_qte_asset_details_csr;
        END IF;

        IF get_rv_streams_csr%ISOPEN THEN
           CLOSE get_rv_streams_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                , 'Handled exception occured');
        END IF;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF get_khr_id_csr%ISOPEN THEN
           CLOSE get_khr_id_csr;
        END IF;

        IF get_rv_khr_id_csr%ISOPEN THEN
           CLOSE get_rv_khr_id_csr;
        END IF;

        IF get_qte_asset_details_csr%ISOPEN THEN
           CLOSE get_qte_asset_details_csr;
        END IF;

        IF get_rv_streams_csr%ISOPEN THEN
           CLOSE get_rv_streams_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                , 'Unexpected exception occured');
        END IF;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN


        IF get_khr_id_csr%ISOPEN THEN
           CLOSE get_khr_id_csr;
        END IF;

        IF get_rv_khr_id_csr%ISOPEN THEN
           CLOSE get_rv_khr_id_csr;
        END IF;

        IF get_qte_asset_details_csr%ISOPEN THEN
           CLOSE get_qte_asset_details_csr;
        END IF;

        IF get_rv_streams_csr%ISOPEN THEN
           CLOSE get_rv_streams_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.process_securitized_streams'
                , 'When others exception occured');
        END IF;
        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END process_securitized_streams;

/*========================================================================
 | PUBLIC PROCEDURE DISBURSE_INVESTOR_RENT
 |
 | DESCRIPTION
 |      Processes invester disbursement for rent.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_tbl      IN     Table of asset(s) records for processing
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-OCT-2003           MDokal            Created.
 | 03-Nov-2003           MDokal            Changed INVESTOR RENT PAYABLE to
 |                                         INVESTOR CONTRACT OBLIGATION PAYABLE
 | 24-Sep-2004           rmunjulu          3910833 Added code to get ia_id and
 |                                         set for disbursement stream
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 | 06-Dec-2004           PAGARG            Pass investor agreement id to obtain
 |                                         formula value.
 | 07-Dec-2005           gboomina          Bug 4775555 INVESTOR_DISB_ADJUSTMENTS
 *=======================================================================*/
  PROCEDURE disburse_investor_rent(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ia_id             IN  NUMBER, -- rmunjulu 3910833
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_asset_tbl			IN  asset_tbl_type) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_next_trx_val_csr IS
       SELECT okl_sif_seq.nextval
       FROM   dual;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_loop_counter      NUMBER;

    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_formula_amount    NUMBER := 0;
    l_formula_name      CONSTANT VARCHAR2(40)  := 'INVESTOR_RENT_DISBURSEMENT';
    l_rent_sty          CONSTANT VARCHAR2(50)  := 'INVESTOR_CNTRCT_OBLIGATION_PAY'; -- SMODUGA 15-Oct-04 Bug 3925469
    l_disbursement_amount   NUMBER;

    l_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    l_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;
    x_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    x_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;

    l_sty_id        NUMBER;
    l_trx_id        NUMBER;
    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag          BOOLEAN;
  BEGIN
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
            ,'Begin (+)');
    END IF;

    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag := FALSE;
    IF g_add_params.COUNT > 0
    THEN
        FOR l_loop_counter IN g_add_params.FIRST..g_add_params.LAST
        LOOP
            IF g_add_params(l_loop_counter).name = 'inv_agr_id'
            THEN
                l_flag := TRUE;
                g_add_params(l_loop_counter).value := p_ia_id;
            END IF;
        END LOOP;
    END IF;
    IF l_flag = FALSE
    THEN
        l_loop_counter := NVL(g_add_params.LAST, 0) + 1;
        g_add_params(l_loop_counter).name := 'inv_agr_id';
        g_add_params(l_loop_counter).value := p_ia_id;
    END IF;

    IF p_asset_tbl.COUNT > 0 THEN

         -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
               OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_id,
                                                        l_rent_sty,
                                                        l_return_status,
                                                        l_sty_id);

        IF l_sty_id IS NULL OR l_sty_id = OKL_API.G_MISS_NUM THEN
             --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                    ,'OKL_STREAMS_UTIL.get_primary_stream_type returned no values');
            END IF;

            -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'STY_ID');
        END IF;
    END IF;

    FOR l_loop_counter IN p_asset_tbl.FIRST..p_asset_tbl.LAST
        LOOP
            IF p_asset_tbl(l_loop_counter).p_amount IS NOT NULL
            THEN
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >=
                  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                        ,'calling OKL_AM_UTIL_PVT.get_formula_value with'
                        ||' formula name '||l_formula_name);
                END IF;

                OKL_AM_UTIL_PVT.get_formula_value(
                     p_formula_name  =>  l_formula_name
                    ,p_chr_id        =>  p_asset_tbl(l_loop_counter).p_khr_id
                    ,p_cle_id        =>  p_asset_tbl(l_loop_counter).p_kle_id
     				,p_additional_parameters => g_add_params -- rmunjulu EDAT
                    ,x_formula_value =>  l_formula_amount
                    ,x_return_status =>  l_return_status);

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >=
                  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                        ,'returning from OKL_AM_UTIL_PVT.get_formula_value'
                        ||', status is '
                        ||l_return_status
                        ||' and l_formula_amount is '
                        ||l_formula_amount);
                END IF;

                OPEN get_next_trx_val_csr;
                FETCH get_next_trx_val_csr INTO l_trx_id;
                CLOSE get_next_trx_val_csr;

                l_disbursement_amount :=
                      (p_asset_tbl(l_loop_counter).p_amount * l_formula_amount);
                -- stream header parameters
                l_stmv_rec.khr_id       := p_asset_tbl(l_loop_counter).p_khr_id;
                l_stmv_rec.kle_id       := p_asset_tbl(l_loop_counter).p_kle_id;
                l_stmv_rec.sty_id       := l_sty_id;
                l_stmv_rec.SGN_CODE     := 'MANL';
                l_stmv_rec.SAY_CODE     := 'CURR';
                l_stmv_rec.TRANSACTION_NUMBER   :=  l_trx_id;
                l_stmv_rec.ACTIVE_YN    := 'Y';

                -- rmunjulu 3910833 added code to set source_id and source_table
                l_stmv_rec.source_id := p_ia_id;
                l_stmv_rec.source_table := G_SOURCE_TABLE;
                l_stmv_rec.date_current := SYSDATE;

                -- stream element parameters
                l_selv_tbl(1).stream_element_date  := p_transaction_date; -- rmunjulu EDAT
                -- 04 Nov 2004 PAGARG Bug# 3954752
                l_selv_tbl(1).amount    := l_disbursement_amount;
                l_selv_tbl(1).ACCRUED_YN           := 'N';
                l_selv_tbl(1).SE_LINE_NUMBER       := 1;

                -- create disbursement record

                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                        ,'calling OKL_STREAMS_PUB.create_streams ');
                END IF;

                OKL_STREAMS_PUB.create_streams(
                                 p_api_version    => p_api_version
                                ,p_init_msg_list  => p_init_msg_list
                                ,x_return_status  => l_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_stmv_rec       => l_stmv_rec
                                ,p_selv_tbl       => l_selv_tbl
                                ,x_stmv_rec       => x_stmv_rec
                                ,x_selv_tbl       => x_selv_tbl  );

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                        ,'returning from OKL_STREAMS_PUB.create_streams,'
                        ||' status is '||l_return_status);
                END IF;
                -- gboomina Bug 4775555 - Start
                -- INVESTOR_DISB_ADJUSTMENTS
                do_disb_adjustments (
                        p_api_version               => p_api_version,
                        p_init_msg_list     => OKL_API.G_FALSE,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data,
                        p_ia_id             => p_ia_id,
                        p_khr_id            => p_asset_tbl(l_loop_counter).p_khr_id,
                        p_kle_id            => p_asset_tbl(l_loop_counter).p_kle_id,
                        p_partial_yn        => G_PARTIAL_YN,
                        p_quote_eff_date    => G_DATE_EFFECTIVE_FROM,
                                            x_return_status     => l_return_status);

                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                           ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                           ,'returning from do_disb_adjustments,'
                           ||' status is '||l_return_status);
                END IF;

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                -- gboomina Bug 4775555 - End
            END IF;
        END LOOP; -- p_asset_tbl
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
            ,'End (-)');
    END IF;

    x_return_status := l_return_status;

    EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                , 'Handled exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                , 'Expected exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rent'
                , 'When others exception occured');
        END IF;

        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


    END disburse_investor_rent;


    /*========================================================================
 | PUBLIC PROCEDURE DISBURSE_INVESTOR_LOAN_PAYMENT
 |
 | DESCRIPTION
 |      Processes invester disbursement for loan payment.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_tbl      IN     Table of asset(s) records for processing
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Jan-2008           sosharma            Created.
 |
 *=======================================================================*/
  PROCEDURE disburse_investor_loan_payment(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ia_id             IN  NUMBER, -- rmunjulu 3910833
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_asset_tbl			IN  asset_tbl_type) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    CURSOR get_next_trx_val_csr IS
       SELECT okl_sif_seq.nextval
       FROM   dual;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_loop_counter      NUMBER;

    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_formula_amount    NUMBER := 0;
    l_formula_name      CONSTANT VARCHAR2(40)  := 'INVESTOR_LOAN_DISBURSEMENT';
    l_rent_sty          CONSTANT VARCHAR2(50)  := 'INVESTOR_CNTRCT_OBLIGATION_PAY'; -- SMODUGA 15-Oct-04 Bug 3925469
    l_disbursement_amount   NUMBER;

    l_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    l_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;
    x_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    x_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;

    l_sty_id        NUMBER;
    l_trx_id        NUMBER;
    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag          BOOLEAN;
  BEGIN
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
            ,'Begin (+)');
    END IF;

    --06-Dec-2004 PAGARG Bug# 3948473 passing investor agreement id as part of
    --additonal parameter to obtain formula value.
    l_flag := FALSE;
    IF g_add_params.COUNT > 0
    THEN
        FOR l_loop_counter IN g_add_params.FIRST..g_add_params.LAST
        LOOP
            IF g_add_params(l_loop_counter).name = 'inv_agr_id'
            THEN
                l_flag := TRUE;
                g_add_params(l_loop_counter).value := p_ia_id;
            END IF;
        END LOOP;
    END IF;
    IF l_flag = FALSE
    THEN
        l_loop_counter := NVL(g_add_params.LAST, 0) + 1;
        g_add_params(l_loop_counter).name := 'inv_agr_id';
        g_add_params(l_loop_counter).value := p_ia_id;
    END IF;

    IF p_asset_tbl.COUNT > 0 THEN

         -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
               OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_id,
                                                        l_rent_sty,
                                                        l_return_status,
                                                        l_sty_id);

        IF l_sty_id IS NULL OR l_sty_id = OKL_API.G_MISS_NUM THEN
             --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                    ,'OKL_STREAMS_UTIL.get_primary_stream_type returned no values');
            END IF;

            -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++
            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'STY_ID');
        END IF;
    END IF;

    FOR l_loop_counter IN p_asset_tbl.FIRST..p_asset_tbl.LAST
        LOOP
            IF p_asset_tbl(l_loop_counter).p_amount IS NOT NULL
            THEN
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >=
                  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                        ,'calling OKL_AM_UTIL_PVT.get_formula_value with'
                        ||' formula name '||l_formula_name);
                END IF;

                OKL_AM_UTIL_PVT.get_formula_value(
                     p_formula_name  =>  l_formula_name
                    ,p_chr_id        =>  p_asset_tbl(l_loop_counter).p_khr_id
                    ,p_cle_id        =>  p_asset_tbl(l_loop_counter).p_kle_id
     				,p_additional_parameters => g_add_params -- rmunjulu EDAT
                    ,x_formula_value =>  l_formula_amount
                    ,x_return_status =>  l_return_status);

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >=
                  FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                        ,'returning from OKL_AM_UTIL_PVT.get_formula_value'
                        ||', status is '
                        ||l_return_status
                        ||' and l_formula_amount is '
                        ||l_formula_amount);
                END IF;

                OPEN get_next_trx_val_csr;
                FETCH get_next_trx_val_csr INTO l_trx_id;
                CLOSE get_next_trx_val_csr;

                l_disbursement_amount :=
                      (p_asset_tbl(l_loop_counter).p_amount * l_formula_amount);
                -- stream header parameters
                l_stmv_rec.khr_id       := p_asset_tbl(l_loop_counter).p_khr_id;
                l_stmv_rec.kle_id       := p_asset_tbl(l_loop_counter).p_kle_id;
                l_stmv_rec.sty_id       := l_sty_id;
                l_stmv_rec.SGN_CODE     := 'MANL';
                l_stmv_rec.SAY_CODE     := 'CURR';
                l_stmv_rec.TRANSACTION_NUMBER   :=  l_trx_id;
                l_stmv_rec.ACTIVE_YN    := 'Y';

                -- rmunjulu 3910833 added code to set source_id and source_table
                l_stmv_rec.source_id := p_ia_id;
                l_stmv_rec.source_table := G_SOURCE_TABLE;
                l_stmv_rec.date_current := SYSDATE;

                -- stream element parameters
                l_selv_tbl(1).stream_element_date  := p_transaction_date; -- rmunjulu EDAT
                -- 04 Nov 2004 PAGARG Bug# 3954752
                l_selv_tbl(1).amount    := l_disbursement_amount;
                l_selv_tbl(1).ACCRUED_YN           := 'N';
                l_selv_tbl(1).SE_LINE_NUMBER       := 1;

                -- create disbursement record

                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                        ,'calling OKL_STREAMS_PUB.create_streams ');
                END IF;

                OKL_STREAMS_PUB.create_streams(
                                 p_api_version    => p_api_version
                                ,p_init_msg_list  => p_init_msg_list
                                ,x_return_status  => l_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_stmv_rec       => l_stmv_rec
                                ,p_selv_tbl       => l_selv_tbl
                                ,x_stmv_rec       => x_stmv_rec
                                ,x_selv_tbl       => x_selv_tbl  );

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                        ,'returning from OKL_STREAMS_PUB.create_streams,'
                        ||' status is '||l_return_status);
                END IF;
                -- gboomina Bug 4775555 - Start
                -- INVESTOR_DISB_ADJUSTMENTS
                do_disb_adjustments_loan (
                        p_api_version               => p_api_version,
                        p_init_msg_list     => OKL_API.G_FALSE,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data,
                        p_ia_id             => p_ia_id,
                        p_khr_id            => p_asset_tbl(l_loop_counter).p_khr_id,
                        p_kle_id            => p_asset_tbl(l_loop_counter).p_kle_id,
                        p_partial_yn        => G_PARTIAL_YN,
                        p_quote_eff_date    => G_DATE_EFFECTIVE_FROM,
                                            x_return_status     => l_return_status);

                --message logging
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                           ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                           ,'returning from do_disb_adjustments,'
                           ||' status is '||l_return_status);
                END IF;

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                -- gboomina Bug 4775555 - End
            END IF;
        END LOOP; -- p_asset_tbl
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
            ,'End (-)');
    END IF;

    x_return_status := l_return_status;

    EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                , 'Handled exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                , 'Expected exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_loan_payment'
                , 'When others exception occured');
        END IF;

        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


    END disburse_investor_loan_payment;

/*========================================================================
 | PUBLIC PROCEDURE DISBURSE_INVESTOR_RV
 |
 | DESCRIPTION
 |      Processes invester disbursement for residual value.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_kle_id         IN     Asset Line identifier
 |      p_khr_id         IN     Contract Header identifier
 |      p_sale_price     IN     Disposition Amount
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-OCT-2003           MDokal            Created.
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 24-Sep-2004           rmunjulu          3910833 Added code to get ia_id and
 |                                         set for disbursement stream
 | 06-Oct-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE disburse_investor_rv(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_khr_id            IN  NUMBER,
    p_kle_id			IN  NUMBER,
    p_ia_id             IN  NUMBER, -- rmunjulu 3910833
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_sale_price        IN  NUMBER) IS

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/


    CURSOR get_next_trx_val_csr IS
       SELECT okl_sif_seq.nextval
       FROM   dual;

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_formula_amount    NUMBER;
    l_formula_name      CONSTANT VARCHAR2(40)  := 'INVESTOR_RV_DISBURSEMENT';
    l_rent_sty          CONSTANT VARCHAR2(30)  := 'INVESTOR_RESIDUAL_PAY';--        SMODUGA 15-Oct-04 Bug 3925469

    l_disbursement_amount   NUMBER;

    l_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    l_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;
    x_stmv_rec          Okl_Stm_Pvt.stmv_rec_type;
    x_selv_tbl          Okl_Sel_Pvt.selv_tbl_type;

    l_trx_id            NUMBER;

  BEGIN
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
            ,'Begin (+)');
    END IF;
    -- kle_id and sale_amount are used to determine the what and how much to
    -- disburse.

    IF (p_kle_id IS NOT NULL) AND (p_sale_price IS NOT NULL) THEN
        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                ,'calling OKL_AM_UTIL_PVT.get_formula_value with formula name '
                ||l_formula_name);
        END IF;

        OKL_AM_UTIL_PVT.get_formula_value(
                                    p_formula_name  =>  l_formula_name,
                                    p_chr_id        =>  p_khr_id,
                                    p_cle_id        =>  p_kle_id,
     			 	                p_additional_parameters => g_add_params, -- rmunjulu EDAT
                                    x_formula_value =>  l_formula_amount,
                                    x_return_status =>  l_return_status);

        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                ,'returning from OKL_AM_UTIL_PVT.get_formula_value, status is '
                ||l_return_status
                ||' and l_formula_amount is '
                ||l_formula_amount);
        END IF;

        l_disbursement_amount := (p_sale_price * l_formula_amount);


         -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
               OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_id,
                                                        l_rent_sty,
                                                        l_return_status,
                                                        l_stmv_rec.sty_id);
        IF l_stmv_rec.sty_id IS NULL OR l_stmv_rec.sty_id = OKL_API.G_MISS_NUM THEN

            --message logging
            IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_ERROR
                    ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                    ,' OKL_STREAMS_UTIL.get_primary_stream_type returned no values');
            END IF;
            -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++

            OKL_API.set_message(p_app_name      => G_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE1,
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'STY.CODE');
        END IF;

        OPEN get_next_trx_val_csr;
        FETCH get_next_trx_val_csr INTO l_trx_id;
        CLOSE get_next_trx_val_csr;

        -- stream header parameters
        l_stmv_rec.khr_id               := p_khr_id;
        l_stmv_rec.kle_id               := p_kle_id;
        l_stmv_rec.SGN_CODE             := 'MANL';
        l_stmv_rec.SAY_CODE             := 'CURR';
        l_stmv_rec.TRANSACTION_NUMBER   :=  l_trx_id;
        l_stmv_rec.ACTIVE_YN            := 'Y';
        l_stmv_rec.DATE_CURRENT         := SYSDATE;

        -- rmunjulu 3910833 added code to set source_id and source_table
        l_stmv_rec.source_id := p_ia_id;
        l_stmv_rec.source_table := G_SOURCE_TABLE;

        -- stream element parameters
        l_selv_tbl(1).stream_element_date  := p_transaction_date; -- rmunjulu EDAT
        l_selv_tbl(1).amount               := l_disbursement_amount;
        l_selv_tbl(1).ACCRUED_YN           := 'N';
        l_selv_tbl(1).SE_LINE_NUMBER       := 1;

        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                ,'calling OKL_STREAMS_PUB.create_streams ');
        END IF;

        -- create disbursement record
        OKL_STREAMS_PUB.create_streams(
                                 p_api_version    => p_api_version
                                ,p_init_msg_list  => p_init_msg_list
                                ,x_return_status  => l_return_status
                                ,x_msg_count      => x_msg_count
                                ,x_msg_data       => x_msg_data
                                ,p_stmv_rec       => l_stmv_rec
                                ,p_selv_tbl       => l_selv_tbl
                                ,x_stmv_rec       => x_stmv_rec
                                ,x_selv_tbl       => x_selv_tbl  );

        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --message logging
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                ,'returning from OKL_STREAMS_PUB.create_streams, status is '
                ||l_return_status);
        END IF;
    END IF;
    --message logging
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
            ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
            ,'End (-)');
    END IF;

    x_return_status := l_return_status;

    EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                , 'Handled exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                , 'Unexpected exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN


        IF get_next_trx_val_csr%ISOPEN THEN
           CLOSE get_next_trx_val_csr;
        END IF;

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.disburse_investor_rv'
                , 'When others exception occured');
        END IF;

        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END disburse_investor_rv;

/*========================================================================
 | PUBLIC PROCEDURE CREATE_POOL_TRANSACTION
 |
 | DESCRIPTION
 |      Create the pool transaction and makes pool modifications
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Called from PROCESS_SECURITIZED_STREAMS
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_api_version    IN     Standard in parameter
 |      p_init_msg_list  IN     Standard in parameter
 |      x_return_status  OUT    Standard out parameter
 |      x_msg_count      OUT    Standard out parameter
 |      x_msg_data       OUT    Standard out parameter
 |      p_asset_tbl      IN     Contains a list of assets for pool transactions
 |      p_transaction_reason IN Reason required for creating pool transaction
 |      p_kle_id         IN     Asset for pool transaction
 |      p_khr_id         IN     Contract for pool transaction
 |      p_disb_type      IN     Identifies the subclass, RESIDUAL or RENT
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-OCT-2003           MDokal            Created.
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 | 23-Sep-2004           rmunjulu          EDAT Added Parameters to get transaction
 |                                         date and effective date and do processing
 |                                         based on those
 |
 *=======================================================================*/
  PROCEDURE create_pool_transaction(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_asset_tbl			IN  asset_tbl_type,
    p_transaction_reason	IN  VARCHAR2,
    p_khr_id            IN  NUMBER,
    p_kle_id            IN  NUMBER,
    p_effective_date    IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_transaction_date  IN  DATE DEFAULT NULL, -- rmunjulu EDAT
    p_disb_type         IN  VARCHAR2) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_asset_table       asset_tbl_type;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_loop_counter      NUMBER := 1;

  BEGIN
        --message logging
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                ,'Begin (+)');
        END IF;

        IF p_disb_type = 'RESIDUAL' THEN -- RV pool transaction

            l_asset_table(1).p_khr_id := p_khr_id;
            l_asset_table(1).p_kle_id := p_kle_id;
        ELSE
            l_asset_table   := p_asset_tbl; -- Rent pool transaction
        END IF;

        IF p_transaction_reason =
                      OKL_SECURITIZATION_PVT.G_TRX_REASON_EARLY_TERMINATION THEN
            --message logging
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                    ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                    ,'calling OKL_SECURITIZATION_PVT.MODIFY_POOL_CONTENTS'
                    ||' with transaction reason '
                    ||p_transaction_reason);
            END IF;
--start: |  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |
            -- Commenting for bug 6964174
            -- Inactivation of pool contents during early full termination is deferred to
            -- the end of termination transaction. This was done to ensure that pool contents are active
            -- until all accounting transactions like termination billing amounts, termination accounting
            -- transactions are complete and have used special accounting.
            -- Instead of this place, pool contents are inactivated at the end of
            -- OKL_AM_LEASE_TRMNT_PVT.lease_termination API
/*
            OKL_SECURITIZATION_PVT.MODIFY_POOL_CONTENTS
                ( p_api_version        => p_api_version
                 ,p_init_msg_list      => p_init_msg_list
                 ,p_transaction_reason => p_transaction_reason
                 ,p_khr_id             => l_asset_table(l_loop_counter).p_khr_id
                 ,p_stream_type_subclass => p_disb_type
                 ,p_transaction_date   => p_transaction_date   -- rmunjulu EDAT
                 ,p_effective_date     => p_effective_date     -- rmunjulu EDAT
                 ,x_return_status      => l_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data  );

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            --message logging
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                    ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                    ,'returning from  '
                    ||'OKL_SECURITIZATION_PVT.MODIFY_POOL_CONTENTS, status is '
                    ||l_return_status);
            END IF;*/-- end of commenting for bug 6964174
--end: |  05-29-08 cklee -- fixed bug: 7017824(R12)/OKL.H: bug#6964174              |

			-- rmunjulu 4398936 removed the following else and added elseif
        --ELSE -- handle partial termination transactions and residual
             -- transactions by asset

		   -- rmunjulu 4398936 Added this elseif
           ELSIF p_transaction_reason =
                      OKL_SECURITIZATION_PVT.G_TRX_REASON_ASSET_DISPOSAL THEN
           IF g_call_ad_flag THEN

            FOR l_loop_counter IN l_asset_table.FIRST..l_asset_table.LAST LOOP
                IF l_asset_table(l_loop_counter).p_khr_id IS NOT NULL THEN
                    --message logging
                    IF (FND_LOG.LEVEL_STATEMENT >=
                      FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                            ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                            ,'calling OKL_SECURITIZATION_PVT.MODIFY_POOL_'
                            ||'CONTENTS with transaction reason '
                            ||p_transaction_reason);
                    END IF;

                    OKL_SECURITIZATION_PVT.MODIFY_POOL_CONTENTS
                        ( p_api_version        => p_api_version
                         ,p_init_msg_list      => p_init_msg_list
                         ,p_transaction_reason => p_transaction_reason
                         ,p_khr_id   => l_asset_table(l_loop_counter).p_khr_id
                         ,p_kle_id   => l_asset_table(l_loop_counter).p_kle_id
                         ,p_stream_type_subclass => p_disb_type
                         ,p_transaction_date   => p_transaction_date   -- rmunjulu EDAT
                         ,p_effective_date     => p_effective_date     -- rmunjulu EDAT
                         ,x_return_status      => l_return_status
                         ,x_msg_count          => x_msg_count
                         ,x_msg_data           => x_msg_data  );

                    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                    --message logging
                    IF (FND_LOG.LEVEL_STATEMENT >=
                                          FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                            ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                            ,'returning from  OKL_SECURITIZATION_PVT.'
                            ||'MODIFY_POOL_CONTENTS, status is '
                            ||l_return_status);
                    END IF;
                END IF;
            END LOOP;   -- l_asset_table
          END IF;    -- gboomina 07-Dec-05 - Added End if
        END IF;
        --message logging
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                ,'End (-)');
        END IF;

    x_return_status := l_return_status;

    EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                , 'Handled exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                , 'Unexpected exception occured');
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          'proc_secure_streams',
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );

    WHEN OTHERS THEN

        --message logging
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
                ,'OKL_AM_SECURITIZATION_PVT.create_pool_transaction'
                , 'When others exception occured');
        END IF;
        OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END create_pool_transaction;


END OKL_AM_SECURITIZATION_PVT;

/
