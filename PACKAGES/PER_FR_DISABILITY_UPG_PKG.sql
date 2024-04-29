--------------------------------------------------------
--  DDL for Package PER_FR_DISABILITY_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_DISABILITY_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: pefrdiup.pkh 115.0 2002/04/05 10:22:48 pkm ship      $ */

function run_upgrade(p_business_group_id IN NUMBER) return number;

END PER_FR_DISABILITY_UPG_PKG;

 

/
