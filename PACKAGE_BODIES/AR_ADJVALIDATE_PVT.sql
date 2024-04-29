--------------------------------------------------------
--  DDL for Package Body AR_ADJVALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ADJVALIDATE_PVT" AS
/* $Header: ARXVADJB.pls 120.13.12010000.2 2008/11/13 10:14:42 dgaurab ship $*/
G_PKG_NAME	CONSTANT VARCHAR2(30)	:='AR_ADJVALIDATE_PVT';

G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

G_caching_done		varchar2(1) := FND_API.G_FALSE;
G_cache_date		date := NULL ;
G_receivables_name	ar_receivables_trx.name%type := NULL;
G_cache_org_id          ar_receivables_trx.org_id%TYPE;

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

/*--------------------------------------------------------------------------+
 | Accounting_affect_flag has been added for the BR/BOE project.            |
 | This flag would indicate that whether any accounting enteries need to    |
 | created or not. Also the code_combination_id will be set to null if the  |
 | accounting_affect_flag is set to 'N'                                     |
 +---------------------------------------------------------------------------*/
TYPE Rcvtrx_Rec_Type	IS RECORD
     (
	receivables_trx_id 	ar_receivables_trx.RECEIVABLES_TRX_ID%type,
        name			ar_receivables_trx.NAME%type,
        type                    ar_receivables_trx.TYPE%type,
        code_combination_id	ar_receivables_trx.CODE_COMBINATION_ID%type,
        accounting_affect_flag  ar_receivables_trx.ACCOUNTING_AFFECT_FLAG%type,
	gl_account_source       ar_receivables_trx.GL_ACCOUNT_SOURCE%type  /*Bug 2925924*/
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

/*
  bug 3751203 : make l_lookup_csr global to the package, reuse it
  by parameterizing the lookup_type affects : Cache_Approval_Type,
  Cache_Adjustment_Type and Cache_Adjustment_Reason
*/

CURSOR l_lookup_csr (l_lookup_type IN AR_LOOKUPS.LOOKUP_TYPE%TYPE) IS
       SELECT lookup_code
         FROM ar_lookups
        WHERE lookup_type = l_lookup_type
          AND   enabled_flag = 'Y'
          AND   trunc(sysdate) BETWEEN nvl(trunc(start_date_active),
                                           trunc(sysdate))
                                   AND nvl(trunc(end_date_active),trunc(sysdate)) ;

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

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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

    BEGIN
        SELECT set_of_books_id
          INTO l_set_of_books_id
          FROM ar_system_parameters ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Cache_Gl_Periods: ' || 'No Open/Future Enterable GL periods exist',G_MSG_HIGH);
            END IF;
            /*-----------------------------------------------+
            |  Set the message                               |
            +-----------------------------------------------*/
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_OPEN_FUTURE_PERIOD');
            FND_MESSAGE.SET_TOKEN ( 'SET_OF_BOOKS_ID',   to_char(arp_global.set_of_books_id)) ;
            FND_MSG_PUB.ADD ;

            p_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('EXCEPTION: Cache_Gl_Periods()', G_MSG_UERROR);
            END IF;
            /*-----------------------------------------------+
            |  Set unexpected error message and status       |
            +-----------------------------------------------*/
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Cache_Gl_Periods');
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    END;

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
        FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_OPEN_FUTURE_PERIOD');
        FND_MESSAGE.SET_TOKEN ( 'SET_OF_BOOKS_ID',   to_char(arp_global.set_of_books_id)) ;
        FND_MSG_PUB.ADD ;

        p_return_status := FND_API.G_RET_STS_ERROR;
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

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Approval_Type()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr('APPROVAL_TYPE') LOOP
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

       FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_APPROVAL_CODES');
       FND_MSG_PUB.ADD ;

       p_return_status := FND_API.G_RET_STS_ERROR ;

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
 |    Vivek Halder   11-JUL-97  Created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Cache_Adjustment_Type (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Adjustment_Type()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr('ADJUSTMENT_TYPE') LOOP
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
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_TYPE_CODES');
            FND_MSG_PUB.ADD ;

            p_return_status := FND_API.G_RET_STS_ERROR ;

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

    l_index   	BINARY_INTEGER default 0;
    l_temp_rec  Lookup_Rec_Type;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Cache_Adjustment_Reason()+' , G_MSG_HIGH);
    END IF;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FOR l_temp_rec IN l_lookup_csr('ADJUST_REASON') LOOP
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
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_REASON_CODES');
            FND_MSG_PUB.ADD ;

            p_return_status := FND_API.G_RET_STS_ERROR ;

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
 |    Vivek Halder   11-JUL-97  Created                                      |
 |    Saloni Shah    03-FEB-00  Changes made for BOE/BR project.             |
 |                              Added a column (accounting_affect_flag) in   |
 |                              the select clause.                           |
 |    SNAMBIAR       31-May-00  Bug 1290698 . Included type ENDORSEMENT also |
 |                              BOE/BR
 |    SNAMBIAR       31-Jan-01  Bug 1620930 .                                |
 |    SNAMBIAR       02-Apr-01  Modified the cursor to pickup receivables trx|
 |                              id -12 which is used for deduction chargeback|
 |                              reversal
 |    M Raymond      30-JUL-02  Bug 2441496 - Need to add FINCHRG to
 |                              list of cached receivables trx.
 +===========================================================================*/

PROCEDURE Cache_Receivables_Trx (p_return_status IN OUT NOCOPY VARCHAR2 )
IS

    CURSOR l_receivables_csr  IS
           SELECT receivables_trx_id,name,type,code_combination_id ,accounting_affect_flag,
	          gl_account_source /*Bug 2925924*/
             FROM ar_receivables_trx
            WHERE nvl(status,'A') = 'A'
            AND   type in ('ADJUST','ENDORSEMENT','FINCHRG')
            AND   receivables_trx_id not in (-11,-13 )
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

            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_RECEIVABLES_TRX');
            FND_MSG_PUB.ADD ;

            p_return_status := FND_API.G_RET_STS_ERROR ;

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

       FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_USSGL_CODES');
       FND_MSG_PUB.ADD ;

       p_return_status := FND_API.G_RET_STS_SUCCESS ;

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

       FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CCID');
       FND_MSG_PUB.ADD ;

       p_return_status := FND_API.G_RET_STS_ERROR ;

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
l_return_status         varchar2(1);
l_current_org_id        ar_receivables_trx.org_id%TYPE;

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

       -- bug 2822474 : this line does not seem necessary
       -- Bug 4038942 : re-cache the data only if org_id has changed
       l_current_org_id := fnd_global.org_id;
       IF NVL(l_current_org_id,-88888) <> NVL(G_cache_org_id,-88888) THEN
         G_cache_org_id := l_current_org_id;
         l_tobe_cached_flag := FND_API.G_TRUE;
       END IF;

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
       |  Initialize return status to SUCCESS             |
       +-------------------------------------------------*/
           p_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-------------------------------------------------+
       |   Cache Approval type. To be used for validation |
       |   of status                                      |
       +-------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_approval_type (l_return_status);

       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
             p_return_status := l_return_status;
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Cache_Details: ' || ' failed to cache approval_type');
             END IF;
       END IF;
       /*-------------------------------------------------+
       |   Cache reason codes for adjustment. To be used  |
       |   for validation of adjustment reason codes      |
       +-------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_adjustment_reason (l_return_status);
       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache adjustment_reason');
            END IF;
       END IF;

       /*-------------------------------------------------+
       |   Cache adjustment types i.e. INVOICE, LINE etc. |
       |   To be used for validation of type              |
       +-------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_adjustment_type (l_return_status);
       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache adjustment_type');
            END IF;
       END IF;

       /*-------------------------------------------------+
       |   Cache Receivables transaction ids. To be used  |
       |   for validation of Receivables trx id           |
       +-------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_receivables_trx (l_return_status) ;

       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache receivables_trx');
            END IF;
       END IF;

       /*-------------------------------------------------+
       |   Cache USSGL transaction information. To be used|
       |   for validation of USSGL transaction code       |
       +-------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_ussgl_code (l_return_status);
       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache ussgl_code');
            END IF;
       END IF;

       /*--------------------------------------------------+
       |   Cache GL periods. To be used to validate if GL  |
       |   dates lie within open or future enterable period|
       +--------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_gl_periods(l_return_status);
       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache gl_periods');
            END IF;
       END IF;

       /*--------------------------------------------------+
       |   Cache Code combination Ids. To be used to       |
       |   validate input provided by user                 |
       +--------------------------------------------------*/

       AR_ADJVALIDATE_PVT.cache_code_combination (l_return_status);
       IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
       THEN
            p_return_status := l_return_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug ('Cache_Details: ' || ' failed to cache code_combination');
            END IF;
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
             AND    currency_code = p_inv_curr_code
             AND    document_type = 'ADJ';

       EXCEPTION
          WHEN NO_DATA_FOUND THEN

	     IF PG_DEBUG in ('Y', 'C') THEN
	        arp_util.debug ('Within_approval_limits: ' || 'User Id : ' || l_user_id);
                arp_util.debug ('Within_approval_limits: ' ||
                       'User does not have approval limits for currency ' ||
                       p_inv_curr_code, G_MSG_HIGH
                       );
             END IF;

            FND_MESSAGE.SET_NAME ('AR', 'AR_VAL_USER_LIMIT');
            FND_MESSAGE.SET_TOKEN ( 'CURRENCY',  p_inv_curr_code ) ;
            FND_MSG_PUB.ADD ;
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

               FND_MESSAGE.SET_NAME ('AR', 'AR_VAL_AMT_APPROVAL_LIMIT');
               FND_MSG_PUB.ADD ;

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
 |              validate_buckets                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine checks if the various buckets of an adjustment  |
 |              are correct incase they have been specified while creating   |
 |              an INVOICE type adjustment.                                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    JASSING   01-MAY-2005   Bug 4258945                                    |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Validate_buckets(
               	p_adj_rec	      IN   ar_adjustments%rowtype,
		p_ps_rec	      IN   ar_payment_schedules%rowtype,
      p_return_status	IN OUT NOCOPY varchar2
   ) IS

BEGIN

             IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate buckets()+', G_MSG_MEDIUM);
             END IF;

             /*------------------------------------------+
             |  Initialize the return status to SUCCESS  |
             +------------------------------------------*/

             p_return_status := FND_API.G_RET_STS_SUCCESS;

	     /*Verify the data in other buckets if they have been entered by the user.
	       If data is entered for any of the bucket while invoking the API, then
	       it must be validated for all the buckets.
	     */

	     IF   (p_adj_rec.line_adjusted IS NOT NULL
	        OR p_adj_rec.tax_adjusted IS NOT NULL
		OR p_adj_rec.freight_adjusted IS NOT NULL
		OR p_adj_rec.receivables_charges_adjusted IS NOT NULL)
	     THEN
	        /*Check line bucket*/

		IF (p_adj_rec.line_adjusted is NULL
		   AND p_ps_rec.amount_line_items_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_INC_BUCKET');
		   FND_MESSAGE.SET_TOKEN('BUCKET','LINE');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF (p_adj_rec.line_adjusted + p_ps_rec.amount_line_items_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_ADJ_BUCKETS');
		   FND_MESSAGE.SET_TOKEN('BUCKET','LINE');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

		/*Check tax bucket*/

	        IF (p_adj_rec.tax_adjusted is NULL
		   AND p_ps_rec.tax_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_INC_BUCKET');
		   FND_MESSAGE.SET_TOKEN('BUCKET','TAX');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF (p_adj_rec.tax_adjusted + p_ps_rec.tax_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_ADJ_BUCKETS');
		   FND_MESSAGE.SET_TOKEN('BUCKET','TAX');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

                /*Check freight bucket*/

		IF (p_adj_rec.freight_adjusted is NULL
		   AND p_ps_rec.freight_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_INC_BUCKET');
		   FND_MESSAGE.SET_TOKEN('BUCKET','FREIGHT');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF (p_adj_rec.freight_adjusted + p_ps_rec.freight_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_ADJ_BUCKETS');
		   FND_MESSAGE.SET_TOKEN('BUCKET','FREIGHT');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

		/*Check charges bucket*/

		IF (p_adj_rec.receivables_charges_adjusted is NULL
		   AND p_ps_rec.receivables_charges_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_INC_BUCKET');
		   FND_MESSAGE.SET_TOKEN('BUCKET','CHARGES');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
		ELSIF (p_adj_rec.receivables_charges_adjusted + p_ps_rec.receivables_charges_remaining <> 0)
		THEN
		   FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_ADJ_BUCKETS');
		   FND_MESSAGE.SET_TOKEN('BUCKET','CHARGES');
		   FND_MSG_PUB.ADD;

                   p_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
             END IF;

	     IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate buckets()-', G_MSG_MEDIUM);
             END IF;

	     RETURN;

EXCEPTION
    WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_buckets()', G_MSG_UERROR);
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_buckets'
			);
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;

END Validate_buckets;


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
      |  Initialize the return status to ERROR  |
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

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_ADJUSTMENT_TYPE');
         FND_MESSAGE.SET_TOKEN ( 'TYPE',  p_adj_rec.type ) ;
         FND_MSG_PUB.ADD ;

      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Type()-', G_MSG_MEDIUM);
      END IF;


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
 |    Vivek Halder    30-JUNE-97  Created                                    |
 |    Satheesh Nambir 01-Jun-00 Bug 1290698. Added one more class 'BR' for   |
 |                              BOE/BR Project
 |  Satheesh Nambiar  25-Aug-00 Modified the code to process $0 adjustment |
 |                              and process line without customer_trx_line_id
 |                              Bug 1395396                                |
+==========================================================================*/

PROCEDURE Validate_Payschd (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_ps_rec	IN OUT NOCOPY	ar_payment_schedules%rowtype,
		p_return_status	OUT NOCOPY	Varchar2,
		p_from_llca_call    IN  varchar2 DEFAULT 'N'
               ) IS

l_index			BINARY_INTEGER ;
l_count			number:= 0 ;

-- Line Level Adjustment
l_customer_trx_id	number;
l_customer_trx_line_id  number;
l_receivables_trx_id    number;

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_util.debug('Validate_Payschd()+', G_MSG_MEDIUM);
	   arp_util.debug('p_from_llca_call :'|| p_from_llca_call);
	END IF;

	/*------------------------------------------+
	|  Initialize the return status to SUCCESS  |
	+------------------------------------------*/

        p_return_status := FND_API.G_RET_STS_SUCCESS;

	--  Initialize Line Level Adjustment
	l_customer_trx_id	:= p_adj_rec.customer_trx_id;
	l_customer_trx_line_id  := p_adj_rec.customer_trx_line_id;
	l_receivables_trx_id    := p_adj_rec.receivables_trx_id;

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

                 FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_PAYSCHD');
                 FND_MESSAGE.SET_TOKEN ( 'PAYMENT_SCHEDULE_ID',  to_char(p_adj_rec.payment_schedule_id)) ;
                 FND_MSG_PUB.ADD ;

		 p_return_status := FND_API.G_RET_STS_ERROR;

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_util.debug('Validate_Payschd: ' || 'payment schedule id is invalid');
                 END IF;

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

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_PAYSCHD');
         FND_MESSAGE.SET_TOKEN('PAYMENT_SCHEDULE_ID',to_char(p_adj_rec.payment_schedule_id)) ;
         FND_MSG_PUB.ADD ;
         p_return_status := FND_API.G_RET_STS_ERROR;
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('Validate_Payschd: ' || 'payment schedule id is invalid');
         END IF;
      END ;

      /*-----------------------------------------------+
      |  Check that the class of transaction is valid  |
      +-----------------------------------------------*/
      /*------------------------------------------------------------+
      |  Bug 1290698- Added one more class 'BR' for BOE/BR project  |
      +-------------------------------------------------------------*/
      --snambiar added chargeback also in the list for adjustment
      IF ( p_ps_rec.class NOT IN ( 'INV','DM','CM','DEP','GUAR','BR','CB') )
      THEN

          FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_TRX_CLASS');
          FND_MESSAGE.SET_TOKEN ( 'CLASS',  p_ps_rec.class ) ;
          FND_MSG_PUB.ADD ;

	  p_return_status := FND_API.G_RET_STS_ERROR;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_Payschd: ' || 'class of transaction is invalid');
          END IF;
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

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CUSTOMER_TRX_ID');
         FND_MESSAGE.SET_TOKEN('PAYMENT_SCHEDULE_ID',to_char(p_adj_rec.payment_schedule_id));
         FND_MSG_PUB.ADD ;
	 p_return_status := FND_API.G_RET_STS_ERROR;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_Payschd: ' || 'there is no valid customer trx id for the paysch id');
          END IF;

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

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CUSTOMER_ID');
         FND_MESSAGE.SET_TOKEN('PAYMENT_SCHEDULE_ID',to_char(p_adj_rec.payment_schedule_id));
         FND_MSG_PUB.ADD ;

	 p_return_status := FND_API.G_RET_STS_ERROR;
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_Payschd: ' || 'there is no valid customer id for the paysch id');
          END IF;

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
        --Bug 1395396 Modified <> to check for customer_trx_line_id for handling seperate
          IF (nvl(p_adj_rec.customer_trx_line_id,0) > 0 ) THEN
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
                 IF p_from_llca_call <> 'Y' THEN
		     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Payschd');
	             p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                     RETURN;
		 ELSE
			insert into ar_llca_adj_trx_errors_gt
			(
				customer_trx_id,
				customer_trx_line_id,
				receivables_trx_id,
				error_message,
				invalid_value
			)
			values
			(
				l_customer_trx_id,
				l_customer_trx_line_id,
				l_receivables_trx_id,
				'Validate_Payschd',
				'payment_sch_id'
			);
			p_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

            END ;

            IF ( l_count <> 1 ) THEN
               /*-----------------------------------------------+
       	       |  Set error message and status                  |
      	       +-----------------------------------------------*/
             IF p_from_llca_call <> 'Y' THEN
	       FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CUSTOMER_TRX_LINEID');
               FND_MESSAGE.SET_TOKEN('CUSTOMER_TRX_LINE_ID',to_char(p_adj_rec.customer_trx_line_id) ) ;
               FND_MESSAGE.SET_TOKEN('CUSTOMER_TRX_ID',to_char(p_adj_rec.customer_trx_id));
               FND_MSG_PUB.ADD ;

               p_return_status := FND_API.G_RET_STS_ERROR;
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Validate_Payschd: ' || 'customer trx line id is invalid');
               END IF;

	     ELSE
			insert into ar_llca_adj_trx_errors_gt
			(
				customer_trx_id,
				customer_trx_line_id,
				receivables_trx_id,
				error_message,
				invalid_value
			)
			values
			(
				l_customer_trx_id,
				l_customer_trx_line_id,
				l_receivables_trx_id,
				'AR_AAPI_NO_CUSTOMER_TRX_LINEID',
				'payment_sch_id'
			);
			p_return_status := FND_API.G_RET_STS_ERROR;
	      END IF;

            END IF ;
            -- Bug 1395396 - IF customer trx line id is null then do not raise error message
            -- Modification for LINE adjustment without line id
         /*

          ELSE
            -- ARTA Changes, removing the check if type='LINE' then Line Id
            -- must be provided
            IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
               null;
            ELSE

              --   Set error message when the type is line and the |
              --   customer_trx_line_id is null                    |
               FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CUSTOMER_TRX_LINEID');
               FND_MESSAGE.SET_TOKEN('CUSTOMER_TRX_LINE_ID',to_char(p_adj_rec.customer_trx_line_id) ) ;
               FND_MESSAGE.SET_TOKEN('CUSTOMER_TRX_ID',to_char(p_adj_rec.customer_trx_id));
               FND_MSG_PUB.ADD ;

               p_return_status := FND_API.G_RET_STS_ERROR;

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Validate_Payschd: ' || 'customer trx line id is missing for adj type = LINE');
               END IF;
            END IF;
        */
          END IF ;

      ELSE
          /*-----------------------------------------------+
          |  The Customer Trx Line Id should not be there  |
          +-----------------------------------------------*/

          IF ( p_adj_rec.customer_trx_line_id IS NOT NULL OR
               p_adj_rec.customer_trx_line_id <> 0 )
          THEN

            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_LINE_ID_FOR_NONLINE');
            FND_MESSAGE.SET_TOKEN ( 'CUSTOMER_TRX_LINE_ID',  to_char(p_adj_rec.customer_trx_line_id) ) ;
            FND_MESSAGE.SET_TOKEN ( 'TYPE',  p_ps_rec.class ) ;
            FND_MSG_PUB.ADD ;

               p_return_status := FND_API.G_RET_STS_ERROR;
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('Validate_Payschd: ' || 'customer trx line id is not required for adj type ');
               END IF;
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
 |    Saloni Shah    03-FEB-00  Changes for BOE/BR project has been made.    |
 |                              Two new parameters have been introduced.     |
 |                              p_chk_approval_limits: this flag indicates   |
 |                              if the check for the adjustment amount should|
 |                              be validated against the approval user limits|
 |                              or not.                                      |
 |                              p_check_amount: this flag is set to 'N'      |
 |                              indicates that this is a reversal of an      |
 |                              adjustment and hence the amount_due_remaining|
 |                              will not be zero.                            |
 |   Satheesh Nambiar 25-Aug-00 Bug 1395396 Modified the code process $0     |
 |                              adjustment                                   |
 |   skoukunt         31-MAY-01 Bug 1773947, should not check approval limits|
 |                              when creating adjustment from cash engine,   |
 |                              split merge, DMS interface, deductions in    |
 |                              receipts W/B, this should works if we change |
 |                              p_chk_approval_limits to false while calling |
 |                              adjustment API, but the changes need to be   |
 |                              made in number of files and not sure if      |
 |                              setting the parameter would effect anything  |
 |                              else. This condition was removed while making|
 |                              the API generic.                             |
+===========================================================================*/

PROCEDURE Validate_amount (
               	p_adj_rec	      IN OUT NOCOPY ar_adjustments%rowtype,
		p_ps_rec	      IN     ar_payment_schedules%rowtype,
                p_chk_approval_limits IN     varchar2,
                p_check_amount        IN     varchar2,
		p_return_status	      IN OUT NOCOPY varchar2
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

      /*----------------------------------------------------------------------+
      | If the type is INVOICE then the amount must close the invoice         |
      |                                                                       |
      | Change for the BOE/BR project has been made if the value of the       |
      | flag p_check_amount is 'F'indicating that this is an adjustment       |
      | reversal at invoice level, then amount_due remaining will not be zero |
      +-----------------------------------------------------------------------*/
      IF ( p_adj_rec.type = 'INVOICE'  AND
       	   p_check_amount = FND_API.G_TRUE)
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

                FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_ADR_ZERO_INV');
                FND_MSG_PUB.ADD ;

		p_return_status := FND_API.G_RET_STS_ERROR ;
	     END IF;
             p_adj_rec.amount := - p_ps_rec.amount_due_remaining ;
             /*Bug 4258945*/
	                    validate_buckets(p_adj_rec,
	                                     p_ps_rec,
					     l_return_status);
             IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
             THEN
                 p_return_status := l_return_status ;
             END IF ;
         ELSE
             IF ( p_adj_rec.amount + p_ps_rec.amount_due_remaining <> 0 )
             THEN

                FND_MESSAGE.SET_NAME ('AR', 'AR_TW_VAL_AMT_ADJ_INV');
                FND_MSG_PUB.ADD ;

                p_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
             /*Bug 4258945*/
	                    validate_buckets(p_adj_rec,
	                                     p_ps_rec,
					     l_return_status);
             IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
             THEN
                 p_return_status := l_return_status ;
             END IF ;
         END IF;

	 /*Bug 4258945
	   Calculate all the buckets over here.
         */
	 p_adj_rec.line_adjusted := -p_ps_rec.amount_line_items_remaining;
	 p_adj_rec.tax_adjusted := -p_ps_rec.tax_remaining;
	 p_adj_rec.freight_adjusted := -p_ps_rec.freight_remaining;
	 p_adj_rec.receivables_charges_adjusted := -p_ps_rec.receivables_charges_remaining;
      END IF;

      /*-----------------------------------------------+
      |  Check if the adjustment amount is zero        |
      +-----------------------------------------------*/
      --Bug 1395396 Removed the check for p_adj_rec.amount = 0 for
      --Processing $0 adjustment

      IF ( p_adj_rec.amount IS NULL)
      THEN
         /*--------------------------------------------+
	 |  Set the message and return                 |
      	 +--------------------------------------------*/

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_ADJ_AMOUNT_ZERO');
         FND_MSG_PUB.ADD ;

         p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      /*------------------------------------------------+
      |  Verify if amount is within user approval limits|
      +-------------------------------------------------*/
     /*----------------------------------------------------+
      |  Change introduced for the BR/BOE project.         |
      |  Special processing for bypassing limit check if   |
      |  p_chk_approval_limits is set to 'F'               |
      +---------------------------------------------------*/
      -- Added OR conditions for bug fix 1773947
      IF ( p_chk_approval_limits = FND_API.G_FALSE OR
           p_adj_rec.created_from LIKE 'CASH_ENGINE%' OR
           p_adj_rec.created_from LIKE 'RECEIPT_REVERSAL%' OR
           p_adj_rec.created_from LIKE 'SPLIT_MERGE%' OR
           p_adj_rec.created_from LIKE 'DMS_INTERFACE%' OR
           p_adj_rec.created_from LIKE 'ENHANCED_CASH%' )
      THEN
          l_approved_flag := FND_API.G_TRUE ;
      ELSE
          AR_ADJVALIDATE_PVT.Within_approval_limits (
                    p_adj_rec.amount,
                    p_ps_rec.invoice_currency_code,
                    l_approved_flag,
                    l_return_status
                   ) ;
         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
         THEN
            p_return_status := l_return_status ;
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

            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_CREATE_STATUS');
            FND_MESSAGE.SET_TOKEN ( 'STATUS',  p_adj_rec.status ) ;
            FND_MSG_PUB.ADD ;

             p_return_status := FND_API.G_RET_STS_ERROR ;
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
 |    Vivek Halder     13-JUN-97                                             |
 |    Saloni Shah      03-FEB-00  Changes made for BOE/BR project.           |
 |                                Defined a local variable                   |
 |                                l_accounting_affect. If the value of this  |
 |                                flag is set to 'N', then the code          |
 |                                combination id will be set to null.        |
 |    Satheesh Nambiar 01-Jun-00  Bug 1290698. Modified Validate_Rcvtrxccid  |
 |                                to include PS record also. For BOE/BR, the |
 |                                PS class 'BR' can only be adjusted by      |
 |                                receivables trx type 'ENDORSMENT'          |
 |    Satheesh Nambiar 29-Jun-00  Bug 1343351.Fixed the validation for 'BR' class
 +===========================================================================*/

PROCEDURE Validate_Rcvtrxccid (
		p_adj_rec	  IN OUT NOCOPY ar_adjustments%rowtype,
                p_ps_rec          IN     ar_payment_schedules%rowtype,
                p_return_status	  IN OUT NOCOPY varchar2,
		p_from_llca_call    IN  varchar2 DEFAULT 'N'
	        ) IS

l_index			number;
l_set_of_books_id	ar_receivables_trx.set_of_books_id%type := NULL;
l_cc_id			ar_receivables_trx.code_combination_id%type := NULL;
l_count			number;
l_found			BOOLEAN;
l_accounting_affect_flag varchar2(1);
l_receivable_trx_type   ar_receivables_trx.TYPE%type := NULL;
l_gl_account_source ar_receivables_trx.GL_ACCOUNT_SOURCE%type; /*Bug 2925924*/

-- Line Level Adjustment
l_customer_trx_id	number;
l_customer_trx_line_id  number;
l_receivables_trx_id    number;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Rcvtrxccid()+', G_MSG_MEDIUM);
	 arp_util.debug('p_from_llca_call : ' || p_from_llca_call);
      END IF;

      /*------------------------------------------+
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

--  Initialize Line Level Adjustment
	l_customer_trx_id	:= p_adj_rec.customer_trx_id;
	l_customer_trx_line_id  := p_adj_rec.customer_trx_line_id;
	l_receivables_trx_id    := p_adj_rec.receivables_trx_id;


      l_found := FALSE ;

      FOR l_index IN 1..G_RCVTRX_TBL.COUNT LOOP

         IF (p_adj_rec.receivables_trx_id =
			     G_RCVTRX_TBL(l_index).receivables_trx_id )
         THEN
             G_receivables_name := G_RCVTRX_TBL(l_index).name ;
             l_cc_id := G_RCVTRX_TBL(l_index).code_combination_id;
             l_accounting_affect_flag := G_RCVTRX_TBL(l_index).accounting_affect_flag;
             l_receivable_trx_type    := G_RCVTRX_TBL(l_index).type;
	     l_gl_account_source := G_RCVTRX_TBL(l_index).gl_account_source; /*Bug 2925924*/
             l_found := TRUE ;

             EXIT ;
         END IF;

      END LOOP;

      /*------------------------------------------------+
       |  Bug 1290698. For BOE/BR, a PS class 'BR'      |
       |  can only be adjusted by adjustment_type       |
       |  'E'-ENDORSMENT or 'X'- EXCHANGE               |
       |  Bug 1343351- Fixed the IF condition           |
       +------------------------------------------------*/
      IF (p_ps_rec.class = 'BR' and ((l_receivable_trx_type <> 'ENDORSEMENT')AND
                                     (p_adj_rec.receivables_trx_id <> -15   )))
      THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate_Rcvtrxccid: ' || 'For Payment schedule class BR,Receivable trx id
                            should be of type ENDORSEMENT or -15',G_MSG_HIGH);
            END IF;

	    IF p_from_llca_call <> 'Y' THEN
		FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_RCVABLE_TRX_ID');
		FND_MESSAGE.SET_TOKEN ( 'RECEIVABLES_TRX_ID',   to_char(p_adj_rec.receivables_trx_id) ) ;
		FND_MSG_PUB.ADD ;
		p_return_status := FND_API.G_RET_STS_ERROR;
            ELSE
	       insert into ar_llca_adj_trx_errors_gt
	        (
		customer_trx_id,
		customer_trx_line_id,
		receivables_trx_id,
		error_message,
		invalid_value
		)
		values
		(
		l_customer_trx_id,
		l_customer_trx_line_id,
		l_receivables_trx_id,
		'AR_AAPI_INVALID_RCVABLE_TRX_ID',
		'receivables_trx_id'
		);
		p_return_status := FND_API.G_RET_STS_ERROR;
             END IF;


      END IF;
      /*-------------------------------------------------------+
       |Re-defaulting adjustment_type to 'E' for ENDORSEMENT   |
       |and 'X' for receivables_trx_id -15 Except for Reversal |
       +-------------------------------------------------------*/
      IF (l_receivable_trx_type = 'ENDORSEMENT'
          AND p_adj_rec.created_from <> 'REVERSE_ADJUSTMENT')
      THEN
         p_adj_rec.adjustment_type:='E';
      END IF;
      IF (p_adj_rec.receivables_trx_id = -15
             AND  p_adj_rec.created_from <> 'REVERSE_ADJUSTMENT') THEN
         p_adj_rec.adjustment_type:='X';
      END IF;

      IF ( NOT l_found )
      THEN
 	 /*-----------------------------------------------+
	 |  Set the message                               |
      	 +-----------------------------------------------*/
	  IF p_from_llca_call <> 'Y' THEN

            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_RCVABLE_TRX_ID');
            FND_MESSAGE.SET_TOKEN ( 'RECEIVABLES_TRX_ID',   to_char(p_adj_rec.receivables_trx_id) ) ;
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;

	  ELSE
	       insert into ar_llca_adj_trx_errors_gt
	        (
		customer_trx_id,
		customer_trx_line_id,
		receivables_trx_id,
		error_message,
		invalid_value
		)
		values
		(
		l_customer_trx_id,
		l_customer_trx_line_id,
		l_receivables_trx_id,
		'AR_AAPI_INVALID_RCVABLE_TRX_ID',
		'receivables_trx_id'
		);
		p_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

/*--------------------------------------------------------------------------+
 | This validation has been added for the BR/BOE project.                   |
 | This flag would indicate that whether any accounting enteries need to    |
 | created or not. Also the code_combination_id will be set to null if the  |
 | accounting_affect_flag is set to 'N'                                     |
 +---------------------------------------------------------------------------*/
      IF (l_accounting_affect_flag = 'N')
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Validate_Rcvtrxccid: ' || 'for adj without accounting information - do not check the ccid');
          END IF;
          p_adj_rec.code_combination_id := NULL;
          return;
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

          IF ( (l_cc_id IS NULL OR l_cc_id = 0) and l_gl_account_source = 'ACTIVITY_GL_ACCOUNT')
          THEN
             IF p_from_llca_call <> 'Y' THEN
              FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CCID_FOR_ACTIVITY');
              FND_MESSAGE.SET_TOKEN ( 'RECEIVABLES_TRX_ID',  to_char(p_adj_rec.receivables_trx_id) ) ;
              FND_MSG_PUB.ADD ;
              p_return_status := FND_API.G_RET_STS_ERROR;
             ELSE
	       insert into ar_llca_adj_trx_errors_gt
	        (
		customer_trx_id,
		customer_trx_line_id,
		receivables_trx_id,
		error_message,
		invalid_value
		)
		values
		(
		l_customer_trx_id,
		l_customer_trx_line_id,
		l_receivables_trx_id,
		'AR_AAPI_NO_CCID_FOR_ACTIVITY',
		'receivables_trx_id'
		);
		p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

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
             END ;

             IF ( l_count <> 1 )
	     THEN
                /*-------------------------------------------+
	        |  Set the message                           |
      	        +-------------------------------------------*/
              IF p_from_llca_call <> 'Y' THEN
                FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_CCID');
                FND_MESSAGE.SET_TOKEN ( 'CCID',  p_adj_rec.code_combination_id ) ;
                FND_MSG_PUB.ADD ;
                p_return_status := FND_API.G_RET_STS_ERROR;
	      ELSE
	       insert into ar_llca_adj_trx_errors_gt
	        (
		customer_trx_id,
		customer_trx_line_id,
		receivables_trx_id,
		error_message,
		invalid_value
		)
		values
		(
		l_customer_trx_id,
		l_customer_trx_line_id,
		l_receivables_trx_id,
		'AR_AAPI_INVALID_CCID',
		'receivables_trx_id'
		);
		p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

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
              IF p_from_llca_call <> 'Y' THEN
                 FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_OVERRIDE_CCID_DISALLOW');
                 FND_MSG_PUB.ADD ;
                 p_return_status := FND_API.G_RET_STS_ERROR;
	      ELSE
	       insert into ar_llca_adj_trx_errors_gt
	        (
		customer_trx_id,
		customer_trx_line_id,
		receivables_trx_id,
		error_message,
		invalid_value
		)
		values
		(
		l_customer_trx_id,
		l_customer_trx_line_id,
		l_receivables_trx_id,
		'AR_AAPI_OVERRIDE_CCID_DISALLOW',
		'receivables_trx_id'
		);
		p_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
             END IF;
         END IF;

      END IF;

      /*-----------------------------------------------+
      |  Set the Set of books Id                       |
      +-----------------------------------------------*/

      p_adj_rec.set_of_books_id := arp_global.set_of_books_id ;
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
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

     /*------------------------------------------+
      |  The dates should not be null            |
      +-----------------------------------------*/

      IF ( p_apply_date IS NULL )
      THEN

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_APPLY_DATE');
         FND_MSG_PUB.ADD ;
         p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( p_gl_date IS NULL )
      THEN

         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_GL_DATE');
         FND_MSG_PUB.ADD ;
         p_return_status := FND_API.G_RET_STS_ERROR;
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
         FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_GLDATE_INVALID_PERIOD');
         FND_MESSAGE.SET_TOKEN ( 'GL_DATE',  to_char(p_gl_date,'DD-MON-YYYY') ) ;
         FND_MSG_PUB.ADD ;
         p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      /*---------------------------------------+
      | Check that apply date should be equal  |
      | to or greater than the transaction date|
      +---------------------------------------*/

      IF ( trunc(p_apply_date) < trunc(p_ps_rec.trx_date) )
      THEN
        FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_APPLYDATE_LT_TRXDATE');
        FND_MESSAGE.SET_TOKEN ( 'APPLY_DATE',  to_char(p_apply_date,'DD-MON-YYYY') ) ;
        FND_MESSAGE.SET_TOKEN ( 'TRX_DATE',  to_char(p_ps_rec.trx_date,'DD-MON-YYYY') ) ;
        FND_MSG_PUB.ADD ;
        p_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      /*---------------------------------------+
      | Check that GL date should be equal to  |
      | or greater than the transaction GL date|
      +---------------------------------------*/

      IF ( trunc(p_gl_date) < trunc(p_ps_rec.gl_date) )
      THEN
        FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_GLDATE_LT_TRXGLDATE');
        FND_MESSAGE.SET_TOKEN ( 'GL_DATE',  to_char(p_gl_date,'DD-MON-YYYY') ) ;
        FND_MESSAGE.SET_TOKEN ( 'TRX_GL_DATE',  to_char(p_ps_rec.gl_date,'DD-MON-YYYY') ) ;
        FND_MSG_PUB.ADD ;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

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

l_dummy               BINARY_INTEGER;
l_sequence_name       fnd_document_sequences.name%type;
l_doc_sequence_id     fnd_document_sequences.doc_sequence_id%type ;

--bug2629883
l_seq_assign_id       fnd_doc_sequence_assignments.doc_sequence_assignment_id%TYPE;
l_sequence_type       fnd_document_sequences.type%TYPE;
l_db_sequence_name    fnd_document_sequences.db_sequence_name%TYPE;
l_prod_table_name     fnd_document_sequences.table_name%TYPE;
l_audit_table_name    fnd_document_sequences.audit_table_name%TYPE;
l_mesg_flag           fnd_document_sequences.message_flag%TYPE;

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
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('Validate_doc_seq():'|| g_context_rec.unique_seq_numbers );
    END IF;

    IF ( NVL(g_context_rec.unique_seq_numbers, 'N') = 'N' )
    THEN
        IF ( p_adj_rec.doc_sequence_id IS NOT NULL 	OR
             p_adj_rec.doc_sequence_id <> 0 	    	OR
             p_adj_rec.doc_sequence_value IS NOT NULL 	OR
             p_adj_rec.doc_sequence_value <> 0 	)
        THEN
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_DOC_SEQ_NOT_REQD');
            FND_MESSAGE.SET_TOKEN ( 'DOCUMENT_SEQ',
		to_char(nvl(p_adj_rec.doc_sequence_id,p_adj_rec.doc_sequence_value ))) ;
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    ELSE
        /*--------------------------------------------------------+
        |  Get info about whether any doc seq assignment exists.  |
        +---------------------------------------------------------*/

        p_adj_rec.doc_sequence_id := NULL;
	BEGIN
            l_dummy := fnd_seqnum.get_seq_info(
                                               222,
                                               G_receivables_name,
                                               arp_global.set_of_books_id,
                                               'A',
                                               p_adj_rec.apply_date,
                                               p_adj_rec.doc_sequence_id,
                                               l_sequence_type,
                                               l_sequence_name,
                                               l_db_sequence_name,
                                               l_seq_assign_id,
                                               l_prod_table_name,
                                               l_audit_table_name,
                                               l_mesg_flag,'y','y');
            IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('Validate_doc_seq():'|| p_adj_rec.doc_sequence_id );
	    END IF;
        EXCEPTION
            WHEN OTHERS THEN
                arp_util.debug('Validate_doc_seq() : Exception raised by get_seq_info');
               	p_return_status := FND_API.G_RET_STS_ERROR;
        END;



        /*------------------------------------------------------------------+
        |  Get the doc_seq_val if we found that doc seq assignment exists.  |
        +-------------------------------------------------------------------*/

        IF (p_adj_rec.doc_sequence_id IS NOT NULL )
        THEN

            IF (p_adj_rec.doc_sequence_value IS NOT NULL )
            THEN
                IF ( l_sequence_type in ( 'A' , 'G' ))
                THEN
                    /*-----------------------------------------+
                    |  Automatic Document Numbering case       |
                    |  Document seuqence value should not exist|
                    +-----------------------------------------*/
                    FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_DOC_SEQ_NOT_REQD');
                    FND_MESSAGE.SET_TOKEN ( 'DOCUMENT_SEQ',
			to_char(p_adj_rec.doc_sequence_value) ) ;
                    FND_MSG_PUB.ADD ;

                     p_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            END IF;

            /*---------------------------------------------------+
            |  Auto Doc Num with doc seq setup exists ,     	 |
            |  so, call the get_seq_val to get next seq value    |
            +----------------------------------------------------*/
            IF ( p_return_status = FND_API.G_RET_STS_SUCCESS) THEN

		BEGIN
                    l_dummy := fnd_seqnum.get_seq_val (
                                                        arp_global.G_AR_APP_ID,
                                                        G_receivables_name,
                                                        arp_global.set_of_books_id,
                                                        'A',
                                                        p_adj_rec.apply_date,
                                                        p_adj_rec.doc_sequence_value ,
                                                        p_adj_rec.doc_sequence_id
                                                       );
            	    IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Validate_doc_seq():'|| p_adj_rec.doc_sequence_value );
	    	    END IF;
		EXCEPTION
		    WHEN OTHERS THEN
		        arp_util.debug('Validate_doc_seq() : Exception raised by get_seq_val');
                 	p_return_status := FND_API.G_RET_STS_ERROR;
		END;

            END IF;
        ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Validate_doc_seq() : No active document sequence assignments',
                 G_MSG_MEDIUM);
            END IF;
            p_adj_rec.doc_sequence_value := NULL;
    	    IF (g_context_rec.unique_seq_numbers = 'A'
        	AND  p_adj_rec.doc_sequence_id    IS NULL
        	AND  p_adj_rec.doc_sequence_value    IS NULL )
    	    THEN

        	FND_MESSAGE.SET_NAME ('FND', 'UNIQUE-ALWAYS USED');
        	FND_MSG_PUB.ADD ;

        	p_return_status := FND_API.G_RET_STS_ERROR;
    	    END IF;

        END IF;    -- Handled for both cases: when seq assign exists and when it doesn't..

    END IF;  ---Handled all combinations of Seq Numbering...


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

                FND_MESSAGE.SET_NAME ('FND', 'UNIQUE-ALWAYS USED');
                FND_MSG_PUB.ADD ;

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
      |  Initialize the return status to SUCCESS  |
      +------------------------------------------*/

      p_return_status := FND_API.G_RET_STS_SUCCESS;

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
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_REASON_CODE');
            FND_MESSAGE.SET_TOKEN ( 'REASON_CODE',   p_adj_rec.reason_code ) ;
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;

          END IF;

      END IF ;

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
 |    Satheesh Nambiar  16-Jun-00  Bug 1290698. Modified Validate_Desc_Flexfield
 |                                 to call arp_util.Validate_Desc_Flexfield
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Desc_Flexfield(
                          p_adj_rec		IN OUT NOCOPY	ar_adjustments%rowtype,
		          p_return_status	IN OUT NOCOPY	varchar2
	                 ) IS

l_flex_name	fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name      VARCHAR2(50);
p_desc_flex_rec arp_util.attribute_rec_type;

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

   --Bug 1290698 - Validate and default flex field

     p_desc_flex_rec.attribute_category := p_adj_rec.attribute_category;
     p_desc_flex_rec.attribute1  := p_adj_rec.attribute1;
     p_desc_flex_rec.attribute2  := p_adj_rec.attribute2;
     p_desc_flex_rec.attribute3  := p_adj_rec.attribute3;
     p_desc_flex_rec.attribute4  := p_adj_rec.attribute4;
     p_desc_flex_rec.attribute5  := p_adj_rec.attribute5;
     p_desc_flex_rec.attribute6  := p_adj_rec.attribute6;
     p_desc_flex_rec.attribute7  := p_adj_rec.attribute7;
     p_desc_flex_rec.attribute8  := p_adj_rec.attribute8;
     p_desc_flex_rec.attribute9  := p_adj_rec.attribute9;
     p_desc_flex_rec.attribute10 := p_adj_rec.attribute10;
     p_desc_flex_rec.attribute11 := p_adj_rec.attribute11;
     p_desc_flex_rec.attribute12 := p_adj_rec.attribute12;
     p_desc_flex_rec.attribute13 := p_adj_rec.attribute13;
     p_desc_flex_rec.attribute14 := p_adj_rec.attribute14;
     p_desc_flex_rec.attribute15 := p_adj_rec.attribute15;

     arp_util.Validate_Desc_Flexfield(p_desc_flex_rec ,
                                      l_flex_name,
                                      p_return_status);

     IF ( p_return_status <>FND_API.G_RET_STS_SUCCESS)
     THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('arp_util.Validate_Desc_Flexfield - Failed', G_MSG_UERROR);
       END IF;
       FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_DESC_FLEX');
       FND_MSG_PUB.ADD ;
       p_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     p_adj_rec.attribute_category := p_desc_flex_rec.attribute_category;
     p_adj_rec.attribute1  := p_desc_flex_rec.attribute1;
     p_adj_rec.attribute2  := p_desc_flex_rec.attribute2;
     p_adj_rec.attribute3  := p_desc_flex_rec.attribute3;
     p_adj_rec.attribute4  := p_desc_flex_rec.attribute4;
     p_adj_rec.attribute5  := p_desc_flex_rec.attribute5;
     p_adj_rec.attribute6  := p_desc_flex_rec.attribute6;
     p_adj_rec.attribute7  := p_desc_flex_rec.attribute7;
     p_adj_rec.attribute8  := p_desc_flex_rec.attribute8;
     p_adj_rec.attribute9  := p_desc_flex_rec.attribute9;
     p_adj_rec.attribute10 := p_desc_flex_rec.attribute10;
     p_adj_rec.attribute11 := p_desc_flex_rec.attribute11;
     p_adj_rec.attribute12 := p_desc_flex_rec.attribute12;
     p_adj_rec.attribute13 := p_desc_flex_rec.attribute13;
     p_adj_rec.attribute14 := p_desc_flex_rec.attribute14;
     p_adj_rec.attribute15 := p_desc_flex_rec.attribute15;

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
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_NO_CREATED_FROM');
            FND_MSG_PUB.ADD ;
            p_return_status := FND_API.G_RET_STS_ERROR;
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
      |  Initialize the return status to ERROR  |
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
            FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_USSGL_CODE');
            FND_MESSAGE.SET_TOKEN ( 'USSGL_CODE',   p_adj_rec.ussgl_transaction_code ) ;
            FND_MSG_PUB.ADD ;

         END IF;

       ELSE

         /*------------------------------------------+
         |  No USSGL code should be provided         |
         +------------------------------------------*/
          IF ( p_adj_rec.ussgl_transaction_code IS NOT NULL AND
              p_adj_rec.ussgl_transaction_code <> ' ' )
          THEN
              FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_USSGL_CODE_DISALLOW');
              FND_MESSAGE.SET_TOKEN ( 'USSGL_CODE',   p_adj_rec.ussgl_transaction_code ) ;
              FND_MSG_PUB.ADD ;

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
                FND_MESSAGE.SET_NAME ('AR', 'AR_AAPI_INVALID_RECEIPT_ID');
                FND_MESSAGE.SET_TOKEN ( 'ASSOCIATED_CASH_RECEIPT_ID',  to_char(p_adj_rec.associated_cash_receipt_id) ) ;
                FND_MSG_PUB.ADD ;

              p_return_status := FND_API.G_RET_STS_ERROR;
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

 /*==========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Over_Application                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the whether the adjustment is over    |
 |              applying the transaction.                                    |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |                   p_ps_rec                                                |
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
 |    JASSING 17-AUG-04   Bug 3766262                                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Validate_Over_Application (
		p_adj_rec	IN 	ar_adjustments%rowtype,
                p_ps_rec        IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_creation_sign         varchar2(30);
l_allow_overapp_flag    varchar2(1);
l_type_adr              number;
l_type_ado              number;
l_type_adj_amount       number;
l_message_name          varchar2(50);
BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Over_Application()+', G_MSG_MEDIUM);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;


      IF ( p_adj_rec.type = 'CHARGES' )
      THEN
           l_type_adr := p_ps_rec.amount_due_remaining;
           l_type_ado  := p_ps_rec.amount_due_original;
	   l_type_adj_amount := p_adj_rec.receivables_charges_adjusted;
      ELSIF ( p_adj_rec.type = 'FREIGHT' )
      THEN
           l_type_adr := p_ps_rec.freight_remaining;
           l_type_ado  := p_ps_rec.freight_original;
	   l_type_adj_amount := p_adj_rec.amount;
      ELSIF ( p_adj_rec.type = 'LINE' )
      THEN
           l_type_adr := p_ps_rec.amount_line_items_remaining;
           l_type_ado  := p_ps_rec.amount_line_items_original;
	   l_type_adj_amount := p_adj_rec.line_adjusted;
      ELSIF ( p_adj_rec.type = 'TAX' )
      THEN
           l_type_adr := p_ps_rec.tax_remaining;
           l_type_ado  := p_ps_rec.tax_original;
	   l_type_adj_amount := p_adj_rec.amount;
      ELSIF ( p_adj_rec.type = 'INVOICE' )
      THEN
           l_type_adr := p_ps_rec.amount_due_remaining;
           l_type_ado  := p_ps_rec.amount_due_original;
      END IF;


      SELECT creation_sign,
             allow_overapplication_flag
      INTO l_creation_sign,
           l_allow_overapp_flag
      FROM ra_cust_trx_types
      WHERE cust_trx_type_id    = p_ps_rec.cust_trx_type_id;



      IF ( p_adj_rec.type = 'INVOICE' )
      THEN

         /*----------------------------------------------------------+
         |  Invoice type adjustment must make the balance due zero  |
	 +----------------------------------------------------------*/
	 /*This is validated while validating the amount, so not needed
	   out here*/

	 NULL;
/*
        IF ( l_type_adr + p_adj_rec.amount <> 0 )
        THEN
               p_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AR','AR_TW_VAL_AMT_ADJ_INV');
               FND_MSG_PUB.Add;
        END IF;*/


      ELSE

        /*----------------------------------------------------------+
         |  Check for overapplication based on the adjustment type  |
         +----------------------------------------------------------*/

         arp_non_db_pkg.check_natural_application(
	      p_creation_sign             => l_creation_sign,
	      p_allow_overapplication_flag=> l_allow_overapp_flag,
	      p_natural_app_only_flag     => 'N',
	      p_sign_of_ps                => '+',
	      p_chk_overapp_if_zero       => null,
	      p_payment_amount            => l_type_adj_amount,
	      p_discount_taken            => 0,
	      p_amount_due_remaining      => nvl(l_type_adr,0),
	      p_amount_due_original       => nvl(l_type_ado,0),
	      event                       => 'WHEN-VALIDATE-ITEM',
	      p_message_name              => l_message_name);


           IF ( l_message_name IS NOT NULL)
           THEN
               p_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AR',l_message_name);
               FND_MSG_PUB.Add;
           END IF;


        /*------------------------------------+
         |  Check for overapplication of tax  |
         +------------------------------------*/

	IF p_adj_rec.type in ('CHARGES', 'LINE') and
	   nvl(p_adj_rec.tax_adjusted,0) <> 0 THEN
           arp_non_db_pkg.check_natural_application(
	      p_creation_sign             => l_creation_sign,
	      p_allow_overapplication_flag=> l_allow_overapp_flag,
	      p_natural_app_only_flag     => 'N',
	      p_sign_of_ps                => '+',
	      p_chk_overapp_if_zero       => null,
	      p_payment_amount            => p_adj_rec.tax_adjusted,
	      p_discount_taken            => 0,
	      p_amount_due_remaining      => nvl(p_ps_rec.tax_remaining,0),
	      p_amount_due_original       => nvl(p_ps_rec.tax_original,0),
	      event                       => 'WHEN-VALIDATE-ITEM',
	      p_message_name              => l_message_name);

           IF ( l_message_name IS NOT NULL)
           THEN
               p_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('AR',l_message_name);
               FND_MSG_PUB.Add;
           END IF;

	END IF;

      END IF;

      RETURN;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Over_Application', G_MSG_UERROR);
           arp_util.debug('EXCEPTION: Validate_Over_Application '
		       || p_adj_rec.customer_trx_id, G_MSG_HIGH );
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Over_Application');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;
END Validate_Over_Application;


/*==========================================================================+
 | PROCEDURE                                                                 |
 |              Validate_Over_Application_llca                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This routine validates the whether the line adjustment       |
 |              is over applying the transaction.                            |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |     arp_util.disable_debug                                                |
 |     fnd_api.g_exc_unexpected_error                                        |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_error                                               |
 |     fnd_api.g_ret_sts_success                                             |
 |     fnd_api.to_boolean                                                    |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_adj_rec                                               |
 |                                                                           |
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
 |    mpsingh 05-Feb-2008 CREATED                                            |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE Validate_Over_Application_llca (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_ps_rec        IN	ar_payment_schedules%rowtype,
                p_return_status	IN OUT NOCOPY	varchar2
	        ) IS

l_creation_sign         varchar2(30);
l_allow_overapp_flag    varchar2(1);
l_type_adj_amount       number;
l_message_name          varchar2(50);
l_line_remaining	number;
l_tax_remaining		number;
l_line_org		number;
l_tax_org		number;
l_invoice_currency_code varchar2(30);
l_customer_trx_id	number;
l_customer_trx_line_id  number;
l_receivables_trx_id    number;


BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('Validate_Over_Application_llca()+', G_MSG_MEDIUM);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;

      l_type_adj_amount		:= p_adj_rec.amount;
      l_customer_trx_id		:= p_adj_rec.customer_trx_id;
      l_customer_trx_line_id	:= p_adj_rec.customer_trx_line_id;
      l_receivables_trx_id	:= p_adj_rec.receivables_trx_id;



     SELECT creation_sign,
             allow_overapplication_flag
      INTO l_creation_sign,
           l_allow_overapp_flag
      FROM ra_cust_trx_types
      WHERE cust_trx_type_id    = p_ps_rec.cust_trx_type_id;


      -- As per LLCA design, overapplication not allowed at Line level
      l_allow_overapp_flag := 'N';


      SELECT sum(DECODE (lines.line_type,
                                'TAX',0,
                                'FREIGHT',0 , 1) *
                         DECODE(ct.complete_flag, 'N',
                                0, lines.amount_due_remaining)), -- line adr
                    sum(DECODE (lines.line_type,
                                'TAX',1,0) *
                          DECODE(ct.complete_flag,
                                 'N', 0,
                                 lines.amount_due_remaining )), -- tax adr
             sum(DECODE (lines.line_type,
                                'TAX',0,
                                'FREIGHT',0 , 1) *
                         DECODE(ct.complete_flag, 'N',
                                0, lines.amount_due_original)), -- line adr org
                    sum(DECODE (lines.line_type,
                                'TAX',1,0) *
                          DECODE(ct.complete_flag,
                                 'N', 0,
                                 lines.amount_due_original)),   -- tax adr  org
                    max(ct.invoice_currency_code) -- curr code
      INTO        l_line_remaining,
                  l_tax_remaining,
		  l_line_org,
                  l_tax_org,
                  l_invoice_currency_code
      FROM        ra_customer_trx ct,
                  ra_customer_trx_lines lines
      WHERE (lines.customer_Trx_line_id = p_adj_rec.customer_trx_line_id or
                   lines.link_to_cust_trx_line_id = p_adj_rec.customer_trx_line_id)
      AND  ct.customer_Trx_id = lines.customer_trx_id;



         /*----------------------------------------------------------+
         |  Check for overapplication based on the adjustment type  |
         +----------------------------------------------------------*/

         arp_non_db_pkg.check_natural_application(
	      p_creation_sign             => l_creation_sign,
	      p_allow_overapplication_flag=> l_allow_overapp_flag,
	      p_natural_app_only_flag     => 'N',
	      p_sign_of_ps                => '+',
	      p_chk_overapp_if_zero       => null,
	      p_payment_amount            => l_type_adj_amount,
	      p_discount_taken            => 0,
	      p_amount_due_remaining      => nvl(l_line_remaining,0),
	      p_amount_due_original       => nvl(l_line_org,0),
	      event                       => 'WHEN-VALIDATE-ITEM',
	      p_message_name              => l_message_name);


           IF ( l_message_name IS NOT NULL)
           THEN
               insert into ar_llca_adj_trx_errors_gt
			(
				customer_trx_id,
				customer_trx_line_id,
				receivables_trx_id,
				error_message,
				invalid_value
			)
			values
			(
				l_customer_trx_id,
				l_customer_trx_line_id,
				l_receivables_trx_id,
				l_message_name,
				'Overapplication'
			);
           END IF;


        /*------------------------------------+
         |  Check for overapplication of tax  |
         +------------------------------------*/

	IF p_adj_rec.type in ('LINE') and
	   nvl(p_adj_rec.tax_adjusted,0) <> 0 THEN
           arp_non_db_pkg.check_natural_application(
	      p_creation_sign             => l_creation_sign,
	      p_allow_overapplication_flag=> l_allow_overapp_flag,
	      p_natural_app_only_flag     => 'N',
	      p_sign_of_ps                => '+',
	      p_chk_overapp_if_zero       => null,
	      p_payment_amount            => p_adj_rec.tax_adjusted,
	      p_discount_taken            => 0,
	      p_amount_due_remaining      => nvl(l_tax_remaining,0),
	      p_amount_due_original       => nvl(l_tax_org,0),
	      event                       => 'WHEN-VALIDATE-ITEM',
	      p_message_name              => l_message_name);

           IF ( l_message_name IS NOT NULL)
           THEN
               insert into ar_llca_adj_trx_errors_gt
			(
				customer_trx_id,
				customer_trx_line_id,
				receivables_trx_id,
				error_message,
				invalid_value
			)
			values
			(
				l_customer_trx_id,
				l_customer_trx_line_id,
				l_receivables_trx_id,
				l_message_name,
				'Overapplication'
			);
           END IF;

	END IF;
	RETURN;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION: Validate_Over_Application_llca', G_MSG_UERROR);
           arp_util.debug('EXCEPTION: Validate_Over_Application_llca '
		       || p_adj_rec.customer_trx_id, G_MSG_HIGH );
        END IF;
	/*-----------------------------------------------+
      	|  Set unexpected error message and status       |
      	+-----------------------------------------------*/
	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,'Validate_Over_Application_llca');
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RETURN;
END Validate_Over_Application_llca;

BEGIN
    arp_util.debug('initialization section of ar_adjvalidate_pvt');
    G_cache_org_id := -99999;

END AR_ADJVALIDATE_PVT;

/
