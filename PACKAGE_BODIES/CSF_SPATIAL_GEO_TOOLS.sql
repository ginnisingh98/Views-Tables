--------------------------------------------------------
--  DDL for Package Body CSF_SPATIAL_GEO_TOOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SPATIAL_GEO_TOOLS" AS
  /* $Header: CSFPGEOWB.pls 120.0.12010000.3 2010/03/02 06:57:01 rajukum noship $*/

-- Start of Comments
-- API Name	: CSF_LF_ReverseGeoCoding
-- Type 	: Public
-- Pre-req	:
-- Function	: Returns address after doing reverse geo coding
-- Parameters	:
-- IN
--		p_api_version IN NUMBER required :=
--		p_init_msg_list IN VARCHAR2  = NULL optional :=
--		p_latitude IN NUMBER required :=
--		p_longitude IN NUMBER required :=
--		p_country OUT VARCHAR2 :=
--		p_state OUT VARCHAR2 :=
--		p_county OUT VARCHAR2 :=
--		p_city OUT VARCHAR2 :=
--		p_roadname OUT VARCHAR2 :=
--		p_postalcode OUT VARCHAR2 :=
--		p_bnum OUT VARCHAR2 :=
--		p_dist OUT VARCHAR2 :=
--		p_accuracy_lvl OUT VARCHAR2 :=
--		x_msg_count OUT NUMBER :=
--		x_msg_data OUT VARCHAR2 :=
--		x_return_status OUT VARCHAR2 :=
-- Version:
-- End Comments
PROCEDURE CSF_LF_ReverseGeoCoding
(  p_api_version   IN         NUMBER
 , p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
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
)

IS
  l_api_name    CONSTANT VARCHAR2(30) := 'CSF_LF_ReverseGeoCoding';
  l_api_version CONSTANT NUMBER       := 1.0;

BEGIN

  if ( l_api_version <> p_api_version ) then
    raise csf_lf_version_error;
  end if;

  if ( p_init_msg_list = 'TRUE' ) then
    x_msg_count := 0; /* FND_MSG_PUB.initialize; */
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- Validate parameters
  --

  if ( p_latitude = NULL or p_latitude = '' ) then
    raise CSF_LF_LATITUDE_NOT_SET_ERROR;
  end if;

  if ( p_longitude = NULL or p_longitude = '' ) then
    raise CSF_LF_LONGITUDE_NOT_SET_ERROR;
  end if;

  --Initialize message count and mssage data.
  x_msg_count := 0;
  x_msg_data := 'Success';

 csf_lf_geopvt.CSF_LF_ResolveGEOAddress(
                     p_api_version     => l_api_version
                     , p_latitude      => p_latitude
                     , p_longitude     => p_longitude
                     , p_dataset       => p_dataset
                     , p_country       => p_country
                     , p_state         => p_state
                     , p_county        => p_county
                     , p_city          => p_city
                     , p_roadname      => p_roadname
                     , p_postalCode    => p_postalcode
                     , p_bnum          => p_bnum
                     , p_dist          => p_dist
                     , p_accuracy_lvl  => p_accuracy_lvl
                     , x_msg_count     => x_msg_count
                     , x_msg_data      => x_msg_data
                     , x_return_status  => x_return_status);

EXCEPTION
  when CSF_LF_VERSION_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := 'Incompatibale version';
  when others then
    x_return_status := FND_API.G_RET_STS_ERROR;

END CSF_LF_ReverseGeoCoding;

END CSF_SPATIAL_GEO_TOOLS ;

/
