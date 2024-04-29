--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_PUB" AS
/* $Header: OKLPKHRB.pls 120.2 2005/06/29 16:55:13 apaul noship $ */
  -- GLOBAL VARIABLES
  G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';



  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN	 	CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 	CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE      CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE       CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN      CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_TABLE_TOKEN      	CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;

  G_EXCEPTION_HALT_VALIDATION exception;

  NO_CONTRACT_FOUND exception;

  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKL_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;

  G_API_TYPE		CONSTANT VARCHAR2(4) := '_PUB';

-- Start of comments
--
-- Procedure Name  : create_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_chrv_rec          okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec          khrv_rec_type;
    l_okc_chrv_rec      okl_okc_migration_pvt.chrv_rec_type;
    l_okc_chrv_rec_out  okl_okc_migration_pvt.chrv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
  --code added for CUHK
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;
    g_khrv_rec := l_khrv_rec;
    g_chrv_rec := l_chrv_rec;
--Call pre Vertical Hook :

    l_khrv_rec.id := p_khrv_rec.id;
    l_khrv_rec.object_version_number := p_khrv_rec.object_version_number;
    l_chrv_rec.id := p_chrv_rec.id;
    l_chrv_rec.object_version_number := p_chrv_rec.object_version_number;


    okl_contract_pvt.create_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec,
      x_chrv_rec      => x_chrv_rec,
      x_khrv_rec      => x_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


     l_khrv_rec := x_khrv_rec;
     l_chrv_rec := x_chrv_rec;
     g_khrv_rec := l_khrv_rec;
     g_chrv_rec := l_chrv_rec;

    --Call After Vertical  Hook
     --Call After User Hook

      OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
    Exception
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
  END create_contract_header;


-- Start of comments
--
-- Procedure Name  : create_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_khrv_tbl   		khrv_tbl_type := p_khrv_tbl;
  BEGIN
/*
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
*/
    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_contract_header(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_chrv_rec		=> p_chrv_tbl(i),
      		p_khrv_rec		=> l_khrv_tbl(i),
			x_chrv_rec		=> x_chrv_tbl(i),
      		x_khrv_rec		=> x_khrv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
*/
  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		NULL;
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
  END create_contract_header;

-- Start of comments
--
-- Procedure Name  : update_contract_header
-- Description     : updates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    --code added for CUHK
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;
    g_khrv_rec := l_khrv_rec;
    g_chrv_rec := l_chrv_rec;

--Call pre Vertical Hook :

    l_khrv_rec.id := p_khrv_rec.id;
    l_khrv_rec.object_version_number := p_khrv_rec.object_version_number;
    l_chrv_rec.id := p_chrv_rec.id;
    l_chrv_rec.object_version_number := p_chrv_rec.object_version_number;

--Base API Logic
    okl_contract_pvt.update_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_restricted_update => p_restricted_update,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec,
      x_chrv_rec      => x_chrv_rec,
      x_khrv_rec      => x_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_khrv_rec := x_khrv_rec;
     l_chrv_rec := x_chrv_rec;
     g_khrv_rec := l_khrv_rec;
     g_chrv_rec := l_chrv_rec;


    --Call After Vertical  Hook
     --Call After User Hook

      OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);

	Exception
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
  END update_contract_header;


-- Start of comments
--
-- Procedure Name  : update_contract_header
-- Description     : creates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type,
    x_chrv_tbl                     OUT NOCOPY okl_okc_migration_pvt.chrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_khrv_tbl   		khrv_tbl_type := p_khrv_tbl;
  BEGIN
/*
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
*/
    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
                  p_restricted_update => p_restricted_update,
			p_chrv_rec		=> p_chrv_tbl(i),
      		p_khrv_rec		=> l_khrv_tbl(i),
			x_chrv_rec		=> x_chrv_tbl(i),
      		x_khrv_rec		=> x_khrv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
*/
EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    	NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    ROLLBACK  TO update_contract_header_pub;
    x_return_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME, 'update_contract_header');
   FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data =>  x_msg_data);
  END update_contract_header;
