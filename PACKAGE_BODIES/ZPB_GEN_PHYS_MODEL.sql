--------------------------------------------------------
--  DDL for Package Body ZPB_GEN_PHYS_MODEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_GEN_PHYS_MODEL" AS
/* $Header: zpbgenphysmodel.plb 120.0.12010.2 2005/12/23 08:09:39 appldev noship $ */

PROCEDURE GEN_PHYSICAL_MODEL(Instance_ID IN NUMBER) IS

BEGIN

  ZPB_AW.EXECUTE('call CM.GENPHYSMODEL(''' || TO_CHAR(Instance_ID, '99999999999') || ''')');
  commit;

END;

END ZPB_GEN_PHYS_MODEL;

/
