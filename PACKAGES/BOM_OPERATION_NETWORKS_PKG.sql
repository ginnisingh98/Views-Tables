--------------------------------------------------------
--  DDL for Package BOM_OPERATION_NETWORKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OPERATION_NETWORKS_PKG" AUTHID CURRENT_USER as
/* $Header: BOMOPNWS.pls 115.0 99/07/16 05:14:39 porting ship $ */
  PROCEDURE INSERT_ROW(X_ROW_ID IN OUT VARCHAR2,
              x_from_op_seq_id         NUMBER,
              x_to_op_seq_id           NUMBER,
              x_transition_type        NUMBER,
              x_planning_pct           NUMBER,
              x_last_updated_by        NUMBER,
              x_creation_date          DATE,
              x_last_update_date       DATE,
              x_created_by             NUMBER,
              x_last_update_login      NUMBER,
              x_attribute_category     VARCHAR2,
              x_attribute1             VARCHAR2,
              x_attribute2             VARCHAR2,
              x_attribute3             VARCHAR2,
              x_attribute4             VARCHAR2,
              x_attribute5             VARCHAR2,
              x_attribute6             VARCHAR2,
              x_attribute7             VARCHAR2,
              x_attribute8             VARCHAR2,
              x_attribute9             VARCHAR2,
              x_attribute10            VARCHAR2,
              x_attribute11            VARCHAR2,
              x_attribute12            VARCHAR2,
              x_attribute13            VARCHAR2,
              x_attribute14            VARCHAR2,
              x_attribute15            VARCHAR2
         );

  PROCEDURE Lock_Row(X_ROW_ID    VARCHAR2,
              x_from_op_seq_id     NUMBER,
              x_to_op_seq_id       NUMBER,
              x_transition_type    NUMBER,
              x_planning_pct       NUMBER,
              x_effectivity_date   DATE,
              x_disable_date       DATE,
              x_last_updated_by    NUMBER,
              x_creation_date      DATE,
              x_last_update_date   DATE,
              x_created_by         NUMBER,
              x_last_update_login  NUMBER,
              x_attribute_category VARCHAR2,
              x_attribute1         VARCHAR2,
              x_attribute2         VARCHAR2,
              x_attribute3         VARCHAR2,
              x_attribute4         VARCHAR2,
              x_attribute5         VARCHAR2,
              x_attribute6         VARCHAR2,
              x_attribute7         VARCHAR2,
              x_attribute8         VARCHAR2,
              x_attribute9         VARCHAR2,
              x_attribute10         VARCHAR2,
              x_attribute11         VARCHAR2,
              x_attribute12         VARCHAR2,
              x_attribute13         VARCHAR2,
              x_attribute14         VARCHAR2,
              x_attribute15         VARCHAR2
         );

  PROCEDURE Update_Row(X_ROW_ID    VARCHAR2,
              x_from_op_seq_id     NUMBER,
              x_to_op_seq_id       NUMBER,
              x_transition_type    NUMBER,
              x_planning_pct       NUMBER,
              x_effectivity_date   DATE,
              x_disable_date       DATE,
              x_last_updated_by    NUMBER,
              x_creation_date      DATE,
              x_last_update_date   DATE,
              x_created_by         NUMBER,
              x_last_update_login  NUMBER,
              x_attribute_category VARCHAR2,
              x_attribute1         VARCHAR2,
              x_attribute2         VARCHAR2,
              x_attribute3         VARCHAR2,
              x_attribute4         VARCHAR2,
              x_attribute5         VARCHAR2,
              x_attribute6         VARCHAR2,
              x_attribute7         VARCHAR2,
              x_attribute8         VARCHAR2,
              x_attribute9         VARCHAR2,
              x_attribute10         VARCHAR2,
              x_attribute11         VARCHAR2,
              x_attribute12         VARCHAR2,
              x_attribute13         VARCHAR2,
              x_attribute14         VARCHAR2,
              x_attribute15         VARCHAR2
         );

     PROCEDURE Delete_Row(X_Rowid VARCHAR2);

     PROCEDURE CHECK_UNIQUE_LINK(X_ROWID VARCHAR2,
                                 X_FROM_OP_SEQ_ID NUMBER,
                                 X_TO_OP_SEQ_ID NUMBER);
END BOM_OPERATION_NETWORKS_PKG;

 

/
