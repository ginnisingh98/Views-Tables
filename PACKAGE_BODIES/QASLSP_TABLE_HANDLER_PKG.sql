--------------------------------------------------------
--  DDL for Package Body QASLSP_TABLE_HANDLER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QASLSP_TABLE_HANDLER_PKG" as
/* $Header: qaslspb.plb 115.2 2002/11/27 19:19:15 jezheng ship $ */

PROCEDURE insert_sl_sp_rcv_criteria_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          IN OUT NOCOPY NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_sl_sp_rcv_criteria
               WHERE criteria_id = X_Criteria_id;

   CURSOR C2 IS SELECT qa_sl_sp_criteria_s.nextval FROM dual;

BEGIN


   if (X_Criteria_id is NULL) then
      OPEN C2;
      FETCH C2 INTO X_Criteria_id;
      CLOSE C2;
   end if;

   INSERT INTO QA_SL_SP_RCV_CRITERIA(
      criteria_id,
      organization_id,
      vendor_id,
      vendor_site_id,
      item_id,
      item_Revision,
      item_category_id,
      manufacturer_id,
      project_id,
      task_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Criteria_id,
      X_Organization_id,
      nvl(X_Vendor_id, -1),
      nvl(X_Vendor_Site_id, -1),
      nvl(X_Item_id, -1),
      nvl(X_Item_Revision, '-1'),
      nvl(X_Category_id, -1),
      nvl(X_Manufacturer_id, -1),
      nvl(X_Project_id, -1),
      nvl(X_Task_id, -1),
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login
   );

   --commit;

   OPEN C1;
   FETCH C1 INTO X_Rowid;
   if (C1%NOTFOUND) then
     CLOSE C1;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C1;

END insert_sl_sp_rcv_criteria_row;




PROCEDURE insert_sp_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_sampling_association
               WHERE criteria_id = X_Criteria_id and
		     sampling_plan_id = X_Sampling_Plan_id;

BEGIN

   INSERT INTO QA_SAMPLING_ASSOCIATION(
      criteria_id,
      sampling_plan_id,
      collection_plan_id,
      wf_role_name,
      effective_from,
      effective_to,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Criteria_id,
      X_Sampling_Plan_id,
      nvl(X_Collection_Plan_id, -1),
      X_SP_WF_Role_Name,
      X_SP_Effective_From,
      X_SP_Effective_To,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login
   );

   --commit;

   OPEN C1;
   FETCH C1 INTO X_Rowid;
   if (C1%NOTFOUND) then
     CLOSE C1;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C1;

END insert_sp_association_row;



PROCEDURE insert_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

   CURSOR C1 IS SELECT rowid FROM qa_skiplot_association
               WHERE criteria_id = X_Criteria_id and
		     process_id = X_Process_id;

BEGIN

   INSERT INTO QA_SKIPLOT_ASSOCIATION(
      criteria_id,
      process_id,
      effective_from,
      effective_to,
      lotsize_from,
      lotsize_to,
      wf_role_name,
      insp_stage,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
   )
   values(
      X_Criteria_id,
      X_Process_id,
      X_SL_Effective_From,
      X_SL_Effective_To,
      X_Lotsize_From,
      X_Lotsize_To,
      X_SL_WF_Role_Name,
      X_Insp_Stage,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login
   );

   --commit;

   OPEN C1;
   FETCH C1 INTO X_Rowid;
   if (C1%NOTFOUND) then
     CLOSE C1;
     Raise NO_DATA_FOUND;
   end if;
   CLOSE C1;

END insert_sl_association_row;




PROCEDURE update_sl_sp_rcv_criteria_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

   UPDATE QA_SL_SP_RCV_CRITERIA
   SET
      criteria_id                =       X_Criteria_id,
      organization_id            =       X_Organization_id,
      vendor_id                  =       nvl(X_Vendor_id, -1),
      vendor_Site_id             =       nvl(X_Vendor_Site_id, -1),
      item_id                    =       nvl(X_Item_id, -1),
      item_Revision              =       nvl(X_Item_Revision, '-1'),
      item_category_id           =       nvl(X_Category_id, -1),
      manufacturer_id            =       nvl(X_Manufacturer_id, -1),
      project_id                 =       nvl(X_Project_id, -1),
      task_id                    =       nvl(X_Task_id, -1),
      last_update_date           =       X_Last_Update_Date,
      last_updated_by            =       X_Last_Updated_By,
      creation_date              =       X_Creation_Date,
      created_by                 =       X_Created_By,
      last_update_login          =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_sl_sp_rcv_criteria_row;




