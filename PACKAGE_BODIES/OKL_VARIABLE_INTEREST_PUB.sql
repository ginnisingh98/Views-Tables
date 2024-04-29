--------------------------------------------------------
--  DDL for Package Body OKL_VARIABLE_INTEREST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VARIABLE_INTEREST_PUB" AS
    /* $Header: OKLPVARB.pls 120.5.12010000.2 2008/08/11 05:07:14 rpillay ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.RATE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
/* 4682018
       PROCEDURE initiate_request
        (p_api_version        IN  NUMBER,
         p_init_msg_list      IN  VARCHAR2,
         p_contract_number             IN  VARCHAR2,
		 p_from_date          IN  DATE,
		 p_to_date            IN  DATE,
		 x_return_status      OUT NOCOPY VARCHAR2,
		 x_msg_count          OUT NOCOPY NUMBER,
		 x_msg_data           OUT NOCOPY VARCHAR2,
		 x_request_id         OUT NOCOPY NUMBER,
		 x_trans_status       OUT NOCOPY VARCHAR2)
         is

    	l_api_version NUMBER := 1;
    	l_init_msg_list VARCHAR2(1) ;
    	l_return_status VARCHAR2(1);
    	l_msg_count NUMBER ;
    	l_msg_data VARCHAR2(2000);
        l_request_id NUMBER;
        l_trans_status VARCHAR2(3);


  BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;




       OKL_VARIABLE_INTEREST_PVT.initiate_request
        (p_api_version	    => l_api_version
    	,p_init_msg_list	=> l_init_msg_list
        ,p_contract_number           => p_contract_number
        ,p_from_date        => p_from_date
        ,p_to_date          => p_to_date
    	,x_return_status	=> l_return_status
    	,x_msg_count	    => l_msg_count
    	,x_msg_data	    	=> l_msg_data
		,x_request_id       => l_request_id
		,x_trans_status     => l_trans_status);



    IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
    	RAISE Fnd_Api.G_EXC_ERROR;
    ELSIF (X_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;



    EXCEPTION

        WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN OTHERS THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.ADD_EXC_MSG('OKL_VARIABLE_INTEREST_PUB','VARIABLE_INTEREST');
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

    END ;
*/
       PROCEDURE var_int_rent_level(
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_chr_id        IN NUMBER,
        p_trx_id        IN NUMBER,
        p_trx_status    IN VARCHAR2,
        p_rent_tbl      IN csm_periodic_expenses_tbl_type) is

    	l_api_version NUMBER := 1;
    	l_init_msg_list VARCHAR2(1) ;
    	l_return_status VARCHAR2(1);
    	l_msg_count NUMBER ;
    	l_msg_data VARCHAR2(2000);

       	p_from_date date := sysdate;
       	p_to_date date := sysdate;
       	l_csm_loan_level_tbl csm_loan_level_tbl_type ;
        l_child_trx_id NUMBER;

  BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;




