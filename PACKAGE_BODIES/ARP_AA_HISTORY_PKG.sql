--------------------------------------------------------
--  DDL for Package Body ARP_AA_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AA_HISTORY_PKG" AS
/* $Header: ARCIAAHB.pls 120.5 2005/10/30 04:14:16 appldev ship $*/
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function inserts a row into AR_APPROVAL_ACTION_HISTORY table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_aah_rec - approval_action_history record structure   |
 |              OUT:                                                         |
 |                    p_adj_id - approval_action_history id of inserted row  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_p( p_aah_rec 	IN ar_approval_action_history%ROWTYPE,
 p_aah_id OUT NOCOPY ar_approval_action_history.approval_action_history_id%TYPE) IS
l_aah_id ar_approval_action_history.approval_action_history_id%TYPE;
BEGIN
      arp_standard.debug( '>>>>>>>> arp_aa_history_pkg.insert_p' );
      --
      SELECT ar_approval_action_history_s.nextval
      INTO   l_aah_id
      FROM   dual;

      --
      INSERT INTO  ar_approval_action_history (
		   approval_action_history_id,
		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
 		   last_update_login,
 		   action_name,
 		   adjustment_id,
 		   action_date,
 		   comments,
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
 		   attribute15
 		 )
       VALUES (    l_aah_id,
		   arp_standard.profile.user_id,
		   SYSDATE,
 		   arp_standard.profile.user_id,
 		   SYSDATE,
 		   NVL( arp_standard.profile.last_update_login,
			p_aah_rec.last_update_login ),
 		   p_aah_rec.action_name,
 		   p_aah_rec.adjustment_id,
 		   p_aah_rec.action_date,
 		   p_aah_rec.comments,
 		   p_aah_rec.attribute_category,
 		   p_aah_rec.attribute1,
 		   p_aah_rec.attribute2,
 		   p_aah_rec.attribute3,
 		   p_aah_rec.attribute4,
 		   p_aah_rec.attribute5,
 		   p_aah_rec.attribute6,
 		   p_aah_rec.attribute7,
 		   p_aah_rec.attribute8,
 		   p_aah_rec.attribute9,
 		   p_aah_rec.attribute10,
 		   p_aah_rec.attribute11,
 		   p_aah_rec.attribute12,
 		   p_aah_rec.attribute13,
 		   p_aah_rec.attribute14,
 		   p_aah_rec.attribute15
	       );
    p_aah_id := l_aah_id;
     --
    arp_standard.debug( '<<<<<<<< arp_aa_history_pkg.insert_p' );
    EXCEPTION
	WHEN  OTHERS THEN
	    arp_standard.debug( 'EXCEPTION: arp_aa_history_pkg.insert_p' );
	    RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates a row into AR_APPROVAL_ACTION_HISTORY table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_aah_rec - approval action history record structure   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_p( p_aah_rec 	IN ar_approval_action_history%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_aa_history_pkg.update_p' );
    --
    UPDATE ar_approval_action_history SET
		   approval_action_history_id =
				p_aah_rec.approval_action_history_id,
 		   last_updated_by = arp_standard.profile.user_id,
 		   last_update_date = SYSDATE,
 		   last_update_login =
			NVL( arp_standard.profile.last_update_login,
			     p_aah_rec.last_update_login ),
 		   action_name = p_aah_rec.action_name,
 		   adjustment_id = p_aah_rec.adjustment_id,
 		   action_date = p_aah_rec.action_date,
 		   comments = p_aah_rec.comments,
 		   attribute_category =  p_aah_rec.attribute_category,
 		   attribute1 = p_aah_rec.attribute1,
 		   attribute2 = p_aah_rec.attribute2,
 		   attribute3 = p_aah_rec.attribute3,
 		   attribute4 = p_aah_rec.attribute4,
 		   attribute5 = p_aah_rec.attribute5,
 		   attribute6 = p_aah_rec.attribute6,
 		   attribute7 = p_aah_rec.attribute7,
 		   attribute8 = p_aah_rec.attribute8,
 		   attribute9 = p_aah_rec.attribute9,
 		   attribute10 = p_aah_rec.attribute10,
 		   attribute11 = p_aah_rec.attribute11,
 		   attribute12 = p_aah_rec.attribute12,
 		   attribute13 = p_aah_rec.attribute13,
 		   attribute14 = p_aah_rec.attribute14,
 		   attribute15 = p_aah_rec.attribute15
    WHERE approval_action_history_id = p_aah_rec.approval_action_history_id;
    --
    arp_standard.debug( '<<<<<<<< arp_aa_history_pkg.update_p' );
    EXCEPTION
        WHEN  OTHERS THEN
            arp_standard.debug( 'EXCEPTION: arp_aa_history_pkg.update_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes a row from AR_APPROVAL_ACTION_HISTORY table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_aah_id - approval action history id                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_p(
    p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_aa_history_pkg.delete_p' );
    DELETE FROM ar_approval_action_history
    WHERE approval_action_history_id = p_aah_id;
    --
    arp_standard.debug( '<<<<<<<< arp_aa_history_pkg.delete_p' );
    EXCEPTION
        WHEN  OTHERS THEN
            arp_standard.debug( 'EXCEPTION: arp_aa_history_pkg.delete_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function fetches a row from AR_APPROVAL_ACTION_HISTORY table      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_aah_id - approval action history id                    |
 |              OUT:                                                         |
 |                  p_aah_rec - approval action history record structure     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_p(
   p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE,
   p_aah_rec OUT NOCOPY ar_approval_action_history%ROWTYPE ) IS
BEGIN
    arp_standard.debug( '>>>>>>>> arp_aa_history_pkg.fetch_p' );
    SELECT *
    INTO   p_aah_rec
    FROM  ar_approval_action_history
    WHERE approval_action_history_id = p_aah_id;
    arp_standard.debug( '<<<<<<<< arp_aa_history_pkg.fetch_p' );
    --
    EXCEPTION
        WHEN  OTHERS THEN
            arp_standard.debug( 'EXCEPTION: arp_aa_history_pkg.fetch_p' );
            RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function locks a row in AR_APPROVAL_ACTION_HISTORY table          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_aah_id - approval action history id of row to be       |
 |                             locked in AR_APPROVAL_ACTION_HISTORY table    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 24-Jun-1999	J.Gazmen-Dabir	Bug 911364, modified update as STATUS        |
 |				column does not exist in table.              |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_p(
   p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE ) IS
l_aah_id	ar_approval_action_history.approval_action_history_id%TYPE;
BEGIN
    arp_standard.debug( '>>>>>>>> arp_aa_history_pkg.lock_p' );
    SELECT approval_action_history_id
    INTO   l_aah_id
    FROM  ar_approval_action_history
    WHERE approval_action_history_id = p_aah_id
    FOR UPDATE OF ACTION_NAME NOWAIT;
    --
    arp_standard.debug( '<<<<<<<< arp_aa_history_pkg.lock_p' );
    EXCEPTION
        WHEN  OTHERS THEN
            arp_standard.debug( 'EXCEPTION: arp_aa_history_pkg.lock_p' );
            RAISE;
END;

END  ARP_AA_HISTORY_PKG;
--

/
