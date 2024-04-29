--------------------------------------------------------
--  DDL for Package CSF_GANTT_ICONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_GANTT_ICONS_PVT" AUTHID CURRENT_USER as
/* $Header: CSFGTICS.pls 120.0 2005/05/25 11:23:00 appldev noship $ */
  procedure update_row
  ( p_seq_id                IN OUT NOCOPY number
  , p_object_version_number IN OUT NOCOPY number
  , P_RANKING               IN number
  , P_ACTIVE                IN VARCHAR2
  , p_last_updated_by       IN   number
  , p_last_update_date      IN   date
  , p_last_update_login     IN   number
  );
end CSF_GANTT_ICONS_PVT;

 

/
