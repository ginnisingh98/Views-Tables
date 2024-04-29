--------------------------------------------------------
--  DDL for Package PER_AU_ADD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AU_ADD_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peaulhpa.pkh 120.0 2005/05/31 05:57 appldev noship $*/
  g_package  VARCHAR2(33) := 'per_au_add_leg_hook.';


PROCEDURE check_address_ins(p_style              IN VARCHAR2
                           ,p_region_1           IN VARCHAR2
                           ,p_country            IN VARCHAR2);

PROCEDURE check_address_upd(p_address_id         IN NUMBER
                           ,p_region_1           IN VARCHAR2
                           ,p_country            IN VARCHAR2);

END per_au_add_leg_hook;

 

/
