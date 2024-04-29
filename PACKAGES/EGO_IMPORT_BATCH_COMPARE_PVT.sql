--------------------------------------------------------
--  DDL for Package EGO_IMPORT_BATCH_COMPARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_IMPORT_BATCH_COMPARE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVCMPS.pls 120.5 2007/07/20 13:12:25 nshariff ship $ */
FUNCTION GET_COMPARED_DATA (p_ss_code         NUMBER,
                              p_ss_record     VARCHAR2,
                              p_batch_id      NUMBER,
                              p_mode          NUMBER,
                              p_item1         NUMBER,
                              p_item2         NUMBER,
                              p_item3         NUMBER,
                              p_item4         NUMBER,
                              p_org_Id        NUMBER,
	                      p_pdh_revision  VARCHAR2,
                              p_supplier_id   NUMBER DEFAULT NULL,
	                      p_supplier_site_id NUMBER DEFAULT NULL,
                              p_bundle_id     NUMBER DEFAULT NULL
                              )
                              RETURN    SYSTEM.EGO_COMPARE_VIEW_TABLE ;

FUNCTION GET_CURRENT_PDH_REVISION(p_inventory_item_id NUMBER
                                  ,p_organization_id NUMBER)
RETURN VARCHAR2;

FUNCTION REV_EXISTS_IN_PDH ( p_revision VARCHAR2,
                             p_inventory_item_id NUMBER,
                             p_organization_id NUMBER
                           )
RETURN varchar2;

END EGO_IMPORT_BATCH_COMPARE_PVT;

/
