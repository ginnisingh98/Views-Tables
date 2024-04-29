--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_TOP_LINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_TOP_LINE_PUB" as
  /* $Header: OKLPKTLB.pls 115.5 2003/01/07 19:36:54 smereddy noship $ */

-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  G_API_TYPE	CONSTANT VARCHAR2(4) := '_PUB';

  PROCEDURE create_contract_link_serv(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id			   IN  NUMBER,
    p_contract_number              IN  VARCHAR2,
    p_item_name                    IN  VARCHAR2,
    p_supplier_name                IN  VARCHAR2,
    x_cle_id			   OUT NOCOPY NUMBER
) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_link_serv';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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

    okl_contract_top_line_pvt.create_contract_link_serv (
            p_api_version    		=> p_api_version,
            p_init_msg_list  		=> p_init_msg_list,
            x_return_status  		=> x_return_status,
            x_msg_count      		=> x_msg_count,
            x_msg_data       		=> x_msg_data,
            p_chr_id			=> p_chr_id,
	    p_contract_number           => p_contract_number,
	    p_item_name                 => p_item_name,
	    p_supplier_name             => p_supplier_name,
	    x_cle_id			=> x_cle_id);

     if(x_return_status = FND_API.G_RET_STS_ERROR )  then
	RAISE OKC_API.G_EXCEPTION_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     end if;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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
  END create_contract_link_serv;

  PROCEDURE update_contract_link_serv(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id			   IN  NUMBER,
    p_cle_id			   IN  NUMBER,
    p_contract_number              IN  VARCHAR2,
    p_item_name                    IN  VARCHAR2,
    p_supplier_name                IN  VARCHAR2,
    x_cle_id			   OUT NOCOPY NUMBER
) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'update_contract_link_serv';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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

    okl_contract_top_line_pvt.update_contract_link_serv (
            p_api_version    		=> p_api_version,
            p_init_msg_list  		=> p_init_msg_list,
            x_return_status  		=> x_return_status,
            x_msg_count      		=> x_msg_count,
            x_msg_data       		=> x_msg_data,
            p_chr_id			=> p_chr_id,
            p_cle_id			=> p_cle_id,
	    p_contract_number           => p_contract_number,
	    p_item_name                 => p_item_name,
	    p_supplier_name             => p_supplier_name,
	    x_cle_id			=> x_cle_id);

     if(x_return_status = FND_API.G_RET_STS_ERROR )  then
	RAISE OKC_API.G_EXCEPTION_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     end if;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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
  END update_contract_link_serv;

  PROCEDURE create_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
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

    OKL_CONTRACT_TOP_LINE_pvt.create_contract_top_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec        => l_clev_rec,
      p_klev_rec	=> l_klev_rec,
      p_cimv_rec	=> l_cimv_rec,
      p_cplv_rec	=> l_cplv_rec,
      x_clev_rec	=> x_clev_rec,
      x_klev_rec	=> x_klev_rec,
      x_cimv_rec	=> x_cimv_rec,
      x_cplv_rec	=> x_cplv_rec
	);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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
  END create_contract_top_line;

-- Start of comments
--
-- Procedure Name  : create_contract_top_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    p_cplv_tbl                     IN  cplv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_contract_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
    l_cplv_tbl   	cplv_tbl_type := p_cplv_tbl;
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


    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_contract_top_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
      			p_cplv_rec		=> l_cplv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i),
      			x_cplv_rec		=> x_cplv_tbl(i));

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);

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

  END create_contract_top_line;


