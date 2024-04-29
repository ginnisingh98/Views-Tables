--------------------------------------------------------
--  DDL for Package Body OKL_TMPT_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TMPT_SET_PVT" AS
/* $Header: OKLCAESB.pls 115.5 2002/02/18 20:10:17 pkm ship       $ */


 PROCEDURE create_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
   ,p_avlv_tbl                     IN avlv_tbl_type
   ,p_atlv_tbl                     IN atlv_tbl_type
   ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
   ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
   ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type
    )

AS

    l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_aesv_rec              aesv_rec_type;
    l_avlv_tbl              avlv_tbl_type := p_avlv_tbl;
    l_atlv_tbl              atlv_tbl_type := p_atlv_tbl;
    i			    NUMBER;
    j			    NUMBER;

BEGIN

    --Populate the Template Set Table

    create_tmpt_set(p_api_version,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_aesv_rec,
                    x_aesv_rec);

-- Proceed Further only if no Error is Encountered.

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

      -- Populate the foreign key for the line
       IF (l_avlv_tbl.COUNT > 0) THEN
          i := l_avlv_tbl.FIRST;
          LOOP
             l_avlv_tbl(i).aes_id := x_aesv_rec.id;
             EXIT WHEN (i = l_avlv_tbl.LAST);
             i := l_avlv_tbl.NEXT(i);
          END LOOP;
       END IF;

    --Populate the Template Table

       create_template(p_api_version,
    	               p_init_msg_list,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       l_avlv_tbl,
                       x_avlv_tbl);

-- Proceed with the lines only if Template Creation is Successful.

       IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

          -- Populate the foreign key for the detail
           IF (l_avlv_tbl.COUNT > 0) THEN
               i := l_avlv_tbl.FIRST;
               LOOP
                  j := l_atlv_tbl.FIRST;
	          LOOP
                     IF (i = p_atlv_tbl(j).avl_tbl_index) THEN
             	         l_atlv_tbl(j).avl_id := x_avlv_tbl(i).id;
            	     END IF;
	   	     EXIT WHEN (j = l_atlv_tbl.LAST);
                     j := l_atlv_tbl.NEXT(j);
	          END LOOP;
                  EXIT WHEN (i = l_avlv_tbl.LAST);
                  i := l_avlv_tbl.NEXT(i);
               END LOOP;
           END IF;

           --Populate the detail
           create_tmpt_lines(p_api_version,
    	                     p_init_msg_list,
    	                     x_return_status,
                             x_msg_count,
                             x_msg_data,
                             l_atlv_tbl,
                             x_atlv_tbl);
       END IF;

    END IF;


EXCEPTION

   WHEN OTHERS THEN
      Okc_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

END;


 PROCEDURE update_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
   ,p_avlv_tbl                     IN avlv_tbl_type
   ,p_atlv_tbl                     IN atlv_tbl_type
   ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
   ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
   ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type
    )
	AS
   l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

    --Update the Template Set Table

    update_tmpt_set(p_api_version,
    	            p_init_msg_list,
               	    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_aesv_rec,
                    x_aesv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    --Update the Template Table
        update_template(p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        p_avlv_tbl,
                        x_avlv_tbl);

        IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    --Update the Template Line Table
           update_tmpt_lines(p_api_version,
                             p_init_msg_list,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             p_atlv_tbl,
                             x_atlv_tbl);
        END IF;

    END IF;

END UPDATE_TMPT_SET;



 PROCEDURE validate_tmpt_set(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_aesv_rec                     IN aesv_rec_type
   ,p_avlv_tbl                     IN avlv_tbl_type
   ,p_atlv_tbl                     IN atlv_tbl_type
    )

AS
   l_overall_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN

   -- Validate the Template Set Table

    validate_tmpt_set(p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      p_aesv_rec);

     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             l_overall_status := x_return_status;
         END IF;
     END IF;

    --Validate the Template Table
    validate_template(p_api_version,
                      p_init_msg_list,
                      x_return_status,
                      x_msg_count,
                      x_msg_data,
                      p_avlv_tbl);

     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             l_overall_status := x_return_status;
         END IF;
     END IF;

    --Validate the detail
    validate_tmpt_lines(p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        p_atlv_tbl);

     IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             l_overall_status := x_return_status;
         END IF;
     END IF;

     x_return_status := l_overall_status;


EXCEPTION

   WHEN OTHERS THEN
      Okc_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

END;


PROCEDURE create_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec		    IN aesv_rec_type,
    x_aesv_rec              OUT NOCOPY aesv_rec_type) IS

BEGIN

    okl_aes_pvt.insert_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_aesv_rec,
                           x_aesv_rec);

END create_tmpt_set;

PROCEDURE create_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_tbl		    IN aesv_tbl_type,
    x_aesv_tbl              OUT NOCOPY aesv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
BEGIN

   Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
   IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        create_tmpt_set(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i),
          x_aesv_rec                     => x_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;

END create_tmpt_set;


PROCEDURE lock_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec		    IN aesv_rec_type) IS
BEGIN
    okl_aes_pvt.lock_row(p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_aesv_rec);