PROCEDURE update_sp_association_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

   UPDATE QA_SAMPLING_ASSOCIATION
   SET
      criteria_id                =       X_Criteria_id,
      sampling_plan_id           =       X_Sampling_Plan_id,
      collection_plan_id         =       nvl(X_Collection_Plan_id, -1),
      wf_role_name               =       X_SP_WF_Role_Name,
      effective_from             =       X_SP_Effective_From,
      effective_to               =       X_SP_Effective_To,
      last_update_date           =       X_Last_Update_Date,
      last_updated_by            =       X_Last_Updated_By,
      creation_date              =       X_Creation_Date,
      created_by                 =       X_Created_By,
      last_update_login          =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_sp_association_row;



PROCEDURE update_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

BEGIN

   UPDATE QA_SKIPLOT_ASSOCIATION
   SET
      criteria_id               =       X_Criteria_id,
      process_id                =       X_Process_id,
      effective_from            =       X_SL_Effective_From,
      effective_to              =       X_SL_Effective_To,
      lotsize_from              =       X_Lotsize_From,
      lotsize_to                =       X_Lotsize_To,
      wf_role_name              =       X_SL_WF_Role_Name,
      insp_stage                =       X_Insp_Stage,
      last_update_date          =       X_Last_Update_Date,
      last_updated_by           =       X_Last_Updated_By,
      creation_date             =       X_Creation_Date,
      created_by                =       X_Created_By,
      last_update_login         =       X_Last_Update_Login
   WHERE rowid = X_Rowid;

   --commit;

   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
   end if;

END update_sl_association_row;




PROCEDURE lock_sl_sp_rcv_criteria_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Organization_id      NUMBER,
      X_Vendor_id            NUMBER       DEFAULT -1,
      X_Vendor_Site_id       NUMBER       DEFAULT -1,
      X_Item_id              NUMBER       DEFAULT -1,
      X_Item_Revision        VARCHAR2     DEFAULT '-1',
      X_Category_id          NUMBER       DEFAULT -1,
      X_Manufacturer_id      NUMBER       DEFAULT -1,
      X_Project_id           NUMBER       DEFAULT -1,
      X_Task_id              NUMBER       DEFAULT -1,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SL_SP_RCV_CRITERIA
     WHERE  rowid = X_Rowid
     FOR UPDATE of criteria_id NOWAIT;

     Recinfo C%ROWTYPE;


BEGIN

  OPEN C;
  FETCH C INTO Recinfo;

  if (C%NOTFOUND) then
     CLOSE C;
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
  end if;

  CLOSE C;

  if (
      (Recinfo.criteria_id =  X_Criteria_id)
       AND (Recinfo.organization_id =  X_Organization_id)
       AND (Recinfo.vendor_id =  nvl(X_Vendor_id, -1))
       AND (Recinfo.vendor_site_id =  nvl(X_Vendor_Site_id, -1))
       AND (Recinfo.item_id =  nvl(X_Item_id, -1))
       AND (Recinfo.item_revision =  nvl(X_Item_Revision, '-1'))
       AND (Recinfo.item_category_id =  nvl(X_Category_id, -1))
       AND (Recinfo.manufacturer_id =  nvl(X_Manufacturer_id, -1))
       AND (Recinfo.project_id =  nvl(X_Project_id, -1))
       AND (Recinfo.task_id =  nvl(X_Task_id, -1))
       AND (Recinfo.last_update_date =  X_Last_Update_Date)
       AND (Recinfo.last_updated_by =  X_Last_Updated_By)
       AND (Recinfo.creation_date =  X_Creation_Date)
       AND (Recinfo.created_by =  X_Created_By)
       AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
               OR (    (Recinfo.last_update_login IS NULL)
                        AND (X_Last_Update_Login IS NULL)))

  ) then

    return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

END lock_sl_sp_rcv_criteria_row;




