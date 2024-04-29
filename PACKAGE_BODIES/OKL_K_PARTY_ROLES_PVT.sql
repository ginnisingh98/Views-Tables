--------------------------------------------------------
--  DDL for Package Body OKL_K_PARTY_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_K_PARTY_ROLES_PVT" AS
/* $Header: OKLRKPLB.pls 120.1 2006/02/24 21:31:13 rpillay noship $ */
  -- GLOBAL VARIABLES

  G_API_TYPE		CONSTANT VARCHAR2(4) := '_PVT';

procedure print(s in varchar2) is
begin
  fnd_file.put_line(fnd_file.log, s);
end;
--------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_k_party_role
-- Description     : creates contract party role
-- Bug# :
--
--
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
--------------------------------------------------------------------------------
  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type,
    x_kplv_rec                     OUT NOCOPY kplv_rec_type) IS

    l_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    l_kplv_rec kplv_rec_type;
    l_api_name       CONSTANT VARCHAR2(30) := 'CREATE_K_PARTY_ROLE';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_return_status  VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

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

     --Bug# 4959361
     IF p_cplv_rec.cle_id IS NOT NULL THEN
       OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => p_cplv_rec.cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     --Bug# 4959361

    l_kplv_rec := p_kplv_rec;
    l_cplv_rec := p_cplv_rec;

    okl_okc_migration_pvt.create_k_party_role(
	 p_api_version    => p_api_version,
	 p_init_msg_list  => p_init_msg_list,
	 x_return_status  => x_return_status,
	 x_msg_count      => x_msg_count,
	 x_msg_data    	  => x_msg_data,
	 p_cplv_rec       => l_cplv_rec,
	 x_cplv_rec       => x_cplv_rec);


    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_kplv_rec.ID := x_cplv_rec.ID;


    OKL_KPL_PVT.Insert_Row(
      p_api_version     => p_api_version,
      p_init_msg_list   => p_init_msg_list,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_kplv_rec        => l_kplv_rec,
      x_kplv_rec        => x_kplv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
                         x_msg_data   => x_msg_data);
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
  END create_k_party_role;


-- Start of comments
--
-- Procedure Name  : create_k_party_role
-- Description     : creates contract party role
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY okl_okc_migration_pvt.cplv_tbl_type,
    x_kplv_tbl                     OUT NOCOPY kplv_tbl_type) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_K_PARTY_ROLE';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status    VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    i                   NUMBER;
    l_kplv_tbl   		kplv_tbl_type;
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

    l_kplv_tbl := p_kplv_tbl;
    If (p_cplv_tbl.COUNT > 0) Then
	   i := p_cplv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_k_party_role(
			p_api_version    => p_api_version,
			p_init_msg_list  => p_init_msg_list,
			x_return_status  => x_return_status,
			x_msg_count      => x_msg_count,
			x_msg_data       => x_msg_data,
			p_cplv_rec       => p_cplv_tbl(i),
      		        p_kplv_rec       => l_kplv_tbl(i),
			x_cplv_rec       => x_cplv_tbl(i),
      		        x_kplv_rec       => x_kplv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cplv_tbl.LAST);
		i := p_cplv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data	 => x_msg_data);
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

  END create_k_party_role;


--------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : update_k_party_role
-- Description     : updates party role
--Bug# :
--
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------
  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type,
    x_cplv_rec                     OUT NOCOPY okl_okc_migration_pvt.cplv_rec_type,
    x_kplv_rec                     OUT NOCOPY kplv_rec_type) IS

    l_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    l_kplv_rec kplv_rec_type;

    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_K_PARTY_ROLE';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    cursor l_kplv_csr(l_id IN NUMBER) is
	select 'x'
	from OKL_K_PARTY_ROLES_V
	where id = l_id;
    l_dummy_var VARCHAR2(1) := '?';

    lx_cplv_rec         OKL_OKC_MIGRATION_PVT.cplv_rec_type;

     --Bug# 4959361
     CURSOR l_cpl_csr(p_cpl_id IN NUMBER) IS
     SELECT cle_id
     FROM okc_k_party_roles_b cpl
     WHERE cpl.id = p_cpl_id;

     l_cpl_rec l_cpl_csr%ROWTYPE;
     --Bug# 4959361

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

    --Bug# 4959361
    OPEN l_cpl_csr(p_cpl_id => p_cplv_rec.id);
    FETCH l_cpl_csr INTO l_cpl_rec;
    CLOSE l_cpl_csr;

    IF l_cpl_rec.cle_id IS NOT NULL THEN
      OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_cpl_rec.cle_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug# 4959361

    l_kplv_rec := p_kplv_rec;
    l_cplv_rec := p_cplv_rec;

     okl_okc_migration_pvt.update_k_party_role
     (
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count     	=> x_msg_count,
       x_msg_data      	=> x_msg_data,
       p_cplv_rec       => l_cplv_rec,
       x_cplv_rec       => x_cplv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- get id from OKC record
    l_kplv_rec.ID := x_cplv_rec.ID;

    -- check whether the shadow is present
    open l_kplv_csr(l_kplv_rec.id);
    fetch l_kplv_csr into l_dummy_var;
    close l_kplv_csr;

    -- call procedure in complex API
    -- if l_dummy_var is changed then the shadow is present
    -- and we need to update it, otherwise we need to create the shadow
    if (l_dummy_var = 'x') THEN
        OKL_KPL_PVT.Update_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_kplv_rec		=> l_kplv_rec,
            x_kplv_rec		=> x_kplv_rec);
    else
        OKL_KPL_PVT.Insert_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_kplv_rec		=> l_kplv_rec,
            x_kplv_rec		=> x_kplv_rec);
    end if;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
		         x_msg_data     => x_msg_data);
  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
      if l_kplv_csr%ISOPEN then
	  close l_kplv_csr;
	end if;

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
      if l_kplv_csr%ISOPEN then
	  close l_kplv_csr;
	end if;

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
      if l_kplv_csr%ISOPEN then
	  close l_kplv_csr;
	end if;

  END update_k_party_role;

