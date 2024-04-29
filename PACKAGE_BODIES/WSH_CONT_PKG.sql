--------------------------------------------------------
--  DDL for Package Body WSH_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONT_PKG" as
/* $Header: WSHCONTB.pls 115.5 99/07/26 11:08:01 porting ship  $ */

  -- Name        get_master_container
  -- Purpose     get master container id and master serial number
  -- Arguments
  --             X_container_id
  --             X_master_container_id
  --             X_master_serial_number

PROCEDURE get_master_container(
   X_container_id         IN     NUMBER,
   X_master_container_id  IN OUT NUMBER,
   X_master_serial_number IN OUT VARCHAR2)
IS
   CURSOR get_master_container(
      P_container_id NUMBER)
   IS
      SELECT           container_id, master_serial_number
      FROM             wsh_packed_containers
      WHERE            parent_container_id IS NULL
      START WITH       container_id        = P_container_id
      CONNECT BY PRIOR parent_container_id = container_id;

BEGIN
   OPEN get_master_container(X_container_id);
   FETCH get_master_container INTO X_master_container_id, X_master_serial_number;
   IF (get_master_container%ISOPEN) THEN
     CLOSE get_master_container;
   END IF;
END get_master_container;


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
   X_status               IN OUT NUMBER)
IS
   CURSOR get_child_cont(
      P_container_id NUMBER)
   IS
      SELECT           container_id
      FROM             wsh_packed_containers
      START WITH       parent_container_id = P_container_id
      CONNECT BY PRIOR container_id        = parent_container_id;

   L_container_id NUMBER;

BEGIN
   X_status := 0;

   OPEN get_child_cont(X_container_id);
   LOOP
      FETCH get_child_cont INTO L_container_id;
      EXIT WHEN get_child_cont%NOTFOUND;

      UPDATE wsh_packed_containers
         SET master_container_id  = X_master_container_id,
             master_serial_number = X_master_serial_number
         WHERE container_id = L_container_id
         AND   delivery_id  = X_delivery_id;

      IF (SQL%ROWCOUNT > 0) THEN
         X_status := 1;
      END IF;
   END LOOP;

   IF (get_child_cont%ISOPEN) THEN
      CLOSE get_child_cont;
   END IF;
END check_child_containers;


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
   X_status                    IN OUT NUMBER)
IS
BEGIN
   null;
END validate_master_serial_number;


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
   X_status               IN OUT NUMBER)
IS
  CURSOR get_child_cont(
     P_container_id NUMBER)
  IS
     SELECT           container_id
     FROM             wsh_packed_containers
     START WITH       parent_container_id = P_container_id
     CONNECT BY PRIOR container_id        = parent_container_id;

   L_container_id NUMBER;
BEGIN
   X_status := 0;
   OPEN get_child_cont(X_container_id);
   LOOP
      FETCH get_child_cont INTO L_container_id;
      EXIT WHEN get_child_cont%NOTFOUND;

      UPDATE wsh_packed_containers
         SET master_serial_number = X_master_serial_number
         WHERE container_id = L_container_id
         AND   delivery_id  = X_delivery_id;

      IF (SQL%ROWCOUNT > 0) THEN
         X_status := 1;
      END IF;
   END LOOP;

   IF (get_child_cont%ISOPEN) THEN
      CLOSE get_child_cont;
   END IF;
END update_master_serial_number;


PROCEDURE get_master_serial_number(
   X_sequence_number      IN     NUMBER,
   X_delivery_id          IN     NUMBER,
   X_master_serial_number IN OUT VARCHAR2)
IS
   CURSOR c1(
      P_sequence_number NUMBER,
      P_delivery_id     NUMBER)
   IS
      SELECT master_serial_number
      FROM wsh_packed_containers
      WHERE parent_sequence_number IS NULL
      START WITH sequence_number = p_sequence_number
      AND delivery_id = p_delivery_id
      CONNECT BY PRIOR parent_sequence_number = sequence_number
      AND delivery_id = p_delivery_id;

BEGIN
   OPEN c1(X_sequence_number, X_delivery_id);
   FETCH c1 INTO X_master_serial_number;
   CLOSE c1;
END get_master_serial_number;


END WSH_CONT_PKG;

/
