--------------------------------------------------------
--  DDL for Package Body PO_AUTOCREATE_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AUTOCREATE_DOC" AS
/* $Header: POXWATCB.pls 120.26.12010000.39 2014/08/07 04:32:14 linlilin ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

/* Private Procedure/Function prototypes */

FUNCTION valid_contact(p_vendor_site_id number, p_vendor_contact_id number) RETURN BOOLEAN;
FUNCTION get_contact_id(p_contact_name varchar2, p_vendor_site_id number) RETURN NUMBER;

-- bug2821542
PROCEDURE validate_buyer (p_agent_id IN NUMBER,
                          x_result   OUT NOCOPY VARCHAR2);

--<Shared Proc FPJ START>
PROCEDURE set_purchasing_org_id(
  itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  p_org_id      IN NUMBER,
  p_suggested_vendor_site_id    IN NUMBER
);
--<Shared Proc FPJ END>

-- <SERVICES FPJ START>
PROCEDURE purge_expense_lines(itemtype IN VARCHAR2,
                              itemkey  IN VARCHAR2);
-- <SERVICES FPJ END>

/* Start of procedure/function bodies */

/***************************************************************************
 *
 *  Procedure:  start_wf_process
 *
 *  Description:  Generates the itemkey, sets up the Item Attributes,
 *      then starts the Main workflow process.
 *
 **************************************************************************/
procedure start_wf_process ( ItemType             VARCHAR2,
                             ItemKey              VARCHAR2,
                             workflow_process     VARCHAR2,
                             req_header_id        NUMBER,
                             po_number            VARCHAR2,
           interface_source_code  VARCHAR2,
           org_id     NUMBER) is

x_org_id      number;
x_progress    varchar2(300);

--< Bug 3636669 Start >
l_user_id           NUMBER;
l_application_id    NUMBER;
l_responsibility_id NUMBER;
--< Bug 3636669 End >

BEGIN

  x_progress := '10: start_wf_process:  Called with following parameters:' ||
    'ItemType = ' || ItemType || '/ ' ||
    'ItemKey = '  || ItemKey  || '/ ' ||
    'workflow_process = ' || workflow_process || '/ ' ||
    'req_header_id = ' || to_char(req_header_id) || '/ ' ||
    'po_number = ' || po_number || '/ ' ||
    'interface_source_code = ' || interface_source_code;

  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);
  END IF;


  /* If a process is passed then it will be run
   * If a process is not passed then the selector function defined in
   * item type will be determine which process to run
   */

  IF  ( ItemType is NOT NULL )   AND
      ( ItemKey is NOT NULL)     AND
      ( req_header_id is NOT NULL ) THEN

        --Bug 5490243. Removed the commit introduced in Bug 3293852

        wf_engine.CreateProcess(itemtype => itemtype,
                                itemkey  => itemkey,
                                process  => workflow_process );

        x_progress:= '20: start_wf_process: Just after CreateProcess';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);
        END IF;


        /* Initialize workflow item attributes */

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'REQ_HEADER_ID',
                                     avalue     => req_header_id);

         po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'PO_NUM_TO_CREATE',
                                     avalue     => po_number);

         /* Interface source code can be:
    *   - FORM = 10sc Enter Req form
          * - ICX  = Web Reqs
          *     - SRS  = Conc. program.
          */

         po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'INTERFACE_SOURCE_CODE',
                                     avalue     => interface_source_code);


        /* Both web reqs and sc enter reqs should pass in both a req_header_id
         * and an org_id tied to that header. Even so, I'm going to get the
         * org_id again from the req_header_id just to be sure.
         *
         * Eventually if this workflow gets called for >1 req eg. thru srs then
         * there the req_header_id maybe null so then we'll just take the
         * org_id as passed in.
         */

  x_org_id := org_id;

  /* The calling proc should pass in the right org_id associated with the
   * the req, but get it again just in case.
   */

        if (req_header_id is NOT NULL) then

           select org_id
       into x_org_id
             from po_requisition_headers
      where requisition_header_id = req_header_id;

        end if;

         po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ORG_ID',
                                        avalue     => x_org_id);

        --< Bug 3636669 Start >
        -- Retrieve the current application context values. This assumes that
        -- the application context has been set prior to calling this procedure.
        FND_PROFILE.get('USER_ID',      l_user_id);
        FND_PROFILE.get('RESP_ID',      l_responsibility_id);
        FND_PROFILE.get('RESP_APPL_ID', l_application_id);

        -- Populate the application context workflow attributes
        PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype => itemtype
                                        , itemkey  => itemkey
                                        , aname    => 'USER_ID'
                                        , avalue   => l_user_id
                                        );
        PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype => itemtype
                                        , itemkey  => itemkey
                                        , aname    => 'APPLICATION_ID'
                                        , avalue   => l_application_id
                                        );
        PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype => itemtype
                                        , itemkey  => itemkey
                                        , aname    => 'RESPONSIBILITY_ID'
                                        , avalue   => l_responsibility_id
                                        );
        --< Bug 3636669 End >

        /* Kick off the process */

  x_progress :=  '30: start_wf_process: Kicking off StartProcess ';
  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);
  END IF;

        wf_engine.StartProcess(itemtype => itemtype,
                               itemkey  => itemkey );

    END IF;

exception
  when others then
   wf_core.context('po_autocreate_doc','start_wf_process',x_progress);
   raise;
end start_wf_process;


/***************************************************************************
 *
 *  Procedure:  should_req_be_autocreated
 *
 *  Description:  Decides whether automatic autocreation should
 *      take place or not.
 *
 **************************************************************************/
procedure should_req_be_autocreated(itemtype   IN   VARCHAR2,
                                    itemkey    IN   VARCHAR2,
                                    actid      IN   NUMBER,
                                    funcmode   IN   VARCHAR2,
                                    resultout  OUT NOCOPY  VARCHAR2 ) is

x_autocreate_doc   varchar2(1);
x_progress         varchar2(300);

begin

   /* This decision is made by simply looking at an item atrribute,
    * which has a default value. All the user needs to do is change
    * that attribute according to their needs.
    */

   x_autocreate_doc := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'AUTOCREATE_DOC');

   if (x_autocreate_doc = 'Y') then
     resultout := wf_engine.eng_completed || ':' ||  'Y';

     x_progress:= '10: should_req_be_autocreated: result = Y';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   else
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '20: should_req_be_autocreated: result = N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;
   end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','should_req_be_autocreated',x_progress);
    raise;
end should_req_be_autocreated;


/***************************************************************************
 *
 *  Procedure:  launch_req_line_processing
 *
 *  Description:  This process gets the req lines available for
 *      autocreate either belonging to the req or all
 *      the ones in the req pool. This depends on whether
 *      whether a req_header_id was passed into the
 *      workflow.
 *
 **************************************************************************/
procedure launch_req_line_processing(itemtype  IN   VARCHAR2,
                                     itemkey   IN   VARCHAR2,
                                     actid     IN   NUMBER,
                                     funcmode  IN   VARCHAR2,
                                     resultout OUT NOCOPY  VARCHAR2 ) is



x_ItemType              varchar2(20) := itemtype; /* Calling proc has same
               * item type as called proc
                 */
x_ItemKey               varchar2(60) := null;
x_workflow_process      varchar2(40) := 'REQ_LINE_PROCESSING';
x_seq_for_item_key  varchar2(25)  := null; --Bug14305923
x_req_header_id     number;
x_req_line_id     number;
x_group_id    number;
x_org_id    number;
x_progress          varchar2(300);


/* Declare cursor to get all the req lines for the req
 * passed into the workflow.
 */

/* Bug# 1121317: kagarwal
** Desc: The cursor c1 in launch_req_line_processing() of POXWATCB.pls
** is fetching the requisition_line_id using the po_requisition_lines_inq_v
** view which is a join of more than 20 tables. The cursor has been modified
** to improve performance.
*/

/* Bug1366981
   The following query is still performance intensive and so commenting
   the same and change the cursor c1 to increase the performance

cursor c1 is           x_req_header_id is a parameter
     select pol.requisition_line_id
       from po_requisition_headers poh, po_requisition_lines pol
      where line_location_id                is null           AND
      nvl(pol.cancel_flag,'N')            ='N'    AND
      nvl(pol.closed_code,'OPEN')     <> 'FINALLY CLOSED' AND
            nvl(modified_by_agent_flag,'N') ='N'          AND
            source_type_code        = 'VENDOR'          AND
      authorization_status      = 'APPROVED'  AND
      (poh.requisition_header_id      = x_req_header_id
       OR
       x_req_header_id is null)       AND
      poh.requisition_header_id = pol.requisition_header_id
   order by poh.requisition_header_id, line_num;
*/
/*Bug 1366981
  To handle  the x_req_header_id null case and to ensure the
  index on requisition_header_id is used,modified the cursor c1
  to use  a union all  and thereby increase performance.
 */

/*The first part of this query cause performance hit for bug 10243160. Re-write the cursor
cursor c1 is                            -- x_req_header_id is a parameter
select pol.requisition_line_id
  from po_requisition_headers_all poh,    -- <R12 MOAC>
       po_requisition_lines pol
 where x_req_header_id is null                            AND
      line_location_id                is null            AND
      nvl(pol.cancel_flag,'N')            ='N'            AND
      nvl(pol.closed_code,'OPEN')    <> 'FINALLY CLOSED' AND
      nvl(modified_by_agent_flag,'N') ='N'                AND
      source_type_code                = 'VENDOR'          AND
      authorization_status            = 'APPROVED'        AND
      poh.requisition_header_id = pol.requisition_header_id
union all
select pol.requisition_line_id
  from po_requisition_headers_all poh,     -- <R12 MOAC>
       po_requisition_lines pol
 where x_req_header_id is not null                        AND
      poh.requisition_header_id      = x_req_header_id    AND
      line_location_id                is null            AND
      nvl(pol.cancel_flag,'N')            ='N'            AND
      nvl(pol.closed_code,'OPEN')    <> 'FINALLY CLOSED' AND
      nvl(modified_by_agent_flag,'N') ='N'                AND
      source_type_code                = 'VENDOR'          AND
      authorization_status            = 'APPROVED'        AND
      poh.requisition_header_id = pol.requisition_header_id;
*/
--Bug 10243160 start. Separate the cursor into c1 and c2. c2 is for concurrent program. It may cause performance hit.
--Use c2 only if it needs. so that reduce the overhead for regular autocreate flow.
cursor c1 is  --c1 is for autocreate flow. x_req_header_id is a parameter
select pol.requisition_line_id
  from po_requisition_headers_all poh,     -- <R12 MOAC>
       po_requisition_lines pol
 where poh.requisition_header_id      = x_req_header_id    AND
      line_location_id                is null            AND
      nvl(pol.cancel_flag,'N')            ='N'            AND
      nvl(pol.closed_code,'OPEN')    <> 'FINALLY CLOSED' AND
      nvl(modified_by_agent_flag,'N') ='N'                AND
      source_type_code                = 'VENDOR'          AND
      authorization_status            = 'APPROVED'        AND
      poh.requisition_header_id = pol.requisition_header_id
      order by pol.requisition_line_id asc;

--c2 is for concurrent program flow.
cursor c2 is
select pol.requisition_line_id
  from po_requisition_headers_all poh,    -- <R12 MOAC>
       po_requisition_lines pol
 where line_location_id                is null            AND
      nvl(pol.cancel_flag,'N')            ='N'            AND
      nvl(pol.closed_code,'OPEN')    <> 'FINALLY CLOSED' AND
      nvl(modified_by_agent_flag,'N') ='N'                AND
      source_type_code                = 'VENDOR'          AND
      authorization_status            = 'APPROVED'        AND
      poh.requisition_header_id = pol.requisition_header_id;
--end 10243160
--<CONSUME REQ DEMAND FPI START>
l_consume_req_demand_doc_id po_headers.po_header_id%type;
--sql what: get all the req lines which have the same bid/negotiation info as
--          those on the lines of the current blanket po approval workflow
--          just approved.
--sql why : This cursor fetches all these eligible requisition lines and lauches
--      start_wf_line_process one by one. This would happen only if
--      l_consume_req_demand_doc_id is not null. l_consume_req_demand_doc_id
--      is the blanket document id passed into created document workflow
--      from PO approval workflow.
--sql join: find all the blanket lines of l_consume_req_demand_doc_id,
--      equate the bid_number,bid_line_number and auction_header_id
--      of these lines to requisition lines from po_requisition_lines.
--      Also ensures these lines are not placed on another PO, they are
--      still in approved status, not modified by the buyer, source type is
--      vendor and not finally closed

CURSOR C_ConsumeReqLines is
SELECT prl.requisition_line_id
  FROM po_lines pol,
       po_requisition_lines prl,
       po_requisition_headers_all prh    -- <R12 MOAC>
 WHERE pol.po_header_id=l_consume_req_demand_doc_id
   AND prl.auction_header_id = pol.auction_header_id
   AND prl.bid_line_number = pol.bid_line_number
   AND prl.bid_number = pol.bid_number
   AND prl.line_location_id is null
   AND nvl(prl.cancel_flag,'N') ='N'
   AND nvl(prl.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND nvl(prl.modified_by_agent_flag,'N') ='N'
   AND prl.source_type_code   = 'VENDOR'
   AND prh.authorization_status = 'APPROVED'
   AND prh.requisition_header_id = prl.requisition_header_id;
--<CONSUME REQ DEMAND FPI END>
BEGIN
   /* Set org context */
   x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

   po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

   --<CONSUME REQ DEMAND FPI START>
   l_consume_req_demand_doc_id := PO_WF_UTIL_PKG.GetItemAttrNumber
          (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'CONSUME_REQ_DEMAND_DOC_ID');
   IF l_consume_req_demand_doc_id is null then
   --<CONSUME REQ DEMAND FPI END>

      /* If this create doc workflow was called from either the
       * 10sc form or web req form, they pass in a req_header_id
       * If the workflow was called by the conc. prg then there
       * may or may not be a req_header_id passed in.
       */


      x_req_header_id := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'REQ_HEADER_ID');

      /* Get the group_id for this set of requision lines. The
       * group_id determines which lines should be processed together,
       * which in this case are all the lines belonging to the one req.
       */

       select to_char(PO_WF_GROUP_S.NEXTVAL)
           into x_group_id
           from sys.dual;


       /* Store the group_id so grouping (later) only considers
        * records with this group_id.
        */

       po_wf_util_pkg.SetItemAttrNumber (itemtype     => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'GROUP_ID',
                                        avalue     => x_group_id);



      /* Open cursor and loop thru all the req lines, launching the
       * the req line processing workflow for each line.
       */

      x_progress:= '10: launch_req_line_processing: Just before opening cursor c1 ' ||
        'for req_header_id = ' || to_char(x_req_header_id);

      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      --Bug 10243160 Added IF x_req_header_id is not null  condition
      IF x_req_header_id is not null then
	      open c1;   /* Based on x_req_header_id */

	      loop
		 fetch c1 into x_req_line_id;
		 exit when c1%NOTFOUND;

		 x_progress:= '20: launch_req_line_processing: In loop,fetched c1 req_line_id = '||
		   to_char(x_req_line_id);
		 IF (g_po_wf_debug = 'Y') THEN
		    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
		 END IF;

		 /* Get the unique sequence to make sure item key will be unique */

		 select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
		   into x_seq_for_item_key
		   from sys.dual;

		 /* The item key is the req_line_id concatenated with the
		  * unique id from a seq.
		  */

		 x_ItemKey := to_char(x_req_line_id) || '-' || x_seq_for_item_key;

		 /* Launch the req line processing process
		  *
		  * Need to pass in the parent's itemtype and itemkey so as to
		  * all the parent child relationship to be setup in the called
		  * process.
		  */

		 x_progress:= '30: launch_req_line_processing: Just about to launch '||
		 ' start_wf_line_process with: called_item_type = ' || x_ItemType
		  || '/ ' || 'called_item_key = ' || x_ItemKey || '/ ' ||
			       'group_id = ' || to_char(x_group_id);

		 IF (g_po_wf_debug = 'Y') THEN
		    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
		 END IF;

		 po_autocreate_doc.start_wf_line_process (x_ItemType,
					      x_ItemKey,
					      x_workflow_process,
			      x_group_id,
			      x_req_header_id,
			      x_req_line_id,
			      itemtype,
			      itemkey);

	      end loop;
	      close c1;
      -- Bug 10243160. make use of c2 for concurrent program
      ELSE --x_requesition_header_id is null
                open c2;
                loop
                 fetch c2 into x_req_line_id;
                 exit when c2%NOTFOUND;

                 x_progress:= '21: launch_req_line_processing: In loop,fetched c2 req_line_id = '||
                 to_char(x_req_line_id);
                 IF (g_po_wf_debug = 'Y') THEN
                    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
                 END IF;

               /* Get the unique sequence to make sure item key will be unique */

                 select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
                 into x_seq_for_item_key
                 from sys.dual;

               /* The item key is the req_line_id concatenated with the
                * unique id from a seq.
                */

               x_ItemKey := to_char(x_req_line_id) || '-' || x_seq_for_item_key;

               /* Launch the req line processing process
                *
                * Need to pass in the parent's itemtype and itemkey so as to
                * all the parent child relationship to be setup in the called
                * process.
                */

               x_progress:= '31: launch_req_line_processing: Just about to launch '||
               ' start_wf_line_process with: called_item_type = ' || x_ItemType
                || '/ ' || 'called_item_key = ' || x_ItemKey || '/ ' ||
                             'group_id = ' || to_char(x_group_id);

               IF (g_po_wf_debug = 'Y') THEN
                  po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
               END IF;

               po_autocreate_doc.start_wf_line_process (x_ItemType,
                                            x_ItemKey,
                                            x_workflow_process,
                            x_group_id,
                            x_req_header_id,
                            x_req_line_id,
                            itemtype,
                            itemkey);

             end loop;
             close c2;
      END IF;
      resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

      x_progress:= '40:launch_req_line_processing: result = ACTIVITY_PERFORMED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

   --<CONSUME REQ DEMAND FPI START>
   ELSE  --if l_consume_req_demand_doc_id is not null

    --Get the group_id for this set of requision lines. The
      --group_id determines which lines should be processed together,
      --which in this case are all the lines belonging to the one req.

      SELECT to_char(PO_WF_GROUP_S.NEXTVAL)
         INTO x_group_id
         FROM sys.dual;

      -- Store the group_id so grouping (later) only considers
      -- records with this group_id.
        PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype     => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'GROUP_ID',
                                     avalue     => x_group_id);

    -- Open cursor and loop thru all the req lines, launching the
      --the req line processing workflow for each line.

    x_progress:= '10: launch_req_line_processing: Just before opening '
         ||'cursor C_ConsumeReqLines '
         || 'for l_consume_req_demand_doc_id='
         || to_char(l_consume_req_demand_doc_id);

    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    OPEN C_ConsumeReqLines;

    LOOP
          FETCH C_ConsumeReqLines into x_req_line_id;
          EXIT WHEN C_ConsumeReqLines%NOTFOUND;

          x_progress:= '20: launch_req_line_processing: In loop,fetched'
           ||' C_ConsumeReqLines req_line_id = '
           || to_char(x_req_line_id);
          IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;

          --Get the unique sequence to make sure item key will be unique

    SELECT to_char(PO_WF_ITEMKEY_S.NEXTVAL)
      INTO x_seq_for_item_key
      FROM sys.dual;

          --The item key is the req_line_id concatenated with the
          --unique id from a seq.

          x_ItemKey := to_char(x_req_line_id) || '-' || x_seq_for_item_key;

          --Launch the req line processing process
          --Need to pass in the parent's itemtype and itemkey so as to
          --all the parent child relationship to be setup in the called
          --process.

           x_progress:= '30: launch_req_line_processing: Just about to launch '
      || ' start_wf_line_process with: called_item_type = '
      || x_ItemType || '/ ' || 'called_item_key = '
      || x_ItemKey || '/ ' || 'group_id = '
      || to_char(x_group_id);

           IF (g_po_wf_debug = 'Y') THEN
              po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
           END IF;

           po_autocreate_doc.start_wf_line_process (x_ItemType,
                                       x_ItemKey,
                                       x_workflow_process,
                 x_group_id,
                 x_req_header_id,
                 x_req_line_id,
                 itemtype,
                 itemkey);

        END LOOP;
        CLOSE C_ConsumeReqLines;

        resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

        x_progress:='40:launch_req_line_processing: result =ACTIVITY_PERFORMED';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;
   END IF; --l_consume_req_demand_doc_id is null--
   --<CONSUME REQ DEMAND FPI END>

exception
  when others then
    if l_consume_req_demand_doc_id is not null then
      close c1;
    else
      CLOSE C_ConsumeReqLines;
    end if;
    wf_core.context('po_autocreate_doc','launch_req_line_processing',x_progress);
    raise;
end launch_req_line_processing;

/***************************************************************************
 *
 *  Procedure:  start_wf_line_process
 *
 *  Description:  Generates the itemkey, sets up the Item Attributes,
 *      then starts the workflow process.
 *
 **************************************************************************/
procedure start_wf_line_process ( ItemType            VARCHAR2,
                                  ItemKey             VARCHAR2,
                                  workflow_process    VARCHAR2,
                group_id    NUMBER,
              req_header_id   NUMBER,
          req_line_id   NUMBER,
          parent_itemtype VARCHAR2,
          parent_itemkey  VARCHAR2) is


x_progress    varchar2(300);

begin

  x_progress := '10: start_wf_line_process: Called with item_type = ' || ItemType ||
     '/ '|| 'item_key = ' || ItemKey;
  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* If a process is passed then it will be run
   * If a process is not passed then the selector function defined in
   * item type will be determine which process to run
   */

  IF  (ItemType    is NOT NULL ) AND
      (ItemKey     is NOT NULL)  AND
      (req_line_id is NOT NULL ) then
        wf_engine.CreateProcess(itemtype => itemtype,
                                itemkey  => itemkey,
                                process  => workflow_process );

        x_progress := '20: start_wf_line_process: Just after CreateProcess';
  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

        /* Initialize workflow item attributes */

        po_wf_util_pkg.SetItemAttrNumber (itemtype     => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'GROUP_ID',
                                     avalue     => group_id);

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'REQ_LINE_ID',
                                     avalue     => req_line_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'REQ_HEADER_ID',
                                     avalue     => req_header_id);


  /* Need to set the parent child relationship between processes */

  wf_engine.SetItemParent (itemtype        => itemtype,
         itemkey         => itemkey,
         parent_itemtype => parent_itemtype,
         parent_itemkey  => parent_itemkey,
         parent_context  => NULL);


        /* Kick off the process */

        x_progress:= '30: start_wf_line_process: Kicking off StartProcess';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        wf_engine.StartProcess(itemtype => itemtype,
                               itemkey  => itemkey );

    end if;

exception
  when others then
   x_progress:= '40: start_wf_line_process: IN EXCEPTION';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;
   raise;
end start_wf_line_process;


/***************************************************************************
 *
 *  Procedure:  get_req_info
 *
 *  Description:  Gets all the necessary info from the req line
 *
 *
 **************************************************************************/
procedure get_req_info (itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 ) is

x_req_line_id       number;
x_suggested_buyer_id    number;
x_suggested_vendor_name   po_requisition_lines_all.suggested_vendor_name%type;
x_suggested_vendor_location     varchar2(240);

/* Bug 2577940 The vendor id and vendor site id should also be populated from Req line  */
x_suggested_vendor_id           po_requisition_lines_all.vendor_id%type;
x_suggested_vendor_site_id      po_requisition_lines_all.vendor_site_id%type;
/* Bug 2577940 */

x_source_doc_type_code    varchar2(25);
x_source_doc_po_header_id number;
x_source_doc_line_num   number;
x_rfq_required_flag   varchar2(1);
x_on_rfq_flag     varchar2(1);
x_item_id     number;
x_category_id     number;
x_currency_code     varchar2(15);
x_rate_type     varchar2(30);
x_rate_date     date;
x_rate        number;
x_org_id      number;
x_pcard_id      number;
x_pcard_flag      varchar2(1);
x_progress          varchar2(300);
x_organization_id               number;
x_catalog_type      varchar2(40);
/* Supplier Pcard FPH */
x_vendor_id     number;
x_vendor_site_id    number;

x_ga_flag                       varchar2(1) := 'N'; -- FPI GA
l_job_id                        number := null;  -- <SERVICES FPJ>
l_labor_req_line_id             po_requisition_lines_all.labor_req_line_id%TYPE;  -- <SERVICES FPJ>

begin

  x_req_line_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'REQ_LINE_ID');

  /* Get the necessary info from the req line */

  select pls.org_id,
   pls.suggested_buyer_id,
   pls.suggested_vendor_name,
         pls.suggested_vendor_location,
     pls.document_type_code,
         pls.blanket_po_header_id,
   pls.blanket_po_line_num,
         pls.rfq_required_flag,
   pls.on_rfq_flag,
         pls.item_id,
   pls.category_id,
         pls.currency_code,
   pls.rate_type,
   pls.rate_date,
   pls.rate,
   pls.pcard_flag,
   /* Supplier PCard FPH */
   --16027770
   decode(pls.pcard_flag, 'Y', phs.pcard_id,'S',nvl((po_pcard_pkg.get_valid_pcard_id(-99999,pls.vendor_id,pls.vendor_site_id)),-99999),'N', null),
         pls.destination_organization_id,
   pls.catalog_type,
         pls.vendor_id, /* Bug 2577940 */
         pls.vendor_site_id,
         pls.job_id,  -- <SERVICES FPJ>
         pls.labor_req_line_id  -- <SERVICES FPJ>
    into x_org_id,
   x_suggested_buyer_id,
         x_suggested_vendor_name,
         x_suggested_vendor_location,
         x_source_doc_type_code,
   x_source_doc_po_header_id,
   x_source_doc_line_num,
   x_rfq_required_flag,
   x_on_rfq_flag,
         x_item_id,
   x_category_id,
   x_currency_code,
   x_rate_type,
   x_rate_date,
   x_rate,
   x_pcard_flag,
   x_pcard_id,
         x_organization_id,
   x_catalog_type,
         x_suggested_vendor_id,
         x_suggested_vendor_site_id,
         l_job_id,  -- <SERVICES FPJ>
         l_labor_req_line_id  -- <SERVICES FPJ>
    from po_requisition_headers_all phs,   -- <R12 MOAC>
         po_requisition_lines pls
   where pls.requisition_line_id = x_req_line_id
     and phs.requisition_header_id = pls.requisition_header_id;


  x_progress:= '10: get_req_info: Just after executing sql stmt with req_line_id ' ||
    to_char(x_req_line_id);
  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  /* Set the item attributes */

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'ORG_ID',
                               avalue     => x_org_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SUGGESTED_BUYER_ID',
                               avalue     => x_suggested_buyer_id);

  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'SUGGESTED_VENDOR_NAME',
                             avalue     => x_suggested_vendor_name);

  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'SUGGESTED_VENDOR_LOCATION',
                             avalue     => x_suggested_vendor_location);
  /* Bug 2577940 */
  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'SUGGESTED_VENDOR_ID',
                              avalue     => x_suggested_vendor_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SUGGESTED_VENDOR_SITE_ID',
                               avalue     => x_suggested_vendor_site_id);
  /* Bug 2577940 */
  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'SOURCE_DOCUMENT_TYPE_CODE',
                             avalue     => x_source_doc_type_code);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SOURCE_DOCUMENT_ID',
                               avalue     => x_source_doc_po_header_id);

  /* FPI GA Start */
  /* Get the global agreement flag */

   if x_source_doc_po_header_id is not null then
     select global_agreement_flag
     into x_ga_flag
     from po_headers_all
     where po_header_id = x_source_doc_po_header_id;
   end if;

     po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOC_GA_FLAG',
                                       avalue     => x_ga_flag);


  /* FPI GA End */

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SOURCE_DOCUMENT_LINE_NUM',
                               avalue     => x_source_doc_line_num);

  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'RFQ_REQUIRED_FLAG',
                             avalue     => x_rfq_required_flag);

  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'ON_RFQ_FLAG',
                             avalue     => x_on_rfq_flag);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'ITEM_ID',
                               avalue     => x_item_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CATEGORY_ID',
                               avalue     => x_category_id);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'ORGANIZATION_ID',
                               avalue     => x_organization_id);

  -- Bug 587589, lpo, 12/11/97
  -- Added the follow 4 lines to populate the currency_code, rate_type, rate_date and rate.
  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'CURRENCY_CODE',
                             avalue     => x_currency_code);

  po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'RATE_TYPE',
                             avalue     => x_rate_type);

  po_wf_util_pkg.SetItemAttrDate (itemtype   => itemtype,
                             itemkey    => itemkey,
                             aname      => 'RATE_DATE',
                             avalue     => x_rate_date);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'RATE',
                               avalue     => x_rate);

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'PCARD_ID',
                               avalue     => x_pcard_id);

  po_wf_util_pkg.SetItemAttrText  (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CATALOG_TYPE',
                               avalue     => x_catalog_type);
  -- Bug 587589, lpo, 12/11/97

  --<Shared Proc FPJ START>
  --Set the PURCHASING_ORG_ID workflow item attribute
  set_purchasing_org_id(itemtype,
      itemkey,
      x_org_id,
      x_suggested_vendor_site_id);
  --<Shared Proc FPJ END>

  -- <SERVICES FPJ START>
  po_wf_util_pkg.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'JOB_ID',
                                   avalue   => l_job_id);

  po_wf_util_pkg.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'LABOR_REQ_LINE_ID',
                                   avalue   => l_labor_req_line_id);
  -- <SERVICES FPJ END>

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  x_progress:= '20: get_req_info: result = ACTIVITY_PERFORMED';
  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_req_info',x_progress);
    raise;
