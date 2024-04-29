--------------------------------------------------------
--  DDL for Package Body OKL_REVERSAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REVERSAL_PVT" AS
/* $Header: OKLRREVB.pls 120.8.12010000.3 2008/11/12 10:47:30 racheruv ship $ */

-- Start of wraper code generated automatically by Debug code generator

  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.REVERSAL';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;

-- End of wraper code generated automatically by Debug code generator

-- Record type for printing the report

TYPE PROCESS_REC_TYPE IS RECORD
(Contract_NUMBER		    VARCHAR2(90),
 Transaction_type		    VARCHAR2(78),
 Transaction_number                 VARCHAR2(45),
 Transaction_date		    VARCHAR2(36),
 Transaction_Line_number            VARCHAR2(21),
 Amount                             VARCHAR2(54),
 Org_accounting_date                VARCHAR2(36),
 Reversal_Accounting_Date           VARCHAR2(36));

 l_contract_num_len		NUMBER:=30;
 l_transaction_type_len	      NUMBER:=26;
 l_transaction_num_len 	      NUMBER:=15;
 l_transaction_date_len	      NUMBER:=12;
 l_transaction_line_num_len	NUMBER:=7;
 l_amount_len			NUMBER:=18;
 l_accounting_date_len		NUMBER:=12;
 l_rev_acc_date_len		NUMBER:=12;




--- Function to get the proper length depending upon the data to be printed.

FUNCTION  GET_PROPER_LENGTH(p_input_data          IN   VARCHAR2,
                            p_input_length        IN   NUMBER,
   		                p_input_type          IN   VARCHAR2)
RETURN VARCHAR2

IS

x_return_data VARCHAR2(1000);

BEGIN

IF (p_input_type = 'TITLE') THEN
    IF (p_input_data IS NOT NULL) THEN
     x_return_data := RPAD(SUBSTR(ltrim(rtrim(p_input_data)),1,p_input_length),p_input_length,' ');
    ELSE
     x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
ELSE
    IF (p_input_data IS NOT NULL) THEN
         IF (length(p_input_data) > p_input_length) THEN
             x_return_data := RPAD('*',p_input_length,'*');
         ELSE
             x_return_data := RPAD(p_input_data,p_input_length,' ');
         END IF;
    ELSE
         x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
END IF;

RETURN x_return_data;

END GET_PROPER_LENGTH;






PROCEDURE REVERSE_ENTRIES(p_errbuf        OUT NOCOPY      VARCHAR2,
                          p_retcode       OUT NOCOPY      NUMBER,
                          p_period        IN       VARCHAR2)
IS

BEGIN
--Stubbed out this procedure for Bug 5707866 (SLA Uptake of periodic reversal concurrent program).

FND_MESSAGE.SET_NAME( application =>g_app_name ,
                                              NAME =>  'OKL_OBS_PERD_REV_PRG' );
FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

END REVERSE_ENTRIES;



PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_id                  IN         NUMBER,
			  	  p_source_table               IN         VARCHAR2,
		              p_acct_date                  IN         DATE)
