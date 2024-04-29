--------------------------------------------------------
--  DDL for Package Body OKL_PERD_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PERD_STATUS_PVT" AS
/* $Header: OKLRPSMB.pls 120.8.12010000.3 2008/12/11 23:33:05 sgiyer ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.PERIOD';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;



-- End of wraper code generated automatically by Debug code generator
  G_WARNING_STATUS	VARCHAR2(1) := 'W';


-- Added by kthiruva on 26-Sep-2003 Bug No.3126403
-- Procedure to clear the message except the first error message

PROCEDURE Clear_Message IS
BEGIN

   FOR i IN 1..(fnd_msg_pub.count_msg-1) LOOP
     IF  fnd_msg_pub.count_msg <> 1 THEN
        fnd_msg_pub.delete_MSG(p_msg_index     => 1);
     END IF;
   END LOOP;

END Clear_Message;


PROCEDURE SEARCH_PERIOD_STATUS(p_api_version      IN       NUMBER,
                               p_init_msg_list    IN       VARCHAR2,
                               x_return_status    OUT      NOCOPY VARCHAR2,
                               x_msg_count        OUT      NOCOPY NUMBER,
                               x_msg_data         OUT      NOCOPY VARCHAR2,
                               p_period_rec       IN       PERIOD_REC_TYPE,
                               x_period_tbl       OUT      NOCOPY PERIOD_TBL_TYPE )
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'SEARCH_PERIOD_STATUS';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_period_rec        period_rec_type;
  l_stmt              VARCHAR2(3000);
  l_application_id    NUMBER := 540;
  l_set_of_books_id   NUMBER ;
  l_perd_rec          period_rec_type;


  i NUMBER := 0;

  TYPE ref_cursor IS REF CURSOR ;
  perd_csr ref_cursor;



  BEGIN


     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_set_of_books_id := p_period_rec.SET_OF_BOOKS_ID;


     l_stmt := ' SELECT   APPLICATION_ID
                         ,LEDGER_ID
                         ,PERIOD_NAME
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATED_BY
                         ,CLOSING_STATUS
                         ,START_DATE
                         ,END_DATE
                         ,PERIOD_TYPE
                         ,PERIOD_YEAR
                         ,PERIOD_NUM
                         ,QUARTER_NUM
                         ,ADJUSTMENT_PERIOD_FLAG
                         ,CREATION_DATE
                         ,CREATED_BY
                         ,LAST_UPDATE_LOGIN
                         ,ATTRIBUTE1
                         ,ATTRIBUTE2
                         ,ATTRIBUTE3
                         ,ATTRIBUTE4
                         ,ATTRIBUTE5
                         ,CONTEXT
                         ,YEAR_START_DATE
                         ,QUARTER_START_DATE
                         ,EFFECTIVE_PERIOD_NUM
                         ,ELIMINATION_CONFIRMED_FLAG
    FROM GL_PERIOD_STATUSES
    WHERE Application_id = ' || ':1' ||
    ' AND  ledger_id = ' || ':2'  ;



        l_stmt := l_stmt || ' AND period_name = '|| NVL(':3','period_name') ;


        l_stmt := l_stmt || ' AND period_num = ' ||NVL(':4','period_num');


        l_stmt := l_stmt || ' AND period_year = ' ||NVL(':5','period_year');


        l_stmt := l_stmt || ' AND closing_status = ' || NVL(':6','closing_status');




    OPEN perd_csr FOR l_stmt USING l_application_id ,
				   l_set_of_books_id ,
				   p_period_rec.period_name ,
				   p_period_rec.period_num ,
				   p_period_rec.period_year,
				   p_period_rec.closing_status ;



    LOOP

        i := i + 1;

        FETCH perd_csr INTO l_perd_rec;
        EXIT WHEN perd_csr%NOTFOUND;

        l_period_rec.APPLICATION_ID              := l_perd_rec.APPLICATION_ID;
        l_period_rec.SET_OF_BOOKS_ID             := l_perd_rec.SET_OF_BOOKS_ID;
        l_period_rec.PERIOD_NAME                 := l_perd_rec.PERIOD_NAME ;
        l_period_rec.LAST_UPDATE_DATE            := l_perd_rec.LAST_UPDATE_DATE ;
        l_period_rec.LAST_UPDATED_BY             := l_perd_rec.LAST_UPDATED_BY;
        l_period_rec.CLOSING_STATUS              := l_perd_rec.CLOSING_STATUS;
        l_period_rec.START_DATE                  := l_perd_rec.START_DATE;
        l_period_rec.END_DATE                    := l_perd_rec.END_DATE;
        l_period_rec.PERIOD_TYPE                 := l_perd_rec.PERIOD_TYPE ;
        l_period_rec.PERIOD_YEAR                 := l_perd_rec.PERIOD_YEAR;
        l_period_rec.PERIOD_NUM                  := l_perd_rec.PERIOD_NUM  ;
        l_period_rec.QUARTER_NUM                 := l_perd_rec.QUARTER_NUM ;
        l_period_rec.ADJUSTMENT_PERIOD_FLAG      := l_perd_rec.ADJUSTMENT_PERIOD_FLAG ;
        l_period_rec.CREATION_DATE               := l_perd_rec.CREATION_DATE;
        l_period_rec.CREATED_BY                  := l_perd_rec.CREATED_BY ;
        l_period_rec.LAST_UPDATE_LOGIN           := l_perd_rec.LAST_UPDATE_LOGIN;
        l_period_rec.ATTRIBUTE1                  := l_perd_rec.ATTRIBUTE1;
        l_period_rec.ATTRIBUTE2                  := l_perd_rec.ATTRIBUTE2 ;
        l_period_rec.ATTRIBUTE3                  := l_perd_rec.ATTRIBUTE3;
        l_period_rec.ATTRIBUTE4                  := l_perd_rec.ATTRIBUTE4 ;
        l_period_rec.ATTRIBUTE5                  := l_perd_rec.ATTRIBUTE5 ;
        l_period_rec.CONTEXT                     := l_perd_rec.CONTEXT;
        l_period_rec.YEAR_START_DATE             := l_perd_rec.YEAR_START_DATE;
        l_period_rec.QUARTER_START_DATE          := l_perd_rec.QUARTER_START_DATE;
        l_period_rec.EFFECTIVE_PERIOD_NUM        := l_perd_rec.EFFECTIVE_PERIOD_NUM;
        l_period_rec.ELIMINATION_CONFIRMED_FLAG  := l_perd_rec.ELIMINATION_CONFIRMED_FLAG  ;

        x_period_tbl(i) := l_period_rec;

    END LOOP;

    CLOSE perd_csr;

    EXCEPTION

        WHEN OKL_API.G_EXCEPTION_ERROR THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;


END SEARCH_PERIOD_STATUS;



PROCEDURE UPDATE_PERIOD_STATUS(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_period_tbl         IN       PERIOD_TBL_TYPE)
IS

  l_api_name          CONSTANT VARCHAR2(40) := 'UPDATE_PERIOD_STATUS';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;

  l_stmt VARCHAR2(2000);
  l_count_rec NUMBER := 0;
  i NUMBER := 0;

  CURSOR perd_csr(p_period_name VARCHAR2,p_ledger_id NUMBER) IS
  SELECT closing_status
  FROM gl_period_statuses
  WHERE application_id = 540
  AND   ledger_id = p_ledger_id
  AND   period_name = p_period_name;

  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_closing_status GL_PERIOD_STATUSES.closing_status%TYPE;
  l_msg_data_comp	VARCHAR2(2000);
  l_msg_data		VARCHAR2(2000);
  l_msg_count		NUMBER;

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                               G_PKG_NAME,
                                               p_init_msg_list,
                                               l_api_version,
                                               p_api_version,
                                               '_PVT',
                                               x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;


     FOR i IN 1..p_period_tbl.COUNT

     LOOP


        OPEN perd_csr(p_period_tbl(i).period_name,p_period_tbl(i).set_of_books_id);
        FETCH perd_csr INTO l_closing_status;
        CLOSE perd_csr;

---- Call update only if period status is changed

        IF (l_closing_status <> p_period_tbl(i).closing_status) THEN

            UPDATE_PERD_ROW(p_api_version       => 1.0,
                            p_init_msg_list     => p_init_msg_list,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_period_rec        => p_period_tbl(i));


  	    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               Clear_Message;
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               Clear_Message;
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            IF l_return_status = G_WARNING_STATUS THEN
	       l_overall_status := G_WARNING_STATUS;
	    END IF;

        END IF;
     END LOOP;

     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


     -- Added by kthiruva on 26-Sep-2003 Bug No.3126403
     -- To get the warning messages in message stack incase of warnings

     IF  l_overall_status = G_WARNING_STATUS THEN
	FOR i IN 1..fnd_msg_pub.count_msg LOOP
	    fnd_msg_pub.get(
		p_msg_index     => i,
		p_encoded       => fnd_api.g_false,
		p_data          => l_msg_data,
		p_msg_index_out => l_msg_count);

		l_msg_data_comp := l_msg_data_comp || ' ' || SUBSTR(l_msg_data,1,150);
	END LOOP;
    ELSE
	Clear_Message;
    END IF;

    x_return_status := l_overall_status;
    x_msg_data := l_msg_data_comp;


  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END UPDATE_PERIOD_STATUS;



PROCEDURE UPDATE_PERD_ROW (p_api_version        IN         NUMBER,
                           p_init_msg_list      IN         VARCHAR2,
                           x_return_status      OUT        NOCOPY VARCHAR2,
                           x_msg_count          OUT        NOCOPY NUMBER,
                           x_msg_data           OUT        NOCOPY VARCHAR2,
                           p_period_rec         IN         PERIOD_REC_TYPE)

IS

  l_api_name          CONSTANT VARCHAR2(40) := 'UPDATE_PERD_ROW';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_row_count         NUMBER;
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  CURSOR prd_csr (v_period_name VARCHAR2,p_ledger_id NUMBER) IS
  SELECT closing_status
  FROM GL_PERIOD_STATUSES
  WHERE application_id  =  540
  AND   ledger_id =  p_ledger_id
  AND   period_name     =  v_period_name
  FOR UPDATE;
/* This cursor used to check if there are some unprocessed distributions which
    needs to be posted to gl but are still not posted .
 CURSOR dist_csr(p_start_date DATE,p_end_date DATE,p_ledger_id NUMBER) IS
 SELECT '1'
 FROM okl_trns_acc_dstrs
 WHERE gl_date BETWEEN p_start_date AND p_end_date
 AND post_to_gl ='Y'
 AND posted_yn = 'N'
 AND org_id IN
  (SELECT org_id
   FROM OKL_SYS_ACCT_OPTS
   WHERE set_of_books_id =p_ledger_id);
   */

