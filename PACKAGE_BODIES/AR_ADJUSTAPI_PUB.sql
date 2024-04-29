--------------------------------------------------------
--  DDL for Package Body AR_ADJUSTAPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ADJUSTAPI_PUB" AS
/* $Header: ARTAADJB.pls 115.3 2003/10/10 19:43:15 mraymond noship $ */
G_PKG_NAME	CONSTANT VARCHAR2(30)	:='AR_ADJUSTAPI_PUB';
G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Adj_Insert                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the routine that validates the inputs during creation|
 |              of adjustments                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |     ar_adjvalidate_pub.Validate_Type                                      |
 |     ar_adjvalidate_pub.Validate_Payschd                                   |
 |     ar_adjvalidate_pub.Validate_amount                                    |
 |     ar_adjvalidate_pub.Validate_Rcvtrxccid                                |
 |     ar_adjvalidate_pub.Validate_dates                                     |
 |     ar_adjvalidate_pub.Validate_Reason_code                               |
 |     ar_adjvalidate_pub.Validate_doc_seq                                   |
 |     ar_adjvalidate_pub.Validate_Associated_Receipt                        |
 |     ar_adjvalidate_pub.Validate_Ussgl_code                                |
 |     ar_adjvalidate_pub.Validate_Desc_Flexfield                            |
 |     ar_adjvalidate_pub.Validate_Created_From                              |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                   p_Validation_status                                     |
 |                   p_adj_rec                                               |
 |                   p_ps_rec                                                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JUN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/


PROCEDURE Validate_Adj_Insert (
		p_adj_rec		IN OUT	NOCOPY ar_adjustments%rowtype,
		p_validation_status	IN OUT	NOCOPY varchar2
	        ) IS

l_return_status		varchar2(1);
l_ps_rec		ar_payment_schedules%rowtype;
BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Insert()+' , G_MSG_HIGH);
       END IF;

       /*-------------------------------------------------+
       |   1. Validate type                               |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Type (
                                 p_adj_rec,
                                 p_validation_status
                                 ) ;
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   2. Validate payment_schedule_id  and           |
       |      customer_trx_line_id                        |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Payschd (
                                 p_adj_rec,
                                 l_ps_rec,
                                 p_validation_status
                                );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   3. Validate adjustment apply_date and GL date  |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.Validate_dates (
		               p_adj_rec.apply_date,
                               p_adj_rec.gl_date,
                               l_ps_rec,
                               p_validation_status
                               );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       ELSE
           p_adj_rec.apply_date := trunc(p_adj_rec.apply_date);
           p_adj_rec.gl_date := trunc(p_adj_rec.gl_date);
       END IF;

       /*-------------------------------------------------+
       |   4. Validate amount and status                  |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.Validate_amount (
		                 p_adj_rec,
		                 l_ps_rec,
		                 p_validation_status
                                );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   5. Validate receivables_trx_id and code        |
       |      combination                                 |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.Validate_Rcvtrxccid (
	                        p_adj_rec	,
                                p_validation_status
                               );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   6. Validate  doc_sequence_value                |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_doc_seq (
		             p_adj_rec,
		             p_validation_status
	                     ) ;
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   7. Validate  reason_code                      |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Reason_code (
		               p_adj_rec,
		               p_validation_status
                              );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   8. Validate  associated cash_receipt_id       |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Associated_Receipt (
		               p_adj_rec,
                               p_validation_status
                              );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   9. Validate  ussgl transaction code           |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Ussgl_code (
		               p_adj_rec,
		               p_validation_status
	                      );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   10. Validate  descriptive flex                 |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Desc_Flexfield(
                               p_adj_rec,
		               p_validation_status
                              );
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   11. Validate  created form                     |
       +-------------------------------------------------*/
       ar_adjvalidate_pub.Validate_Created_From (
		               p_adj_rec,
		               p_validation_status
                              );

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Insert()-' , G_MSG_HIGH);
       END IF;
       RETURN;

EXCEPTION

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Adj_Insert() ', G_MSG_UERROR);
        END IF;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Adj_Insert');
	p_validation_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;


END Validate_Adj_Insert;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Set_Remaining_Attributes                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine sets data of remaining attributes which are not |
 |              not populated by the validation process. It also resets the  |
 |              the columns in the adjustment record  that should not be     |
 |              populated during creation of adjustments                     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                   p_Validation_status                                     |
 |          IN/ OUT:                                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JUN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Set_Remaining_Attributes (
		p_adj_rec	IN OUT 	NOCOPY ar_adjustments%rowtype,
                p_return_status IN OUT	NOCOPY varchar2
	        ) IS

BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Set_Remaining_Attributes()+' , G_MSG_HIGH);
       END IF;

       /*-----------------------------------------------+
       |  Set the status to success                     |
       +-----------------------------------------------*/
       p_return_status := FND_API.G_RET_STS_SUCCESS ;

       /*-----------------------------------------------+
       |  Set Adjustment Type and Postable attributes   |
       +-----------------------------------------------*/

       p_adj_rec.adjustment_type := 'M' ;
       p_adj_rec.postable := 'Y' ;

       /*--------------------------------------------------------+
       |  Reset the distribution_set_id, chargeback_customer_id  |
       |  and subsequent customer trx id                         |
       +--------------------------------------------------------*/
       p_adj_rec.distribution_set_id := NULL;
       p_adj_rec.chargeback_customer_trx_id := NULL ;
       p_adj_rec.subsequent_trx_id := NULL ;


       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Set_Remaining_Attributes()-' , G_MSG_HIGH);
       END IF;

       RETURN ;

