--------------------------------------------------------
--  DDL for Function IEC_CLEANDIVISOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."IEC_CLEANDIVISOR" (p_divisor IN NUMBER)
                  RETURN NUMBER
               IS
                  l_clean_divisor     NUMBER;
               BEGIN
                  -- If divisor is 0, then return null
                  IF p_divisor <> 0 THEN
                     l_clean_divisor := p_divisor;
                  END IF;
                  RETURN l_clean_divisor;
               END;
 

/
