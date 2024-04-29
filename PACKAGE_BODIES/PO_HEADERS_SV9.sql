--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV9" AS
/* $Header: POXPIRDB.pls 115.22 2004/05/25 21:14:59 dreddy ship $ */

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

/*================================================================

  PROCEDURE NAME: 	replace_po_original_catalog()

==================================================================*/
PROCEDURE replace_po_original_catalog(X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2,
                                      p_ga_flag                   IN VARCHAR2)


 IS
   X_progress	  VARCHAR2(3) := NULL;
   x_temp      	  binary_integer;
   x_temp2     	  binary_integer := -1;
   l_po_header_id   NUMBER;                   --BUG#3165053
   l_rel_exists  VARCHAR2(1) := NULL;         --BUG#3165053
   l_po_exists_num   NUMBER;                  --<Bug# 3504001>

BEGIN
   X_progress := '010';
   /* make sure that start_date is specified */
   IF (X_start_date is null) THEN
      po_interface_errors_sv1.handle_interface_errors(
                                            'PO_DOCS_OPEN_INTERFACE',
                                            'FATAL',
                                             null,
                                             X_interface_header_id,
                                             X_interface_line_id,
                                            'PO_PDOI_COLUMN_NOT_NULL',
                                            'PO_HEADERS_INTERFACE',
                                            'START_DATE',
                                            'COLUMN_NAME',
                                             null,null,null,null,null,
                                             'START_DATE',
                                             null,null,null,null,null,
                                             X_header_processable_flag);
    END IF;
   /* make sure that the start_date < end_date */
   -- Bug 2449186. Truncate dates when comparing them.
   IF (TRUNC(X_start_date) > TRUNC(nvl(X_end_date, X_start_date))) THEN
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
                                             X_header_processable_flag);
   END IF;

   IF (X_header_processable_flag = 'Y') THEN
   X_progress := '020' ;
   /* make sure that such a po_header_id exists in po_headers table */

/*Bug 1239775
  Performance issue
  Before the fix we had one sql statment to handle both
  quotation and the blanket ,but that was a performance issue
  and so modified it to handle it seperately for quoation and
  blanket and also created indices on  quote_vendor_quote_number
  and vendor_order_num
*/
      -- Bug 2449186. Truncate dates when comparing them.
      if (x_document_type_code = 'QUOTATION') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  quote_vendor_quote_number = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
            AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
     elsif(x_document_type_code= 'BLANKET') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  vendor_order_num = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
            AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
     end if;

   If X_temp = 0 then

   	x_temp2 := x_temp;

