--------------------------------------------------------
--  DDL for Package Body OKL_INCSH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INCSH_PVT" AS
/* $Header: OKLCRCTB.pls 115.4 2002/02/05 11:50:00 pkm ship       $ */

PROCEDURE ADD_LANGUAGE IS
BEGIN
	Okl_Rct_Pvt.add_language;
	Okl_Rca_Pvt.add_language;
END ;


--Object type procedure for insert
PROCEDURE create_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
    ,p_rcav_tbl                     IN rcav_tbl_type
    ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
    ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    ) IS

    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rctv_rec              rctv_rec_type;
    l_rcav_tbl              rcav_tbl_type := p_rcav_tbl;
    i			    		NUMBER;
BEGIN

    --Populate the Master
    create_internal_trans(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_rctv_rec,
    	x_rctv_rec);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;

    -- Populate the foreign key for the detail
    IF (l_rcav_tbl.COUNT > 0) THEN
       i := l_rcav_tbl.FIRST;
       LOOP
          l_rcav_tbl(i).rct_id_details := x_rctv_rec.id;
          EXIT WHEN (i = l_rcav_tbl.LAST);
          i := l_rcav_tbl.NEXT(i);
       END LOOP;
    END IF;


    --Populate the detail
    create_internal_trans(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
   		x_msg_count,
    	x_msg_data,
    	l_rcav_tbl,
    	x_rcav_tbl);

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
 	END IF;


EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END ;

--Object type procedure for update
PROCEDURE update_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
   ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
   ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    ) IS
   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
    --Update the Master
    update_internal_trans(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_rctv_rec,
    	x_rctv_rec);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;

    --Update the detail
    update_internal_trans(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl,
    x_rcav_tbl);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END ;

--Object type procedure for delete
PROCEDURE delete_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
   ,x_rctv_rec                     OUT NOCOPY rctv_rec_type
   ,x_rcav_tbl                     OUT NOCOPY rcav_tbl_type
    ) IS
   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
    --Delete the Master
    delete_internal_trans(
    	p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_rctv_rec);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;

    -- Delete the detail
    delete_internal_trans(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;
EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END ;

--Object type procedure for validate
PROCEDURE validate_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
   ,p_rcav_tbl                     IN rcav_tbl_type
    ) IS
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
    --Validate the Master
    validate_internal_trans(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_rec);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
       		l_return_status := x_return_status;
      	END IF;
   	END IF;

    --Validate the Detail
    validate_internal_trans(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END ;



PROCEDURE create_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_rec		    IN rctv_rec_type,
    x_rctv_rec              OUT NOCOPY rctv_rec_type) IS
BEGIN

    Okl_Rct_Pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_rec,
    x_rctv_rec);



    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_rctv_rec.dnz_chr_id);
    END IF;

END create_internal_trans;

PROCEDURE create_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_tbl		    IN rctv_tbl_type,
    x_rctv_tbl              OUT NOCOPY rctv_tbl_type) IS
BEGIN
    Okl_Rct_Pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_tbl,
    x_rctv_tbl);
END create_internal_trans;

PROCEDURE lock_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_rec		    IN rctv_rec_type) IS
BEGIN
    Okl_Rct_Pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_rec);
END lock_internal_trans;

PROCEDURE lock_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_tbl		    IN rctv_tbl_type) IS
BEGIN
    Okl_Rct_Pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_tbl);
END lock_internal_trans;

PROCEDURE update_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_rec		    IN rctv_rec_type,
    x_rctv_rec              OUT NOCOPY rctv_rec_type) IS
BEGIN
    Okl_Rct_Pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_rec,
    x_rctv_rec);

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_rctv_rec.dnz_chr_id);
    END IF;
END update_internal_trans;

PROCEDURE update_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_tbl		    IN rctv_tbl_type,
    x_rctv_tbl              OUT NOCOPY rctv_tbl_type) IS
BEGIN
    Okl_Rct_Pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_tbl,
    x_rctv_tbl);