end get_req_info;


/***************************************************************************
 *
 *  Procedure:  rfq_required_check
 *
 *  Description:  Checks if an this req line should  be on an RFQ before
 *      it can be autocreated
 *
 **************************************************************************/
procedure rfq_required_check (itemtype   IN   VARCHAR2,
                              itemkey    IN   VARCHAR2,
                              actid      IN   NUMBER,
                              funcmode   IN   VARCHAR2,
                              resultout  OUT NOCOPY  VARCHAR2 ) is

x_org_id    number;
x_rfq_required_flag varchar2(1);
x_on_rfq_flag   varchar2(1);
x_warn_rfq_required varchar2(1);
x_progress        varchar2(300);


begin

  /* Set org context */
  x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');
  po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

  /* Get rfq check flags */

  x_rfq_required_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RFQ_REQUIRED_FLAG');

  x_on_rfq_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ON_RFQ_FLAG');

  /* In 10sc this profile option will just warn the user not stop him
   * from going ahead. We could potentially send a notification to the
   * requestor (preparer) here and wait for a response that its ok
   * to go ahead, but for now we'll just fail the req line.
   */

  fnd_profile.get('PO_AUTOCREATE_WARN_RFQ_REQUIRED', x_warn_rfq_required);

  if ((x_warn_rfq_required = 'Y') AND
      (x_rfq_required_flag = 'Y') AND
      ((x_on_rfq_flag is NULL) OR (x_on_rfq_flag = 'N'))) then
    resultout := wf_engine.eng_completed || ':' ||  'Y';

    x_progress:= '10: rfq_required_check: result = Y';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  else
    resultout := wf_engine.eng_completed || ':' ||  'N';

    x_progress:= '20: rfq_required_check: result = N';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  end if;


exception
  when others then
    wf_core.context('po_autocreate_doc','rfq_required_check',x_progress);
    raise;
end rfq_required_check;


/***************************************************************************
 *
 *  Procedure:  get_supp_info_for_acrt
 *
 *  Description:  Gets the suggested supplier/site info from the req line
 *      and makes sure they are valid.
 *
 **************************************************************************/
procedure get_supp_info_for_acrt (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 ) is

x_suggested_vendor_name  po_requisition_lines_all.suggested_vendor_name%type;
x_suggested_vendor_site  varchar2(240);

/* Bug 2577940 */
x_suggested_vendor_id      number;
x_suggested_vendor_site_id number;
x_vendor                   po_requisition_lines_all.suggested_vendor_name%type;
x_vendor_site              varchar2(240);
/* Bug 2577940 */

x_valid_vendor     varchar2(1);
x_valid_vendor_site  varchar2(1);
x_vendor_id    number;
x_vendor_site_id   number;
x_progress         varchar2(300);
x_org_id                 number;

begin

  /* Set the org context. */

  x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

  po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

  x_suggested_vendor_name := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_NAME');

  x_suggested_vendor_site := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_LOCATION');
  /* Bug 2577940 */
  x_suggested_vendor_id := po_wf_util_pkg.GetItemAttrNumber
                                     (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'SUGGESTED_VENDOR_ID');

  x_suggested_vendor_site_id := po_wf_util_pkg.GetItemAttrNumber
                                           (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'SUGGESTED_VENDOR_SITE_ID');
  /* Bug 2577940 */

  /* Here we should do some validation since the req form doesn't validate
   * the vendor or vendor site against an lov.
   * Actually the lov for the source doc on the req line does have the suggested
   * vendor as part of the where clause. So the source doc check would have failed
   * since it would have been null for an invalid supplier. But no harm double
   * checking here. We need to get the suggested vendor/vendor_site id's anyway
   * since the req line doesn't store them.
   */

  /* Check to see if the vendor on the req line is a valid one */

  x_vendor               :=  x_suggested_vendor_name;
  x_vendor_site          := x_suggested_vendor_site;
  x_vendor_id            := x_suggested_vendor_id;
  x_vendor_site_id       := x_suggested_vendor_site_id;


if x_suggested_vendor_id is not null then

   /* Bug 2577940 if the id is provided, then it should take the precedence */

   begin
     select 'Y',
            vendor_name
     into x_valid_vendor,
          x_vendor
     from po_suppliers_val_v
     where vendor_id = x_suggested_vendor_id;
   exception
     when NO_DATA_FOUND then
       x_valid_vendor := 'N';
   end;

  /* If the vendor is not valid then we exit right here. */

   if (x_valid_vendor ='N') then
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '10: get_supp_info_for_acrt: result = N ' ||
                   'because the supplier id is invalid';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     return;
    end if;

else  /* Bug 2577940 */

   /* If the id is null the name will be used */

   begin
     select 'Y',
      vendor_id
       into x_valid_vendor,
      x_vendor_id
       from po_suppliers_val_v
      where vendor_name = x_suggested_vendor_name;
   exception
     when NO_DATA_FOUND then
       x_valid_vendor := 'N';
   end;

  /* If the vendor is not valid then we exit right here. */

   if (x_valid_vendor ='N') then
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '20: get_supp_info_for_acrt: result = N ' ||
       'because the supplier is null or invalid';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     return;
    end if;

end if; /* Bug 2577940 */

   /* If we get to this point then the vendor is valid, now
    * lets check for vendor site.
    */

if x_suggested_vendor_site_id is not null then  /* Bug 2577940 */

  /* If the id is provided already then it should take the precedence */

 begin

     --<Shared Proc FPJ>
     --Changed the query to go against po_vendor_sites_all
     --instead of po_supplier_sites_val_v.
     select 'Y',
            vendor_site_code
       into x_valid_vendor_site,
            x_vendor_site
       from po_vendor_sites_all
      where vendor_id = x_vendor_id
        and vendor_site_id = x_suggested_vendor_site_id
        --<Shared Proc FPJ START>
        and purchasing_site_flag = 'Y'
        and NVL(rfq_only_site_flag, 'N') = 'N'
        and sysdate < NVL(inactive_date, sysdate + 1);
        --<Shared Proc FPJ END>
    exception
      when NO_DATA_FOUND then
       x_valid_vendor_site := 'N';
    end;

  /* If the vendor site id is not valid then we exit right here. */

   if (x_valid_vendor_site ='N') then
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '30: get_supp_info_for_acrt: result = N ' ||
                   'becuase the supplier site id is invalid';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     return;
   end if;

else  /* Bug 2577940 */

  begin
     select 'Y',
      vendor_site_id
       into x_valid_vendor_site,
      x_vendor_site_id
       from po_supplier_sites_val_v
      where vendor_id = x_vendor_id
        and vendor_site_code = x_suggested_vendor_site;
    exception
      when NO_DATA_FOUND then
       x_valid_vendor_site := 'N';
    end;

  /* If the vendor site is not valid then we exit right here. */

   if (x_valid_vendor_site ='N') then
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '40: get_supp_info_for_acrt: result = N ' ||
       'becuase the supplier site  is null or invalid';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     return;
   end if;

end if; /* Bug 2577940 */

   /* If we get here then both the vendor and vendor site are valid. */

   po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'SUGGESTED_VENDOR_ID',
                                avalue     => x_vendor_id);

   po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'SUGGESTED_VENDOR_SITE_ID',
                                avalue     => x_vendor_site_id);

   /* Bug 2577940  The correct names also should be set */
   po_wf_util_pkg.SetItemAttrText   (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'SUGGESTED_VENDOR_NAME',
                                avalue      => x_vendor);

   po_wf_util_pkg.SetItemAttrText   (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'SUGGESTED_VENDOR_LOCATION',
                                avalue      => x_vendor_site);
   /* Bug 2577940 */

   resultout := wf_engine.eng_completed || ':' ||  'Y';

   x_progress:= '50: get_supp_info_for_acrt: result = Y';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_supp_info_for_acrt',x_progress);
    raise;
end get_supp_info_for_acrt;


/***************************************************************************
 *
 *  Procedure:  is_source_doc_info_ok
 *
 *  Description:  This checks to make sure we have source document
 *      reference information
 *
 **************************************************************************/
procedure is_source_doc_info_ok (itemtype   IN   VARCHAR2,
                           itemkey    IN   VARCHAR2,
                                 actid      IN   NUMBER,
                                 funcmode   IN   VARCHAR2,
                                 resultout  OUT NOCOPY  VARCHAR2 ) is


x_source_doc_type_code    varchar2(25);
x_source_doc_po_header_id number;
x_source_doc_line_num   number;
x_progress                varchar2(300);

--Bug 2745549
l_source_doc_ok                 varchar2(1) := 'N';

begin

      /* When the source doc and source line was put onto the req line
       * it was all validated to make sure it was ok.
       * Ie. docs were within effectivity dates, not canelled or closed etc.
       * So not doing the check here again.
       * We just need to make sure the source_doc_type,  source_doc  and
       * source_line have been populated.
       */

       x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
            (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                     aname      => 'SOURCE_DOCUMENT_TYPE_CODE');

       x_source_doc_po_header_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOCUMENT_ID');

       x_source_doc_line_num := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOCUMENT_LINE_NUM');

     if ((x_source_doc_type_code is NULL)     or
          (x_source_doc_po_header_id is NULL) or
    (x_source_doc_line_num is NULL))    then
        resultout := wf_engine.eng_completed || ':' ||  'N';

        x_progress:= '10: is_source_doc_info_ok: result = N';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     --<Bug 2745549 mbhargav START>
     --Do not create PO if the referenced GA/Blanket is not valid
     --i.e. is Cancelled or Finally Closed
     elsif x_source_doc_type_code = 'BLANKET' THEN

         is_ga_still_valid(x_source_doc_po_header_id, l_source_doc_ok);

         IF l_source_doc_ok = 'N' THEN
            resultout := wf_engine.eng_completed || ':' ||  'N';

            x_progress:= '20: is_source_doc_info_ok: result = N';
         ELSE
            resultout := wf_engine.eng_completed || ':' ||  'Y';

            x_progress:= '20: is_source_doc_info_ok: result = Y';
         END IF;

         IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
         END IF;

     --<Bug 2745549 mbhargav END>

     else
        resultout := wf_engine.eng_completed || ':' ||  'Y';

        x_progress:= '30: is_source_doc_info_ok: result = Y';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','is_source_doc_info_ok',x_progress);
    raise;
end is_source_doc_info_ok;

/***************************************************************************
 *
 *  Procedure:  does_contract_exist
 *
 *  Description:  Check if use_contract_flag is true and if contract
 *      for the vendor and vendor site exists.  This procedure
 *      is added for self service purchasing.
 *                      this is also validating the expiration of the contract.
 *
 **************************************************************************/
procedure does_contract_exist(itemtype   IN   VARCHAR2,
                          itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 ) is

x_contract_id       number;
x_supplier_id       number;
x_supplier_site_id  number;

x_use_contract_flag varchar2(1);
x_item_currency      PO_REQUISITION_LINES_ALL.currency_code%TYPE;

x_progress                varchar2(300) := '000';

-- <GC FPJ START>

l_gc_flag            PO_HEADERS_ALL.global_agreement_flag%TYPE;
l_currency           PO_HEADERS_ALL.currency_code%TYPE;
l_base_currency      PO_HEADERS_ALL.currency_code%TYPE;
l_rate               PO_HEADERS_ALL.rate%TYPE;
l_rate_date          PO_HEADERS_ALL.rate_date%TYPE;
l_rate_type          PO_HEADERS_ALL.rate_type%TYPE;

-- bug4198095
-- No need to match local contract anymore after R12
l_current_org_id     PO_HEADERS_ALL.org_id%TYPE;

-- SQL What: Find available contract that is valid. First it
--           finds local contracts; if none exists then find global contracts.
--           Also, latest contract takes priority
-- SQL Why:  Need to see if any contract out there that can be attached to
--           the req line, if the req line does not already have a source
--           document

CURSOR c_contract_currency IS
  SELECT POH.po_header_id,
         POH.global_agreement_flag,
         POH.currency_code
  FROM   po_headers_all POH
  WHERE  POH.vendor_id = x_supplier_id
  AND    POH.currency_code = nvl(x_item_currency, l_base_currency)
  AND    POH.type_lookup_code = 'CONTRACT'
  /* R12 GCPA
  + If Profile ALLOW_REFERENCING_CPA_UNDER_AMENDMENT is Y, then we can refer any Contract Which is approved Once
  + Else Contract should be in APPROVED state  */
  AND    ( (NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') = 'Y'
           AND POH.Approved_Date Is Not Null
	    )
	 or (  POH.authorization_status = 'APPROVED' )
	 )
  AND    NVL(POH.cancel_flag, 'N') = 'N'
  AND    NVL(POH.frozen_flag, 'N') = 'N'
  AND    NVL(POH.closed_code, 'OPEN') = 'OPEN'
  AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(POH.start_date), SYSDATE - 1)
                        AND     NVL(TRUNC(POH.end_date),   SYSDATE + 1)
  AND    POH.global_agreement_flag = 'Y'
  /* R12 GCPA
  + Vendor Site validation needs to be skipped if Enable All Sites on Contracts is Set to Y.   */
  AND    EXISTS (SELECT 1
              FROM   po_ga_org_assignments PGOA
              WHERE  PGOA.po_header_id = POH.po_header_id
              AND    PGOA.vendor_site_id = decode(Nvl(poh.Enable_All_Sites,'N'),'Y',PGOA.vendor_site_id, x_supplier_site_id)
              AND    PGOA.organization_id = l_current_org_id
              AND    PGOA.enabled_flag = 'Y')
  ORDER BY POH.creation_date desc;

CURSOR c_contract IS
  SELECT POH.po_header_id,
         POH.global_agreement_flag,
         POH.currency_code
  FROM   po_headers_all POH
  WHERE  POH.vendor_id = x_supplier_id
  AND    POH.type_lookup_code = 'CONTRACT'
  /* R12 GCPA
  + If Profile ALLOW_REFERENCING_CPA_UNDER_AMENDMENT is Y, then we can refer any Contract Which is approved Once
  + Else Contract should be in APPROVED state
  */
  AND    ( (NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') = 'Y'
           AND POH.Approved_Date Is Not Null
	    )
	 or (  POH.authorization_status = 'APPROVED' )
	 )
  AND    NVL(POH.cancel_flag, 'N') = 'N'
  AND    NVL(POH.frozen_flag, 'N') = 'N'
  AND    NVL(POH.closed_code, 'OPEN') = 'OPEN'
  AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(POH.start_date), SYSDATE - 1)
                        AND     NVL(TRUNC(POH.end_date),   SYSDATE + 1)
  AND    POH.global_agreement_flag = 'Y'
  /* R12 GCPA
  + Vendor Site validation needs to be skipped if Enable All Sites on Contracts is Set to Y.    */
  AND    EXISTS (SELECT 1
              FROM   po_ga_org_assignments PGOA
              WHERE  PGOA.po_header_id = POH.po_header_id
              AND    PGOA.vendor_site_id = decode(Nvl(poh.Enable_All_Sites,'N'),'Y',PGOA.vendor_site_id, x_supplier_site_id)
              AND    PGOA.organization_id = l_current_org_id
              AND    PGOA.enabled_flag = 'Y')
  ORDER BY POH.creation_date desc;

-- <GC FPJ END>

begin

   x_supplier_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SUGGESTED_VENDOR_ID');

   x_supplier_site_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SUGGESTED_VENDOR_SITE_ID');

   x_use_contract_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'USE_CONTRACT_FLAG');

   x_item_currency     := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'CURRENCY_CODE');

   if nvl(x_use_contract_flag, 'N') <> 'Y' then

        resultout := wf_engine.eng_completed || ':' ||  'N';

        return;

   end if;

   -- <GC FPJ START>

   x_progress := '001';

   -- The original query has been moved to the declare section as a cursor.
   l_base_currency := PO_CORE_S2.get_base_currency;
   l_current_org_id := PO_GA_PVT.get_current_org;

   OPEN c_contract_currency;

   -- Only take the first contract


   FETCH c_contract_currency INTO x_contract_id,
                         l_gc_flag,
                         l_currency;

   IF (c_contract_currency%NOTFOUND) THEN
       x_contract_id := NULL;
   END IF;

   CLOSE c_contract_currency;

   if (x_contract_id IS NULL) then

        OPEN c_contract;

  FETCH c_contract INTO x_contract_id,
                         l_gc_flag,
                         l_currency;

        IF (c_contract%NOTFOUND) THEN
            x_contract_id := NULL;
        END IF;

        CLOSE c_contract;
   end if;

   x_progress := '002';

   --<Bug 3079146>
   IF (x_contract_id IS NOT NULL AND l_gc_flag = 'Y') THEN


           -- Since a PO line referencing a gloabal contract must be in a PO
           -- having the same currency, we need to derive the rate information
           -- if the global contract is using a foreign currency. Contract
           -- reference is not allowed if currency rate is not defined.

           PO_GA_PVT.get_currency_info
           (  p_po_header_id  => x_contract_id,
                 x_currency_code => l_currency,
                 x_rate_type     => l_rate_type,
                 x_rate_date     => l_rate_date,
                 x_rate          => l_rate
           );

           IF (l_rate IS NULL) THEN
               x_contract_id := NULL;
           ELSE    -- rate is defined


             -- Bug 17256040 .Only if requisition currency is not same as contract currency, get the rate information  from contract
             IF (l_currency <> x_item_currency)  THEN

               po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'CURRENCY_CODE',
                                      avalue     => l_currency);

               po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'RATE_TYPE',
                                      avalue     => l_rate_type);

               po_wf_util_pkg.SetItemAttrDate (itemtype   => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'RATE_DATE',
                                      avalue     => l_rate_date);

               po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'RATE',
                                      avalue     => l_rate);
             END IF;

           END IF;  -- l_rate is null

       IF (x_contract_id IS NOT NULL) THEN
           po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'SOURCE_DOC_GA_FLAG',
                                  avalue     => l_gc_flag);
       END IF;  -- x_contract_id is not null
   END IF; -- l_gc_flag = 'Y'

   -- <GC FPJ END>

   if x_contract_id is not null then

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CONTRACT_ID',
                               avalue     => x_contract_id);
        po_wf_util_pkg.SetItemAttrText( itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SOURCE_DOCUMENT_TYPE_CODE',
                               avalue     => 'CONTRACT');

        -- <GC FPJ START>
        -- Since the ref is a contract and is stored in attr CONTRACT_ID,
        -- null out the reference in SOURCE_DOCUMENT_ID

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SOURCE_DOCUMENT_ID',
                               avalue     => NULL);

        -- <GC FPJ END>

        resultout := wf_engine.eng_completed || ':' ||  'Y';

   else

        resultout := wf_engine.eng_completed || ':' ||  'N';

   end if;

exception

  when others then

    -- <GC FPJ START>
    IF (c_contract%ISOPEN) THEN
        CLOSE c_contract;
    END IF;
    -- <GC FPJ END>

    wf_core.context('po_autocreate_doc','does_contract_exist',x_progress);
    raise;

end does_contract_exist;

/***************************************************************************
 *
 *  Procedure:  is_req_pcard_line
 *
 *  Description:  For Pcard req line, it doen't need source doc.
 *
 **************************************************************************/
procedure is_req_pcard_line (itemtype   IN   VARCHAR2,
                             itemkey    IN   VARCHAR2,
                             actid      IN   NUMBER,
                             funcmode   IN   VARCHAR2,
                             resultout  OUT NOCOPY  VARCHAR2 ) is


x_pcard_id  number;

x_progress                varchar2(300);

begin

     x_pcard_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                               itemkey    => itemkey,
                                 aname      => 'PCARD_ID');


     if (x_pcard_id is NULL)    then
        resultout := wf_engine.eng_completed || ':' ||  'N';

        x_progress:= '10: is_req_pcard_line: result = N';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     else
        resultout := wf_engine.eng_completed || ':' ||  'Y';

        x_progress:= '20: is_req_pcard_line: result = Y';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','is_req_pcard_line',x_progress);
    raise;
end is_req_pcard_line;

/***************************************************************************
 *
 *  Procedure:  get_buyer_from_req_line
 *
 *  Description:  Gets the suggested buyer on the req line
 *
 *
 **************************************************************************/
procedure get_buyer_from_req_line (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 ) is

x_suggested_buyer_id  number;
x_progress              varchar2(300);

-- bug2821542
l_validate_result       VARCHAR2(1) := FND_API.G_TRUE;

begin

  x_suggested_buyer_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_BUYER_ID');

-- bug2821542
  IF (x_suggested_buyer_id IS NOT NULL) THEN
    validate_buyer(p_agent_id => x_suggested_buyer_id,
                   x_result   => l_validate_result);
  END IF;

  if (x_suggested_buyer_id  is NULL OR
      l_validate_result = FND_API.G_FALSE) then  -- bug2821542

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_FAILED';

      x_progress:= '10: get_buyer_from_req_line: result = ACTION_FAILED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

  else
      resultout := wf_engine.eng_completed || ':' ||  'ACTION_SUCCEEDED';

      x_progress:= '20: get_buyer_from_req_line: result = ACTION_SUCCEEDED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

 end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_buyer_from_req_line',x_progress);
    raise;
end get_buyer_from_req_line;


/***************************************************************************
 *
 *  Procedure:  get_buyer_from_item
 *
 *  Description:  Gets the buyer from the item master based on the
 *      item on the requisition line.
 *
 **************************************************************************/
procedure get_buyer_from_item (itemtype   IN   VARCHAR2,
                               itemkey    IN   VARCHAR2,
                               actid      IN   NUMBER,
                               funcmode   IN   VARCHAR2,
                               resultout  OUT NOCOPY  VARCHAR2 ) is

x_item_id number;
x_buyer_id  number;
x_inv_org_id  number;
x_org_id  number;
x_progress      varchar2(300);

-- bug2821542
l_validate_result       VARCHAR2(1) := FND_API.G_TRUE;
l_purchasing_org_id     PO_HEADERS_ALL.org_id%TYPE; --<Shared Proc FPJ>

begin

  x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

--<Shared Proc FPJ START>
  l_purchasing_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PURCHASING_ORG_ID');
--<Shared Proc FPJ END>
  x_item_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ITEM_ID');

  --<Shared Proc FPJ>
  --Get default inventory org of purchasing org from the fsp_all table.

  select inventory_organization_id
    into x_inv_org_id
    from financials_system_params_all
     where org_id = l_purchasing_org_id;

  /* Now get the buyer from the item master. There may/may not be one
   * assigned to the item. MTL_SYSTEM_ITEMS is a table that isn't striped
   * org.
   */

   begin
      select buyer_id
        into x_buyer_id
        from mtl_system_items
        where inventory_item_id = x_item_id
              and organization_id = x_inv_org_id;
   exception
     /* For one time items this will not return anything */
     when NO_DATA_FOUND then
        x_buyer_id := null;
   end;

-- bug2821542
  IF (x_buyer_id IS NOT NULL) THEN
    validate_buyer(p_agent_id => x_buyer_id,
                   x_result   => l_validate_result);
  END IF;

  if (x_buyer_id  is NULL OR
      l_validate_result = FND_API.G_FALSE) then -- bug2821542

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_FAILED';

      x_progress:='10: get_buyer_from_item: result = ACTION_FAILED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

  else
      po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SUGGESTED_BUYER_ID',
                               avalue     => x_buyer_id);

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_SUCCEEDED';

      x_progress:='20: get_buyer_from_item: result = ACTION_SUCCEEDED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

 end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_buyer_from_item',x_progress);
    raise;
end get_buyer_from_item;


/***************************************************************************
 *
 *  Procedure:  get_buyer_from_category
 *
 *  Description:  Gets buyer from the category on the req line
 *
 *
 **************************************************************************/
procedure get_buyer_from_category (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 ) is

x_category_id number;
x_agent_id  number := null;
x_progress      varchar2(300);

-- bug2821542
l_validate_result       VARCHAR2(1) := FND_API.G_TRUE;

begin

  x_category_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CATEGORY_ID');

  /* Bug - 1895237

  /* Get the buyer from the buyers table.
     If the HR profile Cross Business Groups is set to 'Y' , get it from
     po_agents as po_agents is not striped. But if that profile is set to No,
     then get only buyers for that business group.   */


 If (nvl(hr_general.get_xbg_profile, 'N') = 'Y') then

    begin
      select agent_id
      into x_agent_id
      from po_agents
      where category_id = x_category_id
       and trunc(sysdate) between start_date_active
                          and nvl(end_date_active, sysdate+1);

    exception

      /* It's possible that the same category is assigned to multiple buyers*/

      when TOO_MANY_ROWS then

        x_agent_id := NULL;

        x_progress := '10: get_buyer_from_category: More than 1 buyer for this category ';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

      when NO_DATA_FOUND then

        x_agent_id := NULL;

        x_progress := '20:get_buyer_from_category: No buyer assinged to category';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     end;

  else

     begin

   /* Bug - 1915033 - Added the effectivity dates condition for
      per_people_f also and also introduced TRUNC function   */

      select agent_id
      into x_agent_id
      from po_agents poa,
	       per_all_people_f ppf, --Bug 16249921. Changed per_people_f to per_all_people_f
		   financials_system_parameters fsp
      where poa.agent_id = ppf.person_id
        and ppf.business_group_id = fsp.business_group_id
        and trunc(sysdate) between ppf.effective_start_date
                           and nvl(ppf.effective_end_date, sysdate+1)
        and poa.category_id = x_category_id
        and trunc(sysdate) between poa.start_date_active
                           and nvl(poa.end_date_active, sysdate+1);

     exception

      /* It's possible that the same category is assigned to multiple buyers in the
       same business group  */

       when TOO_MANY_ROWS then

         x_agent_id := NULL;

         x_progress := '10: get_buyer_from_category: More than 1 buyer for this category ';
         IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
         END IF;

       when NO_DATA_FOUND then

         x_agent_id := NULL;

         x_progress := '20:get_buyer_from_category: No buyer assinged to category';
         IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
         END IF;

      end;

  end if;

-- bug2821542
  IF (x_agent_id IS NOT NULL) THEN
    validate_buyer(p_agent_id => x_agent_id,
                   x_result   => l_validate_result);
  END IF;

  if (x_agent_id is NULL OR
      l_validate_result = FND_API.G_FALSE) then  -- bug2821542

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_FAILED';

      x_progress := '30:get_buyer_from_category: result = ACTION_FAILED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;


  else
      po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'SUGGESTED_BUYER_ID',
                                   avalue     => x_agent_id);

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_SUCCEEDED';

      x_progress := '40:get_buyer_from_category: result = ACTION_SUCCEEDED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

  end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','get_buyer_from_category',x_progress);
    raise;

end get_buyer_from_category;

/***************************************************************************
 *
 *  Procedure:  get_buyer_from_source_doc
 *
 *  Description:  Gets buyer from the source doc
 *
 *
 **************************************************************************/
