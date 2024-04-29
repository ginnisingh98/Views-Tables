--------------------------------------------------------
--  DDL for Package Body OKL_EXTRN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXTRN_PVT" AS
/* $Header: OKLCXCRB.pls 115.1 2002/03/18 08:28:47 pkm ship        $ */

PROCEDURE ADD_LANGUAGE IS
BEGIN
	 Okl_Xcr_Pvt.ADD_LANGUAGE;
	 Okl_Xca_Pvt.ADD_LANGUAGE;
END ADD_LANGUAGE;

 --Object type procedure for insert
PROCEDURE create_ext_csh_txns( p_api_version                  IN NUMBER
                              ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
                              ,x_return_status                OUT NOCOPY VARCHAR2
                              ,x_msg_count                    OUT NOCOPY NUMBER
                              ,x_msg_data                     OUT NOCOPY VARCHAR2
                              ,p_xcrv_rec                     IN xcrv_rec_type
							  ,p_xcav_tbl                     IN xcav_tbl_type
    						  ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
   							  ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
							 ) IS

    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_xcrv_rec              xcrv_rec_type := p_xcrv_rec;
    l_xcav_tbl              xcav_tbl_type := p_xcav_tbl;
    i			    		NUMBER;
    j			    		NUMBER;

BEGIN

    --Populate the Master
    create_ext_csh_txns( p_api_version
    					,p_init_msg_list
    					,x_return_status
   						,x_msg_count
    					,x_msg_data
    					,l_xcrv_rec
    					,x_xcrv_rec
					   );

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
 	END IF;

    -- Populate the foreign key for the line
    IF (l_xcav_tbl.COUNT > 0) THEN
       i := l_xcav_tbl.FIRST;
       LOOP
          l_xcav_tbl(i).xcr_id_details := x_xcrv_rec.id;
          EXIT WHEN (i = l_xcav_tbl.LAST);
          i := l_xcav_tbl.NEXT(i);
       END LOOP;
    END IF;

    --Populate the detail
    create_ext_csh_txns( p_api_version
    				    ,p_init_msg_list
    					,x_return_status
   						,x_msg_count
    					,x_msg_data
    					,l_xcav_tbl
    					,x_xcav_tbl
					   );

	IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
 	END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END create_ext_csh_txns;

 --Object type procedure for update
 PROCEDURE update_ext_csh_txns( p_api_version                  IN NUMBER
   		   					   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   							   ,x_return_status                OUT NOCOPY VARCHAR2
   							   ,x_msg_count                    OUT NOCOPY NUMBER
   							   ,x_msg_data                     OUT NOCOPY VARCHAR2
   							   ,p_xcrv_rec                     IN xcrv_rec_type
   							   ,p_xcav_tbl                     IN xcav_tbl_type
							   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
   							   ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
    						  ) IS

   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN

     --Update the master
    update_ext_csh_txns( p_api_version
    					,p_init_msg_list
    					,x_return_status
    					,x_msg_count
    					,x_msg_data
    					,p_xcrv_rec
    					,x_xcrv_rec
					   );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;

    --Update the detail
    update_ext_csh_txns( p_api_version
    				    ,p_init_msg_list
    					,x_return_status
    					,x_msg_count
    					,x_msg_data
    					,p_xcav_tbl
    					,x_xcav_tbl
					   );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;

EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okl_Api.set_message( p_app_name      => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM
						 );

      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END update_ext_csh_txns;

