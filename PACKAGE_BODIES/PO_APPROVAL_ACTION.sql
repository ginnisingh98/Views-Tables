--------------------------------------------------------
--  DDL for Package Body PO_APPROVAL_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVAL_ACTION" AS
/* $Header: POXWPA9B.pls 120.1.12010000.5 2012/06/14 18:48:04 gjyothi ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
 /*=======================================================================+
 | FILENAME
 |  POXWPA9S.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_APPROVAL_ACTION
 |
 | NOTES
 | CREATE
 | MODIFIED
 *=====================================================================*/

PROCEDURE get_online_report_text(itemtype VARCHAR2, itemkey VARCHAR2, p_online_report_id NUMBER);

-- for the code in podrstat, only check for now row is error case.
-- wft file need to change the error item type back to PO?

function req_state_check_approve( itemtype in VARCHAR2, itemkey in VARCHAR2)
RETURN VARCHAR2 is

  l_authorization_status varchar2(25);
  l_document_id number;
  l_code_exist varchar2(1);
  x_progress varchar2(200) := '000';

begin

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
  x_progress := 'req_state_check_approve 001';


  select nvl(PRH.authorization_status,'INCOMPLETE')
  into l_authorization_status
  from PO_REQUISITION_HEADERS PRH
  where PRH.requisition_header_id = l_document_id;

  if ( not (l_authorization_status = 'INCOMPLETE' or
      l_authorization_status = 'IN PROCESS' or
      l_authorization_status = 'REJECTED' or
      l_authorization_status = 'RETURNED' or
      l_authorization_status = 'PRE-APPROVED')) then
    return 'N';
  end if;

  x_progress := 'req_state_check_approve 002';

  -- do we need to do further document status check as in podrs.lpc?
  -- at most the no row check
  begin
    SELECT 'Y'
    into l_code_exist
    FROM   po_requisition_headers prh,
                       po_lookup_codes plc_clo
                WHERE  plc_clo.lookup_code = nvl(prh.closed_code, 'OPEN')
                AND    plc_clo.lookup_type = 'DOCUMENT STATE'
                AND    prh.requisition_header_id =  l_document_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 'N';
  end;

  x_progress := 'req_state_check_approve 003';

  return 'Y';

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_ACTION','req_state_check_approve',x_progress);
    raise;

end;


function po_state_check_approve( itemtype in VARCHAR2, itemkey in VARCHAR2, doctype in VARCHAR2)
RETURN VARCHAR2 is
  l_authorization_status varchar2(25);
  l_document_id number;
  l_code_exist varchar2(1);
  l_head_closed varchar2(25);
  l_frozen_flag varchar2(25);
  l_user_hold_flag varchar2(25);
  l_document_type varchar2(25);
  x_progress varchar2(200) := '000';

begin

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');
  x_progress := 'po_state_check_approve 001';


  if (doctype = 'RELEASE') then
    SELECT nvl(POR.authorization_status,'INCOMPLETE'),
                        nvl(POR.closed_code, 'OPEN'),
                        nvl(POR.frozen_flag, 'N'),
                        nvl(POR.hold_flag, 'N')
              	 INTO   l_authorization_status,
			l_head_closed,
                        l_frozen_flag,
                        l_user_hold_flag
              	 FROM   PO_RELEASES POR
                 WHERE  POR.po_release_id = l_document_id;
  else
    SELECT nvl(POH.authorization_status,'INCOMPLETE'),
                        nvl(POH.closed_code,'OPEN'),
                        nvl(POH.frozen_flag,'N'),
                        nvl(POH.user_hold_flag,'N')
                 INTO   l_authorization_status,
			l_head_closed,
                        l_frozen_flag,
                        l_user_hold_flag
                 FROM   PO_HEADERS POH
                 WHERE  po_header_id = l_document_id;

  end if;

  x_progress := 'po_state_check_approve 002' || ' auth='|| l_authorization_status
			|| '; closed='|| l_head_closed
                        || '; frozen='|| l_frozen_flag
                        || '; hold='|| l_user_hold_flag;


  if (not (l_authorization_status = 'INCOMPLETE' or
      l_authorization_status = 'IN PROCESS' or
      l_authorization_status = 'REJECTED' or
      l_authorization_status = 'RETURNED' or
      l_authorization_status = 'REQUIRES REAPPROVAL' or
      l_authorization_status = 'PRE-APPROVED')) then
    return 'N';
  end if;

  x_progress := 'po_state_check_approve 003';

