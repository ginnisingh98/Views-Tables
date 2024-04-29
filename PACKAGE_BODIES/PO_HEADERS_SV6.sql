--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV6" AS
/* $Header: POXPIV2B.pls 120.3 2007/10/31 12:50:27 adbharga ship $ */
/* Changed the file name to POXPIV2B.pls from POXPIVHB.pls since
   the file was corrupted . checking in with new name */

/*================================================================

 FUNCTION NAME: 	val_doc_num_uniqueness()

==================================================================*/
 FUNCTION val_doc_num_uniqueness(x_segment1          IN VARCHAR2,
                                 X_rowid             IN VARCHAR2,
                                 X_type_lookup_code  IN VARCHAR2)
 RETURN BOOLEAN IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if the segment1 is unique in po_headers table */
   --<Bug# 3425930 START>
   if X_type_lookup_code in ('BLANKET', 'STANDARD') then
       x_progress := '020';

       SELECT count(*)
         INTO x_temp
         FROM po_headers
        WHERE segment1 = x_segment1
        AND type_lookup_code in ('BLANKET', 'CONTRACT', 'PLANNED', 'STANDARD')
          AND (rowid <> x_rowid OR x_rowid is null);

   elsif X_type_lookup_code = 'QUOTATION' then
       x_progress := '030';

       SELECT count(*)
         INTO x_temp
         FROM po_headers
        WHERE segment1 = x_segment1
          AND type_lookup_code = X_type_lookup_code
          AND (rowid <> x_rowid OR x_rowid is null);
   else
       x_progress := '040';
       -- Do what ? raise exception ??
   end if;
   --<Bug# 3425930 END>

   IF x_temp = 0 THEN
      RETURN TRUE;   /* validation fails */
   ELSE
      RETURN FALSE;  /* validation succeeds */
   END IF;

 EXCEPTION

   WHEN others THEN
        po_message_s.sql_error
        ('val_doc_num_uniqueness', x_progress, sqlcode);
        raise;
 END val_doc_num_uniqueness;

/*================================================================

  FUNCTION NAME: 	val_header_id_uniqueness()

==================================================================*/
 FUNCTION val_header_id_uniqueness(x_po_header_id  IN NUMBER,
                                   x_rowid         IN VARCHAR2)
 RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if the po_header_id already exists in po_headers table,
      if so, FALSE, otherwise, TRUE */

   SELECT COUNT(*)
     INTO x_temp
     FROM po_headers
    WHERE po_header_id = x_po_header_id
     AND (rowid <> x_rowid OR x_rowid is null);

   IF x_temp = 0 THEN   -- no duplicated po_header_id is found
      RETURN TRUE;
   ELSE
      RETURN FALSE;  /* validation fails */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_header_id_uniqueness', x_progress,sqlcode);
      raise;
 END val_header_id_uniqueness;

/*================================================================

  FUNCTION NAME: 	val_rate_info()

==================================================================*/
 FUNCTION val_rate_info(X_base_currency_code   IN  VARCHAR2,
			X_currency_code        IN  VARCHAR2,
			X_rate_type_code       IN  VARCHAR2,
			X_rate_date            IN  DATE,
			X_rate                 IN  NUMBER,
			X_error_code           IN OUT NOCOPY VARCHAR2)
 RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   X_temp_val   boolean;
   X_temp_rate  number;
   x_set_of_books_id       number;                 -- Bug: 2500843
   x_res_display_rate      number := null;         -- Bug: 2500843

 BEGIN
   x_progress := '010';

   IF (nvl(X_base_currency_code,' ') = nvl(X_currency_code,' ')) THEN
      /* make sure all the following columns are NULL */

      IF (X_rate_type_code IS NOT NULL ) THEN
          X_error_code := 'PO_PDOI_RATE_INFO_NULL';
          RETURN FALSE;        /* validation fails */
      END IF;

      x_progress := '020';

      IF (X_rate_date IS NOT NULL ) THEN
         X_error_code := 'PO_PDOI_RATE_INFO_NULL';
         RETURN FALSE;
      END IF;

      x_progress := '030';
      IF (X_rate IS NOT NULL ) THEN
         X_error_code := 'PO_PDOI_RATE_INFO_NULL';
         RETURN FALSE;
      END IF;

   ELSIF (nvl(X_base_currency_code,' ') <> nvl(X_currency_code,' ')) THEN
         x_progress := '040';
         IF (X_rate_type_code is not null ) THEN
           X_temp_val := po_daily_conversion_types_sv1.val_rate_type_code(
                                                           x_rate_type_code);
           IF (X_temp_val = FALSE) THEN
              X_error_code := 'PO_PDOI_INVALID_RATE_TYPE';
              RETURN FALSE;
           END IF;
         END IF;

         x_progress := '050';
         IF (X_rate is null) THEN
            X_error_code := 'PO_PDOI_COLUMN_NOT_NULL';
            RETURN FALSE;
         END IF;

         IF (X_rate < 0) THEN
             X_error_code := 'PO_PDOI_LT_ZERO';
             RETURN FALSE;
         END IF;

         X_progress := '060';
         /* X_rate need to be not null if rate_type_code = 'User'
            X_rate need to be the same as the conversion rate
            if the rate_type_code <> 'User'
         */

         IF (X_rate_type_code is not null) AND
               (X_rate_type_code <> 'User') THEN
              /* get the conversion_rate for gl_daily_conversion_rates
                 table based on the value passed from the parameter */

            X_progress := '070';


	    BEGIN

/* Bug: 2500843 Get the SOB id and then call po_currency_sv.get_rate instead of calling GL api
   directly
*/
                  /*
		    x_temp_rate := gl_currency_api.get_rate (X_currency_code,
			X_base_currency_code,
			X_rate_date,
			X_rate_type_code);
                  */


                  SELECT  fsp.set_of_books_id
                  INTO    X_set_of_books_id
                  FROM    financials_system_parameters fsp,
                          gl_sets_of_books sob
                  WHERE   fsp.set_of_books_id = sob.set_of_books_id;

                                 po_currency_sv.get_rate(X_set_of_books_id,
                                                         X_currency_code,
                                                         X_rate_type_code,
                                                         X_rate_date,
                                                         'N',  /* inverse_rate_display_flag */
                                                         x_temp_rate,
                                                         x_res_display_rate);

			/* Bug 1769714
			** Added round to x_temp_rate.
			** The issue is that here we are calling the gl api directly
			** whereas in default_po_headers we are calling
			** po_currency_sv.get_rate which rounds the resultant rate.
			** Later when we compare the two rates from the two functions,
			** they might not compare since one is rounded the other isn't.
			*/


	    EXCEPTION
		WHEN OTHERS THEN x_temp_rate := 0;

	    END;

          /* rate has to be same with conversion_rate from
             gl_daily_conversion_rates
             table  */

            IF (nvl(X_temp_rate,0) <> nvl(X_rate,0)) THEN
               X_error_code := 'PO_PDOI_INVALID_RATE';
               RETURN FALSE;
            END IF;
         END IF;
   END IF;

   RETURN TRUE;

 EXCEPTION
   WHEN no_data_found THEN
        X_error_code := 'PO_PDOI_NO_DATA_FOUND';
        RETURN FALSE;
   WHEN others THEN
        po_message_s.sql_error('val_rate_info', x_progress,sqlcode);
      raise;
 END val_rate_info;