--Object type procedure for update
 PROCEDURE delete_ext_csh_txns( p_api_version                  IN NUMBER
   		   					   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   							   ,x_return_status                OUT NOCOPY VARCHAR2
   							   ,x_msg_count                    OUT NOCOPY NUMBER
   							   ,x_msg_data                     OUT NOCOPY VARCHAR2
   							   ,p_xcrv_rec                     IN xcrv_rec_type
   							   ,p_xcav_tbl                     IN xcav_tbl_type
							   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
   							   ,x_xcav_tbl                     OUT NOCOPY xcav_tbl_type
    						  ) IS

   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

 BEGIN

     --Update the master
    delete_ext_csh_txns( p_api_version
    					,p_init_msg_list
    					,x_return_status
    					,x_msg_count
    					,x_msg_data
    					,p_xcrv_rec
					   );


    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;

    --Update the detail
    delete_ext_csh_txns( p_api_version
    				    ,p_init_msg_list
    					,x_return_status
    					,x_msg_count
    					,x_msg_data
    					,p_xcav_tbl
					   );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
   		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
       	END IF;
   	END IF;

 EXCEPTION
   WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okl_Api.set_message( p_app_name      => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM
						 );

      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

 END delete_ext_csh_txns;

 --Object type procedure for validate
 PROCEDURE validate_ext_csh_txns( p_api_version                  IN NUMBER
   		   						 ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   								 ,x_return_status                OUT NOCOPY VARCHAR2
   								 ,x_msg_count                    OUT NOCOPY NUMBER
   								 ,x_msg_data                     OUT NOCOPY VARCHAR2
   								 ,p_xcrv_rec                     IN xcrv_rec_type
   								 ,p_xcav_tbl                     IN xcav_tbl_type
    							) IS

   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN

    --Validate the Master
    validate_ext_csh_txns( p_api_version
    					  ,p_init_msg_list
    					  ,x_return_status
    					  ,x_msg_count
    					  ,x_msg_data
    					  ,p_xcrv_rec
						 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

    --Validate the detail
    validate_ext_csh_txns( p_api_version
    					  ,p_init_msg_list
    					  ,x_return_status
    					  ,x_msg_count
    					  ,x_msg_data
    					  ,p_xcav_tbl
						 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      Okl_Api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
END validate_ext_csh_txns;

PROCEDURE create_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
     						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcrv_rec		    IN xcrv_rec_type
    						  ,x_xcrv_rec           OUT NOCOPY xcrv_rec_type
							 )IS
BEGIN
    Okl_Xcr_Pvt.insert_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcrv_rec
    					   ,x_xcrv_rec
						  );

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_xcrv_rec.dnz_chr_id);
    END IF;

END create_ext_csh_txns;

PROCEDURE create_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcrv_tbl		    IN xcrv_tbl_type
   							  ,x_xcrv_tbl           OUT NOCOPY xcrv_tbl_type
							 ) IS
BEGIN
    Okl_Xcr_Pvt.insert_row( p_api_version
    					   ,p_init_msg_list
    				 	   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcrv_tbl
    					   ,x_xcrv_tbl
						  );

END create_ext_csh_txns;

PROCEDURE lock_ext_csh_txns( p_api_version	    IN NUMBER
    	  					,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						,x_return_status    OUT NOCOPY VARCHAR2
    						,x_msg_count        OUT NOCOPY NUMBER
    						,x_msg_data         OUT NOCOPY VARCHAR2
    						,p_xcrv_rec		    IN xcrv_rec_type
						   ) IS
BEGIN
    Okl_Xcr_Pvt.lock_row( p_api_version
    					 ,p_init_msg_list
    					 ,x_return_status
    					 ,x_msg_count
    					 ,x_msg_data
    					 ,p_xcrv_rec
						);
END lock_ext_csh_txns;

PROCEDURE lock_ext_csh_txns( p_api_version	    IN NUMBER
    	  					,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						,x_return_status    OUT NOCOPY VARCHAR2
    						,x_msg_count        OUT NOCOPY NUMBER
    						,x_msg_data         OUT NOCOPY VARCHAR2
    						,p_xcrv_tbl		    IN xcrv_tbl_type
						   ) IS
BEGIN
    Okl_Xcr_Pvt.lock_row( p_api_version
    					 ,p_init_msg_list
    					 ,x_return_status
    					 ,x_msg_count
    					 ,x_msg_data
    					 ,p_xcrv_tbl
						 );
END lock_ext_csh_txns;

PROCEDURE update_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcrv_rec		    IN xcrv_rec_type
    						  ,x_xcrv_rec           OUT NOCOPY xcrv_rec_type
							 ) IS

BEGIN
    Okl_Xcr_Pvt.update_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcrv_rec
    					   ,x_xcrv_rec
						  );

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_xcrv_rec.dnz_chr_id);
    END IF;
END update_ext_csh_txns;

PROCEDURE update_ext_csh_txns( p_api_version	  IN NUMBER
    	  					  ,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status    OUT NOCOPY VARCHAR2
    						  ,x_msg_count        OUT NOCOPY NUMBER
    						  ,x_msg_data         OUT NOCOPY VARCHAR2
    						  ,p_xcrv_tbl		  IN xcrv_tbl_type
    						  ,x_xcrv_tbl         OUT NOCOPY xcrv_tbl_type
							 ) IS
BEGIN
    Okl_Xcr_Pvt.update_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcrv_tbl
    					   ,x_xcrv_tbl
						  );
END update_ext_csh_txns;

	--Put custom code for cascade delete by developer
