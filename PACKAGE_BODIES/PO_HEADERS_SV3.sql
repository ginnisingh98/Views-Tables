--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV3" as
/* $Header: POXPOH3B.pls 115.9 2003/12/12 02:27:15 sbull ship $*/

/*===========================================================================

  PROCEDURE NAME:	get_security_level_code()

===========================================================================*/

 procedure get_security_level_code (X_po_type in varchar2,
                                    X_po_sub_type in varchar2,
                                    X_security_level_code IN OUT NOCOPY varchar2) is

 X_progress  varchar2(3) := '';

 begin
         X_progress := '010';

         if X_po_sub_type is not null then


            select security_level_code
            into   X_security_level_code
            from   po_document_types
            where  document_type_code = X_po_type
            and    document_subtype = X_po_sub_type;
         end if;

         return;
 exception
          when others then
               po_message_s.sql_error('get_security_level_code', X_progress, sqlcode);
               raise;
 end get_security_level_code;


/*==========================================================================

   PROCEDURE NAME: test_get_security_level_code()

=============================================================================*/


   procedure test_get_security_level_code is
    X_security_level_code  varchar2(80);
   begin

           get_security_level_code('PO', 'STANDARD', X_security_level_code );
           -- dbms_output.put_line('Security Code is ' || X_security_level_code );

           get_security_level_code('PA', 'BLANKET', X_security_level_code );
           -- dbms_output.put_line('Security Code is ' || X_security_level_code );

   end test_get_security_level_code;

/*==========================================================================

   FUNCTION NAME: get_currency_code()

=============================================================================*/

  function get_currency_code(X_po_header_id IN NUMBER)
          return varchar2 is
          X_currency_code varchar2(15) := '';
          X_Progress      varchar2(3) := '';
  begin
         X_Progress := '010';

         /* Select the Currency Code the given PO is in  */

         select currency_code
         into   X_currency_code
         from   po_headers_all  -- FPI GA
         where  po_header_id = X_po_header_id;


         return(X_currency_code);

 exception

         when others then
             /* Cannot have this because the procedure sql_error does not
             ** have the compiler directive - restrict_references.
             ** We will not be handling this error gracefully if it
             ** ever occured. To avoid that, we are ignoring this
             ** error here. Based on the return value, the calling
             ** program should interpret it appropriately. */
              -- po_message_s.sql_error('get_currency_code', X_progress, sqlcode);
             return(X_currency_code);
 end get_currency_code;


--=============================================================================
-- PROCEDURE   : get_currency_info                         <2694908>
-- TYPE        : Private
--
-- PRE-REQS    : p_po_header_id must refer to an existing document.
-- MODIFIES    : -
--
-- DESCRIPTION : Retrieves all currency-related info for the document
--               (i.e. currency_code, rate_type, rate_date, rate).
--
-- PARAMETERS  : p_po_header_id  - document ID
--
-- RETURNS     : x_currency_code - Currency
--               x_rate_type     - Rate Type
--               x_rate_date     - Rate Date
--               x_rate          - Rate
--
-- EXCEPTIONS  : -
--=============================================================================
PROCEDURE get_currency_info
(
    p_po_header_id      IN         PO_HEADERS_ALL.po_header_id%TYPE ,
    x_currency_code     OUT NOCOPY PO_HEADERS_ALL.currency_code%TYPE ,
    x_rate_type         OUT NOCOPY PO_HEADERS_ALL.rate_type%TYPE,
    x_rate_date         OUT NOCOPY PO_HEADERS_ALL.rate_date%TYPE,
    x_rate              OUT NOCOPY PO_HEADERS_ALL.rate%TYPE
)
IS
BEGIN

    SELECT    currency_code,
              rate_type,
              rate_date,
              rate
    INTO      x_currency_code,
              x_rate_type,
              x_rate_date,
              x_rate
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

EXCEPTION

    WHEN OTHERS THEN
        x_currency_code := NULL;
        x_rate_type := NULL;
        x_rate_date := NULL;
        x_rate := NULL;

END get_currency_info;


/*===========================================================================

  PROCEDURE NAME:	get_doc_num()

===========================================================================*/

PROCEDURE get_doc_num( X_doc_num	IN OUT NOCOPY VARCHAR2,
                       X_header_id	IN     NUMBER)  IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   SELECT segment1
   INTO   x_doc_num
   FROM   po_headers_all   -- FPI GA
   WHERE  po_header_id = x_header_id;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_doc_num := '';
   WHEN OTHERS THEN
      po_message_s.sql_error('get_doc_num', x_progress, sqlcode);
   RAISE;

END get_doc_num;

/*===========================================================================

  PROCEDURE NAME:	get_po_header_id()

===========================================================================*/
-- Moved this package to RCVTISVB.pls because of globalization issues

 /* PROCEDURE get_po_header_id
                (X_po_header_id_record		IN OUT	rcv_shipment_line_sv.document_num_record_type) is

 BEGIN

   select max(po_header_id)
   into   x_po_header_id_record.po_header_id
   from   po_headers
   where  segment1 = X_po_header_id_record.document_num;

   if (x_po_header_id_record.po_header_id is null) then
	x_po_header_id_record.error_record.error_status		:= 'F';
	x_po_header_id_record.error_record.error_message	:= 'RCV_ITEM_PO_ID';
   end if;

 exception
   when others then
	x_po_header_id_record.error_record.error_status		:= 'U';

 END get_po_header_id; */

