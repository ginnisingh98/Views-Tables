--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CAP_PURPOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CAP_PURPOSE_PUB" AS
 /* $Header: OKLPCPUB.pls 120.3 2005/10/30 04:01:30 appldev noship $ */
---------------------------------------------------------------------------
-- PROCEDURE create_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_purpose
  -- Description     : procedure for inserting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE create_purpose ( p_api_version	    IN  NUMBER
                          ,p_init_msg_list   IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count	      OUT NOCOPY NUMBER
                          ,x_msg_data	       OUT NOCOPY VARCHAR2
                          ,p_strm_tbl        IN  okl_cash_dtls_tbl_type
                          ,x_strm_tbl        OUT NOCOPY okl_cash_dtls_tbl_type
                         ) IS

--Initialize return status.
   l_return_status     VARCHAR2(1) DEFAULT Okl_Api.G_RET_STS_SUCCESS;
   l_init_msg_list	    VARCHAR2(1);
   l_msg_count	        NUMBER;
   l_msg_data		        VARCHAR(2000);
   lp_strm_tbl         okl_cash_dtls_tbl_type;

BEGIN

   SAVEPOINT save_create_purpose;
   l_init_msg_list := l_init_msg_list;
   lp_strm_tbl     := p_strm_tbl;


   -- The procedure creates the receipt purpose and inserts a row in the
   -- internal receipt line trasaction table.

   Okl_Bpd_Cap_Purpose_Pvt.create_purpose(  p_api_version
                                           ,p_init_msg_list
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data
                                           ,p_strm_tbl
                                           ,x_strm_tbl
                                          );


    IF  x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
	 RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   	END IF;


    lp_strm_tbl := x_strm_tbl;


   --Assign value to OUT variables

    x_strm_tbl      := lp_strm_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

   EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN
        ROLLBACK TO save_create_purpose;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);
     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO save_create_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK TO save_create_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pub','insert_row');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END create_purpose ;

---------------------------------------------------------------------------
-- PROCEDURE update_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_purpose
  -- Description     : procedure for updating the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_purpose ( p_api_version	    IN  NUMBER
                          ,p_init_msg_list   IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count	      OUT NOCOPY NUMBER
                          ,x_msg_data	       OUT NOCOPY VARCHAR2
                          ,p_strm_tbl        IN  okl_cash_dtls_tbl_type
                          ,x_strm_tbl        OUT NOCOPY okl_cash_dtls_tbl_type
                         ) IS

--Initialize return status.
   l_return_status     VARCHAR2(1) DEFAULT Okl_Api.G_RET_STS_SUCCESS;
   l_init_msg_list	    VARCHAR2(1);
   l_msg_count	        NUMBER;
   l_msg_data		        VARCHAR(2000);
   lp_strm_tbl         okl_cash_dtls_tbl_type;

BEGIN

   SAVEPOINT save_update_purpose;
   l_init_msg_list := l_init_msg_list;
   lp_strm_tbl     := p_strm_tbl;


   -- The procedure creates the receipt purpose and inserts a row in the
   -- internal receipt line trasaction table.

   Okl_Bpd_Cap_Purpose_Pvt.update_purpose(  p_api_version
                                           ,p_init_msg_list
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data
                                           ,p_strm_tbl
                                           ,x_strm_tbl
                                          );


    IF  x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
	 RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   	END IF;


    lp_strm_tbl := x_strm_tbl;


   --Assign value to OUT variables

    x_strm_tbl      := lp_strm_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

   EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN
        ROLLBACK TO save_update_purpose;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);
     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO save_update_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK TO save_update_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pub','insert_row');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END update_purpose ;

---------------------------------------------------------------------------
-- PROCEDURE delete_purpose
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_purpose
  -- Description     : procedure for deleting the records in
  --                   table OKL_TXL_RCPT_APPS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_strm_tbl, x_strm_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE delete_purpose ( p_api_version	    IN  NUMBER
                          ,p_init_msg_list   IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count	      OUT NOCOPY NUMBER
                          ,x_msg_data	       OUT NOCOPY VARCHAR2
                          ,p_strm_tbl        IN  okl_cash_dtls_tbl_type
                          ,x_strm_tbl        OUT NOCOPY okl_cash_dtls_tbl_type
                         ) IS

--Initialize return status.
   l_return_status     VARCHAR2(1) DEFAULT Okl_Api.G_RET_STS_SUCCESS;
   l_init_msg_list	    VARCHAR2(1);
   l_msg_count	        NUMBER;
   l_msg_data		        VARCHAR(2000);
   lp_strm_tbl         okl_cash_dtls_tbl_type;

BEGIN

   SAVEPOINT save_delete_purpose;
   l_init_msg_list := l_init_msg_list;
   lp_strm_tbl     := p_strm_tbl;


   -- The procedure creates the receipt purpose and inserts a row in the
   -- internal receipt line trasaction table.

   Okl_Bpd_Cap_Purpose_Pvt.delete_purpose(  p_api_version
                                           ,p_init_msg_list
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data
                                           ,p_strm_tbl
                                           ,x_strm_tbl
                                          );


    IF  x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
	 RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   	END IF;


    lp_strm_tbl := x_strm_tbl;


   --Assign value to OUT variables

    x_strm_tbl      := lp_strm_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

   EXCEPTION

      WHEN Fnd_Api.G_EXC_ERROR THEN
        ROLLBACK TO save_delete_purpose;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                  ,p_data    => x_msg_data);
     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO save_delete_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
     WHEN OTHERS THEN
       ROLLBACK TO save_delete_purpose;
       x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := l_msg_count ;
       x_msg_data := l_msg_data ;
       Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Bpd_Cap_Purpose_Pub','insert_row');
       Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END delete_purpose ;

END Okl_Bpd_Cap_Purpose_Pub;

/
