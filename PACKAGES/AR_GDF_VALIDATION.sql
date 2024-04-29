--------------------------------------------------------
--  DDL for Package AR_GDF_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GDF_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: ARXGDVHS.pls 120.1.12010000.2 2008/11/20 07:25:17 npanchak ship $ */

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_valid                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for global descriptive flex field validation   |
 |    during autoinvoice run.                                              |
 |                                                                         |
 |    The actual module is installed only when JL is installed.            |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    request_id        request_id of the autoinvoice run                  |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |    ar_gdf_validation.is_gdf_valid(99999)                                |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    28-Aug-97  Srinivasan Jandyala   Created.                            |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION is_gdf_valid(request_id IN NUMBER) RETURN NUMBER;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_postbatch_valid                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for global descriptive flex field validation   |
 |    during postbatch run.                                                |
 |                                                                         |
 |    The actual module is installed only when JL is installed.            |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    batch_id   IN NUMBER                                                 |
 |    cash_receipt_id IN NUMBER                                            |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    31-Aug-98  Nilesh Acharya             Created.                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION is_gdf_postbatch_valid(batch_id IN NUMBER,
                                cash_receipt_id IN NUMBER) RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_gdf_taxid_valid                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for taxid and global flexfields validation     |
 |    for Globalizations.                                                  |
 |                                                                         |
 |    This package may exist as a stub, however for future implementation  |
 |    this has been integrated as a hook.                                  |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   request_id        IN NUMBER                                           |
 |   org_id            IN NUMBER                                           |
 |   sob               IN NUMBER                                           |
 |   user_id           IN NUMBER                                           |
 |   application_id    IN NUMBER                                           |
 |   language_id       IN NUMBER                                           |
 |   program_id        IN NUMBER                                           |
 |   prog_appl_id      IN NUMBER                                           |
 |   last_update_login IN NUMBER                                           |
 |                                                                         |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    09-Sep-98  Vikram Ahluwalia           Created.                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION is_gdf_taxid_valid(request_id        IN NUMBER,
                            org_id            IN NUMBER,
                            sob               IN NUMBER,
                            user_id           IN NUMBER,
                            application_id    IN NUMBER,
                            language_id       IN NUMBER,
                            program_id        IN NUMBER,
                            prog_appl_id      IN NUMBER,
                            last_update_login IN NUMBER) RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |    is_cust_imp_valid                                                   |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for taxid and global flexfields validation     |
 |    for Globalizations.                                                  |
 |									   |
 | ARGUMENTS                                                               |
 |   request_id        IN NUMBER                                           |
 |   org_id            IN NUMBER                                           |
 |   sob               IN NUMBER                                           |
 |   user_id           IN NUMBER                                           |
 |   application_id    IN NUMBER                                           |
 |   language_id       IN NUMBER                                           |
 |   program_id        IN NUMBER                                           |
 |   prog_appl_id      IN NUMBER                                           |
 |   last_update_login IN NUMBER                                           |
 |   int_table_name    IN VARCHAR2                                                                      |
 | RETURNS                                                                 |
 |    1      If validation is successful                                   |
 |    0      If error occured during validation                            |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    10-MAR-00  Chirag Mehta               Created.                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION is_cust_imp_valid(request_id        IN NUMBER,
                            org_id            IN NUMBER,
                            sob               IN NUMBER,
                            user_id           IN NUMBER,
                            application_id    IN NUMBER,
                            language_id       IN NUMBER,
                            program_id        IN NUMBER,
                            prog_appl_id      IN NUMBER,
                            last_update_login IN NUMBER,
                            int_table_name    IN VARCHAR2) RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |    copy_gdf_attributes                                                  |
 |                                                                         |
 | PUBLIC VARIABLES                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is a stub module for copying global descriptive flex fields to  |
 |    to JG Tables from Autoinvoice and Copy Transactions.                 |
 |                                                                         |
 |    The global descriptive flex field copy package                       |
 |    JL_BR_SPED_PKG is installed only when JG is installed.               |
 |                                                                         |
 | ARGUMENTS                                                               |
 |    p_request_id        Request Id of Autoinvoice/Copy Transactions.     |
 |    p_called_from       Module Name of Autoinvoice/Copy Transactions.    |
 |                                                                         |
 | RETURNS                                                                 |
 |    None                                                                 |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |    ar_gdf_validation.copy_gdf_attributes(99999,'RAXTRX')                |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    26-Aug-08  Vijay Pusuluri   Created.                                 |
 +-------------------------------------------------------------------------*/

PROCEDURE copy_gdf_attributes(p_request_id IN NUMBER,
	p_called_from IN VARCHAR2);

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |  insert_global_table                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This is module for insertion of address related 			   |
 |    records in globalization tables   				   |
 |    for Globalizations.                                                  |
 |									   |
 | ARGUMENTS                                                               |
 |   p_address_id      IN NUMBER                                           |
 |   p_contributor_class_code IN VARCHAR2                                  |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    11-JUNE-00  Chirag Mehta               Created.                      |
 |                                                                         |
 +-------------------------------------------------------------------------*/



PROCEDURE insert_global_table(p_address_id             IN NUMBER,
                                   p_contributor_class_code IN VARCHAR2);

FUNCTION is_jg_installed RETURN VARCHAR2;

END AR_GDF_VALIDATION;


/
