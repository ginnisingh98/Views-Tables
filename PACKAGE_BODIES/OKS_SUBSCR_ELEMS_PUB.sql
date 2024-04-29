--------------------------------------------------------
--  DDL for Package Body OKS_SUBSCR_ELEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SUBSCR_ELEMS_PUB" AS
/* $Header: OKSPELEB.pls 120.0 2005/05/25 18:37:59 appldev noship $ */

  PROCEDURE qc IS
  BEGIN
    OKS_SUBSCR_ELEMS_PVT.qc;
  END qc;

  PROCEDURE change_version IS
  BEGIN
    OKS_SUBSCR_ELEMS_PVT.change_version;
  END change_version;

  PROCEDURE api_copy IS
  BEGIN
    OKS_SUBSCR_ELEMS_PVT.api_copy;
  END api_copy;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_rec                     IN scev_rec_type,
    x_scev_rec                     OUT NOCOPY scev_rec_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKS_SUBSCR_ELEMS_PVT.insert_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_rec         => p_scev_rec,
                                x_scev_rec         => x_scev_rec);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    End insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    x_scev_tbl                     OUT NOCOPY scev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    Begin
    l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;
  OKS_SUBSCR_ELEMS_PVT.insert_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_tbl         => p_scev_tbl,
                                x_scev_tbl         => x_scev_tbl,
                                px_error_tbl       => px_error_tbl);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    x_scev_tbl                     OUT NOCOPY scev_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_scev_tbl.COUNT > 0 Then

          l_ptr := p_scev_tbl.FIRST;

          Loop
            insert_row
            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_scev_tbl(l_ptr)
                       ,x_scev_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_scev_tbl.LAST);
            l_ptr := p_scev_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
  When G_EXCEPTION_HALT_VALIDATION Then
       Null;
  When OTHERS Then
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm
                          );
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    End insert_row;

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_rec                     IN scev_rec_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;


  Begin

  l_return_status := OKC_API.START_ACTIVITY
                     (
		         l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;
  OKS_SUBSCR_ELEMS_PVT.lock_row(
                                p_api_version ,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data ,
                                p_scev_rec);


  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End lock_row;

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
		         l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;
  OKS_SUBSCR_ELEMS_PVT.lock_row(
                                p_api_version ,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data ,
                                p_scev_tbl,
                                px_error_tbl);


  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End lock_row;

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_scev_tbl.COUNT > 0 Then

          l_ptr := p_scev_tbl.FIRST;

          Loop
            OKS_SUBSCR_ELEMS_PVT.lock_row(
                                p_api_version     ,
                                p_init_msg_list   ,
                                x_return_status   ,
                                x_msg_count       ,
                                x_msg_data        ,
                                p_scev_tbl(l_ptr) );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_scev_tbl.LAST);
            l_ptr := p_scev_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End lock_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_rec                     IN scev_rec_type,
    x_scev_rec                     OUT NOCOPY scev_rec_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKS_SUBSCR_ELEMS_PVT.update_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_rec         => p_scev_rec,
                                x_scev_rec         => x_scev_rec);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End update_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    x_scev_tbl                     OUT NOCOPY scev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKS_SUBSCR_ELEMS_PVT.update_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_tbl         => p_scev_tbl,
                                x_scev_tbl         => x_scev_tbl,
                                px_error_tbl       => px_error_tbl);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );


    End update_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    x_scev_tbl                     OUT NOCOPY scev_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_scev_tbl.COUNT > 0 Then

          l_ptr := p_scev_tbl.FIRST;

          Loop
            OKS_SUBSCR_ELEMS_PVT.update_row(
                                p_api_version     ,
                                p_init_msg_list   ,
                                x_return_status   ,
                                x_msg_count       ,
                                x_msg_data        ,
                                p_scev_tbl(l_ptr) ,
                                x_scev_tbl(l_ptr));

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_scev_tbl.LAST);
            l_ptr := p_scev_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End update_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_rec                     IN scev_rec_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKS_SUBSCR_ELEMS_PVT.delete_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_rec         => p_scev_rec);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    End delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

    Begin
  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKS_SUBSCR_ELEMS_PVT.delete_row(
                                p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_scev_tbl         => p_scev_tbl,
                                px_error_tbl       => px_error_tbl);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;


  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type) IS


    l_api_name              CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_scev_tbl.COUNT > 0 Then

          l_ptr := p_scev_tbl.FIRST;

          Loop
            OKS_SUBSCR_ELEMS_PVT.delete_row(
                                p_api_version     ,
                                p_init_msg_list   ,
                                x_return_status   ,
                                x_msg_count       ,
                                x_msg_data        ,
                                p_scev_tbl(l_ptr));

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_scev_tbl.LAST);
            l_ptr := p_scev_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End delete_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_rec                     IN scev_rec_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  Begin

  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;



  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

    OKS_SUBSCR_ELEMS_PVT.validate_row(
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_scev_rec);


  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  Begin

  l_return_status := OKC_API.START_ACTIVITY
                     (
				l_api_name
                        ,p_init_msg_list
                        ,'_PUB'
                        ,x_return_status
                     );

  If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
  End If;



  OKC_UTIL.call_user_hook
  (
		x_return_status	=> x_return_status,
  		p_package_name	=> g_pkg_name,
  		p_procedure_name	=> l_api_name,
  		p_before_after	=> 'B'
  );

  If    (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       raise OKC_API.G_EXCEPTION_ERROR;
  End If;

    OKS_SUBSCR_ELEMS_PVT.validate_row(
                                p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_scev_tbl,
                                px_error_tbl);

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_UTIL.call_user_hook
  (
	x_return_status	=> x_return_status,
  	p_package_name	=> g_pkg_name,
  	p_procedure_name	=> l_api_name,
  	p_before_after	=> 'A'
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  OKC_API.END_ACTIVITY
  (
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
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
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    End validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scev_tbl                     IN scev_tbl_type) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'validate_row';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_scev_tbl.COUNT > 0 Then

          l_ptr := p_scev_tbl.FIRST;

          Loop
            validate_row(
                p_api_version ,
                p_init_msg_list,
                x_return_status,
                x_msg_count,
                x_msg_data,
                p_scev_tbl(l_ptr));

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_scev_tbl.LAST);
            l_ptr := p_scev_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
  When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

  When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );


    End validate_row;

END OKS_SUBSCR_ELEMS_PUB;

/