-- Bug Number: 5707866 dpsingh SLA Uptake Changes for Accounting Period Status
CURSOR unprocessed_events_csr(p_start_date DATE,p_end_date DATE,p_ledger_id NUMBER) IS
SELECT 1
FROM xla_events xle, xla_transaction_entities xte
WHERE xle.event_date BETWEEN p_start_date AND p_end_date
AND xle.entity_id = xte.entity_id
AND xle.event_status_code IN ('I','U')
AND xte.ledger_id = p_ledger_id
AND xle.application_id = 540
AND rownum = 1;

--Bug 6034826 dpsingh
-- Bug 7634078. Commenting below check

 /*CURSOR aeh_csr(p_ledger_id NUMBER) IS
SELECT 1
FROM xla_ae_headers
WHERE application_id = 540
AND gl_transfer_status_code = 'N'
AND ledger_id = p_ledger_id
AND PERIOD_NAME = p_period_rec.period_name;
 */
--- Cursor to find the first ever opened period (or closed period)

-- Fixed Bug 3621515 by Santonyr on 15-May-2004

CURSOR gl_csr1(p_start_date DATE,p_ledger_id NUMBER) IS
SELECT period_name
FROM gl_period_statuses
WHERE application_id = 101
AND   ledger_id = p_ledger_id
AND   start_date <= p_start_date
AND   closing_status IN ('O', 'F');