procedure get_buyer_from_source_doc (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 ) is

x_source_doc_po_header_id number;
x_source_doc_type_code    varchar2(25);
x_agent_id  number := null;
x_progress      varchar2(300);

-- bug2821542
l_validate_result       VARCHAR2(1) := FND_API.G_TRUE;

begin

  x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
            (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                     aname      => 'SOURCE_DOCUMENT_TYPE_CODE');

  x_source_doc_po_header_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOCUMENT_ID');
  if( x_source_doc_type_code = 'BLANKET' or
      x_source_doc_type_code = 'QUOTATION') then
    /* Get the buyer from the PO headers table.
     */
    begin
/*Bug 928568-removed the _all reference and used the striped table
  table instead */

      --<Shared Proc FPJ>
      -- Modified the query to select from po_headers_all instead of po_headers.
      select agent_id
      into   x_agent_id
      from   po_headers_all
      where  po_header_id  = x_source_doc_po_header_id;
    exception
      when NO_DATA_FOUND then
        x_agent_id := NULL;
        x_progress := '10:get_buyer_from_source_doc: Source Doc id is wrong';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;
    end;
  else
    /* Right now, it's for pcard one-time item po, need to figure out
     * how to get buyer*/
    null;
  end if;

-- bug2821542
  IF (x_agent_id IS NOT NULL) THEN
    validate_buyer(p_agent_id => x_agent_id,
                   x_result   => l_validate_result);
  END IF;

  if (x_agent_id is NULL OR
      l_validate_result = FND_API.G_FALSE) then -- bug2821542

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_FAILED';

      x_progress := '30:get_buyer_from_source_doc: result = ACTION_FAILED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;


  else
      po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'SUGGESTED_BUYER_ID',
                                   avalue     => x_agent_id);

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_SUCCEEDED';

      x_progress := '40:get_buyer_from_source_doc: result = ACTION_SUCCEEDED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

  end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_buyer_from_source_doc',x_progress);
    raise;
end get_buyer_from_source_doc;

/***************************************************************************
 *
 *  Procedure:  get_buyer_from_contract
 *
 *  Description:  Gets buyer from the contract
 *
 *
 **************************************************************************/
procedure get_buyer_from_contract (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 ) is

x_contract_id number;
x_agent_id    number;
x_progress    VARCHAR2(300);

-- bug2821542
l_validate_result       VARCHAR2(1) := FND_API.G_TRUE;

begin

  x_contract_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACT_ID');

  x_progress := '001';

  begin

    --<Shared Proc FPJ>
    --Modified the query to select from po_headers_all instead of po_headers
    select agent_id
      into x_agent_id
      from po_headers_all
     where po_header_id  = x_contract_id;

  exception

    when others then
      x_agent_id := null;

  end;

  x_progress := '002';

-- bug2821542
  IF (x_agent_id IS NOT NULL) THEN
    validate_buyer(p_agent_id => x_agent_id,
                   x_result   => l_validate_result);
  END IF;

  if (x_agent_id is NULL OR
      l_validate_result = FND_API.G_FALSE) then -- bug2821542

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_FAILED';

      x_progress := '30:get_buyer_from_source_doc: result = ACTION_FAILED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

  else
      po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'SUGGESTED_BUYER_ID',
                                   avalue     => x_agent_id);

      resultout := wf_engine.eng_completed || ':' ||  'ACTION_SUCCEEDED';

      x_progress := '40:get_buyer_from_contract: result = ACTION_SUCCEEDED';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

  end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','get_buyer_from_contract',x_progress);
    raise;

end get_buyer_from_contract;

/***************************************************************************
 *
 *  Procedure:  get_source_doc_type
 *
 *  Description:  Gets the source document type  from the req line.
 *
 *
 **************************************************************************/
procedure get_source_doc_type (itemtype   IN   VARCHAR2,
                               itemkey    IN   VARCHAR2,
                               actid      IN   NUMBER,
                               funcmode   IN   VARCHAR2,
                               resultout  OUT NOCOPY  VARCHAR2 ) is

x_source_doc_type_code  varchar2(25);
x_progress        varchar2(300);
x_ga_flag               varchar2(1);
begin

  x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOCUMENT_TYPE_CODE');

  /* The source doc must be a blanket or quote so return the
   * appropriate value.
   */

  /* FPI GA Start */
  /* Get the GA Flag */
   x_ga_flag := po_wf_util_pkg.GetItemAttrText
           (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOC_GA_FLAG');

  /* FPI GA End */
/* draising 2692119 */
   if (x_source_doc_type_code is null) then
     resultout := wf_engine.eng_completed || ':' || 'NONE';

    x_progress := '10: get_source_doc_type: result = NONE';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  elsif (x_source_doc_type_code = 'BLANKET') then
    if nvl(x_ga_flag,'N') = 'Y' then                               -- FPI GA
      x_progress := '10: get_source_doc_type: result = GLOBAL_PA';
      resultout := wf_engine.eng_completed || ':' || 'GLOBAL_PA';  -- FPI GA
    else
      x_progress := '10: get_source_doc_type: result = BLANKET_PO';
      resultout := wf_engine.eng_completed || ':' || 'BLANKET_PO';
    end if;

     x_progress := '10: get_source_doc_type: result = BLANKET_PO';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  elsif (x_source_doc_type_code = 'CONTRACT') then
    resultout := wf_engine.eng_completed || ':' || 'CONTRACT_PO';

    x_progress := '10: get_source_doc_type: result = CONTRACT_PO';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

  else
    /* Must be QUOTATION */
    resultout := wf_engine.eng_completed || ':' || 'QUOTATION';

    x_progress := '10: get_source_doc_type: result = QUOTATION';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','get_source_doc_type',x_progress);
    raise;
end get_source_doc_type;

/***************************************************************************
 *
 *  Procedure:  one_time_item_check
 *
 *  Description:  Checks if this is a one-time req line (ie. no
 *      item num)
 *
 **************************************************************************/
procedure one_time_item_check (itemtype   IN   VARCHAR2,
                               itemkey    IN   VARCHAR2,
                               actid      IN   NUMBER,
                               funcmode   IN   VARCHAR2,
                               resultout  OUT NOCOPY  VARCHAR2 ) is

x_item_id   number;
x_progress        varchar2(300);

begin

  x_item_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ITEM_ID');

  /* If item_id is null then this is a one-time item. */

  if (x_item_id is NULL) then
    resultout := wf_engine.eng_completed || ':' || 'Y';

    x_progress:= '10: one_time_item_check: result = Y';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  else
    resultout := wf_engine.eng_completed || ':' || 'N';

    x_progress:= '10: one_time_item_check: result = N';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','one_time_item_check',x_progress);
    raise;
end one_time_item_check;





/***************************************************************************
 *
 *  Procedure:  get_rel_gen_method
 *
 *  Description:  Gets the release generation method from the asl
 *      associated with the supplier/site/item combination
 *            on the req line
 *
 **************************************************************************/
procedure get_rel_gen_method (itemtype   IN   VARCHAR2,
                                   itemkey    IN   VARCHAR2,
                                   actid      IN   NUMBER,
                                   funcmode   IN   VARCHAR2,
                                   resultout  OUT NOCOPY  VARCHAR2 ) is

x_org_id        number;
x_inv_org_id                    number;
x_item_id       number;
x_suggested_vendor_id     number;
x_suggested_vendor_site_id  number;
x_organization_id               number;
x_category_id NUMBER;  -- bug No 5943024
x_rel_gen_method  varchar2(25);
x_progress        varchar2(300);

begin

   /* Set the org context. Backend create_po process assumes it is in
    * an org.
    */

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
                                        (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

     po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

    /* Retrieve required info from item attributes */

    x_item_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ITEM_ID');

    x_suggested_vendor_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_ID');

    x_suggested_vendor_site_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_SITE_ID');

    x_organization_id := po_wf_util_pkg.GetItemAttrNumber
                                (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORGANIZATION_ID');
   /* bug no:5943024*/
    x_category_id := po_wf_util_pkg.GetItemAttrNumber
					(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CATEGORY_ID');
/* end of Bug No 5943024*/
    /* Get the release geneartion method for the item/vendor/vendor_site
     * combination from the asl attributes table.
     * We have a subquery in the following query. The purpose of the subquery
     * is to get the local asl if both a local and global asl exist for the
     * item/vendor/vendor_site combination. Ie. it is possible to have both
     * a local and global asl for the same item/vendor/vendor_site combination.
     * For local asl's the using_organization_id is set to the inv_org_id.
     * For global asl's it is set to -1. Thus the max on the subquery will
     * return the local over the global if both exist.
     */

    /* The release gen method can be:
     * Automatic Release/Review (CREATE)            (not allowed if encumbrance on)
     * Automatic Release  (CREATE_AND_APPROVE)
     * Release Using Autocrate  (MANUAL)
     *
     * For the first two cases we let the Auotmatic Release Generation conc. program
     * pick the req lines up. We will pick up the latter case.
     */

    BEGIN
    /*  Bug No :5943024
  	 This query has been modified in such a way that it could select a release generation method even for the asl at commodity level  Earlier the query selects release generation method only for item.
    */


  -- improving performance bug: 9452512
select release_generation_method
          into x_rel_gen_method
          from (
  select paa.release_generation_method
          from po_asl_attributes_val_v paa
          WHERE Paa.Item_Id = x_item_id
         AND Paa.Vendor_Id = x_suggested_vendor_id
         AND (Paa.Vendor_Site_Id IS NULL
               OR ( x_suggested_vendor_site_id  = Paa.Vendor_Site_Id
                   AND NOT EXISTS (SELECT 'select supplier line with null supplier site'
                                   FROM   po_Asl_Attributes_val_v Paa3
                                   WHERE  Paa.Item_Id = Paa3.Item_Id
                                          AND Nvl(Paa.Category_Id,- 1) = Nvl(Paa3.Category_Id,- 1)
                                          AND Paa.Vendor_Id = Paa3.Vendor_Id
                                          AND Paa3.Vendor_Site_Id IS NULL
                                          AND Paa3.UsIng_Organization_Id IN (- 1,
                                                                             x_organization_id))))
         AND Paa.UsIng_Organization_Id = (SELECT MAX(Paa2.UsIng_Organization_Id)
                                          FROM   po_Asl_Attributes_val_v Paa2
                                          WHERE  Paa.Item_Id = Paa2.Item_Id
                                                 AND Nvl(Paa.Category_Id,- 1) = Nvl(Paa2.Category_Id,- 1)
                                                 AND Paa.Vendor_Id = Paa2.Vendor_Id
                                                 AND Nvl(Paa.Vendor_Site_Id,- 1) = Nvl(Paa2.Vendor_Site_Id,- 1)
                                                 AND Paa2.UsIng_Organization_Id IN (- 1,x_organization_id))
  union all
  select paa.release_generation_method
          from po_asl_attributes_val_v paa
          WHERE (Paa.Item_Id IS NULL
                   AND x_category_id = Paa.Category_Id
                   AND NOT EXISTS (SELECT 'commodity level ASL should be used only if there is no item level ASL'
                                   FROM   po_Asl_Attributes_val_v Paa4
                                   WHERE  Paa4.Item_Id = x_item_id
                                          AND Paa4.Vendor_Id = Paa.Vendor_Id
                                          AND Nvl(Paa4.Vendor_Site_Id,- 1) = Nvl(Paa.Vendor_Site_Id,- 1)
                                          AND Paa4.UsIng_Organization_Id IN (- 1,x_organization_id)))
         AND Paa.Vendor_Id = x_suggested_vendor_id
         AND (Paa.Vendor_Site_Id IS NULL
               OR ( x_suggested_vendor_site_id  = Paa.Vendor_Site_Id
                   AND NOT EXISTS (SELECT 'select supplier line with null supplier site'
                                   FROM   po_Asl_Attributes_val_v Paa3
                                   WHERE  Paa3.Item_Id IS NULL
                                          AND Paa.Category_Id = Paa3.Category_Id
                                          AND Paa.Vendor_Id = Paa3.Vendor_Id
                                          AND Paa3.Vendor_Site_Id IS NULL
                                          AND Paa3.UsIng_Organization_Id IN (- 1,
                                                                             x_organization_id))))
         AND Paa.UsIng_Organization_Id = (SELECT MAX(Paa2.UsIng_Organization_Id)
                                          FROM   po_Asl_Attributes_val_v Paa2
                                          WHERE  Paa2.Item_Id IS NULL
                                                 AND Paa.Category_Id = Paa2.Category_Id
                                                 AND Paa.Vendor_Id = Paa2.Vendor_Id
                                                 AND Nvl(Paa.Vendor_Site_Id,- 1) = Nvl(Paa2.Vendor_Site_Id,- 1)
                                                 AND Paa2.UsIng_Organization_Id IN (- 1,x_organization_id))
  )  WHERE ROWNUM =1;


/* end of Bug No 5943024 */

    exception
      when NO_DATA_FOUND then
         x_rel_gen_method :=null;
    end;

    /* Set item attribute so it can be used later */

    po_wf_util_pkg.SetItemAttrText (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'REL_GEN_METHOD',
             avalue   => x_rel_gen_method);

    if (x_rel_gen_method is NULL) then
      resultout := wf_engine.eng_completed || ':' || 'NO_METHOD_FOUND';

      x_progress:= '10: get_rel_gen_method: result = NO_METHOD_FOUND';
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

    else
      resultout := wf_engine.eng_completed || ':' || x_rel_gen_method;

      x_progress:= '20: get_rel_gen_method: ' || 'result = ' || x_rel_gen_method;
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;
    end if;

    -- <SERVICES FPJ START>
    IF (x_rel_gen_method <> 'MANUAL') THEN
        -- Remove any associated expense line
        purge_expense_lines(itemtype, itemkey);
    END IF;
    -- <SERVICES FPJ END>

exception
  when others then
    wf_core.context('po_autocreate_doc','get_rel_gen_method',x_progress);
    raise;
end get_rel_gen_method;


/***************************************************************************
 *
 *  Procedure:  cont_wf_autocreate_rel_gen
 *
 *  Description:  Decides whether automatic autocreation should
 *      take place (ie. continue with workflow) if
 *      the release generation method is AutoCreate.
 *
 **************************************************************************/
procedure cont_wf_autocreate_rel_gen (itemtype   IN   VARCHAR2,
                                      itemkey    IN   VARCHAR2,
                                      actid      IN   NUMBER,
                                      funcmode   IN   VARCHAR2,
                                      resultout  OUT NOCOPY  VARCHAR2 ) is

x_cont_wf_for_ac_rel_gen   varchar2(1);
x_progress                 varchar2(300);

begin

   x_cont_wf_for_ac_rel_gen:= po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'CONT_WF_FOR_AC_REL_GEN');

   if (x_cont_wf_for_ac_rel_gen = 'Y') then
     resultout := wf_engine.eng_completed || ':' ||  'Y';

     x_progress:= '10: cont_wf_autocreate_rel_gen: Y';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   else
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '20: cont_wf_autocreate_rel_gen: N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     -- Remove any associated expense line
     purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>
   end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','cont_wf_autocreate_rel_gen',x_progress);
    raise;
end cont_wf_autocreate_rel_gen;


/***************************************************************************
 *
 *  Procedure:  insert_cand_req_lines_into_tbl
 *
 *  Description:  Inserts a req line into the temp table.
 *      This means its possible to try and autocreate this
 *      line.
 *
 **************************************************************************/
procedure insert_cand_req_lines_into_tbl (itemtype   IN   VARCHAR2,
                                          itemkey    IN   VARCHAR2,
                                          actid      IN   NUMBER,
                                          funcmode   IN   VARCHAR2,
                                          resultout  OUT NOCOPY  VARCHAR2 ) is


x_group_id      number;
x_req_header_id     number;
x_req_line_id     number;
x_suggested_buyer_id    number;
x_source_doc_type_code    varchar2(25);
x_source_doc_id     number;
x_source_doc_line   number;
x_suggested_vendor_id     number;
x_suggested_vendor_site_id  number;
x_currency_code     varchar2(15);
x_rate_type     varchar2(30);
x_rate_date     date;
x_rate        number;
x_pcard_id      number;
x_rel_gen_method    varchar2(25);
x_item_id     number;
x_progress          varchar2(300);

x_contract_id                   number;
l_job_id                        number := null;  -- <SERVICES FPJ>

begin

  /* Get all the item attributes that we need to put into the
   * temp table.
   */

  /* Not all the fields are needed in the temp table for our
   * processing (grouping) to work. But no harm having them there.
   * If in the future they are needed then they'll already be there.
   */

   x_group_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'GROUP_ID');

   x_req_header_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                     itemkey  => itemkey,
                                         aname    => 'REQ_HEADER_ID');

   x_req_line_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQ_LINE_ID');

   x_suggested_buyer_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_BUYER_ID');

   x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOCUMENT_TYPE_CODE');

   x_source_doc_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOCUMENT_ID');

   x_source_doc_line := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOCUMENT_LINE_NUM');


   x_suggested_vendor_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_ID');

   x_suggested_vendor_site_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_VENDOR_SITE_ID');


  x_contract_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CONTRACT_ID');


   x_currency_code := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENCY_CODE');

   x_rate_type := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RATE_TYPE');

   x_rate_date := po_wf_util_pkg.GetItemAttrDate
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RATE_DATE');

   x_rate := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RATE');

   x_pcard_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PCARD_ID');

   x_rel_gen_method := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'REL_GEN_METHOD');

   x_item_id := po_wf_util_pkg.GetItemAttrText
           (itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ITEM_ID');

   -- <SERVICES FPJ>
   l_job_id := po_wf_util_pkg.GetItemAttrNumber
                                         (itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'JOB_ID');

  /* Insert the req line into the the temp table.
   * The req lines in this table will then be picked up
   * later to be autocreated.
   */

   x_progress := '10:insert_cand_req_lines_into_tbl: inserting into temp table for ' ||
     'req line = ' || to_char(x_req_line_id);

   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   begin
      INSERT INTO po_wf_candidate_req_lines_temp
        (group_id,
     requisition_header_id,
     requisition_line_id,
     suggested_buyer_id,
     source_doc_type_code,
       source_doc_id,
     source_doc_line,
     suggested_vendor_id,
     suggested_vendor_site_id,
                 contract_id,
     currency_code,
     rate_type,
     rate_date,
     rate,
     pcard_id,
     process_code,
     release_generation_method,
     item_id,
                 job_id)  -- <SERVICES FPJ>
   VALUES (x_group_id,
     x_req_header_id,
     x_req_line_id,
     x_suggested_buyer_id,
     x_source_doc_type_code,
       x_source_doc_id,
     x_source_doc_line,
     x_suggested_vendor_id,
     x_suggested_vendor_site_id,
                 x_contract_id,
     x_currency_code,
     x_rate_type,
     x_rate_date,
     x_rate,
     x_pcard_id,
     'PENDING',
     x_rel_gen_method,
     x_item_id,
                 l_job_id);  -- <SERVICES FPJ>
   exception
     when others then
       x_progress := '15: insert_cand_req_lines_into_tbl: IN EXCEPTION when inserting' ||
         'into po_wf_candidate_req_lines_temp';
       IF (g_po_wf_debug = 'Y') THEN
          po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
       END IF;
       raise;
   end;

   /* Calling process should do the commit, so comment out here.
    * COMMIT;
    */

   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

   x_progress:= '20: insert_cand_req_lines_into_tbl: ACTIVITY_PERFORMED';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc','insert_cand_req_lines_into_tbl',x_progress);
    raise;
end insert_cand_req_lines_into_tbl;


/***************************************************************************
 *
 *  Procedure:  group_req_lines
 *
 *  Description:  Groups the requistion lines in the temp table into
 *      header and line records which it then inserts into
 *      the interface tables.
 *
 **************************************************************************/
procedure group_req_lines (itemtype   IN   VARCHAR2,
                           itemkey    IN   VARCHAR2,
                           actid      IN   NUMBER,
                           funcmode   IN   VARCHAR2,
                           resultout  OUT NOCOPY  VARCHAR2 ) is


c1_group_id     number;
c1_req_header_id    number;
c1_req_line_id      number;
c1_suggested_buyer_id   number;
c1_source_doc_type_code   varchar2(25);
c1_source_doc_id    number;
c1_source_doc_line    number;
c1_suggested_vendor_id    number;
c1_suggested_vendor_site_id number;
c1_currency_code    varchar2(15);
c1_rate_type      varchar2(30);
c1_rate_date      date;
c1_rate       number;
c1_process_code     varchar2(30);
c1_rel_gen_method   varchar2(25);
c1_item_id      number;
c1_pcard_id     number;
c1_contract_id      number;
c1_deliver_to_location_code     hr_locations_all.location_code%type;
c1_dest_org_id                  number;                                          -- Consigned FPI
c1_dest_type_code               po_requisition_lines.destination_type_code%TYPE; -- Consigned FPI
c1_cons_from_supp_flag          varchar2(1);                                     -- Consigned FPI
c1_labor_req_line_id            number;  -- <SERVICES FPJ>

c2_rowid      rowid;
c2_group_id     number;
c2_req_header_id    number;
c2_req_line_id      number;
c2_suggested_buyer_id   number;
c2_source_doc_type_code   varchar2(25);
c2_source_doc_id    number;
c2_source_doc_line    number;
c2_suggested_vendor_id    number;
c2_suggested_vendor_site_id number;
c2_currency_code    varchar2(15);
c2_rate_type      varchar2(30);
c2_rate_date      date;
c2_rate       number;
c2_process_code     varchar2(30);
c2_rel_gen_method   varchar2(25);
c2_item_id      number;
c2_pcard_id     number;
c2_contract_id      number;
c2_labor_req_line_id            number;  -- <SERVICES FPJ>
--<R12 STYLES PHASE II START>
c2_line_type_id             number;
c2_purchase_basis           varchar2(30);
c1_line_type_id             number;
c1_purchase_basis           varchar2(30);
l_pcard_id                  number;
--<R12 STYLES PHASE II END>


l_enable_vmi_flag       po_asl_attributes.enable_vmi_flag%TYPE;               -- Consigned FPI
l_last_billing_date     po_asl_attributes.last_billing_date%TYPE;             -- Consigned FPI
l_cons_billing_cycle    po_asl_attributes.consigned_billing_cycle%TYPE;       -- Consigned FPI

c2_dest_org_id              number;                                           -- Consigned FPI
c2_dest_type_code           po_requisition_lines.destination_type_code%TYPE;  -- Consigned FPI
c2_cons_from_supp_flag      varchar2(1);                                      -- Consigned FPI

x_group_id      number;
x_first_time_for_this_comb  varchar2(5);
x_interface_header_id   number;
x_suggested_vendor_contact_id   number;
x_suggested_vendor_contact      varchar2(240);
c2_deliver_to_location_code     hr_locations_all.location_code%type;
x_prev_sug_vendor_contact_id    number;
x_carry_contact_to_po_flag      varchar2(10);

/*  x_grouping_allowed              varchar2(1); Bug 2974129 */
x_group_one_time_address        varchar2(1);

x_progress          varchar2(300);
x_valid       number;

c1_ga_flag                      varchar2(1);     -- FPI GA
c2_ga_flag                      varchar2(1);     -- FPI GA

--Bug 2745549
l_ref_ga_is_valid               varchar2(1) := 'N';

l_return_status         varchar2(1)    := NULL;
l_msg_count             number         := NULL;
l_msg_data              varchar2(2000) := NULL;

x_source_contact_id   NUMBER :=NULL; -- Bug 3586181
c2_found      VARCHAR2(1); -- Bug 3586181

    x_different varchar2(1) ;
    x_src_doc_id number;


/* Define the cursor which picks up records from the temp table.
 * We need the 'for update' since we are going to update the
 * process_code.
 */
/* Bug # 1721991.
   The 'for update' clause was added to update the row which was processed
   in the Cursor c2 but this led to another problem in Oracle 8.1.6.3 or above
   where you can't have a commit inside a 'for update' Cursor loop.
   This let to the Runtime Error 'fetch out of sequence'
   The commit was actually issued in the procedure insert_into_header_interface.
   To solve this we removed the for update in the cursor and instead used rowid
   to update the row processed by the Cursor.
*/
-- <SERVICES FPJ>
-- Added labor_req_line_id to the select statement
cursor c1  is       /* x_group_id is a parameter */
  select prlt.group_id,
         prlt.requisition_header_id,
         prlt.requisition_line_id,
   prlt.suggested_buyer_id,
         prlt.source_doc_type_code,
   prlt.source_doc_id,
   prlt.source_doc_line,
   prlt.suggested_vendor_id,
         prlt.suggested_vendor_site_id,
   prlt.currency_code,
         prlt.rate_type,
   prlt.rate_date,
   prlt.rate,
   prlt.process_code,
   prlt.release_generation_method,
   prlt.item_id,
   prlt.pcard_id,
         prlt.contract_id,
         hrl.location_code,
         prl.destination_organization_id,
         prl.destination_type_code,
         prl.labor_req_line_id
         --<R12 STYLES PHASE II START>
        ,prl.line_type_id,
         prl.purchase_basis
         --<R12 STYLES PHASE II END>
    from po_wf_candidate_req_lines_temp prlt,
         po_requisition_lines prl,
         hr_locations_all hrl
   where prlt.process_code = 'PENDING'
     and prlt.group_id     = x_group_id
     and prlt.requisition_line_id = prl.requisition_line_id
     and prl.deliver_to_location_id = hrl.location_id(+)    -- bug 2709046
     and prl.line_location_id IS NULL-- <REQINPOOL> --bug10064616
   for update; -- <BUG 5256593>
--bug10064616 changed the condition reqs_in_pool_flag = 'Y' to line_location_id is NULL

-- <SERVICES FPJ>
-- Added labor_req_line_id to the select statement
cursor c2  is       /* x_group_id is a parameter */
  select prlt.rowid,   -- Bug# 1721991 , Added rowid to update row processed
         prlt.group_id,
         prlt.requisition_header_id,
         prlt.requisition_line_id,
   prlt.suggested_buyer_id,
         prlt.source_doc_type_code,
   prlt.source_doc_id,
   prlt.source_doc_line,
   prlt.suggested_vendor_id,
         prlt.suggested_vendor_site_id,
   prlt.currency_code,
         prlt.rate_type,
   prlt.rate_date,
   prlt.rate,
   prlt.process_code,
   prlt.release_generation_method,
   prlt.item_id,
   prlt.pcard_id,
         prlt.contract_id,
   prl.suggested_vendor_contact,
   prl.vendor_contact_id,
         hrl.location_code,
         prl.destination_organization_id,
         prl.destination_type_code,
         prl.labor_req_line_id
         --<R12 STYLES PHASE II START>
        ,prl.line_type_id,
         prl.purchase_basis
         --<R12 STYLES PHASE II END>

    from po_wf_candidate_req_lines_temp prlt,
   po_requisition_lines prl,
         hr_locations_all hrl
   where prlt.process_code = 'PENDING'
     and prlt.group_id     = x_group_id
     and prlt.requisition_line_id = prl.requisition_line_id
     and prl.deliver_to_location_id = hrl.location_id(+)  -- bug 2709046
     and prl.line_location_id IS NULL-- <REQINPOOL> --bug10064616
     --Bug# 1721991, for update;
   for update; -- <BUG 5256593>
   --bug10064616 changed the condition reqs_in_pool_flag = 'Y' to line_location_id is NULL

    --<R12 STYLES PHASE II START>
    c1_style_id  PO_DOC_STYLE_HEADERS.style_id%type;
    c2_style_id  PO_DOC_STYLE_HEADERS.style_id%type;
    c1_valid_style   BOOLEAN;
    c2_valid_style   BOOLEAN;
    x_return_status   VARCHAR2(1);
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(2000);
    --<R12 STYLES PHASE II END>

begin


   /* Get the group_id since we only want to process lines belonging
    * to the same group. We need to get the group_id before opening
    * the cursor since it is a parameter to the cursor.
    */

   x_group_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'GROUP_ID');

 /* Bug 2974129. This Grouping allowed flag should not decide the #of documents
    Instead this should be applied to group the lines.

   x_grouping_allowed := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'GROUPING_ALLOWED_FLAG');   */

   x_group_one_time_address := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'GROUP_ONE_ADDR_LINE_FLAG');

