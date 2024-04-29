--------------------------------------------------------
--  DDL for Package Body OKL_ACTIVATE_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACTIVATE_ASSET_PUB" As
/* $Header: OKLPACAB.pls 115.5 2004/04/13 10:26:16 rnaik noship $ */
G_PKG_NAME                 VARCHAR2(100) := 'OKL_ACTIVATE_ASSET_PUB';
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : ACTIVATE_ASSET
--Description    : Selects the 'CFA' - Create Asset Transaction from a ready to be
--                 Booked Contract which has passed Approval
--                 and created assets in FA
--
--History        :
--                 03-Nov-2001  avsingh Created
-- Notes         :
--      IN Parameters -
--                     p_chr_id    - contract id to be activated
--                     p_call_mode - 'BOOK' for booking
--                                   'REBOOK' for rebooking
--                                   'RELEASE' for release
--                    x_cimv_tbl   - OKC line source table showing
--                                   fa links in ID1 , ID2 columns
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE ACTIVATE_ASSET(p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_chrv_id       IN  NUMBER,
                         p_call_mode     IN  VARCHAR2,
                         x_cimv_tbl      OUT NOCOPY cimv_tbl_type) IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'ACTIVATE_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PUB'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Customer pre-processing Section

    --Vertical Industry pre-processing Section

    --call process api
    OKL_ACTIVATE_ASSET_PVT.ACTIVATE_ASSET(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_chrv_id       => p_chrv_id,
                                          p_call_mode     => p_call_mode,
                                          x_cimv_tbl      => x_cimv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post-processing Section

    --Custom post-processing Section

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
END ACTIVATE_ASSET;
--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name :  REBOOK_ASSET (Activate code branch for rebook)
--Description    :  Will be called from activate asset and make rebook adjustments
--                  in FA
--History        :
--                 21-Mar-2002  ashish.singh Created
-- Notes         :
--      IN Parameters -
--                     p_rbk_chr_id    - contract id of rebook copied contract
--
--                     This APi should be called after syncronization of copied k
--                     to the original (being re-booked ) K
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE REBOOK_ASSET  (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rbk_chr_id    IN  NUMBER) IS

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'REBOOK_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PUB'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Customer pre-processing Section

    --Vertical Industry pre-processing Section

    --call process api
    OKL_ACTIVATE_ASSET_PVT.REBOOK_ASSET(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_rbk_chr_id    => p_rbk_chr_id
                                        );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post-processing Section

    --Custom post-processing Section

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
END REBOOK_ASSET;
PROCEDURE RELEASE_ASSET (p_api_version   IN  NUMBER,
                         p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2,
                         p_rel_chr_id    IN  NUMBER) is
l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'RELEASE_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PUB'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Customer pre-processing Section

    --Vertical Industry pre-processing Section

    --call process api
    OKL_ACTIVATE_ASSET_PVT.RELEASE_ASSET(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_rel_chr_id    => p_rel_chr_id
                                        );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post-processing Section

    --Custom post-processing Section

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PUB');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PUB');
END RELEASE_ASSET;
END OKL_ACTIVATE_ASSET_PUB;

/