IS

  TYPE ref_cursor IS REF CURSOR;
  src_csr ref_cursor;


  l_set_of_books_id               NUMBER;
  l_org_id                        NUMBER;
  l_period_name                   GL_PERIODS_V.period_name%TYPE;
  l_closing_status                GL_PERIOD_STATUSES_V.closing_status%TYPE;

  l_new_description               OKL_AE_HEADERS.DESCRIPTION%TYPE;

  l_dist_tbl_in                   OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;
  l_dist_tbl_out                  OKL_TRNS_ACC_DSTRS_PUB.tabv_tbl_type;

  i                  NUMBER := 1;
  j                  NUMBER := 0;
  l_line_number      NUMBER := 0;
  l_validate_flag    VARCHAR2(1);

  l_return_status    VARCHAR2(1);
  l_api_name         VARCHAR2(30) := 'REVERSE_ENTRIES';
  l_init_msg_list    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_api_version      NUMBER := 1.0;
  l_application_id   NUMBER := 101;   -- This should be changed to 540
  l_dummy_var        VARCHAR2(1);
  l_string           VARCHAR2(500);
  l_event_number     NUMBER := 0;
  l_start_date       DATE;
  l_end_date         DATE;
  l_period_status    GL_PERIOD_STATUSES_V.CLOSING_STATUS%TYPE;



  CURSOR prdst_csr(v_period_name     VARCHAR2) IS
  SELECT prdst.closing_status
  FROM  GL_PERIOD_STATUSES_V prdst
  WHERE prdst.ledger_id = OKL_ACCOUNTING_UTIL.get_set_of_books_id
  AND   prdst.period_name     = v_period_name
  AND   prdst.APPLICATION_ID  = l_application_id;

  CURSOR check_dist_csr
  IS
  SELECT 'x'
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id          = p_source_id
  AND   source_table       = p_source_table
  AND   REVERSE_EVENT_FLAG = 'Y';


  CURSOR dist_csr IS
   SELECT  ID
        ,CURRENCY_CONVERSION_TYPE
        ,SET_OF_BOOKS_ID
        ,CR_DR_FLAG
        ,CODE_COMBINATION_ID
        ,ORG_ID
        ,CURRENCY_CODE
        ,AE_LINE_TYPE
        ,TEMPLATE_ID
        ,SOURCE_ID
        ,SOURCE_TABLE
        ,OBJECT_VERSION_NUMBER
        ,AMOUNT
        ,ACCOUNTED_AMOUNT
        ,GL_DATE
        ,PERCENTAGE
        ,COMMENTS
        ,POST_REQUEST_ID
        ,CURRENCY_CONVERSION_DATE
        ,CURRENCY_CONVERSION_RATE
        ,REQUEST_ID
        ,PROGRAM_APPLICATION_ID
        ,PROGRAM_ID
        ,PROGRAM_UPDATE_DATE
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,AET_ID
        ,POSTED_YN
        ,AE_CREATION_ERROR
        ,GL_REVERSAL_FLAG
        ,POST_TO_GL
        ,REVERSE_EVENT_FLAG
        ,ORIGINAL_DIST_ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_table    = p_source_table
  AND   source_id       = p_source_id;

  dist_rec  dist_csr%ROWTYPE;

 -- Cursor to get the short_name to be passed as
 -- the representation code. SLA Uptake
 -- extended to get the representation based on tcn_id.. MG Uptake
 CURSOR get_gl_short_name_csr(p_tcn_id NUMBER) IS
 SELECT rep.representation_code
   FROM okl_trx_contracts_all o,
        okl_representations_v rep
  WHERE o.set_of_books_id = rep.ledger_id
    AND o.id = p_tcn_id;

 --Cursor to get the Account Derivation Option.. SLA Uptake
 CURSOR get_acct_derivation_csr IS
 SELECT account_derivation
   FROM okl_sys_acct_opts;

 --Cursor to get the transaction header id .. SLA Uptake
 CURSOR get_tcn_id_csr IS
 SELECT tcn_id
   FROM okl_txl_cntrct_lns_all
  WHERE id = p_source_id;

 -- Cursor to get transaction type name .. SLA Uptake
 CURSOR get_try_name_csr(p_tcn_id IN NUMBER) IS
 SELECT t.name
   FROM okl_trx_types_tl t, okl_trx_contracts_all tcn
  WHERE tcn.try_id = t.id
    AND tcn.id = p_tcn_id
    AND LANGUAGE = 'US';

 l_account_derivation_option VARCHAR2(10);
 l_tcn_id                    NUMBER;
 l_try_name                  VARCHAR2(150);
 l_gl_short_name             VARCHAR2(20);
 l_event_id                  NUMBER;
 l_exist_event_id            NUMBER;
 l_exist_event_date          DATE;
 l_accounting_event_id       NUMBER;


BEGIN


   x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Validate Source id and Source Table


   IF (p_source_table IS NULL OR p_source_table = OKL_API.G_MISS_CHAR) THEN
       OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'source_table');
       x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (p_source_id IS NULL OR p_source_id = OKL_API.G_MISS_NUM) THEN
       OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'source_id');
       x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (p_acct_date IS NULL OR p_acct_date = OKL_API.G_MISS_DATE) THEN
       OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'acct_date');
       x_return_status    := OKL_API.G_RET_STS_ERROR;
	   RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_validate_flag :=
         OKL_ACCOUNTING_UTIL.VALIDATE_SOURCE_ID_TABLE(p_source_id    => p_source_Id,
                                                      p_source_table => p_source_table);

   IF (l_validate_flag = OKL_API.G_FALSE) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
	                   p_msg_name     => 'OKL_INVALID_SOURCE_TBL_ID');

       RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;


   OKL_ACCOUNTING_UTIL.get_period_info(p_date        => p_acct_date,
                                       p_period_name => l_period_name,
                                       p_start_date  => l_start_date,
                                       p_end_date    => l_end_date);

   IF (l_period_name IS NULL) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKL_ACCT_PERD_NOT_FOUND',
			               p_token1       => 'ACCT_DATE',
			               p_token1_value => p_acct_date);
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_period_status := OKL_ACCOUNTING_UTIL.get_okl_period_status(l_period_name);

   IF (l_period_status NOT IN ('O','F')) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKL_PERD_INVALID_STATUS',
     			           p_token1       => 'PERIOD',
			               p_token1_value => l_period_name);

       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

