--------------------------------------------------------
--  DDL for Function IEC_GETPREDICTEDEXHAUSTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."IEC_GETPREDICTEDEXHAUSTION" 
                                          ( p_rec_remain              IN NUMBER
                                          , p_rec_called_removed      IN NUMBER
                                          , p_start_time              IN DATE
                                          , p_sysdate                 IN DATE)
                  RETURN DATE
               IS
                  l_pred_exhaust DATE;
               BEGIN
                  BEGIN
                     IF p_start_time IS NOT NULL AND ((p_sysdate - p_start_time) > (8/24)) THEN

                        l_pred_exhaust := p_sysdate + (p_rec_remain * (1 / (p_rec_called_removed / Iec_CleanDivisor(p_sysdate - p_start_time))));

                     ELSE
                        -- not enough data to compute predicted exhaustion
                        l_pred_exhaust := NULL;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        l_pred_exhaust := NULL;
                  END;
                  RETURN l_pred_exhaust;
               END;
 

/