/*================================================================

  FUNCTION NAME: 	val_doc_num()

==================================================================*/
 FUNCTION val_doc_num(X_doc_type                   IN VARCHAR2,
		      X_doc_num                    IN VARCHAR2,
		      X_user_defined_num           IN VARCHAR2,
		      X_user_defined_po_num_code   IN VARCHAR2,
                      X_error_code                 IN OUT NOCOPY VARCHAR2 )
 RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   X_temp_val   boolean;

 BEGIN
   x_progress := '010';

   /* check to see if doc_num is unique */

   X_temp_val := val_doc_num_uniqueness(X_doc_num,
                                        null,
                                        X_doc_type);
   IF (X_temp_val = FALSE) THEN
      X_error_code := 'PO_PDOI_DOC_NUM_UNIQUE';
      RETURN FALSE;      /* the document_num is not unique */
   END IF;

--frkhan add standard
   IF (X_doc_type in ('QUOTATION', 'BLANKET', 'STANDARD')) THEN

      if (X_doc_type = 'QUOTATION' and X_user_defined_num = 'NUMERIC')
	  OR
	 (X_doc_type in ('BLANKET','STANDARD') and X_user_defined_po_num_code = 'NUMERIC') then

         x_progress := '020';
         X_temp_val := po_core_sv1.val_numeric_value(X_doc_num);
         IF (X_temp_val = FALSE) THEN
            X_error_code := 'PO_PDOI_VALUE_NUMERIC';
            RETURN FALSE;    /* document_num is not numeric */
         END IF;

         IF (X_doc_num <0 ) THEN
            X_error_code := 'PO_PDOI_LT_ZERO';
            RETURN FALSE;
         ELSE
            RETURN TRUE;
         END IF;
      END IF;

    ELSE
      X_progress := '030';
      X_error_code := 'PO_PDOI_INVALID_TYPE_LKUP_CD';
      RETURN FALSE;
    END IF;

    RETURN TRUE;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_doc_num', x_progress,sqlcode);
        raise;
 END val_doc_num;

/*================================================================

  FUNCTION NAME: 	val_lookup_code()

==================================================================*/
 FUNCTION val_lookup_code (X_lookup_code   IN VARCHAR2,
                           X_lookup_type   IN VARCHAR2)
 RETURN BOOLEAN
 IS

    x_progress    varchar2(3) := null;
    x_temp             binary_integer := 0;

 BEGIN
    x_progress := '010';
    /* check to see if the given lookup_code and type is valid */
    SELECT count(*)
      INTO x_temp
      FROM po_lookup_codes
     WHERE lookup_type = X_lookup_type
       AND sysdate < nvl(inactive_date, sysdate+1)
       AND lookup_code = X_lookup_code;

    IF x_temp = 0 THEN
       RETURN FALSE;     /* validation fails */
    ELSE
       RETURN TRUE;      /* validation succeeds */
    END IF;
 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_lookup_code', x_progress, sqlcode);
        raise;
 END val_lookup_code;


