--------------------------------------------------------
--  DDL for Package HR_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BIS" AUTHID CURRENT_USER AS
/* $Header: hr_bis.pkh 120.1 2005/08/11 10:09:23 cbridge noship $ */

  FUNCTION bis_decode_lookup( p_lookup_type VARCHAR2,
                              p_lookup_code VARCHAR2)
            RETURN fnd_lookup_values.meaning%TYPE;

  FUNCTION get_sec_profile_bg_id
            RETURN   per_security_profiles.business_group_id%TYPE;
  --
  -- Enhancement 3729826
  --
  FUNCTION get_legislation_code RETURN VARCHAR2;
  --

  FUNCTION decode_lang_lookup(p_language VARCHAR2,
                              p_lookup_type VARCHAR2,
                              p_lookup_code VARCHAR2)
             RETURN fnd_lookup_values.meaning%TYPE;

END hr_bis;

 

/