--------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_contract_header
-- Description     : update contract header to be called from stream update as
--                   we do not have to flip status
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--
--------------------------------------------------------------------------------
  PROCEDURE update_contract_header(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_restricted_update            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_chrv_rec                     OUT NOCOPY okl_okc_migration_pvt.chrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_chrv_rec           okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec           khrv_rec_type;
    l_edit_mode          Varchar2(1);

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;
    l_edit_mode := p_edit_mode;
    g_khrv_rec := l_khrv_rec;
    g_chrv_rec := l_chrv_rec;


--Call pre Vertical Hook :

    l_khrv_rec.id := p_khrv_rec.id;
    l_khrv_rec.object_version_number := p_khrv_rec.object_version_number;
    l_chrv_rec.id := p_chrv_rec.id;
    l_chrv_rec.object_version_number := p_chrv_rec.object_version_number;

--Base API Logic
    okl_contract_pvt.update_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_restricted_update => p_restricted_update,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec,
      p_edit_mode     => p_edit_mode,
      x_chrv_rec      => x_chrv_rec,
      x_khrv_rec      => x_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_khrv_rec  := x_khrv_rec;
     l_chrv_rec  := x_chrv_rec;
     l_edit_mode := p_edit_mode;
     g_khrv_rec  := l_khrv_rec;
     g_chrv_rec  := l_chrv_rec;


    --Call After Vertical  Hook

     --Call After User Hook

      OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);

	Exception
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
  END update_contract_header;


-- Start of comments
--
-- Procedure Name  : delete_contract
-- Description     : deletes lease contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_contract_id                  IN  okc_k_headers_b.id%type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    okl_contract_pvt.delete_contract(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_contract_id      => p_contract_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

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
  END delete_contract;


-- Start of comments
--
-- Procedure Name  : delete_contract_header
-- Description     : deletes contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

--Call pre Vertical Hook :

    okl_contract_pvt.delete_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_khrv_rec := p_khrv_rec;
     l_chrv_rec := p_chrv_rec;

    --Call After Vertical  Hook
     --Call After User Hook


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
  END delete_contract_header;


-- Start of comments
--
-- Procedure Name  : delete_contract_header
-- Description     : deletes contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_khrv_tbl   		khrv_tbl_type := p_khrv_tbl;
  BEGIN
/*
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
*/
    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		delete_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_chrv_rec		=> p_chrv_tbl(i),
      		p_khrv_rec		=> l_khrv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
*/
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

  END delete_contract_header;

-- Start of comments
--
-- Procedure Name  : lock_contract_header
-- Description     : locks contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    okl_contract_pvt.lock_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


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
  END lock_contract_header;


-- Start of comments
--
-- Procedure Name  : lock_contract_header
-- Description     : locks contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_khrv_tbl   		khrv_tbl_type := p_khrv_tbl;
  BEGIN
/*
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
*/
    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		lock_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_chrv_rec		=> p_chrv_tbl(i),
      		p_khrv_rec		=> l_khrv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
*/
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

  END lock_contract_header;

-- -----------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_contract_header
-- Description     : validates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN  okl_okc_migration_pvt.chrv_rec_type,
    p_khrv_rec                     IN  khrv_rec_type) IS

    l_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    l_khrv_rec khrv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    -- dbms_output.put_line('Start validation');
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_khrv_rec := p_khrv_rec;
    l_chrv_rec := p_chrv_rec;

--Call pre Vertical Hook :

    okl_contract_pvt.validate_contract_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_chrv_rec      => l_chrv_rec,
      p_khrv_rec      => l_khrv_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_khrv_rec := p_khrv_rec;
     l_chrv_rec := p_chrv_rec;

    --Call After Vertical  Hook
     --Call After User Hook


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
  END validate_contract_header;


-- Start of comments
--
-- Procedure Name  : validate_contract_header
-- Description     : validates contract header for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_tbl                     IN  okl_okc_migration_pvt.chrv_tbl_type,
    p_khrv_tbl                     IN  khrv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'validate_CONTRACT_HEADER';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_khrv_tbl   		khrv_tbl_type := p_khrv_tbl;
  BEGIN
