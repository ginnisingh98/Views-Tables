--------------------------------------------------------
--  DDL for Package Body AML_FIND_PARTY_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_FIND_PARTY_MATCH_PVT" as
/* $Header: amlvcpmb.pls 115.1 2004/03/04 06:09:51 aanjaria noship $ */

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

PROCEDURE main (imp             IN OUT NOCOPY  as_import_interface%rowtype,
                x_return_status OUT NOCOPY varchar2) as

  l_party_id number;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF imp.party_id IS NULL THEN

    SELECT party_id
    INTO   l_party_id
    FROM   hz_parties hzp
    WHERE  hzp.party_name = imp.customer_name;

    imp.party_id := l_party_id;

    UPDATE as_import_interface
       SET party_id = l_party_id
     WHERE import_interface_id = imp.import_interface_id;

  END IF;

EXCEPTION
   -- Handle known exception
  WHEN NO_DATA_FOUND THEN
      l_party_id := NULL;

  WHEN TOO_MANY_ROWS THEN
      l_party_id := NULL;

   /* --dont need following..let lead import program handle the exception
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   */
END main;

END aml_find_party_match_pvt;

/