/* Bug# 2654821: kagarwal
** Desc: We would be allowing POs to be approved even when the status is
** closed.
*/
  if (l_head_closed NOT IN ('OPEN', 'CLOSED') or
      l_frozen_flag <> 'N' or
      l_user_hold_flag <> 'N')  then
    return 'N';
  end if;

  x_progress := 'po_state_check_approve 004';

-- for the code in podrstat, the doc status is not used in old poxwpa4b, so we just need to check if row exists
  begin
    if (doctype = 'RELEASE') then
      select 'Y'
      into l_code_exist
              from   po_releases por,
                     po_lookup_codes plc_sta,
                     po_lookup_codes plc_can,
                     po_lookup_codes plc_clo,
                     po_lookup_codes plc_fro,
                     po_lookup_codes plc_hld
              where  plc_sta.lookup_code =
                     decode(por.approved_flag,
                            'R', por.approved_flag,
                                 nvl(por.authorization_status,'INCOMPLETE'))
              and    plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
              and    plc_can.lookup_code = 'CANCELLED'
              and    plc_can.lookup_type = 'DOCUMENT STATE'
              and    plc_clo.lookup_code = nvl(por.closed_code, 'OPEN')
              and    plc_clo.lookup_type = 'DOCUMENT STATE'
              and    plc_fro.lookup_code = 'FROZEN'
              and    plc_fro.lookup_type = 'DOCUMENT STATE'
              and    plc_hld.lookup_code = 'ON HOLD'
              and    plc_hld.lookup_type = 'DOCUMENT STATE'
              and    por.po_release_id = l_document_id;

    elsif  (l_document_type = 'PO' or l_document_type = 'PA') then
      select 'Y'
      into l_code_exist
                 from   po_headers poh,
                     po_lookup_codes plc_sta,
		     po_lookup_codes plc_can,
		     po_lookup_codes plc_clo,
		     po_lookup_codes plc_fro,
 		     po_lookup_codes plc_hld
              where  plc_sta.lookup_code =
                     decode(poh.approved_flag,
                            'R', poh.approved_flag,
                                 nvl(poh.authorization_status, 'INCOMPLETE'))
              and    plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
	      and    plc_can.lookup_code = 'CANCELLED'
              and    plc_can.lookup_type = 'DOCUMENT STATE'
              and    plc_clo.lookup_code = nvl(poh.closed_code, 'OPEN')
              and    plc_clo.lookup_type = 'DOCUMENT STATE'
              and    plc_fro.lookup_code = 'FROZEN'
              and    plc_fro.lookup_type = 'DOCUMENT STATE'
              and    plc_hld.lookup_code = 'ON HOLD'
              and    plc_hld.lookup_type = 'DOCUMENT STATE'
              and    poh.po_header_id    =  l_document_id;

    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return 'N';
  end;
  x_progress := 'po_state_check_approve 005';


  return 'Y';

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_ACTION','po_state_check_approve',x_progress);
    raise;

end;

procedure set_currency_rate(p_user_id             in number,
                            p_last_update_login   in number,
                            p_document_id         in number)
is
pragma AUTONOMOUS_TRANSACTION;

