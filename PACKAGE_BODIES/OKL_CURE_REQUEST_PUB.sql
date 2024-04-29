--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REQUEST_PUB" AS
/* $Header: OKLPREQB.pls 115.7 2003/10/10 18:35:33 jsanju noship $ */

  ----------------------------------------------------------------------
  -- PROCEDURE SEND_CURE_REQUEST
  ----------------------------------------------------------------------
  PROCEDURE SEND_CURE_REQUEST
  (
     errbuf               OUT NOCOPY VARCHAR2,
     retcode              OUT NOCOPY NUMBER,
     p_vendor_number      IN  NUMBER DEFAULT NULL,
     p_report_number      IN  VARCHAR2 DEFAULT NULL,
     p_report_date        IN  VARCHAR2 DEFAULT NULL

  )
  IS

  l_vendor_number         NUMBER;
  l_report_number         VARCHAR2(2000);
  l_report_date           DATE;

  l_agent_id              NUMBER;
  l_content_id            NUMBER;
  l_from                  VARCHAR2(240);
  l_subject               VARCHAR2(240);
  l_email                 VARCHAR2(240);

  BEGIN


      SAVEPOINT SEND_CURE_REQUEST;
      OKL_CURE_REQUEST_PVT.SEND_CURE_REQUEST
        (
         errbuf           => errbuf,
         retcode          => retcode,
         p_vendor_number  => p_vendor_number,
         p_report_number  => p_report_number,
         p_report_date    => p_report_date
       );

  EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SEND_CURE_REQUEST;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
  END SEND_CURE_REQUEST;

END OKL_CURE_REQUEST_PUB;




/