/*Bug 1239775
  Performance issue
  Before the fix we had one sql statment to handle both
  quotation and the blanket ,but that was a performance issue
  and so modified it to handle it seperately for quoation and
  blanket and also created indices on  quote_vendor_quote_number
  and vendor_order_num
*/
      -- Bug 2449186. Truncate dates when comparing them.
      if (x_document_type_code = 'QUOTATION') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  quote_vendor_quote_number = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate));
     elsif(x_document_type_code= 'BLANKET') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  vendor_order_num = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate));
     end if;

	-- it should be OK to replace a finally closed or cancelled doc.

	if X_temp <> 1 then
		x_temp := x_temp2;
	end if;

   end if;

   IF x_temp = 0 THEN
      /* can not find the original catalog */
      /* call the error handling routine with the error code =
        'PDOI_INVALID_ORIGINAL_CATALOG' */
      X_progress := '030';
      po_interface_errors_sv1.handle_interface_errors(
                                                'PO_DOCS_OPEN_INTERFACE',
                                                'FATAL',
						 null,
						 X_interface_header_id,
						 X_interface_line_id,
						'PO_PDOI_INVALID_ORIG_CATALOG',
						'PO_HEADERS_INTERFACE',
                                                'VENDOR_DOC_NUM',
						'DOC_NUMBER',
						 null,null,null,null,null,
					 	 X_vendor_doc_num ,
						 null,null,null,null,null,
                                                 X_header_processable_flag);
   ELSIF x_temp > 1 THEN
     /* if returns more than 1 row, it is an error */
      X_progress := '040';
      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					'PO_PDOI_INVAL_MULT_ORIG_CATG',
					'PO_HEADERS_INTERFACE',
                                        'VENDOR_DOC_NUM',
				        'DOC_NUMBER',
				         null,null,null,null,null,
				 	 X_vendor_doc_num,
					 null,null,null,null,null,
                                         X_header_processable_flag);
   ELSIF x_temp = 1 THEN
      X_progress := '050';
      /* update the original catelog by changing the effective and expiration
         date */

      if x_temp2 = 0 then

      /* Bug#3165053 : When replacing a blanket through PDOI, check that
         no release with the release date greater than the start date
         of the new replaced blanket exists */

      SELECT po_header_id
      INTO   l_po_header_id
      FROM po_headers
      WHERE vendor_id = X_vendor_id
      AND DECODE(X_document_type_code, 'QUOTATION', quote_vendor_quote_number,
          'BLANKET' , vendor_order_num) = X_vendor_doc_num
      AND TRUNC(nvl(X_start_date, sysdate)) >=
          TRUNC(nvl(start_date, sysdate))
      AND TRUNC(nvl(X_end_date, sysdate)) <=
          TRUNC(nvl(end_date, sysdate));

      IF nvl(p_ga_flag, 'N') = 'N' AND x_document_type_code = 'BLANKET' THEN --<Bug 3504001>

      BEGIN     -- Bug#3274836
         SELECT 'Y' INTO l_rel_exists
         FROM DUAL
         WHERE EXISTS(
           SELECT 'release exist after the expiration  date'
           FROM   po_releases
           WHERE  release_date > X_start_date
           AND    po_header_id = l_po_header_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_rel_exists := 'N';
      END;

        IF l_rel_exists = 'Y'  THEN

                po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_ST_DATE_GT_REL_DATE',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        'EFFECTIVE_DATE',
                     x_tokenname1 =>          null,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         null,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
        END IF;
      --<Bug 3504001 START>
      ELSIF nvl(p_ga_flag, 'N') = 'Y' and x_document_type_code = 'BLANKET' THEN
          SELECT count(1)
          INTO l_po_exists_num
          FROM po_lines_all pl,
               po_headers_all ph
          WHERE pl.from_header_id = l_po_header_id
          AND ph.po_header_id = pl.po_header_id
          AND ph.creation_date >= X_start_date;

          IF l_po_exists_num > 0 THEN
                po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_GA_ST_DATE_GT_PO_DATE',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        'EFFECTIVE_DATE',
                     x_tokenname1 =>          null,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         null,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
          END IF;

      --<Bug 3504001 END>
      END IF;

	      -- Bug 2449186. Truncate dates when comparing them.
	      UPDATE po_headers
	        SET  start_date = nvl(start_date, X_start_date - 1),
	             end_date = X_start_date - 1,
	             last_updated_by = fnd_global.user_id,
	             last_update_date = sysdate
	       WHERE po_header_id = l_po_header_id;

      else

      /* Bug#3165053 : When replacing a blanket through PDOI, check that
         no release with the release date greater than the start date
         of the new replaced blanket exists */

      SELECT po_header_id
      INTO   l_po_header_id
      FROM po_headers
      WHERE vendor_id = X_vendor_id
      AND DECODE(X_document_type_code, 'QUOTATION', quote_vendor_quote_number,
          'BLANKET' , vendor_order_num) = X_vendor_doc_num
      AND TRUNC(nvl(X_start_date, sysdate)) >=
          TRUNC(nvl(start_date, sysdate))
      AND TRUNC(nvl(X_end_date, sysdate)) <=
          TRUNC(nvl(end_date, sysdate))
      AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');

      IF nvl(p_ga_flag, 'N') = 'N' AND x_document_type_code = 'BLANKET' THEN  --<Bug 3504001>
      BEGIN  -- Bug#3274836
         SELECT 'Y' INTO l_rel_exists
         FROM DUAL
         WHERE EXISTS(
           SELECT 'release exist after the expiration  date'
           FROM   po_releases
           WHERE  release_date > X_start_date
           AND    po_header_id = l_po_header_id);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_rel_exists := 'N';
      END;

        IF l_rel_exists = 'Y'  THEN

                po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_ST_DATE_GT_REL_DATE',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        'EFFECTIVE_DATE',
                     x_tokenname1 =>          null,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         null,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
        END IF;
      --<Bug 3504001 START>
      ELSIF nvl(p_ga_flag, 'N') = 'Y' and x_document_type_code = 'BLANKET' THEN
          SELECT count(1)
          INTO l_po_exists_num
          FROM po_lines_all pl,
               po_headers_all ph
          WHERE pl.from_header_id = l_po_header_id AND
                ph.po_header_id = pl.po_header_id AND
                ph.creation_date >= X_start_date;

          IF l_po_exists_num > 0 THEN
                po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_GA_ST_DATE_GT_PO_DATE',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        'EFFECTIVE_DATE',
                     x_tokenname1 =>          null,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         null,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
          END IF;

      --<Bug 3504001 END>
      END IF;

	      -- Bug 2449186. Truncate dates when comparing them.
	      UPDATE po_headers
	        SET  start_date = nvl(start_date, X_start_date - 1),
	             end_date = X_start_date - 1,
	             last_updated_by = fnd_global.user_id,
	             last_update_date = sysdate
	       WHERE po_header_id = l_po_header_id;
      end if;

   END IF;
 END IF;

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('replace_po_original_catalog',
                               X_progress, sqlcode);
       raise;
END replace_po_original_catalog;



/*================================================================

  PROCEDURE NAME: 	check_po_original_catalog()

==================================================================*/
PROCEDURE check_po_original_catalog(X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
				      X_document_num		  IN Varchar2, -- CTO changes FPH
				      X_po_header_id		  IN OUT NOCOPY VARCHAR2,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2)


 IS
   X_progress	  VARCHAR2(3) := NULL;
   x_temp      	  binary_integer :=0;
   x_temp2     	  binary_integer;
   /* Cto Changes FPH start */
   x_colname varchar2(20);
   x_tokenname varchar2(20);
   x_tokenvalue po_headers_interface.vendor_doc_num%type; /* Bug3082104 */
   /* Cto Changes FPH end */

-- <PDOI FPJ START>
-- added the following variables for PDOI enhancement.

x_po_status_rec  PO_STATUS_REC_TYPE;
x_return_status  varchar2(30);
x_consigned_consumption_flag  po_headers.consigned_consumption_flag%type ;

-- <PDOI FPJ END>





BEGIN
   -- For original and update checks - start and end dates are not required.

   IF (X_header_processable_flag = 'Y') THEN
   X_progress := '020' ;

/*Bug 1239775
  Performance issue
  Before the fix we had one sql statment to handle both
  quotation and the blanket ,but that was a performance issue
  and so modified it to handle it seperately for quoation and
  blanket and also created indices on  quote_vendor_quote_number
  and vendor_order_num
*/
    /* CTO changes FPH. If the X_vendor_doc_num use it to get the
     * count. Only if it is null then check whether document number
     * is provided. If so use it. If both are null, then x_temp would
     * be 0 and hence we return a message PO_PDOI_INVALID_ORIG_CATALOG.
     * This is done since performance will be bad if we try to do in
     * the same sql.
     */

     /* Bug# 3552765 - Added 'if' clause to take care of case where both
      *                vendor_doc_num and document_num are provided
      */

    if (X_vendor_doc_num is not null) and (X_document_num is not null) then

	if x_document_type_code = 'STANDARD' then

	    select count(1)
	    into x_temp
	    from po_headers
	    where vendor_id = x_vendor_id
	    and vendor_order_num = x_vendor_doc_num
	    and segment1 = x_document_num;

	else

	    select count(1)
	    into x_temp
	    from po_headers
	    where vendor_id = x_vendor_id
	    and segment1 = x_document_num
	    and decode(x_document_type_code, 'QUOTATION', quote_vendor_quote_number,
	    	'BLANKET', vendor_order_num, NULL) = x_vendor_doc_num
	    AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
	    AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
	    AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');

	end if;

    elsif (X_vendor_doc_num is not null) then

	-- Bug 2449186. Truncate dates when comparing them.
	if (x_document_type_code = 'QUOTATION') then
	    SELECT count(*)
	    INTO x_temp
	    FROM po_headers
	    WHERE vendor_id = X_vendor_id
	    AND  quote_vendor_quote_number = X_vendor_doc_num
	    AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
	    AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
	    AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
	elsif(x_document_type_code= 'BLANKET') then
	    SELECT count(*)
	    INTO x_temp
	    FROM po_headers
	    WHERE vendor_id = X_vendor_id
	    AND  vendor_order_num = X_vendor_doc_num
	    AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
	    AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
	    AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
-- <PDOI FPJ START>
	ELSIF(x_document_type_code = 'STANDARD') THEN
	    SELECT  count(*)
	    INTO  x_temp
	    FROM  po_headers
	    WHERE vendor_id = x_vendor_id
	    and vendor_order_num = x_vendor_doc_num ;
-- <PDOI FPJ END>
	END IF;

    elsif(x_document_num is not null) then
-- <PDOI FPJ>
-- Added the below 'if/else' statement for standard PO.

	if (x_document_type_code <> 'STANDARD') then
	    /* Since we are using segment1 it is same for both
             * Blanket and Quotation.
            */
	    -- Bug 2449186. Truncate dates when comparing them.
	    SELECT count(*)
	    INTO x_temp
	    FROM po_headers
	    WHERE vendor_id = X_vendor_id
	    AND  segment1 = x_document_num
	    AND type_lookup_code= x_document_type_code
	    AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
	    AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
	    AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
-- <PDOI FPJ START>
      else
	    SELECT  count(*)
            INTO  x_temp
            FROM  po_headers
            WHERE vendor_id = x_vendor_id
            and   segment1 = x_document_num ;
     end if;
-- <PDOI FPJ END>
   end if;

      /* Cto Changes FPH start */
      if (x_vendor_doc_num is not null) then
        x_colname := 'VENDOR_DOC_NUM';
        x_tokenname := 'DOC_NUMBER';
        x_tokenvalue := X_vendor_doc_num;
      elsif (x_document_num is not null) then
        x_colname := 'DOCUMENT_NUM';
        x_tokenname := 'DOC_NUMBER';
        x_tokenvalue := x_document_num;
      end if;
      IF (g_po_pdoi_write_to_file = 'Y') THEN
         PO_DEBUG.put_line ('x_colname:' || (x_colname));
         PO_DEBUG.put_line ('x_tokenname:' || (x_tokenname));
         PO_DEBUG.put_line ('x_tokenvalue:' ||(x_tokenvalue));
      END IF;
     /* Cto Changes FPH end */
   IF x_temp = 0 THEN

      /* can not find the original catalog */
      /* call the error handling routine with the error code =
        'PDOI_INVALID_ORIGINAL_CATALOG' */

	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line ('X_vendor_id:' || to_char(X_vendor_id));
   	PO_DEBUG.put_line ('X_vendor_doc_num:' || X_vendor_doc_num);
   	PO_DEBUG.put_line ('X_vendor_doc_num:' || X_vendor_doc_num);
   	PO_DEBUG.put_line ('x_document_num:' || X_vendor_doc_num);
	END IF;
        if ( X_vendor_doc_num is null and x_document_num is null) then
		x_colname := 'VENDOR_DOC_NUM';
		x_tokenname := 'DOC_NUMBER';
		x_tokenvalue := X_vendor_doc_num;
        end if;

      X_progress := '030';
-- <PDOI FPJ>
-- Added the following 'if/else' statement for standard purchase orders.

  IF (x_document_type_code <> 'STANDARD') THEN
      po_interface_errors_sv1.handle_interface_errors(
                                                'PO_DOCS_OPEN_INTERFACE',
                                                'FATAL',
						 null,
						 X_interface_header_id,
						 X_interface_line_id,
						'PO_PDOI_INVALID_ORIG_CATALOG',
						'PO_HEADERS_INTERFACE',
                                                x_colname,
						x_tokenname,
						 null,null,null,null,null,
					 	 x_tokenvalue ,
						 null,null,null,null,null,
                                                 X_header_processable_flag);
  else
-- <PDOI FPJ START>
-- Added the below procedure to populate the error message incase
-- of standard PO.
		po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_INVALID_ORIG_STD_PO',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        x_colname,
                     x_tokenname1 =>         x_tokenname,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         X_tokenvalue,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
-- <PDOI FPJ END>
 end if;
   ELSIF x_temp > 1 THEN
     /* if returns more than 1 row, it is an error */
      X_progress := '040';
      IF (g_po_pdoi_write_to_file = 'Y') THEN
         PO_DEBUG.put_line ('X_vendor_doc_num:' || X_vendor_doc_num);
         PO_DEBUG.put_line ('x_document_num:' || X_vendor_doc_num);
      END IF;
-- <PDOI FPJ>
-- Added the following 'if/else' for standard purchase orders.

   IF (x_document_type_code <> 'STANDARD') THEN
      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					'PO_PDOI_INVAL_MULT_ORIG_CATG',
					'PO_HEADERS_INTERFACE',
                                        x_colname,
				        x_tokenname,
				         null,null,null,null,null,
				 	 X_vendor_doc_num,
					 null,null,null,null,null,
                                         X_header_processable_flag);
   ELSE
