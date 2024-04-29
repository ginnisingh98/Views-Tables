--------------------------------------------------------
--  DDL for Package Body OKL_INTERNAL_TO_EXTERNAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTERNAL_TO_EXTERNAL_PUB" AS
/* $Header: OKLPIEXB.pls 120.7 2006/05/19 21:20:31 fmiao noship $ */

  PROCEDURE internal_to_external (
           p_api_version                  IN NUMBER,
    	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2,
           p_contract_number  	          IN VARCHAR2,
  	   p_assigned_process 	          IN VARCHAR2)
  IS

  l_api_version NUMBER ;
  l_init_msg_list VARCHAR2(1) ;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER ;
  l_msg_data VARCHAR2(2000);

  BEGIN

  SAVEPOINT cons_bill_pub;

   	  Okl_Internal_To_External.INTERNAL_TO_EXTERNAL(
           p_api_version     => p_api_version,
    	   p_init_msg_list   => p_init_msg_list,
    	   x_return_status   => x_return_status,
    	   x_msg_count       => x_msg_count,
    	   x_msg_data        => x_msg_data,
           p_commit          => FND_API.G_TRUE,
	   --fmiao 5209209
	   p_contract_number => p_contract_number,
  	   p_assigned_process =>p_assigned_process
	   --fmiao 5209209 end
        );

  IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO cnsld_ar_hdrs_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO cnsld_ar_hdrs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO cnsld_ar_hdrs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_INTERNAL_TO_EXTERNAL_PUB','internal_to_external');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END internal_to_external;

  PROCEDURE internal_to_external
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
  --fmiao 5209209
  , p_contract_number  			   IN VARCHAR2
  , p_assigned_process 			   IN VARCHAR2
  --fmiao 5209209 end
  )  IS

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_count1          NUMBER;
  l_count2          NUMBER;
  l_count           NUMBER;
  lx_msg_data       VARCHAR2(450);
  i                 NUMBER;
  l_msg_index_out   NUMBER;
  lx_return_status  VARCHAR(1);

    l_request_id      NUMBER;

    CURSOR req_id_csr IS
	  SELECT
          DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	  FROM dual;


    CURSOR xsi_cnt_succ_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
          SELECT count(*)
          FROM okl_ext_sell_invs_v
          WHERE trx_status_code = p_sts AND
                request_id = p_req_id ;

    CURSOR xsi_cnt_err_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
          SELECT count(*)
          FROM okl_ext_sell_invs_v
          WHERE trx_status_code = p_sts AND
                request_id = p_req_id ;

    l_succ_cnt    NUMBER;
    l_err_cnt     NUMBER;

    -- ------------------------------------------------
    -- Bind variables to address issues in bug 3761940
    -- ------------------------------------------------
    submitted_sts  okl_ext_sell_invs_v.trx_status_code%TYPE;
    error_sts      okl_ext_sell_invs_v.trx_status_code%TYPE;

    BEGIN

           internal_to_external(p_api_version => l_api_vesrions,
                                p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf,
				--fmiao 5209209
  				p_contract_number  => p_contract_number,
  				p_assigned_process => p_assigned_process
                                --fmiao 5209209 end
                                );
           IF lx_return_status= 'W' THEN
              retcode := 1;
           END IF;

  EXCEPTION
      WHEN OTHERS THEN
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;
  END internal_to_external;


END Okl_Internal_To_External_Pub;

/
