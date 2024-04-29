--------------------------------------------------------
--  DDL for Package CSF_LF_GEOPVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_LF_GEOPVT" AUTHID CURRENT_USER AS
  /* $Header: CSFVGEOS.pls 120.6.12010000.4 2010/03/03 06:22:21 rajukum noship $*/

  CSF_LF_LATITUDE_NOT_SET_ERROR	EXCEPTION;
  CSF_LF_LONGITUDE_NOT_SET_ERROR	EXCEPTION;
  CSF_LF_VERSION_ERROR		EXCEPTION;

   /**
   * This API is for reverse geo coding. It converts the inputs passed as
   * latitude and longitude to its corresponding address.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_latitude              Latitude
   * @param   p_longitude             Longitude
   * @param   p_dataset               p_dataset
   * @param   p_country               Country of the address
   * @param   p_state                 State of the address
   * @param   p_county                County of the address
   * @param   p_city                  City of the address
   * @param   p_roadname              Street of the address
   * @param   p_postalcode            Postal code of the address
   * @param   p_bnum                  Building Number of the address
   * @param   p_dist                  Distance from given lat and lng
   * @param   p_accuracy_lvl          Accuracy level of address
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   x_return_status         Return Status of the Procedure.
   */
   PROCEDURE CSF_LF_ResolveGEOAddress (
    p_api_version   IN         NUMBER
  , p_init_msg_list IN VARCHAR2  default fnd_api.g_false
  , p_latitude      IN         NUMBER
  , p_longitude     IN         NUMBER
  , p_dataset       IN         VARCHAR2
  , p_country       OUT NOCOPY VARCHAR2
  , p_state         OUT NOCOPY VARCHAR2
  , p_county        OUT NOCOPY VARCHAR2
  , p_city          OUT NOCOPY VARCHAR2
  , p_roadname      OUT NOCOPY VARCHAR2
  , p_postalcode    OUT NOCOPY VARCHAR2
  , p_bnum          OUT NOCOPY VARCHAR2
  , p_dist          OUT NOCOPY VARCHAR2
  , p_accuracy_lvl  OUT NOCOPY VARCHAR2
  , x_msg_count     OUT NOCOPY NUMBER
  , x_msg_data      OUT NOCOPY VARCHAR2
  , x_return_status OUT NOCOPY VARCHAR2
  );

  PROCEDURE CSF_LF_ResolveAddress
            ( p_api_version   IN         NUMBER
            , p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
            , x_return_status OUT NOCOPY VARCHAR2
            , x_msg_count     OUT NOCOPY NUMBER
            , x_msg_data      OUT NOCOPY VARCHAR2
            , p_country       IN         VARCHAR2
            , p_state         IN         VARCHAR2 default NULL
            , p_county        IN         VARCHAR2 DEFAULT NULL
            , p_province      IN         VARCHAR2 DEFAULT NULL
            , p_city          IN         VARCHAR2
            , p_postalCode    IN         VARCHAR2 default NULL
            , p_roadname      IN         VARCHAR2
            , p_buildingnum   IN         VARCHAR2  default NULL
            , p_alternate     IN         VARCHAR2  default NULL
            , p_accu_fac      OUT NOCOPY NUMBER
            , p_segment_id    OUT NOCOPY NUMBER
            , p_offset        OUT NOCOPY NUMBER
            , p_side          OUT NOCOPY NUMBER
            , p_lon           OUT NOCOPY NUMBER
            , p_lat           OUT NOCOPY NUMBER
	    , p_srid          OUT NOCOPY NUMBER
            );


 PROCEDURE delete_valid_geo_batch_address;

 PROCEDURE move_invalid_to_geo_batch(
           p_task_rec    csf_task_address_pvt.task_rec_type
     );

 PROCEDURE resolve_address(
    p_api_version       IN        NUMBER
  , x_return_status    OUT NOCOPY VARCHAR2
  , x_msg_count        OUT NOCOPY NUMBER
  , x_msg_data         OUT NOCOPY VARCHAR2
  , p_location_id       IN        NUMBER
  , p_address1          IN        VARCHAR2
  , p_address2          IN        VARCHAR2
  , p_address3          IN        VARCHAR2
  , p_address4          IN        VARCHAR2
  , p_city              IN        VARCHAR2
  , p_postalcode        IN        VARCHAR2
  , p_county            IN        VARCHAR2
  , p_state             IN        VARCHAR2
  , p_province          IN        VARCHAR2
  , p_country           IN        VARCHAR2
  , p_accu_fac      OUT NOCOPY NUMBER
  , p_segment_id    OUT NOCOPY NUMBER
  , p_offset        OUT NOCOPY NUMBER
  , p_side          OUT NOCOPY NUMBER
  , p_lon           OUT NOCOPY NUMBER
  , p_lat           OUT NOCOPY NUMBER
  );

END CSF_LF_GEOPVT;

/