PROCEDURE delete_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcrv_rec		    IN xcrv_rec_type
							 ) IS

    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        Okl_Xcr_Pvt.delete_row( p_api_version
    						   ,p_init_msg_list
    						   ,x_return_status
    						   ,x_msg_count
    						   ,x_msg_data
    						   ,p_xcrv_rec
							  );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      	RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
    END IF;
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
       -- Custom Code by developer Update_Minor_Version(p_xcrv_rec.dnz_chr_id);
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
END delete_ext_csh_txns;

PROCEDURE delete_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcrv_tbl		    IN xcrv_tbl_type
							 ) IS

    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

BEGIN
      --Initialize the return status
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      IF (p_xcrv_tbl.COUNT > 0) THEN
       	  i := p_xcrv_tbl.FIRST;
       LOOP
          delete_ext_csh_txns( p_api_version
    						  ,p_init_msg_list
    						  ,x_return_status
    						  ,x_msg_count
    						  ,x_msg_data
    						  ,p_xcrv_tbl(i)
							 );
          EXIT WHEN (i = p_xcrv_tbl.LAST);
          i := p_xcrv_tbl.NEXT(i);
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
END delete_ext_csh_txns;

PROCEDURE validate_ext_csh_txns( p_api_version	    IN NUMBER
    	  						,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    							,x_return_status    OUT NOCOPY VARCHAR2
    							,x_msg_count        OUT NOCOPY NUMBER
    							,x_msg_data         OUT NOCOPY VARCHAR2
   								,p_xcrv_rec		    IN xcrv_rec_type
							   ) IS

BEGIN
    Okl_Xcr_Pvt.validate_row( p_api_version
    						 ,p_init_msg_list
   							 ,x_return_status
    						 ,x_msg_count
    						 ,x_msg_data
    						 ,p_xcrv_rec
							);
END validate_ext_csh_txns;

PROCEDURE validate_ext_csh_txns( p_api_version	    IN NUMBER
    	  						,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    							,x_return_status    OUT NOCOPY VARCHAR2
    							,x_msg_count        OUT NOCOPY NUMBER
    							,x_msg_data         OUT NOCOPY VARCHAR2
    							,p_xcrv_tbl		    IN xcrv_tbl_type
							   )IS
BEGIN
    Okl_Xcr_Pvt.validate_row( p_api_version
   	 					     ,p_init_msg_list
    						 ,x_return_status
    						 ,x_msg_count
    						 ,x_msg_data
    						 ,p_xcrv_tbl
							);
END validate_ext_csh_txns;

PROCEDURE create_ext_csh_txns( p_api_version	   IN NUMBER
    	  					  ,p_init_msg_list     IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status     OUT NOCOPY VARCHAR2
    						  ,x_msg_count         OUT NOCOPY NUMBER
    						  ,x_msg_data          OUT NOCOPY VARCHAR2
    						  ,p_xcav_rec		   IN xcav_rec_type
    						  ,x_xcav_rec          OUT NOCOPY xcav_rec_type
							 ) IS
BEGIN
    Okl_Xca_Pvt.insert_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcav_rec
    					   ,x_xcav_rec
						  );

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
    NULL;
    -- Custom code by developer   Update_Minor_Version(p_xcav_rec.dnz_chr_id);
    END IF;

END create_ext_csh_txns;

PROCEDURE create_ext_csh_txns( p_api_version	   IN NUMBER
    	  					  ,p_init_msg_list     IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status     OUT NOCOPY VARCHAR2
    						  ,x_msg_count         OUT NOCOPY NUMBER
    						  ,x_msg_data          OUT NOCOPY VARCHAR2
    						  ,p_xcav_tbl		   IN xcav_tbl_type
    						  ,x_xcav_tbl          OUT NOCOPY xcav_tbl_type
							  ) IS
BEGIN
    Okl_Xca_Pvt.insert_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcav_tbl
    					   ,x_xcav_tbl
						  );
END create_ext_csh_txns;

PROCEDURE lock_ext_csh_txns( p_api_version	    IN NUMBER
    	  					,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						,x_return_status    OUT NOCOPY VARCHAR2
    						,x_msg_count        OUT NOCOPY NUMBER
    						,x_msg_data         OUT NOCOPY VARCHAR2
    						,p_xcav_rec		    IN xcav_rec_type
						   ) IS
BEGIN
    Okl_Xca_Pvt.lock_row( p_api_version
    					 ,p_init_msg_list
    					 ,x_return_status
    					 ,x_msg_count
    					 ,x_msg_data
    					 ,p_xcav_rec
						);
END lock_ext_csh_txns;

