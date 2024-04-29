--------------------------------------------------------
--  DDL for Package Body OKC_STD_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_STD_ARTICLE_PUB" as
/* $Header: OKCPSAEB.pls 120.0 2005/05/25 18:32:21 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--migration procedures
--migrate std article
FUNCTION migrate_saev(p_saev_rec1 IN saev_rec_type,
                        p_saev_rec2 IN saev_rec_type)
    RETURN saev_rec_type IS
    l_saev_rec saev_rec_type;
  BEGIN
    l_saev_rec.id                    := p_saev_rec1.id;
    l_saev_rec.object_version_number := p_saev_rec1.object_version_number;
    l_saev_rec.created_by            := p_saev_rec1.created_by;
    l_saev_rec.creation_date         := p_saev_rec1.creation_date;
    l_saev_rec.last_updated_by       := p_saev_rec1.last_updated_by;
    l_saev_rec.last_update_date      := p_saev_rec1.last_update_date;
    l_saev_rec.last_update_login     := p_saev_rec1.last_update_login;
    l_saev_rec.sfwt_flag             := p_saev_rec2.sfwt_flag;
    l_saev_rec.name                  := p_saev_rec2.name;
    l_saev_rec.sbt_code              := p_saev_rec2.sbt_code;
    l_saev_rec.attribute_category    := p_saev_rec2.attribute_category;
    l_saev_rec.attribute1            := p_saev_rec2.attribute1;
    l_saev_rec.attribute2            := p_saev_rec2.attribute2;
    l_saev_rec.attribute3            := p_saev_rec2.attribute3;
    l_saev_rec.attribute4            := p_saev_rec2.attribute4;
    l_saev_rec.attribute5            := p_saev_rec2.attribute5;
    l_saev_rec.attribute6            := p_saev_rec2.attribute6;
    l_saev_rec.attribute7            := p_saev_rec2.attribute7;
    l_saev_rec.attribute8            := p_saev_rec2.attribute8;
    l_saev_rec.attribute9            := p_saev_rec2.attribute9;
    l_saev_rec.attribute10           := p_saev_rec2.attribute10;
    l_saev_rec.attribute11           := p_saev_rec2.attribute11;
    l_saev_rec.attribute12           := p_saev_rec2.attribute12;
    l_saev_rec.attribute13           := p_saev_rec2.attribute13;
    l_saev_rec.attribute14           := p_saev_rec2.attribute14;
    l_saev_rec.attribute15           := p_saev_rec2.attribute15;
    RETURN (l_saev_rec);
  END migrate_saev;

--migrate std art classings
FUNCTION migrate_sacv(p_sacv_rec1 IN sacv_rec_type,
                        p_sacv_rec2 IN sacv_rec_type)
    RETURN sacv_rec_type IS
    l_sacv_rec sacv_rec_type;
  BEGIN
    l_sacv_rec.id                    := p_sacv_rec1.id;
    l_sacv_rec.object_version_number := p_sacv_rec1.object_version_number;
    l_sacv_rec.created_by            := p_sacv_rec1.created_by;
    l_sacv_rec.creation_date         := p_sacv_rec1.creation_date;
    l_sacv_rec.last_updated_by       := p_sacv_rec1.last_updated_by;
    l_sacv_rec.last_update_date      := p_sacv_rec1.last_update_date;
    l_sacv_rec.last_update_login     := p_sacv_rec1.last_update_login;
    l_sacv_rec.sat_code	             := p_sacv_rec2.sat_code;
    l_sacv_rec.price_type            := p_sacv_rec2.price_type;
    l_sacv_rec.scs_code              := p_sacv_rec2.scs_code;
    RETURN (l_sacv_rec);
  END migrate_sacv;

--migrate std art incmpts
FUNCTION migrate_saiv(p_saiv_rec1 IN saiv_rec_type,
                        p_saiv_rec2 IN saiv_rec_type)
    RETURN saiv_rec_type IS
    l_saiv_rec saiv_rec_type;
  BEGIN
    l_saiv_rec.object_version_number := p_saiv_rec1.object_version_number;
    l_saiv_rec.created_by            := p_saiv_rec1.created_by;
    l_saiv_rec.creation_date         := p_saiv_rec1.creation_date;
    l_saiv_rec.last_updated_by       := p_saiv_rec1.last_updated_by;
    l_saiv_rec.last_update_date      := p_saiv_rec1.last_update_date;
    l_saiv_rec.last_update_login     := p_saiv_rec1.last_update_login;
    l_saiv_rec.sae_id	             := p_saiv_rec2.sae_id;
    l_saiv_rec.sae_id_for            := p_saiv_rec2.sae_id_for;
    RETURN (l_saiv_rec);
  END migrate_saiv;

--migrate std article version
FUNCTION migrate_savv(p_savv_rec1 IN savv_rec_type,
                        p_savv_rec2 IN savv_rec_type)
    RETURN savv_rec_type IS
    l_savv_rec savv_rec_type;
  BEGIN
    l_savv_rec.object_version_number := p_savv_rec1.object_version_number;
    l_savv_rec.created_by            := p_savv_rec1.created_by;
    l_savv_rec.creation_date         := p_savv_rec1.creation_date;
    l_savv_rec.last_updated_by       := p_savv_rec1.last_updated_by;
    l_savv_rec.last_update_date      := p_savv_rec1.last_update_date;
    l_savv_rec.last_update_login     := p_savv_rec1.last_update_login;
    l_savv_rec.sfwt_flag             := p_savv_rec2.sfwt_flag;
    l_savv_rec.sae_id                := p_savv_rec2.sae_id;
    l_savv_rec.sav_release           := p_savv_rec2.sav_release;
    l_savv_rec.date_active           := p_savv_rec2.date_active;
    l_savv_rec.text                  := p_savv_rec2.text;
    l_savv_rec.short_description     := p_savv_rec2.short_description;
    l_savv_rec.attribute_category    := p_savv_rec2.attribute_category;
    l_savv_rec.attribute1            := p_savv_rec2.attribute1;
    l_savv_rec.attribute2            := p_savv_rec2.attribute2;
    l_savv_rec.attribute3            := p_savv_rec2.attribute3;
    l_savv_rec.attribute4            := p_savv_rec2.attribute4;
    l_savv_rec.attribute5            := p_savv_rec2.attribute5;
    l_savv_rec.attribute6            := p_savv_rec2.attribute6;
    l_savv_rec.attribute7            := p_savv_rec2.attribute7;
    l_savv_rec.attribute8            := p_savv_rec2.attribute8;
    l_savv_rec.attribute9            := p_savv_rec2.attribute9;
    l_savv_rec.attribute10           := p_savv_rec2.attribute10;
    l_savv_rec.attribute11           := p_savv_rec2.attribute11;
    l_savv_rec.attribute12           := p_savv_rec2.attribute12;
    l_savv_rec.attribute13           := p_savv_rec2.attribute13;
    l_savv_rec.attribute14           := p_savv_rec2.attribute14;
    l_savv_rec.attribute15           := p_savv_rec2.attribute15;
    RETURN (l_savv_rec);
  END migrate_savv;


--migrate std art set mems
FUNCTION migrate_samv(p_samv_rec1 IN samv_rec_type,
                        p_samv_rec2 IN samv_rec_type)
    RETURN samv_rec_type IS
    l_samv_rec samv_rec_type;
  BEGIN
    l_samv_rec.object_version_number := p_samv_rec1.object_version_number;
    l_samv_rec.created_by            := p_samv_rec1.created_by;
    l_samv_rec.creation_date         := p_samv_rec1.creation_date;
    l_samv_rec.last_updated_by       := p_samv_rec1.last_updated_by;
    l_samv_rec.last_update_date      := p_samv_rec1.last_update_date;
    l_samv_rec.last_update_login     := p_samv_rec1.last_update_login;
    l_samv_rec.sae_id	             := p_samv_rec2.sae_id;
    l_samv_rec.sat_code                := p_samv_rec2.sat_code;
    RETURN (l_samv_rec);
  END migrate_samv;
--Procedures pertaining to Setting up of a standard Article

 PROCEDURE add_language IS
 BEGIN
    OKC_STD_ARTICLE_PVT.add_language;
 END add_language;

--Procedures pertaining to Std Article Objects

 PROCEDURE Create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type,
	x_saev_rec		OUT NOCOPY saev_rec_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
 BEGIN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
   	 OKC_STD_ARTICLE_PVT.create_std_article(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
	    p_saev_rec	=>	 p_saev_rec,
	    p_savv_tbl	=>	 p_savv_tbl,
	    p_saiv_tbl	=>	 p_saiv_tbl,
	    p_samv_tbl	=>	 p_samv_tbl,
	    x_saev_rec	=>	 x_saev_rec,
	    x_savv_tbl	=>	 x_savv_tbl,
	    x_saiv_tbl	=>	 x_saiv_tbl,
	    x_samv_tbl	=>	 x_samv_tbl);

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END Create_std_article;



 PROCEDURE Update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type,
	x_saev_rec		OUT NOCOPY saev_rec_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
 BEGIN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
   	 OKC_STD_ARTICLE_PVT.update_std_article(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
	    p_saev_rec	=>	 p_saev_rec,
	    p_savv_tbl	=>	 p_savv_tbl,
	    p_saiv_tbl	=>	 p_saiv_tbl,
	    p_samv_tbl	=>	 p_samv_tbl,
	    x_saev_rec	=>	 x_saev_rec,
	    x_savv_tbl	=>	 x_savv_tbl,
	    x_saiv_tbl	=>	 x_saiv_tbl,
	    x_samv_tbl	=>	 x_samv_tbl);

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END Update_std_article;



 PROCEDURE Validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	p_savv_tbl		IN savv_tbl_type,
	p_saiv_tbl		IN saiv_tbl_type,
	p_samv_tbl		IN samv_tbl_type) IS
  BEGIN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
   	 OKC_STD_ARTICLE_PVT.validate_std_article(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
	    p_saev_rec	=>	 p_saev_rec,
	    p_savv_tbl	=>	 p_savv_tbl,
	    p_saiv_tbl	=>	 p_saiv_tbl,
	    p_samv_tbl	=>	 p_samv_tbl);

  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END Validate_std_article;



PROCEDURE Create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'CREATE_STD_ARTICLE';
     l_saev_rec                     saev_rec_type := p_saev_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saev_rec := l_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_saev_rec := migrate_saev(l_saev_rec, g_saev_rec);

     OKC_STD_ARTICLE_PVT.create_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => l_saev_rec,
                         x_saev_rec            => x_saev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saev_rec := x_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END Create_std_article;

PROCEDURE Create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       		create_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i),
                         x_saev_rec            => x_saev_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Create_std_article;


PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_STD_ARTICLE';
     l_saev_rec                     saev_rec_type := p_saev_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saev_rec := l_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_saev_rec := migrate_saev(l_saev_rec, g_saev_rec);

     OKC_STD_ARTICLE_PVT.update_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => l_saev_rec,
                         x_saev_rec            => x_saev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saev_rec := x_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END update_std_article;


PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       		update_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i),
                         x_saev_rec            => x_saev_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END update_std_article;



PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_STD_ARTICLE';
     l_saev_rec                     saev_rec_type := p_saev_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saev_rec := l_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_STD_ARTICLE_PVT.delete_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => l_saev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saev_rec := l_saev_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END delete_std_article;

PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       		delete_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_article;


PROCEDURE validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
 BEGIN

     OKC_STD_ARTICLE_PVT.validate_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_rec);


 END validate_std_article;

PROCEDURE validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       		validate_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_std_article;


PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
 BEGIN
   	OKC_STD_ARTICLE_PVT.lock_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_rec);

 END lock_std_article;


PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       		lock_std_article(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_article;


PROCEDURE validate_name(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_Name(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_saev_rec            => p_saev_rec);

End Validate_name;

PROCEDURE validate_name(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       	      Validate_Name(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saev_rec            => p_saev_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_name;

PROCEDURE validate_no_k_attached(
        p_saev_rec                     IN saev_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_no_k_attached(
                         		x_return_status       => x_return_status,
                         		p_saev_rec            => p_saev_rec);

End Validate_no_k_attached;

PROCEDURE validate_no_k_attached(
        p_saev_tbl	              IN saev_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saev_tbl.COUNT > 0 THEN
       i := p_saev_tbl.FIRST;
       LOOP
       	      Validate_no_k_attached(
                         x_return_status       => l_return_status,
                         p_saev_rec            => p_saev_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saev_tbl.LAST);
       		i := p_saev_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End Validate_no_k_attached;

PROCEDURE Create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type) IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'CREATE_STD_ART_VERSION';
     l_savv_rec                     savv_rec_type := p_savv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_savv_rec := l_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_savv_rec := migrate_savv(l_savv_rec, g_savv_rec);

     OKC_STD_ARTICLE_PVT.create_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => l_savv_rec,
                         x_savv_rec            => x_savv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_savv_rec := x_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END Create_std_art_version;


PROCEDURE Create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       		create_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i),
                         x_savv_rec            => x_savv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END Create_std_art_version;



PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_STD_ART_VERSION';
     l_savv_rec                     savv_rec_type := p_savv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_savv_rec := l_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_savv_rec := migrate_savv(l_savv_rec, g_savv_rec);

     OKC_STD_ARTICLE_PVT.update_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => l_savv_rec,
                         x_savv_rec            => x_savv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_savv_rec := x_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END update_std_art_version;

PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       		update_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i),
                         x_savv_rec            => x_savv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END update_std_art_version;


PROCEDURE  lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
 BEGIN
   	OKC_STD_ARTICLE_PVT.lock_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_rec);

 END lock_std_art_version;

PROCEDURE lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       		lock_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_art_version;

PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_STD_ART_VERSION';
     l_savv_rec                     savv_rec_type := p_savv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_savv_rec := l_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_savv_rec := migrate_savv(l_savv_rec, g_savv_rec);

     OKC_STD_ARTICLE_PVT.delete_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => l_savv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_savv_rec := l_savv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END delete_std_art_version;

PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       		delete_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_art_version;

PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
 BEGIN

     OKC_STD_ARTICLE_PVT.validate_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_rec);


 END validate_std_art_version;

PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
      i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       		validate_std_art_version(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_std_art_version;

PROCEDURE validate_sav_release(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_sav_release(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_savv_rec            => p_savv_rec);

End Validate_sav_release;

PROCEDURE validate_sav_release(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_sav_release(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_sav_release;


PROCEDURE validate_date_active(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_date_active(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_savv_rec            => p_savv_rec);

End Validate_date_active;

PROCEDURE validate_date_active(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_date_active(p_api_version   => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_date_active;


PROCEDURE validate_updatable(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_updatable(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_savv_rec            => p_savv_rec);

End Validate_Updatable;

PROCEDURE validate_Updatable(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_Updatable(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End Validate_Updatable;

PROCEDURE validate_no_k_attached(
        p_savv_rec                     IN savv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_no_k_attached(
                         		x_return_status       => x_return_status,
                         		p_savv_rec            => p_savv_rec);

End Validate_no_k_attached;

PROCEDURE validate_no_k_attached(
        p_savv_tbl	              IN savv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_no_k_attached(
                         x_return_status       => l_return_status,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End Validate_no_k_attached;

PROCEDURE validate_latest(
        p_savv_rec                     IN savv_rec_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_latest(
                         		x_return_status       => x_return_status,
                         		p_savv_rec            => p_savv_rec);

End Validate_latest;

PROCEDURE validate_latest(
        p_savv_tbl	              IN savv_tbl_type,
        x_return_status                OUT NOCOPY VARCHAR2) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_latest(
                         x_return_status       => l_return_status,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End Validate_latest;

/*
PROCEDURE validate_short_description(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_short_description(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_savv_rec            => p_savv_rec);

End Validate_short_description;

PROCEDURE validate_short_description(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_savv_tbl.COUNT > 0 THEN
       i := p_savv_tbl.FIRST;
       LOOP
       	      Validate_short_description(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_savv_rec            => p_savv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_savv_tbl.LAST);
       		i := p_savv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_short_description;
*/