END lock_tmpt_set;

PROCEDURE lock_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_tbl		    IN aesv_tbl_type) IS

    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_aesv_tbl.COUNT > 0) THEN
       i := p_aesv_tbl.FIRST;
       LOOP
          lock_tmpt_set(p_api_version  => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_aesv_rec => p_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = p_aesv_tbl.LAST);
          i := p_aesv_tbl.NEXT(i);
       END LOOP;
     END IF;

     x_return_status := l_overall_status;

END lock_tmpt_set;

PROCEDURE update_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec		    IN aesv_rec_type,
    x_aesv_rec              OUT NOCOPY aesv_rec_type) IS
BEGIN
    okl_aes_pvt.update_row(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_aesv_rec,
                           x_aesv_rec);

END update_tmpt_set;

PROCEDURE update_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_tbl		    IN aesv_tbl_type,
    x_aesv_tbl              OUT NOCOPY aesv_tbl_type) IS

    l_overall_status        VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                       NUMBER := 0;

BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aesv_tbl.COUNT > 0) THEN
      i := p_aesv_tbl.FIRST;
      LOOP
        update_tmpt_set(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aesv_rec                     => p_aesv_tbl(i),
          x_aesv_rec                     => x_aesv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

END update_tmpt_set;


PROCEDURE delete_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec		    IN aesv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


CURSOR tmpl_csr(p_aes_id NUMBER)
IS
SELECT id
FROM okl_ae_templates
WHERE aes_id = p_aes_id;


l_ae_template_tbl OKL_AVL_PVT.avlv_tbl_type;

i NUMBER := 0;
j NUMBER := 0;

BEGIN


  FOR tmpl_rec IN tmpl_csr(p_aesv_rec.ID)
  LOOP
      j := j + 1;
      l_ae_template_tbl(j).ID := tmpl_rec.ID;
  END LOOP;

-- Delete_template will take care of deleting the Lines as well.

  delete_template(p_api_version
                 ,p_init_msg_list
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data
                 ,l_ae_template_tbl);

  IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

        delete_tmpt_set(p_api_version,
    		        p_init_msg_list,
    		        x_return_status,
    		        x_msg_count,
    		        x_msg_data,
    		        p_aesv_rec);
  END IF;


EXCEPTION

   WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_tmpt_set;


PROCEDURE delete_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_tbl		    IN aesv_tbl_type) IS
    i	                    NUMBER :=0;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_aesv_tbl.COUNT > 0) THEN
       	  i := p_aesv_tbl.FIRST;
       LOOP
	   delete_tmpt_set(
    	    p_api_version
    	   ,p_init_msg_list
    	   ,x_return_status
    	   ,x_msg_count
    	   ,x_msg_data
    	   ,p_aesv_tbl(i));

           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
           END IF;

          EXIT WHEN (i = p_aesv_tbl.LAST);
          i := p_aesv_tbl.NEXT(i);
       END LOOP;

    END IF;

    x_return_status := l_overall_status;

END delete_tmpt_set;


PROCEDURE validate_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec		    IN aesv_rec_type) IS
BEGIN
    okl_aes_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_aesv_rec);
END validate_tmpt_set;

PROCEDURE validate_tmpt_set(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_tbl		    IN aesv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

BEGIN
   Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing

    IF (p_aesv_tbl.COUNT > 0) THEN

      i := p_aesv_tbl.FIRST;

      LOOP
         validate_tmpt_set(p_api_version,
                           p_init_msg_list,
                           x_return_status,
                           x_msg_count,
                           x_msg_data,
                           p_aesv_tbl(i));

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
         END IF;

        EXIT WHEN (i = p_aesv_tbl.LAST);
        i := p_aesv_tbl.NEXT(i);

      END LOOP;

    END IF;

    x_return_status := l_overall_status;

END validate_tmpt_set;

PROCEDURE create_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_rec		    IN avlv_rec_type,
    x_avlv_rec              OUT NOCOPY avlv_rec_type) IS
BEGIN
    okl_avl_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_avlv_rec,
    x_avlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_avlv_rec.dnz_chr_id);
    END IF;

END create_template;


PROCEDURE create_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_tbl		    IN avlv_tbl_type,
    x_avlv_tbl              OUT NOCOPY avlv_tbl_type) IS

    i      NUMBER := 0;
    l_overall_Status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        create_template(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i),
          x_avlv_rec                     => x_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

END create_template;


PROCEDURE lock_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_rec		    IN avlv_rec_type) IS
BEGIN
    okl_avl_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_avlv_rec);
END lock_template;

PROCEDURE lock_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_tbl		    IN avlv_tbl_type) IS

   l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   i         NUMBER := 0;

BEGIN

Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        lock_template(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

END lock_template;

PROCEDURE update_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_rec		    IN avlv_rec_type,
    x_avlv_rec              OUT NOCOPY avlv_rec_type) IS