/*================================================================

  PROCEDURE NAME: 	validate_po_headers()

==================================================================*/
PROCEDURE  validate_po_headers(
                X_PO_HEADER_ID		        IN NUMBER,
 		X_AGENT_ID  	                IN NUMBER,
 		X_TYPE_LOOKUP_CODE       	IN VARCHAR2,
 		X_LAST_UPDATE_DATE              IN DATE,
 		X_LAST_UPDATED_BY               IN NUMBER,
 		X_SEGMENT1                      IN VARCHAR2,
 		X_SUMMARY_FLAG                  IN VARCHAR2,
 		X_ENABLED_FLAG                  IN VARCHAR2,
 		X_SEGMENT2		        IN VARCHAR2,
 		X_SEGMENT3		        IN VARCHAR2,
 		X_SEGMENT4		        IN VARCHAR2,
 		X_SEGMENT5		        IN VARCHAR2,
 		X_START_DATE_ACTIVE      	IN DATE,
 		X_END_DATE_ACTIVE       	IN DATE,
 		X_LAST_UPDATE_LOGIN	        IN NUMBER,
 		X_CREATION_DATE		        IN DATE,
 		X_CREATED_BY		        IN NUMBER,
 		X_VENDOR_ID		        IN NUMBER,
 		X_VENDOR_SITE_ID	        IN NUMBER,
 		X_VENDOR_CONTACT_ID	        IN NUMBER,
 		X_SHIP_TO_LOCATION_ID	        IN NUMBER,
 		X_BILL_TO_LOCATION_ID	        IN NUMBER,
 		X_TERMS_ID		        IN NUMBER,
 		X_SHIP_VIA_LOOKUP_CODE	        IN VARCHAR2,
 		X_FOB_LOOKUP_CODE	        IN VARCHAR2,
 		X_FREIGHT_TERMS_LOOKUP_CODE     IN VARCHAR2,
 		X_STATUS_LOOKUP_CODE	        IN VARCHAR2,
 		X_CURRENCY_CODE		        IN VARCHAR2,
 		X_RATE_TYPE		        IN VARCHAR2,
 		X_RATE_DATE		        IN DATE,
 		X_RATE			        IN NUMBER,
 		X_FROM_HEADER_ID	        IN NUMBER,
 	        X_FROM_TYPE_LOOKUP_CODE         IN VARCHAR2,
                X_START_DATE		        IN DATE,
 		X_END_DATE		        IN DATE,
 		X_BLANKET_TOTAL_AMOUNT 	        IN NUMBER,
 		X_AUTHORIZATION_STATUS          IN VARCHAR2,
 		X_REVISION_NUM		        IN NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
-- 		X_REVISED_DATE		        IN VARCHAR2,
 		X_REVISED_DATE		        IN DATE,
 		X_APPROVED_FLAG		        IN VARCHAR2,
 		X_APPROVED_DATE		        IN DATE,
 		X_AMOUNT_LIMIT		        IN NUMBER,
 		X_MIN_RELEASE_AMOUNT	        IN NUMBER,
 		X_NOTE_TO_AUTHORIZER 	        IN VARCHAR2,
 		X_NOTE_TO_VENDOR		IN VARCHAR2,
 		X_NOTE_TO_RECEIVER	        IN VARCHAR2,
 		X_PRINT_COUNT		        IN NUMBER,
 		X_PRINTED_DATE		        IN DATE,
 		X_VENDOR_ORDER_NUM   	        IN VARCHAR2,
		X_CONFIRMING_ORDER_FLAG         IN VARCHAR2,
 		X_COMMENTS 		        IN VARCHAR2,
 		X_REPLY_DATE 		        IN  DATE,
 		X_REPLY_METHOD_LOOKUP_CODE      IN VARCHAR2,
 		X_RFQ_CLOSE_DATE 		IN DATE,
 		X_QUOTE_TYPE_LOOKUP_CODE 	IN VARCHAR2,
 		X_QUOTATION_CLASS_CODE 		IN VARCHAR2,
 		X_QUOTE_WARNING_DELAY 		IN NUMBER,
 		X_QUOTE_VENDOR_QUOTE_NUM	IN VARCHAR2,
 		X_ACCEPTANCE_REQUIRED_FLAG 	IN VARCHAR2,
 		X_ACCEPTANCE_DUE_DATE 		IN DATE,
 		X_CLOSED_DATE 			IN DATE,
 		X_USER_HOLD_FLAG 		IN VARCHAR2,
 		X_APPROVAL_REQUIRED_FLAG 	IN VARCHAR2,
 		X_CANCEL_FLAG 			IN VARCHAR2,
 		X_FIRM_STATUS_LOOKUP_CODE 	IN VARCHAR2,
 		X_FIRM_DATE 			IN DATE,
 		X_FROZEN_FLAG 			IN VARCHAR2,
 		X_ATTRIBUTE_CATEGORY 		IN VARCHAR2,
 		X_ATTRIBUTE1 			IN VARCHAR2,
 		X_ATTRIBUTE2 			IN VARCHAR2,
 		X_ATTRIBUTE3 			IN VARCHAR2,
 		X_ATTRIBUTE4 			IN VARCHAR2,
 		X_ATTRIBUTE5 			IN VARCHAR2,
 		X_ATTRIBUTE6 			IN VARCHAR2,
 		X_ATTRIBUTE7 			IN VARCHAR2,
 		X_ATTRIBUTE8 			IN VARCHAR2,
 		X_ATTRIBUTE9 			IN VARCHAR2,
 		X_ATTRIBUTE10 			IN VARCHAR2,
 		X_ATTRIBUTE11 			IN VARCHAR2,
 		X_ATTRIBUTE12 			IN VARCHAR2,
 		X_ATTRIBUTE13 			IN VARCHAR2,
 		X_ATTRIBUTE14 			IN VARCHAR2,
 		X_ATTRIBUTE15 			IN VARCHAR2,
 		X_CLOSED_CODE 			IN VARCHAR2,
 		X_USSGL_TRANSACTION_CODE 	IN VARCHAR2,
 		X_GOVERNMENT_CONTEXT 		IN VARCHAR2,
 		X_REQUEST_ID 			IN NUMBER,
 		X_PROGRAM_APPLICATION_ID 	IN NUMBER,
 		X_PROGRAM_ID 			IN NUMBER,
 		X_PROGRAM_UPDATE_DATE 		IN DATE,
 		X_INTERFACE_SOURCE_CODE		IN VARCHAR2,
		X_INTERFACE_HEADER_ID		IN NUMBER,
		X_REFERENCE_NUM			IN VARCHAR2,
		X_ORG_ID 		        IN NUMBER,
		X_QUOTE_WARNING_DELAY_UNIT 	IN VARCHAR2,
                X_APPROVAL_STATUS		IN VARCHAR2,
                X_release_num                   IN NUMBER,
                X_po_release_id                 IN NUMBER,
                X_release_date                  IN DATE,
                X_manual_quote_num_type         IN VARCHAR2,
		X_manual_po_num_type            IN VARCHAR2,
                X_amount_agreed                 IN NUMBER,
                X_base_currency_code            IN VARCHAR2,
                X_chart_of_accounts_id          IN NUMBER,
                X_def_inv_org_id                IN NUMBER,
		X_header_processable_flag	IN OUT	NOCOPY VARCHAR2,
		X_action_code 			IN VARCHAR2,
                p_shipping_control              IN VARCHAR2    -- <INBOUND LOGISTICS FPJ>
)
IS
   X_progress           VARCHAR2(3)	:= NULL;
   X_temp_val           BOOLEAN;
   x_res_carrier        VARCHAR2(25) := null;
   x_res_fob            varchar2(25) := null;
   x_res_freight        varchar2(25) := null;
   x_res_terms          number := null;
   X_interface_line_id  number := null;
   X_error_code         varchar2(30) := null;
   X_temp_count         binary_integer;
   l_res_shipping_control PO_LOOKUP_CODES.lookup_code%TYPE := NULL;    -- <INBOUND LOGISTICS FPJ>

BEGIN
  X_progress := '010';

  IF (x_type_lookup_code is null) THEN
     po_interface_errors_sv1.handle_interface_errors(
                                     'PO_DOCS_OPEN_INTERFACE',
                                     'FATAL',
		           	      null,
	          		      X_interface_header_id,
				      X_interface_line_id,
			             'PO_PDOI_COLUMN_NOT_NULL',
			       	     'PO_HEADERS_INTERAFCE',
				     'TYPE_LOOKUP_CODE',
				     'COLUMN_NAME',
				      null,null,null,null,null,
				     'TYPE_LOOKUP_CODE',
				      null,null,null,null,null,
                                      x_header_processable_flag);
  END IF;

  X_progress := '011';
