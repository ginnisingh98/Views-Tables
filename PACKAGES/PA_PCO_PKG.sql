--------------------------------------------------------
--  DDL for Package PA_PCO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PCO_PKG" AUTHID CURRENT_USER as
/* $Header: PAPCORPS.pls 120.2.12010000.1 2009/07/20 10:03:25 sosharma noship $ */

procedure create_fnd_attachment
    (
      p_doc_category_name varchar,
      p_entity_name varchar,
      p_file_name         fnd_lobs.file_name%type,
      p_file_content_type fnd_lobs.file_content_type%type ,
      p_CR_id  varchar,
      p_CR_version_number  varchar,
      p_file_id  IN OUT nocopy number);


procedure get_attachment_file_id
         (p_entity_name      IN  varchar2,
          p_pk1_value        IN  varchar2 default NULL,
          p_pk2_value        IN  varchar2 default NULL,
          p_pk3_value        IN  varchar2 default NULL,
          p_pk4_value        IN  varchar2 default NULL,
          p_pk5_value        IN  varchar2 default NULL,
          p_file_id          IN OUT nocopy number);

end;

/
