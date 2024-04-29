--------------------------------------------------------
--  DDL for Package Body OKL_UBB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UBB_PUB" AS
/* $Header: OKLPUBBB.pls 115.12 2004/04/13 11:26:13 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



  PROCEDURE calculate_ubb_amount(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS

    l_api_name VARCHAR2(50) := 'calculate_ubb_amount';
    l_init_msg_list VARCHAR2(200);
    l_msg_data VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;


  BEGIN







-- Start of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.calculate_ubb_amount
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPUBBB.pls call OKL_UBB_PVT.calculate_ubb_amount ');
    END;
  END IF;
        OKL_UBB_PVT.calculate_ubb_amount(
                                                p_api_version
                                               ,p_init_msg_list
                                               ,x_return_status
                                               ,x_msg_count
                                               ,x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPUBBB.pls call OKL_UBB_PVT.calculate_ubb_amount ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.calculate_ubb_amount





  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END calculate_ubb_amount;

  PROCEDURE calculate_ubb_amount(   ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                         RETCODE                 OUT NOCOPY    VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_mesg                VARCHAR2(4000);
   l_mesg_len            NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'calculate_ubb_amount';


   BEGIN

-- Start of wraper code generated automatically by Debug code generator for OKL_UBB_PUB.calculate_ubb_amount
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPUBBB.pls call OKL_UBB_PUB.calculate_ubb_amount ');
    END;
  END IF;
                         OKL_UBB_PUB.calculate_ubb_amount(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPUBBB.pls call OKL_UBB_PUB.calculate_ubb_amount ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_UBB_PUB.calculate_ubb_amount


                        l_msg_count := fnd_msg_pub.count_msg;
                        IF l_msg_count > 0 THEN

                            l_mesg := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE), 1, 512);

                            FOR i IN 1..(l_msg_count - 1) LOOP
                                l_mesg := l_mesg ||
                                substr(fnd_msg_pub.get(fnd_msg_pub.G_NEXT,fnd_api.G_FALSE), 1, 512);
                            END LOOP;

                            fnd_msg_pub.delete_msg();

                            l_mesg_len := length(l_mesg);
                            fnd_file.put_line(fnd_file.log, 'Error: ');
                            fnd_file.put_line(fnd_file.output, 'Error: ');

                            FOR i IN 1..ceil(l_mesg_len/255) LOOP
                                fnd_file.put_line(fnd_file.log, l_mesg);
                                fnd_file.put_line(fnd_file.output, l_mesg);
                            END LOOP;

                            fnd_file.new_line(fnd_file.log,2);
                            fnd_file.new_line(fnd_file.output,2);
                        END IF;

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                            fnd_file.put_line(fnd_file.log,'msg data '||l_msg_data);
                            fnd_file.put_line(fnd_file.log,'return status '||l_return_status);
                        END IF;


fnd_file.put_line(fnd_file.log,'msg data '||l_msg_data);
fnd_file.put_line(fnd_file.log,'return status '||l_return_status);
fnd_file.put_line(fnd_file.output,'msg data '||l_msg_data);
fnd_file.put_line(fnd_file.output,'return status '||l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      l_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        '_PVT'
      );

   END;

  PROCEDURE bill_service_contract(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_contract_number              IN  VARCHAR2
     ) IS

    l_api_name VARCHAR2(50) := 'bill_service_contract';
    l_init_msg_list VARCHAR2(200);
    l_msg_data VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;


  BEGIN







-- Start of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.bill_service_contract
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPUBBB.pls call OKL_UBB_PVT.bill_service_contract ');
    END;
  END IF;
        OKL_UBB_PVT.bill_service_contract(      p_api_version
                                               ,p_init_msg_list
                                               ,x_return_status
                                               ,x_msg_count
                                               ,x_msg_data
                                               ,p_contract_number);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPUBBB.pls call OKL_UBB_PVT.bill_service_contract ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.bill_service_contract





  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END bill_service_contract;

    PROCEDURE bill_service_contract
        (errbuf	 OUT NOCOPY  VARCHAR2
    	,retcode OUT NOCOPY  NUMBER
        ,p_contract_number  IN  VARCHAR2
        ) is

        l_api_version   NUMBER := 1;
        lx_msg_count     NUMBER;
        lx_msg_data       VARCHAR2(450);
        i                 NUMBER;
        l_msg_index_out   NUMBER;
        lx_return_status  VARCHAR(1);

       BEGIN


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Service Contract Billing');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||sysdate);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

        bill_service_contract(
        p_api_version      => l_api_version,
    	p_init_msg_list    => FND_API.G_FALSE,
    	x_return_status    => lx_return_status,
    	x_msg_count        => lx_msg_count,
    	x_msg_data         => errbuf,
        p_contract_number  => p_contract_number
        );

            IF lx_msg_count >= 1 THEN
            FOR i in 1..lx_msg_count LOOP
                fnd_msg_pub.get (p_msg_index => i,
                           p_encoded => 'F',
                           p_data => lx_msg_data,
                           p_msg_index_out => l_msg_index_out);

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
          END LOOP;
          END IF;
          EXCEPTION
          WHEN OTHERS THEN

         FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

       END;

     PROCEDURE billing_status(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_bill_stat_tbl                OUT NOCOPY bill_stat_tbl_type
    ,p_khr_id                       IN  NUMBER
    ,p_transaction_date             IN  DATE
    ) IS

    l_api_name VARCHAR2(50) := 'billing_status';
    l_init_msg_list VARCHAR2(200);
    l_msg_data VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;


  BEGIN


-- Start of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.calculate_ubb_amount
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPUBBB.pls call OKL_UBB_PVT.calculate_ubb_amount ');
    END;
  END IF;
        OKL_UBB_PVT.billing_status(     p_api_version
                                        ,p_init_msg_list
                                        ,x_return_status
                                        ,x_msg_count
                                        ,x_msg_data
                                        ,x_bill_stat_tbl
                                        ,p_khr_id
                                        ,p_transaction_date);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPUBBB.pls call OKL_UBB_PVT.billing_status ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_UBB_PVT.calculate_ubb_amount


  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END billing_status;


END OKL_UBB_PUB;



/