/*   if x_grouping_allowed is NULL then

     x_grouping_allowed := 'Y';

   end if; Bug 2974129 */

   if x_group_one_time_address is NULL then

     x_group_one_time_address := 'Y';

   end if;

   /* Open the cursor with that group_id */
   open c1;   /* Based on x_group_id */
   -- Outer Loop: Loop through all the Req Lines with process_code = PENDING
   loop
      fetch c1 into c1_group_id,
        c1_req_header_id,
              c1_req_line_id,
              c1_suggested_buyer_id,
              c1_source_doc_type_code,
              c1_source_doc_id,
              c1_source_doc_line,
              c1_suggested_vendor_id,
              c1_suggested_vendor_site_id,
              c1_currency_code,
              c1_rate_type,
              c1_rate_date,
              c1_rate,
              c1_process_code,
              c1_rel_gen_method,
              c1_item_id,
        c1_pcard_id,
                    c1_contract_id,
                    c1_deliver_to_location_code,
                    c1_dest_org_id,
                    c1_dest_type_code,
                    c1_labor_req_line_id
                     --<R12 STYLES PHASE II START>
                    ,c1_line_type_id,
                     c1_purchase_basis
                     --<R12 STYLES PHASE II END>
		    ;
        exit when c1%NOTFOUND;

        --<R12 STYLES PHASE II START>
	c1_valid_style := TRUE;

	x_progress := '01: group_req_lines : c1_req_line_id = '|| to_char(c1_req_line_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        -- bug 4923134

	x_progress := '01: group_req_lines : c1_source_doc_id = '|| to_char(c1_source_doc_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

	x_progress := '01: group_req_lines : c1_contract_id = '|| to_char(c1_contract_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;


        if (nvl(c1_source_doc_id,c1_contract_id) is not null) then

	    c1_style_id := PO_DOC_STYLE_PVT.get_doc_style_id(nvl(c1_source_doc_id,c1_contract_id));  -- bug 4923134

            x_progress := '01: group_req_lines : c1_style_id = '|| to_char(c1_style_id);
	    IF (g_po_wf_debug = 'Y') THEN
                po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
            END IF;

            PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                           p_init_msg_list    => fnd_api.g_true,
                                           x_return_status    => x_return_status,
                                           x_msg_count        => x_msg_count,
                                           x_msg_data         => x_msg_data,
                                           p_doc_style_id     => c1_style_id,
                                           p_document_id      => NULL,
                                           p_line_type_id     => c1_line_type_id,
                                           p_purchase_basis   => c1_purchase_basis,
                                           p_destination_type => c1_dest_type_code,
                                           p_source           => 'AUTOCREATE');

             if x_return_status <> FND_API.g_ret_sts_success THEN
                c1_valid_style := FALSE;
             end if;
         --<Bug#5695323 vmaduri START>
         --Set Style ID as 1 if P card is used and source doc or cotract are not there
          else
          c1_style_id:=1;
          end if;
         --<Bug#5695323 vmaduri END>
         --<R12 STYLES PHASE II END>

     if  c1_valid_style then  --< R12 STYLES PHASE II>

	x_progress := '01: group_req_lines : c1_req_line_id = '|| to_char(c1_req_line_id)||'valid style';
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     /* FPI GA start */
        IF (c1_source_doc_id is not null)
	THEN
            select global_agreement_flag
            into c1_ga_flag
            from po_headers_all
            where po_header_id = c1_source_doc_id;
        -- <Bug 14172394>
        -- Reset c1_ga_flag to NULL if there is no sourcing BPA.
        ELSE
	  c1_ga_flag := NULL;
        END IF;

     /* FPI GA End */

     /* Consigned FPI start */
        PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes
       ( p_api_version                  => 1.0
       , p_init_msg_list                => NULL
       , x_return_status                => l_return_status
       , x_msg_count                    => l_msg_count
       , x_msg_data                     => l_msg_data
       , p_inventory_item_id            => c1_item_id
       , p_vendor_id                    => c1_suggested_vendor_id
       , p_vendor_site_id               => c1_suggested_vendor_site_id
       , p_using_organization_id        => c1_dest_org_id
       , x_consigned_from_supplier_flag => c1_cons_from_supp_flag
       , x_enable_vmi_flag              => l_enable_vmi_flag
       , x_last_billing_date            => l_last_billing_date
       , x_consigned_billing_cycle      => l_cons_billing_cycle
      );

    /*Bug11802312 We ll retain the document reference for an consigned PO*/

     --  if c1_cons_from_supp_flag = 'Y' and
     --     nvl(c1_dest_type_code,'INVENTORY') = 'EXPENSE' then
     --     c1_cons_from_supp_flag := 'N';
     --  end if;

    /* Bug#14305183: We will retain the document reference for consigned PO.
     * With Profile 'PO: Create Consigned PO As Standard PO' control the type
     * of consigned document to be created, if source document as local Blanket.
     * If Profile is set to 'Yes', we should still create a Standard PO without
     * having the source document reference. Hence x_doc_type_to_create should
     * be STANDARD in this case.
     * In Case Profile is set to 'No', system will created Consigned Releases.
     */
    -- Bug#14305183::Start

       If c1_cons_from_supp_flag = 'Y' and nvl(c1_dest_type_code,'INVENTORY') <> 'EXPENSE'
       Then
         If (NVL(fnd_profile.value('PO_CREATE_CONSIGNED_PO_AS_SPO'),'N') = 'Y')
	     AND (NVL(c1_ga_flag,'N') = 'N')  -- Retain the Source Doc Ref for GBPA
	 Then
	   c1_source_doc_id := NULL;
           c1_contract_id   := NULL;
         End If;
       Else
         c1_cons_from_supp_flag := 'N';
       End If;

    --Bug Fix#14305183::End

     /* Consigned FPI end */

     --<Bug 2745549 mbhargav START>
     --Null out GA information if GA is not valid
     if c1_source_doc_id is not null then

         is_ga_still_valid(c1_source_doc_id, l_ref_ga_is_valid);

         if l_ref_ga_is_valid = 'N' then
             c1_source_doc_id := null;
         end if;
     end if;
     --<Bug 2745549 mbhargav END>


     /* Supplier PCard FPH. Check whether c1_pcard_id is valid. The function
      * will return pcard_id if valid else will have value null if not.
     */

     If (c1_pcard_id is not null) then
    c1_pcard_id := po_pcard_pkg.get_valid_pcard_id(c1_pcard_id,c1_suggested_vendor_id,c1_suggested_vendor_site_id);
     end if;
      /* Supplier PCard FPH */
      x_first_time_for_this_comb := 'TRUE';
      x_suggested_vendor_contact_id := NULL;
      x_carry_contact_to_po_flag := 'TRUE';
      x_prev_sug_vendor_contact_id := NULL;
      c2_found :='Y';

      open c2;
      -- Inner Loop: Loop through all the Req Lines with process_code = PENDING,
      -- to compare it with current Req Line in cursor c1, and to check if it
      -- can be grouped with the Req Line in cursor c1.
      loop
         fetch c2 into  c2_rowid,  -- Bug# 1721991, Added rowid
                        c2_group_id,
      c2_req_header_id,
            c2_req_line_id,
                c2_suggested_buyer_id,
                c2_source_doc_type_code,
                c2_source_doc_id,
      c2_source_doc_line,
                c2_suggested_vendor_id,
                c2_suggested_vendor_site_id,
                c2_currency_code,
                c2_rate_type,
                c2_rate_date,
                c2_rate,
                c2_process_code,
                c2_rel_gen_method,
                c2_item_id,
            c2_pcard_id,
                        c2_contract_id,
      x_suggested_vendor_contact,
      x_suggested_vendor_contact_id,
                        c2_deliver_to_location_code,
                        c2_dest_org_id,
                        c2_dest_type_code,
                        c2_labor_req_line_id
                        --<R12 STYLES PHASE II START>
                       ,c2_line_type_id,
                        c2_purchase_basis
                        --<R12 STYLES PHASE II END>
                        ;


     if (c2%rowcount)= 0 then  -- Bug 3586181
              c2_found:='N';
           end if;
          exit when c2%NOTFOUND;




        --<R12 STYLES PHASE II START>
	c2_valid_style := TRUE;
	x_progress := '02: group_req_lines : c2_req_line_id = '|| to_char(c2_req_line_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        -- bug 4923134
	x_progress := '02: group_req_lines : c2_source_doc_id = '|| to_char(c2_source_doc_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

	x_progress := '02: group_req_lines : c2_contract_id = '|| to_char(c2_contract_id);
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        if (nvl(c2_source_doc_id,c2_contract_id) is not null) then

	    c2_style_id := PO_DOC_STYLE_PVT.get_doc_style_id(nvl(c2_source_doc_id,c2_contract_id));  -- bug 4923134

            x_progress := '02: group_req_lines : c2_style_id = '|| to_char(c2_style_id);
	    IF (g_po_wf_debug = 'Y') THEN
	         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
	    END IF;

            PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                           p_init_msg_list    => fnd_api.g_true,
                                           x_return_status    => x_return_status,
                                           x_msg_count        => x_msg_count,
                                           x_msg_data         => x_msg_data,
                                           p_doc_style_id     => c2_style_id,
                                           p_document_id      => NULL,
                                           p_line_type_id     => c2_line_type_id,
                                           p_purchase_basis   => c2_purchase_basis,
                                           p_destination_type => c2_dest_type_code,
                                           p_source           => 'AUTOCREATE');

             if x_return_status <> FND_API.g_ret_sts_success THEN
                c2_valid_style := FALSE;
             end if;
         --<Bug#5695323 vmaduri START>
         --Set Style ID as 1 if P card is used and source doc or cotract are not there
          else
          c2_style_id:=1;
          end if;
         --<Bug#5695323 vmaduri END>
        --<R12 STYLES PHASE II END>

       if c2_valid_style then          --<R12 STYLES PHASE II>

	x_progress := '02: group_req_lines : c2_req_line_id = '|| to_char(c2_req_line_id)||'valid style';
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

      /* FPI GA start */
        IF (c2_source_doc_id is not null)
        THEN
            select global_agreement_flag
            into c2_ga_flag
            from po_headers_all
            where po_header_id = c2_source_doc_id;
        -- <Bug 14172394>
        -- Reset c2_ga_flag to NULL if there is no sourcing BPA.
        ELSE
	  c2_ga_flag := NULL;
        END IF;

     /* FPI GA End */
     /* Consigned FPI start */
        PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes
       ( p_api_version                  => 1.0
       , p_init_msg_list                => NULL
       , x_return_status                => l_return_status
       , x_msg_count                    => l_msg_count
       , x_msg_data                     => l_msg_data
       , p_inventory_item_id            => c2_item_id
       , p_vendor_id                    => c2_suggested_vendor_id
       , p_vendor_site_id               => c2_suggested_vendor_site_id
       , p_using_organization_id        => c2_dest_org_id
       , x_consigned_from_supplier_flag => c2_cons_from_supp_flag
       , x_enable_vmi_flag              => l_enable_vmi_flag
       , x_last_billing_date            => l_last_billing_date
       , x_consigned_billing_cycle      => l_cons_billing_cycle
      );

     /*Bug11802312 We ll retain the document reference for an consigned PO*/
      -- if c2_cons_from_supp_flag = 'Y' and
      --    nvl(c2_dest_type_code,'INVENTORY') = 'EXPENSE' then
      --    c2_cons_from_supp_flag := 'N';
      -- end if;

    /* Bug#14305183: We will retain the document reference for consigned PO.
     * With Profile 'PO: Create Consigned PO As Standard PO' control the type
     * of consigned document to be created, if source document as local Blanket.
     * If Profile is set to 'Yes', we should still create a Standard PO without
     * having the source document reference. Hence x_doc_type_to_create should
     * be STANDARD in this case.
     * In Case Profile is set to 'No', system will created Consigned Releases.
     */
     -- Bug#14305183::Start

      If c2_cons_from_supp_flag = 'Y' and nvl(c2_dest_type_code,'INVENTORY') <> 'EXPENSE'
      Then
        If (NVL(fnd_profile.value('PO_CREATE_CONSIGNED_PO_AS_SPO'),'N') = 'Y')
	    AND (NVL(c2_ga_flag,'N') = 'N')  -- Retain the Source Doc Ref for GBPA
	Then
           c2_source_doc_id := NULL;
           c2_contract_id := NULL;
        End If;
      Else
        c2_cons_from_supp_flag := 'N';
      End If;

      --Bug Fix#14305183::End

     /* Consigned FPI end */

     --<Bug 2745549 mbhargav START>
     --Null out GA information if GA is not valid
     if c2_source_doc_id is not null then

         is_ga_still_valid(c2_source_doc_id, l_ref_ga_is_valid);

         if l_ref_ga_is_valid = 'N' then
             c2_source_doc_id := null;
         end if;
     end if;
     --<Bug 2745549 mbhargav END>

     /* Supplier PCard FPH. Check whether c2_pcard_id is valid. The function
      * will return pcard_id if valid else will have value null if not.
     */
  If (c2_pcard_id is not null) then
    c2_pcard_id := po_pcard_pkg.get_valid_pcard_id(c2_pcard_id,c2_suggested_vendor_id,c2_suggested_vendor_site_id);
  end if;
        /* Supplier PCard FPH */
    /* Associate similiar lines with the same header. This is the core
           * grouping logic.
           */

    x_progress := '10: group_req_lines : c1_req_line_id = '
        || to_char(c1_req_line_id) || '   c2_req_line_id = '
        || to_char(c2_req_line_id);

    if (x_suggested_vendor_contact_id is null) then
    x_suggested_vendor_contact_id := get_contact_id(x_suggested_vendor_contact, c2_suggested_vendor_site_id);
    end if;

          IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;

   /* Bug 1362315
   When you initiate the create doc workflow from requisition import
   for a batch of 5000 requisitions or more, the process
   failed to create the po for one or two requisitions bcos
   we were not truncating the sysdate before a comparison in the following
   if logic and thereby not creating records in the po_headers_interface
   table for the autocreate logic to process the req to a PO.
   */


          /* Add one time location grouping logic */
    -- Check if Req Lines in c1 and c1 should be included in the same PO
    -- or differenct POs.
    if (c1_req_line_id = c2_req_line_id) /* Always insert if c1 and c2 is the same line */
             OR
             ( /* (x_grouping_allowed = 'Y') AND Bug 2974129 */
             (x_group_one_time_address = 'Y' OR
              (x_group_one_time_address = 'N' AND
			  /* Added NVL for  deliver to location code as theyre failing for drop ship so flow
			     Because deliver to location is not present in hr locations for drop ship SO instead in hz locations.
				 So above cursors will retrieve NULL values for these variables*/
               nvl(c1_deliver_to_location_code,-99) <> nvl(fnd_profile.value('POR_ONE_TIME_LOCATION'),-99) AND	--bug 4449781 : added nvl
               nvl(c2_deliver_to_location_code,-99) <> nvl(fnd_profile.value('POR_ONE_TIME_LOCATION'),-99))) AND
             (c1_suggested_buyer_id     = c2_suggested_buyer_id)       AND
	     (c1_style_id = c2_style_id)  AND                         --<R12 STYLES PHASE II>
       (c1_suggested_vendor_id    = c2_suggested_vendor_id)    AND
       (c1_suggested_vendor_site_id = c2_suggested_vendor_site_id) AND
       (nvl(c1_source_doc_type_code ,'QUOTATION')    =
              nvl(c2_source_doc_type_code,'QUOTATION'))                  AND
             (nvl(c1_ga_flag,'N')         = nvl(c2_ga_flag,'N'))         AND      -- FPI GA
             (nvl(c1_contract_id,-1)    = nvl(c2_contract_id,-1))  AND
             (nvl(c1_currency_code,'ok')  = nvl(c2_currency_code, 'ok')) AND
       (nvl(c1_rate_type, 'ok')   = nvl(c2_rate_type, 'ok'))   AND
             ((c1_rate is NULL AND c2_rate is NULL)     --<Bug 3343855>
              OR
        (nvl(trunc(c1_rate_date), trunc(sysdate))  = nvl(trunc(c2_rate_date), trunc(sysdate))))  AND --9104813
       (nvl(c1_rate,-1)     = nvl(c2_rate, -1))    AND
       (nvl(c1_pcard_id,-1)   = nvl(c2_pcard_id,-1))   AND
       ((nvl(c1_source_doc_id,-1)   = nvl(c2_source_doc_id,-1))
        OR
              (nvl(c1_source_doc_type_code ,'QUOTATION')   = 'QUOTATION')
              OR
              ((nvl(c1_source_doc_type_code,'QUOTATION') = 'BLANKET') AND (nvl(c1_ga_flag,'N') = 'Y'))) -- FPI GA   AND
             )
             -- <SERVICES FPJ START>
             OR
             (nvl(c1_req_line_id, -1) = nvl(c2_labor_req_line_id, -1))
             OR
             (nvl(c1_labor_req_line_id, -1) = nvl(c2_req_line_id, -1))
             -- <SERVICES FPJ END>
          THEN

        x_progress := '20: group_req_lines: c1 and c2 match ';
        IF (g_po_wf_debug = 'Y') THEN
          po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;


       /* Update the process code of the current line in the temp table so
          * it doesn't get picked up again by the cursor for processing.
        */

       update po_wf_candidate_req_lines_temp
       set process_code = 'PROCESSED'
             where rowid=c2_rowid;
       -- Bug# 1721991, where current of c2;

       x_progress:= '30:group_req_lines: Updated process_code ';
       IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
       END IF;


       if (x_first_time_for_this_comb  = 'TRUE') then

         --<R12 STYLES PHASE II START>
         -- bug5731406
         -- The check for source doc id (added through bug4923134) has been
         -- removed as c2_style_id is always populated after bug5695323

         x_progress:= '30:group_req_lines: is progress payments  ';
         IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
         END IF;

         if PO_DOC_STYLE_PVT.is_progress_payments_enabled(c2_style_id) then
           l_pcard_id := NULL;
         else
           l_pcard_id := c2_pcard_id;
         end if;

         --<R12 STYLES PHASE II END>

                if(po_autocreate_doc.insert_into_headers_interface
                     (itemtype,
                      itemkey,
                      c2_group_id,
                      c2_suggested_vendor_id,
                      c2_suggested_vendor_site_id,
                      c2_suggested_buyer_id,
                      c2_source_doc_type_code,
                      c2_source_doc_id,
                      c2_currency_code,
                      c2_rate_type,
                      c2_rate_date,
                      c2_rate,
                      l_pcard_id,  --<R12 STYLES PHASE II>
                      c2_style_id,  --<R12 STYLES PHASE II>
                      x_interface_header_id) = FALSE) then
                  exit; --bug 3401653: po creation failed, skip out of inner loop
                end if;



          po_autocreate_doc.insert_into_lines_interface (itemtype,
                  itemkey,
                  x_interface_header_id,
                  c2_req_line_id,
                  c2_source_doc_line,
                  c2_source_doc_type_code,
                                                            c2_contract_id,
                                                            c2_source_doc_id,         -- GA FPI
                                                            c2_cons_from_supp_flag);  -- Consigned FPI

    /* Bug  3586181 When the document is Contract or Global Aggrement
                               get the vendor contact from them*/

/*Bug9060101 Removed the code added in Bug8632992. Since the contact can be valid across orgs. We validate the contact
  against the site on the requisition. If valid we set the source contact id*/
                BEGIN
                        IF ((NVL(c1_source_doc_type_code,'BLANKET')='CONTRACT') ) THEN
                                SELECT vendor_contact_id
                                INTO   x_source_contact_id
                                FROM   po_headers_all
                                WHERE  po_header_id=c2_contract_id;

                        elsif (NVL(c2_ga_flag,'N')='Y') THEN -- For Global Aggrement.
                                SELECT vendor_contact_id
                                INTO   x_source_contact_id
                                FROM   po_headers_all -- To take care of GAs in Diff Operating unit
                                WHERE  po_header_id=c2_source_doc_id;

                        ELSE
                                x_source_contact_id := NULL;
                        END IF;
                        IF x_source_contact_id IS NOT NULL THEN
                                IF (NOT valid_contact(c2_suggested_vendor_site_id, x_source_contact_id)) THEN
                                        x_source_contact_id := NULL;
                                END IF;
                        END IF;
                EXCEPTION
                WHEN no_data_found THEN
                        x_source_contact_id := NULL;
                END;

          /* End  3586181*/

          x_progress := '40: group_req_lines: inserted header'||
          ' and line for req line = ' || to_char(c2_req_line_id);
    IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;
/* bug 2656323
   Added code to update vendor_contact_id when  po_headers is inserted for first time. */
     if (x_carry_contact_to_po_flag = 'TRUE' and
              valid_contact(c2_suggested_vendor_site_id, x_suggested_vendor_contact_id)) then
     begin
                      update po_headers_interface
                set vendor_contact_id = x_suggested_vendor_contact_id
          where interface_header_id = x_interface_header_id;
           exception
             when others then
          IF (g_po_wf_debug = 'Y') THEN
                         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
                END IF;
           end;
     end if;



          x_first_time_for_this_comb := 'FALSE';
    --bug#3586181
    if (x_suggested_vendor_contact_id is not NULL) then
      x_prev_sug_vendor_contact_id := x_suggested_vendor_contact_id;
    end if;
    --bug#3586181


       else  /*  ie. x_first_time_for_this_comb  = FALSE */

              /* The line we are checking now can put put onto the same header
           * as a previous one, so only insert a new line into the
                 * po_lines_interface table.
           */

                po_autocreate_doc.insert_into_lines_interface (itemtype,
                  itemkey,
                  x_interface_header_id,
                  c2_req_line_id,
                  c2_source_doc_line,
                  c2_source_doc_type_code,
                                                            c2_contract_id,
                                                            c2_source_doc_id,          -- GA FPI
                                                            c2_cons_from_supp_flag);   -- Consigned FPI

           x_progress := '50: group_req_lines: inserted just line for '||
             'req line = ' || to_char(c2_req_line_id);
     IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

    --bug#3586181
     if (x_carry_contact_to_po_flag = 'TRUE')  then -- SS
         if ( x_suggested_vendor_contact_id is not null and x_prev_sug_vendor_contact_id is not null) and
            (x_suggested_vendor_contact_id <> x_prev_sug_vendor_contact_id) then -- SS
              x_carry_contact_to_po_flag := 'FALSE';
         end if;
     end if;

     -- Start Bug 5250863
     if(x_suggested_vendor_contact_id is not null and
         x_prev_sug_vendor_contact_id  is null )then
          x_prev_sug_vendor_contact_id := x_suggested_vendor_contact_id;
     end if;
     -- End Bug 5250863
    --bug#3586181

       end if;

          end if;
    /* Commented by Bug 5250863
    --bug#3586181
    if(x_suggested_vendor_contact_id is not null)then
      x_prev_sug_vendor_contact_id := x_suggested_vendor_contact_id;
    end if;
    --bug#3586181
    */
   else
	x_progress := '02: group_req_lines : c2_req_line_id = '|| to_char(c2_req_line_id)||'invalid style';
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

   end if ; --if c2_valid_style     --<R12 STYLES PHASE II>

      end loop;
/* Commented this code as we are updating vendor_contact_id when header is inserted first time.
      if (x_carry_contact_to_po_flag = 'TRUE' and
          valid_contact(c2_suggested_vendor_site_id, x_suggested_vendor_contact_id)) then
            begin
                    x_progress := '55: group_req_lines: updating header with vendor contact :'||x_interface_header_id;
                    update po_headers_interface
                    set vendor_contact_id = x_suggested_vendor_contact_id
                    where interface_header_id = x_interface_header_id;
            exception
                    when others then
                    IF (g_po_wf_debug = 'Y') THEN
                       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
                    END IF;
      end;
      end if;
*/
      close c2;



 /* Bug 3586181 Update the contact id if the either Contract or GA has
                got a valid contact */
       if (c2_found='Y') then
       Begin

         if ( x_source_contact_id is not null) then
        update po_headers_interface
              set    vendor_contact_id = x_source_contact_id
              where  interface_header_id = x_interface_header_id;

         elsif (x_carry_contact_to_po_flag = 'FALSE') then -- Implies contacts in Req lines are different
              update po_headers_interface
              set    vendor_contact_id = NULL
              where  interface_header_id = x_interface_header_id;
         elsif (x_carry_contact_to_po_flag = 'TRUE') and (x_prev_sug_vendor_contact_id is not null) then
              update po_headers_interface
        set    vendor_contact_id = x_prev_sug_vendor_contact_id
              where  interface_header_id = x_interface_header_id;

          end if;
        end;
      end if;
 /* End 3586181 */
  else
	x_progress := '01: group_req_lines : c1_req_line_id = '|| to_char(c1_req_line_id)||'invalid style';
	IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;
  end if;  --if c1_valid_style --<R12 STYLES PHASE II>


   end loop;

   close c1;

   /* Calling process should do the commit, so comment out here.
    * COMMIT;
    */

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  x_progress := '60: group_req_lines: result = ACTIVITY_PERFORMED ';
  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

exception
  when others then
    close c1;
    close c2;
    wf_core.context('po_autocreate_doc','group_req_lines',x_progress);
    raise;
end group_req_lines;


/***************************************************************************
 *
 *  Procedure:  insert_into_headers_interface
 *
 *  Description:  Inserts a row into the po_headers_interface
 *  Returns false if creating PO header fails, and true otherwise (bug 3401653)
 *
 **************************************************************************/
function insert_into_headers_interface (itemtype         IN  VARCHAR2,
           itemkey         IN  VARCHAR2,
           x_group_id        IN  NUMBER,
           x_suggested_vendor_id       IN  NUMBER,
           x_suggested_vendor_site_id  IN  NUMBER,
           x_suggested_buyer_id      IN  NUMBER,
           x_source_doc_type_code      IN  VARCHAR2,
           x_source_doc_id       IN  NUMBER,
           x_currency_code       IN  VARCHAR2,
           x_rate_type         IN  VARCHAR2,
           x_rate_date         IN  DATE,
           x_rate          IN  NUMBER,
           x_pcard_id        IN  NUMBER,
                     p_style_id                  IN  NUMBER,  --<R12 STYLES PHASE II>
           x_interface_header_id   IN OUT NOCOPY  NUMBER)
RETURN boolean is --bug 3401653


x_batch_id      number;
x_creation_date     date  := sysdate;
x_last_update_date    date  := sysdate;
x_created_by      number;
x_last_updated_by   number;
x_org_id      number;
x_doc_type_to_create    varchar2(25);
x_release_date      date;
x_document_num      varchar2(25);
x_release_num     number;
x_release_num1      number;
x_currency_code_doc   varchar2(15);
x_found       varchar2(30);

x_no_releases     number;
x_ga_flag                       varchar2(1);   -- FPI GA
x_progress          varchar2(300);

x_grouping_allowed              varchar2(1); /* Bug 2974129 */
x_group_code                    po_headers_interface.group_code%TYPE; /* Bug 2974129 */
l_purchasing_org_id             po_headers_all.org_id%TYPE;  --<Shared Proc FPJ>

--begin bug 3401653
l_source_doc_currency_code      po_headers_all.currency_code%TYPE := NULL;
l_pou_currency_code      po_headers_all.currency_code%TYPE;
l_rou_currency_code      po_headers_all.currency_code%TYPE;
l_pou_sob_id             gl_sets_of_books.set_of_books_id%TYPE;
l_pou_default_rate_type  po_headers_all.rate_type%TYPE;
l_interface_rate         po_headers_all.rate%TYPE := NULL;
l_interface_rate_type    po_headers_all.rate_type%TYPE := NULL;
l_interface_rate_date    po_headers_all.rate_date%TYPE := NULL;
l_display_rate           po_headers_all.rate%TYPE := NULL;
--end bug 3401653

begin

   /* Set the org context. Backend create_po process assumes it is in
    * an org.
    */

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    --<Shared Proc FPJ START>

    x_progress := '10:insert_into_headers_interface:' ||
      'just before set_purchasing_org_id';

    set_purchasing_org_id(itemtype,
      itemkey,
      x_org_id,
      x_suggested_vendor_site_id);

    l_purchasing_org_id := po_wf_util_pkg.GetItemAttrNumber
                                        (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PURCHASING_ORG_ID');

    x_progress:= '20: insert_into_headers_interface: org_id = ' ||
    to_char(x_org_id) || ' purchasing_org_id = ' ||
    to_char(l_purchasing_org_id);

    --<Shared Proc FPJ END>


  /* Bug 2974129.
     This attribute should decide the grouping logic in Auto Create. If this is set Y,
     then the 'DEFAULT' will be populated as grope code else 'REQUISITION' will be
     populated as group code */

    x_grouping_allowed := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                          itemkey  => itemkey,
                                                          aname    => 'GROUPING_ALLOWED_FLAG');

   if x_grouping_allowed = 'N' then
          x_group_code := 'REQUISITION';
   else
          x_group_code := 'DEFAULT';
   end if;


   po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

   /* Get user values */

     --Bug 18465047 added the below IF clause.
     --This is to ensure buyer_id goes into po_headers_all as created_by and last_updated_by.
 	   IF  x_suggested_buyer_id IS NOT NULL THEN
 	         BEGIN
 	           SELECT user_id
 	           INTO   x_created_by
 	           FROM   fnd_user
 	           WHERE  employee_id = x_suggested_buyer_id
 	                  AND ROWNUM = 1;
 	         EXCEPTION
 	           WHEN no_data_found THEN
 	             x_created_by := to_number(fnd_profile.VALUE('user_id'));
 	         END;

 	      x_last_updated_by  := x_created_by;
 	   ELSE
       x_created_by       := to_number(FND_PROFILE.VALUE('user_id'));
       x_last_updated_by  := to_number(FND_PROFILE.VALUE('user_id'));
     END IF;


   /* Get the interface_header_id from the sequence */

   select po_headers_interface_s.nextval
     into x_interface_header_id
     from sys.dual;

   /* Set the batch id which can be the same as
    * the interface_header_id since we create only one
    * po at a time from workflow
    */

   x_batch_id := x_interface_header_id;

   /* If the source doc is a blanket then we are going to create a blanket release.
    * If the source doc is a quotation then we are going to create a standard po.
    */

  /* FPI GA - If ga flag is Y then we create a standard PO */

  -- Bug 2695074 getting the ga flag from the db as the attribute does not have any value
  -- in this process

   if x_source_doc_id is not null then
     select global_agreement_flag, currency_code
     into x_ga_flag, l_source_doc_currency_code
     from po_headers_all
     where po_header_id = x_source_doc_id;
   end if;

   /* Bug 2735730.
    * If x_source_doc_id is null, then it would be only in the case
    * when the supplier is set up as a consigned enabled and the
    * destination type is INVENTORY for the requisition. In this case,
    * we should still create a Standard PO. Hence x_doc_type_to_create
    * should be STANDARD in this case.
   */
   if (x_source_doc_id is null) then
     x_doc_type_to_create := 'STANDARD';
   else
     if (x_source_doc_type_code = 'BLANKET')
      and nvl(x_ga_flag,'N') = 'N' then  -- FPI GA
        x_doc_type_to_create    := 'RELEASE';
     else
        x_doc_type_to_create    := 'STANDARD';
     end if;
   end if;


   if (x_doc_type_to_create = 'STANDARD') then

     /* Whether automatic numbering is on our not, we are going to use
      * the automatic number from the unique identifier table. This is
      * as per req import. If however we have an  po num (eg. emergency po)
      * passed into the workflow then we need to use that.
      *
      * The autocreate backend will take whatever doc num we give it and
      * will try and create that. If we weren't to pass in a doc num and
      * automatic numbering was on, it would get the next number.
      *
      * If we are not using automatic numbering but we get the po num
      * from the unique identifier table then we could get a number that
      * has been used (entered manually by the user). We need to make sure
      * that the doc number is unique here since the backend expects that
      * when using manual numbering.
      */

     x_document_num := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PO_NUM_TO_CREATE');

     if (x_document_num is NULL) then

        x_progress := '30: insert_into_headers_interface: Just about to get doc' ||
           'num from po_unique_identifier_control';

  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

/*
   Bug# 1869409
   Created a function get_document_num  to get the next doucument
   Number from the PO_UNIQUE_IDENTIFIER_CONTROL table. This was
   done as the Commit after the UPDATE of the PO_UNIQUE_IDENTIFIER_CONTROL
   table was also affecting the Workflow transactions.
   The function get_document_num is an autonomous transaction.
*/
        --<Shared Proc FPJ>
        --Get document num in purchasing org
        x_document_num := get_document_num(l_purchasing_org_id);

        x_progress := '40: insert_into_headers_interface: Got doc' ||
           'num from po_unique_identifier_control';
  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

     end if;

     /* Check to make sure the doc num is not a duplicate */

     begin
        --<Shared Proc FPJ>
        --Modified the query to select from po_headers_all instead of po_headers.
        select 'PO EXISTS'
          into x_found
          from po_headers_all
         where segment1 = x_document_num
           and org_id = l_purchasing_org_id    -- <R12 MOAC>
           and type_lookup_code IN ('STANDARD', 'PLANNED', 'BLANKET', 'CONTRACT');

     exception
        when NO_DATA_FOUND then
             null;
  when others then
       /* We have found a duplicate so raise the exception */

             x_progress := '45: insert_into_headers_interface: document_num is a ' ||
         'duplicate - not going to insert into po_headers_interface';
       IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
       END IF;

       raise;
     end;

     x_release_num      := NULL;
     x_release_date     := NULL;


    --begin bug 3401653
    select sob.currency_code, fsp.set_of_books_id
      into l_pou_currency_code, l_pou_sob_id
      from financials_system_params_all fsp,
           gl_sets_of_books sob
     where fsp.set_of_books_id = sob.set_of_books_id
           and fsp.org_id = l_purchasing_org_id;  -- <R12 MOAC>

    select default_rate_type
      into l_pou_default_rate_type
      from po_system_parameters_all psp  --<Shared Proc FPJ>
     where psp.org_id = l_purchasing_org_id;    -- <R12 MOAC> removed nvl                  --<Shared Proc FPJ>

    select sob.currency_code
      into l_rou_currency_code
      from financials_system_params_all fsp,
           gl_sets_of_books sob
     where fsp.set_of_books_id = sob.set_of_books_id
           and fsp.org_id = x_org_id;
    --end bug 3401653

     /* Bug:565623. gtummala. 10/17/97
      * The backend also needs the currency_code to be populated in the
      * the po_headers_interface table. Should use functional currency if
      * its null.
      */
     if (x_currency_code is NULL) then
       x_currency_code_doc := l_pou_currency_code;
     else
       x_currency_code_doc := x_currency_code;
     end if;


    --begin bug 3401653

    IF(l_source_doc_currency_code is not null) THEN
        x_currency_code_doc := l_source_doc_currency_code;
    END IF;

    l_interface_rate_date := x_rate_date;
    IF(l_purchasing_org_id = x_org_id) THEN --x_org_id is req_org_id
       IF(x_currency_code_doc <> l_rou_currency_code) THEN
          --rate from req can go to po because pou=rou
          l_interface_rate_type := x_rate_type;
          l_interface_rate := x_rate;
       END IF;
    ELSE
        IF(l_pou_currency_code <> x_currency_code_doc) THEN
            IF l_pou_default_rate_type IS NULL THEN
                IF (g_po_wf_debug = 'Y') THEN
                    x_progress := '47: insert_into_headers_interface: Purchasing Operating unit' ||
              ' has no default rate type, cannot create PO';
                    po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
                END IF;
                return FALSE;
            END IF;

            -- copy rate info for PO currency to pou_currency
            l_interface_rate_type := l_pou_default_rate_type;
            l_interface_rate_date := trunc(sysdate);
            PO_CURRENCY_SV.get_rate(x_set_of_books_id => l_pou_sob_id,
                                    x_currency_code => x_currency_code_doc,
                                    x_rate_type => l_pou_default_rate_type,
                                    x_rate_date => l_interface_rate_date,
                                    x_inverse_rate_display_flag => 'N',
                                    x_rate => l_interface_rate,
                                    x_display_rate => l_display_rate);

       END IF;
       IF(l_rou_currency_code <> x_currency_code_doc) THEN
            IF l_pou_default_rate_type IS NULL THEN
                IF (g_po_wf_debug = 'Y') THEN
                    x_progress := '47: insert_into_headers_interface: Purchasing Operating unit' ||
              ' has no default rate type, cannot create PO';
                    po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
                END IF;

               return FALSE;
            END IF;

            -- Fail creation of the PO if there is no rate to convert from
            -- ROU currency to PO currency
            IF(PO_CURRENCY_SV.rate_exists (
                                      p_from_currency => l_rou_currency_code,
                                      p_to_currency => x_currency_code_doc,
                                      p_conversion_date => trunc(sysdate),
                                      p_conversion_type => l_pou_default_rate_type) <> 'Y')
                THEN
                IF (g_po_wf_debug = 'Y') THEN
                    x_progress := '48: insert_into_headers_interface: No rate defined to' ||
              ' convert from Requesting OU currency to PO currency, cannot create PO';
                    po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
                END IF;
                return FALSE;
            END IF;
       END IF;
    END IF;
    --end bug 3401653



   else

     -- Doc is RELEASE
     -- Bug 4471683
     -- If Currency code is null get the functional currency
     IF x_currency_code is not NULL THEN
       x_currency_code_doc := x_currency_code;
     ELSE
       x_currency_code_doc := PO_CORE_S2.get_base_currency;
     END IF;

     l_interface_rate_type := x_rate_type; --bug 3401653
     l_interface_rate_date := x_rate_date; --bug 3401653
     l_interface_rate := x_rate; --bug 3401653

     select segment1
       into x_document_num
       from po_headers
      where po_header_id = x_source_doc_id;

     /* Get the release number as the next release in sequence */

     select nvl(max(release_num),0)+1
       into x_release_num
       from po_releases_all por,    -- <R12 MOAC>
            po_headers poh
      where poh.po_header_id = x_source_doc_id
        and poh.po_header_id = por.po_header_id;

     /* Bug565530. gtummala. 10/23/97.
      * Even if the po_releases table gives us the next one in sequence,
      * this could conflict with a release_num that we have inserted into
      * the po_headers_interface table previously that has yet to converted
      * into a release eg. when we have two req lines that will be created
      * onto two diff. releases.
      */

     -- Bug 722352, lpo, 08/26/98
     -- Commented out the release_num filters for the next 2 queries.

     select count (*)
       into x_no_releases
       from po_headers_interface phi
      where phi.document_num = x_document_num;
      -- and phi.release_num  = x_release_num;

     if (x_no_releases <> 0) then
       select max(release_num)+1
   into x_release_num1
         from po_headers_interface phi
        where phi.document_num = x_document_num;
  --  and phi.release_num  = x_release_num;
     end if;

     -- End of fix. Bug 722352, lpo, 08/26/98



     -- <Action Date TZ FPJ>
      /* Bug 638599, lpo, 03/26/98
       * Strip out time portion to be consistent with Enter Release form.
       * 10/22/2003: Action Date TZ FPJ Change
       * Since release_date on the Enter Release form is now
       * a datetime, the trunc is now removed.
       */
      /* Set release date to sysdate */
      x_release_date := SYSDATE;

      -- <End Action Date TZ FPJ>


    end if;

    /* dreddy : bug 1394312 */
    if (x_release_num1 >= x_release_num) then
     x_release_num := x_release_num1;
    end if;

   /* Insert into po_headers_inteface */

   x_progress := '50: insert_into_headers_interface: Just about to insert into ' ||
      'po_headers_interface';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   x_progress :=  '11: the doc type to be created ' || x_doc_type_to_create ;

    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    begin
      insert into po_headers_interface
              (wf_group_id,
         interface_header_id,
               interface_source_code,
               batch_id,
               process_code,
               action,
                 document_type_code,
               document_subtype,
               document_num,
               group_code,
               vendor_id,
               vendor_site_id,
         release_num,
               release_date,
               agent_id,
         currency_code,
         rate_type_code,
         rate_date,
         rate,
         creation_date,
         created_by,
             last_update_date,
         last_updated_by,
         pcard_id,
                 style_id     --<R12 STYLES PHASE II>
                 )
            values
              (x_group_id,
         x_interface_header_id,
               'PO',
               x_batch_id,
         'NEW',
               'NEW',
               'PO',                -- PO for both po's and releases
               x_doc_type_to_create,
               x_document_num,
               x_group_code, /* Bug 2974129 */
               x_suggested_vendor_id,
               x_suggested_vendor_site_id,
         x_release_num,
         x_release_date,
               x_suggested_buyer_id,
         x_currency_code_doc,
         l_interface_rate_type, --bug 3401653
         l_interface_rate_date, --bug 3401653
         l_interface_rate, --bug 3401653
         x_creation_date,
         x_created_by,
         x_last_update_date,
         x_last_updated_by,
         x_pcard_id,
                 p_style_id     --<R12 STYLES PHASE II>
                 );

                 return TRUE; --bug 3401653

    exception
        when others then
    x_progress := '55: insert_into_headers_interface: IN EXCEPTION when '||
      'inserting into po_headers_interface';
          IF (g_po_wf_debug = 'Y') THEN
             po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;

          raise;
    end;

    x_progress := '60: insert_into_headers_interface: Inserted into ' ||
      'po_headers_interface';
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    /* The interface_header_id is returned as an out parameter so that
     * subsequent lines can be tied to this same header if needed.
     */


exception
  when others then
    wf_core.context('po_autoinsert_into_headers_interface','create_doc',x_progress);
    raise;
end insert_into_headers_interface;


/***************************************************************************
 *
 *  Procedure:  insert_into_lines_interface
 *
 *  Description:  Inserts a row in the po_lines_interface table
 *
 *
 **************************************************************************/
procedure insert_into_lines_interface (itemtype         IN VARCHAR2,
               itemkey          IN VARCHAR2,
               x_interface_header_id  IN NUMBER,
               x_req_line_id        IN NUMBER,
               x_source_doc_line      IN NUMBER,
               x_source_doc_type_code IN VARCHAR2,
                                       x_contract_id          IN NUMBER,
                                       x_source_doc_id        IN NUMBER,            -- GA FPI
                                       x_cons_from_supp_flag  IN VARCHAR2) is       -- Consigned FPI

-- <GC FPJ> : removed variable x_contract_num

x_interface_line_id       number;
x_creation_date     date  := sysdate;
x_last_update_date    date  := sysdate;
x_created_by      number;
x_last_updated_by   number;
x_org_id      number;
x_doc_type_to_create    varchar2(25);
x_action_type_code_line   varchar2(3);
x_line_num      number;
x_progress          varchar2(300);
x_source_line_id                number;
x_ga_flag                       varchar2(1);

begin

   /* Set the org context. Backend create_po process assumes it is in
    * an org.
    */

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

   /* Get user values */

   x_created_by       := to_number(FND_PROFILE.VALUE('user_id'));
   x_last_updated_by  := to_number(FND_PROFILE.VALUE('user_id'));

   /* FPI GA - If ga flag is Y then we create a standard PO */

   if x_source_doc_id is not null then
     select global_agreement_flag
     into x_ga_flag
     from po_headers_all
     where po_header_id = x_source_doc_id;
   end if;

   /* Bug 2735730.
    * If x_source_doc_id is null, then it would be only in the case
    * when the supplier is set up as a consigned enabled and the
    * destination type is INVENTORY for the requisition. In this case,
    * we should still create a Standard PO. Hence x_doc_type_to_create
    * should be STANDARD in this case.
   */
   if (x_source_doc_id is null) then
  x_doc_type_to_create := 'STANDARD';
   else
     if (x_source_doc_type_code = 'BLANKET')
      and nvl(x_ga_flag,'N') = 'N' then  -- FPI GA
        x_doc_type_to_create    := 'RELEASE';
     else
        x_doc_type_to_create    := 'STANDARD';
     end if;
   end if;

   if (x_doc_type_to_create = 'STANDARD') then
     x_action_type_code_line  := NULL;
     x_line_num           := NULL;

     -- <GC FPJ START>
     -- We can now insert contract_id into po_lines_interface directly
     -- and therefore no need to derive contract_num

     --if (x_contract_id is not null) then
     --
     --  select max(segment1)
     --    into x_contract_num
     --    from po_headers
     --   where po_header_id = x_contract_id;
     --
     --end if;

     -- <GC FPJ END>

   else
      /* RELEASE */
      x_action_type_code_line := 'ADD';
      x_line_num        :=  x_source_doc_line;
    end if;


    select po_lines_interface_s.nextval
      into x_interface_line_id
      from sys.dual;

    /*  GA FPI start */

     if  x_source_doc_id is not null and
         x_source_doc_line is not null then

    -- SQL what  Get the line id from the source doc line
    -- SQL why    Requisition line does not store the line id
    -- Bug fix 2703592 - need to select from all table instead of po_lines
         Select  po_line_id
         into x_source_line_id
         From po_lines_all
         Where  po_header_id = x_source_doc_id
         And line_num = x_source_doc_line;

     end if;

    /*  GA FPI end */

    /* Insert into po_lines */

    x_progress :=  '10: insert_into_lines_interface: Just about to insert into ' ||
       'po_lines_interface';

    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    x_progress :=  '11: the doc type to be created ' || x_doc_type_to_create ;

    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

/*Bug11802312 We ll retain the document reference for an consigned PO*/
    begin
      insert into po_lines_interface
                  (interface_header_id,
                interface_line_id,
          action,
                line_num,
                shipment_num,
                requisition_line_id,
                                contract_id,     -- <GC FPJ>
                                from_header_id, -- GA FPI
                                from_line_id,   -- GA FPI
                                consigned_flag,  -- Bug 2798503
        creation_date,
        created_by,
            last_update_date,
        last_updated_by)
            values
              (x_interface_header_id,
                 x_interface_line_id,
           x_action_type_code_line,
                 x_line_num,
                 null,
                 x_req_line_id,
                                 x_contract_id,   -- <GC FPJ>
                                 x_source_doc_id ,  -- Consigned FPI
                                 x_source_line_id,  -- Consigned FPI
                                 x_cons_from_supp_flag,    -- Bug 2798503
         x_creation_date,
         x_created_by,
         x_last_update_date,
         x_last_updated_by);

     exception
        when others then
           x_progress:= '15: insert_into_lines_interface: IN EXCEPTION when' ||
      'inserting into po_lines_interface';
     IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;
     raise;
     end;

     x_progress := '20: insert_into_lines_interface: Inserted into ' ||
       'po_lines_interface';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;


exception
  when others then
    wf_core.context('po_autoinsert_into_lines_interface','insert_into_lines_interface',
                      x_progress);
    raise;
end insert_into_lines_interface;


/***************************************************************************
 *
 *  Procedure:  launch_doc_creation_approval
 *
 *  Description:  Launches the child doc creation and approval process
 *      per document.
 *
 **************************************************************************/
procedure launch_doc_creation_approval (itemtype   IN   VARCHAR2,
                          itemkey    IN   VARCHAR2,
                          actid      IN   NUMBER,
                          funcmode   IN   VARCHAR2,
                          resultout  OUT NOCOPY  VARCHAR2 )  is

x_ItemType              varchar2(20) := itemtype; /* Calling proc has same
               * item type as called proc
                 */
x_ItemKey               varchar2(60) := null;
x_workflow_process      varchar2(40) := 'CREATE_AND_APPROVE_DOC';
x_group_id    number;
x_interface_header_id   number;
x_doc_type_to_create  varchar2(25);
x_seq_for_item_key  varchar2(25)  := null; --Bug14305923
x_agent_id    number;
x_org_id    number;
l_purchasing_org_id   number;  --<Shared Proc FPJ>
x_progress        varchar2(300);
l_vendor_site_id        PO_HEADERS_ALL.vendor_site_id%TYPE := NULL; --<BUG 3538308>

cursor c1 is        /* x_group_id is a parameter */
     select interface_header_id,
      document_subtype,
      agent_id,
            vendor_site_id --<BUG 3538308>
       from po_headers_interface
      where wf_group_id = x_group_id
   order by interface_header_id;


begin

   /* Set the org context. Backend create_po process assumes it is in
    * an org.
    */

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>


    /* Get the group id so we can launch doc creation and approval
     * for this group.
     */

    x_group_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'GROUP_ID');

   open c1;  /* x_group_id is a parameter */

   loop
      fetch c1 into x_interface_header_id,
        x_doc_type_to_create,
        x_agent_id,
                    l_vendor_site_id;  --<BUG 3538308>
      exit when c1%NOTFOUND;

      --<BUG 3538308 START>
      --For every iteration of the for-loop, need to set purchasing_org_id for
      --the PO document to be created. The purchasing_org_id retrieved here
      --is passed into po_autocreate_doc.start_wf_create_apprv_process.

      x_progress:= '5: launch_doc_creation_approval: before set_purchasing_org_id: ' ||
                   ' x_org_id (from workflow)= '|| to_char(x_org_id) ||
                   ' l_vendor_site_id (from interface table)='||to_char(l_vendor_site_id);

      set_purchasing_org_id(itemtype                   => itemtype,
                            itemkey                    => itemkey,
                            p_org_id                   => x_org_id,
                            p_suggested_vendor_site_id => l_vendor_site_id);

      l_purchasing_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                                               itemkey  => itemkey,
                                                               aname    => 'PURCHASING_ORG_ID');

      x_progress:= '6: launch_doc_creation_approval: after set_purchasing_org_id: ' ||
                   ' l_purchasing_org_id (from workflow)= '|| to_char(l_purchasing_org_id) ||
                   ' x_org_id (from workflow)= '|| to_char(x_org_id) ||
                   ' l_vendor_site_id (from interface table)='||to_char(l_vendor_site_id);

      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     x_progress => x_progress);
      END IF;

      --<BUG 3538308 END>

      /* Get the unique sequence to make sure item key will be unique */

      select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
        into x_seq_for_item_key
        from sys.dual;

      /* The item key is the interface_header_id concatenated with the
       * unique id from a seq.
       */

      x_ItemKey := to_char(x_interface_header_id) || '-' || x_seq_for_item_key;

      /* Launch the req line processing process
       *
       * Need to pass in the parent's itemtype and itemkey so as to
       * all the parent child relationship to be setup in the called
       * process.
       */

      x_progress:= '10: launch_doc_creation_approval: '||
      ' Called start_wf_create_apprv_process with itemkey = '||
        x_Itemkey;
      IF (g_po_wf_debug = 'Y') THEN
         po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      po_autocreate_doc.start_wf_create_apprv_process (x_ItemType,
                                               x_ItemKey,
                                               x_workflow_process,
                         x_interface_header_id,
                   x_doc_type_to_create,
                   x_agent_id,
                   x_org_id,
                   l_purchasing_org_id, --<Shared Proc FPJ>
                   itemtype,
                   itemkey);



   end loop;
   close c1;

   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

   x_progress := '20: launch_doc_creation_approval: result = ACTIVITY_PERFORMED';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc.launch_doc_creation_approval','launch_doc_creation_approval',
                      x_progress);
    raise;
