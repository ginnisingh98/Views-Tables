--------------------------------------------------------
--  DDL for Package HZ_MIXNM_CONC_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_CONC_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHXCONS.pls 115.4 2003/10/04 01:19:54 kashan noship $ */

/**
 * PROCEDURE BulkCreateOrgSST
 *
 * DESCRIPTION
 *     Generate SST profile for organization.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_from_party_id           From party id.
 *     p_to_party_id             To party id.
 *     p_commit_size             Commit size.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE BulkCreateOrgSST (
    p_from_party_id                 IN     NUMBER,
    p_to_party_id                   IN     NUMBER,
    p_commit_size                   IN     NUMBER
);

/**
 * PROCEDURE BulkUpdateOrgSST
 *
 * DESCRIPTION
 *     Update SST profile for organization.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_from_party_id           From party id.
 *     p_to_party_id             To party id.
 *     p_commit_size             Commit size.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE BulkUpdateOrgSST (
    p_from_party_id                 IN     NUMBER,
    p_to_party_id                   IN     NUMBER,
    p_commit_size                   IN     NUMBER
);

/**
 * PROCEDURE BulkCreatePersonSST
 *
 * DESCRIPTION
 *     Generate SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_from_party_id           From party id.
 *     p_to_party_id             To party id.
 *     p_commit_size             Commit size.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE BulkCreatePersonSST (
    p_from_party_id                 IN     NUMBER,
    p_to_party_id                   IN     NUMBER,
    p_commit_size                   IN     NUMBER
);

/**
 * PROCEDURE BulkUpdatePersonSST
 *
 * DESCRIPTION
 *     Update SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_from_party_id           From party id.
 *     p_to_party_id             To party id.
 *     p_commit_size             Commit size.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE BulkUpdatePersonSST (
    p_from_party_id                 IN     NUMBER,
    p_to_party_id                   IN     NUMBER,
    p_commit_size                   IN     NUMBER
);

/**
 * PROCEDURE ImportCreatePersonSST
 *
 * DESCRIPTION
 *     Generate SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *     p_request_id                 IN     NUMBER,
 *     p_program_id                 IN     NUMBER,
 *     p_program_application_id     IN     NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-10-03   Kate Shan    o Created
 */

PROCEDURE ImportCreateOrgSST (
    p_wu_os                      IN     VARCHAR2,
    p_from_osr                   IN     VARCHAR2,
    p_to_osr                     IN     VARCHAR2,
    p_batch_id                   IN     NUMBER,
    p_request_id                 IN     NUMBER,
    p_program_id                 IN     NUMBER,
    p_program_application_id     IN     NUMBER
);

/**
 * PROCEDURE ImportUpdatePersonSST
 *
 * DESCRIPTION
 *     Update SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *     p_request_id                 IN     NUMBER,
 *     p_program_id                 IN     NUMBER,
 *     p_program_application_id     IN     NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-10-03   Kate Shan    o Created
 */

PROCEDURE ImportUpdateOrgSST (
    p_wu_os                      IN     VARCHAR2,
    p_from_osr                   IN     VARCHAR2,
    p_to_osr                     IN     VARCHAR2,
    p_batch_id                   IN     NUMBER,
    p_request_id                 IN     NUMBER,
    p_program_id                 IN     NUMBER,
    p_program_application_id     IN     NUMBER
);

/**
 * PROCEDURE ImportCreatePersonSST
 *
 * DESCRIPTION
 *     Generate SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *     p_request_id                 IN     NUMBER,
 *     p_program_id                 IN     NUMBER,
 *     p_program_application_id     IN     NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-10-03   Kate Shan    o Created
 */

PROCEDURE ImportCreatePersonSST (
    p_wu_os                      IN     VARCHAR2,
    p_from_osr                   IN     VARCHAR2,
    p_to_osr                     IN     VARCHAR2,
    p_batch_id                   IN     NUMBER,
    p_request_id                 IN     NUMBER,
    p_program_id                 IN     NUMBER,
    p_program_application_id     IN     NUMBER
);

/**
 * PROCEDURE ImportUpdatePersonSST
 *
 * DESCRIPTION
 *     Update SST profile for person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_wu_os                      IN     VARCHAR2,
 *     p_from_osr                   IN     VARCHAR2,
 *     p_to_osr                     IN     VARCHAR2,
 *     p_batch_id                   IN     NUMBER
 *     p_request_id                 IN     NUMBER,
 *     p_program_id                 IN     NUMBER,
 *     p_program_application_id     IN     NUMBER
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-10-03   Kate Shan    o Created
 */

PROCEDURE ImportUpdatePersonSST (
    p_wu_os                      IN     VARCHAR2,
    p_from_osr                   IN     VARCHAR2,
    p_to_osr                     IN     VARCHAR2,
    p_batch_id                   IN     NUMBER,
    p_request_id                 IN     NUMBER,
    p_program_id                 IN     NUMBER,
    p_program_application_id     IN     NUMBER
);


END HZ_MIXNM_CONC_DYNAMIC_PKG;

 

/