-- Start of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PVT.var_int_rent_level
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPVARB.pls call OKL_VARIABLE_INTEREST_PVT.var_int_rent_level ');
    END;
  END IF;
       OKL_VARIABLE_INTEREST_PVT.var_int_rent_level(
        p_api_version	      => p_api_version
    	,p_init_msg_list	  => p_init_msg_list
    	,x_return_status	  => x_return_status
    	,x_msg_count	      => x_msg_count
    	,x_msg_data		      => x_msg_data
      ,p_chr_id             => p_chr_id
      ,p_trx_id             => p_trx_id
      ,p_trx_status         => p_trx_status
      ,p_rent_tbl           => p_rent_tbl
		  ,p_csm_loan_level_tbl => l_csm_loan_level_tbl
      ,x_child_trx_id => l_child_trx_id);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPVARB.pls call OKL_VARIABLE_INTEREST_PVT.var_int_rent_level ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PVT.var_int_rent_level


    IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
    	RAISE Fnd_Api.G_EXC_ERROR;
    ELSIF (X_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;



    EXCEPTION

        WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN OTHERS THEN
          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.ADD_EXC_MSG('OKL_VARIABLE_INTEREST_PUB','VARIABLE_INTEREST');
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

    END ;





    PROCEDURE VARIABLE_INTEREST(p_api_version		IN  NUMBER
    	,p_init_msg_list	IN  VARCHAR2
    	,x_return_status	OUT NOCOPY VARCHAR2
    	,x_msg_count		OUT NOCOPY NUMBER
    	,x_msg_data		    OUT NOCOPY VARCHAR2
        ,p_contract_number  IN  VARCHAR2
    	,p_to_date		    IN  DATE)

    IS
    	l_api_version NUMBER := 1;
    	l_init_msg_list VARCHAR2(1) ;
    	l_return_status VARCHAR2(1);
    	l_msg_count NUMBER ;
    	l_msg_data VARCHAR2(2000);

    BEGIN
    -- 4739869 commenting out the code to issue SAVEPOINT
--    SAVEPOINT VARIABLE_INTEREST;

-- Start of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PVT.VARIABLE_INTEREST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPVARB.pls call OKL_VARIABLE_INTEREST_PVT.VARIABLE_INTEREST ');
    END;
  END IF;
    	OKL_VARIABLE_INTEREST_PVT.VARIABLE_INTEREST(
        p_api_version	    => p_api_version
    	,p_init_msg_list	=> p_init_msg_list
    	,x_return_status	=> x_return_status
    	,x_msg_count	    => x_msg_count
    	,x_msg_data		    => x_msg_data
        ,p_contract_number  => p_contract_number
    	,P_to_date		    => p_to_date);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPVARB.pls call OKL_VARIABLE_INTEREST_PVT.VARIABLE_INTEREST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_VARIABLE_INTEREST_PVT.VARIABLE_INTEREST

    IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
    	RAISE Fnd_Api.G_EXC_ERROR;
    ELSIF (X_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;



    EXCEPTION

        WHEN Fnd_Api.G_EXC_ERROR THEN
          -- 4739869 commenting out the code to Rollback the transactions
--          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          -- 4739869 commenting out the code to Rollback the transactions
--          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

        WHEN OTHERS THEN
          -- 4739869 commenting out the code to Rollback the transactions
--          ROLLBACK TO VARIABLE_INTEREST;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          Fnd_Msg_Pub.ADD_EXC_MSG('OKL_VARIABLE_INTEREST_PUB','VARIABLE_INTEREST');
          Fnd_Msg_Pub.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);

    END ;

    PROCEDURE VARIABLE_INTEREST
        (errbuf	 OUT NOCOPY  VARCHAR2
    	,retcode OUT NOCOPY  NUMBER
        ,p_contract_number  IN  VARCHAR2
    	,p_to_date	 IN  VARCHAR2) is

        l_api_vesrions   NUMBER := 1;
        lx_msg_count     NUMBER;
        l_count         NUMBER :=0;
        l_count1          NUMBER :=0;
        l_count2          NUMBER :=0;
        lx_msg_data       VARCHAR2(450);
        i                 NUMBER;
        l_msg_index_out   NUMBER;
        lx_return_status  VARCHAR(1);
        l_from_date         DATE;
        l_to_date           DATE;

       BEGIN

        --Bug# 7277007
        OKL_DEBUG_PUB.G_SESSION_ID := Sys_Context('USERENV', 'SESSIONID');
        IF p_to_date IS NOT NULL THEN
        l_to_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_date);
        END IF;

        VARIABLE_INTEREST(p_api_version    => l_api_vesrions,
    	p_init_msg_list    => FND_API.G_FALSE,
    	x_return_status    => lx_return_status,
    	x_msg_count        => lx_msg_count,
    	x_msg_data         => errbuf,
        p_contract_number  => p_contract_number,
    	p_to_date	        => l_to_date);

            IF lx_msg_count >= 1 THEN
            FOR i in 1..lx_msg_count LOOP
                fnd_msg_pub.get (p_msg_index => i,
                           p_encoded => 'F',
                           p_data => lx_msg_data,
                           p_msg_index_out => l_msg_index_out);

          FND_FILE.PUT_LINE (FND_FILE.LOG,to_char(i) || ': ' || lx_msg_data);
          END LOOP;
          END IF;
          EXCEPTION
          WHEN OTHERS THEN

         FND_FILE.PUT_LINE (FND_FILE.LOG,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

       END;


END;

/
