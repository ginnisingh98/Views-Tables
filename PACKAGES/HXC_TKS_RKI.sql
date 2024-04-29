--------------------------------------------------------
--  DDL for Package HXC_TKS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKS_RKI" AUTHID CURRENT_USER as
/* $Header: hxctksrhi.pkh 120.0.12010000.2 2008/08/05 12:08:58 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_submission_id                in number
  ,p_resource_id                  in number
  );
end hxc_tks_rki;

/
