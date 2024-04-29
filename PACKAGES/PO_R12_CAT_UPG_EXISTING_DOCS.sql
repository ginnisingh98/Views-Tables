--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_EXISTING_DOCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_EXISTING_DOCS" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_EXISTING_DOCS.pls 120.4 2006/05/10 14:56:54 vkartik noship $ */

PROCEDURE upgrade_existing_docs (
  p_batch_size    IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE process_modified_po_lines(p_batch_size     IN NUMBER default 2500,
                                    p_base_lang      IN FND_LANGUAGES.language_code%TYPE  default null,
                                    p_start_id       IN NUMBER  default null,
                                    p_end_id         IN NUMBER  default null,
                                    x_return_status  IN OUT NOCOPY VARCHAR,
                                    x_rows_processed IN OUT NOCOPY NUMBER);
PROCEDURE process_new_po_lines(     p_batch_size     IN NUMBER default 2500,
                                    p_base_lang      IN FND_LANGUAGES.language_code%TYPE  default null,
                                    p_start_id       IN NUMBER  default null,
                                    p_end_id         IN NUMBER  default null,
                                    x_return_status  IN OUT NOCOPY VARCHAR,
                                    x_rows_processed IN OUT NOCOPY NUMBER);
PROCEDURE create_line_attributes(p_batch_size IN NUMBER,
                                 p_base_lang  IN FND_LANGUAGES.language_code%TYPE);
PROCEDURE create_line_attributes_tlp(p_batch_size IN NUMBER,
                                     p_base_lang  IN FND_LANGUAGES.language_code%TYPE);
PROCEDURE process_modified_rt_lines(p_batch_size IN NUMBER,
                                    p_base_lang  IN FND_LANGUAGES.language_code%TYPE);
PROCEDURE process_new_rt_lines(p_batch_size IN NUMBER,
                               p_base_lang  IN FND_LANGUAGES.language_code%TYPE);
PROCEDURE debug_profiles_on;

END PO_R12_CAT_UPG_EXISTING_DOCS;

 

/