-- If the selected event is already reversed earlier then Abort the processing

   OPEN check_dist_csr;
   FETCH check_dist_csr INTO l_dummy_var;
   IF (check_dist_csr%FOUND) THEN
       OKL_API.set_message(p_app_name     =>  G_APP_NAME,
	                       p_msg_name     => 'OKL_TXN_ALREADY_REVERSED');

       CLOSE check_dist_csr;
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE check_dist_csr;


   OPEN  dist_csr;
   FETCH dist_csr INTO dist_rec;
   IF (dist_csr%NOTFOUND) THEN
       -- Santonyr on 14-Feb-2003 Fixed bug 2804913
       OKL_API.set_message(p_app_name     =>  G_APP_NAME,
                           p_msg_name     => 'OKL_DIST_NOT_FOUND');
       CLOSE dist_csr;
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- SLA uptake changes .. start
   l_event_id         := NULL;
   l_exist_event_id   := NULL;
   l_exist_event_date := NULL;

   OPEN  get_acct_derivation_csr;
   FETCH get_acct_derivation_csr INTO l_account_derivation_option;
   CLOSE get_acct_derivation_csr;

   IF p_source_table = 'OKL_TXL_CNTRCT_LNS' THEN
      OPEN  get_tcn_id_csr;
	  FETCH get_tcn_id_csr INTO l_tcn_id;
	  CLOSE get_tcn_id_csr;

      OPEN  get_try_name_csr(l_tcn_id);
      FETCH get_try_name_csr INTO l_try_name;
	  CLOSE get_try_name_csr;

      IF l_try_name IN
	  ('Booking','Rebook','Release','Termination','Evergreen','Investor',
	   'Asset Disposition', 'Receipt Application','Principal Adjustment',
	   'Specific Loss Provision','General Loss Provision','Accrual',
	   'Upfront Tax') THEN

		 -- changed the cursor to fetch gl short name based on tcn_id .. MG uptake
	     OPEN  get_gl_short_name_csr(l_tcn_id);
	     FETCH get_gl_short_name_csr INTO l_gl_short_name;
	     CLOSE get_gl_short_name_csr;

	  -- Verify existence of event.It's possible to have an event raised for one of the
	  -- transaction lines before. If event is raised for the same transaction, event type
	  -- and event date then re-use it. Do not raise a new event.
      OKL_XLA_EVENTS_PVT.event_exists(p_api_version        => l_api_version
                                     ,p_init_msg_list      => l_init_msg_list
                                     ,x_return_status      => l_return_status
                                     ,x_msg_count          => l_msg_count
                                     ,x_msg_data           => l_msg_data
                                     ,p_tcn_id             => l_tcn_id
                                     ,p_action_type        => 'REVERSE'
                                     ,x_event_id           => l_exist_event_id
                                     ,x_event_date         => l_exist_event_date);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_accounting_event_id := l_exist_event_id;

      IF (NVL(l_exist_event_id,0) = 0 AND
	      NVL(l_exist_event_date, trunc(sysdate) + 1) <> p_acct_date) THEN
	  -- END of code to be deleted once all teams uptake AE call.

      l_event_id :=
        OKL_XLA_EVENTS_PVT.create_event(p_api_version          => l_api_version
                                       ,p_init_msg_list        => l_init_msg_list
                                       ,x_return_status        => l_return_status
                                       ,x_msg_count            => l_msg_count
                                       ,x_msg_data             => l_msg_data
                                       ,p_tcn_id               => l_tcn_id
                                       ,p_gl_date              => p_acct_date
                                       ,p_action_type          => 'REVERSE'
                                       ,p_representation_code  => l_gl_short_name
                                       );

         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_accounting_event_id := l_event_id;

      END IF; -- if l_exist_event_id
	  END IF; -- IF l_try_name

   END IF; -- IF p_source_table
   -- SLA uptake changes .. end
   i := 1;

   LOOP

	   -- SLA Uptake modifications.. start
		  IF (dist_rec.CR_DR_FLAG IS NULL) THEN
		     l_dist_tbl_in(i).CR_DR_FLAG         := NULL;
             l_dist_tbl_in(i).AMOUNT             := -1 * dist_rec.amount;
             l_dist_tbl_in(i).ACCOUNTED_AMOUNT   := -1 * dist_rec.accounted_amount;
          ELSIF (dist_rec.CR_DR_FLAG = 'D') THEN
             l_dist_tbl_in(i).CR_DR_FLAG         := 'C';
             l_dist_tbl_in(i).AMOUNT             := dist_rec.amount;
             l_dist_tbl_in(i).ACCOUNTED_AMOUNT   := dist_rec.accounted_amount;
          ELSE
             l_dist_tbl_in(i).CR_DR_FLAG         := 'D';
             l_dist_tbl_in(i).AMOUNT             := dist_rec.amount;
             l_dist_tbl_in(i).ACCOUNTED_AMOUNT   := dist_rec.accounted_amount;
          END IF;
	   -- SLA Uptake modifications .. end

          l_dist_tbl_in(i).CURRENCY_CONVERSION_TYPE := dist_rec.currency_conversion_type;
          l_dist_tbl_in(i).CODE_COMBINATION_ID      := dist_rec.code_combination_id;
          l_dist_tbl_in(i).CURRENCY_CODE            := dist_rec.currency_code;
          l_dist_tbl_in(i).AE_LINE_TYPE             := dist_rec.ae_line_type;
          l_dist_tbl_in(i).TEMPLATE_ID              := dist_rec.template_id;
          l_dist_tbl_in(i).SOURCE_ID                := dist_rec.source_id;
          l_dist_tbl_in(i).SOURCE_TABLE             := dist_rec.source_table;
          l_dist_tbl_in(i).GL_DATE                  := p_acct_date;
          l_dist_tbl_in(i).PERCENTAGE               := dist_rec.percentage;
          l_dist_tbl_in(i).COMMENTS                 := dist_rec.comments;
          l_dist_tbl_in(i).CURRENCY_CONVERSION_DATE := dist_rec.currency_conversion_date;
          l_dist_tbl_in(i).CURRENCY_CONVERSION_RATE := dist_rec.currency_conversion_rate;
          l_dist_tbl_in(i).ATTRIBUTE_CATEGORY       := dist_rec.attribute_category;
          l_dist_tbl_in(i).ATTRIBUTE1               := dist_rec.attribute1;
          l_dist_tbl_in(i).ATTRIBUTE2               := dist_rec.attribute2;
          l_dist_tbl_in(i).ATTRIBUTE3               := dist_rec.attribute3;
          l_dist_tbl_in(i).ATTRIBUTE4               := dist_rec.attribute4;
          l_dist_tbl_in(i).ATTRIBUTE5               := dist_rec.attribute5;
          l_dist_tbl_in(i).ATTRIBUTE6               := dist_rec.attribute6;
          l_dist_tbl_in(i).ATTRIBUTE7               := dist_rec.attribute7;
          l_dist_tbl_in(i).ATTRIBUTE8               := dist_rec.attribute8;
          l_dist_tbl_in(i).ATTRIBUTE9               := dist_rec.attribute9;
          l_dist_tbl_in(i).ATTRIBUTE10              := dist_rec.attribute10;
          l_dist_tbl_in(i).ATTRIBUTE11              := dist_rec.attribute11;
          l_dist_tbl_in(i).ATTRIBUTE12              := dist_rec.attribute12;
          l_dist_tbl_in(i).ATTRIBUTE13              := dist_rec.attribute13;
          l_dist_tbl_in(i).ATTRIBUTE14              := dist_rec.attribute14;
          l_dist_tbl_in(i).ATTRIBUTE15              := dist_rec.attribute15;
          l_dist_tbl_in(i).AET_ID                   := NULL;
          l_dist_tbl_in(i).POSTED_YN                := 'Y';
          l_dist_tbl_in(i).AE_CREATION_ERROR        := NULL;
          l_dist_tbl_in(i).GL_REVERSAL_FLAG         := 'N';
          l_dist_tbl_in(i).POST_TO_GL               := dist_rec.post_to_gl;
          l_dist_tbl_in(i).REVERSE_EVENT_FLAG       := 'Y';
          l_dist_tbl_in(i).ORIGINAL_DIST_ID         := dist_rec.ID;
          l_dist_tbl_in(i).ACCOUNTING_EVENT_ID      := l_accounting_event_id;
		  -- populate the set of books.
		  l_dist_tbl_in(i).set_of_books_id          := dist_rec.set_of_books_id;

          FETCH dist_csr INTO dist_rec;
          EXIT WHEN dist_csr%NOTFOUND;
          i := i + 1;

   END LOOP;

   CLOSE dist_csr;

