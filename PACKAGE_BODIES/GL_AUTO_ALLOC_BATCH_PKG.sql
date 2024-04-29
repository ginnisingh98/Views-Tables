--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_BATCH_PKG" AS
/* $Header: glatalbb.pls 120.3 2005/05/05 02:02:08 kvora ship $ */
SUCCESS CONSTANT VARCHAR2(1) := 'S';
FAILURE CONSTANT VARCHAR2(1) := 'F';

Procedure Insert_Allocation_Batch(
  l_Row_Id                      IN OUT NOCOPY VARCHAR2
, l_ALLOCATION_SET_ID           IN NUMBER
, l_BATCH_ID                    IN NUMBER
, l_BATCH_TYPE_CODE             IN VARCHAR2
, l_LAST_UPDATE_DATE            IN DATE
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_CREATION_DATE               IN DATE
, l_CREATED_BY                  IN NUMBER
, l_STEP_NUMBER                 IN NUMBER
, l_OWNER                       IN VARCHAR2
, l_ALLOCATION_METHOD_CODE      IN VARCHAR2
, l_ATTRIBUTE1                  IN VARCHAR2
, l_ATTRIBUTE2                  IN VARCHAR2
, l_ATTRIBUTE3                  IN VARCHAR2
, l_ATTRIBUTE4                  IN VARCHAR2
, l_ATTRIBUTE5                  IN VARCHAR2
, l_ATTRIBUTE6                  IN VARCHAR2
, l_ATTRIBUTE7                  IN VARCHAR2
, l_ATTRIBUTE8                  IN VARCHAR2
, l_ATTRIBUTE9                  IN VARCHAR2
, l_ATTRIBUTE10                 IN VARCHAR2
, l_ATTRIBUTE11                 IN VARCHAR2
, l_ATTRIBUTE12                 IN VARCHAR2
, l_ATTRIBUTE13                 IN VARCHAR2
, l_ATTRIBUTE14                 IN VARCHAR2
, l_ATTRIBUTE15                 IN VARCHAR2
, l_CONTEXT                     IN VARCHAR2
)  IS

   CURSOR C IS
   SELECT rowid
   FROM  GL_AUTO_ALLOC_BATCHES
   WHERE ALLOCATION_SET_ID = l_ALLOCATION_SET_ID
   AND   BATCH_ID          = l_BATCH_ID
   And   BATCH_TYPE_CODE   = l_BATCH_TYPE_CODE;

