--------------------------------------------------------
--  DDL for Package Body AR_NUM_RAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_NUM_RAN_PKG" AS
/* $Header: ARPEXTUB.pls 120.0 2005/03/15 00:44:53 hyu noship $ */

  FUNCTION     num_random RETURN NUMBER
  IS
    CURSOR c IS
    SELECT MAX(line_id)
      FROM ar_distributions_all;
  BEGIN
    IF g_num_max = -1 THEN
      OPEN c;
      FETCH c INTO g_num_max;
      IF c%NOTFOUND THEN
        g_num_max := 0;
      END IF;
      CLOSE c;
    END IF;
    RETURN abs(dbms_random.random) + g_num_max;
  END;
END;

/
