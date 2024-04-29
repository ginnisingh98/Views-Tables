--------------------------------------------------------
--  DDL for Package PER_FR_WORK_ACC_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FR_WORK_ACC_UPG_PKG" AUTHID CURRENT_USER AS
/* $Header: pefrwaup.pkh 115.0 2002/04/17 05:02:51 pkm ship      $ */

function run_upgrade(p_business_group_id number) return number;

END PER_FR_WORK_ACC_UPG_PKG;

 

/
