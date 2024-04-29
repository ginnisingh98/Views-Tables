--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_EVENT_PVT" AS
/* $Header: OKLCAETB.pls 115.9 2002/04/16 16:46:30 pkm ship       $ */

 PROCEDURE create_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
   ,p_aehv_tbl                     IN aehv_tbl_type
   ,p_aelv_tbl                     IN aelv_tbl_type
   ,x_aetv_rec                     OUT NOCOPY aetv_rec_type
   ,x_aehv_tbl                     OUT NOCOPY aehv_tbl_type
   ,x_aelv_tbl                     OUT NOCOPY aelv_tbl_type
    )
	AS
    l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aetv_rec              aetv_rec_type;
    l_aehv_tbl              aehv_tbl_type := p_aehv_tbl;
    l_aelv_tbl              aelv_tbl_type := p_aelv_tbl;
    i			    		NUMBER;
    j			    		NUMBER;

BEGIN
	      --Populate the Master
    create_acct_event(p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      p_aetv_rec,
                      x_aetv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Populate the foreign key for the line
    IF (l_aehv_tbl.COUNT > 0) THEN
       i := l_aehv_tbl.FIRST;
       LOOP
          l_aehv_tbl(i).accounting_event_id := x_aetv_rec.accounting_event_id;
          EXIT WHEN (i = l_aehv_tbl.LAST);
          i := l_aehv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the line
    create_acct_header(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   		x_msg_count,
    	x_msg_data,
    	l_aehv_tbl,
    	x_aehv_tbl);


    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Populate the foreign key for the detail
    IF (l_aehv_tbl.COUNT > 0) THEN
       i := l_aehv_tbl.FIRST;
       LOOP
           j := l_aelv_tbl.FIRST;
	   	   LOOP
              IF (i = p_aelv_tbl(j).aeh_tbl_index) THEN
             		   l_aelv_tbl(j).ae_header_id := x_aehv_tbl(i).ae_header_id;
			  END IF;
		   EXIT WHEN (j = l_aelv_tbl.LAST);
           j := l_aelv_tbl.NEXT(j);
		   END LOOP;
       EXIT WHEN (i = l_aehv_tbl.LAST);
       i := l_aehv_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    create_acct_lines(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   		x_msg_count,
    	x_msg_data,
    	l_aelv_tbl,
    	x_aelv_tbl);

  END IF;

 END IF;


EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okc_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

	END create_acct_event;

 --Object type procedure for update
 PROCEDURE update_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
   ,p_aehv_tbl                     IN aehv_tbl_type
	,p_aelv_tbl                     IN aelv_tbl_type
   ,x_aetv_rec                     OUT NOCOPY aetv_rec_type
   ,x_aehv_tbl                     OUT NOCOPY aehv_tbl_type
   ,x_aelv_tbl                     OUT NOCOPY aelv_tbl_type
    )
	AS
   l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

	BEGIN
	     --Update the Master
    update_acct_event(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_aetv_rec,
    	x_aetv_rec);

    IF x_return_status = Okc_Api.G_RET_STS_SUCCESS THEN

        --Update the line
        update_acct_header(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_aehv_tbl,
        x_aehv_tbl);

        IF (x_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN

        --Update the detail
               update_acct_lines(
               p_api_version,
               p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               p_aelv_tbl,
               x_aelv_tbl);
        END IF;

   END IF;

END update_acct_event;


 --Object type procedure for validate
 PROCEDURE validate_acct_event(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aetv_rec                     IN aetv_rec_type
   ,p_aehv_tbl                     IN aehv_tbl_type
   ,p_aelv_tbl                     IN aelv_tbl_type
    )
	AS
   l_return_status           VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   l_overall_status          VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

--Validate the Master
    validate_acct_event(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aetv_rec);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_overall_status := x_return_status;
        END IF;
    END IF;


--Validate the line
    validate_acct_header(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aehv_tbl);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_overall_status := x_return_status;
        END IF;
    END IF;

--Validate the detail
    validate_acct_lines(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aelv_tbl);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_overall_status := x_return_status;
        END IF;
    END IF;

    x_return_status := l_overall_status;


EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okc_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

	END validate_acct_event;


PROCEDURE create_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_rec		    IN aetv_rec_type,
    x_aetv_rec              OUT NOCOPY aetv_rec_type) IS
BEGIN

    okl_aet_pvt.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_aetv_rec,
                           x_aetv_rec);


END create_acct_event;

PROCEDURE create_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_tbl		    IN aetv_tbl_type,
    x_aetv_tbl              OUT NOCOPY aetv_tbl_type) IS

    i         NUMBER := 0;
    l_overall_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        create_Acct_event(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i),
          x_aetv_rec                     => x_aetv_tbl(i));

       IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              l_overall_status := x_return_status;
          END IF;
       END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;


    END IF;

    x_return_status := l_overall_status;

END create_acct_event;



PROCEDURE lock_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_rec		    IN aetv_rec_type) IS
BEGIN
    okl_aet_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aetv_rec);
