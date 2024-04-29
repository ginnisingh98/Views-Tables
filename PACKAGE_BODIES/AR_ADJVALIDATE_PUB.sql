--------------------------------------------------------
--  DDL for Package Body AR_ADJVALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ADJVALIDATE_PUB" AS
/* $Header: ARTAADVB.pls 115.9 2003/10/10 14:27:25 mraymond ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(30)	:='AR_ADJVALIDATE_PUB';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

G_caching_done		varchar2(1) := FND_API.G_FALSE;
G_cache_date		date := NULL ;
G_receivables_name	ar_receivables_trx.name%type := NULL;

TYPE Context_Rec_Type IS RECORD
     (
       validation_level	    	NUMBER ,
       ussgl_option	    	fnd_profile_option_values.profile_option_value%type,
       override_activity_option fnd_profile_option_values.profile_option_value%type,
       unique_seq_numbers   	fnd_profile_option_values.profile_option_value%type
     );

TYPE Lookup_Rec_Type  IS RECORD
     (
	lookup_code		ar_lookups.lookup_code%type
     ) ;
TYPE Approval_Cache_Tbl_type IS
     TABLE OF    Lookup_Rec_Type
     INDEX BY    BINARY_INTEGER;
TYPE Adjtype_Cache_Tbl_type IS
     TABLE OF    Lookup_Rec_Type
     INDEX BY    BINARY_INTEGER;
TYPE Adjreason_Cache_Tbl_type IS
     TABLE OF    Lookup_Rec_Type
     INDEX BY    BINARY_INTEGER;

TYPE Rcvtrx_Rec_Type	IS RECORD
     (
	receivables_trx_id 	ar_receivables_trx.RECEIVABLES_TRX_ID%type,
        name			ar_receivables_trx.NAME%type,
        code_combination_id	ar_receivables_trx.CODE_COMBINATION_ID%type
     ) ;
TYPE Rcvtrx_Cache_Tbl_type IS
     TABLE OF    Rcvtrx_Rec_Type
     INDEX BY    BINARY_INTEGER;


TYPE Ussgl_Rec_Type	IS RECORD
    (
	Ussgl_code	gl_ussgl_transaction_codes.ussgl_transaction_code%type,
	Ussgl_context	gl_ussgl_transaction_codes.context%type
    ) ;
TYPE Ussgl_Cache_Tbl_Type IS
     TABLE OF    Ussgl_Rec_Type
     INDEX BY    BINARY_INTEGER;


TYPE Glperiod_Rec_Type	IS RECORD
    (
	start_date		gl_period_statuses.start_date%type,
	end_date		gl_period_statuses.end_date%type
    ) ;
TYPE Glperiod_Cache_Tbl_Type IS
     TABLE OF    GLperiod_Rec_Type
     INDEX BY    BINARY_INTEGER;


TYPE Ccid_Rec_Type IS RECORD
     (
	dummy  varchar2(1)
     );
TYPE CCid_Cache_Tbl_Type IS
     TABLE OF    Ccid_Rec_Type
     INDEX BY    BINARY_INTEGER;

G_APPROVAL_TBL		Approval_Cache_Tbl_Type;
G_REASON_TBL		Adjreason_Cache_Tbl_Type;
G_ADJTYPE_TBL		Adjtype_Cache_Tbl_Type;
G_RCVTRX_TBL		Rcvtrx_Cache_Tbl_type;
G_USSGL_TBL		Ussgl_Cache_Tbl_Type;
G_GLPERIOD_TBL		Glperiod_Cache_Tbl_Type;
G_CCID_TBL              Ccid_Cache_Tbl_type;

G_CONTEXT_REC		Context_Rec_Type;

G_CCID_CACHE_SIZE 	BINARY_INTEGER	:= 1000;
G_GLPERIOD_CACHE_SIZE	BINARY_INTEGER	:= 1000;


/*===========================================================================+
 | PROCEDURE      aapi_message                                               |
 |                                                                           |
 | DESCRIPTION    This function is the message utility function used for     |
 |                messaging in the Adjustment API                            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   11-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE aapi_message (
	   p_application_name IN varchar2,
           p_message_name IN varchar2,
           p_token1_name  IN varchar2 default NULL,
           p_token1_value IN varchar2 default NULL,
           p_token2_name IN varchar2 default NULL,
           p_token2_value IN varchar2 default NULL,
           p_token3_name IN varchar2 default NULL,
           p_token3_value IN varchar2 default NULL,
           p_msg_level IN number default FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
         ) IS
l_mesg	varchar2(2000);
l_msg_count	number;
l_msg_data	varchar2(2000);
l_app_name	varchar2(30);
l_message_name  varchar2(32);
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('aapi_message()+' , G_MSG_HIGH);
    END IF;

    FND_MESSAGE.SET_NAME (p_application_name, p_message_name);

    IF ( p_token1_name IS NOT NULL )
    THEN
        FND_MESSAGE.SET_TOKEN ( p_token1_name, p_token1_value ) ;
    END IF ;

    IF ( p_token2_name IS NOT NULL )
    THEN
        FND_MESSAGE.SET_TOKEN ( p_token2_name, p_token2_value ) ;
    END IF ;

    IF ( p_token3_name IS NOT NULL )
    THEN
        FND_MESSAGE.SET_TOKEN ( p_token3_name, p_token3_value ) ;
    END IF ;

    FND_MSG_PUB.ADD ;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('aapi_message()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: aapi_message()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'aapi_message');

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END aapi_message;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Init_Context_Rec                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Initializes the context record that is passed into most of   |
 |              the other functions. Many of its values are set when the     |
 |              context variable is instantiated.                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_validation_level                                     |
 |              OUT:                                                         |
 |                    p_return_status                                        |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   06-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Init_Context_Rec(
                            p_validation_level    IN  VARCHAR2,
                            p_return_status       IN OUT NOCOPY varchar2
                           ) IS


BEGIN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Init_Context_Rec()+' , G_MSG_HIGH);
       END IF;


       /*---------------------------+
       |  Set the validation level  |
       +----------------------------*/

       g_context_rec.validation_level := p_validation_level;

       /*-------------------------------------------------------+
       |  Set the profile options for USSGL, DOCUMENT SEQUENCES |
       |  and the OVERRIDE ACTIVITY option                      |
       +-------------------------------------------------------*/

       g_context_rec.ussgl_option :=
	   rtrim(FND_PROFILE.VALUE( 'USSGL_OPTION' ));

       g_context_rec.unique_seq_numbers :=
           rtrim(FND_PROFILE.VALUE('UNIQUE:SEQ_NUMBERS'));

       g_context_rec.override_activity_option :=
           rtrim(FND_PROFILE.VALUE( 'AR_OVERRIDE_ADJUSTMENT_ACTIVITY_ACCOUNT'));


       p_return_status := FND_API.G_RET_STS_SUCCESS;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Init_Context_Rec()-' , G_MSG_HIGH);
       END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION: Init_Context_Rec() ', G_MSG_UERROR);
         END IF;

         FND_MSG_PUB.Add_Exc_Msg (
			   G_PKG_NAME,
			   'Init_Context_Rec'
			);
 	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RETURN;

END Init_Context_Rec;

