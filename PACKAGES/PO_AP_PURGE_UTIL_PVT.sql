--------------------------------------------------------
--  DDL for Package PO_AP_PURGE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_PURGE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVPUUS.pls 115.1 2003/10/10 21:52:21 bao noship $ */

-- <DOC PURGE FPJ START>

PROCEDURE seed_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
);


PROCEDURE delete_req_related_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_low           IN          NUMBER,
  p_range_high          IN          NUMBER
);


PROCEDURE delete_po_related_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_low           IN          NUMBER,
  p_range_high          IN          NUMBER
);


PROCEDURE filter_more_referenced_req
( x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE filter_more_referenced_po
( x_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE log_purge_list_count
( p_module              IN          VARCHAR2,
  p_entity              IN          VARCHAR2
);

-- <DOC PURGE FPJ END>
END PO_AP_PURGE_UTIL_PVT;

 

/
