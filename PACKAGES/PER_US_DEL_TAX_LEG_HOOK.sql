--------------------------------------------------------
--  DDL for Package PER_US_DEL_TAX_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_DEL_TAX_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyusdel.pkh 120.0.12010000.3 2009/04/23 06:29:49 pannapur noship $ */

PROCEDURE DELETE_US_TAX_INFO
         (P_PERSON_ID in NUMBER
         ,P_EFFECTIVE_DATE in DATE);


END PER_US_DEL_TAX_LEG_HOOK;

/
