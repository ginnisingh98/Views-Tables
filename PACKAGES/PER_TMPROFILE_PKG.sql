--------------------------------------------------------
--  DDL for Package PER_TMPROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TMPROFILE_PKG" AUTHID CURRENT_USER as
/* $Header: pertppkg.pkh 120.0.12010000.1 2009/04/02 10:02:59 aniagarw noship $ */
  FUNCTION is_subordinate (p_subordinate_person_id    in number
                          ,p_person_id                in number
                          ,p_effective_date           in date) return varchar2;

  FUNCTION get_address (p_person_id       in number
                       ,p_effective_date  in date) return varchar2;

  pragma restrict_references (get_address, WNPS, WNDS);

  FUNCTION encode64 (p_blob in blob) return clob;

  FUNCTION get_value_for_9box(p_person_id IN NUMBER
                             ,p_effective_date IN DATE
                             ,p_type IN VARCHAR2) RETURN NUMBER;
end PER_TMPROFILE_PKG;

/
