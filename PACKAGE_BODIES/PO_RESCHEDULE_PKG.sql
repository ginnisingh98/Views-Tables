--------------------------------------------------------
--  DDL for Package Body PO_RESCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RESCHEDULE_PKG" as
/* $Header: POXRSCHB.pls 120.2.12010000.5 2010/06/18 06:52:03 lswamina ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_pkg_name       CONSTANT VARCHAR2(30) := 'PO_RESCHEDULE_PKG';
g_module_prefix  CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

-- START Forward declarations for private procedures:
PROCEDURE add_error_to_msg_list (
  p_api_name VARCHAR2,
  p_message  VARCHAR2
);
-- END Forward declarations for private procedures

-- <APS FPJ START>
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Forward declare private procedure po_reschedule_req
PROCEDURE PO_RESCHEDULE_REQ (
    p_line_location_id_tbl   IN         po_tbl_number,
    p_estimated_pickup_dates IN         po_tbl_date,
    p_ship_methods           IN         po_tbl_varchar30,
    x_return_status	     OUT NOCOPY VARCHAR2
); -- Bug 5255550
-- <APS FPJ END>
-- 2279541  added new parameter x_shipment_num
-- bug 5255550 : Overloaded the reschedule API for backward compatibility
Function RESCHEDULE (
       X_need_by_date_old date,
        X_need_by_date date,
        X_po_header_id number,
        X_po_line_id number,
        X_supply_number varchar2,
        X_shipment_num number,
        p_estimated_pickup_date DATE,
        p_ship_method VARCHAR2
    ) Return boolean IS

        l_need_by_dates_old 	   po_tbl_date;
        l_need_by_dates 	   po_tbl_date;
        l_po_line_ids 		   po_tbl_number;
        l_shipment_nums 	   po_tbl_number;
        l_estimated_pickup_dates   po_tbl_date;
        l_ship_methods		   po_tbl_varchar30;
        l_api_name     		   CONSTANT VARCHAR2(30) := 'RESCHEDULE-1';
        l_result 		   BOOLEAN;
BEGIN

    SELECT X_need_by_date_old,
	   X_need_by_date,
	   X_po_line_id
	   /*  Bug 5610714 ,
	   X_shipment_num,
	   p_estimated_pickup_date,
	   p_ship_method */
    BULK COLLECT INTO
           l_need_by_dates_old,
           l_need_by_dates,
           l_po_line_ids
	   /*  Bug 5610714,
           l_shipment_nums,
	   l_estimated_pickup_dates,
	   l_ship_methods */
     FROM  DUAL;

IF X_shipment_num IS NOT NULL THEN
-- 5610714 Initialize the Collection with the parameter value
	l_shipment_nums := po_tbl_number(X_shipment_num);
END IF;

IF p_estimated_pickup_date IS NOT NULL THEN
-- 5610714 Initialize the Collection with the parameter value
	l_estimated_pickup_dates := po_tbl_date(p_estimated_pickup_date);
END IF;

IF p_ship_method IS NOT NULL THEN
-- 5610714 Initialize the Collection with the parameter value
	l_ship_methods := po_tbl_varchar30(p_ship_method);
END IF;


l_result:=  RESCHEDULE(X_need_by_dates_old => l_need_by_dates_old,
	     	       X_need_by_dates     => l_need_by_dates,
		       X_po_header_id 	   => X_po_header_id,
		       X_po_line_ids	     => l_po_line_ids,
		       X_supply_number	   => X_supply_number,
		       X_shipment_nums	   => l_shipment_nums,
		       p_estimated_pickup_dates =>l_estimated_pickup_dates,
		       p_ship_methods	     => l_ship_methods);

RETURN(l_result);

EXCEPTION
WHEN OTHERS THEN
   	 add_error_to_msg_list ( p_api_name => l_api_name,
                                 p_message => 'An exception Occurred ');
     RAISE FND_API.G_EXC_ERROR;
END;

 --bug9372785<START>
