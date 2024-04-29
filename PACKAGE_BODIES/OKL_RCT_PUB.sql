--------------------------------------------------------
--  DDL for Package Body OKL_RCT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RCT_PUB" AS
/* $Header: OKLPRCTB.pls 120.2 2007/11/20 03:15:52 akrangan ship $ */

--PROCEDURE ADD_LANGUAGE IS
--BEGIN
-- 	Okl_Intrn_Pvt.add_language;
--END ;


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

   l_api_version			 NUMBER;
   l_init_msg_list			 VARCHAR2(1);

   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);


   lp_rctv_rec  			 rctv_rec_type;
   lx_rctv_rec				 rctv_rec_type;

   lp_rcav_tbl  			 rcav_tbl_type;
   lx_rcav_tbl				 rcav_tbl_type;

BEGIN

   SAVEPOINT save_Insert_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_rctv_rec     := p_rctv_rec;
   lp_rcav_tbl     := p_rcav_tbl;

   -- customer pre-processing


   -- vertical industry-preprocessing


 	Okl_Incsh_Pvt.create_internal_trans(
	    p_api_version
	   ,p_init_msg_list
   	   ,x_return_status
   	   ,x_msg_count
   	   ,x_msg_data
   	   ,lp_rctv_rec
       ,lp_rcav_tbl
       ,x_rctv_rec
       ,x_rcav_tbl
	);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;


    lp_rctv_rec := x_rctv_rec;
    lp_rcav_tbl := x_rcav_tbl;

   	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_rctv_rec  := lp_rctv_rec;
x_rcav_tbl  := lp_rcav_tbl;
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
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RCT_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

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

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

lp_rctv_rec  rctv_rec_type;
lx_rctv_rec  rctv_rec_type;

lp_rcav_tbl  rcav_tbl_type;
lx_rcav_tbl  rcav_tbl_type;
BEGIN
   SAVEPOINT save_update_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_rctv_rec     := p_rctv_rec;
   lp_rcav_tbl     := p_rcav_tbl;

   -- customer pre-processing

   -- vertical industry-preprocessing




 	Okl_Incsh_Pvt.update_internal_trans(
       p_api_version
      ,p_init_msg_list
      ,l_return_status
   	  ,x_msg_count
   	  ,x_msg_data
   	  ,lp_rctv_rec
   	  ,lp_rcav_tbl
   	  ,lx_rctv_rec
   	  ,lx_rcav_tbl
   	);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		RAISE G_EXCEPTION_HALT_VALIDATION;
        	END IF;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


--Assign value to OUT variables
x_rctv_rec  := lx_rctv_rec;
x_rcav_tbl  := lx_rcav_tbl;
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
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RCT_PUB','update_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

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

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

lp_rctv_rec  rctv_rec_type;
lx_rctv_rec  rctv_rec_type;

lp_rcav_tbl  rcav_tbl_type;
lx_rcav_tbl  rcav_tbl_type;
BEGIN

   SAVEPOINT save_validate_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_rctv_rec     := p_rctv_rec;
   lp_rcav_tbl     := p_rcav_tbl;

   -- customer pre-processing

   -- vertical industry-preprocessing

   -- Call business API
 	Okl_Incsh_Pvt.VALIDATE_INTERNAL_TRANS (
        p_api_version
   		,p_init_msg_list
		,x_return_status
        ,x_msg_count
   		,x_msg_data
   		,p_rctv_rec
   		,p_rcav_tbl
	);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
       		l_return_status := x_return_status;
      	END IF;
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
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RCT_PUB','validate_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END ;

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_rec                     IN rctv_rec_type
    ) IS
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN

 	Okl_Incsh_Pvt.LOCK_INTERNAL_TRANS (
                 p_api_version
   		,p_init_msg_list
		,x_return_status
                ,x_msg_count
   		,x_msg_data
   		,p_rctv_rec
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
END lock_internal_trans;

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rctv_tbl                     IN rctv_tbl_type
    ) IS
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN

 	Okl_Incsh_Pvt.LOCK_INTERNAL_TRANS (
                 p_api_version
   		,p_init_msg_list
		,x_return_status
                ,x_msg_count
   		,x_msg_data
   		,p_rctv_tbl
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
END lock_internal_trans;

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rcav_rec                     IN rcav_rec_type
    ) IS
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN

 	Okl_Incsh_Pvt.LOCK_INTERNAL_TRANS  (
                 p_api_version
   		,p_init_msg_list
		,x_return_status
                ,x_msg_count
   		,x_msg_data
   		,p_rcav_rec
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
END lock_internal_trans;

--Object type procedure for lock
PROCEDURE lock_internal_trans(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rcav_tbl                     IN rcav_tbl_type
    ) IS
    l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
BEGIN

 	Okl_Incsh_Pvt.LOCK_INTERNAL_TRANS  (
                 p_api_version
   		,p_init_msg_list
		,x_return_status
                ,x_msg_count
   		,x_msg_data
   		,p_rcav_tbl
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
END lock_internal_trans;

--Object type procedure for update
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

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

lp_rctv_rec  rctv_rec_type;
lx_rctv_rec  rctv_rec_type;

lp_rcav_tbl  rcav_tbl_type;
lx_rcav_tbl  rcav_tbl_type;
BEGIN
   SAVEPOINT save_delete_row;

   l_api_version   := p_api_version;
   l_init_msg_list := l_init_msg_list;

   lp_rctv_rec     := p_rctv_rec;
   lp_rcav_tbl     := p_rcav_tbl;

   -- customer pre-processing

   -- vertical industry-preprocessing


 	Okl_Incsh_Pvt.delete_internal_trans(
       p_api_version
      ,p_init_msg_list
      ,x_return_status
   	  ,x_msg_count
   	  ,x_msg_data
   	  ,p_rctv_rec
   	  ,p_rcav_tbl
   	  ,x_rctv_rec
   	  ,x_rcav_tbl
   	);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      		RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   	END IF;

	-- customer post-processing


    -- vertical industry-post-processing


/*
--Assign value to OUT variables
x_rctv_rec  := lx_rctv_rec;
x_rcav_tbl  := lx_rcav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
*/

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO save_delete_row;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO save_delete_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO save_delete_row;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RCT_PUB','delete_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END ;

END Okl_Rct_Pub;

/
