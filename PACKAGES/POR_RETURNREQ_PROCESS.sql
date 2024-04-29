--------------------------------------------------------
--  DDL for Package POR_RETURNREQ_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_RETURNREQ_PROCESS" AUTHID CURRENT_USER AS
/* $Header: PORRETRQS.pls 120.0.12010000.1 2014/06/05 01:27:21 uchennam noship $ */
/*===========================================================================
  FILE NAME    :         PORRETRQS.pls
  PACKAGE NAME:         POR_RETURNREQ_PROCESS

  DESCRIPTION:
      POR_RETURNREQ_PROCESS API creates a new requisition with copy of requisition lines
      and deleted the lines from original requisition.
      This gets called in Return Req Process in Buyer Work center when user dont want to return
      entire requisition..
 PROCEDURES: RETURNREQPROCESS

==============================================================================*/

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PKG_NAME CONSTANT VARCHAR2(40) := 'PO_REQUISITION_UPDATE_PVT';

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);

PROCEDURE RETURNREQPROCESS(p_reqlineid_in_tbl IN po_tbl_number, p_req_lineid_out_tbl OUT NOCOPY po_tbl_number,
                           x_retcode OUT NOCOPY VARCHAR2, x_error_msg OUT NOCOPY VARCHAR2);

END POR_RETURNREQ_PROCESS ;

/
