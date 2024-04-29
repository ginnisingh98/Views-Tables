--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_HEADERS_PKG" as
/* $Header: POXRIH1B.pls 120.5 2006/04/27 15:26:16 bao noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT	NOCOPY VARCHAR2,
                       X_Requisition_Header_Id   IN OUT NOCOPY NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Authorization_Status           VARCHAR2,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Transferred_To_Oe_Flag         VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Preliminary_Research_Flag      VARCHAR2,
                       X_Research_Complete_Flag         VARCHAR2,
                       X_Preparer_Finished_Flag         VARCHAR2,
                       X_Preparer_Finished_Date         DATE,
                       X_Agent_Return_Flag              VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Closed_Code                    VARCHAR2,
		       X_Manual				BOOLEAN,
                       p_org_id                  IN     NUMBER   DEFAULT NULL     -- <R12 MOAC>
   ) IS
     CURSOR C IS SELECT rowid FROM PO_REQUISITION_HEADERS
                 WHERE requisition_header_id = X_Requisition_Header_Id;


      CURSOR S IS SELECT po_requisition_headers_s.nextval FROM sys.dual;

   /* Ben: bug#465696 Locking the po_unique_identifier_control table at this
           point of the form commit cycle is causing the performance problem.
           It may take 5 to 10 seconds to commit a PO with many lines, shipments
           and distributions.
           The solution is to insert a bogus value into the SEGMENT1 column
           of po_requisition_headers ( the negative of po_requisition_header)
           then at the end of the commit cycle, i.e. the POST_FORMS-COMMIT
           trigger on the form, update the po_requisition_headers table with
           the real SEGMENT1 value from the po_unique_identifier_control table.
           The advantage of this approach is that the
           po_unique_identifier_control will be locked for only a short period
           of time.
           THEREFORE, taking the S1 cursor out of the logic here.

      CURSOR S1 IS SELECT to_char(current_max_unique_identifier + 1)
                   FROM   po_unique_identifier_control
                   WHERE  table_name = 'PO_REQUISITION_HEADERS'
                   FOR    UPDATE OF current_max_unique_identifier;

    */

    x_progress VARCHAR2(3) := NULL;

    BEGIN
      if (X_Requisition_Header_Id is NULL) then
        OPEN S;
        FETCH S INTO X_Requisition_Header_Id;
        CLOSE S;
      end if;

    /* Ben: bug#465696 Commenting this out. see explanation above
      if ((X_segment1 is NULL) and not(X_manual)) then
	OPEN S1;
	FETCH S1 INTO X_Segment1;
        UPDATE po_unique_identifier_control
	SET    current_max_unique_identifier
			= current_max_unique_identifier + 1
	WHERE  CURRENT of S1;
	CLOSE S1;
      end if;
    */
      /* Ben:bug465696 Added the following IF statement.See explanation above */
      IF ((X_segment1 is NULL) and not(X_manual)) then

         X_segment1 := '-' || to_char(X_Requisition_Header_Id);

      END IF;
    x_progress := '020';

       po_requisition_headers_pkg.check_unique (X_rowid, X_segment1);

    x_progress := '030';

       INSERT INTO PO_REQUISITION_HEADERS(
               requisition_header_id,
               preparer_id,
               last_update_date,
               last_updated_by,
               segment1,
               summary_flag,
               enabled_flag,
               segment2,
               segment3,
               segment4,
               segment5,
               start_date_active,
               end_date_active,
               last_update_login,
               creation_date,
               created_by,
               description,
               authorization_status,
               note_to_authorizer,
               type_lookup_code,
               transferred_to_oe_flag,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               on_line_flag,
               preliminary_research_flag,
               research_complete_flag,
               preparer_finished_flag,
               preparer_finished_date,
               agent_return_flag,
               agent_return_note,
               cancel_flag,
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
               government_context,
               interface_source_code,
               interface_source_line_id,
               closed_code,
               Org_Id,                 -- <R12 MOAC>
               tax_attribute_update_code --<eTax Integration R12>
             ) VALUES (
               X_Requisition_Header_Id,
               X_Preparer_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Segment1,
               X_Summary_Flag,
               X_Enabled_Flag,
               X_Segment2,
               X_Segment3,
               X_Segment4,
               X_Segment5,
               X_Start_Date_Active,
               X_End_Date_Active,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Description,
               X_Authorization_Status,
               X_Note_To_Authorizer,
               X_Type_Lookup_Code,
               X_Transferred_To_Oe_Flag,
               X_Attribute_Category,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_On_Line_Flag,
               X_Preliminary_Research_Flag,
               X_Research_Complete_Flag,
               X_Preparer_Finished_Flag,
               X_Preparer_Finished_Date,
               X_Agent_Return_Flag,
               X_Agent_Return_Note,
               X_Cancel_Flag,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Government_Context,
               X_Interface_Source_Code,
               X_Interface_Source_Line_Id,
               X_Closed_Code,
               p_org_id,                   -- <R12 MOAC>
               'CREATE' --<eTax Integration R12>
             );

    /* Bug #465696 Setting the segment1 back to NULL if using AUTOMATIC
       numbering. Otherwise, the bogus value of segment1 (see above explanation)
       will flash on the screen in front of the user.
    */
    IF NOT (X_manual) then

         X_segment1 := NULL;

    END IF;

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('INSERT_ROW',x_progress,sqlcode);
      raise;

  END Insert_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_REQUISITION_HEADERS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

/***************************************************************************/

