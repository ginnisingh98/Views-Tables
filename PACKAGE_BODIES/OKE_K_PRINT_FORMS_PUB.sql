--------------------------------------------------------
--  DDL for Package Body OKE_K_PRINT_FORMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_PRINT_FORMS_PUB" AS
/* $Header: OKEPKPFB.pls 120.1 2005/05/27 15:58:11 appldev  $ */
    g_api_type		CONSTANT VARCHAR2(4) := '_PUB';
    g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_k_print_forms_pub.';


  PROCEDURE create_print_form(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_form_rec		IN  oke_form_pvt.form_rec_type,
    x_form_rec		OUT NOCOPY  oke_form_pvt.form_rec_type) IS


    l_form_rec		oke_form_pvt.form_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_PRINT_FORM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_line_number       VARCHAR2(120);

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

    l_form_rec := p_form_rec;

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call forms pvt');

    -- call procedure in complex API

	OKE_FORM_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_form_rec		=> l_form_rec,
            x_form_rec		=> x_form_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'oke call passed');

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

  END create_print_form;



  PROCEDURE create_print_form(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_form_tbl		IN  oke_form_pvt.form_tbl_type,
    x_form_tbl		OUT NOCOPY  oke_form_pvt.form_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_PRINT_FORM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_form_tbl           oke_form_pvt.form_tbl_type;
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

    OKE_FORM_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_form_tbl		=> p_form_tbl,
      x_form_tbl		=> x_form_tbl);


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

  END create_print_form;

  PROCEDURE update_print_form(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_form_rec		IN oke_form_pvt.form_rec_type,
    x_form_rec		OUT NOCOPY oke_form_pvt.form_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_PRINT_FORM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.START TO CALL PUB LINE REC UPDATE');
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
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.going to call pvt_update_row');
    OKE_FORM_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_form_rec			=> p_form_rec,
      x_form_rec			=> x_form_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.ended');
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

  END update_print_form;


 PROCEDURE update_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN  oke_form_pvt.form_tbl_type,
    x_form_tbl			   OUT NOCOPY  oke_form_pvt.form_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_PRINT_FORM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.start call pub update table');

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

    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.going to call PVT.update_row table version');

    OKE_FORM_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_form_tbl			=> p_form_tbl,
      x_form_tbl			=> x_form_tbl);



    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'PUB.ended');
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

  END update_print_form;



  PROCEDURE validate_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec			   IN oke_form_pvt.form_rec_type) IS

    l_form_rec		oke_form_pvt.form_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_PRINT_FORM';
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
    l_form_rec := p_form_rec;

    -- call complex API

    OKE_FORM_PVT.Validate_Row(
	p_api_version		=> p_api_version,
	p_init_msg_list	=> p_init_msg_list,
     	x_return_status 	=> x_return_status,
      	x_msg_count     	=> x_msg_count,
      	x_msg_data      	=> x_msg_data,
      	p_form_rec		=> p_form_rec);


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

  END validate_print_form;

  PROCEDURE validate_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN oke_form_pvt.form_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_PRINT_FORM';

    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_form_tbl       oke_form_pvt.form_tbl_type := p_form_tbl;
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


    OKE_FORM_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_form_tbl		=> p_form_tbl);


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

  END validate_print_form;




  PROCEDURE delete_print_form(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec			   IN oke_form_pvt.form_rec_type) IS

    l_form_rec		oke_form_pvt.form_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PRINT_FORM';
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

    l_form_rec := p_form_rec;

    -- call complex api

    	OKE_FORM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_form_rec		=> p_form_rec);


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

  END delete_print_form;


  PROCEDURE delete_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl			   IN  oke_form_pvt.form_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PRINT_FORM';
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


    OKE_FORM_PVT.Delete_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_form_tbl		=> p_form_tbl);



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

  END delete_print_form;



  PROCEDURE delete_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id		IN NUMBER,
    p_cle_id		IN NUMBER,
    p_pfm_cd		IN OKE_K_PRINT_FORMS.PRINT_FORM_CODE%TYPE ) IS

    l_form_rec		oke_form_pvt.form_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PRINT_FORM';
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
		OKE_FORM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_cle_id		=> p_cle_id,
		p_pfm_cd		=> p_pfm_cd);


	Else
		OKE_FORM_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_chr_id		=> p_chr_id,
		p_pfm_cd		=> p_pfm_cd);

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

  END delete_print_form;



   PROCEDURE copy_print_form(
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

    l_form_tbl		oke_form_pvt.form_tbl_type;
    l_form_rec		oke_form_pvt.form_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'COPY_PRINT_FORM';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_rec_num		NUMBER:=0;

    x_form_tbl		oke_form_pvt.form_tbl_type;

    CURSOR form_cle_csr (p_id  IN NUMBER) IS
    SELECT
		b.K_HEADER_ID			,
		b.K_LINE_ID			,
		b.PRINT_FORM_CODE		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.REQUIRED_FLAG			,
		b.CUSTOMER_FURNISHED_FLAG	,
		b.COMPLETED_FLAG		,
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
    FROM OKE_K_PRINT_FORMS b
    WHERE b.K_LINE_ID = p_id;

    CURSOR form_chr_csr (p_id IN NUMBER) IS
    SELECT
		b.K_HEADER_ID			,
		b.K_LINE_ID			,
		b.PRINT_FORM_CODE		,
		b.CREATION_DATE			,
		b.CREATED_BY			,
		b.LAST_UPDATE_DATE		,
		b.LAST_UPDATED_BY		,
		b.LAST_UPDATE_LOGIN		,
		b.REQUIRED_FLAG			,
		b.CUSTOMER_FURNISHED_FLAG	,
		b.COMPLETED_FLAG		,
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
    FROM OKE_K_PRINT_FORMS b
    WHERE (b.K_HEADER_ID = p_id) AND (b.K_LINE_ID IS NULL);


  BEGIN

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'print forms start call copy forms pub');

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

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Print FORMS check conditions');

    IF( p_from_level='H' ) THEN

	--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Print Form copy for chr');

	OPEN form_chr_csr (p_from_chr_id);
	LOOP
	FETCH form_chr_csr INTO
		l_form_rec.K_HEADER_ID			,
		l_form_rec.K_LINE_ID			,
		l_form_rec.PRINT_FORM_CODE		,
		l_form_rec.CREATION_DATE		,
		l_form_rec.CREATED_BY			,
		l_form_rec.LAST_UPDATE_DATE		,
		l_form_rec.LAST_UPDATED_BY		,
		l_form_rec.LAST_UPDATE_LOGIN		,
		l_form_rec.REQUIRED_FLAG		,
		l_form_rec.CUSTOMER_FURNISHED_FLAG	,
		l_form_rec.COMPLETED_FLAG		,
		l_form_rec.ATTRIBUTE_CATEGORY		,
		l_form_rec.ATTRIBUTE1			,
		l_form_rec.ATTRIBUTE2			,
		l_form_rec.ATTRIBUTE3			,
		l_form_rec.ATTRIBUTE4			,
		l_form_rec.ATTRIBUTE5			,
		l_form_rec.ATTRIBUTE6			,
		l_form_rec.ATTRIBUTE7			,
		l_form_rec.ATTRIBUTE8			,
		l_form_rec.ATTRIBUTE9			,
		l_form_rec.ATTRIBUTE10			,
		l_form_rec.ATTRIBUTE11			,
		l_form_rec.ATTRIBUTE12			,
		l_form_rec.ATTRIBUTE13			,
		l_form_rec.ATTRIBUTE14			,
		l_form_rec.ATTRIBUTE15			;
	EXIT WHEN form_chr_csr%NOTFOUND;

	l_rec_num := l_rec_num+1;

	IF(p_to_chr_id IS NULL)AND(p_to_cle_id IS NULL) THEN
		raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	IF(p_to_chr_id IS NULL) THEN
		l_form_rec.K_HEADER_ID := l_form_rec.K_HEADER_ID ;
		l_form_rec.K_LINE_ID := p_to_cle_id;
	ELSE
		IF(p_to_cle_id IS NULL) THEN
			l_form_rec.K_HEADER_ID := p_to_chr_id;
			l_form_rec.K_LINE_ID := NULL;
		ELSE
			l_form_rec.K_HEADER_ID := p_to_chr_id;
			l_form_rec.K_LINE_ID := p_to_cle_id;
		END IF;
	END IF;

	l_form_tbl(l_rec_num) := l_form_rec;


	END LOOP;
	CLOSE form_chr_csr;

	--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'print FORMS inserting std form');
    	OKE_FORM_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_form_tbl		=> l_form_tbl,
      		x_form_tbl		=> x_form_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;


    ELSIF( p_from_level='L' ) THEN

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'print form copy for cle');

	OPEN form_cle_csr (p_from_cle_id);
	LOOP
	FETCH form_cle_csr INTO
		l_form_rec.K_HEADER_ID			,
		l_form_rec.K_LINE_ID			,
		l_form_rec.PRINT_FORM_CODE		,
		l_form_rec.CREATION_DATE		,
		l_form_rec.CREATED_BY			,
		l_form_rec.LAST_UPDATE_DATE		,
		l_form_rec.LAST_UPDATED_BY		,
		l_form_rec.LAST_UPDATE_LOGIN		,
		l_form_rec.REQUIRED_FLAG		,
		l_form_rec.CUSTOMER_FURNISHED_FLAG	,
		l_form_rec.COMPLETED_FLAG		,
		l_form_rec.ATTRIBUTE_CATEGORY		,
		l_form_rec.ATTRIBUTE1			,
		l_form_rec.ATTRIBUTE2			,
		l_form_rec.ATTRIBUTE3			,
		l_form_rec.ATTRIBUTE4			,
		l_form_rec.ATTRIBUTE5			,
		l_form_rec.ATTRIBUTE6			,
		l_form_rec.ATTRIBUTE7			,
		l_form_rec.ATTRIBUTE8			,
		l_form_rec.ATTRIBUTE9			,
		l_form_rec.ATTRIBUTE10			,
		l_form_rec.ATTRIBUTE11			,
		l_form_rec.ATTRIBUTE12			,
		l_form_rec.ATTRIBUTE13			,
		l_form_rec.ATTRIBUTE14			,
		l_form_rec.ATTRIBUTE15			;
	EXIT WHEN form_cle_csr%NOTFOUND;

	l_rec_num := l_rec_num+1;

	IF(p_to_chr_id IS NULL)AND(p_to_cle_id IS NULL) THEN
		raise OKE_API.G_EXCEPTION_ERROR;
	END IF;

	IF(p_to_chr_id IS NULL) THEN
		l_form_rec.K_HEADER_ID := l_form_rec.K_HEADER_ID ;
		l_form_rec.K_LINE_ID := p_to_cle_id;
	ELSE
		IF(p_to_cle_id IS NULL) THEN
			l_form_rec.K_HEADER_ID := p_to_chr_id;
			l_form_rec.K_LINE_ID := NULL;
		ELSE
			l_form_rec.K_HEADER_ID := p_to_chr_id;
			l_form_rec.K_LINE_ID := p_to_cle_id;
		END IF;
	END IF;

	l_form_tbl(l_rec_num) := l_form_rec;


	END LOOP;
	CLOSE form_cle_csr;

	--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'print form inserting std form');
    	OKE_FORM_PVT.Insert_Row(
      		p_api_version	=> p_api_version,
      		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_form_tbl		=> l_form_tbl,
      		x_form_tbl		=> x_form_tbl);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;

  ELSE
	--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'conditions not met');
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

  END copy_print_form;


  PROCEDURE lock_print_form(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_form_rec           IN OKE_FORM_PVT.form_rec_type) IS


    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_PRINT_FORM';
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

    OKE_FORM_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_form_rec		=> p_form_rec);

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

  END lock_print_form;

  PROCEDURE lock_print_form(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl                     IN oke_form_pvt.form_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_PRINT_FORM';
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

    If (p_form_tbl.COUNT > 0) Then
	   i := p_form_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_FORM_PVT.lock_row(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_form_rec		=> p_form_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_form_tbl.LAST);
		i := p_form_tbl.NEXT(i);
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

  END lock_print_form;

END OKE_K_PRINT_FORMS_PUB;


/
