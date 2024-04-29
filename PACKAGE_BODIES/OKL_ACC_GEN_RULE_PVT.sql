--------------------------------------------------------
--  DDL for Package Body OKL_ACC_GEN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_GEN_RULE_PVT" AS
/* $Header: OKLCAGRB.pls 115.9 2002/05/13 16:01:00 pkm ship       $ */

 --Object type procedure for insert
 PROCEDURE create_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
    ,p_aulv_tbl                     IN aulv_tbl_type
    ,x_agrv_rec                     OUT NOCOPY agrv_rec_type
    ,x_aulv_tbl                     OUT NOCOPY aulv_tbl_type
    )
	IS
    i                               NUMBER;
    l_agrv_rec                      agrv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_aulv_tbl                      aulv_tbl_type := p_aulv_tbl;

  BEGIN

  -- Populate Header

     create_acc_gen_rule(
      p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_agrv_rec
      ,x_agrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

  -- populate the foreign key for the detail
    IF (l_aulv_tbl.COUNT > 0) THEN
       i:= l_aulv_tbl.FIRST;
       LOOP
         l_aulv_tbl(i).agr_id := x_agrv_rec.id;
         EXIT WHEN(i = l_aulv_tbl.LAST);
         i := l_aulv_tbl.NEXT(i);
       END LOOP;
    END IF;


    -- populate the detail
    create_acc_gen_rule_lns(
       p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,l_aulv_tbl
      ,x_aulv_tbl);

    END IF;


    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => SQLCODE
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => SQLERRM);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	END create_acc_gen_rule;


 --Object type procedure for update
 PROCEDURE update_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
   ,p_aulv_tbl                     IN aulv_tbl_type
   ,x_agrv_rec                     OUT NOCOPY agrv_rec_type
   ,x_aulv_tbl                     OUT NOCOPY aulv_tbl_type
    )
	IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	BEGIN
	      -- Update the master
    update_acc_gen_rule(
       p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_agrv_rec
      ,x_agrv_rec);


    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Update the detail
    update_acc_gen_rule_lns(
      p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_aulv_tbl
      ,x_aulv_tbl);

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	END update_acc_gen_rule;


 --Object type procedure for validate
 PROCEDURE validate_acc_gen_rule(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_agrv_rec                     IN agrv_rec_type
   ,p_aulv_tbl                     IN aulv_tbl_type
    )
	IS
      l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	BEGIN

    -- Validate the master
    validate_acc_gen_rule(
      p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_agrv_rec);

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
         IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
         END IF;
      END IF;


    -- Validate the detail
    validate_acc_gen_rule_lns(
      p_api_version
      ,p_init_msg_list
      ,x_return_status
      ,x_msg_count
      ,x_msg_data
      ,p_aulv_tbl);

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
         IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
         END IF;
      END IF;

      x_return_Status := l_overall_Status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;



	END validate_acc_gen_rule;


PROCEDURE create_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_rec		    IN agrv_rec_type,
    x_agrv_rec              OUT NOCOPY agrv_rec_type) IS
BEGIN
    okl_agr_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_agrv_rec,
    x_agrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_agrv_rec.dnz_chr_id);
    END IF;

END create_acc_gen_rule;

PROCEDURE create_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_tbl		    IN agrv_tbl_type,
    x_agrv_tbl              OUT NOCOPY agrv_tbl_type) IS

    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

BEGIN

 OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agrv_tbl.COUNT > 0) THEN
      i := p_agrv_tbl.FIRST;
      LOOP
        create_acc_gen_rule(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agrv_rec                     => p_agrv_tbl(i),
          x_agrv_rec                     => x_agrv_tbl(i));

        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;
        END IF;

        EXIT WHEN (i = p_agrv_tbl.LAST);
        i := p_agrv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

END create_acc_gen_rule;


PROCEDURE lock_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_rec		    IN agrv_rec_type) IS
BEGIN
    okl_agr_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_agrv_rec);
END lock_acc_gen_rule;

PROCEDURE lock_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_tbl		    IN agrv_tbl_type) IS

 l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 i                              NUMBER := 0;
BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agrv_tbl.COUNT > 0) THEN
      i := p_agrv_tbl.FIRST;
      LOOP
        lock_acc_gen_rule(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agrv_rec                     => p_agrv_tbl(i));

        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;
        END IF;

        EXIT WHEN (i = p_agrv_tbl.LAST);
        i := p_agrv_tbl.NEXT(i);
      END LOOP;
    END IF;
     x_return_status := l_overall_status;

END lock_acc_gen_rule;

PROCEDURE update_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_rec		    IN agrv_rec_type,
    x_agrv_rec              OUT NOCOPY agrv_rec_type) IS
BEGIN
    okl_agr_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_agrv_rec,
    x_agrv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_agrv_rec.dnz_chr_id);
    END IF;
END update_acc_gen_rule;

PROCEDURE update_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_tbl		    IN agrv_tbl_type,
    x_agrv_tbl              OUT NOCOPY agrv_tbl_type) IS

    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agrv_tbl.COUNT > 0) THEN
      i := p_agrv_tbl.FIRST;
      LOOP
        update_acc_gen_rule(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agrv_rec                     => p_agrv_tbl(i),
          x_agrv_rec                     => x_agrv_tbl(i));

        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_agrv_tbl.LAST);
        i := p_agrv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;

END update_acc_gen_rule;

	--Put custom code for cascade delete by developer