--- Cursor to find out status of a period in GL
CURSOR gl_csr2(p_period_name VARCHAR2,p_ledger_id NUMBER) IS
SELECT closing_status
FROM gl_period_statuses
WHERE application_id = 101
AND   ledger_id = p_ledger_id
AND   period_name = p_period_name;


--- Cursor to find out if there is a period in OKL with 'F' or 'O' status prior to current period
--- which is being closed

CURSOR prior_csr(p_start_date DATE,p_ledger_id NUMBER) IS
SELECT period_name
FROM gl_period_statuses
WHERE application_id = 540
AND   ledger_id = p_ledger_id
AND   closing_status IN ('F','O')
AND   start_date < p_start_date;



i              NUMBER := 0;
l_start_date   DATE;
l_end_date     DATE;
l_dummy        VARCHAR2(1);
l_duplicate    VARCHAR2(1);
l_period_name  GL_PERIOD_STATUSES.period_name%TYPE;

l_closing_status    GL_PERIOD_STATUSES.closing_status%TYPE;
l_gl_closing_status GL_PERIOD_STATUSES.closing_status%TYPE;

BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     IF (p_period_rec.CLOSING_STATUS IS NULL) OR
        (p_period_rec.CLOSING_STATUS = OKL_API.G_MISS_CHAR) THEN

         OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                            ,p_msg_name      => g_required_value
                            ,p_token1        => g_col_name_token
                            ,p_token1_value  => 'PERIOD STATUS');

         RAISE OKL_API.G_EXCEPTION_ERROR;

     END IF;

     OPEN prd_csr(p_period_rec.period_name,p_period_rec.set_of_books_id);
     FETCH prd_csr INTO l_closing_status;

     IF prd_csr%NOTFOUND THEN
        CLOSE prd_csr;
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_PERIOD_NOT_FOUND',
                            p_token1       => 'PERIOD_NAME',
                            p_token1_value => p_period_rec.period_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     CLOSE prd_csr;