Function RESCHEDULE ( X_need_by_dates_old          po_tbl_date,
 	                       X_need_by_dates                     po_tbl_date,
 	                       X_po_header_id                     number,
 	                       X_po_line_ids                po_tbl_number,
 	                       X_supply_number               varchar2,
 	                       X_shipment_nums               po_tbl_number,
 	                       p_estimated_pickup_dates     po_tbl_date,
 	                       p_ship_methods               po_tbl_varchar30
 	 ) Return boolean IS
 	     l_result          BOOLEAN;
 	     l_api_name        CONSTANT VARCHAR2(30) := 'RESCHEDULE-2';
 	     l_error_message   po_tbl_varchar2000;
 	 BEGIN
 	     l_result:=  RESCHEDULE (X_need_by_dates_old => X_need_by_dates_old,
 	                                  X_need_by_dates     => X_need_by_dates,
 	                             X_po_header_id         => X_po_header_id,
 	                             X_po_line_ids        => X_po_line_ids,
 	                             X_supply_number        => X_supply_number,
 	                             X_shipment_nums        => X_shipment_nums,
 	                             p_estimated_pickup_dates =>p_estimated_pickup_dates,
 	                             p_ship_methods        => p_ship_methods,
 	                             X_error_message => l_error_message);

 	     RETURN(l_result);
 	     EXCEPTION
 	      WHEN OTHERS THEN
 	          add_error_to_msg_list ( p_api_name => l_api_name,
 	                                  p_message => 'An exception Occurred ');
 	      RAISE FND_API.G_EXC_ERROR;
 	 END;
 --bug9372785<END>



-- bug 5255550 : Reschedule API rewrite
-- Previously, the reschedule api was called once per line by APS.
-- This was not only performance intensive, but also made the reschedule
-- program to fail, since approval launched on the first call to resched.
-- api might put the doc in 'IN PROCESS' state due to which the
-- successive calls might not be able to make any modifications to the doc.
-- Now APS will pass all the lines/shipments for 1 PO/Release at once.

-- 2279541  added new parameter x_shipment_num
Function RESCHEDULE ( X_need_by_dates_old      po_tbl_date,
	              X_need_by_dates 	       po_tbl_date,
	              X_po_header_id	       number,
                      X_po_line_ids 	       po_tbl_number,
                      X_supply_number 	       VARCHAR2,
                      X_shipment_nums 	       po_tbl_number,
                      p_estimated_pickup_dates po_tbl_date,
                      p_ship_methods	       po_tbl_varchar30,
                      x_error_message     OUT NOCOPY po_tbl_varchar2000 --bug9372785
) Return boolean IS

l_po_release_id         number;
X_po_type               varchar2(25) := 'RELEASE';
x_progress    		      varchar2(300);
x_pare_right            number;
x_pare_left             number;
x_release_num           number;

-- <PO_CHANGE_API FPJ START>
-- In 115.13, modified the PO Reschedule API to call the PO Change API
-- instead of updating the database tables directly.
-- Bug 5255550
l_original_org_context  VARCHAR2(10) := null;
l_document_org_id       NUMBER;
l_changes               PO_CHANGES_REC_TYPE;
l_shipment_changes      PO_SHIPMENTS_REC_TYPE;
l_line_location_id_tbl  PO_TBL_NUMBER;
l_need_by_date_tbl      PO_TBL_DATE;
l_return_status         VARCHAR2(1);
l_api_errors            PO_API_ERRORS_REC_TYPE;
l_release_type          PO_RELEASES_ALL.RELEASE_TYPE%TYPE;
l_session_gt_key        NUMBER;
l_api_name     CONSTANT VARCHAR2(30) := 'RESCHEDULE-3';
l_log_head CONSTANT VARCHAR2(100):= g_module_prefix||l_api_name;
l_progress              VARCHAR2(3):='000';
l_promised_by_date_tbl  PO_TBL_DATE; --Bug5633563
l_need_by_promise_def_prf  VARCHAR2(1); --Bug5633563
-- <PO_CHANGE_API FPJ END>

