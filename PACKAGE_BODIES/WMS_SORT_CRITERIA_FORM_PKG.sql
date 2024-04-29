--------------------------------------------------------
--  DDL for Package Body WMS_SORT_CRITERIA_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SORT_CRITERIA_FORM_PKG" AS
/* $Header: WMSFPCRB.pls 120.1 2005/06/20 05:37:14 appldev ship $ */

g_pkg_name constant varchar2(30) := 'WMSSort_Criteria_Form_PKG';

-- private function
-- return true if no existing sort_criteria has the same id as the input
FUNCTION check_existence
  (
    p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ) RETURN BOOLEAN IS
      CURSOR c IS SELECT rule_id FROM wms_sort_criteria
	WHERE rule_id = p_rule_id
	AND sequence_number = p_sequence_number;
      l_rule_id NUMBER;
      l_exist   BOOLEAN;
BEGIN
   OPEN c;
   FETCH c INTO l_rule_id;
   l_exist := NOT(c%notfound);
   CLOSE c;
   RETURN l_exist;
END check_existence;

-- private validation routine
PROCEDURE validate_input
  (
    x_return_status                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_action                         IN  VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_order_code                     IN  NUMBER
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
  ) IS
     l_return_status 	   VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_found               BOOLEAN;
     l_msg_count           NUMBER ;
     l_msg_data            VARCHAR2(240);
BEGIN

   IF p_action NOT IN ('INSERT', 'UPDATE', 'LOCK', 'DELETE') THEN
      -- unknown exception
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   /* check existence */
   IF check_existence(p_rule_id, p_sequence_number) THEN
      IF p_action = 'INSERT' THEN
	 fnd_message.set_name('WMS', 'WMS_SORT_CRITERIA_EXISTS');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      IF p_action IN ('DELETE','LOCK','UPDATE') THEN
	 fnd_message.set_name('WMS', 'WMS_SORT_CRITERIA_NOT_FOUND');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   /* more input validation update and insert */
   IF p_action IN ('UPDATE', 'INSERT') THEN
      /* check foreign keys */
      wms_rule_form_pkg.find_rule
	(
 	  p_api_version      => 1.0
	 ,p_init_msg_list    => fnd_api.g_false
	 ,x_return_status    => l_return_status
	 ,x_msg_count        => l_msg_count
	 ,x_msg_data         => l_msg_data
	 ,p_rule_id          => p_rule_id
	 ,x_found            => l_found
	 );

      if x_return_status = fnd_api.g_ret_sts_unexp_error then
	 raise fnd_api.g_exc_unexpected_error;
       elsif x_return_status = fnd_api.g_ret_sts_error then
	 raise fnd_api.g_exc_error;
      end if;

      IF l_found = FALSE THEN
	 fnd_message.set_name('WMS', 'WMS_RULE_NOT_FOUND');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      -- other input parameters are not validated currently
      /* like parameter id */
    END IF;

    x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END validate_input;

procedure insert_sort_criteria
  (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_order_code                    IN  NUMBER
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
   ) IS
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Insert_Sort_criteria';
     l_return_status 	   VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_row_id        	   VARCHAR2(20);
     l_date          	   DATE;
     l_user_id       	   NUMBER;
     l_login_id      	   NUMBER;
     l_found         	   BOOLEAN;
begin

  -- Standard call to check for call compatibility
  if not fnd_api.compatible_api_call( l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,g_pkg_name ) then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE
  if fnd_api.to_boolean( p_init_msg_list ) then
    fnd_msg_pub.initialize;
  end if;

  /* add validation here */
  /* get who column information */
  SELECT Sysdate INTO l_date FROM dual;
  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  validate_input
    (
      x_return_status                => x_return_status
     ,p_action                       => 'INSERT'
     ,p_rule_id                      => p_rule_id
     ,p_sequence_number              => p_sequence_number
     ,p_parameter_id                 => p_parameter_id
     ,p_order_code                   => p_order_code
     ,p_attribute_category           => p_attribute_category
     ,p_attribute1                   => p_attribute1
     ,p_attribute2                   => p_attribute2
     ,p_attribute3                   => p_attribute3
     ,p_attribute4                   => p_attribute4
     ,p_attribute5                   => p_attribute5
     ,p_attribute6                   => p_attribute6
     ,p_attribute7                   => p_attribute7
     ,p_attribute8                   => p_attribute8
     ,p_attribute9                   => p_attribute9
     ,p_attribute10                  => p_attribute10
     ,p_attribute11                  => p_attribute11
     ,p_attribute12                  => p_attribute12
     ,p_attribute13                  => p_attribute13
     ,p_attribute14                  => p_attribute14
     ,p_attribute15                  => p_attribute15
    );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   /* call the table handler to do the insert */
   wms_sort_criteria_pkg.insert_row
    (
      x_rowid                        => p_rowid
     ,x_rule_id                      => p_rule_id
     ,x_sequence_number              => p_sequence_number
     ,x_last_updated_by              => l_user_id
     ,x_last_update_date             => l_date
     ,x_created_by                   => l_user_id
     ,x_creation_date                => l_date
     ,x_last_update_login            => l_login_id
     ,x_parameter_id                 => p_parameter_id
     ,x_order_code                   => p_order_code
     ,x_attribute_category           => p_attribute_category
     ,x_attribute1                   => p_attribute1
     ,x_attribute2                   => p_attribute2
     ,x_attribute3                   => p_attribute3
     ,x_attribute4                   => p_attribute4
     ,x_attribute5                   => p_attribute5
     ,x_attribute6                   => p_attribute6
     ,x_attribute7                   => p_attribute7
     ,x_attribute8                   => p_attribute8
     ,x_attribute9                   => p_attribute9
     ,x_attribute10                  => p_attribute10
     ,x_attribute11                  => p_attribute11
     ,x_attribute12                  => p_attribute12
     ,x_attribute13                  => p_attribute13
     ,x_attribute14                  => p_attribute14
     ,x_attribute15                  => p_attribute15
    );

  x_return_status := l_return_status;

