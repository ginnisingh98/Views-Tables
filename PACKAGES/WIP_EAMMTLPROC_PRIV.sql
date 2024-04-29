--------------------------------------------------------
--  DDL for Package WIP_EAMMTLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAMMTLPROC_PRIV" AUTHID CURRENT_USER as
 /* $Header: wipempps.pls 115.1 2003/08/06 18:43:15 kmreddy noship $ */

  procedure validateTxns(p_txnHdrID IN NUMBER,
                         x_returnStatus OUT NOCOPY VARCHAR2);

  procedure processCompTxn(p_compRec IN wip_mtlTempProc_grp.comp_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2);
end wip_eamMtlProc_priv;

 

/
