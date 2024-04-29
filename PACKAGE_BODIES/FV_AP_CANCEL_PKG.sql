--------------------------------------------------------
--  DDL for Package Body FV_AP_CANCEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_CANCEL_PKG" AS
/* $Header: FVAPCANB.pls 120.0 2006/01/04 21:47:57 ksriniva noship $ */
    g_module_name VARCHAR2(100) := 'fv.plsql.FV_AP_CANCEL_PKG.';

FUNCTION OPEN_PO_SHIPMENT(P_Invoice_Id 	IN   NUMBER,
			  P_Return_Code OUT  NOCOPY VARCHAR2 ) return BOOLEAN IS

  l_module_name         VARCHAR2(200) := g_module_name || 'OPEN_PO_SHIPMENT';
  l_errbuf              VARCHAR2(1024);
  l_line_location_id	po_line_locations_all.line_location_id%type;
  l_po_line_id		po_lines_all.po_line_id%type;
  l_po_header_id	po_headers_all.po_header_id%type;
  l_po_doc_type		po_headers.type_lookup_code%type;
  l_po_sub_type		po_headers.type_lookup_code%type;
  l_return_code		varchar2(30);
  l_inv_accounting_date date;

  -- Start Bug 3706938
  l_ret_status                  VARCHAR2(100);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);
  l_po_line_loc_tab             PO_TBL_NUMBER;
  -- End Bug 3706938

BEGIN

  SELECT pd.line_location_id,
	 pd.po_line_id,
	 decode(pd.po_release_id, null, pd.po_header_id, pd.po_release_id),
	 decode(ph.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
	 decode(pd.po_release_id, NULL, ph.type_lookup_code,
		pr.release_type),
	 MAX(aid.accounting_date)
  INTO l_line_location_id,
       l_po_line_id,
       l_po_header_id,
       l_po_doc_type,
       l_po_sub_type,
       l_inv_accounting_date
  FROM po_distributions pd,
       po_headers ph,
       po_releases pr,
       ap_invoice_distributions aid,
       po_line_locations pll								-- Bug 3706938
  WHERE aid.invoice_id		= P_invoice_id
  AND   aid.po_distribution_id	= pd.po_distribution_id
  AND   ph.po_header_id		= pd.po_header_id
  AND   ph.po_header_id		= pll.po_header_id					-- Bug 3706938
  AND   pll.line_location_id	= pd.line_location_id
  AND   pd.po_release_id	= pr.po_release_id(+)
  -- AND   aid.final_match_flag	= 'D'							-- Bug 3706938
  AND   decode(PLL.final_match_flag, 'Y', 'D', NVL(AID.final_match_flag, 'N')) = 'D'	-- Bug 3706938
  GROUP BY pd.line_location_id,
	   pd.po_line_id,
	   decode(pd.po_release_id, null, pd.po_header_id, pd.po_release_id),
	   decode(ph.type_lookup_code, 'STANDARD', 'PO', 'RELEASE'),
	   decode(pd.po_release_id, NULL, ph.type_lookup_code,
		 pr.release_type);

  IF (NOT(PO_ACTIONS.Close_PO (p_docid        => l_po_header_id,
                               p_doctyp       => l_po_doc_type,
                               p_docsubtyp    => l_po_sub_type,
                               p_lineid       => l_po_line_id,
                               p_shipid       => l_line_location_id,
                               p_action       => 'INVOICE OPEN',
                               p_reason       => NULL,
                               p_calling_mode => 'AP',
                               p_conc_flag    => 'N',
                               p_return_code  => p_return_code,
                               p_auto_close   => 'N',
                               p_action_date  => l_inv_accounting_date,
			       p_origin_doc_id  => p_invoice_id))) /*bug3132946*/
       THEN

      RETURN(FALSE);

   ELSE
      IF p_return_code in ('STATE_FAILED','SUBMISSION_FAILED') THEN

         RETURN(FALSE);

      END IF;
  END IF;

  -- Start Bug 3706938
  l_po_line_loc_tab := po_tbl_number();
  l_po_line_loc_tab.extend;
  l_po_line_loc_tab(l_po_line_loc_tab.last) := l_line_location_id;

  PO_AP_INVOICE_MATCH_GRP.set_final_match_flag
                                (p_api_version          => '1.0',
                                 p_entity_type          => 'PO_LINE_LOCATIONS',
                                 p_entity_id_tbl        => l_po_line_loc_tab,
                                 p_final_match_flag     => 'N',
                                 p_init_msg_list        => FND_API.G_FALSE ,
                                 p_commit               => FND_API.G_FALSE ,
                                 x_ret_status           => l_ret_status,
                                 x_msg_count            => l_msg_count,
                                 x_msg_data             => l_msg_data);

  IF NOT (l_ret_status = FND_API.G_RET_STS_SUCCESS) THEN

     RETURN FALSE;

  END IF;
  -- End Bug 3706938

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,l_errbuf);
    RAISE;

END OPEN_PO_SHIPMENT;

END FV_AP_CANCEL_PKG;

/
