--------------------------------------------------------
--  DDL for Package Body OKS_COV_ENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COV_ENT_PUB" AS
/* $Header: OKSPCENB.pls 120.0 2005/05/25 18:04:59 appldev noship $ */


  PROCEDURE Get_default_react_resolve_by
    (p_api_version                in  number
    ,p_init_msg_list              in  varchar2
    ,p_inp_rec                    in  gdrt_inp_rec_type
    ,x_return_status              out nocopy varchar2
    ,x_msg_count                  out nocopy number
    ,x_msg_data                   out nocopy varchar2
    ,x_react_rec                  out nocopy rcn_rsn_rec_type
    ,x_resolve_rec                out nocopy rcn_rsn_rec_type)
    IS

    l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name            CONSTANT VARCHAR2(30) := 'Get_def_reac_resol_by';

    BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKS_COV_ENT_PVT.Get_default_react_resolve_by
                                (p_api_version
                                ,p_init_msg_list
                                ,p_inp_rec
                                ,x_return_status
                                ,x_msg_count
                                ,x_msg_data
                                ,x_react_rec
                                ,x_resolve_rec );

       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);


    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END Get_default_react_resolve_by;

END OKS_COV_ENT_PUB;

/