/*===========================================================================+
 | PROCEDURE      Cache_Gl_Periods                                           |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                opened, future-enterable in a pl/sql table.                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek halder  10-JUL-97  Created                                       |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Gl_Periods (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    l_set_of_books_id  ar_system_parameters.set_of_books_id%type;

    CURSOR l_periods_csr  IS
           SELECT trunc(g.start_date) start_date,
                  trunc(g.end_date) end_date
           FROM   gl_period_statuses g,
                  gl_sets_of_books   b
           WHERE  g.application_id          = 222
           AND    g.set_of_books_id         = l_set_of_books_id
           AND    g.set_of_books_id         = b.set_of_books_id
           AND    g.period_type             = b.accounted_period_type
           AND    g.adjustment_period_flag  = 'N'
           AND    g.closing_status IN ('O','F') ;


    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Glperiod_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Gl_Periods()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    SELECT set_of_books_id
      INTO l_set_of_books_id
      FROM ar_system_parameters ;

    l_index := 0 ;
    FOR l_temp_rec IN l_periods_csr LOOP
        l_index := l_index + 1;
        IF ( l_index > G_GLPERIOD_CACHE_SIZE )
        THEN
             EXIT ;
        END IF;
        G_GLPERIOD_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Gl_Periods: ' || 'G_GLPERIOD_TBL count = '|| to_char(g_glperiod_tbl.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Gl_Periods()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Cache_Gl_Periods: ' || 'No Open/Future Enterable GL periods exist',G_MSG_HIGH);
        END IF;
        /*-----------------------------------------------+
        |  Set the message                               |
        +-----------------------------------------------*/
        aapi_message(
                     p_application_name =>'AR',
                     p_message_name => 'AR_AAPI_NO_OPEN_FUTURE_PERIOD',
                     p_token1_name => 'SET_OF_BOOKS_ID',
                     p_token1_value => to_char(arp_global.set_of_books_id)
                   ) ;
        p_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Gl_Periods()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Gl_Periods');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Gl_Periods;


 /*===========================================================================+
 | PROCEDURE      Cache_Approval_Type                                        |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                approval codes in a pl/sql table.                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   10-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Approval_Type (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_lookup_csr  IS
           SELECT lookup_code
             FROM ar_lookups
            WHERE lookup_type = 'APPROVAL_TYPE'
            AND   enabled_flag = 'Y'
            AND   sysdate BETWEEN nvl(start_date_active,sysdate)
                            AND   nvl(end_date_active,sysdate) ;

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Approval_Type()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr LOOP
        l_index := l_index + 1;
        G_APPROVAL_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Approval_Type: ' || 'G_APPROVAL_TBL count = '|| to_char(G_APPROVAL_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Approval_Type()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Approval_Type: ' || 'No Approval Codes exist ', G_MSG_HIGH);
       END IF;
       /*-----------------------------------------------+
       |  Set the message                               |
       +-----------------------------------------------*/
       aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_NO_APPROVAL_CODES'
                      ) ;
       p_return_status := FND_API.G_RET_STS_ERROR ;
       RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Approval_Type()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Approval_Type');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Approval_Type;

 /*==========================================================================+
 | PROCEDURE      Cache_Adjustment_Type                                      |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                types in a pl/sql table.                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder      11-JUL-97  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Adjustment_Type (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_lookup_csr  IS
           SELECT lookup_code
             FROM ar_lookups
            WHERE lookup_type = 'ADJUSTMENT_TYPE'
            AND   enabled_flag = 'Y'
            AND   trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
					     trunc(sysdate))
                            AND nvl(trunc(end_date_active),trunc(sysdate)) ;

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Adjustment_Type()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr LOOP
        l_index := l_index + 1;
        G_ADJTYPE_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Adjustment_Type: ' || 'G_ADJTYPE_TBL count = '|| to_char(G_ADJTYPE_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Adjustment_Type()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Adjustment_Type: ' || 'No Adjustment Type codes', G_MSG_HIGH);
       END IF;
            /*-----------------------------------------------+
	    |  Set the message                               |
      	    +-----------------------------------------------*/
            aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_NO_TYPE_CODES'
                      ) ;
            p_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Adjustment_Type()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Adjustment_Type');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Adjustment_Type;

 /*==========================================================================+
 | PROCEDURE      Cache_Adjustment_Reason                                    |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                adjustment reason codes in a pl/sql table.                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   11-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Adjustment_Reason (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_lookup_csr  IS
           SELECT lookup_code
             FROM ar_lookups
            WHERE lookup_type = 'ADJUST_REASON'
            AND   enabled_flag = 'Y'
            AND   trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
					     trunc(sysdate))
                            AND   nvl(trunc(end_date_active),trunc(sysdate)) ;

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Adjustment_Reason()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr LOOP
        l_index := l_index + 1;
        G_REASON_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Adjustment_Reason: ' || 'G_REASON_TBL count = '|| to_char(G_REASON_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Adjustment_Reason()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Adjustment_Reason: ' || 'No Adjustment Reason codes', G_MSG_HIGH);
       END IF;
            /*-----------------------------------------------+
	    |  Set the message                               |
      	    +-----------------------------------------------*/
            aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_NO_REASON_CODES'
                      ) ;
            p_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Adjustment_Reason()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Adjustment_Reason');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Adjustment_Reason;


 /*==========================================================================+
 | PROCEDURE      Cache_Receivables_Trx                                      |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                Receivables Trx codes in a pl/sql table.                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder      11-JUL-97  Created                                   |
 |    Satheesh Nambiar  31-May-00  Bug 1290698.Included type ENDORSEMENT for |
 |                                 BOE/BR
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Receivables_Trx (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_receivables_csr  IS
           SELECT receivables_trx_id,name,code_combination_id
            FROM ar_receivables_trx
            WHERE nvl(status,'A') = 'A'
            AND   type in ('ADJUST','ENDORSEMENT')
            AND   receivables_trx_id not in ( -1,-11,-12,-13 )
            AND   trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
					     trunc(sysdate))
                            AND   nvl(trunc(end_date_active),trunc(sysdate)) ;


    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Rcvtrx_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Receivables_Trx()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_receivables_csr LOOP
        l_index := l_index + 1;
        G_RCVTRX_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Receivables_Trx: ' || 'G_RCVTRX_TBL count = '|| to_char(G_RCVTRX_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Receivables_Trx()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Receivables_Trx: ' || 'No Adjustment Reason codes', G_MSG_HIGH);
       END IF;
            /*-----------------------------------------------+
	    |  Set the message                               |
      	    +-----------------------------------------------*/
            aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_NO_RECEIVABLES_TRX'
                      ) ;
            p_return_status := FND_API.G_RET_STS_ERROR ;
            RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Receivables_Trx()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Receivables_Trx');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Receivables_Trx;

/*===========================================================================+
 | PROCEDURE      Cache_Ussgl_code                                           |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                Ussgl codes in a pl/sql table.                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   11-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Ussgl_Code (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_ussgl_csr  IS
           SELECT ussgl_transaction_code,context
             FROM gl_ussgl_transaction_codes
            WHERE chart_of_accounts_id = arp_global.chart_of_accounts_id
              AND trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
					     trunc(sysdate))
                              AND nvl(trunc(end_date_active),trunc(sysdate)) ;


    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Ussgl_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Ussgl_Code()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------------+
    |  Load the USSGL based on profile option        |
    +-----------------------------------------------*/

    IF ( g_context_rec.ussgl_option <> 'Y' )
    THEN
       RETURN ;
    END IF;

    FOR l_temp_rec IN l_ussgl_csr LOOP
        l_index := l_index + 1;
        G_USSGL_TBL(l_index) := l_temp_rec;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Ussgl_Code: ' || 'G_USSGL_TBL count = '|| to_char(G_USSGL_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Ussgl_Code()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Ussgl_Code: ' || 'No USSGL codes', G_MSG_HIGH);
       END IF;
       /*-----------------------------------------------+
       |  Set the message                               |
       +-----------------------------------------------*/
       aapi_message(
                     p_application_name =>'AR',
                     p_message_name => 'AR_AAPI_NO_USSGL_CODES'
                   ) ;
       p_return_status := FND_API.G_RET_STS_SUCCESS ;
       RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Ussgl_Code()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Ussgl_Code');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Ussgl_code;

