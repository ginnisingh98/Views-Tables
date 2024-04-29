--------------------------------------------------------
--  DDL for Package Body GMD_QC_FIND_SPECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_FIND_SPECS" AS
/* $Header: GMDQFSPB.pls 115.8 2003/12/05 17:37:01 pupakare noship $ */


PROCEDURE find_spec_for_cust_info
                   ( p_cust_spec     IN GMD_QC_SPEC_MATCH.find_cust_spec_rec
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   ) IS
BEGIN
  NULL;
END;

PROCEDURE find_spec_for_supplier_info
                   ( p_supplier_in   IN supl_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   )  IS
BEGIN
  NULL;
END;

PROCEDURE find_spec_for_prod_info
                   ( p_prod_rec_in   IN  prod_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                   )   IS
BEGIN
  NULL;
END;


PROCEDURE find_spec_for_item_info
                   ( p_item_rec_in   IN  item_rec_in
                   , p_api_version   IN NUMBER
                   , p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE
                   , p_spec_out      OUT NOCOPY spec_found_rec
                   , p_return_status OUT NOCOPY VARCHAR2
                   , p_msg_count     OUT NOCOPY NUMBER
                   , p_msg_stack     OUT NOCOPY VARCHAR2
                  ) IS
BEGIN
  NULL;
END;

END   gmd_qc_find_specs;

/
