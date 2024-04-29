--------------------------------------------------------
--  DDL for Package WSH_IB_TXN_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_IB_TXN_MATCH_PKG" AUTHID CURRENT_USER as
/* $Header: WSHIBMAS.pls 115.3 2003/11/16 21:23:21 nparikh noship $ */

PROCEDURE matchTransaction
            (
              p_action_prms      IN             WSH_BULK_TYPES_GRP.action_parameters_rectype,
              p_line_rec         IN  OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
              x_return_status    OUT     NOCOPY VARCHAR2
            );

PROCEDURE handlePriorReceipts
            (
              p_action_prms      IN             WSH_BULK_TYPES_GRP.action_parameters_rectype,
              x_line_rec         IN  OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
              x_return_status    OUT     NOCOPY VARCHAR2
            );

END WSH_IB_TXN_MATCH_PKG;

 

/
