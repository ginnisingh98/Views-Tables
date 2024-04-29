--------------------------------------------------------
--  DDL for Package BEN_TEST_HARNESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TEST_HARNESS" AUTHID CURRENT_USER AS
/* $Header: bentsthn.pkh 120.0 2005/05/28 09:31:49 appldev noship $ */
--
PROCEDURE process
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_person_id         in     number   default null
  ,p_business_group_id in     number   default null
  ,p_days              in     number   default null
  ,p_baselines         in     number   default null
  ,p_submit_validate   in     varchar2 default 'Y'
  ,p_rollup_rbvs       in     varchar2 default 'Y'
  ,p_refresh_rollups   in     varchar2 default 'N'
  ,p_testcycle_type    in     varchar2 default null
  ,p_mode_cd           in     varchar2 default null
  --
  ,p_ler_id            in     number   default null
  ,p_pgm_id            in     number   default null
  ,p_process_date      in     date     default null
  );
--
procedure BFT_DispRepErrInfo
  (p_bft_id      in number
  ,p_reperr_text in boolean
  ,p_disp_rows   in number
  ,p_ext_rslt_id in number
  --
  ,p_dispout_va  in out nocopy benutils.g_varchar2_table
  );
--
END ben_test_harness;

 

/
