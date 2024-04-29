--------------------------------------------------------
--  DDL for Package PN_VAR_UPG_VOL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_UPG_VOL_PKG" AUTHID CURRENT_USER AS
-- $Header: PNUPGVOS.pls 120.0.12010000.1 2009/10/19 07:06:58 rrambati noship $

PROCEDURE vr_update_volume_status ( errbuf                OUT NOCOPY  VARCHAR2,
                                     retcode               OUT NOCOPY  VARCHAR2,
                                     p_property_code       IN  VARCHAR2,
                                     p_property_name       IN  VARCHAR2,
                                     p_location_code_from  IN  VARCHAR2,
                                     p_location_code_to    IN  VARCHAR2,
                                     p_lease_num_from      IN  VARCHAR2,
                                     p_lease_num_to        IN  VARCHAR2,
                                     p_vrent_num_from      IN  VARCHAR2,
                                     p_vrent_num_to        IN  VARCHAR2);

PROCEDURE process_vr_upgrade( p_var_rent_id IN NUMBER);

END PN_VAR_UPG_VOL_PKG;

/
