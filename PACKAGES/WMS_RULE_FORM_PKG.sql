--------------------------------------------------------
--  DDL for Package WMS_RULE_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULE_FORM_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSFPPRS.pls 120.1 2005/06/22 08:31:52 appldev ship $ */
procedure insert_rule
  (
    x_return_status       	out NOCOPY varchar2
   ,x_msg_count           	out NOCOPY number
   ,x_msg_data            	out NOCOPY varchar2
   ,x_rule_id 			out NOCOPY NUMBER
   ,p_api_version         	in  number
   ,p_organization_id 		in  NUMBER
   ,p_type_code 		in  NUMBER
   ,p_qty_function_parameter_id in  NUMBER
   ,p_enabled_flag 		in  VARCHAR2
   ,p_user_defined_flag 	in  VARCHAR2
   ,p_min_pick_tasks_flag 	in  VARCHAR2
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
  );

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
  p_min_pick_tasks_flag 	 in  VARCHAR2,
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
  p_type_header_id              in  NUMBER,
  p_rule_weight                 in  NUMBER,
  p_api_version         	 in  NUMBER,
  p_init_msg_list       	 in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level    	 in  number   DEFAULT fnd_api.g_valid_level_full
 ,p_allocation_mode_id    in number
  );

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
  );

procedure find_rule (
  x_return_status             out NOCOPY VARCHAR2,
  x_msg_count                 out NOCOPY NUMBER,
  x_msg_data                  out NOCOPY VARCHAR2,
  x_found                     out NOCOPY BOOLEAN,
  p_rule_id                   IN  NUMBER,
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level          in  number   DEFAULT fnd_api.g_valid_level_full
 );

procedure delete_rule (
  x_return_status             out NOCOPY VARCHAR2,
  x_msg_count                 out NOCOPY NUMBER,
  x_msg_data                  out NOCOPY VARCHAR2,
  p_rule_id                   IN  NUMBER,
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 DEFAULT fnd_api.g_false,
  p_validation_level          in  number   DEFAULT fnd_api.g_valid_level_full
);

procedure copy_rule
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
   );

--Added to fix the Bug #3941280
FUNCTION check_wms_rule_exists
 (
   p_std_operation_id IN NUMBER
 )
RETURN BOOLEAN;

end WMS_RULE_FORM_PKG;


 

/
