--------------------------------------------------------
--  DDL for Package FUN_RULE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_VALIDATE_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULGENVLS.pls 120.1 2006/01/10 12:17:56 ammishra noship $ */
/*---------------------------------------------------------
  -- Component for every entities in Rules module-
  ---------------------------------------------------------*/
PROCEDURE check_existence_rules_object
-- Check if the user customizable object  exists
 (p_rule_object_name     IN     VARCHAR2,
  p_application_id         IN     NUMBER,
  x_return_status      IN OUT NOCOPY VARCHAR2);

procedure check_err(
        x_return_status    IN  VARCHAR2
);

PROCEDURE validate_rule_objects(
  p_create_update_flag                    IN      VARCHAR2,
  p_rule_objects_rec                      IN      FUN_RULE_OBJECTS_PUB.rule_objects_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_rule_object_instance(
  p_create_update_flag                    IN      VARCHAR2,
  p_rule_object_instance_rec              IN      FUN_RULE_OBJECTS_PUB.rule_objects_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_rule_criteria_params(
  p_create_update_flag                    IN      VARCHAR2,
  p_rule_crit_params_rec                  IN      FUN_RULE_CRIT_PARAMS_PUB.rule_crit_params_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_rule_details(
  p_create_update_flag                    IN      VARCHAR2,
  p_rule_details_rec                      IN      FUN_RULE_DETAILS_PUB.rule_details_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_rule_criteria(
  p_create_update_flag                    IN      VARCHAR2,
  p_rule_criteria_rec                     IN      FUN_RULE_CRITERIA_PUB.rule_criteria_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
 );

/*
PROCEDURE validate_rich_messages(
  p_create_update_flag                    IN      VARCHAR2,
  p_rich_messages_rec                     IN      FUN_RICH_MESSAGES_PUB.rich_messages_rec_type,
  p_rowid                                 IN      ROWID ,
  x_return_status                         IN OUT NOCOPY  VARCHAR2
);
*/

 PROCEDURE validate_mandatory (
      p_create_update_flag                    IN     VARCHAR2,
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     DATE,
      p_restricted                            IN     VARCHAR2 DEFAULT 'N',
      x_return_status                         IN OUT NOCOPY VARCHAR2
 );

 PROCEDURE validate_mandatory (
      p_create_update_flag                    IN     VARCHAR2,
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     NUMBER,
      p_restricted                            IN     VARCHAR2 DEFAULT 'N',
      x_return_status                         IN OUT NOCOPY VARCHAR2
 );

 PROCEDURE validate_mandatory (
       p_create_update_flag                    IN     VARCHAR2,
       p_column                                IN     VARCHAR2,
       p_column_value                          IN     VARCHAR2,
       p_restricted                            IN     VARCHAR2 DEFAULT 'N',
       x_return_status                         IN OUT NOCOPY VARCHAR2
 );



 PROCEDURE validate_nonupdateable (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      p_old_column_value                      IN     VARCHAR2,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 );

  PROCEDURE validate_nonupdateable_atall (
      p_column                                IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      p_old_column_value                      IN     VARCHAR2,
      p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
      x_return_status                         IN     OUT NOCOPY VARCHAR2,
      p_raise_error                           IN     VARCHAR2 := 'Y'
 );

 PROCEDURE validate_lookup (
      p_column                                IN     VARCHAR2,
      p_lookup_table                          IN     VARCHAR2 DEFAULT 'FND_LOOKUP_VALUES',
      p_lookup_type                           IN     VARCHAR2,
      p_column_value                          IN     VARCHAR2,
      x_return_status                         IN OUT NOCOPY VARCHAR2
 );



PROCEDURE validate_rich_messages(
     p_create_update_flag                    IN      VARCHAR2,
     p_rich_messages_rec                     IN      FUN_RICH_MESSAGES_PUB.rich_messages_rec_type,
     p_rowid                                 IN      ROWID ,
     x_return_status                         IN OUT NOCOPY  VARCHAR2
);

FUNCTION isFlexFieldValid(p_FlexFieldName IN VARCHAR2,
                            p_FlexFieldAppShortName IN VARCHAR2) RETURN BOOLEAN;

FUNCTION validate_org_id (
        p_org_id  IN    NUMBER) RETURN BOOLEAN;

FUNCTION validate_application_id (
        p_application_id  IN    NUMBER) RETURN BOOLEAN;

FUNCTION validate_flex_value_set_id (
        p_flex_value_set_id  IN    NUMBER) RETURN BOOLEAN;

END FUN_RULE_VALIDATE_PKG;

 

/
