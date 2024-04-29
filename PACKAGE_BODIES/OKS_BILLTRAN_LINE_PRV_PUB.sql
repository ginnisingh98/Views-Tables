--------------------------------------------------------
--  DDL for Package Body OKS_BILLTRAN_LINE_PRV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILLTRAN_LINE_PRV_PUB" AS
/* $Header: OKSBTLVB.pls 120.0 2005/05/25 18:31:57 appldev noship $ */

  PROCEDURE insert_btl_pr
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                     IN btl_pr_rec_type,
    x_btl_pr_rec                     OUT NOCOPY btl_pr_rec_type
  )

  Is

    l_api_name              CONSTANT VARCHAR2(30) := 'insert_btl_pr';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_btl_pr_rec	    btl_pr_rec_type;

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

  g_btl_pr_rec := p_btl_pr_rec;

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

--Restore ID/OBJECT VERSION NUMBER

  l_btl_pr_rec                        := g_btl_pr_rec;
  l_btl_pr_rec.id	                  := p_btl_pr_rec.id;
  l_btl_pr_rec.object_version_number	:= p_btl_pr_rec.object_version_number;

  OKS_BTL_PRINT_PREVIEW_PVT.insert_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    l_btl_pr_rec                     ,
    x_btl_pr_rec
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  g_btl_pr_rec := x_btl_pr_rec;

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

  End;


  PROCEDURE insert_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                     IN btl_pr_tbl_type,
    x_btl_pr_tbl                     OUT NOCOPY btl_pr_tbl_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'insert_btl_pr';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_btl_pr_tbl.COUNT > 0 Then

          l_ptr := p_btl_pr_tbl.FIRST;

          Loop
            insert_btl_pr
            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_btl_pr_tbl(l_ptr)
                       ,x_btl_pr_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_btl_pr_tbl.LAST);
            l_ptr := p_btl_pr_tbl.NEXT(l_ptr);

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
  End;


  PROCEDURE lock_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                     IN btl_pr_rec_type)
  Is

    l_api_name              CONSTANT VARCHAR2(30) := 'lock_btl_pr';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_btl_pr_rec		             btl_pr_rec_type;

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

  OKS_BTL_PRINT_PREVIEW_PVT.lock_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_btl_pr_rec
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


  PROCEDURE lock_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                     IN btl_pr_tbl_type)

  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'lock_btl_pr';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_btl_pr_tbl.COUNT > 0 Then

          l_ptr := p_btl_pr_tbl.FIRST;

          Loop

            lock_btl_pr
            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_btl_pr_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_btl_pr_tbl.LAST);
            l_ptr := p_btl_pr_tbl.NEXT(l_ptr);

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


  PROCEDURE update_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                     IN btl_pr_rec_type,
    x_btl_pr_rec                     OUT NOCOPY btl_pr_rec_type)
  Is

    l_api_name              CONSTANT VARCHAR2(30) := 'update_btl_pr';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status          VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_btl_pr_rec             btl_pr_rec_type;

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

  g_btl_pr_rec := p_btl_pr_rec;

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

--Restore ID/OBJECT VERSION NUMBER

  l_btl_pr_rec                        := g_btl_pr_rec;
  l_btl_pr_rec.id	                  := p_btl_pr_rec.id;
  l_btl_pr_rec.object_version_number	:= p_btl_pr_rec.object_version_number;

  OKS_BTL_PRINT_PREVIEW_PVT.update_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    l_btl_pr_rec                     ,
    x_btl_pr_rec
  );

  If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  g_btl_pr_rec := x_btl_pr_rec;

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


  PROCEDURE update_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                     IN btl_pr_tbl_type,
    x_btl_pr_tbl                     OUT NOCOPY btl_pr_tbl_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'update_btl_pr';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_btl_pr_tbl.COUNT > 0 Then

          l_ptr := p_btl_pr_tbl.FIRST;

          Loop
            update_btl_pr
            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_btl_pr_tbl(l_ptr)
                       ,x_btl_pr_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_btl_pr_tbl.LAST);
            l_ptr := p_btl_pr_tbl.NEXT(l_ptr);

          End Loop;

  End If;

  Exception
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


  PROCEDURE delete_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                     IN btl_pr_rec_type)
  Is

    l_api_name              CONSTANT VARCHAR2(30) := 'update_btl_pr';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_btl_pr_rec             btl_pr_rec_type;

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

  g_btl_pr_rec := p_btl_pr_rec;

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

--Restore ID/OBJECT VERSION NUMBER

  l_btl_pr_rec                        := g_btl_pr_rec;
  l_btl_pr_rec.id	                  := p_btl_pr_rec.id;
  l_btl_pr_rec.object_version_number	:= p_btl_pr_rec.object_version_number;

  OKS_BTL_PRINT_PREVIEW_PVT.delete_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    l_btl_pr_rec
  );

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


  PROCEDURE delete_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                     IN btl_pr_tbl_type)
  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'delete_btl_pr';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_btl_pr_tbl.COUNT > 0 Then

          l_ptr := p_btl_pr_tbl.FIRST;

          Loop
            delete_btl_pr            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_btl_pr_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_btl_pr_tbl.LAST);
            l_ptr := p_btl_pr_tbl.NEXT(l_ptr);

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


  PROCEDURE validate_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_rec                     IN btl_pr_rec_type)
   Is

    l_api_name              CONSTANT VARCHAR2(30) := 'validate_btl_pr';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_btl_pr_rec	    btl_pr_rec_type;

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

  g_btl_pr_rec := p_btl_pr_rec;

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

--Restore ID/OBJECT VERSION NUMBER

  l_btl_pr_rec                        := g_btl_pr_rec;
  l_btl_pr_rec.id	                  := p_btl_pr_rec.id;
  l_btl_pr_rec.object_version_number	:= p_btl_pr_rec.object_version_number;

  OKS_BTL_PRINT_PREVIEW_PVT.validate_row
  (
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    l_btl_pr_rec
  );

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


  PROCEDURE validate_btl_pr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btl_pr_tbl                     IN btl_pr_tbl_type)

  Is
    l_api_name              CONSTANT VARCHAR2(30) := 'validate_btl_pr';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptr			    BINARY_INTEGER;

  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_btl_pr_tbl.COUNT > 0 Then

          l_ptr := p_btl_pr_tbl.FIRST;

          Loop
            validate_btl_pr            (
                        p_api_version
                       ,p_init_msg_list
                       ,l_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,p_btl_pr_tbl(l_ptr)
            );

            If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
               If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                  x_return_status := l_return_status;
                  Raise G_EXCEPTION_HALT_VALIDATION;
               Else
                  x_return_status := l_return_status;
               End If;
            End If;

            Exit When  (l_ptr = p_btl_pr_tbl.LAST);
            l_ptr := p_btl_pr_tbl.NEXT(l_ptr);

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

END OKS_BILLTran_Line_PRV_PUB;

/