/*===========================================================================+
 | PROCEDURE      Cache_Code_Combination                                     |
 |                                                                           |
 | DESCRIPTION    This function is called during start_up to fetch the 	     |
 |                Code Combination Ids in a pl/sql table.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT: p_return_status                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   11-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Code_Combination (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_ccid_csr  IS
           SELECT code_combination_id
             FROM gl_code_combinations
            WHERE chart_of_accounts_id = arp_global.chart_of_accounts_id
              AND enabled_flag = 'Y'
              AND trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
					     trunc(sysdate))
                              AND nvl(trunc(end_date_active),trunc(sysdate)) ;


    l_index   			BINARY_INTEGER default 0;

    TYPE ccid_rec  IS RECORD
     (
	code_combination_id	gl_code_combinations.code_combination_id%type
     ) ;

    l_ccid_rec	ccid_rec;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Code_Combination()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_ccid_rec IN l_ccid_csr LOOP
        l_index := l_index + 1 ;
        IF ( l_index > G_CCID_CACHE_SIZE )
        THEN
           EXIT;
        END IF;
        G_CCID_TBL(l_ccid_rec.code_combination_id).dummy := FND_API.G_TRUE;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('Cache_Code_Combination: ' || 'G_CCID_TBL count = '|| to_char(G_CCID_TBL.count), G_MSG_HIGH);
       arp_util.debug ('Cache_Code_Combination()-' , G_MSG_HIGH);
    END IF;

    RETURN;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Code_Combination: ' || 'No USSGL codes', G_MSG_HIGH);
       END IF;
       /*-----------------------------------------------+
       |  Set the message                               |
       +-----------------------------------------------*/
       aapi_message(
                     p_application_name =>'AR',
                     p_message_name => 'AR_AAPI_NO_CCID'
                   ) ;
       p_return_status := FND_API.G_RET_STS_ERROR ;
       RETURN;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Cache_Code_Combination()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Code_Combination');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Cache_Code_Combination;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Cache_Details                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Caches data when it is first used so that values can easily  |
 |		be accessed later and need not be fetched from the database  |
 |              for future transactions.                                     |
 |                                                                           |
 |		The following tables are cached                              |
 |			- ar_lookups for type = APPROVAL_TYPE		     |
 |			- ar_lookups for type = ADJUSTMENT_TYPE		     |
 |			- ar_lookups for type = ADJUSTMENT_REASON	     |
 |			- ussgl transaction codes			     |
 |			- receivables trx for type = 'ADJUST'                |
 |                      - code combination ids                               |
 |                      - gl periods                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    cache_approval_type();                                                 |
 |    cache_adjustment_type();                                               |
 |    cache_adjustment_reason();                                             |
 |    cache_ussgl_code();                                                    |
 |    cache_receivables_trx();                                               |
 |    cache_gl_periods();                                                    |
 |    cache_code_combination();                                              |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT: p_return_status                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder      05-JUL-97  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Details (
                          p_return_status IN OUT NOCOPY varchar2
                        ) IS

l_tobe_cached_flag	varchar2(1) ;

BEGIN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Details()+' , G_MSG_HIGH);
       END IF;

       /*--------------------------------------------------+
       |   Check if caching is needed. Caching is needed if|
       |   g_caching_done is FALSE or sysdate > cache_date |
       +--------------------------------------------------*/

       l_tobe_cached_flag := FND_API.G_FALSE ;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug ('Cache_Details: ' || 'G_Caching done = ' || G_caching_done, G_MSG_HIGH);
          arp_util.debug ('Cache_Details: ' || 'G_Cache_date = ' || to_char(G_cache_date,'DD-MON-YY'),
			G_MSG_HIGH);
          arp_util.debug ('Cache_Details: ' || 'Sysdate = ' || to_char(sysdate,'DD-MON-YY'),G_MSG_HIGH);
       END IF;

       IF ( G_caching_done = FND_API.G_FALSE )
       THEN
           l_tobe_cached_flag := FND_API.G_TRUE ;
           G_cache_date := trunc(sysdate) ;
       ELSE
           IF ( G_cache_date < trunc(sysdate) )
           THEN
              l_tobe_cached_flag := FND_API.G_TRUE ;
              G_cache_date := trunc(sysdate) ;
           END IF;
       END IF;

       l_tobe_cached_flag := FND_API.G_TRUE;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug ('Cache_Details: ' ||  'Caching Flag : '|| l_tobe_cached_flag,G_MSG_HIGH);
       END IF;

       IF ( l_tobe_cached_flag = FND_API.G_FALSE )
       THEN
           p_return_status := FND_API.G_RET_STS_SUCCESS;
           RETURN ;
       ELSE
       /*-------------------------------------------------+
       |   Initialise the PL/SQL cache tables             |
       +-------------------------------------------------*/
          G_APPROVAL_TBL.DELETE;
          G_REASON_TBL.DELETE;
          G_ADJTYPE_TBL.DELETE;
          G_RCVTRX_TBL.DELETE;
          G_USSGL_TBL.DELETE;
          G_GLPERIOD_TBL.DELETE;
          G_CCID_TBL.DELETE;
      END IF;

       /*-------------------------------------------------+
       |   Cache Approval type. To be used for validation |
       |   of status                                      |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.cache_approval_type (p_return_status);

       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
          RETURN ;
       END IF;
       /*-------------------------------------------------+
       |   Cache reason codes for adjustment. To be used  |
       |   for validation of adjustment reason codes      |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.cache_adjustment_reason (p_return_status);
       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   Cache adjustment types i.e. INVOICE, LINE etc. |
       |   To be used for validation of type              |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.cache_adjustment_type (p_return_status);
       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   Cache Receivables transaction ids. To be used  |
       |   for validation of Receivables trx id           |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.cache_receivables_trx (p_return_status) ;

       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*-------------------------------------------------+
       |   Cache USSGL transaction information. To be used|
       |   for validation of USSGL transaction code       |
       +-------------------------------------------------*/

       ar_adjvalidate_pub.cache_ussgl_code (p_return_status);
       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*--------------------------------------------------+
       |   Cache GL periods. To be used to validate if GL  |
       |   dates lie within open or future enterable period|
       +--------------------------------------------------*/

       ar_adjvalidate_pub.cache_gl_periods(p_return_status);
       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       /*--------------------------------------------------+
       |   Cache Code combination Ids. To be used to       |
       |   validate input provided by user                 |
       +--------------------------------------------------*/

       ar_adjvalidate_pub.cache_code_combination (p_return_status);
       IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
           RETURN ;
       END IF;

       G_caching_done := FND_API.G_TRUE ;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('Cache_Details ()-' , G_MSG_HIGH);
       END IF;

EXCEPTION
    WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: Cache_Details() ', G_MSG_UERROR);
    END IF;

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Details');
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RETURN;

END Cache_Details;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Within_approval_limits                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine checks if the amount is within the approval     |
 |              limits of the user                                           |
 |                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |                   p_inv_curr_code                                         |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                  p_approved_flag                                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Within_approval_limits(
      p_adj_amount	IN     ar_adjustments.amount%type,
      p_inv_curr_code   IN     ar_payment_schedules.invoice_currency_code%type,
      p_approved_flag	IN OUT NOCOPY varchar2,
      p_return_status	IN OUT NOCOPY varchar2
   ) IS

