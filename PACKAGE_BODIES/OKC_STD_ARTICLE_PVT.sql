--------------------------------------------------------
--  DDL for Package Body OKC_STD_ARTICLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_STD_ARTICLE_PVT" as
/* $Header: OKCCSAEB.pls 120.0 2005/05/25 22:30:18 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Procedures pertaining to Setting up of a standard Article

 PROCEDURE add_language IS
 BEGIN
    OKC_SAE_PVT.add_language;
    OKC_SAV_PVT.add_language;
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
	l_savv_tbl		savv_tbl_type := p_savv_tbl;
   	l_saiv_tbl		saiv_tbl_type := p_saiv_tbl;
   	l_samv_tbl		samv_tbl_type := p_samv_tbl;
   	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    	i			NUMBER := 0;
 BEGIN
   	 create_std_article(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saev_rec,
	    x_saev_rec);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

        IF (l_savv_tbl.COUNT > 0) THEN
      		i := l_savv_tbl.FIRST;
      		LOOP
       	 		l_savv_tbl(i).sae_id := x_saev_rec.id;
        		EXIT WHEN (i = l_savv_tbl.LAST);
       	 		i := l_savv_tbl.NEXT(i);
     	 	END LOOP;
    	END IF;

        -- in case of saiv , it is assumed that sae_id and sae_id_for will be populated by the newly generated
        --id in saev_rec. That is the l_saiv_tbl has already got sae_id_for
        IF (l_saiv_tbl.COUNT > 0) THEN
      		i := l_saiv_tbl.FIRST;
      		LOOP
       	 		l_saiv_tbl(i).sae_id := x_saev_rec.id;
        		EXIT WHEN (i = l_saiv_tbl.LAST);
       	 		i := l_saiv_tbl.NEXT(i);
     	 	END LOOP;
    	END IF;

        IF (l_samv_tbl.COUNT > 0) THEN
      		i := l_samv_tbl.FIRST;
      		LOOP
       	 		l_samv_tbl(i).sae_id := x_saev_rec.id;
        		EXIT WHEN (i = l_samv_tbl.LAST);
       	 		i := l_samv_tbl.NEXT(i);
     	 	END LOOP;
    	END IF;

        --Now call complex apis for each child individually

        create_std_art_version(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_savv_tbl,
	    x_savv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	create_std_art_incmpt(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_saiv_tbl,
	    x_saiv_tbl);

    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	create_std_art_set_mem(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    l_samv_tbl,
	    x_samv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

       x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 BEGIN
   	   Update_std_article(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saev_rec,
	    x_saev_rec);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

        --Now call complex apis for each child individually

        Update_std_art_version(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_savv_tbl,
	    x_savv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	Update_std_art_incmpt(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saiv_tbl,
	    x_saiv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	Update_std_art_set_mem(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_samv_tbl,
	    x_samv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

        x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
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
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 BEGIN
   	   Validate_std_article(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saev_rec);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

        --Now call complex apis for each child individually

        Validate_std_art_version(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_savv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	Validate_std_art_incmpt(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saiv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

	Validate_std_art_set_mem(
	    p_api_version,
	    p_init_msg_list,
	    x_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_samv_tbl);
    	IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      		raise G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;

        x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
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
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type) IS
 BEGIN
   	OKC_SAE_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_tbl,
				x_saev_tbl);
 END Create_std_article;


PROCEDURE Create_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type) IS
 BEGIN
   	OKC_SAE_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_rec,
				x_saev_rec);
 END Create_std_article;

PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS
 BEGIN
   	OKC_SAE_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_tbl);
 END lock_std_article;


PROCEDURE lock_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
 BEGIN
   	OKC_SAE_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_rec);
 END lock_std_article;

PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type,
	x_saev_tbl		OUT NOCOPY saev_tbl_type) IS
 BEGIN
   	OKC_SAE_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_tbl,
				x_saev_tbl);
 END update_std_article;


PROCEDURE update_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type,
	x_saev_rec		OUT NOCOPY saev_rec_type) IS
 BEGIN
   	OKC_SAE_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_rec,
				x_saev_rec);
 END update_std_article;


PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS

	 Cursor l_ver(id number) is
	   select '1' from OKC_STD_ART_VERSIONS_B where sae_id=id;
	 Cursor l_set(id number) is
	   select '1' from OKC_STD_ART_SET_MEMS where sae_id=id;
	 Cursor l_incmpt(id number) is
	   select '1' from OKC_STD_ART_INCMPTS where sae_id=id;
      l_count varchar2(1):='0';

  BEGIN
       x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF p_saev_rec.id IS NOT NULL THEN
        OPEN l_ver(p_saev_rec.id);
        FETCH l_ver into l_count;
        Close l_ver;
        IF (l_COUNT='1') THEN
            raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

        OPEN l_set(p_saev_rec.id);
        FETCH l_set into l_count;
        Close l_set;
        IF (l_COUNT='1') THEN
            raise G_EXCEPTION_HALT_VALIDATION;
        END IF;

        OPEN l_incmpt(p_saev_rec.id);
        FETCH l_incmpt into l_count;
        Close l_incmpt;
        IF (l_COUNT='1') THEN
            raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
     END IF;


       OKC_SAE_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_rec);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
                OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_CHILD_DELETE);
            x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END delete_std_article;


PROCEDURE delete_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_tbl		IN saev_tbl_type) IS
        i number                 :=0;
    	l_return_status 		   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_saev_tbl.COUNT > 0) THEN
      i := p_saev_tbl.FIRST;
      LOOP
        delete_std_article(
	    p_api_version,
	    p_init_msg_list,
	    l_return_status,
	    x_msg_count,
	    x_msg_data,
	    p_saev_tbl(i));
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_saev_tbl.LAST);
        i := p_saev_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
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
	p_saev_tbl		IN saev_tbl_type) IS
 BEGIN
   	OKC_SAE_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_tbl);
 END validate_std_article;


PROCEDURE validate_std_article(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saev_rec		IN saev_rec_type) IS
 BEGIN
   	OKC_SAE_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saev_rec);
 END validate_std_article;


PROCEDURE validate_name(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saev_rec                     IN saev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Name';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saev_rec                     saev_rec_type := p_saev_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    OKC_UTIL.ADD_VIEW('OKC_STD_ARTICLES_V',x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/
    --- Validate name
    OKC_SAE_PVT.validate_name(p_saev_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION

   WHEN G_EXCEPTION_HALT_VALIDATION THEN
       null;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_name;

PROCEDURE validate_no_k_attached(
    p_saev_rec                     IN saev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

  BEGIN

    --- Validate that no contract is attached to the release getting updated
    OKC_SAE_PVT.validate_no_k_attached(p_saev_rec,x_return_status);

  END validate_no_k_attached;

PROCEDURE Create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type) IS
 BEGIN
   	OKC_SAV_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_tbl,
				x_savv_tbl);
 END Create_std_art_version;


PROCEDURE Create_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type) IS
 BEGIN
   	OKC_SAV_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_rec,
				x_savv_rec);
 END Create_std_art_version;

PROCEDURE lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
 BEGIN
   	OKC_SAV_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_tbl);
 END lock_std_art_version;


PROCEDURE  lock_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
 BEGIN
   	OKC_SAV_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_rec);
 END lock_std_art_version;

PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type,
	x_savv_tbl		OUT NOCOPY savv_tbl_type) IS
 BEGIN
   	OKC_SAV_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_tbl,
				x_savv_tbl);
 END update_std_art_version;


PROCEDURE update_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type,
	x_savv_rec		OUT NOCOPY savv_rec_type) IS
 BEGIN
   	OKC_SAV_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_rec,
				x_savv_rec);
 END update_std_art_version;

PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
 BEGIN
   	OKC_SAV_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_tbl);
 END delete_std_art_version;

PROCEDURE delete_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
 BEGIN
   	OKC_SAV_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_rec);
 END delete_std_art_version;

PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_tbl		IN savv_tbl_type) IS
 BEGIN
   	OKC_SAV_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_tbl);
 END validate_std_art_version;


PROCEDURE validate_std_art_version(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_savv_rec		IN savv_rec_type) IS
 BEGIN
   	OKC_SAV_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_savv_rec);
 END validate_std_art_version;

PROCEDURE validate_sav_release(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Sav_Release';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/*
    OKC_UTIL.ADD_VIEW('OKC_STD_ART_VERSIONS_V',x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/

    --- Validate sav_release
    OKC_SAV_PVT.validate_sav_release(p_savv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     null;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_sav_release;

PROCEDURE validate_date_active(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Date_Active';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --- Validate date_active
    OKC_SAV_PVT.validate_date_active(p_savv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_date_active;

PROCEDURE validate_no_k_attached(
    p_savv_rec                     IN savv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

  BEGIN

    --- Validate that no contract is attached to the release getting updated
    OKC_SAV_PVT.validate_no_k_attached(p_savv_rec,x_return_status);

  END validate_no_k_attached;

PROCEDURE validate_latest(
    p_savv_rec                     IN savv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS

  BEGIN

    --- Validate that the release getting updated is the latest release
    OKC_SAV_PVT.validate_latest(p_savv_rec,x_return_status);

  END validate_latest;

PROCEDURE validate_updatable(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Updatable';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --- Validate that the date_active and text are updatable
    OKC_SAV_PVT.validate_updatable(p_savv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     null;


    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_updatable;

/*
-- No check length is called as the form column length made equal to
-- table column length -- JOHN
--
PROCEDURE validate_short_description(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_savv_rec                     IN savv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Short_Description';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_savv_rec                     savv_rec_type := p_savv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_UTIL.ADD_VIEW('OKC_STD_ART_VERSIONS_V',x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    --- Validate short_description
    OKC_SAV_PVT.validate_short_description(p_savv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     null;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_short_description;
*/