EXCEPTION

   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Set_Remaining_Attributes() ', G_MSG_UERROR);
        END IF;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Set_Remaining_Attributes');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Set_Remaining_Attributes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Adj_Modify                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the validation routine for Modification of Approvals |
 |              						             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_old_adj_rec                                           |
 |                                                                           |
 |              OUT:                                                         |
 |                   p_Validation_status                                     |
 |          IN/ OUT:                                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Adj_modify (
		p_adj_rec	IN OUT 	NOCOPY ar_adjustments%rowtype,
		p_old_adj_rec   IN	ar_adjustments%rowtype,
		p_validation_status IN OUT NOCOPY varchar2
	        ) IS

l_ps_rec	ar_payment_schedules%rowtype;
l_approved_flag	varchar2(1);
l_temp_adj_rec  ar_adjustments%rowtype;

BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_modify()+' , G_MSG_HIGH);
       END IF;

       /*----------------------------------------------+
       | Validate Old Adjustment status. Cannot modify |
       | if status is 'A'                              |
       +----------------------------------------------*/

       IF ( p_old_adj_rec.status = 'A' )
       THEN
            ar_adjvalidate_pub.aapi_message (
                            p_application_name => 'AR',
                            p_message_name => 'AR_AAPI_NO_CHANGE_OR_REVERSE',
                            p_token1_name => 'STATUS',
                            p_token1_value => p_old_adj_rec.status
                          );

            p_validation_status := FND_API.G_RET_STS_ERROR;
            RETURN;
       END IF;

       /*----------------------------------------------------+
       |  Check new status. It could be NULL, 'A','R','W','M'|
       +----------------------------------------------------*/

       IF ( (p_adj_rec.status IS NOT NULL) AND
            (p_adj_rec.status NOT IN ('A', 'R', 'W', 'M')) )
       THEN
          ar_adjvalidate_pub.aapi_message (
                         p_application_name => 'AR',
                         p_message_name => 'AR_AAPI_INVALID_CHANGE_STATUS',
                         p_token1_name => 'STATUS',
                         p_token1_value => p_adj_rec.status
                       );

          p_validation_status := FND_API.G_RET_STS_ERROR;
          RETURN;
       END IF;

       /*---------------------------------------------------+
       |   2. Validate approval limits if new status is 'A' |
       +---------------------------------------------------*/

       /*----------------------------------+
       |  a) Get the invoice currency code |
       +----------------------------------*/

       BEGIN

         SELECT	*
           INTO	l_ps_rec
           FROM	ar_payment_schedules
      	  WHERE	payment_schedule_id = p_old_adj_rec.payment_schedule_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

            /*-----------------------------------------------+
      	    |  Payment schedule Id does not exist            |
      	    |  Set the message and status accordingly        |
      	    +-----------------------------------------------*/
 	    ar_adjvalidate_pub.aapi_message(
                p_application_name =>'AR',
                p_message_name => 'AR_AAPI_INVALID_PAYMENT_SCHEDULE',
                p_token1_name => 'PAYMENT_SCHEDULE_ID',
                p_token1_value => to_char(p_old_adj_rec.payment_schedule_id)
                ) ;
            p_validation_status := FND_API.G_RET_STS_ERROR;
            RETURN ;
       END ;

       IF ( p_adj_rec.status = 'A' )
       THEN

         /*-----------------------------------+
      	 |  Get the approval limits and check |
      	 +-----------------------------------*/

         ar_adjvalidate_pub.Within_approval_limits(
                p_old_adj_rec.amount,
                l_ps_rec.invoice_currency_code,
                l_approved_flag,
	  	p_validation_status
                         ) ;

         IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
         THEN
             RETURN;
         END IF;

         IF ( l_approved_flag <> FND_API.G_TRUE )
         THEN
            ar_adjvalidate_pub.aapi_message
                                ( p_application_name => 'AR',
                                  p_message_name => 'AR_VAL_AMT_APPROVAL_LIMIT'
                                );
             p_validation_status := FND_API.G_RET_STS_ERROR;
             RETURN ;
         END IF;

         /*-------------------------------------------------+
         | Check over application                           |
         +-------------------------------------------------*/

         -- This is done by the entity handler

       END IF;

       /*-------------------------------------------------+
       |   3. Validate GL date                            |
       +-------------------------------------------------*/

       IF ( p_adj_rec.gl_date IS NOT NULL )
       THEN
          ar_adjvalidate_pub.Validate_dates (
	                     p_old_adj_rec.apply_date,
                             p_adj_rec.gl_date,
                             l_ps_rec,
		             p_validation_status
	                    ) ;
          IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
          THEN
             RETURN;
          END IF;
       END IF;

       p_adj_rec.gl_date := trunc(p_adj_rec.gl_date);

       /*---------------------------------------------------+
       |   4. Copy all other attributes into p_adj_rec      |
       +---------------------------------------------------*/

       l_temp_adj_rec.comments := p_adj_rec.comments ;
       l_temp_adj_rec.status := p_adj_rec.status ;
       l_temp_adj_rec.gl_date := p_adj_rec.gl_date ;

       p_adj_rec := p_old_adj_rec ;

       IF ( l_temp_adj_rec.comments IS NOT NULL )
       THEN
           p_adj_rec.comments := l_temp_adj_rec.comments;
       END IF;

       IF ( l_temp_adj_rec.status IS NOT NULL )
       THEN
          p_adj_rec.status := l_temp_adj_rec.status ;
       END IF ;

       IF ( l_temp_adj_rec.gl_date IS NOT NULL )
       THEN
          p_adj_rec.gl_date := l_temp_adj_rec.gl_date ;
       END IF ;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_modify()-' , G_MSG_HIGH);
       END IF;

EXCEPTION

     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Adj_Modify() ', G_MSG_UERROR);
        END IF;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Adj_Modify');
	p_validation_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;


