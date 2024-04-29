--------------------------------------------------------
--  DDL for Package WSH_CARRIER_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CARRIER_ADDRESS_PKG" AUTHID CURRENT_USER as
/* $Header: WSHADTHS.pls 115.4 2003/08/22 10:02:31 msutar ship $ */

PROCEDURE  Create_Addressinfo (
  p_carrier_id                IN     NUMBER,
  p_status                    IN     VARCHAR2,
  p_site_number               IN OUT NOCOPY VARCHAR2,
  p_address1                  IN     VARCHAR2 DEFAULT NULL,
  p_address2                  IN     VARCHAR2 DEFAULT NULL,
  p_address3                  IN     VARCHAR2 DEFAULT NULL,
  p_address4                  IN     VARCHAR2 DEFAULT NULL,
  p_city                      IN     VARCHAR2 DEFAULT NULL,
  p_state                     IN     VARCHAR2 DEFAULT NULL,
  p_province                  IN     VARCHAR2 DEFAULT NULL,
  p_postal_code               IN     VARCHAR2 DEFAULT NULL,
  p_country                   IN     VARCHAR2 DEFAULT NULL,
  p_county                    IN     VARCHAR2 DEFAULT NULL,
  x_location_id               IN OUT NOCOPY  NUMBER,
  x_party_site_id             IN OUT NOCOPY  NUMBER,
  x_return_status                OUT NOCOPY  VARCHAR2,
  x_exception_msg                OUT NOCOPY  VARCHAR2,
  x_position                     OUT NOCOPY  NUMBER,
  x_procedure                    OUT NOCOPY  VARCHAR2,
  x_sqlerr                       OUT NOCOPY  VARCHAR2,
  x_sql_code                     OUT NOCOPY  VARCHAR2 );


PROCEDURE Update_Addressinfo (
  p_carrier_party_id IN     NUMBER,
  p_site_number      IN     VARCHAR2,
  p_status           IN     VARCHAR2,
  p_party_site_id    IN     NUMBER,
  p_location_id      IN     NUMBER,
  p_address1         IN     VARCHAR2,
  p_address2         IN     VARCHAR2,
  p_address3         IN     VARCHAR2,
  p_address4         IN     VARCHAR2,
  p_city             IN     VARCHAR2,
  p_state            IN     VARCHAR2,
  p_province         IN     VARCHAR2,
  p_postal_code      IN     VARCHAR2,
  p_country          IN     VARCHAR2,
  p_county           IN     VARCHAR2,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_exception_msg       OUT NOCOPY  VARCHAR2,
  x_position            OUT NOCOPY  NUMBER,
  x_procedure           OUT NOCOPY  VARCHAR2,
  x_sqlerr              OUT NOCOPY  VARCHAR2,
  x_sql_code            OUT NOCOPY  VARCHAR2 );


FUNCTION Concatenate_Address(
  p_address1     IN VARCHAR2,
  p_address2     IN VARCHAR2,
  p_address3     IN VARCHAR2,
  p_address4     IN VARCHAR2,
  p_city         IN VARCHAR2,
  p_postal_code  IN VARCHAR2,
  p_state        IN VARCHAR2,
  p_province     IN VARCHAR2,
  p_country      IN VARCHAR2,
  p_county       IN VARCHAR2 ) RETURN VARCHAR2;

END WSH_CARRIER_ADDRESS_PKG;

 

/
