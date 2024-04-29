--------------------------------------------------------
--  DDL for Package CSF_GPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_GPS_PUB" AUTHID CURRENT_USER AS
  /* $Header: CSFPGPSS.pls 120.0.12010000.8 2010/03/10 10:56:57 anangupt noship $ */

  FUNCTION is_gps_enabled
    RETURN VARCHAR2;

  FUNCTION get_gps_label(
      p_device_id     NUMBER     DEFAULT NULL
    , p_resource_id   NUMBER     DEFAULT NULL
    , p_resource_type VARCHAR2   DEFAULT NULL
    , p_date          DATE       DEFAULT NULL
    )
    RETURN VARCHAR2;

  PROCEDURE get_location(
      p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_date                       IN        DATE      DEFAULT NULL
    , x_feed_time                 OUT NOCOPY DATE
    , x_status_code               OUT NOCOPY VARCHAR2
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_speed                     OUT NOCOPY NUMBER
    , x_direction                 OUT NOCOPY VARCHAR2
    , x_parked_time               OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_creation_date             OUT NOCOPY DATE
    , x_device_tag                OUT NOCOPY VARCHAR2
    , x_status_code_meaning       OUT NOCOPY VARCHAR2
    );

  FUNCTION get_location (
      p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_date                       IN        DATE      DEFAULT NULL
    )
    RETURN MDSYS.SDO_POINT_TYPE;

  PROCEDURE save_location_feeds(
      p_api_version                IN        NUMBER
    , p_init_msg_list              IN        VARCHAR2
    , p_commit                     IN        VARCHAR2
    , x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , p_count                      IN        NUMBER
    , p_device_id_tbl              IN        jtf_number_table
    , p_feed_time_tbl              IN        jtf_date_table
    , p_status_tbl                 IN        jtf_varchar2_table_100
    , p_lat_tbl                    IN        jtf_number_table
    , p_lng_tbl                    IN        jtf_number_table
    , p_speed_tbl                  IN        jtf_number_table
    , p_dir_tbl                    IN        jtf_varchar2_table_100
    , p_parked_time_tbl            IN        jtf_number_table
    , p_address_tbl                IN        jtf_varchar2_table_300
    );

  PROCEDURE purge_location_feeds(
      errbuf                      OUT NOCOPY VARCHAR2
    , retcode                     OUT NOCOPY VARCHAR2
    , p_vendor_id                  IN        NUMBER    DEFAULT NULL
    , p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_device_assignment_id       IN        NUMBER    DEFAULT NULL
    , p_territory_id               IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_start_date                 IN        VARCHAR2  DEFAULT NULL
    , p_end_date                   IN        VARCHAR2  DEFAULT NULL
    , p_num_days                   IN        NUMBER    DEFAULT NULL
    );

  PROCEDURE add_language;

END csf_gps_pub;

/
