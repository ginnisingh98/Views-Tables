--------------------------------------------------------
--  DDL for Package PO_GA_ORG_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GA_ORG_ASSIGN_PVT" AUTHID CURRENT_USER AS
/* $Header: POXPORGS.pls 115.7 2003/10/02 05:15:54 jskim noship $ */

PROCEDURE insert_row
(    p_init_msg_list    IN  VARCHAR2,                      --< Shared Proc FPJ >
     x_return_status    OUT NOCOPY VARCHAR2,               --< Shared Proc FPJ >
     p_org_assign_rec   IN  PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
     x_row_id           OUT NOCOPY     ROWID
);

--< Shared Proc FPJ Start >
-- Modified the existing update_row procedure
PROCEDURE update_row
(   p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    p_org_assign_rec    IN  PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
    p_row_id            IN  ROWID
);
--< Shared Proc FPJ End >

PROCEDURE delete_row
(   p_po_header_id      IN      PO_GA_ORG_ASSIGNMENTS.po_header_id%TYPE
);

--< Shared Proc FPJ Start >
PROCEDURE delete_row
(   p_po_header_id    IN NUMBER,
    p_organization_id IN NUMBER
);

-- Modified the existing lock_row procedure
PROCEDURE lock_row
(   p_org_assign_rec IN PO_GA_ORG_ASSIGNMENTS%ROWTYPE,
    p_row_id         IN ROWID
);

PROCEDURE copy_rows
(
    p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    p_from_po_header_id IN  NUMBER,
    p_to_po_header_id   IN  NUMBER,
    p_last_update_date  IN  DATE,
    p_last_updated_by   IN  NUMBER,
    p_creation_date     IN  DATE,
    p_created_by        IN  NUMBER,
    p_last_update_login IN  NUMBER
);
--< Shared Proc FPJ End >

END PO_GA_ORG_ASSIGN_PVT;

 

/
