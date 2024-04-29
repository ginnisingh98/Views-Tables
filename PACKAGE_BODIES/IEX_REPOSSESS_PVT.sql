--------------------------------------------------------
--  DDL for Package Body IEX_REPOSSESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_REPOSSESS_PVT" AS
/* $Header: iexrrepb.pls 120.6 2008/06/25 21:41:55 ehuh ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE create_repossess_request
  ---------------------------------------------------------------------------

  PROCEDURE create_repossess_request(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_repv_rec                 IN repv_rec_type,
     p_date_repossession_required IN DATE,
     p_date_hold_until          IN DATE,
     p_relocate_asset_yn        IN VARCHAR2,
     x_repv_rec                 OUT NOCOPY repv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

     l_return_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_repossess_request';

     G_REPOS_REQUEST_EXCEPTION EXCEPTION;

     lp_repv_rec                 repv_rec_type;
     lx_repv_rec                 repv_rec_type;

     --record type to create a return request in OKL_ASSET_RETURNS_B
     lp_artv_rec                  okl_am_asset_return_pub.artv_rec_type;
     lx_artv_rec                  okl_am_asset_return_pub.artv_rec_type;


     --BEGIN for bug 4610223 -jsanju 09/14/05
     --Cursor to get the contract line id of the financial asset
/*
 CURSOR l_kle_csr(cp_repossession_id IN IEX_REPOSSESSIONS.REPOSSESSION_ID%TYPE
                     ,cp_asset_id IN OKX_ASSET_LINES_V.ASSET_ID%TYPE) IS
     SELECT  irp.delinquency_id
       ,ico.cas_id
       ,ico.object_id contract_id
       ,alv.asset_id
       ,alv.parent_line_id
     FROM  iex_repossessions irp
     ,iex_delinquencies_all ida
     ,iex_case_objects ico
     ,okx_asset_lines_v alv
    ,okl_cnsld_ar_strms_b stream
     WHERE irp.repossession_id = cp_repossession_id
     AND   irp.delinquency_id = ida.delinquency_id
     and ida.transaction_id =stream.RECEIVABLES_INVOICE_ID
     and stream.khr_id=ico.object_id
     AND   ico.object_id = alv.dnz_chr_id
     AND alv.asset_id = cp_asset_id;

     --END for bug 4610223 -jsanju 09/14/05
 */
     CURSOR l_kle_csr(cp_repossession_id in IEX_REPOSSESSIONS.REPOSSESSION_ID%TYPE
                     ,cp_asset_id in OKX_ASSET_LINES_V.ASSET_ID%TYPE) is
            select alv.parent_line_id from iex_repossessions irp, okx_asset_lines_v alv
             where alv.asset_id = cp_asset_id
               and irp.repossession_id = cp_repossession_id
               and alv.dnz_chr_id = irp.contract_id;

 BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    lp_repv_rec := p_repv_rec;

    FOR cur IN l_kle_csr(lp_repv_rec.repossession_id, lp_repv_rec.asset_id) LOOP
      lp_artv_rec.kle_id := cur.parent_line_id;
      --dbms_output.put_line('kle id : ' || lp_artv_rec.kle_id);
      EXIT;
    END LOOP;

    lp_artv_rec.ars_code := G_ARS_CODE;
    lp_artv_rec.art1_code := G_ART_CODE;
    lp_artv_rec.rna_id := lp_repv_rec.rna_id;
    lp_artv_rec.date_repossession_required := p_date_repossession_required;
    lp_artv_rec.date_repossession_actual := p_date_repossession_required;
    lp_artv_rec.date_hold_until := p_date_hold_until;
    lp_artv_rec.relocate_asset_yn := p_relocate_asset_yn;

    mo_global.set_policy_context('S',7746); -- bug 6911936

    --Insert repossession request into okl_asset_returns_b
    okl_am_asset_return_pub.create_asset_return(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    x_return_status => l_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_artv_rec => lp_artv_rec,
    x_artv_rec => lx_artv_rec);

    IEX_DEBUG_PUB.logMessage('EEEEE === '||l_return_status);


   /*
    IF (l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => G_RET_REQ_ERROR);
        RAISE G_REPOS_REQUEST_EXCEPTION;
    END IF;
   */
    --Update request id
    lp_repv_rec.art_id := lx_artv_rec.id;
    -- Moac Changes. Get the Current org Id. Start.
    -- lp_repv_rec.org_id := fnd_profile.value('ORG_ID');
    lp_repv_rec.org_id := mo_global.get_current_org_id;
    -- Moac Changes. get the current org_id. End.

    --Insert record into iex_repos_objects
    iex_repos_objects_pub.insert_repos_objects(
     p_api_version => p_api_version
    ,p_init_msg_list => p_init_msg_list
    ,x_return_status => l_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
    ,p_repv_rec => lp_repv_rec
    ,x_repv_rec => lx_repv_rec);

    x_repv_rec := lx_repv_rec;

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_repossess_request;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_repossess_request
  ---------------------------------------------------------------------------
  PROCEDURE create_repossess_request(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 ,
     p_repv_tbl                 IN repv_tbl_type,
     p_date_repossession_required IN DATE,
     p_date_hold_until          IN DATE,
     p_relocate_asset_yn        IN VARCHAR2,
     x_repv_tbl                 OUT NOCOPY repv_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'create_repossess_request';

     lp_repv_tbl                 repv_tbl_type;
     lx_repv_tbl                 repv_tbl_type;

     lp_repv_rec                 repv_rec_type;
     lx_repv_rec                 repv_rec_type;

     i                           NUMBER := 0;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    lp_repv_tbl := p_repv_tbl;

    IF (lp_repv_tbl.count > 0) THEN
      i := lp_repv_tbl.first;
      loop
        lp_repv_rec := lp_repv_tbl(i);

        create_repossess_request(
        p_api_version              => p_api_version,
        p_init_msg_list            => p_init_msg_list,
        p_repv_rec                 => lp_repv_rec,
        p_date_repossession_required => p_date_repossession_required,
        p_date_hold_until          => p_date_hold_until,
        p_relocate_asset_yn        => p_relocate_asset_yn,
        x_repv_rec                 => lx_repv_rec,
        x_return_status            => l_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data);

        IF (l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
          exit;
        END IF;

        i := lp_repv_tbl.next(i);
        exit when i IS NULL;
      end loop;

      IF (l_return_status = okl_api.G_RET_STS_SUCCESS) THEN
        commit;
      END IF;
    END IF;

    -- Processing ends

    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END create_repossess_request;

END IEX_REPOSSESS_PVT;

/
