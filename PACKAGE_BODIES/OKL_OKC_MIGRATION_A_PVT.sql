--------------------------------------------------------
--  DDL for Package Body OKL_OKC_MIGRATION_A_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OKC_MIGRATION_A_PVT" AS
/* $Header: OKLROMAB.pls 115.9 2004/04/13 11:28:28 rnaik noship $ */
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_OKC_MIGRATION_A_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR(200)  :=  'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) :=  'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) :=  'SQLcode';

---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared catv record type
  -- to OKC catv declared record type
  PROCEDURE migrate_catv(p_from IN catv_rec_type,
                         p_to OUT NOCOPY OKC_K_ARTICLE_PUB.catv_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.cat_id := p_from.cat_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.sav_sae_id := p_from.sav_sae_id;
    p_to.sav_sav_release := p_from.sav_sav_release;
    p_to.sbt_code := p_from.sbt_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.comments := p_from.comments;
    p_to.fulltext_yn := p_from.fulltext_yn;
    p_to.variation_description := p_from.variation_description;
    p_to.name := p_from.name;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.cat_type := p_from.cat_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_catv;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared catv record type
  -- to Locally declared catv record type
  PROCEDURE migrate_catv(p_from IN OKC_K_ARTICLE_PUB.catv_rec_type,
                                   p_to OUT NOCOPY catv_rec_type ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.cat_id := p_from.cat_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.sav_sae_id := p_from.sav_sae_id;
    p_to.sav_sav_release := p_from.sav_sav_release;
    p_to.sbt_code := p_from.sbt_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.comments := p_from.comments;
    p_to.fulltext_yn := p_from.fulltext_yn;
    p_to.variation_description := p_from.variation_description;
    p_to.name := p_from.name;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.cat_type := p_from.cat_type;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate_catv;

---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from Locally declared rgpv record type
  -- to OKC rgpv declared record type
  PROCEDURE migrate_rgpv(p_from IN rgpv_rec_type,
                         p_to OUT NOCOPY OKC_RULE_PUB.rgpv_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.comments := p_from.comments;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate_rgpv;
---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared rgpv record type
  -- to Locally declared rgpv record type
  PROCEDURE migrate_rgpv(p_from IN OKC_RULE_PUB.rgpv_rec_type,
                                   p_to OUT NOCOPY rgpv_rec_type ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.rgd_code := p_from.rgd_code;
    p_to.sat_code := p_from.sat_code;
    p_to.rgp_type := p_from.rgp_type;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_rgp_id := p_from.parent_rgp_id;
    p_to.comments := p_from.comments;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate_rgpv;
 ---------------------------------------------------------------------------------------------------
  -- Local Procedure to migrate from OKC declared msg record type
  -- to Locally declared msg record type
PROCEDURE migrate_msgv(p_from IN OKC_QA_CHECK_PUB.msg_tbl_type,
                                   p_to OUT NOCOPY msg_tbl_type ) IS
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN

--  x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  if (p_from.COUNT>0) then
    i := p_from.FIRST;
    LOOP
      p_to(i).severity := p_from(i).severity;
      p_to(i).name := p_from(i).name;
      p_to(i).description := p_from(i).description;
      p_to(i).package_name := p_from(i).package_name;
      p_to(i).procedure_name := p_from(i).procedure_name;
      p_to(i).error_status := p_from(i).error_status;
      p_to(i).data := p_from(i).data;
      EXIT WHEN (i=p_from.LAST);
      i := p_from.NEXT(i);
    END LOOP;
  end if;

  END migrate_msgv;

---------------------------------------------------------------------------------------------------

-- INSERTING ARTICLE

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type,
    x_catv_rec                     OUT NOCOPY  catv_rec_type) IS

    l_catv_rec		   catv_rec_type;
    l_okc_catv_rec_in  okc_k_article_pub.catv_rec_type;
    l_okc_catv_rec_out okc_k_article_pub.catv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_K_ARTICLE';
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

    l_catv_rec := p_catv_rec;
    -- call procedure in complex API

    migrate_catv(p_from => l_catv_rec,
                 p_to   => l_okc_catv_rec_in);

    OKC_K_ARTICLE_PUB.create_k_article(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_catv_rec		=> l_okc_catv_rec_in,
      x_catv_rec		=> l_okc_catv_rec_out);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    migrate_catv(p_from => l_okc_catv_rec_out,
                 p_to   => x_catv_rec);

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

END insert_row;

-----------------------------------------------------------------------------------------------------------
-- UPDATING ARTICLE

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type,
    x_catv_rec                     OUT NOCOPY  catv_rec_type) IS

    l_catv_rec		   catv_rec_type;
    l_okc_catv_rec_in  okc_k_article_pub.catv_rec_type;
    l_okc_catv_rec_out okc_k_article_pub.catv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_K_ARTICLE';
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

    l_catv_rec := p_catv_rec;
    -- call procedure in complex API

    migrate_catv(p_from => l_catv_rec,
                 p_to   => l_okc_catv_rec_in);

    OKC_K_ARTICLE_PUB.update_k_article(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_catv_rec		=> l_okc_catv_rec_in,
      x_catv_rec		=> l_okc_catv_rec_out);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    migrate_catv(p_from => l_okc_catv_rec_out,
                 p_to   => x_catv_rec);

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

END update_row;

-----------------------------------------------------------------------------------------------------------
-- DELETING ARTICLE

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_catv_rec                     IN  catv_rec_type) IS

    l_catv_rec		   catv_rec_type;
    l_okc_catv_rec_in  okc_k_article_pub.catv_rec_type;
    l_okc_catv_rec_out okc_k_article_pub.catv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_K_ARTICLE';
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

    l_catv_rec := p_catv_rec;
    -- call procedure in complex API

    migrate_catv(p_from => l_catv_rec,
                 p_to   => l_okc_catv_rec_in);

    OKC_K_ARTICLE_PUB.delete_k_article(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_catv_rec		=> l_okc_catv_rec_in);

    -- check return status
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

END delete_row;

---------------------------------------------------------------------
-- MIGRATION API FOR calling api OKC_RULE_PUB
---------------------------------------------------------------------
--INSERTING ROW Rule Groups
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY  rgpv_rec_type) IS

    l_rgpv_rec		   rgpv_rec_type;
    l_okc_rgpv_rec_in  okc_rule_pub.rgpv_rec_type;
    l_okc_rgpv_rec_out okc_rule_pub.rgpv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'INSERT_ROW';
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

    l_rgpv_rec := p_rgpv_rec;
    -- call procedure in complex API

    migrate_rgpv(p_from => l_rgpv_rec,
                 p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.create_rule_group(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_rgpv_rec		=> l_okc_rgpv_rec_in,
      x_rgpv_rec		=> l_okc_rgpv_rec_out);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    migrate_rgpv(p_from => l_okc_rgpv_rec_out,
                 p_to   => x_rgpv_rec);

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

END insert_row;

-----------------------------------------------------------------------------------------------------------
-- UPDATING ROW Rule Groups
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type,
    x_rgpv_rec                     OUT NOCOPY  rgpv_rec_type) IS

    l_rgpv_rec		   rgpv_rec_type;
    l_okc_rgpv_rec_in  okc_rule_pub.rgpv_rec_type;
    l_okc_rgpv_rec_out okc_rule_pub.rgpv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_ROW';
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

    l_rgpv_rec := p_rgpv_rec;
    -- call procedure in complex API

    migrate_rgpv(p_from => l_rgpv_rec,
                 p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.update_rule_group(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_rgpv_rec		=> l_okc_rgpv_rec_in,
      x_rgpv_rec		=> l_okc_rgpv_rec_out);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    migrate_rgpv(p_from => l_okc_rgpv_rec_out,
                 p_to   => x_rgpv_rec);

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

END update_row;

-----------------------------------------------------------------------------------------------------------
-- DELETING ROW Rule Groups

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgpv_rec                     IN  rgpv_rec_type) IS

    l_rgpv_rec		   rgpv_rec_type;
    l_okc_rgpv_rec_in  okc_rule_pub.rgpv_rec_type;
    l_okc_rgpv_rec_out okc_rule_pub.rgpv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_ROW';
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

    l_rgpv_rec := p_rgpv_rec;
    -- call procedure in complex API

    migrate_rgpv(p_from => l_rgpv_rec,
                 p_to   => l_okc_rgpv_rec_in);

    OKC_RULE_PUB.delete_rule_group(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_rgpv_rec		=> l_okc_rgpv_rec_in);

    -- check return status
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