/*
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
*/
    If (p_chrv_tbl.COUNT > 0) Then
	   i := p_chrv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		validate_contract_header(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_chrv_rec		=> p_chrv_tbl(i),
      		p_khrv_rec		=> l_khrv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_chrv_tbl.LAST);
		i := p_chrv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				 x_msg_data		=> x_msg_data);
*/
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

  END validate_contract_header;

-- -----------------------------------------------------------------------------
-- Contract Line Related Procedure
-- -----------------------------------------------------------------------------

-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

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

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    g_klev_rec := l_klev_rec;
    g_clev_rec := l_clev_rec;

--Call pre Vertical Hook :

    l_klev_rec.id := p_klev_rec.id;
    l_klev_rec.object_version_number := p_klev_rec.object_version_number;
    l_clev_rec.id := p_clev_rec.id;
    l_clev_rec.object_version_number := p_clev_rec.object_version_number;

    okl_contract_pvt.create_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_klev_rec := x_klev_rec;
     l_clev_rec := x_clev_rec;
     g_klev_rec := l_klev_rec;
     g_clev_rec := l_clev_rec;

    --Call After Vertical  Hook
     --Call After User Hook

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
  END create_contract_line;


-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN
/*
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
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      		x_klev_rec		=> x_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END create_contract_line;


-- Start of comments
--
-- Procedure Name  : update_contract_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

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

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    g_klev_rec := l_klev_rec;
    g_clev_rec := l_clev_rec;


	--Call pre Vertical Hook :


    l_klev_rec.id := p_klev_rec.id;
    l_klev_rec.object_version_number := p_klev_rec.object_version_number;
    l_clev_rec.id := p_clev_rec.id;
    l_clev_rec.object_version_number := p_clev_rec.object_version_number;

    okl_contract_pvt.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_klev_rec := x_klev_rec;
     l_clev_rec := x_clev_rec;
     g_klev_rec := l_klev_rec;
     g_clev_rec := l_clev_rec;


    --Call After Vertical  Hook
     --Call After User Hook


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
  END update_contract_line;


-- Start of comments
--
-- Procedure Name  : update_contract_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN
/*
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
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      		x_klev_rec		=> x_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END update_contract_line;
--------------------------------------------------------------------------------
-- Start of comments
-- Bug # 2525554   : introducerd in this bug
-- Procedure Name  : update_contract_line
-- Description     : updates contract line for shadowed contract
--                   takes p_edit_mode as input. It this is send as 'Y' then
--                   contract status will be set to 'INCOMPLETE' after edit,
--                   else it will not be set to 'INCOMPLETE'
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_rec                     OUT NOCOPY okl_okc_migration_pvt.clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

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

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    g_klev_rec := l_klev_rec;
    g_clev_rec := l_clev_rec;


	--Call pre Vertical Hook :


    l_klev_rec.id := p_klev_rec.id;
    l_klev_rec.object_version_number := p_klev_rec.object_version_number;
    l_clev_rec.id := p_clev_rec.id;
    l_clev_rec.object_version_number := p_clev_rec.object_version_number;

    okl_contract_pvt.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      p_edit_mode     => p_edit_mode,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_klev_rec := x_klev_rec;
     l_clev_rec := x_clev_rec;
     g_klev_rec := l_klev_rec;
     g_clev_rec := l_clev_rec;


    --Call After Vertical  Hook
     --Call After User Hook


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
  END update_contract_line;

--------------------------------------------------------------------------------
-- Start of comments
-- Bug # 2525554   : introducerd in this bug
-- Procedure Name  : update_contract_line
-- Description     : updates contract line for shadowed contract
--                   takes p_edit_mode as input. It this is send as 'Y' then
--                   contract status will be set to 'INCOMPLETE' after edit,
--                   else it will not be set to 'INCOMPLETE'
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
  PROCEDURE update_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_edit_mode                    IN  VARCHAR2,
    x_clev_tbl                     OUT NOCOPY okl_okc_migration_pvt.clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_line(
			p_api_version	=> p_api_version,
			p_init_msg_list	=> p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i),
            p_edit_mode     => p_edit_mode,
			x_clev_rec		=> x_clev_tbl(i),
      		x_klev_rec		=> x_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

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

  END update_contract_line;
-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : line can be deleted only when there is no sublines attached
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

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

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    g_klev_rec := l_klev_rec;
    g_clev_rec := l_clev_rec;


	--Call pre Vertical Hook :

    l_klev_rec.id := p_klev_rec.id;
    l_klev_rec.object_version_number := p_klev_rec.object_version_number;
    l_clev_rec.id := p_clev_rec.id;
    l_clev_rec.object_version_number := p_clev_rec.object_version_number;

    okl_contract_pvt.delete_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_klev_rec := p_klev_rec;
     l_clev_rec := p_clev_rec;
     g_klev_rec := l_klev_rec;
     g_clev_rec := l_clev_rec;

    --Call After Vertical  Hook
     --Call After User Hook

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
  END delete_contract_line;


-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : line can be deleted only if there is not sublines attached
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN
/*
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
*/
    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		delete_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : delete contract line, all related objects and sublines
