--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_UNIT_PKG" AUTHID CURRENT_USER as
/* $Header: EAMTCUS.pls 120.0.12010000.1 2008/11/12 10:00:52 dsingire noship $ */

PROCEDURE Insert_CU_Row(
      px_cu_id		  IN OUT      NOCOPY  NUMBER
     ,p_cu_name		  IN          VARCHAR2
     ,p_description	  IN          VARCHAR2
     ,p_organization_id	  IN          NUMBER
     ,p_cu_effective_from IN          DATE
     ,p_cu_effective_to   IN          DATE
     ,p_attribute_category  IN        VARCHAR2
     ,p_attribute1        IN          VARCHAR2
     ,p_attribute2        IN          VARCHAR2
     ,p_attribute3        IN          VARCHAR2
     ,p_attribute4        IN          VARCHAR2
     ,p_attribute5        IN          VARCHAR2
     ,p_attribute6        IN          VARCHAR2
     ,p_attribute7        IN          VARCHAR2
     ,p_attribute8        IN          VARCHAR2
     ,p_attribute9        IN          VARCHAR2
     ,p_attribute10       IN          VARCHAR2
     ,p_attribute11       IN          VARCHAR2
     ,p_attribute12       IN          VARCHAR2
     ,p_attribute13       IN          VARCHAR2
     ,p_attribute14       IN          VARCHAR2
     ,p_attribute15       IN          VARCHAR2
     ,p_creation_date     IN          DATE
     ,p_created_by        IN          NUMBER
     ,p_last_update_date  IN          DATE
     ,p_last_updated_by   IN          NUMBER
     ,p_last_update_login IN          NUMBER

      );

PROCEDURE Update_CU_Row(
      p_cu_id		  IN          NUMBER
     ,p_cu_name		  IN          VARCHAR2
     ,p_description	  IN          VARCHAR2
     ,p_organization_id	  IN          NUMBER
     ,p_cu_effective_from IN          DATE
     ,p_cu_effective_to   IN          DATE
     ,p_attribute_category  IN        VARCHAR2
     ,p_attribute1        IN          VARCHAR2
     ,p_attribute2        IN          VARCHAR2
     ,p_attribute3        IN          VARCHAR2
     ,p_attribute4        IN          VARCHAR2
     ,p_attribute5        IN          VARCHAR2
     ,p_attribute6        IN          VARCHAR2
     ,p_attribute7        IN          VARCHAR2
     ,p_attribute8        IN          VARCHAR2
     ,p_attribute9        IN          VARCHAR2
     ,p_attribute10       IN          VARCHAR2
     ,p_attribute11       IN          VARCHAR2
     ,p_attribute12       IN          VARCHAR2
     ,p_attribute13       IN          VARCHAR2
     ,p_attribute14       IN          VARCHAR2
     ,p_attribute15       IN          VARCHAR2
     ,p_last_update_date  IN          DATE
     ,p_last_updated_by   IN          NUMBER
     ,p_last_update_login IN          NUMBER

      );


PROCEDURE Insert_CU_Activity_Row(
      px_cu_detail_id		    IN OUT      NOCOPY  NUMBER
     ,p_cu_id			    IN    NUMBER
     ,p_acct_class_code		    IN    VARCHAR2
     ,p_activity_id		    IN    NUMBER
     ,p_cu_activity_qty		    IN    NUMBER
     ,p_cu_activity_effective_from  IN    DATE
     ,p_cu_activity_effective_to    IN    DATE
     ,p_creation_date               IN    DATE
     ,p_created_by                  IN    NUMBER
     ,p_last_update_date            IN    DATE
     ,p_last_updated_by             IN    NUMBER
     ,p_last_update_login           IN    NUMBER
      );

PROCEDURE Update_CU_Activity_Row(
      p_cu_detail_id		    IN    NUMBER
     ,p_cu_id			    IN    NUMBER
     ,p_acct_class_code		    IN    VARCHAR2
     ,p_activity_id		    IN    NUMBER
     ,p_cu_activity_qty		    IN    NUMBER
     ,p_cu_activity_effective_from  IN    DATE
     ,p_cu_activity_effective_to    IN    DATE
     ,p_last_update_date            IN    DATE
     ,p_last_updated_by             IN    NUMBER
     ,p_last_update_login           IN    NUMBER
      );

End EAM_CONSTRUCTION_UNIT_PKG;

/