l_user_id		ar_approval_user_limits.user_id%type;
l_approval_amount_to    ar_approval_user_limits.amount_to%type;
l_approval_amount_from  ar_approval_user_limits.amount_from%type;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Within_approval_limits()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      p_approved_flag := FND_API.G_TRUE ;

     /*------------------------------------------+
      |  Get the user Id                          |
      +------------------------------------------*/

      l_user_id := FND_GLOBAL.USER_ID ;

      BEGIN
             SELECT amount_to,
                    amount_from
             INTO   l_approval_amount_to,
                    l_approval_amount_from
             FROM   ar_approval_user_limits
             WHERE  user_id       = l_user_id
             AND    currency_code = p_inv_curr_code;

       EXCEPTION
          WHEN NO_DATA_FOUND THEN

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug ('Within_approval_limits: ' ||
                       'User does not have approval limits for currency ' ||
                       p_inv_curr_code, G_MSG_HIGH
                       );
             END IF;
             aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_VAL_USER_LIMIT',
                          p_token1_name => 'CURRENCY',
                          p_token1_value => p_inv_curr_code
                          ) ;
	     p_approved_flag := FND_API.G_FALSE;

          WHEN OTHERS THEN

	     IF PG_DEBUG in ('Y', 'C') THEN
	        arp_util.debug ('EXCEPTION: Within_approval_limits',G_MSG_UERROR);
	     END IF;

	     /*-------------------------------------------------+
      	     |  Set unexpected error message, status and return |
      	     +-------------------------------------------------*/
	     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Within_approval_limits');
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             RETURN;
        END;

	/*-----------------------------------------------+
        |  Ensure that approval data has been selected   |
      	+-----------------------------------------------*/

        IF ( p_approved_flag = FND_API.G_TRUE )
        THEN

	   /*--------------------------------------------+
           |  Perform actual check of approval limits.   |
      	   +--------------------------------------------*/

           IF  ((  p_adj_amount > l_approval_amount_to ) OR
                (  p_adj_amount < l_approval_amount_from ))
           THEN
  	       IF PG_DEBUG in ('Y', 'C') THEN
  	          arp_util.debug('Within_approval_limits: ' ||  'User ID: ' || l_user_id ||
                               ' Amount: ' || p_adj_amount ||
           		       ' From: '   || l_approval_amount_from ||
                               ' To: '     || l_approval_amount_to ||
                               ' exceeds approval limit', G_MSG_HIGH );
  	       END IF;
               /*--------------------------------------+
               | Add a message. But do not signal error|
               +--------------------------------------*/

 	       aapi_message(
                             p_application_name =>'AR',
                             p_message_name => 'AR_VAL_AMT_APPROVAL_LIMIT'
                             ) ;
  	       p_approved_flag := FND_API.G_FALSE;

           END IF;

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Within_approval_limits()-', G_MSG_HIGH);
        END IF;
        RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Within_approval_limits()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Within_approval_limits'
			);
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Within_approval_limits;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Type                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the type of adjustment                |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                   p_return_status                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Type (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index		number;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Type()+', G_MSG_HIGH);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to ERROR    |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_ERROR;

      FOR l_index IN 1..G_ADJTYPE_TBL.COUNT LOOP

         IF (p_adj_rec.type = G_ADJTYPE_TBL(l_index).lookup_code)
         THEN
             p_return_status := FND_API.G_RET_STS_SUCCESS;
             EXIT ;
         END IF;

      END LOOP;

      IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
 	 /*-----------------------------------------------+
	 |  Set the message                               |
      	 +-----------------------------------------------*/
         aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_AAPI_INVALID_ADJUSTMENT_TYPE',
                          p_token1_name => 'TYPE',
                          p_token1_value => p_adj_rec.type
                          ) ;
         RETURN ;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Type()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Type()', G_MSG_UERROR );
           arp_util.debug('Validate_Type for type = ' ||p_adj_rec.type,G_MSG_HIGH);
        END IF;

	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_Type' );

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_Type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Payschd                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the payment schedule id of the        |
 |              transaction for which the adjustment is to be created        |
 |		In case it is valid it populates the customer_trx_id         |
 |              and customer id in the adjustment record.                    |
 |		It also validates the customer trx line Id if type = 'LINE'  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT:                                                         |
 |                   p_return_status                                         |
 |                                                                           |
 |              IN/ OUT:                                                     |
 |                   p_adj_rec                                               |
 |                   p_ps_rec                                                |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder     30-JUNE-97  Created                                   |
 |    Satheesh Nambiar 01-Jun-00 Bug 1290698 Added one more class 'BR' to    |
 |                               PS check for BOE/BR                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Payschd (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_ps_rec	IN OUT NOCOPY	ar_payment_schedules%rowtype,
		p_return_status	OUT NOCOPY	Varchar2
               ) IS

l_index			BINARY_INTEGER ;
l_count			number:= 0 ;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_Payschd()+', G_MSG_MEDIUM);
	END IF;

	/*------------------------------------------+
	|  Initialize the return status to SUCCESS  |
	+------------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	/*-----------------------------------------------+
	|  Check if the payment schedule Id is 0 or null |
        |  If so return with failure                     |
	+-----------------------------------------------*/

	IF	( p_adj_rec.payment_schedule_id IS NULL or
	     	  p_adj_rec.payment_schedule_id <= 0 )
	THEN

		 /*-----------------------------------------------+
		 |  Set the message and return                    |
      		 +-----------------------------------------------*/
                  aapi_message(
                       p_application_name =>'AR',
                       p_message_name => 'AR_AAPI_INVALID_PAYSCHD',
                       p_token1_name => 'PAYMENT_SCHEDULE_ID',
                       p_token1_value => to_char(p_adj_rec.payment_schedule_id)
                     ) ;
		 p_return_status := FND_API.G_RET_STS_ERROR;
		 RETURN;

	END IF ;

      /*--------------------------------------------------+
      |  Check if the payment schedule Id exists. Get the |
      |  Customer Id and Customer Trx Id                  |
      +--------------------------------------------------*/

      BEGIN

      	SELECT	*
      	INTO	p_ps_rec
      	FROM	ar_payment_schedules
      	WHERE	payment_schedule_id = p_adj_rec.payment_schedule_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

     	 /*-----------------------------------------------+
      	 |  Payment schedule Id does not exist            |
      	 |  Set the message and status accordingly        |
      	 +-----------------------------------------------*/
 	 aapi_message(
                       p_application_name =>'AR',
                       p_message_name => 'AR_AAPI_INVALID_PAYSCHD',
                       p_token1_name => 'PAYMENT_SCHEDULE_ID',
                       p_token1_value => to_char(p_adj_rec.payment_schedule_id)
                     ) ;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RETURN ;
      END ;

      /*-----------------------------------------------+
      |  Check that the class of transaction is valid  |
      +-----------------------------------------------*/
      /*---------------------------------------------------------+
      |  Bug 1290698 Added one more class 'BR' for BOE/BR project|
      +----------------------------------------------------------*/
      IF ( p_ps_rec.class NOT IN ( 'INV','DM','CM','DEP','GUAR','BR') )
      THEN
          aapi_message(
                       p_application_name =>'AR',
                       p_message_name => 'AR_AAPI_INVALID_TRX_CLASS',
                       p_token1_name => 'CLASS',
                       p_token1_value => p_ps_rec.class
                     ) ;
	  p_return_status := FND_API.G_RET_STS_ERROR;
	  RETURN;
      END IF;

      /*-----------------------------------------------+
      |  Check that the Customer Trx Id exists in the  |
      |  payment schedule record. If not, return error |
      +-----------------------------------------------*/

      IF ( p_ps_rec.customer_trx_id IS NULL OR p_ps_rec.customer_trx_id = 0 )
      THEN

         /*-----------------------------------------------+
       	 |  Set the message accordingly                   |
      	 +-----------------------------------------------*/
         aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_NO_CUSTOMER_TRX_ID',
                      p_token1_name => 'PAYMENT_SCHEDULE_ID',
                      p_token1_value => to_char(p_adj_rec.payment_schedule_id)
                     ) ;
	 p_return_status := FND_API.G_RET_STS_ERROR;
         RETURN ;

      END IF;

      /*-----------------------------------------------+
      |  Check that the Customer Id exists in the      |
      |  payment schedule record. If not, return error |
      +-----------------------------------------------*/

      IF ( p_ps_rec.customer_id IS NULL OR p_ps_rec.customer_id = 0 )
      THEN

         /*-----------------------------------------------+
       	 |  Set the message accordingly                   |
      	 +-----------------------------------------------*/
         aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_NO_CUSTOMER_ID',
                      p_token1_name => 'PAYMENT_SCHEDULE_ID',
                      p_token1_value => to_char(p_adj_rec.payment_schedule_id)
                     ) ;
	 p_return_status := FND_API.G_RET_STS_ERROR;
         RETURN ;

      END IF;

      /*-----------------------------------------------+
      |  Since the validation is successful populate   |
      |  the customer_trx_id and customer_id in adj rec|
      +-----------------------------------------------*/

      p_adj_rec.customer_trx_id := p_ps_rec.customer_trx_id ;

      /*-----------------------------------------------+
      |  Check if the customer trx line Id is there if |
      |  the Invoice type is LINE                      |
      +-----------------------------------------------*/

      IF p_adj_rec.type = 'LINE'
      THEN
          IF ( nvl(p_adj_rec.customer_trx_line_id,0) <> 0 ) THEN
             l_count := 0 ;
             BEGIN
                SELECT count(*)
                  INTO l_count
                  FROM RA_CUSTOMER_TRX_LINES
                  WHERE customer_trx_id = p_adj_rec.customer_trx_id AND
                        customer_trx_line_id = p_adj_rec.customer_trx_line_id ;

             EXCEPTION
                 WHEN OTHERS THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Validate_Payschd: ' ||
			 'EXCEPTION: Validate_Payschd() for CustTrxLineId = '||
                        to_char(p_adj_rec.customer_trx_line_id),  G_MSG_HIGH);
                     END IF;

            	     /*-----------------------------------------------+
      	             |  Set unexpected error message and status       |
      	             +-----------------------------------------------*/
	             FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Payschd');
	             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                     RETURN;
            END ;

            IF ( l_count <> 1 ) THEN
               /*-----------------------------------------------+
       	       |  Set error message and status                  |
      	       +-----------------------------------------------*/
               aapi_message(
                     p_application_name =>'AR',
                     p_message_name => 'AR_AAPI_INV_CUST_TRX_LINE_ID',
                     p_token1_name => 'CUSTOMER_TRX_LINE_ID',
                     p_token1_value => to_char(p_adj_rec.customer_trx_line_id),
                     p_token2_name => 'CUSTOMER_TRX_ID',
                     p_token2_value => to_char(p_adj_rec.customer_trx_id)
                     ) ;
               p_return_status := FND_API.G_RET_STS_ERROR;
               RETURN ;

            END IF ;

          END IF ;

      ELSE
          /*-----------------------------------------------+
          |  The Customer Trx Line Id should not be there  |
          +-----------------------------------------------*/

          IF ( p_adj_rec.customer_trx_line_id IS NOT NULL OR
               p_adj_rec.customer_trx_line_id <> 0 )
          THEN
               aapi_message(
                     p_application_name =>'AR',
                     p_message_name => 'AR_AAPI_LINE_ID_FOR_NONLINE',
                     p_token1_name => 'CUSTOMER_TRX_LINE_ID',
                     p_token1_value => to_char(p_adj_rec.customer_trx_line_id),
                     p_token2_name => 'TYPE',
                     p_token2_value => p_ps_rec.class
                    ) ;
               p_return_status := FND_API.G_RET_STS_ERROR;
               RETURN ;
          END IF;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Payschd()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;