------ Check for Valid status changes
------ YOu can go from N to F,O; From F to O; from O to C; from C to N and from O to C

     IF (l_closing_status = 'N') THEN
         IF NOT (p_period_rec.closing_status  IN('F','O','N')) THEN

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_PERD_INVALID_CHANGE',
                                p_token1       => 'PERIOD_NAME',
                                p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;
     ELSIF (l_closing_status = 'F') THEN
         IF NOT (p_period_rec.closing_status IN ('O','F')) THEN

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_PERD_INVALID_CHANGE',
                                p_token1       => 'PERIOD_NAME',
                                p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;
     ELSIF (l_closing_status = 'O') THEN
         IF NOT (p_period_rec.closing_status IN ('C','O')) THEN

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_PERD_INVALID_CHANGE',
                                p_token1       => 'PERIOD_NAME',
                                p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
     ELSIF (l_closing_status = 'C') THEN
         IF NOT (p_period_rec.closing_status IN ('O','P','C')) THEN

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_PERD_INVALID_CHANGE',
                                p_token1       => 'PERIOD_NAME',
                                p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
     ELSIF (l_closing_status = 'P') THEN
         IF NOT (p_period_rec.closing_status = 'P') THEN

            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_PERD_INVALID_CHANGE',
                                p_token1       => 'PERIOD_NAME',
                                p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

     END IF;

----- End of status changes validation

----- Get the period information
-- rkuttiya changed for Multi Gaap Project bug 7263041
     OKL_ACCOUNTING_UTIL.get_period_info(p_period_name    => p_period_rec.period_name,
                                         p_start_date     => l_start_date,
                                         p_end_date       => l_end_date,
                                         p_ledger_id      =>
p_period_rec.set_of_books_id);

----- Validate that the period being opened is later than the first ever opened GL period

     IF (l_closing_status IN ('N') ) AND
        (p_period_rec.closing_status  IN ('F','O')) THEN --- You are trying to open a period

         l_period_name := NULL;
         OPEN gl_csr1(l_start_date,p_period_rec.set_of_books_id);
         FETCH gl_csr1 INTO l_period_name;
         CLOSE gl_csr1;

         IF (l_period_name IS NULL) THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_PERD_LATER_THAN_GL',
                                 p_token1       => 'PERIOD_NAME',
                                 p_token1_value => p_period_rec.period_name);
            RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;

     END IF;

