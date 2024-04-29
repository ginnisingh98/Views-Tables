--------------------------------------------------------
--  DDL for Package HXC_ALIAS_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcaliutl.pkh 115.4 2002/06/19 17:02:58 mhanda noship $ */
/*===========================================================================+
 |              Copyright (c) 1993 Oracle Corporation                        |
 |                 Redwood Shores, California, USA                           |
 |                      All rights reserved.                                 |
 +===========================================================================+
  Name
    hxc_alias_utils_pkg
  Purpose
    Used by HXCALIAS (Define Alternate Names) for the hxc_alias_definitions
    and the hxc_alias_values blocks.
  Notes

  History
 Version Date        Author         Comment
 -------+-----------+--------------+----------------------------------------
 115.0   01-Nov-00   RAMURTHY       Date created.
 115.0   21-MAR-02   mhanda         file name changed from hxaliutl.pkh to
                                    hxcaliutl.pkh due to GSCC Warnings.
                                    Added begin statement.
 ===========================================================================*/

PROCEDURE validate_defn_translation (p_alias_definition_id   IN    number,
                                     p_language              IN    varchar2,
                                     p_alias_definition_name IN    varchar2,
                                     p_description           IN    varchar2);

PROCEDURE validate_name_translation (p_alias_value_id    IN    number,
                                     p_language          IN    varchar2,
                                     p_alias_value_name  IN    varchar2);

END hxc_alias_utils_pkg;

 

/
