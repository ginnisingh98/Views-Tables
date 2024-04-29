--------------------------------------------------------
--  DDL for Package Body OKL_PRCTIMEOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PRCTIMEOUT_PVT" AS
/* $Header: OKLRPTOB.pls 120.2 2007/05/14 20:39:24 srsreeni ship $ */

PROCEDURE REQUEST_TIME_OUT(x_errbuf OUT  NOCOPY VARCHAR2,
                           x_retcode OUT NOCOPY NUMBER)
IS
  l_api_name          CONSTANT VARCHAR2(40) := 'OKL_PRCTIMEOUT_PVT';
  l_api_version       CONSTANT NUMBER       := 1.0;
  p_api_version       CONSTANT NUMBER 	    := 1.0;

  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_init_msg_list     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  lp_sifv_rec sifv_rec_type;
  lx_sifv_rec sifv_rec_type;

  l_time_out 		  NUMBER := TO_NUMBER (FND_PROFILE.VALUE ('OKL_STREAMS_TIME_OUT'));
  l_sysdate		  	  DATE := SYSDATE;

  CURSOR l_okl_prctimeout_csr
  IS
  SELECT ID, DATE_PROCESSED, ORP_CODE,KHR_ID
  FROM OKL_STREAM_INTERFACES
  WHERE sis_code IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST, G_SIS_RET_DATA_RECEIVED);

  l_okl_prctimeout_rec l_okl_prctimeout_csr%ROWTYPE;
  l_date_processed DATE;
  l_RecordsProcessed NUMBER := 0;
  l_error_msg_rec     Error_message_Type;

BEGIN

    x_retcode := 0;
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,l_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error in Start Activity');
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Start Activity');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Activity Successful');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

-- Printing the values in the log file.

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Pricing Time out value : ' || l_time_out);
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');


    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Processing Started ... ');


    FOR l_okl_prctimeout_rec in l_okl_prctimeout_csr LOOP

    IF((l_sysdate - l_okl_prctimeout_rec.date_processed)  * 1440) > l_time_out THEN
      l_RecordsProcessed := l_RecordsProcessed + 1;

      lp_sifv_rec.id := l_okl_prctimeout_rec.id;
	  lp_sifv_rec.sis_code := G_SIS_TIME_OUT;
	  lp_sifv_rec.orp_code := l_okl_prctimeout_rec.orp_code;

  	  okl_stream_interfaces_pub.update_stream_interfaces(
	      p_api_version     => l_api_version,
		  p_init_msg_list   => l_init_msg_list  ,
		  x_return_status   => l_return_status,
          x_msg_count  		=> l_msg_count,
          x_msg_data  		=> l_msg_data,
          p_sifv_rec        => lp_sifv_rec,
          x_sifv_rec        => lx_sifv_rec );
	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_return_Status || 'Unexpected Error ');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_return_Status || 'Expected Error ');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
--srsreeni Bug6011651 starts.Updates to ERROR when the processing fails
OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
     p_api_version         => l_api_version,
     p_init_msg_list       => l_init_msg_list,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data,
     p_khr_id              => l_okl_prctimeout_rec.khr_id,
     p_prog_short_name     => OKL_BOOK_CONTROLLER_PVT.G_PRICE_CONTRACT,
     p_progress_status     => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

--srsreeni Bug6011651 ends

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Record Updated for ID : ' || l_okl_prctimeout_rec.id);

     END IF;
   END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' Processing Started ... ');

  IF l_RecordsProcessed > 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of Records Updated : ' || l_RecordsProcessed);
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'None of the Records are updated.');
  END IF;


  Okl_Api.END_ACTIVITY(l_msg_count, l_msg_data);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End Activity Successful');
  x_retcode := 0;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_retcode := 2;

      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'Okl_Api.G_RET_STS_ERROR'
                                 ,l_msg_count
                                 ,l_msg_data
                                 ,'_PVT');

      -- print the error message in the log file

      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_retcode := 2;
      IF l_okl_prctimeout_csr%ISOPEN THEN
        CLOSE l_okl_prctimeout_csr;
      END IF;

      l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                             ,g_pkg_name
                             ,'Okl_Api.G_RET_STS_UNEXP_ERROR'
                             ,l_msg_count
                             ,l_msg_data
                             ,'_PVT');
      -- print the error message in the log file
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       IF l_okl_prctimeout_csr%ISOPEN THEN
         CLOSE l_okl_prctimeout_csr;
       END IF;

       l_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                             ,g_pkg_name
                             ,'OTHERS'
                             ,l_msg_count
                             ,l_msg_data
                             ,'_PVT');

     -- print the error message in the log file
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
          FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
          LOOP
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
          END LOOP;
        END IF;

END REQUEST_TIME_OUT;

END OKL_PRCTIMEOUT_PVT;

/
