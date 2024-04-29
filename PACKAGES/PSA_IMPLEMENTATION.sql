--------------------------------------------------------
--  DDL for Package PSA_IMPLEMENTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_IMPLEMENTATION" AUTHID CURRENT_USER AS
/* $Header: PSAMFIMS.pls 120.4 2006/09/13 13:09:14 agovil ship $ */
  --

  g_mfar_enabled varchar2(1) := NULL;
  g_org_id       number(15) := NULL;


  FUNCTION get (p_org_id        IN  INTEGER,
                p_psa_feature   IN  VARCHAR2,
                p_enabled_flag  OUT NOCOPY VARCHAR2)
  RETURN boolean;
  --
  PROCEDURE enable_mfar  (p_org_id        IN  INTEGER,
                           p_psa_feature   IN  VARCHAR2);
  --
  PROCEDURE disable_mfar  (p_org_id        IN  INTEGER,
                           p_psa_feature   IN  VARCHAR2);
END PSA_IMPLEMENTATION;

 

/
