--------------------------------------------------------
--  DDL for Package Body AR_TRANSACTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRANSACTION_GRP" AS
/* $Header: ARXGTRXB.pls 120.5 2005/09/07 19:55:31 mraymond noship $ */

pg_debug      CONSTANT VARCHAR2(1)  := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'AR_TRANSACTION_GRP';
G_MODULE_NAME CONSTANT VARCHAR2(30) := 'AR.PLSQL.AR_TRANSACTION_GRP' ;

--Private procedures

/*===========================================================================+
 | PROCEDURE                                                                 |
 |      trx_debug                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Wrapper procedure so that it becomes easy to convert to logging       |
 |     infrastructure later if needed                                        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |       None                                                                |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |   IN:                                                                     |
 |     p_message_name                                                        |
 |   OUT:                                                                    |
 |     None                                                                  |
 |   IN/ OUT:                                                                |
 |     None                                                                  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/
PROCEDURE trx_debug( p_message_name IN VARCHAR2) IS

  BEGIN
    arp_util.debug(p_message_name);
  END trx_debug;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |      fetch_trx_type                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     Fetches a record from ra_cust_trx_type for a customer_trx_id          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |       None                                                                |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |   IN:                                                                     |
 |    p_customer_trx_id                                                      |
 |   OUT:                                                                    |
 |     p_trx_type_rec                                                        |
 |   IN/ OUT:                                                                |
 |     None
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_trx_type( p_trx_type_rec     OUT NOCOPY ra_cust_trx_types%rowtype,
                          p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%type,
                          x_return_status    OUT NOCOPY VARCHAR2
						)
IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SELECT  trxtype.type,
            trxtype.name,
            trxtype.allow_overapplication_flag ,
			trxtype.natural_application_only_flag,
			trxtype.creation_sign
       INTO p_trx_type_rec.type,
    	    p_trx_type_rec.name,
            p_trx_type_rec.allow_overapplication_flag,
            p_trx_type_rec.natural_application_only_flag,
            p_trx_type_rec.creation_sign
    FROM   ra_cust_trx_types trxtype, ra_customer_trx header
    WHERE  header.customer_trx_id = p_customer_trx_id
      AND  trxtype.cust_trx_type_id = header.cust_trx_type_id;

    EXCEPTION
      WHEN  OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF pg_debug = 'Y' THEN
          trx_debug ('Exception: ar_transaction_grp.fetch_trx_type' ||sqlerrm);
        END IF;
  END fetch_trx_type;


--Public procedures
/*===========================================================================+
 | PROCEDURE                                                                 |
 |      Complete_Transaction                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Completes the transaction after the following checks                 |
 |           1. Validate Tax enforcement                                     |
 |           2. Validate if transaction can be completed                     |
 |           3. Perform document sequence number handling                    |
 |           4. If all fine then update ra_customer_trx with complete_flag =Y|
 |              and call to maintain the payment schedules                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |       arp_ct_pkg.lock_fetch_p                                             |
 |       arp_trx_complete_chk.do_completion_checking                         |
 |       FND_SEQNUM.GET_SEQ_VAL                                              |
 |       arp_ct_pkg.update_p                                                 |
 |       ARP_PROCESS_HEADER_POST_COMMIT.post_commit                          |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |   IN:                                                                     |
 |     p_api_version                                                         |
 |     p_init_msg_list                                                       |
 |     p_commit                                                              |
 |     p_validation_level	                                                 |
 |     p_customer_trx_id                                                     |
 |   OUT:                                                                    |
 |     x_return_status                                                       |
 |     x_msg_count                                                           |
 |     x_mssg_data                                                           |
 |   IN/ OUT:                                                                |
 |     None
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE COMPLETE_TRANSACTION(
      p_api_version           IN      	  NUMBER,
      p_init_msg_list         IN      	  VARCHAR2 := NULL,
      p_commit                IN      	  VARCHAR2 := NULL,
      p_validation_level	  IN          NUMBER   := NULL,
      p_customer_trx_id       IN          ra_customer_trx.customer_trx_id%type,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2) IS

      l_api_name              CONSTANT  VARCHAR2(30) := 'COMPLETE_TRANSACTION';
      l_api_version           CONSTANT NUMBER        := 1.0;

      l_trx_rec               ra_customer_trx%rowtype;
      l_trx_type_rec          ra_cust_trx_types%rowtype;
      l_doc_sequence_id       ra_customer_trx.doc_sequence_id%TYPE;
      l_doc_sequence_value    ra_customer_trx.doc_sequence_value%TYPE;
      l_line_number           NUMBER;
      l_gl_tax_code           VARCHAR2(50);
      l_validation_status     BOOLEAN;
      l_error_count           NUMBER;
      l_status                NUMBER;
	  l_copy_doc_num_flag     VARCHAR2(1);
	  l_unique_seq_number     VARCHAR2(255);
	  l_so_source_code        VARCHAR2(255);
	  l_init_msg_list         VARCHAR2(1);
	  l_commit                VARCHAR2(1);
	  l_validation_level      NUMBER;

   BEGIN

     /*-------------------------------------------+
	  | Initialize local variables                |
      +-------------------------------------------*/
      IF p_commit = NULL THEN
        l_commit := FND_API.G_FALSE;
      ELSE
        l_commit := p_commit;
      END IF;

      IF p_init_msg_list = NULL THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
        l_init_msg_list := p_init_msg_list;
      END IF;

      IF p_validation_level = NULL THEN
        l_validation_level := FND_API.G_VALID_LEVEL_FULL;
      ELSE
        l_validation_level := p_validation_level;
      END IF;

	  l_unique_seq_number :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');
	  l_so_source_code    :=  oe_profile.value('SO_SOURCE_CODE');

      --------------------------------------------------------------
      IF pg_debug = 'Y' THEN
           trx_debug ('AR_TRANSACTION_GRP.COMPLETE_TRANSACTION(+)');
      END IF;

      SAVEPOINT Complete_Transaction;
     /*--------------------------------------------------+
      |   Standard call to check for call compatibility  |
      +--------------------------------------------------*/

      IF NOT FND_API.Compatible_API_Call(
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*--------------------------------------------------------------+
      |   Initialize message list if l_init_msg_list is set to TRUE  |
      +--------------------------------------------------------------*/

      IF FND_API.to_Boolean( l_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

     /*-----------------------------------------+
      |   Initialize return status to SUCCESS   |
      +-----------------------------------------*/
      x_return_status := FND_API.G_RET_STS_SUCCESS;


     /*-----------------------------------------------------+
      | Lock and fetch the header record for customer trx id |
      +-----------------------------------------------------*/
      IF pg_debug = 'Y'  THEN
        trx_debug ('Calling ar_ct_pkg.lock_fetch_p(+) ');
      END IF;

      arp_ct_pkg.lock_fetch_p (l_trx_rec,
                               p_customer_trx_id);

       IF pg_debug = 'Y'  THEN
         trx_debug ('ar_ct_pkg.lock_fetch_p(-) ');
      END IF;

     /*----------------------------------------------+
      | Get the transaction type for trx type id     |
      +----------------------------------------------*/
      fetch_trx_type ( l_trx_type_rec,
                       p_customer_trx_id,
                       x_return_status
                     );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
           ROLLBACK to Complete_Transaction;
           return;
      END IF;

      /*------------------------------+
      |          Tax Handling         |
      +-------------------------------*/

      /* Enforce natural account feature is obsolete for R12
         and the logic behind it is now supported internally
         within the etax product.  The local code for it here
         has been removed */

      /*-----------------------------------------+
      |Validate if transaction can be completed  |
      +------------------------------------------*/
      IF pg_debug = 'Y'  THEN
         trx_debug ('Calling arp_trx_complete_chk.do_completion_checking(+) ');
      END IF;
      arp_trx_complete_chk.do_completion_checking(p_customer_trx_id,
                                            	  l_so_source_code,
                                                  arp_global.sysparam.ta_installed_flag,
                                                  l_error_count);

      IF ( l_error_count > 0 ) THEN
        ROLLBACK to Complete_Transaction;
   	    x_return_status := FND_API.G_RET_STS_ERROR ;
  	    FND_MESSAGE.Set_Name('AR', 'AR_TW_CANT_COMPLETE');
        FND_MSG_PUB.Add;
     	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count     	,
        		                   p_data  => x_msg_data
                                  );
        return;
      END IF;

      IF pg_debug = 'Y'  THEN
         trx_debug ('arp_trx_complete_chk.do_completion_checking(-) ');
         trx_debug ('Calling fnd_seqnum.get_seq_val(+) ');
      END IF;
      /*-----------------------------------------------------------------------------+
      | Document sequencing changes: assign document number here only if Document    |
	  | Number Generation Level profile is set to 'When the Transaction is completed'|
      +-------------------------------------------------------------------------------*/
      IF (l_unique_seq_number IN ('A','P') AND l_trx_rec.doc_sequence_value IS NULL) THEN
         l_status := FND_SEQNUM.GET_SEQ_VAL(222,
                                            l_trx_type_rec.name,
                                            arp_global.sysparam.set_of_books_id,
                                            'M',
                                            l_trx_rec.trx_date,
                                            l_doc_sequence_value,
                                            l_doc_sequence_id);

         IF l_doc_sequence_value IS NOT NULL THEN
           l_trx_rec.doc_sequence_id    := l_doc_sequence_id;
           l_trx_rec.doc_sequence_value := l_doc_sequence_value;
         ELSIF l_unique_seq_number = 'A' THEN
           ROLLBACK to Complete_Transaction;
    	   x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MESSAGE.Set_Name('FND', 'UNIQUE-ALWAYS USED');
           FND_MSG_PUB.Add;
           FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                      p_data  => x_msg_data
                                     );
           return;
        END IF;
     END IF;
     IF pg_debug = 'Y'  THEN
         trx_debug ('fnd_seqnum.get_seq_val(-) ');
      END IF;

      /*-----------------------------------------------------------------------------------+
      | Copy document number to transaction number if "copy document to transaction number"|
	  | flag is checked in batch source                                                    |
      +------------------------------------------------------------------------------------*/

      SELECT copy_doc_number_flag
	    INTO l_copy_doc_num_flag
      FROM   RA_BATCH_SOURCES batch, RA_CUSTOMER_TRX header
	  WHERE  batch.batch_source_id = header.batch_source_id
    	AND  header.customer_trx_id = p_customer_trx_id;

      IF NVL (l_copy_doc_num_flag, 'N')  = 'Y'
	     AND l_trx_rec.doc_sequence_value is not null
		 AND l_trx_rec.old_trx_number is null THEN
            l_trx_rec.old_trx_number := l_trx_rec.trx_number;
            l_trx_rec.trx_number := l_doc_sequence_value;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_trx_rec.complete_flag := 'Y';
         arp_ct_pkg.update_p(l_trx_rec,p_customer_trx_id);
         IF pg_debug = 'Y'  THEN
            trx_debug ('Calling ARP_PROCESS_HEADER_POST_COMMIT.post_commit(+)');
         END IF;
         ARP_PROCESS_HEADER_POST_COMMIT.post_commit (
                   p_form_name                  => 'AR_TRANSACTION_GRP',
                   p_form_version               => 1,
                   p_customer_trx_id            => p_customer_trx_id,
                   p_previous_customer_trx_id   => l_trx_rec.previous_customer_trx_id,
                   p_complete_flag              => 'Y',
                   p_trx_open_receivables_flag  => l_trx_type_rec.accounting_affect_flag,
                   p_prev_open_receivables_flag => null,
                   p_creation_sign              => l_trx_type_rec.creation_sign,
                   p_allow_overapplication_flag => l_trx_type_rec.allow_overapplication_flag,
                   p_natural_application_flag   => l_trx_type_rec.natural_application_only_flag,
                   p_cash_receipt_id            => null,
                   p_error_mode                 => null
                   );
          IF pg_debug = 'Y' THEN
            trx_debug ('ARP_PROCESS_HEADER_POST_COMMIT.post_commit(-)');
          END IF;
       END IF;

      /*-----------------------------------+
	  | Standard check of l_commit.          |
      +------------------------------------*/
      IF FND_API.To_Boolean( l_commit ) THEN
        COMMIT;
      END IF;

      /*-----------------------------------------------------------------------+
	  | Standard call to get message count and if count is 1, get message info |
      +------------------------------------------------------------------------*/
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count     	,
        		                 p_data  => x_msg_data
                                 );


      IF pg_debug = 'Y' THEN
        trx_debug ('AR_TRANSACTION_GRP.COMPLETE_TRANSACTION(-)');
      END IF;

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	    	ROLLBACK TO Complete_Transaction;
    		x_return_status := FND_API.G_RET_STS_ERROR ;
	    	FND_MSG_PUB.Count_And_Get (
			                           p_count => x_msg_count     	,
        		                       p_data  => x_msg_data
                                   	  );
    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    	ROLLBACK TO Complete_Transaction;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    	FND_MSG_PUB.Count_And_Get (
			                           p_count => x_msg_count     	,
        		                       p_data  => x_msg_data
                                   	  );
    	WHEN OTHERS THEN
	    	ROLLBACK TO Complete_Transaction;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	    	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,
     	    	     	    			l_api_name
										);
    		END IF;

	    	FND_MSG_PUB.Count_And_Get (
			                           p_count => x_msg_count,
        		                       p_data  => x_msg_data
                                   	  );

  END COMPLETE_TRANSACTION;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |      Incomplete_Transaction                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Incompletes the transaction after the following checks               |
 |           1. It should not have been posted to GL                         |
 |           2. There should not exist any activity against it               |
 |           3. There should not be a chargeback for the transaction         |
 |           4. There should not be debit memo reversal on the transaction   |
 |           4. If none of above then update ra_customer_trx with            |
 |              complete_flag =N and call to maintain the payment schedules  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |       arp_ct_pkg.lock_fetch_p                                             |
 |       arpt_sql_func_util.get_posted_flag                                  |
 |       arpt_sql_func_util.get_activity_flag
 |       arp_ct_pkg.update_p                                                 |
 |       ARP_PROCESS_HEADER_POST_COMMIT.post_commit                          |
 |                                                                           |
 | ARGUMENTS  :                                                              |
 |   IN:                                                                     |
 |     p_api_version                                                         |
 |     p_init_msg_list                                                       |
 |     p_commit                                                              |
 |     p_validation_level	                                                 |
 |     p_customer_trx_id                                                     |
 |   OUT:                                                                    |
 |     x_return_status                                                       |
 |     x_msg_count                                                           |
 |     x_mssg_data                                                           |
 |   IN/ OUT:                                                                |
 |     None
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE INCOMPLETE_TRANSACTION(
      p_api_version           IN      	  NUMBER,
      p_init_msg_list         IN      	  VARCHAR2 := NULL,
      p_commit                IN      	  VARCHAR2 := NULL,
      p_validation_level	  IN          NUMBER   := NULL,
      p_customer_trx_id       IN          ra_customer_trx.customer_trx_id%type,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_count             OUT NOCOPY  NUMBER,
      x_msg_data              OUT NOCOPY  VARCHAR2) IS

      l_api_name              CONSTANT  VARCHAR2(30) := 'INCOMPLETE_TRANSACTION';
      l_api_version           CONSTANT NUMBER        := 1.0;

      l_trx_rec               ra_customer_trx%rowtype;
      l_trx_type_rec          ra_cust_trx_types%rowtype;
      l_posted_flag 		  VARCHAR2(1);
      l_activity_flag		  VARCHAR2(1);

 	  l_init_msg_list         VARCHAR2(1);
	  l_commit                VARCHAR2(1);
	  l_validation_level      NUMBER;

   BEGIN

     /*-------------------------------------------+
	  | Initialize local variables                |
      +-------------------------------------------*/
      IF p_commit = NULL THEN
        l_commit := FND_API.G_FALSE;
      ELSE
        l_commit := p_commit;
      END IF;

      IF p_init_msg_list = NULL THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
        l_init_msg_list := p_init_msg_list;
      END IF;

      IF p_validation_level = NULL THEN
        l_validation_level := FND_API.G_VALID_LEVEL_FULL;
      ELSE
        l_validation_level := p_validation_level;
      END IF;

      IF pg_debug = 'Y' THEN
       trx_debug ('AR_TRANSACTION_GRP.INCOMPLETE_TRANSACTION(+)' );
      END IF;

      SAVEPOINT Incomplete_Transaction;
     /*--------------------------------------------------+
      |   Standard call to check for call compatibility  |
      +--------------------------------------------------*/

      IF NOT FND_API.Compatible_API_Call(
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*--------------------------------------------------------------+
      |   Initialize message list if l_init_msg_list is set to TRUE  |
      +--------------------------------------------------------------*/

      IF FND_API.to_Boolean( l_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

     /*-----------------------------------------+
      |   Initialize return status to SUCCESS   |
      +-----------------------------------------*/
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*-----------------------------------------------------+
      | Lock and fetch the header record for customer trx id |
      +-----------------------------------------------------*/
      IF pg_debug = 'Y'  THEN
         trx_debug ('Calling arp_ct_pkg.lock_fetch_p(+) ');
      END IF;

      arp_ct_pkg.lock_fetch_p (l_trx_rec,
                           p_customer_trx_id);

      IF pg_debug = 'Y'  THEN
         trx_debug ('arp_ct_pkg.lock_fetch_p(-) ');
      END IF;

     /*----------------------------------------------+
      | Get the transaction type for trx type id     |
      +----------------------------------------------*/
      fetch_trx_type ( l_trx_type_rec,
                       p_customer_trx_id,
                       x_return_status
                     );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
           ROLLBACK to Incomplete_Transaction;
           return;
      END IF;

     /*--------------------------------------------------------------+
      | Check for activities, etc on invoice before incompleting     |
      +--------------------------------------------------------------*/
      IF l_trx_rec.complete_flag ='Y' THEN
        IF pg_debug = 'Y' THEN
          trx_debug ('Calling arpt_sql_funct_util.get_posted_flag(+)');
        END IF;

        l_posted_flag := arpt_sql_func_util.get_posted_flag(
                                         p_customer_trx_id,
                                         l_trx_type_rec.post_to_gl,
                                         l_trx_rec.complete_flag );
        IF (l_posted_flag = 'Y') THEN
          ROLLBACK to Incomplete_Transaction;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.Set_Name('AR', 'AR_TAPI_CANT_UPDATE_POSTED');
          FND_MSG_PUB.Add;
       	  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
           		                     p_data  => x_msg_data
                                    );
		  return;
        END IF;
        IF pg_debug = 'Y' THEN
           trx_debug ('arpt_sql_funct_util.get_posted_flag(-)');
           trx_debug ('Calling arpt_sql_funct_util.get_activity_flag(+)');
        END IF;

        l_activity_flag := arpt_sql_func_util.get_activity_flag(
                                         p_customer_trx_id,
                                         l_trx_type_rec.accounting_affect_flag,
                                         l_trx_rec.complete_flag,
                                         l_trx_type_rec.type,
                                         l_trx_rec.initial_customer_trx_id,
                                         l_trx_rec.previous_customer_trx_id
                                         );
        IF (l_activity_flag = 'Y') THEN
          ROLLBACK to Incomplete_Transaction;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.Set_Name('AR', 'AR_TW_NO_RECREATE_PS');
          FND_MSG_PUB.Add;
       	  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
           		                     p_data  => x_msg_data
                                    );
          return;
        ELSIF (l_activity_flag = 'G') THEN
          ROLLBACK to Incomplete_Transaction;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.Set_Name('AR', 'AR_TAPI_CANT_UPDATE_POSTED');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                     p_data  => x_msg_data
                                    );
		  return;
        END IF;
        IF pg_debug = 'Y' THEN
           trx_debug ('arpt_sql_funct_util.get_activity_flag(-)');
        END IF;

        IF ( l_trx_rec.created_from  IN ('ARXREV', 'REL9_ARXREV') ) THEN
          ROLLBACK to Incomplete_Transaction;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.Set_Name('AR', 'AR_TAPI_CANT_UPDATE_DM_REV');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                     p_data  => x_msg_data
                                    );
          return;
        END IF;

        IF ( l_trx_type_rec.type = 'CB' )  THEN
          ROLLBACK to Incomplete_Transaction;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.Set_Name('AR', 'AR_TAPI_CANT_UPDATE_CB');
          FND_MSG_PUB.Add;
          FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                     p_data  => x_msg_data
                                    );
		  return;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_trx_rec.complete_flag := 'N';
              arp_ct_pkg.update_p(l_trx_rec,p_customer_trx_id);
              IF pg_debug = 'Y' THEN
                trx_debug ('Calling ARP_PROCESS_HEADER_POST_COMMIT.post_commit(+)');
              END IF;
              ARP_PROCESS_HEADER_POST_COMMIT.post_commit (
                   p_form_name                  => 'AR_TRANSACTION_GRP',
                   p_form_version               => 1,
                   p_customer_trx_id            => p_customer_trx_id,
                   p_previous_customer_trx_id   => l_trx_rec.previous_customer_trx_id,
                   p_complete_flag              => 'N',
                   p_trx_open_receivables_flag  => l_trx_type_rec.accounting_affect_flag,
                   p_prev_open_receivables_flag => null,
                   p_creation_sign              => l_trx_type_rec.creation_sign,
                   p_allow_overapplication_flag => l_trx_type_rec.allow_overapplication_flag,
                   p_natural_application_flag   => l_trx_type_rec.natural_application_only_flag,
                   p_cash_receipt_id            => null,
                   p_error_mode                 => null
                   );
              IF pg_debug = 'Y' THEN
                trx_debug ('ARP_PROCESS_HEADER_POST_COMMIT.post_commit(-)' );
              END IF;
        END IF;
      END IF; --complete_flag ='Y'

      /*-----------------------------------+
	  | Standard check of l_commit.          |
      +------------------------------------*/
      IF FND_API.To_Boolean( l_commit ) THEN
        COMMIT;
      END IF;

      /*-----------------------------------------------------------------------+
	  | Standard call to get message count and if count is 1, get message info |
      +------------------------------------------------------------------------*/
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                 p_data  => x_msg_data
                                 );


      IF pg_debug = 'Y' THEN
        trx_debug ('AR_TRANSACTION_GRP.INCOMPLETE_TRANSACTION(-)');
      END IF;

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
	    	ROLLBACK TO Incomplete_Transaction;
    		x_return_status := FND_API.G_RET_STS_ERROR ;
	    	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                       p_data  => x_msg_data
                                   	  );
    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    	ROLLBACK TO Incomplete_Transaction;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                       p_data  => x_msg_data
                                   	  );
    	WHEN OTHERS THEN
	    	ROLLBACK TO Incomplete_Transaction;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     	    	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,
     	    	     	    			l_api_name
										);
    		END IF;

	    	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
        		                       p_data  => x_msg_data
                                   	  );

  END INCOMPLETE_TRANSACTION;

END AR_TRANSACTION_GRP;

/