PROCEDURE Create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'CREATE_STD_ART_INCMPT';
     l_saiv_rec                     saiv_rec_type := p_saiv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saiv_rec := l_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_saiv_rec := migrate_saiv(l_saiv_rec, g_saiv_rec);

     OKC_STD_ARTICLE_PVT.create_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => l_saiv_rec,
                         x_saiv_rec            => x_saiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saiv_rec := x_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END Create_std_art_incmpt;


PROCEDURE Create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       		create_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i),
                         x_saiv_rec            => x_saiv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END Create_std_art_incmpt;

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_STD_ART_INCMPT';
     l_saiv_rec                     saiv_rec_type := p_saiv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saiv_rec := l_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_saiv_rec := migrate_saiv(l_saiv_rec, g_saiv_rec);

     OKC_STD_ARTICLE_PVT.update_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => l_saiv_rec,
                         x_saiv_rec            => x_saiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saiv_rec := x_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END update_std_art_incmpt;

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       		update_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i),
                         x_saiv_rec            => x_saiv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END update_std_art_incmpt;

PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS
 BEGIN
   	OKC_STD_ARTICLE_PVT.lock_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_rec);

 END lock_std_art_incmpt;

PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       		lock_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_art_incmpt;

PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_STD_ART_INCMPT';
     l_saiv_rec                     saiv_rec_type := p_saiv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_saiv_rec := l_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_saiv_rec := migrate_saiv(l_saiv_rec, g_saiv_rec);

     OKC_STD_ARTICLE_PVT.delete_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => l_saiv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_saiv_rec := l_saiv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END delete_std_art_incmpt;

PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS
      i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       		delete_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_art_incmpt;

PROCEDURE validate_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS
 BEGIN

     OKC_STD_ARTICLE_PVT.validate_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_rec);

 END validate_std_art_incmpt;


PROCEDURE validate_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       		validate_std_art_incmpt(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_std_art_incmpt;


PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_Unique(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_saiv_rec            => p_saiv_rec);

End Validate_unique;

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_saiv_tbl.COUNT > 0 THEN
       i := p_saiv_tbl.FIRST;
       LOOP
       	      Validate_unique(p_api_version   => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_saiv_rec            => p_saiv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_saiv_tbl.LAST);
       		i := p_saiv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_unique;


PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'CREATE_STD_ART_CLASSING';
     l_sacv_rec                     sacv_rec_type := p_sacv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_sacv_rec := l_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_sacv_rec := migrate_sacv(l_sacv_rec, g_sacv_rec);

     OKC_STD_ARTICLE_PVT.create_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => l_sacv_rec,
                         x_sacv_rec            => x_sacv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_sacv_rec := x_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END create_std_art_classing;

PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       		create_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i),
                         x_sacv_rec            => x_sacv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END create_std_art_classing;

PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_STD_ART_CLASSING';
     l_sacv_rec                     sacv_rec_type := p_sacv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_sacv_rec := l_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_sacv_rec := migrate_sacv(l_sacv_rec, g_sacv_rec);

     OKC_STD_ARTICLE_PVT.update_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => l_sacv_rec,
                         x_sacv_rec            => x_sacv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_sacv_rec := x_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END update_std_art_classing;



PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       		update_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i),
                         x_sacv_rec            => x_sacv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END update_std_art_classing;


PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
 BEGIN
   	OKC_STD_ARTICLE_PVT.lock_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_rec);

 END lock_std_art_classing;

PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type)IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       		lock_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_art_classing;


PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_STD_ART_CLASSING';
     l_sacv_rec                     sacv_rec_type := p_sacv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_sacv_rec := l_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_sacv_rec := migrate_sacv(l_sacv_rec, g_sacv_rec);

     OKC_STD_ARTICLE_PVT.delete_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => l_sacv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_sacv_rec := l_sacv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END delete_std_art_classing;

PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       		delete_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_art_classing;


PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
 BEGIN
   OKC_STD_ARTICLE_PVT.validate_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_rec);

 END validate_std_art_classing;


PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       		validate_std_art_classing(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_std_art_classing;

PROCEDURE validate_price_type(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_price_type(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_sacv_rec            => p_sacv_rec);

End Validate_price_type;

PROCEDURE validate_price_type(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       	      Validate_price_type(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_price_type;

PROCEDURE validate_scs_code(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_scs_code(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_sacv_rec            => p_sacv_rec);

End Validate_scs_code;

PROCEDURE validate_scs_code(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_sacv_tbl.COUNT > 0 THEN
       i := p_sacv_tbl.FIRST;
       LOOP
       	      Validate_scs_code(p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_sacv_rec            => p_sacv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_sacv_tbl.LAST);
       		i := p_sacv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_scs_code;

PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'CREATE_STD_ART_SET_MEM';
     l_samv_rec                     samv_rec_type := p_samv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_samv_rec := l_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_samv_rec := migrate_samv(l_samv_rec, g_samv_rec);

     OKC_STD_ARTICLE_PVT.create_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => l_samv_rec,
                         x_samv_rec            => x_samv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_samv_rec := x_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END create_std_art_set_mem;


PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       		create_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i),
                         x_samv_rec            => x_samv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END create_std_art_set_mem;

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_STD_ART_SET_MEM';
     l_samv_rec                     samv_rec_type := p_samv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_samv_rec := l_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_samv_rec := migrate_samv(l_samv_rec, g_samv_rec);

     OKC_STD_ARTICLE_PVT.update_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => l_samv_rec,
                         x_samv_rec            => x_samv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_samv_rec := x_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
END update_std_art_set_mem;

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       		update_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i),
                         x_samv_rec            => x_samv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END update_std_art_set_mem;

PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
 BEGIN
   	OKC_STD_ARTICLE_PVT.lock_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_rec);

END lock_std_art_set_mem;

PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       		lock_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_art_set_mem;


PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_STD_ART_SET_MEM';
     l_samv_rec                     samv_rec_type := p_samv_rec;
 BEGIN
     l_return_status := OKC_API.START_ACTIVITY(l_api_name,
	 				      p_init_msg_list,
		 			      '_PUB',
                                              x_return_status);
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     -- Call user hook for BEFORE
     g_samv_rec := l_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     l_samv_rec := migrate_samv(l_samv_rec, g_samv_rec);

     OKC_STD_ARTICLE_PVT.delete_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => l_samv_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- Call user hook for AFTER
     g_samv_rec := l_samv_rec;
     okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
 END delete_std_art_set_mem;

PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       		delete_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_art_set_mem;


PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
  BEGIN

     OKC_STD_ARTICLE_PVT.validate_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => x_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_rec);

END validate_std_art_set_mem;

PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       		validate_std_art_set_mem(
                         p_api_version         => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i));
       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_std_art_set_mem;

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
BEGIN
	OKC_STD_ARTICLE_PVT.Validate_Unique(p_api_version         => p_api_version,
                         		p_init_msg_list       => p_init_msg_list,
                         		x_return_status       => x_return_status,
                         		x_msg_count           => x_msg_count,
                         		x_msg_data            => x_msg_data,
                         		p_samv_rec            => p_samv_rec);

End Validate_unique;

PROCEDURE validate_unique(
	p_api_version 		IN NUMBER,
	p_init_msg_list         IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS

     i				    NUMBER := 0;
     l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 BEGIN
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF p_samv_tbl.COUNT > 0 THEN
       i := p_samv_tbl.FIRST;
       LOOP
       	      Validate_unique(p_api_version   => p_api_version,
                         p_init_msg_list       => p_init_msg_list,
                         x_return_status       => l_return_status,
                         x_msg_count           => x_msg_count,
                         x_msg_data            => x_msg_data,
                         p_samv_rec            => p_samv_tbl(i));

       		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         		IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           			x_return_status := l_return_status;
           			raise G_EXCEPTION_HALT_PROCESSING;
         		ELSE
           			x_return_status := l_return_status;
         		END IF;
       		END IF;
       		EXIT WHEN (i = p_samv_tbl.LAST);
       		i := p_samv_tbl.NEXT(i);
       END LOOP;
     END IF;
   EXCEPTION
     WHEN G_EXCEPTION_HALT_PROCESSING THEN
       NULL;
     WHEN OTHERS THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => g_unexpected_error,
                           p_token1        => g_sqlcode_token,
                           p_token1_value  => sqlcode,
                           p_token2        => g_sqlerrm_token,
                           p_token2_value  => sqlerrm);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
End Validate_unique;

-- BUG 3188215 - KOL: BACKWARD COMPATIBILITY CHANGES
-- modified the function to call the new api function
-- art_used_in_contracts
FUNCTION used_in_contracts
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_sav_sav_release          IN   okc_k_articles_b.sav_sav_release%TYPE
)
RETURN VARCHAR2 IS

