--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_SETUP_PKG" 
/* $Header: jai_cmn_rgm_setp.plb 120.4.12010000.2 2009/07/09 08:31:38 vkaranam ship $ */
as
/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rgn_setup -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

14-Jun-2005   rchandan for bug#4428980, Version 116.3
              Modified the object to remove literals from DML statements and CURSORS.
16-apr-2007  Vkaranam for bug #5989740,File version 120.2
             Forward Porting the changes done in 115 bug 5907436(Budget Changes).
             1.added the p_doc_class in the end of the decode statement in the c_default cursor

24-Apr-2007  ssawant for bug#5603661. File version 120.3
                1. Cursors which are not closed have been closed
                2. Added the following clause to the cursor c_get_prefix_current.
                   -- FOR UPDATE of current_number

16/5/2007		 csahoo for bug#5233925, File Version 120.4
						 Forward Porting to R12
						 made code changes in the cursor c_rgm_dtl to make it work for unregistered RTV
09-jul-2009    vkaranam for bug#8667957 file version 120.1.12000000.3
               Issue:
	      When attempting to complete the future date AR invoice with VAT taxes, the following error
		  occurs:
		  ERROR
		  -----------------------
		  APP-JA-460204: Document sequencing setup not done at Registration number
		  level
		  Even with the Document sequence setup exists
		  Reason:
		Issue is with the following code in jai_cmn_rgm_setup_pkg.gen_invoice_num

		 SELECT RGM_DOCUMENT_SEQ_ID
		         FROM jai_rgm_doc_seq_hdrs rhdr
		         WHERE rhdr.regime_id            = p_regime_id
		         AND   rhdr.party_id             = p_organization_id
		         AND   rhdr.party_site_id        = p_location_id
		         AND   TRUNC(p_date)  between TRUNC(rhdr.effective_from) and
		 NVL(TRUNC(rhdr.effective_to) ,sysdate) ;
		 In the VAT document sequencing setup,effective to date is given as null.

		 If the effective to date is given as null then the system date is the
		 effective to date.

		 Fix:
		 the default value for the effective to date has been changed as the transaction date instead of sysdate.



*/
PROCEDURE Gen_Invoice_Number(
        p_regime_id                     JAI_RGM_DEFINITIONS.regime_id%Type,
        p_organization_id               hr_all_organization_units.organization_id%Type,
        p_location_id                   hr_locations.location_id%Type,
        p_DATE                          DATE,
        p_doc_class                     jai_rgm_doc_seq_dtls.document_class%Type   ,
        p_doc_type_id                   jai_rgm_doc_seq_dtls.document_class_type_id%Type,
        p_invoice_number OUT NOCOPY VARCHAR2,   /*  caller should call with parameter of size VARCHAR2(100)*/
        p_process_flag OUT NOCOPY VARCHAR2,   /*  caller should call with parameter of size VARCHAR2(2)*/
        p_process_msg OUT NOCOPY VARCHAR2)   /*  caller should call with parameter of size VARCHAR2(1100) atleast*/
IS
lv_prefix                       jai_rgm_doc_seq_dtls.prefix%Type ;
ln_current                      jai_rgm_doc_seq_dtls.current_number%Type ;
ln_end                          jai_rgm_doc_seq_dtls.end_number%Type ;
ln_seq_id                       jai_rgm_doc_seq_dtls.rgm_document_seq_id%Type ;
ln_seq_dtl_id                   jai_rgm_doc_seq_dtls.rgm_document_seq_dtl_id%Type ;
ln_regnum                       JAI_RGM_REGISTRATIONS.attribute_value%Type ;

CURSOR c_rgm_hdr(p_regime_id JAI_RGM_DEFINITIONS.regime_id%Type,
                           p_organization_id hr_all_organization_units.organization_id%Type,
                           p_location_id hr_locations.location_id%Type ,
                           p_date DATE
                           )  IS
        SELECT RGM_DOCUMENT_SEQ_ID
        FROM jai_rgm_doc_seq_hdrs rhdr
        WHERE rhdr.regime_id            = p_regime_id
        AND   rhdr.party_id             = p_organization_id
        AND   rhdr.party_site_id        = p_location_id
       -- AND   TRUNC(p_date)  between TRUNC(rhdr.effective_from) and NVL(TRUNC(rhdr.effective_to) ,sysdate) ;
       AND   TRUNC(p_date)  between TRUNC(rhdr.effective_from) and NVL(TRUNC(rhdr.effective_to) ,TRUNC(p_date)) ; --changed the sysdate default value to TRUNC(p_date) for bug#8667957

