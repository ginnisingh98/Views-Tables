--------------------------------------------------------
--  DDL for Package PO_AP_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AP_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVPUDS.pls 115.0 2003/09/17 01:05:29 bao noship $ */

-- <DOC PURGE FPJ START>

PROCEDURE seed_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_last_activity_date IN DATE
);


PROCEDURE filter_records
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
   p_purge_status  IN VARCHAR2,
   p_purge_name IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_action         IN VARCHAR2,
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
(  p_api_version    IN NUMBER,
   p_init_msg_list  IN VARCHAR2,
   p_commit         IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_purge_name     IN VARCHAR2,
   p_purge_category IN VARCHAR2,
   p_range_size     IN NUMBER
);


PROCEDURE delete_purge_lists
(  p_api_version   IN NUMBER,
   p_init_msg_list IN VARCHAR2,
   p_commit        IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_data      OUT NOCOPY VARCHAR2,
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



END PO_AP_PURGE_PVT;

 

/
