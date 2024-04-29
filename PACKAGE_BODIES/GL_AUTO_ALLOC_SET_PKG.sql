--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_SET_PKG" AS
/* $Header: glatalsb.pls 120.6 2006/01/24 22:38:17 xiwu ship $ */
SUCCESS CONSTANT VARCHAR2(1) := 'S';
FAILURE CONSTANT VARCHAR2(1) := 'F';

FUNCTION get_unique_set_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_auto_alloc_sets_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_AUTO_ALLOCATION_SET_ID_S');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_auto_alloc_set_pkg.get_unique_set_id');
      RAISE;
  END get_unique_set_id;



Procedure Insert_Allocation_Set(
 l_Row_Id            IN OUT NOCOPY VARCHAR2
, l_ALLOCATION_SET_ID           IN NUMBER
, l_ALLOCATION_SET_TYPE_CODE    IN VARCHAR2
, l_ALLOCATION_SET_NAME         IN VARCHAR2
, l_ALLOCATION_CODE             IN VARCHAR2
, l_CHART_OF_ACCOUNTS_ID        IN NUMBER
, l_PERIOD_SET_NAME             IN VARCHAR
, l_ACCOUNTED_PERIOD_TYPE       IN VARCHAR
, l_LAST_UPDATE_DATE            IN DATE
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_CREATION_DATE               IN DATE
, l_CREATED_BY                  IN NUMBER
, l_ORG_ID                      IN NUMBER
, l_DESCRIPTION                 IN VARCHAR2
, l_OWNER                       IN VARCHAR2
, l_SECURITY_FLAG               IN VARCHAR2
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
CURSOR C_SET IS
   SELECT rowid
   FROM GL_AUTO_ALLOC_SETS
   WHERE ALLOCATION_SET_ID = l_ALLOCATION_SET_ID;

Begin
 Insert Into GL_AUTO_ALLOC_SETS (
  ALLOCATION_SET_ID
, ALLOCATION_SET_TYPE_CODE
, ALLOCATION_SET_NAME
, ALLOCATION_CODE
, CHART_OF_ACCOUNTS_ID
, PERIOD_SET_NAME
, ACCOUNTED_PERIOD_TYPE
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, CREATION_DATE
, CREATED_BY
, ORG_ID
, DESCRIPTION
, OWNER
, SECURITY_FLAG
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
, l_ALLOCATION_SET_TYPE_CODE
, l_ALLOCATION_SET_NAME
, l_ALLOCATION_CODE
, l_CHART_OF_ACCOUNTS_ID
, l_PERIOD_SET_NAME
, l_ACCOUNTED_PERIOD_TYPE
, l_LAST_UPDATE_DATE
, l_LAST_UPDATED_BY
, l_LAST_UPDATE_LOGIN
, l_CREATION_DATE
, l_CREATED_BY
, l_ORG_ID
, l_DESCRIPTION
, l_OWNER
, l_SECURITY_FLAG
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
 Open C_SET;
 FETCH C_Set INTO l_Row_id ;
    If (C_SET%NOTFOUND) then
      CLOSE C_SET;
      Raise NO_DATA_FOUND;
    End If;
 CLOSE C_SET;

End Insert_Allocation_Set;

Procedure Update_Allocation_Set(
 l_Row_Id                      IN VARCHAR2
, l_ALLOCATION_SET_NAME         IN VARCHAR2
, l_LAST_UPDATE_DATE            IN DATE
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_DESCRIPTION                 IN VARCHAR2
, l_OWNER                       IN VARCHAR2
, l_SECURITY_FLAG               IN VARCHAR2
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
  Update GL_AUTO_ALLOC_SETS
  SET
   ALLOCATION_SET_NAME      = l_ALLOCATION_SET_NAME
 , LAST_UPDATE_DATE         = l_LAST_UPDATE_DATE
 , LAST_UPDATED_BY          = l_LAST_UPDATED_BY
 , LAST_UPDATE_LOGIN        = l_LAST_UPDATE_LOGIN
 , DESCRIPTION              = l_DESCRIPTION
 , OWNER                    = l_OWNER
 , SECURITY_FLAG            = l_SECURITY_FLAG
 , ATTRIBUTE1        = l_ATTRIBUTE1
 , ATTRIBUTE2        = l_ATTRIBUTE2
 , ATTRIBUTE3        = l_ATTRIBUTE3
 , ATTRIBUTE4        = l_ATTRIBUTE4
 , ATTRIBUTE5        = l_ATTRIBUTE5
 , ATTRIBUTE6        = l_ATTRIBUTE6
 , ATTRIBUTE7        = l_ATTRIBUTE7
 , ATTRIBUTE8        = l_ATTRIBUTE8
 , ATTRIBUTE9        = l_ATTRIBUTE9
 , ATTRIBUTE10       = l_ATTRIBUTE10
 , ATTRIBUTE11       = l_ATTRIBUTE11
 , ATTRIBUTE12       = l_ATTRIBUTE12
 , ATTRIBUTE13       = l_ATTRIBUTE13
 , ATTRIBUTE14       = l_ATTRIBUTE14
 , ATTRIBUTE15       = l_ATTRIBUTE15
 , CONTEXT           = l_CONTEXT
   Where rowid       = l_row_id;

End Update_Allocation_Set;

Procedure Lock_Allocation_Set(
  l_Row_Id                      IN VARCHAR2
, l_ALLOCATION_SET_ID           IN NUMBER
, l_ALLOCATION_SET_TYPE_CODE    IN VARCHAR2
, l_ALLOCATION_SET_NAME         IN VARCHAR2
, l_ALLOCATION_CODE             IN VARCHAR2
, l_CHART_OF_ACCOUNTS_ID        IN NUMBER
, l_PERIOD_SET_NAME             IN VARCHAR
, l_ACCOUNTED_PERIOD_TYPE       IN VARCHAR
, l_LAST_UPDATED_BY             IN NUMBER
, l_LAST_UPDATE_LOGIN           IN NUMBER
, l_CREATED_BY                  IN NUMBER
, l_DESCRIPTION                 IN VARCHAR2
, l_OWNER                       IN VARCHAR2
, l_SECURITY_FLAG               IN VARCHAR2
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
        FROM   GL_AUTO_ALLOC_SETS
        WHERE  rowid = l_ROW_ID
        FOR UPDATE NOWAIT;
 Recinfo C%ROWTYPE;
Begin
    Open C;
    Fetch C Into Recinfo;

    If (C%NOTFOUND) then
      Close C;
      Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
      App_Exception.Raise_Exception;
    End If;

    Close C;
    If (
            Recinfo.ALLOCATION_SET_ID      = l_ALLOCATION_SET_ID
        And Recinfo.CHART_OF_ACCOUNTS_ID   = l_CHART_OF_ACCOUNTS_ID
        And Recinfo.PERIOD_SET_NAME = l_PERIOD_SET_NAME
        And Recinfo.ACCOUNTED_PERIOD_TYPE = l_ACCOUNTED_PERIOD_TYPE
        And Recinfo.ALLOCATION_SET_NAME    = l_ALLOCATION_SET_NAME
        And Recinfo.ALLOCATION_SET_TYPE_CODE  = l_ALLOCATION_SET_TYPE_CODE
        AND Recinfo.SECURITY_FLAG = l_SECURITY_FLAG
        And ( Recinfo.DESCRIPTION            = l_DESCRIPTION
              OR  ( Recinfo.DESCRIPTION  IS NULL AND
                    l_DESCRIPTION IS NULL ))
        And ( Recinfo.OWNER                = l_OWNER
              OR ( Recinfo.OWNER  IS NULL AND
                   l_OWNER IS NULL ))
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
End Lock_Allocation_Set ;

Procedure Delete_Allocation_Set(
   l_allocation_set_id                  IN NUMBER
  ) Is
 Begin
    --delete batches
   DELETE From GL_AUTO_ALLOC_BATCHES
   Where Allocation_Set_Id = l_allocation_set_id;
   --Now delete set
   DELETE From GL_AUTO_ALLOC_SETS
   Where Allocation_Set_Id = l_allocation_set_id;

   If (SQL%NOTFOUND) then
       Raise NO_DATA_FOUND;
   End If;

End Delete_Allocation_Set;


  -- Procedure
  --   Get_Batch_Content
  -- Purpose
  --   Get summary level batch type and balance type info

  PROCEDURE Get_Set_Content(
                     X_Allocation_Set_Id                NUMBER,
                     X_Contain_Actual       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Budget       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Encumbrance  IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Recurring    IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Project      IN OUT NOCOPY      BOOLEAN,
                     X_Batch_Count          IN OUT NOCOPY      NUMBER
                    ) IS

      v_batch_type VARCHAR2(1);

      CURSOR get_type IS
        SELECT batch_type_code
        FROM   gl_auto_alloc_batches
        WHERE  allocation_set_id = X_Allocation_Set_Id;
  BEGIN
    X_Contain_Actual := FALSE;
    X_Contain_Budget := FALSE;
    X_Contain_Encumbrance := FALSE;
    X_Contain_Recurring := FALSE;
    X_Contain_Project := FALSE;
    X_Batch_Count := 0;

    OPEN get_type;

    LOOP
        FETCH get_type INTO v_batch_type;
        EXIT WHEN get_type%NOTFOUND;

        IF (v_batch_type = 'A') THEN
            X_Contain_Actual := TRUE;
        ELSIF (v_batch_type = 'B') THEN
            X_Contain_Budget := TRUE;
        ELSIF (v_batch_type = 'E') THEN
            X_Contain_Encumbrance := TRUE;
        ELSIF (v_batch_type = 'R') THEN
            --X_Contain_Actual := TRUE;
            X_Contain_Recurring := TRUE;
        ELSIF (v_batch_type = 'P') THEN
            X_Contain_Project := TRUE;
        END IF;

        X_Batch_Count := X_Batch_Count + 1;
    END LOOP;
    CLOSE get_type;

 END Get_Set_Content;

PROCEDURE Get_SetHistory_Content(
                     X_Request_Id           IN          NUMBER,
                     X_Contain_Actual       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Budget       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Encumbrance  IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Recurring    IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Project      IN OUT NOCOPY      BOOLEAN,
                     X_Batch_Count          IN OUT NOCOPY      NUMBER
                    ) IS

      v_batch_type VARCHAR2(1);

      CURSOR get_type IS
        SELECT batch_type_code
        FROM   gl_auto_alloc_batch_history
        WHERE  Request_Id = X_Request_Id;
  BEGIN
    X_Contain_Actual := FALSE;
    X_Contain_Budget := FALSE;
    X_Contain_Encumbrance := FALSE;
    X_Contain_Recurring := FALSE;
    X_Contain_Project := FALSE;
    X_Batch_Count := 0;

    OPEN get_type;

    LOOP
        FETCH get_type INTO v_batch_type;
        EXIT WHEN get_type%NOTFOUND;

        IF (v_batch_type = 'A') THEN
            X_Contain_Actual := TRUE;
        ELSIF (v_batch_type = 'B') THEN
            X_Contain_Budget := TRUE;
        ELSIF (v_batch_type = 'E') THEN
            X_Contain_Encumbrance := TRUE;
        ELSIF (v_batch_type = 'R') THEN
            X_Contain_Actual := TRUE;
            X_Contain_Recurring := TRUE;
        ELSIF (v_batch_type = 'P') THEN
            X_Contain_Project := TRUE;
        END IF;

        X_Batch_Count := X_Batch_Count + 1;
    END LOOP;
    CLOSE get_type;

 END Get_SetHistory_Content;


 FUNCTION set_random_ledger_id(X_Mode IN VARCHAR2,
                               X_Batch_Id IN NUMBER,
                               X_Ledger_Id IN NUMBER) RETURN NUMBER IS
   CURSOR random_batch IS
      SELECT batch_id,batch_type_code
      FROM   gl_auto_alloc_batches
      WHERE  allocation_set_id = x_batch_id
      ORDER BY (decode(batch_type_code, 'A', 1, 'R', 2, 'E', 3, 'P',4));

   CURSOR rje_ledger(random_bid number) IS
      SELECT ledger_id
      FROM   gl_recurring_headers
      WHERE  recurring_batch_id = random_bid;


    CURSOR ma_ledger (random_bid number) IS
      SELECT lgr.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers lgr
      WHERE  af.allocation_batch_id = random_bid
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    lsa.ledger_set_id (+) = nvl(afl.ledger_id, x_ledger_id)
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    lgr.ledger_id = nvl(lsa.ledger_id,
                                 nvl(afl.ledger_id, x_ledger_id))
      AND    lgr.object_type_code = 'L';

   CURSOR mb_ledger (random_bid number)IS
      SELECT lgr.ledger_id
      FROM   gl_alloc_formulas af,
             gl_alloc_formula_lines afl,
             gl_ledger_set_assignments lsa,
             gl_ledgers lgr
      WHERE  af.allocation_batch_id = random_bid
      AND    afl.allocation_formula_id = af.allocation_formula_id
      AND    afl.line_number IN (4, 5)
      AND    lsa.ledger_set_id (+) = afl.ledger_id
      AND    sysdate BETWEEN
                     nvl(trunc(lsa.start_date), sysdate - 1)
                 AND nvl(trunc(lsa.end_date), sysdate + 1)
      AND    lgr.ledger_id = nvl(lsa.ledger_id, afl.ledger_id)
      AND    lgr.object_type_code = 'L';

   random_id   NUMBER;
   random_bid  NUMBER;
   random_btype VARCHAR2(1);
  BEGIN

     IF (x_mode = 'AUTOSET') THEN

        OPEN random_batch;
        FETCH random_batch into random_bid, random_btype;
        CLOSE random_batch;

        IF(random_btype = 'R') THEN
           OPEN rje_ledger(random_bid);
           FETCH rje_ledger INTO random_id;
           CLOSE rje_ledger;
        ELSIF (random_btype = 'B') THEN
           OPEN mb_ledger(random_bid);
           FETCH mb_ledger INTO random_id;
           CLOSE mb_ledger;
        ELSIF (random_btype = 'A' or random_btype = 'E') THEN
           OPEN ma_ledger(random_bid);
           FETCH ma_ledger INTO random_id;
           CLOSE ma_ledger;
        END IF;

    ELSIF (x_mode = 'ALLOC') THEN

         random_bid := x_batch_id;
         OPEN ma_ledger(random_bid);
         FETCH ma_ledger INTO random_id;
         CLOSE ma_ledger;

    ELSIF (x_mode = 'RECUR' or x_mode = 'RECUR_BUDGET') THEN

         random_bid := x_batch_id;
         OPEN rje_ledger(random_bid);
         FETCH rje_ledger INTO random_id;
         CLOSE rje_ledger;

    ELSIF (x_mode = 'ALLOC_BUDGET') THEN

         random_bid := x_batch_id;
         OPEN mb_ledger(random_bid);
         FETCH mb_ledger INTO random_id;
         CLOSE mb_ledger;

    ELSE

         random_id := -1;

    END IF;

    RETURN random_id;
  END set_random_ledger_id;

FUNCTION Get_Alloc_Set_Name(X_Mode            IN   VARCHAR,
                            X_Alloc_Set_Id    IN   NUMBER) RETURN VARCHAR IS

      CURSOR get_set_name IS
        SELECT allocation_set_name
        FROM   gl_auto_alloc_sets
        WHERE  allocation_set_id = X_Alloc_Set_Id;

      CURSOR get_alloc_name IS
        SELECT name
        FROM   gl_alloc_batches
        WHERE  allocation_batch_id = X_Alloc_Set_Id;

      CURSOR get_rje_name IS
        SELECT name
        FROM   gl_recurring_batches
        WHERE  recurring_batch_id = X_Alloc_Set_Id;

     v_name VARCHAR2(40);
  BEGIN
    IF (X_mode = 'AUTOSET') THEN
         OPEN get_set_name;
         FETCH get_set_name INTO v_name;
         IF get_set_name%FOUND THEN
            CLOSE get_set_name;
            return(v_name);
         ELSE
            CLOSE get_set_name;
            return(null);
         END IF;
   ELSIF (X_mode = 'ALLOC' OR X_mode = 'ALLOC_BUDGET') THEN
          OPEN get_alloc_name;
         FETCH get_alloc_name INTO v_name;
         IF get_alloc_name%FOUND THEN
            CLOSE get_alloc_name;
            return(v_name);
         ELSE
            CLOSE get_alloc_name;
            return(null);
         END IF;
   ELSIF (X_mode = 'RECUR'OR X_Mode = 'RECUR_BUDGET') THEN
         OPEN get_rje_name;
         FETCH get_rje_name INTO v_name;
         IF get_rje_name%FOUND THEN
            CLOSE get_rje_name;
            return(v_name);
         ELSE
            CLOSE get_rje_name;
            return(null);
         END IF;
   ELSE
       return(null);

   END IF;

 EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_auto_alloc_set_pkg.get_alloc_set_name');
      RAISE;
 END Get_Alloc_Set_Name;

END gl_auto_alloc_set_pkg;

/