END Validate_Adj_Modify;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Adj_Reverse                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the validation routine for Reversal of Approvals     |
 |              						             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_old_adj_rec                                           |
 |                                                                           |
 |              OUT:                                                         |
 |                   p_Validation_status                                     |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                   p_reversal_gl_date                                      |
 |                   p_reversal_date                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Adj_Reverse  (
		p_old_adj_rec   	IN	ar_adjustments%rowtype,
                p_reversal_gl_date	IN OUT	NOCOPY date,
                p_reversal_date		IN OUT  NOCOPY date,
		p_validation_status	IN OUT	NOCOPY varchar2
	        ) IS

l_ps_rec	ar_payment_schedules%rowtype;

BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Reverse()+' , G_MSG_HIGH);
       END IF;

       /*----------------------------------------------+
       | Validate Old Adjustment status. Cannot reverse|
       | if status is 'A' or 'R'                       |
       +----------------------------------------------*/

       IF ( p_old_adj_rec.status <> 'A' )
       THEN
            ar_adjvalidate_pub.aapi_message (
                            p_application_name => 'AR',
                            p_message_name => 'AR_AAPI_NO_CHANGE_OR_REVERSE',
                            p_token1_name => 'STATUS',
                            p_token1_value => p_old_adj_rec.status
                          );

            p_validation_status := FND_API.G_RET_STS_ERROR;
            RETURN;
       END IF;


       /*-------------------------------------------------+
       | Validate reversal dates                          |
       +-------------------------------------------------*/


       IF ( p_reversal_gl_date IS  NULL )
       THEN
           p_reversal_gl_date := p_old_adj_rec.gl_date;
       END IF;

       IF ( p_reversal_date IS  NULL )
       THEN
           p_reversal_date := p_old_adj_rec.apply_date;
       END IF;

       /*-----------------------------------+
       |  Get the Payment schedule details  |
       +-----------------------------------*/

       BEGIN

         SELECT	*
           INTO	l_ps_rec
           FROM	ar_payment_schedules
      	  WHERE	payment_schedule_id = p_old_adj_rec.payment_schedule_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

            /*-----------------------------------------------+
      	    |  Payment schedule Id does not exist            |
      	    |  Set the message and status accordingly        |
      	    +-----------------------------------------------*/
 	    ar_adjvalidate_pub.aapi_message(
                   p_application_name =>'AR',
                   p_message_name => 'AR_AAPI_INVALID_PAYMENT_SCHEDULE',
                   p_token1_name => 'PAYMENT_SCHEDULE_ID',
                   p_token1_value => to_char(p_old_adj_rec.payment_schedule_id)
                   ) ;
            p_validation_status := FND_API.G_RET_STS_ERROR;
            RETURN ;
       END ;

       ar_adjvalidate_pub.Validate_dates (
	                     p_reversal_date,
                             p_reversal_gl_date,
                             l_ps_rec,
		             p_validation_status
	                    ) ;
       IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN;
       END IF;

       p_reversal_gl_date := trunc(p_reversal_gl_date);
       p_reversal_date := trunc(p_reversal_date);

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Reverse()-' , G_MSG_HIGH);
       END IF;

EXCEPTION

     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Adj_Reverse() ', G_MSG_UERROR);
        END IF;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Adj_Reverse');
	p_validation_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;


END Validate_Adj_Reverse;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Adj_Approve                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the validation routine for Approval                  |
 |              						             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_old_adj_rec                                           |
 |                                                                           |
 |              OUT:                                                         |
 |                   p_Validation_status                                     |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Adj_Approve  (
		p_adj_rec	IN OUT 	NOCOPY ar_adjustments%rowtype,
		p_old_adj_rec   IN	ar_adjustments%rowtype,
		p_validation_status IN OUT NOCOPY varchar2
	        ) IS

l_ps_rec	ar_payment_schedules%rowtype;
l_approved_flag	varchar2(1);
l_temp_adj_rec  ar_adjustments%rowtype;

BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Approve()+' , G_MSG_HIGH);
       END IF;

      /*-----------------------------------------------+
       | Validate Old Adjustment status. Cannot approve|
       | if status is 'A' or 'R'                       |
       +----------------------------------------------*/

       IF ( p_old_adj_rec.status = 'A' )
       THEN
          ar_adjvalidate_pub.aapi_message (
                         p_application_name => 'AR',
                         p_message_name => 'AR_AAPI_NO_CHANGE_OR_REVERSE',
                         p_token1_name => 'STATUS',
                         p_token1_value => p_old_adj_rec.status
                       );
          p_validation_status := FND_API.G_RET_STS_ERROR;
          RETURN;
       END IF;

       /*----------------------------------------------------+
       |  If new status is NULL set it to 'A'                |
       +----------------------------------------------------*/

       IF (p_adj_rec.status IS NULL )
       THEN
           p_adj_rec.status := 'A' ;
       END IF;

       /*----------------------------------------------------+
       |  Check new status. It could be NULL, 'A','R','W','M'|
       +----------------------------------------------------*/

       IF ( (p_adj_rec.status IS NOT NULL) AND
            (p_adj_rec.status NOT IN ('A', 'R', 'W', 'M')) )
       THEN
          ar_adjvalidate_pub.aapi_message (
                         p_application_name => 'AR',
                         p_message_name => 'AR_AAPI_INVALID_CHANGE_STATUS',
                         p_token1_name => 'STATUS',
                         p_token1_value => p_adj_rec.status
                       );

          p_validation_status := FND_API.G_RET_STS_ERROR;
          RETURN;
       END IF;



       /*---------------------------------------------------+
       |   2. Validate approval limits if new status is 'A' |
       +---------------------------------------------------*/

       /*----------------------------------+
       |  a) Get the invoice currency code |
       +----------------------------------*/

       BEGIN

         SELECT	*
           INTO	l_ps_rec
           FROM	ar_payment_schedules
      	  WHERE	payment_schedule_id = p_old_adj_rec.payment_schedule_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

            /*-----------------------------------------------+
      	    |  Payment schedule Id does not exist            |
      	    |  Set the message and status accordingly        |
      	    +-----------------------------------------------*/
 	    ar_adjvalidate_pub.aapi_message(
                  p_application_name =>'AR',
                  p_message_name => 'AR_AAPI_INVALID_PAYMENT_SCHEDULE',
                  p_token1_name => 'PAYMENT_SCHEDULE_ID',
                  p_token1_value => to_char(p_old_adj_rec.payment_schedule_id)
                  ) ;
            p_validation_status := FND_API.G_RET_STS_ERROR;
            RETURN ;
       END ;

       IF ( p_adj_rec.status = 'A' )
       THEN

         /*-----------------------------------+
      	 |  Get the approval limits and check |
      	 +-----------------------------------*/

         ar_adjvalidate_pub.Within_approval_limits(
                  p_old_adj_rec.amount,
                  l_ps_rec.invoice_currency_code,
                  l_approved_flag,
	  	  p_validation_status
                  ) ;

         IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
         THEN
             RETURN;
         END IF;

         IF ( l_approved_flag <> FND_API.G_TRUE )
         THEN
            ar_adjvalidate_pub.aapi_message
                                ( p_application_name => 'AR',
                                  p_message_name => 'AR_VAL_AMT_APPROVAL_LIMIT'
                                );
             p_validation_status := FND_API.G_RET_STS_ERROR;
             RETURN ;
         END IF;

         /*-------------------------------------------------+
         | Check over application                           |
         +-------------------------------------------------*/

         -- This is done by the entity handler

       END IF;

       /*-------------------------------------------------+
       |   3. Validate GL date                            |
       +-------------------------------------------------*/

       IF ( p_adj_rec.gl_date IS NOT NULL )
       THEN
          ar_adjvalidate_pub.Validate_dates (
	                     p_old_adj_rec.apply_date,
                             p_adj_rec.gl_date,
                             l_ps_rec,
		             p_validation_status
	                    ) ;
          IF ( p_validation_status <> FND_API.G_RET_STS_SUCCESS )
          THEN
             RETURN;
          END IF;
       END IF;

       p_adj_rec.gl_date := trunc(p_adj_rec.gl_date);

       /*---------------------------------------------------+
       |   4. Copy all other attributes into p_adj_rec      |
       +---------------------------------------------------*/

       l_temp_adj_rec := NULL ;

       l_temp_adj_rec.comments := p_adj_rec.comments ;
       l_temp_adj_rec.status := p_adj_rec.status ;
       l_temp_adj_rec.gl_date := p_adj_rec.gl_date ;

       p_adj_rec := p_old_adj_rec ;

       IF ( l_temp_adj_rec.comments IS NOT NULL )
       THEN
           p_adj_rec.comments := l_temp_adj_rec.comments;
       END IF;

       IF ( l_temp_adj_rec.status IS NOT NULL )
       THEN
          p_adj_rec.status := l_temp_adj_rec.status ;
       END IF ;

       IF ( l_temp_adj_rec.gl_date IS NOT NULL )
       THEN
          p_adj_rec.gl_date := l_temp_adj_rec.gl_date ;
       END IF ;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Validate_Adj_Approve ()-' , G_MSG_HIGH);
       END IF;

EXCEPTION

     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Adj_Approve() ', G_MSG_UERROR);
        END IF;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Adj_Approve');
	p_validation_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;


END Validate_Adj_Approve;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Create_Adjustment                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that creates adjustment             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |     ar_adjvalidate_pub.Init_Context_Rec                                   |
 |     ar_adjvalidate_pub.Cache_Details                                      |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit                                                |
 |                   p_validation_level                                      |
 |                   p_adj_rec                                               |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                   p_msg_count					     |
 |		     p_msg_data		                                     |
 |                   p_new_adjust_number                                     |
 |                   p_new_adjust_id                                         |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JUN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Create_Adjustment (
p_api_name		IN	varchar2,
p_api_version		IN	number,
p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
p_validation_level     	IN	number := FND_API.G_VALID_LEVEL_FULL,
p_msg_count		OUT NOCOPY  	number,
p_msg_data		OUT NOCOPY	varchar2,
p_return_status		OUT NOCOPY	varchar2 ,
p_adj_rec		IN 	ar_adjustments%rowtype,
p_new_adjust_number	OUT NOCOPY	ar_adjustments.adjustment_number%type,
p_new_adjust_id		OUT NOCOPY	ar_adjustments.adjustment_id%type
) IS

  l_api_name		CONSTANT VARCHAR2(20) := 'AR_ADJUSTAPI_PUB';
  l_api_version         CONSTANT NUMBER       := 1.0;

  l_hsec		VARCHAR2(10);
  l_status		number;

  l_inp_adj_rec		ar_adjustments%rowtype;
  o_adjustment_number	ar_adjustments.adjustment_number%type;
  o_adjustment_id 	ar_adjustments.adjustment_id%type;
  l_return_status	varchar2(1);

