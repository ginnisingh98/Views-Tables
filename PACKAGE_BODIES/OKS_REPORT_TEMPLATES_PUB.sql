--------------------------------------------------------
--  DDL for Package Body OKS_REPORT_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_REPORT_TEMPLATES_PUB" AS
/* $Header: OKSPRTMB.pls 120.0 2005/05/25 17:39:41 appldev noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    OKS_REPORT_TEMPLATES_PVT.qc;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    OKS_REPORT_TEMPLATES_PVT.change_version;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    OKS_REPORT_TEMPLATES_PVT.api_copy;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKS_TEMPLATE_SET_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                     IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.validate_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_rec           => p_rtmpv_rec );

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

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END validate_row;
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_TEMPLATE_SET_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    l_return_status                VARCHAR2(1);
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.validate_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      px_error_tbl         => px_error_tbl);

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
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END validate_row;

  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_TEMPLATE_SET_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                     IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.validate_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl);

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
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for :OKS_TEMPLATE_SET_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type
     ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.insert_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_rec           => p_rtmpv_rec,
                                      x_rtmpv_rec           => x_rtmpv_rec);


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

     x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:TMSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    l_return_status                VARCHAR2(1);
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.insert_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      x_rtmpv_tbl           => x_rtmpv_tbl,
                                      px_error_tbl         => px_error_tbl);

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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END insert_row;

  ----------------------------------------
  -- PL/SQL TBL insert_row for:TMSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.insert_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      x_rtmpv_tbl           => x_rtmpv_tbl);


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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for: OKS_TEMPLATE_SET_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.lock_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_rec           => p_rtmpv_rec);


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
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:TMSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE
    ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    l_return_status                VARCHAR2(1);
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.lock_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      px_error_tbl         => px_error_tbl);


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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:TMSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.lock_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl);

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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
   ---------------------------------------
  -- update_row for:OKS_TEMPLATE_SET_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    Begin
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.update_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_rec           => p_rtmpv_rec,
                                      x_rtmpv_rec           =>  x_rtmpv_rec);



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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:tmsv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    l_return_status                VARCHAR2(1);
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.update_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      x_rtmpv_tbl           => x_rtmpv_tbl,
                                      px_error_tbl         => px_error_tbl);


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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_row;

  ----------------------------------------
  -- PL/SQL TBL update_row for:TMSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.update_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      x_rtmpv_tbl           => x_rtmpv_tbl);


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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- delete_row for:OKS_TEMPLATE_SET_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.delete_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_rec            => p_rtmpv_rec);



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
    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_row;
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_TEMPLATE_SET_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    l_return_status                VARCHAR2(1);
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.delete_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl,
                                      px_error_tbl         => px_error_tbl);


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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_row;

  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_TEMPLATE_SET_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

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
    OKS_REPORT_TEMPLATES_PVT.delete_row(p_api_version        => l_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      p_rtmpv_tbl           => p_rtmpv_tbl);



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

    x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_row;

END OKS_REPORT_TEMPLATES_PUB;

/
