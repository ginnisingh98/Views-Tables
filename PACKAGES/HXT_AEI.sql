--------------------------------------------------------
--  DDL for Package HXT_AEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_AEI" AUTHID CURRENT_USER AS
/* $Header: hxtaei.pkh 120.0.12000000.2 2007/03/13 11:38:55 nissharm noship $ */

procedure insert_HXT_ADD_ELEM_INFO(
p_rowid                      IN OUT NOCOPY VARCHAR2,
p_id                         NUMBER,
p_effective_start_date       DATE,
p_effective_end_date         DATE,
p_element_type_id            NUMBER,
p_earning_category           VARCHAR2,
p_absence_type               VARCHAR2,
p_absence_points             NUMBER,
p_points_assigned            NUMBER,
p_premium_type               VARCHAR2,
p_premium_amount             NUMBER,
p_processing_order           NUMBER,
p_expenditure_type           VARCHAR2,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_attribute_category         VARCHAR2,
p_attribute1                 VARCHAR2,
p_attribute2                 VARCHAR2,
p_attribute3                 VARCHAR2,
p_attribute4                 VARCHAR2,
p_attribute5                 VARCHAR2,
p_attribute6                 VARCHAR2,
p_attribute7                 VARCHAR2,
p_attribute8                 VARCHAR2,
p_attribute9                 VARCHAR2,
p_attribute10                VARCHAR2,
p_attribute11                VARCHAR2,
p_attribute12                VARCHAR2,
p_attribute13                VARCHAR2,
p_attribute14                VARCHAR2,
p_attribute15                VARCHAR2,
p_attribute16                VARCHAR2,
p_attribute17                VARCHAR2,
p_attribute18                VARCHAR2,
p_attribute19                VARCHAR2,
p_attribute20                VARCHAR2,
p_attribute21                VARCHAR2,
p_attribute22                VARCHAR2,
p_attribute23                VARCHAR2,
p_attribute24                VARCHAR2,
p_attribute25                VARCHAR2,
p_attribute26                VARCHAR2,
p_attribute27                VARCHAR2,
p_attribute28                VARCHAR2,
p_attribute29                VARCHAR2,
p_attribute30                VARCHAR2,
p_exclude_from_explosion     VARCHAR2 /* Bug: 4489952 */
);

procedure update_HXT_ADD_ELEM_INFO(
p_rowid                      IN VARCHAR2,
p_id                         NUMBER,
p_effective_start_date       DATE,
p_effective_end_date         DATE,
p_element_type_id            NUMBER,
p_earning_category           VARCHAR2,
p_absence_type               VARCHAR2,
p_absence_points             NUMBER,
p_points_assigned            NUMBER,
p_premium_type               VARCHAR2,
p_premium_amount             NUMBER,
p_processing_order           NUMBER,
p_expenditure_type           VARCHAR2,
p_created_by                 NUMBER,
p_creation_date              DATE,
p_last_updated_by            NUMBER,
p_last_update_date           DATE,
p_last_update_login          NUMBER,
p_attribute_category         VARCHAR2,
p_attribute1                 VARCHAR2,
p_attribute2                 VARCHAR2,
p_attribute3                 VARCHAR2,
p_attribute4                 VARCHAR2,
p_attribute5                 VARCHAR2,
p_attribute6                 VARCHAR2,
p_attribute7                 VARCHAR2,
p_attribute8                 VARCHAR2,
p_attribute9                 VARCHAR2,
p_attribute10                VARCHAR2,
p_attribute11                VARCHAR2,
p_attribute12                VARCHAR2,
p_attribute13                VARCHAR2,
p_attribute14                VARCHAR2,
p_attribute15                VARCHAR2,
p_attribute16                VARCHAR2,
p_attribute17                VARCHAR2,
p_attribute18                VARCHAR2,
p_attribute19                VARCHAR2,
p_attribute20                VARCHAR2,
p_attribute21                VARCHAR2,
p_attribute22                VARCHAR2,
p_attribute23                VARCHAR2,
p_attribute24                VARCHAR2,
p_attribute25                VARCHAR2,
p_attribute26                VARCHAR2,
p_attribute27                VARCHAR2,
p_attribute28                VARCHAR2,
p_attribute29                VARCHAR2,
p_attribute30                VARCHAR2,
p_exclude_from_explosion     VARCHAR2 /* Bug: 4489952 */
);

procedure delete_HXT_ADD_ELEM_INFO(p_rowid VARCHAR2);

procedure lock_HXT_ADD_ELEM_INFO(p_rowid VARCHAR2);

END HXT_AEI;

 

/