-- Start of wraper code generated automatically by Debug code generator for OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRREVB.pls call OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs ');
    END;
  END IF;

   OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs(p_api_version      => l_api_version,
                                                p_init_msg_list    => p_init_msg_list,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => x_msg_count,
                                                x_msg_data         => x_msg_data,
                                                p_tabv_tbl         => l_dist_tbl_in,
                                                x_tabv_tbl         => l_dist_tbl_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRREVB.pls call OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs


   x_return_status := l_return_status;

EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

           x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END REVERSE_ENTRIES;



PROCEDURE REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                          p_init_msg_list              IN         VARCHAR2,
                          x_return_status              OUT        NOCOPY VARCHAR2,
                          x_msg_count                  OUT        NOCOPY NUMBER,
                          x_msg_data                   OUT        NOCOPY VARCHAR2,
                          p_source_table               IN         VARCHAR2,
			  p_acct_date                  IN         DATE,
		          p_source_id_tbl              IN         SOURCE_ID_TBL_TYPE)
IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                    CONSTANT VARCHAR2(30) := 'REVERSE_ENTRIES';
  l_return_status               VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_overall_status              VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  i                             NUMBER := 0;
  l_msg_count                   NUMBER := 0;
  l_msg_data                    VARCHAR2(2000);


