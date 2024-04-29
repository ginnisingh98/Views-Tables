--------------------------------------------------------
--  DDL for Package PAY_ES_NIE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_NIE_UPDATE" AUTHID CURRENT_USER AS
/* $Header: peesnieu.pkh 120.0.12010000.1 2008/10/14 04:34:00 parusia noship $ */
--
PROCEDURE qualify_nie_update(
        p_person_id number
      , p_qualifier	out nocopy varchar2)
  ;

PROCEDURE update_NIE(
       p_person_id number
       );
END pay_es_nie_update ;

/