EXCEPTION
  when fnd_api.g_exc_error then
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
				,p_data  => x_msg_data );

   when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

end insert_sort_criteria;

procedure lock_sort_criteria (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN  VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_order_code                     IN  NUMBER
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Lock_Sort_criteria';
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
begin
   -- Standard call to check for call compatibility
   if not fnd_api.compatible_api_call( l_api_version
 				      ,p_api_version
 				      ,l_api_name
 				      ,g_pkg_name ) then
     raise fnd_api.g_exc_unexpected_error;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE
   if fnd_api.to_boolean( p_init_msg_list ) then
     fnd_msg_pub.initialize;
   end if;

   validate_input
    (
      x_return_status                => x_return_status
     ,p_action                       => 'LOCK'
     ,p_rule_id                      => p_rule_id
     ,p_sequence_number              => p_sequence_number
     ,p_parameter_id                 => p_parameter_id
     ,p_order_code                   => p_order_code
     ,p_attribute_category           => p_attribute_category
     ,p_attribute1                   => p_attribute1
     ,p_attribute2                   => p_attribute2
     ,p_attribute3                   => p_attribute3
     ,p_attribute4                   => p_attribute4
     ,p_attribute5                   => p_attribute5
     ,p_attribute6                   => p_attribute6
     ,p_attribute7                   => p_attribute7
     ,p_attribute8                   => p_attribute8
     ,p_attribute9                   => p_attribute9
     ,p_attribute10                  => p_attribute10
     ,p_attribute11                  => p_attribute11
     ,p_attribute12                  => p_attribute12
     ,p_attribute13                  => p_attribute13
     ,p_attribute14                  => p_attribute14
     ,p_attribute15                  => p_attribute15
    );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   wms_sort_criteria_pkg.lock_row (
       x_rowid                        => p_rowid
      ,x_rule_id                      => p_rule_id
      ,x_sequence_number              => p_sequence_number
      ,x_parameter_id                 => p_parameter_id
      ,x_order_code                   => p_order_code
      ,x_attribute_category           => p_attribute_category
      ,x_attribute1                   => p_attribute1
      ,x_attribute2                   => p_attribute2
      ,x_attribute3                   => p_attribute3
      ,x_attribute4                   => p_attribute4
      ,x_attribute5                   => p_attribute5
      ,x_attribute6                   => p_attribute6
      ,x_attribute7                   => p_attribute7
      ,x_attribute8                   => p_attribute8
      ,x_attribute9                   => p_attribute9
      ,x_attribute10                  => p_attribute10
      ,x_attribute11                  => p_attribute11
      ,x_attribute12                  => p_attribute12
      ,x_attribute13                  => p_attribute13
      ,x_attribute14                  => p_attribute14
      ,x_attribute15                  => p_attribute15
     );

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
				,p_data  => x_msg_data );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

end lock_sort_criteria ;

