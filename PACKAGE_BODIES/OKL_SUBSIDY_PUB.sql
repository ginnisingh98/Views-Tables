--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_PUB" AS
/* $Header: OKLPSUBB.pls 115.0 2003/09/19 22:43:47 avsingh noship $ */


PROCEDURE create_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN  subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_rec          subv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_rec := p_subv_rec;

    okl_subsidy_pvt.create_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_rec		    => l_subv_rec,
	 x_subv_rec		    => x_subv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END create_subsidy;



PROCEDURE create_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN  subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_tbl          subv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_tbl := p_subv_tbl;

    okl_subsidy_pvt.create_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_tbl		    => l_subv_tbl,
	 x_subv_tbl		    => x_subv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END create_subsidy;


PROCEDURE update_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN  subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_rec          subv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_rec := p_subv_rec;

    okl_subsidy_pvt.update_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_rec		    => l_subv_rec,
	 x_subv_rec		    => x_subv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END update_subsidy;

PROCEDURE update_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN  subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_tbl          subv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_tbl := p_subv_tbl;

    okl_subsidy_pvt.update_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_tbl		    => l_subv_tbl,
	 x_subv_tbl		    => x_subv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END update_subsidy;


PROCEDURE delete_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN  subv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_rec          subv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_rec := p_subv_rec;

    okl_subsidy_pvt.delete_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_rec		    => l_subv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END delete_subsidy;


PROCEDURE delete_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN  subv_tbl_type) Is

    l_api_name		    CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_tbl          subv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_tbl := p_subv_tbl;

    okl_subsidy_pvt.delete_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_tbl		    => l_subv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END delete_subsidy;

PROCEDURE lock_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN  subv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_rec          subv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_rec := p_subv_rec;

    okl_subsidy_pvt.lock_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_rec		    => l_subv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END lock_subsidy;

PROCEDURE lock_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN  subv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_tbl          subv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_tbl := p_subv_tbl;

    okl_subsidy_pvt.lock_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_tbl		    => l_subv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END lock_subsidy;



PROCEDURE validate_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN  subv_rec_type) IS


    l_api_name		    CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_rec          subv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_rec := p_subv_rec;

    okl_subsidy_pvt.validate_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_rec		    => l_subv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_subsidy;

PROCEDURE validate_subsidy(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN  subv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_subv_tbl          subv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_subv_tbl := p_subv_tbl;

    okl_subsidy_pvt.validate_subsidy(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_subv_tbl		    => l_subv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_subsidy;


PROCEDURE create_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN  sucv_rec_type,
    x_sucv_rec                     OUT NOCOPY sucv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_rec          sucv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_rec := p_sucv_rec;

    okl_subsidy_pvt.create_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_rec		    => l_sucv_rec,
	 x_sucv_rec		    => x_sucv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END create_subsidy_criteria;



PROCEDURE create_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN  sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY sucv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'CREATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_tbl          sucv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_tbl := p_sucv_tbl;

    okl_subsidy_pvt.create_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_tbl		    => l_sucv_tbl,
	 x_sucv_tbl		    => x_sucv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END create_subsidy_criteria;


PROCEDURE update_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN  sucv_rec_type,
    x_sucv_rec                     OUT NOCOPY sucv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_rec          sucv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_rec := p_sucv_rec;

    okl_subsidy_pvt.update_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_rec		    => l_sucv_rec,
	 x_sucv_rec		    => x_sucv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END update_subsidy_criteria;

PROCEDURE update_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN  sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY sucv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'UPDATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_tbl          sucv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_tbl := p_sucv_tbl;

    okl_subsidy_pvt.update_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_tbl		    => l_sucv_tbl,
	 x_sucv_tbl		    => x_sucv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END update_subsidy_criteria;


PROCEDURE delete_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN  sucv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_rec          sucv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_rec := p_sucv_rec;

    okl_subsidy_pvt.delete_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_rec		    => l_sucv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END delete_subsidy_criteria;


PROCEDURE delete_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN  sucv_tbl_type) Is

    l_api_name		    CONSTANT VARCHAR2(30) := 'DELETE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_tbl          sucv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_tbl := p_sucv_tbl;

    okl_subsidy_pvt.delete_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_tbl		    => l_sucv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END delete_subsidy_criteria;

PROCEDURE lock_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN  sucv_rec_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_rec          sucv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_rec := p_sucv_rec;

    okl_subsidy_pvt.lock_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_rec		    => l_sucv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END lock_subsidy_criteria;

PROCEDURE lock_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN  sucv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'LOCK_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_tbl          sucv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_tbl := p_sucv_tbl;

    okl_subsidy_pvt.lock_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_tbl		    => l_sucv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END lock_subsidy_criteria;



PROCEDURE validate_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN  sucv_rec_type) IS


    l_api_name		    CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_rec          sucv_rec_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_rec := p_sucv_rec;

    okl_subsidy_pvt.validate_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_rec		    => l_sucv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_subsidy_criteria;

PROCEDURE validate_subsidy_criteria(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN  sucv_tbl_type) IS

    l_api_name		    CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY_CRITERIA';
    l_api_version		CONSTANT NUMBER	      := 1.0;
    l_return_status	    VARCHAR2(1)		      := OKL_API.G_RET_STS_SUCCESS;

    l_sucv_tbl          sucv_tbl_type;
Begin
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sucv_tbl := p_sucv_tbl;

    okl_subsidy_pvt.validate_subsidy_criteria(
	 p_api_version	    => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sucv_tbl		    => l_sucv_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_subsidy_criteria;

PROCEDURE add_language IS
Begin
    OKL_SUBSIDY_PVT.add_language;
End add_language;

END OKL_SUBSIDY_PUB;

/
