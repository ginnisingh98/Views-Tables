--------------------------------------------------------
--  DDL for Package RCV_AP_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_AP_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVVPUDS.pls 115.0 2003/09/17 01:06:50 bao noship $ */

-- <DOC PURGE FPJ START>

PROCEDURE summarize_receipts
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
);


PROCEDURE delete_receipts
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
);

-- <DOC PURGE FPJ END>

END RCV_AP_PURGE_PVT;

 

/
