--------------------------------------------------------
--  DDL for Package Body ARP_CINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CINT" AS
/* $Header: ARPLCINB.pls 120.2 2005/10/30 04:24:22 appldev ship $  */

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE EXCEPTIONS                                                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/

ccid_error1 EXCEPTION;
PRAGMA EXCEPTION_INIT( ccid_error1, -20000 );


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/

loc_ccid NUMBER(15) := NULL;
msg_text VARCHAR(240) := NULL;
int_stat VARCHAR(3)   := NULL;

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE CURSORS                                                         |
 |                                                                         |
 |                                                                         |
 +-------------------------------------------------------------------------*/

CURSOR val_address_segs( request_id in number ) IS
       SELECT rci.country             country,
              rci.city                city,
              rci.state               state,
              rci.county              county,
              rci.province            province,
              rci.postal_code         postal_code,
              rci.address_attribute1  attribute1,
              rci.address_attribute2  attribute2,
              rci.address_attribute3  attribute3,
              rci.address_attribute4  attribute4,
              rci.address_attribute5  attribute5,
              rci.address_attribute6  attribute6,
              rci.address_attribute7  attribute7,
              rci.address_attribute8  attribute8,
              rci.address_attribute9  attribute9,
              rci.address_attribute10 attribute10,
              rci.rowid               row_id
	 FROM ra_customers_interface rci ,
	      ar_system_parameters sp
        WHERE rci.interface_status is null
          AND rci.orig_system_address_ref is not null
          AND rci.request_id = request_id
	  AND rci.country    = sp.default_country
          AND rci.rowid in (SELECT min(rci2.rowid)
                              FROM ra_customers_interface rci2
                             WHERE rci2.interface_status is null
                               AND rci2.orig_system_address_ref =
						  rci.orig_system_address_ref
/* Added the site_use_code clause for Bug 235747 which causes all of the *
 * relevant rows to be considered for error checking. Leaving this where *
 * clause causes only 1 of the row from ra_customers_interface to be     *
 * selected. In order to do proper error checking we would like to have  *
 * all those rows which have a distinct combination of address ref and   *
 * site use code.							 */
			       AND NVL(rci2.site_use_code,'X') = NVL(rci.site_use_code,'X')
                               AND rci2.request_id = request_id
                           );


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PROCEDURE up_cust_int                                                   |
 |                                                                         |
 +-------------------------------------------------------------------------*/
PROCEDURE up_cust_int( warning_text_in	     in varchar2,
 		       location_ccid_in 	in number,
  		       message_text_in		in varchar2,
  		       interface_status_in	in varchar2,
  		       rowid_in 		in rowid
  		     ) IS
BEGIN

    UPDATE ra_customers_interface
       SET warning_text	    = warning_text_in,
  	   location_ccid    = location_ccid_in,
  	   message_text	    = message_text_in,
  	   interface_status = interface_status_in
     WHERE rowid	    = rowid_in;
     COMMIT;

END;


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PROCEDURE cint_gen_loc_ccid                                             |
 |                                                                         |
 +-------------------------------------------------------------------------*/
PROCEDURE cint_gen_loc_ccid (h_request_id        in number,
                             h_user_id           in number,
			     h_prog_appl_id      in number,
			     h_program_id        in number,
			     h_last_update_login in number,
			     h_application_id    in number,
			     h_language_id       in number ) IS

BEGIN

        arp_standard.set_who_information( h_user_id,
                                          h_request_id,
                                          h_prog_appl_id,
                                          h_program_id,
                                          h_last_update_login ) ;

        arp_standard.set_application_information( h_application_id,
                                                  h_language_id );

   /*
    * Loop through the address records within the interface
    * table and validate the address segments.
    */
    FOR add_rec IN val_address_segs(h_request_id) LOOP
        BEGIN
            BEGIN
                loc_ccid:=NULL;
                    arp_adds.Set_Location_CCID(add_rec.country,
                                               add_rec.city,
                                               add_rec.state,
                                               add_rec.county,
                                               add_rec.province,
                                               add_rec.postal_code,
                                               add_rec.attribute1,
                                               add_rec.attribute2,
                                               add_rec.attribute3,
                                               add_rec.attribute4,
                                               add_rec.attribute5,
                                               add_rec.attribute6,
                                               add_rec.attribute7,
                                               add_rec.attribute8,
                                               add_rec.attribute9,
                                               add_rec.attribute10,
                                               loc_ccid
                                              );
                IF ( arp_standard.sysparm.address_validation = 'WARN') AND
	           ( arp_adds.location_segment_inserted      =  TRUE )
		THEN
                    arp_cint.up_cust_int( 'Q1,', loc_ccid, null,
					  null, add_rec.row_id );
                ELSE
 		    arp_cint.up_cust_int( '', loc_ccid, '',
					  '', add_rec.row_id );
                END IF;

            EXCEPTION

                WHEN ccid_error1 THEN
		    BEGIN
                        msg_text :=
			arp_standard.fnd_message(ARP_STANDARD.MD_MSG_NUMBER + ARP_STANDARD.MD_MSG_TEXT );
			arp_cint.up_cust_int( '', null, msg_text, 'Q2,', add_rec.row_id );
		    END;

            END;

        END;

    END LOOP;

END; /* end of procedure gen_address_loc_ccid */


END ARP_CINT;

/
