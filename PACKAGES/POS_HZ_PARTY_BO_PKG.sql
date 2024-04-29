--------------------------------------------------------
--  DDL for Package POS_HZ_PARTY_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_PARTY_BO_PKG" AUTHID CURRENT_USER AS
 /* $Header: POSSPPAS.pls 120.0.12010000.2 2010/02/08 14:16:28 ntungare noship $ */
    PROCEDURE get_hz_party_bo(p_api_version   IN NUMBER DEFAULT NULL,
                              p_init_msg_list IN VARCHAR2 DEFAULT NULL,
                              p_party_id      IN NUMBER,
                              x_hz_party_bo   OUT NOCOPY pos_hz_party_bo,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2);

END pos_hz_party_bo_pkg;

/