end launch_doc_creation_approval;


/***************************************************************************
 *
 *  Procedure:  start_wf_create_apprv_process
 *
 *  Description:  Creates and starts the 'CREATE_AND_APPROVE_DOC'
 *      workflow proccess.
 *
 **************************************************************************/
procedure start_wf_create_apprv_process (ItemType             VARCHAR2,
                                     ItemKey              VARCHAR2,
                                     workflow_process     VARCHAR2,
                   interface_header_id    NUMBER,
           doc_type_to_create VARCHAR2,
           agent_id   NUMBER,
           org_id     NUMBER,
           purchasing_org_id  NUMBER, --<Shared Proc FPJ>
           parent_itemtype  VARCHAR2,
           parent_itemkey   VARCHAR2) is

x_progress    varchar2(300);

begin

  x_progress := '10: start_wf_create_apprv_process: This was called with' ||
     'ItemType = ' || ItemType || '/ ' || 'ItemKey = ' || ItemKey;

  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  /* If a process is passed then it will be run
   * If a process is not passed then the selector function defined in
   * item type will be determine which process to run
   */

  IF  (ItemType    is NOT NULL ) AND
      (ItemKey     is NOT NULL)  AND
      (interface_header_id is NOT NULL ) then
        wf_engine.CreateProcess(itemtype => itemtype,
                                itemkey  => itemkey,
                                process  => workflow_process );

        x_progress:= '20. start_wf_create_apprv_process: Just after create process';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

  /* Set the item attributes */

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'ORG_ID',
                                     avalue     => org_id);

  --<Shared Proc FPJ START>
  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'PURCHASING_ORG_ID',
                                     avalue     => purchasing_org_id);
  --<Shared Proc FPJ END>

  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'INTERFACE_HEADER_ID',
                                     avalue     => interface_header_id);


  po_wf_util_pkg.SetItemAttrText   (itemtype    => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'DOC_TYPE_TO_CREATE',
                                     avalue     => doc_type_to_create);


        po_wf_util_pkg.SetItemAttrNumber (itemtype    => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'AGENT_ID',
                                     avalue     => agent_id);


  /* Need to set the parent child relationship between processes */

  wf_engine.SetItemParent (itemtype        => itemtype,
         itemkey         => itemkey,
         parent_itemtype => parent_itemtype,
         parent_itemkey  => parent_itemkey,
         parent_context  => NULL);


        /* Kick off the process */

        x_progress:= '30. start_wf_create_apprv_process: Kicking off StartProcess ' ||
               'with item_type = ' || itemtype || '/ ' || 'item_key = ' ||
          itemkey;
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        wf_engine.StartProcess(itemtype => itemtype,
                               itemkey  => itemkey );

    END IF;

exception
  when others then
   x_progress:= '40. start_wf_create_apprv_process: IN EXCEPTION';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;
   raise;
end start_wf_create_apprv_process;


/***************************************************************************
 *
 *  Procedure:  create_doc
 *
 *  Description:  Calls backend autocreate package to create the
 *      standard po or blanket release
 *
 *
 **************************************************************************/
procedure create_doc (itemtype   IN   VARCHAR2,
                      itemkey     IN   VARCHAR2,
                      actid       IN   NUMBER,
                      funcmode    IN   VARCHAR2,
                      resultout   OUT NOCOPY  VARCHAR2 ) is

x_interface_header_id     number;
x_num_lines_processed     number;
x_autocreated_doc_id    number;
x_org_id      number;
x_progress          varchar2(300);

--<Shared Proc FPJ START>
l_purchasing_org_id             PO_HEADERS_ALL.org_id%TYPE;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      FND_NEW_MESSAGES.message_text%TYPE;
l_doc_number                    PO_HEADERS_ALL.segment1%TYPE;
--<Shared Proc FPJ END>

x_group_shipments varchar2(1);             --<Bug 14608120 Autocreate GE ER>
x_operting_unit_id    Number;              --<Bug 14608120 Autocreate GE ER>

