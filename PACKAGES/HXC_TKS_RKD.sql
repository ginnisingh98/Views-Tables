--------------------------------------------------------
--  DDL for Package HXC_TKS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TKS_RKD" AUTHID CURRENT_USER as
/* $Header: hxctksrhi.pkh 120.0.12010000.2 2008/08/05 12:08:58 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_submission_id                in number
  ,p_resource_id_o                in number
  );
--
end hxc_tks_rkd;

/