EXCEPTION

    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Payschd() ', G_MSG_UERROR);
           arp_util.debug('Validate_Payschd: ' ||  'Payment Schedule  = ' ||
			p_adj_rec.payment_schedule_id, G_MSG_HIGH);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_Payschd' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_Payschd;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Amount                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the adjustment amount and status. It  |
 |		checks for the user approval limits, validates status and    |
 |              set the adjustment status accordingly.                       |
 |									     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ps_rec                                                |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |		     p_return_status                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   30-JUN-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_amount (
               	p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_ps_rec	IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index			number;
l_user_id		BINARY_INTEGER;
l_approval_amount_to    ar_approval_user_limits.amount_to%type;
l_approval_amount_from  ar_approval_user_limits.amount_from%type;
l_approved_flag		VARCHAR2(1);
l_return_status		VARCHAR2(1);
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_amount()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      /*-----------------------------------------------+
      |  If the type is INVOICE then the amount must   |
      |  close the invoice                             |
      +-----------------------------------------------*/

      IF ( p_adj_rec.type = 'INVOICE' )
      THEN

         /*-----------------------------------------------+
         |  If amount is not specified then set it to     |
         |  close the transaction                         |
         +-----------------------------------------------*/
         IF ( p_adj_rec.amount IS NULL or p_adj_rec.amount = 0 )
         THEN
             /*-----------------------------------------------+
             |  If amount is not specifiedand the amount due  |
	     |  remaining is zero then should not create adj  |
             +-----------------------------------------------*/
	     IF ( p_ps_rec.amount_due_remaining = 0 )
	     THEN
                aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_AAPI_ADR_ZERO_INV'
                          ) ;
		p_return_status := FND_API.G_RET_STS_ERROR ;
		RETURN ;
	     END IF;
             p_adj_rec.amount := - p_ps_rec.amount_due_remaining ;
         ELSE
             IF ( p_adj_rec.amount + p_ps_rec.amount_due_remaining <> 0 )
             THEN
                aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_TW_VAL_AMT_ADJ_INV'
                          ) ;
                p_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
             END IF;
         END IF;
      END IF;

      /*-----------------------------------------------+
      |  Check if the adjustment amount is zero        |
      +-----------------------------------------------*/

      IF ( p_adj_rec.amount IS NULL OR p_adj_rec.amount = 0 )
      THEN
         /*--------------------------------------------+
	 |  Set the message and return                 |
      	 +--------------------------------------------*/
         aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_AAPI_ADJ_AMOUNT_ZERO'
                          ) ;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

      /*------------------------------------------------+
      |  Verify if amount is within user approval limits|
      +-------------------------------------------------*/
     /*----------------------------------------------------+
      |  Special processing for bypassing limit check if   |
      |  created from 'CASH_ENGINE' and 'RECEIPT_REVERSAL'  |
      +----------------------------------------------------*/

      IF ( p_adj_rec.created_from LIKE 'CASH_ENGINE%' OR
           p_adj_rec.created_from LIKE 'RECEIPT_REVERSAL%' OR
           p_adj_rec.created_from LIKE 'SPLIT_MERGE%' OR
           p_adj_rec.created_from LIKE 'DMS_INTERFACE%' OR
           p_adj_rec.created_from LIKE 'ENHANCED_CASH%' )
      THEN
          l_approved_flag := FND_API.G_TRUE ;
      ELSE
          ar_adjvalidate_pub.Within_approval_limits (
                    p_adj_rec.amount,
                    p_ps_rec.invoice_currency_code,
                    l_approved_flag,
                    l_return_status
                   ) ;
         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
         THEN
            p_return_status := l_return_status ;
            RETURN;
         END IF ;
      END IF;

      /*--------------------------------------------------+
      |  Check Status. If null/blank then set the value   |
      |  based on l_approved_flag                         |
      +--------------------------------------------------*/

      IF ( p_adj_rec.status IS NULL or p_adj_rec.status = ' ' )
      THEN
         IF ( l_approved_flag = FND_API.G_TRUE )
         THEN
              p_adj_rec.status := 'A' ;
         ELSE
              p_adj_rec.status := 'W' ;
         END IF ;
      ELSE
         /*-----------------------------------------------------+
         |  Check valid status values provided by user          |
         +-----------------------------------------------------*/

         IF (p_adj_rec.status <> 'A' AND p_adj_rec.status <> 'W' AND
             p_adj_rec.status <> 'M' )
         THEN
             aapi_message(
                           p_application_name =>'AR',
                           p_message_name => 'AR_AAPI_INVALID_CREATE_STATUS',
                           p_token1_name => 'STATUS',
                           p_token1_value => p_adj_rec.status
                         ) ;
             p_return_status := FND_API.G_RET_STS_ERROR ;
             RETURN ;
         END IF;

         /*-----------------------------------------------------+
         |  Handle the case for setting status to W if outside  |
         |  approval limits during creation of Adjustments      |
         +-----------------------------------------------------*/

         IF ( l_approved_flag = FND_API.G_FALSE AND p_adj_rec.status = 'A' )
         THEN
            p_adj_rec.status := 'W' ;
         END IF;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Amount()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Amount() ', G_MSG_UERROR);
        END IF;

	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Amount');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_Amount;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Rcvtrxccid                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the Receivables Trx Id and CCId       |
 |              It sets the set_of_books_id value in the adjustment record   |
 |              and also the code combination id (if required)               |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                  p_adj_rec                                                |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Rcvtrxccid (
		p_adj_rec	IN OUT NOCOPY 	ar_adjustments%rowtype,
                p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index			number;
l_set_of_books_id	ar_receivables_trx.set_of_books_id%type := NULL;
l_cc_id			ar_receivables_trx.code_combination_id%type := NULL;
l_count			number;
l_found			BOOLEAN;
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Rcvtrxccid()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to ERROR    |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_ERROR;

      l_found := FALSE ;

      FOR l_index IN 1..G_RCVTRX_TBL.COUNT LOOP

         IF (p_adj_rec.receivables_trx_id =
			     G_RCVTRX_TBL(l_index).receivables_trx_id )
         THEN
             G_receivables_name := G_RCVTRX_TBL(l_index).name ;
             l_cc_id := G_RCVTRX_TBL(l_index).code_combination_id;
             l_found := TRUE ;
             EXIT ;
         END IF;

      END LOOP;

      IF ( NOT l_found )
      THEN
 	 /*-----------------------------------------------+
	 |  Set the message                               |
      	 +-----------------------------------------------*/
            aapi_message(
                 p_application_name =>'AR',
                 p_message_name => 'AR_AAPI_INVALID_RCVABLE_TRX_ID',
                 p_token1_name =>'RECEIVABLES_TRX_ID',
                 p_token1_value => to_char(p_adj_rec.receivables_trx_id)
                ) ;
            RETURN ;
      END IF;

      /*--------------------------------------------+
      |  Check the Code Combination Id              |
      |  If no value is provided default it to the  |
      |  code combination Id of the receivables Trx |
      +--------------------------------------------*/

      IF ( p_adj_rec.code_combination_id IS NULL OR
           p_adj_rec.code_combination_id = 0 )
      THEN
         /*--------------------------------------------+
         | If no default value exists and none is      |
         | provided by user then set error             |
         +--------------------------------------------*/

          IF ( l_cc_id IS NULL OR l_cc_id = 0 )
          THEN
              aapi_message(
                    p_application_name =>'AR',
                    p_message_name => 'AR_AAPI_NO_CCID_FOR_ACTIVITY',
                    p_token1_name  => 'RECEIVABLES_TRX_ID',
                    p_token1_value => to_char(p_adj_rec.receivables_trx_id)
                          ) ;
              RETURN ;
          END IF ;

         /*--------------------------------------------+
         | Else default to the CCid of the Receivables |
         | Activity                                    |
         +--------------------------------------------*/

          p_adj_rec.code_combination_id := l_cc_id ;

      ELSE
         /*--------------------------------------------+
         |  Validate the code combination Id provided  |
         +--------------------------------------------*/

         l_found := FALSE ;

         FOR l_index IN 1..G_CCID_TBL.COUNT LOOP

            IF (G_CCID_TBL.EXISTS (p_adj_rec.code_combination_id))
            THEN
                l_found := TRUE;
                EXIT ;
            END IF;

         END LOOP;

         IF ( NOT l_found)
         THEN

             /*------------------------------------------+
             | Check the code combination from database  |
             +------------------------------------------*/
             BEGIN

                 l_count := 0 ;
                 SELECT count(*)
		   INTO l_count
                   FROM gl_code_combinations
                  WHERE code_combination_id  = p_adj_rec.code_combination_id
                    AND enabled_flag        = 'Y'
                    AND SYSDATE BETWEEN NVL(start_date_active, sysdate)
                    AND                 NVL(end_date_active, sysdate);

             EXCEPTION
                 WHEN OTHERS THEN
                     /*---------------------------------------------+
                     |Set unexpected error message and status       |
      	             +---------------------------------------------*/
	             FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Rcvtrxccid');
 	             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                     RETURN;
             END ;

             IF ( l_count <> 1 )
	     THEN
                /*-------------------------------------------+
	        |  Set the message                           |
      	        +-------------------------------------------*/
                aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_INVALID_CCID',
                        p_token1_name => 'CCID',
                        p_token1_value => p_adj_rec.code_combination_id
                       ) ;
                RETURN ;
             END IF;

         END IF;

         /*--------------------------------------------+
         |  Check that if the Profile Option : Allow   |
         |  Override of default activity is set to Y   |
         |  then value must be equal to l_cc_id        |
         +--------------------------------------------*/

         IF ( g_context_rec.override_activity_option = 'N' AND
              l_cc_id IS NOT NULL )
         THEN
             IF ( p_adj_rec.code_combination_id <> l_cc_id )
             THEN
                 aapi_message (
                           p_application_name =>'AR',
                           p_message_name => 'AR_AAPI_OVERRIDE_CCID_DISALLOW'
                          ) ;
                 RETURN ;
             END IF;
         END IF;

      END IF;

      /*-----------------------------------------------+
      |  Set the Set of books Id                       |
      +-----------------------------------------------*/

      p_adj_rec.set_of_books_id := arp_global.set_of_books_id ;

      p_return_status := FND_API.G_RET_STS_SUCCESS ;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Rcvtrxccid()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Rcvtrxccid', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Rcvtrxccid');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_Rcvtrxccid;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_dates                                               |
 | DESCRIPTION                                                               |
 |              This routine validates the apply and gl dates for both       |
 |              creation and reversal                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_dates (
		p_apply_date	IN 	ar_adjustments.apply_date%type,
                p_gl_date	IN	ar_adjustments.gl_date%type,
                p_ps_rec        IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index		number;
l_found_flag	BOOLEAN;
l_count 	number ;
l_set_of_books_id AR_SYSTEM_PARAMETERS.SET_OF_BOOKS_ID%TYPE ;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_dates()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to ERROR    |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_ERROR;

     /*------------------------------------------+
      |  The dates should not be null            |
      +-----------------------------------------*/

      IF ( p_apply_date IS NULL )
      THEN
         aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_NO_APPLY_DATE'
                       ) ;
         RETURN ;
      END IF;

      IF ( p_gl_date IS NULL )
      THEN
         aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_NO_GL_DATE'
                       ) ;
         RETURN ;
      END IF;

     /*------------------------------------------+
      |  Validate from GL date from period cache |
      |  Check that it lies in open/future period|
      +-----------------------------------------*/

      l_found_flag := FALSE ;

      FOR l_index IN 1..G_GLPERIOD_TBL.COUNT LOOP

            IF (trunc(p_gl_date) >=
		   nvl(G_GLPERIOD_TBL(l_index).start_date, trunc(p_gl_date))
				 AND
                trunc(p_gl_date) <=
		   nvl(G_GLPERIOD_TBL(l_index).end_date,trunc(p_gl_date))
	       )
            THEN
                l_found_flag := TRUE ;
                EXIT ;
            END IF;

      END LOOP;

      /*------------------------------------------+
      |  If it does not exist in cache validate it|
      |  from database                            |
      +------------------------------------------*/

      IF ( NOT l_found_flag )
      THEN

          select set_of_books_id
            into l_set_of_books_id
	    from ar_system_parameters;

          l_count := 0 ;

           SELECT count(*)
             INTO l_count
           FROM   gl_period_statuses g,
                  gl_sets_of_books   b
           WHERE  g.application_id          = 222
           AND    g.set_of_books_id         = l_set_of_books_id
           AND    g.set_of_books_id         = b.set_of_books_id
           AND    g.period_type             = b.accounted_period_type
           AND    g.adjustment_period_flag  = 'N'
           AND    g.closing_status IN ('O','F')
           AND    trunc(p_gl_date) BETWEEN nvl(trunc(g.start_date),
							  trunc(p_gl_date))
                               AND nvl(trunc(g.end_date),trunc(p_gl_date)) ;

          IF ( l_count > 0 )
          THEN
             l_found_flag := TRUE ;
          END IF;

      END IF;

      /*------------------------------------------+
      |  If no valid period found then set message|
      |  and return                               |
      +------------------------------------------*/

      IF ( NOT l_found_flag )
      THEN
          aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_GLDATE_INVALID_PERIOD',
                        p_token1_name => 'GL_DATE',
                        p_token1_value => to_char(p_gl_date,'DD-MON-YYYY')
                       ) ;
          RETURN;
      END IF;

      /*---------------------------------------+
      | Check that apply date should be equal  |
      | to or greater than the transaction date|
      +---------------------------------------*/

      IF ( trunc(p_apply_date) < trunc(p_ps_rec.trx_date) )
      THEN
           aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_APPLYDATE_LT_TRXDATE',
                      p_token1_name => 'APPLY_DATE',
                      p_token1_value => to_char(p_apply_date,'DD-MON-YYYY'),
                      p_token2_name => 'TRX_DATE',
                      p_token2_value => to_char(p_ps_rec.trx_date,'DD-MON-YYYY')
                     ) ;
           RETURN;
      END IF;

      /*---------------------------------------+
      | Check that GL date should be equal to  |
      | or greater than the transaction GL date|
      +---------------------------------------*/

      IF ( trunc(p_gl_date) < trunc(p_ps_rec.gl_date) )
      THEN
           aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_GLDATE_LT_TRXGLDATE',
                      p_token1_name => 'GL_DATE',
                      p_token1_value => to_char(p_gl_date,'DD-MON-YYYY'),
                      p_token2_name => 'TRX_GL_DATE',
                      p_token2_value => to_char(p_ps_rec.gl_date,'DD-MON-YYYY')
                     ) ;
           RETURN;
      END IF;

      /*------------------------------------+
      |  Check that GL date should be equal |
      |  to or greater than the apply date  |
      +------------------------------------*/

      /* ------------------------------This check is no longer valid
      IF ( trunc(p_gl_date) < trunc(p_apply_date) )
      THEN
           aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_GLDATE_LT_APPLYDATE',
                        p_token1_name => 'GL_DATE',
                        p_token1_value => to_char(p_gl_date,'DD-MON-YYYY'),
                        p_token2_name => 'APPLY_DATE',
                        p_token2_value => to_char(p_apply_date,'DD-MON-YYYY')
                       ) ;
           RETURN;
      END IF;
      ------------------------------------------------------------ */
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_dates()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_dates ', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_dates' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_dates;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_doc_seq                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the Document Sequence value and sets  |
 |              the Id also                                                  |
 |                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_doc_seq (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_dummy                BINARY_INTEGER;
l_sequence_name        fnd_document_sequences.name%type;
l_doc_sequence_id      fnd_document_sequences.doc_sequence_id%type ;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_doc_seq()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      /*------------------------------------------------+
      |  Document sequences are only applicable if the  |
      |  unique seq number option is not equal to N     |
      +------------------------------------------------*/

     IF ( NVL(g_context_rec.unique_seq_numbers, 'N') = 'N' )
     THEN
         IF ( p_adj_rec.doc_sequence_value IS NOT NULL OR
              p_adj_rec.doc_sequence_value <> 0 )
         THEN
             aapi_message(
                    p_application_name =>'AR',
                    p_message_name => 'AR_AAPI_DOC_SEQ_NOT_REQD',
                    p_token1_name => 'DOCUMENT_SEQ',
                    p_token1_value => to_char(p_adj_rec.doc_sequence_value)
		    );
             p_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         RETURN ;
     END IF;

     /*-----------------------------+
     |  Get the document sequence.  |
     +------------------------------*/

     p_adj_rec.doc_sequence_id := NULL;

     fnd_seqnum.get_seq_name (
                               arp_global.G_AR_APP_ID,
                               G_receivables_name,
                               arp_global.set_of_books_id,
                               'M',
                               p_adj_rec.apply_date,
                               l_sequence_name,
                               p_adj_rec.doc_sequence_id,
                               l_dummy
                             );

     IF ( l_sequence_name IS NOT NULL AND
          p_adj_rec.doc_sequence_id IS NOT NULL )
     THEN
        /*-----------------------------------------+
        |  Automatic Document Numbering case       |
        |  Document seuqence value should not exist|
        +-----------------------------------------*/

        IF ( p_adj_rec.doc_sequence_value IS NOT NULL OR
             p_adj_rec.doc_sequence_value <> 0 )
        THEN
             aapi_message(
                  p_application_name =>'AR',
                  p_message_name => 'AR_AAPI_DOC_SEQ_NOT_REQD',
                  p_token1_name => 'DOCUMENT_SEQ',
                  p_token1_value => to_char(p_adj_rec.doc_sequence_value)
		  );
             p_return_status := FND_API.G_RET_STS_ERROR;
             RETURN ;
        END IF;

        /*-----------------------------------------+
        |  Get the document sequence value         |
        +-----------------------------------------*/

        p_adj_rec.doc_sequence_value :=
                fnd_seqnum.get_next_sequence (
                                  arp_global.G_AR_APP_ID,
                                  G_receivables_name,
                                  arp_global.set_of_books_id,
                                  'M',
                                  p_adj_rec.apply_date,
                                  l_sequence_name,
                                  p_adj_rec.doc_sequence_id
                                  );

     ELSIF ( p_adj_rec.doc_sequence_id IS NOT NULL AND
             p_adj_rec.doc_sequence_value IS NOT NULL )
      THEN
           /*------------------------------------+
           |  Manual Document Numbering case     |
           |  with the document value specified. |
           |  Use the specified value.           |
           +-------------------------------------*/
           NULL;

     ELSIF ( p_adj_rec.doc_sequence_id IS NOT NULL  AND
             p_adj_rec.doc_sequence_value IS NULL )
      THEN
          /*-------------------------------------------+
          |  Manual Document Numbering case            |
          |  with the document value not specified.    |
          |  Generate a document value mandatory error |
          +-----------------------------------------*/
          aapi_message(
                       p_application_name =>'FND',
                       p_message_name => 'UNIQUE-NO VALUE'
		       );
          p_return_status := FND_API.G_RET_STS_ERROR;
          RETURN ;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_doc_seq()-', G_MSG_MEDIUM);
     END IF;

     RETURN ;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
             /*-----------------------------------------+
             |  No document assignment was found.       |
             |  Generate an error if document numbering |
             |  is mandatory.                           |
             +-----------------------------------------*/
             IF (g_context_rec.unique_seq_numbers = 'A' )
             THEN
                 aapi_message(
                       p_application_name =>'FND',
                       p_message_name => 'UNIQUE-ALWAYS USED'
		       );
                 p_return_status := FND_API.G_RET_STS_ERROR;
             ELSE
                 p_adj_rec.doc_sequence_id    := NULL;
                 p_adj_rec.doc_sequence_value := NULL;
             END IF;
             RETURN;

    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_doc_seq ', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_doc_seq' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_doc_seq;


/*===========================================================================+
 | PROCEDURE    Validate_reason_code                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the reason code of adjustment         |
 |                                                                           |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT:                                                         |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                  p_return_status                                          |
 |                   p_adj_rec                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Reason_code (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index		number;
l_found		BOOLEAN;
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Reason_code()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to ERROR    |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_ERROR;

      /*------------------------------------------+
      |  Validate only is value is provided       |
      +------------------------------------------*/

      IF ( p_adj_rec.reason_code IS NOT NULL AND
           p_adj_rec.reason_code <> ' ' )
      THEN

          l_found := FALSE ;

          FOR l_index IN 1..G_REASON_TBL.COUNT LOOP

            IF (p_adj_rec.reason_code = G_REASON_TBL(l_index).lookup_code)
            THEN
                l_found := TRUE ;
                EXIT ;
            END IF;

          END LOOP;

          IF ( NOT l_found )
          THEN
 	     /*-----------------------------------------------+
	     |  Set the message                               |
      	     +-----------------------------------------------*/
             aapi_message(
                          p_application_name =>'AR',
                          p_message_name => 'AR_AAPI_INVALID_REASON_CODE',
                          p_token1_name => 'REASON_CODE',
                          p_token1_value => p_adj_rec.reason_code
                          ) ;
	     RETURN ;

          END IF;

      END IF ;

      p_return_status := FND_API.G_RET_STS_SUCCESS ;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Reason_Code()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Reason_code ', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_Reason_code' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_Reason_code;


/*===========================================================================+
 | PROCEDURE     Validate_Desc_Flexfield                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |		 Validates descriptive flexfields using the flex API.        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |		This validation is currently disabled because it doesn't     |
 |		work correctly. The descriptive flexfield API functions      |
 |		that this routine uses are not yet production code and are   |
 |		unstable.						     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder      01-JUL-97  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Desc_Flexfield(
                          p_adj_rec		IN OUT NOCOPY	ar_adjustments%rowtype,
		          p_return_status	IN OUT NOCOPY	varchar2
	                 ) IS

l_flex_name	fnd_descriptive_flexs.descriptive_flexfield_name%type;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Desc_Flexfield()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      /*------------------------------------------+
      |  Get the flexfield name                   |
      +------------------------------------------*/

      BEGIN

         SELECT  descriptive_flexfield_name
           INTO  l_flex_name
           FROM  fnd_descriptive_flexs
          WHERE  application_id = arp_global.G_AR_APP_ID AND
                 application_table_name like 'AR_ADJUSTMENTS' ;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              RETURN;

         WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('EXCEPTION: Validate_Desc_Flexfield', G_MSG_UERROR);
             END IF;
	      /*-----------------------------------------------+
              |  Set unexpected error message and status       |
      	      +-----------------------------------------------*/
	      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_Desc_Flexfield' );
	      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              RETURN;
      END ;


     /*--------------------------------------------------------------------+
     |  Call the flexfield routines to validate the transaction flexfield. |
     +--------------------------------------------------------------------*/

     fnd_flex_descval.set_context_value(p_adj_rec.attribute_category);

     fnd_flex_descval.set_column_value('ATTRIBUTE1',  p_adj_rec.attribute1);
     fnd_flex_descval.set_column_value('ATTRIBUTE2',  p_adj_rec.attribute2);
     fnd_flex_descval.set_column_value('ATTRIBUTE3',  p_adj_rec.attribute3);
     fnd_flex_descval.set_column_value('ATTRIBUTE4',  p_adj_rec.attribute4);
     fnd_flex_descval.set_column_value('ATTRIBUTE5',  p_adj_rec.attribute5);
     fnd_flex_descval.set_column_value('ATTRIBUTE6',  p_adj_rec.attribute6);
     fnd_flex_descval.set_column_value('ATTRIBUTE7',  p_adj_rec.attribute7);
     fnd_flex_descval.set_column_value('ATTRIBUTE8',  p_adj_rec.attribute8);
     fnd_flex_descval.set_column_value('ATTRIBUTE9',  p_adj_rec.attribute9);
     fnd_flex_descval.set_column_value('ATTRIBUTE10', p_adj_rec.attribute10);
     fnd_flex_descval.set_column_value('ATTRIBUTE11', p_adj_rec.attribute11);
     fnd_flex_descval.set_column_value('ATTRIBUTE12', p_adj_rec.attribute12);
     fnd_flex_descval.set_column_value('ATTRIBUTE13', p_adj_rec.attribute13);
     fnd_flex_descval.set_column_value('ATTRIBUTE14', p_adj_rec.attribute14);
     fnd_flex_descval.set_column_value('ATTRIBUTE15', p_adj_rec.attribute15);

     IF ( NOT fnd_flex_descval.validate_desccols ('AR', l_flex_name) )
     THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_INVALID_DESC_FLEX'
                       ) ;
           RETURN ;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Validate_Desc_Flexfield()-', G_MSG_MEDIUM);
     END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION: Validate_Desc_Flexfield', G_MSG_UERROR);
         END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_Desc_Flexfield' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_Desc_Flexfield;

 /*==========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Created_From                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the Created From field of adjustment  |
 |                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Created_From (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Created_From()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( p_adj_rec.created_from IS NULL OR
           p_adj_rec.created_from = ' ' )
      THEN
          /*------------------------------------------+
	  |  Set the message                          |
      	  +------------------------------------------*/
          aapi_message(
                      p_application_name =>'AR',
                      p_message_name => 'AR_AAPI_NO_CREATED_FROM'
                      ) ;
          p_return_status := FND_API.G_RET_STS_ERROR;
          RETURN ;
      END IF;


      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Created_From ()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Created_From()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Created_From'
			);
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_Created_From;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Ussgl_code                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the USSGL code  of adjustment         |
 |              and also sets the context                                    |
 |                                                                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                   p_adj_rec                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Ussgl_code (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_index		number;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Ussgl_code()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to ERROR    |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_ERROR;

      /*------------------------------------------+
      |  Validate based on option                 |
      +------------------------------------------*/

      IF ( g_context_rec.ussgl_option = 'Y' )
      THEN
         /*------------------------------------------+
         |  Validate from the cache                  |
         +------------------------------------------*/
         FOR l_index IN 1..G_USSGL_TBL.COUNT LOOP

            IF (p_adj_rec.ussgl_transaction_code =
				   G_USSGL_TBL(l_index).ussgl_code)
            THEN
                p_adj_rec.ussgl_transaction_code_context :=
				   G_USSGL_TBL(l_index).ussgl_context;
                p_return_status := FND_API.G_RET_STS_SUCCESS;
                EXIT ;
            END IF;

         END LOOP;

         IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS )
         THEN
            /*-----------------------------------------------+
	    |  Set the message                               |
      	    +-----------------------------------------------*/
            aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_INVALID_USSGL_CODE',
                        p_token1_name => 'USSGL_CODE',
                        p_token1_value => p_adj_rec.ussgl_transaction_code
                       ) ;
            RETURN;
         END IF;

       ELSE

         /*------------------------------------------+
         |  No USSGL code should be provided         |
         +------------------------------------------*/
          IF ( p_adj_rec.ussgl_transaction_code IS NOT NULL AND
              p_adj_rec.ussgl_transaction_code <> ' ' )
          THEN
              aapi_message(
                        p_application_name =>'AR',
                        p_message_name => 'AR_AAPI_USSGL_CODE_DISALLOW',
                        p_token1_name => 'USSGL_CODE',
                        p_token1_value => p_adj_rec.ussgl_transaction_code
                       ) ;
              RETURN;
          ELSE
             p_return_status := FND_API.G_RET_STS_SUCCESS;
          END IF ;
       END IF ;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Ussgl_Code()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Ussgl_code ', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, 'Validate_Ussgl_code' );
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RETURN;

