--------------------------------------------------------
--  DDL for Package Body WMS_RULE_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_FORM_PKG" AS
/* $Header: WMSFPPRB.pls 120.1 2005/06/21 10:01:18 appldev ship $ */

g_pkg_name constant varchar2(30) := 'WMSRule_Form_PKG';

-- private function
-- return true if no existing rule has the same id as the input
FUNCTION check_existence
  (
    p_rule_id                        IN  NUMBER
   ) RETURN BOOLEAN IS
      CURSOR c IS SELECT rule_id FROM wms_rules_b
	WHERE rule_id = p_rule_id;
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
    x_return_status             out NOCOPY VARCHAR2
   ,p_action                    IN  VARCHAR2
   ,p_rule_id 			in  NUMBER
   ,p_organization_id 		in  NUMBER
   ,p_type_code 		in  NUMBER
   ,p_qty_function_parameter_id in  NUMBER
   ,p_enabled_flag 		in  VARCHAR2
   ,p_user_defined_flag 	in  VARCHAR2
   ,p_attribute_category 	in  VARCHAR2
   ,p_attribute1 		in  VARCHAR2
   ,p_attribute2  		in  VARCHAR2
   ,p_attribute3 		in  VARCHAR2
   ,p_attribute4 		in  VARCHAR2
   ,p_attribute5 		in  VARCHAR2
   ,p_attribute6 		in  VARCHAR2
   ,p_attribute7 		in  VARCHAR2
   ,p_attribute8 		in  VARCHAR2
   ,p_attribute9 		in  VARCHAR2
   ,p_attribute10 		in  VARCHAR2
   ,p_attribute11 		in  VARCHAR2
   ,p_attribute12 		in  VARCHAR2
   ,p_attribute13 		in  VARCHAR2
   ,p_attribute14 		in  VARCHAR2
   ,p_attribute15 		in  VARCHAR2
   ,p_name 		        in  VARCHAR2
   ,p_description 		in  VARCHAR2
   ,p_allocation_mode_id    in number
  ) IS
     l_return_status 	   VARCHAR2(1) := fnd_api.g_ret_sts_success;
BEGIN

   /* check p_action */
   IF p_action NOT IN ('INSERT', 'UPDATE', 'LOCK', 'DELETE') THEN
      -- unknown exception
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   /* check existence */
   IF p_action IN ('DELETE','LOCK','UPDATE') THEN
      IF check_existence(p_rule_id) THEN
	 fnd_message.set_name('WMS', 'WMS_RULE_NOT_FOUND');
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   /* more input validation update and insert */
   IF p_action IN ('UPDATE', 'INSERT') THEN
      /* check foreign keys */
      /* check organization id here by calling api */

      /* validate enabled_flag */
      IF p_enabled_flag NOT IN ('Y', 'N') THEN
	 fnd_message.set_name('WMS', 'WMS_INVALID_ENABLED_FLAG');
	 fnd_message.set_token('FLAG',p_enabled_flag);
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

      /* validate user_defined_flag */
      IF p_user_defined_flag NOT IN ('Y', 'N') THEN
	 fnd_message.set_name('WMS', 'WMS_INVALID_USER_DEFINED_FLAG');
	 fnd_message.set_token('FLAG',p_user_defined_flag);
	 fnd_msg_pub.ADD;
	 RAISE fnd_api.g_exc_error;
      END IF;

	/*commented out on 12/6/99 by jcearley, since type code can be > 2*/
      /* validate type code */
--      IF p_type_code NOT IN (1,2) THEN
--	 fnd_message.set_name('WMS','WMS_INVALID_PP_TYPE_CODE');
--	 fnd_msg_pub.ADD;
--	 RAISE fnd_api.g_exc_error;
--     END IF;

      /* validate qty parameter id */
--       IF wms_parameter_form_pkg(p_qty_function_parameter_id) THEN
-- 	 fnd_message.set_name('WMS','WMS_INVALID_QTY_PARAMETER');
-- 	 fnd_msg_pub.ADD;
-- 	 RAISE fnd_api.g_exc_error;
--       END IF;
   END IF;

   /* check that if the rule is in use in a strategy */
   /* delete is not allowed */
--    IF p_action = 'DELETE' THEN
--       IF wms_strategy_form_pkg.rule_in_used(rule_id) THEN
-- 	 fnd_message.set_name('WMS','WMS_RULE_IN_USE');
-- 	 fnd_msg_pub.ADD;
-- 	 RAISE fnd_api.g_exc_error;
--       END IF;
--    END IF;
   x_return_status := l_return_status;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END validate_input;

