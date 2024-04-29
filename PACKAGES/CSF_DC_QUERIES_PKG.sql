--------------------------------------------------------
--  DDL for Package CSF_DC_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DC_QUERIES_PKG" AUTHID CURRENT_USER as
/* $Header: CSFDCQTS.pls 120.0 2005/05/25 11:19:27 appldev noship $ */

  procedure insert_row
  ( p_row_id                IN OUT NOCOPY varchar2
  , p_query_id              IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN number
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN date
  , p_end_date_active       IN date
  );

  procedure update_row
  ( p_query_id              IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN number
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN date
  , p_end_date_active       IN date
  );


  procedure translate_row
  ( p_query_id              IN varchar2
  , p_owner                 IN varchar2
  , p_name                  IN varchar2
  , p_description           IN varchar2
  );

  procedure load_row
  ( p_query_id              IN varchar2
  , p_owner                 IN varchar2
  , p_object_version_number IN varchar2
  , p_name                  IN varchar2
  , p_description           IN varchar2
  , p_where_clause          IN varchar2
  , p_user_id               IN varchar2
  , p_seeded_flag           IN varchar2
  , p_start_date_active     IN varchar2
  , p_end_date_active       IN varchar2
  );

  procedure add_language;

end CSF_DC_QUERIES_PKG;

 

/
