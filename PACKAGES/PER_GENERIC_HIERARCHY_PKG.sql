--------------------------------------------------------
--  DDL for Package PER_GENERIC_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GENERIC_HIERARCHY_PKG" AUTHID CURRENT_USER as
/* $Header: peghrval.pkh 115.3 2002/12/05 16:47:30 pkakar noship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Generic Hierarchy Package
Purpose
        This package is used to perform operations for the generic hierarchy
        form such as validating hierarchies and copying hierarchies.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      25-Jan-01  gperry     Created
  115.3      05-Dec-02  pkakar     Added nocopy to parameters
*/
--
procedure validate_hierarchy(p_hierarchy_version_id in number);
--
procedure copy_hierarchy(p_hierarchy_id     in  number,
                         p_name             in  varchar2,
                         p_effective_date   in  date,
                         p_out_hierarchy_id out nocopy number);
--
procedure copy_hierarchy_version(p_hierarchy_version_id     in  number,
                                 p_new_version_number       in  number,
                                 p_date_from                in  date,
                                 p_date_to                  in  date,
                                 p_effective_date           in  date,
                                 p_out_hierarchy_version_id out nocopy number);
--
end per_generic_hierarchy_pkg;

 

/