--Bug9372785<START>
 x_error_count NUMBER;
 supply_number_tbl po_tbl_varchar30 ; --bug9787555
 line_number_tbl po_tbl_number ;
 shipment_number_tbl po_tbl_number;
 ascp_date_tbl po_tbl_varchar30;
 po_date_tbl po_tbl_varchar30;
--Bug9372785<END>

BEGIN
--Bug 5255550

-- Step1 get the release id from x_supply number into l_po_release_id;
-- debug <Start>
  po_debug.debug_begin(l_log_head);
-- debug <End>

 select instr(x_supply_number, '(')
  into   x_pare_left
  from   dual;

  if x_pare_left <= 0 then
     X_po_type := 'PO';
  ELSE
     x_po_type := 'RELEASE';
  end if;
  -- debug <START>
  PO_DEBUG.debug_var(l_log_head,l_progress,'x_po_type', x_po_type);
  -- debug <END>

l_progress:= '010';
  if X_po_type <> 'PO' then
    -- Get the index of ')' in the supply number
    select instr(x_supply_number, ')')
    into   x_pare_right
    from   dual;

    if x_pare_right <=0 then
      -- No ending parentheis.
      add_error_to_msg_list (
        p_api_name => l_api_name,
        p_message => 'Incorrect format for supply number: '||x_supply_number
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;

    select to_number(substr(x_supply_number, x_pare_left+1,
           x_pare_right - x_pare_left-1))
    into   x_release_num
    from   dual;


   l_progress:= '020';
   -- debug <START>
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_release_num', x_release_num);
   -- debug <END>

    begin
      -- Get the po_release_id out of supply_number
      select po_release_id,release_type
      into   l_po_release_id,l_release_type
      from   po_releases_all
      where  po_header_id = x_po_header_id
      and  release_num  = x_release_num;

   l_progress:= '030';
   -- debug <START>
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_release_id', l_po_release_id);
   -- debug <END>

    exception
      when no_data_found then
        -- Wrong format for supply number
        add_error_to_msg_list (
          p_api_name => l_api_name,
          p_message => 'Incorrect format for supply number: '||x_supply_number
        );
        RAISE FND_API.G_EXC_ERROR;
    end;
  end if;

  l_progress:= '040';
/* Step 2: save the existing org_context. get the org_id from
   po_header_id and set the context to this org_id */
 l_original_org_context := PO_MOAC_UTILS_PVT.get_current_org_id ; -- <R12 MOAC>

  -- debug <START>
  PO_DEBUG.debug_var(l_log_head,l_progress,'l_original_org_context', l_original_org_context);
  -- debug <END>

  --Bug 5255550
  BEGIN
    -- Retrieve the document's operating unit.
    IF (x_po_type = 'RELEASE') THEN
      SELECT org_id
      INTO l_document_org_id
      FROM po_releases_all
      WHERE po_release_id = l_po_release_id;/*Bug 5255550*/
    ELSE -- PO
      SELECT org_id
      INTO l_document_org_id
      FROM po_headers_all
      WHERE po_header_id = x_po_header_id;
    END IF; -- x_po_type

  l_progress:= '050';
  -- debug <START>
  PO_DEBUG.debug_var(l_log_head,l_progress,'l_document_org_id', l_document_org_id);
  -- debug <END>

  -- Set the org context to the document's OU.
    PO_MOAC_UTILS_PVT.set_org_context(l_document_org_id) ;       -- <R12 MOAC>
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      add_error_to_msg_list (
        p_api_name => l_api_name,
        p_message => 'Could not obtain the document operating unit.'
      );
      RAISE FND_API.G_EXC_ERROR;
  END;
   /*STEP 3: get all the shipments */

 /* It is not possible to use forall, and bulk collect simultaneously.
    Hence for performance reasons, we will use scratch pad, to insert data
   and then use bulk collect to get all the data in plsql table*/


/* If l_po_release_id is present, it means that the document is a release */
l_session_gt_key := PO_CORE_S.get_session_gt_nextval();

l_progress:= '060';
  -- debug <START>
  PO_DEBUG.debug_var(l_log_head,l_progress,'l_session_gt_key', l_session_gt_key);
  -- debug <END>

-- Bug 5610714 replacing x_shipment_nums.Count with X_po_line_ids.Count as x_shipment_nums can be Null
-- Bug 5610714 Added the following If Condition to handle the issue of passing x_shipment_nums as Null.
-- x_shipment_nums(1) will be Null if this call is routed thru overloaded RESCHEDULE api.

If x_shipment_nums is Null then
	forall i in 1..X_po_line_ids.Count


	/*
	  po_session_gt map:
	  KEY  : unique key for the current session processing
	  NUM1 : line_location_id
	  NUM2 : shipment_num
	  DATE1: db dates in po_line_locations_all
	  DATE2: new need by dates passed in
	  CHAR1: old need by dates passed in ,
		 using the char field since session_gt has only 2 date columns
	  CHAR2: indicates a valid record

	  */

	    insert into po_session_gt (key,
				       num1,
				       num2,
				       num3, --bug9372785
				       date1,
				       date2,
				       char1, -- we're using this for date passed in.
				       char2  -- we're using this to mark a valid record
				       )
	    select l_session_gt_key,
		   pll.line_location_id,
		   pll.shipment_num,
	           X_po_line_ids(i), --bug9372785
		   -- Have picked this from the existing code. From the planning perspective
		   -- promised date becomes important and should be preferred over nbd
		   Nvl(pll.promised_date,pll.need_by_date),
		   X_need_by_dates(i),
		   To_Char(X_need_by_dates_old(i),'DD-MON-YYYY:hh:mi:ss'),
		   'Y'
	      from po_line_locations_all pll
	     where pll.po_line_id = X_po_line_ids(i)
	       and pll.po_header_id = X_po_header_id
	       and (l_po_release_id is NULL OR
				pll.po_release_id = l_po_release_id);

ELSE
	forall i in 1..X_po_line_ids.Count

	/*
	  po_session_gt map:
	  KEY  : unique key for the current session processing
	  NUM1 : line_location_id
	  NUM2 : shipment_num
	  DATE1: db dates in po_line_locations_all
	  DATE2: new need by dates passed in
	  CHAR1: old need by dates passed in ,
		 using the char field since session_gt has only 2 date columns
	  CHAR2: indicates a valid record

	  */

	    insert into po_session_gt (key,
				       num1,
				       num2,
				       num3, --bug9372785
				       date1,
				       date2,
				       char1, -- we're using this for date passed in.
				       char2  -- we're using this to mark a valid record
				       )
	    select l_session_gt_key,
		   pll.line_location_id,
		   X_shipment_nums(i),
		   X_po_line_ids(i), --bug9372785
		   -- Have picked this from the existing code. From the planning perspective
		   -- promised date becomes important and should be preferred over nbd
		   Nvl(pll.promised_date,pll.need_by_date),
		   X_need_by_dates(i),
		   To_Char(X_need_by_dates_old(i),'DD-MON-YYYY:hh:mi:ss'),
		   'Y'
	      from po_line_locations_all pll
	     where pll.po_line_id = X_po_line_ids(i)
	       and pll.shipment_num = Nvl(X_shipment_nums(i), pll.shipment_num)
	       and pll.po_header_id = X_po_header_id
	       and (l_po_release_id is NULL OR
				pll.po_release_id = l_po_release_id);
End If;   -- End Of Bug 5610714

l_progress:= '065';
--bug9372785<START>
--update po_session_gt with line number as the error message should contain the
--line numbers
UPDATE po_session_gt scratch
SET num4 = (SELECT line_num FROM po_lines_all WHERE po_line_id = scratch.num3);
--bug9372785<END>

--Validations <START>

-- Validation #1 : Old Need by date passed and the db need by date should
--                 Match

l_progress:= '070';
UPDATE po_session_gt scratch
SET char2 = 'N'
WHERE  scratch.char1 <>
                To_char(scratch.date1,'DD-MON-YYYY:hh:mi:ss')
  AND scratch.KEY = l_session_gt_key;

 l_progress:= '080';
--bug9372785<START>
--We select the values for the tokens to be substituted in the error message
SELECT x_supply_number,scratch.num4,scratch.num2,scratch.char1, To_char(scratch.date1,'DD-MON-YYYY:hh:mi:ss')
BULK collect INTO supply_number_tbl,line_number_tbl,shipment_number_tbl,ascp_date_tbl,po_date_tbl
FROM po_session_gt scratch
WHERE scratch.KEY = l_session_gt_key
  AND Nvl(scratch.char2,'Y') = 'N';

  x_error_message := po_tbl_varchar2000();

  IF (supply_number_tbl.Count > 0) THEN
      FOR i IN 1..supply_number_tbl.Count LOOP
        FND_MESSAGE.SET_NAME('PO','PO_NEED_BY_DATE_MISMATCH');
        FND_MESSAGE.SET_TOKEN ('SUPPLY_NUMBER',supply_number_tbl(i));
        FND_MESSAGE.SET_TOKEN ('LINE_NUMBER',line_number_tbl(i));
        FND_MESSAGE.SET_TOKEN ('SHIPMENT_NUMBER',shipment_number_tbl(i));
        FND_MESSAGE.SET_TOKEN ('ASCP_DATE',ascp_date_tbl(i));
        FND_MESSAGE.SET_TOKEN ('PO_DATE',po_date_tbl(i));
        x_error_message.extend;
        x_error_message(i) := fnd_message.get;
        add_error_to_msg_list ( p_api_name => l_api_name,
                              p_message => x_error_message(i) );
      END LOOP;
  END IF;

   --we ll delete the contents in these collections to repopulate
    supply_number_tbl.DELETE;
    line_number_tbl.DELETE;
    shipment_number_tbl.DELETE;

--bug9372785<END>

-- Validation 2: New need by date should not be NULL
 l_progress:= '090';
UPDATE po_session_gt scratch
SET char2 = 'N'
WHERE  scratch.date2 IS NULL
  AND scratch.KEY = l_session_gt_key;

--bug9372785<START>

SELECT x_supply_number,scratch.num4,scratch.num2
BULK collect INTO  supply_number_tbl,line_number_tbl,shipment_number_tbl
FROM po_session_gt scratch
WHERE scratch.KEY = l_session_gt_key
  AND scratch.date2 IS NULL;
 x_error_count := x_error_message.Count;
IF (supply_number_tbl.Count > 0) THEN
     FOR i IN 1..supply_number_tbl.Count LOOP
      FND_MESSAGE.SET_NAME('PO','PO_NEED_BY_DATE_NULL');
      FND_MESSAGE.SET_TOKEN ('SUPPLY_NUMBER',supply_number_tbl(i));
      FND_MESSAGE.SET_TOKEN ('LINE_NUMBER',line_number_tbl(i));
      FND_MESSAGE.SET_TOKEN ('SHIPMENT_NUMBER',shipment_number_tbl(i));
      x_error_message.extend;
      x_error_message(x_error_count+i) := fnd_message.get;
      add_error_to_msg_list ( p_api_name => l_api_name,
                              p_message => x_error_message(i) );
   END LOOP;
END IF;
--bug9372785<END>

--Validations <END>

/*Step 4: construct two tables one for shipments, and one for need_by_dates*/
l_progress:= '100';

select num1, date2
bulk collect into l_line_location_id_tbl, l_need_by_date_tbl
from po_session_gt SCRATCH
WHERE KEY = l_session_gt_key
AND Nvl(scratch.char2,'Y') = 'Y' ;
/* Step 5:

if p_estimate_date, p_ship_method is not null then call reschedule req
    -- should be in the loop,
    -- since one po/release can be linked to different reqs.*/

-- should not do this for a scheduled release.
l_progress:= '110';

l_progress:= '120';
 IF ((p_estimated_pickup_dates IS NOT NULL) OR (p_ship_methods IS NOT NULL))
    AND (Nvl(l_release_type,'PO') <> 'SCHEDULED') THEN

l_progress:= '130';
          PO_RESCHEDULE_REQ(
              p_line_location_id_tbl      => l_line_location_id_tbl,
              p_estimated_pickup_dates    => p_estimated_pickup_dates,
              p_ship_methods              => p_ship_methods,
              x_return_status             => l_return_status);

  -- debug <START>
  PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status', l_return_status);
  -- debug <END>

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;
-- Construct the shipment changes object.
  /*Bug 5633563
  If profile option PO: Default PO Promise Date from Need By Date
  is set then new need_by_date must be copied to promised_by_date
 */
  fnd_profile.get('PO_NEED_BY_PROMISE_DEFAULTING', l_need_by_promise_def_prf);
  IF nvl(l_need_by_promise_def_prf,'N') = 'Y' THEN
    l_promised_by_date_tbl := PO_TBL_DATE();
    select date2
    bulk collect into l_promised_by_date_tbl
    from po_session_gt SCRATCH
    WHERE KEY = l_session_gt_key
    AND Nvl(scratch.char2,'Y') = 'Y' ;
    l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
    p_po_line_location_id => l_line_location_id_tbl,
    p_need_by_date => l_need_by_date_tbl,
    p_promised_date=> l_promised_by_date_tbl
    );
  ELSE
    l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
    p_po_line_location_id => l_line_location_id_tbl,
    p_need_by_date => l_need_by_date_tbl
    );
  END IF;
  /*Bug 5633563 :old code
    l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
    p_po_line_location_id => l_line_location_id_tbl,
    p_need_by_date => l_need_by_date_tbl
  );5633563*/

  -- Construct the document changes object.
  l_changes := PO_CHANGES_REC_TYPE.create_object (
    p_po_header_id => x_po_header_id,
    p_po_release_id => l_po_release_id,
    p_shipment_changes => l_shipment_changes
  );

