--------------------------------------------------------
--  DDL for Package Body OKL_RESI_CAT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RESI_CAT_SETS_PVT" as
  /* $Header: OKLRRCSB.pls 120.4 2005/09/14 06:43:12 smadhava noship $ */

 -- Function checks if there are repetitions of items or categories in a residual category set
 FUNCTION check_existence (p_source_code VARCHAR2, p_res_tbl IN okl_res_tbl) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_temp_resi_category_set_id     NUMBER := NULL;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_existence';

  l_count NUMBER := 0;

    BEGIN

     FOR i IN p_res_tbl.FIRST..p_res_tbl.LAST
     LOOP
       l_count := 0;
       IF p_source_code = G_CAT_ITEM THEN
          FOR j IN p_res_tbl.FIRST..p_res_tbl.LAST
	  LOOP
	     IF p_res_tbl(i).inventory_item_id   = p_res_tbl(j).inventory_item_id
	        AND p_res_tbl(i).organization_id = p_res_tbl(j).organization_id
		AND p_res_tbl(i).category_set_id = p_res_tbl(j).category_set_id THEN
		l_count := l_count + 1;
              END IF;
          END LOOP;

	  IF l_count > 1 THEN
	    OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ITEM_REPEAT');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

	ELSIF p_source_code = G_CAT_ITEM_CAT THEN
          FOR j IN p_res_tbl.FIRST..p_res_tbl.LAST
	  LOOP
	     IF p_res_tbl(i).category_id         = p_res_tbl(j).category_id
		AND p_res_tbl(i).category_set_id = p_res_tbl(j).category_set_id THEN
		l_count := l_count + 1;
              END IF;
          END LOOP;

	  IF l_count > 1 THEN
	    OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_ITEM_CAT_REPEAT');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF; -- end of source code check
      END LOOP; -- end of for loop

  	  RETURN (l_return_status);
 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RETURN OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      RETURN OKL_API.G_RET_STS_UNEXP_ERROR;
   END check_existence;

  /*
    Function checks the inventory for the presence of the items/item categories.
    If not present, it changes the status of the residual category set to Inactive
  */
  FUNCTION check_update_status(
                                p_source_code IN VARCHAR2
                              , p_res_upd_tbl IN okl_res_tbl) RETURN VARCHAR2 IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.check_update_status';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_update_status';
    l_make_inactive VARCHAR2(3) := 'no';
    l_temp_cnt NUMBER :=0;
  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call check_update_status');
    END IF;


    IF p_source_code = G_CAT_ITEM THEN
       l_temp_cnt := 0;
       FOR i IN p_res_upd_tbl.FIRST..p_res_upd_tbl.LAST
       LOOP

           SELECT
                 COUNT(1)
           INTO
                l_temp_cnt
           FROM
                MTL_ITEM_CATEGORIES MTL
           WHERE
                MTL.INVENTORY_ITEM_ID = p_res_upd_tbl(i).inventory_item_id
            AND MTL.ORGANIZATION_ID = p_res_upd_tbl(i).organization_id;

           IF l_temp_cnt = 0 THEN
              l_make_inactive := 'yes';
           END IF;

       END LOOP;

    ELSIF p_source_code = G_CAT_ITEM_CAT THEN
       FOR i IN p_res_upd_tbl.FIRST..p_res_upd_tbl.LAST
       LOOP
          l_temp_cnt := 0;
           SELECT
                 COUNT(1)
           INTO
                l_temp_cnt
           FROM
                MTL_ITEM_CATEGORIES MTL
           WHERE
                MTL.CATEGORY_ID = p_res_upd_tbl(i).category_id
            AND MTL.CATEGORY_SET_ID = p_res_upd_tbl(i).category_set_id;

           IF l_temp_cnt = 0 THEN
              l_make_inactive := 'yes';
           END IF;

       END LOOP;

    END IF;



     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call check_update_status');
     END IF;

    RETURN l_make_inactive;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN OKL_API.G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RETURN OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      RETURN OKL_API.G_RET_STS_UNEXP_ERROR;
 END check_update_status;

  procedure create_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                       , x_res_tbl          OUT NOCOPY okl_res_tbl
                        ) IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.create_rcs';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name      CONSTANT VARCHAR2(40)   := 'create_rcs';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    l_rcsv_rec               okl_rcsv_rec   := p_rcsv_rec;
    l_res_tbl                okl_res_tbl    := p_res_tbl;

    i     NUMBER :=0;
  begin
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call create_rcs');
    END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Set the status of the residual category set to ACTIVE
    l_rcsv_rec.sts_code := OKL_RCS_PVT.G_STS_ACTIVE;

    -- Insert row in the header table
    okl_rcs_pvt.insert_row(
	 	      p_api_version   => p_api_version
      	    , p_init_msg_list => p_init_msg_list
     	    , x_return_status => l_return_status
	 	    , x_msg_count     => x_msg_count
	 	    , x_msg_data      => x_msg_data
		    , p_rcsv_rec      => l_rcsv_rec
		    , x_rcsv_rec      => x_rcsv_rec);


    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Assign the foreign key to the child table
    for i IN l_res_tbl.FIRST..l_res_tbl.LAST
    LOOP

      l_res_tbl(i).resi_category_set_id := x_rcsv_rec.resi_category_set_id;
    end loop;


    -- Check for the presence of duplicate items or item categories
    l_return_status :=  check_existence(l_rcsv_rec.source_code, p_res_tbl);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Insert rows in the lines table for the respective header
    okl_res_pvt.insert_row(
	 	      p_api_version   => p_api_version
        	, p_init_msg_list => p_init_msg_list
	     	, x_return_status => l_return_status
	 	    , x_msg_count     => x_msg_count
	 	    , x_msg_data      => x_msg_data
		    , p_res_tbl       => l_res_tbl
		    , x_res_tbl       => x_res_tbl);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;
 x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call create_rcs');
     END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
      	-- No action necessary.
       NULL;

	  WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
  end create_rcs;

 /*
    Procedure to update the residual category set. It inserts new lines if any
    into the OKL_FE_RESI_CAT_OBJECTS table. It inactivates the residual category set if
    any of the existing lines are not present in the inventory.
  */
  PROCEDURE update_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                        ) IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.update_rcs';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name      CONSTANT VARCHAR2(40)   := 'update_rcs';
    l_api_version   NUMBER         := p_api_version;
    l_init_msg_list VARCHAR2(1)    := p_init_msg_list;
    l_return_status VARCHAR2(1)    := x_return_status;
    lp_rcsv_rec     okl_rcsv_rec   := p_rcsv_rec;
    lp_res_tbl      okl_res_tbl    := p_res_tbl;
    lp_res_crt_tbl  okl_res_tbl;
    lx_res_crt_tbl  okl_res_tbl;
    lp_res_upd_tbl  okl_res_tbl;
    lx_res_upd_tbl  okl_res_tbl;

    l_make_inactive VARCHAR2(3) := 'no';
    j NUMBER;
    k NUMBER;
    BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call update_rcs');
    END IF;
    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    j:=1;
    k:=1;
    FOR i IN p_res_tbl.FIRST..p_res_tbl.LAST
     LOOP

      IF p_res_tbl(i).resi_cat_object_id IS NULL OR p_res_tbl(i).resi_cat_object_id = OKL_API.G_MISS_NUM THEN
         lp_res_crt_tbl(j) := p_res_tbl(i);
         lp_res_crt_tbl(j).resi_category_set_id := p_rcsv_rec.resi_category_set_id;
         j := j+1;

       ELSE
         lp_res_upd_tbl(k) := p_res_tbl(i);
         k := k+1;
       END IF;
    END LOOP;


    -- Check for the presence of duplicate items or item categories
    l_return_status :=  check_existence(lp_rcsv_rec.source_code, p_res_tbl);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Update the objects if any
    OKL_RES_PVT.update_row(
                    p_api_version    =>	l_api_version
                  , p_init_msg_list  => l_init_msg_list
                  , x_return_status  => l_return_status
                  , x_msg_count	    =>  x_msg_count
                  , x_msg_data	    =>  x_msg_data
                  , p_res_tbl	    =>  lp_res_upd_tbl
                  , x_res_tbl        => lx_res_upd_tbl);

    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OKL_RES_PVT.insert_row(
                    p_api_version    =>	l_api_version
                  , p_init_msg_list  => l_init_msg_list
                  , x_return_status  => l_return_status
                  , x_msg_count	    =>  x_msg_count
                  , x_msg_data	    =>  x_msg_data
                  , p_res_tbl	    =>  lp_res_crt_tbl
                  , x_res_tbl        => lx_res_crt_tbl);

    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* Call function to check if the residual category set needs to be made Inactive */
    l_make_inactive := check_update_status( p_rcsv_rec.source_code, lp_res_upd_tbl);


   IF l_make_inactive = 'yes' THEN
     lp_rcsv_rec.sts_code :=  G_STS_INACTIVE;
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_RES_CAT_INACTIVATED',
                           p_token1       => 'NAME',
                           p_token1_value => lp_rcsv_rec.resi_cat_name);
   ELSE
    -- Set the status of the residual category set to ACTIVE
    lp_rcsv_rec.sts_code := OKL_RCS_PVT.G_STS_ACTIVE;
   END IF;

   OKL_RCS_PVT.update_row(
                 p_api_version    => l_api_version
               , p_init_msg_list  => l_init_msg_list
               , x_return_status  => l_return_status
               , x_msg_count      => x_msg_count
               , x_msg_data       => x_msg_data
               , p_rcsv_rec       => lp_rcsv_rec
               , x_rcsv_rec       => x_rcsv_rec);

    IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call update_rcs');
     END IF;
	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
      	-- No action necessary.
       NULL;

	  WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
  END update_rcs;

 /*
    Procedure to activate the residual category set. It inactivates the residual
    category set if any of the existing lines are not present in the inventory.
  */

  PROCEDURE activate_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcsv_rec         IN         okl_rcsv_rec
                       , p_res_tbl          IN         okl_res_tbl
                       , x_rcsv_rec         OUT NOCOPY okl_rcsv_rec
                        ) IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.activate_rcs';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name      CONSTANT VARCHAR2(40)   := 'activate_rcs';
    l_api_version   NUMBER         := p_api_version;
    l_init_msg_list VARCHAR2(1)    := p_init_msg_list;
    l_return_status VARCHAR2(1)    := x_return_status;
    lp_rcsv_rec     okl_rcsv_rec   := p_rcsv_rec;

    l_make_inactive VARCHAR2(3) := 'no';
    BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call activate_rcs');
    END IF;

    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,l_return_status);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;



    /* Call function to check if the residual category set needs to be made Inactive */
    l_make_inactive := check_update_status( p_rcsv_rec.source_code, p_res_tbl);


   IF l_make_inactive = 'yes' THEN
     lp_rcsv_rec.sts_code :=  G_STS_INACTIVE;
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_RES_CAT_INACTIVE');
   ELSE
     lp_rcsv_rec.sts_code :=  G_STS_ACTIVE;

     OKL_RCS_PVT.update_row(
                 p_api_version    => l_api_version
               , p_init_msg_list  => l_init_msg_list
               , x_return_status  => l_return_status
               , x_msg_count      => x_msg_count
               , x_msg_data       => x_msg_data
               , p_rcsv_rec       => lp_rcsv_rec
               , x_rcsv_rec       => x_rcsv_rec);
   END IF;



    IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
 x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call update_rcs');
	 END IF;
	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
      	-- No action necessary.
       NULL;

	  WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
  END activate_rcs;

 /*
    Procedure to Inactivate the residual category set.
  */

  PROCEDURE Inactivate_rcs (
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_rcs_id           IN         NUMBER
                       , p_obj_ver_number   IN         NUMBER
                        ) IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.Inactivate_rcs';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name      CONSTANT VARCHAR2(40)   := 'Inactivate_rcs';
    l_api_version   NUMBER         := p_api_version;
    l_init_msg_list VARCHAR2(1)    := p_init_msg_list;
    l_return_status VARCHAR2(1)    := x_return_status;
    lp_rcsv_rec     okl_rcsv_rec;
    x_rcsv_rec     okl_rcsv_rec ;
    BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call Inactivate_rcs');
    END IF;
    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

     lp_rcsv_rec.resi_category_set_id := p_rcs_id;
     lp_rcsv_rec.sts_code :=  G_STS_INACTIVE;
     lp_rcsv_rec.object_version_number := p_obj_ver_number;

     OKL_RCS_PVT.update_row(
                 p_api_version    => l_api_version
               , p_init_msg_list  => l_init_msg_list
               , x_return_status  => l_return_status
               , x_msg_count      => x_msg_count
               , x_msg_data       => x_msg_data
               , p_rcsv_rec       => lp_rcsv_rec
               , x_rcsv_rec       => x_rcsv_rec);


    IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call Inactivate_rcs');
	 END IF;
	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
      	-- No action necessary.
       NULL;

	  WHEN OKL_API.G_EXCEPTION_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
  END Inactivate_rcs;