-- Start of comments
--
-- Procedure Name  : update_k_party_role
-- Description     : updates contract party role
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY okl_okc_migration_pvt.cplv_tbl_type,
    x_kplv_tbl                     OUT NOCOPY kplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_PARTY_ROLE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_kplv_tbl   		kplv_tbl_type := p_kplv_tbl;
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

    If (p_cplv_tbl.COUNT > 0) Then
	   i := p_cplv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_k_party_role(
			p_api_version     => p_api_version,
			p_init_msg_list   => p_init_msg_list,
			x_return_status   => x_return_status,
			x_msg_count       => x_msg_count,
			x_msg_data        => x_msg_data,
			p_cplv_rec        => p_cplv_tbl(i),
         		p_kplv_rec        => l_kplv_tbl(i),
			x_cplv_rec        => x_cplv_tbl(i),
      	                x_kplv_rec        => x_kplv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cplv_tbl.LAST);
		i := p_cplv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);
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

  END update_k_party_role;

-- Start of comments
--
-- Procedure Name  : delete_k_party_role
-- Description     : deletes contract party role
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  okl_okc_migration_pvt.cplv_rec_type,
    p_kplv_rec                     IN  kplv_rec_type) IS

    l_cplv_rec okl_okc_migration_pvt.cplv_rec_type;
    l_kplv_rec kplv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_K_PARTY_ROLE';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;

    --Bug# 4959361
    CURSOR l_cpl_csr(p_cpl_id IN NUMBER) IS
    SELECT cle_id
    FROM okc_k_party_roles_b cpl
    WHERE cpl.id = p_cpl_id;

    l_cpl_rec l_cpl_csr%ROWTYPE;
    --Bug# 4959361

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

    --Bug# 4959361
    OPEN l_cpl_csr(p_cpl_id => p_cplv_rec.id);
    FETCH l_cpl_csr INTO l_cpl_rec;
    CLOSE l_cpl_csr;

    IF l_cpl_rec.cle_id IS NOT NULL THEN
      OKL_LLA_UTIL_PVT.check_line_update_allowed
         (p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_cle_id          => l_cpl_rec.cle_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    --Bug# 4959361

    l_kplv_rec := p_kplv_rec;
    l_cplv_rec := p_cplv_rec;

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.delete_k_party_role(
	 p_api_version	 => p_api_version,
	 p_init_msg_list => p_init_msg_list,
	 x_return_status => x_return_status,
	 x_msg_count     => x_msg_count,
	 x_msg_data      => x_msg_data,
	 p_cplv_rec	 => l_cplv_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- call procedure in complex API
        OKL_KPL_PVT.Delete_Row(
	    p_api_version	=> p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_kplv_rec		=> p_kplv_rec);

    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data);
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
  END delete_k_party_role;


-- Start of comments
--
-- Procedure Name  : delete_k_party_role
-- Description     : deletes contract party role
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE delete_k_party_role(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_tbl                     IN  okl_okc_migration_pvt.cplv_tbl_type,
    p_kplv_tbl                     IN  kplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_K_PARTY_ROLE';
    l_api_version 	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKL_API.G_RET_STS_SUCCESS;
    i				NUMBER;
    l_kplv_tbl   		kplv_tbl_type := p_kplv_tbl;
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

    If (p_cplv_tbl.COUNT > 0) Then
	   i := p_cplv_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		delete_k_party_role(
			p_api_version   => p_api_version,
			p_init_msg_list => p_init_msg_list,
			x_return_status => x_return_status,
			x_msg_count     => x_msg_count,
			x_msg_data      => x_msg_data,
			p_cplv_rec      => p_cplv_tbl(i),
      	    	        p_kplv_rec      => l_kplv_tbl(i));

		If x_return_status <> OKL_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cplv_tbl.LAST);
		i := p_cplv_tbl.NEXT(i);
	   END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
    End If;

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

  END delete_k_party_role;

END OKL_K_PARTY_ROLES_PVT;

/