/*Step 7: Call update_documents; */
l_progress:= '150';
PO_DOCUMENT_UPDATE_PVT.update_document(
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    x_return_status => l_return_status,
    p_changes => l_changes,
    p_run_submission_checks => FND_API.G_FALSE,
    p_launch_approvals_flag => FND_API.G_TRUE,
    p_buyer_id => NULL,
    p_update_source => NULL,
    p_override_date => NULL,
    x_api_errors => l_api_errors
  );

l_progress:= '160';
 /* Step 8: add the errors to the error list.*/
  -- debug <START>
  PO_DEBUG.debug_stmt(l_log_head,l_progress,'After return from update document');
  PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status', l_return_status);
  -- debug <END>

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   x_error_count := x_error_message.Count; --bug9372785
    -- PO Change API returned some errors. Add them to the API message list.
    FND_MSG_PUB.initialize;
    FOR i IN 1..l_api_errors.message_text.COUNT LOOP
      add_error_to_msg_list ( p_api_name => l_api_name,
                              p_message => l_api_errors.message_text(i) );
    --bug9372785<START>
    x_error_message.extend;
    x_error_message(x_error_count+i) := l_api_errors.message_text(i);
    --bug9372785<END>
    END LOOP;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

l_progress:= '160';
  -- debug <START>
  PO_DEBUG.debug_stmt(l_log_head,l_progress,'setting the context back to '
                      ||l_original_org_context);
   -- debug <END>
 /* Step 9: set the context back to the orginal context.*/
  PO_MOAC_UTILS_PVT.set_org_context(l_original_org_context) ;       -- <R12 MOAC>

  /* Delete all the data from po_session_gt */