-- Parameters      :
-- Version         : 1.0
-- End of comments
 PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                     IN NUMBER) IS

    l_api_version	CONSTANT	NUMBER      := 1.0;
    l_return_status	VARCHAR2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';

  BEGIN

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

    okl_contract_pvt.delete_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_line_id       => p_line_id);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


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
  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : delete_contract_line
-- Description     : deletes contract line for shadowed contract
-- Business Rules  : if p_delete_cascade_yn is 'Y' deletes all sublines
--                   rules etc. else does not delete line if it has fk
--                   dependents
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_delete_cascade_yn            IN  VARCHAR2) is

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
BEGIN

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

    --call pvt api
    OKL_CONTRACT_PVT.delete_contract_line(
    p_api_version       => p_api_version,
    p_init_msg_list     => p_init_msg_list,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_clev_rec          => p_clev_rec,
    p_klev_rec          => p_klev_rec,
    p_delete_cascade_yn => p_delete_cascade_yn);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

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
  END delete_contract_line;

PROCEDURE delete_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_delete_cascade_yn            IN  varchar2) is
    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
BEGIN

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

    --call pvt api
    OKL_CONTRACT_PVT.delete_contract_line(
    p_api_version       => p_api_version,
    p_init_msg_list     => p_init_msg_list,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_clev_tbl          => p_clev_tbl,
    p_klev_tbl          => p_klev_tbl,
    p_delete_cascade_yn => p_delete_cascade_yn);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

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
  END delete_contract_line;

-- Start of comments
--
-- Procedure Name  : lock_contract_line
-- Description     : locks contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'LOCK_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

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

    okl_contract_pvt.lock_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

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
  END lock_contract_line;


-- Start of comments
--
-- Procedure Name  : lock_contract_line
-- Description     : locks contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE lock_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'lock_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN
/*
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
*/
    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		lock_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END lock_contract_line;


-- Start of comments
--
-- Procedure Name  : validate_contract_line
-- Description     : validates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  okl_okc_migration_pvt.clev_rec_type,
    p_klev_rec                     IN  klev_rec_type) IS

    l_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_klev_rec klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

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

    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    g_klev_rec := l_klev_rec;
    g_clev_rec := l_clev_rec;


	--Call pre Vertical Hook :

    l_klev_rec.id := p_klev_rec.id;
    l_klev_rec.object_version_number := p_klev_rec.object_version_number;
    l_clev_rec.id := p_clev_rec.id;
    l_clev_rec.object_version_number := p_clev_rec.object_version_number;

    okl_contract_pvt.validate_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_klev_rec := p_klev_rec;
     l_clev_rec := p_clev_rec;
     g_klev_rec := l_klev_rec;
     g_clev_rec := l_clev_rec;

    --Call After Vertical  Hook
     --Call After User Hook

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
  END validate_contract_line;


-- Start of comments
--
-- Procedure Name  : validate_contract_line
-- Description     : validates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE validate_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  okl_okc_migration_pvt.clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'validate_CONTRACT_LINE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_klev_tbl   		klev_tbl_type := p_klev_tbl;
  BEGIN
/*
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
*/
    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		validate_contract_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      		p_klev_rec		=> l_klev_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
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

  END validate_contract_line;

PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type) is
begin
           okl_contract_pvt.create_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_rec           =>   p_gvev_rec,
             x_gvev_rec           =>   x_gvev_rec);

end;

  PROCEDURE create_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type)is
begin
           okl_contract_pvt.create_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_tbl           =>   p_gvev_tbl,
             x_gvev_tbl           =>   x_gvev_tbl);

end;

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY okl_okc_migration_pvt.gvev_rec_type)is
begin
           okl_contract_pvt.update_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_rec           =>   p_gvev_rec,
             x_gvev_rec           =>   x_gvev_rec);

end;

  PROCEDURE update_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY okl_okc_migration_pvt.gvev_tbl_type)is
begin
            okl_contract_pvt.update_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_tbl           =>   p_gvev_tbl,
             x_gvev_tbl           =>   x_gvev_tbl);

end;

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type)is
begin
            okl_contract_pvt.delete_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_rec           =>   p_gvev_rec);

end;

  PROCEDURE delete_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type)is
begin
            okl_contract_pvt.delete_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_tbl           =>   p_gvev_tbl);

end;

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type)is
begin
        okl_contract_pvt.lock_governance
            (p_api_version       =>   p_api_version,
             p_init_msg_list      =>   p_init_msg_list,
             x_return_status      =>   x_return_status,
             x_msg_count          =>   x_msg_count,
             x_msg_data           =>   x_msg_data,
             p_gvev_rec           =>   p_gvev_rec);

end;

  PROCEDURE lock_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN okl_okc_migration_pvt.gvev_tbl_type)is
begin
        okl_contract_pvt.lock_governance
        (p_api_version        =>   p_api_version,
         p_init_msg_list      =>   p_init_msg_list,
         x_return_status      =>   x_return_status,
         x_msg_count          =>   x_msg_count,
         x_msg_data           =>   x_msg_data,
         p_gvev_tbl           =>   p_gvev_tbl);

end;

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN okl_okc_migration_pvt.gvev_rec_type)is
begin
        okl_contract_pvt.validate_governance
    (p_api_version       =>   p_api_version,
    p_init_msg_list      =>   p_init_msg_list,
    x_return_status      =>   x_return_status,
    x_msg_count          =>   x_msg_count,
    x_msg_data           =>   x_msg_data,
    p_gvev_rec           =>   p_gvev_rec);

end;

  PROCEDURE validate_governance(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN  okl_okc_migration_pvt.gvev_tbl_type)is
begin
    okl_contract_pvt.validate_governance
    (p_api_version       =>   p_api_version,
    p_init_msg_list      =>   p_init_msg_list,
    x_return_status      =>   x_return_status,
    x_msg_count          =>   x_msg_count,
    x_msg_data           =>   x_msg_data,
    p_gvev_tbl           =>   p_gvev_tbl);
end;

 Procedure get_contract_header_info(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_chr_id_old                   IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_orgId                        IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_custId                       IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_invOrgId                     IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_oldOKL_STATUS                IN  VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
    p_oldOKC_STATUS                IN  VARCHAR2 DEFAULT OKL_API.G_MISS_CHAR,
    x_hdr_tbl                      OUT NOCOPY hdr_tbl_type) is

    l_api_name		    CONSTANT VARCHAR2(30) := 'CONTRACT_HDR_INFO';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	    VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

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

     OKL_CONTRACT_PVT.get_contract_header_info(
     p_api_version      => p_api_version,
     p_init_msg_list    => p_init_msg_list,
     x_return_status    => x_return_status,
     x_msg_count        => x_msg_count,
     x_msg_data         => x_msg_data,
     p_chr_id           => p_chr_id,
     p_chr_id_old       => p_chr_id_old,
     p_orgId            => p_orgid,
     p_custId           => p_custid,
     p_invOrgId         => p_invOrgId,
     p_oldOKL_STATUS    => p_oldOKL_STATUS,
     p_oldOKC_STATUS    => p_oldOKC_STATUS,
     x_hdr_tbl          => x_hdr_tbl);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
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
End get_contract_header_info;

END OKL_CONTRACT_PUB;

/