BEGIN

    OKL_AVL_PVT.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_avlv_rec,
    x_avlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_avlv_rec.dnz_chr_id);
    END IF;
END update_template;

PROCEDURE update_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_tbl		    IN avlv_tbl_type,
    x_avlv_tbl              OUT NOCOPY avlv_tbl_type) IS
   l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   i         NUMBER := 0;
BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        update_template(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i),
          x_avlv_rec                     => x_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

END update_template;


PROCEDURE delete_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_rec		    IN avlv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_atlv_tbl                  OKL_ATL_PVT.ATLV_TBL_TYPE;

CURSOR atl_csr(v_avl_id NUMBER) IS
SELECT ID
FROM OKL_AE_TMPT_LNES
WHERE avl_id = p_avlv_rec.ID;

atl_rec atl_csr%ROWTYPE;

BEGIN

   FOR atl_rec IN atl_csr(p_avlv_rec.ID)
   LOOP

     i := i + 1;
     l_atlv_tbl(i).ID := atl_rec.ID;

   END LOOP;

   delete_tmpt_lines(p_api_version,
                     p_init_msg_list,
                     x_return_Status,
                     x_msg_count,
                     x_msg_data,
                     l_atlv_tbl);

   IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

        okl_avl_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_avlv_rec);
   END IF;

END delete_template;



PROCEDURE delete_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_tbl		    IN avlv_tbl_type) IS
    i	                    NUMBER :=0;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
      --Initialize the return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_avlv_tbl.COUNT > 0) THEN
       	  i := p_avlv_tbl.FIRST;
       LOOP
          delete_template(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = p_avlv_tbl.LAST);
          i := p_avlv_tbl.NEXT(i);
       END LOOP;
    END IF;

    x_return_status := l_overall_status;

END delete_template;

PROCEDURE validate_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_rec		    IN avlv_rec_type) IS
BEGIN
    okl_avl_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_avlv_rec);
END validate_template;

PROCEDURE validate_template(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_avlv_tbl		    IN avlv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_avlv_tbl.COUNT > 0) THEN
      i := p_avlv_tbl.FIRST;
      LOOP
        validate_template(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_avlv_rec                     => p_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_avlv_tbl.LAST);
        i := p_avlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

END validate_template;

PROCEDURE create_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_rec		    IN atlv_rec_type,
    x_atlv_rec              OUT NOCOPY atlv_rec_type) IS
BEGIN
    okl_atl_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_atlv_rec,
    x_atlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_atlv_rec.dnz_chr_id);
    END IF;

END create_tmpt_lines;

PROCEDURE create_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_tbl		    IN atlv_tbl_type,
    x_atlv_tbl              OUT NOCOPY atlv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        create_tmpt_lines (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i),
          x_atlv_rec                     => x_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

END create_tmpt_lines;

PROCEDURE lock_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_rec		    IN atlv_rec_type) IS
BEGIN
    okl_atl_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_atlv_rec);
END lock_tmpt_lines;

PROCEDURE lock_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_tbl		    IN atlv_tbl_type) IS
   l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   i         NUMBER := 0;
BEGIN

 Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        lock_tmpt_lines (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

END lock_tmpt_lines;

PROCEDURE update_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_rec		    IN atlv_rec_type,
    x_atlv_rec              OUT NOCOPY atlv_rec_type) IS
BEGIN
    okl_atl_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_atlv_rec,
    x_atlv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_atlv_rec.dnz_chr_id);
    END IF;
END update_tmpt_lines;

PROCEDURE update_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_tbl		    IN atlv_tbl_type,
    x_atlv_tbl              OUT NOCOPY atlv_tbl_type) IS
   l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   i         NUMBER := 0;
BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        update_tmpt_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i),
          x_atlv_rec                     => x_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;

END update_tmpt_lines;


	--Put custom code for cascade delete by developer
PROCEDURE delete_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_rec		    IN atlv_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        okl_atl_pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_atlv_rec);

END delete_tmpt_lines;

PROCEDURE delete_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_tbl		    IN atlv_tbl_type) IS
    i	                    NUMBER :=0;
    l_overall_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
      --Initialize the return status

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (p_atlv_tbl.COUNT > 0) THEN
       	  i := p_atlv_tbl.FIRST;
       LOOP
          delete_tmpt_lines(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = p_atlv_tbl.LAST);
          i := p_atlv_tbl.NEXT(i);
       END LOOP;

    END IF;
    x_return_status := l_overall_Status;

END delete_tmpt_lines;

PROCEDURE validate_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_rec		    IN atlv_rec_type) IS
BEGIN
    okl_atl_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_atlv_rec);
END validate_tmpt_lines;

PROCEDURE validate_tmpt_lines(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_atlv_tbl		    IN atlv_tbl_type) IS

    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_atlv_tbl.COUNT > 0) THEN
      i := p_atlv_tbl.FIRST;
      LOOP
        validate_tmpt_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_atlv_rec                     => p_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_atlv_tbl.LAST);
        i := p_atlv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

END validate_tmpt_lines;


END okl_tmpt_set_pvt;

/
