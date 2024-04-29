--------------------------------------------------------
--  DDL for Package Body ARP_NON_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_NON_DB_PKG" AS
/* $Header: ARXNODBB.pls 120.7 2005/10/30 04:28:06 appldev ship $ */

/***************************************************************************
Declare Private Procedures
****************************************************************************/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE raise_error( p_message_code IN VARCHAR2 );

-- PUBLIC procedures

PROCEDURE check_natural_application(
	      p_creation_sign 		IN VARCHAR2,
	      p_allow_overapplication_flag IN VARCHAR2,
	      p_natural_app_only_flag 	IN VARCHAR2,
	      p_sign_of_ps 		IN VARCHAR2 DEFAULT '-',
	      p_chk_overapp_if_zero 	IN VARCHAR2 DEFAULT 'N',
	      p_payment_amount 		IN NUMBER,
	      p_discount_taken 		IN NUMBER,
	      p_amount_due_remaining 	IN NUMBER,
	      p_amount_due_original 	IN NUMBER,
	      event 			IN VARCHAR2 DEFAULT NULL,
	      p_lockbox_record          IN BOOLEAN DEFAULT FALSE) IS

     l_message_name  VARCHAR2(50);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_natural_application(1)+');
  END IF;
  arp_non_db_pkg.check_natural_application(
	      p_creation_sign,
	      p_allow_overapplication_flag,
	      p_natural_app_only_flag,
	      p_sign_of_ps,
	      p_chk_overapp_if_zero,
	      p_payment_amount,
	      p_discount_taken,
	      p_amount_due_remaining,
	      p_amount_due_original,
	      event,
              l_message_name,
	      p_lockbox_record);

  IF ( l_message_name IS NOT NULL)
  THEN
    arp_non_db_pkg.raise_error( l_message_name );
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_natural_application(1)-');
  END IF;

EXCEPTION
   WHEN OTHERS THEN

    -- 12/5/1995 H.Kaukovuo	 Added debug statements for problem solving.
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('-- ARP_NON_DB_PK.RAISE_ERROR: EXCEPTION');
       arp_standard.debug('raise_error: ' || '-- Printing out NOCOPY package parameters:');
       arp_standard.debug('raise_error: ' || '--  p_creation_sign = '||p_creation_sign);
       arp_standard.debug('raise_error: ' || '--  p_allow_overapplication_flag = '||
	p_allow_overapplication_flag);
       arp_standard.debug('raise_error: ' || '--  p_natural_app_only_flag = '||
	p_natural_app_only_flag);
       arp_standard.debug('raise_error: ' || '--  p_sign_of_ps = '||p_sign_of_ps);
       arp_standard.debug('raise_error: ' || '--  p_chk_overapp_if_zero = '||p_chk_overapp_if_zero);
       arp_standard.debug('raise_error: ' || '--  p_payment_amount = '||to_char(p_payment_amount));
       arp_standard.debug('raise_error: ' || '--  p_discount_taken = '||to_char(p_discount_taken));
       arp_standard.debug('raise_error: ' || '--  p_amount_due_remaining = '||
	to_char(p_amount_due_remaining));
       arp_standard.debug('raise_error: ' || '--  p_amount_due_original = '||
	to_char(p_amount_due_original));
       arp_standard.debug('raise_error: ' || '--  event = '||event);
    END IF;
   RAISE;

END;


PROCEDURE check_natural_application(
	      p_creation_sign 		IN VARCHAR2,
	      p_allow_overapplication_flag IN VARCHAR2,
	      p_natural_app_only_flag 	IN VARCHAR2,
	      p_sign_of_ps 		IN VARCHAR2,
	      p_chk_overapp_if_zero 	IN VARCHAR2,
	      p_payment_amount 		IN NUMBER,
	      p_discount_taken 		IN NUMBER,
	      p_amount_due_remaining 	IN NUMBER,
	      p_amount_due_original 	IN NUMBER,
	      event 			IN VARCHAR2,
              p_message_name            OUT NOCOPY VARCHAR2,
	      p_lockbox_record          IN BOOLEAN DEFAULT FALSE) IS