PROCEDURE Create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type) IS
 BEGIN
   	OKC_SAI_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_tbl,
				x_saiv_tbl);
 END Create_std_art_incmpt;


PROCEDURE Create_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type) IS

        l_saiv_rec  		saiv_rec_type;

 BEGIN
        x_return_status:= OKC_API.G_RET_STS_SUCCESS;

      	l_saiv_rec:=p_saiv_rec;
      	l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       	l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;

    	OKC_SAI_PVT.validate_unique(l_saiv_rec,x_return_status);
    	IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
   		OKC_SAI_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_rec,
				x_saiv_rec);

       END IF;
   EXCEPTION
      WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END Create_std_art_incmpt;

PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS
 BEGIN
   	OKC_SAI_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_tbl);
 END lock_std_art_incmpt;


PROCEDURE lock_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS

        l_saiv_rec                saiv_rec_type;
        CURSOR l_sai_csr IS
        SELECT '1'
        FROM   okc_std_art_incmpts  sai
   	WHERE  sai.sae_id = p_saiv_rec.sae_id_for and sai.sae_id_for = p_saiv_rec.sae_id;
        l_dummy_var   VARCHAR2(1):='0';
 BEGIN
        --check if the opposite combination record exists
        OPEN l_sai_csr;
        FETCH l_sai_csr into l_dummy_var;
        CLOSE l_sai_csr;
        IF (l_dummy_var<>'1') Then --if opposite combination record  doesnot exist then
       		--lock the record if the combination exists like this
   		OKC_SAI_PVT.lock_row(p_api_version,
			       	     p_init_msg_list,
				     x_return_status,
				     x_msg_count,
				     x_msg_data,
				     p_saiv_rec);
       ELSE
      		 l_saiv_rec:=p_saiv_rec;
      		 l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       		 l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;
       		-- lock the opposite combination as the record might exist the opposite combination way
      		 OKC_SAI_PVT.lock_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_saiv_rec);
      END IF;

      EXCEPTION
      WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END lock_std_art_incmpt;

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type,
	x_saiv_tbl		OUT NOCOPY saiv_tbl_type) IS
 BEGIN
   	OKC_SAI_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_tbl,
				x_saiv_tbl);
 END update_std_art_incmpt;