PROCEDURE get_real_segment1(x_requisition_header_id NUMBER,
                            x_type_lookup_code      VARCHAR2,
                            x_currency_code         VARCHAR2,
                            x_segment1       IN OUT NOCOPY VARCHAR2) is

x_progress varchar2(3);

/* Ben: bug#465696 Locking the po_unique_identifier_control table at the
          beginning of the form commit cycle is causing the performance problem.
           It may take 5 to 10 seconds to commit a PO with many lines, shipments
           and distributions.
           The solution is to insert a bogus value into the SEGMENT1 column
           of po_requisition_headers ( the negative of po_requisition_header)
           during the ON-INSERT trigger on the PO_HEADERS,
           then at the end of the commit cycle, i.e. the POST_FORMS-COMMIT
           trigger on the form, update the po_requisition_headers table with
           the real SEGMENT1 value from the po_unique_identifier_control table.
           The advantage of this approach is that the
           po_unique_identifier_control will be locked for only a short period
           of time.

           This procedure gets called from the  POST_FORMS-COMMIT trigger
 */


BEGIN

  -- bug5176308 START
  -- Call API to get the po number
  x_segment1 :=
    PO_CORE_SV1.default_po_unique_identifier
    ( x_table_name => 'PO_REQUISITION_HEADERS'
    );
  -- bug5176308 END


        UPDATE po_requisition_headers set segment1=x_segment1
        where requisition_header_id=x_requisition_header_id;

 /*  bug# 465696 8/5/97. The previous fix to this performance problem introduced
   a problem with the notifications (the bogus value used temporarily as the
   document number was being inserted into the fnd_notifications table, since
   the call below was made before we called the procedure to get the real
   document number (segment1) .
   Therefore, removed the call below from po_reqs_sv.insert_row and moved it to
   here.
 */
   /*hvadlamu : commenting out since notifications will be handled by workflow */
   /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
                                       x_requisition_header_id,
                                       x_currency_code,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null); */
EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('get_real_segment1',x_progress,sqlcode);
      raise;

END get_real_segment1;


  PROCEDURE Check_Unique(X_Rowid			VARCHAR2,
		     	 X_Segment1			VARCHAR2) IS

  x_progress	VARCHAR2(3) := NULL;
  dummy 	NUMBER;
  BEGIN

  x_progress := '010';

  SELECT 1 INTO dummy
  FROM   DUAL
  WHERE NOT EXISTS
    ( SELECT 1
      FROM po_requisition_headers
      WHERE Segment1 = X_Segment1
      AND  ((X_Rowid IS NULL) OR (ROWID <> X_ROWID)))
  AND NOT EXISTS
    ( SELECT 1
      FROM   po_history_requisitions phr
      WHERE  phr.segment1 = X_Segment1);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      po_message_s.app_error('PO_ALL_ENTER_UNIQUE_VAL');
      raise;
  WHEN OTHERS THEN
      po_message_s.sql_error('check_unique',x_progress,sqlcode);
      raise;

END Check_Unique;




  FUNCTION get_req_total
	(p_header_id   number) return number is
    	 X_req_total     number;

  BEGIN
    -- <SERVICES FPJ>
    -- Added a decode statement to use amount for total calculation
    -- when quantity is null for the new Services lines.
    SELECT nvl(SUM(decode(quantity,
                          null,
                          amount,
                          (quantity * unit_price)
                         )
           ), 0)
	   into X_req_total
    FROM   po_requisition_lines
    WHERE  requisition_header_id = p_header_id and
           nvl(cancel_flag,'N') <> 'Y' and    -- Bug 554452 Ignore cancelled lines
           nvl(MODIFIED_BY_AGENT_FLAG, 'N') = 'N' and   -- Bug 574676
           nvl(CLOSED_CODE, 'OPEN') <> 'FINALLY CLOSED';  -- Bug 574676

    RETURN (X_req_total);

  EXCEPTION
    WHEN OTHERS then
       X_req_total := 0;
  END get_req_total;
 /* Start Bug#3406460 overloaded the function to calculate header total*/
 /* by rounding the line totals to the precision */

   FUNCTION get_req_total
       (p_header_id   number,
          p_currency_code  varchar2) return number is
        X_req_total     number;
         l_precision         number;
          l_ext_precision     number;
          l_min_acct_unit     number;

   BEGIN

 fnd_currency.get_info(p_currency_code,
                                 l_precision,
                                 l_ext_precision,
                                 l_min_acct_unit);

    -- <BUG 3553405 START> Need to sum the amount (rather than
    -- quantity*unit_price)in the case of Services line types.
    --
    SELECT  nvl ( sum ( round ( decode ( order_type_lookup_code
                                       , 'FIXED PRICE' , amount
                                       , 'RATE'        , amount
                                       ,                 quantity*unit_price
                                       )
                              , l_precision
                              )
                      )
                , 0
                )
    -- <BUG 3553405 END>
          into X_req_total
    FROM   po_requisition_lines
    WHERE  requisition_header_id = p_header_id and
            nvl(cancel_flag,'N') <> 'Y' and    -- Bug 554452 Ignore cancelled lines
            nvl(MODIFIED_BY_AGENT_FLAG, 'N') = 'N' and   -- Bug 574676
            nvl(CLOSED_CODE, 'OPEN') <> 'FINALLY CLOSED';  -- Bug 574676

     RETURN (X_req_total);

   EXCEPTION
     WHEN OTHERS then
        x_req_total := 0;
   END get_req_total;


/* End Bug3406460 */

END PO_REQUISITION_HEADERS_PKG;

/
