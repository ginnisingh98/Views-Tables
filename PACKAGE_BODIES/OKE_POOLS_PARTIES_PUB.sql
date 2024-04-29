--------------------------------------------------------
--  DDL for Package Body OKE_POOLS_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_POOLS_PARTIES_PUB" AS
/* $Header: OKEPPPPB.pls 120.1 2005/05/27 15:58:52 appldev  $ */
    g_api_type		CONSTANT VARCHAR2(4) := '_PUB';
    g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_pools_parties_pub.';



  PROCEDURE create_pool(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_pool_rec		IN  oke_pool_pvt.pool_rec_type,
    x_pool_rec		OUT NOCOPY  oke_pool_pvt.pool_rec_type) IS


    l_pool_rec		oke_pool_pvt.pool_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_POOL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_line_number       VARCHAR2(120);

  BEGIN
--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call oke_pools_parties_pub.create_pool');
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

    l_pool_rec := p_pool_rec;

    -- call procedure in complex API

	OKE_POOL_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_pool_rec		=> l_pool_rec,
            x_pool_rec		=> x_pool_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'end call oke_pools_parties_pub.create_pool');

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

  END create_pool;



  PROCEDURE create_pool(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_pool_tbl		IN  oke_pool_pvt.pool_tbl_type,
    x_pool_tbl		OUT NOCOPY  oke_pool_pvt.pool_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_POOL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_pool_tbl           oke_pool_pvt.pool_tbl_type;
  BEGIN
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call oke_pools_parties_pub.create_pool');
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

    OKE_POOL_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_pool_tbl		=> p_pool_tbl,
      x_pool_tbl		=> x_pool_tbl);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'end call oke_pools_parties_pub.create_pool');
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

  END create_pool;

  PROCEDURE update_pool(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_pool_rec		IN oke_pool_pvt.pool_rec_type,
    x_pool_rec		OUT NOCOPY oke_pool_pvt.pool_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_POOL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call oke_pools_parties_pub.update_pool');

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
    OKE_POOL_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_pool_rec			=> p_pool_rec,
      x_pool_rec			=> x_pool_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
  --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'end call oke_pools_parties_pub.update_pool');

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

  END update_pool;


 PROCEDURE update_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl			   IN  oke_pool_pvt.pool_tbl_type,
    x_pool_tbl			   OUT NOCOPY  oke_pool_pvt.pool_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_POOL';
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

    OKE_POOL_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_pool_tbl			=> p_pool_tbl,
      x_pool_tbl			=> x_pool_tbl);


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

  END update_pool;


  PROCEDURE delete_pool(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_funding_pool_id		   IN NUMBER) IS

    l_pool_rec		oke_pool_pvt.pool_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_POOL';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;

    l_current_id	NUMBER;
    l_temp		NUMBER;

	CURSOR l_csr IS
	SELECT POOL_PARTY_ID
	FROM OKE_POOL_PARTIES
	WHERE FUNDING_POOL_ID = p_funding_pool_id;

	Cursor l_csr_id IS
	select funding_pool_id
	from oke_funding_pools
	where funding_pool_id=p_funding_pool_id;


  BEGIN
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call oke_pools_parties_pub.delete_pool');
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


    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>oke_api.g_invalid_value,
		p_token1		=>oke_api.g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'must provide valid funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;


    l_pool_rec.funding_pool_id := p_funding_pool_id;

    	OPEN l_csr;
	LOOP
    	FETCH l_csr INTO l_current_id;
	EXIT WHEN l_csr%NOTFOUND;
	delete_party(p_api_version	=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
		p_pool_party_id		=> l_current_id);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  close l_csr;
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  close l_csr;
	  raise OKE_API.G_EXCEPTION_ERROR;
    	End If;

	END LOOP;
    	CLOSE l_csr;

    -- call complex api

    	OKE_POOL_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_pool_rec		=> l_pool_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'end call oke_pools_parties_pub.delete_pool');
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

  END delete_pool;


  PROCEDURE delete_pool(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec			   IN oke_pool_pvt.pool_rec_type) IS

    l_pool_rec		oke_pool_pvt.pool_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_POOL';
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

    l_pool_rec := p_pool_rec;

    -- call complex api

    	delete_pool(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_funding_pool_id	=> p_pool_rec.funding_pool_id);


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

  END delete_pool;

  PROCEDURE delete_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl			   IN  oke_pool_pvt.pool_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_POOL';
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



  If (p_pool_tbl.COUNT>0) Then
     i:=p_pool_tbl.FIRST;
     LOOP
      Delete_Pool(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_funding_pool_id	=> p_pool_tbl(i).funding_pool_id);

                -- store the highest degree of error
         If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;


	EXIT WHEN (i = p_pool_tbl.LAST);
 	i := p_pool_tbl.NEXT(i);
     END LOOP;
         x_return_status := l_overall_status;
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

  END delete_pool;


  PROCEDURE lock_pool(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_pool_rec           IN OKE_POOL_PVT.pool_rec_type) IS


    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_POOL';
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

    OKE_POOL_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_pool_rec		=> p_pool_rec);

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

  END lock_pool;

  PROCEDURE lock_pool(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN oke_pool_pvt.pool_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_POOL';
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

    If (p_pool_tbl.COUNT > 0) Then
	   i := p_pool_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_POOL_PVT.lock_row(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_pool_rec		=> p_pool_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_pool_tbl.LAST);
		i := p_pool_tbl.NEXT(i);
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

  END lock_pool;


--- start of party section ------------------



  PROCEDURE create_party(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_party_rec		IN  oke_party_pvt.party_rec_type,
    x_party_rec		OUT NOCOPY  oke_party_pvt.party_rec_type) IS


    l_party_rec		oke_party_pvt.party_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_PARTY';
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

    l_party_rec := p_party_rec;

--FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call partys pvt');

    -- call procedure in complex API

	OKE_PARTY_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_party_rec		=> l_party_rec,
            x_party_rec		=> x_party_rec);


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

  END create_party;



  PROCEDURE create_party(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_party_tbl		IN  oke_party_pvt.party_tbl_type,
    x_party_tbl		OUT NOCOPY  oke_party_pvt.party_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_PARTY';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_party_tbl           oke_party_pvt.party_tbl_type;
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

    OKE_PARTY_PVT.Insert_Row(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_party_tbl		=> p_party_tbl,
      x_party_tbl		=> x_party_tbl);


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

  END create_party;


  PROCEDURE update_party(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_party_rec		IN oke_party_pvt.party_rec_type,
    x_party_rec		OUT NOCOPY oke_party_pvt.party_rec_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_PARTY';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;


	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_FUNDING_SOURCES
	WHERE POOL_PARTY_ID = p_party_rec.POOL_PARTY_ID;


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
    OKE_PARTY_PVT.Update_Row(
      p_api_version		=> p_api_version,
      p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_party_rec			=> p_party_rec,
      x_party_rec			=> x_party_rec);


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

  END update_party;


 PROCEDURE update_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl			   IN  oke_party_pvt.party_tbl_type,
    x_party_tbl			   OUT NOCOPY  oke_party_pvt.party_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_PARTY';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    i			NUMBER;


	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr (p_row NUMBER)  IS
	SELECT 'x'
	FROM OKE_K_FUNDING_SOURCES
	WHERE POOL_PARTY_ID = p_party_tbl(p_row).POOL_PARTY_ID;

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

    OKE_PARTY_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_party_tbl			=> p_party_tbl,
      x_party_tbl			=> x_party_tbl);



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

  END update_party;


  PROCEDURE delete_party(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec			   IN oke_party_pvt.party_rec_type) IS

    l_party_rec		oke_party_pvt.party_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PARTY';
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

    l_party_rec := p_party_rec;

    -- call complex api

    	delete_party(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_pool_party_id		=> p_party_rec.pool_party_id);


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

  END delete_party;



  PROCEDURE delete_party(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_party_id		   IN NUMBER) IS

    l_party_rec		oke_party_pvt.party_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PARTY';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKE_API.G_RET_STS_SUCCESS;
    l_current_id	NUMBER;
    l_temp			NUMBER;

	CURSOR l_csr IS
	SELECT FUNDING_SOURCE_ID
	FROM OKE_K_FUNDING_SOURCES
	WHERE POOL_PARTY_ID = p_pool_party_id;

	Cursor l_csr_id IS
	select pool_party_id
	from oke_pool_parties
	where pool_party_id=p_pool_party_id;

  BEGIN
    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call oke_pools_parties_pub.delete_party');
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

    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>oke_api.g_invalid_value,
		p_token1		=>oke_api.g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'must provide valid pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;


    l_party_rec.pool_party_id := p_pool_party_id;


    	OPEN l_csr;
	LOOP
    	FETCH l_csr INTO l_current_id;
	EXIT WHEN l_csr%NOTFOUND;
	oke_funding_pub.delete_funding(
		p_api_version		=> p_api_version,
	 	p_init_msg_list		=> p_init_msg_list,
		p_commit		=> OKE_API.G_FALSE,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
		p_funding_source_id	=> l_current_id);

    	If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  close l_csr;
    	Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
	  close l_csr;
    	End If;

	END LOOP;
    	CLOSE l_csr;


    -- call complex api

    	OKE_PARTY_PVT.delete_row(
	 	p_api_version		=> p_api_version,
	 	p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_party_rec		=> l_party_rec);


    If x_return_status = OKE_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKE_API.G_RET_STS_ERROR Then
	  raise OKE_API.G_EXCEPTION_ERROR;
    End If;

    --FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'end call oke_pools_parties_pub.delete_party');
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

  END delete_party;



  PROCEDURE delete_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl			   IN  oke_party_pvt.party_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_PARTY';
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


  If (p_party_tbl.COUNT>0) Then
     i:=p_party_tbl.FIRST;
     LOOP
      Delete_Party(
      p_api_version	=> p_api_version,
      p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_pool_party_id	=> p_party_tbl(i).pool_party_id);

                -- store the highest degree of error
         If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
           If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
             l_overall_status := x_return_status;
           End If;
         End If;


	EXIT WHEN (i = p_party_tbl.LAST);
 	i := p_party_tbl.NEXT(i);
     END LOOP;
         x_return_status := l_overall_status;
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

  END delete_party;


  PROCEDURE lock_party(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_party_rec           IN OKE_PARTY_PVT.party_rec_type) IS


    l_del_rec		oke_deliverable_pvt.del_rec_type;
    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_PARTY';
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

    OKE_PARTY_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_party_rec		=> p_party_rec);

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

  END lock_party;

  PROCEDURE lock_party(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN oke_party_pvt.party_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_PARTY';
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

    If (p_party_tbl.COUNT > 0) Then
	   i := p_party_tbl.FIRST;
	   LOOP
		-- call procedure in complex API
		OKE_PARTY_PVT.lock_row(
			p_api_version		=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_party_rec		=> p_party_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;
        EXIT WHEN (i = p_party_tbl.LAST);
		i := p_party_tbl.NEXT(i);
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

  END lock_party;



END OKE_POOLS_PARTIES_PUB;


/
