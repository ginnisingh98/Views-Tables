--------------------------------------------------------
--  DDL for Package Body ARP_RATE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RATE_ADJUSTMENTS_PKG" AS
/*$Header: ARRIRADB.pls 120.4 2004/03/01 19:15:09 mraymond ship $*/
--

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_p(
	p_radj_rec 	IN ar_rate_adjustments%ROWTYPE,
	p_radj_id	OUT NOCOPY  ar_rate_adjustments.rate_adjustment_id%TYPE ) IS
l_radj_id	ar_rate_adjustments.rate_adjustment_id%TYPE;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rate_adjustments_pkg.insert_p()+' );
    END IF;
      --
      SELECT AR_RATE_ADJUSTMENTS_s.nextval
      INTO   l_radj_id
      FROM   dual;
      --
      INSERT INTO  AR_RATE_ADJUSTMENTS (
		rate_adjustment_id,
		cash_receipt_id,
		gain_loss,
		gl_date,
		new_exchange_date,
		new_exchange_rate,
		new_exchange_rate_type,
		old_exchange_date,
		old_exchange_rate,
		old_exchange_rate_type,
		gl_posted_date,
		posting_control_id,
		created_from,
 		    attribute_category,
 		    attribute1,
 		    attribute2,
 		    attribute3,
 		    attribute4,
 		    attribute5,
 		    attribute6,
 		    attribute7,
 		    attribute8,
 		    attribute9,
 		    attribute10,
 		    attribute11,
 		    attribute12,
 		    attribute13,
 		    attribute14,
 		    attribute15,
 		   request_id,
 		   program_application_id,
 		   program_id,
 		   program_update_date,
 		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
 		   last_update_login
                   ,org_id
 		 )
       VALUES (    l_radj_id,
                   p_radj_rec.cash_receipt_id,
                   p_radj_rec.gain_loss,
                   p_radj_rec.gl_date,
                   p_radj_rec.new_exchange_date,
                   p_radj_rec.new_exchange_rate,
                   p_radj_rec.new_exchange_rate_type,
                   p_radj_rec.old_exchange_date,
                   p_radj_rec.old_exchange_rate,
                   p_radj_rec.old_exchange_rate_type,
                   p_radj_rec.gl_posted_date,
                   p_radj_rec.posting_control_id,
                   p_radj_rec.created_from,
 		   p_radj_rec.attribute_category,
 		   p_radj_rec.attribute1,
 		   p_radj_rec.attribute2,
 		   p_radj_rec.attribute3,
 		   p_radj_rec.attribute4,
 		   p_radj_rec.attribute5,
 		   p_radj_rec.attribute6,
 		   p_radj_rec.attribute7,
 		   p_radj_rec.attribute8,
 		   p_radj_rec.attribute9,
 		   p_radj_rec.attribute10,
 		   p_radj_rec.attribute11,
 		   p_radj_rec.attribute12,
 		   p_radj_rec.attribute13,
 		   p_radj_rec.attribute14,
 		   p_radj_rec.attribute15,
 		   NVL( arp_standard.profile.request_id,
			p_radj_rec.request_id ),
 		   NVL( arp_standard.profile.program_application_id,
			p_radj_rec.program_application_id ),
 		   NVL( arp_standard.profile.program_id,
			p_radj_rec.program_id ),
		   DECODE( arp_standard.profile.program_id,
                           NULL, NULL,
                           SYSDATE
                         ),
		   arp_standard.profile.user_id,
 		   SYSDATE,
		   arp_standard.profile.user_id,
 		   SYSDATE,
		   NVL( arp_standard.profile.last_update_login,
		        p_radj_rec.last_update_login )
                  ,arp_standard.sysparm.org_id /* SSA changes anuj */
	       );
    --
            /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'INSERT',
                        p_table_name        => 'AR_RATE_ADJUSTMENTS',
                        p_mode		    => 'SINGLE',
                        p_key_value         => l_radj_id
                       );

    p_radj_id := l_radj_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rate_adjustments_pkg.insert_p()+' );
    END IF;
    EXCEPTION
	WHEN  OTHERS THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'EXCEPTION: arp_rate_adjustments_pkg.insert_p' );
	    END IF;
	    RAISE;
END insert_p;
--
--
END ARP_RATE_ADJUSTMENTS_PKG;

/
