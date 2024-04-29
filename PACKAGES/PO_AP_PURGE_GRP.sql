--------------------------------------------------------
--  DDL for Package PO_AP_PURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_PURGE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGPUDS.pls 115.0 2003/09/17 00:59:20 bao noship $ */

-- Purge Category
G_PUR_CAT_SIMPLE_REQ     CONSTANT VARCHAR2(30) := 'SIMPLE REQUISITIONS';
G_PUR_CAT_SIMPLE_PO      CONSTANT VARCHAR2(30) := 'SIMPLE POS';
G_PUR_CAT_MATCHED_PO_INV CONSTANT VARCHAR2(30) := 'MATCHED POS AND INVOICES';

-- Filter Action
G_FILTER_ACT_REF_PO_REQ  CONSTANT VARCHAR2(30) := 'FILTER REF PO AND REQ';
G_FILTER_ACT_DEP_PO_REQ  CONSTANT VARCHAR2(30) := 'FILTER DEPENDENT PO AND REQ';
G_FILTER_ACT_DEP_PO_AP   CONSTANT VARCHAR2(30) := 'FILTER DEPENDENT PO AND AP';

FUNCTION validate_purge
(
    p_po_header_id          IN          PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN VARCHAR2;


PROCEDURE purge
(
    p_api_version           IN          NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2
);

FUNCTION referencing_docs_exist
(   p_po_header_id       IN     PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;


-- <DOC PURGE FPJ START>

PROCEDURE seed_records
(  p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_purge_name         IN VARCHAR2,
   p_purge_category     IN VARCHAR2,
   p_last_activity_date IN DATE
);



PROCEDURE filter_records
(  p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_purge_status       IN VARCHAR2,
   p_purge_name         IN VARCHAR2,
   p_purge_category     IN VARCHAR2,
   p_action             IN VARCHAR2,
   x_po_records_filtered OUT NOCOPY VARCHAR2
);



PROCEDURE confirm_records
(  p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_purge_name         IN VARCHAR2,
   p_purge_category     IN VARCHAR2,
   p_last_activity_date IN DATE
);


PROCEDURE summarize_records
(  p_api_version        IN          NUMBER,
   p_init_msg_list      IN          VARCHAR2,
   p_commit             IN          VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_data           OUT NOCOPY  VARCHAR2,
   p_purge_name         IN          VARCHAR2,
   p_purge_category     IN          VARCHAR2,
   p_range_size         IN          NUMBER
);


PROCEDURE delete_records
(  p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2,
   p_commit             IN VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_purge_name         IN VARCHAR2,
   p_purge_category     IN VARCHAR2,
   p_range_size         IN NUMBER
);


PROCEDURE delete_purge_lists
(  p_api_version    IN NUMBER,
   p_init_msg_list  IN VARCHAR2,
   p_commit         IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2
);


PROCEDURE delete_history_tables
(  p_api_version    IN NUMBER,
   p_init_msg_list  IN VARCHAR2,
   p_commit         IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2
);


PROCEDURE count_po_rows
(  p_api_version    IN          NUMBER,
   p_init_msg_list  IN          VARCHAR2,
   x_return_status  OUT NOCOPY  VARCHAR2,
   x_msg_data       OUT NOCOPY  VARCHAR2,
   x_po_hdr_count   OUT NOCOPY  NUMBER,
   x_rcv_line_count OUT NOCOPY  NUMBER,
   x_req_hdr_count  OUT NOCOPY  NUMBER,
   x_vendor_count   OUT NOCOPY  NUMBER,
   x_asl_count      OUT NOCOPY  NUMBER,
   x_asl_attr_count OUT NOCOPY  NUMBER,
   x_asl_doc_count  OUT NOCOPY  NUMBER
);

-- <DOC PURGE FPJ END>

END PO_AP_PURGE_GRP;

 

/
