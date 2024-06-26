--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMP_GROUP_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMP_GROUP_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfctkgs.pls 115.6 2002/12/05 23:29:50 sachoudh ship $ */


G_PKG_NAME      CONSTANT        VARCHAR2(30):='JTF_TASK_TEMP_GROUP_CUHK';

Procedure  CREATE_TASK_TEMPLATE_GROUP_pre
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

Procedure  CREATE_TASK_TEMPLATE_GROUP_pst
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

Procedure  update_TASK_TEMPLATE_GROUP_pre
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

Procedure  update_TASK_TEMPLATE_GROUP_pst
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

Procedure  delete_TASK_TEMPLATE_GROUP_pre
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

Procedure  delete_TASK_TEMPLATE_GROUP_pst
  (
  p_TEMPLATE_GROUP          in JTF_TASK_TEMP_GROUP_pub.TASK_TEMPLATE_GROUP_REC,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2
  );

END ;

 

/