BEGIN

    IF (p_source_id_tbl.COUNT > 0) THEN

        i := p_source_id_tbl.FIRST;

        LOOP

          REVERSE_ENTRIES(p_api_version      => 1.0,
                          p_init_msg_list    => OKL_API.G_FALSE,
                          x_return_status    => l_return_status,
                          x_msg_count        => l_msg_count,
                          x_msg_data         => l_msg_data,
                          p_source_id        => p_source_id_tbl(i),
			  p_source_table     => p_source_table,
			  p_acct_date        => p_acct_date);

	  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
	      IF (l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		  l_overall_status := l_return_status;
	      END IF;
	  END IF;


          EXIT WHEN (i = p_source_id_tbl.LAST);
          i := p_source_id_tbl.NEXT(i);


        END LOOP;

    END IF;


    x_return_status := l_overall_status;
    x_msg_data      := l_msg_data;
    x_msg_count     := l_msg_count;


END REVERSE_ENTRIES;



PROCEDURE SUBMIT_PERIOD_REVERSAL(p_api_version         IN         NUMBER,
                                 p_init_msg_list       IN         VARCHAR2,
                                 x_return_status       OUT        NOCOPY VARCHAR2,
                                 x_msg_count           OUT        NOCOPY NUMBER,
                                 x_msg_data            OUT        NOCOPY VARCHAR2,
                                 p_period              IN         VARCHAR2,
                                 x_request_id          OUT NOCOPY        NUMBER)
IS

   l_api_version          CONSTANT NUMBER := 1.0;
   l_api_name             CONSTANT VARCHAR2(30) := 'SUBMIT_PERIOD_REVERSAL';
   l_return_status        VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_init_msg_list        VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);

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

    -- check for period name before submitting the request.
   IF (p_period IS NULL) OR (p_period = Okl_Api.G_MISS_CHAR) THEN
      Okc_Api.set_message('OKC', G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Period Name');
      RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   -- Submit Concurrent Program Request for interest calculation

   FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
   x_request_id := FND_REQUEST.SUBMIT_REQUEST
         (application    => 'OKL',
          program        => 'PERIOD_REVERSAL',
          description    => 'Period Reversal',
          argument1      =>  p_period);

   IF x_request_id = 0 THEN
       Okc_Api.set_message(p_app_name => 'OFA',
            p_msg_name => 'FA_DEPRN_TAX_ERROR',
            p_token1   => 'REQUEST_ID',
            p_token1_value => x_request_id);
       RAISE okl_api.g_exception_error;

   END IF;

   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END SUBMIT_PERIOD_REVERSAL;


END OKL_REVERSAL_PVT;

/
