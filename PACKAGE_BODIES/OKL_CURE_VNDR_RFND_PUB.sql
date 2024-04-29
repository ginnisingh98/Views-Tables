--------------------------------------------------------
--  DDL for Package Body OKL_CURE_VNDR_RFND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_VNDR_RFND_PUB" AS
/* $Header: OKLPRFSB.pls 115.1 2003/04/25 15:12:06 jsanju noship $ */

PROCEDURE create_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'create_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

     OKL_CURE_VNDR_RFND_PVT.create_cure_refund(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_cure_rfnd_tbl	        => p_cure_rfnd_tbl,
	   	x_cure_rfnd_tbl		=> x_cure_rfnd_tbl
		);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

  END;


PROCEDURE update_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'update_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;


  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

     OKL_CURE_VNDR_RFND_PVT.update_cure_refund(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_cure_rfnd_tbl	        => p_cure_rfnd_tbl,
	   	x_cure_rfnd_tbl		=> x_cure_rfnd_tbl
		);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

  END;

PROCEDURE delete_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 ,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl         IN  cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'delete_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;

  BEGIN

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

     OKL_CURE_VNDR_RFND_PVT.delete_cure_refund(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_cure_rfnd_tbl	        => p_cure_rfnd_tbl
		);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

  END;

END OKL_CURE_VNDR_RFND_PUB;

/
