--------------------------------------------------------
--  DDL for Package Body ITG_SYNCFIELDINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_SYNCFIELDINBOUND_PVT" AS
/* ARCS: $Header: itgvsfib.pls 120.3 2006/01/23 03:47:54 bsaratna noship $
 * CVS:  itgvsfib.pls,v 1.14 2002/12/23 21:20:30 ecoe Exp
 */

  l_debug_level         NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'ITG_SyncFieldInbound_PVT';
  g_action VARCHAR2(200);

  PROCEDURE Process_PoNumber(
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_reqid            IN         NUMBER,
        p_reqlinenum       IN         NUMBER,
        p_poid             IN         NUMBER,
        p_org              IN         NUMBER
  ) IS
        l_tmp              varchar2(30);
        l_req_hdr_id       varchar2(500);
        l_api_name         CONSTANT VARCHAR2(30) := 'Sync_PoLookup';
        l_api_version      CONSTANT NUMBER       := 1.0;
  BEGIN
        g_action := 'Field sync';
        /* Initialize return status */
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('ENTERING PPN-Process_PoNumber',2);
        END IF;

        BEGIN
                SAVEPOINT Process_PoNumber_PVT;
                BEGIN
                        FND_Client_Info.set_org_context(p_org); /*bug 4073707*/
	 			MO_GLOBAL.set_policy_context('S', p_org); -- MOAC
                EXCEPTION
                        WHEN OTHERS THEN
                            itg_msg.invalid_org(p_org);
                            RAISE FND_API.G_EXC_ERROR;
                END;

                ITG_Debug.setup(
                        p_reset     => TRUE,
                        p_pkg_name  => G_PKG_NAME,
                        p_proc_name => l_api_name);

                --Now in wrapper
                --FND_MSG_PUB.Initialize;
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PPN  - Top of procedure.' ,1);
                        itg_debug_pub.Add('PPN  - p_reqid'||p_reqid  ,1);
                        itg_debug_pub.Add('PPN  - p_reqlinenum'||p_reqlinenum,1);
                        itg_debug_pub.Add('PPN  - p_poid'||p_poid    ,1);
                        itg_debug_pub.Add('PPN  - p_org'||p_org      ,1);
                END IF;

                g_action := 'Sync-field parameter validation';

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PPN -  Validating inputs' ,1);
                END IF;

                ITG_BOAPI_Utils.validate('FIELDID',      NULL, NULL, FALSE, p_reqid);
                ITG_BOAPI_Utils.validate('ORACLEITG.REQLINENUM', NULL, NULL, FALSE, p_reqlinenum);
                ITG_BOAPI_Utils.validate('ORACLEITG.POID',       NULL, NULL, FALSE, p_poid);
                ITG_BOAPI_Utils.validate('ORACLEITG.POENTITY',        NULL, NULL, FALSE, p_org);

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PPN - Updating requisition info' ,1);
                END IF;
                /* 2683558 : multiple po numbers from SAP for the same Req. Updates the table
                   with "," seperated. */

                BEGIN
                        SELECT requisition_header_id
                        INTO     l_req_hdr_id
                        FROM   po_requisition_headers_all
                        WHERE  segment1 = to_char(p_reqid)
                        AND    org_id   = p_org;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                itg_msg.no_req_hdr(p_reqid,p_org);
                                RAISE FND_API.G_EXC_ERROR;
                END;

                g_action := 'Requisition-line update';

                UPDATE po_requisition_lines_all
                SET    attribute13 = attribute13 ||DECODE(NVL(attribute13,'FIRST'),'FIRST','',',')
                                        ||to_char(p_poid)
                WHERE  requisition_header_id = l_req_hdr_id
                AND    line_num              = p_reqlinenum;

                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('PPN - Update done' ,1);
                END IF;

                IF SQL%ROWCOUNT <> 1 THEN
                        IF (l_Debug_Level <= 1) THEN
                                itg_debug_pub.Add('PPN - Update failed' ,1);
                        END IF;

                        ITG_MSG.no_req_line(p_reqid, p_reqlinenum,p_org);
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                COMMIT WORK;
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                        ROLLBACK TO Process_PoNumber_PVT;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        ITG_msg.checked_error(g_action);

                WHEN OTHERS THEN
                        ROLLBACK TO Process_PoNumber_PVT;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        itg_debug.msg('Unexpected error (Field sync) - ' || substr(SQLERRM,1,255),true);
                        ITG_msg.unexpected_error(g_action);
        END;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('EXITING PPN-Process_PoNumber',2);
        END IF;

    --Removed FND_MSG_PUB.Count_And_Get
  END Process_PoNumber;
END ITG_SyncFieldInbound_PVT;

/
