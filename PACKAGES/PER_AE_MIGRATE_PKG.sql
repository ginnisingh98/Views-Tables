--------------------------------------------------------
--  DDL for Package PER_AE_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AE_MIGRATE_PKG" AUTHID CURRENT_USER AS
/* $Header: peaemigr.pkh 120.0 2006/04/09 22:33:06 abppradh noship $ */

  PROCEDURE update_scl_from_ddf
    (errbuf                      OUT NOCOPY VARCHAR2
    ,retcode                    OUT NOCOPY VARCHAR2
    ,p_business_group_id IN NUMBER);

END per_ae_migrate_pkg;


 

/
