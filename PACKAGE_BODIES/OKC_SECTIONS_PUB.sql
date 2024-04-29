--------------------------------------------------------
--  DDL for Package Body OKC_SECTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SECTIONS_PUB" AS
/* $Header: OKCPSCNB.pls 120.0 2005/05/25 22:34:55 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_api_type		CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN  scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY  scnv_rec_type) IS

    l_scnv_rec		scnv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_scnv_rec := p_scnv_rec;
    g_scnv_rec := l_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_scnv_rec		:= g_scnv_rec;
    l_scnv_rec.id	:= p_scnv_rec.id;
    l_scnv_rec.object_version_number	:= p_scnv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.create_section(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> l_scnv_rec,
      x_scnv_rec		=> x_scnv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_scnv_rec := x_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END create_section;

  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN  scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY  scnv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_scnv_tbl.COUNT > 0) Then
	   i := p_scnv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_SECTIONS_PUB.create_section(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_scnv_rec		=> p_scnv_tbl(i),
			x_scnv_rec		=> x_scnv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_scnv_tbl.LAST);
		i := p_scnv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END create_section;

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY scnv_rec_type) IS

    l_scnv_rec		scnv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_scnv_rec := p_scnv_rec;
    g_scnv_rec := l_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_scnv_rec		:= g_scnv_rec;
    l_scnv_rec.id	:= p_scnv_rec.id;
    l_scnv_rec.object_version_number	:= p_scnv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.update_section(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_scnv_rec			=> l_scnv_rec,
      x_scnv_rec			=> x_scnv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_scnv_rec := x_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END update_section;

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY scnv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_scnv_tbl.COUNT > 0) Then
	   i := p_scnv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.update_section(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_scnv_rec		=> p_scnv_tbl(i),
			x_scnv_rec		=> x_scnv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_scnv_tbl.LAST);
		i := p_scnv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END update_section;

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_scnv_rec		scnv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_scnv_rec := p_scnv_rec;
    g_scnv_rec := l_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_scnv_rec		:= g_scnv_rec;
    l_scnv_rec.id	:= p_scnv_rec.id;
    l_scnv_rec.object_version_number	:= p_scnv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.delete_section(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> l_scnv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END delete_section;

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_scnv_tbl.COUNT > 0) Then
	   i := p_scnv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.delete_section(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_scnv_rec		=> p_scnv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_scnv_tbl.LAST);
		i := p_scnv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END delete_section;

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_scnv_rec		scnv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_scnv_rec := p_scnv_rec;
    g_scnv_rec := l_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_scnv_rec		:= g_scnv_rec;
    l_scnv_rec.id	:= p_scnv_rec.id;
    l_scnv_rec.object_version_number	:= p_scnv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.lock_section(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> l_scnv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END lock_section;

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_scnv_tbl.COUNT > 0) Then
	   i := p_scnv_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_SECTIONS_PUB.lock_section(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_scnv_rec		=> p_scnv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_scnv_tbl.LAST);
		i := p_scnv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END lock_section;

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN scnv_rec_type) IS

    l_scnv_rec		scnv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_scnv_rec := p_scnv_rec;
    g_scnv_rec := l_scnv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_scnv_rec		:= g_scnv_rec;
    l_scnv_rec.id	:= p_scnv_rec.id;
    l_scnv_rec.object_version_number	:= p_scnv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.validate_section(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> l_scnv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END validate_section;

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN scnv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_SECTION';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_scnv_tbl.COUNT > 0) Then
	   i := p_scnv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.validate_section(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_scnv_rec		=> p_scnv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_scnv_tbl.LAST);
		i := p_scnv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END validate_section;

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN  sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY  sccv_rec_type) IS

    l_sccv_rec		sccv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_sccv_rec := p_sccv_rec;
    g_sccv_rec := l_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_sccv_rec		:= g_sccv_rec;
    l_sccv_rec.id	:= p_sccv_rec.id;
    l_sccv_rec.object_version_number	:= p_sccv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.create_section_content(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> l_sccv_rec,
      x_sccv_rec		=> x_sccv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_sccv_rec := x_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END create_section_content;

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN  sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY  sccv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_sccv_tbl.COUNT > 0) Then
	   i := p_sccv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_SECTIONS_PUB.create_section_content(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_sccv_rec		=> p_sccv_tbl(i),
			x_sccv_rec		=> x_sccv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_sccv_tbl.LAST);
		i := p_sccv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END create_section_content;

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY sccv_rec_type) IS

    l_sccv_rec		sccv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_sccv_rec := p_sccv_rec;
    g_sccv_rec := l_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					 p_package_name	=> g_pkg_name,
  					 p_procedure_name	=> l_api_name,
  					 p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_sccv_rec		:= g_sccv_rec;
    l_sccv_rec.id	:= p_sccv_rec.id;
    l_sccv_rec.object_version_number	:= p_sccv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.update_section_content(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_sccv_rec			=> l_sccv_rec,
      x_sccv_rec			=> x_sccv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_sccv_rec := x_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END update_section_content;

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY sccv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_sccv_tbl.COUNT > 0) Then
	   i := p_sccv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.update_section_content(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_sccv_rec		=> p_sccv_tbl(i),
			x_sccv_rec		=> x_sccv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_sccv_tbl.LAST);
		i := p_sccv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END update_section_content;

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_sccv_rec		sccv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_sccv_rec := p_sccv_rec;
    g_sccv_rec := l_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_sccv_rec		:= g_sccv_rec;
    l_sccv_rec.id	:= p_sccv_rec.id;
    l_sccv_rec.object_version_number	:= p_sccv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.delete_section_content(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> l_sccv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END delete_section_content;

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_sccv_tbl.COUNT > 0) Then
	   i := p_sccv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.delete_section_content(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_sccv_rec		=> p_sccv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_sccv_tbl.LAST);
		i := p_sccv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END delete_section_content;

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_sccv_rec		sccv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_sccv_rec := p_sccv_rec;
    g_sccv_rec := l_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_sccv_rec		:= g_sccv_rec;
    l_sccv_rec.id	:= p_sccv_rec.id;
    l_sccv_rec.object_version_number	:= p_sccv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.lock_section_content(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> l_sccv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END lock_section_content;

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_sccv_tbl.COUNT > 0) Then
	   i := p_sccv_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_SECTIONS_PUB.lock_section_content(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_sccv_rec		=> p_sccv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_sccv_tbl.LAST);
		i := p_sccv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END lock_section_content;

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN sccv_rec_type) IS

    l_sccv_rec		sccv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
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
    l_sccv_rec := p_sccv_rec;
    g_sccv_rec := l_sccv_rec;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'B');

    -- check return status of user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- get values back from user hook call
    l_sccv_rec		:= g_sccv_rec;
    l_sccv_rec.id	:= p_sccv_rec.id;
    l_sccv_rec.object_version_number	:= p_sccv_rec.object_version_number;

    -- call procedure in complex API
    OKC_SECTIONS_PVT.validate_section_content(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> l_sccv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_UTIL.call_user_hook(x_return_status	=> x_return_status,
  					   p_package_name	=> g_pkg_name,
  					   p_procedure_name	=> l_api_name,
  					   p_before_after	=> 'A');

    -- check return status of the user hook call
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END validate_section_content;

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN sccv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_SECTION_CONTENT';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
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

    If (p_sccv_tbl.COUNT > 0) Then
	   i := p_sccv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_SECTIONS_PUB.validate_section_content(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_sccv_rec		=> p_sccv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_sccv_tbl.LAST);
		i := p_sccv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(	x_msg_count		=> x_msg_count,
  						x_msg_data		=> x_msg_data);
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
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
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

  END validate_section_content;

  PROCEDURE add_language IS
    l_api_name		CONSTANT VARCHAR2(30) := 'ADD_LANGUAGE';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call procedure in complex API
    OKC_SECTIONS_PVT.add_language;

  END add_language;

END OKC_SECTIONS_PUB;

/
