--------------------------------------------------------
--  DDL for Package WF_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: wfdrtps.pls 120.0.12010000.1 2018/04/03 18:47:05 skandepu noship $ */

  -- wf_hr_drc
  --   Implement Core HR specific DRC for HR entity type
  -- IN:
  --   person_id - HR person id
  -- OUT:
  --   result_tbl - DRC record structure
  --
 PROCEDURE wf_hr_drc(person_id       IN         number,
                     result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);

  -- wf_tca_drc
  --   Implement Core HR specific DRC for TCA entity type
  -- IN:
  --   person_id - TCA person id
  -- OUT:
  --   result_tbl - DRC record structure
  --
  PROCEDURE wf_tca_drc(person_id     IN         number,
                       result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  -- wf_fnd_drc
  --   Implement Core HR specific DRC for FND entity type
  -- IN:
  --   person_id - FND user id
  -- OUT:
  --   result_tbl - DRC record structure
  --
  PROCEDURE wf_fnd_drc(person_id     IN         number,
                       result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

END wf_drt_pkg;

/