l_progress:= '170';

  -- debug <START>
  PO_DEBUG.debug_stmt(l_log_head,l_progress,'Deleting data from session gt '
                      );
   -- debug <END>

  DELETE FROM po_session_gt
  WHERE KEY = l_session_gt_key;

 /*Step 10 : return from the api */
  PO_DEBUG.debug_end(l_log_head);
  return TRUE;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    -- Set the org context back to the original operating unit.
    IF (l_original_org_context IS NOT NULL) THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_original_org_context) ;       -- <R12 MOAC>
    END IF;
    DELETE FROM po_session_gt
    WHERE KEY = l_session_gt_key;
    RETURN FALSE;

  WHEN OTHERS THEN
      DELETE FROM po_session_gt
      WHERE KEY = l_session_gt_key;
      IF (l_original_org_context IS NOT NULL) THEN
         FND_CLIENT_INFO.set_org_context(l_original_org_context);
      END IF;

END RESCHEDULE;



-------------------------------------------------------------------------------
--Start of Comments
--Name: reschedule_req
--Function:
--Pre-reqs:
--  None.
--Modifies:
--  po_requistion_lines_all
--Locks:
--  None.
--  1. Given release_id and possible shipment_num, query out the backing
--   requistion lines and update them with new estimated_pickup_date and
--   ship_method.
--  2. Given po_line_id and possible shipment_num, query out the backing
--   requistion lines and update them with new estimated_pickup_date and
--   ship_method.
--IN:
--l_line_location_id_tbl
--  Specifies collection of line_location_ids
--p_estimated_pickup_date
--  Specifies new estimated_pickup_dates.
--p_ship_method
--  Sepcifies new ship_methods.
--OUT:
--x_return_status
--  Indicates API return status as 'S' or 'U'.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE PO_RESCHEDULE_REQ (
    p_line_location_id_tbl   IN         po_tbl_number,
    p_estimated_pickup_dates IN         po_tbl_date,
    p_ship_methods           IN         po_tbl_varchar30,
    x_return_status         OUT NOCOPY VARCHAR2
) IS
l_api_name CONSTANT VARCHAR2(30) := 'PO_RESCHEDULE_REQ';
l_log_head CONSTANT VARCHAR2(200) := g_module_prefix || l_api_name;
l_progress          VARCHAR2(3);
BEGIN
-- Bug 5255550
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_progress:= '000';
    PO_DEBUG.debug_begin(l_log_head);

        --SQL What: line_location_id, query out
        --SQL       the backing requistion lines and update them with new
        --SQL       estimated_pickup_dates and ship_methods
        --SQL Where:all req lines associated to the shipments, and having
        --SQL       estimated_pickup_dates, ship_methods.
        --SQL Why: Same as SQL What

        forall i in 1..p_line_location_id_tbl.count
        UPDATE po_requisition_lines_all REQ
           SET REQ.estimated_pickup_date =
                   NVL(p_estimated_pickup_dates(i), REQ.estimated_pickup_date),
               REQ.ship_method = NVL(p_ship_methods(i), REQ.ship_method)
         WHERE REQ.line_location_id = p_line_location_id_tbl(i);

