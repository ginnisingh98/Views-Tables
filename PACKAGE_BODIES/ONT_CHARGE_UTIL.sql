--------------------------------------------------------
--  DDL for Package Body ONT_CHARGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_CHARGE_UTIL" AS
/* $Header: ONTUCHRB.pls 120.0 2005/06/01 00:37:30 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_CHARGE_UTIL';

/* function to return the meaning from qp_charge_lookup when lookup type i
   passed to this function */

Function Get_Meaning
  (   p_charge_type_code in VARCHAR2
 ,    p_charge_subtype_code in VARCHAR2 := NULL
  ) RETURN VARCHAR2
 IS
 l_meaning               VARCHAR2(80) := NULL;
 l_charge_type_code      VARCHAR2(30);
 l_charge_subtype_code   VARCHAR2(30);
 BEGIN
    -- Check whether p_charge_type_code is null

    -- bug 2816272, need to convert miss char to NULL.
    l_charge_type_code := p_charge_type_code;
    l_charge_subtype_code := p_charge_subtype_code;

    IF p_charge_type_code = FND_API.G_MISS_CHAR THEN
       l_charge_type_code := NULL;
    END IF;

    IF p_charge_subtype_code = FND_API.G_MISS_CHAR THEN
       l_charge_subtype_code := NULL;
    END IF;


    IF l_charge_type_code is NULL THEN

        l_meaning := NULL;

    ELSE /* l_charge_type_code is not null */

      IF l_charge_subtype_code is NULL THEN

        BEGIN

         select meaning into l_meaning
         from wsh_lookups
         where lookup_code = l_charge_type_code
         and lookup_type = 'FREIGHT_COST_TYPE';

        EXCEPTION

          WHEN NO_DATA_FOUND THEN

            select meaning into l_meaning
            from qp_lookups
            where lookup_code = l_charge_type_code
            and lookup_type = 'FREIGHT_CHARGES_TYPE';

        END;

      ELSE /* l_charge_subtype_code is not null */

         select meaning into l_meaning
         from qp_lookups
         where lookup_type = l_charge_type_code
         and lookup_code = l_charge_subtype_code;

      END IF; /* if l_charge_subtype_code is null */

    END IF;  /* if l_charge_type_code is null */

    Return l_meaning;

 EXCEPTION

    WHEN NO_DATA_FOUND THEN

         l_meaning := NULL;
         RETURN l_meaning;

    WHEN OTHERS THEN

         l_meaning := NULL;
         RETURN l_meaning;

 END Get_Meaning;

END ONT_CHARGE_UTIL;

/