l_payment_amount     NUMBER;
l_sign_value_of_ps   NUMBER := 0;
l_temp_amount        NUMBER := 0;
l_debug		     VARCHAR2(5) := 'N';
l_message_name       VARCHAR2(50);  /*Bug 3842116*/

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_natural_application(2)+');
  END IF;

  p_message_name := NULL;

  -- 12/5/95 H.Kaukovuo
  -- This 'IF' is needed because this package can be used in client
  -- site and we don't want to have unnecessary network rounds.
  -- Normally these kind of IF statements are NOT needed.
  IF (l_debug='Y') THEN
    -- +----------------------------------------------------------+
    -- | This is for debug purposes. Comment out NOCOPY when not needed. |
    -- +----------------------------------------------------------+
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('raise_error: ' || '-- p_creation_sign ='||p_creation_sign);
       arp_standard.debug('raise_error: ' || '-- p_allow_overapplication_flag ='||
	p_allow_overapplication_flag);
       arp_standard.debug('raise_error: ' || '-- p_natural_app_only_flag ='||
	p_natural_app_only_flag);
       arp_standard.debug('raise_error: ' || '-- p_sign_of_ps ='||p_sign_of_ps);
       arp_standard.debug('raise_error: ' || '-- p_chk_overapp_if_zero ='||p_chk_overapp_if_zero);
       arp_standard.debug('raise_error: ' || '-- p_payment_amount ='||to_char(p_payment_amount));
       arp_standard.debug('raise_error: ' || '-- p_discount_taken ='||to_char(p_discount_taken));
       arp_standard.debug('raise_error: ' || '-- p_amount_due_remaining='||
	to_char(p_amount_due_remaining));
       arp_standard.debug('raise_error: ' || '-- p_amount_due_original='||
	to_char(p_amount_due_original));
       arp_standard.debug('raise_error: ' || '-- event ='||event);
    END IF;
  END IF;

  /*----------------------------+
  | Checking out NOCOPY the parameters |
  +----------------------------*/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || '-- Checking out NOCOPY the parameters');
  END IF;
  IF ( p_creation_sign IS NULL ) THEN
        p_message_name := 'AR_CKAP_CRE_SIGN_NULL';

  ELSIF ( p_allow_overapplication_flag IS NULL ) THEN
         p_message_name := 'AR_CKAP_OVERAPP_FLAG_NULL';

  ELSIF ( p_natural_app_only_flag IS NULL ) THEN
         p_message_name := 'AR_CKAP_NAT_FLAG_NULL';

  ELSIF ( ( p_sign_of_ps <> '-' ) AND
         ( p_sign_of_ps <> '+' ) ) THEN
         p_message_name := 'AR_CKAP_SIGN_INVALID';
  END IF;

  --
  -- If allow over application, return AR_CKAP_SUCCESS.
  --
  IF ( p_allow_overapplication_flag = 'Y' ) THEN
     RETURN;
  END IF;

    /***********************************************************************
    -- If sign = '-' then l_payment_amount = (-1) *  (payment_amount + disc)
    --                        else l_payment_amount = (payment_amount + disc)
    ************************************************************************/

    l_payment_amount := NVL( p_payment_amount, 0 ) +
                        NVL( p_discount_taken, 0 );
    IF ( p_sign_of_ps = '-' ) THEN
        l_payment_amount := (-1) * l_payment_amount;
    END IF;

    --
    -- IF amount_due_remaining is not zero, Use the sign of ADR
    -- as the sign of payment schedule.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('raise_error: ' || '-- Checking amount due remaining');
    END IF;

    IF ( NVL( p_amount_due_remaining, 0 ) < 0 ) THEN
        l_sign_value_of_ps:= -1;
    ELSIF ( NVL( p_amount_due_remaining, 0 ) > 0 ) THEN
        l_sign_value_of_ps := 1;
    --
    -- Else if,  amount_due_original is zero, Use the sign of ADO
    -- as the sign of payment schedule.
    --
    ELSE
        IF ( NVL( p_amount_due_original, 0 ) < 0 ) THEN
            l_sign_value_of_ps:= -1;
        ELSIF ( NVL( p_amount_due_original, 0 ) > 0 ) THEN
            l_sign_value_of_ps:= 1;
        --
        -- Else if,  ADO AND ADR is zero, Use the sign of ADO
        -- as the sign of payment schedule.
        --
        ELSE
            --
            -- Check if chk_overapp_if_zero = Y. If so, then if
            -- payment_amount <> 0, return failure, else if amount = 0,
            -- return success.
            --
            IF ( p_chk_overapp_if_zero = 'Y' ) THEN
                IF ( l_payment_amount <> 0 AND NOT(p_lockbox_record)) THEN
                     p_message_name := 'AR_CKAP_OVERAPP';
                ELSE
                    RETURN;
                END IF;
            END IF;
        END IF;
        --
        -- check the creation_sign. The amount changed should only make the
        -- amount_due_remaining go to where the creation_sign allows
        --

        arp_non_db_pkg.check_creation_sign( p_creation_sign,
                                            l_payment_amount, event,
					    l_message_name); /*Bug 3842116*/
        IF l_message_name IS NOT NULL /*Bug 3842116*/
	THEN
	   p_message_name := 'AR_CKAP_OVERAPP';
        END IF;
    END IF;

    --
    -- Then check whether it violates overapplication flag and natural
    -- application flag.
    --
    l_temp_amount := NVL( p_amount_due_remaining, 0 ) + l_payment_amount;
    IF ( ( l_sign_value_of_ps * l_temp_amount ) < 0  AND NOT(p_lockbox_record)) THEN
         p_message_name := 'AR_CKAP_OVERAPP';
    END IF;
    --
    -- check natural application
    --

  IF (p_natural_app_only_flag = 'Y') THEN
    IF ( l_payment_amount < 0 ) THEN
            l_temp_amount := -1;
    ELSIF ( l_payment_amount > 0 ) THEN
            l_temp_amount := 1;
    ELSE
            l_temp_amount := 0;
    END IF;

    -- 11/27/1995 H.Kaukovuo	Changed "<>1" to "= 1"
    IF (( l_sign_value_of_ps * l_temp_amount ) = 1) THEN
      p_message_name := 'AR_CKAP_NATURALAPP';
    END IF;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_natural_application(2)-'|| p_message_name);
  END IF;

