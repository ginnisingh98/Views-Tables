--------------------------------------------------------
--  DDL for Package Body PO_CONTROL_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CONTROL_CHECKS" AS
/* $Header: POXPOSCB.pls 120.3 2006/06/06 22:11:52 tpoon noship $ */

  -- Constants :

  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


  -- <Doc Manager Rewrite R12>: Removed po_check function, get_debug function
  -- Also removed unnecessary private global variables.

--<DropShip FPJ Start>
FUNCTION chk_drop_ship(
    p_doctyp  IN VARCHAR2,
    p_docid  IN NUMBER,
    p_lineid  IN NUMBER,
    p_shipid  IN NUMBER,
    p_reportid   IN NUMBER,
    p_action IN VARCHAR2,
    p_return_code IN OUT NOCOPY VARCHAR2)

RETURN BOOLEAN IS

l_po_header_id  PO_TBL_NUMBER;
l_po_release_id PO_TBL_NUMBER;
l_po_line_id    PO_TBL_NUMBER;
l_line_location_id PO_TBL_NUMBER;
l_shipnum       PO_TBL_NUMBER;
l_updatable_flag	VARCHAR2(1);
l_on_hold	        VARCHAR2(30);
l_order_line_status	NUMBER;
l_return_status VARCHAR2(30);
l_msg_data VARCHAR2(3000);
l_msg_count NUMBER;
l_message VARCHAR2(30);

l_api_name    CONSTANT VARCHAR(60) := 'po.plsql.PO_CONTROL_CHECKS.CHK_DROP_SHIP';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_api_name||'.' || l_progress,
      'Entered Procedure. DocType:' || p_doctyp || ' DocID:' || p_docid
      || ' p_lineid:' || p_lineid || ' p_shipid:' || p_shipid
      || ' p_reportid:' || p_reportid || ' p_action:' || p_action);
    END IF;
END IF;

-- Bug 3370387 START
-- For a PO or release, we only need to check the sales order references for
-- Finally Close. We do not need to check for the other actions (i.e. Cancel).
IF (p_doctyp IN ('PO', 'RELEASE')) AND (p_action <> 'FINALLY CLOSE') THEN
  RETURN TRUE;
END IF;
-- Bug 3370387 END

l_progress := '010';
--SQL What: Finds DropShip Shipments for this Entity
--Bug 3648769: tweaked the WHERE conditions on p_doctyp for performance
--Bug 5277112 Added NVLs around p_lineid and p_shipid. With the Doc Manager
--Rewrite, this procedure could now be called with these parameters passed
--as NULL instead of 0.
SELECT  s.po_header_id, s.po_release_id, s.po_line_id, s.line_location_id, s.shipment_num
BULK COLLECT INTO l_po_header_id, l_po_release_id, l_po_line_id, l_line_location_id, l_shipnum
FROM    po_requisition_lines_all rl, po_line_locations_all s
WHERE rl.line_location_id = s.line_location_id
AND (  (p_doctyp = 'REQUISITION' and rl.requisition_header_id = p_docid)
    OR (p_doctyp = 'PO' and s.po_header_id = p_docid)
    OR (p_doctyp = 'RELEASE' and s.po_release_id = p_docid)
    )
AND (NVL(p_lineid,0) = 0 OR s.po_line_id = p_lineid)
AND (NVL(p_shipid,0) = 0 OR s.line_location_id = p_shipid)
AND nvl(s.drop_ship_flag, 'N') = 'Y';

l_progress := '020';
-- If any of the Drop Ship Requisition Lines have open sales orders, return error
FOR I IN 1..l_line_location_id.count LOOP

    OE_DROP_SHIP_GRP.Get_Order_Line_Status(
         p_api_version => 1.0,
         p_po_header_id => l_po_header_id(i),
         p_po_release_id => l_po_release_id(i),
         p_po_line_id => l_po_line_id(i),
         p_po_line_location_id => l_line_location_id(i),
         p_mode  => 0, --To Check if Updatable
         x_updatable_flag  => l_updatable_flag,
         x_on_hold  => l_on_hold,
         x_order_line_status  => l_order_line_status,
         x_return_status  => l_return_status,
         x_msg_data  => l_msg_data,
         x_msg_count  => l_msg_count);

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_api_name|| '.' || l_progress,
    'After Call to OE_DROP_SHIP_GRP.Get_Order_Line_Status RetStatus: ' || l_return_status
    || 'POHeader:' || l_po_header_id(i) || ' Release:' || l_po_release_id(i)
    || ' Line:' || l_po_line_id(i) || ' LineLoc:' || l_line_location_id(i)
    || ' SOUpdatable:' || l_updatable_flag);
    END IF;
END IF;

    IF (l_return_status IS NULL) THEN
        l_return_status := FND_API.g_ret_sts_success;
    END IF;

    IF (l_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '030';
    IF (l_updatable_flag = 'Y') THEN
        -- There are open Sales Order Lines, do not allow PO Finally Close, Requisition Cancel
        -- Set p_return_code to SUBMISSION_FAILED and Insert Error into PO_ONLINE_REPORT
        IF p_action = 'FINALLY CLOSE' THEN
            l_message := 'PO_DROPSHIP_CANT_FIN_CLOSE';
        ELSE -- cancel requisition
            l_message := 'PO_DROPSHIP_CANT_CANCEL';
        END IF;
        p_return_code := 'SUBMISSION_FAILED';

        IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_api_name|| '.' || l_progress,
            'Submission Failed, ReturnCode:' || p_return_code
            || 'l_message:' || l_message);
            END IF;
        END IF;

        insert into po_online_report_text(online_report_id,
                                      last_update_login,
                                      last_updated_by,
                                      last_update_date,
                                      created_by,
                                      creation_date,
                                      line_num,
                                      shipment_num,
                                      distribution_num,
                                      sequence,
                                      text_line)
                              values (p_reportid,
                                      FND_GLOBAL.LOGIN_ID,
                                      FND_GLOBAL.USER_ID,
                                      sysdate,
                                      FND_GLOBAL.USER_ID,
                                      sysdate,
                                      NULL,
                                      l_shipnum(i),
                                      NULL,
                                      1,
                                      FND_MESSAGE.GET_STRING('PO', l_message));
        return TRUE;

    END IF;

END LOOP;

l_progress := '090';

return TRUE;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
        l_return_status := FND_API.G_RET_STS_ERROR;
        return FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return FALSE;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg('', l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        return FALSE;
END chk_drop_ship;
--<DropShip FPJ End>




END PO_CONTROL_CHECKS;

/
