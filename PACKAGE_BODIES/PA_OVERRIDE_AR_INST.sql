--------------------------------------------------------
--  DDL for Package Body PA_OVERRIDE_AR_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OVERRIDE_AR_INST" AS
/* $Header: PAPARICB.pls 120.2 2005/08/16 15:39:50 hsiu noship $ */
  PROCEDURE get_installation_mode
      (  p_ar_inst_mode             IN    VARCHAR2,
         x_ar_inst_mode             OUT   NOCOPY VARCHAR2)
  IS
  BEGIN

    -- set "in" installation mode to "out" installation mode

    x_ar_inst_mode := p_ar_inst_mode;

  END get_installation_mode;

END pa_override_ar_inst;

/