END lock_acct_event;

PROCEDURE lock_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_tbl		    IN aetv_tbl_type) IS

    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

BEGIN

Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP

        lock_acct_event(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i));

      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_overall_status := x_return_status;
          END IF;
      END IF;

      EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;

    END IF;

END lock_acct_event;

PROCEDURE update_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_rec		    IN aetv_rec_type,
    x_aetv_rec              OUT NOCOPY aetv_rec_type) IS
BEGIN
    okl_aet_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aetv_rec,
    x_aetv_rec);

END update_acct_event;

PROCEDURE update_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_tbl		    IN aetv_tbl_type,
    x_aetv_tbl              OUT NOCOPY aetv_tbl_type) IS
    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        update_acct_event(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i),
          x_aetv_rec                     => x_aetv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;

END;



PROCEDURE delete_acct_event(p_api_version	    IN NUMBER,
                            p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status         OUT NOCOPY VARCHAR2,
                            x_msg_count             OUT NOCOPY NUMBER,
                            x_msg_data              OUT NOCOPY VARCHAR2,
                            p_aetv_rec		    IN aetv_rec_type)

IS

  l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  CURSOR aeh_csr(v_aet_id NUMBER)
  IS
  SELECT ae_header_id
  FROM okl_ae_headers
  WHERE accounting_event_id = v_aet_id;

  l_aehv_rec  aehv_rec_type;

BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   OPEN  aeh_csr(p_aetv_rec.accounting_event_id);
   FETCH aeh_csr INTO l_aehv_rec.ae_header_id;
   IF (aeh_csr%FOUND) THEN
      delete_Acct_header(p_api_version       => p_api_version
                        ,p_init_msg_list     => p_init_msg_list
                        ,x_return_status     => x_return_status
                        ,x_msg_count         => x_msg_count
                        ,x_msg_data          => x_msg_data
                        ,p_aehv_rec          => l_aehv_rec);

   END IF;
   CLOSE aeh_csr;

   IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

      OKL_AET_PVT.delete_row(p_api_version     => p_api_version,
    		             p_init_msg_list   => p_init_msg_list,
                 	     x_return_status   => x_return_status,
                      	     x_msg_count       => x_msg_count,
                      	     x_msg_data        => x_msg_data,
                 	     p_aetv_rec        => p_aetv_rec);

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
END delete_acct_event;


PROCEDURE delete_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_tbl		    IN aetv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_aetv_tbl.COUNT > 0) THEN
       	  i := p_aetv_tbl.FIRST;
       LOOP

	     delete_acct_event(
    	    p_api_version
    	   ,p_init_msg_list
    	   ,x_return_status
    	   ,x_msg_count
    	   ,x_msg_data
    	   ,p_aetv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

          EXIT WHEN (i = p_aetv_tbl.LAST);
          i := p_aetv_tbl.NEXT(i);
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
END delete_acct_event;

PROCEDURE validate_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_rec		    IN aetv_rec_type) IS
BEGIN
    okl_aet_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aetv_rec);
END validate_acct_event;


PROCEDURE validate_acct_event(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aetv_tbl		    IN aetv_tbl_type) IS

    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aetv_tbl.COUNT > 0) THEN
      i := p_aetv_tbl.FIRST;
      LOOP
        validate_acct_event(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aetv_rec                     => p_aetv_tbl(i));

      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_overall_status := x_return_status;
          END IF;
      END IF;

        EXIT WHEN (i = p_aetv_tbl.LAST);
        i := p_aetv_tbl.NEXT(i);
      END LOOP;
          x_return_status := l_overall_status;
    END IF;

END validate_acct_event;

PROCEDURE create_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_rec		    IN aehv_rec_type,
    x_aehv_rec              OUT NOCOPY aehv_rec_type) IS

BEGIN

    okl_aeh_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aehv_rec,
    x_aehv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_aehv_rec.dnz_chr_id);
    END IF;

END create_acct_header;

PROCEDURE create_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_tbl		    IN aehv_tbl_type,
    x_aehv_tbl              OUT NOCOPY aehv_tbl_type) IS
    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        create_Acct_header(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i),
          x_aehv_rec                     => x_aehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END create_acct_header;

PROCEDURE lock_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_rec		    IN aehv_rec_type) IS
BEGIN
    okl_aeh_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aehv_rec);
END lock_acct_header;

PROCEDURE lock_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_tbl		    IN aehv_tbl_type) IS

    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        lock_acct_header(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END lock_acct_header;

PROCEDURE update_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_rec		    IN aehv_rec_type,
    x_aehv_rec              OUT NOCOPY aehv_rec_type) IS
BEGIN
    okl_aeh_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aehv_rec,
    x_aehv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_aehv_rec.dnz_chr_id);
    END IF;
END update_acct_header;