/*===========================================================================

  FUNCTION  NAME:	get_po_status


===========================================================================*/

  FUNCTION get_po_status  (X_po_header_id IN NUMBER)
              RETURN VARCHAR2 IS


   -- Bug 1186210: increase the length of status.

   X_status             VARCHAR2(4000) := '';
   x_status_code	VARCHAR2(80) := '';
   x_cancel_status	VARCHAR2(80) := '';
   x_closed_status      VARCHAR2(80) := '';
   x_frozen_status      VARCHAR2(80) := '';
   x_hold_status        VARCHAR2(80) := '';
   x_auth_status        VARCHAR2(25) := '';
   x_cancel_flag	VARCHAR2(1)  := 'N';
   x_closed_code        VARCHAR2(25) := '';
   x_frozen_flag	VARCHAR2(1)  := 'N';
   x_user_hold_flag     VARCHAR2(1)  := 'N';
   x_reserved_flag      VARCHAR2(1)  := 'N';
   x_reserved_status    VARCHAR2(80) := '';
   x_delimiter		VARCHAR2(2)  := ', ';

   X_progress           VARCHAR2(3)  := '';

   X_type_lookup_code   PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE; -- <ENCUMBRANCE FPJ>
   l_org_id             PO_HEADERS_ALL.org_id%TYPE; -- Bug 3208853

   --<Encumbrance FPJ>
   l_doc_type           PO_DOCUMENT_TYPES.document_type_code%TYPE;

   BEGIN
      X_progress := '010';

              -- Bug 3208853 Enhanced to work across operating units.

              SELECT plc_sta.displayed_field,
                     decode(poh.cancel_flag,
                            'Y', plc_can.displayed_field, NULL),
                     decode(nvl(poh.closed_code, 'OPEN'), 'OPEN', NULL,
                            plc_clo.displayed_field),
                     decode(poh.frozen_flag,
                            'Y', plc_fro.displayed_field, NULL),
                     decode(poh.user_hold_flag,
                            'Y', plc_hld.displayed_field, NULL),
                     poh.authorization_status,
                     nvl(poh.cancel_flag, 'N'),
                     poh.closed_code,
                     nvl(poh.frozen_flag, 'N'),
                     nvl(poh.user_hold_flag, 'N'),
                     poh.type_lookup_code,
                     poh.org_id                   -- Bug 3208853
              into   x_status_code,
                     x_cancel_status,
                     x_closed_status,
                     x_frozen_status,
                     x_hold_status,
                     x_auth_status,
                     x_cancel_flag,
                     x_closed_code,
                     x_frozen_flag,
                     x_user_hold_flag,
                     x_type_lookup_code,
                     l_org_id                     -- Bug 3208853
              from   po_lookup_codes plc_sta,
                     po_lookup_codes plc_can,
                     po_lookup_codes plc_clo,
                     po_lookup_codes plc_fro,
                     po_lookup_codes plc_hld,
                     po_headers_all poh           -- Bug 3208853
              where  plc_sta.lookup_code =
                     decode(poh.approved_flag,
                            'R', poh.approved_flag,
                                 nvl(poh.authorization_status,'INCOMPLETE'))
              and    plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
              and    plc_can.lookup_code = 'CANCELLED'
              and    plc_can.lookup_type = 'DOCUMENT STATE'
              and    plc_clo.lookup_code = nvl(poh.closed_code, 'OPEN')
              and    plc_clo.lookup_type = 'DOCUMENT STATE'
              and    plc_fro.lookup_code = 'FROZEN'
              and    plc_fro.lookup_type = 'DOCUMENT STATE'
              and    plc_hld.lookup_code = 'ON HOLD'
              and    plc_hld.lookup_type = 'DOCUMENT STATE'
              and    poh.po_header_id = X_po_header_id;


	      X_progress := '015';

      --<Encumbrance FPJ START>
      IF (x_type_lookup_code = 'BLANKET') THEN
         l_doc_type := PO_CORE_S.g_doc_type_PA;
      ELSE
         l_doc_type := PO_CORE_S.g_doc_type_PO;
      END IF;

      IF PO_CORE_S.is_encumbrance_on(
            p_doc_type => l_doc_type
         ,  p_org_id => l_org_id
         )
      THEN

         PO_CORE_S.should_display_reserved(
            p_doc_type => l_doc_type
         ,  p_doc_level => PO_CORE_S.g_doc_level_header
         ,  p_doc_level_id => x_po_header_id
         ,  x_display_reserved_flag => x_reserved_flag
         );

         IF (x_reserved_flag = 'Y') THEN
            PO_CORE_S.get_reserved_lookup(x_displayed_field => x_reserved_status);
         END IF;

      END IF;
      --<Encumbrance FPJ END>

	      X_progress := '030';

	      SELECT x_status_code||
			decode(x_closed_code, 'OPEN', '', '', '',
				x_delimiter||x_closed_status)||
			decode(x_cancel_flag, 'N', '', '', '',
			        x_delimiter||x_cancel_status)||
			decode(x_frozen_flag, 'N', '', '', '',
				x_delimiter||x_frozen_status)||
		        decode(x_user_hold_flag, 'N', '', '', '',
				x_delimiter||x_hold_status)||
			decode(x_reserved_flag, 'N', '', '', '',
				x_delimiter||x_reserved_status)
	      INTO   x_status
              FROM   dual;

      RETURN (X_status);

      EXCEPTION
	WHEN OTHERS THEN
             RETURN (NULL);
             RAISE;

 END get_po_status;


END PO_HEADERS_SV3;

/
