--------------------------------------------------------
--  DDL for Package Body OKC_OPER_INST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OPER_INST_PUB" AS
/* $Header: OKCPCOPB.pls 120.0 2005/05/25 22:49:09 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_api_type		CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE Create_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN  copv_rec_type,
    x_copv_rec                     OUT NOCOPY  copv_rec_type) IS

    l_copv_rec		copv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_copv_rec := p_copv_rec;
    g_copv_rec := l_copv_rec;

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
    l_copv_rec		:= g_copv_rec;
    l_copv_rec.id	:= p_copv_rec.id;
    l_copv_rec.object_version_number	:= p_copv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Create_Class_Operation(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> l_copv_rec,
      x_copv_rec		=> x_copv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_copv_rec := x_copv_rec;

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

  END Create_Class_Operation;

  PROCEDURE Create_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN  copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY  copv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_copv_tbl.COUNT > 0) Then
	   i := p_copv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_OPER_INST_PUB.Create_Class_Operation(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_copv_rec		=> p_copv_tbl(i),
			x_copv_rec		=> x_copv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_copv_tbl.LAST);
		i := p_copv_tbl.NEXT(i);
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

  END Create_Class_Operation;

  PROCEDURE Update_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type,
    x_copv_rec                     OUT NOCOPY copv_rec_type) IS

    l_copv_rec		copv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_copv_rec := p_copv_rec;
    g_copv_rec := l_copv_rec;

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
    l_copv_rec		:= g_copv_rec;
    l_copv_rec.id	:= p_copv_rec.id;
    l_copv_rec.object_version_number	:= p_copv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Update_Class_Operation(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_copv_rec			=> l_copv_rec,
      x_copv_rec			=> x_copv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_copv_rec := x_copv_rec;

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

  END Update_Class_Operation;

  PROCEDURE Update_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type,
    x_copv_tbl                     OUT NOCOPY copv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_copv_tbl.COUNT > 0) Then
	   i := p_copv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Update_Class_Operation(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_copv_rec		=> p_copv_tbl(i),
			x_copv_rec		=> x_copv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_copv_tbl.LAST);
		i := p_copv_tbl.NEXT(i);
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

  END Update_Class_Operation;

  PROCEDURE Delete_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type) IS

    l_copv_rec		copv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_copv_rec := p_copv_rec;
    g_copv_rec := l_copv_rec;

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
    l_copv_rec		:= g_copv_rec;
    l_copv_rec.id	:= p_copv_rec.id;
    l_copv_rec.object_version_number	:= p_copv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Delete_Class_Operation(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> l_copv_rec);

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

  END Delete_Class_Operation;

  PROCEDURE Delete_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_copv_tbl.COUNT > 0) Then
	   i := p_copv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Delete_Class_Operation(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_copv_rec		=> p_copv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_copv_tbl.LAST);
		i := p_copv_tbl.NEXT(i);
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

  END Delete_Class_Operation;

  PROCEDURE Lock_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type) IS

    l_copv_rec		copv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_copv_rec := p_copv_rec;
    g_copv_rec := l_copv_rec;

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
    l_copv_rec		:= g_copv_rec;
    l_copv_rec.id	:= p_copv_rec.id;
    l_copv_rec.object_version_number	:= p_copv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Lock_Class_Operation(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> l_copv_rec);

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

  END Lock_Class_Operation;

  PROCEDURE Lock_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_copv_tbl.COUNT > 0) Then
	   i := p_copv_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_OPER_INST_PUB.Lock_Class_Operation(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_copv_rec		=> p_copv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_copv_tbl.LAST);
		i := p_copv_tbl.NEXT(i);
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

  END Lock_Class_Operation;

  PROCEDURE Validate_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                     IN copv_rec_type) IS

    l_copv_rec		copv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_copv_rec := p_copv_rec;
    g_copv_rec := l_copv_rec;

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
    l_copv_rec		:= g_copv_rec;
    l_copv_rec.id	:= p_copv_rec.id;
    l_copv_rec.object_version_number	:= p_copv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Validate_Class_Operation(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_copv_rec		=> l_copv_rec);

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

  END Validate_Class_Operation;

  PROCEDURE Validate_Class_Operation(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                     IN copv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Class_Operation';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_copv_tbl.COUNT > 0) Then
	   i := p_copv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Validate_Class_Operation(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_copv_rec		=> p_copv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_copv_tbl.LAST);
		i := p_copv_tbl.NEXT(i);
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

  END Validate_Class_Operation;

  PROCEDURE Create_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN  oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY  oiev_rec_type) IS

    l_oiev_rec		oiev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_oiev_rec := p_oiev_rec;
    g_oiev_rec := l_oiev_rec;

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
    l_oiev_rec		:= g_oiev_rec;
    l_oiev_rec.id	:= p_oiev_rec.id;
    l_oiev_rec.object_version_number	:= p_oiev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Create_Operation_Instance(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> l_oiev_rec,
      x_oiev_rec		=> x_oiev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_oiev_rec := x_oiev_rec;

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

  END Create_Operation_Instance;

  PROCEDURE Create_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN  oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY  oiev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_oiev_tbl.COUNT > 0) Then
	   i := p_oiev_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_OPER_INST_PUB.Create_Operation_Instance(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_oiev_rec		=> p_oiev_tbl(i),
			x_oiev_rec		=> x_oiev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_oiev_tbl.LAST);
		i := p_oiev_tbl.NEXT(i);
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

  END Create_Operation_Instance;

  PROCEDURE Update_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type,
    x_oiev_rec                     OUT NOCOPY oiev_rec_type) IS

    l_oiev_rec		oiev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_oiev_rec := p_oiev_rec;
    g_oiev_rec := l_oiev_rec;

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
    l_oiev_rec		:= g_oiev_rec;
    l_oiev_rec.id	:= p_oiev_rec.id;
    l_oiev_rec.object_version_number	:= p_oiev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Update_Operation_Instance(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_oiev_rec			=> l_oiev_rec,
      x_oiev_rec			=> x_oiev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_oiev_rec := x_oiev_rec;

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

  END Update_Operation_Instance;

  PROCEDURE Update_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type,
    x_oiev_tbl                     OUT NOCOPY oiev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_oiev_tbl.COUNT > 0) Then
	   i := p_oiev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Update_Operation_Instance(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_oiev_rec		=> p_oiev_tbl(i),
			x_oiev_rec		=> x_oiev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_oiev_tbl.LAST);
		i := p_oiev_tbl.NEXT(i);
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

  END Update_Operation_Instance;

  PROCEDURE Delete_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type) IS

    l_oiev_rec		oiev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_oiev_rec := p_oiev_rec;
    g_oiev_rec := l_oiev_rec;

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
    l_oiev_rec		:= g_oiev_rec;
    l_oiev_rec.id	:= p_oiev_rec.id;
    l_oiev_rec.object_version_number	:= p_oiev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Delete_Operation_Instance(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> l_oiev_rec);

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

  END Delete_Operation_Instance;

  PROCEDURE Delete_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_oiev_tbl.COUNT > 0) Then
	   i := p_oiev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Delete_Operation_Instance(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_oiev_rec		=> p_oiev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_oiev_tbl.LAST);
		i := p_oiev_tbl.NEXT(i);
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

  END Delete_Operation_Instance;

  PROCEDURE Lock_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type) IS

    l_oiev_rec		oiev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_oiev_rec := p_oiev_rec;
    g_oiev_rec := l_oiev_rec;

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
    l_oiev_rec		:= g_oiev_rec;
    l_oiev_rec.id	:= p_oiev_rec.id;
    l_oiev_rec.object_version_number	:= p_oiev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Lock_Operation_Instance(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> l_oiev_rec);

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

  END Lock_Operation_Instance;

  PROCEDURE Lock_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_oiev_tbl.COUNT > 0) Then
	   i := p_oiev_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_OPER_INST_PUB.Lock_Operation_Instance(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_oiev_rec		=> p_oiev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_oiev_tbl.LAST);
		i := p_oiev_tbl.NEXT(i);
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

  END Lock_Operation_Instance;

  PROCEDURE Validate_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                     IN oiev_rec_type) IS

    l_oiev_rec		oiev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_oiev_rec := p_oiev_rec;
    g_oiev_rec := l_oiev_rec;

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
    l_oiev_rec		:= g_oiev_rec;
    l_oiev_rec.id	:= p_oiev_rec.id;
    l_oiev_rec.object_version_number	:= p_oiev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Validate_Operation_Instance(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> l_oiev_rec);

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

  END Validate_Operation_Instance;

  PROCEDURE Validate_Operation_Instance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                     IN oiev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Operation_Instance';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_oiev_tbl.COUNT > 0) Then
	   i := p_oiev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Validate_Operation_Instance(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_oiev_rec		=> p_oiev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_oiev_tbl.LAST);
		i := p_oiev_tbl.NEXT(i);
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

  END Validate_Operation_Instance;

  PROCEDURE Create_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN  olev_rec_type,
    x_olev_rec                     OUT NOCOPY  olev_rec_type) IS

    l_olev_rec		olev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_olev_rec := p_olev_rec;
    g_olev_rec := l_olev_rec;

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
    l_olev_rec		:= g_olev_rec;
    l_olev_rec.id	:= p_olev_rec.id;
    l_olev_rec.object_version_number	:= p_olev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Create_Operation_Line(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> l_olev_rec,
      x_olev_rec		=> x_olev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_olev_rec := x_olev_rec;

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

  END Create_Operation_Line;

  PROCEDURE Create_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN  olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY  olev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_olev_tbl.COUNT > 0) Then
	   i := p_olev_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_OPER_INST_PUB.Create_Operation_Line(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_olev_rec		=> p_olev_tbl(i),
			x_olev_rec		=> x_olev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_olev_tbl.LAST);
		i := p_olev_tbl.NEXT(i);
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

  END Create_Operation_Line;

  PROCEDURE Update_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type,
    x_olev_rec                     OUT NOCOPY olev_rec_type) IS

    l_olev_rec		olev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_olev_rec := p_olev_rec;
    g_olev_rec := l_olev_rec;

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
    l_olev_rec		:= g_olev_rec;
    l_olev_rec.id	:= p_olev_rec.id;
    l_olev_rec.object_version_number	:= p_olev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Update_Operation_Line(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_olev_rec			=> l_olev_rec,
      x_olev_rec			=> x_olev_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_olev_rec := x_olev_rec;

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

  END Update_Operation_Line;

  PROCEDURE Update_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type,
    x_olev_tbl                     OUT NOCOPY olev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_olev_tbl.COUNT > 0) Then
	   i := p_olev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Update_Operation_Line(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_olev_rec		=> p_olev_tbl(i),
			x_olev_rec		=> x_olev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_olev_tbl.LAST);
		i := p_olev_tbl.NEXT(i);
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

  END Update_Operation_Line;

  PROCEDURE Delete_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type) IS

    l_olev_rec		olev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_olev_rec := p_olev_rec;
    g_olev_rec := l_olev_rec;

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
    l_olev_rec		:= g_olev_rec;
    l_olev_rec.id	:= p_olev_rec.id;
    l_olev_rec.object_version_number	:= p_olev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Delete_Operation_Line(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> l_olev_rec);

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

  END Delete_Operation_Line;

  PROCEDURE Delete_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_olev_tbl.COUNT > 0) Then
	   i := p_olev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Delete_Operation_Line(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_olev_rec		=> p_olev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_olev_tbl.LAST);
		i := p_olev_tbl.NEXT(i);
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

  END Delete_Operation_Line;

  PROCEDURE Lock_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type) IS

    l_olev_rec		olev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_olev_rec := p_olev_rec;
    g_olev_rec := l_olev_rec;

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
    l_olev_rec		:= g_olev_rec;
    l_olev_rec.id	:= p_olev_rec.id;
    l_olev_rec.object_version_number	:= p_olev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Lock_Operation_Line(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> l_olev_rec);

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

  END Lock_Operation_Line;

  PROCEDURE Lock_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_olev_tbl.COUNT > 0) Then
	   i := p_olev_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_OPER_INST_PUB.Lock_Operation_Line(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_olev_rec		=> p_olev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_olev_tbl.LAST);
		i := p_olev_tbl.NEXT(i);
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

  END Lock_Operation_Line;

  PROCEDURE Validate_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                     IN olev_rec_type) IS

    l_olev_rec		olev_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_olev_rec := p_olev_rec;
    g_olev_rec := l_olev_rec;

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
    l_olev_rec		:= g_olev_rec;
    l_olev_rec.id	:= p_olev_rec.id;
    l_olev_rec.object_version_number	:= p_olev_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Validate_Operation_Line(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_olev_rec		=> l_olev_rec);

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

  END Validate_Operation_Line;

  PROCEDURE Validate_Operation_Line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                     IN olev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Operation_Line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_olev_tbl.COUNT > 0) Then
	   i := p_olev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Validate_Operation_Line(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_olev_rec		=> p_olev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_olev_tbl.LAST);
		i := p_olev_tbl.NEXT(i);
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

  END Validate_Operation_Line;

  PROCEDURE Create_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN  mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY  mrdv_rec_type) IS

    l_mrdv_rec		mrdv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_mrdv_rec := p_mrdv_rec;
    g_mrdv_rec := l_mrdv_rec;

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
    l_mrdv_rec		:= g_mrdv_rec;
    l_mrdv_rec.id	:= p_mrdv_rec.id;
    l_mrdv_rec.object_version_number	:= p_mrdv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Create_Masschange_Dtls(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> l_mrdv_rec,
      x_mrdv_rec	=> x_mrdv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_mrdv_rec := x_mrdv_rec;

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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Create_Masschange_Dtls;

  PROCEDURE Create_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN  mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY  mrdv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Create_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_mrdv_tbl.COUNT > 0) Then
	   i := p_mrdv_tbl.FIRST;
	   LOOP
		-- call procedure in public API for a record
		OKC_OPER_INST_PUB.Create_Masschange_Dtls(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_mrdv_rec		=> p_mrdv_tbl(i),
			x_mrdv_rec		=> x_mrdv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
		      l_overall_status := x_return_status;
		   End If;
		End If;
                EXIT WHEN (i = p_mrdv_tbl.LAST);
		i := p_mrdv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Create_Masschange_Dtls;

  PROCEDURE Update_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY mrdv_rec_type) IS

    l_mrdv_rec		mrdv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_mrdv_rec := p_mrdv_rec;
    g_mrdv_rec := l_mrdv_rec;

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
    l_mrdv_rec		:= g_mrdv_rec;
    l_mrdv_rec.id	:= p_mrdv_rec.id;
    l_mrdv_rec.object_version_number	:= p_mrdv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Update_Masschange_Dtls(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_mrdv_rec		=> l_mrdv_rec,
      x_mrdv_rec		=> x_mrdv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- call AFTER user hook
    g_mrdv_rec := x_mrdv_rec;

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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Update_Masschange_Dtls;

  PROCEDURE Update_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY mrdv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Update_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_mrdv_tbl.COUNT > 0) Then
	   i := p_mrdv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Update_Masschange_Dtls(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_mrdv_rec		=> p_mrdv_tbl(i),
			x_mrdv_rec		=> x_mrdv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
		      l_overall_status := x_return_status;
		   End If;
		End If;
                EXIT WHEN (i = p_mrdv_tbl.LAST);
		i := p_mrdv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Update_Masschange_Dtls;

  PROCEDURE Delete_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_mrdv_rec		mrdv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_mrdv_rec := p_mrdv_rec;
    g_mrdv_rec := l_mrdv_rec;

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
    l_mrdv_rec		:= g_mrdv_rec;
    l_mrdv_rec.id	:= p_mrdv_rec.id;
    l_mrdv_rec.object_version_number	:= p_mrdv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Delete_Masschange_Dtls(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> l_mrdv_rec);

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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Delete_Masschange_Dtls;

  PROCEDURE Delete_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Delete_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_mrdv_tbl.COUNT > 0) Then
	   i := p_mrdv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Delete_Masschange_Dtls(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_mrdv_rec		=> p_mrdv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
                EXIT WHEN (i = p_mrdv_tbl.LAST);
		i := p_mrdv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Delete_Masschange_Dtls;

  PROCEDURE Lock_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_mrdv_rec		mrdv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_mrdv_rec := p_mrdv_rec;
    g_mrdv_rec := l_mrdv_rec;

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
    l_mrdv_rec		:= g_mrdv_rec;
    l_mrdv_rec.id	:= p_mrdv_rec.id;
    l_mrdv_rec.object_version_number	:= p_mrdv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Lock_Masschange_Dtls(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> l_mrdv_rec);

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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Lock_Masschange_Dtls;

  PROCEDURE Lock_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Lock_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_mrdv_tbl.COUNT > 0) Then
	   i := p_mrdv_tbl.FIRST;
	   LOOP
    		-- call procedure in complex API
    		OKC_OPER_INST_PUB.Lock_Masschange_Dtls(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_mrdv_rec		=> p_mrdv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
                EXIT WHEN (i = p_mrdv_tbl.LAST);
		i := p_mrdv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Lock_Masschange_Dtls;

  PROCEDURE Validate_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_mrdv_rec		mrdv_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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
    l_mrdv_rec := p_mrdv_rec;
    g_mrdv_rec := l_mrdv_rec;

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
    l_mrdv_rec		:= g_mrdv_rec;
    l_mrdv_rec.id	:= p_mrdv_rec.id;
    l_mrdv_rec.object_version_number	:= p_mrdv_rec.object_version_number;

    -- call procedure in complex API
    OKC_OPER_INST_PVT.Validate_Masschange_Dtls(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_mrdv_rec	=> l_mrdv_rec);

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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Validate_Masschange_Dtls;

  PROCEDURE Validate_Masschange_Dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'Validate_Masschange_Dtls';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to Create savepoint, check compatibility
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

    If (p_mrdv_tbl.COUNT > 0) Then
	   i := p_mrdv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKC_OPER_INST_PUB.Validate_Masschange_Dtls(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_mrdv_rec		=> p_mrdv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        	EXIT WHEN (i = p_mrdv_tbl.LAST);
		i := p_mrdv_tbl.NEXT(i);
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
    OKC_API.END_ACTIVITY(x_msg_count		=> x_msg_count,
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

  END Validate_Masschange_Dtls;
END OKC_OPER_INST_PUB;

/
