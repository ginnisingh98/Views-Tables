--------------------------------------------------------
--  DDL for Package Body ITG_BOAPI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_BOAPI_UTILS" AS
/* ARCS: $Header: itgvutlb.pls 120.1 2005/12/22 04:10:22 bsaratna noship $
 * CVS:  itgvutlb.pls,v 1.4 2002/11/05 04:14:11 ecoe Exp
 */
  l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

  PROCEDURE validate(
        p_name          IN VARCHAR2,
        p_min           IN NUMBER,
        p_max           IN NUMBER,
        p_nullok        IN BOOLEAN,
        p_value         IN VARCHAR2
  ) AS
        l_len           NUMBER;
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering validate VARCHAR2 ---' ,2);
        END IF;

        IF NOT p_nullok AND p_value IS NULL THEN
                IF (l_Debug_Level <= 1) THEN
                        ITG_Debug.msg('NULL check failed for field '||p_name ,1);
                END IF;

                ITG_MSG.missing_element_value(p_name, p_value);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_len := LENGTHB(p_value); /* bug  4002567*/

        IF ((p_min IS NOT NULL AND l_len < p_min) OR
            (p_max IS NOT NULL AND l_len > p_max))  THEN
                IF (l_Debug_Level <= 1) THEN
                        ITG_Debug.msg('Length check failed for field '||p_name ,1);
                END IF;

                ITG_MSG.data_value_error(p_value, p_min, p_max);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exiting validate VARCHAR2 ---' ,2);
        END IF;
  END validate;



  PROCEDURE validate(
        p_name          IN VARCHAR2,
        p_min           IN NUMBER,
        p_max           IN NUMBER,
        p_nullok        IN BOOLEAN,
        p_value         IN NUMBER
  ) AS
        l_len           NUMBER;
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Entering validate NUMBER ---' ,2);
        END IF;

        IF NOT p_nullok AND p_value IS NULL THEN
                IF (l_Debug_Level <= 1) THEN
                        ITG_Debug.msg('NULL check failed for field '||p_name ,1);
                END IF;

                ITG_MSG.missing_element_value(p_name, NULL);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF ((p_min IS NOT NULL AND p_value < p_min) OR
            (p_max IS NOT NULL AND p_value > p_max))  THEN
                IF (l_Debug_Level <= 1) THEN
                        ITG_Debug.msg('Range check failed for field '||p_name, 1);
                END IF;

                ITG_MSG.data_value_error(to_char(p_value), p_min, p_max);
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('--- Exiting validate NUMBER ---' ,2);
        END IF;

  END validate;

END ITG_BOAPI_Utils;

/
