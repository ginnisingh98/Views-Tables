--------------------------------------------------------
--  DDL for Package Body POR_AUTOSOURCE_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_AUTOSOURCE_CUSTOM_PKG" AS
    /* $Header: PORSRCCB.pls 115.7 2003/02/21 22:39:56 jjessup ship $ */


    FUNCTION  autosource(p_item_id                    IN                NUMBER,
                         p_category_id                IN                NUMBER,
                         p_dest_organization_id       IN                NUMBER,
                         p_dest_subinventory          IN                VARCHAR2,
                         p_vendor_id                  IN                NUMBER,
                         p_vendor_site_id             IN                NUMBER,
                         p_not_purchasable_override   IN                VARCHAR2,
                         p_unit_of_issue              IN OUT  NOCOPY    VARCHAR2,
                         p_source_organization_id     OUT     NOCOPY    NUMBER,
                         p_source_subinventory        OUT     NOCOPY    VARCHAR2,
                         p_sourcing_type              OUT     NOCOPY    VARCHAR2,
                         p_cost_price                 OUT     NOCOPY    NUMBER,
                         p_error_message              OUT     NOCOPY    VARCHAR2
    ) RETURN BOOLEAN

    IS

      --if customized, need to change to TRUE
      l_is_customized_flag VARCHAR2(1) := 'N';

    BEGIN

      if l_is_customized_flag = 'N' then
         return FALSE;
      end if;

      -- Enter custom PL/SQL here

      RETURN TRUE;

    EXCEPTION
       WHEN OTHERS THEN
          RETURN FALSE;

    END autosource;


END POR_AUTOSOURCE_CUSTOM_PKG;

/
