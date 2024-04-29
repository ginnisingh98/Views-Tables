--------------------------------------------------------
--  DDL for Package Body POS_USER_REG_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_USER_REG_HELPER_PKG" AS
/* $Header: POSUSRHB.pls 120.0.12010000.2 2013/03/04 15:19:35 svalampa noship $ */

PROCEDURE gen_reg_key
  (p_registration_id  IN NUMBER,
   x_registration_key OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_error            OUT NOCOPY VARCHAR2
   )
  IS
   l_count   NUMBER;
   l_random  VARCHAR2(1000);
   l_max_run INTEGER;

   CURSOR l_cur (p_reg_key IN VARCHAR2) IS
      SELECT registration_id
	FROM fnd_registrations
	WHERE registration_key = p_reg_key;

   l_id               NUMBER;
   l_registration_key fnd_registrations.registration_key%TYPE;

BEGIN

   -- This procedure uses wf_core to generate the registration key.
   -- This approach is different from the code in java/schema/FndRegistrationEOImpl.java.
   -- We can not use that approach as this is in PLSQL.

   -- loop 20 times to generate registration key
   l_count := 0;
   l_max_run := 20;

   WHILE TRUE LOOP
      l_count := l_count + 1;
      IF l_count > l_max_run THEN
	 -- it is unlikely we can not find a unique reg key after several tries, but raise exception if it happens
	 x_return_status := 'E';
	 x_error := 'Can not generate a unique registration key';
      END IF;

      l_random := wf_core.random;

      -- the registration key is varchar2(100) in fnd_registrations table

      l_registration_key := Substr(Substr(l_random,1,4) || To_char(Sysdate,'MMDDYYYYMISS') ||
				   To_char(p_registration_id) || wf_core.random,1,100);

      -- check if the registration key already exists, and if not, we got a good key
      OPEN l_cur(l_registration_key);
      FETCH l_cur INTO l_id;
      IF l_cur%found THEN
	 CLOSE l_cur;
       ELSE
	 CLOSE l_cur;
	 EXIT;
      END IF;
   END LOOP;

   -- dbms_output.put_line('get ' || l_registration_key || ' for id ' || l_registration_id);

   x_registration_key := l_registration_key;
   x_return_status := 'S';

END gen_reg_key;

PROCEDURE invite_supplier_user
  (p_vendor_id       IN  NUMBER,
   p_email_address   IN  VARCHAR2,
   p_isp_flag        IN  VARCHAR2 DEFAULT 'Y',
   p_sourcing_flag   IN  VARCHAR2 DEFAULT 'N',
   p_cp_flag         IN  VARCHAR2 DEFAULT 'N',
   p_note            IN  VARCHAR2 DEFAULT NULL,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_error           OUT NOCOPY VARCHAR2,
   x_registration_id OUT NOCOPY NUMBER
   )
  IS

   l_reg_type       	 VARCHAR2(10);
   l_app_id         	 NUMBER;

   l_registration_id     NUMBER;
   l_registration_key    fnd_registrations.registration_key%TYPE;
   l_supplier_name       po_vendors.vendor_name%TYPE;
   l_return_status       VARCHAR2(100);

BEGIN

   SAVEPOINT pos_user_reg_helper_sp1;

   BEGIN
      SELECT vendor_name INTO l_supplier_name FROM po_vendors WHERE vendor_id = p_vendor_id;
   EXCEPTION
      WHEN no_data_found THEN
	 dbms_output.put_line('Error: can not find record in po_vendors for vendor id ' || p_vendor_id);
	 RETURN;
   END;

   l_reg_type 	   := 'POS_REG';
   l_app_id   	   := 177;

   -- Bug 16390037
   -- Add p_language_code parameter to the below call

   l_registration_id := fnd_registration_pkg.insert_fnd_reg
     (
      p_application_id           => l_app_id,
      p_party_id                 => NULL,
      p_registration_type        => l_reg_type,
      p_requested_user_name      => NULL,
      p_assigned_user_name       => NULL,
      p_registration_status      => 'INVITED',
      p_exists_in_fnd_user_flag  => 'N',
      p_email                    => p_email_address,
      p_language_code            => USERENV('LANG')
      );

   gen_reg_key (p_registration_id  => l_registration_id,
		x_registration_key => l_registration_key,
		x_return_status    => l_return_status,
		x_error            => x_error
		);

   IF l_return_status IS NULL OR l_return_status <> 'S' THEN
      x_return_status := 'E';
      x_error := 'Unable to generate registration key';
      ROLLBACK TO pos_user_reg_helper_sp1;
      RETURN;
   END IF;

   UPDATE fnd_registrations SET registration_key = l_registration_key WHERE registration_id = l_registration_id;

   -- create details rows similar to the invite supplier user UI
   -- Note: some rows are created with null values as in the UI
   -- Dont think it matters but just to be consistent

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Supplier Name',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => l_supplier_name,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   -- Bug 16390037
   -- pass p_vendor_id as parameter
   -- fprward porting the fix of 9846239

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Supplier Number',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => NULL,
      p_field_value_number => p_vendor_id,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Sourcing',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => p_sourcing_flag,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'ISP',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => p_isp_flag,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'CollaborativePlanning',
      p_field_type         => NULL,
      p_field_format       => 'Y|N',
      p_field_value_string => p_cp_flag,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Job Title',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => NULL,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Note',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => p_note,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'User Access',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => NULL,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Restrict Access',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => NULL,
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Approver ID',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => NULL,
      p_field_value_number => fnd_global.user_id,
      p_field_value_date   => NULL
      );

   fnd_registration_pkg.insert_fnd_reg_details
     (
      p_registration_id    => l_registration_id,
      p_application_id     => l_app_id,
      p_registration_type  => l_reg_type,
      p_field_name         => 'Invited Flag',
      p_field_type         => NULL,
      p_field_format       => NULL,
      p_field_value_string => 'Y',
      p_field_value_number => NULL,
      p_field_value_date   => NULL
      );

   dbms_output.put_line('reg id ' || l_registration_id);

   l_return_status := fnd_registration_utils_pkg.publish_invitation_event(l_registration_id);

   IF l_return_status IS NOT NULL AND l_return_status = 'Y' THEN
      x_return_status := 'S';
      x_error := NULL;
      x_registration_id := l_registration_id;
    ELSE
      ROLLBACK TO pos_user_reg_helper_sp1;
      x_return_status := 'E';
      x_error := 'Unable to publish invitation event';
   END IF;

   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO pos_user_reg_helper_sp1;
      RAISE;
END;

END pos_user_reg_helper_pkg;

/
