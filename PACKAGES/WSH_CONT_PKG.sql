--------------------------------------------------------
--  DDL for Package WSH_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONT_PKG" AUTHID CURRENT_USER as
/* $Header: WSHCONTS.pls 115.5 99/07/26 11:08:04 porting ship  $ */

  -- Name        get_master_container
  -- Purpose     get master container id and master serial number
  -- Arguments
  --             X_container_id
  --             X_master_container_id
  --             X_master_serial_number

PROCEDURE get_master_container(
   X_container_id         IN     NUMBER,
   X_master_container_id  IN OUT NUMBER,
   X_master_serial_number IN OUT VARCHAR2);


  -- Name        check_child_containers
  -- Purpose     find all child containers and update master container
  --             id and master serial number
  -- Arguments
  --             X_delivery_id
  --             X_container_id
  --             X_master_container_id
  --             X_master_serial_number
  --             X_status

PROCEDURE check_child_containers(
   X_delivery_id          IN     NUMBER,
   X_container_id         IN     NUMBER,
   X_master_container_id  IN     NUMBER,
   X_master_serial_number IN     VARCHAR2,
   X_status               IN OUT NUMBER);


  -- Name        validate_master_serial_number
  -- Purpose     Customizable API for validating master serial number.
  --             This API by default will always return true.
  --             It can be customized to perform validation according to the
  --             customer business needs.
  -- Arguments
  --             X_delivery_id
  --             X_container_sequence_number
  --             X_status

PROCEDURE validate_master_serial_number(
   X_delivery_id               IN     NUMBER,
   X_container_sequence_number IN     NUMBER,
   X_status                    IN OUT NUMBER);


  -- Name        update_master_serial_number
  -- Purpose     update master serial number
  -- Arguments
  --             X_master_serial_number
  --             X_container_id
  --             X_delivery_id
  --             X_status

PROCEDURE update_master_serial_number(
   X_master_serial_number IN     VARCHAR2,
   X_container_id         IN     NUMBER,
   X_delivery_id          IN     NUMBER,
   X_status                 IN OUT NUMBER);


PROCEDURE get_master_serial_number(
   X_sequence_number      IN     NUMBER,
   X_delivery_id          IN     NUMBER,
   X_master_serial_number IN OUT VARCHAR2);


END WSH_CONT_PKG;

 

/