-- <PDOI FPJ START>
-- Added the below procedure to populate error message is case of standard
-- purchase orders.
		po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_MULTIPLE_STD_PO',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        x_colname,
                     x_tokenname1 =>         x_tokenname,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         X_vendor_doc_num,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);
-- <PDOI FPJ END>
   end if;
   ELSIF x_temp = 1 THEN
      X_progress := '050';

      --
      -- Valid original catalog exists and can be updated.
      --
      IF (g_po_pdoi_write_to_file = 'Y') THEN
         PO_DEBUG.put_line ('Valid catalog/blanket exists and can be updated');
      END IF;

      -- Bug 2449186. Truncate dates when comparing them. Also refactored update.
-- <PDOI FPJ>
-- Added the following 'if/else' for standard purchase orders.

  IF (x_document_type_code <> 'STANDARD') THEN
      SELECT po_header_id
        INTO X_po_header_id
        FROM po_headers
       WHERE vendor_id = X_vendor_id
         AND decode(x_vendor_doc_num,null,segment1,(DECODE(X_document_type_code,
                    'QUOTATION', quote_vendor_quote_number,
                    'BLANKET' , vendor_order_num)))
             = decode(X_vendor_doc_num,null,x_document_num,X_vendor_doc_num) --cto changes FPH
         AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
         AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
         AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');