-- Start of comments
--
-- Procedure Name  : update_contract_top_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_api_name		CONSTANT VARCHAR2(30) 	:= 'UPDATE_contract_top_line';
    l_api_version	CONSTANT NUMBER	  	:= 1.0;
    l_return_status	VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;

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

    OKL_CONTRACT_TOP_LINE_pvt.update_contract_top_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec	=> l_clev_rec,
      p_klev_rec	=> l_klev_rec,
      p_cimv_rec	=> l_cimv_rec,
      p_cplv_rec	=> l_cplv_rec,
      x_clev_rec	=> x_clev_rec,
      x_klev_rec	=> x_klev_rec,
      x_cimv_rec	=> x_cimv_rec,
      x_cplv_rec	=> x_cplv_rec
      );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

       OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
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
  END update_contract_top_line;


-- Start of comments
--
-- Procedure Name  : update_contract_top_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    p_cplv_tbl                     IN  cplv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_contract_top_line';
    l_api_version	CONSTANT NUMBER	:= 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
    l_cplv_tbl   	cplv_tbl_type := p_cplv_tbl;
  BEGIN
/*
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
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_top_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
      			p_cplv_rec		=> l_cplv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i),
      			x_cplv_rec		=> x_cplv_tbl(i));

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END update_contract_top_line;


  PROCEDURE delete_contract_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id	     IN  number,
            p_cle_id         IN  number) IS

    l_api_name		CONSTANT VARCHAR2(30)     := 'DELETE_contract_line';
    l_api_version	CONSTANT NUMBER	  	  := 1.0;
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

    OKL_CONTRACT_TOP_LINE_pvt.delete_contract_line(
      				p_api_version   => p_api_version,
      				p_init_msg_list => p_init_msg_list,
      				x_return_status => x_return_status,
      				x_msg_count     => x_msg_count,
      				x_msg_data      => x_msg_data,
      				p_chr_id        => p_chr_id,
    				p_cle_id        => p_cle_id);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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
  END delete_contract_line;


PROCEDURE delete_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_api_name		CONSTANT VARCHAR2(30)     := 'DELETE_contract_top_line';
    l_api_version	CONSTANT NUMBER	  	  := 1.0;
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


    OKL_CONTRACT_TOP_LINE_pvt.delete_contract_top_line(
      				p_api_version   => p_api_version,
      				p_init_msg_list => p_init_msg_list,
      				x_return_status => x_return_status,
      				x_msg_count     => x_msg_count,
      				x_msg_data      => x_msg_data,
      				p_clev_rec      => l_clev_rec,
      				p_klev_rec      => l_klev_rec,
      				p_cimv_rec      => l_cimv_rec,
      				p_cplv_rec      => l_cplv_rec
      				);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;


    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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
  END delete_contract_top_line;

  -- Start of comments
  --
  -- Procedure Name  : delete_contract_top_line
  -- Description     : deletes contract line for shadowed contract
  -- Business Rules  : line can be deleted only if there is no sublines attached
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE delete_contract_top_line(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clev_tbl                     IN  clev_tbl_type,
      p_klev_tbl                     IN  klev_tbl_type,
      p_cimv_tbl                     IN  cimv_tbl_type,
      p_cplv_tbl                     IN  cplv_tbl_type
      ) IS

      l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_contract_top_line';
      l_api_version		CONSTANT NUMBER	:= 1.0;
      l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_overall_status 		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i				NUMBER;
      l_klev_tbl   		klev_tbl_type := p_klev_tbl;
      l_cimv_tbl   		cimv_tbl_type := p_cimv_tbl;
      l_cplv_tbl   		cplv_tbl_type := p_cplv_tbl;
    BEGIN
  /*
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
  */
      If (p_clev_tbl.COUNT > 0) Then
  	   i := p_clev_tbl.FIRST;
  	   LOOP
  		-- call procedure in complex API for a record
  		delete_contract_top_line(
  			p_api_version		=> p_api_version,
  			p_init_msg_list		=> p_init_msg_list,
  			x_return_status 	=> x_return_status,
  			x_msg_count     	=> x_msg_count,
  			x_msg_data      	=> x_msg_data,
  			p_clev_rec		=> p_clev_tbl(i),
        		p_klev_rec		=> l_klev_tbl(i),
        		p_cimv_rec		=> l_cimv_tbl(i),
        		p_cplv_rec		=> l_cplv_tbl(i));

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;

          EXIT WHEN (i = p_clev_tbl.LAST);
  		i := p_clev_tbl.NEXT(i);
  	   END LOOP;

      End If;

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
  /*
      OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
  				x_msg_data	=> x_msg_data);
  */
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

    END delete_contract_top_line;

  PROCEDURE validate_fee_expense_rule(
                                     p_api_version         IN  NUMBER,
                                     p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status       OUT NOCOPY VARCHAR2,
                                     x_msg_count           OUT NOCOPY NUMBER,
                                     x_msg_data            OUT NOCOPY VARCHAR2,
                                     p_chr_id              IN  OKC_K_HEADERS_V.ID%TYPE,
                                     p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                     p_no_of_period        IN  NUMBER,
                                     p_frequency           IN  VARCHAR2,
                                     p_amount_per_period   IN  NUMBER
                                    ) IS

  l_api_name		 CONSTANT VARCHAR2(30)     := 'VALIDATE_FEE_EXPENSE_RULE';
  l_api_version	CONSTANT NUMBER	  	           := 1.0;
  l_return_status        VARCHAR2(1)               := OKL_API.G_RET_STS_SUCCESS;
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

    OKL_CONTRACT_TOP_LINE_pvt.validate_fee_expense_rule(
                                     p_api_version         => p_api_version,
                                     p_init_msg_list       => p_init_msg_list,
                                     x_return_status       => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data,
                                     p_chr_id              => p_chr_id,
                                     p_line_id             => p_line_id,
                                     p_no_of_period        => p_no_of_period,
                                     p_frequency           => p_frequency,
                                     p_amount_per_period   => p_amount_per_period
                                    );

    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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

  END validate_fee_expense_rule;

  PROCEDURE validate_passthru_rule(
                                   p_api_version         IN  NUMBER,
                                   p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2,
                                   p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                   p_vendor_id           IN  NUMBER,
                                   p_payment_term        IN  VARCHAR2,
                                   p_payment_term_id     IN  NUMBER,
                                   p_pay_to_site         IN  VARCHAR2,
                                   p_pay_to_site_id      IN  NUMBER,
                                   p_payment_method_code IN  VARCHAR2,
                                   x_payment_term_id1    OUT NOCOPY VARCHAR2,
                                   x_pay_site_id1        OUT NOCOPY VARCHAR2,
                                   x_payment_method_id1  OUT NOCOPY VARCHAR2
                                  ) IS

  l_api_name		 CONSTANT VARCHAR2(30)     := 'VALIDATE_passthru_rule';
  l_api_version	CONSTANT NUMBER	  	           := 1.0;
  l_return_status        VARCHAR2(1)               := OKL_API.G_RET_STS_SUCCESS;
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

    OKL_CONTRACT_TOP_LINE_pvt.validate_passthru_rule(
                                                     p_api_version         => p_api_version,
                                                     p_init_msg_list       => p_init_msg_list,
                                                     x_return_status       => x_return_status,
                                                     x_msg_count           => x_msg_count,
                                                     x_msg_data            => x_msg_data,
                                                     p_line_id             => p_line_id,
                                                     p_vendor_id           => p_vendor_id,
                                                     p_payment_term        => p_payment_term,
                                                     p_payment_term_id     => p_payment_term_id,
                                                     p_pay_to_site         => p_pay_to_site,
                                                     p_pay_to_site_id      => p_pay_to_site_id,
                                                     p_payment_method_code => p_payment_method_code,
                                                     x_payment_term_id1    => x_payment_term_id1,
                                                     x_pay_site_id1        => x_pay_site_id1,
                                                     x_payment_method_id1  => x_payment_method_id1
                                                    );

    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
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

  END validate_passthru_rule;
END OKL_CONTRACT_TOP_LINE_PUB;

/
