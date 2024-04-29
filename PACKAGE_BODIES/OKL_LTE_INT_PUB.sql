--------------------------------------------------------
--  DDL for Package Body OKL_LTE_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LTE_INT_PUB" AS
/* $Header: OKLPLINB.pls 115.15 2004/04/13 10:51:49 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.INTEREST';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



  PROCEDURE calculate_late_interest(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS

    l_api_name VARCHAR2(50) := 'calculate_late_interest';
    l_init_msg_list VARCHAR2(200);
    l_msg_data VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;


  BEGIN







-- Start of wraper code generated automatically by Debug code generator for OKL_lte_int_PVT.calculate_late_interest
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPLINB.pls call OKL_lte_int_PVT.calculate_late_interest ');
    END;
  END IF;
        OKL_lte_int_PVT.calculate_late_interest(
                                                p_api_version
                                               ,p_init_msg_list
                                               ,x_return_status
                                               ,x_msg_count
                                               ,x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPLINB.pls call OKL_lte_int_PVT.calculate_late_interest ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_lte_int_PVT.calculate_late_interest





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
  END calculate_late_interest;

  PROCEDURE calculate_late_interest(   ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                         RETCODE                 OUT NOCOPY    VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_mesg                VARCHAR2(4000);
   l_mesg_len            NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'calculate_late_interest';


   BEGIN

-- Start of wraper code generated automatically by Debug code generator for OKL_LTE_INT_PUB.calculate_late_interest
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPLINB.pls call OKL_LTE_INT_PUB.calculate_late_interest ');
    END;
  END IF;
                         OKL_LTE_INT_PUB.calculate_late_interest(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPLINB.pls call OKL_LTE_INT_PUB.calculate_late_interest ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_LTE_INT_PUB.calculate_late_interest


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
                           fnd_file.put_line(fnd_file.log, 'Late Interest Calculation Failed');
                           fnd_file.put_line(fnd_file.output, 'Late Interest Calculation Failed');
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

END OKL_LTE_INT_PUB;

/