PROCEDURE update_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type,
	x_saiv_rec		OUT NOCOPY saiv_rec_type) IS

        l_api_version           CONSTANT NUMBER := 1;
        l_api_name              CONSTANT VARCHAR2(30) := 'V_Validate_Std_Art_Incmpt';
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_saiv_rec              saiv_rec_type;
        CURSOR l_sai_csr IS
        SELECT '1'
        FROM   okc_std_art_incmpts  sai
   	    WHERE  sai.sae_id = p_saiv_rec.sae_id_for and sai.sae_id_for = p_saiv_rec.sae_id;

        l_dummy_var   VARCHAR2(1):='0';
 BEGIN

        --check if the opposite combination record exists
        OPEN l_sai_csr;
        FETCH l_sai_csr into l_dummy_var;
        CLOSE l_sai_csr;
        IF (l_dummy_var<>'1') Then --if opposite combination record  doesnot exist then
       		--update the record if the combination exists like this
    		OKC_SAI_PVT.update_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					p_saiv_rec,
					x_saiv_rec);
       ELSE
      		 l_saiv_rec:=p_saiv_rec;
      		 l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       		 l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;
       		-- update the opposite combination as the record might exist the opposite combination way
   		 OKC_SAI_PVT.update_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_saiv_rec,
					x_saiv_rec);
      END IF;

      EXCEPTION
      WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END update_std_art_incmpt;

PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_tbl		IN saiv_tbl_type) IS
 BEGIN
   	OKC_SAI_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_tbl);
 END delete_std_art_incmpt;

PROCEDURE delete_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS

        l_saiv_rec                saiv_rec_type;
        CURSOR l_sai_csr IS
        SELECT '1'
        FROM   okc_std_art_incmpts  sai
   	    WHERE  sai.sae_id = p_saiv_rec.sae_id_for and sai.sae_id_for = p_saiv_rec.sae_id;
        l_dummy_var   VARCHAR2(1):='0';
 BEGIN
        --check if the opposite combination record exists
        OPEN l_sai_csr;
        FETCH l_sai_csr into l_dummy_var;
        CLOSE l_sai_csr;
        IF (l_dummy_var<>'1') Then --if opposite combination record  doesnot exist then
       		--delete the record if the combination exists like this
   		 OKC_SAI_PVT.delete_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					p_saiv_rec);
       ELSE
      		 l_saiv_rec:=p_saiv_rec;
      		 l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       		 l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;
       		-- try to delete the opposite combination as the record might exist the opposite combination way
      		 OKC_SAI_PVT.delete_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_saiv_rec);
      END IF;

      EXCEPTION
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
	p_saiv_tbl		IN saiv_tbl_type) IS
 BEGIN
   	OKC_SAI_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_saiv_tbl);
 END validate_std_art_incmpt;


PROCEDURE validate_std_art_incmpt(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_saiv_rec		IN saiv_rec_type) IS

        l_api_version           CONSTANT NUMBER := 1;
        l_api_name              CONSTANT VARCHAR2(30) := 'V_Validate_Std_Art_Incmpt';
        l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_saiv_rec              saiv_rec_type;
        CURSOR l_sai_csr IS
        SELECT '1'
        FROM   okc_std_art_incmpts  sai
   	    WHERE  sai.sae_id = p_saiv_rec.sae_id_for and sai.sae_id_for = p_saiv_rec.sae_id;

        l_dummy_var   VARCHAR2(1):='0';
 BEGIN
         --check if the opposite combination record exists
        OPEN l_sai_csr;
        FETCH l_sai_csr into l_dummy_var;
        CLOSE l_sai_csr;
        IF (l_dummy_var<>'1') Then --if opposite combination record  doesnot exist then
       		--validate the record if the combination exists like this
   		 OKC_SAI_PVT.validate_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					p_saiv_rec);
       ELSE
      		 l_saiv_rec:=p_saiv_rec;
      		 l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       		 l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;
       		-- validate the opposite combination as the record might exist the opposite combination way
      		 OKC_SAI_PVT.validate_row(p_api_version,
			       		p_init_msg_list,
					x_return_status,
					x_msg_count,
					x_msg_data,
					l_saiv_rec);
      END IF;

      EXCEPTION
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
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Unique';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saiv_rec                     saiv_rec_type := p_saiv_rec;


  BEGIN
    	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              	G_PKG_NAME,
                                              	p_init_msg_list,
                                              	l_api_version,
                                              	p_api_version,
                                              	'_PVT',
                                             	 x_return_status);
    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     	 RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

     	--check if the record exists
      	OKC_SAI_PVT.validate_unique(p_saiv_rec,l_return_status);

     	--- If any errors happen abort API
    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     			 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     			 RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

      	l_saiv_rec:=p_saiv_rec;
      	l_saiv_rec.sae_id:=p_saiv_rec.sae_id_for;
       	l_saiv_rec.sae_id_for:=p_saiv_rec.sae_id;
       	 -- validate opposite combination as the record might exist the opposite combination way

     	OKC_SAI_PVT.validate_unique(l_saiv_rec,l_return_status);
    	--- If any errors happen abort API
    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     		 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     		 RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_unique;

PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type) IS
 BEGIN
   	OKC_SAC_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_tbl,
				x_sacv_tbl);
 END Create_std_art_classing;

PROCEDURE create_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type) IS
 BEGIN
   	OKC_SAC_PVT.insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_rec,
				x_sacv_rec);
 END create_std_art_classing;

PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type)IS
 BEGIN
   	OKC_SAC_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_tbl);
 END lock_std_art_classing;


PROCEDURE lock_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
 BEGIN
   	OKC_SAC_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_rec);
 END lock_std_art_classing;


PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type,
	x_sacv_tbl		OUT NOCOPY sacv_tbl_type) IS
 BEGIN
   	OKC_SAC_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_tbl,
				x_sacv_tbl);
 END update_std_art_classing;


PROCEDURE update_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type,
	x_sacv_rec		OUT NOCOPY sacv_rec_type) IS
 BEGIN
   	OKC_SAC_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_rec,
				x_sacv_rec);
 END update_std_art_classing;

PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS
 BEGIN
   	OKC_SAC_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_tbl);
 END delete_std_art_classing;


PROCEDURE delete_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
 BEGIN
   	OKC_SAC_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_rec);
 END delete_std_art_classing;

PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_tbl		IN sacv_tbl_type) IS
 BEGIN
   	OKC_SAC_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_tbl);
 END validate_std_art_classing;


PROCEDURE validate_std_art_classing(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sacv_rec		IN sacv_rec_type) IS
 BEGIN
   	OKC_SAC_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_sacv_rec);
 END validate_std_art_classing;

PROCEDURE validate_price_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Price_Type';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type := p_sacv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/*
    OKC_UTIL.ADD_VIEW('OKC_STD_ART_CLASSINGS_V',x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/

    --- Validate price_type
    OKC_SAC_PVT.validate_price_type(p_sacv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     null;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_price_type;

PROCEDURE validate_scs_code(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_SCS_Code';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type := p_sacv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/*
    OKC_UTIL.ADD_VIEW('OKC_STD_ART_CLASSINGS_V',x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;
*/

    --- Validate scs_code
    OKC_SAC_PVT.validate_scs_code(p_sacv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
     null;

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_scs_code;


PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
 BEGIN
   	OKC_SAM_PVT.Insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_tbl,
				x_samv_tbl);
 END create_std_art_set_mem;


PROCEDURE create_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type) IS
 BEGIN
   	OKC_SAM_PVT.Insert_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_rec,
				x_samv_rec);
 END create_std_art_set_mem;


PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
 BEGIN
   	OKC_SAM_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_tbl);
 END lock_std_art_set_mem;


PROCEDURE lock_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
 BEGIN
   	OKC_SAM_PVT.lock_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_rec);
 END lock_std_art_set_mem;

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type,
	x_samv_tbl		OUT NOCOPY samv_tbl_type) IS
 BEGIN
   	OKC_SAM_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_tbl,
				x_samv_tbl);
 END update_std_art_set_mem;

PROCEDURE update_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type,
	x_samv_rec		OUT NOCOPY samv_rec_type) IS
 BEGIN
   	OKC_SAM_PVT.update_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_rec,
				x_samv_rec);
 END update_std_art_set_mem;

PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
 BEGIN
   	OKC_SAM_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_tbl);
 END delete_std_art_set_mem;

PROCEDURE delete_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
 BEGIN
   	OKC_SAM_PVT.delete_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_rec);
 END delete_std_art_set_mem;

PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_tbl		IN samv_tbl_type) IS
 BEGIN
   	OKC_SAM_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_tbl);
 END validate_std_art_set_mem;

