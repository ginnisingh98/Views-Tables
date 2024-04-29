--------------------------------------------------------
--  DDL for Package IGI_SLS_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_SECURITY_PKG" AUTHID CURRENT_USER AS
-- $Header: igislsds.pls 120.5.12000000.2 2007/10/03 13:56:57 vspuli ship $

   PROCEDURE write_to_log            ( p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2);

   PROCEDURE get_mrc_mls_schemanames ( p_mls_schema_name  IN OUT NOCOPY VARCHAR2,
                                       p_mrc_schema_name  IN OUT NOCOPY VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   FUNCTION  check_allocation_exists (p_table_name        IN     igi_sls_secure_tables.table_name%TYPE)
             RETURN BOOLEAN;

   PROCEDURE create_drop_sls_objects ( p_mls_schema_name  IN     VARCHAR2,
                                       p_mrc_schema_name  IN     VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   PROCEDURE refresh_sls_objects     ( p_mls_schema_name  IN     VARCHAR2,
                                       p_mrc_schema_name  IN     VARCHAR2,
                                       errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   PROCEDURE populate_group_alloc    ( errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   PROCEDURE cleanup_data            ( errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   PROCEDURE consolidate_groups     ( errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER);

   PROCEDURE apply_security          ( errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER,
                                       p_mode             IN     VARCHAR2);

   PROCEDURE secure_existing_data    ( errbuf             IN OUT NOCOPY VARCHAR2,
                                       retcode            IN OUT NOCOPY NUMBER,
                                       p_sec_grp          IN     VARCHAR2);
END igi_sls_security_pkg;

 

/