CURSOR c_rgm_hdr_regnum(p_regime_id   JAI_RGM_DEFINITIONS.regime_id%Type,
                  ln_regnum     JAI_RGM_REGISTRATIONS.attribute_value%Type,
                  p_date        DATE
                  )  IS
        SELECT rgm_document_seq_id
        FROM jai_rgm_doc_seq_hdrs rhdr
        WHERE rhdr.regime_id            = p_regime_id
        AND   rhdr.registration_num     = ln_regnum
     --   AND   TRUNC(p_date)  between TRUNC(rhdr.effective_from) and NVL(TRUNC(rhdr.effective_to) ,sysdate) ;
       AND   TRUNC(p_date)  between TRUNC(rhdr.effective_from) and NVL(TRUNC(rhdr.effective_to) ,TRUNC(p_date)) ; --changed the sysdate default value to TRUNC(p_date) for bug#8667957

CURSOR c_rgm_regnum(p_regime_id JAI_RGM_DEFINITIONS.regime_id%Type,
                           p_organization_id hr_all_organization_units.organization_id%Type,
                           p_location_id hr_locations.location_id%Type,
			   p_att_type_code  jai_rgm_registrations.attribute_type_Code%TYPE ,   --rchandan for bug#4428980
			   p_att_code       jai_rgm_registrations.attribute_Code%TYPE --rchandan for bug#4428980
                           )  IS
                select attribute_value
                from   JAI_RGM_ORG_REGNS_V
                where  regime_id = p_regime_id
                and    organization_id = p_organization_id
                and    location_id = p_location_id
                and    attribute_type_Code =  p_att_type_code
                and    attribute_code = p_att_code  ;


CURSOR c_rgm_dtl(ln_seq_id jai_rgm_doc_seq_hdrs.rgm_document_seq_id%Type,
                 p_doc_class  jai_rgm_doc_seq_dtls.document_class%Type,
                 p_doc_type_id  jai_rgm_doc_seq_dtls.document_class_Type_id%Type
                           )  IS
        SELECT rgm_document_seq_dtl_id
        FROM jai_rgm_doc_seq_dtls   rdtl
        WHERE rdtl.rgm_document_seq_id          = ln_seq_id
        AND   rdtl.document_class               = p_doc_class
        AND   rdtl.document_class_type_id       =   decode(p_doc_class, 'R', -8888,	  'UR', -8888, --csahoo bug 5233925
                                      p_doc_type_id) ;

CURSOR c_default(ln_seq_id jai_rgm_doc_seq_dtls.rgm_document_seq_dtl_id%Type)
IS
        SELECT rgm_document_seq_dtl_id
        FROM jai_rgm_doc_seq_dtls
        WHERE rgm_document_seq_id = ln_seq_id
        AND    document_class      = DECODE(p_doc_class,'O','D','UO','UD','UI','UD','I','D','R','D','UR','UD',p_doc_class);
      /*added the p_doc_class in the end of the aboive decode statement for bug #5989740 */

CURSOR c_get_prefix_current(ln_seq_dtl_id jai_rgm_doc_seq_dtls.rgm_document_seq_dtl_id%Type)
IS
        SELECT prefix,current_number,end_number
        FROM jai_rgm_doc_seq_dtls
        WHERE rgm_document_seq_dtl_id = ln_seq_dtl_id
	FOR UPDATE of current_number ;   /* Added 'FOR UPDATE OF current_number' by ssawant for bug#5603661 */

