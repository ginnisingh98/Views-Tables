--------------------------------------------------------
--  DDL for Package POS_HZ_PARTY_SITE_BO_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_PARTY_SITE_BO_TBL_PKG" AUTHID CURRENT_USER AS
  /*$Header: POSSPPASS.pls 120.0.12010000.2 2010/02/08 14:17:00 ntungare noship $ */

    PROCEDURE get_party_site_bos(p_party_id        IN NUMBER,
                                 x_party_site_objs OUT NOCOPY pos_hz_party_site_bo_tbl,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2);

END pos_hz_party_site_bo_tbl_pkg;

/
