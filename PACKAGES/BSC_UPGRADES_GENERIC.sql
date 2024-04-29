--------------------------------------------------------
--  DDL for Package BSC_UPGRADES_GENERIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPGRADES_GENERIC" AUTHID CURRENT_USER AS
  /* $Header: BSCUPGNS.pls 120.0 2005/05/31 19:05:35 appldev noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCUPGNS.pls
---
---  DESCRIPTION
---     Package body File for Upgrade scripts on BSC side. bscup.sql will
--      call APIs from this package.
---
---  NOTES
---
---  HISTORY
---
---  05-Oct-2004 ankgoel  bug#3933075  Created
---===========================================================================

c_kpi_label       CONSTANT VARCHAR2(7) := '<kpi>';
c_function_id     CONSTANT NUMBER      := -1;

FUNCTION Upgrade_Role_To_Tabs
(
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION Upgrade_Tab_View_Functions
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION Upgrade_Tab_View_Kpi_labels
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


END BSC_UPGRADES_GENERIC;


 

/