--frkhan add standard
  IF (x_type_lookup_code not in ('QUOTATION', 'BLANKET', 'STANDARD')) THEN
     po_interface_errors_sv1.handle_interface_errors(
                                     'PO_DOCS_OPEN_INTERFACE',
                                     'FATAL',
                                      null,
                                      X_interface_header_id,
                                      X_interface_line_id,
                                     'PO_PDOI_INVALID_TYPE_LKUP_CD',
                                     'PO_HEADERS_INTERAFCE',
                                     'TYPE_LOOKUP_CODE',
                                     'VALUE',
                                      null,null,null,null,null,
                                      x_type_lookup_code,
                                      null,null,null,null,null,
                                      x_header_processable_flag);
  END IF;

  X_progress := '020';
  IF (x_type_lookup_code = 'QUOTATION') THEN
     BEGIN
       SELECT count(*)
         INTO x_temp_count
         FROM po_document_types
        WHERE document_type_code = X_type_lookup_code
          AND document_subtype = x_quote_type_lookup_code;

       IF (x_temp_count = 0) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           	        null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_INVALID_QUOTE_TYPE_CD',
	          	          	'PO_HEADERS_INTERFACE',
		          		'QUOTE_TYPE_LOOKUP_CODE',
					'VALUE',
					null,null,null,null,null,
					X_quote_type_lookup_code,
					null,null,null,null,null,
                                        x_header_processable_flag);
       END IF;
     END;

	/* All the following columns are mandatory */
     X_progress := '030';
     If  (X_quote_warning_delay IS NULL ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'QUOTE_WARNING_DELAY',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'QUOTE_WARNING_DELAY',
					null,null,null,null,null,
                                        x_header_processable_flag);
     END IF;

     X_progress := '040';
     IF  (X_approval_required_flag IS NULL ) THEN
  	 po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'APPROVAL_REQUIRED_FLAG',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'APPROVAL_REQUIRED_FLAG',
					null,null,null,null,null,
                                        x_header_processable_flag);
      END IF;

      X_progress := '050';
      IF  (X_created_by IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'CREATED_BY',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'CREATED_BY',
					null,null,null,null,null,
                                        x_header_processable_flag);
       END IF;

	X_progress := '060';
	IF  (X_creation_date IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                              'PO_DOCS_OPEN_INTERFACE',
                                              'FATAL',
		           			null,
		          			X_interface_header_id,
		         			X_interface_line_id,
		       				'PO_PDOI_COLUMN_NOT_NULL',
		       	          		'PO_HEADERS_INTERFACE',
						'CREATION_DATE',
						'COLUMN_NAME',
						null,null,null,null,null,
		          			'CREATION_DATE',
						null,null,null,null,null,
                                                x_header_processable_flag);
	END IF;

      X_progress := '070';
--frkhan add standard
  ELSIF (X_type_lookup_code in ('BLANKET','STANDARD')) THEN
     IF (X_quote_type_lookup_code is not null) THEN
        po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
                                        null,
                                        X_interface_header_id,
                                        X_interface_line_id,
                                        'PO_PDOI_COLUMN_NULL',
                                        'PO_HEADERS_INTERFACE',
                                        'DOCUMENT_SUBTYPE',
                                        'COLUMN_NAME',
                                        'VALUE',
                                        null,null,null,null,
                                        'DOCUMENT_SUBTYPE',
                                        X_quote_type_lookup_code,
                                        null,null,null,null,
                                        x_header_processable_flag);

     END IF;

     X_progress := '075';
	IF  (X_acceptance_required_flag IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		       	          	'PO_HEADERS_INTERFACE',
					'ACCEPTANCE_REQUIRED_FLAG',
					'COLUMN_NAME',
					 null,null,null,null,null,
		          		'ACCEPTANCE_REQUIRED_FLAG',
					 null,null,null,null,null,
                                         x_header_processable_flag);

	END IF;
      X_progress := '080';

      --
      -- Do not need this check for a "UPDATE" action. Blanket can have non-zero revision number.
      --

      IF (X_action_code <> 'UPDATE' AND  X_revision_num <> 0) THEN
	  po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_ZERO',
		       	          	'PO_HEADERS_INTERFACE',
					'REVISION_NUM',
					'COLUMN_NAME',
					 null,null,null,null,null,
		       		        'REVISION_NUM',
					 null,null,null,null,null,
                                         x_header_processable_flag);

	END IF;
  END IF;

  X_progress := '090';