procedure update_sort_criteria (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN  VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_order_code                     IN  NUMBER
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Update_Sort_criteria';
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_row_id        VARCHAR2(20);
     l_date          DATE;
     l_user_id       NUMBER;
     l_login_id      NUMBER;
     l_found         BOOLEAN;
begin
   -- Standard call to check for call compatibility
   if not fnd_api.compatible_api_call( l_api_version
				      ,p_api_version
				      ,l_api_name
				      ,g_pkg_name ) then
     raise fnd_api.g_exc_unexpected_error;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE
   if fnd_api.to_boolean( p_init_msg_list ) then
     fnd_msg_pub.initialize;
   end if;

   validate_input
    (
      x_return_status                => x_return_status
     ,p_action                       => 'UPDATE'
     ,p_rule_id                      => p_rule_id
     ,p_sequence_number              => p_sequence_number
     ,p_parameter_id                 => p_parameter_id
     ,p_order_code                   => p_order_code
     ,p_attribute_category           => p_attribute_category
     ,p_attribute1                   => p_attribute1
     ,p_attribute2                   => p_attribute2
     ,p_attribute3                   => p_attribute3
     ,p_attribute4                   => p_attribute4
     ,p_attribute5                   => p_attribute5
     ,p_attribute6                   => p_attribute6
     ,p_attribute7                   => p_attribute7
     ,p_attribute8                   => p_attribute8
     ,p_attribute9                   => p_attribute9
     ,p_attribute10                  => p_attribute10
     ,p_attribute11                  => p_attribute11
     ,p_attribute12                  => p_attribute12
     ,p_attribute13                  => p_attribute13
     ,p_attribute14                  => p_attribute14
     ,p_attribute15                  => p_attribute15
    );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   /* get who column information */
   SELECT Sysdate INTO l_date FROM dual;
   l_user_id := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   /* call the table handler to do the update */
   wms_sort_criteria_pkg.update_row
     (
       x_rowid                        => p_rowid
      ,x_rule_id                      => p_rule_id
      ,x_sequence_number              => p_sequence_number
      ,x_last_updated_by              => l_user_id
      ,x_last_update_date             => l_date
      ,x_last_update_login            => l_login_id
      ,x_parameter_id                 => p_parameter_id
      ,x_order_code                   => p_order_code
      ,x_attribute_category           => p_attribute_category
      ,x_attribute1                   => p_attribute1
      ,x_attribute2                   => p_attribute2
      ,x_attribute3                   => p_attribute3
      ,x_attribute4                   => p_attribute4
      ,x_attribute5                   => p_attribute5
      ,x_attribute6                   => p_attribute6
      ,x_attribute7                   => p_attribute7
      ,x_attribute8                   => p_attribute8
      ,x_attribute9                   => p_attribute9
      ,x_attribute10                  => p_attribute10
      ,x_attribute11                  => p_attribute11
      ,x_attribute12                  => p_attribute12
      ,x_attribute13                  => p_attribute13
      ,x_attribute14                  => p_attribute14
      ,x_attribute15                  => p_attribute15
      );

   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
				,p_data  => x_msg_data );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

end update_sort_criteria ;

procedure delete_sort_criteria (
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 := fnd_api.g_false,
  p_validation_level          in  number   := fnd_api.g_valid_level_full,
  x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_rowid                     IN  VARCHAR2,
  p_rule_id                   IN  NUMBER,
  p_sequence_number           IN  NUMBER
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Delete_Sort_criteria';
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_dummy_rowid VARCHAR2(18);
BEGIN

   -- Standard call to check for call compatibility
   if not fnd_api.compatible_api_call( l_api_version
				      ,p_api_version
				      ,l_api_name
				      ,g_pkg_name ) then
     raise fnd_api.g_exc_unexpected_error;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE
   if fnd_api.to_boolean( p_init_msg_list ) then
     fnd_msg_pub.initialize;
   end if;

   validate_input
    (
      x_return_status                => x_return_status
     ,p_action                       => 'DELETE'
     ,p_rule_id                      => p_rule_id
     ,p_sequence_number              => p_sequence_number
     ,p_parameter_id                 => fnd_api.g_miss_num -- dont care
     ,p_order_code                   => fnd_api.g_miss_num
     ,p_attribute_category           => fnd_api.g_miss_char
     ,p_attribute1                   => fnd_api.g_miss_char
     ,p_attribute2                   => fnd_api.g_miss_char
     ,p_attribute3                   => fnd_api.g_miss_char
     ,p_attribute4                   => fnd_api.g_miss_char
     ,p_attribute5                   => fnd_api.g_miss_char
     ,p_attribute6                   => fnd_api.g_miss_char
     ,p_attribute7                   => fnd_api.g_miss_char
     ,p_attribute8                   => fnd_api.g_miss_char
     ,p_attribute9                   => fnd_api.g_miss_char
     ,p_attribute10                  => fnd_api.g_miss_char
     ,p_attribute11                  => fnd_api.g_miss_char
     ,p_attribute12                  => fnd_api.g_miss_char
     ,p_attribute13                  => fnd_api.g_miss_char
     ,p_attribute14                  => fnd_api.g_miss_char
     ,p_attribute15                  => fnd_api.g_miss_char
    );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   wms_sort_criteria_pkg.delete_row(p_rowid);
   fnd_msg_pub.count_and_get( p_count => x_msg_count
			      ,p_data => x_msg_data );
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_count => x_msg_count
				,p_data  => x_msg_data );

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data => x_msg_data );

end delete_sort_criteria ;

-- private procedure should be used only by the wms_rule_form_pkg.delete_rule
-- no validation is done whatsoever
procedure delete_sort_criterias (
  p_rule_id                   IN  NUMBER
) is
BEGIN
   DELETE FROM wms_sort_criteria
     WHERE rule_id = p_rule_id;
END delete_sort_criterias;

end WMS_SORT_CRITERIA_FORM_PKG;

/