PROCEDURE delete_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_rec		    IN agrv_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

	CURSOR rule_line_csr(p_agr_id IN NUMBER)
	IS
	SELECT id
	FROM OKL_ACC_GEN_RUL_LNS
	WHERE agr_id = p_agr_id;

	l_rule_line_tbl OKL_AUL_PVT.aulv_tbl_type;
	l_loop_ctr NUMBER := 1;

BEGIN

    -- delete detail
	FOR l_rule_line_csr IN rule_line_csr(p_agrv_rec.id)
	LOOP
     l_rule_line_tbl(l_loop_ctr).id := l_rule_line_csr.id;
	 l_loop_ctr := l_loop_ctr + 1 ;
	END LOOP;

	    -- delete Lines
    delete_acc_gen_rule_lns(p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,l_rule_line_tbl);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

        okl_agr_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_agrv_rec);


    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_acc_gen_rule;


PROCEDURE delete_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_tbl		    IN agrv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_agrv_tbl.COUNT > 0) THEN
       	  i := p_agrv_tbl.FIRST;
       LOOP
	     delete_acc_gen_rule(
    	    p_api_version
    	   ,p_init_msg_list
    	   ,x_return_status
    	   ,x_msg_count
    	   ,x_msg_data
    	   ,p_agrv_tbl(i));

     IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;
        END IF;

          EXIT WHEN (i = p_agrv_tbl.LAST);
          i := p_agrv_tbl.NEXT(i);
       END LOOP;

    END IF;

    x_return_Status := l_overall_status;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_acc_gen_rule;

PROCEDURE validate_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_rec		    IN agrv_rec_type) IS
BEGIN
    okl_agr_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_agrv_rec);
END validate_acc_gen_rule;

PROCEDURE validate_acc_gen_rule(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_agrv_tbl		    IN agrv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agrv_tbl.COUNT > 0) THEN
      i := p_agrv_tbl.FIRST;
      LOOP
        validate_acc_gen_rule(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agrv_rec                     => p_agrv_tbl(i));

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;
        EXIT WHEN (i = p_agrv_tbl.LAST);
        i := p_agrv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

END validate_acc_gen_rule;

PROCEDURE create_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_rec		    IN aulv_rec_type,
    x_aulv_rec              OUT NOCOPY aulv_rec_type) IS
BEGIN
    okl_aul_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aulv_rec,
    x_aulv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_aulv_rec.dnz_chr_id);
    END IF;

END create_acc_gen_rule_lns;

PROCEDURE create_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_tbl		    IN aulv_tbl_type,
    x_aulv_tbl              OUT NOCOPY aulv_tbl_type) IS

   l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        create_acc_gen_rule_lns(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i),
          x_aulv_rec                     => x_aulv_tbl(i));

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
              l_overall_status := x_return_status;
              EXIT;
          END IF;

        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;


END create_acc_gen_rule_lns;

PROCEDURE lock_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_rec		    IN aulv_rec_type) IS
BEGIN
    okl_aul_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aulv_rec);
END lock_acc_gen_rule_lns;

PROCEDURE lock_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_tbl		    IN aulv_tbl_type) IS
  l_overall_Status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        lock_acc_gen_rule_lns(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i));

 IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;
        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;

END lock_acc_gen_rule_lns;

PROCEDURE update_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_rec		    IN aulv_rec_type,
    x_aulv_rec              OUT NOCOPY aulv_rec_type) IS
BEGIN


    okl_aul_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aulv_rec,
    x_aulv_rec);

--  RAISE_APPLICATION_ERROR (-20001, 'Return Status in acc gen pvtTTTTTTTTTT' || x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_aulv_rec.dnz_chr_id);
    END IF;
END update_acc_gen_rule_lns;

PROCEDURE update_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_tbl		    IN aulv_tbl_type,
    x_aulv_tbl              OUT NOCOPY aulv_tbl_type) IS

   l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        update_acc_gen_rule_lns(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i),
          x_aulv_rec                     => x_aulv_tbl(i));

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;

        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_Status;

END update_acc_gen_rule_lns;

	--Put custom code for cascade delete by developer

PROCEDURE delete_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_rec		    IN aulv_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        okl_aul_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_aulv_rec);


EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_acc_gen_rule_lns;

PROCEDURE delete_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_tbl		    IN aulv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_aulv_tbl.COUNT > 0) THEN
       	  i := p_aulv_tbl.FIRST;
       LOOP
          delete_acc_gen_rule_lns(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_aulv_tbl(i));

        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN

           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

       END IF;

          EXIT WHEN (i = p_aulv_tbl.LAST);
          i := p_aulv_tbl.NEXT(i);
       END LOOP;
    END IF;

    x_return_status := l_overall_status;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_acc_gen_rule_lns;

PROCEDURE validate_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_rec		    IN aulv_rec_type) IS
BEGIN
    okl_aul_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aulv_rec);
END validate_acc_gen_rule_lns;

PROCEDURE validate_acc_gen_rule_lns(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aulv_tbl		    IN aulv_tbl_type) IS

   l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aulv_tbl.COUNT > 0) THEN
      i := p_aulv_tbl.FIRST;
      LOOP
        validate_acc_gen_rule_lns(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aulv_rec                     => p_aulv_tbl(i));

          IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               l_overall_status := x_return_status;
           END IF;

          END IF;
        EXIT WHEN (i = p_aulv_tbl.LAST);
        i := p_aulv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

END validate_acc_gen_rule_lns;

END okl_acc_gen_rule_pvt;

/
