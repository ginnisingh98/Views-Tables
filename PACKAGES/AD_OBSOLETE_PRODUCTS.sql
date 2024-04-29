--------------------------------------------------------
--  DDL for Package AD_OBSOLETE_PRODUCTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_OBSOLETE_PRODUCTS" AUTHID CURRENT_USER as
/* $Header: adobsprs.pls 120.2.12010000.2 2010/02/24 08:09:51 diverma ship $*/
   -- Star of Comments
   --
   -- Name
   --
   --   Package name:   AD_OBSOLETE_PRODUCTS
   --
   -- History
   --                Aug-10-05           hxue    Creation Date
   --
   --
procedure drop_synonym_list (x_appl_id in number,
                             x_app_short_name in varchar2);
   --
   -- Purpose
   --
   --   drop correspondence synonyms (in APPS) which points to the
   --   base schema objects
   --
   -- Arguments
   --
   -- Out Parameters
   --
   --   x_appl_id
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --

procedure drop_synonym_all (x_appl_id in number,
                            x_app_short_name in varchar2);
   --
   -- Purpose
   --
   --   drop all synonyms(in APPS) which points to objects in base schema
   --
   -- Arguments
   --
   -- Out Parameters
   --
   --   x_appl_id
   --   x_app_short_name
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --
procedure drop_apps_objects (x_appl_id in number);
   --
   -- Purpose
   --
   --   Drop objects based on application_id from .
   --   table AD_OBSOLETE_OBJECTS
   --
   -- Arguments
   --
   -- Out Parameters
   --
   --   x_appl_id
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --

procedure drop_schema_objects
     (aSqlcode      IN OUT NOCOPY  NUMBER,
      aSqlerrm      IN OUT NOCOPY  VARCHAR2,
      x_appl_id     IN             NUMBER,
      x_flag        IN             VARCHAR2);

   --
   -- Purpose
   --
   --   Drop schema objects based on application_id.
   --
   -- Arguments
   --
   -- In Parameters
   --
   --   aSqlcode
   --   aSqlerrm
   --   x_appl_id
   --   x_flag
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --

procedure undo_delete_object
     ( x_appl_id     in number,
       x_object_name in varchar2,
       x_object_type in varchar2);
   --
   -- Purpose
   --
   --   Do not delette the specific objects which are inserted in
   --   AD_OBSOLETE_OBJECTS table
   --
   -- Arguments
   --
   -- In Parameters
   --
   --   x_appl_id
   --   x_object_name
   --   x_object_type
   --
   -- Example
   --
   --   none
   --
   -- Notes
   --
   --   none
   --

end AD_OBSOLETE_PRODUCTS;

/
