--------------------------------------------------------
--  DDL for Package Body OKE_TERMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_TERMS_PUB" AS
/* $Header: OKEPTRMB.pls 115.7 2002/11/20 20:46:43 who ship $ */
    g_api_type		CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE create_term(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_term_rec		IN  oke_term_pvt.term_rec_type,
    x_term_rec		OUT NOCOPY  oke_term_pvt.term_rec_type) IS


    l_term_rec		oke_term_pvt.term_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_term_rec := p_term_rec;

    -- call procedure in complex API

	OKE_TERM_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_term_rec		=> l_term_rec,
            x_term_rec		=> x_term_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END create_term;



  PROCEDURE create_term(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_term_tbl		IN  oke_term_pvt.term_tbl_type,
    x_term_tbl		OUT NOCOPY  oke_term_pvt.term_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_term_tbl           oke_term_pvt.term_tbl_type;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_TERM_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_term_tbl	=> p_term_tbl,
      x_term_tbl	=> x_term_tbl);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END create_term;

/* not supported


  PROCEDURE update_term(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_term_rec		IN oke_term_pvt.term_rec_type,
    x_term_rec		OUT NOCOPY oke_term_pvt.term_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list


    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call complex api

    OKE_TERM_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_term_rec			=> p_term_rec,
      x_term_rec			=> x_term_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END update_term;


 PROCEDURE update_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl			   IN  oke_term_pvt.term_tbl_type,
    x_term_tbl			   OUT NOCOPY  oke_term_pvt.term_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;

    End If;

    OKE_TERM_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_term_tbl			=> p_term_tbl,
      x_term_tbl			=> x_term_tbl);



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END update_term;



  PROCEDURE validate_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec			   IN oke_term_pvt.term_rec_type) IS

    l_term_rec		oke_term_pvt.term_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- call BEFORE user hook
    l_term_rec := p_term_rec;

    -- call complex API

    OKE_TERM_PVT.Validate_Row(
	p_api_version		=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
     	x_return_status 	=> x_return_status,
      	x_msg_count     	=> x_msg_count,
      	x_msg_data      	=> x_msg_data,
      	p_term_rec		=> p_term_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END validate_term;

  PROCEDURE validate_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl			   IN oke_term_pvt.term_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_TERM';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_term_tbl       oke_term_pvt.term_tbl_type := p_term_tbl;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_TERM_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_term_tbl		=> p_term_tbl);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity
    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END validate_term;

*/


  PROCEDURE delete_term(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec			   IN oke_term_pvt.term_rec_type) IS

    l_term_rec		oke_term_pvt.term_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    l_term_rec := p_term_rec;

    -- call complex api

    	OKE_TERM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_term_rec		=> p_term_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_term;

  PROCEDURE delete_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl			   IN  oke_term_pvt.term_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_TERM_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_term_tbl	=> p_term_tbl);



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_term;


  PROCEDURE delete_term(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id		IN NUMBER,
    p_cle_id		IN NUMBER,
    p_trm_cd		IN OKE_K_TERMS.TERM_CODE%TYPE,
    p_trm_val_pk1	IN OKE_K_TERMS.TERM_VALUE_PK1%TYPE,
    p_trm_val_pk2	IN OKE_K_TERMS.TERM_VALUE_PK2%TYPE) IS

    l_term_rec		oke_term_pvt.term_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_check_num1	NUMBER;
    l_check_num2	NUMBER;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

	If (p_cle_id IS NOT NULL) Then
		OKE_TERM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_cle_id		=> p_cle_id,
		p_trm_cd		=> p_trm_cd,
		p_trm_val_pk1		=> p_trm_val_pk1,
		p_trm_val_pk2		=> p_trm_val_pk2);


	Else
		OKE_TERM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_chr_id		=> p_chr_id,
		p_trm_cd		=> p_trm_cd,
		p_trm_val_pk1		=> p_trm_val_pk1,
		p_trm_val_pk2		=> p_trm_val_pk2);

	End If;



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;


    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END delete_term;


   PROCEDURE copy_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_level		IN VARCHAR2,
    p_to_level			IN VARCHAR2,
    p_from_chr_id		IN NUMBER,
    p_to_chr_id			IN NUMBER,
    p_from_cle_id		IN NUMBER,
    p_to_cle_id			IN NUMBER
) IS


    l_term_tbl		oke_term_pvt.term_tbl_type;
    l_term_rec		oke_term_pvt.term_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_rec_num		NUMBER:=0;

    x_term_tbl		oke_term_pvt.term_tbl_type;

    CURSOR term_cle_csr (p_id  IN NUMBER) IS
    SELECT
		b.K_HEADER_ID			,
		b.K_LINE_ID			,
		b.TERM_CODE			,
		b.TERM_VALUE_PK1		,
		b.TERM_VALUE_PK2		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.ATTRIBUTE_CATEGORY		,
		b.ATTRIBUTE1			,
		b.ATTRIBUTE2			,
		b.ATTRIBUTE3			,
		b.ATTRIBUTE4			,
		b.ATTRIBUTE5			,
		b.ATTRIBUTE6			,
		b.ATTRIBUTE7			,
		b.ATTRIBUTE8			,
		b.ATTRIBUTE9			,
		b.ATTRIBUTE10			,
		b.ATTRIBUTE11			,
		b.ATTRIBUTE12			,
		b.ATTRIBUTE13			,
		b.ATTRIBUTE14			,
		b.ATTRIBUTE15
    FROM OKE_K_TERMS b
    WHERE b.K_LINE_ID = p_id;

    CURSOR term_chr_csr (p_id IN NUMBER) IS
    SELECT
		b.K_HEADER_ID			,
		b.K_LINE_ID			,
		b.TERM_CODE			,
		b.TERM_VALUE_PK1		,
		b.TERM_VALUE_PK2		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.ATTRIBUTE_CATEGORY		,
		b.ATTRIBUTE1			,
		b.ATTRIBUTE2			,
		b.ATTRIBUTE3			,
		b.ATTRIBUTE4			,
		b.ATTRIBUTE5			,
		b.ATTRIBUTE6			,
		b.ATTRIBUTE7			,
		b.ATTRIBUTE8			,
		b.ATTRIBUTE9			,
		b.ATTRIBUTE10			,
		b.ATTRIBUTE11			,
		b.ATTRIBUTE12			,
		b.ATTRIBUTE13			,
		b.ATTRIBUTE14			,
		b.ATTRIBUTE15
    FROM OKE_K_TERMS b
    WHERE (b.K_HEADER_ID = p_id) AND (b.K_LINE_ID IS NULL);


  BEGIN


    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;



    IF( p_from_level='H' ) THEN

	OPEN term_chr_csr (p_from_chr_id);
	LOOP
	FETCH term_chr_csr INTO
		l_term_rec.K_HEADER_ID			,
		l_term_rec.K_LINE_ID			,
		l_term_rec.TERM_CODE			,
		l_term_rec.TERM_VALUE_PK1		,
		l_term_rec.TERM_VALUE_PK2		,
		l_term_rec.CREATION_DATE		,
		l_term_rec.CREATED_BY			,
		l_term_rec.LAST_UPDATE_DATE		,
		l_term_rec.LAST_UPDATED_BY		,
		l_term_rec.LAST_UPDATE_LOGIN		,
		l_term_rec.ATTRIBUTE_CATEGORY		,
		l_term_rec.ATTRIBUTE1			,
		l_term_rec.ATTRIBUTE2			,
		l_term_rec.ATTRIBUTE3			,
		l_term_rec.ATTRIBUTE4			,
		l_term_rec.ATTRIBUTE5			,
		l_term_rec.ATTRIBUTE6			,
		l_term_rec.ATTRIBUTE7			,
		l_term_rec.ATTRIBUTE8			,
		l_term_rec.ATTRIBUTE9			,
		l_term_rec.ATTRIBUTE10			,
		l_term_rec.ATTRIBUTE11			,
		l_term_rec.ATTRIBUTE12			,
		l_term_rec.ATTRIBUTE13			,
		l_term_rec.ATTRIBUTE14			,
		l_term_rec.ATTRIBUTE15			;
	EXIT WHEN term_chr_csr%NOTFOUND;

	l_rec_num := l_rec_num+1;

	IF(p_to_chr_id IS NULL)AND(p_to_cle_id IS NULL) THEN
		raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	IF(p_to_chr_id IS NULL) THEN
		l_term_rec.K_HEADER_ID := l_term_rec.K_HEADER_ID ;
		l_term_rec.K_LINE_ID := p_to_cle_id;
	ELSE
		IF(p_to_cle_id IS NULL) THEN
			l_term_rec.K_HEADER_ID := p_to_chr_id;
			l_term_rec.K_LINE_ID := NULL;
		ELSE
			l_term_rec.K_HEADER_ID := p_to_chr_id;
			l_term_rec.K_LINE_ID := p_to_cle_id;
		END IF;
	END IF;

	l_term_tbl(l_rec_num) := l_term_rec;


	END LOOP;
	CLOSE term_chr_csr;

    	OKE_TERM_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_term_tbl		=> l_term_tbl,
      		x_term_tbl		=> x_term_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;


    ELSIF( p_from_level='L' ) THEN

	OPEN term_cle_csr (p_from_cle_id);
	LOOP
	FETCH term_cle_csr INTO
		l_term_rec.K_HEADER_ID			,
		l_term_rec.K_LINE_ID			,
		l_term_rec.TERM_CODE		,
		l_term_rec.TERM_VALUE_PK1	,
		l_term_rec.TERM_VALUE_PK2	,
		l_term_rec.CREATION_DATE		,
		l_term_rec.CREATED_BY			,
		l_term_rec.LAST_UPDATE_DATE		,
		l_term_rec.LAST_UPDATED_BY		,
		l_term_rec.LAST_UPDATE_LOGIN		,
		l_term_rec.ATTRIBUTE_CATEGORY		,
		l_term_rec.ATTRIBUTE1			,
		l_term_rec.ATTRIBUTE2			,
		l_term_rec.ATTRIBUTE3			,
		l_term_rec.ATTRIBUTE4			,
		l_term_rec.ATTRIBUTE5			,
		l_term_rec.ATTRIBUTE6			,
		l_term_rec.ATTRIBUTE7			,
		l_term_rec.ATTRIBUTE8			,
		l_term_rec.ATTRIBUTE9			,
		l_term_rec.ATTRIBUTE10			,
		l_term_rec.ATTRIBUTE11			,
		l_term_rec.ATTRIBUTE12			,
		l_term_rec.ATTRIBUTE13			,
		l_term_rec.ATTRIBUTE14			,
		l_term_rec.ATTRIBUTE15			;
	EXIT WHEN term_cle_csr%NOTFOUND;

	l_rec_num := l_rec_num+1;

	IF(p_to_chr_id IS NULL)AND(p_to_cle_id IS NULL) THEN
		raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	IF(p_to_chr_id IS NULL) THEN
		l_term_rec.K_HEADER_ID := l_term_rec.K_HEADER_ID ;
		l_term_rec.K_LINE_ID := p_to_cle_id;
	ELSE
		IF(p_to_cle_id IS NULL) THEN
			l_term_rec.K_HEADER_ID := p_to_chr_id;
			l_term_rec.K_LINE_ID := NULL;
		ELSE
			l_term_rec.K_HEADER_ID := p_to_chr_id;
			l_term_rec.K_LINE_ID := p_to_cle_id;
		END IF;
	END IF;

	l_term_tbl(l_rec_num) := l_term_rec;


	END LOOP;
	CLOSE term_cle_csr;


    	OKE_TERM_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_term_tbl		=> l_term_tbl,
      		x_term_tbl		=> x_term_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;

  ELSE
	raise OKE_API.G_EXCEPTION_ERROR;
  END IF;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END copy_term;



  PROCEDURE lock_term(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_term_rec           IN OKE_TERM_PVT.term_rec_type) IS


    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)	  := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_TERM_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_term_rec		=> p_term_rec);

    -- check return status
    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END lock_term;

  PROCEDURE lock_term(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN oke_term_pvt.term_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_TERM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) then
       raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKE_API.G_RET_STS_ERROR) then
       raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    If (p_term_tbl.COUNT > 0) Then
	   i := p_term_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_TERM_PVT.lock_row(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_term_rec		=> p_term_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
       		EXIT WHEN (i = p_term_tbl.LAST);
		i := p_term_tbl.NEXT(i);
	   END LOOP;
	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    -- end activity

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKE_API.G_EXCEPTION_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKE_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END lock_term;

END OKE_TERMS_PUB;


/
