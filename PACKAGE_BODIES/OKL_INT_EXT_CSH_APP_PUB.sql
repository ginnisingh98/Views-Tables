--------------------------------------------------------
--  DDL for Package Body OKL_INT_EXT_CSH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INT_EXT_CSH_APP_PUB" AS
/* $Header: OKLPIECB.pls 115.6 2002/12/18 12:20:41 kjinger noship $ */

--Object type procedure for insert
PROCEDURE int_ext_csh_app_pub ( p_api_version	 IN	 NUMBER
  				               ,p_init_msg_list  IN	 VARCHAR2 DEFAULT Okc_Api.G_FALSE
                               ,x_return_status  OUT NOCOPY VARCHAR2
                               ,x_msg_count	     OUT NOCOPY NUMBER
                               ,x_msg_data	     OUT NOCOPY VARCHAR2
                                ) IS

   l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_api_version			 NUMBER := 1;
   l_init_msg_list			 VARCHAR2(1);
   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

BEGIN

   SAVEPOINT save_Insert_row;

   l_api_version      := p_api_version;
   l_init_msg_list    := p_init_msg_list;

   -- customer pre-processing



   OKL_INT_EXT_CSH_APP_PVT.int_ext_csh_app ( p_api_version
                                            ,p_init_msg_list
                                            ,x_return_status
			                                ,x_msg_count
                                            ,x_msg_data
                                            );


   IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      		IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
         		l_return_status := x_return_status;
        	END IF;
   END IF;



--Assign value to OUT variables

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
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_INT_EXT_CSH_APP_PUB','insert_row');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END int_ext_csh_app_pub;


PROCEDURE int_ext_csh_app_conc ( errbuf  	  OUT NOCOPY   VARCHAR2
                                ,retcode 	  OUT NOCOPY   NUMBER )
IS

  l_api_version     NUMBER := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  lx_msg_count     	NUMBER;
  lx_msg_data    	VARCHAR2(450);
  l_init_msg_list   VARCHAR2(1);

  l_msg_index_out   NUMBER :=0;
  l_error_msg_rec 		Okl_Accounting_Util.Error_message_Type;

BEGIN


	OKL_INT_EXT_CSH_APP_PUB.int_ext_csh_app_pub ( p_api_version     => l_api_version
                                                 ,p_init_msg_list   => l_init_msg_list
                                                 ,x_return_status   => l_return_status
			                                     ,x_msg_count       => lx_msg_count
                                                 ,x_msg_data        => lx_msg_data
                                                );

    FND_FILE.PUT_LINE (FND_FILE.LOG, '***************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'OKL Concurrent Payment Process Program');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Program Run Date:'||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Detailed Error Messages For Each Consolidated invoice/Contract processed ...');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');

    BEGIN

        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
            FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');
            END LOOP;
        END IF;
/*
        FOR i in 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                             p_encoded => 'F',
                             p_data => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
        END LOOP;
*/
    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;

EXCEPTION
    WHEN OTHERS THEN
         NULL ;
END int_ext_csh_app_conc;

END OKL_INT_EXT_CSH_APP_PUB;

/