PROCEDURE validate_std_art_set_mem(
	p_api_version 		IN NUMBER,
	p_init_msg_list 		IN VARCHAR2 ,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_samv_rec		IN samv_rec_type) IS
 BEGIN
   	OKC_SAM_PVT.validate_row(p_api_version,
			       	p_init_msg_list,
				x_return_status,
				x_msg_count,
				x_msg_data,
				p_samv_rec);
 END validate_std_art_set_mem;


PROCEDURE validate_unique(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_samv_rec                     IN samv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_Validate_Unique';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_samv_rec                     samv_rec_type := p_samv_rec;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --- Validate unique
    OKC_SAM_PVT.validate_unique(p_samv_rec,l_return_status);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION

    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_unique;

FUNCTION used_in_contracts
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_sav_sav_release          IN   okc_k_articles_b.sav_sav_release%TYPE
)
RETURN VARCHAR2 IS
/*
  This function is used in view okc_kol_std_art_lib_v
  This function returns 'Y' if
    The current article release is used in contract
  If this is 'Y' we disable delete for the release
*/

l_count    NUMBER;

CURSOR csr_cnt_k IS
SELECT COUNT(*)
FROM okc_k_articles_v
WHERE sav_sae_id = p_sav_sae_id
  AND sav_sav_release = p_sav_sav_release ;

BEGIN

   OPEN csr_cnt_k;
     FETCH csr_cnt_k INTO l_count;
   CLOSE csr_cnt_k;

   -- if not used in contracts delete is allowed
   IF NVL(l_count,0) = 0 THEN
      RETURN 'N' ;
   ELSE
      RETURN 'Y';
   END IF;
END used_in_contracts;

FUNCTION empclob
RETURN CLOB IS

 c1 CLOB;

BEGIN

    DBMS_LOB.CREATETEMPORARY(c1,true);
    DBMS_LOB.OPEN(c1,dbms_lob.lob_readwrite);
    DBMS_LOB.WRITE(c1,1,1,' ');
    RETURN c1;

END empclob;


FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE
)
RETURN VARCHAR2 IS


l_latest_release  okc_std_art_versions_b.sav_release%TYPE := '';

/*
  We check the latest release based on the following
  1. date_active
  2. creation_date

  Also the date_active MUST BE LESS THEN OR EQUAL TO sysdate
  i.e future dated articles cannot be latest release
*/

CURSOR csr_latest_release IS
SELECT sav_release
  FROM okc_std_art_versions_b
 WHERE sae_id = p_sav_sae_id
   AND date_active <= sysdate
 ORDER BY date_active DESC, creation_date DESC ;

BEGIN

   OPEN csr_latest_release;
     FETCH csr_latest_release INTO l_latest_release;
   CLOSE csr_latest_release;

   RETURN l_latest_release;

END latest_release;

FUNCTION latest_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_sav_sav_release          IN   okc_k_articles_b.sav_sav_release%TYPE
)
RETURN VARCHAR2 IS
/*
  This function is used in view okc_kol_std_art_latest_rel_v
  This function returns 'Y' if
  The current article release is latest release
*/

l_latest_release  okc_std_art_versions_b.sav_release%TYPE := '';

BEGIN
   l_latest_release := latest_release(p_sav_sae_id);

   IF l_latest_release = p_sav_sav_release  THEN
      RETURN 'Y' ;
   ELSE
      RETURN 'N';
   END IF;
END latest_release;

FUNCTION latest_or_future_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_sav_sav_release          IN   okc_k_articles_b.sav_sav_release%TYPE,
  p_date_active              IN   okc_std_art_versions_b.date_active%TYPE
)
RETURN VARCHAR2 IS
/*
 This function is used in view okc_kol_std_art_lib_v
 This function returns 'Y' if the current release is latest or future dated.
 This is used in view okc_kol_std_art_lib_v to decide if an article can be updated

 Article can be update if :
 1. It is NOT used in any contracts
 2. It is the latest release OR future dated release.
*/

l_latest_release  okc_std_art_versions_b.sav_release%TYPE := '';

BEGIN

   -- check if future release
   IF p_date_active > sysdate THEN
     RETURN 'Y' ;
   END IF;

   -- check if latest release
   l_latest_release := latest_release(p_sav_sae_id);

   IF l_latest_release = p_sav_sav_release  THEN
      RETURN 'Y' ;
   ELSE
      RETURN 'N';
   END IF;