begin

  UPDATE PO_REQUISITION_LINES_ALL PORL
  SET PORL.last_update_date = sysdate,
      PORL.last_updated_by = p_user_id,
      PORL.last_update_login =  p_last_update_login,
      PORL.rate =
        (SELECT
           po_core_s.get_conversion_rate (FSP.set_of_books_id, PORL.currency_code, PORL.rate_date,  PORL.rate_type)
         FROM
           FINANCIALS_SYSTEM_PARAMS_ALL FSP,
           GL_SETS_OF_BOOKS SOB
         WHERE
           nvl(FSP.org_id, -9999) = nvl(PORL.org_id, -9999)      AND
           SOB.set_of_books_id    = FSP.set_of_books_id          AND
           SOB.currency_code     <> PORL.currency_code          AND
           PORL.currency_code is not null)
  WHERE   PORL.rate is NULL     AND
    PORL.requisition_header_id = p_document_id     AND
    PORL.rate_type <> 'User'
    AND     nvl(PORL.cancel_flag,'N') = 'N'     AND
    nvl(PORL.closed_code, 'OPEN') <> 'FINALLY CLOSED';

  commit;

end;

function req_complete_check(itemtype in VARCHAR2, itemkey in VARCHAR2)
return VARCHAR2 IS

-- pragma AUTONOMOUS_TRANSACTION;

l_user_id            number;
l_last_update_login  number;
l_document_id        number;
l_online_report_id   number;
l_error_occur        varchar2(1);
l_line_num           number := -1;
l_msg_text           varchar2(200);
l_sequence           number;
l_last_user_id       number;
x_progress           varchar2(240);
-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period VARCHAR2(1);

begin

-- should we check to see if any lines are qualify for update first? then 2 sqls.
-- do we need a lock for updating?
-- login id is same as the user id?


  x_progress := 'req_complete_check 001';


  l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'USER_ID');

  x_progress := 'req_complete_check 002' || to_char(l_user_id);


  l_last_update_login := l_user_id;
  l_last_user_id := l_user_id;

  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         		itemkey  => itemkey,
                                         		aname    => 'DOCUMENT_ID');

  x_progress := 'req_complete_check 003' || to_char(l_document_id);

  set_currency_rate(l_user_id,
                    l_last_update_login,
                    l_document_id);

  select PO_ONLINE_REPORT_TEXT_S.nextval
  into   l_online_report_id
  from SYS.DUAL;

  x_progress := 'req_complete_check 004, report id '|| to_char(l_online_report_id);


  l_sequence := 1;
  l_error_occur := 'N';
  l_msg_text := 'Requisitions has no lines';
  begin

  select 'Y'
  into l_error_occur
  FROM
  PO_REQUISITION_HEADERS PRH
  WHERE  PRH.requisition_header_id = l_document_id
    AND    NOT EXISTS (SELECT 'Lines Exist'     FROM   PO_REQUISITION_LINES
  PRL     WHERE  PRL.requisition_header_id = PRH.requisition_header_id
  AND    nvl(PRL.cancel_flag,'N') = 'N');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_occur := 'N';
  end;

  x_progress := 'req_complete_check 005' || l_error_occur;


  if(l_error_occur = 'Y') then

    INSERT INTO po_online_report_text  (online_report_id, last_update_login,
      last_updated_by, last_update_date, created_by, creation_date, line_num,
      shipment_num, distribution_num, sequence, text_line)
    VALUES  (
      l_online_report_id, l_last_update_login,     l_user_id, sysdate,
      l_user_id, sysdate,     0, 0, 0, l_sequence, l_msg_text);
    l_error_occur := 'N';

  end if;

  l_sequence := 2;
  l_msg_text := 'Requisition lines has no distributions';

  begin

  SELECT 'Y'
    INTO l_error_occur
  FROM
    PO_REQUISITION_LINES PRL
  WHERE PRL.requisition_header_id = l_document_id
    AND   nvl(PRL.cancel_flag,'N') = 'N'
    AND nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND   nvl(PRL.modified_by_agent_flag,'N') = 'N'
    AND   NOT EXISTS    (SELECT 'Dist Exist'    FROM PO_REQ_DISTRIBUTIONS PRD
          WHERE PRD.requisition_line_id = PRL.requisition_line_id)
    AND rownum=1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_occur := 'N';
  end;

  x_progress := 'req_complete_check 006' || l_error_occur;


  if(l_error_occur = 'Y') then

    INSERT INTO po_online_report_text  (online_report_id, last_update_login,
      last_updated_by, last_update_date, created_by, creation_date, line_num,
      shipment_num, distribution_num, sequence, text_line)
    SELECT
      l_online_report_id, l_last_update_login, l_user_id,     sysdate,
      l_user_id,sysdate,PRL.line_num,0,0,l_sequence, 'Line #' || PRL.line_num ||' ' || l_msg_text
    FROM
      PO_REQUISITION_LINES PRL
    WHERE PRL.requisition_header_id = l_document_id
      AND   nvl(PRL.cancel_flag,'N') = 'N'
      AND   nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND   nvl(PRL.modified_by_agent_flag,'N') = 'N'
      AND   NOT EXISTS  (SELECT 'Dist Exist'    FROM PO_REQ_DISTRIBUTIONS PRD
            WHERE PRD.requisition_line_id = PRL.requisition_line_id);

    l_error_occur := 'N';

  end if;

  l_sequence := 3;
  l_msg_text := 'does not match distribution quantity';
  begin

  /* Commented the following sql in bug 5864807
  SELECT 'Y'
  INTO l_error_occur
  FROM
    PO_REQ_DISTRIBUTIONS PRD,PO_REQUISITION_LINES PRL
  WHERE
    PRL.requisition_line_id = PRD.requisition_line_id     AND
    PRL.requisition_header_id = l_document_id   AND
    nvl(PRL.cancel_flag,'N') = 'N'
    AND nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'     AND
    nvl(PRL.modified_by_agent_flag,'N') = 'N' AND
    PRL.quantity <>       (SELECT
           sum(PRD.req_line_quantity)
           FROM PO_REQ_DISTRIBUTIONS PRD
           WHERE
           PRD.requisition_line_id = PRL.requisition_line_id)
           AND rownum=1; */