END update_internal_trans;

	--Put custom code for cascade delete by developer
PROCEDURE delete_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_rec		    IN rctv_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        Okl_Rct_Pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_rctv_rec);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      	RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
    END IF;
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
       -- Custom Code by developer Update_Minor_Version(p_rctv_rec.dnz_chr_id);
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END delete_internal_trans;

PROCEDURE delete_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_tbl		    IN rctv_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
      --Initialize the return status
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      IF (p_rctv_tbl.COUNT > 0) THEN
       	  i := p_rctv_tbl.FIRST;
       LOOP
          delete_internal_trans(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_rctv_tbl(i));
          EXIT WHEN (i = p_rctv_tbl.LAST);
          i := p_rctv_tbl.NEXT(i);
       END LOOP;
    END IF;
    	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END delete_internal_trans;

PROCEDURE validate_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_rec		    IN rctv_rec_type) IS
BEGIN
    Okl_Rct_Pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_rec);
END validate_internal_trans;

PROCEDURE validate_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rctv_tbl		    IN rctv_tbl_type) IS
BEGIN
    Okl_Rct_Pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rctv_tbl);
END validate_internal_trans;

PROCEDURE create_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_rec		    IN rcav_rec_type,
    x_rcav_rec              OUT NOCOPY rcav_rec_type) IS
BEGIN
    Okl_Rca_Pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_rec,
    x_rcav_rec);

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_rcav_rec.dnz_chr_id);
    END IF;

END create_internal_trans;

PROCEDURE create_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_tbl		    IN rcav_tbl_type,
    x_rcav_tbl              OUT NOCOPY rcav_tbl_type) IS
BEGIN
    Okl_Rca_Pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl,
    x_rcav_tbl);
END create_internal_trans;

PROCEDURE lock_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_rec		    IN rcav_rec_type) IS
BEGIN
    Okl_Rca_Pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_rec);
END lock_internal_trans;

PROCEDURE lock_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_tbl		    IN rcav_tbl_type) IS
BEGIN
    Okl_Rca_Pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl);
END lock_internal_trans;

PROCEDURE update_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_rec		    IN rcav_rec_type,
    x_rcav_rec              OUT NOCOPY rcav_rec_type) IS
BEGIN
    Okl_Rca_Pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_rec,
    x_rcav_rec);

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_rcav_rec.dnz_chr_id);
    END IF;
END update_internal_trans;

PROCEDURE update_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_tbl		    IN rcav_tbl_type,
    x_rcav_tbl              OUT NOCOPY rcav_tbl_type) IS
BEGIN
    Okl_Rca_Pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl,
    x_rcav_tbl);
END update_internal_trans;

	--Put custom code for cascade delete by developer
PROCEDURE delete_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_rec		    IN rcav_rec_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        Okl_Rca_Pvt.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_rcav_rec);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      	RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
    END IF;
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
       -- Custom Code by developer Update_Minor_Version(p_rcav_rec.dnz_chr_id);
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END delete_internal_trans;

PROCEDURE delete_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_tbl		    IN rcav_tbl_type) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
      --Initialize the return status
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      IF (p_rcav_tbl.COUNT > 0) THEN
       	  i := p_rcav_tbl.FIRST;
       LOOP
          delete_internal_trans(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_rcav_tbl(i));
          EXIT WHEN (i = p_rcav_tbl.LAST);
          i := p_rcav_tbl.NEXT(i);
       END LOOP;
    END IF;
    	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
    	END IF;
EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END delete_internal_trans;

PROCEDURE validate_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_rec		    IN rcav_rec_type) IS
BEGIN
    Okl_Rca_Pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_rec);
END validate_internal_trans;

PROCEDURE validate_internal_trans(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rcav_tbl		    IN rcav_tbl_type) IS
BEGIN
    Okl_Rca_Pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rcav_tbl);
END validate_internal_trans;

END Okl_Incsh_Pvt;

/