END latest_or_future_release;


-- Bug 3188215 KOL: BACKWARD COMPATIBILITY CHANGES
-- Introduced the new api fundtion.
FUNCTION art_used_in_contracts
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE
)
RETURN VARCHAR2 IS
/*
  This function is used in view okc_kol_std_art_lib_v
  This function returns 'Y' if
    The current article version is used in contract
  If this is 'Y' we disable delete for the release
*/

l_count    NUMBER;

CURSOR csr_cnt_k IS
SELECT COUNT(*)
FROM okc_article_versions a, okc_k_articles_b b
WHERE b.sav_sae_id = p_sav_sae_id
  AND b.sav_sae_id = a.article_id
  AND ( a.article_version_number = p_article_version_number OR
        a.sav_release = to_char(p_article_version_number) );

BEGIN

   OPEN csr_cnt_k;
     FETCH csr_cnt_k INTO l_count;
   CLOSE csr_cnt_k;

   -- if not used in contracts delete is allowed
   IF NVL(l_count,0) = 0 THEN
      RETURN 'N' ;
   ELSE
      RETURN 'Y';
   END IF;
END art_used_in_contracts;

-- Bug 3188215 KOL: BACKWARD COMPATIBILITY CHANGES
-- Introduced the new api fundtion.
FUNCTION latest_art_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE
)
RETURN VARCHAR2 IS


l_latest_release  okc_article_versions.sav_release%TYPE := ' ';

/*
  We check the latest release based on the following
  1. date_active/start_date
  2. creation_date

  Also the date_active MUST BE LESS THEN OR EQUAL TO sysdate
  i.e future dated articles cannot be latest release
*/

CURSOR csr_latest_release IS
SELECT NVL(sav_release, to_char(article_version_number))
  FROM okc_article_versions
 WHERE article_id = p_sav_sae_id
   AND start_date <= sysdate
 ORDER BY start_date DESC, creation_date DESC ;

BEGIN

   OPEN csr_latest_release;
     FETCH csr_latest_release INTO l_latest_release;
   CLOSE csr_latest_release;

   RETURN l_latest_release;

END latest_art_release;

-- Bug 3188215 KOL: BACKWARD COMPATIBILITY CHANGES
-- Introduced the new api fundtion.
FUNCTION latest_art_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE
)
RETURN VARCHAR2 IS
/*
  This function is used in view okc_kol_std_art_latest_rel_v
  This function returns 'Y' if
  The current article version is latest release
*/

l_latest_release  okc_article_versions.sav_release%TYPE := ' ';

BEGIN
   l_latest_release := latest_art_release(p_sav_sae_id);

   IF l_latest_release = to_char(p_article_version_number)  THEN
      RETURN 'Y' ;
   ELSE
      RETURN 'N';
   END IF;
END latest_art_release;


-- Bug 3188215 KOL: BACKWARD COMPATIBILITY CHANGES
-- Introduced the new api fundtion.
FUNCTION latest_or_future_art_release
(
  p_sav_sae_id               IN   okc_k_articles_b.sav_sae_id%TYPE,
  p_article_version_number   IN   okc_article_versions.article_version_number%TYPE,
  p_date_active              IN   okc_article_versions.start_date%TYPE
)
RETURN VARCHAR2 IS
/*
 This function is used in view okc_kol_std_art_lib_v
 This function returns 'Y' if the current version is latest or future dated.
 This is used in view okc_kol_std_art_lib_v to decide if an article can be updated

 Article can be update if :
 1. It is NOT used in any contracts
 2. It is the latest release OR future dated release.
*/

l_latest_release  okc_article_versions.sav_release%TYPE := ' ';

BEGIN

   -- check if future release
   IF p_date_active > sysdate THEN
     RETURN 'Y' ;
   END IF;

   -- check if latest release
   l_latest_release := latest_art_release(p_sav_sae_id);

   IF l_latest_release = to_char(p_article_version_number)  THEN
      RETURN 'Y' ;
   ELSE
      RETURN 'N';
   END IF;
END latest_or_future_art_release;


END okc_std_article_pvt;

/
