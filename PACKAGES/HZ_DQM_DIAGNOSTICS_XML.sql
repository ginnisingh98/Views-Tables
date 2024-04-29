--------------------------------------------------------
--  DDL for Package HZ_DQM_DIAGNOSTICS_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_DIAGNOSTICS_XML" AUTHID CURRENT_USER AS
/*$Header: ARHDXMLS.pls 120.1 2005/09/07 21:18:05 schitrap noship $ */

PROCEDURE DQM_SETUP_OVERVIEW_XML;
FUNCTION GET_TABLE_SIZE(p_table_name VARCHAR2) RETURN  NUMBER;
PROCEDURE GENERATE_XML(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, whichXml VARCHAR2);

END HZ_DQM_DIAGNOSTICS_XML;


 

/
