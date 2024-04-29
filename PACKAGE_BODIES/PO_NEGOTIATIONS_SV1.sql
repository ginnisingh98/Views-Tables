--------------------------------------------------------
--  DDL for Package Body PO_NEGOTIATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NEGOTIATIONS_SV1" AS
/* $Header: POXNEG1B.pls 120.22.12010000.4 2011/12/05 10:25:48 ramkandu ship $*/

--<RENEG BLANKET FPI>
G_PKG_NAME CONSTANT varchar2(30) := 'po_negotiations_sv1';
-- Bug 3780359
g_log_head CONSTANT VARCHAR2(50) := 'po.plsql.'||G_PKG_NAME||'.';
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;


-- <HTMLAC START>
-- Start of comments
--	API name 	: create_negotiation_bulk
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: Calls create_negotiation, because from Java
--			  the req_lines_table_type cannot be seen, as it is
--         declared inside a package
--	Parameters	:
--	IN		:	p_api_version           	   IN NUMBER	Required
--          p_negotiation_type            IN varchar2 Required
--            The negotiation type of the document
--          p_grouping_method             IN varchar2 Required
--            The req grouping selected from the UI
--          p_req_line_id_tbl             IN PO_TBL_NUMBER Required
--            The table containing the req_line_id column.
--          p_line_type_ids_tbl           IN PO_TBL_NUMBER Required
--            The table containing the line_type_id column.
--          p_item_ids_tbl                IN PO_TBL_NUMBER Required
--            The table containing the item_id column.
--          <ACHTML R12>
--          p_item_revisions_tbl          IN PO_TBL_VARCHAR5 Required
--            The table containing the item_revision column.
--          p_category_ids_tbl            IN PO_TBL_NUMBER Required
--            The table containing the req_line_id column.
--          p_quantities_tbl              IN PO_TBL_NUMBER Required
--            The table containing the quantity column.
--          <ACHTML R12>
--          p_unit_meas_lookup_codes_tbl  IN PO_TBL_VARCHAR30 Required
--            The table containing the unit_meas_lookup_code column.
--          p_job_ids_tbl                 IN PO_TBL_NUMBER Required
--            The table containing the job_id column.
--          p_neg_outcome                 IN varchar2  Required
--            The type of document for the negotiation outcome
--          p_document_org_id           IN number Not Required
--            The org in which the out doc is to be created.
--          p_neg_style_id                IN NUMBER Required
--            Style of Negotiation document to create.
--          p_outcome_style_id            IN NUMBER Required
--            Style of Outcome PO document created from Negotiation.
-- IN/OUT:  x_result                  IN/OUT NUMBER   Required
--          x_error_message           IN/OUT VARCHAR2 Required
--          x_negotiation_id          IN/OUT number Required
--            The negotiation id of the doc created.
--          x_doc_url_params          IN/OUT varchar2 Required
--            Any URL params returned by the sourcing call.
--	Version	: Current version	1.0
--			  Previous version 	1.0
--			  Initial version 	1.0
-- End of comments
PROCEDURE create_negotiation_bulk
(
   -- standard API params
   p_api_version                IN	      NUMBER,
   x_result        		IN OUT NOCOPY NUMBER,
   x_error_message	        IN OUT NOCOPY VARCHAR2,
   -- input params
   p_negotiation_type           IN            varchar2,
   p_grouping_method            IN            varchar2,
   -- table params in
   p_req_line_id_tbl            IN            PO_TBL_NUMBER,
   p_line_type_id_tbl           IN            PO_TBL_NUMBER,
   p_item_id_tbl                IN            PO_TBL_NUMBER,
   p_item_revision_tbl          IN            PO_TBL_VARCHAR5, -- <ACHTML R12>
   p_category_id_tbl            IN            PO_TBL_NUMBER,
   p_quantity_tbl               IN            PO_TBL_NUMBER,
   p_unit_meas_lookup_code_tbl  IN            PO_TBL_VARCHAR30,-- <ACHTML R12>
   p_job_id_tbl                 IN            PO_TBL_NUMBER,
   -- some more input params
   p_neg_outcome                IN            varchar2,
   p_document_org_id            IN            number,
   p_neg_style_id               IN            NUMBER,          -- <ACHTML R12>
   p_outcome_style_id           IN            NUMBER,          -- <ACHTML R12>
  -- output params
   x_negotiation_id             IN OUT NOCOPY number,
   x_doc_url_params             IN OUT NOCOPY varchar2
)
IS
   l_api_name         CONSTANT VARCHAR2(30)   := 'create_negotiation_bulk';
   l_api_version      CONSTANT NUMBER         := 1.0;
   l_error_code                VARCHAR2(2000);
  -- l_req_lines_tbl             REQ_LINES_TABLE_TYPE; --Bug5841426
   l_num_lines                 NUMBER;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT create_negotiation_bulk_SP;
   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(    l_api_version   ,
                                          p_api_version   ,
                                          l_api_name      ,
                                          G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- API Body
   -- Get the number of lines being passed in.
   l_num_lines := p_req_line_id_tbl.COUNT;

   -- Go through the arrays and create the table to pass into
   -- create_negotiation

--bug5841426 commented the following loop because the l_req_lines_tbl is
-- not used instead p_req_line_id_tbl is directly used to create the negotiation.
   /*for i in 1..l_num_lines loop
      l_req_lines_tbl(i).requisition_line_id   := p_req_line_id_tbl(i);
      l_req_lines_tbl(i).line_type_id          := p_line_type_id_tbl(i);
      l_req_lines_tbl(i).item_id               := p_item_id_tbl(i);
      l_req_lines_tbl(i).item_revision         := p_item_revision_tbl(i);
      l_req_lines_tbl(i).category_id           := p_category_id_tbl(i);
      l_req_lines_tbl(i).quantity              := p_quantity_tbl(i);
      l_req_lines_tbl(i).unit_meas_lookup_code := p_unit_meas_lookup_code_tbl(i);
      l_req_lines_tbl(i).job_id                := p_job_id_tbl(i);
   end loop;*/

   -- Finally, make the call to create_negotiation
   create_negotiation(
                  x_negotiation_type => p_negotiation_type,
                  x_grouping_method  => p_grouping_method,
                  p_neg_style_id     => p_neg_style_id,
                  p_outcome_style_id => p_outcome_style_id,
                  t_req_lines        => p_req_line_id_tbl,  -- bug5841426
                  x_negotiation_id   => x_negotiation_id,
                  x_doc_url_params   => x_doc_url_params,
                  x_result           => x_result,
                  x_error_code       => l_error_code,
                  x_error_message    => x_error_message,
                  p_neg_outcome      => p_neg_outcome,
                  p_document_org_id  => p_document_org_id);

   -- End of API Body
   -- Standard check to see if there is any error
   IF(x_result = -1) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_negotiation_bulk_SP;
      x_result := -1;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_negotiation_bulk_SP;
      x_result := -1;
      x_error_message := 'Unexpected error in create_negotiaton_bulk';
   WHEN OTHERS THEN
      ROLLBACK TO create_negotiation_bulk_SP;
      x_result := -1;
      x_error_message := 'Unhandled exception in create_negotiation_bulk';
END create_negotiation_bulk;
-- <HTMLAC END>

/*============================================================================
     Name: CREATE_NEGOTIATION
     DESC: Create  document from requisition data in autocreate
     dreddy : sourcing project
==============================================================================*/

PROCEDURE create_negotiation(x_negotiation_type      IN varchar2 ,
                             x_grouping_method       IN varchar2 ,
                             t_req_lines             IN PO_TBL_NUMBER, /* Changed the po_tbl_number to upper case for uniformity - bug 6631173 */            -- bug5841426
                             p_neg_style_id          IN NUMBER, -- <ACHTML R12>
                             p_outcome_style_id      IN NUMBER, -- <ACHTML R12>
                             x_negotiation_id        IN OUT NOCOPY  number,
                             x_doc_url_params        IN OUT NOCOPY  varchar2,
                             x_result                IN OUT NOCOPY  number,
                             x_error_code            IN OUT NOCOPY  varchar2,
                             x_error_message         IN OUT NOCOPY  varchar2,
 			     --<RENEG BLANKET FPI>
                             p_neg_outcome           IN   varchar2,
                             --<HTMLAC>
                             p_document_org_id       IN   number DEFAULT null)
IS


x_org_id           number := null;
api_result         number := 0;
api_error_code     varchar2(2000) := null;
api_error_msg      varchar2(2000) := null;
x_ship_to_location_id  number;
x_deliver_to_location_id  number;
x_negotiation_line_num number;
x_num_records          number;
x_req_header_id   number;
x_note_to_vendor   po_requisition_lines_all.note_to_vendor%TYPE;
x_need_by_date  date  := null;
x_req_num  varchar2(30);
x_item_num varchar2(80);
x_item_desc varchar2(240);
x_unit_price number;
x_uom_code varchar2(3);

-- <SERVICES FPJ START>
--
l_value_basis             PO_REQUISITION_LINES.order_type_lookup_code%TYPE;
l_req_line_id             PO_REQUISITION_LINES.requisition_line_id%TYPE;
l_amount                  PO_REQUISITION_LINES.amount%TYPE;
l_job_name                PER_JOBS_VL.name%TYPE;
l_job_long_description    PO_REQUISITION_LINES.job_long_description%TYPE;
l_has_price_diff_flag     VARCHAR2(1);
l_bid_start_price         PO_REQUISITION_LINES.unit_price%TYPE;
l_po_agreed_amount        PO_REQUISITION_LINES.amount%TYPE;

-- <ACHTML R12 START>
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
-- <ACHTML R12 END>

/*    --<R12 STYLES PHASE II START>
    l_req_line_id_table       PO_DOC_STYLE_PVT.g_po_tbl_num;
    l_source_doc_id_table     PO_DOC_STYLE_PVT.g_po_tbl_num;
    l_line_type_id_table      PO_DOC_STYLE_PVT.g_po_tbl_num;
    l_destination_type_table  PO_DOC_STYLE_PVT.g_po_tbl_char30;
    l_purchase_basis_table    PO_DOC_STYLE_PVT.g_po_tbl_char30;
    l_style_id                PO_DOC_STYLE_HEADERS.style_id%type;
    l_neg_style_id            PO_DOC_STYLE_HEADERS.style_id%type;
*/    --<R12 STYLES PHASE II END>

CURSOR l_price_diff_csr ( p_req_line_id NUMBER ) IS
    SELECT   *
    FROM     po_price_differentials
    WHERE    entity_type = 'REQ LINE'
    AND      entity_id = p_req_line_id;
--
-- <SERVICES FPJ END>

--<HTMLAC START>
-- The conversion rate from the current org to the destination org
l_conv_rate NUMBER;
-- The organization of the req line.
l_from_org_id PO_REQUISITION_LINES_ALL.org_id%TYPE;
--<HTMLAC END>

x_progress varchar2(3);


-- bug5841426 <start>
TYPE t_crs is ref cursor;
l_cursor t_crs;
l_string VARCHAR2(10000);

x_line_type po_requisition_lines_all.LINE_TYPE_ID%type;
x_item_id  po_requisition_lines_all.ITEM_ID%type;
x_item_rev po_requisition_lines_all.ITEM_REVISION%type;
x_category_id po_requisition_lines_all.CATEGORY_ID%type;
x_quantity po_requisition_lines_all.QUANTITY%type;
x_uom po_requisition_lines_all.UNIT_MEAS_LOOKUP_CODE%type  ;
x_job_id po_requisition_lines_all.JOB_ID%type;
x_req_line_id po_requisition_lines_all.requisition_line_id%TYPE;
x_line_num po_requisition_lines_all.line_num%TYPE;
--bug5841426<end>

--bug6131913<start>

x_req_in_pool_flag VARCHAR2(1) :=NULL;
x_cancel_flag		  varchar2(1);
x_closed_code   	  varchar2(25);

--bug6131913<end>

--<Bug : 11071489 REQ_AUTOCREATE Start>--
l_parameter_list  PO_CORE_S4.p_parameter_list;
l_event_name VARCHAR2(100);
--<REQ_AUTOCREATE END>--

BEGIN
     /* get the current org_id */
     x_progress := '000';

      --<HTMLAC START>
      IF(p_document_org_id IS NULL) THEN
         --<HTMLAC END>
         -- You can pass in a null, or leave out this parameter, in which case
         -- we need to get the org from the po_system_parameters table.
         begin
            select org_id
            into x_org_id
            from po_system_parameters;
         exception
            when others then
            po_message_s.sql_error('In Exception of create_negotiation()', x_progress, sqlcode);
         end;
         --<HTMLAC START>
      ELSE
         x_org_id := p_document_org_id;
      END IF;
      --<HTMLAC END>

      --<R12 STYLES PHASE II START>
          /* count the number of records in the plsql table */
/*
         x_num_records := t_req_lines.COUNT;
       for i in 1..x_num_records loop

      l_req_line_id_table(i) := t_req_lines(i).requisition_line_id;
      l_source_doc_id_table(i):= t_req_lines(i).blanket_po_header_id;
      l_line_type_id_table(i):= t_req_lines(i).line_type_id;
      l_destination_type_table(i):= t_req_lines(i).destination_type_code;
      l_purchase_basis_table(i):=   t_req_lines(i).purchase_basis;
      end loop;
     PO_DOC_STYLE_PVT.populate_gt_and_validate(p_api_version             => 1.0,
                                     p_init_msg_list           => FND_API.G_TRUE,
                                     X_return_status           => l_return_status,
                                     X_msg_count               => l_msg_count,
                                     x_msg_data                => l_msg_data,
                                     p_req_line_id_table       => l_req_line_id_table,
                                     p_source_doc_id_table     => l_source_doc_id_table,
                                     p_line_type_id_table      => l_line_type_id_table,
                                     p_destination_type_table  => l_destination_type_table,
                                     p_purchase_basis_table    => l_purchase_basis_table,
                                     p_po_header_id            =>  NULL,
                                     x_style_id                => l_style_id);

      IF  l_return_status <> 'S' THEN

        x_result := -1;
        x_error_message := FND_MESSAGE.get;
        return;

      END IF;
*/
      --<R12 STYLES PHASE II END>

       /* Call the sourcing Header API to create the draft negotiation */
       /* Adding parameter p_neg_outcome - RENEG BLANKET FPI */
       -- <STYLES R12> Changed API call to use binding parameters.
       x_progress := '001';
       PON_AUCTION_INTERFACE_PKG.create_draft_negotiation
       ( p_document_title => null                                    -- IN
       , p_document_type => x_negotiation_type --<RENEG BLANKET FPI> -- IN
       , p_contract_type => p_neg_outcome                            -- IN
       , p_origination_code => 'REQUISITION'                         -- IN
       , p_org_id => x_org_id                                        -- IN
       , p_buyer_id => to_number(FND_PROFILE.VALUE('user_id'))       -- IN
       --<R12 STYLES PHASE II START>
       , p_neg_style_id =>  p_neg_style_id     -- <ACHTML R12>       -- IN
       , p_po_style_id  =>  p_outcome_style_id -- <ACHTML R12>       -- IN
       --<R12 STYLES PHASE II END>
       , p_document_number => x_negotiation_id                       -- OUT
       , p_document_url => x_doc_url_params                          -- OUT
       , p_result => api_result                                      -- OUT
       , p_error_code => api_error_code                              -- OUT
       , p_error_message => api_error_msg                            -- OUT
       );

       if api_result <> 0 THEN
           /* If unsuccessful return the error code to the form. */
           x_progress := '002';
                  x_result := -1;
                  x_error_code := api_error_code;
                  x_error_message := api_error_msg;
                  return ;

       end if;


--bug 6131913<start>
/*****
       This Code is to check if the Requisition Line which we are trying to AutoCreate has already been locked or deleted or cancelled.
       If so, simply return to the caller and show a message saying Requisition Line can't be auto created.
*****/

BEGIN

SAVEPOINT CHECK_LOCK;


for i in 1..(t_req_lines.count)-1
loop

x_req_in_pool_flag:=NULL;

BEGIN

	  SELECT Nvl(reqs_in_pool_flag,'Y'),cancel_flag,closed_code
          INTO x_req_in_pool_flag,
          x_cancel_flag,
          x_closed_code
          FROM po_requisition_lines WHERE requisition_line_id=t_req_lines(i)
          FOR UPDATE OF auction_header_id NOWAIT;


	  EXCEPTION

		 WHEN NO_DATA_FOUND then
		  /* The req line has been deleted since it was queried up. */
			  x_result:=-1;
			  fnd_message.set_name('PO', 'PO_ALL_REQ_LINE_DLTD_CANT_AC');
			  /*
		          SELECT prh.segment1,prl.line_num INTO x_req_num,x_line_num FROM po_requisition_headers_all prh,po_requisition_lines_all prl
		          WHERE prh.requisition_header_id = prl.requisition_header_id
		          AND prl.requisition_line_id = t_req_lines(i);

			  fnd_message.set_token('REQ_NUM', x_req_num);
			  fnd_message.set_token('REQ_LINE_NUM',x_line_num);
			  */
		          rollback to CHECK_LOCK;
		          x_error_message := fnd_message.get;
	          RETURN;

		WHEN OTHERS THEN
		           /* This is to see if req line is locked */
		 if (SQLCODE=-54)
		 THEN
				  x_result:=-1;
		 	          fnd_message.set_name('PO', 'PO_ALL_RQ_LINE_LOCKED_CANT_AC');
			          SELECT prh.segment1,prl.line_num INTO x_req_num,x_line_num FROM po_requisition_headers_all prh,po_requisition_lines_all prl
			          WHERE prh.requisition_header_id = prl.requisition_header_id
			          AND prl.requisition_line_id = t_req_lines(i);

			          fnd_message.set_token('REQ_NUM', x_req_num);
			          fnd_message.set_token('REQ_LINE_NUM',x_line_num);

			          x_error_message := fnd_message.get;
				  rollback to CHECK_LOCK;
			RETURN;
		else
		x_result:=-1;
		raise;
		end if;

END;

    if (x_req_in_pool_flag='N')
	  then
     /* The req line has been auto created already. */
          x_result:=-1;
	  fnd_message.set_name('PO', 'PO_ALL_RQ_LINE_ALREADY_AC');
          SELECT prh.segment1,prl.line_num INTO x_req_num,x_line_num FROM po_requisition_headers_all prh,po_requisition_lines_all prl
          WHERE prh.requisition_header_id = prl.requisition_header_id
          AND prl.requisition_line_id = t_req_lines(i);

	        fnd_message.set_token('REQ_NUM', x_req_num);
	        fnd_message.set_token('REQ_LINE_NUM',x_line_num);


      x_error_message := fnd_message.get;
      ROLLBACK TO CHECK_LOCK;
      RETURN;

    elsif (x_cancel_flag = 'Y') then
    /* The req line has been cancelled. */
              x_result:=-1;
      fnd_message.set_name('PO', 'PO_ALL_RQ_LINE_CNCLD_CANT_AC');
      SELECT prh.segment1,prl.line_num INTO x_req_num,x_line_num FROM po_requisition_headers_all prh,po_requisition_lines_all prl
          WHERE prh.requisition_header_id = prl.requisition_header_id
          AND prl.requisition_line_id = t_req_lines(i);

	        fnd_message.set_token('REQ_NUM', x_req_num);
	        fnd_message.set_token('REQ_LINE_NUM',x_line_num);


      x_error_message := fnd_message.get;
      ROLLBACK TO CHECK_LOCK;
      RETURN;

    elsif (x_closed_code = 'FINALLY CLOSED') then
    /* The req line has been auto created already. */
             x_result:=-1;
       fnd_message.set_name('PO', 'PO_ALL_RQ_LINE_FCLSD_CANT_AC');
       SELECT prh.segment1,prl.line_num INTO x_req_num,x_line_num FROM po_requisition_headers_all prh,po_requisition_lines_all prl
          WHERE prh.requisition_header_id = prl.requisition_header_id
          AND prl.requisition_line_id = t_req_lines(i);

	        fnd_message.set_token('REQ_NUM', x_req_num);
	        fnd_message.set_token('REQ_LINE_NUM',x_line_num);


       x_error_message := fnd_message.get;
       ROLLBACK TO CHECK_LOCK;
       RETURN;

    end if;



END LOOP;

END;

--bug 6131913<end>

          x_progress := '003';
          /* count the number of records in the plsql table */
             x_num_records := t_req_lines.COUNT;

--bug 6131913

             DELETE FROM po_session_gt WHERE index_char1='PO_NEGOTIATIONS_SV1';



          --bug 5841426<start>
          FORALL i IN 1..t_req_lines.Count
          INSERT INTO po_session_gt (KEY, index_char1, char1, num1, num2, num3, date1)
          SELECT prl.requisition_line_id,
                 'PO_NEGOTIATIONS_SV1',
                 prh.segment1,
                 prl.line_num,
                 prl.item_id,
                 prl.category_id,
                 decode (prl.purchase_basis , 'TEMP LABOR' , prl.assignment_start_date , prl.need_by_date )
            FROM po_requisition_lines_all prl,
                 po_requisition_headers_all prh
           WHERE prh.requisition_header_id = prl.requisition_header_id
             AND prl.requisition_line_id = t_req_lines(i);


          /* For each req line in the plsql table we call the sourcing line API */

        -- for i in 1..x_num_records loop --Bug5841426

          --l_req_line_id := t_req_lines(i).requisition_line_id;-- <SERVICES FPJ>

          /* get the info from the req line which is not available in the client side  */
          -- begin
            -- x_progress := '005';
            l_string := ' select rl.requisition_line_id,
                          rl.LINE_TYPE_ID,			    -- line_type_id
	                  rl.ITEM_ID,				        -- item_id
	                  rl.ITEM_REVISION,			    -- item_revision
	                  rl.CATEGORY_ID,			      -- category id
	                  rl.QUANTITY,				      -- quantity
	                  rl.UNIT_MEAS_LOOKUP_CODE,	-- unit meas lookup code
	                  rl.JOB_ID,				        -- job id
	                  rl.requisition_header_id,
                    psg.char1,
                    RL.order_type_lookup_code,              -- <SERVICES FPJ>
                    rl.note_to_vendor,
                    rl.need_by_date,
                    RL.amount,                              -- <SERVICES FPJ>
                    msi.concatenated_segments,
                    rl.deliver_to_location_id,
                    rl.unit_price,
                    rl.item_description,
                    PJ.name,                                  -- <SERVICES FPJ>
                    RL.job_long_description,                  -- <SERVICES FPJ>
                    RL.org_id                                 -- <HTMLAC>


                   /*into  x_req_header_id,
                   l_value_basis,                             -- <SERVICES FPJ>
                   x_note_to_vendor,
                   x_need_by_date,
                   l_amount,                                  -- <SERVICES FPJ>
                   x_item_num,
                   x_deliver_to_location_id,
                   x_unit_price,
                   x_item_desc,
                   l_job_name,                                -- <SERVICES FPJ>
                   l_job_long_description,                    -- <SERVICES FPJ>
                   l_from_org_id   */                           -- <HTMLAC>
             from po_requisition_lines_all rl,                -- <HTMLAC>
                  mtl_system_items_kfv msi,
                  per_jobs_vl          PJ,
                  PO_SESSION_GT psg                     -- <SERVICES FPJ>
             where  requisition_line_id = psg.key     -- <SERVICES FPJ>
             and    rl.item_id = msi.inventory_item_id(+)
             and    nvl(msi.organization_id, rl.destination_organization_id) =
                         rl.destination_organization_id
             AND    RL.job_id = PJ.job_id(+)                 -- <SERVICES FPJ>
             AND    psg.index_char1 = ''PO_NEGOTIATIONS_SV1'''       ;

             if (x_grouping_method = 'REQUISITION') then
  l_string := l_string || '  ORDER BY psg.char1, psg.num1';
ELSE
 l_string := l_string || '  order by psg.num2, psg.num3, psg.date1, psg.key';
END IF;

    OPEN l_cursor FOR l_string;

   loop
             FETCH l_cursor INTO  x_req_line_id ,
                                  x_line_type  ,
                                  x_item_id   ,
                                  x_item_rev   ,
                                  x_category_id ,
                                  x_quantity     ,
                                  x_uom           ,
                                  x_job_id         ,
                                  x_req_header_id   ,
                                  x_req_num          ,
                                  l_value_basis,
                                  x_note_to_vendor,
                                  x_need_by_date,
                                  l_amount,
                                  x_item_num,
                                  x_deliver_to_location_id,
                                  x_unit_price,
                                  x_item_desc,
                                  l_job_name,
                                  l_job_long_description,
                                  l_from_org_id       ;
          IF l_cursor%NOTFOUND THEN
           EXIT;
          END IF;

          /* exception
           when others then
           po_message_s.sql_error('In Exception of create_negotiation()', x_progress, sqlcode);
           end;*/

          /* begin
             x_progress := '006';
             select segment1
             into x_req_num
             from po_requisition_headers_all                   -- <HTMLAC>
             where requisition_header_id=x_req_header_id;
           exception
              when others then
              po_message_s.sql_error('In Exception of create_negotiation()', x_progress, sqlcode);
           end;*/
          --Bug 5841426<end>

            /*
          ** Get the ship to location id associated with the deliver to location.
          ** This may then used to get the tax name, if the tax system parameters are
          ** set up to retrieve the tax code based on ship-to location. */

          BEGIN
          x_progress := '004';
          SELECT nvl(ship_to_location_id,location_id)
          INTO x_ship_to_location_id
          FROM hr_locations
          WHERE location_id = x_deliver_to_location_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
                x_ship_to_location_id := x_deliver_to_location_id;
          END;

          /* Sourcing expects the uom_code whereas req lines stores unit_of_measure .
             need to get the correct value */
             begin
               select mum.uom_code
               into x_uom_code
               from mtl_units_of_measure mum
               where mum.unit_of_measure = x_uom; --bug 5841426
             exception
               when others then
                 x_uom_code := null;
             end;

           -- <SERVICES FPJ START>

           -- Determine if this Requisition Line has Price Differentials.
           --
           IF  ( PO_PRICE_DIFFERENTIALS_PVT.has_price_differentials
                 (   p_entity_type => 'REQ LINE'
                 ,   p_entity_id   => x_req_line_id)  --Bug 5841426
               )
           THEN
               l_has_price_diff_flag := 'Y';
           ELSE
               l_has_price_diff_flag := 'N';
           END IF;

           --<HTMLAC START>
           -- Get The Conversion rate from the from_ou to the to_ou
           -- If the l_conv_rate is null, means there is no conversion
           -- rate between the different OUs, then we pass in null for
           -- the amount and the unit_price
           l_conv_rate := PO_CURRENCY_SV.get_cross_ou_rate(
                              l_from_org_id,
                              x_org_id);
           --<HTMLAC END>

           -- Determine which value to pass in for BID_START_PRICE and
           -- PO_AGREED_AMOUNT. For Fixed Price lines, we will pass the
           -- Req Line Amount into the Bid Start Price.
           --
           IF ( l_value_basis = 'FIXED PRICE' )
           THEN
               l_bid_start_price := l_amount * l_conv_rate;     --<HTMLAC>
               l_po_agreed_amount := NULL;
           ELSE
               l_bid_start_price := x_unit_price * l_conv_rate; --<HTMLAC>
               l_po_agreed_amount := l_amount * l_conv_rate;    --<HTMLAC>
           END IF;

           -- <SERVICES FPJ END>

        /* call the sourcing api to add the requisition lines to the above negotiation */
        /* Adding parameter p_neg_outcome - RENEG BLANKET FPI */
           x_progress := '007';
           PON_AUCTION_INTERFACE_PKG.add_negotiation_line
           (   p_document_number     => x_negotiation_id
           ,   p_contract_type       => p_neg_outcome
           ,   p_origination_code    => 'REQUISITION'
           ,   p_org_id              => x_org_id
           ,   p_buyer_id            => to_number(FND_PROFILE.VALUE('user_id'))
           ,   p_grouping_type       => x_grouping_method
           ,   p_requisition_header_id => x_req_header_id
           ,   p_requisition_number  => x_req_num
           ,   p_requisition_line_id => x_req_line_id
           ,   p_line_type_id        => x_line_type  --Bug5841426
           ,   p_category_id         => x_category_id
           ,   p_item_description    => x_item_desc
           ,   p_item_id             => x_item_id    --Bug5841426
           ,   p_item_number         => x_item_num   --Bug5841426
           ,   p_item_revision       => x_item_rev

           ,   p_uom_code            => x_uom_code
           ,   p_quantity            => x_quantity

           ,   p_need_by_date        => x_need_by_date
           ,   p_ship_to_location_id => x_ship_to_location_id
           ,   p_note_to_vendor      => x_note_to_vendor
           ,   p_price               => l_bid_start_price     -- <SERVICES FPJ>
           ,   p_job_id              => x_job_id-- <SERVICES FPJ> --Bug5841426

           ,   p_job_details         => l_job_long_description-- <SERVICES FPJ>
           ,   p_po_agreed_amount    => l_po_agreed_amount    -- <SERVICES FPJ>
           ,   p_has_price_diff_flag => l_has_price_diff_flag -- <SERVICES FPJ>
           ,   p_line_number         => x_negotiation_line_num
           ,   p_result              => api_result
           ,   p_error_code          => api_error_code
           ,   p_error_message       => api_error_msg
           );

         If api_result = 0 then

             begin

                x_progress := '008';
                update po_requisition_lines_all                 --<HTMLAC>
                set on_rfq_flag = 'Y',
                    auction_header_id  = x_negotiation_id,
                    auction_display_number = to_char(x_negotiation_id) ,
                    auction_line_number = x_negotiation_line_num,
                    at_sourcing_flag = 'Y',                -- <REQINPOOL>
                    reqs_in_pool_flag = NULL,               -- <REQINPOOL>
                    last_update_date  = sysdate,
                    last_updated_by = to_number(FND_PROFILE.VALUE('user_id')),
                    last_update_login = to_number(FND_PROFILE.VALUE('user_id'))
                where requisition_line_id = x_req_line_id;    --5841426

             exception
               when others then
               po_message_s.sql_error('In Exception of create_negotiation()', x_progress, sqlcode);
             end;

            -- <SERVICES FPJ START> For each Price Differential,
            -- call Sourcing API to add it.
            --
            IF ( l_has_price_diff_flag = 'Y' ) THEN

                FOR l_price_diff_rec IN l_price_diff_csr(x_req_line_id) LOOP    --Bug5841426

                    PON_AUCTION_INTERFACE_PKG.add_price_differential
                    (   p_document_number   => x_negotiation_id
                    ,   p_line_number       => x_negotiation_line_num
                    ,   p_shipment_number   => -1
                    ,   p_price_type        => l_price_diff_rec.price_type
                    ,   p_multiplier        => l_price_diff_rec.min_multiplier
                    ,   p_buyer_id          => FND_PROFILE.value('user_id')
                    ,   p_price_differential_number => l_price_diff_rec.price_differential_num
                    ,   p_result            => api_result
                    ,   p_error_code        => api_error_code
                    ,   p_error_message     => api_error_msg
                    );

                    IF ( api_result <> 0 )                -- API failure
                    THEN
                        x_result := api_result;
                        x_error_code := api_error_code;
                        x_error_message := api_error_msg;
                        rollback;
                        return;
                    END IF;

                END LOOP;

            END IF;
            --
            -- <SERVICES FPJ END>

            x_result := api_result;
            x_error_code := api_error_code;
            x_error_message := api_error_msg;

          else
               /* If unsuccessful return the error code to the form. */
                  x_progress := '009';
                  x_result := api_result;
                  x_error_code := api_error_code;
                  x_error_message := api_error_msg;

                /* before returning we rollback and return */
                  rollback;
                  return ;
          end if;

         end loop;

          x_progress := '010';

	 -- <ACHTML R12 START>
  	 PON_AUCTION_INTERFACE_PKG.add_negotiation_invitees
         ( p_api_version     => 1.0                                      -- IN
         , x_return_status   => l_return_status                          -- OUT
         , x_msg_count       => l_msg_count                              -- OUT
         , x_msg_data        => l_msg_data                               -- OUT
         , p_document_number => x_negotiation_id                         -- IN
         , p_buyer_id        => to_number(FND_PROFILE.VALUE('user_id'))  -- IN
	 );

         if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_progress := '020';
           x_result := -1;
	   x_error_message := l_msg_data;

           -- before returning we rollback and return
           rollback;
           return ;
         end if;
	 -- <ACHTML R12 END>

         -- <Catalog Convergence R12 START>
         PON_AUCTION_INTERFACE_PKG.add_catalog_descriptors
         ( p_api_version => 1.0
         , p_document_number => x_negotiation_id
         , x_return_status => l_return_status
         , x_msg_count => l_msg_count
         , x_msg_data => l_msg_data
         );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_progress := '030';
           x_result := -1;
	   x_error_message := l_msg_data;

           -- before returning we rollback and return
           ROLLBACK;
           return ;
         END IF;
         -- <Catalog Convergence R12 END>

	 --<Bug : 11071489 REQ_AUTOCREATE Start>--
	 --Raise business event when negotiation created from Requisition
	 -- from autocreate process
	  x_progress := '040';
	 l_event_name := 'oracle.apps.po.autocreate.negcreated';
         l_parameter_list(1).name := 'Auction_Header_id' ;
         l_parameter_list(1).value := x_negotiation_id;
         po_core_s4.raise_business_event(l_event_name,l_parameter_list);
	 --<REQ_AUTOCREATE end>--
        /* issue commit */
          commit;

EXCEPTION
WHEN OTHERS THEN
    rollback;
    x_result := -1;
    --<HTMLAC START>
    IF (x_error_message IS NULL) THEN
      x_error_message := 'In Exception of create_negotiation:' || x_progress || ':' || fnd_message.get;
    END IF;
    --<HTMLAC END>
    po_message_s.sql_error('In Exception of create_negotiation()', x_progress, sqlcode);
END;

/*============================================================================
     Name: DELETE_NEGOTIATION_REF
     DESC: Delete negotiation reference from the backing requisition
==============================================================================*/

PROCEDURE  DELETE_NEGOTIATION_REF (x_negotiation_id   in  number,
                                   x_negotiation_line_num  in  number,
                                   x_error_code  out NOCOPY varchar2) is

BEGIN
      if x_negotiation_line_num is null then

                -- <REQINPOOL>: added update of at_sourcing_flag and of
                -- WHO columns.
                update po_requisition_lines_all prla --Bug 4001965: use _all
                set auction_header_id  = null,
                    auction_display_number = null,
                    auction_line_number = null,
                    at_sourcing_flag = null,   --<REQINPOOL>
                    on_rfq_flag = null, -- bug 5370213
                    --<Begin Bug#: 5203799> We don't want to set the reqs_in_pool_flag to 'Y'
                    --if any of the following conditions are met.
                    reqs_in_pool_flag =
					(CASE
                       WHEN (nvl(modified_by_agent_flag,'N') = 'Y'
                         or NVL(cancel_flag,'N') IN ('Y', 'I')
                         or NVL(closed_code,'OPEN') = 'FINALLY CLOSED'
                         or source_type_code = 'INVENTORY'
                         or NVL(line_location_id, -999) <> -999
                         or exists
			               (select 'Req Header auth_status is not approved or contractor_status is pending'
				            from po_requisition_headers_all prha
				            where prha.requisition_header_id = prla.requisition_header_id
				            and (NVL(prha.authorization_status,'INCOMPLETE') <> 'APPROVED'
				                 or NVL(prha.contractor_status,'NOT_APPLICABLE') = 'PENDING')))
                       THEN null
                       ELSE 'Y'
                     END
                    ), --<End Bug#: 5203799>
	            	last_update_date       = SYSDATE,
                    last_updated_by        = FND_GLOBAL.USER_ID,
                    last_update_login      = FND_GLOBAL.LOGIN_ID
              where auction_header_id = x_negotiation_id;

     else
             -- <REQINPOOL>: added update of at_sourcing_flag and of
             -- WHO columns.
             update po_requisition_lines_all prla --Bug 4001965: use _all
                set auction_header_id  = null,
                    auction_display_number = null,
                  auction_line_number = null,
                  at_sourcing_flag = null,       --<REQINPOOL>
                  on_rfq_flag = null, -- bug 5370213
                  --<Begin Bug#: 5203799> We don't want to set the reqs_in_pool_flag to 'Y'
                    --if any of the following conditions are met.
                  reqs_in_pool_flag =
				  (CASE
                       WHEN (nvl(modified_by_agent_flag,'N') = 'Y'
                         or NVL(cancel_flag,'N') IN ('Y', 'I')
                         or NVL(closed_code,'OPEN') = 'FINALLY CLOSED'
                         or source_type_code = 'INVENTORY'
                         or NVL(line_location_id, -999) <> -999
                         or exists
			               (select 'Req Header auth_status is not approved or contractor_status is pending'
				            from po_requisition_headers_all prha
				            where prha.requisition_header_id = prla.requisition_header_id
				            and (NVL(prha.authorization_status,'INCOMPLETE') <> 'APPROVED'
				                 or NVL(prha.contractor_status,'NOT_APPLICABLE') = 'PENDING')))
                       THEN null
                       ELSE 'Y'
                     END
                    ), --<End Bug#: 5203799>
	          last_update_date       = SYSDATE,
                  last_updated_by        = FND_GLOBAL.USER_ID,
                  last_update_login      = FND_GLOBAL.LOGIN_ID
              where auction_header_id = x_negotiation_id
              and auction_line_number = x_negotiation_line_num;
     end if;

             x_error_code := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
    x_error_code := 'FAILURE';
END;

/*============================================================================
     Name: UPDATE_NEGOTIATION_REF
     DESC: Update negotiation reference in the backing requisition
==============================================================================*/

PROCEDURE UPDATE_NEGOTIATION_REF (x_old_negotiation_id     in   number ,
                                  x_new_negotiation_id  in   number ,
                                  x_new_negotiation_num  in varchar2 ,
                                  x_error_code  out NOCOPY varchar2) is
BEGIN
             update po_requisition_lines_all --Bug 4001965: use _all
             set auction_header_id  = x_new_negotiation_id,
                 auction_display_number = x_new_negotiation_num
             where auction_header_id =  x_old_negotiation_id;

             x_error_code := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
    x_error_code := 'FAILURE';
END;

--<Bug 2440254 mbhargav START>
--Provide Sourcing with an API which Given two negotiation lines,
--update all requisition line from one negotiation line to
--point to another negotiation line.
/*============================================================================
   Name: UPDATE_NEGOTIATION_LINE_REF
   DESC: Update negotiation reference in the backing requisition line to
           point to another negotiation line.
   Input parameters :
       p_api_version: Version of the API expected by caller. Current value 1.0
       p_old_negotiation_id : negotiation whose reference has to be replaced
       p_old_negotiation_line_num : negotiation line whose reference has to be replaced
       p_new_negotiation_num/id : new negotiation reference
       p_new_negotiation_line_num : new negotiation line where reference has
                                    to be added
   Output parameters :
       x_return_status: The return status of the API. Valid values are:
                         FND_API.G_RET_STS_SUCCESS
                         FND_API.G_RET_STS_ERROR
                         FND_API.G_RET_STS_UNEXP_ERROR
       x_error_message: Contain translated error message in case the return status
                        is G_RET_STS_ERROR or G_RET_STS_UNEXP_ERROR
   Version: Current Version         1.0
                  Changed:   Initial design 1/27/2003
            Previous Version        1.0
==============================================================================*/

PROCEDURE UPDATE_NEGOTIATION_LINE_REF (
                                  p_api_version              IN         NUMBER,
                                  p_old_negotiation_id       IN         NUMBER,
                                  p_old_negotiation_line_num IN         NUMBER,
                                  p_new_negotiation_id       IN         NUMBER,
                                  p_new_negotiation_line_num IN         NUMBER,
                                  p_new_negotiation_num      IN         varchar2,
                                  x_return_status            OUT NOCOPY varchar2,
                                  x_error_message            OUT NOCOPY varchar2) is

l_api_name              CONSTANT varchar2(30) := 'UPDATE_NEGOTIATION_LINE_REF';
l_api_version           CONSTANT NUMBER       := 1.0;

l_progress              varchar2(3);
BEGIN
        l_progress := '000';

        -- Standard call to check for call compatibility
        IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '001';

        update po_requisition_lines_all --Bug 4001965: use _all
        set   auction_header_id  = p_new_negotiation_id,
              auction_display_number = p_new_negotiation_num,
              auction_line_number = p_new_negotiation_line_num
        where auction_header_id =  p_old_negotiation_id and
              auction_line_number = p_old_negotiation_line_num;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_error_message := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
           x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                  FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name,
                  SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
           END IF;

           x_error_message := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_NEGOTIATION_LINE_REF;
--<Bug 2440254 mbhargav END>

/*============================================================================
     Name: UPDATE_REQ_POOL
     DESC: Update requisition pool flag in the backing requisition
==============================================================================*/

PROCEDURE UPDATE_REQ_POOL (x_negotiation_id   in  number,
                           x_negotiation_line_num   in  number,
                           x_flag_value  in varchar2,
                           x_error_code  out NOCOPY varchar2) is

       x_sourcing_flag_value    PO_REQUISITION_LINES_ALL.at_sourcing_flag%TYPE;    -- <REQINPOOL>
       x_new_pool_value         PO_REQUISITION_LINES_ALL.reqs_in_pool_flag%TYPE;    -- <REQINPOOL>
BEGIN
       -- <REQINPOOL>: check sourcing flag value and convert to new Y/NULL
       -- domain for reqs_in_pool_flag and new col at_sourcing_flag
       IF(x_flag_value = 'N') THEN
            x_sourcing_flag_value := 'Y';
            x_new_pool_value      := NULL;
       ELSE
            x_sourcing_flag_value := NULL;
            x_new_pool_value      := 'Y';
       END IF;


       if x_negotiation_line_num is null then
              -- <REQINPOOL>: added update of at_sourcing_flag and of
              -- WHO columns.
              update po_requisition_lines_all prla --Bug 4001965: use _all
              set reqs_in_pool_flag = x_new_pool_value,
                  at_sourcing_flag = x_sourcing_flag_value, --<REQINPOOL>
	          last_update_date       = SYSDATE,
                  last_updated_by        = FND_GLOBAL.USER_ID,
                  last_update_login      = FND_GLOBAL.LOGIN_ID
              where auction_header_id = x_negotiation_id
              --<Begin Bug#: 5203799>  We only want to set the reqs_in_pool_flag to 'Y'
              --if all of the following conditions are met.
              and nvl(modified_by_agent_flag,'N') <> 'Y' --<BUG#: 5067460 ,BUG#:4957635>
			  and NVL(cancel_flag,'N') NOT IN ('Y', 'I')
			  and NVL(closed_code,'OPEN') <> 'FINALLY CLOSED'
			  and source_type_code <> 'INVENTORY'
			  and NVL(line_location_id, -999) = -999
			  and not exists
			     (select 'Req Header auth_status is not approved or contractor_status is pending'
				  from po_requisition_headers_all prha
				  where prha.requisition_header_id = prla.requisition_header_id
				  and (NVL(prha.authorization_status,'INCOMPLETE') <> 'APPROVED'
				       or NVL(prha.contractor_status,'NOT_APPLICABLE') = 'PENDING'));
			  --<End Bug#: 5203799>

       else
              -- <REQINPOOL>: added update of at_sourcing_flag and of
              -- WHO columns.
          update po_requisition_lines_all prla --Bug 4001965: use _all
              set reqs_in_pool_flag = x_new_pool_value,
                  at_sourcing_flag = x_sourcing_flag_value, --<REQINPOOL>
	          last_update_date       = SYSDATE,
                  last_updated_by        = FND_GLOBAL.USER_ID,
                  last_update_login      = FND_GLOBAL.LOGIN_ID
              where auction_header_id = x_negotiation_id
              and auction_line_number = x_negotiation_line_num
              --<Begin Bug#: 5203799> We only want to set the reqs_in_pool_flag to 'Y'
              --if all of the following conditions are met.
              and nvl(modified_by_agent_flag,'N') <> 'Y' --<BUG#: 5067460 ,BUG#:4957635>
			  and NVL(cancel_flag,'N') NOT IN ('Y', 'I')
			  and NVL(closed_code,'OPEN') <> 'FINALLY CLOSED'
			  and source_type_code <> 'INVENTORY'
			  and NVL(line_location_id, -999) = -999
			  and not exists
			     (select 'Req Header auth_status is not approved or contractor_status is pending'
				  from po_requisition_headers_all prha
				  where prha.requisition_header_id = prla.requisition_header_id
				  and (NVL(prha.authorization_status,'INCOMPLETE') <> 'APPROVED'
				       or NVL(prha.contractor_status,'NOT_APPLICABLE') = 'PENDING'));
			  --<End Bug#: 5203799>
      end if;

              x_error_code := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
    x_error_code := 'FAILURE';
END;

/*============================================================================
     Name: check_negotiation_ref
     DESC: checks if a req line/header has negotiation reference
==============================================================================*/

PROCEDURE check_negotiation_ref(x_doc_level IN VARCHAR2,
                                x_doc_id    IN NUMBER,
                                x_negotiation_ref_flag IN OUT NOCOPY varchar2) is

cursor c1(x_doc_line_id in number) is
select at_sourcing_flag       --<REQINPOOL>
from po_requisition_lines_all --Bug 4001965: use _all
where requisition_line_id = X_doc_line_id;

cursor c2(x_doc_header_id in number) is
select at_sourcing_flag       --<REQINPOOL>
from po_requisition_lines_all --Bug 4001965: use _all
where requisition_header_id = X_doc_header_id;

x_doc_line_id   number;
x_doc_header_id   number;
x_sourcing_flag   PO_REQUISITION_LINES_ALL.at_sourcing_flag%TYPE; --<REQINPOOL>
x_sourcing_install_status varchar2(1);

BEGIN

    if x_doc_level = 'REQ LINE' then

        x_doc_line_id := x_doc_id;
        open c1(x_doc_line_id);
         loop
          fetch c1 into x_sourcing_flag;
          EXIT WHEN c1%NOTFOUND;

          if x_sourcing_flag = 'Y' then
             x_negotiation_ref_flag := 'Y';
          end if;

          end loop;
        close c1;

    elsif x_doc_level = 'REQ HEADER' then

        x_doc_header_id := x_doc_id;
        open c2(x_doc_header_id);
         loop
          fetch c2 into x_sourcing_flag;
          EXIT WHEN c2%NOTFOUND;

          if x_sourcing_flag ='Y' then
             x_negotiation_ref_flag := 'Y';
             exit;
          end if;
         end loop;
        close c2;

    end if;


END;

PROCEDURE renegotiate_blanket(  p_api_version		IN 		NUMBER,
				p_commit		IN		varchar2,
				p_po_header_id          IN              NUMBER,
                                p_negotiation_type      IN              varchar2,
                                x_negotiation_id        OUT NOCOPY      NUMBER,
                                x_doc_url_params        OUT NOCOPY      varchar2,
                                x_return_status		OUT NOCOPY      varchar2,
                                x_error_code            OUT NOCOPY      varchar2,
                                x_error_message         OUT NOCOPY      varchar2) IS
l_large_negotiation     VARCHAR2(1);
l_large_neg_request_id  NUMBER;

BEGIN
  renegotiate_blanket(  p_api_version		,
		        p_commit		,
		        p_po_header_id          ,
                        p_negotiation_type      ,
                        x_negotiation_id        ,
                        x_doc_url_params        ,
                        x_return_status		,
                        x_error_code            ,
                        x_error_message         ,
                        l_large_negotiation     ,
                        l_large_neg_request_id ) ;
END;

--<RENEG BLANKET FPI START>
/*============================================================================
Name      : 	RENEGOTIATE_BLANKET
Type      : 	Private
Function  :  	This procedure
        	a. populates the Sourcing Interface tables
        	b. Calls Sourcing APIs for creating draft_negotiation and purging interface tables
Pre-req   :	None
Parameters:
IN	  : 	p_api_version		IN 		NUMBER		REQUIRED
		p_commit		IN		varchar2	REQUIRED
		p_po_header_id		IN		NUMBER  	REQUIRED
		p_negotiation_type	IN		varchar2	REQUIRED
OUT para  :	x_negotiation_id        OUT NOCOPY	NUMBER
                x_doc_url_params        OUT NOCOPY	varchar2
                x_return_status         OUT NOCOPY	varchar2
                x_error_code            OUT NOCOPY	varchar2
                x_error_message         OUT NOCOPY	varchar2
Version   :	Current Version 	1.0
		     Changed:	Initial design 10/1/2002
		Previous Version	1.0
==============================================================================*/
PROCEDURE renegotiate_blanket(  p_api_version		IN 		NUMBER,
				p_commit		IN		varchar2,
				p_po_header_id          IN              NUMBER,
                                p_negotiation_type      IN              varchar2,
                                x_negotiation_id        OUT NOCOPY      NUMBER,
                                x_doc_url_params        OUT NOCOPY      varchar2,
                                x_return_status		OUT NOCOPY      varchar2,
                                x_error_code            OUT NOCOPY      varchar2,
                                x_error_message         OUT NOCOPY      varchar2,
                                x_large_negotiation     OUT NOCOPY      varchar2,
                                x_large_neg_request_id  OUT NOCOPY      NUMBER) IS

l_api_name		CONSTANT varchar2(30) := 'RENEGOTIATE_BLANKET';
l_api_version		CONSTANT NUMBER	      := 1.0;

l_po_num		po_headers.segment1%type := NULL;
l_interface_id		NUMBER;

l_create_api_result	varchar2(30) :=NULL;
l_create_api_err_code	varchar2(100) := NULL;
l_create_api_err_msg	varchar2(400) := NULL;

l_ret_sts_success	varchar2(30) := 'SUCCESS';
l_ret_sts_error		varchar2(30) := 'FAILURE';

l_progress		varchar2(3);
l_user_id               NUMBER := -1;

--<Catalog Convergence 12.0 START>
l_po_created_language PO_HEADERS_ALL.created_language%TYPE;

--<Catalog Convergence 12.0 END>
BEGIN
	l_progress := '000';

	-- Standard start of API savepoint
	SAVEPOINT	renegotiate_blanket_grp;

	-- Standard call to check for call compatibility
	IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    l_progress := '001';

      --Bug 2694722 : Getting user id
      l_user_id := FND_GLOBAL.USER_ID;

      --Populate PON_AUC_HEADERS_INTERFACE table
	insert into pon_auc_headers_interface(
		interface_auction_header_id,
      		neg_type,
      		contract_type,
      		ship_to_location_id,
      		bill_to_location_id,
      		payment_terms_id,
      		freight_terms_code,
      		fob_code,
      		carrier_code,
      		note_to_bidders,
      		creation_date,
      		created_by,
      		last_update_date,
      		last_updated_by,
      		allow_other_bid_currency_flag,
      		po_agreed_amount,
      		origination_code,
      		global_agreement_flag,
      		po_min_rel_amount,
      		currency_code,
      		rate_type,
      		rate_date,
      		rate,
      		user_id,
      		org_id,
      		supplier_id,
		source_doc_id,
		source_doc_number,
		source_doc_msg,
		source_doc_line_msg,
		source_doc_msg_app,
		po_style_id, -- BUG#5532470
		language_code, --Bug#4911361
                supplier_site_id)
	select PON_AUC_HEADERS_INTERFACE_S.nextval,
			p_negotiation_type,
			'BLANKET',
			ship_to_location_id,
			bill_to_location_id,
			terms_id,
			freight_terms_lookup_code,
			fob_lookup_code,
			ship_via_lookup_code,
			note_to_vendor,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			'Y',
			blanket_total_amount,
			type_lookup_code,
			global_agreement_flag,
			min_release_amount,
			currency_code,
			rate_type,
			rate_date,
			rate,
			l_user_id,
			org_id,
			vendor_id,
			po_header_id,
			segment1,
                        --<Bug 2917962 mbhargav START>
                        --Sourcing team wants the name of the messages and
                        --not the message text. So inserting the names of messages
                        --for 'Blanket Agreement' and 'Line' respectively
			'PO_POTYPE_BLKT',
			'PO_SOURCING_LINE_NUMBER',
                        --<Bug 2917962 mbhargav END>
			'PO',
			style_id, -- BUG#5532470
		        created_language, --Bug#4911361
                        vendor_site_id  --<Bug 3325876>
	from	po_headers
	where	po_header_id=p_po_header_id;

	l_progress := '002';

    -- Get the interface_id into local variable
	select PON_AUC_HEADERS_INTERFACE_S.currval
	into l_interface_id
	from dual;

    l_progress := '003';
    -- Get the segment1 from p_po_header_id
	select segment1
	into l_po_num
	from po_headers
	where po_header_id = p_po_header_id;


     l_progress := '004';
     --Bug #2737797
     --Amount agreed needs to passed instead of unit_price to
     --bid_start_price column in pon_auc_items_interface for
     -- amount based lines.

     l_progress := '005';
      --Populate PON_AUC_ITEMS_INTERFACE table
	insert into pon_auc_items_interface(
		interface_auction_header_id,
      		interface_line_number,
      		line_type_id,
      		item_description,
      		org_id,
      		category_id,
      		quantity,
      		current_price, --Bug#4915340
      		note_to_bidders,
      		uom_code,
      		creation_date,
      		created_by,
      		last_update_date,
      		last_updated_by,
      		origination_code,
      		po_min_rel_amount,
      		price_break_type,
      		item_id,
      		item_number,
      		item_revision,
      		source_doc_number,
      		source_line_number,
      		source_doc_id,
      		source_line_id,
            job_id,                                           -- <SERVICES FPJ>
            po_agreed_amount,                                 -- <SERVICES FPJ>
            purchase_basis,                                   -- <SERVICES FPJ>
            ip_category_id)                                   -- <Catalog Convergence 12.0>
	select 	l_interface_id,
            rownum, --bug 2714549: renumbers lines
            pl.line_type_id,
            item_description,
            pl.org_id,
            pl.category_id,
            quantity_committed, --Bug #2706156
                        --Bug #2737797
            decode ( PL.order_type_lookup_code                -- <SERVICES FPJ>
                   , 'AMOUNT'      , PL.committed_amount
                   , 'FIXED PRICE' , PL.amount
                   ,                 PL.unit_price
                   ),
			note_to_vendor,
			mum.uom_code,
			pl.creation_date,
			pl.created_by,
			pl.last_update_date,
			pl.last_updated_by,
			'BLANKET',
			min_release_amount,
			price_break_lookup_code,
			item_id,
			msi.concatenated_segments,
			item_revision,
			l_po_num,
			line_num,   --original (non-renumbered) line num
			po_header_id,
			po_line_id,
                        PL.job_id,                                        -- <SERVICES FPJ>
                        decode ( PL.order_type_lookup_code                -- <SERVICES FPJ>
                                 , 'FIXED PRICE' , PL.committed_amount
                                 , 'RATE'        , PL.committed_amount
                                 ,  NULL),
                        PL.purchase_basis,                                -- <SERVICES FPJ>
                        pl.ip_category_id                                 -- <Catalog Convergence 12.0>
        from    po_lines pl, mtl_units_of_measure mum, mtl_system_items_kfv msi,
                financials_system_parameters fsp --<Bug 3274272,3330235>
	where	po_header_id=p_po_header_id and
		mum.unit_of_measure (+) = pl.unit_meas_lookup_code and -- <BUG 3211566>
		--bug #2716412: made pl/msi join an outer join
		pl.item_id = msi.inventory_item_id(+) and
                --<Bug 3274272, 3330235>
                (pl.item_id IS NULL OR fsp.inventory_organization_id = msi.organization_id);

        --<Catalog Convergence 12.0 START>
        --call API to insert descriptor values for each PO line

        SELECT created_language into l_po_created_language
         FROM po_headers_all
        WHERE po_header_id = p_po_header_id;

        PO_ATTRIBUTE_VALUES_PVT.handle_attributes(p_interface_header_id => l_interface_id,
                                                  p_po_header_id => p_po_header_id,
                                                  p_language => l_po_created_language);
        --<Catalog Convergence 12.0 END>

        --<Bug 2699631 mbhargav START>
        --Earlier the Release line locations for this Blanket were also getting copied over
        --to Sourcing. Added the pll.shipment_type = 'PRICE BREAK' in WHERE clause below
        --so that only price breaks of Blanket are copied over
        --<Bug 2699631 mbhargav END>

	l_progress := '006';
      -- Populate PON_AUC_SHIPMENTS_INTERFACE table
	insert into pon_auc_shipments_interface(
			interface_auction_header_id,
      		interface_line_number,
      		interface_ship_number,
      		shipment_type,
      		ship_to_organization_id,
      		ship_to_location_id,
      		quantity,
      		price,
      		org_id,
      		creation_date,
      		created_by,
      		last_update_date,
      		last_updated_by)
	select 	l_interface_id,
			--bug 2714549: get renumbered line#
                        paii.interface_line_number,
			pll.shipment_num,
			pll.shipment_type,
			pll.ship_to_organization_id,
			pll.ship_to_location_id,
			pll.quantity,
			pll.price_override,
			pll.org_id,
			pll.creation_date,
			pll.created_by,
			pll.last_update_date,
			pll.last_updated_by
	from 	po_line_locations pll,
		  -- bug 2714549: added paii to join; removed join to po_lines
                pon_auc_items_interface paii
	where	pll.po_header_id = p_po_header_id and
		  --bug 2714549 start: changed join conditions from po_lines
		  --            to paii and added auction_header cond
		  --            to ensure unique doc_id/line_id from paii
                paii.source_doc_id = p_po_header_id and
                paii.source_line_id = pll.po_line_id and
		paii.interface_auction_header_id = l_interface_id and
		  --bug 2714549 end
                pll.shipment_type = 'PRICE BREAK';


    -- <SERVICES FPJ START>

    -- Populate PON_PRICE_DIFFERENTIALS_INTERFACE Table
    -- with Line-level Price Differentials

    INSERT INTO pon_price_differ_interface
    (    interface_auction_header_id
    ,    interface_line_number
    ,    interface_shipment_number
    ,    interface_price_differ_number
    ,    price_type
    ,    multiplier
    ,    process_status
    ,    creation_date
    ,    created_by
    ,    last_update_date
    ,    last_updated_by
    ,    last_update_login
    )
    SELECT l_interface_id
    ,      POL.line_num
    ,      -1             -- <BUG 3212055> Insert -1 when shipment not present.
    ,      PD.price_differential_num
    ,      PD.price_type
    ,      PD.min_multiplier
    ,      NULL
    ,      PD.creation_date
    ,      PD.created_by
    ,      PD.last_update_date
    ,      PD.last_updated_by
    ,      PD.last_update_login
    FROM   po_price_differentials      PD
    ,      po_lines_all                POL
    WHERE  PD.entity_type   = 'BLANKET LINE'
    AND    PD.entity_id     = POL.po_line_id
    AND    POL.po_header_id = p_po_header_id;


    -- Populate PON_PRICE_DIFFERENTIALS_INTERFACE Table
    -- with Price Break-level Price Differentials

    INSERT INTO pon_price_differ_interface
    (    interface_auction_header_id
    ,    interface_line_number
    ,    interface_shipment_number
    ,    interface_price_differ_number
    ,    price_type
    ,    multiplier
    ,    process_status
    ,    creation_date
    ,    created_by
    ,    last_update_date
    ,    last_updated_by
    ,    last_update_login
    )
    SELECT l_interface_id
    ,      POL.line_num
    ,      POLL.shipment_num
    ,      PD.price_differential_num
    ,      PD.price_type
    ,      PD.min_multiplier
    ,      NULL
    ,      PD.creation_date
    ,      PD.created_by
    ,      PD.last_update_date
    ,      PD.last_updated_by
    ,      PD.last_update_login
    FROM   po_price_differentials      PD
    ,      po_lines_all                POL
    ,      po_line_locations_all       POLL
    WHERE  PD.entity_type   = 'PRICE BREAK'
    AND    PD.entity_id     = POLL.line_location_id
    AND    POLL.po_line_id  = POL.po_line_id
    AND    POL.po_header_id = p_po_header_id;

    -- <SERVICES FPJ END>


	l_progress := '007';
      --Populate PON_ATTACHMENTS_INTERFACE with header level attachments
	insert into pon_attachments_interface(
             interface_auction_header_id,
      		interface_line_number,
      		document_id,
      		seq_num,
      		last_update_date,
      		last_updated_by,
      		creation_date,
      		created_by)
	select  l_interface_id,
			NULL,
			fad.document_id,
			fad.seq_num,
			fad.last_update_date,
			fad.last_updated_by,
			fad.creation_date,
			fad.created_by
	from 	fnd_attached_documents fad,
			fnd_documents fd,
			fnd_documents_tl fdtl
	where 	fad.document_id = fd.document_id AND
			fd.document_id = fdtl.document_id AND
			fdtl.language = userenv('LANG') AND
			fad.entity_name = 'PO_HEADERS' AND
			fad.pk1_value = to_char(p_po_header_id) AND
			fd.category_id <> 39;

	l_progress := '008';
      --Populate PON_ATTACHMENTS_INTERFACE with line level attachments
	insert into pon_attachments_interface(
			interface_auction_header_id,
      		interface_line_number,
      		document_id,
      		seq_num,
      		last_update_date,
      		last_updated_by,
      		creation_date,
      		created_by)
	select 	l_interface_id,
			--bug 2714549: get renumbered line#
                        paii.interface_line_number,
			fad.document_id,
			fad.seq_num,
			fad.last_update_date,
			fad.last_updated_by,
			fad.creation_date,
			fad.created_by
	from 	fnd_attached_documents fad,
			fnd_documents fd,
			fnd_documents_tl fdtl,
                          --bug 2714549: replaced join to po_lines
                          -- with join to paii.
                        pon_auc_items_interface paii
	where 	fad.document_id = fd.document_id AND
			fd.document_id = fdtl.document_id AND
			fdtl.language = userenv('LANG') AND
			fad.entity_name = 'PO_LINES' AND
		  --bug 2714549 start: changed join conditions from po_lines
		  --            to paii and added auction_header cond
		  --            to ensure unique doc_id/line_id from paii
                        paii.source_doc_id = p_po_header_id AND
                        fad.pk1_value = to_char(paii.source_line_id) AND
			paii.interface_auction_header_id = l_interface_id and
		  --bug 2714549 end
			fd.category_id <> 39;

	l_progress := '009';
	-- Call Sourcing API to create draft negotiation
        -- Catalog Convergence 12.0 - new signature to support
        -- large negotiations where sourcing could launch a concurrent program
        -- and return the request id to PO for display. Also changed call to
        -- use parameter name/value convention
	PON_SOURCING_OPENAPI_GRP.CREATE_DRAFT_NEG_INTERFACE(p_interface_id => l_interface_id,
							    x_document_number => x_negotiation_id,
							    x_document_url => x_doc_url_params,
							    x_concurrent_program_started => x_large_negotiation,
                                                            x_request_id => x_large_neg_request_id,
                                                            x_result => l_create_api_result,
							    x_error_code => l_create_api_err_code,
							    x_error_message => l_create_api_err_msg);
	l_progress := '010';

        --<Catalog Convergence 12.0 START>
        -- PO no longer needs to make this call. Sourcing will handle this.
        -- With large negotiation support, it would be incorrect to call purge

	-- Call Sourcing API to purge interface tables
	--PON_SOURCING_OPENAPI_GRP.PURGE_INTERFACE_TABLE(l_interface_id,
	--					  l_purge_api_result,
	--					  l_purge_api_err_code,
	--					  l_purge_api_err_msg);

        --<Catalog Convergence 12.0 END>

	l_progress := '011';

    /* Return appropriate error message. In case of failure of both APIs then
	   error messsage corresponding to create_draft_neg is returned */
        --<Catalog Convergence 12.0 START>
        -- Since Purge call is no longer required removed checks for return status
        -- from that call
	if (l_create_api_result = l_ret_sts_success) then
		x_return_status := l_ret_sts_success;
		x_error_code := l_create_api_err_code;
		x_error_message := l_create_api_err_msg;
	else
		x_return_status := l_ret_sts_error;
		x_error_code := l_create_api_err_code;
		x_error_message := l_create_api_err_msg;
	end if;
        --<Catalog Convergence 12.0. END>

    -- Committing the changes to the database
    if FND_API.To_Boolean(p_commit) then
    	commit;
    end if;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO renegotiate_blanket_grp;
		x_error_message := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
					p_encoded => 'F');
		x_return_status := l_ret_sts_error;
	WHEN OTHERS THEN
		ROLLBACK TO renegotiate_blanket_grp;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name,
                  SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
        END IF;

		x_error_message := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
					p_encoded => 'F');
		x_return_status := l_ret_sts_error;

END RENEGOTIATE_BLANKET;
--<RENEG BLANKET FPI END>

-- Bug 3780359 Start
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_auction_display_line_num
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- This procedure retrieves the display number of an auction line, given
-- the auction header ID and auction line number
--Parameters:
--IN:
--p_auction_header_id
--  Auction Header ID, unique identifier of an auction
--p_auction_line_number
--  Auction Line Number, unique identifier of a line of a particular auction
--OUT:
--x_auction_display_line_num
--  Display number of an auction line for display purpose only
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_auction_display_line_num(
                p_auction_header_id        IN NUMBER,
                p_auction_line_number      IN NUMBER,
                x_auction_display_line_num OUT NOCOPY VARCHAR2)
IS

  l_api_name CONSTANT VARCHAR2(30):= 'GET_AUCTION_DISPLAY_LINE_NUM';
  l_progress          VARCHAR2(3);

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

BEGIN
  l_progress := '000';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name||
                   '.' || l_progress, ' Begin');
     END IF;
  END IF;

  PON_SOURCING_OPENAPI_GRP.get_display_line_number(
     p_api_version           => 1.0,
     p_init_msg_list         => 'F',
     p_auction_header_id     => p_auction_header_id,
     p_auction_line_number   => p_auction_line_number,
     x_display_line_number   => x_auction_display_line_num,
     x_return_status         => l_return_status,
     x_msg_count             => l_msg_count,
     x_msg_data              => l_msg_data);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     l_progress := '010';
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';
  IF g_debug_stmt THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT, g_log_head || l_api_name||
                   '.' || l_progress, ' End');
     END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_stmt THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_log_head ||
         l_api_name||'.' || l_progress, ' Exception has occured.' ||
         ' l_msg_data: ' || l_msg_data || ' l_msg_count: ' || l_msg_count);
       END IF;
    END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
       FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name,
            SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
    END IF;

    x_auction_display_line_num := NULL;

END get_auction_display_line_num;
-- Bug 3780359 End

END po_negotiations_sv1;

/