PROCEDURE lock_ext_csh_txns( p_api_version	    IN NUMBER
    	  					,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						,x_return_status    OUT NOCOPY VARCHAR2
    						,x_msg_count        OUT NOCOPY NUMBER
    						,x_msg_data         OUT NOCOPY VARCHAR2
    						,p_xcav_tbl		    IN xcav_tbl_type
						   ) IS
BEGIN
    Okl_Xca_Pvt.lock_row( p_api_version
    					 ,p_init_msg_list
    					 ,x_return_status
    					 ,x_msg_count
    					 ,x_msg_data
    					 ,p_xcav_tbl
						 );
END lock_ext_csh_txns;

PROCEDURE update_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
							  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcav_rec		    IN xcav_rec_type
    						  ,x_xcav_rec           OUT NOCOPY xcav_rec_type
							 ) IS
BEGIN
    Okl_Xca_Pvt.update_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcav_rec
    					   ,x_xcav_rec
						  );

    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
     -- Custom code by developer  Update_Minor_Version(p_xcav_rec.id);
    END IF;
END update_ext_csh_txns;

PROCEDURE update_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcav_tbl		    IN xcav_tbl_type
    						  ,x_xcav_tbl           OUT NOCOPY xcav_tbl_type
							 ) IS
BEGIN
    Okl_Xca_Pvt.update_row( p_api_version
    					   ,p_init_msg_list
    					   ,x_return_status
    					   ,x_msg_count
    					   ,x_msg_data
    					   ,p_xcav_tbl
    					   ,x_xcav_tbl
						  );
END update_ext_csh_txns;

	--Put custom code for cascade delete by developer
PROCEDURE delete_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcav_rec		    IN xcav_rec_type
	) IS
    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
	--Delete the Master
        Okl_Xca_Pvt.delete_row( p_api_version
    						   ,p_init_msg_list
    						   ,x_return_status
    						   ,x_msg_count
    						   ,x_msg_data
    						   ,p_xcav_rec
							  );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      	RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
        END IF;
    END IF;
    IF (x_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
	NULL;
       -- Custom Code by developer Update_Minor_Version(p_xcav_rec.dnz_chr_id);
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
END delete_ext_csh_txns;

PROCEDURE delete_ext_csh_txns( p_api_version	    IN NUMBER
    	  					  ,p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    						  ,x_return_status      OUT NOCOPY VARCHAR2
    						  ,x_msg_count          OUT NOCOPY NUMBER
    						  ,x_msg_data           OUT NOCOPY VARCHAR2
    						  ,p_xcav_tbl		    IN xcav_tbl_type
							 ) IS

    i	                    NUMBER :=0;
    l_return_status 	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN
      --Initialize the return status
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      IF (p_xcav_tbl.COUNT > 0) THEN
       	  i := p_xcav_tbl.FIRST;
       LOOP
          delete_ext_csh_txns( p_api_version
    						  ,p_init_msg_list
    						  ,x_return_status
    						  ,x_msg_count
    						  ,x_msg_data
    						  ,p_xcav_tbl(i)
							 );

          EXIT WHEN (i = p_xcav_tbl.LAST);
          i := p_xcav_tbl.NEXT(i);
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
END delete_ext_csh_txns;

PROCEDURE validate_ext_csh_txns( p_api_version	    IN NUMBER
    	  						,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    							,x_return_status    OUT NOCOPY VARCHAR2
    							,x_msg_count        OUT NOCOPY NUMBER
    							,x_msg_data         OUT NOCOPY VARCHAR2
    							,p_xcav_rec		    IN xcav_rec_type
							   ) IS

BEGIN
    Okl_Xca_Pvt.validate_row( p_api_version
    						 ,p_init_msg_list
    						 ,x_return_status
    						 ,x_msg_count
    						 ,x_msg_data
    						 ,p_xcav_rec
							);
END validate_ext_csh_txns;

PROCEDURE validate_ext_csh_txns( p_api_version	    IN NUMBER
    	  						,p_init_msg_list    IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
    							,x_return_status    OUT NOCOPY VARCHAR2
    							,x_msg_count        OUT NOCOPY NUMBER
    							,x_msg_data         OUT NOCOPY VARCHAR2
    							,p_xcav_tbl		    IN xcav_tbl_type
							   ) IS
BEGIN
    Okl_Xca_Pvt.validate_row( p_api_version
    						 ,p_init_msg_list
    						 ,x_return_status
    						 ,x_msg_count
    						 ,x_msg_data
    						 ,p_xcav_tbl
							);
END validate_ext_csh_txns;

END Okl_Extrn_Pvt;

/