begin

   /* Set the org context. Backend create_po process assumes it is in
    * an org.
    */

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');
    --<Shared Proc FPJ START>
    l_purchasing_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PURCHASING_ORG_ID');
    --<Shared Proc FPJ END>

    PO_MOAC_UTILS_PVT.set_org_context(x_org_id); --<R12 MOAC>
    x_interface_header_id := po_wf_util_pkg.GetItemAttrNumber
              (itemtype  => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'INTERFACE_HEADER_ID');




    /* Call the main sever side routine to actually create
     * the documents, ie:
     *      - default in values not populated
     *      - group accordingly
     *      - insert into the main tables from the
     *        the interface tables.
     *
     * x_document_id is populated with po_header_id for pos
     * and po_release_id for releases
     */


     x_progress:= '10: create_doc: Kicking off backend with' ||
            'interface_header_id = '|| to_char(x_interface_header_id);
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

	--<Bug 14608120 Autocreate GE ER Start>
    /*Logic to get the group shipments value in the purchasing options
    and pass it to create_document proc*/

    select nvl(group_shipments_flag, 'Y')
    into x_group_shipments
    from po_system_parameters;

    --<Bug 14608120 Autocreate GE ER End>

     --<Shared Proc FPJ>
     --Call Autocreate Backend to create the document
     --in the purchasing org specified.
     po_interface_s.create_documents(p_api_version              => 1.0,
                                     x_return_status            => l_return_status,
                                     x_msg_count                => l_msg_count,
                                     x_msg_data                 => l_msg_data,
                                     p_batch_id                 => x_interface_header_id,
                                     p_req_operating_unit_id  => x_org_id,
                                     p_purch_operating_unit_id  => l_purchasing_org_id,
                                     x_document_id              => x_autocreated_doc_id,
                                     x_number_lines             => x_num_lines_processed,
                                     x_document_number        => l_doc_number,
                 -- Bug 3648268. Using lookup code instead of hardcoded value
                                     p_document_creation_method => 'CREATEDOC',
                                     p_orig_org_id              => x_org_id,    -- <R12 MOAC>
									 p_group_shipments          => x_group_shipments  --<Bug 14608120 Autocreate GE ER>
                                    );


     x_progress := '20: create_doc: Came back from the backend with '  ||
       'doc_id = ' || to_char(x_autocreated_doc_id) || '/ ' ||
       'num_lines_processed = ' || to_char(x_num_lines_processed);

     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;


     /* If at least one req line got processed then we have succeeded in
      * creating the po or release
      */

     if (x_num_lines_processed > 0) then
       po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      => 'AUTOCREATED_DOC_ID',
                                    avalue     => x_autocreated_doc_id);

       /* Call procedure to setup notification data which will be used
        * in sending a notification to the buyer that the doc has been
        * created successfully.
        */

       po_autocreate_doc.setup_notification_data (itemtype, itemkey);

       resultout := wf_engine.eng_completed || ':' ||  'CREATE_OK';

       x_progress:= '30: create_doc: result = CREATE_OK';
       IF (g_po_wf_debug = 'Y') THEN
          po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
       END IF;

     else
       resultout := wf_engine.eng_completed || ':' ||  'CREATE_FAILED';

       x_progress:= '40: create_doc: result = CREATE_FAILED';
       IF (g_po_wf_debug = 'Y') THEN
          po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
       END IF;

     end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','create_doc',x_progress);
    raise;
end create_doc;


/***************************************************************************
 *
 *  Procedure:  setup_notification_data
 *
 *  Description:  Setup all the data (item attributes etc) needed
 *      for the notification.
 *
 **************************************************************************/
procedure setup_notification_data (itemtype   IN   VARCHAR2,
                             itemkey    IN   VARCHAR2) is



x_doc_type_to_create          varchar2(25);
x_doc_type_created_disp   varchar2(80);
x_segment1      varchar2(20);
x_release_num     number;
x_agent_id      number;
x_username          varchar2(100);
x_user_display_name     varchar2(240);
x_autocreated_doc_id    number;
l_open_form                     varchar2(200); --Bug#2982867
l_view_po_url varchar2(1000);   -- HTML Orders R12
l_edit_po_url varchar2(1000);   -- HTML Orders R12
l_style_id    po_headers_all.style_id%TYPE;  -- HTML Orders R12

x_progress          varchar2(300);

--Added as part of bug 16838186 fix
l_display_name varchar2(240);
l_email_address varchar2(240);
l_notification_preference  varchar2(240);
l_language  varchar2(240);
l_territory varchar2(240);
l_language_code fnd_languages.language_code%TYPE;

begin

   x_doc_type_to_create := po_wf_util_pkg.GetItemAttrText
            (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'DOC_TYPE_TO_CREATE');

   x_autocreated_doc_id := po_wf_util_pkg.GetItemAttrNumber
            (itemtype   => itemtype,
                                         itemkey    => itemkey,
                                         aname      => 'AUTOCREATED_DOC_ID');


   x_agent_id :=  po_wf_util_pkg.GetItemAttrNumber
              (itemtype  => itemtype,
                                      itemkey    => itemkey,
                                      aname      => 'AGENT_ID');


   --Start of code changes for the bug 16838186 fix
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,'x_agent_id : '||x_agent_id);
   END IF;
   po_reqapproval_init1.get_user_name(x_agent_id, x_username, x_user_display_name); --replaced from bottom to here.

   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,'x_username : '||x_username);
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,'x_user_display_name : '||x_user_display_name);
   END IF;

   WF_DIRECTORY.GETROLEINFO(
			     x_username,
			     l_display_name,
			     l_email_address,
			     l_notification_preference,
			     l_language,
			     l_territory);

   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,'l_language : '||l_language);
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,'l_display_name : '||l_display_name);
   END IF;

   BEGIN
      select language_code INTO l_language_code
      FROM fnd_languages
      WHERE nls_language = l_language;

      IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,'l_language_code : '||l_language_code);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        l_language_code := NULL;
   END;

   /* Get the displayed value from po_lookup_codes so it will be translated
    * This will return either 'Standard PO' or 'Release'
    */
   --<R12 STYLES PHASE II START>
   if (x_doc_type_to_create = 'STANDARD') then
       x_doc_type_created_disp:= PO_DOC_STYLE_PVT.get_style_display_name(x_autocreated_doc_id, l_language_code);
   else    --releases

     select displayed_field
       into x_doc_type_created_disp
       from po_lookup_codes
      where lookup_type = 'NOTIFICATION TYPE'
        and lookup_code = x_doc_type_to_create;
   end if;
     --<R12 STYLES PHASE II END>
   --END of code changes for the bug 16838186 fix


   po_wf_util_pkg.SetItemAttrText   (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'DOC_TYPE_CREATED_DISP',
                                avalue     => x_doc_type_created_disp);

   /* Get the document number created */

   if (x_doc_type_to_create = 'STANDARD') then

     --<Shared Proc FPJ>
     --Modified the query to select from po_headers_all instead of
     --po_headers.
     --< HTML Orders R12>
     -- selected style id
     select segment1,
            style_id
       into x_segment1,
            l_style_id
       from po_headers_all
      where po_header_id = x_autocreated_doc_id;


     po_wf_util_pkg.SetItemAttrText   (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'DOC_NUM_CREATED',
                                  avalue     => x_segment1);

     /* Bug 2982867, Assigning the proper Command and setting the item
     attribute to open PO or Release Form depending on what
     document was created. */
     -- <HTML Orders R12 Start >
     -- Set the URL and form link attributes based on doc style and type
     l_view_po_url := PO_REQAPPROVAL_INIT1.get_po_url(
                                    p_po_header_id    => x_autocreated_doc_id,
                                    p_doc_subtype  => x_doc_type_to_create,
                                    p_mode         => 'viewOnly');

     l_edit_po_url := PO_REQAPPROVAL_INIT1.get_po_url(
                                    p_po_header_id    => x_autocreated_doc_id,
                                    p_doc_subtype  => x_doc_type_to_create,
                                    p_mode         => 'update');

     IF PO_DOC_STYLE_GRP.is_standard_doc_style(l_style_id) = 'Y' THEN
       l_open_form := 'PO_POXPOEPO:PO_HEADER_ID="' || '&' ||
                      'AUTOCREATED_DOC_ID"' ||
                      ' ACCESS_LEVEL_CODE="MODIFY"' ||
                      ' POXPOEPO_CALLING_FORM="POXSTNOT"';
     ELSE
       l_open_form := null;
     END IF;
     -- <HTML Orders R12 End >
   else
     /* RELEASE */

     select poh.segment1,
      por.release_num
       into x_segment1,
      x_release_num
       from po_headers_all  poh,    -- <R12 MOAC>
            po_releases por
      where por.po_release_id = x_autocreated_doc_id
  and por.po_header_id  = poh.po_header_id;

      /* Append the release num to blanket po num */

      po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'DOC_NUM_CREATED',
                                  avalue     => x_segment1 || ', ' ||
                  to_char (x_release_num));

     -- HTML Orders R12: HTML URLs not applicable for releases
     l_view_po_url := '';
     l_edit_po_url := '';
     -- Bug 2982867
     l_open_form := 'PO_POXPOERL:PO_RELEASE_ID="' || '&' ||
                    'AUTOCREATED_DOC_ID"' ||
                    ' ACCESS_LEVEL_CODE="MODIFY"' ||
                    ' POXPOERL_CALLING_FORM="POXSTNOT"';
   end if;

    PO_WF_UTIL_PKG.SetItemAttrText   (itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'OPEN_FORM_COMMAND',
                                  avalue     =>l_open_form );

    -- HTML Orders R12
    -- Set the URL and form attributes
    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'VIEW_DOC_URL' ,
                              avalue     => l_view_po_url);

    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'EDIT_DOC_URL' ,
                              avalue     => l_edit_po_url);

   /* Need to get the username (webuser) of the person we want to send
    * to send the notification to.
    *
    * Call po_req_approval_init1.get_user_name which then calls
    * wf.GetUserName to get the info.
    *
    * The agent_id in the po_agents table has the same value as the employee_id
    * in the HR_EMPLOYEES view for the corresponding employee so we can pass in
    * agent_id
    */

   x_progress := '10: setup_notification_data: Got the doc num created.' ||
     'Just before call to get_user_name';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   po_wf_util_pkg.SetItemAttrText   (itemtype   => itemtype,
                                itemkey    => itemkey,
                                aname      => 'BUYER_USERNAME',
                                avalue     => x_username);


   x_progress := '20: setup_notification_data: Username = ' || x_username ||
     'End of setup_notification_data';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

exception
  when others then
    wf_core.context('po_autosetup_notification_data','setup_notification_data',x_progress);
    raise;
end setup_notification_data;


/***************************************************************************
 *
 *  Procedure:  should_doc_be_approved
 *
 *  Description:  Decides whether document approval process should
 *      be kicked off or not.
 *
 **************************************************************************/
procedure should_doc_be_approved (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 ) is

x_auto_approve_doc   varchar2(1);
x_progress           varchar2(300);

--<R12 eTax Integration Start>
l_doc_type_to_create    po_headers_all.type_lookup_code%TYPE;
l_doc_type              po_document_types_all_b.document_type_code%TYPE;
l_doc_subtype           po_document_types_all_b.document_subtype%TYPE;
l_po_header_id          po_headers_all.po_header_id%TYPE;
l_po_release_id         po_releases_all.po_release_id%TYPE;
l_return_status         VARCHAR2(1);
--<R12 eTax Integration End>

--start of code changes for the bug 14243104 fix
l_document_id NUMBER;
l_document_number VARCHAR2(80);
l_emailaddress VARCHAR2(2000);
l_default_method VARCHAR2(25);
l_fax_number VARCHAR2(25);
l_preparer_id NUMBER;
--end of code changes for the bug 14243104 fix

begin

   /* This decision is made by simply looking at an item atrribute,
    * which has a default value. All the user needs to do is change
    * that attribute according to their needs.
    */
   --<R12 eTax Integration Start>
   --
   -- Calculate tax before launching approval process
   -- If tax calculation is success and the wf attribute AUTO_APPROVE_DOC
   -- is set to Y then this function would return Y else it would
   -- return N. So Approval depends on tax calculation being successful
   --
   --<R12 eTax Integration End>
   x_auto_approve_doc := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'AUTO_APPROVE_DOC');


   --<R12 eTax Integration Start>
   l_po_release_id      := null;
   l_po_header_id       := null;
   l_doc_type_to_create := null;
   l_doc_type           := null;
   l_doc_subtype        := null;
   l_return_status      := null;
   l_doc_type_to_create := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'DOC_TYPE_TO_CREATE');

   IF (l_doc_type_to_create = PO_CONSTANTS_SV.RELEASE) THEN
      l_doc_type      := PO_CONSTANTS_SV.RELEASE;
      l_doc_subtype   := PO_CONSTANTS_SV.BLANKET;
      l_po_release_id := po_wf_util_pkg.GetItemAttrNumber
                              (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'AUTOCREATED_DOC_ID');
      l_document_id := l_po_release_id;  --bug 14243104 fix
   ELSE
      l_doc_type      := PO_CONSTANTS_SV.PO;
      l_doc_subtype   := PO_CONSTANTS_SV.STANDARD;
      l_po_header_id  := po_wf_util_pkg.GetItemAttrNumber
                              (itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'AUTOCREATED_DOC_ID');
      l_document_id := l_po_header_id;  --bug 14243104 fix
   END IF;

   po_tax_interface_pvt.calculate_tax(p_po_header_id    => l_po_header_id,
                                      p_po_release_id   => l_po_release_id,
                                      x_return_status   => l_return_status,
                                      p_calling_program => 'AUTOCREATED_DOC_WF');

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,'Tax Errored ');
     END IF;
   END IF;

   --<R12 eTax Integration End>

   if (x_auto_approve_doc = 'Y' AND l_return_status = FND_API.G_RET_STS_SUCCESS) then   --<R12 eTax Integration>
      --Start of code changes for the bug 14243104 fix
      l_preparer_id := NULL;
      PO_VENDOR_SITES_SV.Get_Transmission_Defaults(
          p_document_id => l_document_id,
          p_document_type => l_doc_type,
          p_document_subtype => l_doc_subtype,
          p_preparer_id => l_preparer_id,
          x_default_method => l_default_method,
          x_email_address => l_emailaddress,
          x_fax_number => l_fax_number,
          x_document_num => l_document_number);

      IF l_default_method = 'EMAIL' AND (l_emailaddress IS NULL OR l_emailaddress='') THEN
          resultout := wf_engine.eng_completed || ':' ||  'N';

          x_progress:= '0: should_doc_be_approved: result = N';
          IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;

      ELSIF l_default_method = 'FAX' AND (l_fax_number IS NULL OR l_fax_number='') THEN
          resultout := wf_engine.eng_completed || ':' ||  'N';

          x_progress:= '1: should_doc_be_approved: result = N';
          IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;
      ELSE
          resultout := wf_engine.eng_completed || ':' ||  'Y';

          x_progress:= '10: should_doc_be_approved: result = Y';
          IF (g_po_wf_debug = 'Y') THEN
              po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
          END IF;
      END IF;
      --END of code changes for the bug 14243104 fix

   else
     resultout := wf_engine.eng_completed || ':' ||  'N';

     x_progress:= '20: should_doc_be_approved: result = N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','should_doc_be_approved',x_progress);
    raise;
end should_doc_be_approved;



/***************************************************************************
 *
 *  Procedure:  launch_po_approval
 *
 *  Description:  Kicks off the po approval workflow to approve the
 *      po or the release
 *
 **************************************************************************/
procedure launch_po_approval (itemtype   IN   VARCHAR2,
                              itemkey    IN   VARCHAR2,
                              actid      IN   NUMBER,
                              funcmode   IN   VARCHAR2,
                              resultout  OUT NOCOPY  VARCHAR2 ) is

x_ItemType              varchar2(20) := null;
x_ItemKey               varchar2(60) := null;
x_workflow_process      varchar2(40) := null;
/*Bug 10418763 Set the action_orig_from parameter as "CREATEDOC" */
x_action_orig_from      varchar2(30) := 'CREATEDOC';
x_doc_id                number       := null;
x_doc_num         po_headers.segment1%type := null; -- Bug 3152167
x_preparer_id           number       := null;
x_doc_type              varchar2(25) := null;
x_doc_subtype           varchar2(25) := null;
x_submitter_action      varchar2(25) := null;
x_forward_to_id         number       := null;
x_forward_from_id       number       := null;
x_def_approval_path_id  number       := null;
x_note      varchar2(240):= null;
x_seq_for_item_key  varchar2(25)  := null; --Bug14305923
x_doc_type_to_create    varchar2(25);
x_org_id    number;
x_progress        varchar2(300);
x_printflag             varchar2(1)    := 'N';
x_faxflag               varchar2(1)    := 'N';
x_faxnum                varchar2(30)   := null;
x_fax_area              varchar2(10)   := null;  -- bug 2567900
x_emailflag             varchar2(1)    := 'N';
x_emailaddress          varchar2(2000) := null;
x_default_method        varchar2(25)   := null;


  /* RETROACTIVE FPI START */
  l_document_num      po_headers.segment1%type;
  /* RETROACTIVE FPI END */

/* <SUP_CON FPI START> */
l_consigned_consumption_flag po_headers_all.consigned_consumption_flag%TYPE;
/* <SUP_CON FPI END> */

l_purchasing_org_id       po_headers_all.org_id%TYPE; --<Shared Proc FPJ>

/* BUG 4638656 */
l_tp_header_id             ece_tp_details.tp_header_id%TYPE;
l_edi_flag                 ece_tp_details.edi_flag%TYPE;
l_transaction_subtype      ece_tp_details.document_id%TYPE;
/* BUG 4638656 */



begin

    x_org_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

    --<Shared Proc FPJ START>
    l_purchasing_org_id := po_wf_util_pkg.GetItemAttrNumber
                                        (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PURCHASING_ORG_ID');
    --<Shared Proc FPJ END>


/* Bug: 1479382 set the org contect */

   IF x_org_id IS NOT NULL THEN

     po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

     --<Shared Proc FPJ START>
     IF x_org_id <> l_purchasing_org_id THEN
       --Set the org_id to be the purchasing org for PO Approval Process
       po_wf_util_pkg.SetItemAttrNumber(itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'ORG_ID',
                                        avalue     => l_purchasing_org_id);
       --Set the context to be that of purchasing org
       po_moac_utils_pvt.set_org_context(l_purchasing_org_id); --<R12 MOAC>

     END IF;
     --<Shared Proc FPJ END>
   END IF;

    x_doc_type_to_create := po_wf_util_pkg.GetItemAttrText
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOC_TYPE_TO_CREATE');

   if (x_doc_type_to_create = 'RELEASE') then
      x_doc_type    := 'RELEASE';
      x_doc_subtype := 'BLANKET';
   else
      /* STANDARD */
      x_doc_type    := 'PO';
      x_doc_subtype := 'STANDARD';
   end if;

   /* Need to get item_type and workflow process from po_document_types.
    * They may be different based on the doc/org.
    */


   /* Get the doc_id, doc_num and preparer_id */

   /* The preparer is the same as the buyer */

   x_preparer_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUGGESTED_BUYER_ID');

   x_doc_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'AUTOCREATED_DOC_ID');


   /* Bug 712718 ecso 08/17/98
   ** PO Approval workflow requires a non-null preparer_id
   ** Since attributes from another child workflow is not
   ** passed to this child workflow, hit the table to get
   ** the agent id.
    */

    /* RETROACTIVE FPI START.
    * Deleted  the  code which gets teh preparer_id if it is null since
    * x_preparer_id will be derived in get_transmission_defaults if
    * this is null. Also deleted the code which gets the default supplier
    * communication method from po_vendor_site and now call
    * PO_VENDOR_SITES_SV.Get_Transmission_Defaults which does this now.
    * Also deleted the code which defaults item_type, item_key from
    * po_document_types as this is done now in start_wf_process.
   */

    /* Bug 1845764 :
    Check if the supplier site on the PO/Release has email as the default notification method.
    if so set the email flag and address from the site */

  -- included bug fix 2342323. Modified changes are to retrieve segment1
        -- from po_headers into x_doc_num
  -- for release, PO or PA
        -- Bug 2567900 Included fax number in the select

        /* bug 4638656 - start */
        /* We donot consider transaction subtype POCO, since a
	   document cannot be in requires reapproval when
	   launching approval from create doc */

	 --Bug4956479 Included agent_id/preparer_id in select/into clause
	 --for doctype of both PO/RELEASE

        l_transaction_subtype := 'POO';

        IF x_doc_type = 'PO' THEN
           BEGIN
             select      pvs.tp_header_id,
                         nvl(etd.edi_flag,'N'),
                         ph.agent_id
             into        l_tp_header_id,
                         l_edi_flag,
                         x_preparer_id
             from        ece_tp_details etd,
                         po_vendor_sites pvs,
                         po_vendors pv,
                         po_headers ph
             where       pv.vendor_id       = pvs.vendor_id
             and         pvs.tp_header_id   = etd.tp_header_id
             and         etd.document_id    = l_transaction_subtype
             and         ph.vendor_id       = pv.vendor_id
             and         ph.vendor_site_id  = pvs.vendor_site_id
             and         ph.po_header_id    = x_doc_id
             and         ph.type_lookup_code= x_doc_subtype
             and         etd.document_type  = ph.type_lookup_code;

           EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_edi_flag := 'N';
           END;

        ELSIF x_doc_type = 'RELEASE' THEN

           BEGIN

             select      pvs.tp_header_id,
                         nvl(etd.edi_flag,'N'),
                         pr.agent_id
             into        l_tp_header_id,
                         l_edi_flag,
                         x_preparer_id
             from        ece_tp_details etd,
                         po_vendor_sites pvs,
                         po_vendors pv,
                         po_headers ph ,
                         po_releases pr
             where       pv.vendor_id       = pvs.vendor_id
             and         pvs.tp_header_id   = etd.tp_header_id
             and         etd.document_id    = l_transaction_subtype
             and         ph.vendor_id       = pv.vendor_id
             and         ph.vendor_site_id  = pvs.vendor_site_id
             and         pr.po_header_id    = ph.po_header_id
             and         pr.po_release_id   = x_doc_id
	     and         etd.document_type  = 'RELEASE';

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_edi_flag := 'N';
          END;
        END IF;

        if (l_edi_flag ='Y') and (l_tp_header_id is not null) then
	   x_printflag   := 'N';
           x_faxflag     := 'N';
           x_faxnum      := null;
           x_emailflag   := 'N';
           x_emailaddress:= null;

           --Bug4956479
           po_wf_util_pkg.SetItemAttrNumber(itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'SUGGESTED_BUYER_ID',
                                 avalue     => x_preparer_id);

        else
   	   /* bug 4638656 - end */


  PO_VENDOR_SITES_SV.Get_Transmission_Defaults(
                                        p_document_id => x_doc_id,
                                        p_document_type => x_doc_type,
                                        p_document_subtype => x_doc_subtype,
                                        p_preparer_id => x_preparer_id,
                                        x_default_method => x_default_method,
                                        x_email_address => x_emailaddress,
                                        x_fax_number => x_faxnum,
                                        x_document_num => x_doc_num );

           -- Bug 3152167 Get the document number and pass the same to start po approval.

     po_wf_util_pkg.SetItemAttrNumber(itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'SUGGESTED_BUYER_ID',
                                 avalue     => x_preparer_id);


        If (x_default_method = 'EMAIL' ) and (x_emailaddress is not null) then
            x_emailflag := 'Y';
        elsif  x_default_method  = 'FAX'  and (x_faxnum is not null) then
            x_emailaddress := null;
            x_faxnum := x_fax_area || x_faxnum;

            x_faxflag := 'Y';
        elsif  x_default_method  = 'PRINT' then
            x_emailaddress := null;
            x_faxnum := null;

            x_printflag := 'Y';
        else
            x_emailaddress := null;
            x_faxnum := null;
        end if;

	end if; -- if l_edi_flag..


        /* <SUP_CON FPI START> */
        /* Add code to check if document is Consumption PO/Release.
         * If it is, transmission method will be disabled.
         */

   /* Kick off the po approval workflow */

   x_progress:= '18: launch_po_approval: Kicking off start_wf_process with' ||
     'item_type = ' || x_ItemType || '/ ' || 'item_key = ' ||
     x_ItemKey || '/ ' || 'workflow_process = ' || x_workflow_process ||
                 '/ ' || 'doc_type = ' || x_doc_type || '/ ' || 'x_doc_id = ' ||
     to_char(x_doc_id);

   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   po_reqapproval_init1.start_wf_process(
                             x_ItemType,
                             x_ItemKey,
                             x_workflow_process,
                             x_action_orig_from,
                             x_doc_id,
                             x_doc_num,          -- pass in as null since id exists
                             x_preparer_id,
                             x_doc_type,
                             x_doc_subtype,
                             x_submitter_action,
                             x_forward_to_id,
                             x_forward_from_id,
                             x_def_approval_path_id,
           x_note,
                             x_printflag,
                             x_faxflag,
                             x_faxnum,
                             x_emailflag,
                             x_emailaddress);

   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

   x_progress:= '20: launch_po_approval: result = ACTIVITY_PERFORMED';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   --<BUG 5044645 START>  set the org context back to original one
   IF x_org_id <> l_purchasing_org_id THEN
     po_moac_utils_pvt.set_org_context(x_org_id);
   END IF;
   --<BUG 5044645 END>

exception
  when others then
    wf_core.context('po_autocreate_doc','launch_po_approval',x_progress);
    raise;
end launch_po_approval;


/***************************************************************************
 *
 *  Procedure:  purge_rows_from_temp_table
 *
 *  Description:  This purges the rows from the temp table for the
 *      group id associated with this workflow run.
 *
 **************************************************************************/
procedure purge_rows_from_temp_table (itemtype   IN   VARCHAR2,
                                      itemkey    IN   VARCHAR2,
                                      actid      IN   NUMBER,
                                      funcmode   IN   VARCHAR2,
                                      resultout  OUT NOCOPY  VARCHAR2 ) is
x_group_id   number;
x_progress   varchar2(300);

begin

  x_group_id:= po_wf_util_pkg.GetItemAttrNumber
          (itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'GROUP_ID');


  /* Delete all rows belonging to this group_id */

  delete from po_wf_candidate_req_lines_temp
        where group_id = x_group_id;

 /* Calling process should do the commit, so comment out here.
  * COMMIT;
  */

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  x_progress:= '10: purge_rows_from_temp_table: result = ACTIVITY_PERFORMED';
  IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;



exception
  when others then
    wf_core.context('po_autocreate_doc','purge_rows_from_temp_table',x_progress);
    raise;
end purge_rows_from_temp_table;

/***************************************************************************
 *
 *  Procedure:  is_this_emergency_req
 *
 *  Description:  This check if there is a reserved PO number
 *
 **************************************************************************/
procedure is_this_emergency_req(itemtype   IN   VARCHAR2,
                                itemkey    IN   VARCHAR2,
                                actid      IN   NUMBER,
                                funcmode   IN   VARCHAR2,
                                resultout  OUT NOCOPY  VARCHAR2 ) is

x_req_header_id    number;
x_emergency_po_num varchar2(20);
x_progress         varchar2(300);

begin

   x_req_header_id := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'REQ_HEADER_ID');
   BEGIN
     SELECT   emergency_po_num
     INTO     x_emergency_po_num
     FROM     po_requisition_headers
     WHERE    requisition_header_id=x_req_header_id;
   EXCEPTION
     WHEN OTHERS THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_progress:= '10: is_this_emergency_req: result = N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   END;

   IF x_emergency_po_num IS NOT NULL THEN
     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_progress:= '20: is_this_emergency_req: result = Y';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   ELSE
     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_progress:= '30: is_this_emergency_req: result = N';
     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
     END IF;

   END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc','is_this_emergency_req',x_progress);
    raise;
end is_this_emergency_req;

/***************************************************************************
 *
 *  Procedure:  put_on_one_po
 *
 *  Description:  Group all req lines into one po and
 *                      insert into the interface tables
 *      Remark:         This is for processing emergency requisitions
 *                      where only one PO number is reserved for each
 *                      requisition
 *
 **************************************************************************/
procedure put_on_one_po(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 ) is

c_rowid       rowid;
c_group_id      number;
c_req_header_id   number;
c_req_line_id     number;
c_suggested_buyer_id    number;
c_source_doc_type_code    varchar2(25);
c_source_doc_id   number;
c_source_doc_line   number;
c_suggested_vendor_id     number;
c_suggested_vendor_site_id  number;
c_currency_code   varchar2(15);
c_rate_type     varchar2(30);
c_rate_date     date;
c_rate        number;
c_process_code      varchar2(30);
c_rel_gen_method    varchar2(25);
c_item_id     number;
c_pcard_id      number;
c_contract_id     number;

l_enable_vmi_flag       po_asl_attributes.enable_vmi_flag%TYPE;               -- Consigned FPI
l_last_billing_date     po_asl_attributes.last_billing_date%TYPE;             -- Consigned FPI
l_cons_billing_cycle    po_asl_attributes.consigned_billing_cycle%TYPE;       -- Consigned FPI

c_dest_org_id              number;                                            -- Consigned FPI
c_dest_type_code           po_requisition_lines.destination_type_code%TYPE;   -- Consigned FPI
c_cons_from_supp_flag      varchar2(1);                                       -- Consigned FPI

x_progress          varchar2(300);
x_group_id      number;
x_first_time_for_this_comb  varchar2(5);
x_interface_header_id   number;
x_suggested_vendor_contact_id   number;
x_suggested_vendor_contact      varchar2(240);
x_prev_sug_vendor_contact_id    number;
x_carry_contact_to_po_flag      varchar2(10);