PROCEDURE delete_objects(
                         p_api_version      IN         NUMBER
                       , p_init_msg_list    IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
                       , x_return_status    OUT NOCOPY VARCHAR2
                       , x_msg_count        OUT NOCOPY NUMBER
                       , x_msg_data         OUT NOCOPY VARCHAR2
                       , p_res_tbl          IN         okl_res_tbl) IS
    l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_RESI_CAT_SETS_PVT.delete_objects';
    l_debug_enabled VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;

    l_api_name      CONSTANT VARCHAR2(40)   := 'delete_objects';
    l_api_version   NUMBER         := p_api_version;
    l_init_msg_list VARCHAR2(1)    := p_init_msg_list;
    l_return_status VARCHAR2(1)    := x_return_status;
    BEGIN


    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRRCSB.pls call delete_objects');
    END IF;
    l_return_status := OKL_API.start_activity(l_api_name
                           ,G_PKG_NAME
                           ,p_init_msg_list
                           ,l_api_version
                           ,p_api_version
                           ,'_PVT'
                           ,x_return_status);
    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_RES_PVT.delete_row(
	                    p_api_version	=> l_api_version
              	      , p_init_msg_list	=> l_init_msg_list
                      , x_return_status	=> l_return_status
            	      , x_msg_count		=> x_msg_count
            	      , x_msg_data		=> x_msg_data
              	      , p_res_tbl       => p_res_tbl);

    if l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif l_return_status = OKL_API.G_RET_STS_ERROR then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

     IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRRCSB.pls call delete_objects');
	 END IF;
	EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OTHERS THEN

		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);
END delete_objects;

END OKL_RESI_CAT_SETS_PVT;

/