--frkhan add standard
  IF ( X_type_lookup_code IN ('QUOTATION', 'BLANKET', 'STANDARD')) THEN
     /*** validations common to both blanket/standard and quote ***/
     IF  (X_segment1 IS NULL ) THEN
	 po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
			    		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'DOCUMENT_NUM',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'DOCUMENT_NUM',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;
	X_progress := '100';
	IF  (X_po_header_id IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
			    		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		         	      	'PO_HEADERS_INTERFACE',
					'PO_HEADER_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'PO_HEADER_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '110';
	IF  (X_currency_code IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	        X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'CURRENCY_CODE',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'CURRENCY_CODE',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '120';
	IF  (X_agent_id IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		         	      	'PO_HEADERS_INTERFACE',
					'AGENT_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'AGENT_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '130';
	IF  (X_vendor_id IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                         'FATAL',
		           		 null,
		          		 X_interface_header_id,
		         		 X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'VENDOR_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'VENDOR_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '140';
/* Bug 1541387: For the corresponding enhancement request, now allowing
Quotations to be loaded without the vendor_site_code and hence moving the
following piece of code to validations meant for Blankets only.

	IF  (X_vendor_site_id IS NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		         	      	'PO_HEADERS_INTERFACE',
					'VENDOR_SITE_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'VENDOR_SITE_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;
*/
        X_progress := '143';
	IF (X_ship_to_location_id IS NULL) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		         	      	'PO_HEADERS_INTERFACE',
					'SHIP_TO_LOCATION_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'SHIP_TO_LOCATION_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;


	X_progress := '145';
	IF (X_bill_to_location_id IS NULL) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
		       			'PO_PDOI_COLUMN_NOT_NULL',
		         	      	'PO_HEADERS_INTERFACE',
					'BILL_TO_LOCATION_ID',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'BILL_TO_LOCATION_ID',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;


	X_progress := '150';
	IF (X_last_updated_by IS NULL ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'LAST_UPDATED_BY',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'LAST_UPDATED_BY',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '160';
	IF  (X_last_update_date IS NULL ) THEN
	     po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'LAST_UPDATE_DATE',
					'COLUMN_NAME',
					null,null,null,null,null,
		          		'LAST_UPDATE_DATE',
					null,null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '170';
	/*** The following columns have to be NULL for both blankets
		and quotes ****/

	IF  (X_release_num IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'RELEASE_NUM',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'RELEASE_NUM',
		          		X_release_num,
					null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '180';
	IF  (X_po_release_id IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'PO_RELEASE_ID',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'PO_RELEASE_ID',
		          		X_po_release_id,
					null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '190';
	IF  (X_release_date IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'RELEASE_DATE',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'RELEASE_DATE',
			      		X_release_date,
					null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '200';
	IF  (X_revised_date IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'REVISED_DATE',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'REVISED_DATE',
		          		X_revised_date,
					null,null,null,null,
                                        x_header_processable_flag);

	/* gtummala. 6/12/97
         * There was an "END IF" missing here so I added it.
         */

        END IF;

	X_progress := '215';
	IF  (X_user_hold_flag IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'USER_HOLD_FLAG',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'USER_HOLD_FLAG',
		          		X_user_hold_flag,
					null,null,null,null,
                                        x_header_processable_flag);

	END IF;

	X_progress := '217';
	IF  (X_printed_date IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'PRINTED_DATE',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'PRINTED_DATE',
		          		X_printed_date,
					null,null,null,null,
                                        x_header_processable_flag);
	END IF;

	X_progress := '219';
	IF  (X_closed_date IS NOT NULL ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
	          	          	'PO_HEADERS_INTERFACE',
					'CLOSED_DATE',
					'COLUMN_NAME',
                                        'VALUE',
					null,null,null,null,
                                        'CLOSED_DATE',
		          		X_closed_date,
					null,null,null,null,
                                        x_header_processable_flag);
	END IF;

  END IF; /* X_type_lookup_code in ('QUOTATION', 'BLANKET') */

  X_progress := '210';
  IF (X_po_header_id IS NOT NULL ) THEN
     X_temp_val := po_headers_sv6.val_header_id_uniqueness(X_po_header_id,
						            null /* rowid */);
      IF ( X_temp_val = FALSE ) THEN
	 po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_PO_HDR_ID_UNIQUE',
					 'PO_HEADERS_INTERFACE',
					 'PO_HEADER_ID',
                                         'VALUE',
					 null,null,null,null,null,
	     				 X_po_header_id,
					 null,null,null,null, null,
                                         x_header_processable_flag);

      END IF;
  END IF;

  X_progress := '220';

  -- Bug 679535 - skip validation for po number as the number generation is defered till commit time.
  -- Validation will only be skipped if no document number is provided in the flat file

  IF (X_segment1 IS NOT NULL and X_segment1 <> 'POI_Temp_PO_b679535') THEN

      X_temp_val := po_headers_sv6.val_doc_num(
                                           X_type_lookup_code,
					   X_segment1,
					   X_manual_quote_num_type,
					   X_manual_po_num_type,
                                           X_error_code);

	IF ( X_temp_val = FALSE ) THEN
           IF (X_error_code = 'PO_PDOI_DOC_NUM_UNIQUE') THEN
              po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 X_error_code,
					 'PO_HEADERS_INTERFACE',
					 'DOCUMENT_NUM',
					 'VALUE',
					 null,null,null,null,null,
	   				 X_segment1,
					 null,null,null,null,null,
                                         x_header_processable_flag);

           ELSIF (X_error_code = 'PO_PDOI_VALUE_NUMERIC') THEN
              po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                         'PO_HEADERS_INTERFACE',
                                         'DOCUMENT_NUM',
                                         'COLUMN_NAME',
                                         'VALUE',
                                         null,null,null,null,
                                         'DOCUMENT_NUM',
                                         X_segment1,
                                         null,null,null,null,
                                         x_header_processable_flag);

           ELSIF (X_error_code = 'PO_PDOI_LT_ZERO') THEN
              po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                         'PO_HEADERS_INTERFACE',
                                         'DOCUMENT_NUM',
                                         'COLUMN_NAME',
                                         'VALUE',
                                         null,null,null,null,
                                         'DOCUMENT_NUM',
                                         X_segment1,
                                         null,null,null,null,
                                         x_header_processable_flag);

           ELSIF (X_error_code = 'PO_PDOI_INVALID_TYPE_LKUP_CD') THEN
              po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                         'PO_HEADERS_INTERFACE',
                                         'TYPE_LOOKUP_CODE',
                                         'VALUE',
                                         null,null,null,null,null,
                                         X_type_lookup_code,
                                         null,null,null,null,null,
                                         x_header_processable_flag);
           END IF;
    	END IF;
  END IF;

  X_progress := '230';
  IF (X_currency_code IS NOT NULL ) THEN
      X_temp_val := po_currency_sv.val_currency(X_currency_code);
      IF ( X_temp_val = FALSE ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_CURRENCY',
					 'PO_HEADERS_INTERFACE',
					 'CURRENCY_CODE',
					 'VALUE',
					 null,null,null,null,null,
					 X_currency_code,
					 null,null,null,null,null,
                                         x_header_processable_flag);
    	END IF;
  END IF;

  X_progress := '240';
  IF (X_base_currency_code is not null) AND
     (x_currency_code is not null)
  THEN
     X_temp_val := po_headers_sv6.val_rate_info(X_base_currency_code,
                                                X_currency_code,
                                                X_rate_type,
                                                X_rate_date,
                                                X_rate,
                                                X_error_code);
     IF ( X_temp_val = FALSE ) THEN
         IF (X_error_code = 'PO_PDOI_NO_DATA_FOUND') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'RATE',
                                        'CURRENCY',
                                        'RATE_TYPE',
                                         null,null,null,null,
                                         X_currency_code,
                                         X_rate_type,
                                         null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_RATE_INFO_NULL') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                         NULL,
                                         null,null,null,null,null,null,
                                         null,
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_INVALID_RATE_TYPE') THEN
           po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'RATE_TYPE' ,
                                        'VALUE',
                                         null,null,null,null,null,
                                         X_rate_type,
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_COLUMN_NOT_NULL') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'RATE',
                                        'COLUMN_NAME',
                                         null,null,null,null,null,
                                        'RATE',
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_INVALID_RATE') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'RATE',
                                        'VALUE',
                                         null,null,null,null,null,
                                         X_rate,
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_LT_ZERO') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'RATE',
                                        'COLUMN_NAME',
                                        'VALUE',
                                         null,null,null,null,
                                        'RATE',
                                         X_rate,
                                         null,null,null,null,
                                         x_header_processable_flag);

         END IF;
     END IF;
  END IF;

  X_progress := '250';
  IF (X_agent_id IS NOT NULL ) THEN
	X_temp_val := po_agents_sv1.val_agent_id(x_agent_id);
      IF ( X_temp_val = FALSE ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_BUYER',
					 'PO_HEADERS_INTERFACE',
					 'AGENT_ID',
					 'VALUE',
					 null,null,null,null,null,
					 X_agent_id,
					 null,null,null,null,null,
                                         x_header_processable_flag);

	END IF;
  END IF;

  X_progress := '260';
  IF (X_vendor_id is not null)
  THEN
     X_temp_val := po_vendors_sv1.val_vendor_info(X_vendor_id,
                                                  'PO SITE',
                                                  X_vendor_site_id,
                                                  X_vendor_contact_id,
                                                  X_error_code);
     IF ( X_temp_val = FALSE ) THEN
         IF (X_error_code = 'PO_PDOI_INVALID_VENDOR') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'VENDOR_ID',
                                        'VALUE',
                                         null,null,null,null,null,
                                         X_vendor_id,
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_INVALID_VENDOR_SITE') THEN
            po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
                                         null,
                                         X_interface_header_id,
                                         X_interface_line_id,
                                         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'VENDOR_SITE_ID',
                                        'VALUE',
                                         null,null,null,null,null,
                                         X_vendor_site_id,
                                         null,null,null,null,null,
                                         x_header_processable_flag);

         ELSIF (X_error_code = 'PO_PDOI_INVALID_VDR_CNTCT') THEN
	     po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
				         X_error_code,
                                        'PO_HEADERS_INTERFACE',
                                        'VENDOR_CONTACT_ID',
                                        'VALUE',
					 null,null,null,null,null,
					 X_vendor_contact_id,
					 null,null,null,null,null,
                                         x_header_processable_flag);
         END IF;
    END IF;
  END IF;

  X_progress := '270';
  IF (X_ship_to_location_id IS NOT NULL ) THEN
     X_temp_val := po_line_locations_sv1.val_location_id(
                                                      X_ship_to_location_id,
					              'SHIP_TO');

      IF ( X_temp_val = FALSE ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_SHIP_LOC_ID',
					 'PO_HEADERS_INTERFACE',
					 'SHIP_TO_LOCATION_ID',
					 'VALUE',
					 null,null,null,null,null,
					 X_ship_to_location_id,
					 null,null,null,null,null,
                                         x_header_processable_flag);
	END IF;
  END IF;

  X_progress := '280';
  IF (X_bill_to_location_id IS NOT NULL) THEN
     X_temp_val := po_line_locations_sv1.val_location_id(
                                                       X_bill_to_location_id,
					               'BILL_TO');

	IF ( X_temp_val = FALSE ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_BILL_LOC_ID',
					 'PO_HEADERS_INTERFACE',
					 'BILL_TO_LOCATION_ID',
					 'VALUE',
					 null,null,null,null,null,
					 X_bill_to_location_id,
					 null,null,null,null,null,
                                         x_header_processable_flag);
	END IF;
  END IF;

  X_progress := '290';
  IF (X_terms_id IS NOT NULL ) THEN
     po_terms_sv.val_ap_terms(X_terms_id, x_res_terms);
     IF ( x_res_terms is null ) THEN
	  po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_PAY_TERMS',
					 'PO_HEADERS_INTERFACE',
					 'TERMS_ID',
					 'VALUE',
					 null,null,null,null,null,
					 X_terms_id,
					 null,null,null,null,null,
                                         x_header_processable_flag);
     END IF;
  END IF;

  X_progress := '300';
  If (X_ship_via_lookup_code IS NOT NULL ) AND (X_def_inv_org_id is not null)
  THEN
     po_vendors_sv.val_freight_carrier(X_ship_via_lookup_code,
                                       X_def_inv_org_id,
                                       X_res_carrier);
     IF ( X_res_carrier is null ) THEN
	  po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_FREIGHT_CARR',
					 'PO_HEADERS_INTERFACE',
					 'SHIP_VIA_LOOKUP_CODE',
					 'VALUE',
					 null,null,null,null,null,
					 X_ship_via_lookup_code,
					 null,null,null,null,null,
                                         x_header_processable_flag);
     END IF;
  END IF;

  X_progress := '310';
  IF (X_fob_lookup_code IS NOT NULL ) THEN
	po_vendors_sv.val_fob(X_fob_lookup_code, x_res_fob);
      IF ( x_res_fob is null ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_FOB',
					 'PO_HEADERS_INTERFACE',
					 'FOB_LOOKUP_CODE',
					 'VALUE',
					 null,null,null,null,null,
					 X_fob_lookup_code,
					 null,null,null,null,null,
                                         x_header_processable_flag);

	END IF;
  END IF;

  X_progress := '320';
  IF (X_freight_terms_lookup_code IS NOT NULL ) THEN
	po_vendors_sv.val_freight_terms(X_freight_terms_lookup_code,
                                        x_res_freight);
      IF ( x_res_freight is null ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_FREIGHT_TERMS',
					 'PO_HEADERS_INTERFACE',
					 'FREIGHT_TERMS_LOOKUP_CODE',
					 'VALUE',
					 null,null,null,null,null,
					 X_freight_terms_lookup_code,
					 null,null,null,null,null,
                                         x_header_processable_flag);
	END IF;
  END IF;