BEGIN
        select hsecs
        into G_START_TIME
        from v$timer;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT AR_ADJUSTAPI_PUB;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR ;

            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Compatility error occurred.', G_MSG_ERROR);
            END IF;

            RETURN ;
        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;

       /*------------------------------------------------------------+
        |  Turn on AR debugging messages only if the most verbose    |
        |  log is requested. The AR messages do not provide message  |
        |  level information.                                        |
        +------------------------------------------------------------*/

        IF ( FND_MSG_PUB.Check_Msg_Level( G_MSG_LOW) )
        THEN
             arp_util.enable_debug;
        ELSE
             arp_util.disable_debug;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Insert_Adjustment()+ ', G_MSG_HIGH);
        END IF;

	/*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	/*---------------------------------------------+
        |   ========== Start of API Body ==========   |
        +---------------------------------------------*/

	/*--------------------------------------------+
        |   Copy the input adjustment record to local |
        |   variable to allow changes to it           |
        +--------------------------------------------*/
	l_inp_adj_rec := p_adj_rec ;


        /*------------------------------------------------+
        |   Initialize the profile options and cache data |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Init_Context_Rec (
                                   p_validation_level,
                                   l_return_status
                                 );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

        /*------------------------------------------------+
        |   Cache details                                 |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Cache_Details (
                              l_return_status
                            );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

	/*------------------------------------------+
        |  Validate the input details		    |
        |  Do not continue if there are errors.     |
        +------------------------------------------*/

        ar_adjustapi_pub.Validate_Adj_Insert(
                          l_inp_adj_rec,
                          l_return_status
                        );

        IF   ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN

             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Create_Adjustment: ' ||
                             'Validation error(s) occurred. Rolling back '||
			     'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END IF;

	/*-----------------------------------------------+
	| Build up remaining data for the entity handler |
        | Reset attributes which should not be populated |
        +-----------------------------------------------*/

	ar_adjustapi_pub.Set_Remaining_Attributes (
  		              	              l_inp_adj_rec,
                                              l_return_status
                                              ) ;

        IF   ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN

             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Create_Adjustment: ' ||
                             'Validation error(s) occurred. Rolling back '||
			     'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END IF;

	/*-----------------------------------------------+
	| Call the entity Handler for insert             |
	+-----------------------------------------------*/
	BEGIN
	    arp_process_adjustment.insert_adjustment (
                           	'DUMMY',
                           	'1',
                           	l_inp_adj_rec,
                           	o_adjustment_number,
			  	o_adjustment_id
                              ) ;

        EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Create_Adjustment: ' ||
                'Error in Insert Entity handler. Rolling back ' ||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;


             RETURN;

        END ;

	p_new_adjust_id := o_adjustment_id ;
        p_new_adjust_number := o_adjustment_number ;

       /*-------------------------------------------+
        |   ========== End of API Body ==========   |
        +-------------------------------------------*/

       /*---------------------------------------------------+
        |  Get message count and if 1, return message data  |
        +---------------------------------------------------*/

        FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count => p_msg_count,
                                   p_data  => p_msg_data
                                 );

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit_flag )
        THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Create_Adjustment: ' || 'committing', G_MSG_HIGH);
              END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Create_Adjustment()- ', G_MSG_HIGH);
        END IF;

        select TO_CHAR( (hsecs - G_START_TIME) / 100)
        into l_hsec
        from v$timer;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Create_Adjustment: ' || 'Elapsed Time : '||l_hsec||' seconds', G_MSG_LOW);
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(SQLCODE, G_MSG_ERROR);
                   arp_util.debug(SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO AR_ADJUSTAPI_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug(SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO AR_ADJUSTAPI_PUB ;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                      p_return_status := FND_API.G_RET_STS_ERROR ;
                      ROLLBACK TO AR_ADJUSTAPI_PUB;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Create_Adjustment: ' ||
                            'Completion validation error(s) occurred. ' ||
                            'Rolling back and setting status to ERROR',
                            G_MSG_ERROR);
                      END IF;

                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
					   );
                      RETURN;
                ELSE
                      NULL;
                END IF;

         arp_util.disable_debug;

END Create_Adjustment;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Modify_Adjustment                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that modifies an adjustment         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |     ar_adjustments_pkg.fetch_p                                            |
 |     ar_process_adjustment.update_adjustment                               |
 |     ar_adjvalidate_pub.within_approval_limit                              |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit_flag                                           |
 |                   p_validation_level                                      |
 |                   p_adj_rec                                               |
 | 		     p_old_adjust_id                                         |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                   p_msg_count					     |
 |		     p_msg_data		                                     |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Modify_Adjustment (
p_api_name		IN	varchar2,
p_api_version		IN	number,
p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
p_validation_level     	IN	number := FND_API.G_VALID_LEVEL_FULL,
p_msg_count		OUT NOCOPY  	number,
p_msg_data		OUT NOCOPY	varchar2,
p_return_status		OUT NOCOPY	varchar2 ,
p_adj_rec		IN 	ar_adjustments%rowtype,
p_old_adjust_id		IN	ar_adjustments.adjustment_id%type
) IS

  l_api_name		CONSTANT VARCHAR2(20) := 'AR_ADJUSTAPI_PUB';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_old_adj_rec		ar_adjustments%rowtype;
  l_hsec		VARCHAR2(10);
  l_status		number;
  l_inp_adj_rec		ar_adjustments%rowtype;
  l_return_status   varchar2(1)    := FND_API.G_RET_STS_SUCCESS;


