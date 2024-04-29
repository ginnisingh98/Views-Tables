--------------------------------------------------------
--  DDL for Package Body OKS_BILLSUBLINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILLSUBLINE_PVT" AS
/* $Header: OKSRBSLB.pls 120.0 2005/05/25 18:02:46 appldev noship $ */

  PROCEDURE insert_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type)

  Is

    l_api_name              CONSTANT VARCHAR2(30) := 'insert_bill_cont_line';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  oks_bsl_pvt.insert_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_bslv_rec                     ,
    x_bslv_rec
  );


  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  End;



  PROCEDURE lock_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'lock_bill_cont_line';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  oks_bsl_pvt.lock_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_bslv_rec
  );

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  End;



  PROCEDURE update_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'update_bill_cont_line';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  oks_bsl_pvt.update_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_bslv_rec                     ,
    x_bslv_rec
  );

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  End;



  PROCEDURE delete_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'delete_bill_cont_line';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  oks_bsl_pvt.delete_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_bslv_rec
  );

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  End;



  PROCEDURE validate_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'validate_bill_cont_line';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  oks_bsl_pvt.validate_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_bslv_rec
  );


  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

  End;

END OKS_BILLSubLINE_PVT;

/