BEGIN

  RETURN okc_std_article_pvt.art_used_in_contracts(p_sav_sae_id,p_sav_sav_release);

END used_in_contracts;

FUNCTION empclob
RETURN CLOB IS

BEGIN
   RETURN okc_std_article_pvt.empclob;

END empclob;

FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE
)
RETURN VARCHAR2 IS

BEGIN

  RETURN okc_std_article_pvt.latest_release(p_sav_sae_id);

END latest_release;

--BUG 3188215 - KOL: BACKWARD COMPATIBILITY CHANGES
-- modified the function to call the new api function
-- latest_art_release
FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE
)
RETURN VARCHAR2 IS

BEGIN

  RETURN okc_std_article_pvt.latest_art_release(p_sav_sae_id,p_article_version_number);

END latest_release;

-- BUG 3188215 - KOL: BACKWARD COMPATIBILITY CHANGES
-- modified the function to call the new api function
-- latest_or_future_art_release
FUNCTION latest_or_future_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE,
  p_date_active              IN   okc_article_versions.start_date%TYPE
)
RETURN VARCHAR2 IS

BEGIN

  RETURN okc_std_article_pvt.latest_or_future_art_release(p_sav_sae_id,p_article_version_number,p_date_active);

END latest_or_future_release;


END okc_std_article_pub;

/
