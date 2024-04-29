--------------------------------------------------------
--  DDL for Package PER_KR_GRADE_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_GRADE_AMOUNT_PKG" AUTHID CURRENT_USER AS
/* $Header: pekrsg02.pkh 115.1 2002/12/03 09:35:29 viagarwa noship $ */
-------------------------------------------------------------------------------------
PROCEDURE insert_row
(p_row_id          IN OUT NOCOPY VARCHAR2
,p_grade_amount_id IN OUT NOCOPY NUMBER
,p_effective_start_date   DATE
,p_effective_end_date     DATE
,p_grade_id               NUMBER
,p_grade_amount           NUMBER
,p_object_version_number  NUMBER
,p_last_update_date       DATE
,p_last_updated_by        NUMBER
,p_last_update_login      NUMBER
,p_created_by             NUMBER
,p_creation_date          DATE
,p_attribute_category     VARCHAR2
,p_attribute1             VARCHAR2
,p_attribute2             VARCHAR2
,p_attribute3             VARCHAR2
,p_attribute4             VARCHAR2
,p_attribute5             VARCHAR2
,p_attribute6             VARCHAR2
,p_attribute7             VARCHAR2
,p_attribute8             VARCHAR2
,p_attribute9             VARCHAR2
,p_attribute10            VARCHAR2
,p_attribute11            VARCHAR2
,p_attribute12            VARCHAR2
,p_attribute13            VARCHAR2
,p_attribute14            VARCHAR2
,p_attribute15            VARCHAR2
,p_attribute16            VARCHAR2
,p_attribute17            VARCHAR2
,p_attribute18            VARCHAR2
,p_attribute19            VARCHAR2
,p_attribute20            VARCHAR2
,p_attribute21            VARCHAR2
,p_attribute22            VARCHAR2
,p_attribute23            VARCHAR2
,p_attribute24            VARCHAR2
,p_attribute25            VARCHAR2
,p_attribute26            VARCHAR2
,p_attribute27            VARCHAR2
,p_attribute28            VARCHAR2
,p_attribute29            VARCHAR2
,p_attribute30            VARCHAR2
);
-------------------------------------------------------------------------------------
PROCEDURE lock_row
(p_row_id                VARCHAR2
,p_grade_amount_id       NUMBER
,p_effective_start_date  DATE
,p_effective_end_date    DATE
,p_grade_id              NUMBER
,p_grade_amount          NUMBER
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
,p_attribute_category    VARCHAR2
,p_attribute1            VARCHAR2
,p_attribute2            VARCHAR2
,p_attribute3            VARCHAR2
,p_attribute4            VARCHAR2
,p_attribute5            VARCHAR2
,p_attribute6            VARCHAR2
,p_attribute7            VARCHAR2
,p_attribute8            VARCHAR2
,p_attribute9            VARCHAR2
,p_attribute10           VARCHAR2
,p_attribute11           VARCHAR2
,p_attribute12           VARCHAR2
,p_attribute13           VARCHAR2
,p_attribute14           VARCHAR2
,p_attribute15           VARCHAR2
,p_attribute16           VARCHAR2
,p_attribute17           VARCHAR2
,p_attribute18           VARCHAR2
,p_attribute19           VARCHAR2
,p_attribute20           VARCHAR2
,p_attribute21           VARCHAR2
,p_attribute22           VARCHAR2
,p_attribute23           VARCHAR2
,p_attribute24           VARCHAR2
,p_attribute25           VARCHAR2
,p_attribute26           VARCHAR2
,p_attribute27           VARCHAR2
,p_attribute28           VARCHAR2
,p_attribute29           VARCHAR2
,p_attribute30           VARCHAR2
);
-------------------------------------------------------------------------------------
PROCEDURE update_row
(p_row_id                VARCHAR2
,p_grade_amount_id       NUMBER
,p_effective_start_date  DATE
,p_effective_end_date    DATE
,p_grade_id              NUMBER
,p_grade_amount          NUMBER
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
,p_attribute_category    VARCHAR2
,p_attribute1            VARCHAR2
,p_attribute2            VARCHAR2
,p_attribute3            VARCHAR2
,p_attribute4            VARCHAR2
,p_attribute5            VARCHAR2
,p_attribute6            VARCHAR2
,p_attribute7            VARCHAR2
,p_attribute8            VARCHAR2
,p_attribute9            VARCHAR2
,p_attribute10           VARCHAR2
,p_attribute11           VARCHAR2
,p_attribute12           VARCHAR2
,p_attribute13           VARCHAR2
,p_attribute14           VARCHAR2
,p_attribute15           VARCHAR2
,p_attribute16           VARCHAR2
,p_attribute17           VARCHAR2
,p_attribute18           VARCHAR2
,p_attribute19           VARCHAR2
,p_attribute20           VARCHAR2
,p_attribute21           VARCHAR2
,p_attribute22           VARCHAR2
,p_attribute23           VARCHAR2
,p_attribute24           VARCHAR2
,p_attribute25           VARCHAR2
,p_attribute26           VARCHAR2
,p_attribute27           VARCHAR2
,p_attribute28           VARCHAR2
,p_attribute29           VARCHAR2
,p_attribute30           VARCHAR2
);
-------------------------------------------------------------------------------------
PROCEDURE delete_row
(p_row_id VARCHAR2
);
END per_kr_grade_amount_pkg;

 

/