l_return_status         varchar2(1)    := NULL;
l_msg_count             number         := NULL;
l_msg_data              varchar2(2000) := NULL;

l_style_id            PO_DOC_STYLE_HEADERS.style_id%TYPE; --<R12 STYLES PHASE II>
/* Define the cursor which picks up records from the temp table.
 * We need the 'for update' since we are going to update the
 * process_code.
 */

/* Bug # 1721991.
   The 'for update' clause was added to update the row which was processed
   in the Cursor c1 but this led to another problem in Oracle 8.1.6.3 or above
   where you can't have a commit inside a 'for update' Cursor loop.
   This let to the Runtime Error 'fetch out of sequence'
   The commit was actually issued in the procedure insert_into_header_interface.
   To solve this we removed the for update in the cursor and instead used rowid
   to update the row processed by the Cursor.
*/

cursor c1  is       /* x_group_id is a parameter */
  select prlt.rowid, -- Bug# 1721991, Added rowid to update row
         prlt.group_id,
         prlt.requisition_header_id,
         prlt.requisition_line_id,
   prlt.suggested_buyer_id,
         prlt.source_doc_type_code,
   prlt.source_doc_id,
   prlt.source_doc_line,
   prlt.suggested_vendor_id,
         prlt.suggested_vendor_site_id,
   prlt.currency_code,
         prlt.rate_type,
   prlt.rate_date,
   prlt.rate,
   prlt.process_code,
   prlt.release_generation_method,
   prlt.item_id,
   prlt.pcard_id,
         prlt.contract_id,
   prl.suggested_vendor_contact,
   prl.vendor_contact_id,
         prl.destination_organization_id,
         prl.destination_type_code
    from po_wf_candidate_req_lines_temp  prlt,
   po_requisition_lines prl
   where prlt.process_code = 'PENDING'
     and prlt.group_id     = x_group_id
     and prlt.requisition_header_id = prl.requisition_header_id
     and prlt.requisition_line_id = prl.requisition_line_id;
     --Bug # 1721991, for update;

    x_ga_flag VARCHAR2(1); --Bugfix#14305183

begin


   /* Get the group_id since we only want to process lines belonging
    * to the same group. We need to get the group_id before opening
    * the cursor since it is a parameter to the cursor.
    */
   l_style_id := PO_DOC_STYLE_GRP.get_standard_doc_style;  --<R12 STYLES PHASE II>

   x_group_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'GROUP_ID');

   x_progress := '10: put_on_one_po : group_id '||
                 to_char(x_group_id);
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;


   /* only true for the first line */
   x_first_time_for_this_comb := 'TRUE';
   x_suggested_vendor_contact_id := NULL;
   x_carry_contact_to_po_flag := 'TRUE';

   /* Open the cursor with that group_id */
   open c1;   /* Based on x_group_id */
   loop
      fetch c1 into c_rowid, --Bug# 1721991, Added rowid
                    c_group_id,
        c_req_header_id,
              c_req_line_id,
              c_suggested_buyer_id,
              c_source_doc_type_code,
              c_source_doc_id,
              c_source_doc_line,
              c_suggested_vendor_id,
              c_suggested_vendor_site_id,
              c_currency_code,
              c_rate_type,
              c_rate_date,
              c_rate,
              c_process_code,
              c_rel_gen_method,
              c_item_id,
        c_pcard_id,
                    c_contract_id,
        x_suggested_vendor_contact,
        x_suggested_vendor_contact_id,
                    c_dest_org_id,
                    c_dest_type_code;
        exit when c1%NOTFOUND;

     update po_wf_candidate_req_lines_temp
     set process_code = 'PROCESSED'
     where rowid=c_rowid;
     --Bug# 1721991, where current of c1;

     if (x_suggested_vendor_contact_id is null) then
  x_suggested_vendor_contact_id := get_contact_id(x_suggested_vendor_contact, c_suggested_vendor_site_id);
     end if;

   /* Bug#14305183: For emergency requisition, outcome document is always a
    * STANDARD purchase order.
    * Customer in bug13496442 had requested that, if the emergency requisition
    * creating into the PO, retains the source document reference on the PO.
    * If source document is local Blanket. we should still create a Standard PO
    * without having the source document reference. Hence x_doc_type_to_create
    * should be STANDARD in this case.
    */

    -- Bug#14305183: Start
     IF (c_source_doc_id is not null)
     THEN
       IF (c_source_doc_type_code = 'BLANKET') THEN -- bug19022186
         Begin
           select NVL(global_agreement_flag,'N')
             into x_ga_flag
             from po_headers_all
             where po_header_id = c_source_doc_id;
           Exception
             when others then
               x_ga_flag := 'N';
          End;
        -- bug19022186 begin
        ELSIF (c_source_doc_type_code = 'CONTRACT') THEN
          c_contract_id := c_source_doc_id;
          c_source_doc_id := NULL;
        END IF;
        -- bug19022186 end
     END IF;

     IF (x_ga_flag = 'N')
     THEN
       c_source_doc_type_code := NULL;
       c_source_doc_line := NULL;
       c_source_doc_id := NULL;
     END IF;

     -- Bug#14305183: End
     /* Consigned FPI start */
        PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes
       ( p_api_version                  => 1.0
       , p_init_msg_list                => NULL
       , x_return_status                => l_return_status
       , x_msg_count                    => l_msg_count
       , x_msg_data                     => l_msg_data
       , p_inventory_item_id            => c_item_id
       , p_vendor_id                    => c_suggested_vendor_id
       , p_vendor_site_id               => c_suggested_vendor_site_id
       , p_using_organization_id        => c_dest_org_id
       , x_consigned_from_supplier_flag => c_cons_from_supp_flag
       , x_enable_vmi_flag              => l_enable_vmi_flag
       , x_last_billing_date            => l_last_billing_date
       , x_consigned_billing_cycle      => l_cons_billing_cycle
      );

       if nvl(c_dest_type_code,'INVENTORY') = 'EXPENSE' then
           c_cons_from_supp_flag := 'N';
       end if;

     /* Consigned FPI end */

     /** Bug 956730
      *  bgu, Aug. 11, 1999
      *  For Emergency Requisition, don't need to populate sourcing
      *  information.
      */
     if (x_first_time_for_this_comb  = 'TRUE') then

       if(po_autocreate_doc.insert_into_headers_interface
               (itemtype,
                itemkey,
                c_group_id,
                c_suggested_vendor_id,
                c_suggested_vendor_site_id,
                c_suggested_buyer_id,
		--Bug 13496442/14305183 , replace null values only if global BPA
		c_source_doc_type_code,
                c_source_doc_id,
                --null,
                --null,
		--End bug 13496442
                c_currency_code,
                c_rate_type,
                c_rate_date,
                c_rate,
                c_pcard_id,
                            l_style_id,  --<R12 STYLES PHASE II>
                x_interface_header_id) = FALSE) then
                    return; --bug 3401653: po creation failed
        end if;




        po_autocreate_doc.insert_into_lines_interface (itemtype,
                itemkey,
                x_interface_header_id,
                c_req_line_id,
				--Bug 13496442, replace null values
				c_source_doc_line,
				c_source_doc_type_code,
                --null,
                --null,
                c_contract_id, -- bug19022186
                c_source_doc_id,
				--null,
				--End bug 13496442
                c_cons_from_supp_flag);        -- Consigned FPI

        x_progress := '20: put_on_one_po: inserted header'||
                ' and line for req line = ' ||
                      to_char(c_req_line_id);
  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
  END IF;

        x_first_time_for_this_comb := 'FALSE';

  if (x_suggested_vendor_contact_id is NULL) then
    x_carry_contact_to_po_flag := 'FALSE';
  end if;

  x_prev_sug_vendor_contact_id := x_suggested_vendor_contact_id;

     else  /*  ie. x_first_time_for_this_comb  = FALSE */

        /* The line will be put onto the same header
         * as a previous one, so only insert a new line into the
         * po_lines_interface table.
         */

        po_autocreate_doc.insert_into_lines_interface (itemtype,
                itemkey,
                x_interface_header_id,
                c_req_line_id,
                --Bug 13496442, replace null values
				c_source_doc_line,
				c_source_doc_type_code,
                --null,
                --null,
                c_contract_id, -- bug19022186
                c_source_doc_id,
				--null,
				--End bug 13496442
                c_cons_from_supp_flag);   -- Consigned FPI


  if (x_carry_contact_to_po_flag = 'TRUE' and x_suggested_vendor_contact_id is not null) then
    if (x_suggested_vendor_contact_id <> x_prev_sug_vendor_contact_id) then
      x_carry_contact_to_po_flag := 'FALSE';
    end if;
   else
    x_carry_contact_to_po_flag := 'FALSE';
   end if;

         x_progress := '30: put_on_one_po: inserted just line for '||
             'req line = ' || to_char(c_req_line_id);
   IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

     end if;

     x_prev_sug_vendor_contact_id := x_suggested_vendor_contact_id;

   end loop;
   close c1;

   if (x_carry_contact_to_po_flag = 'TRUE' and
       valid_contact(c_suggested_vendor_site_id, x_suggested_vendor_contact_id)) then
            begin
                    x_progress := '55: group_req_lines: updating header with vendor contact :'||x_interface_header_id;

                    update po_headers_interface
                    set vendor_contact_id = x_suggested_vendor_contact_id
                    where interface_header_id = x_interface_header_id;

            exception
                    when others then
                    IF (g_po_wf_debug = 'Y') THEN
                       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
                    END IF;
      end;
   end if;


   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

   x_progress := '40: put_on_one_po: result = ACTIVITY_PERFORMED ';
   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
   END IF;

exception
  when others then
    close c1;
    wf_core.context('po_autocreate_doc','put_on_one_po',x_progress);
    raise;
end put_on_one_po;

/***************************************************************************
 *
 *  Procedure:  send_return_notif
 *
 *  Description:  Send notification to preparer when the requisition
 *                      is returned.
 *
 **************************************************************************/

/* Bug# 1694064: kagarwal
** Desc: Calling Req Approval wf to send return Notification
** instead of the wf API.
*/

procedure send_return_notif(p_req_header_id IN number,
                            p_agent_id      IN number,
                            p_reason        IN VARCHAR2) is

  l_doc_type           varchar2(240); /* Bug# 2681512: kagarwal */
  --Bug# 3268971: sbgeorge
  l_doc_type_code      varchar2(80);
  l_doc_subtype        varchar2(80);
  doc_subtype          varchar2(25);

  l_req_num            varchar2(20);
  --l_agent_name         varchar2(240);--<BUG 7650916>
  l_preparer_id        number;
  l_preparer_disp_name varchar2(240);
  l_preparer_user_name varchar2(200);

  l_nid                number;
  l_seq                varchar2(25); --Bug14305923
  ItemType             varchar2(8);
  ItemKey              varchar2(240);

  l_update_req_url     varchar2(1000);
  l_open_req_url       varchar2(1000);
  l_resubmit_req_url   varchar2(1000);

  l_org_id             number;

  x_progress           varchar2(300);

  -- bug 5657496 variable addition <START>
  l_responsibility_id  NUMBER;
  l_user_id	       NUMBER;
  l_application_id     NUMBER;
  -- bug 5657496 variable addition <END>
  --<BUG 7650916 START>
  l_approver_disp_name per_people_f.full_name%TYPE;
  l_approver_user_name fnd_user.user_name%TYPE;
  --<BUG 7650916 END>

begin

     x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 001';

/* Bug# 2681512: kagarwal
** We will get the document type display value from
** po document types for correct translation.
*/
/*
    select st.DISPLAYED_FIELD,
           ty.DISPLAYED_FIELD,
           hd.SEGMENT1,
           hd.ORG_ID,
           hd.PREPARER_ID,
           hd.TYPE_LOOKUP_CODE
      into l_doc_subtype,
           l_doc_type,
           l_req_num,
           l_org_id,
           l_preparer_id,
           doc_subtype
      from po_requisition_headers hd,
           po_lookup_codes ty,
           po_lookup_codes st
     where hd.requisition_header_id = p_req_header_id
       and ty.lookup_type = 'DOCUMENT TYPE'
       and ty.lookup_code = 'REQUISITION'
       and st.lookup_type = 'REQUISITION TYPE'
       and st.lookup_code = hd.TYPE_LOOKUP_CODE;
*/

    select ty.DOCUMENT_TYPE_CODE,
           ty.DOCUMENT_SUBTYPE,
           ty.type_name,
           hd.SEGMENT1,
           hd.ORG_ID,
           hd.PREPARER_ID,
           hd.TYPE_LOOKUP_CODE,
           ty.wf_approval_itemtype
      into l_doc_type_code,
           l_doc_subtype,
           l_doc_type,
           l_req_num,
           l_org_id,
           l_preparer_id,
           doc_subtype,
           ItemType
      from po_requisition_headers hd,
           po_document_types ty
     where hd.requisition_header_id = p_req_header_id
       and ty.document_type_code = 'REQUISITION'
       and ty.document_subtype = hd.TYPE_LOOKUP_CODE;

     -- Get Req Approval process.

     x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 010';

/* Bug# 2681512: kagarwal
** Getting the wf_item_type in the SQL above

     begin

     select wf_approval_itemtype
       into ItemType
       from PO_DOCUMENT_TYPES
      where DOCUMENT_TYPE_CODE = 'REQUISITION'
        and DOCUMENT_SUBTYPE =  doc_subtype;

     exception
           when others then
           null;
     end;
*/

     IF ItemType IS NULL THEN
        x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 020';
        return;
     END IF;

     -- Build the links.

     l_open_req_url := por_util_pkg.jumpIntoFunction(
             p_application_id        => 178,
             p_function_code         => 'POR_OPEN_REQ',
             p_parameter1            => to_char(p_req_header_id),
             p_parameter11           => to_char(l_org_id) );

     l_update_req_url := por_util_pkg.jumpIntoFunction(
                     p_application_id=> 178,
                     p_function_code => 'POR_UPDATE_REQ',
                     p_parameter1    => to_char(p_req_header_id),
                     p_parameter11   => to_char(l_org_id) );

     l_resubmit_req_url := por_util_pkg.jumpIntoFunction(
                     p_application_id=> 178,
                     p_function_code => 'POR_RESUBMIT_URL',
                     p_parameter1    => to_char(p_req_header_id),
                     p_parameter11   => to_char(l_org_id) );

     PO_REQAPPROVAL_INIT1.get_user_name(l_preparer_id, l_preparer_user_name,
                                        l_preparer_disp_name);
     --<BUG 7650916 commented the following code since the same as been performed later>
     /*select pr.FULL_NAME
       into l_agent_name
       from per_people_f pr
      where pr.person_id = p_agent_id
        and trunc(sysdate) between pr.effective_start_date
                               and pr.effective_end_date;*/

     -- Create wf process.

     x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 040';

     select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;
     ItemKey := to_char(p_req_header_id) || '-' || l_seq;

     wf_engine.CreateProcess( ItemType => ItemType,
                              ItemKey  => ItemKey,
                              process  => 'NOTIFY_RETURN_REQ');

     x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 050 - '||
                     'itemtype: ' || ItemType || 'itemkey: ' || ItemKey;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     -- Set the attributes
     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'DOCUMENT_NUMBER',
                                 avalue     =>  l_req_num);
     --
     po_wf_util_pkg.SetItemAttrNumber ( itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => 'DOCUMENT_ID',
                                   avalue     => p_req_header_id);
     --
     po_wf_util_pkg.SetItemAttrText ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_TYPE_DISP',
                                 avalue          =>  l_doc_type);
     --
     -- Bug 2942228. The org id was getting changed from 458 to 204 when requisition was
     --     returned in Vision Services because it is not set as Workflow Attribute here.
     po_wf_util_pkg.SetItemAttrNumber ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'ORG_ID',
                                 avalue          =>  l_org_id);

/* Bug# 2681512: kagarwal
** Desc: We will only be using one display attribute for type and
** subtype - DOCUMENT_TYPE_DISP, hence commenting the code below
*/
/*
     po_wf_util_pkg.SetItemAttrText ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_SUBTYPE_DISP',
                                 avalue          =>  l_doc_subtype);
     --
*/
/* Bug# 3268971: sbgeorge
** Need to call PO_REQAPPROVAL_INIT1.Get_Req_Attributes after start in
** NOTIFY_RETURN_REQ process, since the notification needs to be similar to
** other Req Approval Notifications.
** Setting the item attributes for DOCUMENT_TYPE and DOCUMENT_SUBTYPE with
** document_type_code and document_subtype from po_document_types, because
** these are used in PO_REQAPPROVAL_INIT1.SetReqHdrAttributes to set the item
** attribute for DOCUMENT_TYPE_DISP.
*/
     po_wf_util_pkg.SetItemAttrText ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_TYPE',
                                 avalue          =>  l_doc_type_code);
     --
     po_wf_util_pkg.SetItemAttrText ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'DOCUMENT_SUBTYPE',
                                 avalue          =>  l_doc_subtype);
     --

     po_wf_util_pkg.SetItemAttrText ( itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'NOTE',
                                 avalue          =>  p_reason);
     --
     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'PREPARER_USER_NAME' ,
                                 avalue     => l_preparer_user_name);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'PREPARER_DISPLAY_NAME' ,
                                 avalue     => l_preparer_disp_name);

     --<BUG 7650916 Fetching the Buyer username and display name and
     -- setting the values in corresponding workflow attributes.
     PO_REQAPPROVAL_INIT1.get_user_name(p_agent_id, l_approver_user_name,
                                        l_approver_disp_name);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'APPROVER_DISPLAY_NAME' ,
                                 avalue     => l_approver_disp_name);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'APPROVER_USER_NAME' ,
                                 avalue     => l_approver_user_name);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_URL' ,
                                 avalue     => l_open_req_url);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_UPDATE_URL' ,
                                 avalue     => l_update_req_url);

     po_wf_util_pkg.SetItemAttrText ( itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      => 'REQ_RESUBMIT_URL' ,
                                 avalue     => l_resubmit_req_url);

    -- bug 5657496 <START>
    -- Need to set the context variables also, else the selector function in
    -- the workflow will set a null context.
    l_user_id := FND_GLOBAL.user_id;
    l_responsibility_id := FND_GLOBAL.resp_id;
    l_application_id := FND_GLOBAL.resp_appl_id;
          wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'USER_ID',
                                     avalue          =>  l_user_id);

       wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'APPLICATION_ID',
                                     avalue          =>  l_application_id);

       wf_engine.SetItemAttrNumber ( itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'RESPONSIBILITY_ID',
                                     avalue          =>  l_responsibility_id);
    -- bug 5657496 <END>

   -- Start Process
    x_progress :=  'PO_AUTOCREATE_DOC.send_return_notif: 055';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    wf_engine.StartProcess(itemtype        => itemtype,
                           itemkey         => itemkey );


EXCEPTION
 WHEN OTHERS THEN
   po_message_s.sql_error('Error: send_return_notif()', x_progress, sqlcode);
   RAISE;

end send_return_notif;

/***************************************************************************
 *
 *      function:       get_document_num
 *
 *      Description:    get the next document number in the OU specified
 *                      from po_unique_identifier_cont_all table
 *
 **************************************************************************/

FUNCTION  get_document_num (
  p_purchasing_org_id IN NUMBER --<Shared Proc FPJ>
) RETURN VARCHAR2
IS

-- Bug # 1869409
-- Created a function get_document_num as an  autonomous transaction
-- to avoid the COMMIT for the Workflow transactions.

-- bug5176308
-- No need to be an autonomous transaction as the number generation is now
-- through an API which itself is an autonomous transaction.

--  pragma AUTONOMOUS_TRANSACTION;

  x_document_num varchar2(25);
  x_progress    varchar2(300);

begin

  x_progress := '10: get_document_num: Just before get doc' ||
                 'num from po_unique_identifier_control';

  -- bug5176308
  -- Call API to get the next document num
  x_document_num :=
    PO_CORE_SV1.default_po_unique_identifier
    ( p_table_name => 'PO_HEADERS',
      p_org_id     => p_purchasing_org_id
    );


  x_progress := '20: get_document_num: Just after get doc' ||
                 'num from po_unique_identifier_control';

  return x_document_num;

exception
  when others then
   wf_core.context('po_autocreate_doc','get_document_num',x_progress);
   raise;

end get_document_num;

/***************************************************************************
 *
 *      function:       is_contract_required_on_req_line
 *
 *      Description:    check the worlflow options for the autocreate po
 *                      document.
 *
 **************************************************************************/

procedure is_contract_required_on_req(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
                        resultout  OUT NOCOPY  VARCHAR2 ) is

x_contract_required_flag varchar2(1);

x_progress                varchar2(300) := '000';

begin

   x_contract_required_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'CONTRACT_REQUIRED_FLAG');

   if nvl(x_contract_required_flag, 'N') <> 'Y' then

        resultout := wf_engine.eng_completed || ':' ||  'N';

        return;
   else
        resultout:= wf_engine.eng_completed || ':' || 'Y';

  return;

   end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','is_contract_required_on_req',x_progress);
    raise;

end is_contract_required_on_req;

/***************************************************************************
 *
 *      function:       should_contract_be_used
 *
 *      Description:    check whether contract be used to create document
 *
 **************************************************************************/
 procedure should_contract_be_used(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
         resultout  OUT NOCOPY  VARCHAR2 ) is
x_use_contract_flag varchar2(1);

x_progress                varchar2(300) := '000';

begin

   x_use_contract_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'USE_CONTRACT_FLAG');

   if nvl(x_use_contract_flag, 'N') <> 'Y' then

        resultout := wf_engine.eng_completed || ':' ||  'N';

        return;
   else
        resultout:= wf_engine.eng_completed || ':' || 'Y';

  return;

   end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','should_contract_be_used',x_progress);
    raise;

end should_contract_be_used;

/***************************************************************************
 *
 *  Procedure:  non_catalog_item_check
 *
 *  Description:  Checks if this is a non_catalog_item  req line
 *      (ie. non_catalog item)
 *
 **************************************************************************/

procedure non_catalog_item_check (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 ) is

x_item_id   number;
x_progress        varchar2(300);
x_catalog_type    varchar2(30);

begin

  x_catalog_type := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CATALOG_TYPE');

  if nvl(x_catalog_type, 'CATALOG') <> 'NONCATALOG' then

    resultout := wf_engine.eng_completed || ':' || 'N';

  else
    resultout := wf_engine.eng_completed || ':' || 'Y';

    x_progress:= '10: non_catalog_item_check: result = '|| resultout;
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  end if;


exception
  when others then
    wf_core.context('po_autocreate_doc','non_catalog_item_check',x_progress);
    raise;
end non_catalog_item_check;


/***************************************************************************
 *
 *      function:       is_contract_info_ok
 *
 *      Description:    check the source contract number is okay
 *
 *
 **************************************************************************/
procedure is_contract_doc_info_ok(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
              resultout  OUT NOCOPY  VARCHAR2 ) is

x_source_doc_type_code    varchar2(25);
x_source_doc_po_header_id number;
x_source_doc_line_num   number;
x_progress                varchar2(300) := '000';
x_contract_id_valid   number;
x_contract_currency_code        varchar2(25);
x_source_currency_code          PO_REQUISITION_LINES_ALL.currency_code%TYPE;
l_vendor_site_id                PO_HEADERS_ALL.vendor_site_id%TYPE; -- <GC FPJ>
l_base_currency                 PO_HEADERS_ALL.currency_code%TYPE;
begin

      /* When the source doc and source line was put onto the req line
       * it was all validated to make sure it was ok.
       * Ie. docs were within effectivity dates, not canelled or closed etc.
       * So not doing the check here again.
       * We just need to make sure the source_doc_type,  source_doc  and
       * source_line have been populated.
       * here it will just validate the contract docuement type.
       */

       x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
            (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                     aname      => 'SOURCE_DOCUMENT_TYPE_CODE');

       x_source_doc_po_header_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOCUMENT_ID');

       x_source_doc_line_num := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOCUMENT_LINE_NUM');
       x_source_currency_code := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'CURRENCY_CODE');

       -- <GC FPJ START>
       l_vendor_site_id := po_wf_util_pkg.GetItemAttrNumber
                                    (itemtype   => itemtype,
                                     itemkey    => itemkey,
                                     aname      => 'SUGGESTED_VENDOR_SITE_ID');
       -- <GC FPJ END>

     if ((x_source_doc_line_num is NULL) and (x_source_doc_type_code = 'CONTRACT') and x_source_doc_po_header_id is not NULL) then

-- validate the contract reference is active, bug 2076945

     begin

     x_progress  := '001';

     -- <GC FPJ START>

     -- SQL What: Validate the contract ref. If it is a GC, make sure
     --           that it is still enabled for purchasing against the suggested
     --           vendor site
     -- SQL Why: The reference cannot be used if it is not valid

     select POH.po_header_id, poh.currency_code
       into x_contract_id_valid, x_contract_currency_code
       from po_headers_all POH        -- <GC FPJ>: Use ALL table
      where
        POH.po_header_id = x_source_doc_po_header_id
        and POH.type_lookup_code = 'CONTRACT'
        and nvl(POH.cancel_flag,'N') = 'N'
        and TRUNC(sysdate) between nvl(TRUNC(start_date), sysdate - 1)
                           and     nvl(TRUNC(end_date), sysdate + 1)
        and POH.authorization_status = 'APPROVED'
        and nvl(POH.closed_code,'OPEN') = 'OPEN'
        AND NVL(POH.frozen_flag, 'N') = 'N'
        AND (NVL(POH.global_agreement_flag, 'N') = 'N'
             OR EXISTS (SELECT 1
                        FROM   po_ga_org_assignments PGOA,
                               po_system_parameters  PSP
                        WHERE  PGOA.po_header_id = POH.po_header_id
                        AND    PGOA.organization_id = PSP.org_id
                        AND    PGOA.vendor_site_id = decode(Nvl(poh.Enable_All_Sites,'N'),'Y',PGOA.vendor_site_id, l_vendor_site_id)
                        AND    PGOA.enabled_flag = 'Y'));
     -- <GC FPJ END>

   exception

     when others then
       x_contract_id_valid := -1;

     end;

     if (x_contract_id_valid =  -1 ) then

        resultout := wf_engine.eng_completed || ':' ||  'N';

     elsif (x_contract_id_valid = x_source_doc_po_header_id) then
        -- bug 3079146
        -- if currency didn't match, don't create po
        -- so set the flag to true so that po won't be created.
        l_base_currency := PO_CORE_S2.get_base_currency;

        if ((x_source_currency_code is not null and x_contract_currency_code = x_source_currency_code) or (x_source_currency_code is null and x_contract_currency_code = l_base_currency)) then

           resultout := wf_engine.eng_completed || ':' ||  'Y';

  else
     resultout := wf_engine.eng_completed || ':' || 'N';
            po_wf_util_pkg.SetItemAttrText (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CONTRACT_REQUIRED_FLAG',
                               avalue     => 'Y');
  end if;

     else

    resultout := wf_engine.eng_completed || ':' || 'N';

     end if;

        x_progress:= '10: is_source_doc_info_ok: result = ' || resultout;
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'CONTRACT_ID',
                               avalue     => x_source_doc_po_header_id);

        -- <GC FPJ START>
        -- Since the ref is a contract and is stored in attr CONTRACT_ID,
        -- null out the reference in SOURCE_DOCUMENT_ID

        po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                               itemkey    => itemkey,
                               aname      => 'SOURCE_DOCUMENT_ID',
                               avalue     => NULL);

        -- <GC FPJ END>
     else
        resultout := wf_engine.eng_completed || ':' ||  'N';

        x_progress:= '20: is_contract_info_ok: result = N';
        IF (g_po_wf_debug = 'Y') THEN
           po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
        END IF;

     end if;

exception
  when others then
    wf_core.context('po_autocreate_doc','is_contract_doc_info_ok',x_progress);
    raise;

end is_contract_doc_info_ok;

 /***************************************************************************
 *
 *      function:       should_nctlog_src_frm_contract
 *
 *      Description:    check the workflow options on whether to include the
 *                      non_catalog_request in the autosource
 *
 *
 **************************************************************************/

procedure should_nctlog_src_frm_contract(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
          resultout  OUT NOCOPY  VARCHAR2 ) is