PROCEDURE lock_sp_association_row(
      X_Rowid                VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Sampling_Plan_id     NUMBER,
      X_Collection_Plan_id   NUMBER       DEFAULT -1,
      X_SP_WF_Role_Name      VARCHAR2,
      X_SP_Effective_From    DATE,
      X_SP_Effective_To      DATE,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SAMPLING_ASSOCIATION
     WHERE  rowid = X_Rowid
     FOR UPDATE of criteria_id NOWAIT;

     Recinfo C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO Recinfo;

  if (C%NOTFOUND) then
     CLOSE C;
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
  end if;

  CLOSE C;

  if (
       (Recinfo.criteria_id =  X_Criteria_id)
       AND (Recinfo.sampling_plan_id =  X_Sampling_Plan_id)
       AND (Recinfo.collection_plan_id =  X_Collection_Plan_id)
       AND (   (Recinfo.wf_role_name =  X_SP_WF_Role_Name)
               OR (    (Recinfo.wf_role_name IS NULL)
                        AND (X_SP_WF_Role_Name IS NULL)))
       AND (   (Recinfo.effective_from =  X_SP_Effective_From)
               OR (    (Recinfo.effective_from IS NULL)
                        AND (X_SP_Effective_From IS NULL)))
       AND (   (Recinfo.effective_to =  X_SP_Effective_To)
               OR (    (Recinfo.effective_to IS NULL)
                        AND (X_SP_Effective_To IS NULL)))
       AND (Recinfo.last_update_date =  X_Last_Update_Date)
       AND (Recinfo.last_updated_by =  X_Last_Updated_By)
       AND (Recinfo.creation_date =  X_Creation_Date)
       AND (Recinfo.created_by =  X_Created_By)
       AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
               OR (    (Recinfo.last_update_login IS NULL)
                        AND (X_Last_Update_Login IS NULL)))

  ) then
    null;
   -- return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

END lock_sp_association_row;



PROCEDURE lock_sl_association_row(
      X_Rowid                IN OUT NOCOPY VARCHAR2,
      X_Criteria_id          NUMBER,
      X_Process_id           NUMBER,
      X_SL_WF_Role_Name      VARCHAR2,
      X_SL_Effective_From    DATE,
      X_SL_Effective_To      DATE,
      X_Lotsize_From         NUMBER,
      X_Lotsize_To           NUMBER,
      X_Insp_Stage           VARCHAR2,
      X_Last_Update_Date     DATE,
      X_Last_Updated_By      NUMBER,
      X_Creation_Date        DATE,
      X_Created_By           NUMBER,
      X_Last_Update_Login    NUMBER
) IS

  CURSOR C IS
     SELECT *
     FROM   QA_SKIPLOT_ASSOCIATION
     WHERE  rowid = X_Rowid
     FOR UPDATE of criteria_id NOWAIT;

     Recinfo C%ROWTYPE;


BEGIN

  OPEN C;
  FETCH C INTO Recinfo;

  if (C%NOTFOUND) then
     CLOSE C;
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
     APP_EXCEPTION.Raise_Exception;
  end if;

  CLOSE C;

  if (
       (Recinfo.criteria_id =  X_Criteria_id)
       AND (Recinfo.process_id =  X_Process_id)
       AND (   (Recinfo.effective_from =  X_SL_Effective_From)
               OR (    (Recinfo.effective_from IS NULL)
                        AND (X_SL_Effective_From IS NULL)))
       AND (   (Recinfo.effective_to =  X_SL_Effective_To)
               OR (    (Recinfo.effective_to IS NULL)
                        AND (X_SL_Effective_To IS NULL)))
       AND (   (Recinfo.lotsize_from =  X_Lotsize_From)
               OR (    (Recinfo.lotsize_from IS NULL)
                        AND (X_Lotsize_From IS NULL)))
       AND (   (Recinfo.lotsize_to =  X_Lotsize_To)
               OR (    (Recinfo.lotsize_to IS NULL)
                        AND (X_Lotsize_To IS NULL)))
       AND (Recinfo.insp_stage =  X_Insp_Stage)
       AND (Recinfo.last_update_date =  X_Last_Update_Date)
       AND (Recinfo.last_updated_by =  X_Last_Updated_By)
       AND (Recinfo.creation_date =  X_Creation_Date)
       AND (Recinfo.created_by =  X_Created_By)
       AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
               OR (    (Recinfo.last_update_login IS NULL)
                        AND (X_Last_Update_Login IS NULL)))

  ) then

    return;

  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;

  end if;

END lock_sl_association_row;




PROCEDURE delete_sl_sp_rcv_criteria_row(X_Rowid VARCHAR2) IS

BEGIN

  delete from QA_SL_SP_RCV_CRITERIA
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_sl_sp_rcv_criteria_row;





PROCEDURE delete_sp_association_row(X_Rowid VARCHAR2) IS

BEGIN
  delete from QA_SAMPLING_ASSOCIATION
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_sp_association_row;




PROCEDURE delete_sl_association_row(X_Rowid VARCHAR2) IS

BEGIN

  delete from QA_SKIPLOT_ASSOCIATION
  where rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND;
  end if;

END delete_sl_association_row;




END QASLSP_TABLE_HANDLER_PKG;

/
