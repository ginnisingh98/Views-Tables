--------------------------------------------------------
--  DDL for Package POS_HZ_LOCATION_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_LOCATION_BO_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSPLOCS.pls 120.0.12010000.2 2010/02/08 14:15:55 ntungare noship $ */
    PROCEDURE get_hz_location_bo(p_api_version    IN NUMBER DEFAULT NULL,
                                 p_init_msg_list  IN VARCHAR2 DEFAULT NULL,
                                 p_party_id       IN NUMBER,
                                 p_orig_system           IN VARCHAR2,
                                 p_orig_system_reference IN VARCHAR2,
                                 x_hz_location_bo OUT NOCOPY pos_hz_location_bo_tbl,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2);
    PROCEDURE create_hz_location_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                    p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
                                    p_orig_system           IN VARCHAR2,
                                    p_orig_system_reference IN VARCHAR2,
                                    p_hz_location_bo        IN pos_hz_location_bo,
                                    p_create_update_flag    IN VARCHAR2,
                                    x_location_id           OUT NOCOPY NUMBER,
                                    x_object_version_number OUT NOCOPY NUMBER,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2);

END pos_hz_location_bo_pkg;

/
