--------------------------------------------------------
--  DDL for Package PQP_EXCP_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXCP_RPT" AUTHID CURRENT_USER AS
/* $Header: pqpexrcp.pkh 115.3 2003/06/19 08:41:08 appatil noship $ */

procedure PQP_EXR_CSV_FORMAT (errbuf OUT NOCOPY VARCHAR2
                   ,retcode OUT NOCOPY NUMBER
                   ,p_ppa_finder IN VARCHAR2
                   ,p_report_date IN varchar2
                   ,p_business_group_id IN NUMBER
                   ,p_report_name IN VARCHAR2
                   ,p_group_name IN VARCHAR2
                   ,p_override_variance_type IN VARCHAR2
                   ,p_override_variance_value IN NUMBER
                   );

end PQP_EXCP_RPT;

 

/
