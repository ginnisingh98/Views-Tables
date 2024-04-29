--------------------------------------------------------
--  DDL for Package WMS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: WMSHPPRS.pls 120.0 2005/05/25 09:06:24 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY VARCHAR2,
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       IN VARCHAR2,
  X_CREATION_DATE             in DATE,
  X_CREATED_BY                in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
  ,X_ALLOCATION_MODE_ID       in NUMBER
  ,X_wms_enabled_flag         in VARCHAR2 DEFAULT NULL
  );

procedure LOCK_ROW (
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       IN VARCHAR2,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
  ,X_ALLOCATION_MODE_ID        in NUMBER);

procedure UPDATE_ROW (
  X_RULE_ID                   in NUMBER,
  X_ORGANIZATION_ID           in NUMBER,
  X_TYPE_CODE                 in NUMBER,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_QTY_FUNCTION_PARAMETER_ID in NUMBER,
  X_ENABLED_FLAG              in VARCHAR2,
  X_USER_DEFINED_FLAG         in VARCHAR2,
  X_MIN_PICK_TASKS_FLAG       IN VARCHAR2,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_TYPE_HEADER_ID            in NUMBER,
  X_RULE_WEIGHT               in NUMBER,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2
 ,X_ALLOCATION_MODE_ID        in NUMBER);

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW
  (x_rule_id IN VARCHAR2,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
   );
procedure LOAD_ROW (
   x_rule_id                     IN VARCHAR2,
   x_owner                       IN VARCHAR2,
   x_organization_code           IN VARCHAR2,
   x_type_code                   IN VARCHAR2,
   x_qty_function_parameter_id   IN VARCHAR2,
   x_enabled_flag                IN VARCHAR2,
   x_user_defined_flag           IN VARCHAR2,
   x_type_hdr_id                 IN VARCHAR2,
   x_rule_weight                 IN VARCHAR2,
   X_MIN_PICK_TASKS_FLAG         IN VARCHAR2,
   x_name                        IN VARCHAR2,
   x_description                 in VARCHAR2,
   x_attribute_category          IN VARCHAR2,
   x_attribute1                  IN VARCHAR2,
   x_attribute2                  IN VARCHAR2,
   x_attribute3                  IN VARCHAR2,
   x_attribute4                  IN VARCHAR2,
   x_attribute5                  IN VARCHAR2,
   x_attribute6                  IN VARCHAR2,
   x_attribute7                  IN VARCHAR2,
   x_attribute8                  IN VARCHAR2,
   x_attribute9                  IN VARCHAR2,
   x_attribute10                 IN VARCHAR2,
   x_attribute11                 IN VARCHAR2,
   x_attribute12                 IN VARCHAR2,
   x_attribute13                 IN VARCHAR2,
   x_attribute14                 IN VARCHAR2,
   x_attribute15                 IN VARCHAR2
   ,x_allocation_mode_id         IN NUMBER
   );
--
end WMS_RULES_PKG;

 

/
