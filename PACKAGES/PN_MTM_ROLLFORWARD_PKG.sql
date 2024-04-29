--------------------------------------------------------
--  DDL for Package PN_MTM_ROLLFORWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_MTM_ROLLFORWARD_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRLFWDS.pls 120.0.12010000.2 2010/01/22 13:34:20 kmaddi ship $ */

PROCEDURE rollforward_leases(   errbuf             OUT NOCOPY VARCHAR2,
                                retcode            OUT NOCOPY VARCHAR2,
                                p_lease_no_low         VARCHAR2,
                                p_lease_no_high        VARCHAR2,
                                p_lease_ext_end_dt     VARCHAR2,
                                p_lease_option         VARCHAR2);

PROCEDURE create_amendment(     p_lease_id             NUMBER,
                                p_lease_ext_end_dt     DATE,
				p_leaseChangeId    OUT NOCOPY NUMBER);

PROCEDURE rollforward_tenancies(p_lease_id             NUMBER,
                                p_lease_ext_end_dt     DATE,
                                p_old_ext_end_dt       DATE default NULL);

PROCEDURE rollforward_var_rent( p_lease_id             NUMBER,
                                p_lease_ext_end_dt     DATE,
                                p_old_ext_end_dt       DATE,
                                p_lease_change_id      NUMBER);

PROCEDURE rollforward_terms(    p_lease_id             NUMBER,
                                p_lease_ext_end_dt     DATE,
                                p_extend_ri            VARCHAR2);

PROCEDURE print_output(         p_lease_id             NUMBER);

END PN_MTM_ROLLFORWARD_PKG;

/