/* <INBOUND LOGISTICS FPJ START> */
  X_progress := '325';
  IF ( p_shipping_control IS NOT NULL ) THEN
        PO_VENDORS_SV.val_shipping_control( p_shipping_control,
                                            l_res_shipping_control);
      IF ( l_res_shipping_control IS NULL ) THEN
          PO_INTERFACE_ERRORS_SV1.handle_interface_errors (
              'PO_DOCS_OPEN_INTERFACE',
              'FATAL',
              NULL,
              X_interface_header_id,
              X_interface_line_id,
              'PO_PDOI_INVALID_SHIPPING_CTRL',
              'PO_HEADERS_INTERFACE',
              'SHIPPING_CONTROL',
              'VALUE',
              NULL,NULL,NULL,NULL,NULL,
              p_shipping_control,
              NULL,NULL,NULL,NULL,NULL,
              x_header_processable_flag);
      END IF;
  END IF;
/* <INBOUND LOGISTICS FPJ END> */

  X_progress := '330';
  IF  (X_type_lookup_code = 'QUOTATION') THEN
	IF (X_approval_required_flag IS NOT NULL ) THEN
	   X_temp_val := po_core_sv1.val_flag_value(x_approval_required_flag);
	   IF ( X_temp_val = FALSE ) THEN
		po_interface_errors_sv1.handle_interface_errors(
                                            'PO_DOCS_OPEN_INTERFACE',
                                            'FATAL',
		           		     null,
		          		     X_interface_header_id,
		         		     X_interface_line_id,
	          			    'PO_PDOI_INVALID_FLAG_VALUE',
	          	          	    'PO_HEADERS_INTERFACE',
					    'APPROVAL_REQUIRED_FLAG',
				 	    'COLUMN_NAME',
                                            'VALUE',
					    null,null,null,null,
                                            'APPROVAL_REQUIRED_FLAG',
	     				    X_approval_required_flag,
					    null,null,null,null,
                                            x_header_processable_flag );

	    END IF;
	 END IF;
       X_progress := '340';
       IF (X_quote_warning_delay < 0 ) THEN
	    po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           		null,
		          		X_interface_header_id,
		       		        X_interface_line_id,
			          	'PO_PDOI_LT_ZERO',
			          	'PO_HEADERS_INTERFACE',
					'QUOTE_WARNING_DELAY',
					'COLUMN_NAME',
                                        'VALUE',
					 null,null,null,null,
                                        'QUOTE_WARNING_DELAY',
	     				 X_quote_warning_delay,
					 null,null,null,null,
                                         x_header_processable_flag  );

       END IF;

       X_progress := '350';
       IF (X_reply_method_lookup_code IS NOT NULL ) THEN
          X_temp_val := po_headers_sv6.val_lookup_code(
                                               X_reply_method_lookup_code,
					     'REPLY/RECEIVE VIA');
          IF ( X_temp_val = FALSE ) THEN
	     po_interface_errors_sv1.handle_interface_errors(
                                         'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					 'PO_PDOI_INVALID_REPLY_METHOD',
					 'PO_HEADERS_INTERFACE',
					 'REPLY_METHOD_LOOKUP_CODE',
				         'VALUE',
					 null,null,null,null,null,
	     				 X_reply_method_lookup_code,
					 null,null,null,null,null,
                                         x_header_processable_flag);
	END IF;
  END IF;
  END IF; /* end x_type_lookup_code = 'QUOTATION' */

  X_progress := '360';
