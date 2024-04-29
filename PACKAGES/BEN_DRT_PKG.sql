--------------------------------------------------------
--  DDL for Package BEN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: bedrtapi.pkh 120.0.12010000.1 2018/03/27 12:29:36 arakudit noship $ */
--
/*
+========================================================================+
|             Copyright (c) 1997,2018 Oracle Corporation                 |
|                Redwood Shores, California, USA                         |
|                      All rights reserved.                              |
+========================================================================+
*/
/*
History
     Date             Who        Version    What?
     ----             ---        -------    -----
     27-Mar-2018      arakudit   120.0                 Initial Version
*/
-----------------------------------------------------------------------------------------


  PROCEDURE write_log
    (message IN varchar2
    ,stage   IN varchar2);

  PROCEDURE add_to_results
    (person_id   IN            number
    ,entity_type IN            varchar2
    ,status      IN            varchar2
    ,msgcode     IN            varchar2
    ,msgaplid    IN            number
    ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ben_hr_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ben_hr_pre
    (person_id IN number);

  PROCEDURE ben_hr_post
    (person_id IN number);

END ben_drt_pkg;

/
