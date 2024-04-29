--------------------------------------------------------
--  DDL for Package Body GMF_MTL_GET_ORG_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_MTL_GET_ORG_ID" as
/* $Header: gmforgib.pls 115.1 2002/10/29 22:03:27 jdiiorio ship $ */
  CURSOR cur_inv_get_org_code(st_date date, en_date date,
  pm_lookup_cd varchar2, ship_to_loc_id number)  IS
        SELECT   o.organization_code from
                     org_organization_definitions o
        WHERE    organization_id > 0;

  PROCEDURE proc_inv_get_org_id (
          st_date  in out nocopy date,
          en_date    in out nocopy date,
          pm_lookup_cd    in out nocopy varchar2,
          ship_to_loc_id  in out nocopy number,
          inv_org_id     in out nocopy varchar2,
          row_to_fetch in number,
          error_status out nocopy number) IS

  Begin  /* Beginning of procedure proc_gl_get_sob_id */
    IF NOT cur_inv_get_org_code%ISOPEN THEN
      OPEN cur_inv_get_org_code(st_date, en_date, pm_lookup_cd,
      ship_to_loc_id);
    END IF;

    FETCH cur_inv_get_org_code
    INTO   inv_org_id;

      if cur_inv_get_org_code%NOTFOUND then
           error_status := 100;
         end if;
    if (cur_inv_get_org_code%NOTFOUND) or row_to_fetch = 1 THEN
      CLOSE cur_inv_get_org_code;
      end if;

      exception

          when others then
            error_status := SQLCODE;

  END;  /* End of procedure proc_inv_get_org_id */

END GMF_MTL_GET_ORG_ID;  -- END GMF_MTL_GET_ORG_ID

/
