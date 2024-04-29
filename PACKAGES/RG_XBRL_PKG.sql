--------------------------------------------------------
--  DDL for Package RG_XBRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_XBRL_PKG" AUTHID CURRENT_USER AS
/* $Header: rgxbrlps.pls 120.0 2003/05/14 00:26:28 vtreiger noship $ */
--
-- Name
--   rg_xbrl_pkg
-- Purpose
--   to include all server side procedures and packages for
--   XBRL taxonomy processing
-- Notes
--
-- History
--   02/19/03	V Treiger	Created
--
--
-- Procedures
-- Name
--   Upload_taxonomy
-- Purpose
--   wrapper to run procedure load_taxonomy from SRS
-- Arguments
--   p_full_tax_name - Taxonomy Name
--   p_tax_file_name - Taxonomy Alias
--   p_tax_descr     - Taxonomy Description
PROCEDURE Upload_taxonomy(errbuf	OUT NOCOPY VARCHAR2,
		          retcode	OUT NOCOPY VARCHAR2,
		          p_full_tax_name IN VARCHAR2,
		          p_tax_file_name IN VARCHAR2,
		          p_tax_descr     IN VARCHAR2);

-- Name
--   Remove_taxonomy
-- Purpose
--   wrapper to run procedure delete_taxonomy from SRS
-- Arguments
--   p_full_tax_name - Taxonomy Name
PROCEDURE Remove_taxonomy(errbuf	OUT NOCOPY VARCHAR2,
		          retcode	OUT NOCOPY VARCHAR2,
		          p_full_tax_name IN VARCHAR2);

-- Name
--   delete_taxonomy
-- Purpose
--   removes taxonomy from taxonomy storage and elements storage
-- Arguments
--   p_full_tax_name - Taxonomy Name
PROCEDURE delete_taxonomy(p_full_tax_name IN VARCHAR2);

-- Name
--   load_taxonomy
-- Purpose
--   load taxonomy into taxonomy storage and elements storage
-- Arguments
--   p_full_tax_name - Taxonomy Name
--   p_tax_file_name - Taxonomy Alias
--   p_tax_descr     - Taxonomy Description
PROCEDURE load_taxonomy(p_full_tax_name  IN VARCHAR2,
                        p_tax_file_name  IN VARCHAR2,
                        p_tax_descr      IN VARCHAR2);

-- Name
--   update_flags
-- Purpose
--   updates flags in elements storage
-- Arguments
--   p_taxonomy_id - Taxonomy ID
PROCEDURE update_flags(p_taxonomy_id IN NUMBER);

-- Name
--   verify_import
-- Purpose
--   get import URLs from Taxonomy Schema definition
--   and check that import taxonomies have been loaded
--   before processing current Taxonomy
-- Arguments
--   p_filename   - Taxonomy Schema Definition filename
--   p_valid_flag - Imported taxonomies presence validation flag
--   p_valid_str  - String of all URLs from imported taxonomies
PROCEDURE verify_import(p_filename IN VARCHAR2,
                        p_valid_flag IN OUT NOCOPY NUMBER,
                        p_valid_str  IN OUT NOCOPY VARCHAR2,
                        p_srch_str1 IN VARCHAR2,
                        p_srch_str2 IN VARCHAR2,
                        p_srch_str3 IN VARCHAR2,
                        p_srch_str4 IN VARCHAR2);

-- Name
--   read_url
-- Purpose
--   get URL and linkbase names from
--   Taxonomy Schema definition
-- Arguments
--   filename     - Taxonomy Schema Definition filename
--   p_first_srch - first search string
--   p_last_replace - last search string
--   p_url_ret   - Taxonomy URL string
--   p_link_srch - linkbase search string
--   p_link_c - Calculation linkbase name
--   p_link_d - Definition linkbase name
--   p_link_c - Label linkbase name
--   p_link_c - Presentation linkbase name
--   p_link_c - Reference linkbase name
PROCEDURE  read_url(filename IN VARCHAR2,p_first_srch IN VARCHAR2,p_last_replace IN VARCHAR2,
  p_url_ret IN OUT NOCOPY VARCHAR2,p_link_srch IN VARCHAR2,p_link_c IN OUT NOCOPY VARCHAR2,
  p_link_d IN OUT NOCOPY VARCHAR2,p_link_l IN OUT NOCOPY VARCHAR2,p_link_p IN OUT NOCOPY VARCHAR2,
  p_link_r  IN OUT NOCOPY VARCHAR2);

-- Name
--   insert_tax_clob
-- Purpose
--   insert taxonomy elements in elements storage from
--   taxonomy schema definition
-- Arguments
--   p_taxonomy_id - Taxonomy ID
--   filename      - Taxonomy Schema Definition filename
--   p_valid_str   - String of Imported Taxonomies URLs
PROCEDURE insert_tax_clob(p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2,
                          p_valid_str   IN VARCHAR2);

-- Name
--   update_lbl_clob
-- Purpose
--   update label details in elements storage from
--   label linkbase
-- Arguments
--   p_tax_name    - Taxonomy Alias
--   p_taxonomy_id - Taxonomy ID
--   filename      - Label Linkbase filename
PROCEDURE update_lbl_clob(p_tax_name    IN VARCHAR2,
                          p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2);

-- Name
--   update_dfn_clob
-- Purpose
--   update parent details in elements storage from
--   definition linkbase
-- Arguments
--   p_tax_name    - Taxonomy Alias
--   p_taxonomy_id - Taxonomy ID
--   filename      - Definition Linkbase filename
PROCEDURE update_dfn_clob(p_tax_name    IN VARCHAR2,
                          p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2);

END RG_XBRL_PKG;

 

/
