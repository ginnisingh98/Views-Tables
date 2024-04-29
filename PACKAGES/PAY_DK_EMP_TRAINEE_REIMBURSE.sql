--------------------------------------------------------
--  DDL for Package PAY_DK_EMP_TRAINEE_REIMBURSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_EMP_TRAINEE_REIMBURSE" AUTHID CURRENT_USER AS
/* $Header: pydkaerrpt.pkh 120.3.12000000.1 2007/01/17 18:24:28 appldev noship $ */
     PROCEDURE POPULATE_DETAILS (
				P_QUARTER            IN  VARCHAR2,
				P_LEGAL_EMPLOYER_ID  IN  NUMBER,
				P_BUSINESS_GROUP_ID  IN  NUMBER,
				P_EFFECTIVE_DATE1    IN  VARCHAR2, --Bug 4895163 fix
				P_TEMPLATE_NAME      IN  VARCHAR2,
				P_XML                OUT NOCOPY CLOB
			     );
END PAY_DK_EMP_TRAINEE_REIMBURSE;


 

/
