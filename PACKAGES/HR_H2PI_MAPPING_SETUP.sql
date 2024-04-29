--------------------------------------------------------
--  DDL for Package HR_H2PI_MAPPING_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_MAPPING_SETUP" AUTHID CURRENT_USER AS
/* $Header: hrh2piim.pkh 120.0 2005/05/31 00:39:39 appldev noship $ */

PROCEDURE mapping_id_upload (p_errbuf    OUT NOCOPY VARCHAR2,
                             p_retcode   OUT NOCOPY NUMBER,
                             p_file_name         VARCHAR2,
                             p_business_group_id NUMBER);

END hr_h2pi_mapping_setup;

 

/
