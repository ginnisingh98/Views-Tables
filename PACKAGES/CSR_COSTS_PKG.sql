--------------------------------------------------------
--  DDL for Package CSR_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSR_COSTS_PKG" AUTHID CURRENT_USER as
/*$Header: CSRSIPCS.pls 115.9 2002/11/22 13:01:46 jgrondel ship $
 +========================================================================+
 |                 Copyright (c) 1999 Oracle Corporation                  |
 |                    Redwood Shores, California, USA                     |
 |                         All rights reserved.                           |
 +========================================================================+
 Name
 ----
 CSR_COSTS_PKG

 Purpose
 -------
 Insert, update, delete or lock tables belonging to view CSR_COSTS_VL:
 - base table CSR_COSTS_ALL_B, and
 - translation table CSR_COSTS_ALL_TL.
 Restore data integrity to a corrupted base/translation pair.

 History
 -------
 10-DEC-1999 E.Kerkhoven       First creation
 13-NOV-2002 J. van Grondelle  Bug 2664009.
                               Added NOCOPY hint to procedure
                               out-parameters.
 +========================================================================+
*/
  procedure insert_row
  (
    p_row_id             IN OUT NOCOPY varchar2
  , p_cost_id            IN OUT NOCOPY number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
  , p_created_by         IN OUT NOCOPY number
  , p_creation_date      IN OUT NOCOPY date
  , p_last_updated_by    IN OUT NOCOPY number
  , p_last_update_date   IN OUT NOCOPY date
  , p_last_update_login  IN OUT NOCOPY number
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  , p_org_id             IN number
  );

  procedure lock_row
  (
    p_cost_id            IN number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  );

  procedure update_row
  (
    p_cost_id            IN number
  , p_name               IN varchar2
  , p_value              IN number
  , p_description        IN varchar2
  , p_last_updated_by    IN OUT NOCOPY number
  , p_last_update_date   IN OUT NOCOPY date
  , p_last_update_login  IN OUT NOCOPY number
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  );

  procedure delete_row
  (
    p_cost_id IN number
  );

  procedure add_language;

  procedure translate_row
  (
    p_cost_id           IN varchar2
  , p_owner             IN varchar2
  , p_description       IN varchar2
  );

  procedure load_row
  (
    p_cost_id            IN varchar2
  , p_name               IN varchar2
  , p_value              IN varchar2
  , p_description        IN varchar2
  , p_owner              IN varchar2
  , p_attribute1         IN varchar2
  , p_attribute2         IN varchar2
  , p_attribute3         IN varchar2
  , p_attribute4         IN varchar2
  , p_attribute5         IN varchar2
  , p_attribute6         IN varchar2
  , p_attribute7         IN varchar2
  , p_attribute8         IN varchar2
  , p_attribute9         IN varchar2
  , p_attribute10        IN varchar2
  , p_attribute11        IN varchar2
  , p_attribute12        IN varchar2
  , p_attribute13        IN varchar2
  , p_attribute14        IN varchar2
  , p_attribute15        IN varchar2
  , p_attribute_category IN varchar2
  , p_org_id             IN varchar2
  );

end CSR_COSTS_PKG;

 

/