END check_natural_application;


PROCEDURE check_creation_sign(
                      p_creation_sign  IN VARCHAR2,
                      p_amount         IN NUMBER,
                      event            IN VARCHAR2,
                      p_message_name   OUT NOCOPY VARCHAR2) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_creation_sign(1)+');
  END IF;
    p_message_name := NULL;

    IF ( p_creation_sign = 'A' ) THEN
        RETURN;
    ELSIF ( p_creation_sign  = 'P' ) THEN
        IF ( NVL( p_amount, 0 ) < 0 ) THEN
            p_message_name :=  'AR_CKAP_CT_SIGN';
        END IF;
    ELSIF ( p_creation_sign = 'N' ) THEN
        IF ( NVL( p_amount, 0 ) > 0 ) THEN
            p_message_name :=  'AR_CKAP_CT_SIGN';
        END IF;
    ELSE
        p_message_name :=  'AR_CKAP_INV_CT_SIGN';
    END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_creation_sign(1)-');
  END IF;
END check_creation_sign;


PROCEDURE check_creation_sign(
                      p_creation_sign  IN VARCHAR2,
                      p_amount         IN NUMBER,
                      event            IN VARCHAR2 DEFAULT NULL ) IS

    l_message_name VARCHAR2(50);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_creation_sign(2)+');
  END IF;
  check_creation_sign(
                           p_creation_sign,
                           p_amount,
                           event,
                           l_message_name );

  IF   ( l_message_name  IS NOT NULL )
  THEN
    arp_non_db_pkg.raise_error(l_message_name);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('raise_error: ' || 'arp_non_db_pkg.check_creation_sign(2)-');
  END IF;
END check_creation_sign;


/*------------------------------------------------------------------------+
| This procedure does a RAISE app_exception.application_exception that is |
| compatible with forms and Server side.                                  |
| History:
| 1/25/1996	Harri Kaukovuo		Changed to use
|					app_exception.raise_exception because
|					of ORA-6512 errors.
| 03-FEB-00     Saloni Shah             Added fnd_msg_pub.add             |
+------------------------------------------------------------------------*/
PROCEDURE raise_error( p_message_code IN VARCHAR2 ) IS
BEGIN

  fnd_message.set_name('AR', p_message_code);
  fnd_msg_pub.add;
  --sbkini bug 2115049
  fnd_message.set_name('AR',p_message_code);
  -- end bug 2115049
  app_exception.raise_exception;

END raise_error;

END ARP_NON_DB_PKG;

/
