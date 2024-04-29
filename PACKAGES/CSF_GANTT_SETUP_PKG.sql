--------------------------------------------------------
--  DDL for Package CSF_GANTT_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_GANTT_SETUP_PKG" AUTHID CURRENT_USER as
/* $Header: CSFGTSTS.pls 120.0.12010000.2 2009/12/22 12:55:52 ramchint ship $ */


 type tooltip_setup_type is record
    ( seq_no	number
    , field_name	varchar2(50)
    , field_value	varchar2(50));

   type tooltip_setup_tbl is table of tooltip_setup_type INDEX BY BINARY_INTEGER;

 procedure insert_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , P_RANKING               IN number
  , P_ACTIVE                IN VARCHAR2
 );

  procedure update_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_created_by            IN OUT NOCOPY number
  , p_creation_date         IN OUT NOCOPY date
  , p_last_updated_by       IN OUT NOCOPY number
  , p_last_update_date      IN OUT NOCOPY date
  , p_last_update_login     IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , P_RANKING               IN number
  , p_ACTIVE                IN VARCHAR2
  );
  procedure load_row
  ( p_seq_id                IN  varchar2
  , p_owner                 IN varchar2
  , p_object_version_number IN varchar2
  , p_icon_file_name        IN varchar2
  , p_description           IN varchar2
  , p_RANKING               IN VARCHAR2
  , p_ACTIVE                IN VARCHAR2
  );
  PROCEDURE insert_rows
  ( p_setup_type		IN	varchar2
  , p_tooltip_setup_tbl IN	tooltip_setup_tbl
  , p_delete_rows	IN	boolean
  , p_user_id		IN	number
  , p_login_id     IN   number
  );
end CSF_GANTT_SETUP_PKG;

/