ELSE
-- <PDOI FPJ START>
-- Added the following api to check whether the document is in valid
-- status and updateable.
            IF (g_po_pdoi_write_to_file = 'Y') THEN
               PO_DEBUG.put_line ('Calling status check api for standard POs');
            END IF;

    		PO_DOCUMENT_CHECKS_GRP.po_status_check(
    				p_api_version => 1.0,
    				p_header_id => null,
    				p_release_id => null,
    				p_document_type => 'PO',
    				p_document_subtype => 'STANDARD',
    				p_document_num => x_document_num,
    				p_vendor_order_num => x_vendor_doc_num,
    				p_line_id => null,
    				p_line_location_id => null,
    				p_distribution_id => null,
    				p_mode => 'CHECK_UPDATEABLE',
    				x_po_status_rec => x_po_status_rec,
    				x_return_status  => x_return_status);

    		IF (x_vendor_doc_num is not null) THEN

    		   SELECT  po_header_id,
			   consigned_consumption_flag
    	  	   INTO    x_po_header_id,
			   x_consigned_consumption_flag
    		   FROM    po_headers
      		   WHERE   vendor_order_num = x_vendor_doc_num;

    	       ELSE

    		   SELECT  po_header_id,
			   consigned_consumption_flag
                   INTO    x_po_header_id,
		           x_consigned_consumption_flag
    		   FROM    po_headers
    		   WHERE   segment1 = x_document_num ;

    	       END IF;  /* x_vendor_doc_num is not null */

               IF x_return_status = FND_API.G_RET_STS_SUCCESS  THEN

        	  if x_po_status_rec.updatable_flag(1) = 'N' or
                     x_consigned_consumption_flag='Y' then

		       if (g_po_pdoi_write_to_file = 'Y') THEN
                          PO_DEBUG.put_line ('Standard PO is not updatable');
	 		  PO_DEBUG.put_line('x_po_status_rec.updatable_flag is '	   		             || x_po_status_rec.updatable_flag(1));
                          PO_DEBUG.put_line ('x_consigned_consumption_flag is
				    '|| x_consigned_consumption_flag);
      		       end if;

		po_interface_errors_sv1.handle_interface_errors(
                     x_interface_type => 'PO_DOCS_OPEN_INTERFACE',
                     x_error_type =>     'FATAL',
                     x_batch_id =>       null,
                     x_interface_header_id => X_interface_header_id,
                     x_interface_line_id => null,
                     x_error_message_name => 'PO_PDOI_STD_PO_INVALID_STATUS',
                     x_table_name =>         'PO_HEADERS_INTERFACE',
                     x_column_name =>        x_colname,
                     x_tokenname1 =>         x_tokenname,
                     x_tokenname2 =>          null,
                     x_tokenname3 =>          null,
                     x_tokenname4 =>          null,
                     x_tokenname5 =>          null,
                     x_tokenname6 =>          null,
                     x_tokenvalue1 =>         X_vendor_doc_num,
                     x_tokenvalue2 =>         null,
                     x_tokenvalue3 =>         null,
                     x_tokenvalue4 =>         null,
                     x_tokenvalue5 =>         null,
                     x_tokenvalue6 =>         null,
                     x_header_processable_flag=>x_header_processable_flag);

 		END IF; /* x_status_rec.updatable-flag(1)='N'  */

             END IF;  /* x_return_status = FND_API.G_RET_STS_SUCCESS */

-- <PDOI FPJ END>
end if;

      -- update po_header_id in interface table

      update po_headers_interface
      set po_header_id = x_po_header_id
      where interface_header_id = X_interface_header_id;   /* nwang, need this */


   END IF;
   END IF;

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('check_po_original_catalog',
                               X_progress, sqlcode);
       raise;
END check_po_original_catalog;



/*================================================================

  PROCEDURE NAME: 	check_if_catalog_exists()

==================================================================*/
PROCEDURE check_if_catalog_exists (   X_interface_header_id       IN NUMBER,
                                      X_interface_line_id         IN NUMBER,
                                      X_vendor_id                 IN NUMBER,
				      X_document_type_code        IN VARCHAR2,
			 	      X_vendor_doc_num            IN VARCHAR2,
                                      X_start_date                IN DATE,
                                      X_end_date                  IN DATE,
				      X_po_header_id		  IN OUT NOCOPY VARCHAR2,
                                      X_header_processable_flag   IN OUT NOCOPY VARCHAR2)


 IS
   X_progress	  VARCHAR2(3) := NULL;
   x_temp      	  binary_integer;

BEGIN
   X_progress := '010';

   IF (X_header_processable_flag = 'Y') THEN
/*Bug 1239775
  Performance issue
  Before the fix we had one sql statment to handle both
  quotation and the blanket ,but that was a performance issue
  and so modified it to handle it seperately for quoation and
  blanket and also created indices on  quote_vendor_quote_number
  and vendor_order_num
*/
      -- Bug 2449186. Truncate dates when comparing them.
      if (x_document_type_code = 'QUOTATION') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  quote_vendor_quote_number = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
            AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
     elsif(x_document_type_code= 'BLANKET') then
            SELECT count(*)
            INTO x_temp
            FROM po_headers
            WHERE vendor_id = X_vendor_id
            AND  vendor_order_num = X_vendor_doc_num
            AND TRUNC(nvl(X_start_date, sysdate)) >= TRUNC(nvl(start_date, sysdate))
            AND TRUNC(nvl(X_end_date, sysdate)) <= TRUNC(nvl(end_date, sysdate))
            AND nvl(closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CANCELLED');
--frkhan was not catching this case before so request was failing
     elsif (x_document_type_code= 'STANDARD') then
	    x_temp := 0;
     end if;

   IF (g_po_pdoi_write_to_file = 'Y') THEN
      po_debug.put_line ('Value of count(*) is :' || to_char(x_temp));
   END IF;

   IF x_temp = 0 THEN

	-- No active catalog exists in the system with the same vendor doc number.
	-- OK to create a new catalog.
	NULL;

   ELSE
     /* if returns 1 or more than one row, it is an error */
      X_progress := '020';
      po_interface_errors_sv1.handle_interface_errors(
                                        'PO_DOCS_OPEN_INTERFACE',
                                        'FATAL',
					 null,
					 X_interface_header_id,
					 X_interface_line_id,
					'PO_PDOI_CATG_ALREADY_EXISTS',
					'PO_HEADERS_INTERFACE',
                                        'VENDOR_DOC_NUM',
				        'DOC_NUMBER',
				         null,null,null,null,null,
				 	 X_vendor_doc_num,
					 null,null,null,null,null,
                                         X_header_processable_flag);
   END IF;
  END IF;

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('check_if_catalog_exists',
                               X_progress, sqlcode);
       raise;
END check_if_catalog_exists;

END PO_HEADERS_SV9;

/
