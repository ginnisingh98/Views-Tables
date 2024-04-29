--------------------------------------------------------
--  DDL for Package PN_EXP_TO_EAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_EXP_TO_EAM_PVT" AUTHID CURRENT_USER as
/* $Header: PNXPEAMS.pls 120.2 2007/08/10 06:22:38 hrodda ship $ */


   PROCEDURE export_location_to_eam (
            errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
            p_batch_name            IN VARCHAR2,
            p_locn_code_from        IN pn_locations_all.location_code%TYPE,
            p_locn_code_to          IN pn_locations_all.location_code%TYPE,
            p_locn_type             IN pn_locations_all.location_type_lookup_code%TYPE,
            p_organization_id       IN mtl_serial_numbers.current_organization_id%TYPE,
            p_inventory_item_id     IN mtl_serial_numbers.inventory_item_id%TYPE,
            p_owning_department_id  IN mtl_serial_numbers.owning_department_id%TYPE,
            p_maintainable_flag     IN mtl_serial_numbers.maintainable_flag%TYPE);

END PN_EXP_TO_EAM_PVT;

/
