--------------------------------------------------------
--  DDL for Package PER_FR_TERMINATION_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_TERMINATION_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: pefrtmup.pkh 115.0 2002/09/16 13:11:07 jrhodes noship $ */

function run_upgrade(p_business_group_id IN NUMBER) return number;

END PER_FR_TERMINATION_UPG_PKG;

 

/
