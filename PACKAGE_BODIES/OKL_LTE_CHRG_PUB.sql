--------------------------------------------------------
--  DDL for Package Body OKL_LTE_CHRG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LTE_CHRG_PUB" AS
/* $Header: OKLPCHGB.pls 115.11 2004/04/13 10:37:39 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.FEES';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



  PROCEDURE calculate_late_charge(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS

    l_api_name VARCHAR2(50) := 'calculate_late_charge';
    l_init_msg_list VARCHAR2(200);
    l_msg_data VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;


  BEGIN







-- Start of wraper code generated automatically by Debug code generator for Okl_Lte_Chrg_Pvt.calculate_late_charge
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCHGB.pls call Okl_Lte_Chrg_Pvt.calculate_late_charge ');
    END;
  END IF;
        Okl_Lte_Chrg_Pvt.calculate_late_charge(
                                                p_api_version
                                               ,p_init_msg_list
                                               ,x_return_status
                                               ,x_msg_count
                                               ,x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCHGB.pls call Okl_Lte_Chrg_Pvt.calculate_late_charge ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Lte_Chrg_Pvt.calculate_late_charge







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
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Other) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END calculate_late_charge;

  PROCEDURE calculate_late_charge(   ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                         RETCODE                 OUT NOCOPY    VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2 DEFAULT Okc_Api.G_FALSE
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_mesg                VARCHAR2(4000);
   l_mesg_len            NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'calculate_late_charge';


   BEGIN

-- Start of wraper code generated automatically by Debug code generator for Okl_Lte_Chrg_Pub.calculate_late_charge
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCHGB.pls call Okl_Lte_Chrg_Pub.calculate_late_charge ');
    END;
  END IF;
                         Okl_Lte_Chrg_Pub.calculate_late_charge(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCHGB.pls call Okl_Lte_Chrg_Pub.calculate_late_charge ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Lte_Chrg_Pub.calculate_late_charge


                        l_msg_count := Fnd_Msg_Pub.count_msg;
                        IF l_msg_count > 0 THEN

                            l_mesg := SUBSTR(Fnd_Msg_Pub.get(Fnd_Msg_Pub.G_FIRST, Fnd_Api.G_FALSE), 1, 512);

                            FOR i IN 1..(l_msg_count - 1) LOOP
                                l_mesg := l_mesg || SUBSTR(Fnd_Msg_Pub.get(Fnd_Msg_Pub.G_NEXT,Fnd_Api.G_FALSE), 1, 512);
                            END LOOP;

                            Fnd_Msg_Pub.delete_msg();

                            l_mesg_len := LENGTH(l_mesg);
                            Fnd_File.put_line(Fnd_File.LOG, 'Error: ');
                            Fnd_File.put_line(Fnd_File.output, 'Error: ');

                            FOR i IN 1..CEIL(l_mesg_len/255) LOOP
                                Fnd_File.put_line(Fnd_File.LOG, l_mesg);
                                Fnd_File.put_line(Fnd_File.output, l_mesg);
                            END LOOP;

                            Fnd_File.new_line(Fnd_File.LOG,2);
                            Fnd_File.new_line(Fnd_File.output,2);
                        END IF;

                        IF l_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
                           Fnd_File.put_line(Fnd_File.LOG, 'Late Charges Calculation Failed');
                           Fnd_File.put_line(Fnd_File.output, 'Late Charges Calculation Failed');
                        END IF;


Fnd_File.put_line(Fnd_File.LOG,'msg data '||l_msg_data);
Fnd_File.put_line(Fnd_File.LOG,'return status '||l_return_status);
Fnd_File.put_line(Fnd_File.output,'msg data '||l_msg_data);
Fnd_File.put_line(Fnd_File.output,'return status '||l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Other) => '||SQLERRM);
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

END Okl_Lte_Chrg_Pub;

/
