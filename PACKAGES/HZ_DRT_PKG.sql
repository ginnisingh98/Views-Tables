--------------------------------------------------------
--  DDL for Package HZ_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DRT_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHZDRTS.pls 120.0.12010000.3 2018/03/27 10:07:11 vekoppar noship $ */


 PROCEDURE tca_fnd_drc
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) ;

 PROCEDURE tca_tca_pre
    (p_party_id   IN number) ;

 PROCEDURE tca_tca_post
    (p_party_id   IN number) ;




END HZ_DRT_PKG ;

/