BEGIN
        OPEN c_rgm_hdr(p_regime_id, p_organization_id, p_location_id, p_date) ;
        FETCH c_rgm_hdr  into ln_seq_id ;

        IF c_rgm_hdr%FOUND THEN --header exists for regime,location,organization
	close c_rgm_hdr ;-- added by ssawant for bug#5603661
                OPEN c_rgm_dtl(ln_seq_id,p_doc_class,p_doc_Type_id );
                FETCH c_rgm_dtl  into ln_seq_dtl_id ;

                IF c_rgm_dtl%FOUND THEN
                   CLOSE c_rgm_dtl;
                   OPEN  c_get_prefix_current( ln_seq_dtl_id ) ;
                   FETCH c_get_prefix_current INTO lv_prefix,ln_current, ln_end ;
                   CLOSE c_get_prefix_current ;

                   IF  (ln_current +1 ) > NVL(ln_end,ln_current+1)
                   THEN
                /*
                || Coding the ln_current > nvl(ln_end, ln_current+1) to make this check explicitly  false in case the ln_end is NULL
                || so it becomes  infinitely applicable
                */
                        p_process_flag := jai_constants.expected_error;
                        p_process_msg := 'Document Numbers are exhausted. Please set the End number to a larger value';
                        p_invoice_number := 0;
                    ELSIF ((ln_current +1 ) <= NVL(ln_end,ln_current+1) )
                    THEN
                        ln_current := ln_current  + 1;
                        IF lv_prefix is null
                        THEN
                                p_invoice_number := ln_current ;
                        ELSE
                                p_invoice_number := lv_prefix || '/' || ln_current ;
                        END IF;

                        UPDATE jai_rgm_doc_seq_dtls
                        SET  current_number = ln_current
                        WHERE rgm_document_seq_dtl_id  = ln_seq_dtl_id ;

                        p_process_flag := jai_constants.successful ;
                        p_process_msg := 'VAT Invoice Number generated';

                    END IF;
                ELSE /*
		     || This is the else to get the line level default in case the given order / invoice type is not setup
		     */
		        close c_rgm_dtl;-- added by ssawant for bug#5603661
                        OPEN c_default( ln_seq_id );
                        FETCH c_default INTO ln_seq_dtl_id ;
                        if c_default%FOUND
                        THEN
                            CLOSE c_default ;
                            OPEN c_get_prefix_current( ln_seq_dtl_id ) ;
                            FETCH c_get_prefix_current INTO lv_prefix,ln_current, ln_end ;
                            CLOSE c_get_prefix_current ;

                            IF ( (ln_current +1 ) > NVL(ln_end,ln_current + 1) )
                            THEN
                                p_process_flag := jai_constants.expected_error;
                                p_process_msg := 'Document Numbers are exhausted. Please set the End number to a larger value';
                                p_invoice_number := 0;
                            ELSIF ( (ln_current +1 ) <= NVL(ln_end,ln_current + 1) )
                            THEN
                                ln_current := ln_current  + 1 ;
                                IF lv_prefix is null
                                THEN
                                        p_invoice_number := ln_current ;
                                ELSE
                                        p_invoice_number := lv_prefix || '/' || ln_current ;
                                END IF;

                                UPDATE jai_rgm_doc_seq_dtls
                                SET  current_number = ln_current
                                WHERE rgm_document_seq_dtl_id  = ln_seq_dtl_id ;

                                p_process_flag := jai_constants.successful ;
                                p_process_msg := 'VAT Invoice Number generated - default 1';

                            END IF;
                        ELSE
			    close c_default ; -- added by ssawant for bug#5603661
                            p_process_flag := jai_constants.expected_error;
                            p_process_msg := 'No Default document sequence setup exists for the regime / organization / location';
                            p_invoice_number := 0;
            END IF;
                END IF;  /* END IF for detail found */

        ELSIF   c_rgm_hdr%NOTFOUND THEN
         /*
         || Header doesnt exists for such regime,location,organization combination
         || Check the registration number level settings.
         */
            CLOSE c_rgm_hdr ;
            OPEN c_rgm_regnum(p_regime_id, p_organization_id, p_location_id,'PRIMARY','REGISTRATION_NO' ) ;--rchandan for bug#4428980
            FETCH c_rgm_regnum  into ln_regnum ;

            IF c_rgm_regnum%FOUND THEN --regime registration num exists
                CLOSE c_rgm_regnum ;
                OPEN c_rgm_hdr_regnum(p_regime_id, ln_regnum, p_date );
                FETCH c_rgm_hdr_regnum  into ln_seq_id ;

                IF c_rgm_hdr_regnum%FOUND THEN
                   CLOSE c_rgm_hdr_regnum;

                   OPEN c_rgm_dtl(ln_seq_id,p_doc_class,p_doc_type_id );
                   FETCH c_rgm_dtl  into ln_seq_dtl_id ;

                       IF c_rgm_dtl%FOUND THEN
                          CLOSE c_rgm_dtl;
                          OPEN  c_get_prefix_current( ln_seq_dtl_id ) ;
                          FETCH c_get_prefix_current INTO lv_prefix,ln_current, ln_end ;
                          CLOSE c_get_prefix_current ;

                          IF  (ln_current +1 ) > NVL(ln_end,ln_current+1)
                          THEN
                            p_process_flag := jai_constants.expected_error;
                            p_process_msg := 'Document Numbers are exhausted. Please set the End number to a larger value';
                            p_invoice_number := 0;
                          ELSIF ((ln_current +1 ) <= NVL(ln_end,ln_current+1) )
                          THEN
                              ln_current := ln_current  + 1;
                              IF lv_prefix is null
                              THEN
                                 p_invoice_number := ln_current ;
                              ELSE
                                 p_invoice_number := lv_prefix || '/' || ln_current ;
                              END IF;

                              UPDATE jai_rgm_doc_seq_dtls
                              SET  current_number = ln_current
                              WHERE rgm_document_seq_dtl_id  = ln_seq_dtl_id ;

                              p_process_flag := jai_constants.successful ;
                              p_process_msg := 'VAT Invoice Number generated';

                          END IF;
                       ELSE       -- if given doc class doesnt exist for the registration number
		         close c_rgm_dtl; -- added by ssawant for bug#5603661
                         OPEN c_default( ln_seq_id );
                         FETCH c_default INTO ln_seq_dtl_id ;
                         if c_default%FOUND
                         THEN
                           CLOSE c_default ;
                           OPEN c_get_prefix_current( ln_seq_dtl_id ) ;
                           FETCH c_get_prefix_current INTO lv_prefix,ln_current, ln_end ;
                           CLOSE c_get_prefix_current ;

                           IF ( (ln_current +1 ) > NVL(ln_end,ln_current + 1) )
                           THEN
                              p_process_flag := jai_constants.expected_error;
                              p_process_msg := 'Document Numbers are exhausted. Please set the End number to a larger value';
                              p_invoice_number := 0;
                           ELSIF ( (ln_current +1 ) <= NVL(ln_end,ln_current + 1) )
                           THEN
                              ln_current := ln_current  + 1 ;
                              IF lv_prefix is null
                              THEN
                                 p_invoice_number := ln_current ;
                              ELSE
                                 p_invoice_number := lv_prefix || '/' || ln_current ;
                              END IF;

                              UPDATE jai_rgm_doc_seq_dtls
                              SET  current_number = ln_current
                              WHERE rgm_document_seq_dtl_id  = ln_seq_dtl_id ;

                              p_process_flag := jai_constants.successful ;
                              p_process_msg := 'VAT Invoice Number generated - default 2';

                           END IF;
                         ELSE /* No Default exists for the registration number level also */
			    close c_default;  -- added by ssawant for bug#5603661
                            p_process_flag := jai_constants.expected_error;
                            p_process_msg := 'No Default document sequence setup exists for the regime / registration number level';
                            p_invoice_number := 0;
             END IF;
                       END IF; /*  END IF for No detail exists for the registration number */

                ELSE
                   /*
		   || No Setup found for the registration number , hence need to signal an error
		   */
		   close c_rgm_hdr_regnum ; -- added by ssawant for bug#5603661
                   p_process_flag := jai_constants.expected_error;
                   p_process_msg:= 'Document sequencing setup not done at  Registration number level ' ;
                   --registration_num exist for such regime,organization, location combination
                   --Document sequencing not done though setup form
                END IF;
            ELSE
	       close c_rgm_regnum ;  -- added by ssawant for bug#5603661
               p_process_flag := jai_constants.expected_error;
               p_process_msg:= 'Unable to get the registration number for regime +  organization + location ' ;
               --registration_num doesnt exist for such regime,organization, location combination
            END IF ;
         /*
						Commented this code for testing purposes.
						ELSE   --header doesnt exists for such regime,location,organization combination (or) such registration_num

						p_process_flag := jai_constants.expected_error;
						p_process_msg := 'Document Sequencing Setup not done for this Regime, Location and Organization';
						p_invoice_number := 0;
         */
         END IF;
EXCEPTION
WHEN OTHERS THEN
      p_process_flag := jai_constants.unexpected_error ;
      p_process_msg  := 'Exception occurred: ' || SQLCODE || 'Exception Message: ' || substr(SQLERRM,1,1000) ;

END Gen_Invoice_Number;

end jai_cmn_rgm_setup_pkg;

/