BEGIN
        select hsecs
        into G_START_TIME
        from v$timer;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT AR_ADJUSTAPI_PUB;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR ;
            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Modify_Adjustment: ' ||  'Compatility error occurred.', G_MSG_ERROR);
            END IF;

            RETURN ;
        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;

       /*------------------------------------------------------------+
        |  Turn on AR debugging messages only if the most verbose    |
        |  log is requested. The AR messages do not provide message  |
        |  level information.                                        |
        +------------------------------------------------------------*/

        IF ( FND_MSG_PUB.Check_Msg_Level( G_MSG_LOW ) )
        THEN
             arp_util.enable_debug;
        ELSE
             arp_util.disable_debug;
        END IF;


        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Modify_Adjustment()+ ', G_MSG_HIGH);
        END IF;

	/*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	/*---------------------------------------------+
        |   ========== Start of API Body ==========    |
        +---------------------------------------------*/

	/*---------------------------------------------+
        |   Copy the input record to local variable to |
        |   allow changes to it                        |
        +---------------------------------------------*/
	l_inp_adj_rec := p_adj_rec ;


        /*------------------------------------------------+
        |   Initialize the profile options and cache data |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Init_Context_Rec (
                                   p_validation_level,
                                   l_return_status
                                 );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

        /*------------------------------------------------+
        |   Cache details                                 |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Cache_Details (
                              l_return_status
                            );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

	/*------------------------------------------------+
        |   Fetch details of the old adjustment record    |
        +------------------------------------------------*/
        BEGIN

	 arp_adjustments_pkg.fetch_p (
				       l_old_adj_rec,
                                       p_old_adjust_id
                                     );

        EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             ar_adjvalidate_pub.aapi_message (
                            p_application_name => 'AR',
                            p_message_name => 'AR_AAPI_INVALID_ADJ_ID',
                            p_token1_name => 'ADJUSTMENT_ID',
                            p_token1_value => to_char(p_old_adjust_id)
                          );

             RETURN ;
        END ;

	/*------------------------------------------+
        |  Validate the input details		    |
        |  Do not continue if there are errors.     |
        +------------------------------------------*/

        ar_adjustapi_pub.Validate_Adj_Modify (
                                           l_inp_adj_rec,
					   l_old_adj_rec,
                                           l_return_status
                                         );


        IF   ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN

             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Modify_Adjustment: ' ||
                'Validation error(s) occurred. Rolling back ' ||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END IF;


	/*-----------------------------------------------+
	| Call the entity Handler for Modify             |
	+-----------------------------------------------*/
        BEGIN
	     arp_process_adjustment.update_adjustment (
                           	'DUMMY',
                           	'1',
  				l_inp_adj_rec,
                                NULL,
				p_old_adjust_id
                              ) ;

       EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Modify_Adjustment: ' ||
                'Error in Insert Entity handler. Rolling back '||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END ;

       /*-------------------------------------------+
        |   ========== End of API Body ==========   |
        +-------------------------------------------*/

       /*---------------------------------------------------+
        |  Get message count and if 1, return message data  |
        +---------------------------------------------------*/

        FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count => p_msg_count,
                                   p_data  => p_msg_data
                                 );

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit_flag )
        THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Modify_Adjustment: ' || 'committing', G_MSG_HIGH);
              END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Modify_Adjustment()- ', G_MSG_HIGH);
        END IF;

        select TO_CHAR( (hsecs - G_START_TIME) / 100)
        into l_hsec
        from v$timer;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Modify_Adjustment: ' || 'Elapsed Time : '||l_hsec||' seconds', G_MSG_LOW);
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Modify_Adjustment: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Modify_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO AR_ADJUSTAPI_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Modify_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO AR_ADJUSTAPI_PUB ;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                      p_return_status := FND_API.G_RET_STS_ERROR ;
                      ROLLBACK TO AR_ADJUSTAPI_PUB;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Modify_Adjustment: ' ||
                            'Completion validation error(s) occurred. ' ||
                            'Rolling back and setting status to ERROR',
                            G_MSG_ERROR);
                      END IF;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );
                      RETURN;
                ELSE
                      NULL;
                END IF;

         arp_util.disable_debug;

END Modify_Adjustment;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Reverse_Adjustment                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that reverses an adjustment         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |     ar_adjustments_pkg.fetch_p                                            |
 |     ar_process_adjustment.reverse_adjustment                              |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit_flag                                           |
 |                   p_validation_level                                      |
 | 		     p_old_adjust_id                                         |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                   p_msg_count					     |
 |		     p_msg_data		                                     |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Reverse_Adjustment (
p_api_name		IN	varchar2,
p_api_version		IN	number,
p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
p_validation_level     	IN	number := FND_API.G_VALID_LEVEL_FULL,
p_msg_count		OUT NOCOPY  	number,
p_msg_data		OUT NOCOPY	varchar2,
p_return_status		OUT NOCOPY	varchar2 ,
p_old_adjust_id		IN	ar_adjustments.adjustment_id%type,
p_reversal_gl_date	IN	date,
p_reversal_date		IN	date
) IS

  l_api_name		CONSTANT VARCHAR2(20) := 'AR_ADJUSTAPI_PUB';
  l_api_version         CONSTANT NUMBER       := 1.0;

  l_reversal_date	ar_adjustments.apply_date%type;
  l_reversal_gl_date 	ar_adjustments.gl_date%type;
  l_hsec		VARCHAR2(10);
  l_status		number;
  l_old_adj_rec		ar_adjustments%rowtype;
  l_return_status   varchar2(1)    := FND_API.G_RET_STS_SUCCESS;


