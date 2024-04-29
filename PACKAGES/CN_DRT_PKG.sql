--------------------------------------------------------
--  DDL for Package CN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DRT_PKG" AUTHID CURRENT_USER AS
  -- $Header: cndrtapis.pls 120.0.12010000.2 2018/04/03 07:56:29 rnagaraj noship $


  --
  --- Implement common process for all person type
  --

  PROCEDURE process_drc (
                p_person_id   IN NUMBER,
                p_entity_type IN VARCHAR2,
                p_salesrep_id IN NUMBER,
                p_org_id      IN NUMBER,
                result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
            );

  --
  --- Implement TCA Core specific DRC for Entity Type TCA
  --
 PROCEDURE cn_tca_drc (
                person_id     IN  NUMBER,
                result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE cn_hr_drc (
               person_id   IN  NUMBER,
               result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);


  --
  --- Implement FND Core specific DRC for Entity Type FND
  --
  PROCEDURE cn_fnd_drc (
               person_id   IN  NUMBER ,
               result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);


END cn_drt_pkg;

/