-- Added the following sql for bug 5864807
SELECT 'Y'
      INTO l_error_occur
      FROM
        PO_REQUISITION_LINES PRL
      WHERE
        PRL.requisition_header_id = l_document_id   AND
        nvl(PRL.cancel_flag,'N') = 'N'
        AND nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'     AND
        nvl(PRL.modified_by_agent_flag,'N') = 'N' AND
        --Start Bug 13065293
        round(PRL.quantity,15) <>       (SELECT
               round(sum(PRD.req_line_quantity),15)
        --End Bug 13065293
               FROM PO_REQ_DISTRIBUTIONS PRD
               WHERE
               PRD.requisition_line_id = PRL.requisition_line_id
               GROUP BY PRD.requisition_line_id)
        AND rownum=1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_error_occur := 'N';
  end;


  x_progress := 'req_complete_check 007' || l_error_occur;


  if(l_error_occur = 'Y') then

    INSERT INTO po_online_report_text(online_report_id,last_update_login,
      last_updated_by,last_update_date,created_by,creation_date,line_num,
      shipment_num,distribution_num,sequence,text_line)
    SELECT l_online_report_id, l_last_update_login, l_user_id,     sysdate,
      l_user_id,sysdate,PRL.line_num,0,0,l_sequence,
      'Line #' || PRL.line_num ||' Quantity '|| to_char (PRL.quantity) || ' ' ||
      l_msg_text || ' ' || to_char(sum(PRD.req_line_quantity))
    FROM
      PO_REQ_DISTRIBUTIONS PRD,PO_REQUISITION_LINES PRL
    WHERE
      PRL.requisition_line_id = PRD.requisition_line_id     AND
      PRL.requisition_header_id = l_document_id   AND
      nvl(PRL.cancel_flag,'N') = 'N'
      AND nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'     AND
      nvl(PRL.modified_by_agent_flag,'N') = 'N' AND
      PRL.quantity <>       (SELECT
           sum(PRD.req_line_quantity)
           FROM PO_REQ_DISTRIBUTIONS PRD
           WHERE
           PRD.requisition_line_id = PRL.requisition_line_id)
      GROUP BY   PRL.line_num,PRL.quantity;
    l_error_occur := 'N';

  end if;



  l_sequence := 4;
  l_msg_text := 'Lines with source type of INVENTORY must have only one distribution';

  INSERT INTO po_online_report_text  (online_report_id, last_update_login,
  last_updated_by, last_update_date, created_by, creation_date, line_num,
  shipment_num, distribution_num, sequence, text_line) SELECT
  l_online_report_id,l_last_update_login,l_last_user_id,     sysdate,
  l_user_id,sysdate,PRL.line_num,0,0,l_sequence,
  'Line #' ||PRL.line_num||' '|| l_msg_text
  FROM PO_REQUISITION_LINES PRL
  WHERE PRL.requisition_header_id = l_document_id
  AND   PRL.source_type_code = 'INVENTORY'     AND   nvl(PRL.cancel_flag,'N')
  = 'N'     AND   nvl(PRL.closed_code, 'OPEN') <> 'FINALLY CLOSED'     AND
  1 < (select count(PRD.requisition_line_id)     FROM  PO_REQ_DISTRIBUTIONS
  PRD     WHERE PRD.requisition_line_id = PRL.requisition_line_id);

  x_progress := 'req_complete_check 008';


  l_sequence := 5;
  l_msg_text := 'No foreign currency exchange rate';

  INSERT INTO po_online_report_text  (online_report_id, last_update_login,
  last_updated_by, last_update_date, created_by, creation_date, line_num,
  shipment_num, distribution_num, sequence, text_line)
  SELECT
  l_online_report_id,l_last_update_login,l_user_id,     sysdate,
  l_user_id,sysdate,PRL.line_num,0,0,l_sequence,
  'Line #' ||PRL.line_num||' '||l_msg_text
  FROM PO_REQUISITION_LINES PRL, FINANCIALS_SYSTEM_PARAMETERS FSP,
  GL_SETS_OF_BOOKS SOB
  WHERE PRL.requisition_header_id = l_document_id     AND
  nvl(PRL.cancel_flag, 'N') = 'N'     AND nvl(PRL.closed_code, 'OPEN') <>
  'FINALLY CLOSED'     AND SOB.set_of_books_id = FSP.set_of_books_id     AND
  SOB.currency_code <> PRL.currency_code     AND (   PRL.rate is null
   OR PRL.rate_type is null          OR (    PRL.rate_type <> 'User'
      AND PRL.rate_date is null));

  x_progress := 'req_complete_check 009';


  l_sequence := 6;
  l_msg_text := 'PO_SUB_REQ_INVALID_GL_DATE';

