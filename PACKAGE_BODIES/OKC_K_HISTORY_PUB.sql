--------------------------------------------------------
--  DDL for Package Body OKC_K_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_HISTORY_PUB" AS
/* $Header: OKCPHSTB.pls 120.0 2005/05/25 19:38:39 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_api_type            CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN  hstv_rec_type,
    x_hstv_rec                     OUT NOCOPY  hstv_rec_type) IS

    l_hstv_rec          hstv_rec_type;
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_hstv_rec := p_hstv_rec;
    g_hstv_rec := l_hstv_rec;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                         p_package_name => g_pkg_name,
                                         p_procedure_name       => l_api_name,
                                         p_before_after => 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_hstv_rec          := g_hstv_rec;
    l_hstv_rec.id       := p_hstv_rec.id;
    l_hstv_rec.object_version_number    := p_hstv_rec.object_version_number;

    -- call procedure in complex API
    OKC_K_HISTORY_PVT.create_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_rec                => l_hstv_rec,
      x_hstv_rec                => x_hstv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_hstv_rec := x_hstv_rec;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                         p_package_name => g_pkg_name,
                                         p_procedure_name       => l_api_name,
                                         p_before_after => 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END create_k_history;

  PROCEDURE create_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN  hstv_tbl_type,
    x_hstv_tbl                     OUT NOCOPY  hstv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)                  := OKC_API.G_RET_STS_SUCCESS;
    i                   NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If (p_hstv_tbl.COUNT > 0) Then
           i := p_hstv_tbl.FIRST;
           LOOP
                -- call procedure in public API for a record
                OKC_K_HISTORY_PVT.create_k_history(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_hstv_rec              => p_hstv_tbl(i),
                        x_hstv_rec              => x_hstv_tbl(i));

                -- store the highest degree of error
                If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;
        EXIT WHEN (i = p_hstv_tbl.LAST);
                i := p_hstv_tbl.NEXT(i);
           END LOOP;
           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END create_k_history;


  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type) IS

    l_hstv_rec          hstv_rec_type;
    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_hstv_rec := p_hstv_rec;
    g_hstv_rec := l_hstv_rec;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                           p_package_name       => g_pkg_name,
                                           p_procedure_name     => l_api_name,
                                           p_before_after       => 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_hstv_rec          := g_hstv_rec;
    l_hstv_rec.id       := p_hstv_rec.id;
    l_hstv_rec.object_version_number    := p_hstv_rec.object_version_number;

    -- call procedure in complex API
    OKC_K_HISTORY_PVT.delete_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_rec                => l_hstv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                           p_package_name       => g_pkg_name,
                                           p_procedure_name     => l_api_name,
                                           p_before_after       => 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END delete_k_history;

  PROCEDURE delete_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)                  := OKC_API.G_RET_STS_SUCCESS;
    i                   NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If (p_hstv_tbl.COUNT > 0) Then
           i := p_hstv_tbl.FIRST;
           LOOP
                -- call procedure in complex API
                OKC_K_HISTORY_PVT.delete_k_history(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_hstv_rec              => p_hstv_tbl(i));

                -- store the highest degree of error
                If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;
        EXIT WHEN (i = p_hstv_tbl.LAST);
                i := p_hstv_tbl.NEXT(i);
           END LOOP;
           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END delete_k_history;

 PROCEDURE delete_all_rows(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_ALL_ROWS';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call procedure in complex API
    OKC_K_HISTORY_PVT.delete_all_rows(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_chr_id                => p_chr_id);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END delete_all_rows;

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_rec                     IN hstv_rec_type) IS

    l_hstv_rec          hstv_rec_type;
    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_hstv_rec := p_hstv_rec;
    g_hstv_rec := l_hstv_rec;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                           p_package_name       => g_pkg_name,
                                           p_procedure_name     => l_api_name,
                                           p_before_after       => 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_hstv_rec          := g_hstv_rec;
    l_hstv_rec.id       := p_hstv_rec.id;
    l_hstv_rec.object_version_number    := p_hstv_rec.object_version_number;

    -- call procedure in complex API
    OKC_K_HISTORY_PVT.validate_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_hstv_rec                => l_hstv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status     => x_return_status,
                                           p_package_name       => g_pkg_name,
                                           p_procedure_name     => l_api_name,
                                           p_before_after       => 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END validate_k_history;

  PROCEDURE validate_k_history(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hstv_tbl                     IN hstv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_K_HISTORY';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)                  := OKC_API.G_RET_STS_SUCCESS;
    i                   NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    If (p_hstv_tbl.COUNT > 0) Then
           i := p_hstv_tbl.FIRST;
           LOOP
                -- call procedure in complex API
                OKC_K_HISTORY_PVT.validate_k_history(
                        p_api_version           => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_hstv_rec              => p_hstv_tbl(i));

                -- store the highest degree of error
                If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
                   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                         l_overall_status := x_return_status;
                   End If;
                End If;
        EXIT WHEN (i = p_hstv_tbl.LAST);
                i := p_hstv_tbl.NEXT(i);
           END LOOP;
           -- return overall status
           x_return_status := l_overall_status;
    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(       x_msg_count             => x_msg_count,
                                                x_msg_data              => x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  =>
'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

  END validate_k_history;

  PROCEDURE add_language IS
    l_api_name          CONSTANT VARCHAR2(30) := 'ADD_LANGUAGE';
    l_api_version       CONSTANT NUMBER   := 1.0;
    l_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1)               := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call procedure in complex API
    OKC_K_HISTORY_PVT.add_language;

  END add_language;

END OKC_K_HISTORY_PUB;

/
