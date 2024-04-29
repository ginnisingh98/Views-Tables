--------------------------------------------------------
--  DDL for Package Body BEN_PIL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_CACHE" as
/* $Header: benpilch.pkb 115.2 2003/02/12 12:07:38 rpgupta noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      17-Aug-01	mhoyes     Created.
  115.1      26-Nov-01	mhoyes     - dbdrv lines.
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_pil_cache.';
--
-- 0 - Always refresh
-- 1 - Initialise cache
-- 2 - Cache hit
--
g_pil_cached     pls_integer := 0;
--
g_pil_current    g_pil_inst_row;
--
procedure PIL_GetPILDets
  (p_per_in_ler_id in     number
  ,p_inst_row      in out NOCOPY g_pil_inst_row
  )
is
  --
  cursor c_instance
    (c_pil_id number
    )
  is
    select pil.per_in_ler_id,
           pil.ntfn_dt
    from  ben_per_in_ler pil
    where pil.per_in_ler_id = c_pil_id;
  --
  l_reset g_pil_inst_row;
  --
begin
  --
  -- Check for already cached or a change in current PIL ID
  --
  if nvl(g_pil_current.per_in_ler_id,-9999) <> p_per_in_ler_id
    or g_pil_cached < 2
  then
    --
    open c_instance
      (c_pil_id => p_per_in_ler_id
      );
    fetch c_instance into g_pil_current;
    if c_instance%notfound then
      --
      g_pil_current := l_reset;
      --
    end if;
    close c_instance;
    --
    if g_pil_cached = 1
    then
      --
      g_pil_cached := 2;
      --
    end if;
    --
  end if;
  --
  p_inst_row := g_pil_current;
  --
end PIL_GetPILDets;
--
procedure clear_down_cache
is

  l_reset g_pil_inst_row;

begin
  --
  g_pil_current := l_reset;
  g_pil_cached  := 1;
  --
end clear_down_cache;
--
end ben_pil_cache;

/
