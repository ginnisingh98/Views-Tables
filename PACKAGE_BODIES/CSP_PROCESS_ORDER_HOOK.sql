--------------------------------------------------------
--  DDL for Package Body CSP_PROCESS_ORDER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PROCESS_ORDER_HOOK" as
/* $Header: cspiohookb.pls 120.0.12010000.3 2012/03/20 09:14:03 htank noship $ */

PROCEDURE update_oe_dff_info(px_req_header_rec IN OUT NOCOPY csp_parts_requirement.header_rec_type
                        ,px_req_line_table IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
			,px_oe_header_rec  IN OUT   NOCOPY  oe_order_pub.header_rec_type
			,px_oe_line_table    IN OUT   NOCOPY  oe_order_pub.line_tbl_type) AS

BEGIN

 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_process_order_hook.update_oe_dff_info',
                      'Start of hook api ' );



    end if;
  --copy flex field related fields
  --px_oe_header_rec.attribute3 :='Test';

 if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                      'csp.plsql.csp_process_order_hook.update_oe_dff_info',
                      'End of hook api ' );
 end if;

END update_oe_dff_info;


END CSP_PROCESS_ORDER_HOOK;

/
