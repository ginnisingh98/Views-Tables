--------------------------------------------------------
--  DDL for Package GMF_MTL_GET_ORG_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_MTL_GET_ORG_ID" AUTHID CURRENT_USER AS
/* $Header: gmforgis.pls 115.1 2002/10/29 22:02:16 jdiiorio ship $ */
  PROCEDURE proc_inv_get_org_id (
          st_date  in out nocopy date,
          en_date    in out nocopy date,
          pm_lookup_cd    in out nocopy varchar2,
          ship_to_loc_id  in out nocopy number,
          inv_org_id     in out nocopy varchar2,
          row_to_fetch in number,
          error_status out nocopy number);
END GMF_MTL_GET_ORG_ID;

 

/
