--------------------------------------------------------
--  DDL for Package AML_FIND_PARTY_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_FIND_PARTY_MATCH_PVT" AUTHID CURRENT_USER as
/* $Header: amlvcpms.pls 115.1 2004/03/04 06:10:25 aanjaria noship $ */

-- Start of Comments
-- Package name     : aml_find_party_match_pvt
-- NOTE             : This is a custom program that contains user logic.
--                    This program should be used as a template and customers
--                    can modify the code for their filtering/validations.
--
--                    This program will be invoked by lead import program
--                    for each record before processing the import record
--                    through DQM. Execution of this program is controlled
--                    by profile 'OS: Execute custom code from lead import'.
--
-- End of Comments

PROCEDURE main (imp             IN  OUT NOCOPY as_import_interface%rowtype,
                x_return_status OUT NOCOPY varchar2);

END aml_find_party_match_pvt;

 

/