PROCEDURE update_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_tbl		    IN aehv_tbl_type,
    x_aehv_tbl              OUT NOCOPY aehv_tbl_type) IS

    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        update_Acct_header(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i),
          x_aehv_rec                     => x_aehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
      x_return_status := l_overall_status;

END IF;

END update_acct_header;


PROCEDURE delete_acct_header(p_api_version	   IN NUMBER,
                             p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER,
                             x_msg_data            OUT NOCOPY VARCHAR2,
                             p_aehv_rec		   IN aehv_rec_type) IS

  i	                    NUMBER :=0;
  l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_aelv_tbl                OKL_AEL_PVT.AELV_TBL_TYPE;

  CURSOR ael_csr(v_aeh_id NUMBER) IS
  SELECT ae_line_id
  FROM OKL_AE_LINES
  WHERE ae_header_id = v_aeh_id;

  ael_rec ael_csr%ROWTYPE;

BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   FOR ael_rec IN ael_csr(p_aehv_rec.ae_header_id)
   LOOP

     i := i + 1;
     l_aelv_tbl(i).ae_line_id := ael_rec.ae_line_id;

   END LOOP;

   IF (l_aelv_tbl.COUNT > 0) THEN

       delete_acct_lines(p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_Status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_aelv_tbl        => l_aelv_tbl);

   END IF;

   IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

	--Delete the Header

        okl_aeh_pvt.delete_row(p_api_version       => p_api_version,
    		               p_init_msg_list     => p_init_msg_list,
                   	       x_return_status     => x_return_status,
                   	       x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_aehv_rec          => p_aehv_rec);

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
END delete_acct_header;

PROCEDURE delete_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_tbl		    IN aehv_tbl_type) IS
    i	                    NUMBER :=0;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        delete_acct_header(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
      x_return_status := l_overall_status;

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
END delete_acct_header;

PROCEDURE validate_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_rec		    IN aehv_rec_type) IS
BEGIN
    okl_aeh_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aehv_rec);
END validate_acct_header;


PROCEDURE validate_acct_header(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aehv_tbl		    IN aehv_tbl_type) IS

    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aehv_tbl.COUNT > 0) THEN
      i := p_aehv_tbl.FIRST;
      LOOP
        validate_acct_header(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aehv_rec                     => p_aehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aehv_tbl.LAST);
        i := p_aehv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END validate_acct_header;

PROCEDURE create_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_rec		    IN aelv_rec_type,
    x_aelv_rec              OUT NOCOPY aelv_rec_type) IS
BEGIN
    okl_ael_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aelv_rec,
    x_aelv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_aelv_rec.dnz_chr_id);
    END IF;

END create_acct_lines;


PROCEDURE create_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_tbl		    IN aelv_tbl_type,
    x_aelv_tbl              OUT NOCOPY aelv_tbl_type) IS

    i                       NUMBER := 0;
    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

   Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        create_acct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i),
          x_aelv_rec                     => x_aelv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END create_acct_lines;

PROCEDURE lock_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_rec		    IN aelv_rec_type) IS
BEGIN
    okl_ael_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aelv_rec);
END lock_acct_lines;

PROCEDURE lock_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_tbl		    IN aelv_tbl_type) IS

   i                              NUMBER := 0;
    l_overall_status                 VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        lock_acct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END lock_acct_lines;

PROCEDURE update_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_rec		    IN aelv_rec_type,
    x_aelv_rec              OUT NOCOPY aelv_rec_type) IS
BEGIN
    okl_ael_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aelv_rec,
    x_aelv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_aelv_rec.dnz_chr_id);
    END IF;
END update_acct_lines;

PROCEDURE update_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_tbl		    IN aelv_tbl_type,
    x_aelv_tbl              OUT NOCOPY aelv_tbl_type) IS

 i                              NUMBER := 0;
    l_overall_status                 VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        update_Acct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i),
          x_aelv_rec                     => x_aelv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;

END update_acct_lines;

	--Put custom code for cascade delete by developer
PROCEDURE delete_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_rec		    IN aelv_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        okl_ael_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_aelv_rec);

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
END delete_acct_lines;

PROCEDURE delete_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_tbl		    IN aelv_tbl_type) IS

i                              NUMBER := 0;
    l_overall_status                 VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        delete_Acct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error

          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

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
END delete_acct_lines;

PROCEDURE validate_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_rec		    IN aelv_rec_type) IS
BEGIN
    okl_ael_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aelv_rec);
END validate_acct_lines;

PROCEDURE validate_acct_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aelv_tbl		    IN aelv_tbl_type) IS

    i                              NUMBER := 0;
    l_overall_status                 VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aelv_tbl.COUNT > 0) THEN
      i := p_aelv_tbl.FIRST;
      LOOP
        validate_acct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aelv_rec                     => p_aelv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_aelv_tbl.LAST);
        i := p_aelv_tbl.NEXT(i);
      END LOOP;
          -- return overall status
          x_return_status := l_overall_status;

    END IF;


END validate_acct_lines;

END okl_acct_event_pvt;

/
