--------------------------------------------------------
--  DDL for Package PQP_GB_PENSION_SCHEME_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PENSION_SCHEME_UPDATE" AUTHID CURRENT_USER AS
-- /* $Header: pqpgbschupd.pkh 120.1.12000000.1 2007/02/06 15:28:23 appldev noship $ */
--
Procedure process_scheme_type
                 (errbuf                OUT NOCOPY  VARCHAR2
                 ,retcode               OUT NOCOPY  VARCHAR2
                 ,p_business_group_id   IN          NUMBER
                 ,p_execution_mode      IN          VARCHAR2
                 );
END PQP_GB_PENSION_SCHEME_UPDATE;


 

/
