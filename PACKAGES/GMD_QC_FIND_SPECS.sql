--------------------------------------------------------
--  DDL for Package GMD_QC_FIND_SPECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_FIND_SPECS" AUTHID CURRENT_USER AS
/* $Header: GMDQFSPS.pls 115.5 2003/12/05 17:31:31 pupakare noship $ */

-- ==================================================
-- The body uses find_cust_spec_rec from gmd_qc_spec_match (GMDQMCHS.pls)
-- for customer specs.  All other searchs - vendor, item, production -
-- are in the body.
-- ==================================================
-- TKW 9/18/2002 B2578186 Location VARCHAR2(16)instead of VARCHAR2(4)

TYPE  item_rec_in IS record
                       (  item_id                     NUMBER
                        , date_effective              date
                        , orgn_code                   VARCHAR2(4)
                        , lot_id                      NUMBER
                        , whse_code                   VARCHAR2(4)
                        , location                    VARCHAR2(16)
                        , exact_match                 VARCHAR2(1)
                        , qcassy_typ_id               NUMBER
                       );

TYPE  supl_rec_in IS record
                       (  item_id                     NUMBER
                        , date_effective              date
                        , orgn_code                   VARCHAR2(4)
                        , lot_id                      NUMBER
                        , vendor_id                   NUMBER
                        , exact_match                 VARCHAR2(1)
                        , qcassy_typ_id               NUMBER
                       );

TYPE  prod_rec_in IS record
                       (  item_id                     NUMBER
                        , date_effective              date
                        , orgn_code                   VARCHAR2(4)
                        , lot_id                      NUMBER
                        , batch_id                    NUMBER
                        , formula_id                  NUMBER
                        , formulaline_id              NUMBER
                        , routing_id                  NUMBER
                        , routingstep_id              NUMBER
                        , routingstep_no              NUMBER
                        , oprn_id                     NUMBER
                        , charge                      NUMBER
                        , exact_match                 VARCHAR2(1)
                        , qcassy_typ_id               NUMBER
                       );

TYPE  spec_found_rec IS record
                        ( spec_hdr_id                 NUMBER
                         ,spec_match_type             VARCHAR2(4)
                         ,qc_spec_id                  NUMBER
                        ) ;


-- send in orgn_code, cust_id, item_id, order_id (if any), sched ship date
-- for Date_effective.
-- return spec_hdr_id, orgn_code of spec found


PROCEDURE find_spec_for_cust_info
                   ( p_cust_spec     IN GMD_QC_SPEC_MATCH.find_cust_spec_rec
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   );

PROCEDURE find_spec_for_supplier_info
                   ( p_supplier_in   IN supl_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   );

PROCEDURE find_spec_for_prod_info
                   ( p_prod_rec_in   IN  prod_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   );


PROCEDURE find_spec_for_item_info
                   ( p_item_rec_in   IN  item_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                  );

END   gmd_qc_find_specs;

 

/
