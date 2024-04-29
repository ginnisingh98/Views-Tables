--------------------------------------------------------
--  DDL for Package Body OKL_XCR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XCR_PUB" AS
/* $Header: OKLPXCRB.pls 115.9 2002/12/18 12:44:31 kjinger noship $ */

PROCEDURE ADD_LANGUAGE IS
BEGIN
	 Okl_Extrn_Pvt.ADD_LANGUAGE;
END ADD_LANGUAGE;

 --Object type procedure for insert
PROCEDURE create_ext_ar_txns(
     p_api_version                  IN NUMBER
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

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_xcrv_rec  			 xcrv_rec_type;
   lx_xcrv_rec				 xcrv_rec_type;

   lp_xcav_tbl  			 xcav_tbl_type;
   lx_xcav_tbl				 xcav_tbl_type;
BEGIN

   SAVEPOINT save_Insert_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_xcrv_rec     := p_xcrv_rec;
   lp_xcav_tbl     := p_xcav_tbl;

   -- customer pre-processing


   -- vertical industry-preprocessing



	Okl_Extrn_Pvt.CREATE_EXT_CSH_TXNS (
     p_api_version
    ,p_init_msg_list
    ,x_return_status
    ,x_msg_count
    ,x_msg_data
    ,p_xcrv_rec
    ,p_xcav_tbl
    ,x_xcrv_rec
    ,x_xcav_tbl
	);


    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_xcrv_rec  := lx_xcrv_rec;
x_xcav_tbl  := lx_xcav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_Insert_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_XCB_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END create_ext_ar_txns;

--Object type procedure for update
PROCEDURE update_ext_ar_txns(
    p_api_version                  IN NUMBER
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

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_xcrv_rec  			 xcrv_rec_type;
   lx_xcrv_rec				 xcrv_rec_type;

   lp_xcav_tbl  			 xcav_tbl_type;
   lx_xcav_tbl				 xcav_tbl_type;

BEGIN

   SAVEPOINT save_update_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_xcrv_rec     := p_xcrv_rec;
   lp_xcav_tbl     := p_xcav_tbl;

   -- customer pre-processing


   -- vertical industry-preprocessing


	Okl_Extrn_Pvt.UPDATE_EXT_CSH_TXNS(
    	p_api_version
       ,p_init_msg_list
   	   ,x_return_status
   	   ,x_msg_count
   	   ,x_msg_data
   	   ,p_xcrv_rec
   	   ,p_xcav_tbl
   	   ,x_xcrv_rec
   	   ,x_xcav_tbl
	);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_xcrv_rec  := lx_xcrv_rec;
x_xcav_tbl  := lx_xcav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_XCB_PUB','update_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END update_ext_ar_txns;

PROCEDURE update_ext_csh_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,x_xcrv_rec                     OUT NOCOPY xcrv_rec_type
    ) IS

   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_xcrv_rec  			 xcrv_rec_type;
   lx_xcrv_rec				 xcrv_rec_type;

BEGIN

   SAVEPOINT save_update_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_xcrv_rec     := p_xcrv_rec;

   -- customer pre-processing


   -- vertical industry-preprocessing


    Okl_Extrn_Pvt.update_ext_csh_txns(
        p_api_version
       ,p_init_msg_list
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
       ,p_xcrv_rec
       ,x_xcrv_rec
     );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_xcrv_rec  := lx_xcrv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_XCB_PUB','update_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END update_ext_csh_txns;

--Object type procedure for update
PROCEDURE delete_ext_ar_txns(
    p_api_version                  IN NUMBER
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

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_xcrv_rec  			 xcrv_rec_type;
   lx_xcrv_rec				 xcrv_rec_type;

   lp_xcav_tbl  			 xcav_tbl_type;
   lx_xcav_tbl				 xcav_tbl_type;

BEGIN

   SAVEPOINT save_update_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_xcrv_rec     := p_xcrv_rec;
   lp_xcav_tbl     := p_xcav_tbl;

   -- customer pre-processing


   -- vertical industry-preprocessing


	Okl_Extrn_Pvt.DELETE_EXT_CSH_TXNS(
    	p_api_version
       ,p_init_msg_list
   	   ,x_return_status
   	   ,x_msg_count
   	   ,x_msg_data
   	   ,p_xcrv_rec
   	   ,p_xcav_tbl
   	   ,x_xcrv_rec
   	   ,x_xcav_tbl
	);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_xcrv_rec  := lx_xcrv_rec;
x_xcav_tbl  := lx_xcav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_update_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_XCR_PUB','delete_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END delete_ext_ar_txns;

--Object type procedure for validate
PROCEDURE validate_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
   ,p_xcav_tbl                     IN xcav_tbl_type
    ) IS

   l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   lp_xcrv_rec  			 xcrv_rec_type;
   lx_xcrv_rec				 xcrv_rec_type;

   lp_xcav_tbl  			 xcav_tbl_type;
   lx_xcav_tbl				 xcav_tbl_type;

BEGIN
   SAVEPOINT save_validate_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_xcrv_rec     := p_xcrv_rec;
   lp_xcav_tbl     := p_xcav_tbl;

   -- customer pre-processing


   -- vertical industry-preprocessing



	 Okl_Extrn_Pvt.VALIDATE_EXT_CSH_TXNS(
         p_api_version
        ,p_init_msg_list
   		,x_return_status
   		,x_msg_count
   		,x_msg_data
   		,p_xcrv_rec
   		,p_xcav_tbl
	 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_validate_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_validate_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_validate_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_XCB_PUB','validate_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END validate_ext_ar_txns;

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_rec                     IN xcrv_rec_type
    ) IS
BEGIN
	 Okl_Extrn_Pvt.LOCK_EXT_CSH_TXNS(
                 p_api_version
                ,p_init_msg_list
   		,x_return_status
   		,x_msg_count
   		,x_msg_data
   		,p_xcrv_rec
	 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
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
END lock_ext_ar_txns;

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcrv_tbl                     IN xcrv_tbl_type
    ) IS
BEGIN
	 Okl_Extrn_Pvt.LOCK_EXT_CSH_TXNS(
                 p_api_version
                ,p_init_msg_list
   		,x_return_status
   		,x_msg_count
   		,x_msg_data
   		,p_xcrv_tbl
	 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
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
END lock_ext_ar_txns;

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcav_rec                     IN xcav_rec_type
    ) IS
BEGIN
	 Okl_Extrn_Pvt.LOCK_EXT_CSH_TXNS(
                 p_api_version
                ,p_init_msg_list
   		,x_return_status
   		,x_msg_count
   		,x_msg_data
   		,p_xcav_rec
	 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
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
END lock_ext_ar_txns;

--Object type procedure for lock
PROCEDURE lock_ext_ar_txns(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_xcav_tbl                     IN xcav_tbl_type
    ) IS
BEGIN
	 Okl_Extrn_Pvt.LOCK_EXT_CSH_TXNS(
                 p_api_version
                ,p_init_msg_list
   		,x_return_status
   		,x_msg_count
   		,x_msg_data
   		,p_xcav_tbl
	 );

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
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
END lock_ext_ar_txns;

END Okl_Xcr_Pub;

/
