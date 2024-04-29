--------------------------------------------------------
--  DDL for Package HZ_TIMEZONE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TIMEZONE_UTILS_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHTZUTS.pls 115.1 2003/09/10 19:22:26 awu noship $ */

procedure duplicate_country_code(p_territory_code in varchar2,
 x_return_status out nocopy varchar2);

procedure duplicate_area_code(p_territory_code in varchar2, p_area_code in varchar2,
		x_return_status out nocopy varchar2);

PROCEDURE create_area_code(
  p_territory_code        IN VARCHAR2,
  p_phone_country_code    IN VARCHAR2,
  p_area_code             IN VARCHAR2,
  p_description           IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE update_area_code(
  p_territory_code        IN VARCHAR2,
  p_area_code             IN VARCHAR2,
  p_old_area_code             IN VARCHAR2,
  p_description           IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  p_object_version_number IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE update_country_timezone(
  p_territory_code        IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  p_object_version_number IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2);

function areacode_timezone_exist(p_territory_code in varchar2) return varchar2;


END HZ_TIMEZONE_UTILS_PVT;

 

/
