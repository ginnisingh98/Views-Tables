--------------------------------------------------------
--  DDL for Package Body PER_JBD_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JBD_FLEX" as
/* $Header: pejbdfli.pkb 115.1 99/07/18 13:54:40 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= ' per_jbd_flex.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< kf >-------------------------------------|
-- ----------------------------------------------------------------------------
-- Validation for Job Key flexfield
procedure kf
  (p_rec   in  per_jbd_shd.g_rec_type
  ) is
--
  l_proc             varchar2(72) := g_package||'kf';
--
begin
  --
  null;
  --
end kf;
--
end per_jbd_flex;

/
