--------------------------------------------------------
--  DDL for Package HR_H2PI_MAIN_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_MAIN_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: hrh2pimn.pkh 120.0 2005/05/31 00:40:29 appldev noship $ */

PROCEDURE upload (p_errbuf      OUT NOCOPY  VARCHAR2,
                  p_retcode     OUT NOCOPY  NUMBER,
                  p_file_name         VARCHAR2,
                  p_business_group_id NUMBER);
PROCEDURE retry_upload (p_errbuf      OUT NOCOPY  VARCHAR2,
                        p_retcode     OUT NOCOPY  NUMBER,
                        p_business_group_id NUMBER);
PROCEDURE clear_staging_tables (p_from_client_id NUMBER);
FUNCTION get_from_business_group_id RETURN NUMBER;
FUNCTION get_request_id (p_process VARCHAR2) RETURN NUMBER;

END hr_h2pi_main_upload;

 

/