-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period := nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y');

--<Encumbrance FPJ>
-- Reformatted the following SQL.
-- Added transferred_to_oe/source_type conditions.

INSERT INTO po_online_report_text
(  online_report_id
,  last_update_login
,  last_updated_by
,  last_update_date
,  created_by
,  creation_date
,  line_num
,  shipment_num
,  distribution_num
,  sequence
,  text_line
)
SELECT
   l_online_report_id
,  l_last_update_login
,  l_user_id
,  sysdate
,  l_user_id
,  sysdate
,  PRL.line_num
,  0
,  PRD.distribution_num
,  l_sequence
,  'Line #'||PRL.line_num||' Distribution '||PRD.distribution_num||' '||l_msg_text
FROM
   FINANCIALS_SYSTEM_PARAMETERS FSP
,  PO_REQ_DISTRIBUTIONS PRD
,  PO_REQUISITION_LINES PRL
,  PO_REQUISITION_HEADERS_ALL PRH
WHERE PRD.requisition_line_id = PRL.requisition_line_id
AND   PRL.requisition_header_id = PRH.requisition_header_id
AND   PRL.requisition_header_id = l_document_id
AND   PRL.line_location_id IS NULL
AND
   (  NVL(PRH.transferred_to_oe_flag,'N') <> 'Y'
   OR NVL(PRL.source_type_code,'VENDOR') <> 'INVENTORY'
   )
