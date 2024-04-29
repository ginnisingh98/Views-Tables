--------------------------------------------------------
--  DDL for Package IBE_DELIVERABLE_EXPIMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DELIVERABLE_EXPIMP_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVDEIS.pls 120.0 2005/05/30 03:11:20 appldev noship $ */
/*======================================================================+
|  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA       |
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|     IBEVDEIS.pls                                                      |
|                                                                       |
| DESCRIPTION                                                           |
|     procedures for export and import of deliverables                  |
|                                                                       |
| HISTORY                                                               |
|     08/26/2003 ABHANDAR   Created                                     |
|     03/23/2005 RGUPTA     Added p_enable_debug param                  |
+=======================================================================*/


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_DELIVERABLE_EXPIMP_PVT';
-- added 07/29/03 abhandar for template export and import----------

 PROCEDURE save_template_mapping(
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 := FND_API.g_false,
  p_commit              IN VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY VARCHAR2,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_error_num           IN OUT NOCOPY NUMBER,
  p_error_limit         IN NUMBER,
  p_access_name         IN VARCHAR2,
  p_item_name           IN VARCHAR2,
  p_description         IN VARCHAR2,
  p_applicable_to       IN VARCHAR2,
  p_keywords            IN VARCHAR2,
  p_minisite_ids        IN JTF_NUMBER_TABLE,
  p_language_codes      IN JTF_VARCHAR2_TABLE_100,
  p_default_sites       IN JTF_VARCHAR2_TABLE_100,
  p_default_languages   IN JTF_VARCHAR2_TABLE_100,
  p_file_names          IN JTF_VARCHAR2_TABLE_100,
  p_enable_debug        IN VARCHAR2);


END IBE_DELIVERABLE_EXPIMP_PVT;

 

/