Begin
  Insert Into GL_AUTO_ALLOC_BATCHES
  (
  ALLOCATION_SET_ID
, BATCH_ID
, BATCH_TYPE_CODE
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, CREATION_DATE
, CREATED_BY
, STEP_NUMBER
, OWNER
, ALLOCATION_METHOD_CODE
, ATTRIBUTE1
, ATTRIBUTE2
, ATTRIBUTE3
, ATTRIBUTE4
, ATTRIBUTE5
, ATTRIBUTE6
, ATTRIBUTE7
, ATTRIBUTE8
, ATTRIBUTE9
, ATTRIBUTE10
, ATTRIBUTE11
, ATTRIBUTE12
, ATTRIBUTE13
, ATTRIBUTE14
, ATTRIBUTE15
, CONTEXT
)
Values(
  l_ALLOCATION_SET_ID
, l_BATCH_ID
, l_BATCH_TYPE_CODE
, l_LAST_UPDATE_DATE
, l_LAST_UPDATED_BY
, l_LAST_UPDATE_LOGIN
, l_CREATION_DATE
, l_CREATED_BY
, l_STEP_NUMBER
, l_OWNER
, l_ALLOCATION_METHOD_CODE
, l_ATTRIBUTE1
, l_ATTRIBUTE2
, l_ATTRIBUTE3
, l_ATTRIBUTE4
, l_ATTRIBUTE5
, l_ATTRIBUTE6
, l_ATTRIBUTE7
, l_ATTRIBUTE8
, l_ATTRIBUTE9
, l_ATTRIBUTE10
, l_ATTRIBUTE11
, l_ATTRIBUTE12
, l_ATTRIBUTE13
, l_ATTRIBUTE14
, l_ATTRIBUTE15
, l_CONTEXT
 );
    OPEN C;
    FETCH C INTO l_Row_id ;
    If (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    End If;
    CLOSE C;
End Insert_Allocation_Batch;

Procedure Update_Allocation_Batch(
  l_Row_Id                      IN VARCHAR2
, l_BATCH_ID                    IN NUMBER
, l_BATCH_TYPE_CODE             IN VARCHAR2
, l_LAST_UPDATE_DATE            IN DATE
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_STEP_NUMBER                 IN NUMBER
, l_OWNER                       IN VARCHAR2
, l_ALLOCATION_METHOD_CODE      IN VARCHAR2
, l_ATTRIBUTE1                  IN VARCHAR2
, l_ATTRIBUTE2                  IN VARCHAR2
, l_ATTRIBUTE3                  IN VARCHAR2
, l_ATTRIBUTE4                  IN VARCHAR2
, l_ATTRIBUTE5                  IN VARCHAR2
, l_ATTRIBUTE6                  IN VARCHAR2
, l_ATTRIBUTE7                  IN VARCHAR2
, l_ATTRIBUTE8                  IN VARCHAR2
, l_ATTRIBUTE9                  IN VARCHAR2
, l_ATTRIBUTE10                 IN VARCHAR2
, l_ATTRIBUTE11                 IN VARCHAR2
, l_ATTRIBUTE12                 IN VARCHAR2
, l_ATTRIBUTE13                 IN VARCHAR2
, l_ATTRIBUTE14                 IN VARCHAR2
, l_ATTRIBUTE15                 IN VARCHAR2
, l_CONTEXT                     IN VARCHAR2
) IS
Begin
  Update GL_AUTO_ALLOC_BATCHES
  Set
   Batch_id = l_BATCH_ID
 , BATCH_TYPE_CODE = l_BATCH_TYPE_CODE
 , STEP_NUMBER     = l_STEP_NUMBER
 , OWNER           = l_OWNER
 , ALLOCATION_METHOD_CODE = l_ALLOCATION_METHOD_CODE
 , LAST_UPDATE_DATE  = l_LAST_UPDATE_DATE
 , LAST_UPDATED_BY  = l_LAST_UPDATED_BY
 , LAST_UPDATE_LOGIN = l_LAST_UPDATE_LOGIN
 , ATTRIBUTE1 = l_ATTRIBUTE1
 , ATTRIBUTE2 = l_ATTRIBUTE2
 , ATTRIBUTE3 = l_ATTRIBUTE3
 , ATTRIBUTE4 = l_ATTRIBUTE4
 , ATTRIBUTE5 = l_ATTRIBUTE5
 , ATTRIBUTE6 = l_ATTRIBUTE6
 , ATTRIBUTE7 = l_ATTRIBUTE7
 , ATTRIBUTE8 = l_ATTRIBUTE8
 , ATTRIBUTE9 = l_ATTRIBUTE9
 , ATTRIBUTE10 = l_ATTRIBUTE10
 , ATTRIBUTE11 = l_ATTRIBUTE11
 , ATTRIBUTE12 = l_ATTRIBUTE12
 , ATTRIBUTE13 = l_ATTRIBUTE13
 , ATTRIBUTE14 = l_ATTRIBUTE14
 , ATTRIBUTE15 = l_ATTRIBUTE15
 , CONTEXT     = l_CONTEXT
   Where rowid = l_row_id;

End Update_Allocation_batch;


Procedure Delete_Allocation_batch(
  l_Row_id                  IN VARCHAR2
 ) Is
Begin
  Delete From GL_AUTO_ALLOC_BATCHES
  Where RowId = l_Row_id;
  If (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
  End If;
End Delete_Allocation_batch;


Procedure Lock_allocation_batch
(
  l_Row_Id                      IN VARCHAR2
, l_ALLOCATION_SET_ID           IN NUMBER
, l_BATCH_ID                    IN NUMBER
, l_BATCH_TYPE_CODE             IN VARCHAR2
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_STEP_NUMBER                 IN NUMBER
, l_OWNER                       IN VARCHAR2
, l_ALLOCATION_METHOD_CODE      IN VARCHAR2
, l_ATTRIBUTE1                  IN VARCHAR2
, l_ATTRIBUTE2                  IN VARCHAR2
, l_ATTRIBUTE3                  IN VARCHAR2
, l_ATTRIBUTE4                  IN VARCHAR2
, l_ATTRIBUTE5                  IN VARCHAR2
, l_ATTRIBUTE6                  IN VARCHAR2
, l_ATTRIBUTE7                  IN VARCHAR2
, l_ATTRIBUTE8                  IN VARCHAR2
, l_ATTRIBUTE9                  IN VARCHAR2
, l_ATTRIBUTE10                 IN VARCHAR2
, l_ATTRIBUTE11                 IN VARCHAR2
, l_ATTRIBUTE12                 IN VARCHAR2
, l_ATTRIBUTE13                 IN VARCHAR2
, l_ATTRIBUTE14                 IN VARCHAR2
, l_ATTRIBUTE15                 IN VARCHAR2
, l_CONTEXT                     IN VARCHAR2
 ) IS
 CURSOR C IS
        SELECT *
        FROM   GL_AUTO_ALLOC_BATCHES
        WHERE  rowid = l_ROW_ID
        FOR UPDATE NOWAIT;
 Recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO Recinfo;

    If (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    End If;

    CLOSE C;

    If (
            Recinfo.ALLOCATION_SET_ID = l_ALLOCATION_SET_ID
        And Recinfo.BATCH_ID          = l_BATCH_ID
        And Recinfo.BATCH_TYPE_CODE   = l_BATCH_TYPE_CODE
        And Recinfo.STEP_NUMBER       = l_STEP_NUMBER
        And ( Recinfo.OWNER           = l_OWNER
              OR ( Recinfo.OWNER  IS NULL AND
                   l_OWNER IS NULL )
             )
         And ( Recinfo.ALLOCATION_METHOD_CODE     = l_ALLOCATION_METHOD_CODE
              OR (Recinfo.ALLOCATION_METHOD_CODE IS NULL AND
                  l_ALLOCATION_METHOD_CODE IS NULL )
             )
        And ( Recinfo.ATTRIBUTE1           = l_ATTRIBUTE1
              OR ( Recinfo.ATTRIBUTE1  IS NULL AND
                   l_ATTRIBUTE1 IS NULL ))
        And ( Recinfo.ATTRIBUTE2           = l_ATTRIBUTE2
              OR ( Recinfo.ATTRIBUTE2  IS NULL AND
                   l_ATTRIBUTE2 IS NULL ))
        And ( Recinfo.ATTRIBUTE3           = l_ATTRIBUTE3
              OR ( Recinfo.ATTRIBUTE3  IS NULL AND
                   l_ATTRIBUTE3 IS NULL ))
        And ( Recinfo.ATTRIBUTE4           = l_ATTRIBUTE4
              OR ( Recinfo.ATTRIBUTE4  IS NULL AND
                   l_ATTRIBUTE4 IS NULL ))
        And ( Recinfo.ATTRIBUTE5           = l_ATTRIBUTE5
              OR ( Recinfo.ATTRIBUTE5  IS NULL AND
                   l_ATTRIBUTE5 IS NULL ))
        And ( Recinfo.ATTRIBUTE6           = l_ATTRIBUTE6
              OR ( Recinfo.ATTRIBUTE6  IS NULL AND
                   l_ATTRIBUTE6 IS NULL ))
        And ( Recinfo.ATTRIBUTE7           = l_ATTRIBUTE7
              OR ( Recinfo.ATTRIBUTE7  IS NULL AND
                   l_ATTRIBUTE7 IS NULL ))
        And ( Recinfo.ATTRIBUTE8           = l_ATTRIBUTE8
              OR ( Recinfo.ATTRIBUTE8  IS NULL AND
                   l_ATTRIBUTE8 IS NULL ))
        And ( Recinfo.ATTRIBUTE9           = l_ATTRIBUTE9
              OR ( Recinfo.ATTRIBUTE9  IS NULL AND
                   l_ATTRIBUTE9 IS NULL ))
        And ( Recinfo.ATTRIBUTE10           = l_ATTRIBUTE10
              OR ( Recinfo.ATTRIBUTE10  IS NULL AND
                   l_ATTRIBUTE10 IS NULL ))
        And ( Recinfo.ATTRIBUTE11          = l_ATTRIBUTE11
              OR ( Recinfo.ATTRIBUTE11  IS NULL AND
                   l_ATTRIBUTE11 IS NULL ))
        And ( Recinfo.ATTRIBUTE12          = l_ATTRIBUTE12
              OR ( Recinfo.ATTRIBUTE12  IS NULL AND
                   l_ATTRIBUTE12 IS NULL ))
        And ( Recinfo.ATTRIBUTE13          = l_ATTRIBUTE13
              OR ( Recinfo.ATTRIBUTE13  IS NULL AND
                   l_ATTRIBUTE13 IS NULL ))
        And ( Recinfo.ATTRIBUTE14           = l_ATTRIBUTE14
              OR ( Recinfo.ATTRIBUTE14  IS NULL AND
                   l_ATTRIBUTE14 IS NULL ))
        And ( Recinfo.ATTRIBUTE15           = l_ATTRIBUTE15
              OR ( Recinfo.ATTRIBUTE15  IS NULL AND
                   l_ATTRIBUTE15 IS NULL ))
        And ( Recinfo.Context           = l_Context
              OR ( Recinfo.Context  IS NULL AND
                   l_Context IS NULL ))

        ) Then
            Return;
      Else
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.RAISE_EXCEPTION;
      End If;
 End Lock_allocation_batch;

 PROCEDURE Check_Unique_Step( l_rowid              IN  VARCHAR2
                             ,l_step_number        IN  NUMBER
                             ,l_allocation_set_id  IN  NUMBER
                             ,l_step_label        IN  VARCHAR2 ) IS
    Cursor c_dup IS
      Select 'Duplicate'
      From   gl_auto_alloc_batches r
      Where  r.step_number = l_step_number
      And    r.allocation_set_id = l_allocation_set_id
      And    ( l_rowid is NULL
               OR
               r.rowid <> l_rowid );

    dummy VARCHAR2(100);

  Begin
    Open  c_dup;
    Fetch c_dup Into dummy;

    If c_dup%FOUND THEN
      Close c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_ALLOC_DUP_STEP' );
      fnd_message.set_token('STEP_LABEL',
        l_step_label);
      app_exception.raise_exception;
    End If;

    Close c_dup;

  Exception
    When app_exceptions.application_exception THEN
      Raise;
    When Others THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_auto_alloc_batch_pkg.Check_Unique_Step');
      Raise;

 End Check_Unique_Step;

PROCEDURE Check_Unique_Batch( l_rowid              IN  VARCHAR2
                             ,l_allocation_set_id  IN  NUMBER
                             ,l_Batch_Id           IN  NUMBER
                             ,l_Batch_Type_Code    IN  VARCHAR2
                             ,l_Return_Code         IN OUT NOCOPY VARCHAR2 ) Is
    Cursor c_dup IS
      Select 'Duplicate'
      From   gl_auto_alloc_batches r
      Where  r.allocation_set_id = l_allocation_set_id
      And    r.Batch_Id          = l_Batch_Id
      And    r.Batch_Type_Code   = l_Batch_Type_Code
      And    ( l_rowid is NULL
               OR
               r.rowid <> l_rowid );

    dummy VARCHAR2(100);

  Begin
    Open  c_dup;
    Fetch c_dup Into dummy;

    If c_dup%FOUND THEN
      l_Return_Code := FAILURE;
    Else
      l_Return_Code := SUCCESS;
    End If;

    Close c_dup;

  Exception
    When app_exceptions.application_exception THEN
      Raise;
    When Others THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_auto_alloc_batch_pkg.Check_Unique_Batch');
      Raise;

 End Check_Unique_Batch;

Procedure get_step_status (
   p_request_Id      IN NUMBER
  ,p_step_number     IN NUMBER
  ,p_mode            IN VARCHAR2
  ,p_status          OUT NOCOPY VARCHAR2
  ) Is

 l_batch_type_code Varchar2(2);

 Cursor Get_Batch_Type_C IS
 Select Batch_Type_Code
 From   GL_AUTO_ALLOC_BATCH_HISTORY
 Where  REQUEST_ID = p_request_Id
 AND    STEP_NUMBER = p_step_number;

Begin
 If p_mode = 'SD' Then
     Open Get_Batch_Type_C;
     Fetch Get_Batch_Type_C
     into l_batch_type_code;

     If Get_Batch_Type_C%NOTFOUND Then
         p_status := NULL;
         Close Get_Batch_Type_C;
        return;
     End If;

     Close Get_Batch_Type_C;
 Else
   --doesn't matter for parallel or for request detail
   l_batch_type_code := 'A';
 End If;

   If l_batch_type_code in ('A','B','E','R') Then
        get_gl_step_status(
                      p_request_Id
                     ,p_step_number
                     ,p_mode
                     ,p_status);
   ElsIf l_batch_type_code = 'P' Then
       gl_pa_autoalloc_pkg.get_pa_step_status (
                      p_request_Id
                     ,p_step_number
                     ,p_mode
                     ,p_status);
   End If;
End get_step_status;


Procedure get_gl_step_status(
                          p_request_id    In  Number
                         ,p_step_number   In  Number
                         ,p_mode          In  Varchar2
                         ,p_status        Out NOCOPY Varchar2) Is

 l_meaning         Varchar2(80);
 l_description     Varchar2(240);
 l_status_code     Varchar2(30);
 l_lookup_code     Varchar2(30);
 l_request_id      Number := p_request_id;

 l_phase           Varchar2(30);
 l_status          Varchar2(30);
 l_dev_phase       Varchar2(30);
 l_dev_status      Varchar2(30);
 l_message         Varchar2(240);
 call_status       Boolean;

 Cursor Get_status_Code_C IS
 Select Status_Code
 From GL_AUTO_ALLOC_BATCH_HISTORY
 Where REQUEST_ID = p_request_Id
 AND   STEP_NUMBER = p_step_number;

 Cursor Get_Status_Meaning_C IS
 Select
  Meaning
 ,Description
 From gl_lookups
 Where LOOKUP_TYPE = 'AUTOALLOCATION_STATUS'
 And LOOKUP_CODE = l_lookup_code;

  Cursor get_request_id_C IS
  Select request_id
  From GL_AUTO_ALLOC_BAT_HIST_DET
  Where PARENT_REQUEST_ID = p_request_Id
  And STEP_NUMBER = p_step_number
  order by request_id desc;
Begin

If p_mode = 'SD' Then
  -- Mode is step-down
  If p_request_id is Null Or
     p_step_number is Null Then
     p_status := NULL;
     return;
  End If;

  Open Get_status_Code_C;
  Fetch Get_status_Code_C into l_status_code;
  If Get_status_Code_C%NOTFOUND Then
      p_status := NULL;
      Close Get_status_Code_C;
      return;
   End If;
   Close Get_status_Code_C;

   If l_status_code in ('VP','GP','PP','RPP') Then
      -- Find whether pending request is presently  running or completed
      Open get_request_id_C;
      Fetch get_request_id_C into l_request_id;
      Close get_request_id_C;

      call_status :=
           fnd_concurrent.get_request_status(
           l_request_Id
          ,'SQLGL'
          ,NULL
          ,l_phase
          ,l_status
          ,l_dev_phase
          ,l_dev_status
          ,l_message
        );

     If l_dev_phase = 'COMPLETE' AND
           l_dev_status In ('ERROR','CANCELLED','TERMINATED') Then
         If l_status_code = 'VP' Then
            l_status_code := 'VF';
         ElsIf l_status_code = 'GP' Then
            l_status_code := 'GF' ;
         ElsIf l_status_code = 'PP'  Then
            l_status_code := 'PF' ;
         ElsIf l_status_code = 'RPP'  Then
            l_status_code := 'RPF' ;
         End If;
     ElsIf l_dev_phase = 'COMPLETE' AND
           l_dev_status = 'NORMAL' Then
         If l_status_code = 'VP' Then
            l_status_code := 'VPC';
         ElsIf l_status_code = 'GP' Then
            l_status_code := 'GPC' ;
         ElsIf l_status_code = 'PP'  Then
            l_status_code := 'PPC' ;
         ElsIf l_status_code = 'RPP'  Then
            l_status_code := 'RPPC' ;
         End If;
      ElsIf l_dev_phase = 'RUNNING' AND
           l_dev_status in ('NORMAL')  Then
         If l_status_code = 'VP' Then
            l_status_code := 'VR';
         ElsIf l_status_code = 'GP' Then
            l_status_code := 'GR' ;
         ElsIf l_status_code = 'PP'  Then
            l_status_code := 'PR' ;
         ElsIf l_status_code = 'RPP'  Then
            l_status_code := 'RPR' ;
         End If;

      End If;
   End If;
   l_lookup_code := l_status_code;

   Open Get_Status_Meaning_C;
   Fetch Get_Status_Meaning_C into
      l_Meaning, l_description;

   If Get_Status_Meaning_C%NOTFOUND Then
      FND_MESSAGE.Set_Name('SQLGL', 'GL_AUTO_ALLOC_STATUS_ERR');
      p_status := FND_MESSAGE.Get;
      Close Get_Status_Meaning_C;
      return;
   Else
     Close Get_Status_Meaning_C;
     p_status := l_description;
   End If;
Else
  -- if not step down
   call_status :=
        fnd_concurrent.get_request_status(
           l_request_Id
          ,'SQLGL'
          ,NULL
          ,l_phase
          ,l_status
          ,l_dev_phase
          ,l_dev_status
          ,l_message
        );

       If l_dev_phase = 'COMPLETE' AND
          l_dev_status = 'NORMAL' Then
           p_status := l_dev_phase;
       ElsIf l_dev_phase = 'COMPLETE' AND
         l_dev_status <> 'NORMAL' Then
         p_status := l_dev_status;
       Else
         p_status := l_dev_phase;
       End If;
 End If;
End get_gl_step_status;

END gl_auto_alloc_batch_pkg;

/
