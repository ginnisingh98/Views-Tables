--------------------------------------------------------
--  DDL for Package Body FND_EID_PRECEDENCE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_PRECEDENCE_RULES_PKG" as
/* $Header: fndeidprerulb.pls 120.0.12010000.3 2012/10/09 01:36:08 rnagaraj noship $ */

PROCEDURE load_row (
      X_EID_INSTANCE_ID                IN VARCHAR2,
      X_EID_INSTANCE_PRECEDENCE_RULE   IN VARCHAR2,
      X_TRIGGER_INSTANCE_ATTRIBUTE     IN VARCHAR2,
      X_TARGET_INSTANCE_ATTRIBUTE      IN VARCHAR2,
      X_TRIGGER_ATTR_VALUE             IN VARCHAR2,
      X_LEAF_TRIGGER_FLAG              IN VARCHAR2,
      X_EID_RELEASE_VERSION            IN VARCHAR2,
      X_OBSOLETED_FLAG                 IN VARCHAR2,
      X_OBSOLETED_EID_REL_VER          IN VARCHAR2,
      X_LAST_UPDATE_DATE               IN VARCHAR2,
      X_APPLICATION_SHORT_NAME         IN VARCHAR2,
      X_OWNER                          IN VARCHAR2
     ) IS

   user_id NUMBER;

BEGIN

   IF ( x_owner IS NOT NULL ) THEN
     user_id := fnd_load_util.owner_id(x_owner);
   ELSE
     user_id := -1;
   END IF;

   IF ( user_id > 0 ) THEN

      MERGE INTO FND_EID_PRECEDENCE_RULES d USING
         ( SELECT
             X_EID_INSTANCE_ID               AS EID_INSTANCE_ID,
             X_EID_INSTANCE_PRECEDENCE_RULE  AS EID_INSTANCE_PRECEDENCE_RULE,
             X_TRIGGER_INSTANCE_ATTRIBUTE    AS TRIGGER_INSTANCE_ATTRIBUTE,
             X_TARGET_INSTANCE_ATTRIBUTE     AS TARGET_INSTANCE_ATTRIBUTE,
             X_TRIGGER_ATTR_VALUE            AS TRIGGER_ATTR_VALUE,
             X_LEAF_TRIGGER_FLAG             AS LEAF_TRIGGER_FLAG,
             X_EID_RELEASE_VERSION           AS EID_RELEASE_VERSION,
             X_OBSOLETED_FLAG                AS OBSOLETED_FLAG,
             X_OBSOLETED_EID_REL_VER         AS OBSOLETED_EID_RELEASE_VERSION,
             X_LAST_UPDATE_DATE              AS LAST_UPDATE_DATE,
             X_OWNER                         AS LAST_UPDATED_BY
              FROM DUAL
          ) s
          ON ( d.eid_instance_id = s.eid_instance_id AND
               d.eid_instance_precedence_rule = s.eid_instance_precedence_rule)
      WHEN MATCHED THEN
         UPDATE SET
             d.TRIGGER_INSTANCE_ATTRIBUTE    = s.TRIGGER_INSTANCE_ATTRIBUTE,
             d.TARGET_INSTANCE_ATTRIBUTE     = s.TARGET_INSTANCE_ATTRIBUTE,
             d.TRIGGER_ATTR_VALUE            = s.TRIGGER_ATTR_VALUE,
             d.LEAF_TRIGGER_FLAG             = s.LEAF_TRIGGER_FLAG,
             d.EID_RELEASE_VERSION           = s.EID_RELEASE_VERSION,
             d.OBSOLETED_FLAG                = s.OBSOLETED_FLAG,
             d.OBSOLETED_EID_RELEASE_VERSION = s.OBSOLETED_EID_RELEASE_VERSION,
             d.LAST_UPDATE_DATE              = TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD'),
             d.LAST_UPDATED_BY               = user_id
       WHEN NOT MATCHED THEN
         INSERT (
             d.EID_INSTANCE_ID ,
             d.EID_INSTANCE_PRECEDENCE_RULE,
             d.TRIGGER_INSTANCE_ATTRIBUTE,
             d.TARGET_INSTANCE_ATTRIBUTE,
             d.TRIGGER_ATTR_VALUE,
             d.LEAF_TRIGGER_FLAG,
             d.EID_RELEASE_VERSION,
             d.OBSOLETED_FLAG,
             d.OBSOLETED_EID_RELEASE_VERSION,
             d.CREATED_BY,
             d.CREATION_DATE,
             d.LAST_UPDATED_BY,
             d.LAST_UPDATE_DATE
             )
         VALUES  (
             TO_NUMBER(s.EID_INSTANCE_ID) ,
             s.EID_INSTANCE_PRECEDENCE_RULE,
             s.TRIGGER_INSTANCE_ATTRIBUTE,
             s.TARGET_INSTANCE_ATTRIBUTE,
             s.TRIGGER_ATTR_VALUE,
             s.LEAF_TRIGGER_FLAG,
             s.EID_RELEASE_VERSION,
             s.OBSOLETED_FLAG,
             s.OBSOLETED_EID_RELEASE_VERSION,
             user_id,
             TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD'),
             user_id,
             TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')
             );
  END IF;

END load_row;

END FND_EID_PRECEDENCE_RULES_PKG;

/
