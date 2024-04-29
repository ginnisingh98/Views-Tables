--------------------------------------------------------
--  DDL for Package SERIAL_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SERIAL_CHECK" AUTHID CURRENT_USER AS
/* $Header: INVMKUMS.pls 120.2 2005/06/17 15:16:35 appldev  $ */

PROCEDURE inv_mark_serial
  ( from_serial_number  IN      VARCHAR2,
    to_serial_number    IN      VARCHAR2 DEFAULT NULL,
    item_id             IN      NUMBER,
    org_id              IN      NUMBER,
    hdr_id              IN      NUMBER,
    temp_id             IN      NUMBER,
    lot_temp_id         IN      NUMBER,
    success             IN OUT  NOCOPY  NUMBER);

/*** {{ R12 Enhanced reservations code changes ***/
-- overloaded procedure
PROCEDURE inv_mark_rsv_serial
  ( from_serial_number	IN      VARCHAR2,
    to_serial_number	IN      VARCHAR2 DEFAULT NULL,
    item_id		IN      NUMBER,
    org_id		IN      NUMBER,
    hdr_id		IN      NUMBER,
    temp_id		IN      NUMBER,
    lot_temp_id		IN      NUMBER,
    p_reservation_id    IN      NUMBER DEFAULT NULL,
    p_update_reservation IN     VARCHAR2 DEFAULT fnd_api.g_true,
    success		IN OUT  NOCOPY NUMBER);
/*** End R12 }} ***/

PROCEDURE inv_unmark_serial
  ( from_serial_number   IN  VARCHAR2,
    to_serial_number     IN  VARCHAR2,
    serial_code          IN  NUMBER,
    hdr_id               IN  NUMBER,
    temp_id              IN  NUMBER DEFAULT NULL,
    lot_temp_id          IN  NUMBER DEFAULT NULL,
    p_inventory_item_id  IN  NUMBER DEFAULT NULL);

/*** {{ R12 Enhanced reservations code changes ***/
-- overloaded procedure
PROCEDURE inv_unmark_rsv_serial
  ( from_serial_number	 IN  VARCHAR2,
    to_serial_number	 IN  VARCHAR2,
    serial_code		 IN  NUMBER,
    hdr_id		 IN  NUMBER,
    temp_id		 IN  NUMBER DEFAULT NULL,
    lot_temp_id		 IN  NUMBER DEFAULT NULL,
    p_inventory_item_id  IN  NUMBER DEFAULT NULL,
    p_update_reservation IN  VARCHAR2 DEFAULT fnd_api.g_true);
/*** End R12 }} ***/

PROCEDURE inv_update_marked_serial
  ( from_serial_number IN         VARCHAR2,
    to_serial_number   IN         VARCHAR2 DEFAULT NULL,
    item_id            IN         NUMBER,
    org_id             IN         NUMBER,
    temp_id            IN         NUMBER DEFAULT NULL,
    hdr_id             IN         NUMBER DEFAULT NULL,
    lot_temp_id        IN         NUMBER DEFAULT NULL,
    success            OUT NOCOPY BOOLEAN );

END SERIAL_CHECK;

 

/