--frkhan add standard
  IF  (X_type_lookup_code in ('BLANKET','STANDARD')) THEN
      /*** validations which apply to Blanket agreements only ***/

      IF (X_confirming_order_flag IS NOT NULL ) THEN
	   X_temp_val := po_core_sv1.val_flag_value(x_confirming_order_flag);
	   IF ( X_temp_val = FALSE ) THEN
		po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         	 	X_interface_line_id,
		       			'PO_PDOI_INVALID_FLAG_VALUE',
		       	          	'PO_HEADERS_INTERFACE',
				 	'CONFIRMING_ORDER_FLAG',
				 	'COLUMN_NAME',
                                        'VALUE',
				 	null,null,null,null,
                                        'CONFIRMING_ORDER_FLAG',
	     			 	X_confirming_order_flag,
				 	null,null,null,null,
                                        x_header_processable_flag );
	   END IF;
 	END IF;

      X_progress := '370';
      IF (X_acceptance_required_flag IS NOT NULL ) THEN
	   X_temp_val := po_core_sv1.val_flag_value(
                                          x_acceptance_required_flag);
	   IF ( X_temp_val = FALSE ) THEN
		po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		 X_interface_line_id,
	          			'PO_PDOI_INVALID_FLAG_VALUE',
		          	      	'PO_HEADERS_INTERFACE',
				 	'ACCEPTANCE_REQUIRED_FLAG',
				 	'COLUMN_NAME',
                                        'VALUE',
				 	null,null,null,null,
                                        'ACCEPTANCE_REQUIRED_FLAG',
				 	X_acceptance_required_flag,
				 	null,null,null,null,
                                        x_header_processable_flag);
	    END IF;
      END IF;
      X_progress := '380';

     -- bug6601134(obsoleted 4467491)
     -- Removing the required property of acceptance due date
     -- when acceptance_required_flag is 'Y' to be consistent
     -- with forms behavior

/*
     IF (X_acceptance_required_flag = 'Y' ) THEN
	  IF ( X_acceptance_due_date IS NULL ) THEN
		po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		 X_interface_line_id,
	          			'PO_PDOI_COLUMN_NOT_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'ACCEPTANCE_DUE_DATE',
					'COLUMN_NAME',
					null,null,null,null,null,
	     		                'ACCEPTANCE_DUE_DATE',
					null,null,null,null,null,
                                        x_header_processable_flag );

	   END IF;
      ELSIF */

	IF(X_acceptance_required_flag = 'N') AND
	    (X_acceptance_due_date IS NOT NULL) THEN
		po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		 X_interface_line_id,
	          			'PO_PDOI_COLUMN_NULL',
		          	      	'PO_HEADERS_INTERFACE',
					'ACCEPTANCE_DUE_DATE',
					'COLUMN_NAME',
					null,null,null,null,null,
	     		                'ACCEPTANCE_DUE_DATE',
					null,null,null,null,null,
                                        x_header_processable_flag );
      END IF;

      X_progress := '390';
--frkhan, just for blankets
   IF  (X_type_lookup_code = 'BLANKET') THEN
      IF (X_amount_agreed < 0 ) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		 X_interface_line_id,
		       			'PO_PDOI_LT_ZERO',
		       	          	'PO_HEADERS_INTERFACE',
					'AMOUNT_AGREED',
					'COLUMN_NAME',
                                        'VALUE',
					 null,null,null,null,
                                        'AMOUNT_AGREED',
	     				 X_amount_agreed,
					 null,null,null,null,
                                         x_header_processable_flag );

	END IF;
     END IF;

      X_progress := '400';

	X_progress := '420';
	IF (X_firm_status_lookup_code IS NOT NULL) AND
	   (X_firm_status_lookup_code NOT IN ('Y', 'N')) THEN

		po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
		           		null,
		          		X_interface_header_id,
		         		 X_interface_line_id,
	          			'PO_PDOI_INVALID_FLAG_VALUE',
		          	      	'PO_HEADERS_INTERFACE',
				 	'FIRM_STATUS_LOOKUP_CODE',
				 	'COLUMN_NAME',
                                        'VALUE',
				 	null,null,null,null,
                                        'FIRM_STATUS_LOOKUP_CODE',
				 	X_firm_status_lookup_code,
				 	null,null,null,null,
                                        x_header_processable_flag);
	END IF;

        X_progress := '420';
	IF (X_cancel_flag <> 'N') THEN
	      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
				       'PO_PDOI_INVALID_VALUE',
				       'PO_HEADERS_INTERFACE',
				       'CANCEL_FLAG',
				       'COLUMN_NAME',
				       'VALUE',null,null,null,null,
					 'CANCEL_FLAG',
					 X_cancel_flag,null,null,null,null,
                                         x_header_processable_flag);

	END IF;

        X_progress := '430';
	IF (X_closed_code <> 'OPEN') THEN
	      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
				       'PO_PDOI_INVALID_VALUE',
				       'PO_HEADERS_INTERFACE',
				       'CLOSED_CODE',
				       'COLUMN_NAME',
				       'VALUE',null,null,null,null,
					 'CLOSED_CODE',
					 X_closed_code,null,null,null,null,
                                         x_header_processable_flag);
	END IF;

        X_progress := '440';
