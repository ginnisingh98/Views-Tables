--------------------------------------------------------
--  DDL for Package PO_JL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_JL_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVJLIS.pls 120.1 2005/06/21 02:44:28 vsanjay noship $ */

/*Bug#4430300 Replaced the references to JLBR data types with the po standard data types */
PROCEDURE get_trx_reason_code
    ( p_fsp_inv_org_id       IN  NUMBER
    , p_inventory_org_id_tbl IN  po_tbl_number
    , p_item_id_tbl          IN  po_tbl_number
    , p_org_id               IN  NUMBER
    , x_return_status        OUT NOCOPY VARCHAR2
    , x_trx_reason_code_tbl  OUT NOCOPY po_tbl_varchar100
    , x_error_code_tbl       OUT NOCOPY po_tbl_number
    );

PROCEDURE get_trx_reason_code
    ( p_fsp_inv_org_id    IN  NUMBER
    , p_inventory_org_id  IN  NUMBER
    , p_item_id           IN  NUMBER
    , p_org_id            IN  NUMBER
    , x_return_status     OUT NOCOPY VARCHAR2
    , x_trx_reason_code   OUT NOCOPY VARCHAR2
    );

PROCEDURE chk_def_trx_reason_flag
    ( x_return_status       OUT NOCOPY VARCHAR2
    , x_def_trx_reason_flag OUT NOCOPY VARCHAR2
    );

END PO_JL_INTERFACE_PVT;

 

/