END Validate_Ussgl_code;

 /*==========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Associated_Receipt                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the associated cash_receipt_id        |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     arp_util.enable_debug                                                 |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |									     |
 |              OUT:                                                         |
 |                  p_return_status                                          |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Vivek Halder   13-JUN-97                                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Associated_Receipt (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_count		number;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Associated_Receipt()+', G_MSG_MEDIUM);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( p_adj_rec.associated_cash_receipt_id IS NOT NULL AND
           p_adj_rec.associated_cash_receipt_id <> 0 )
      THEN
           /*------------------------------------------+
           |  Validate the Cash Receipt Id             |
           +------------------------------------------*/

           l_count := 0 ;

           SELECT count(*)
             INTO l_count
             FROM ar_cash_receipts
            WHERE cash_receipt_id = p_adj_rec.associated_cash_receipt_id ;

           IF ( l_count <> 1 )
           THEN
              /*------------------------------------------+
	      |  Set the message                          |
      	      +------------------------------------------*/
              aapi_message(
                 p_application_name =>'AR',
                 p_message_name => 'AR_AAPI_INVALID_RECEIPT_ID',
                 p_token1_name =>'ASSOCIATED_CASH_RECEIPT_ID',
                 p_token1_value =>to_char(p_adj_rec.associated_cash_receipt_id)
                 ) ;
              p_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
           END IF;

      END IF ;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Associated_Receipt()-', G_MSG_MEDIUM);
      END IF;

      RETURN ;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Associated_Receipt', G_MSG_UERROR);
           arp_util.debug('EXCEPTION: Validate_Associated_Receipt for Receipt Id '
		       || p_adj_rec.associated_cash_receipt_id, G_MSG_HIGH );
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Associated_Receipt');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_Associated_Receipt;
END ar_adjvalidate_pub;

/