l_progress:= '020';

PO_DEBUG.debug_end(l_log_head);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.initialize;
        add_error_to_msg_list (
            p_api_name => l_api_name,
            p_message  => 'Can not update estimated_pickup_date and ship_method on requisitions');

        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc (
                p_log_head => l_log_head,
                p_progress => l_progress || 'with sqlcode' || sqlcode);
        END IF;

END PO_RESCHEDULE_REQ;
-- <APS FPJ END>

-- <PO_CHANGE_API FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: add_error_to_msg_list
--Function:
--  Adds the given error message to the standard API message list and
--  to the FND log, if enabled.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE add_error_to_msg_list (
  p_api_name VARCHAR2,
  p_message  VARCHAR2
) IS
BEGIN
  -- Add a generic error to the API message list.
  FND_MESSAGE.set_name ('PO', 'PO_GENERIC_ERROR');
  FND_MESSAGE.set_token ('ERROR_TEXT', p_message);
  FND_MSG_PUB.add;

  -- Also add it to the FND log, if enabled.
  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
      FND_LOG.string( FND_LOG.LEVEL_ERROR, g_module_prefix || p_api_name,
                    p_message);
    END IF;
  END IF;
END add_error_to_msg_list;
-- <PO_CHANGE_API FPJ END>

-- <PO_CHANGE_API FPJ START>
-- In 115.13, removed the following private procedures from this package,
-- because their functionality is now handled by the PO Change API:
--   update_po_tables, update_po_tables_rel, check_revision_number,
--   wf_approve_doc, SetupWorkflow
-- <PO_CHANGE_API FPJ END>

END PO_RESCHEDULE_PKG;



/
