--------------------------------------------------------
--  DDL for Package PN_RECOVERY_TENANCY_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_RECOVERY_TENANCY_UPG_PKG" AUTHID CURRENT_USER AS
-- $Header: PNUPTENS.pls 115.0 2003/06/27 18:22:24 psidhu noship $

PROCEDURE tenancy_upgrade_batch(errbuf                OUT NOCOPY VARCHAR2,
                                retcode               OUT NOCOPY VARCHAR2,
                                p_lease_num_from      IN VARCHAR2,
                                p_lease_num_to        IN VARCHAR2,
                                p_rec_space_std_code  IN VARCHAR2,
                                p_rec_type_code       IN VARCHAR2,
                                p_upd_customer        IN VARCHAR2,
                                p_upd_fin_oblg_end_dt IN VARCHAR2);

FUNCTION cust_space_assign_exists(p_tenancy_id NUMBER)
RETURN BOOLEAN;

END pn_recovery_tenancy_upg_pkg;


 

/