AND   nvl(PRD.encumbered_flag,'N') = 'N'
AND   FSP.req_encumbrance_flag = 'Y'
AND   nvl(PRL.cancel_flag,'N') = 'N'
AND   nvl(PRL.closed_code,'OPEN') <> 'FINALLY CLOSED'
AND    Nvl(prl.modified_by_agent_flag,'N') = 'N' /*Bug 4882209*/
AND   not exists (
   select 'find if the GL date is not within Open period'
   from
      GL_PERIOD_STATUSES PS1
   ,  GL_PERIOD_STATUSES PS2
   ,  GL_SETS_OF_BOOKS GSOB
   WHERE PS1.application_id  = 101
   AND   PS1.set_of_books_id = FSP.set_of_books_id
   -- bug 5498063 <R12 GL PERIOD VALIDATION>
AND ((  l_validate_gl_period IN ('Y','R') -- 14178037 <GL DATE Project>
             and PS1.closing_status IN ('O', 'F'))
         OR
          (l_validate_gl_period = 'N'))
   -- AND   PS1.closing_status IN ('O','F')
   AND   trunc(nvl(PRD.GL_ENCUMBERED_DATE,PS1.start_date))
      BETWEEN trunc(PS1.start_date) AND trunc(PS1.end_date)
   AND   PS1.period_year <= GSOB.latest_encumbrance_year
   AND   PS1.period_name = PS2.period_name
   AND   PS2.application_id  = 201
   AND   PS2.closing_status  = 'O'
   AND   PS2.set_of_books_id = FSP.set_of_books_id
   AND   GSOB.set_of_books_id = FSP.set_of_books_id
   )
;

  x_progress := 'req_complete_check 010';

--  commit;

  -- if there is report inserted, update wf attribute

  l_error_occur := 'N';

/* Bug# 2959296: kagarwal
** Desc: If the po_online_report_text has more than one record for the
** given online_report_id, the following SQL will error out.
** Since all we want to know is if there is any row, appending the where
** clause rownum = 1
*/

  begin
    select 'Y'
    into l_error_occur
    from po_online_report_text
    where online_report_id = l_online_report_id
    and rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_progress := 'req_complete_check 011';


      return 'Y';
  end;

  if(l_error_occur = 'Y') then

    x_progress := 'req_complete_check 012';


    wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'ONLINE_REPORT_ID',
                                   avalue     =>  l_online_report_id);

    /* Get the text of the online_report and store in workflow item attribute */
    get_online_report_text( itemtype, itemkey, l_online_report_id );

    return('N');
  end if;

  x_progress := 'req_complete_check 013';

  return('N');
EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_ACTION','req_complete_check',x_progress);
    raise;

end;

PROCEDURE get_online_report_text(itemtype VARCHAR2, itemkey VARCHAR2, p_online_report_id NUMBER) is

cursor C1(p_online_report_id NUMBER) is
select text_line from po_online_report_text where online_report_id = p_online_report_id
order by sequence;

l_report_text          varchar2(240);
l_concat_report_text varchar2(2000);

    /* Bug# 1381880: draising
    ** Forward Fix of Bug#1338645
    **
    ** Desc: If the online_report_text exceeds 2000 char, copy only 2000 char
    ** into ONLINE_REPORT_TEXT attribute.
    **
    ** Each time we add l_report_text and 2 spaces to the l_concat_report_text
    ** hence check if (len_txt + len_rep) < 1999.
    */

len_rep NUMBER := 0;
len_txt NUMBER := 0;

x_progress   varchar2(200);
BEGIN

  OPEN C1(p_online_report_id);
  LOOP

    FETCH C1 into l_report_text;

    EXIT WHEN C1%NOTFOUND;
    len_txt := length(l_report_text);

    IF ((len_rep + len_txt) < 1999)  THEN
         l_concat_report_text := l_concat_report_text || '  ' || l_report_text;
    ELSE
          l_concat_report_text := l_concat_report_text || '  ' || substr(l_report_text,1,(2000 - len_rep -2));
    END IF;

    len_rep := length(l_concat_report_text);

  END LOOP;

  CLOSE C1;

  wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'ONLINE_REPORT_TEXT',
                              avalue     =>  l_concat_report_text);

  x_progress := 'PO_APPROVAL_ACTION.get_online_report_text. ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_ACTION','get_online_report_text',x_progress);
    raise;

END get_online_report_text;


end PO_APPROVAL_ACTION;

/