---- If you are trying to re-open a closed period, make sure that GL period is Open

     IF (l_closing_status IN ('C')) AND
        (p_period_rec.closing_status  IN ('O')) THEN --- You are trying to re-open a closed period

         l_gl_closing_status := NULL;

         OPEN gl_csr2(p_period_rec.period_name,p_period_rec.set_of_books_id);
         FETCH gl_csr2 INTO l_gl_closing_status;
         CLOSE gl_csr2;

         IF (l_gl_closing_status IN ('C','P')) THEN

             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_GL_PERD_NOT_OPEN',
                                 p_token1       => 'PERIOD_NAME',
                                 p_token1_value => p_period_rec.period_name);

            RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;

     END IF;


---- If you are trying to close a period, make sure that prior periods are not open
---- In this case, just issue error message, no need to abort.

     IF (l_closing_status IN ('O')) AND
        (p_period_rec.closing_status  IN ('C')) THEN --- You are trying to close a period

         l_period_name := NULL;

         OPEN prior_csr(l_start_date,p_period_rec.set_of_books_id);
         FETCH prior_csr INTO l_period_name;
         CLOSE prior_csr;

         IF (l_period_name IS NOT NULL) THEN

             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_PRIOR_PERD_NOT_OPEN',
                                 p_token1       => 'PERIOD_NAME',
                                 p_token1_value => p_period_rec.period_name);

             x_return_status := G_WARNING_STATUS;

         END IF;

 /*   Bug 6017488 dpsingh
      -- Check in the distribution that there are no un-accounted distribution for this period.
         OPEN dist_csr(l_start_date,l_end_date,p_period_rec.set_of_books_id);
         FETCH dist_csr INTO l_dummy;

         IF (l_dummy = '1')THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_PERD_INVALID_CLOSE',
                                  p_token1       => 'PERIOD_NAME',
                                  p_token1_value => p_period_rec.period_name);
              CLOSE dist_csr;
              RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;

         CLOSE dist_csr;
 */
-- Bug Number: 5707866 dpsingh SLA Uptake Changes for Accounting Period Status
---- Error should be thrown on closing the period if there are any accounting events that are not accounted i.e. events are still in the status of Incomplete or Unprocessed
         l_dummy := NULL;
         OPEN unprocessed_events_csr(l_start_date,l_end_date,p_period_rec.set_of_books_id);
         FETCH unprocessed_events_csr INTO l_dummy;
         CLOSE unprocessed_events_csr;

         IF (l_dummy = '1')THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_PERD_INVALID_CLOSE',
                                  p_token1       => 'PERIOD_NAME',
                                  p_token1_value => p_period_rec.period_name);
              CLOSE unprocessed_events_csr;
              RAISE OKL_API.G_EXCEPTION_ERROR;

         END IF;


         ---- Check in the accounting tables that there is no un-transferred records
         -- Bug 7634078. As per vphanse & mmittal, no need to check untranferred records
         --              commenting below code.
/*
         l_dummy := NULL;
         OPEN aeh_csr(p_period_rec.set_of_books_id);
         FETCH aeh_csr INTO l_dummy;

         IF (l_dummy = '1') THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_RUN_GL_TRANSFER',
                                  p_token1       => 'PERIOD_NAME',
                                  p_token1_value => p_period_rec.period_name);
              CLOSE aeh_csr;
              RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         CLOSE aeh_csr;
*/
     END IF;

---- All validations done. Now update the GL period Status table.

     UPDATE GL_PERIOD_STATUSES
     SET   CLOSING_STATUS    =  p_period_rec.closing_status,
           LAST_UPDATE_DATE  =  SYSDATE,
           LAST_UPDATED_BY   =  FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN =  FND_GLOBAL.LOGIN_ID
     WHERE APPLICATION_ID    =  540
     AND   LEDGER_ID   =  p_period_rec.set_of_books_id
     AND   PERIOD_NAME       =  p_period_rec.period_name;


    EXCEPTION

        WHEN OKL_API.G_EXCEPTION_ERROR THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
               x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_PERD_ROW;

END OKL_PERD_STATUS_PVT ;

/