END delete_row;
---------------------------------------------------------------------------------
-- execute_qa_check_list

  PROCEDURE execute_qa_check_list(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY msg_tbl_type) IS

    l_msgv_rec		   qa_msg_rec_type;
    l_okc_msgv_rec_out qa_msg_rec_type;
    l_okc_msgv_tbl_out okc_qa_check_pub.msg_tbl_type;

    l_api_name		CONSTANT VARCHAR2(30) := 'execute_qa_check_list';
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

    OKC_QA_CHECK_PUB.execute_qa_check_list(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_qcl_id          => p_qcl_id,
      p_chr_id          => p_chr_id,
      x_msg_tbl	    	=> l_okc_msgv_tbl_out);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    migrate_msgv(p_from => l_okc_msgv_tbl_out,
                 p_to   => x_msg_tbl);

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

END execute_qa_check_list;
--
-- The below Update allowed has been replaced by full implementation
-- of the same. This is because there is a bug in okc_contract_pub.
--update_allowed. As soon as the bug is solved, the immedialtely below
-- function needs to be used and the full implementation removed.
--FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2 IS
--BEGIN
--  return (OKC_CONTRACT_PUB.Update_Allowed(p_chr_id));
--END Update_Allowed;

  --
  -- function that checkes whether a contract is updateable or not
  -- returns 'Y' if updateable, 'N' if not.
  -- returns OKC_API.G_RET_STS_ERROR or OKC_API.G_RET_STS_UNEXP_ERROR
  -- in case of error
  --
  FUNCTION Update_Allowed(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
	l_sts_code	OKC_ASSENTS.STS_CODE%TYPE;
	l_scs_code	OKC_ASSENTS.SCS_CODE%TYPE;
	l_return_value	VARCHAR2(1) := 'N';

	Cursor l_chrv_csr Is
		SELECT sts_code, scs_code
		FROM OKC_K_HEADERS_B
		WHERE id = p_chr_id;

	Cursor l_astv_csr Is
		SELECT upper(substr(allowed_yn,1,1))
		FROM okc_assents
		WHERE sts_code = l_sts_code
		AND scs_code = l_scs_code
		AND opn_code = 'UPDATE';
  BEGIN
	-- get status from contract headers
	Open l_chrv_csr;
	Fetch l_chrv_csr Into l_sts_code, l_scs_code;
	If l_chrv_csr%FOUND Then
	   Close l_chrv_csr;
	   Open l_astv_csr;
	   Fetch l_astv_csr into l_return_value;
	   If (l_return_value not in ('Y','N')) Then
		 l_return_value := OKC_API.G_RET_STS_UNEXP_ERROR;
	   End If;
	   Close l_astv_csr;
	Else
	   Close l_chrv_csr;
	End If;
	return l_return_value;
  Exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   l_return_value := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Update_Allowed;

END; -- Package Body OKL_OKC_MIGRATION_A_PVT

/