/* Fix 2560428 draising */
        IF X_approval_status <> 'APPROVED'  then
            IF (X_print_count <> 0) then
              po_interface_errors_sv1.handle_interface_errors(
                              'PO_DOCS_OPEN_INTERFACE',
                              'FATAL',
                                null,
                                X_interface_header_id,
                                X_interface_line_id,
                                 'PO_PDOI_INVALID_VALUE',
                                      'PO_HEADERS_INTERFACE',
                                      'PRINT_COUNT',
                                      'COLUMN_NAME',
                                      'VALUE',null,null,null,null,
                                        'PRINT_COUNT',
                                         '0',
                                                null,null,null,null,
                                        x_header_processable_flag);
             END IF;
        END IF;

        X_progress := '450';

-- Bug: 2466897 The value of frozen flag would be either Y or N

	IF (X_frozen_flag not in ('Y', 'N' )) THEN
	      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
				       'PO_PDOI_INVALID_VALUE',
				       'PO_HEADERS_INTERFACE',
				       'FROZEN_FLAG',
				       'COLUMN_NAME',
				       'VALUE',null,null,null,null,
					 'FROZEN_FLAG',
					 X_frozen_flag,null,null,null,null,
                                         x_header_processable_flag);
	END IF;
/* Bug No. 1541387: For the corresponding enhancement request, now allowing
Quotations to be loaded without the vendor_site_code and hence moving the
following piece of code to validations meant for Blankets only.*/
        IF  (X_vendor_site_id IS NULL ) THEN
               po_interface_errors_sv1.handle_interface_errors(
                                       'PO_DOCS_OPEN_INTERFACE',
                                       'FATAL',
                                        null,
                                        X_interface_header_id,
                                        X_interface_line_id,
                                        'PO_PDOI_COLUMN_NOT_NULL',
                                        'PO_HEADERS_INTERFACE',
                                        'VENDOR_SITE_ID',
                                        'COLUMN_NAME',
                                        null,null,null,null,null,
                                        'VENDOR_SITE_ID',
                                        null,null,null,null,null,
                                        x_header_processable_flag);

        END IF;


  END IF; /* type_lookup_code = 'BLANKET' */

  X_progress := '460';
  IF (X_start_date is not null) AND (X_end_date is not null) THEN
     X_temp_val := po_core_sv1.val_start_and_end_date(X_start_date,
                                                      X_end_date);
     IF (X_temp_val = FALSE) THEN
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           	 	null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_INVALID_START_DATE',
	          	          	'PO_HEADERS_INTERFACE',
					'START_DATE',
                                        'VALUE',
					 null,null,null,null,null,
                                         X_start_date,
					 null,null,null,null,null,
                                         x_header_processable_flag );
     END IF;
  END IF;

  --<JFMIP Vendor Registration FPJ Start>
  x_progress := '470';
  -- (1) QUOTATION is out of scope; STANDARD and BLANKET need to be validated
  -- (2) UPDATE only updates lines, does not update vendor/vendor site. Since
  -- this piece of code is not called if action is UPDATE, omit the condition
  -- (3) INCOMPLETE or INITIATE APPROVAL do no need to pass this validation
  IF (x_type_lookup_code <> 'QUOTATION')
  -- AND (x_action_code <> 'UPDATE')
     AND ((x_approval_status = 'APPROVED')
         OR (x_approval_status IS NULL AND x_authorization_status = 'APPROVED'))
     AND (x_vendor_id IS NOT NULL)
     AND (x_vendor_site_id IS NOT NULL) THEN

     -- Call PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis to check the
     -- Central Contractor Registration (CCR) status of the vendor site
     x_temp_val := PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis(
                           p_vendor_id      => x_vendor_id,
                           p_vendor_site_id => x_vendor_site_id);

     IF (x_temp_val = FALSE) THEN
	 PO_INTERFACE_ERRORS_SV1.handle_interface_errors(
            x_interface_type      => 'PO_DOCS_OPEN_INTERFACE',
            x_error_type          => 'FATAL',
            x_batch_id            => null,
            x_interface_header_id => x_interface_header_id,
            x_interface_line_id   => x_interface_line_id,
	    x_error_message_name  => 'PO_PDOI_VENDOR_SITE_CCR_INV',
	    x_table_name          => 'PO_HEADERS_INTERFACE',
            x_column_name         => 'VENDOR_SITE_ID',
            x_tokenname1          => 'VENDOR_ID',
            x_tokenname2          => 'VENDOR_SITE_ID',
            x_tokenname3          => null,
            x_tokenname4          => null,
            x_tokenname5          => null,
            x_tokenname6          => null,
            x_tokenvalue1         => x_vendor_id,
            x_tokenvalue2         => x_vendor_site_id,
            x_tokenvalue3         => null,
            x_tokenvalue4         => null,
            x_tokenvalue5         => null,
            x_tokenvalue6         => null,
            x_header_processable_flag => x_header_processable_flag,
            x_interface_dist_id   => null);
     END IF;
  END IF;
  --<JFMIP Vendor Registration FPJ End>

  X_progress := '480';
  /** also need to make sure approval_status specified is valid ***/
  /* Now Initiate Approval is also valid for Standard Po's.   */
  IF (X_approval_status NOT IN ('INCOMPLETE', 'APPROVED', 'INITIATE APPROVAL')) THEN
	/*** should be an error here ***/
	   po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
		           	 	null,
		          		X_interface_header_id,
		         		X_interface_line_id,
	          			'PO_PDOI_INVALID_STATUS',
	          	          	'PO_HEADERS_INTERFACE',
					'APPROVAL_STATUS',
                                        null,null,null,null,null,null,
                                        null,null,null,null,null,null,
                                         x_header_processable_flag );

  END IF;

EXCEPTION

  WHEN others THEN
       po_message_s.sql_error('validate_po_headers', x_progress, sqlcode);
       raise;
END validate_po_headers;


 END PO_HEADERS_SV6;

/