procedure insert_rule
  (
    x_return_status       	out NOCOPY varchar2
   ,x_msg_count           	out NOCOPY number
   ,x_msg_data            	out NOCOPY varchar2
   ,x_rule_id 			out NOCOPY NUMBER
   , p_api_version         	in  number
   ,p_organization_id 		in  NUMBER
   ,p_type_code 		in  NUMBER
   ,p_qty_function_parameter_id in  NUMBER
   ,p_enabled_flag 		in  VARCHAR2
   ,p_user_defined_flag 	in  VARCHAR2
   ,p_min_pick_tasks_flag       in  VARCHAR2
   ,p_attribute_category 	in  VARCHAR2
   ,p_attribute1 		in  VARCHAR2
   ,p_attribute2  		in  VARCHAR2
   ,p_attribute3 		in  VARCHAR2
   ,p_attribute4 		in  VARCHAR2
   ,p_attribute5 		in  VARCHAR2
   ,p_attribute6 		in  VARCHAR2
   ,p_attribute7 		in  VARCHAR2
   ,p_attribute8 		in  VARCHAR2
   ,p_attribute9 		in  VARCHAR2
   ,p_attribute10 		in  VARCHAR2
   ,p_attribute11 		in  VARCHAR2
   ,p_attribute12 		in  VARCHAR2
   ,p_attribute13 		in  VARCHAR2
   ,p_attribute14 		in  VARCHAR2
   ,p_attribute15 		in  VARCHAR2
   ,p_name 		        in  VARCHAR2
   ,p_description 		in  VARCHAR2
   ,p_type_header_id            in  NUMBER
   ,p_rule_weight               in  NUMBER
   ,p_init_msg_list       	in  varchar2 DEFAULT fnd_api.g_false
   ,p_validation_level    	in  number   DEFAULT fnd_api.g_valid_level_full
   ,p_allocation_mode_id    in number
  ) IS
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Insert_Rule';
     l_return_status 	   VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_row_id        	   VARCHAR2(20);
     l_date          	   DATE;
     l_user_id       	   NUMBER;
     l_login_id      	   NUMBER;
     l_found         	   BOOLEAN;
     l_rule_id             NUMBER;
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

  SELECT wms_rules_s.NEXTVAL INTO l_rule_id FROM dual;

  validate_input
  (
    x_return_status             => l_return_status
   ,p_action                    => 'INSERT'
   ,p_rule_id 			=> l_rule_id
   ,p_organization_id 		=> p_organization_id
   ,p_type_code 		=> p_type_code
   ,p_qty_function_parameter_id => p_qty_function_parameter_id
   ,p_enabled_flag 		=> p_enabled_flag
   ,p_user_defined_flag 	=> p_user_defined_flag
   ,p_attribute_category 	=> p_attribute_category
   ,p_attribute1 		=> p_attribute1
   ,p_attribute2  		=> p_attribute2
   ,p_attribute3 		=> p_attribute3
   ,p_attribute4 		=> p_attribute4
   ,p_attribute5 		=> p_attribute5
   ,p_attribute6 		=> p_attribute6
   ,p_attribute7 		=> p_attribute7
   ,p_attribute8 		=> p_attribute8
   ,p_attribute9 		=> p_attribute9
   ,p_attribute10 		=> p_attribute10
   ,p_attribute11 		=> p_attribute11
   ,p_attribute12 		=> p_attribute12
   ,p_attribute13 		=> p_attribute13
   ,p_attribute14 		=> p_attribute14
   ,p_attribute15 		=> p_attribute15
   ,p_name 		        => p_name
   ,p_description 		=> p_description
    ,p_allocation_mode_id => p_allocation_mode_id
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

   /* call the table handler to do the insert */
   wms_rules_pkg.insert_row
     (
       x_rowid 			      => l_row_id
      ,x_rule_id 		      => l_rule_id
      ,x_organization_id 	      => p_organization_id
      ,x_type_code 		      => p_type_code
      ,x_qty_function_parameter_id    => p_qty_function_parameter_id
      ,x_enabled_flag 		      => p_enabled_flag
      ,x_user_defined_flag 	      => p_user_defined_flag
      ,x_min_pick_tasks_flag 	      => p_min_pick_tasks_flag
      ,x_attribute_category 	      => p_attribute_category
      ,x_attribute1 		      => p_attribute1
      ,x_attribute2 		      => p_attribute2
      ,x_attribute3 		      => p_attribute3
      ,x_attribute4 		      => p_attribute4
      ,x_attribute5 		      => p_attribute5
      ,x_attribute6 		      => p_attribute6
      ,x_attribute7 		      => p_attribute7
      ,x_attribute8 		      => p_attribute8
      ,x_attribute9 		      => p_attribute9
      ,x_attribute10 		      => p_attribute10
      ,x_attribute11 		      => p_attribute11
      ,x_attribute12 		      => p_attribute12
      ,x_attribute13 		      => p_attribute13
      ,x_attribute14 		      => p_attribute14
      ,x_attribute15 		      => p_attribute15
      ,x_name 		              => p_name
      ,x_description 		      => p_description
      ,x_creation_date 		      => l_date
      ,x_created_by 		      => l_user_id
      ,x_last_update_date 	      => l_date
      ,x_last_updated_by 	      => l_user_id
      ,x_last_update_login 	      => l_login_id
      ,x_type_header_id               => p_type_header_id
      ,x_rule_weight                  => p_rule_weight
      ,x_allocation_mode_id       => p_allocation_mode_id
      );

   x_return_status := l_return_status;
   x_rule_id := l_rule_id;

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

end insert_rule;

procedure lock_rule (
  x_return_status       	 out NOCOPY VARCHAR2,
  x_msg_count           	 out NOCOPY NUMBER,
  x_msg_data            	 out NOCOPY VARCHAR2,
  p_rule_id                      in  NUMBER,
  p_organization_id              in  NUMBER,
  p_type_code                    in  NUMBER,
  p_qty_function_parameter_id    in  NUMBER,
  p_enabled_flag                 in  VARCHAR2,
  p_user_defined_flag            in  VARCHAR2,
  p_min_pick_tasks_flag          in  VARCHAR2,
  p_attribute_category           in  VARCHAR2,
  p_attribute1 			 in  VARCHAR2,
  p_attribute2 			 in  VARCHAR2,
  p_attribute3  		 in  VARCHAR2,
  p_attribute4 			 in  VARCHAR2,
  p_attribute5 			 in  VARCHAR2,
  p_attribute6 			 in  VARCHAR2,
  p_attribute7 			 in  VARCHAR2,
  p_attribute8 			 in  VARCHAR2,
  p_attribute9 			 in  VARCHAR2,
  p_attribute10 		 in  VARCHAR2,
  p_attribute11 		 in  VARCHAR2,
  p_attribute12 		 in  VARCHAR2,
  p_attribute13 		 in  VARCHAR2,
  p_attribute14 		 in  VARCHAR2,
  p_attribute15 		 in  VARCHAR2,
  p_name                         in  VARCHAR2,
  p_description                  in  VARCHAR2,
  p_type_header_id               in  NUMBER,
  p_rule_weight                  in  NUMBER,
  p_api_version                  in  NUMBER,
  p_init_msg_list               in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level            in  number   DEFAULT fnd_api.g_valid_level_full
 ,p_allocation_mode_id          in number
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Lock_Rule';
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
    x_return_status             => l_return_status
   ,p_action                    => 'LOCK'
   ,p_rule_id 			=> p_rule_id
   ,p_organization_id 		=> p_organization_id
   ,p_type_code 		=> p_type_code
   ,p_qty_function_parameter_id => p_qty_function_parameter_id
   ,p_enabled_flag 		=> p_enabled_flag
   ,p_user_defined_flag 	=> p_user_defined_flag
   ,p_attribute_category 	=> p_attribute_category
   ,p_attribute1 		=> p_attribute1
   ,p_attribute2  		=> p_attribute2
   ,p_attribute3 		=> p_attribute3
   ,p_attribute4 		=> p_attribute4
   ,p_attribute5 		=> p_attribute5
   ,p_attribute6 		=> p_attribute6
   ,p_attribute7 		=> p_attribute7
   ,p_attribute8 		=> p_attribute8
   ,p_attribute9 		=> p_attribute9
   ,p_attribute10 		=> p_attribute10
   ,p_attribute11 		=> p_attribute11
   ,p_attribute12 		=> p_attribute12
   ,p_attribute13 		=> p_attribute13
   ,p_attribute14 		=> p_attribute14
   ,p_attribute15 		=> p_attribute15
   ,p_name 		        => p_name
   ,p_description 		=> p_description
   ,p_allocation_mode_id => p_allocation_mode_id
    );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   wms_rules_pkg.lock_row
     (
       x_rule_id 		      => p_rule_id
      ,x_organization_id 	      => p_organization_id
      ,x_type_code 		      => p_type_code
      ,x_qty_function_parameter_id    => p_qty_function_parameter_id
      ,x_enabled_flag 		      => p_enabled_flag
      ,x_user_defined_flag 	      => p_user_defined_flag
      ,x_min_pick_tasks_flag 	      => p_min_pick_tasks_flag
      ,x_attribute_category 	      => p_attribute_category
      ,x_attribute1 		      => p_attribute1
      ,x_attribute2 		      => p_attribute2
      ,x_attribute3 		      => p_attribute3
      ,x_attribute4 		      => p_attribute4
      ,x_attribute5 		      => p_attribute5
      ,x_attribute6 		      => p_attribute6
      ,x_attribute7 		      => p_attribute7
      ,x_attribute8 		      => p_attribute8
      ,x_attribute9 		      => p_attribute9
      ,x_attribute10 		      => p_attribute10
      ,x_attribute11 		      => p_attribute11
      ,x_attribute12 		      => p_attribute12
      ,x_attribute13 		      => p_attribute13
      ,x_attribute14 		      => p_attribute14
      ,x_attribute15 		      => p_attribute15
      ,x_name 		              => p_name
      ,x_description 		      => p_description
      ,x_type_header_id               => p_type_header_id
      ,x_rule_weight                  => p_rule_weight
      ,x_allocation_mode_id => p_allocation_mode_id
     );

   x_return_status := l_return_status;

EXCEPTION
   WHEN no_data_found THEN
      fnd_message.set_name('WMS','WMS_RULE_NOT_FOUND');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

end lock_rule ;

procedure update_rule (
  x_return_status             out NOCOPY VARCHAR2,
  x_msg_count                 out NOCOPY NUMBER,
  x_msg_data                  out NOCOPY VARCHAR2,
  p_api_version               in  NUMBER,
  p_rule_id           	      in NUMBER,
  p_organization_id   	      in NUMBER,
  p_type_code         	      in NUMBER,
  p_qty_function_parameter_id in NUMBER,
  p_enabled_flag              in VARCHAR2,
  p_user_defined_flag         in VARCHAR2,
  p_min_pick_tasks_flag       in VARCHAR2,
  p_attribute_category        in VARCHAR2,
  p_attribute1 		      in VARCHAR2,
  p_attribute2 		      in VARCHAR2,
  p_attribute3  	      in VARCHAR2,
  p_attribute4 		      in VARCHAR2,
  p_attribute5 		      in VARCHAR2,
  p_attribute6 		      in VARCHAR2,
  p_attribute7 		      in VARCHAR2,
  p_attribute8 		      in VARCHAR2,
  p_attribute9 		      in VARCHAR2,
  p_attribute10 	      in VARCHAR2,
  p_attribute11       	      in VARCHAR2,
  p_attribute12       	      in VARCHAR2,
  p_attribute13 	      in VARCHAR2,
  p_attribute14 	      in VARCHAR2,
  p_attribute15 	      in VARCHAR2,
  p_name                      in VARCHAR2,
  p_description               in VARCHAR2,
  p_type_header_id            in  NUMBER,
  p_rule_weight               in  NUMBER,
  p_last_update_date          in DATE,
  p_last_updated_by           in NUMBER,
  p_last_update_login         in NUMBER,
  p_init_msg_list             in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level          in  number   DEFAULT fnd_api.g_valid_level_full
 ,p_allocation_mode_id    in number
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Update_Rule';
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
    x_return_status             => l_return_status
   ,p_action                    => 'UPDATE'
   ,p_rule_id 			=> p_rule_id
   ,p_organization_id 		=> p_organization_id
   ,p_type_code 		=> p_type_code
   ,p_qty_function_parameter_id => p_qty_function_parameter_id
   ,p_enabled_flag 		=> p_enabled_flag
   ,p_user_defined_flag 	=> p_user_defined_flag
   ,p_attribute_category 	=> p_attribute_category
   ,p_attribute1 		=> p_attribute1
   ,p_attribute2  		=> p_attribute2
   ,p_attribute3 		=> p_attribute3
   ,p_attribute4 		=> p_attribute4
   ,p_attribute5 		=> p_attribute5
   ,p_attribute6 		=> p_attribute6
   ,p_attribute7 		=> p_attribute7
   ,p_attribute8 		=> p_attribute8
   ,p_attribute9 		=> p_attribute9
   ,p_attribute10 		=> p_attribute10
   ,p_attribute11 		=> p_attribute11
   ,p_attribute12 		=> p_attribute12
   ,p_attribute13 		=> p_attribute13
   ,p_attribute14 		=> p_attribute14
   ,p_attribute15 		=> p_attribute15
   ,p_name 		        => p_name
   ,p_description 		=> p_description
   ,p_allocation_mode_id => p_allocation_mode_id
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
   wms_rules_pkg.update_row
     (
       x_rule_id 		      => p_rule_id
      ,x_organization_id 	      => p_organization_id
      ,x_type_code 		      => p_type_code
      ,x_qty_function_parameter_id    => p_qty_function_parameter_id
      ,x_enabled_flag 		      => p_enabled_flag
      ,x_user_defined_flag 	      => p_user_defined_flag
      ,x_min_pick_tasks_flag 	      => p_min_pick_tasks_flag
      ,x_attribute_category 	      => p_attribute_category
      ,x_attribute1 		      => p_attribute1
      ,x_attribute2 		      => p_attribute2
      ,x_attribute3 		      => p_attribute3
      ,x_attribute4 		      => p_attribute4
      ,x_attribute5 		      => p_attribute5
      ,x_attribute6 		      => p_attribute6
      ,x_attribute7 		      => p_attribute7
      ,x_attribute8 		      => p_attribute8
      ,x_attribute9 		      => p_attribute9
      ,x_attribute10 		      => p_attribute10
      ,x_attribute11 		      => p_attribute11
      ,x_attribute12 		      => p_attribute12
      ,x_attribute13 		      => p_attribute13
      ,x_attribute14 		      => p_attribute14
      ,x_attribute15 		      => p_attribute15
      ,x_name 		              => p_name
      ,x_description 		      => p_description
      ,x_last_update_date 	      => l_date
      ,x_last_updated_by 	      => l_user_id
      ,x_last_update_login 	      => l_login_id
      ,x_type_header_id               => p_type_header_id
      ,x_rule_weight                  => p_rule_weight
      ,x_allocation_mode_id       => p_allocation_mode_id
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

end update_rule ;

procedure find_rule (
  x_return_status             out NOCOPY VARCHAR2,
  x_msg_count                 out NOCOPY NUMBER,
  x_msg_data                  out NOCOPY VARCHAR2,
  x_found                     out NOCOPY BOOLEAN,
  p_rule_id                   IN  NUMBER,
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level          in  number   DEFAULT fnd_api.g_valid_level_full
  ) IS
  -- API standard variables
  l_api_version         constant number       := 1.0;
  l_api_name            constant varchar2(30) := 'Find_Rule';

  CURSOR l_cur IS
     SELECT	'Y'
       FROM wms_rules_b
       WHERE rule_id = p_rule_id;

  l_dummy VARCHAR2(1);
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

  OPEN l_cur;
  FETCH l_cur INTO l_dummy;

  IF l_cur%notfound THEN
     x_found := FALSE;
   ELSE
     x_found := TRUE;
  END IF;
  CLOSE l_cur;

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

END find_rule;

procedure delete_rule (
  x_return_status             out NOCOPY VARCHAR2,
  x_msg_count                 out NOCOPY NUMBER,
  x_msg_data                  out NOCOPY VARCHAR2,
  p_rule_id                   IN  NUMBER,
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level          in  number   DEFAULT fnd_api.g_valid_level_full
) is
     -- API standard variables
     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Delete_Rule';
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
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

   SAVEPOINT delete_rule_sa;

   validate_input
     (
       x_return_status             => l_return_status
      ,p_action                    => 'DELETE'
      ,p_rule_id 		           => p_rule_id
      ,p_organization_id           => fnd_api.g_miss_num
      ,p_type_code                 => fnd_api.g_miss_num
      ,p_qty_function_parameter_id => fnd_api.g_miss_num
      ,p_enabled_flag              => fnd_api.g_miss_char
      ,p_user_defined_flag         => fnd_api.g_miss_char
      ,p_attribute_category        => fnd_api.g_miss_char
      ,p_attribute1                => fnd_api.g_miss_char
      ,p_attribute2                => fnd_api.g_miss_char
      ,p_attribute3                => fnd_api.g_miss_char
      ,p_attribute4                => fnd_api.g_miss_char
      ,p_attribute5                => fnd_api.g_miss_char
      ,p_attribute6                => fnd_api.g_miss_char
      ,p_attribute7                => fnd_api.g_miss_char
      ,p_attribute8                => fnd_api.g_miss_char
      ,p_attribute9                => fnd_api.g_miss_char
      ,p_attribute10               => fnd_api.g_miss_char
      ,p_attribute11               => fnd_api.g_miss_char
      ,p_attribute12               => fnd_api.g_miss_char
      ,p_attribute13               => fnd_api.g_miss_char
      ,p_attribute14               => fnd_api.g_miss_char
      ,p_attribute15               => fnd_api.g_miss_char
      ,p_name                      => fnd_api.g_miss_char
      ,p_description               => fnd_api.g_miss_char
      ,p_allocation_mode_id        => fnd_api.g_miss_num
      );

   if x_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif x_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   /* special treatment */
   /* we want to delete all restrictions and sort criteria records that tie to */
   /* this rule */
   wms_restriction_form_pkg.delete_restrictions(p_rule_id);
   /* wms_sort_criteria_form_pkg.delete_sort_criteria(p_rule_id); */
   wms_rules_pkg.delete_row(p_rule_id);

   x_return_status := l_return_status;

EXCEPTION
   when fnd_api.g_exc_error THEN
      ROLLBACK TO delete_rule_sa;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   when fnd_api.g_exc_unexpected_error then
      ROLLBACK TO delete_rule_sa;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   WHEN OTHERS THEN
      ROLLBACK TO delete_rule_sa;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data => x_msg_data );

end delete_rule ;

PROCEDURE copy_rule
  (
    x_return_status            out NOCOPY VARCHAR2
   ,x_msg_count                out NOCOPY NUMBER
   ,x_msg_data                 out NOCOPY VARCHAR2
   ,x_new_rule_id              out NOCOPY NUMBER
   ,p_orig_rule_id             IN  NUMBER
   ,p_new_rule_name            IN  VARCHAR2
   ,p_new_description          IN  VARCHAR2
   ,p_new_organization_id      IN  NUMBER
   ,p_new_type_code            IN  NUMBER
   ,p_copy_restriction_flag    IN  VARCHAR2
   ,p_copy_sort_criteria_flag  IN  VARCHAR2
   ,p_api_version              in  NUMBER
   ,p_init_msg_list            in  varchar2 DEFAULT fnd_api.g_false
   ,p_validation_level         in  number   DEFAULT fnd_api.g_valid_level_full
  ) IS

     l_api_version         constant number       := 1.0;
     l_api_name            constant varchar2(30) := 'Copy_Rule';
     l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_rowid               VARCHAR2(2000);

     l_consistency_id   NUMBER;
     l_date   DATE;


     CURSOR l_orig_rule_cur IS
     SELECT
        organization_id
       ,rule_id
       ,type_code
       ,qty_function_parameter_id
       ,enabled_flag
       ,user_defined_flag
       ,min_pick_tasks_flag
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,name
       ,description
       ,TYPE_HDR_ID
       ,RULE_WEIGHT
       ,allocation_mode_id
       FROM  wms_rules
       WHERE rule_id         = p_orig_rule_id;

     l_rule_rec l_orig_rule_cur%ROWTYPE;

     CURSOR l_orig_restriction_cur IS
	SELECT
	   rule_id
	  ,sequence_number
	  ,parameter_id
	  ,operator_code
	  ,operand_type_code
	  ,operand_constant_number
	  ,operand_constant_character
	  ,operand_constant_date
	  ,operand_parameter_id
	  ,operand_expression
	  ,operand_flex_value_set_id
	  ,logical_operator_code
	  ,bracket_open
	  ,bracket_close
	  ,attribute_category
	  ,attribute1
	  ,attribute2
	  ,attribute3
	  ,attribute4
	  ,attribute5
	  ,attribute6
	  ,attribute7
	  ,attribute8
	  ,attribute9
	  ,attribute10
	  ,attribute11
	  ,attribute12
	  ,attribute13
	  ,attribute14
	  ,attribute15
       FROM  wms_restrictions
       WHERE rule_id         = p_orig_rule_id;

     l_restriction_rec l_orig_restriction_cur%ROWTYPE;

     CURSOR l_orig_sort_cur IS
	SELECT
	  rule_id
	  ,sequence_number
	  ,parameter_id
	  ,order_code
	  ,attribute_category
	  ,attribute1
	  ,attribute2
	  ,attribute3
	  ,attribute4
	  ,attribute5
	  ,attribute6
	  ,attribute7
	  ,attribute8
	  ,attribute9
	  ,attribute10
	  ,attribute11
	  ,attribute12
	  ,attribute13
	  ,attribute14
	  ,attribute15
	  FROM  wms_sort_criteria
	  WHERE rule_id         = p_orig_rule_id;

     l_sort_rec       l_orig_sort_cur%ROWTYPE;

-- Part of Bugfix 2279644
     CURSOR l_orig_consistency_cur IS
	SELECT
	  rule_id
	  ,consistency_id
     ,parameter_id
	  ,attribute_category
	  ,attribute1
	  ,attribute2
	  ,attribute3
	  ,attribute4
	  ,attribute5
	  ,attribute6
	  ,attribute7
	  ,attribute8
	  ,attribute9
	  ,attribute10
	  ,attribute11
	  ,attribute12
	  ,attribute13
	  ,attribute14
	  ,attribute15
	  FROM  wms_rule_consistencies
	  WHERE rule_id         = p_orig_rule_id;

     l_consistency_rec       l_orig_consistency_cur%ROWTYPE;


     l_rule_id        NUMBER;
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

   SAVEPOINT copy_rule_sp;

   /* copy rule */
   OPEN l_orig_rule_cur;
   FETCH l_orig_rule_cur INTO l_rule_rec;
   IF l_orig_rule_cur%NOTFOUND THEN
      fnd_message.set_name('WMS','WMS_RULE_NOT_FOUND');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   /* no validation is done here */
   /* should be added later */
   l_rule_rec.organization_id 	:= p_new_organization_id;
   l_rule_rec.name            	:= p_new_rule_name;
   l_rule_rec.description     	:= p_new_description;
   l_rule_rec.type_code       	:= p_new_type_code;
   l_rule_rec.enabled_flag    	:= 'N';
   l_rule_rec.user_defined_flag	:= 'Y'; /*As a part of bug 1903620 */

   wms_rule_form_pkg.insert_rule
     (
       x_return_status       	    => l_return_status
      ,x_msg_count           	    => x_msg_count
      ,x_msg_data            	    => x_msg_data
      ,x_rule_id 		    => l_rule_id
      , p_api_version         	    => 1.0
      ,p_organization_id 	    => l_rule_rec.organization_id
      ,p_type_code 		    => l_rule_rec.type_code
      ,p_qty_function_parameter_id  => l_rule_rec.qty_function_parameter_id
      ,p_enabled_flag 		    => l_rule_rec.enabled_flag
      ,p_user_defined_flag 	    => l_rule_rec.user_defined_flag
      ,p_min_pick_tasks_flag 	    => l_rule_rec.min_pick_tasks_flag
      ,p_attribute_category 	    => l_rule_rec.attribute_category
      ,p_attribute1 		    => l_rule_rec.attribute1
      ,p_attribute2  		    => l_rule_rec.attribute2
      ,p_attribute3 		    => l_rule_rec.attribute3
      ,p_attribute4 		    => l_rule_rec.attribute4
      ,p_attribute5 		    => l_rule_rec.attribute5
      ,p_attribute6 		    => l_rule_rec.attribute6
      ,p_attribute7 		    => l_rule_rec.attribute7
      ,p_attribute8 		    => l_rule_rec.attribute8
      ,p_attribute9 		    => l_rule_rec.attribute9
      ,p_attribute10 		    => l_rule_rec.attribute10
      ,p_attribute11 		    => l_rule_rec.attribute11
      ,p_attribute12 		    => l_rule_rec.attribute12
      ,p_attribute13 		    => l_rule_rec.attribute13
      ,p_attribute14 		    => l_rule_rec.attribute14
      ,p_attribute15 		    => l_rule_rec.attribute15
      ,p_name 		            => l_rule_rec.name
      ,p_description 		    => l_rule_rec.description
      ,p_type_header_id            =>  l_rule_rec.type_hdr_id
      ,p_rule_weight               =>  l_rule_rec.rule_weight
      ,p_init_msg_list       	    => fnd_api.g_false
      ,p_validation_level    	    => fnd_api.g_valid_level_full
      ,p_allocation_mode_id         => l_rule_rec.allocation_mode_id
      );
 /* changed the x_return_status to l_return_status  below as part of bug1678742 */

   if l_return_status = fnd_api.g_ret_sts_unexp_error then
      raise fnd_api.g_exc_unexpected_error;
    elsif l_return_status = fnd_api.g_ret_sts_error then
      raise fnd_api.g_exc_error;
   end if;

   CLOSE l_orig_rule_cur;

   /* copy restrictions */

   IF p_copy_restriction_flag = 'Y' THEN
      OPEN l_orig_restriction_cur;
      LOOP
	 FETCH l_orig_restriction_cur INTO l_restriction_rec;
	 EXIT WHEN l_orig_restriction_cur%NOTFOUND;
	 l_restriction_rec.rule_id := l_rule_id;
	 wms_restriction_form_pkg.insert_restriction
	   (
      	      p_api_version         	   => 1.0
      	     ,p_init_msg_list       	   => fnd_api.g_false
      	     ,p_validation_level    	   => fnd_api.g_valid_level_full
      	     ,x_return_status       	   => l_return_status
      	     ,x_msg_count           	   => x_msg_count
      	     ,x_msg_data            	   => x_msg_data
             ,p_rowid                      => l_rowid
      	     ,p_rule_id                    => l_restriction_rec.rule_id
      	     ,p_sequence_number            => l_restriction_rec.sequence_number
      	     ,p_parameter_id               => l_restriction_rec.parameter_id
      	     ,p_operator_code              => l_restriction_rec.operator_code
      	     ,p_operand_type_code          => l_restriction_rec.operand_type_code
      	     ,p_operand_constant_number    => l_restriction_rec.operand_constant_number
      	     ,p_operand_constant_character => l_restriction_rec.operand_constant_character
      	     ,p_operand_constant_date      => l_restriction_rec.operand_constant_date
      	     ,p_operand_parameter_id       => l_restriction_rec.operand_parameter_id
      	     ,p_operand_expression         => l_restriction_rec.operand_expression
      	     ,p_operand_flex_value_set_id  => l_restriction_rec.operand_flex_value_set_id
      	     ,p_logical_operator_code      => l_restriction_rec.logical_operator_code
      	     ,p_bracket_open               => l_restriction_rec.bracket_open
      	     ,p_bracket_close              => l_restriction_rec.bracket_close
      	     ,p_attribute_category         => l_restriction_rec.attribute_category
      	     ,p_attribute1                 => l_restriction_rec.attribute1
      	     ,p_attribute2                 => l_restriction_rec.attribute2
      	     ,p_attribute3                 => l_restriction_rec.attribute3
      	     ,p_attribute4                 => l_restriction_rec.attribute4
      	     ,p_attribute5                 => l_restriction_rec.attribute5
      	     ,p_attribute6                 => l_restriction_rec.attribute6
      	     ,p_attribute7                 => l_restriction_rec.attribute7
      	     ,p_attribute8                 => l_restriction_rec.attribute8
      	     ,p_attribute9                 => l_restriction_rec.attribute9
      	     ,p_attribute10                => l_restriction_rec.attribute10
      	     ,p_attribute11                => l_restriction_rec.attribute11
      	     ,p_attribute12                => l_restriction_rec.attribute12
      	     ,p_attribute13                => l_restriction_rec.attribute13
      	     ,p_attribute14                => l_restriction_rec.attribute14
      	     ,p_attribute15                => l_restriction_rec.attribute15
	   );
 /* changed the x_return_status to l_return_status  below as part of bug1678742 */
	 if l_return_status = fnd_api.g_ret_sts_unexp_error then
	    raise fnd_api.g_exc_unexpected_error;
	  elsif l_return_status = fnd_api.g_ret_sts_error then
	    raise fnd_api.g_exc_error;
	 end if;
      END LOOP;
   CLOSE l_orig_restriction_cur;
   END IF;

   /* copy sort criteria */
   IF p_copy_sort_criteria_flag = 'Y' THEN
      OPEN l_orig_sort_cur;
      WHILE TRUE LOOP
	 FETCH l_orig_sort_cur INTO l_sort_rec;
	 EXIT WHEN l_orig_sort_cur%NOTFOUND;

	 l_sort_rec.rule_id := l_rule_id;
	 wms_sort_criteria_form_pkg.insert_sort_criteria
	   (
      	      p_api_version         	   => 1.0
      	     ,p_init_msg_list       	   => fnd_api.g_false
      	     ,p_validation_level    	   => fnd_api.g_valid_level_full
      	     ,x_return_status       	   => l_return_status
      	     ,x_msg_count           	   => x_msg_count
      	     ,x_msg_data            	   => x_msg_data
             ,p_rowid                      => l_rowid
      	     ,p_rule_id                    => l_sort_rec.rule_id
      	     ,p_sequence_number            => l_sort_rec.sequence_number
	     ,p_parameter_id               => l_sort_rec.parameter_id
	     ,p_order_code                 => l_sort_rec.order_code
      	     ,p_attribute_category         => l_sort_rec.attribute_category
      	     ,p_attribute1                 => l_sort_rec.attribute1
      	     ,p_attribute2                 => l_sort_rec.attribute2
      	     ,p_attribute3                 => l_sort_rec.attribute3
      	     ,p_attribute4                 => l_sort_rec.attribute4
      	     ,p_attribute5                 => l_sort_rec.attribute5
      	     ,p_attribute6                 => l_sort_rec.attribute6
      	     ,p_attribute7                 => l_sort_rec.attribute7
      	     ,p_attribute8                 => l_sort_rec.attribute8
      	     ,p_attribute9                 => l_sort_rec.attribute9
      	     ,p_attribute10                => l_sort_rec.attribute10
      	     ,p_attribute11                => l_sort_rec.attribute11
      	     ,p_attribute12                => l_sort_rec.attribute12
      	     ,p_attribute13                => l_sort_rec.attribute13
      	     ,p_attribute14                => l_sort_rec.attribute14
      	     ,p_attribute15                => l_sort_rec.attribute15
	   );
 /* changed the x_return_status to l_return_status  below as part of bug1678742 */
	 if l_return_status = fnd_api.g_ret_sts_unexp_error then
	    raise fnd_api.g_exc_unexpected_error;
	  elsif l_return_status = fnd_api.g_ret_sts_error then
	    raise fnd_api.g_exc_error;
	 end if;
      END LOOP;
   CLOSE l_orig_sort_cur;
   END IF;

-- Part of Bugfix 2279644
   /* Copy Rule_consistencies */
--   IF x_copy_consistency_criteria_flag = 'Y' THEN
      SELECT SYSDATE INTO l_date FROM dual;
      OPEN l_orig_consistency_cur;
      WHILE TRUE LOOP
	 FETCH l_orig_consistency_cur INTO l_consistency_rec;
	 EXIT WHEN l_orig_consistency_cur%NOTFOUND;

	 l_consistency_rec.rule_id := l_rule_id;
    SELECT wms_rule_consistencies_s.NEXTVAL INTO l_consistency_id FROM dual;
	 wms_rule_consistencies_pkg.insert_row
	   (
               x_rowid                      => l_rowid
              ,x_consistency_id             => l_consistency_id
      	     ,x_rule_id                    => l_consistency_rec.rule_id
              ,x_parameter_id               => l_consistency_rec.parameter_id
              ,x_creation_date              => l_date
              ,x_created_by                 => fnd_global.user_id
              ,x_last_update_date           => l_date
              ,x_last_updated_by            => fnd_global.user_id
              ,x_last_update_login          => fnd_global.login_id
      	     ,x_attribute_category         => l_consistency_rec.attribute_category
      	     ,x_attribute1                 => l_consistency_rec.attribute1
      	     ,x_attribute2                 => l_consistency_rec.attribute2
      	     ,x_attribute3                 => l_consistency_rec.attribute3
      	     ,x_attribute4                 => l_consistency_rec.attribute4
      	     ,x_attribute5                 => l_consistency_rec.attribute5
      	     ,x_attribute6                 => l_consistency_rec.attribute6
      	     ,x_attribute7                 => l_consistency_rec.attribute7
      	     ,x_attribute8                 => l_consistency_rec.attribute8
      	     ,x_attribute9                 => l_consistency_rec.attribute9
      	     ,x_attribute10                => l_consistency_rec.attribute10
      	     ,x_attribute11                => l_consistency_rec.attribute11
      	     ,x_attribute12                => l_consistency_rec.attribute12
      	     ,x_attribute13                => l_consistency_rec.attribute13
      	     ,x_attribute14                => l_consistency_rec.attribute14
      	     ,x_attribute15                => l_consistency_rec.attribute15
	   );

      END LOOP;
   CLOSE l_orig_consistency_cur;
--  END IF;

   x_new_rule_id := l_rule_id;
   x_return_status := l_return_status;

EXCEPTION
   when fnd_api.g_exc_error THEN
      ROLLBACK TO copy_rule_sp;
      IF l_orig_rule_cur%ISOPEN THEN
	 CLOSE l_orig_rule_cur;
      END IF;
      IF l_orig_restriction_cur%ISOPEN THEN
	 CLOSE l_orig_restriction_cur;
      END IF;
      IF l_orig_sort_cur%ISOPEN THEN
	 CLOSE l_orig_sort_cur;
      END IF;
-- Part of Bugfix 2279644
      IF l_orig_consistency_cur%ISOPEN THEN
	 CLOSE l_orig_consistency_cur;
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   when fnd_api.g_exc_unexpected_error then
      ROLLBACK TO copy_rule_sp;
      IF l_orig_rule_cur%ISOPEN THEN
	 CLOSE l_orig_rule_cur;
      END IF;
      IF l_orig_restriction_cur%ISOPEN THEN
	 CLOSE l_orig_restriction_cur;
      END IF;
      IF l_orig_sort_cur%ISOPEN THEN
	 CLOSE l_orig_sort_cur;
      END IF;
-- Part of Bugfix 2279644
      IF l_orig_consistency_cur%ISOPEN THEN
	 CLOSE l_orig_consistency_cur;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
				 ,p_data  => x_msg_data );

   when others then
      ROLLBACK TO copy_rule_sp;
      IF l_orig_rule_cur%ISOPEN THEN
	 CLOSE l_orig_rule_cur;
      END IF;
      IF l_orig_restriction_cur%ISOPEN THEN
	 CLOSE l_orig_restriction_cur;
      END IF;
      IF l_orig_sort_cur%ISOPEN THEN
	 CLOSE l_orig_sort_cur;
      END IF;
-- Part of Bugfix 2279644
      IF l_orig_consistency_cur%ISOPEN THEN
	 CLOSE l_orig_consistency_cur;
      END IF;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;

END copy_rule;

--Added to fix the Bug #3941280
FUNCTION check_wms_rule_exists ( p_std_operation_id IN NUMBER )
RETURN BOOLEAN
AS
  l_exist NUMBER := 0;
BEGIN
  BEGIN
    select 1
     into  l_exist
      from wms_rules_b
     where type_hdr_id = p_std_operation_id
       and type_code = 3
       and rownum < 2 ;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_exist := 0;
     WHEN OTHERS THEN
        RAISE fnd_api.g_exc_unexpected_error;
  END;

  IF l_exist = 1 THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END check_wms_rule_exists;

end WMS_RULE_FORM_PKG;

/