BEGIN
        select hsecs
        into G_START_TIME
        from v$timer;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT AR_ADJUSTAPI_PUB;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR ;

            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded =>FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Reverse_Adjustment: ' ||  'Compatility error occurred.', G_MSG_ERROR);
            END IF;

            RETURN ;
        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;

       /*------------------------------------------------------------+
        |  Turn on AR debugging messages only if the most verbose    |
        |  log is requested. The AR messages do not provide message  |
        |  level information.                                        |
        +------------------------------------------------------------*/

        IF ( FND_MSG_PUB.Check_Msg_Level( G_MSG_LOW ) )
        THEN
             arp_util.enable_debug;
        ELSE
             arp_util.disable_debug;
        END IF;


        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Reverse_Adjustment()+ ', G_MSG_HIGH);
        END IF;

	/*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	/*---------------------------------------------+
        |   ========== Start of API Body ==========    |
        +---------------------------------------------*/


        /*------------------------------------------------+
        |   Initialize the profile options and cache data |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Init_Context_Rec (
                                   p_validation_level,
                                   l_return_status
                                 );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

	/*------------------------------------------------+
        |   Fetch details of the old adjustment record    |
        +------------------------------------------------*/
        BEGIN

	 arp_adjustments_pkg.fetch_p (
				       l_old_adj_rec,
                                       p_old_adjust_id
                                     );
        EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             ar_adjvalidate_pub.aapi_message (
                            p_application_name => 'AR',
                            p_message_name => 'AR_AAPI_INVALID_ADJ_ID',
                            p_token1_name => 'ADJUSTMENT_ID',
                            p_token1_value => to_char(p_old_adjust_id)
                          );

             RETURN;
        END ;

        /*------------------------------------------------+
        |   Cache details                                 |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Cache_Details (
                              l_return_status
                            );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

	/*--------------------------------------------+
        |  Validate the input details. Copy the dates |
        |  into local variables                       |
        +--------------------------------------------*/

        l_reversal_gl_date := p_reversal_gl_date ;
        l_reversal_date := p_reversal_date ;

        /*------------------------------------------------+
        |   Validate if the adjustment can be reversed    |
        +------------------------------------------------*/


        ar_adjustapi_pub.Validate_Adj_Reverse (
					   l_old_adj_rec,
                                           l_reversal_gl_date,
                                           l_reversal_date,
                                           l_return_status
                                         );


       IF   ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN

             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded =>FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Reverse_Adjustment: ' ||
                'Validation error(s) occurred. Rolling back '||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END IF;


	/*-----------------------------------------------+
	| Call the entity Handler for Reversal           |
	+-----------------------------------------------*/
        BEGIN

	           arp_process_adjustment.reverse_adjustment (
                       		p_old_adjust_id,
				l_reversal_gl_date,
				l_reversal_date,
				'DUMMY',
                		'1'
                              ) ;
        EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded =>FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Reverse_Adjustment: ' ||
                'Error in Insert Entity handler. Rolling back '||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END ;


       /*-------------------------------------------+
        |   ========== End of API Body ==========   |
        +-------------------------------------------*/

       /*---------------------------------------------------+
        |  Get message count and if 1, return message data  |
        +---------------------------------------------------*/

        FND_MSG_PUB.Count_And_Get(
					p_encoded =>FND_API.G_FALSE,
                                   p_count => p_msg_count,
                                   p_data  => p_msg_data
                                 );

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit_flag )
        THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Reverse_Adjustment: ' || 'committing', G_MSG_HIGH);
              END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Reverse_Adjustment()- ', G_MSG_HIGH);
        END IF;

        select TO_CHAR( (hsecs - G_START_TIME) / 100)
        into l_hsec
        from v$timer;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Reverse_Adjustment: ' || 'Elapsed Time : '||l_hsec||' seconds', G_MSG_LOW);
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Reverse_Adjustment: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Reverse_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO AR_ADJUSTAPI_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
					   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Reverse_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO AR_ADJUSTAPI_PUB ;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
					   );

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                      p_return_status := FND_API.G_RET_STS_ERROR ;
                      ROLLBACK TO AR_ADJUSTAPI_PUB;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Reverse_Adjustment: ' ||
                            'Completion validation error(s) occurred. ' ||
                            'Rolling back and setting status to ERROR',
                            G_MSG_ERROR);
                      END IF;

                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
					   );
                      RETURN;
                ELSE
                      NULL;
                END IF;

         arp_util.disable_debug;