x_incl_non_ctlg_req_flag varchar2(1);

x_progress                varchar2(300) := '000';

begin


   x_incl_non_ctlg_req_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'INCLUDE_NON_CATALOG_REQ_FLAG');


   if nvl(x_incl_non_ctlg_req_flag, 'N') <> 'Y' then

        resultout := wf_engine.eng_completed || ':' ||  'N';

        return;
   else
        resultout:= wf_engine.eng_completed || ':' || 'Y';

  return;

   end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','should_nctlog_src_frm_cntrct',x_progress);
    raise;

end should_nctlog_src_frm_contract;

/* Private Procedure/Functions */

FUNCTION valid_contact(p_vendor_site_id number, p_vendor_contact_id number) RETURN BOOLEAN
is
   x_count number;
begin
  if (p_vendor_site_id is null or p_vendor_contact_id is null) then
    return false;
  else
    -- check if contact on req. lines is valid
    select count(*) into x_count
    from po_vendor_contacts
    where vendor_site_id = p_vendor_site_id
    and vendor_contact_id = p_vendor_contact_id
    and nvl(inactive_date, sysdate+1) > sysdate;

    if (x_count > 0) then
      return true;
    else
      return false;
    end if;
  end if;
end;

FUNCTION get_contact_id(p_contact_name varchar2, p_vendor_site_id number) RETURN NUMBER
IS
     x_first_name varchar2(60);
     x_last_name  varchar2(60);
     x_comma_pos  number;
     x_contact_id number := null;
BEGIN

  begin
    select max(vendor_contact_id)
    into x_contact_id
    from po_supplier_contacts_val_v
    where vendor_site_id = p_vendor_site_id
    and contact = p_contact_name;
  exception
    when others then
    x_contact_id := null;
  end;

  return x_contact_id;
END;

/***************************************************************************
 *
 *  Procedure:  is_src_doc_ga_frm_other_ou
 *
 *  Description:  Checks if the source doc is a GA from another OU
 *                      Added for global Agreements project in FPI (FPI GA)
 *
 **************************************************************************/
procedure is_src_doc_ga_frm_other_ou (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 ) is

x_org_id      number;
x_owning_org_id     number;
x_progress          varchar2(300);
x_ga_flag                 varchar2(1);
x_source_doc_po_header_id number;

begin

  /* Set org context */
  x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'ORG_ID');

  po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>

  x_source_doc_po_header_id := po_wf_util_pkg.GetItemAttrNumber
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'SOURCE_DOCUMENT_ID');

  x_ga_flag := po_wf_util_pkg.GetItemAttrText
           (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SOURCE_DOC_GA_FLAG');

  /* get the owning org of the source document */

   if x_source_doc_po_header_id is not null then
     select org_id
     into x_owning_org_id
     from po_headers_all
     where po_header_id = x_source_doc_po_header_id;
   end if;

  if nvl(x_ga_flag,'N') = 'Y'  and
     x_owning_org_id <> x_org_id  then

     x_progress := '10: is_src_doc_ga_frm_other_ou: result = Y';
     resultout  := wf_engine.eng_completed || ':' ||  'Y';
  else
     x_progress := '20: is_src_doc_ga_frm_other_ou: result = N';
     resultout  := wf_engine.eng_completed || ':' ||  'N';
  end if;

     IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(Itemtype,Itemkey,x_progress);
     END IF;

exception
  when others then
    wf_core.context('po_autocreate_doc','is_src_doc_ga_other_ou',x_progress);
    raise;
end is_src_doc_ga_frm_other_ou;


/*****************************************************************************/

--<Bug 2745549 mbhargav START>
--Checks whether the referenced document is not cancelled or finally closed
PROCEDURE is_ga_still_valid(p_ga_po_header_id   IN NUMBER,
                            x_ref_is_valid          OUT NOCOPY VARCHAR2) IS

BEGIN
         x_ref_is_valid := 'N';

         --Check the referenced GA for cancel/finally closed status
         select 'Y'
         into   x_ref_is_valid
         from   po_headers_all poh
         where  poh.po_header_id = p_ga_po_header_id and
                nvl(poh.cancel_flag, 'N') = 'N' and
                nvl(poh.closed_code, 'OPEN')  <> 'FINALLY CLOSED';

EXCEPTION
   WHEN OTHERS THEN
       x_ref_is_valid := 'N';
END;
--<Bug 2745549 mbhargav END>


-- bug2821542
-- validate_buyer is created to make sure that the derived buyer
-- is a valid buyer

/**
* Private Procedure: validate_buyer
* Requires: N/A
* Modifies: N/A
* Effects: Validates that p_agent_id is a valid buyer
* Retunrs:
* x_result: FND_API.G_TRUE if validation suceeds
*           FND_API.G_FALSE if validation fails
*/

PROCEDURE validate_buyer (p_agent_id IN NUMBER,
                          x_result   OUT NOCOPY VARCHAR2) IS

l_result VARCHAR2(1);

l_progress VARCHAR2(300);
BEGIN

  l_progress := '10: validate buyer';

  /* Changed the view from PO_BUYERS_VAL_V to PO_BUYERS_V to fetch the buyer with out
     hr security profile settings */

  SELECT 'Y'
  INTO   l_result
  FROM   po_buyers_v
  WHERE  employee_id = p_agent_id;

  x_result := FND_API.G_TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_result := FND_API.G_FALSE;
  WHEN OTHERS THEN
    x_result := FND_API.G_FALSE;
    WF_CORE.context('po_autocreate_doc','validate_buyer',l_progress);
    raise;
END validate_buyer;

--<Shared Proc FPJ START>

----------------------------------------------------------------
--Start of Comments
--Name: buyer_on_src_doc_ok
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks the buyer on source document.
--Parameters:
--IN:
--itemtype
--  internal name for the item type
--itemkey
--  primary key generated by the workflow for the item type
--actid
--  id number of the activity from which this procedure is called
--funcmode
--  execution mode of the function activity (RUN or CANCEL)
--OUT:
--resultout
--  result returned to the workflow
--     YES if 1) The buyer on the global agreement is in the same
--               business group as the requesting operating unit OR
--            2) The HR:Cross Business Group profile is set to 'Y'
--     NO otherwise
--Notes:
--  Added for Shared Procurement Services Project in FPJ
--Testing:
--  None
--End of Comments
----------------------------------------------------------------


PROCEDURE buyer_on_src_doc_ok (
   itemtype    IN              VARCHAR2,
   itemkey     IN              VARCHAR2,
   actid       IN              NUMBER,
   funcmode    IN              VARCHAR2,
   resultout   OUT NOCOPY      VARCHAR2
) IS
   x_org_id                     PO_HEADERS_ALL.org_id%TYPE;
   x_progress                   VARCHAR2(300);
   x_source_doc_po_header_id    PO_HEADERS_ALL.po_header_id%TYPE;
   x_source_doc_type_code     PO_HEADERS_ALL.from_type_lookup_code%TYPE;
   x_ga_flag                    PO_HEADERS_ALL.global_agreement_flag%TYPE;
   l_return_status              VARCHAR2(1)   := 'N';

BEGIN
   --Set org context
   x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'ORG_ID');

   IF x_org_id IS NOT NULL THEN
      po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>
   END IF;

   IF (NVL(hr_general.get_xbg_profile, 'N') = 'Y') THEN
      x_progress := '10: buyer_on_src_doc_ok: result = Y';
      resultout := wf_engine.eng_completed || ':' || 'Y';
   ELSE --cross business group profile is 'N'
      x_source_doc_po_header_id := po_wf_util_pkg.GetItemAttrNumber
            (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'SOURCE_DOCUMENT_ID');

      x_source_doc_type_code := po_wf_util_pkg.GetItemAttrText
                                          (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'SOURCE_DOCUMENT_TYPE_CODE');

      x_ga_flag := po_wf_util_pkg.GetItemAttrText
            (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'SOURCE_DOC_GA_FLAG');

      IF ((x_source_doc_type_code = 'QUOTATION') OR
          (x_source_doc_type_code = 'BLANKET' AND NVL(x_ga_flag, 'N') = 'N')) THEN

         x_progress := '20: buyer_on_src_doc_ok: result = Y';
         resultout := wf_engine.eng_completed || ':' || 'Y';

      ELSIF x_source_doc_type_code = 'BLANKET' AND NVL(x_ga_flag, 'N') = 'Y' THEN

         BEGIN

            SELECT 'Y'
            INTO   l_return_status
            FROM   po_headers_all poh,
                   per_all_people_f ppf, --Bug 16249921. Changed per_people_f ppf to per_all_people_f
                   financials_system_parameters fsp
            WHERE  poh.agent_id = ppf.person_id
                   AND ppf.business_group_id = fsp.business_group_id
                   AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date
                                               AND NVL (ppf.effective_end_date, SYSDATE + 1)
            AND    poh.po_header_id = x_source_doc_po_header_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_return_status := 'N';
         END;

         IF l_return_status = 'Y' THEN
            x_progress := '30: buyer_on_src_doc_ok: result = Y';
            resultout := wf_engine.eng_completed || ':' || 'Y';
         ELSE
            x_progress := '40: buyer_on_src_doc_ok: result = N';
            resultout := wf_engine.eng_completed || ':' || 'N';
         END IF;

      ELSE
         x_progress := '50: buyer_on_src_doc_ok: result = N';
         resultout := wf_engine.eng_completed || ':' || 'N';

      END IF; --source doc check
   END IF; --check profile option

   IF (g_po_wf_debug = 'Y') THEN
      po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.CONTEXT ('po_autocreate_doc', 'buyer_on_src_doc_ok',
                       x_progress);
      RAISE;
END buyer_on_src_doc_ok;


----------------------------------------------------------------
--Start of Comments
--Name: buyer_on_contract_ok
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks the buyer on contract.
--Parameters:
--IN:
--itemtype
--  internal name for the item type
--itemkey
--  primary key generated by the workflow for the item type
--actid
--  id number of the activity from which this procedure is called
--funcmode
--  execution mode of the function activity (RUN or CANCEL)
--OUT:
--resultout
--  result returned to the workflow
--     YES if 1) The buyer on the global contract is in the same
--               business group as the requesting operating unit OR
--            2)  The HR:Cross Business Group profile is set to 'Y'
--     NO otherwise
--Notes:
--  Added for Shared Procurement Services Project in FPJ
--Testing:
--  None
--End of Comments
----------------------------------------------------------------


PROCEDURE buyer_on_contract_ok (
   itemtype     IN              VARCHAR2,
   itemkey      IN              VARCHAR2,
   actid        IN              NUMBER,
   funcmode     IN              VARCHAR2,
   resultout    OUT NOCOPY      VARCHAR2
) IS
   x_org_id          PO_HEADERS_ALL.org_id%TYPE;
   x_progress        VARCHAR2(300);
   x_contract_id     NUMBER;
   l_return_status   VARCHAR2(1)   := 'N';

BEGIN
   --Set org context
   x_org_id := po_wf_util_pkg.GetItemAttrNumber (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'ORG_ID');

   IF x_org_id IS NOT NULL THEN
     po_moac_utils_pvt.set_org_context(x_org_id); --<R12 MOAC>
   END IF;

   IF (NVL(hr_general.get_xbg_profile, 'N') = 'Y') THEN
     x_progress := '10: buyer_on_contract_ok: result = Y';
     resultout := wf_engine.eng_completed || ':' || 'Y';
   ELSE -- cross business group profile is 'N'
     x_contract_id := po_wf_util_pkg.GetItemAttrNumber
            (itemtype      => itemtype,
                                           itemkey       => itemkey,
                                           aname         => 'CONTRACT_ID');

     IF x_contract_id IS NOT NULL THEN
       BEGIN
         SELECT 'Y'
         INTO   l_return_status
         FROM   po_headers_all poh,
                per_all_people_f ppf,----Bug16249921 Changed per_people_f to per_all_people_f
                                     --as per_people_f is security profile restricted.
                financials_system_parameters fsp
         WHERE  poh.agent_id = ppf.person_id
                AND ppf.business_group_id = fsp.business_group_id
                AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date
                                              AND NVL(ppf.effective_end_date, SYSDATE + 1)
                AND poh.po_header_id = x_contract_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_return_status := 'N';
       END;

       IF l_return_status = 'Y' THEN
          x_progress := '20: buyer_on_contract_ok: result = Y';
          resultout := wf_engine.eng_completed || ':' || 'Y';
       ELSE
          x_progress := '30: buyer_on_contract_ok: result = N';
          resultout := wf_engine.eng_completed || ':' || 'N';

          purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

       END IF;

     ELSE --contract id is null

       x_progress := '40: buyer_on_contract_ok: result = N';
       resultout := wf_engine.eng_completed || ':' || 'N';

       purge_expense_lines(itemtype, itemkey);  -- <SERVICES FPJ>

     END IF; --contract_id check
   END IF; --check profile option

   IF (g_po_wf_debug = 'Y') THEN
     po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     wf_core.CONTEXT('po_autocreate_doc', 'buyer_on_contract_ok', x_progress);
     RAISE;
END buyer_on_contract_ok;


----------------------------------------------------------------
--Start of Comments
--Name: purchasing_ou_check
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Checks the purchasing org of the Requisition.
--Parameters:
--IN:
--itemtype
--  internal name for the item type
--itemkey
--  primary key generated by the workflow for the item type
--actid
--  id number of the activity from which this procedure is called
--funcmode
--  execution mode of the function activity (RUN or CANCEL)
--OUT:
--resultout
--  result returned to the workflow
--     YES if the operating unit associated with vendor_site_id
--         is different from requesting operating unit.
--     NO otherwise
--Notes:
--  Added for Shared Procurement Services Project in FPJ
--Testing:
--  None
--End of Comments
----------------------------------------------------------------


PROCEDURE purchasing_ou_check (
  itemtype    IN           VARCHAR2,
  itemkey     IN           VARCHAR2,
  actid       IN           NUMBER,
  funcmode    IN           VARCHAR2,
  resultout   OUT NOCOPY   VARCHAR2
) IS

  l_org_id              PO_HEADERS_ALL.org_id%TYPE;
  l_purchasing_org_id   PO_HEADERS_ALL.org_id%TYPE;
  x_progress            VARCHAR2(300);

BEGIN

  l_org_id := po_wf_util_pkg.GetItemAttrNumber
               (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'ORG_ID');

  l_purchasing_org_id := po_wf_util_pkg.GetItemAttrNumber
               (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'PURCHASING_ORG_ID');

  IF l_org_id = l_purchasing_org_id THEN
    x_progress := '10: purchasing_ou_check: result = N';
    resultout := wf_engine.eng_completed || ':' || 'N';
  ELSE
    x_progress := '20: purchasing_ou_check: result = Y';
    resultout := wf_engine.eng_completed || ':' || 'Y';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.CONTEXT ('po_autocreate_doc', 'purchasing_ou_check', x_progress);
    RAISE;

END purchasing_ou_check;


----------------------------------------------------------------
--Start of Comments
--Name: ok_to_create_in_diff_ou
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  This procedure calls an API which does the following checks:
--  1) Transaction Flow existance
--  2) PA Exclusion: Expense Dest with Project and Task Information
--  3) VMI Enabled Check
--  4) Consigned Relationship exists
--  5) Check if we need to do following checks:
--     a) Item validation and Revision checks
--     b) Encumbrance check
--     c) Destination Inv Org OPM enabled check
--Parameters:
--IN:
--itemtype
--  internal name for the item type
--itemkey
--  primary key generated by the workflow for the item type
--actid
--  id number of the activity from which this procedure is called
--funcmode
--  execution mode of the function activity (RUN or CANCEL)
--OUT:
--resultout
--  result returned to the workflow
--     YES if it is ok to create document in different operating unit
--     NO otherwise
--Notes:
--  Added for Shared Procurement Services Project in FPJ
--Testing:
--  None
--End of Comments
----------------------------------------------------------------


PROCEDURE ok_to_create_in_diff_ou (
   itemtype    IN              VARCHAR2,
   itemkey     IN              VARCHAR2,
   actid       IN              NUMBER,
   funcmode    IN              VARCHAR2,
   resultout   OUT NOCOPY      VARCHAR2
)
IS
   l_requesting_org_id          NUMBER;
   l_purchasing_org_id    NUMBER;
   l_dest_org_id    NUMBER;
   l_req_line_id        NUMBER;
   l_source_doc_id    NUMBER;
   l_item_id      NUMBER;
   l_cons_from_supp_flag    VARCHAR2(1);
   x_progress             VARCHAR2 (300);
   l_suggested_vendor_id        PO_VENDORS.vendor_id%TYPE;
   l_suggested_vendor_site_id PO_VENDOR_SITES_ALL.vendor_site_id%TYPE;

   l_return_status    VARCHAR2(1);
   l_msg_count      NUMBER;
   l_msg_data     VARCHAR2(2000);
   l_error_msg_name   VARCHAR2(30);
   l_vmi_flag       po_asl_attributes.enable_vmi_flag%TYPE;
   l_cons_from_supplier_flag  VARCHAR2(1);
   l_last_billing_date    po_asl_attributes.last_billing_date%TYPE;
   l_cons_billing_cycle         po_asl_attributes.consigned_billing_cycle%TYPE;
BEGIN

      l_req_line_id :=
      po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'REQ_LINE_ID'
                                       );
      l_item_id :=
      po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'ITEM_ID'
                                       );

      l_source_doc_id :=
      po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'SOURCE_DOCUMENT_ID'
                                       );

      l_requesting_org_id :=
      po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'ORG_ID'
                                       );
      l_purchasing_org_id :=
      po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'PURCHASING_ORG_ID'
                                       );

       l_suggested_vendor_id :=
       po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'SUGGESTED_VENDOR_ID'
                                       );

       l_suggested_vendor_site_id :=
       po_wf_util_pkg.getitemattrnumber (itemtype      => itemtype,
                                        itemkey       => itemkey,
                                        aname         => 'SUGGESTED_VENDOR_SITE_ID'
                                       );


      --SQL WHAT:Get the destination inventory org from the req line
      --SQL WHY: This information is needed for passing dest inv org
      --         to get_asl_attributes
      SELECT prl.destination_organization_id
      INTO l_dest_org_id
      FROM po_requisition_lines_all prl
      WHERE requisition_line_id = l_req_line_id;

      PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes(
             p_api_version                => 1.0
           , p_init_msg_list                  => NULL
           , x_return_status                  => l_return_status
           , x_msg_count                      => l_msg_count
           , x_msg_data                       => l_msg_data
           , p_inventory_item_id              => l_item_id
           , p_vendor_id                      => l_suggested_vendor_id
           , p_vendor_site_id                 => l_suggested_vendor_site_id
           , p_using_organization_id          => l_dest_org_id
           , x_consigned_from_supplier_flag   => l_cons_from_supp_flag
           , x_enable_vmi_flag                => l_vmi_flag
           , x_last_billing_date              =>  l_last_billing_date
           , x_consigned_billing_cycle        => l_cons_billing_cycle
        );

      PO_SHARED_PROC_PVT.validate_cross_ou_purchasing(
    p_api_version =>1.0,
    p_requisition_line_id =>l_req_line_id,
    p_requesting_org_id =>l_requesting_org_id,
    p_purchasing_org_id =>l_purchasing_org_id,
                p_item_id   =>l_item_id,
                p_source_doc_id   =>l_source_doc_id,
                p_vmi_flag    =>l_vmi_flag,
                p_cons_from_supp_flag =>l_cons_from_supp_flag,
    x_return_status   =>l_return_status,
    x_error_msg_name  =>l_error_msg_name
      );

   IF l_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
      x_progress := '10:ok_to_create_in_diff_ou: result = Y';
      resultout := wf_engine.eng_completed || ':' || 'Y';
   ELSE
      x_progress := '20: ok_to_create_in_diff_ou: result = N'
        || ' error msg: ' || l_error_msg_name;
      resultout := wf_engine.eng_completed || ':' || 'N';
   END IF;

   IF (g_po_wf_debug = 'Y')
   THEN
      po_wf_debug_pkg.insert_debug (itemtype, itemkey, x_progress);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      wf_core.CONTEXT ('po_autocreate_doc',
                       'ok_to_create_in_diff_ou',
                       x_progress
                      );
      RAISE;
END ok_to_create_in_diff_ou;

----------------------------------------------------------------
--Start of Comments
--Name: set_purchasing_org_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Helper function to set the PURCHASING_ORG_ID workflow
--  attribute.
--Parameters:
--IN:
--itemtype
--  internal name for the item type
--itemkey
--  primary key generated by the workflow for the item type
--p_org_id
--  org_id of the operating unit where the requisition in
--  question was created
--p_suggested_vendor_site_id
--  id of the suggested vendor site for the requisition in
--  question
--Notes:
--  Added for Shared Procurement Services Project in FPJ
--Testing:
--  None
--End of Comments
----------------------------------------------------------------

PROCEDURE set_purchasing_org_id(
  itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  p_org_id      IN NUMBER,
  p_suggested_vendor_site_id    IN NUMBER
)
IS

  l_purchasing_org_id PO_HEADERS_ALL.org_id%TYPE;
  l_progress      VARCHAR2(300);

BEGIN

  --Get the purchasing_org_id

  l_progress:= '10: set_purchasing_org_id: org_id = ' || to_char(p_org_id);

  IF p_suggested_vendor_site_id IS NOT NULL THEN
    BEGIN
      SELECT org_id
      INTO l_purchasing_org_id
      FROM po_vendor_sites_all
      WHERE vendor_site_id = p_suggested_vendor_site_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_purchasing_org_id := p_org_id;
    END;
  ELSE
    --suggested_vendor_site_id is null
    l_purchasing_org_id := p_org_id;
  END IF;


  l_progress:= '20: set_purchasing_org_id: org_id = ' || to_char(p_org_id)
                || ' purchasing_org_id = ' || to_char(l_purchasing_org_id);


  --Set purchasing_org_id workflow attribute
  po_wf_util_pkg.SetItemAttrNumber (itemtype   => itemtype,
                              itemkey    => itemkey,
                              aname      => 'PURCHASING_ORG_ID',
                              avalue     => l_purchasing_org_id);

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('po_autocreate_doc', 'set_purchasing_org_id', l_progress);
    RAISE;

END set_purchasing_org_id;


--<Shared Proc FPJ END>



-- <SERVICES FPJ START>

-------------------------------------------------------------
--Start of Comments
--Name        : is_expense_line
--
--Pre-reqs    : IN parameters need to be passed in with valid values
--
--Modifies    : None
--
--Locks       : None
--
--Function    : This procedure checks whether a given line is an
--              expense line
--
--Parameter(s):
--
--IN          : itemtype   IN   VARCHAR2,
--              itemkey    IN   VARCHAR2,
--              actid      IN   NUMBER,
--              funcmode   IN   VARCHAR2,
--
--IN OUT:     : None
--
--OUT         : resultout  OUT NOCOPY  VARCHAR2
--
--Returns     : resultout  OUT NOCOPY  VARCHAR2
--
--Notes       : None
--
--Testing     : None
--
--End of Comments
-------------------------------------------------------------

PROCEDURE is_expense_line(itemtype  IN         VARCHAR2,
                          itemkey   IN         VARCHAR2,
                          actid     IN         NUMBER,
                          funcmode  IN         VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2) IS

l_org_id            number := null;
l_labor_req_line_id number := null;
l_progress          varchar2(300) := null;

BEGIN

    /* Set org context */
    l_progress := '000';
    l_org_id := po_wf_util_pkg.GetItemAttrNumber(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'ORG_ID');
    po_moac_utils_pvt.set_org_context(l_org_id); --<R12 MOAC>

    /* Get the expense line grouping ID */
    l_labor_req_line_id := po_wf_util_pkg.GetItemAttrNumber(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'LABOR_REQ_LINE_ID');

    IF (l_labor_req_line_id is not null) THEN
        resultout := wf_engine.eng_completed || ':' ||  'Y';

        l_progress:= '10: is_expense_line: result = Y';

        IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,
                                         itemkey,
                                         l_progress);
        END IF;

    ELSE
        resultout := wf_engine.eng_completed || ':' ||  'N';

        l_progress:= '20: is_expense_line: result = N';

        IF (g_po_wf_debug = 'Y') THEN
            po_wf_debug_pkg.insert_debug(itemtype,
                                         itemkey,
                                         l_progress);
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('po_autocreate_doc',
                        'is_expense_line',
                        l_progress);
        RAISE;
END is_expense_line;



-------------------------------------------------------------
--Start of Comments
--Name        : purge_expense_lines
--
--Pre-reqs    : IN parameters need to be passed in with valid values
--
--Modifies    : None
--
--Locks       : None
--
--Function    : This procedure deletes all expense lines associated with a
--              Temp Labor Requisition line that fails validations.
--
--Parameter(s):
--
--IN          : itemtype IN VARCHAR2,
--              itemkey  IN VARCHAR2
--
--IN OUT:     : None
--
--OUT         : None
--
--Returns     : None
--
--Notes       : None
--
--Testing     : None
--
--End of Comments
-------------------------------------------------------------

PROCEDURE purge_expense_lines(itemtype IN VARCHAR2,
                              itemkey  IN VARCHAR2) IS

l_req_line_id number := null;
l_progress    varchar2(300) := null;

BEGIN

    l_progress := '000';
    -- Get the requisition line ID
    l_req_line_id := po_wf_util_pkg.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'REQ_LINE_ID');

    l_progress := '010';
    -- Delete all expense lines from the temporary table
    DELETE FROM po_wf_candidate_req_lines_temp
    WHERE       requisition_line_id = (
                    SELECT requisition_line_id
                    FROM   po_requisition_lines
                    WHERE  labor_req_line_id = l_req_line_id);

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('po_autocreate_doc',
                        'purge_expense_lines',
                        l_progress);
        RAISE;
END purge_expense_lines;
-- <SERVICES FPJ END>

/***************************************************************************
 *
 *  Procedure:  temp_labor_item_check
 *
 *  Description:  Checks if this is a temp_labor req line (ie. no
 *      item num)
 *
 **************************************************************************/
procedure temp_labor_item_check  (itemtype   IN   VARCHAR2,
                                  itemkey    IN   VARCHAR2,
                                  actid      IN   NUMBER,
                                  funcmode   IN   VARCHAR2,
                                  resultout  OUT NOCOPY  VARCHAR2 ) IS
x_progress        varchar2(300);
x_catalog_type    varchar2(30);

begin

  x_catalog_type := po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CATALOG_TYPE');

  if nvl(x_catalog_type, 'CATALOG') <> 'TEMP_LABOR' then

    resultout := wf_engine.eng_completed || ':' || 'N';

  else
    resultout := wf_engine.eng_completed || ':' || 'Y';

    x_progress:= '10: temp_labor_item_check: result = '|| resultout;
    IF (g_po_wf_debug = 'Y') THEN
       po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
    END IF;

  end if;


exception
  when others then
    wf_core.context('po_autocreate_doc','temp_labor_item_check',x_progress);
    raise;
end temp_labor_item_check;

/***************************************************************************
 *
 *      function:       should_tmplbr_src_frm_contract
 *
 *      Description:    check the workflow options on whether to include the
 *                      temp_labor_request in the autosource
 *
 *
 **************************************************************************/

procedure should_tmplbr_src_frm_contract(itemtype   IN   VARCHAR2,
                        itemkey    IN   VARCHAR2,
                        actid      IN   NUMBER,
                        funcmode   IN   VARCHAR2,
              resultout  OUT NOCOPY  VARCHAR2 ) IS
x_incl_temp_labor_flag varchar2(1);
x_progress       varchar2(300) := '000';

begin

   x_incl_temp_labor_flag := po_wf_util_pkg.GetItemAttrText
          (itemtype   => itemtype,
                                       itemkey    => itemkey,
                                       aname      => 'INCLUDE_TEMP_LABOR_FLAG');


   if nvl(x_incl_temp_labor_flag, 'N') <> 'Y' then

        resultout := wf_engine.eng_completed || ':' ||  'N';

        return;
   else
        resultout:= wf_engine.eng_completed || ':' || 'Y';

  return;

   end if;

exception

  when others then
    wf_core.context('po_autocreate_doc','should_tmplbr_src_frm_cntract',x_progress);
    raise;

end should_tmplbr_src_frm_contract;



END PO_AUTOCREATE_DOC;

/
