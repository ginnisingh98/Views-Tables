--------------------------------------------------------
--  DDL for Package PER_ZA_ABS_DURATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_ABS_DURATION" AUTHID CURRENT_USER as
/* $Header: perzaabd.pkh 120.4 2008/01/30 15:10:04 rpahune noship $ */
  function za_daysoff   (p_DateFrom IN DATE,
                         p_DateTo   IN DATE)
  return number;
-- Function returns no of public holidays/weekend days between
-- parameters

  function get_canonical_Dt_format
  return varchar2;

  function za_canonical_Dt_format (p_date varchar2)
  return varchar2;

end per_za_abs_duration;

/
