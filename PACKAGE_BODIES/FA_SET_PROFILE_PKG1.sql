--------------------------------------------------------
--  DDL for Package Body FA_SET_PROFILE_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SET_PROFILE_PKG1" as
/* $Header: faxsprfb.pls 120.3.12010000.2 2009/07/19 13:03:19 glchen ship $ */

 procedure fa_sprf (prof in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
   oldprof varchar2(1);
  begin

     oldprof := fnd_profile.value('CONC_SINGLE_THREAD');
     fnd_profile.put('CONC_SINGLE_THREAD',prof);
     prof := oldprof;
  end fa_sprf;

END FA_SET_PROFILE_PKG1;

/