END Reverse_Adjustment;


 /*===========================================================================+
 | PROCEDURE                                                                 |
 |              Approve_Adjustment                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine that approves an adjustment         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.compatible_api_call                                           |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |     fnd_msg_pub.check_msg_level                                           |
 |     fnd_msg_pub.count_and_get                                             |
 |     fnd_msg_pub.initialize                                                |
 |     ar_adjustments_pkg.fetch_p                                            |
 |     ar_process_adjustment.update_approve_adjustment                       |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit_flag                                           |
 |                   p_validation_level                                      |
 |                   p_adj_rec                                               |
 |                   p_old_adjust_id                                         |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                   p_msg_count					     |
 |		     p_msg_data		                                     |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JAN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Approve_Adjustment (
p_api_name		IN	varchar2,
p_api_version		IN	number,
p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
p_validation_level     	IN	number := FND_API.G_VALID_LEVEL_FULL,
p_msg_count		OUT NOCOPY  	number,
p_msg_data		OUT NOCOPY	varchar2,
p_return_status		OUT NOCOPY	varchar2 ,
p_adj_rec		IN 	ar_adjustments%rowtype,
p_old_adjust_id		IN	ar_adjustments.adjustment_id%type
) IS

  l_api_name		CONSTANT VARCHAR2(20) := 'AR_ADJUSTAPI_PUB';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_old_adj_rec		ar_adjustments%rowtype;

  l_inp_adj_rec		ar_adjustments%rowtype;
  l_hsec		VARCHAR2(10);
  l_status		number;

  l_return_status   varchar2(1)    := FND_API.G_RET_STS_SUCCESS;


BEGIN
        select hsecs
        into G_START_TIME
        from v$timer;

       /*------------------------------------+
        |   Standard start of API savepoint  |
        +------------------------------------*/

        SAVEPOINT AR_ADJUSTAPI_PUB;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR ;
            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Approve_Adjustment: ' ||  'Compatility error occurred.', G_MSG_ERROR);
            END IF;

            RETURN ;
        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;

       /*------------------------------------------------------------+
        |  Turn on AR debugging messages only if the most verbose    |
        |  log is requested. The AR messages do not provide message  |
        |  level information.                                        |
        +------------------------------------------------------------*/

        IF ( FND_MSG_PUB.Check_Msg_Level( G_MSG_LOW ) )
        THEN
             arp_util.enable_debug;
        ELSE
             arp_util.disable_debug;
        END IF;


        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Approve_Adjustment()+ ', G_MSG_HIGH);
        END IF;

	/*-----------------------------------------+
        |   Initialize return status to SUCCESS   |
        +-----------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	/*---------------------------------------------+
        |   ========== Start of API Body ==========    |
        +---------------------------------------------*/


	/*---------------------------------------------+
        |   Copy the input record to local variable to |
        |   allow changes to it                        |
        +---------------------------------------------*/
	l_inp_adj_rec := p_adj_rec ;


        /*------------------------------------------------+
        |   Initialize the profile options and cache data |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Init_Context_Rec (
                                   p_validation_level,
                                   l_return_status
                                 );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

        /*------------------------------------------------+
        |   Cache details                                 |
        +------------------------------------------------*/

        ar_adjvalidate_pub.Cache_Details (
                              l_return_status
                            );
        /*------------------------------------------------+
        |   Check status and return if error              |
        +------------------------------------------------*/

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;
             p_return_status := l_return_status ;
             RETURN;
        END IF;

	/*------------------------------------------------+
        |   Fetch details of the old adjustment record    |
        +------------------------------------------------*/
        BEGIN

	 arp_adjustments_pkg.fetch_p (
				       l_old_adj_rec,
                                       p_old_adjust_id
                                     );

        EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             ar_adjvalidate_pub.aapi_message (
                            p_application_name => 'AR',
                            p_message_name => 'AR_AAPI_INVALID_ADJ_ID',
                            p_token1_name => 'ADJUSTMENT_ID',
                            p_token1_value => to_char(p_old_adjust_id)
                          );

             RETURN ;
        END ;

	/*------------------------------------------+
        |  Validate the input details		    |
        |  Do not continue if there are errors.     |
        +------------------------------------------*/

        ar_adjustapi_pub.Validate_Adj_Approve (
                                           l_inp_adj_rec,
					   l_old_adj_rec,
                                           l_return_status
                                         );


        IF   ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN

             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Approve_Adjustment: ' ||
                'Validation error(s) occurred. Rolling back ' ||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END IF;

	/*-----------------------------------------------+
	| Call the entity Handler for Approve            |
	+-----------------------------------------------*/
	BEGIN

	         arp_process_adjustment.update_approve_adj (
                           	'DUMMY',
                           	'1',
  				l_inp_adj_rec,
                                NULL,
                                l_inp_adj_rec.status,
                                p_old_adjust_id
                              ) ;

       EXCEPTION
           WHEN OTHERS THEN
             /*---------------------------------------------------+
             |  Rollback to the defined Savepoint                 |
             +---------------------------------------------------*/

             ROLLBACK TO AR_ADJUSTAPI_PUB;

             p_return_status := FND_API.G_RET_STS_ERROR ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

             FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => p_msg_count,
                                        p_data  => p_msg_data
                                      );

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Approve_Adjustment: ' ||
                'Error in Insert Entity handler. Rolling back ' ||
		'and setting status to ERROR', G_MSG_ERROR);
             END IF;

             RETURN;

        END ;


       /*-------------------------------------------+
        |   ========== End of API Body ==========   |
        +-------------------------------------------*/

       /*---------------------------------------------------+
        |  Get message count and if 1, return message data  |
        +---------------------------------------------------*/

        FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count => p_msg_count,
                                   p_data  => p_msg_data
                                 );

       /*--------------------------------+
        |   Standard check of p_commit   |
        +--------------------------------*/

        IF FND_API.To_Boolean( p_commit_flag )
        THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('Approve_Adjustment: ' || 'committing', G_MSG_HIGH);
              END IF;
              Commit;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Approve_Adjustment()- ', G_MSG_HIGH);
        END IF;

        select TO_CHAR( (hsecs - G_START_TIME) / 100)
        into l_hsec
        from v$timer;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Approve_Adjustment: ' || 'Elapsed Time : '||l_hsec||' seconds', G_MSG_LOW);
        END IF;


EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Approve_Adjustment: ' || SQLCODE, G_MSG_ERROR);
                   arp_util.debug('Approve_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;

                ROLLBACK TO AR_ADJUSTAPI_PUB;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('Approve_Adjustment: ' || SQLERRM, G_MSG_ERROR);
                END IF;
                ROLLBACK TO AR_ADJUSTAPI_PUB ;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );

        WHEN OTHERS THEN

               /*-------------------------------------------------------+
                |  Handle application errors that result from trapable  |
                |  error conditions. The error messages have already    |
                |  been put on the error stack.                         |
                +-------------------------------------------------------*/

                IF (SQLCODE = -20001)
                THEN
                      p_return_status := FND_API.G_RET_STS_ERROR ;
                      ROLLBACK TO AR_ADJUSTAPI_PUB;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('Approve_Adjustment: ' ||
                            'Completion validation error(s) occurred. ' ||
                            'Rolling back and setting status to ERROR',
                            G_MSG_ERROR);
                      END IF;

                FND_MSG_PUB.Count_And_Get( p_encoded     => FND_API.G_FALSE,
					   p_count       =>      p_msg_count,
                                           p_data        =>      p_msg_data
                                         );
                      RETURN;
                ELSE
                      NULL;
                END IF;

         arp_util.disable_debug;

END Approve_Adjustment;


END AR_ADJUSTAPI_PUB;

/
