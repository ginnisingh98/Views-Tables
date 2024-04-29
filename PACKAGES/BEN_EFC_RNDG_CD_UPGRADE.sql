--------------------------------------------------------
--  DDL for Package BEN_EFC_RNDG_CD_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EFC_RNDG_CD_UPGRADE" AUTHID CURRENT_USER as
/* $Header: beefcrcu.pkh 120.0 2005/05/28 02:08:25 appldev noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      12-Jul-00	mhoyes     Created.
  -----------------------------------------------------------------------------
*/
--
procedure upgrade_rounding_codes
  (p_business_group_id in     number
  ,p_action_id         in     number
  --
  ,p_modify            in     boolean default false
  );
--
END ben_efc_rndg_cd_upgrade;

 

/
